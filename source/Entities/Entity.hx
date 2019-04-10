package;

import flixel.FlxSprite;

class Entity extends FlxSprite
{
    var world : World;

    public function new(X : Float, Y : Float, World : World)
    {
        super(X, Y);
        world = World;

        moves = false;
    }

    override public function update(elapsed : Float) : Void
    {
        super.update(elapsed);
    }
}
