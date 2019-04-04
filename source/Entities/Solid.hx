package;

import flixel.FlxObject;

class Solid extends Entity
{
    public function new(X : Float, Y : Float, Width : Float, Height : Float, World : World)
    {
        super(X, Y, World);

        var c = 0x88FF0a00;
        if (Height < 14)
            c = 0x8800FF0a;

        makeGraphic(Std.int(Width), Std.int(Height), c);
    }
}
