package;

import flixel.FlxCamera;
import flixel.FlxObject;
import flixel.math.FlxPoint;
import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxBasic;

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

    /**
	 * Checks to see if some `FlxObject` overlaps this `FlxObject` or `FlxGroup`.
	 * If the group has a LOT of things in it, it might be faster to use `FlxG.overlap()`.
	 * WARNING: Currently tilemaps do NOT support screen space overlap checks!
	 *
	 * @param   ObjectOrGroup   The object or group being tested.
	 * @param   InScreenSpace   Whether to take scroll factors into account when checking for overlap.
	 *                          Default is `false`, or "only compare in world space."
	 * @param   Camera          Specify which game camera you want.
	 *                          If `null`, it will just grab the first global camera.
	 * @return  Whether or not the two objects overlap.
	 */
	@:access(flixel.group.FlxTypedGroup)
	override public function overlaps(ObjectOrGroup:FlxBasic, InScreenSpace:Bool = false, ?Camera:FlxCamera):Bool
	{
		var group = FlxTypedGroup.resolveGroup(ObjectOrGroup);
		if (group != null) // if it is a group
		{
			return FlxTypedGroup.overlaps(overlapsCallback, group, 0, 0, InScreenSpace, Camera);
        }
        
        var object:FlxObject = cast ObjectOrGroup;
        if (!object.exists)
            return false;
        
		if (!InScreenSpace)
		{
			return (object.x + object.width > x) && (object.x < x + width) && (object.y + object.height > y) && (object.y < y + height);
		}

		if (Camera == null)
		{
			Camera = FlxG.camera;
		}
		var objectScreenPos:FlxPoint = object.getScreenPosition(null, Camera);
		getScreenPosition(_point, Camera);
		return (objectScreenPos.x + object.width > _point.x)
			&& (objectScreenPos.x < _point.x + width)
			&& (objectScreenPos.y + object.height > _point.y)
			&& (objectScreenPos.y < _point.y + height);
	}

    /**
	 * Checks to see if this `FlxObject` were located at the given position,
	 * would it overlap the `FlxObject` or `FlxGroup`?
	 * This is distinct from `overlapsPoint()`, which just checks that point,
	 * rather than taking the object's size into account.
	 * WARNING: Currently tilemaps do NOT support screen space overlap checks!
	 *
	 * @param   X               The X position you want to check.
	 *                          Pretends this object (the caller, not the parameter) is located here.
	 * @param   Y               The Y position you want to check.
	 *                          Pretends this object (the caller, not the parameter) is located here.
	 * @param   ObjectOrGroup   The object or group being tested.
	 * @param   InScreenSpace   Whether to take scroll factors into account when checking for overlap.
	 *                          Default is `false`, or "only compare in world space."
	 * @param   Camera          Specify which game camera you want.
	 *                          If `null`, it will just grab the first global camera.
	 * @return  Whether or not the two objects overlap.
	 */
	@:access(flixel.group.FlxTypedGroup)
	override public function overlapsAt(X:Float, Y:Float, ObjectOrGroup:FlxBasic, InScreenSpace:Bool = false, ?Camera:FlxCamera):Bool
	{
		var group = FlxTypedGroup.resolveGroup(ObjectOrGroup);
		if (group != null) // if it is a group
		{
			return FlxTypedGroup.overlaps(overlapsAtCallback, group, X, Y, InScreenSpace, Camera);
		}

        var object:FlxObject = cast ObjectOrGroup;
        if (!object.exists)
            return false;

		if (!InScreenSpace)
		{
			return (object.x + object.width > X) && (object.x < X + width) && (object.y + object.height > Y) && (object.y < Y + height);
		}

		if (Camera == null)
		{
			Camera = FlxG.camera;
		}
		var objectScreenPos:FlxPoint = object.getScreenPosition(null, Camera);
		getScreenPosition(_point, Camera);
		return (objectScreenPos.x + object.width > _point.x)
			&& (objectScreenPos.x < _point.x + width)
			&& (objectScreenPos.y + object.height > _point.y)
			&& (objectScreenPos.y < _point.y + height);
	}
}
