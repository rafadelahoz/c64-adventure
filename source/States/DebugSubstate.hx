package;

import flixel.FlxObject;
import flixel.text.FlxBitmapText;
import text.PixelText;
import flixel.FlxBasic;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.FlxSubState;

class DebugSubstate extends FlxSubState
{
    // Char width (6px)
    public static final CW : Int = 6;
    // Char height (6px)
    public static final CH : Int = 6;

    public var world : World;
    var cursor : DebugCursor;

    var inventoryPanel : DebugInventoryPanel;
    var playerPanel : DebugPlayerPanel;
    var switchesPanel : DebugSwitchesPanel;

    var alreadyBlurred : Bool;

    public function new(World : World)
    {
        super(0xFF40318d);

        world = World;

        text(1, 1, "- DEBUG MENU - ");
        text(1, 3, "Press F9 to close");

        addObject(inventoryPanel = new DebugInventoryPanel(char(1), line(5), this));
        addObject(playerPanel = new DebugPlayerPanel(char(18), line(5), this));
        addObject(switchesPanel = new DebugSwitchesPanel(char(18+18), line(5), this));

        inventoryPanel.focus();
        
        cursor = new DebugCursor();
        addObject(cursor);

        alreadyBlurred = false;
    }

    function char(char : Int) : Int
    {
        return char * CW;
    }

    function line(line : Int) : Int
    {
        return line * CH;
    }

    function text(char : Int, line : Int, text : String, ?color : Int = 0xFFFFFFFF) : FlxBitmapText
    {
        var object : FlxBitmapText = PixelText.New(char * 6, line * 6, text, color);
        addObject(object);
        return object;
    }

    function addObject(object : FlxSprite)
    {
        object.cameras = [world.hudcam];
        object.scrollFactor.set(0, 0);
        add(object);
    }

    public function onPanelBlur(panel : FlxObject, direction : BlurDirection)
    {
        // Blur only once per step
        if (!alreadyBlurred)
        {
            alreadyBlurred = true;

            if (panel == switchesPanel)
            {
                switch (direction)
                {
                    case BlurDirection.Right:
                        switchesPanel.focus();
                    case BlurDirection.Left:
                        playerPanel.focus();
                        switchesPanel.blur();
                }
            }
            else if (panel == playerPanel)
            {
                switch (direction)
                {
                    case BlurDirection.Right:
                        switchesPanel.focus();
                        playerPanel.blur();
                    case BlurDirection.Left:
                        inventoryPanel.focus();
                        playerPanel.blur();
                }
            }
            else if (panel == inventoryPanel)
            {
                switch (direction)
                {
                    case BlurDirection.Right:
                        playerPanel.focus();
                        inventoryPanel.blur();
                    default:
                        inventoryPanel.focus();
                }
            }
        }
    }

    override public function update(elapsed : Float)
    {
        if (FlxG.keys.justPressed.F9)
            close();

        super.update(elapsed);

        alreadyBlurred = false;
    }
}

class DebugCursor extends FlxSprite
{
    var gfx : FlxBitmapText;

    public function new()
    {
        super(0, 0);

        gfx = PixelText.New(0, 0, ">", color);
        makeGraphic(1, 1, 0x00000000);
    }

    public function placeAt(char: Int, line : Int)
    {
        x = DebugSubstate.CW * char;
        y = DebugSubstate.CH * char;
    }

    override public function draw()
    {
        gfx.draw();

        super.draw();
    }
}

enum BlurDirection { Left; Right; }