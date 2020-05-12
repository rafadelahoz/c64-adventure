package;

class Lever extends Interactable
{
    var state : Bool;

    public function new(X : Float, Y : Float, World : World)
    {
        super(X, Y, World);

        loadGraphic("assets/images/triggers-sheet.png", true, 7, 14);
        animation.add("idle", [0]);
        animation.play("idle");

        setSize(width*2, height);
        centerOffsets(true);

        // TODO: Read this from map colors
        color = Palette.blue[5];

        // TODO: receive this value
        state = false;
    }

    override function onInteract() {
        state = !state;
        LRAM.SwitchState();
    }

    override public function onUpdate(elapsed : Float)
    {
        flipX = state;

        super.onUpdate(elapsed);
    }
}