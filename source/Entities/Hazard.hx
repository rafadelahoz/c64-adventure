package;

class Hazard extends Actor
{
    public static var TypeSpikes (default, never) : String = "spikes";
    public static var TypeStar(default, never) : String = "star";
    
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
                power = 6;
            case TypeStar:
                makeGraphic(7, 14, 0x00FFFFFF);
                flixel.util.FlxSpriteUtil.drawCircle(this, -1, -1, -1, 0xFFAAAA00);
                power = 1;
            default:
                makeGraphic(7, 14, 0xFFFF000a);
                power = 6;
        }
    }

    public function damages(player : Player) : Int
    {
        var damage : Int  = power;

        // Special checks given type
        switch (type)
        {
            case TypeSpikes:
                // Don't damage things that are not falling
                if (player.vspeed <= 0)
                    damage = -1;
        }

        return damage;
    }
}