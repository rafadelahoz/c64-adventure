package;

import flixel.effects.FlxFlicker;

class FallingSolid extends Solid
{
    static final StatusIdle : Int = 0;
    static final StatusWarn : Int = 1;
    static final StatusFall : Int = 2;

    var WarnTime : Float = 1.235;
    var Gravity : Float = 0.2; // 0.175; // 0.35;
    var MaxVspeed : Float = 8;
    var vspeed : Float;

    var status : Int;
    // TODO: Only works for 7x14 solids for now
    public function new(X : Float, Y : Float, Width : Float, Height : Float, World : World)
    {
        super(X, Y, Width, Height, World);
        
        status = StatusIdle;
    }

    override function handleGraphic(?Width : Float = -1, ?Height : Float = -1)
    {
        loadGraphic("assets/images/items.png", true, 7, 14);
        animation.add("idle", [3]);
        animation.play("idle");

        color = 0xFF7869c4;
    }

    override public function onUpdate(elapsed : Float)
    {
        switch (status)
        {
            case StatusIdle:
                if (!overlaps(world.player) && overlapsAt(x, y-1, world.player) && world.player.vspeed >= 0)
                {
                    status = StatusWarn;
                    // FlxFlicker.flicker(this, 0, 0.02);
                    alpha = 0.5;
                    wait(WarnTime, startFalling);
                }
            case StatusWarn:
                // Nothing to do here
            case StatusFall:
                vspeed += Gravity;
                if (vspeed > MaxVspeed)
                {
                    vspeed = MaxVspeed;
                }

                move(0, vspeed);

                if (y > world.bottom)
                {
                    destroy();
                    return;
                }
        }

        super.onUpdate(elapsed);
    }

    function startFalling() 
    {
        status = StatusFall;
        // FlxFlicker.stopFlickering(this);
        alpha = 1;
        vspeed = 0;
    }
}