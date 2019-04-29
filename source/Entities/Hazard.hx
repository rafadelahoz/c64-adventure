package;

class Hazard extends Actor
{
    public var type : String;
    public var power : Int;

    public function new(X : Float, Y : Float, World : World, Type : String, ?Properties : Dynamic = null)
    {
        super(X, Y, World);

        type = Type;

        // TODO: Use type to configure graphic, power
        makeGraphic(7, 14, 0xFFFF000a);
        power = 6;
    }
}