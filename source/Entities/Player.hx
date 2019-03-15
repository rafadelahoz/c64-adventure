package;

import flixel.FlxG;
import flixel.FlxSprite;

class Player extends Actor
{
    var HorizontalSpeed : Float = 1;
    var HorizontalAirFactor : Float = 0.7;
    var VerticalSpeed : Float = 6.6;
    var JumpReleaseSlowdownFactor : Float = 0.256;
    var Gravity : Float = 0.35;
    var MaxVspeed : Float = 25;

    var HorizontalAccel : Float = 0.2;
    var Friction : Float = 0.6;

    var CoyoteTime : Int = 6;
    var coyoteBuffer : Int = 0;

    var onAir : Bool;

    var hspeed : Float;
    var vspeed : Float;

    var haccel : Float;

    var groundProbe : FlxSprite;

    var debug : Bool = false;

    public function new(X : Float, Y : Float, World : World) {
        super(X, Y, World);

        makeGraphic(7, 14, 0xFFFFFFFF);

        hspeed = 0;
        vspeed = 0;

        haccel = 0;

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
        }
        else if (Gamepad.right())
        {
            haccel = HorizontalAccel * (onAir ? HorizontalAirFactor : 1);
        }
        else
        {
            haccel = 0;
        }

        if (debug)
        {
            if (Gamepad.up())
                vspeed = -1;
            else if (Gamepad.down())
                vspeed = 1;
            else vspeed = 0;
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
        }

        if (vspeed > MaxVspeed)
        {
            vspeed = MaxVspeed;
        }

        // Debug zone
        if (coyoteBuffer > 0)
            color = 0xFF000aFF;
        else if (onAir)
            color = 0xFF0aFF00;
        else
            color = 0xFFFFFFFF;

        groundProbe.x = x;
        groundProbe.y = y + height;

        super.update(elapsed);
        groundProbe.update(elapsed);
    }

    override public function draw()
    {
        super.draw();
        groundProbe.draw();
    }

    function onHorizontalCollision() : Void
    {
        hspeed = 0;
        haccel = 0;
    }

    function onVerticalCollision() : Void
    {
        vspeed = 0;
    }
}
