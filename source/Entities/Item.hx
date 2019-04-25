package;

import Inventory.ItemData;

class Item extends Actor
{
    var Gravity : Float = 0.2; // 0.175; // 0.35;

    public var data : ItemData;

    var state : ItemState;

    var vspeed : Float;

    public function new(X : Float, Y : Float, World : World, Data : ItemData) 
    {
        super(X, Y, World);

        data = Data;

        state = ItemState.Idle;

        x += 1;
        y += 2;
        makeGraphic(5, 10, 0x88FF00FF);
    }

    override public function update(elapsed : Float)
    {
        switch (state)
        {
            case ItemState.Carried:
                // Nop!
            case ItemState.Idle:
                if (!overlapsAt(x, y+1, world.platforms))
                    vspeed += Gravity;
                else
                    vspeed = 0;

                moveY(vspeed, function() {
                    // Touched ground
                    vspeed = 0;
                });
        }

        super.update(elapsed);
    }

    public function onCarry()
    {
        state = ItemState.Carried;
    }

    public function onRelease()
    {
        state = ItemState.Idle;
    }
}

enum ItemState { Idle; Carried; }