package;

import flixel.FlxG;
import flixel.util.FlxTimer;
import flixel.FlxSprite;

class MapExit extends Entity
{
    var ColorDuration : Float = 0.0841235;

    public var name : String;
    var flag : FlxSprite;

    var colorTimer : FlxTimer;
    var hueIndex : Int = 0;
    var colorIndex : Int = 0;
    var hueDirection : Int = 1;
    var colorDirection : Int = 1;

    public function new(X : Float, Y : Float, Width : Int, Height : Int, Name : String, World : World)
    {
        super(X, Y, World);

        name = Name;
        
        loadGraphic("assets/images/exit-pole.png");
        offset.set(0, 3);

        flag = new FlxSprite(X, Y, "assets/images/exit-flag.png");
        flag.x = x + 4;
        flag.y = y - 3;

        if (!GameStatus.isExitClear(name))
        {
            flag.color = 0xFFFF0a1a;
            hueIndex = FlxG.random.int(2, 15);
            colorIndex = FlxG.random.int(0, 7);
            colorDirection = (FlxG.random.bool(50) ? -1 : 1);
            hueDirection = (FlxG.random.bool(50) ? -1 : 1);
            
            colorTimer = new FlxTimer();
            onColorTimer(colorTimer);
        }
        else   
        {
            // Cleared exits are grayscale only
            flag.color = 0xFF808080;
            hueIndex = 1;
            colorIndex = FlxG.random.int(0, 7);
            colorDirection = (FlxG.random.bool(50) ? -1 : 1);

            colorTimer = new FlxTimer();
            onColorTimer(colorTimer);

            // And the flag is a bit lowered
            flag.y += 2;
        }
    }

    function onColorTimer(t : FlxTimer)
    {
        var hue : Array<Int> = Palette.colors[hueIndex];

        colorIndex += colorDirection;
        if (colorIndex < 0 || colorIndex >= hue.length)
        {
            colorDirection *= -1;
            if (colorIndex < 0) colorIndex = 0;
            else colorIndex = hue.length-1;

            if (!GameStatus.isExitClear(name))
            {
                hueIndex += hueDirection;
                if (hueIndex < 2 || hueIndex >= Palette.colors.length)
                {
                    hueDirection *= -1;
                    if (hueIndex < 2) hueIndex = 2;
                    else hueIndex = Palette.colors.length-1;
                }

                hue = Palette.colors[hueIndex];
            }
        }

        flag.color = hue[colorIndex];

        t.start(ColorDuration, onColorTimer);
    }

    override public function draw()
    {
        flag.draw();
        super.draw();
    }
}