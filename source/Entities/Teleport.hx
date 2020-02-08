package;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxTween.FlxTweenManager;
import flixel.FlxSprite;

class Teleport extends Entity
{
    var data : TeleportData;

    public function new(X : Float, Y : Float, Width : Float, Height : Float, Data : TeleportData, World : World)
    {
        super(X, Y, World);

        makeGraphic(Std.int(Width), Std.int(Height), 0x44FFFFFF);

        data = Data;
    }

    public function onTeleport() 
    {
        world.pause();
        var fader : Fader = new Fader(world);
        fader.fade(false, function() {
            world.teleportTo(data);
        });
    }
}

typedef TeleportData = {
    var target : Int;   // Target room id
    var tileX : Int;    // Target tile x
    var tileY : Int;    // Target tile y
};