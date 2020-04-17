package;

import flixel.FlxG;

class EnemyPlant extends Enemy
{
    public function new(X : Float, Y : Float, World : World, ?properties : haxe.DynamicAccess<Dynamic> = null)
    {
        super(X, Y, World);

        loadGraphic("assets/images/enemy-plant.png", true, 7, 14);
        animation.add("idle", [0, 1], FlxG.random.int(2, 4), false);
        animation.finishCallback = function(name : String) {
            flipX = !flipX;
            animation.play("idle");
        }

        animation.play("idle");
        animation.frameIndex = FlxG.random.int(0, 1);

        setSize(5, 10);
        centerOffsets();
        offset.y = 4;
        y += 4;

        if (properties == null || properties.get("color") == null)
            color = Palette.orange[3];
        else
            color = new MapReader().color(properties.get("color"));
    }

    override public function onCollisionWithPlayer(player : Player)
    {
        // Nop!
    }

    override public function onPlayerKilled()
    {
        animation.curAnim.frameRate *= 3;
    }

    override public function damages(player : Player) : Int
    {
        return 1;
    }
}