package;

import flixel.math.FlxPoint;
import flixel.util.FlxTimer;
import flixel.FlxSprite;
import flixel.FlxG;

class EnemyFrog extends Enemy
{
    static final StateIdle : Int = 0;
    static final StateCrouch : Int = 1;
    static final StateJump : Int = 2;

    var Gravity : Float = 0.2; // 0.175; // 0.35;
    var Speed : Float = 0.5;
    var JumpPower : Float = 3.64647;

    var SightRadius : Float = 21;
    var IdleTime : Float = 1;
    var CrouchTime : Float = 0.5352;

    var hspeed : Float;
    var vspeed : Float;
    var direction : Float;

    var groundProbe : FlxSprite;

    var state : Int;

    var timer : FlxTimer;

    public function new(X : Float, Y : Float, World : World, ?properties : haxe.DynamicAccess<Dynamic> = null)
    {
        super(X, Y, World);

        // loadGraphic("assets/images/enemy-frog.png", true, 7, 14);
        loadGraphic("assets/images/enemy-skeleton.png", true, 7, 14);
        animation.add("idle", [0]);
        animation.add("crouch", [1]);
        animation.add("jump", [2]);

        animation.play("idle");

        setSize(5, 12);
        centerOffsets();
        offset.y = 2;

        direction = FlxG.random.bool() ? -1 : 1;

        if (properties == null || properties.get("color") == null)
            color = Palette.green[5];
        else
            color = new MapReader().color(properties.get("color"));

        groundProbe = new FlxSprite(0, 0);
        groundProbe.makeGraphic(Std.int(width), 1, 0xFFFFFFFF);
        groundProbe.visible = false;
        world.add(groundProbe);

        timer = new FlxTimer();
        
        switchState(StateIdle);
    }

    override public function destroy()
    {
        world.remove(groundProbe);
        groundProbe.destroy();
        
        world.enemies.remove(this);
        super.destroy();
    }

    override public function onUpdate(elapsed : Float)
    {
        if (timer != null)
        {
            switch (state)
            {
                case StateIdle:
                    hspeed = 0;
                    if (checkOnAir())
                    {
                        timer.active = false;
                        vspeed += Gravity;
                        animation.play("jump");
                    }
                    else
                    {
                        timer.active = true;
                        vspeed = 0;
                        animation.play("idle");

                        // TODO: Face player if close
                        if (getMidpoint().distanceTo(world.player.getMidpoint()) <= SightRadius)
                        {
                            if (world.player.getMidpoint().x < getMidpoint().x)
                                direction = -1;
                            else
                                direction = 1;
                        }
                    }
                case StateCrouch:
                    hspeed = 0;
                    vspeed = 0;
                    animation.play("crouch");
                case StateJump:
                    vspeed += Gravity;
                    animation.play("jump");
            }

            moveX(hspeed * direction, function() {
                direction *= -1;
            });

            moveY(vspeed, function() {
                if (vspeed < 0)
                    vspeed = 0;
                else
                    switchState(StateIdle);
            });

            flipX = (direction < 0);
        }
        else
        {
            animation.play("idle");
        }

        super.onUpdate(elapsed);

        groundProbe.x = x;
        groundProbe.y = y + height;
    }

    function switchState(toState : Int)
    {
        switch (toState)
        {
            case StateIdle:
                timer.start(fuzzy(IdleTime), function(_) {
                    switchState(StateCrouch);
                });
            case StateCrouch:
                timer.start(fuzzy(CrouchTime), function(_) {
                    switchState(StateJump);
                });
            case StateJump:
                vspeed = -fuzzy(JumpPower);
                hspeed = fuzzy(Speed);
        }

        state = toState;
    }

    function fuzzy(value : Float) : Float
    {
        return FlxG.random.float(value*0.9, value*1.1);
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

    function changeDirection()
    {
        animation.pause();
        animation.frameIndex = 0;
        var tmp : Float = hspeed;
        hspeed = 0;
        wait(0.25, function() {
            direction *= -1;
            wait(0.25, function() {
                hspeed = tmp;
                animation.resume();
            });
        });
    }

    override public function onPlayerKilled()
    {
        timer.cancel();
        timer.destroy();
        timer = null;
        state = StateIdle;
    }

    override public function damages(player : Player) : Int
    {
        return 1;
    }
}