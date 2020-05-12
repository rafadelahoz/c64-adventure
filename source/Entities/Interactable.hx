package;

import flixel.FlxSprite;

class Interactable extends Actor
{
    var affordance : FlxSprite;

    public function new(X : Float, Y : Float, World : World)
    {
        super(X, Y, World);
        prepareAffordance();
    }

    function prepareAffordance()
    {
        affordance = new FlxSprite(x + width/2 - Constants.TileWidth/2, y - Constants.TileHeight);
        affordance.loadGraphic("assets/images/fx-pick-cursor.png", true, 7, 14);
        affordance.animation.add("idle", [0, 1], 1);
        affordance.animation.play("idle");

        affordance.visible = false;
    }

    override public function onUpdate(elapsed : Float)
    {
        if (!overlaps(world.player)) 
        {
            affordance.visible = false;
        }

        super.onUpdate(elapsed);
        affordance.setPosition(x + width/2 - Constants.TileWidth/2, y - Constants.TileHeight);
        affordance.update(elapsed);
    }

    public function setInteractable(interactable : Bool)
    {
        affordance.visible = interactable;
    }

    public function canInteractWithPlayer()
    {
        return (Math.abs(world.player.getMidpoint().x - getMidpoint().x) < 14);
    }

    public function onInteract()
    {
        // override me
    }

    override public function draw()
    {
        if (affordance.visible)
            affordance.draw();

        super.draw();
    }
}