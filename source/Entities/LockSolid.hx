package;

import flixel.util.FlxTimer;
import flixel.FlxG;

class LockSolid extends Solid
{
    var lockId : String;
    var lockColor : Int;

    var closed : Bool;
    var closedWidth : Int;
    var closedHeight : Int;

    var handled : Bool;

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
        handled = false;
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
                if (self.handled)
                    return;

                if (item.data.type == "KEY")
                {
                    // TODO: Check color
                    if (closed && !self.handled)
                    {
                        self.handled = true;
                        // Wait a tad
                        new FlxTimer().start(0.45, function(t : FlxTimer) {
                            // Key Puff Effect
                            trace("KEY PUFF");
                            world.add(new FxPuff(item.x + item.width/2, item.y + item.height/2, world));

                            // Tiles Puff Effect
                            var heightInTiles : Float = height / 14;
                            var yy = y + (14/2);
                            var i = 0;
                            while (i < heightInTiles)
                            {
                                world.add(new FxPuff(x + width/2, yy + i * 14, world));
                                i++;
                            }
                        });
                        
                        world.pause(0.5, function() {
                            closed = false;
                            item.destroy();
                        });
                    }
                }
            });
        }

        super.update(elapsed);
    }
}