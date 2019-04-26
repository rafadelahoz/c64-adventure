package;

import flixel.FlxG;

class LockSolid extends Solid
{
    var lockId : String;
    var lockColor : Int;

    var closed : Bool;
    var closedWidth : Int;
    var closedHeight : Int;

    public function new(X : Float, Y : Float, Width : Float, Height : Float, World : World)
    {
        super(X, Y, Width, Height, World);

        makeGraphic(Std.int(Width), Std.int(Height), 0xFFFFFFFF);
        flixel.util.FlxSpriteUtil.drawRect(this, 1, 1, Width-2, Height-2, 0x00000000, {
            thickness: 1, color: 0xFF000000
        });

        closed = false;
        closedWidth = Std.int(width);
        closedHeight = Std.int(height);
    }

    public function init(id : String, ?color : Int = -1)
    {
        lockId = id;
        lockColor = color;

        // TODO: Check lram in order to close/unclose

        closed = true;
    }

    override public function update(elapsed : Float)
    {
        if (!closed)
        {
            visible = false;
            solid = false;

            width = 0;
            height = 0;
        }
        else
        {
            visible = true;
            solid = true;

            width = closedWidth;
            height = closedHeight;

            FlxG.overlap(this, world.items, function(self : LockSolid, item : Item) {
                if (item.data.type == "KEY")
                {
                    // TODO: Check color
                    if (closed)
                    {
                        closed = false;
                        item.destroy();
                    }
                }
            });
        }

        super.update(elapsed);
    }
}