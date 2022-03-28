package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxSprite;
import flixel.FlxCamera;
import StageData;


class GameOverSubstate extends MusicBeatSubstate
{
	var bf:Boyfriend;
	var camFollow:FlxPoint;
	var camFollowPos:FlxObject;
	var updateCamera:Bool = false;
	var stageData:StageFile = StageData.getStageFile(PlayState.curStage);

	var stageSuffix:String = "";

	var lePlayState:PlayState;
	var cameraGame:FlxCamera;

	public static var characterName:String = 'bf';
	public static var deathSoundName:String = 'fnf_loss_sfx';
	public static var loopSoundName:String = 'aftonMenu';
	public static var endSoundName:String = 'gameOverEnd';

	var retry:FlxSprite;

	public static function resetVariables() {
		characterName = 'bf';
		deathSoundName = 'fnf_loss_sfx';
		loopSoundName = 'aftonMenu';
		endSoundName = 'gameOverEnd';
	}

	public function new(x:Float, y:Float, camX:Float, camY:Float, camera:FlxCamera, state:PlayState)
	{
		//FlxG.camera.zoom = stageData.defaultZoom;

		lePlayState = state;
		state.setOnLuas('inGameOver', true);
		super();

		cameraGame = camera;

		Conductor.songPosition = 0;

		retry = new FlxSprite(0, 0);

		retry.frames = Paths.getSparrowAtlas('retry');
		retry.animation.addByPrefix('idle', "retry idle", 16);
		retry.animation.addByPrefix('menu', "retry menu", 16);
		retry.animation.addByPrefix('retry', "retry retry", 16);
		retry.setGraphicSize(Std.int(retry.width * 1));
		retry.scrollFactor.set();
		retry.antialiasing = true;
		retry.updateHitbox();
		retry.screenCenter();
		add(retry);
		retry.animation.play('idle');
		retry.cameras = [cameraGame];
		retry.alpha = 0;

		coolStartDeath();

		FlxTween.tween(retry, {alpha: 1}, 2);	

		//FlxG.sound.play(Paths.sound(deathSoundName));
		Conductor.changeBPM(100);

		var exclude:Array<Int> = [];

		/*bf = new Boyfriend(x, y, characterName);
		add(bf);

		camFollow = new FlxPoint(bf.getGraphicMidpoint().x, bf.getGraphicMidpoint().y);

		FlxG.sound.play(Paths.sound(deathSoundName));
		Conductor.changeBPM(100);
		// FlxG.camera.followLerp = 1;
		// FlxG.camera.focusOn(FlxPoint.get(FlxG.width / 2, FlxG.height / 2));
		FlxG.camera.scroll.set();
		FlxG.camera.target = null;

		bf.playAnim('firstDeath');

		var exclude:Array<Int> = [];

		camFollowPos = new FlxObject(0, 0, 1, 1);
		camFollowPos.setPosition(FlxG.camera.scroll.x + (FlxG.camera.width / 2), FlxG.camera.scroll.y + (FlxG.camera.height / 2));
		add(camFollowPos);*/


	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		lePlayState.callOnLuas('onUpdate', [elapsed]);
		if(updateCamera) {
			var lerpVal:Float = CoolUtil.boundTo(elapsed * 0.6, 0, 1);
			//camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));
		}

		if (controls.ACCEPT)
		{
			endBullshit();
		}

		if (controls.BACK)
		{
			if(!isEnding){
				isEnding = true;
				retry.animation.play('menu');
				FlxG.sound.play(Paths.music(endSoundName));
				FlxG.sound.music.stop();
				PlayState.deathCounter = 0;
				PlayState.seenCutscene = false;
				new FlxTimer().start(0.7, function(tmr:FlxTimer)
				{
					FlxTween.tween(retry, {alpha: 0}, 2, {
						onComplete: function(tween:FlxTween)
						{
							if (PlayState.isStoryMode)
								if(FlxG.save.data.weekCompleted != null)
									MusicBeatState.switchState(new AftonMenuState());
								else
									MusicBeatState.switchState(new MainMenuState());
							else
								MusicBeatState.switchState(new FreeplayState());
	
							FlxG.sound.playMusic(Paths.music('aftonMenu'));
							lePlayState.callOnLuas('onGameOverConfirm', [false]);
						}
					});	
				});
			}
		}

		/*if (bf.animation.curAnim.name == 'firstDeath')
		{
			if(bf.animation.curAnim.curFrame == 12)
			{
				//FlxG.camera.follow(camFollowPos, LOCKON, 1);
				updateCamera = true;
			}

			if (bf.animation.curAnim.finished)
			{
				coolStartDeath();
				bf.startedDeath = true;
			}
		}*/

		if (FlxG.sound.music.playing)
		{
			Conductor.songPosition = FlxG.sound.music.time;
		}
		lePlayState.callOnLuas('onUpdatePost', [elapsed]);
	}

	override function beatHit()
	{
		super.beatHit();

		//FlxG.log.add('beat');
	}

	var isEnding:Bool = false;

	function coolStartDeath(?volume:Float = 1):Void
	{	
		new FlxTimer().start(2, function(tmr:FlxTimer){
			if(PlayState.curStage == 'fright')
				FlxG.sound.play(Paths.sound('springtrapLines/springDeath_' + FlxG.random.int(0, 6)), 0.4);
			if(PlayState.curStage == 'frightAAABURN')
				FlxG.sound.play(Paths.sound('springtrapLines/springDeath_' + FlxG.random.int(0, 6)), 0.4);
		});
	}

	function endBullshit():Void
	{
		if (!isEnding)
		{
			isEnding = true;
			//bf.playAnim('deathConfirm', true);
			retry.animation.play('retry');
			FlxG.sound.music.stop();
			FlxG.sound.play(Paths.music(endSoundName));
			new FlxTimer().start(0.7, function(tmr:FlxTimer)
			{
				FlxTween.tween(retry, {alpha: 0}, 2, {
					onComplete: function(tween:FlxTween)
					{
						MusicBeatState.resetState();
					}
				});	
			});
			lePlayState.callOnLuas('onGameOverConfirm', [true]);
		}
	}
}
