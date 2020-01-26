package;

import flixel.tile.FlxTileblock;
import flixel.FlxG;

class Solid extends Entity
{
    var ladderSprite : FlxTileblock;

    public function new(X : Float, Y : Float, Width : Float, Height : Float, World : World)
    {
        super(X, Y, World);

        ladderSprite = null;

        var c = 0x88FF0a00; // Full solid
        if (Height < 14)
            c = 0x8800FF0a; // One way solid
        if (Width < 7)
        {
            c = 0x88ffA00a; // Ladder
            ladderSprite = new FlxTileblock(Std.int(x-2), Std.int(y), 7, Std.int(Height));
            ladderSprite.loadTiles("assets/images/ladder.png", 7, 14);
            ladderSprite.color = c;
            makeGraphic(1, 1, 0x00000000);
        }
        else
            makeGraphic(Std.int(Width), Std.int(Height), c);

        setSize(Std.int(Width), Std.int(Height));

        visible = false;
    }

    override public function onUpdate(elapsed : Float)
    {
        if (FlxG.keys.justPressed.O)
            visible = !visible;
        if (ladderSprite != null)
            visible = true;

        super.onUpdate(elapsed);
    }

    override public function draw()
    {
        if (ladderSprite != null)
            ladderSprite.draw();
        
        super.draw();
    }
}
