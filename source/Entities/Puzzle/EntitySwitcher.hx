package;

class EntitySwitcher extends Entity
{
    var state : Bool;
    var target : Entity;

    public function new(Target : Entity)
    {
        super(-100, -100, Target.world);

        // TODO: Receive this value
        state = false;

        target = Target;
    }

    override function onStateSwitchChange(on : Bool) 
    {
        target.exists = on;
    }
}