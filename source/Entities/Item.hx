package;

import flixel.FlxSprite;
import flixel.FlxG;
import Inventory.ItemData;

class Item extends Actor
{
    var Gravity : Float = 0.2; // 0.175; // 0.35;

    public var data : ItemData;

    var state : ItemState;

    var vspeed : Float;

    var groundProbe : FlxSprite;

    public function new(X : Float, Y : Float, World : World, Data : ItemData) 
    {
        super(X, Y, World);

        data = Data;

        state = ItemState.Idle;

        handleGraphic();

        groundProbe = new FlxSprite(0, 0);
        groundProbe.makeGraphic(Std.int(width), 1, 0xFFFFFFFF);
        groundProbe.visible = false;
        world.add(groundProbe);
    }

    function handleGraphic()
    {
        loadGraphic("assets/images/items.png", true, 7, 14);
        switch (data.type)
        {
            case "KEY":
                animation.add("idle", [1]);
                animation.add("carry", [11]);
            case "APPLE":
                animation.add("idle", [2]);
            case "DONUT":
                animation.add("idle", [3]);
            case "STAR":
                animation.add("idle", [4]);
            case "POTION":
                animation.add("idle", [data.properties.flavour]);
            case "SHRIMP":
                animation.add("idle", [7]);
            default:
                animation.add("idle", [0]);
        }

        animation.play("idle");
    }

    override public function update(elapsed : Float)
    {
        switch (state)
        {
            case ItemState.Carried:
                // Nop!
            case ItemState.Idle:
                if (checkOnAir())
                    vspeed += Gravity;
                else
                    vspeed = 0;

                moveY(vspeed, function() {
                    // Touched ground
                    vspeed = 0;
                });
        }

        super.update(elapsed);

        // Good items stay in room bounds
        if (x < world.left)
            x = world.left;
        else if (x > world.right - width)
            x = world.right - width;
        if (y < world.top)
            y = world.top;
        else if (y > world.bottom)
            y = world.bottom;

        groundProbe.x = x;
        groundProbe.y = y + height;
    }

    private function checkOnAir() : Bool
    {
        var onGround =
            groundProbe.overlaps(world.solids) ||
            (vspeed >= 0 &&
                (groundProbe.overlaps(world.oneways) &&
                !groundProbe.overlapsAt(x, y+height-1, world.oneways)));

        return !onGround;
    }

    public function onCarry()
    {
        state = ItemState.Carried;
        if (animation.getByName("carry") != null)
            animation.play("carry");
    }

    public function onRelease()
    {
        state = ItemState.Idle;
    }

    public function onPickup()
    {
        world.items.remove(this);
        destroy();
    }
}

enum ItemState { Idle; Carried; }