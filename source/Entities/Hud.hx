package;

import Inventory.ItemData;
import flixel.effects.FlxFlicker;
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
    var roomNameLabel : FlxBitmapText;

    public var playerDead : Bool;

    public var pickableItemLabel : String;

    public function new(World : World)
    {
        super(0, 0);

        world = World;
        inventoryLabels = [];
        pickableItemLabel = "";

        bgImage = new FlxSprite(0, 0, "assets/images/temp-hud.png");
        add(bgImage);

        cursor = new FlxSprite(12, 0);
        cursor.makeGraphic(72, 12, 0xFFffe947);
        add(cursor);

        prepareItemLabels();
        renderInventory();
        
        roomNameLabel = text.PixelText.New(0, 0, world.roomData.name);
        roomNameLabel.x = 194 - roomNameLabel.width/2;
        roomNameLabel.y = 174;
        add(roomNameLabel);

        playerDead = false;
    }

    public function onRoomChange()
    {
        roomNameLabel.text = world.roomData.name;
    }

    override public function update(elapsed : Float) : Void
    {
        if (!playerDead)
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
        }

        renderInventory();

        super.update(elapsed);
    }

    function prepareItemLabels()
    {
        var ly : Int = 38;
        var label : FlxBitmapText;

        for (i in 0...Inventory.MaxItems)
        {
            label = PixelText.New(12, ly, "");
            add(label);
            inventoryLabels.push(label);
            
            ly += 12;
        }
    }

    function renderInventory()
    {
        var ly : Int = 38;
        var i : Int = 0;
        var label : FlxBitmapText;
        var item : ItemData;

        for (i in 0...inventoryLabels.length)
        {
            item = Inventory.items[i];
            label = inventoryLabels[i];
            label.text = (item == null ? "" : item.label);
            
            if (pickableItemLabel.length > 0 && i == Inventory.cursor && Inventory.GetCurrent() == null)
            {
                inventoryLabels[i].text = pickableItemLabel;
                FlxFlicker.flicker(inventoryLabels[i], 0, true, false);
            } 
            else
                FlxFlicker.stopFlickering(inventoryLabels[i]);

            ly += 12;
        }
    }
}