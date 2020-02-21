package;

import flixel.FlxState;

class Boot extends FlxState
{

    override public function create() : Void
    {
        super.create();

        bgColor = 0xFF000000;

        Palette.Init();

        text.PixelText.Init();

        GameController.Init();
        GameController.EnterWorldMap();
    }
}