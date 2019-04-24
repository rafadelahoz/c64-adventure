package;

import openfl.events.KeyboardEvent;
import flixel.input.keyboard.FlxKey;
import flixel.input.FlxInput.FlxInputState;
import flixel.FlxG;

class Gamepad
{
    public static var A (default, never) : String = "A";
    public static var B (default, never) : String = "B";
    public static var Up (default, never) : String = "Up";
    public static var Right (default, never) : String = "Right";
    public static var Left (default, never) : String = "Left";
    public static var Down (default, never) : String = "Down";
    public static var Start (default, never) : String = "Start";

    public static function left() : Bool
    {
        return pressed(Gamepad.Left);
    }

    public static function right() : Bool
    {
        return pressed(Gamepad.Right);
    }

    public static function up() : Bool
    {
        return pressed(Gamepad.Up);
    }

    public static function down() : Bool
    {
        return pressed(Gamepad.Down);
    }

    public static function pressed(button : String) : Bool
    {
        var pressed : Bool = false;

        switch (button) {
            case Gamepad.A:
                pressed = FlxG.keys.checkStatus(FlxKey.A, FlxInputState.PRESSED);
            case Gamepad.B:
                return FlxG.keys.pressed.S;
            case Gamepad.Up:
                return FlxG.keys.pressed.UP;
            case Gamepad.Down:
                return FlxG.keys.pressed.DOWN;
            case Gamepad.Left:
                // return FlxG.keys.pressed.LEFT;
                pressed = FlxG.keys.checkStatus(FlxKey.LEFT, FlxInputState.PRESSED);
            case Gamepad.Right:
                // return FlxG.keys.pressed.RIGHT;
                pressed = FlxG.keys.checkStatus(FlxKey.RIGHT, FlxInputState.PRESSED);
            case Gamepad.Start:
                return FlxG.keys.pressed.ENTER;
        }

        return pressed;
    }

    public static function justPressed(button : String) : Bool
    {
        var justPressed : Bool = false;
        switch (button) {
            case Gamepad.A:
                justPressed = FlxG.keys.justPressed.A;
            case Gamepad.B:
                return FlxG.keys.justPressed.S;
            case Gamepad.Up:
                return FlxG.keys.justPressed.UP;
            case Gamepad.Down:
                return FlxG.keys.justPressed.DOWN;
            case Gamepad.Left:
                justPressed = FlxG.keys.justPressed.LEFT;
            case Gamepad.Right:
                justPressed = FlxG.keys.justPressed.RIGHT;
            case Gamepad.Start:
                return FlxG.keys.justPressed.ENTER;
        }

        return justPressed;
    }

    public static function justReleased(button : String) : Bool
    {
        var justReleased : Bool = false;
        switch (button) {
            case Gamepad.A:
                justReleased = FlxG.keys.justReleased.A;
            case Gamepad.B:
                return FlxG.keys.justReleased.S;
            case Gamepad.Up:
                return FlxG.keys.justReleased.UP;
            case Gamepad.Down:
                return FlxG.keys.justReleased.DOWN;
            case Gamepad.Left:
                justReleased = FlxG.keys.justReleased.LEFT;
            case Gamepad.Right:
                justReleased = FlxG.keys.justReleased.RIGHT;
            case Gamepad.Start:
                return FlxG.keys.justReleased.ENTER;
        }

        return justReleased;
    }

    public static function handleBufferedState(left : Bool, right : Bool, up : Bool, down : Bool, a : Bool)
    {
        // TODO: Generalize this (gamepad, etc)
        if (left)
            FlxG.stage.dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, true, 0, 37));
        if (right)
            FlxG.stage.dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, true, 0, 39));
        if (up)
            FlxG.stage.dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, true, 0, 38));
        if (down)
            FlxG.stage.dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, true, 0, 40));
        if (a)
            FlxG.stage.dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, true, 0, 65));
    }
}
