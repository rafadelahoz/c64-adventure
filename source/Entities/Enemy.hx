package;

class Enemy extends Actor implements IDangerous
{
    public function new(X : Float, Y : Float, World : World)
    {
        super(X, Y, World);
    }

    public function onCollisionWithPlayer(player : Player)
    {
        // Override me
    }

    override public function onHit(by : Entity, ?damage : Int = 0) : Void
    {
        // Override me
        if (Std.is(by, Hazard))
        {
            onDeath();
        }
    }

    public function onDeath() : Void
    {
        // Override me
        kill();
        world.remove(this);

        world.add(new FxPuff(x + width / 2, y + height / 2, world));
    }

    public function onPlayerKilled() : Void
    {
        // Override me
    }

    public function damages(player : Player) : Int
    {
        return -1;
    }

    /**
     * Spawns an enemy considering the given data and returns it
     * @param data Data to spawn enemy with
     * @return Enemy Instance of enemy, ready to go
     */
    public static function Spawn(data : Dynamic) : Enemy
    {
        var enemy : Enemy = null;
        return enemy;
    }
}