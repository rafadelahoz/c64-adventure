package;

import flixel.FlxSprite;

class NPC extends Interactable
{
    var messages : Array<String>;
    

    public function new(X : Float, Y : Float, World : World, ?properties : haxe.DynamicAccess<Dynamic> = null)
    {
        super(X, Y, World);

        init(properties);
    }

    override function prepareAffordance()
    {
        affordance = new FlxSprite(x + width/2 - Constants.TileWidth/2, y - Constants.TileHeight, "assets/images/fx-talk.png");
        affordance.visible = false;
    }

    function init(properties : haxe.DynamicAccess<Dynamic>)
    {
        loadGraphic("assets/images/char.png", true, 7, 14);   
        animation.add("idle", [0], 1);
        animation.play("idle");

        setSize(width*2, height);
        centerOffsets(true);

        color = getRandomColor();

        if (properties != null)
        {
            var tmpMessages : Dynamic = properties.get("messages");
            if (Std.is(tmpMessages, Array))
                messages = properties.get("messages");
            else if (Std.is(tmpMessages, String))
                messages = [properties.get("messages")];
            if (properties.get("color") != null)
                color = new MapReader().color(properties.get("color"));
        }
    }

    function getRandomColor() : Int
    {
        /*return FlxG.random.getObject([Palette.red[5], Palette.purple[5], Palette.yellow[5],
                                      Palette.pink[5], Palette.brown[5], Palette.orange[5]]);*/
        return Palette.orange[5];
    }

    override public function onUpdate(elapsed : Float)
    {
        flipX = (world.player.getMidpoint().x < getMidpoint().x);

        super.onUpdate(elapsed);
    }

    override public function canInteractWithPlayer()
    {
        return (world.player.facing == Player.Left && (getMidpoint().x < world.player.getMidpoint().x) ||
            world.player.facing == Player.Right && (getMidpoint().x > world.player.getMidpoint().x));
    }

    override public function onInteract()
    {
        world.showMessages(messages);
    }
}