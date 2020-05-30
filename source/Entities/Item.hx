package;

import flixel.FlxSprite;
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
                if (data.properties != null)
                {
                    switch (data.properties.flavour) 
                    {
                        case "NONE":    color = 0xFFbfbfbf;
                        case "CHERRY":  color = 0xFFf7a8a2;
                        case "LAPIS":   color = 0xFF87d6dd;
                        case "ROSE":    color = 0xFFea9ff6;
                        case "PEAR":    color = 0xFF94e089;
                        case "LILAC":   color = 0xFFbfb0ff;
                        case "HONEY":   color = 0xFFbfce72;
                        default: color = 0xFFbfbfbf; // NONE by default
                    }
                } 
                else 
                {
                    color = 0xFFbfbfbf; // NONE by default
                }

            case "APPLE":
                animation.add("idle", [2]);
            case "DONUT":
                animation.add("idle", [3]);
                color = 0xFF7869c4;
            case "STAR":
                animation.add("idle", [4]);
            case "POTION":
                animation.add("idle", [data.properties.flavour == "SPEED" ? 0 : 1]);
            case "SHRIMP":
                animation.add("idle", [7]);
            default:
                animation.add("idle", [0]);
        }

        animation.play("idle");
    }

    override public function destroy()
    {
        world.remove(groundProbe);
        groundProbe.destroy();
        
        world.items.remove(this);
        super.destroy();
    }

    override public function onUpdate(elapsed : Float)
    {
        switch (state)
        {
            case ItemState.Carried:
                if (data.type == "KEY" || data.type == "SHRIMP")
                    flipX = (world.player.facing == Player.Left);
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

        super.onUpdate(elapsed);

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

    public function onCollisionWithHazard(hazard : Hazard)
    {
        // if (vspeed > 0)
        {
            // Puff!
            world.add(new FxPuff(x + width/2, y + height/2, world));

            // Then die
            destroy();
        }
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

        switch (data.type)
        {
            case "KEY":
                setSize(7, 6);
                centerOffsets();
            default:
                // setSize(5, 12);
                // centerOffsets(true);
        }
    }

    public function onRelease()
    {
        state = ItemState.Idle;

        switch (data.type)
        {
            case "KEY":
                setSize(7, 14);
                offset.set(0, 0);
                y -= 5;
            default:
                // setSize(7, 14);
                // centerOffsets(true);
                // y -= 1;
        }
    }

    public function onPickup()
    {
        world.items.remove(this);
        destroy();
    }
}

enum ItemState { Idle; Carried; }