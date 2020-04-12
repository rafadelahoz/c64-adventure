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

        #if (desktop || web)
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
                pressed = pressed || (gamepad != null && (gamepad.pressed.GUIDE || gamepad.pressed.Y));
        }
        #end

        return pressed;
    }

    public static function justPressed(button : String) : Bool
    {
        var justPressed : Bool = false;

        var gamepad : FlxGamepad = FlxG.gamepads.lastActive;

        #if (desktop || web)
        switch (button) {
            case Gamepad.A:
                justPressed = FlxG.keys.justPressed.A;
                justPressed = justPressed || (gamepad != null && gamepad.justPressed.A);
            case Gamepad.B:
                justPressed = FlxG.keys.justPressed.S;
                justPressed = justPressed || (gamepad != null && gamepad.justPressed.X);
            case Gamepad.Up:
                justPressed = FlxG.keys.justPressed.UP;
                justPressed = justPressed || (gamepad != null && (gamepad.justPressed.LEFT_STICK_DIGITAL_UP || gamepad.justPressed.LEFT_STICK_DIGITAL_UP));
            case Gamepad.Down:
                justPressed = FlxG.keys.justPressed.DOWN;
                justPressed = justPressed || (gamepad != null && (gamepad.justPressed.LEFT_STICK_DIGITAL_DOWN || gamepad.justPressed.LEFT_STICK_DIGITAL_DOWN));
            case Gamepad.Left:
                justPressed = FlxG.keys.justPressed.LEFT;
                justPressed = justPressed || (gamepad != null && (gamepad.justPressed.LEFT_STICK_DIGITAL_LEFT || gamepad.justPressed.LEFT_STICK_DIGITAL_LEFT));
            case Gamepad.Right:
                justPressed = FlxG.keys.justPressed.RIGHT;
                justPressed = justPressed || (gamepad != null && (gamepad.justPressed.LEFT_STICK_DIGITAL_RIGHT || gamepad.justPressed.LEFT_STICK_DIGITAL_RIGHT));
            case Gamepad.Start:
                justPressed = FlxG.keys.justPressed.ENTER;
                justPressed = justPressed || (gamepad != null && gamepad.justPressed.START);
            case Gamepad.Select:
                justPressed = FlxG.keys.justPressed.SPACE;
                justPressed = justPressed || (gamepad != null && (gamepad.justPressed.GUIDE || gamepad.justPressed.Y));
        }
        #end

        return justPressed;
    }

    public static function justReleased(button : String) : Bool
    {
        var justReleased : Bool = false;

        var gamepad : FlxGamepad = FlxG.gamepads.lastActive;

        #if (desktop || web)
        switch (button) {
            case Gamepad.A:
                justReleased = FlxG.keys.justReleased.A;
                justReleased = justReleased || (gamepad != null && gamepad.justReleased.A);
            case Gamepad.B:
                justReleased = FlxG.keys.justReleased.S;
                justReleased = justReleased || (gamepad != null && gamepad.justReleased.X);
            case Gamepad.Up:
                justReleased = FlxG.keys.justReleased.UP;
                justReleased = justReleased || (gamepad != null && (gamepad.justReleased.LEFT_STICK_DIGITAL_UP || gamepad.justReleased.LEFT_STICK_DIGITAL_UP));
            case Gamepad.Down:
                justReleased = FlxG.keys.justReleased.DOWN;
                justReleased = justReleased || (gamepad != null && (gamepad.justReleased.LEFT_STICK_DIGITAL_DOWN || gamepad.justReleased.LEFT_STICK_DIGITAL_DOWN));
            case Gamepad.Left:
                justReleased = FlxG.keys.justReleased.LEFT;
                justReleased = justReleased || (gamepad != null && (gamepad.justReleased.LEFT_STICK_DIGITAL_LEFT || gamepad.justReleased.LEFT_STICK_DIGITAL_LEFT));
            case Gamepad.Right:
                justReleased = FlxG.keys.justReleased.RIGHT;
                justReleased = justReleased || (gamepad != null && (gamepad.justReleased.LEFT_STICK_DIGITAL_RIGHT || gamepad.justReleased.LEFT_STICK_DIGITAL_RIGHT));
            case Gamepad.Start:
                justReleased = FlxG.keys.justReleased.ENTER;
                justReleased = justReleased || (gamepad != null && gamepad.justReleased.START);
            case Gamepad.Select:
                justReleased = FlxG.keys.justReleased.SPACE;
                justReleased = justReleased || (gamepad != null && (gamepad.justReleased.GUIDE || gamepad.justReleased.Y));
        }
        #end

        return justReleased;
    }
}
