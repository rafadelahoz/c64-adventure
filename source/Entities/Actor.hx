package;

class Actor extends Entity
{
    public var xRemainder : Float;
    var yRemainder : Float;

    public function new(X : Float, Y : Float, World : World)
    {
        super(X, Y, World);

        xRemainder = 0;
        yRemainder = 0;
    }

    override public function update(elapsed : Float)
    {
        super.update(elapsed);
    }

    public function moveX(amount : Float, ?callback : Void -> Void = null) : Void
    {
        xRemainder += amount;
        var move : Int = Std.int(xRemainder);

        if (move != 0)
        {
            xRemainder -= move;
            var delta : Int = MathUtil.sign(move);
            while (move != 0)
            {
                if (!solid || !overlapsAt(x + delta, y, world.solids))
                {
                    x += delta;
                    move -= delta;
                }
                else
                {
                    if (callback != null) {
                        callback();
                    }

                    break;
                }
            }
        }
    }

    public function moveY(amount : Float, ?callback : Void -> Void = null) : Void
    {
        yRemainder += amount;
        var move : Int = Std.int(yRemainder);

        if (move != 0)
        {
            yRemainder -= move;
            var delta : Int = MathUtil.sign(move);

            while (move != 0)
            {
                if (solid && (overlapsAt(x, y + delta, world.solids) ||
                    (delta > 0 && !overlapsAt(x, y, world.oneways) &&
                    overlapsAt(x, y + delta, world.oneways))))
                {
                    if (callback != null) {
                        callback();
                    }

                    break;
                }
                else
                {
                    y += delta;
                    move -= delta;
                }

            }
        }
    }
}
