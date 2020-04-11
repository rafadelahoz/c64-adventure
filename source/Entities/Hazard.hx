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

        // TODO: Use type to configure graphic, power
        switch (type)
        {
            case TypeSpikes:
                loadGraphic("assets/images/hazards.png", true, 7, 14);
                animation.add("idle", [0]);
                animation.play("idle");
                setSize(7, 10);
                offset.y = 4;
                y += 4;
                
                power = 6;
            case TypeStar:
                // makeGraphic(7, 14, 0x00FFFFFF);
                // flixel.util.FlxSpriteUtil.drawCircle(this, -1, -1, -1, 0xFFAAAA00);
                loadGraphic("assets/images/hazards.png", true, 7, 14);
                animation.add("idle", [1]);
                animation.play("idle");
                setSize(5, 12);
                offset.set(1, 1);
                x += 1;
                y += 1;

                power = 1;
            default:
                makeGraphic(7, 14, 0xFFFF000a);
                power = 6;
        }

        if (world.roomData.colors.length > 3)
            color = new MapReader().color(world.roomData.colors[3]);
        else // White by default
            color = 0xFFFFFFFF;
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