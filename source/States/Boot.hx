package;

import flixel.FlxObject;
import openfl.events.KeyboardEvent;
import flixel.util.FlxTimer;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.group.FlxGroup;
import flixel.tile.FlxTilemap;

import MapReader.RoomData;
import MapReader.MapData;

class Boot extends FlxState
{

    override public function create() : Void
    {
        super.create();

        bgColor = 0xFF000000;

        GameController.Init();

        GameController.EnterMap();
    }
}