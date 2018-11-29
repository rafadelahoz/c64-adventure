package;

import flixel.FlxSprite;

class Entity extends FlxSprite
{
    var world : World;

    var slowdown : Bool;

    public function new(X : Float, Y : Float, World : World)
    {
        super(X, Y);
        world = World;

        moves = false;

        slowdown = false;
    }

    override public function update(elapsed : Float) : Void
    {
        super.update(elapsed);
    }

    public function beginSlowdown() : Void
    {
        slowdown = true;
    }

    public function endSlowdown() : Void
    {
        slowdown = false;
    }
}
