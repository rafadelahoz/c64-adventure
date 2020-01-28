package;

import flixel.input.gamepad.FlxGamepad;
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
    public static var Select (default, never) : String = "Select";

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

        var gamepad : FlxGamepad = FlxG.gamepads.lastActive;

        switch (button) {
            case Gamepad.A:
                pressed = FlxG.keys.checkStatus(FlxKey.A, FlxInputState.PRESSED);
                pressed = pressed || (gamepad != null && gamepad.pressed.A);
            case Gamepad.B:
                pressed = FlxG.keys.pressed.S;
                pressed = pressed || (gamepad != null && gamepad.pressed.X);
            case Gamepad.Up:
                pressed = FlxG.keys.pressed.UP;
                pressed = pressed || (gamepad != null && (gamepad.pressed.LEFT_STICK_DIGITAL_UP || gamepad.pressed.LEFT_STICK_DIGITAL_UP));
            case Gamepad.Down:
                pressed = FlxG.keys.pressed.DOWN;
                pressed = pressed || (gamepad != null && (gamepad.pressed.LEFT_STICK_DIGITAL_DOWN || gamepad.pressed.LEFT_STICK_DIGITAL_DOWN));
            case Gamepad.Left:
                pressed = FlxG.keys.checkStatus(FlxKey.LEFT, FlxInputState.PRESSED);
                pressed = pressed || (gamepad != null && (gamepad.pressed.LEFT_STICK_DIGITAL_LEFT || gamepad.pressed.LEFT_STICK_DIGITAL_LEFT));
            case Gamepad.Right:
                pressed = FlxG.keys.checkStatus(FlxKey.RIGHT, FlxInputState.PRESSED);
                pressed = pressed || (gamepad != null && (gamepad.pressed.LEFT_STICK_DIGITAL_RIGHT || gamepad.pressed.LEFT_STICK_DIGITAL_RIGHT));
            case Gamepad.Start:
                pressed = FlxG.keys.pressed.ENTER;
                pressed = pressed || (gamepad != null && (gamepad.pressed.START || gamepad.pressed.START));
            case Gamepad.Select:
                pressed =  FlxG.keys.pressed.SPACE;
                pressed = pressed || (gamepad != null && (gamepad.pressed.BACK || gamepad.pressed.BACK));
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
            case Gamepad.Select:
                return FlxG.keys.justPressed.SPACE;
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
            case Gamepad.Select:
                return FlxG.keys.justReleased.SPACE;
        }

        return justReleased;
    }

    public static function handleBufferedState(left : Bool, right : Bool, up : Bool, down : Bool, a : Bool, b : Bool)
    {
        // TODO: Generalize this (gamepad, etc)
        // TODO: Maybe this only works for windows??
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
        if (b)
            FlxG.stage.dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, true, 0, 83));
    }
}
