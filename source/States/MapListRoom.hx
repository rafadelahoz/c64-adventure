package;

import lime.utils.AssetType;
import lime.utils.Assets;
import flixel.FlxState;

class MapListRoom extends FlxState
{

    override public function create() : Void
    {
        super.create();

        bgColor = 0xFF000000;

        var textAssets : Array<String> = Assets.list(AssetType.TEXT);
        textAssets = textAssets.filter(function (assetName : String) : Bool {
            return assetName.indexOf("assets/maps/") > -1;
        });
    }
}