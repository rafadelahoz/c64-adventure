package;

import flixel.FlxG;
import flixel.text.FlxBitmapText;
import flixel.group.FlxSpriteGroup.FlxSpriteGroup;

class GameOverThing extends FlxSpriteGroup
{
    var world : World;

    var restartLabel : FlxBitmapText;
    var abandonLabel : FlxBitmapText;
    var cursor : FlxBitmapText;

    var selection : Int;

    public function new(World : World)
    {
        super(0, 0);

        world = World;

        restartLabel = text.PixelText.New(16, 0,  "AGAIN");
        abandonLabel = text.PixelText.New(16, 14, "TO MAP");
        cursor = text.PixelText.New(16-8, 0, ">");

        add(restartLabel);
        add(abandonLabel);
        add(cursor);

        x = FlxG.random.float(world.screencam.x, world.screencam.width - width);
        y = FlxG.random.float(world.screencam.y, world.screencam.height - height);

        selection = 0;
    }

    override public function update(elapsed : Float)
    {
        if (Gamepad.justPressed(Gamepad.Select))
            selection = (selection+1)%2;
        else if (Gamepad.justPressed(Gamepad.Down))
            selection = 1;
        else if (Gamepad.justPressed(Gamepad.Up))
            selection = 0;

        if (selection == 0)
            cursor.y = restartLabel.y;
        else 
            cursor.y = abandonLabel.y;

        restartLabel.color = 0xFFFFFFFF;
        abandonLabel.color = 0xFFFFFFFF;

        if (Gamepad.pressed(Gamepad.A))
        {
            if (selection == 0)
                restartLabel.color = 0xFFbfce72;
            else
                abandonLabel.color = 0xFFbfce72;
        }

        if (Gamepad.justReleased(Gamepad.A) || Gamepad.justReleased(Gamepad.Start))
        {
            if (selection == 0)
                GameController.RestartMap();
            else
                // TODO: Back to map selection
                GameController.RestartMap();
        }

        super.update(elapsed);
    }
}