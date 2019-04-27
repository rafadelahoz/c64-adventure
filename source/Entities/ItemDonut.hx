package;

import Inventory.ItemData;

class ItemDonut extends Item
{
    var platform : Solid;

    public function new(X : Float, Y : Float, World : World, Data : ItemData)
    {
        super(X, Y, World, Data);

        platform = new Solid(X, Y, width, 2, world);
        world.oneways.add(platform);
    }

    override function handleGraphic()
    {
        super.handleGraphic();
    }
    
    override private function checkOnAir() : Bool
    {
        //  world.oneways.remove(platform);
        var onGround =
            groundProbe.overlaps(world.solids) ||
            (vspeed >= 0 &&
                (groundProbe.overlaps(world.oneways) &&
                !groundProbe.overlapsAt(x, y+height-1, world.oneways)));

        // world.oneways.add(platform);
        return !onGround;
    }

    override public function update(elapsed : Float)
    {
        world.oneways.remove(platform);

        super.update(elapsed);

        world.oneways.add(platform);

        platform.x = x;
        platform.y = y;
    }

    override public function onPickup()
    {
        world.oneways.remove(platform);
        platform.destroy();
        destroy();
    }
}
