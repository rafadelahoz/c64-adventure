package;

import flixel.FlxG;
import flixel.FlxSprite;

import World.PlayerData;

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

    var HorizontalAccel : Float = 0.2;
    var Friction : Float = 0.6;

    var CoyoteTime : Int = 6;
    var coyoteBuffer : Int = 0;

    var onAir : Bool;

    public var hspeed : Float;
    public var vspeed : Float;

    public var haccel : Float;

    var groundProbe : FlxSprite;

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

        hspeed = PlayerData.hspeed;
        vspeed = PlayerData.vspeed;

        debug = PlayerData.debug;

        haccel = 0;

        facing = PlayerData.facing;

        groundProbe = new FlxSprite(0, 0);
        groundProbe.makeGraphic(Std.int(width), 1, 0xFFFFFFFF);
        groundProbe.visible = false;
        groundProbe.solid = false;

        FlxG.watch.add(this, "hspeed");
        FlxG.watch.add(this, "vspeed");
        FlxG.watch.add(this, "xRemainder");
        FlxG.watch.add(this, "yRemainder");
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

    override public function update(elapsed : Float) : Void
    {
        var wasOnAir : Bool = onAir;
        onAir = checkOnAir();

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
        if (slowdown) {
            _hspeed *= Constants.SlowdownFactor;
            _vspeed *= Constants.SlowdownFactor;
        }

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

        // Debug zone
        if (FlxG.keys.justPressed.G)
            debug = !debug;
        /*if (coyoteBuffer > 0)
            color = 0xFF000aFF;
        // else if (onAir)
        //     color = 0xFF0aFF00;
        else
            color = 0xFFFFFFFF;*/

        solid = (!debug);

        groundProbe.x = x;
        groundProbe.y = y + height;

        super.update(elapsed);
        groundProbe.update(elapsed);
    }

    override public function draw()
    {
        super.draw();
        // groundProbe.draw();
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
