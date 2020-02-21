package;

import flixel.FlxSprite;

class MapExit extends Entity
{
    public var name : String;
    var flag : FlxSprite;

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
        }
        else   
        {
            flag.color = 0xFF808080;
            flag.y += 2;
        }
    }

    override public function draw()
    {
        flag.draw();
        super.draw();
    }
}