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
        // whawtha!
        trace("TELEPORTTTT");

        world.pause();
        var fader : FlxSprite = new FlxSprite(0, 0);
        world.add(fader);
        fader.cameras = [world.screencam];
        fader.scrollFactor.set(0, 0);
        fader.makeGraphic(320, 240, 0xFF000000);
        fader.alpha = 0;
        FlxTween.tween(fader, {alpha: 1}, 0.25, {
            ease: FlxEase.linear, onComplete: function(t:FlxTween) {
                world.teleportTo(data);
            }
        });
        
    }
}

typedef TeleportData = {
    var target : Int;   // Target room id
    var tileX : Int;    // Target tile x
    var tileY : Int;    // Target tile y
};