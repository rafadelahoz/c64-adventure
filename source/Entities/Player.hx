package;

import flixel.FlxBasic;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxObject;

import World.PlayerData;

enum State { Idle; Move; Air; Climb; }

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

    public var hspeed : Float;
    public var vspeed : Float;

    public var haccel : Float;

    var groundProbe : FlxSprite;

    var ladder : Solid;

    public var debug (default, null) : Bool = false;

    public function new(PlayerData : PlayerData, World : World) {
        super(PlayerData.x, PlayerData.y, World);

        loadGraphic('assets/images/player-sheet.png', true, 11, 18);
        animation.add('idle', [0]);
        animation.add('walk', [1, 0], 8);
        animation.add('jump', [1]);

        animation.play('idle');

        setSize(5, 12);
        offset.set(3, 4);

        color = GameStatus.playerColor;

        hspeed = PlayerData.hspeed;
        vspeed = PlayerData.vspeed;

        debug = PlayerData.debug;

        haccel = 0;

        facing = PlayerData.facing;

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

    override public function update(elapsed : Float) : Void
    {
        var wasOnAir : Bool = onAir;
        onAir = checkOnAir();

        switch (state)
        {
            case State.Idle, State.Move, State.Air:
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

                // Item management
                if (!onAir && Gamepad.down())
                {
                    var items : Array<Item> = [];
                    FlxG.overlap(this, world.items, function(self : Player, item : Item) {
                        items.push(item);
                    });

                    var item = findClosestItem(items);
                    // Inventory.
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

                        state = Climb;
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
                    state = State.Idle;
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
                        state = State.Idle;
                    }

                    // Reposition slowly
                    if (vspeed != 0)
                        x = FlxMath.lerp(x, ladder.x+ladder.width/2 - width/2 , 0.35);
                }
            default:
                trace("Don't know what to do with state = " + state);
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
            case Idle, Move, Air:
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
        }
        
        // Debug zone
        if (FlxG.keys.justPressed.G)
            debug = !debug;

        solid = (!debug);

        groundProbe.x = x;
        groundProbe.y = y + height;

        super.update(elapsed);

        groundProbe.x = x;
        groundProbe.y = y + height;

        // groundProbe.update(elapsed);
    }

    override public function draw()
    {
        super.draw();
        // groundProbe.draw();
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
}
