package;

class Teleport extends Entity
{
    public function new(X : Float, Y : Float, Width : Float, Height : Float, Data : TeleportData, World : World)
    {
        super(X, Y, World);

        makeGraphic(Std.int(Width), Std.int(Height), 0x44FFFFFF);
    }

    public function onTeleport() 
    {
        // whawtha!
        trace("TELEPORTTTT");
    }
}

typedef TeleportData = {
    var target : Int;   // Target room id
    var tileX : Int;    // Target tile x
    var tileY : Int;    // Target tile y
};