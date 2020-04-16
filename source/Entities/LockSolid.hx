package;

import flixel.FlxSprite;
import flixel.util.FlxSpriteUtil;
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

        makeGraphic(Std.int(Width), Std.int(Height), 0x00FFFFFF);
        var lockY : Int = Std.int(height/2 - 7);
        if (Height == Constants.TileHeight)
            lockY = 0;
        else if (Height == Constants.TileHeight*2)
            lockY = Constants.TileHeight;
            
        FlxSpriteUtil.drawRect(this, 0, 2, Width, lockY-2, 0xFFFFFFFF);
        FlxSpriteUtil.drawRect(this, 0, lockY+14, Width, Height - (lockY+14), 0xFFFFFFFF);
        
        stamp(new FlxSprite(0, 0, "assets/images/lock.png"), 0, lockY);
        if (lockY > 0)
            stamp(new FlxSprite(0, 0, "assets/images/lock-top.png"), 0, 0);
        
        closedWidth = Std.int(width);
        closedHeight = Std.int(height);
    }

    public function init(id : String, ?flavour : String = "NONE")
    {
        switch (flavour) 
        {
            case "NONE":    color = 0xFFbfbfbf;
            case "CHERRY":  color = 0xFFf7a8a2;
            case "LAPIS":   color = 0xFF87d6dd;
            case "ROSE":    color = 0xFFea9ff6;
            case "PEAR":    color = 0xFF94e089;
            case "LILAC":   color = 0xFFbfb0ff;
            case "HONEY":   color = 0xFFbfce72;
        }

        lockId = id;
        lockColor = color;

        // Check lram in order to close/unclose
        closed = !LRAM.IsLockSolidOpen(lockId);

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
                    // Check color
                    // TODO: All keys open gray doors?
                    if (closed && !self.handled && (item.color == color))
                    {
                        self.handled = true;

                        // Store that the door is opened
                        LRAM.OpenLockSolid(lockId);

                        // Wait a tad
                        new FlxTimer().start(0.45, function(t : FlxTimer) {
                            // Key Puff Effect
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
                            world.player.carrying = null;
                        });
                    }
                }
            });
        }

        super.update(elapsed);
    }
}