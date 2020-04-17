package;

import flixel.FlxCamera;
import flixel.tile.FlxTilemap;

class Tilemap extends FlxTilemap
{
    public function new()
    {
        super();
    }

    override public function drawDebugOnCamera(camera : FlxCamera) : Void
    {
        // NOP!
    }
}