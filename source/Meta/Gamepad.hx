package;

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
        switch (button) {
            case Gamepad.A:
                return FlxG.keys.pressed.A;
            case Gamepad.B:
                return FlxG.keys.pressed.S;
            case Gamepad.Up:
                return FlxG.keys.pressed.UP;
            case Gamepad.Down:
                return FlxG.keys.pressed.DOWN;
            case Gamepad.Left:
                return FlxG.keys.pressed.LEFT;
            case Gamepad.Right:
                return FlxG.keys.pressed.RIGHT;
            case Gamepad.Start:
                return FlxG.keys.pressed.ENTER;
        }

        return false;
    }

    public static function justPressed(button : String) : Bool
    {
        switch (button) {
            case Gamepad.A:
                return FlxG.keys.justPressed.A;
            case Gamepad.B:
                return FlxG.keys.justPressed.S;
            case Gamepad.Up:
                return FlxG.keys.justPressed.UP;
            case Gamepad.Down:
                return FlxG.keys.justPressed.DOWN;
            case Gamepad.Left:
                return FlxG.keys.justPressed.LEFT;
            case Gamepad.Right:
                return FlxG.keys.justPressed.RIGHT;
            case Gamepad.Start:
                return FlxG.keys.justPressed.ENTER;
        }

        return false;
    }

    public static function justReleased(button : String) : Bool
    {
        switch (button) {
            case Gamepad.A:
                return FlxG.keys.justReleased.A;
            case Gamepad.B:
                return FlxG.keys.justReleased.S;
            case Gamepad.Up:
                return FlxG.keys.justReleased.UP;
            case Gamepad.Down:
                return FlxG.keys.justReleased.DOWN;
            case Gamepad.Left:
                return FlxG.keys.justReleased.LEFT;
            case Gamepad.Right:
                return FlxG.keys.justReleased.RIGHT;
            case Gamepad.Start:
                return FlxG.keys.justReleased.ENTER;
        }

        return false;
    }
}
