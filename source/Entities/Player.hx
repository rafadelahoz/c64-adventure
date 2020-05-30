package;

import Inventory.ItemData;
import flixel.effects.FlxFlicker;
import flixel.group.FlxGroup.FlxTypedGroupIterator;
import flixel.util.FlxTimer;
import flixel.FlxBasic;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxObject;

import World.PlayerData;

enum State { Idle; Acting; Climb; Hurt; Dying; }

class Player extends Actor
{
    public static var Left : Int = -1;
    public static var Right : Int = 1;

    var HorizontalSpeed : Float = 0.65; // 0.5; // 1;
    var HorizontalAirFactor : Float = 0.7;
    var VerticalSpeed : Float = 4; // 3.3; // 6.6;
    var JumpReleaseSlowdownFactor : Float = 0.256;
    var Gravity : Float = 0.2; // 0.175; // 0.35;
    var MaxVspeed : Float = 8; // 12.5; // 25;
    var ClimbSpeed : Float = 1;
    var DoubleJumpFactor : Float = 0.85;

    var HorizontalAccel : Float = 0.2;
    var Friction : Float = 0.6;

    var CoyoteTime : Int = 6;
    var coyoteBuffer : Int = 0;

    public var state : State;

    var onAir : Bool;
    public var carrying : Item;

    public var hspeed : Float;
    public var vspeed : Float;

    public var haccel : Float;

    // Used for ground collision checks
    var groundProbe : Actor;

    // Reference to the ladder currently being climbed
    var ladder : Solid;

    var actingTimer : FlxTimer;
    var invulnerableTimer : FlxTimer;

    var InvulnerableDuration : Float = 2;
    public var invulnerable : Bool;

    // Testing area
    var shadow : FlxSprite;
    var pickCursor : FlxSprite;
    var pickCursorTimer : FlxTimer;
    var nearInteractable : Bool = false;
    var justPickedSomething : Bool = false;

    public var center : FlxPoint;

    public var debug (default, null) : Bool = false;

    public function new(PlayerData : PlayerData, World : World) {
        super(PlayerData.x, PlayerData.y, World);

        var g : Int = GameStatus.playerGraphic * 3;
        loadGraphic('assets/images/player-sheet.png', true, 11, 18);
        animation.add('idle', [g+0]);
        animation.add('walk', [g+1, g+0], 8);
        animation.add('jump', [g+1]);
        animation.add('act', [g+1]);
        animation.add('hurt', [g+2]);

        animation.play('idle');

        shadow = new FlxSprite(x, y);
        shadow.loadGraphic('assets/images/player-sheet-bg.png', true, 11, 18);
        shadow.animation.copyFrom(animation);
        shadow.color = new MapReader().color(world.roomData.colors[0]);

        setSize(5, 12);
        offset.set(3, 4);

        shadow.setSize(5, 12);
        shadow.offset.set(3, 4);

        refreshColor();

        hspeed = PlayerData.hspeed;
        vspeed = PlayerData.vspeed;

        debug = PlayerData.debug;

        haccel = 0;

        facing = PlayerData.facing;

        actingTimer = new FlxTimer();
        invulnerableTimer = new FlxTimer();

        carrying = null;

        invulnerable = false;

        center = FlxPoint.get();

        state = PlayerData.state;
        if (state == State.Climb)
        {
            // Initialize!
            var ladders : Array<Solid> = [];
            var iterator : FlxTypedGroupIterator<FlxBasic> = world.ladders.iterator();
            while (iterator.hasNext())
            {
                var aLadder : Solid = cast(iterator.next(), Solid);
                if (this.overlaps(aLadder))
                    ladders.push(aLadder);
            }

            ladder = findClosestLadder(ladders);
        }
        else if (state == State.Hurt)
        {
            actingTimer.start(PlayerData.actingTimerRemaining, onHurtTimer);
            if (PlayerData.invulnerableTimerRemaining > 0)
            {         
                invulnerable = true;
                invulnerableTimer.start(PlayerData.invulnerableTimerRemaining, function(_) {
                    invulnerable = false;
                });
            }
        }
        else
        {
            ladder = null;
        }

        groundProbe = new Actor(0, 0, world);
        groundProbe.makeGraphic(Std.int(width), 1, 0xFFFFFFFF);
        groundProbe.visible = false;
        world.add(groundProbe);

        pickCursor = new FlxSprite(-1000, -1000);
        pickCursor.loadGraphic("assets/images/fx-pick-cursor.png", true, 7, 14);
        pickCursor.animation.add("idle", [2, 3], 1);
        pickCursor.animation.play("idle");
        pickCursor.visible = false;
        pickCursor.solid = false;
    }

    override public function destroy()
    {
        world.remove(groundProbe);
        groundProbe.destroy();

        center.put();

        super.destroy();
    }

    public function refreshColor()
    {
        color = GameStatus.playerColor;
    }

    private function checkOnAir() : Bool
    {
        var onGround = groundProbe.overlaps(world.solids) || checkOnewaysGround();

        return !onGround;
    }

    function checkOnewaysGround(delta : Float = 0) : Bool
    {
        var onewaysGroundCheck : Bool = false;
        // = (groundProbe.overlaps(world.oneways) &&
        //        !groundProbe.overlapsAt(x, y+height-1, world.oneways))
        if (vspeed >= 0)
        {
            var oneways : Array<FlxBasic> = findOverlappingOneways();
            if (oneways.length > 0)
            {
                onewaysGroundCheck = true;
                for (oneway in oneways)
                {
                    if (groundProbe.overlapsAt(x, y+height-1, oneway))
                    {
                        onewaysGroundCheck = false;
                        break;
                    }
                }
            }
        }

        return onewaysGroundCheck;
    }

    function findOverlappingOneways() : Array<FlxBasic>
    {
        var oneways : Array<FlxBasic> = [];

        for (oneway in world.oneways) 
        {
            if (groundProbe.overlaps(oneway))
                oneways.push(oneway);
        }

        return oneways;
    }

    public function preupdate() : Void
    {
        world.ladders.forEach(function(ladder : FlxBasic) {
            cast(ladder, Solid).color = 0x88ffA00a;
        });
    }

    override public function onUpdate(elapsed : Float) : Void
    {
        var wasOnAir : Bool = onAir;
        onAir = checkOnAir();

        switch (state)
        {
            case State.Idle:
                if (!wasOnAir && onAir && coyoteBuffer == 0)
                {
                    coyoteBuffer = CoyoteTime;
                }

                if (onAir)
                {
                    if (!debug)
                        vspeed += Gravity;
                    if (coyoteBuffer > 0)
                    {
                        coyoteBuffer -= 1;
                    }
                } else {
                    vspeed = 0;
                    coyoteBuffer = 0;
                }

                /* Item management */
                
                // When carrying something
                if (carrying != null)
                {
                    // Drop carried thing when B is released
                    if (!Gamepad.pressed(Gamepad.B))
                    {
                        // repositionCarriedItem();
                        carrying.onRelease();
                        
                        // Reposition from center
                        // carrying.y -= 1;
                        // carrying.moveY(-3;
                        // carrying.moveY(3);

                        var deltaX : Float = 0;
                        var solidAtLeft : Bool = overlapsAt(x-7, y, world.solids);
                        var solidAtRight : Bool = overlapsAt(x+7, y, world.solids);
                        
                        if (solidAtLeft && solidAtRight)
                        {
                            var done : Bool = false;
                            // Slow positioning?
                            for (xx in Std.int(x+offset.x)...Std.int(x-3))
                            {
                                if (!overlapsAt(xx, y, world.solids))
                                {
                                    carrying.x = xx;
                                    done = true;
                                    break;
                                }
                            }

                            if (!done)
                            {
                                for (xx in Std.int(x-offset.x)...Std.int(x+3))
                                {
                                    if (!overlapsAt(xx, y, world.solids))
                                    {
                                        carrying.x = xx;
                                        done = true;
                                        break;
                                    }
                                }
                            }

                            if (!done)
                            {
                                // Can't position?
                                carrying.x = x;
                                trace("Positioning failed");
                            }
                        }
                        else if (solidAtLeft)
                        {
                            deltaX = carrying.x - (x + offset.x);
                            carrying.x = x + offset.x;
                        }
                        else if (solidAtRight)
                        {
                            deltaX = carrying.x - (x - offset.x);
                            carrying.x = x - offset.x;
                        }
                        carrying.moveX(deltaX);

                        carrying = null;
                    }
                }

                // Check for Interactables
                nearInteractable = false;
                if (!onAir && carrying == null)
                {
                    var interactables : Array<Entity> = [];
                    FlxG.overlap(this, world.npcs, function(self : Player, interactable : Interactable) {
                        interactable.setInteractable(false);
                        if (interactable.canInteractWithPlayer())
                            interactables.push(interactable);
                    });

                    var interactable : Interactable = cast(findClosestEntity(interactables), Interactable);
                    if (interactable != null)
                    {
                        interactable.setInteractable(true);
                        // nearInteractable = true;

                        if (Gamepad.justPressed(Gamepad.Up))
                        {
                            interactable.onInteract();
                        }
                    }
                }

                // Can pick things if there's no NPC
                // TODO: Assess if this works
                pickCursor.visible = false;
                justPickedSomething = false;
                if (!nearInteractable)
                {
                    world.hud.pickableItemLabel = "";
                    if (!onAir && Inventory.GetCurrent() == null 
                        && carrying == null) // TODO: Show pickable things when carrying?
                    {
                        var items : Array<Item> = [];
                        FlxG.overlap(this, world.items, function(self : Player, item : Item) {
                            if (item != carrying)
                                items.push(item);
                        });

                        var item : Item = findClosestItem(items);
                        if (item != null)
                        {
                            pickCursor.x = item.x + item.width / 2 - pickCursor.width / 2;
                            pickCursor.y = item.y - (pickCursor.height + 1);
                            pickCursor.visible = true;

                            world.hud.pickableItemLabel = item.data.label;
                            if (Gamepad.justPressed(Gamepad.B) && Inventory.Put(item.data))
                            {
                                item.onPickup();
                                item = null;
                                pickCursor.visible = false;
                                justPickedSomething = true;
                            }
                        }
                        else
                            pickCursor.visible = false;
                    }
                }

                // Entering things
                if (!onAir && (Gamepad.justPressed(Gamepad.Up)))
                {
                    // TODO: Level exits as doors?
                    // var activableExits : Array<Teleport> = [];

                    // Teleports
                    var activableTeleports : Array<Teleport> = [];
                    if (FlxG.overlap(this, world.teleports, function(self : Player, aTeleport : Teleport) {
                            activableTeleports.push(aTeleport);
                        })) 
                    {
                        var closest : Teleport = cast(findClosestEntity(cast(activableTeleports)));
                        closest.onTeleport();
                    }
                }

                // Ladder management
                if (!onAir && (Gamepad.up() || Gamepad.down()))
                {
                    ladder = null;

                    var ladders : Array<Solid> = [];
                    FlxG.overlap(this, world.ladders, function(self : Player, aLadder : Solid) {
                        aLadder.color = 0xFF00FF0a;
                        ladders.push(aLadder);
                    });
                    
                    var lowLadders : Array<Solid> = [];
                    FlxG.overlap(groundProbe, world.ladders, function(probe : FlxObject, aLadder : Solid) {
                        aLadder.color = 0xFF000aFF;
                        lowLadders.push(aLadder);
                    });

                    if (Gamepad.up())
                    {
                        ladder = findClosestLadder(ladders);
                    }
                    else if (Gamepad.down())
                    {
                        ladder = findClosestLadder(lowLadders);
                    }
                    
                    if (ladder != null)
                    {
                        xRemainder = 0;
                        hspeed = 0;
                        haccel = 0;
                        vspeed = 0;

                        if (Gamepad.down())
                        {
                            y++;
                            x = FlxMath.lerp(x, ladder.x+ladder.width/2 - width/2 , 0.35);
                        }

                        switchState(Climb);
                    }
                }
                
                if (state != Climb)
                {
                    if (Gamepad.left())
                    {
                        haccel = -HorizontalAccel * (onAir ? HorizontalAirFactor : 1);
                        facing = Left;
                    }
                    else if (Gamepad.right())
                    {
                        haccel = HorizontalAccel * (onAir ? HorizontalAirFactor : 1);
                        facing = Right;
                    }
                    else
                    {
                        haccel = 0;
                    }

                    // Special case: double jump shrimps
                    var carryingShrimp : Bool = (carrying != null && carrying.data.type == "SHRIMP");

                    if ((!onAir || coyoteBuffer > 0 || carryingShrimp) && Gamepad.justPressed(Gamepad.A))
                    {
                        vspeed = -VerticalSpeed;

                        // Make sure to only use the shrimp on a double jump
                        if (onAir && carryingShrimp) 
                        {
                            // Use the shrimp
                            world.add(new FxPuff(carrying.x + carrying.width/2, carrying.y + carrying.height/2, world));
                            carrying.destroy();
                            carrying = null;
                            vspeed *= DoubleJumpFactor;
                        }
                        
                        onAir = true;
                        coyoteBuffer = 0;
                    }
                    else if (onAir && vspeed < 0 && Gamepad.justReleased(Gamepad.A))
                    {
                        vspeed *= JumpReleaseSlowdownFactor;
                    }
                }

            case State.Climb:
                haccel = 0;
                hspeed = 0;
                
                if (ladder == null || !overlaps(ladder))
                {
                    ladder = null;
                    vspeed = 0;
                    switchState(State.Idle);
                }
                else
                {
                    ladder.color = 0xFFFFFFFF;

                    if (Gamepad.up())
                    {
                        vspeed = -ClimbSpeed;
                    }
                    else if (Gamepad.down())
                    {
                        // Allow climbing down when there's no ground below or there's still ladder
                        if (onAir || groundProbe.overlaps(ladder))
                            vspeed = ClimbSpeed;
                    }
                    else
                        vspeed = 0;

                    if (Gamepad.left())
                        facing = Left;
                    else if (Gamepad.right())
                        facing = Right;

                    if (!onAir && vspeed == 0 && (Gamepad.left() || Gamepad.right()))
                    {
                        vspeed = 0;
                        switchState(State.Idle);
                    }

                    // Reposition slowly
                    if (vspeed != 0)
                        x = FlxMath.lerp(x, ladder.x+ladder.width/2 - width/2 , 0.35);
                }
            case State.Hurt:
                if (facing == Left)
                    haccel = HorizontalAccel * 0.3;
                else
                    haccel = -HorizontalAccel * 0.3;

                if (onAir)
                    vspeed += Gravity;
            case State.Dying:
                vspeed = 0;
                hspeed = 0;
                haccel = 0;
            case State.Acting:
                // ?
                if (ladder != null)
                    vspeed = 0;
                else if (onAir)
                    vspeed += Gravity;

                if (!onAir)
                    haccel = 0;
        }

        // Things that may happen on any state (??)
        // Maybe think a bit more about this one
        if (!nearInteractable && !justPickedSomething && Gamepad.justPressed(Gamepad.B))
        {
            var item : ItemData = Inventory.GetCurrent();
            world.useItem(item);
        }
        
        hspeed += haccel;
        if (Math.abs(hspeed) > HorizontalSpeed)
        {
            hspeed = MathUtil.sign(hspeed) * HorizontalSpeed;
        }

        if (vspeed > MaxVspeed)
        {
            vspeed = MaxVspeed;
        }

        if (debug)
        {
            if (Gamepad.up())
                vspeed = -HorizontalSpeed;
            else if (Gamepad.down())
                vspeed = HorizontalSpeed;
            else vspeed = 0;

            if (Gamepad.left())
                hspeed = -HorizontalSpeed;
            else if (Gamepad.right())
                hspeed = HorizontalSpeed;
            else
                hspeed = 0;
            
            hspeed *= 2;
            vspeed *= 2;
        }

        var _hspeed : Float = hspeed;
        var _vspeed : Float = vspeed;

        moveX(_hspeed, onHorizontalCollision);
        moveY(_vspeed, onVerticalCollision);

        // Handle friction
        if (haccel == 0)
        {
            hspeed *= Friction;

            if (Math.abs(hspeed) < 0.1)
                hspeed = 0;
        }

        // Graphics
        switch (state)
        {
            case Idle:
                if (onAir)
                {
                    animation.play("jump");
                }
                else
                {
                    if (Math.abs(hspeed) > 0.6)
                        animation.play("walk")
                    else
                        animation.play("idle");
                }

                flipX = (facing == Left);
            case Climb:
                if (vspeed != 0)
                    animation.play("walk");
                else
                    animation.play("idle");
                
                flipX = (facing == Left);
            case Hurt:
                animation.play("hurt");
                flipX = (facing == Left);
            case Dying:
                animation.pause();
            case Acting:
                // ?
                animation.play("act");
        }

        shadow.animation.play(animation.curAnim.name);
        shadow.animation.paused = animation.paused;
        shadow.flipX = flipX;
        shadow.flipY = flipY;

        if (invulnerable)
            // flixel.util.FlxSpriteUtil.flicker(this);
            FlxFlicker.flicker(this, 0, true, false);
        else
            FlxFlicker.stopFlickering(this);
        
        // Debug zone
        #if (desktop || web)
        if (FlxG.keys.justPressed.G)
            debug = !debug;
        #end

        solid = (!debug);

        super.onUpdate(elapsed);

        shadow.update(elapsed);
        pickCursor.update(elapsed);

        handleAfterMovement();

        // groundProbe.update(elapsed);
    }

    public function handleAfterMovement()
    {
        groundProbe.x = x;
        groundProbe.y = y + height;

        shadow.x = x;
        shadow.y = y;

        getMidpoint(center);

        // Reposition carried item
        repositionCarriedItem();
    }

    function repositionCarriedItem()
    {
        repositionCarriedItemCustom();
        return;

        if (carrying != null)
        {
            if (facing == Left)
            {
                //carrying.moveX(x - carrying.width - carrying.x);
                // carrying.x = x - carrying.width;
                carrying.x = x;
                var delta = -carrying.width;
                carrying.moveX(delta);
            }
            else
            {
                // carrying.moveX(x + width - carrying.x);
                // carrying.x = x + width;
                carrying.x = x;
                var delta = width;
                carrying.moveX(delta);
            }

            // carrying.y = y + height/2 - carrying.height/2 - 2;
            carrying.y = y + height/2 - carrying.height/2;
            carrying.moveY(-4);
            carrying.moveY(1);
        }
    }

    function repositionCarriedItemCustom()
    {
        if (carrying != null)
        {
            var fallbackY : Float = carrying.y;

            var originX : Float = x;
            var targetX : Float = originX + (facing == Left ? -carrying.width : width);
            var deltaX : Int = (facing == Left ? 1 : -1);

            var originY = y + height/2 - carrying.height/2;
            var targetY : Float = originY - 3;
            var deltaY : Int = 1;

            carrying.x = targetX;
            var done : Bool = false;
            while (carrying.x != originX && !done)
            {
                carrying.y = targetY;
                while (carrying.y != originY && carrying.overlaps(world.solids))
                {
                    carrying.y += deltaY;
                }

                done = (!carrying.overlaps(world.solids));
                if (!done)
                    carrying.x += deltaX;
            }

            // If we didn't manage to place it properly,
            // fuck it, just place it at the initial height
            if (!done)
                carrying.y = fallbackY;

        }
    }

    override public function onPausedUpdate(elapsed : Float)
    {
        animation.pause();
    }

    override public function draw()
    {
        if (state != Dying)
            shadow.draw();
        
        super.draw();
        // groundProbe.draw();

        if (state != Dying && pickCursor.visible)
            pickCursor.draw();
    }

    // TODO: This to be configured by... item used?
    var ActingDuration : Float = 0.15;
    function switchState(newState : State)
    {
        switch (newState)
        {
            case Acting:
                actingTimer.start(ActingDuration, onActingTimer);
            case Hurt:
                actingTimer.start(HurtDuration, onHurtTimer);
            case Dying:
                invulnerable = false;
            default:
                // nothing
        }

        state = newState;
    }

    function onActingTimer(t : FlxTimer)
    {
        if (ladder == null)
            switchState(Idle);
        else
            switchState(Climb);
    }

    function onHurtTimer(t : FlxTimer)
    {
        switchState(Idle);
    }

    public function onUseItem(item : Item, ?willingly : Bool = true) : Bool
    {
        if (canUseItem(willingly))
        {
            carrying = item;
            item.onCarry();
            repositionCarriedItem();
            if (willingly)
                switchState(Acting);

            return true;
        }

        return false;
    }

    function canUseItem(?willingly : Bool = true)
    {
        // If not willingly, Player will always use the item
        return !willingly || willingly && state == State.Idle &&
                carrying == null;
    }

    function findClosestItem(items : Array<Item>) : Item
    {
        var item : Item = null;
        
        if (items.length > 0)
        {
            var midpoint : FlxPoint = getMidpoint();

            var distance : Float = Math.POSITIVE_INFINITY;
            for (i in items)
            {
                var point : FlxPoint = i.getMidpoint();
                
                if (midpoint.distanceTo(point) < distance)
                {
                    item = i;
                    distance = midpoint.distanceTo(point);
                } 
            }
        }

        return item;
    }

    function findClosestLadder(ladders : Array<Solid>) : Solid
    {
        var ladder : Solid = null;
        
        if (ladders.length > 0)
        {
            // Check X coordinates only
            var midpoint : FlxPoint = getMidpoint();

            var distance : Float = Math.POSITIVE_INFINITY;
            for (l in ladders)
            {
                l.color = 0xFF000aFF;
                var point : FlxPoint = l.getMidpoint();
                
                if (Math.abs(midpoint.x - point.x) < distance)
                {
                    ladder = l;
                    distance = Math.abs(midpoint.x - point.x);
                } 
            }
        }

        if (ladder != null)
            ladder.color = 0xFFFFFFFF;
        
        return ladder;
    }

    function findClosestEntity(entities : Array<Entity>) : Entity
    {
        var entity : Entity = null;
        
        if (entities.length > 0)
        {
            var midpoint : FlxPoint = getMidpoint();

            var distance : Float = Math.POSITIVE_INFINITY;
            for (i in entities)
            {
                var point : FlxPoint = i.getMidpoint();
                
                if (midpoint.distanceTo(point) < distance)
                {
                    entity = i;
                    distance = midpoint.distanceTo(point);
                } 
            }
        }

        return entity;
    }

    function onHorizontalCollision() : Void
    {
        hspeed = 0;
        haccel = 0;
        xRemainder = 0;
    }

    function onVerticalCollision() : Void
    {
        vspeed = 0;
    }

    public function onCollisionWithDanger(danger : IDangerous)
    {
        // die?
        if (state != State.Dying && (state != State.Hurt && !invulnerable || danger.ignoresInvincibility()))
        {
            var damage : Int = danger.damages(this);
            if (damage > -1)
            {
                if (LRAM.hp - damage <= 0)
                    handleDeath(cast(danger, FlxBasic));
                else
                    onHit(cast(danger, Entity), damage);
            }
                
        }
    }

    var HurtDuration : Float = 0.5;
    override public function onHit(by : Entity, ?damage : Int = 0)
    {
        if (!invulnerable)
        {
            LRAM.hp -= damage;

            if (by.x + by.width / 2 < x + width / 2)
                facing = Left;
            else
                facing = Right;

            hspeed = (facing == Right ? -1 : 1)*HorizontalSpeed*0.85;
            vspeed = -VerticalSpeed*0.366;

            invulnerable = true;
            invulnerableTimer.start(InvulnerableDuration, function(t:FlxTimer) {
                invulnerable = false;
            });

            switchState(Hurt);
        }
    }

    function handleDeath(?killer : FlxBasic = null)
    {
        LRAM.hp = 0;

        switchState(Dying);
        
        // Hide everything, change bg color
        world.onPlayerDead();

        // Make sure we are visible, ...
        visible = true;
        
        // ...also our carried item, ...
        if (carrying != null)
        {
            carrying.visible = true;
            world.add(carrying);
        }

        // ...and the killer as well
        if (killer != null)
        {
            killer.visible = true;
            world.add(killer);
            if (Std.is(killer, Enemy))
                cast(killer, Enemy).onPlayerKilled();
        }

        // Now wait for a tad
        new FlxTimer().start(1, function(t:FlxTimer) {

            // Puff!
            world.add(new FxPuff(x + width/2, y + height/2, world, true));

            // Then die
            destroy();
            if (carrying != null)
                carrying.destroy();

            // Then game over
            t.start(1, function(_t:FlxTimer) {
                _t.destroy();
                world.onPlayerDead(true);
            });
        });
    }

    public function triggerDeath()
    {
        handleDeath();
    }

    public function findGround()
    {
        // Store the starting point in case we fail
        var startY : Float = y;
        // Try to ground up to this point: 1.5 tiles
        var limitY : Float = startY + height * 1.5;
        
        while (checkOnAir() && y < limitY)
        {
            y++;
            groundProbe.y = y + height;
        }

        // In case there was no ground, get back to the starting point
        if (y >= limitY)
        {
            y = startY;
            groundProbe.y = y+height;
        }
    }

    public function getPlayerData() : PlayerData
    {
        return {
            x: x,
            y: y,
            facing : facing,
            state : state,
            actingTimerRemaining: actingTimer.timeLeft,
            invulnerableTimerRemaining: invulnerableTimer.timeLeft,
            hspeed : hspeed,
            vspeed : vspeed,
            debug: debug,
            carrying: (carrying == null ? null : carrying.data)
        };
    }

    public function getPlayerTeleportData() : PlayerData
    {
        return {
            x: x, y: y, facing: facing,
            state: State.Idle, hspeed: 0, vspeed: 0,
            actingTimerRemaining: 0,
            invulnerableTimerRemaining: 0,
            debug: debug,
            carrying: (carrying == null ? null : carrying.data)
        };
    }

    public static function getInitialPlayerData(x : Float, y : Float) : PlayerData
    {
        return {
            x: x, y : y,
            state : Player.State.Idle,
            facing : FlxObject.RIGHT,
            hspeed: 0,
            vspeed: 0,
            actingTimerRemaining: 0,
            invulnerableTimerRemaining: 0,
            debug: false,
            carrying: null
        };
    }
}
