package;

import flixel.FlxG;
import flixel.text.FlxBitmapText;
import flixel.group.FlxSpriteGroup.FlxSpriteGroup;

class CourseClearThing extends FlxSpriteGroup
{
    var world : World;

    var clearLabel : FlxBitmapText;
    var okLabel : FlxBitmapText;
    var cursor : FlxBitmapText;

    var selection : Int;

    public function new(World : World)
    {
        super(0, 0);

        world = World;

        clearLabel = text.PixelText.New(16, 0,  "COURSE CLEAR!");
        
        okLabel = text.PixelText.New(16 + 30, 16, "NICE");
        cursor = text.PixelText.New(16 + 24, 0, ">");

        add(clearLabel);
        add(okLabel);
        add(cursor);

        x = world.screencam.x + world.screencam.width / 2 - (16+13*6/*clearLabel.width*/) / 2;
        y = world.screencam.y + world.screencam.height * 0.3;

        selection = 0;
    }

    override public function update(elapsed : Float)
    {
        cursor.y = okLabel.y;

        clearLabel.color = 0xFFFFFFFF;
        okLabel.color = 0xFFFFFFFF;

        if (Gamepad.pressed(Gamepad.A))
        {
            okLabel.color = 0xFFbfce72;         
        }

        if (Gamepad.justReleased(Gamepad.A) || Gamepad.justReleased(Gamepad.Start))
        {
            GameController.EnterWorldMap();
        }

        super.update(elapsed);
    }
}