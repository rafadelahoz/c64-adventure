package;

import text.PixelNumbers;
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
    var roomNameBG : FlxSprite;

    var hpBG : FlxSprite;
    var hpDisplay : Array<FlxSprite>;

    var starsLabel : FlxBitmapText;
    var clearsLabel : FlxBitmapText;

    var redOrb : FlxSprite;
    var blueOrb : FlxSprite;
    var greenOrb : FlxSprite;
    var yellowOrb : FlxSprite;

    public var playerDead : Bool;

    public var pickableItemLabel : String;

    public function new(World : World)
    {
        super(0, 0);

        world = World;
        inventoryLabels = [];
        pickableItemLabel = "";

        bgImage = new FlxSprite(0, 0, "assets/ui/hud-" + GameStatus.hudStyle + ".png");
        add(bgImage);

        prepareHpDisplay();

        cursor = new FlxSprite(12, 0);
        cursor.makeGraphic(72, 12, 0xFFffe947);
        add(cursor);

        prepareItemLabels();
        renderInventory();
        
        roomNameLabel = text.PixelText.New(0, 0, world.roomData.name);
        roomNameLabel.x = 200 - roomNameLabel.width/2;
        roomNameLabel.y = 171;
        roomNameBG = new FlxSprite(roomNameLabel.x, roomNameLabel.y).makeGraphic(Std.int(roomNameLabel.width), Std.int(roomNameLabel.height), 0xFF000000);

        add(roomNameBG);
        add(roomNameLabel);

        starsLabel = text.PixelNumbers.New(61, 9, "000");
        add(starsLabel);
        clearsLabel = text.PixelNumbers.New(61, 26, "000");
        add(clearsLabel);

        prepareOrbs();

        playerDead = false;
    }

    function prepareOrbs()
    {
        redOrb = new FlxSprite(11-3, 10-2);
        redOrb.loadGraphic("assets/ui/hud-orbs.png", true, 14, 12);
        redOrb.animation.add("orb", [0]);
        redOrb.animation.play("orb");
        add(redOrb);

        blueOrb = new FlxSprite(29-3, 26-2);
        blueOrb.loadGraphic("assets/ui/hud-orbs.png", true, 14, 12);
        blueOrb.animation.add("orb", [3]);
        blueOrb.animation.play("orb");
        add(blueOrb);

        greenOrb = new FlxSprite(11-3, 26-2);
        greenOrb.loadGraphic("assets/ui/hud-orbs.png", true, 14, 12);
        greenOrb.animation.add("orb", [2]);
        greenOrb.animation.play("orb");
        add(greenOrb);

        yellowOrb = new FlxSprite(29-3, 10-2);
        yellowOrb.loadGraphic("assets/ui/hud-orbs.png", true, 14, 12);
        yellowOrb.animation.add("orb", [1]);
        yellowOrb.animation.play("orb");
        add(yellowOrb);
    }

    public function onRoomChange()
    {
        roomNameLabel.text = world.roomData.name;
        roomNameLabel.x = 200 - roomNameLabel.width/2;
        roomNameBG.x = roomNameLabel.x;
        roomNameBG.makeGraphic(Std.int(roomNameLabel.width), Std.int(roomNameLabel.height), 0xFF000000);
    }

    override public function update(elapsed : Float) : Void
    {
        if (!playerDead)
        {
            if (Inventory.cursor < 0 || Inventory.items.length <= 0)
                cursor.y = -200;
            else
            {
                cursor.y = 35 + 12 + 12*Inventory.cursor;
                for (i in 0...inventoryLabels.length)
                {
                    if (i == Inventory.cursor)
                        inventoryLabels[i].color = 0xFF000000;
                    else
                        inventoryLabels[i].color = 0xFFFFF0FF;
                }
            }
        }

        renderHP();
        renderInventory();
        renderCounters();
        renderOrbs();

        super.update(elapsed);
    }

    function prepareHpDisplay()
    {
        hpBG = new FlxSprite(0, 0).makeGraphic(14*GameStatus.maxHP, 12, 0xFF000000);
        add(hpBG);

        hpDisplay = [];
        for (i in 0...GameStatus.maxHP)
        {
            hpDisplay.push(new FlxSprite(0+i*14, 0, "assets/ui/hud-heart.png"));
            add(hpDisplay[i]);
        }
    }

    function renderHP()
    {
        var baseX : Int = Std.int(180-14*Std.int((GameStatus.maxHP-3)/2));
        for (i in 0...GameStatus.maxHP)
        {
            hpDisplay[i].x = baseX + i*14;
            hpDisplay[i].visible = i < LRAM.hp;
        }
        
        hpBG.x = baseX;
    }

    function prepareItemLabels()
    {
        var ly : Int = 38+12;
        var label : FlxBitmapText;

        for (_ in 0...Inventory.MaxItems)
        {
            label = PixelText.New(12, ly, "");
            add(label);
            inventoryLabels.push(label);
            
            ly += 12;
        }
    }

    function renderInventory()
    {
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
        }
    }

    function renderCounters()
    {
        starsLabel.text = "" + GameStatus.stars;
        clearsLabel.text = "" + GameStatus.getClearedExits();
    }

    function renderOrbs()
    {
        redOrb.visible = GameStatus.redOrb;
        blueOrb.visible = GameStatus.blueOrb;
        greenOrb.visible = GameStatus.greenOrb;
        yellowOrb.visible = GameStatus.yellowOrb;
    }
}