package;

import flixel.group.FlxSpriteGroup;
import flixel.FlxSprite;

class Hud extends FlxSpriteGroup
{
    var bgImage : FlxSprite;

    public function new()
    {
        super(0, 0);

        bgImage = new FlxSprite(0, 0, "assets/images/temp-hud.png");
        add(bgImage);
    }
}