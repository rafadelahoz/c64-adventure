package;

class Hazard extends Actor implements IDangerous
{
    public static var TypeSpikes (default, never) : String = "spikes";
    public static var TypeStar(default, never) : String = "pointy";
    
    public var type : String;
    public var power : Int;

    public function new(X : Float, Y : Float, World : World, Type : String, ?Properties : Dynamic = null)
    {
        super(X, Y, World);

        type = Type;
        power = 1;
    }

    public function damages(player : Player) : Int
    {
        return power;
    }

    public function onPlayerKilled() : Void
    {
        // OK
    }
}