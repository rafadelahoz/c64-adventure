package;

import flixel.effects.FlxFlicker;
import DebugSubstate.BlurDirection;
import flixel.FlxSprite;
import text.PixelText;
import flixel.text.FlxBitmapText;
import flixel.group.FlxSpriteGroup;

class DebugSwitchesPanel extends FlxSpriteGroup
{
    var substate : DebugSubstate;

    var switches : Array<FlxBitmapText>;
    var current : Int;

    var focused : Bool;

    public function new(X : Float, Y : Float, DebugState : DebugSubstate)
    {
        super(X, Y);

        substate = DebugState;

        text(0, 0, "@=============@");

        switches = [];
        var char : Int = 1;
        var line : Int = 1;
        for (sw in GameStatus.switches.keys())
        {
            switches.push(text(char, line, sw));
            line++;
        }

        current = 0;

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
            if (Gamepad.justPressed(Gamepad.Left))
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

    function addObject(object : FlxSprite)
    {
        // object.cameras = [world.hudcam];
        object.scrollFactor.set(0, 0);
        add(object);
    }
}