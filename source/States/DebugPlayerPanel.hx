package;

import flixel.util.FlxTimer;
import flixel.FlxG;
import Inventory.ItemData;
import flixel.FlxSprite;
import text.PixelText;
import flixel.text.FlxBitmapText;
import flixel.group.FlxSpriteGroup;

class DebugPlayerPanel extends FlxSpriteGroup
{
    var colors : Array<Int>;

    var labels : Array<FlxBitmapText>;
    var current : Int;

    public function new(X : Float, Y : Float)
    {
        super(X, Y);

        colors = setupColors();

        text(0, 0, "!=============!");

        var char : Int = 1;
        var line : Int = 1;
        labels = [];
        for (color in colors)
        {
            labels.push(text(char, line, StringTools.hex(color), color));
            line++;
        }

        current = 0;
    }

    override public function update(elapsed : Float)
    {
        if (Gamepad.justPressed(Gamepad.Up))
        {
            current -= 1;
            if (current < 0)
                current = labels.length-1;
        }
        else if (Gamepad.justPressed(Gamepad.Down))
            current = (current+1) % labels.length;

        for (label in labels)
            label.color = 0xFFFFFFFF;
        
        labels[current].color = 0xFFFFde1a;

        if (Gamepad.justPressed(Gamepad.A))
        {
            GameStatus.playerColor = Std.parseInt(labels[current].text);

            timedText(Std.int((labels[current].x - x)/ 6), Std.int((labels[current].y - y) / 6), "CHOSEN!", 0.35);
        }

        super.update(elapsed);
    }

    function text(char : Int, line : Int, text : String, ?color : Int = 0xFFFFFFFF) : FlxBitmapText
    {
        var object : FlxBitmapText = PixelText.New(char * 6, line * 6, text, color);
        addObject(object);
        return object;
    }

    function timedText(char : Int, line : Int, text : String, ?color : Int = 0xFF0aff1a, duration : Float)
    {
        var object : FlxBitmapText = PixelText.New(char * 6, line * 6, text, color);
        addObject(object);
        new FlxTimer().start(duration, function(t:FlxTimer) {
            t.destroy();
            object.destroy();
        });
    }

    function addObject(object : FlxSprite)
    {
        // object.cameras = [world.hudcam];
        object.scrollFactor.set(0, 0);
        add(object);
    }

    function setupColors() : Array<Int>
    {
        var cs : Array<Int> = [];

        // Light colors
        cs.push(0xFF000000);
        cs.push(0xFFdfdfdf);
        cs.push(0xFFf7a8a2);
        cs.push(0xFF87d6dd);
        cs.push(0xFFea9ff6);
        cs.push(0xFF94e089);
        cs.push(0xFFbfb0ff);
        cs.push(0xFFbfce72);
        cs.push(0xFFeab489);
        cs.push(0xFFd7c178);
        cs.push(0xFFa8d978);
        cs.push(0xFFfca0bf);
        cs.push(0xFF82debf);
        cs.push(0xFF94cbf6);
        cs.push(0xFFd7a6ff);
        cs.push(0xFF87e2a2);

        // Dark colors
        cs.push(0xFF000000);
        cs.push(0xFF606060);
        cs.push(0xFF984942);
        cs.push(0xFF27777d);
        cs.push(0xFF8b3f96);
        cs.push(0xFF358029);
        cs.push(0xFF6051ac);
        cs.push(0xFF606f13);
        cs.push(0xFF8b5429);
        cs.push(0xFF776219);
        cs.push(0xFF487919);
        cs.push(0xFF9c4160);
        cs.push(0xFF237f60);
        cs.push(0xFF356b96);
        cs.push(0xFF7746a7);
        cs.push(0xFF278242);

        return cs;
    }
}