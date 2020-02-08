package;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxSprite;

class Fader extends FlxSprite
{
    var tweenedAlpha : Float;

    public function new(World : World)
    {
        super(0, 0);

        cameras = [World.screencam];

        scrollFactor.set(0, 0);
        makeGraphic(Constants.ScreenWidth, Constants.ScreenHeight, 0xFF000000);

        alpha = 0;

        World.add(this);
    }

    public function fade(FadeIn : Bool, Callback : Void -> Void)
    {
        var targetAlpha : Float = (FadeIn ? 0 : 1);
        alpha = (FadeIn ? 1 : 0);
        
        tweenedAlpha = alpha;
        
        FlxTween.tween(this, {tweenedAlpha: targetAlpha}, 0.25, {
            ease: FlxEase.linear, onComplete: function(t:FlxTween) {
                Callback();
            }
        });
    }

    override public function draw()
    {
        // Alpha is chunky!
        // alpha = Math.floor(tweenedAlpha * 10) / 10;
        
        if (tweenedAlpha > 0.85)
            alpha = 1;
        else if (tweenedAlpha > 0.66)
            alpha = 0.66;
        else if (tweenedAlpha > 0.33)
            alpha = 0.33;
        else
            alpha = 0;

        super.draw();
    }
}