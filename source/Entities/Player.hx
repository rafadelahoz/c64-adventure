package;

import flixel.util.FlxSpriteUtil;
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
    static var Left : Int = -1;
    static var Right : Int = 1;

    var HorizontalSpeed : Float = 0.65; // 0.5; // 1;
    var HorizontalAirFactor : Float = 0.7;
    var VerticalSpeed : Float = 4; // 3.3; // 6.6;
    var JumpReleaseSlowdownFactor : Float = 0.256;
    var Gravity : Float = 0.2; // 0.175; // 0.35;
    var MaxVspeed : Float = 15; // 12.5; // 25;
    var ClimbSpeed : Float = 1;

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
    var groundProbe : FlxSprite;

    // Reference to the ladder currently being climbed
    var ladder : Solid;

    var actingTimer : FlxTimer;
    var invulnerableTimer : FlxTimer;

    var InvulnerableDuration : Float = 1;
    var invulnerable : Bool;

    public var debug (default, null) : Bool = false;

    public function new(PlayerData : PlayerData, World : World) {
        super(PlayerData.x, PlayerData.y, World);

        loadGraphic('assets/images/player-sheet.png', true, 11, 18);
        animation.add('idle', [0]);
        animation.add('walk', [1, 0], 8);
        animation.add('jump', [1]);
        animation.add('act', [1]);
        animation.add('hurt', [2]);

        animation.play('idle');

        setSize(5, 12);
        offset.set(3, 4);

        color = GameStatus.playerColor;

        hspeed = PlayerData.hspeed;
        vspeed = PlayerData.vspeed;

        debug = PlayerData.debug;

        haccel = 0;

        facing = PlayerData.facing;

        actingTimer = new FlxTimer();
        invulnerableTimer = new FlxTimer();

        state = PlayerData.state;
        if (state == State.Climb)
        {
            // Initialize!
            var ladders : Array<Solid> = [];
            FlxG.overlap(this, world.ladders, function(self : Player, aLadder : Solid) {
                aLadder.color = 0xFF00FF0a;
                ladders.push(aLadder);
            });

            ladder = findClosestLadder(ladders);
        }
        else
        {
            ladder = null;
        }

        // TODO: Read from PlayerData
        carrying = null;

        invulnerable = false;

        groundProbe = new FlxSprite(0, 0);
        groundProbe.makeGraphic(Std.int(width), 1, 0xFFFFFFFF);
        groundProbe.visible = false;
        world.add(groundProbe);
    }

    private function checkOnAir() : Bool
    {
        var onGround =
            groundProbe.overlaps(world.solids) ||
            (vspeed >= 0 &&
                (groundProbe.overlaps(world.oneways) &&
                !groundProbe.overlapsAt(x, y+height-1, world.oneways)));

        return !onGround;
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
                        carrying.onRelease();
                        // Reposition from center
                        carrying.y += 1;

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

                // TODO: Can pickup while carrying?
                if (!onAir && Gamepad.justPressed(Gamepad.Down))
                {
                    var items : Array<Item> = [];
                    FlxG.overlap(this, world.items, function(self : Player, item : Item) {
                        if (item != carrying)
                            items.push(item);
                    });

                    var item : Item = findClosestItem(items);
                    if (item != null && Inventory.Add(item.data))
                    {
                        item.onPickup();
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

                    if ((!onAir || coyoteBuffer > 0) && Gamepad.justPressed(Gamepad.A))
                    {
                        vspeed = -VerticalSpeed;
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

        if (invulnerable)
            flixel.util.FlxSpriteUtil.flicker(this);
        else
            FlxSpriteUtil.stopFlickering(this);
        
        // Debug zone
        if (FlxG.keys.justPressed.G)
            debug = !debug;

        solid = (!debug);

        super.onUpdate(elapsed);

        groundProbe.x = x;
        groundProbe.y = y + height;

        // Reposition carried item
        if (carrying != null)
        {
            if (facing == Left)
                //carrying.moveX(x - carrying.width - carrying.x);
                carrying.x = x - carrying.width;
            else
                // carrying.moveX(x + width - carrying.x);
                carrying.x = x + width;

            // carrying.moveY(y + height/2 - carrying.height/2 - 2 - carrying.y);
            carrying.y = y + height/2 - carrying.height/2 - 2;
        }

        // groundProbe.update(elapsed);
    }

    override public function onPausedUpdate(elapsed : Float)
    {
        animation.pause();
    }

    override public function draw()
    {
        super.draw();
        // groundProbe.draw();
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

    public function onUseItem(item : Item) : Bool
    {
        if (canUseItem())
        {
            carrying = item;
            item.onCarry();
            switchState(Acting);

            return true;
        }

        return false;
    }

    function canUseItem()
    {
        return (state == State.Idle) &&
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

    public function onCollisionWithHazard(hazard : Hazard)
    {
        // die?
        if (state != State.Hurt && state != State.Dying && !invulnerable)
        {
            var damage : Int = hazard.damages(this);
            if (damage > -1)
            {
                if (LRAM.hp - damage < 0)
                    handleDeath(hazard);
                else
                    onHit(damage, hazard);
            }
                
        }
    }

    var HurtDuration : Float = 0.5;
    public function onHit(damage : Int, by : Entity)
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
        }

        // Now wait for a tad
        new FlxTimer().start(1, function(t:FlxTimer) {
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

    public function getPlayerData(goingUp : Bool) : PlayerData
    {
        return {
            x: x,
            y: y,
            facing : facing,
            state : state,
            hspeed : hspeed,
            vspeed : vspeed,
            leftPressed: Gamepad.left(),
            rightPressed: Gamepad.right(),
            upPressed: Gamepad.up(),
            downPressed: Gamepad.down(),
            // Only allow jump buffering when going up
            jumpPressed: goingUp && Gamepad.pressed(Gamepad.A),
            actionPressed: Gamepad.pressed(Gamepad.B),
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
            leftPressed: false, rightPressed: false, upPressed: false, downPressed: false, 
            jumpPressed: false, actionPressed: false,
            debug: false,
            carrying: null
        };
    }
}
