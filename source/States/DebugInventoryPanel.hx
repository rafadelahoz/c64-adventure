package;

import flixel.effects.FlxFlicker;
import DebugSubstate.BlurDirection;
import flixel.util.FlxTimer;
import flixel.FlxG;
import Inventory.ItemData;
import flixel.FlxSprite;
import text.PixelText;
import flixel.text.FlxBitmapText;
import flixel.group.FlxSpriteGroup;

class DebugInventoryPanel extends FlxSpriteGroup
{
    var substate : DebugSubstate;

    var labels : Array<FlxBitmapText>;
    var current : Int;
    var items : Map<String, ItemData>;

    var focused : Bool;

    public function new(X : Float, Y : Float, DebugState : DebugSubstate)
    {
        super(X, Y);

        substate = DebugState;

        setupItems();

        text(0, 0, "#=============#");

        var char : Int = 1;
        var line : Int = 1;
        labels = [];
        for (item in items.keys())
        {
            labels.push(text(char, line, item));
            line++;
        }

        current = 0;

        focused = false;
    }

    public function focus()
    {
        focused = true;
        FlxFlicker.flicker(this, 0.25);
    }

    public function blur()
    {
        focused = false;
    }

    override public function update(elapsed : Float)
    {
        if (focused)
        {
            if (Gamepad.justPressed(Gamepad.Up))
            {
                current -= 1;
                if (current < 0)
                    current = labels.length-1;
            }
            else if (Gamepad.justPressed(Gamepad.Down))
                current = (current+1) % labels.length;

            for (label in labels)
                label.color = 0xFFFFFFFF;
            
            labels[current].color = 0xFFFFde1a;

            if (Gamepad.justPressed(Gamepad.A))
            {
                var item : ItemData = items.get(labels[current].text);
                var data : ItemData = {
                    id: "DEBUG-" + FlxG.random.int(3000),
                    type: item.type,
                    label: item.label,
                    properties: item.properties
                };

                // Try to add it to the current slot,
                // otherwise, find the first empty one
                if (Inventory.GetCurrent == null)
                    Inventory.Put(data);
                else {
                    for (i in 0...Inventory.MaxItems)
                    {
                        if (Inventory.items[i] == null)
                        { 
                            Inventory.items[i] = data;
                            break;
                        }
                    }
                }

                timedText(Std.int((labels[current].x - x)/ 6), Std.int((labels[current].y - y) / 6), "ADDED!", 0.35);
            }
            else if (Gamepad.justPressed(Gamepad.Left))
                substate.onPanelBlur(this, BlurDirection.Left);
            else if (Gamepad.justPressed(Gamepad.Right))
                substate.onPanelBlur(this, BlurDirection.Right);
        }

        super.update(elapsed);
    }

    function text(char : Int, line : Int, text : String, ?color : Int = 0xFFFFFFFF) : FlxBitmapText
    {
        var object : FlxBitmapText = PixelText.New(char * 6, line * 6, text, color);
        addObject(object);
        return object;
    }

    function timedText(char : Int, line : Int, text : String, ?color : Int = 0xFF0aff1a, duration : Float)
    {
        var object : FlxBitmapText = PixelText.New(char * 6, line * 6, text, color);
        addObject(object);
        new FlxTimer().start(duration, function(t:FlxTimer) {
            t.destroy();
            object.destroy();
        });
    }

    function addObject(object : FlxSprite)
    {
        // object.cameras = [world.hudcam];
        object.scrollFactor.set(0, 0);
        add(object);
    }

    function setupItems() 
    {
        items = new Map<String, ItemData>();
        items.set("SHRIMP",     {id: null, type: "SHRIMP", label: "SHRIMP"});
        items.set("DONUT",      {id: null, type: "DONUT", label: "DONUT"});
        items.set("KEY",        {id: null, type: "KEY", label: "KEY", properties: {flavour: "NONE"}});
        items.set("MAUVE KEY",  {id: null, type: "KEY", label: "MAUVE KEY", properties: {flavour: "MAUVE"}});
        items.set("CHERRY KEY", {id: null, type: "KEY", label: "CHERRY KEY", properties: {flavour: "CHERRY"}});
        items.set("SPEED POTION", {id: null, type: "POTION", label: "SPEED POTION", properties: {flavour: "SPEED"}});
    }
}