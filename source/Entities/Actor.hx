package;

class Actor extends Entity
{
    public var xRemainder : Float;
    public var yRemainder : Float;

    public function new(X : Float, Y : Float, World : World)
    {
        super(X, Y, World);

        xRemainder = 0;
        yRemainder = 0;
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
                    (delta > 0 && checkDeltaOnEachOneway(delta))))
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

    function checkDeltaOnEachOneway(delta : Float) : Bool
    {
        // !overlapsAt(x, y, world.oneways) &&
        //            overlapsAt(x, y + delta, world.oneways)
        for (oneway in world.oneways) 
        {
            // If it's not currently overlapping with us
            if (!overlapsAt(x, y, oneway)) 
            {
                // But will be after delta
                if (overlapsAt(x, y+delta, oneway))
                {
                    // Then there's collision
                    return true;
                }
            }
        }

        // Otherwise, there's no collision
        return false;
    }

    public function isRiding(solid : Solid) : Bool
    {
        return overlapsAt(x, y+1, solid);
    }

    public function squish()
    {
        // TODO: Temporary violence
        // destroy();
    }
}
