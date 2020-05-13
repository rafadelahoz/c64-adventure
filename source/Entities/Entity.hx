package;

import flixel.FlxCamera;
import flixel.FlxObject;
import flixel.math.FlxPoint;
import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxBasic;
import flixel.util.FlxTimer;
import flixel.FlxSprite;

class Entity extends FlxSprite
{
    var world : World;

    public function new(X : Float, Y : Float, World : World)
    {
        super(X, Y);
        world = World;

        moves = false;
    }

    /*public function onPause() {}

    public function onUnpause() {}*/

    public function onUpdate(elapsed : Float)
    {
        super.update(elapsed);
    }

    public function onPausedUpdate(elapsed : Float)
    {
        super.update(elapsed);
    }

    public function onHit(by : Entity, ?damage : Int = 0)
    {
        // Generic collision, override me
    }

    public function onStateSwitchChange(on : Bool)
    {
        // Override me
    }

    override public function update(elapsed : Float) : Void
    {
        if (!world.paused)
            onUpdate(elapsed);
        else
            onPausedUpdate(elapsed);        
    }

    function wait(seconds : Float, callback : Void -> Void)
    {
        new FlxTimer().start(seconds, function(t:FlxTimer) {
            t.destroy();
            callback();
        });
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
