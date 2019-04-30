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

    public function onPause() {}

    public function onUnpause() {}

    public function onUpdate(elapsed : Float)
    {
        super.update(elapsed);
    }

    public function onPausedUpdate(elapsed : Float)
    {
        super.update(elapsed);
    }

    override public function update(elapsed : Float) : Void
    {
        if (!world.paused)
            onUpdate(elapsed);
        else
            onPausedUpdate(elapsed);        
    }
}
