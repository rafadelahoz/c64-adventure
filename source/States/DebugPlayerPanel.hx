package;

import flixel.effects.FlxFlicker;
import DebugSubstate.BlurDirection;
import flixel.util.FlxTimer;
import flixel.FlxG;
import Inventory.ItemData;
import flixel.FlxSprite;
import text.PixelText;
import flixel.text.FlxBitmapText;
import flixel.group.FlxSpriteGroup;

class DebugPlayerPanel extends FlxSpriteGroup
{
    var substate : DebugSubstate;

    var colors : Array<Int>;
    var lightColors : Array<Int>;
    var darkColors : Array<Int>;

    var labels : Array<FlxBitmapText>;
    var current : Int;
    var cursor : FlxBitmapText;

    var focused : Bool;

    public function new(X : Float, Y : Float, DebugState : DebugSubstate)
    {
        super(X, Y);

        substate = DebugState;

        text(0, 0, "!=============!");

        setupColors();
        
        var char : Int = 1;
        var line : Int = 1;
        labels = [];
        for (color in colors)
        {
            labels.push(text(char, line, "0x" + StringTools.hex(color), color));
            line++;
        }

        cursor = text(0, 0, ">");

        current = 0;
        cursor.x = labels[current].x - cursor.width;
        cursor.y = labels[current].y;

        focused = false;
    }

    public function focus()
    {
        focused = true;
        FlxFlicker.flicker(this, 0.25);
    }

    public function blur()
    {
        focused = false;
    }    

    override public function update(elapsed : Float)
    {
        if (focused)
        {
            if (Gamepad.justPressed(Gamepad.Up))
            {
                current -= 1;
                if (current < 0)
                    current = labels.length-1;
            }
            else if (Gamepad.justPressed(Gamepad.Down))
                current = (current+1) % labels.length;

            cursor.x = labels[current].x - cursor.width;
            cursor.y = labels[current].y;

            if (Gamepad.justPressed(Gamepad.A))
            {
                GameStatus.playerColor = Std.parseInt(labels[current].text);
                substate.world.player.refreshColor();

                timedText(Std.int((labels[current].x - x)/ 6), Std.int((labels[current].y - y) / 6), "CHOSEN!", 0.35);
            }
            else if (Gamepad.justPressed(Gamepad.B))
            {
                if (colors == lightColors)
                    colors = darkColors;
                else
                    colors = lightColors;

                rebuildColorList();
            }
            else if (Gamepad.justPressed(Gamepad.Left))
                substate.onPanelBlur(this, BlurDirection.Left);
            else if (Gamepad.justPressed(Gamepad.Right))
                substate.onPanelBlur(this, BlurDirection.Right);
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
    
    function rebuildColorList()
    {
        var index : Int = 0;
        while (index < labels.length)
        {
            labels[index].text = "0x" + StringTools.hex(colors[index]);
            labels[index].color = colors[index];
            index++;
        }
    }

    function setupColors()
    {
        // Light colors
        lightColors = [];
        lightColors.push(0xFF000000);
        lightColors.push(0xFFdfdfdf);
        lightColors.push(0xFFf7a8a2);
        lightColors.push(0xFF87d6dd);
        lightColors.push(0xFFea9ff6);
        lightColors.push(0xFF94e089);
        lightColors.push(0xFFbfb0ff);
        lightColors.push(0xFFbfce72);
        lightColors.push(0xFFeab489);
        lightColors.push(0xFFd7c178);
        lightColors.push(0xFFa8d978);
        lightColors.push(0xFFfca0bf);
        lightColors.push(0xFF82debf);
        lightColors.push(0xFF94cbf6);
        lightColors.push(0xFFd7a6ff);
        lightColors.push(0xFF87e2a2);

        // Dark colors
        darkColors = [];
        darkColors.push(0xFF000000);
        darkColors.push(0xFF606060);
        darkColors.push(0xFF984942);
        darkColors.push(0xFF27777d);
        darkColors.push(0xFF8b3f96);
        darkColors.push(0xFF358029);
        darkColors.push(0xFF6051ac);
        darkColors.push(0xFF606f13);
        darkColors.push(0xFF8b5429);
        darkColors.push(0xFF776219);
        darkColors.push(0xFF487919);
        darkColors.push(0xFF9c4160);
        darkColors.push(0xFF237f60);
        darkColors.push(0xFF356b96);
        darkColors.push(0xFF7746a7);
        darkColors.push(0xFF278242);

        colors = lightColors;
    }
}