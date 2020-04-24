package;

import flixel.FlxSprite;

class NPC extends Actor
{
    var messages : Array<String>;
    var talkIcon : FlxSprite;

    public function new(X : Float, Y : Float, World : World, ?properties : haxe.DynamicAccess<Dynamic> = null)
    {
        super(X, Y, World);

        loadGraphic("assets/images/char.png", true, 7, 14);   
        animation.add("idle", [0], 1);
        animation.play("idle");

        setSize(width*2, height);
        centerOffsets(true);

        talkIcon = new FlxSprite(x + width/2 - Constants.TileWidth/2, y - Constants.TileHeight, "assets/images/fx-talk.png");
        talkIcon.visible = false;

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

        if (!overlaps(world.player)) 
        {
            talkIcon.visible = false;
        }

        super.onUpdate(elapsed);
    }

    public function setInteractable(interactable : Bool)
    {
        talkIcon.visible = interactable;
    }

    public function onInteract()
    {
        world.showMessages(messages);
    }

    override public function draw()
    {
        if (talkIcon.visible)
            talkIcon.draw();

        super.draw();
    }
}