package;

class Hazard extends Actor
{
    public static var TypeSpikes (default, never) : String = "spikes";
    
    public var type : String;
    public var power : Int;

    public function new(X : Float, Y : Float, World : World, Type : String, ?Properties : Dynamic = null)
    {
        super(X, Y, World);

        type = Type;

        // TODO: Use type to configure graphic, power
        switch (type)
        {
            case TypeSpikes:
                loadGraphic("assets/images/hazards.png", true, 7, 14);
                animation.add("idle", [0]);
                animation.play("idle");
            default:
                makeGraphic(7, 14, 0xFFFF000a);
                power = 6;
        }
    }
}