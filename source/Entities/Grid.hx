package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxSpriteUtil;

class Grid extends FlxSprite
{
    var world : World;

    var w : Int = 200;
    var h : Int = 200;

    var tw : Int = 7;
    var th : Int = 14;

    var cx : Int = -1;
    var cy : Int = -1;

    var cursor : FlxSprite;

    public function new(World : World)
    {
        super(0, 0);

        world = World;

        makeGraphic(w*tw, h*th, 0x00000000);
        redraw();

        cursor = new FlxSprite(0, 0).makeGraphic(tw, th, 0x55FFFF00);
    }

    override public function update(elapsed : Float)
    {
        #if (desktop || web)
        var camx : Float = FlxG.mouse.screenX+2;
        var camy : Float = FlxG.mouse.screenY-7;

        var wx : Float = Std.int(camx/world.screencam.scaleX + world.screencam.scroll.x);
        var wy : Float = Std.int(camy + world.screencam.scroll.y);

        cx = Std.int(wx/tw);
        cy = Std.int(wy/th);

        cursor.x = cx*tw;
        cursor.y = cy*th;
        #end

        super.update(elapsed);

        cursor.update(elapsed);
    }

    override public function draw()
    {
        super.draw();
        cursor.draw();
    }

    function redraw()
    {
        FlxSpriteUtil.fill(this, 0x00000000);
        return;

        for (c in 0...w)
        {
            for (r in 0...h)
            {
                FlxSpriteUtil.drawRect(this, c*tw, r*th, tw-1, th-1, 0x00000000, {color: 0xFF777777, thickness: 1});
            }
        }
    }
}
