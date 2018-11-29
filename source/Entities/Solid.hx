package;

import flixel.FlxObject;

class Solid extends Entity
{
    public function new(X : Float, Y : Float, Width : Float, Height : Float, World : World)
    {
        super(X, Y, World);

        var c = 0xFFFF0a00;
        if (Height < 16)
            c = 0xFF00FF0a;

        makeGraphic(Std.int(Width), Std.int(Height), c);
    }
}
