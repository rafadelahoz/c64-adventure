package;

import flixel.effects.FlxFlicker;
import flixel.util.FlxTimer;

class FallingHazard extends Hazard implements IDangerous
{
    static final StateIdle : Int = 0;
    static final StateAlert : Int = 1;
    static final StateFalling : Int = 2;
    
    var AlertTime : Float = 0.35;
    var Gravity : Float = 0.2;

    var state : Int;
    var vspeed : Float;

    public function new(X : Float, Y : Float, World : World, ?Properties : Dynamic = null)
    {
        super(X, Y, World, Properties);
        
        loadGraphic("assets/images/hazards.png", true, 7, 14);
        animation.add("idle", [2]);
        animation.play("idle");
        
        setSize(5, 12);
        centerOffsets(true);

        color = Palette.pink[5];

        power = 1;

        // TODO: Allow choosing gfx, color, power

        state = StateIdle;
    }

    override public function onUpdate(elapsed : Float)
    {
        switch (state)
        {
            case StateIdle:
                if (world.player.hspeed != 0 && Math.abs(world.player.center.x - (x+width/2)) < Constants.TileWidth*1.442)
                {
                    state = StateAlert;
                    new FlxTimer().start(AlertTime, function(t : FlxTimer) {
                        state = StateFalling;
                        FlxFlicker.stopFlickering(this);
                        t.destroy();
                    });
                }
            case StateAlert:
                // Flicker or something?
                FlxFlicker.flicker(this, 0, 0.075, true, false);
            case StateFalling:
                vspeed += Gravity;
                moveY(vspeed, function() {
                    if (!world.player.invulnerable && LRAM.hp <= power && overlaps(world.player))
                    {
                        // Congrats, you have just killed the player
                        // Here's your medal O
                    }
                    else
                    {
                        // I'm sorry, you died for nothing

                        // Puff!
                        world.add(new FxPuff(x + width/2, y + height/2, world));

                        // Then die
                        world.hazards.remove(this);
                        kill();
                        destroy();
                    }
                });
        }

        if (alive)
            super.onUpdate(elapsed);
    }

    override function onPlayerKilled() {
        vspeed = 0;
    }

    override function onHit(by:Entity, ?damage:Int = 0) {
        world.add(new FxPuff(x + width/2, y + height/2, world));

        // Then die
        world.hazards.remove(this);
        kill();
        destroy();
    }
}