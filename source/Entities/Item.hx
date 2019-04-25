package;

import MapReader.ActorData;

class Item extends Actor
{
    var Gravity : Float = 0.2; // 0.175; // 0.35;

    var data : ActorData;

    var vspeed : Float;

    public function new(X : Float, Y : Float, World : World, Data : ActorData) 
    {
        super(X, Y, World);

        data = Data;

        x += 1;
        y += 1;
        makeGraphic(5, 12, 0x88FF00FF);
    }

    override public function update(elapsed : Float)
    {
        if (!overlapsAt(x, y+1, world.platforms))
            vspeed += Gravity;
        else
            vspeed = 0;

        moveY(vspeed, function() {
            // Touched ground
            vspeed = 0;
        });

        super.update(elapsed);
    }
}