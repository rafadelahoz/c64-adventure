package;

import flixel.util.FlxSpriteUtil;
import text.PixelText;
import flixel.text.FlxBitmapText;
import flixel.group.FlxSpriteGroup;
import flixel.FlxSprite;

class Hud extends FlxSpriteGroup
{
    var world : World;
    var bgImage : FlxSprite;
    var cursor : FlxSprite;
    var inventoryLabels : Array<FlxBitmapText>;

    public function new(World : World)
    {
        super(0, 0);

        world = World;
        inventoryLabels = [];

        bgImage = new FlxSprite(0, 0, "assets/images/temp-hud.png");
        add(bgImage);

        cursor = new FlxSprite(12, 0);
        cursor.makeGraphic(72, 12, 0xFFffe947);
        add(cursor);

        renderInventory();
        
        var roomNameLabel : FlxBitmapText = text.PixelText.New(0, 0, world.roomData.name);
        roomNameLabel.x = 194 - roomNameLabel.width/2;
        roomNameLabel.y = 174;
        add(roomNameLabel);
    }

    override public function update(elapsed : Float) : Void
    {
        if (Inventory.cursor < 0 || Inventory.items.length <= 0)
            cursor.y = -200;
        else
        {
            cursor.y = 35 + 12*Inventory.cursor;
            for (i in 0...inventoryLabels.length)
            {
                if (i == Inventory.cursor)
                    inventoryLabels[i].color = 0xFF000000;
                else
                    inventoryLabels[i].color = 0xFFFFF0FF;
            }
        }

        super.update(elapsed);
    }

    function renderInventory()
    {
        var ly : Int = 38;
        for (item in Inventory.items)
        {
            var label : FlxBitmapText = PixelText.New(12, ly, item.label);
            add(label);
            inventoryLabels.push(label);
            ly += 12;
        }
    }
}