
class FxPuff extends Entity
{
    /**
     * Creates a new Puff effect centered on the provided X, Y
     * @param X Center X position of the new puff effect
     * @param Y Center Y position of the new puff effect
     * @param World World that contains the puff effect
     */
    public function new(X : Float, Y : Float, World : World)
    {
        super(X, Y, World);

        loadGraphic("assets/images/fx-puff.png", true, 7, 14);
        animation.add("puff", [0, 1, 2, 3], 16, false);
        animation.finishCallback = onAnimationFinish;
        
        animation.play("puff");

        scale.set(1.25, 1.25);

        centerOrigin();
        centerOffsets();

        x -= width / 2;
        y -= height / 2;

        solid = false;
    }

    function onAnimationFinish(animationName : String)
    {
        destroy();
    }
}