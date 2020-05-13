package;

/**
    Puzzle entity that switches the Level StateSwitch while pressed
**/
class Button extends Solid
{
    var pressed : Bool;

    public function new(X : Float, Y : Float, World : World)
    {
        super(X, Y, Constants.TileWidth, 2, World);

        // TODO: read puzzle color from map
        color = Palette.blue[5];

        pressed = false;
    }

    override function handleGraphic(?Width:Float = -1, ?Height:Float = -1) {
        loadGraphic("assets/images/triggers-sheet.png", true, 7, 14);
        animation.add("idle", [1]);
        animation.add("pressed", [2]);

        animation.play("idle");

        y += Constants.TileHeight-2;
        setSize(Constants.TileWidth, 2);
        offset.set(0, Constants.TileHeight-2);

        visible = true;
    }

    override public function onUpdate(elapsed : Float)
    {
        if (pressed)
        {
            if (!checkPressed())
            {
                pressed = false;
                // TODO: Play SFX
                LRAM.SwitchState();
            }
        }
        else
        {
            // Note that we avoid calling superclass onUpdate
            if (checkPressed())
            {
                pressed = true;
                // TODO: Play SFX
                LRAM.SwitchState();
            }
        }

        animation.play(pressed ? "pressed" : "idle");
    }

    function checkPressed()
    {
        return (overlapsAt(x, y-1, world.player) || overlapsAt(x, y-1, world.enemies) || overlapsAt(x, y-1, world.items));
    }
}