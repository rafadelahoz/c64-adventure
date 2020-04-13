package;

class Teleport extends Entity
{
    var data : TeleportData;

    public function new(X : Float, Y : Float, Width : Float, Height : Float, Data : TeleportData, World : World)
    {
        super(X, Y, World);

        data = Data;

        visible = data.visible;
        if (visible)
        {
            // TODO: Prepare door graphic
            // makeGraphic(Std.int(Width), Std.int(Height), 0xFFFFFFFF);
            loadGraphic("assets/images/door.png");
            color = data.color;
        }
        else
        {
            makeGraphic(Std.int(Width), Std.int(Height), 0x00000000);
        }
    }

    public function onTeleport() 
    {
        world.pause();
        var fader : Fader = new Fader(world);
        fader.fade(false, function() {
            world.teleportTo(data);
            world.remove(fader);
            fader.destroy();
        });
    }
}

typedef TeleportData = {
    var target : Int;   // Target room id
    var tileX : Int;    // Target tile x
    var tileY : Int;    // Target tile y
    var ?visible : Bool; // Is the door visible?
    var ?color : Int;    // Color for the graphic?
};