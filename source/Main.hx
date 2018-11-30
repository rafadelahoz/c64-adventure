package;

import flixel.FlxGame;
import openfl.display.Sprite;

class Main extends Sprite
{
	var fps : Int = 60;

	public function new()
	{
		super();
		addChild(new FlxGame(320, 180, World, 1, fps, fps));
	}
}
