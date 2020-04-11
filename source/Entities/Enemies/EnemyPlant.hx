package;

class EnemyPlant extends Enemy
{
    public function new(X : Float, Y : Float, World : World)
    {
        super(X, Y, World);

        loadGraphic("assets/images/enemy-plant.png", true, 7, 14);
        animation.add("idle", [0, 1], 1, false);
        animation.finishCallback = function(name : String) {
            flipX = !flipX;
            animation.play("idle");
        }

        animation.play("idle");

        color = Palette.orange[3];
    }

    override public function onCollisionWithPlayer(player : Player)
    {
        // Nop!
    }

    override public function onPlayerKilled()
    {
        animation.curAnim.frameRate *= 3;
    }

    override public function damages(player : Player) : Int
    {
        return 1;
    }
}