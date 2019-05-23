package;

import flixel.text.FlxBitmapText;
import flixel.group.FlxGroup;
import lime.utils.AssetType;
import lime.utils.Assets;
import flixel.FlxState;

import text.PixelText;

class MapListRoom extends FlxState
{
    var labelGroup : FlxGroup;
    var labels : Array<FlxBitmapText>;

    var cursor : FlxBitmapText;
    var current : Int;

    override public function create() : Void
    {
        super.create();

        bgColor = 0xFF000000;

        labelGroup = new FlxGroup();
        add(labelGroup);

        labels = [];

        var textAssets : Array<String> = Assets.list(AssetType.TEXT);
        textAssets = textAssets.filter(function (assetName : String) : Bool {
            return assetName.indexOf("assets/maps/") > -1;
        });

        var rexp = ~/.*\/(.*?).json/;
        var xx : Int = 16;
        var yy : Int = 8;
        var label : String = null;
        var entity : FlxBitmapText = null;

        for (textAsset in textAssets) {
            rexp.match(textAsset);
            label = rexp.matched(1);
            entity = PixelText.New(xx, yy, label);
            labelGroup.add(entity);
            labels.push(entity);
            yy += 8;
        }

        cursor = PixelText.New(5, 3, ">");
        add(cursor);

        current = 0;
        // Start the cursor in the current map
        for (label in labels)
        {
            if (label.text == GameStatus.map)
                break;
            else
                current++;
        }

        if (current >= labels.length)
            current = 0;
    }

    override public function update(elapsed : Float)
    {
        if (Gamepad.justPressed(Gamepad.Up))
            current = (current-1)%labels.length;
        else if (Gamepad.justPressed(Gamepad.Down))
            current = (current+1)%labels.length;

        for (label in labels)
        {
            label.color = 0xFF777777;
        }

        if (labels[current] != null)
        {
            cursor.y = labels[current].y;
            labels[current].color = 0xFFffffff;

            if (Gamepad.justPressed(Gamepad.A) || Gamepad.justPressed(Gamepad.Start))
            {
                GameController.SetCurrentMap(labels[current].text);
                GameController.EnterMap();
            }
        }

        super.update(elapsed);
    }
}