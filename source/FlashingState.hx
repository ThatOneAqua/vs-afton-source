package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.effects.FlxFlicker;
import lime.app.Application;
import flixel.addons.transition.FlxTransitionableState;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;

class FlashingState extends MusicBeatState
{
	public static var leftState:Bool = false;

	var warnText:FlxText;
	override function create()
	{
		super.create();

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);

		var wall:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('UI_Wall_Background'));
		wall.antialiasing = true;
		wall.screenCenter();
		add(wall);

		var helpy:FlxSprite = new FlxSprite(480, 0).loadGraphic(Paths.image('Helpy_Settings_Menu'));
		helpy.setGraphicSize(Std.int(helpy.width * 0.4));
		helpy.antialiasing = true;
		helpy.screenCenter(Y);
		add(helpy);

		warnText = new FlxText(50, 0, FlxG.width,
			"WARNING: This mod contains flashing lights\n
			and jumpscares.\n
			If you are prone to epilepsy or eyestrain, \n
			do not progress further.\n
			You have been warned, thank you for playing\n
			Funkin' at Freddy's.",
			16);
		warnText.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, LEFT);
		warnText.screenCenter(Y);
		add(warnText);
	}

	override function update(elapsed:Float)
	{
		if(!leftState) {
			var back:Bool = controls.BACK;
			if (controls.ACCEPT || back) {
				leftState = true;
				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
				if(!back) {
					ClientPrefs.flashing = false;
					ClientPrefs.saveSettings();
					FlxG.sound.play(Paths.sound('confirmMenu'));
					FlxFlicker.flicker(warnText, 1, 0.1, false, true, function(flk:FlxFlicker) {
						new FlxTimer().start(0.5, function (tmr:FlxTimer) {
							MusicBeatState.switchState(new TitleState());
						});
					});
				} else {
					FlxG.sound.play(Paths.sound('cancelMenu'));
					FlxTween.tween(warnText, {alpha: 0}, 1, {
						onComplete: function (twn:FlxTween) {
							MusicBeatState.switchState(new TitleState());
						}
					});
				}
			}
		}
		super.update(elapsed);
	}
}
