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

        if (target != null)
            onStateSwitchChange(LRAM.GetStateSwitch());
    }

    override function onStateSwitchChange(on : Bool) 
    {
        if (target != null)
            target.exists = on;
    }
}