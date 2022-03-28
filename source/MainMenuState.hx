package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import Achievements;
import editors.MasterEditorMenu;
import flixel.util.FlxTimer;

using StringTools;

class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '0.4.2'; //This is also used for Discord RPC
	public static var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;
	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;
	
	var optionShit:Array<String> = ['afton', 'difficulty', 'options'];
	var difficArray:Array<String> = ['easy','normal','hard'];

	var curDifficulty:Int = 2;
	var magenta:FlxSprite;
	var camFollow:FlxObject;
	var camFollowPos:FlxObject;
	var arrowMenu:FlxSprite;
	var menuDiff:FlxSprite;

	override function create()
	{
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		camGame = new FlxCamera();
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camAchievement);
		FlxCamera.defaultCameras = [camGame];

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		FlxG.sound.playMusic(Paths.music('partyMenu'), 0);

		var yScroll:Float = Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1);
		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menuBG'));
		bg.scrollFactor.set(0, yScroll);
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		//add(bg);
		
		var box:FlxSprite = new FlxSprite(0, 270).loadGraphic(Paths.image('mainmenu/menu_box'));
		box.scrollFactor.set(0, 0);
		box.setGraphicSize(Std.int(box.width * 0.6));
		box.updateHitbox();
		box.screenCenter(X);
		box.antialiasing = ClientPrefs.globalAntialiasing;
		add(box);

		arrowMenu = new FlxSprite(552, 286).loadGraphic(Paths.image('mainmenu/menu_arrow'));
		arrowMenu.scrollFactor.set(0, 0);
		arrowMenu.setGraphicSize(Std.int(arrowMenu.width * 0.6));
		arrowMenu.updateHitbox();
		arrowMenu.antialiasing = ClientPrefs.globalAntialiasing;
		add(arrowMenu);

		FlxFlicker.flicker(arrowMenu, 0, 0.75, true);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		add(camFollowPos);

		magenta = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		magenta.scrollFactor.set(0, yScroll);
		magenta.setGraphicSize(Std.int(magenta.width * 1.175));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.antialiasing = ClientPrefs.globalAntialiasing;
		magenta.color = 0xFFfd719b;
		//add(magenta);

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var offset:Float = 290 - (Math.max(optionShit.length, 4) - 4) * 80;

		for (i in 0...optionShit.length)
		{
			if(i != 1){
				var menuItem:FlxSprite = new FlxSprite(-500, (i * 50)  + offset).loadGraphic(Paths.image('mainmenu/menu_' + optionShit[i]));
				menuItem.ID = i;
				menuItem.screenCenter(X);
				menuItems.add(menuItem);
				menuItem.scrollFactor.set(0, 0);
				menuItem.antialiasing = ClientPrefs.globalAntialiasing;
				menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));
				menuItem.updateHitbox();
			}
		}

		menuDiff = new FlxSprite(-380, (1 * 50) + offset);
		menuDiff.frames = Paths.getSparrowAtlas('mainmenu/menu_difficulty');
		menuDiff.animation.addByPrefix('easy', "easy", 24);
		menuDiff.animation.addByPrefix('normal', "normal", 24);
		menuDiff.animation.addByPrefix('hard', "hard", 24);
		menuDiff.animation.play('hard');
		menuDiff.screenCenter(X);
		menuDiff.x += 41;
		menuDiff.y -= 5;
		menuDiff.setGraphicSize(Std.int(menuDiff.width * 0.62));
		add(menuDiff);
		menuDiff.scrollFactor.set(0, 0);
		menuDiff.antialiasing = ClientPrefs.globalAntialiasing;
		menuDiff.updateHitbox();

		FlxG.camera.follow(camFollowPos, null, 1);

		// NG.core.calls.event.logEvent('swag').send();

		changeItem();

		#if ACHIEVEMENTS_ALLOWED
		Achievements.loadAchievements();
		var leDate = Date.now();
		if (!Achievements.achievementsUnlocked[achievementID][1] && leDate.getDay() == 5 && leDate.getHours() >= 18) { //It's a friday night. WEEEEEEEEEEEEEEEEEE
			Achievements.achievementsUnlocked[achievementID][1] = true;
			giveAchievement();
			ClientPrefs.saveSettings();
		}
		#end

		super.create();
	}

	#if ACHIEVEMENTS_ALLOWED
	// Unlocks "Freaky on a Friday Night" achievement
	var achievementID:Int = 0;
	function giveAchievement() {
		add(new AchievementObject(achievementID, camAchievement));
		FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
		trace('Giving achievement ' + achievementID);
	}
	#end

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 5.6, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

		if (!selectedSomethin)
		{
			if (controls.UI_UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.UI_DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			/*if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}*/

			if (controls.ACCEPT)
			{
				if (optionShit[curSelected] == 'difficulty')
				{
					changeDiff(1);
				}
				else
				{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));

					if(ClientPrefs.flashing) FlxFlicker.flicker(magenta, 1.1, 0.15, false);
					FlxFlicker.flicker(arrowMenu, 5, 0.06, false);

					var daChoice:String = optionShit[curSelected];
							
					new FlxTimer().start(0.8, function(tmr:FlxTimer)
					{
						switch (daChoice)
						{
							case 'afton':
								playStory();
							case 'options':
								MusicBeatState.switchState(new OptionsState());
						}
					});		
				}
			}
			#if desktop
			else if (FlxG.keys.justPressed.SEVEN)
			{
				selectedSomethin = true;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
			#end
		}

		super.update(elapsed);

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.screenCenter(X);
		});
	}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= 3)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = 2;

		var daChoice:String = optionShit[curSelected];
		
		switch(daChoice)
		{
			case 'afton':
				arrowMenu.y = 286;
			case 'difficulty':
				arrowMenu.y = 335;
			case 'options':
				arrowMenu.y = 385;
		}
	}
	function changeDiff(huh:Int = 0)
	{
		curDifficulty += huh;
		
		if (curDifficulty >= 3)
			curDifficulty = 0;
		if (curDifficulty < 0)
			curDifficulty = 2;

		menuDiff.animation.play(difficArray[curDifficulty]);
	}

	function playStory()
	{
		FlxG.mouse.visible = false;
		PlayState.storyPlaylist = ['Celebrate', 'Follow-Me', 'Midnight', "You-Can't"];
		PlayState.isStoryMode = true;
		
		var diffic = "";
		
		switch (curDifficulty)
		{
			case 0:
				diffic = '-easy';
			case 2:
				diffic = '-hard';
		}
		
		PlayState.storyDifficulty = curDifficulty;
			
		PlayState.SONG = Song.loadFromJson('celebrate' + diffic, 'celebrate');
		PlayState.storyWeek = 0;
		PlayState.campaignScore = 0;
		
		LoadingState.loadAndSwitchState(new PlayState());
		FlxG.sound.music.fadeOut();
	}
}
