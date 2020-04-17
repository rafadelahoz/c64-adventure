package;

import flixel.FlxG;

class EnemySkeleton extends Enemy
{
    var red : Bool;
    var hspeed : Float;
    var vspeed : Float = 0.5;
    var direction : Float;

    public function new(X : Float, Y : Float, World : World, ?properties : haxe.DynamicAccess<Dynamic> = null)
    {
        super(X, Y, World);

        loadGraphic("assets/images/enemy-skeleton.png", true, 7, 14);
        animation.add("walk", [0, 1], 3);
        animation.play("walk");

        if (properties == null)
        {
            red = false;
            direction = FlxG.random.bool() ? -1 : 1;
        }
        else
        {
            var type : String = properties.get("type"); 
            red = (type != null && type == "RED");
            var facing : String = properties.get("facing");
            if (facing == null)
                direction = FlxG.random.bool() ? -1 : 1;
            else
                direction = (facing == "left" ? -1 : 1);
        }

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
    }

    override public function onUpdate(elapsed : Float)
    {
        if (!overlapsAt(x, y+1, world.platforms))
        {
            animation.pause();
            moveY(vspeed);
        }
        else if (hspeed != 0)
        {
            animation.resume();
            if (x + hspeed * direction < 0 || (x + width) + hspeed * direction >= world.right ||
                overlapsAt(x + hspeed * direction, y, world.hazards) ||  
                !overlapsAt(x + hspeed * direction + width * direction, y + 1, world.platforms))
            {
                x -= direction;
                changeDirection();
            }

            var switched : Bool = false;
            var xx = x;
            x += hspeed * direction;
            FlxG.overlap(this, world.enemies, function(me : EnemySkeleton, other : Enemy) {
                if (!switched && other != me)
                {
                    xx -= direction;
                    changeDirection();
                    switched = true;
                }
            });
            x = xx;
            
            moveX(hspeed * direction, function() {
                // Flip when hitting walls
                x -= direction;
                changeDirection();
            });
        }

        flipX = (direction < 0);

        super.onUpdate(elapsed);
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
        animation.curAnim.frameRate *= 3;
        hspeed = 0;
    }

    override public function damages(player : Player) : Int
    {
        return 1;
    }
}