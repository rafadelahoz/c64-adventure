package;

import flixel.FlxG;

class EnemySkeleton extends Enemy
{
    var red : Bool;
    var hspeed : Float;
    var vspeed : Float = 0.5;
    var direction : Float;

    public function new(X : Float, Y : Float, World : World)
    {
        super(X, Y, World);

        loadGraphic("assets/images/enemy-skeleton.png", true, 7, 14);
        animation.add("walk", [0, 1], 3);
        animation.play("walk");

        red = FlxG.random.bool();
        if (red)
        {
            color = Palette.red[5];
            hspeed = 0.35;
            animation.curAnim.frameRate = 6;
        }
        else
        {
            color = Palette.white[7];
            hspeed = 0.05;
        }

        direction = FlxG.random.bool() ? -1 : 1; // right
    }

    override public function onUpdate(elapsed : Float)
    {
        if (!overlapsAt(x, y+1, world.platforms))
        {
            animation.pause();
            moveY(vspeed);
        }
        else
        {
            animation.resume();
            if (x + hspeed * direction < 0 || (x + width) + hspeed * direction >= world.right ||
                overlapsAt(x + hspeed * direction, y, world.hazards) ||  
                red && !overlapsAt(x + hspeed * direction + width * direction, y + 1, world.platforms))
            {
                direction *= -1;
            }

            var switched : Bool = false;
            var xx = x;
            x += hspeed * direction;
            FlxG.overlap(this, world.enemies, function(me : EnemySkeleton, other : Enemy) {
                if (!switched && other != me)
                {
                    direction *= -1;
                    xx += direction;
                    switched = true;
                }
            });
            x = xx;
            
            moveX(hspeed * direction, function() {
                // Flip when hitting walls
                x += direction;
                direction *= -1;
            });

            flipX = (direction < 0);
        }

        super.onUpdate(elapsed);
    }

    override public function onPlayerKilled()
    {
        animation.curAnim.frameRate *= 3;
        hspeed = 0;
    }

    override public function damages(player : Player) : Int
    {
        return 1;
    }
}