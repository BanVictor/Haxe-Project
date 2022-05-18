package;

import flixel.system.frontEnds.SoundFrontEnd;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.util.FlxSave;
import openfl.display.Sprite;

class Main extends Sprite {
	public static var curLevel = 0; 
	public static var levelsNumbers = ["001", "002", "003"];

	public function new() {
		var startFullscreen:Bool = false;
		var save:FlxSave = new FlxSave();
		save.bind("TurnBasedRPG");
		#if desktop
		if (save.data.fullscreen != null) {
			startFullscreen = save.data.fullscreen;
		}
		#end
		super();
		addChild(new FlxGame(320, 240, MenuState, 1, 60, 60, false, startFullscreen));
		FlxG.sound.volume = 0;
		if (save.data.volume != null) {
			FlxG.sound.volume = save.data.volume;
		}
		save.close();
	}
}
