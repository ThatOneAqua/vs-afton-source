package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.input.keyboard.FlxKey;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.display.FlxBackdrop;
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
import haxe.Json;
import flixel.input.mouse.FlxMouseEventManager;

using StringTools;

class AftonMenuState extends MusicBeatState
{
	public static var springtrapUnlocked:Bool;
	public static var shadowBonnieUnlocked:Bool;
	public static var matpatUnlocked:Bool;
	public static var scottUnlocked:Bool;

	public static var salvageBeaten:Bool;
	public static var nightmareBeaten:Bool;
	public static var umbraBeaten:Bool;
	public static var matpatBeaten:Bool;
	public static var scottBeaten:Bool;
	public static var fazbarsBeaten:Bool;

	public static var psychEngineVersion:String = '0.4.2'; //This is also used for Discord RPC
	public static var curSelected:Int = 0;

	var matpatKey:Array<FlxKey> = [FlxKey.THREE, FlxKey.NINE, FlxKey.FIVE, FlxKey.TWO, FlxKey.FOUR, FlxKey.EIGHT];
	var lastKeysPressed:Array<FlxKey> = [];

	var menuItems:FlxTypedGroup<FlxSprite>;
	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;
	
	var optionShit:Array<String> = ['afton', 'extras', 'options', 'credits'];

	var camFollow:FlxObject;
	var camFollowPos:FlxObject;
	var arrowMenu:FlxSprite;
	var difficultyMenu:FlxSprite;
	var wall:FlxBackdrop;
	var curDifficulty:Int = 2;

	var fazbarsCounter:Int = 0;

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

		FlxG.sound.playMusic(Paths.music('aftonMenu'), 0);

		FlxG.mouse.visible = true;

		var yScroll:Float = Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1);
		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menuBG'));
		bg.scrollFactor.set(0, yScroll);
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		wall = new FlxBackdrop(Paths.image('UI_Wall_Background'), 5, 1, true, true);
		wall.setPosition(0, 750);
		wall.updateHitbox();
		wall.antialiasing = ClientPrefs.globalAntialiasing;
		add(wall);

		var monitor:FlxSprite = new FlxSprite(-100, 0).loadGraphic(Paths.image('UI_Monitor'));
		monitor.setGraphicSize(Std.int(monitor.width * 1));
		monitor.scrollFactor.set();
		add(monitor);

		arrowMenu = new FlxSprite().loadGraphic(Paths.image('mainmenu/menu_afton_arrow'));
		arrowMenu.scrollFactor.set(0, 0);
		arrowMenu.setGraphicSize(Std.int(arrowMenu.width * 0.6));
		arrowMenu.updateHitbox();
		arrowMenu.antialiasing = ClientPrefs.globalAntialiasing;
		add(arrowMenu);

		difficultyMenu = new FlxSprite(-340, 150);
		difficultyMenu.frames = Paths.getSparrowAtlas('mainmenu/afton_menu_diff');
		difficultyMenu.animation.addByPrefix('easy', "afton_menu_diff easy", 1);
		difficultyMenu.animation.addByPrefix('normal', "afton_menu_diff normal", 1);
		difficultyMenu.animation.addByPrefix('hard', "afton_menu_diff hard", 1);
		difficultyMenu.setGraphicSize(Std.int(difficultyMenu.width * 0.6));
		difficultyMenu.updateHitbox();
		add(difficultyMenu);

		var aftonDifficulty:FlxSprite = new FlxSprite(difficultyMenu.x - 73, difficultyMenu.y - 90).loadGraphic(Paths.image('mainmenu/menu_afton_difficulty'));
		aftonDifficulty.setGraphicSize(Std.int(aftonDifficulty.width * 0.6));
		add(aftonDifficulty);

		var aftonSystem:FlxSprite = new FlxSprite(monitor.x - 523, monitor.y - 55).loadGraphic(Paths.image('mainmenu/menu_afton_system'));
		aftonSystem.setGraphicSize(Std.int(aftonSystem.width * 0.6));
		add(aftonSystem);

		var gtLogo:FlxSprite = new FlxSprite(-520, monitor.y - 810).loadGraphic(Paths.image('mainmenu/portrait/Character_Portrait_GT_Logo'));
		gtLogo.setGraphicSize(Std.int(gtLogo.width * 0.4));
		gtLogo.visible = FlxG.save.data.matpatUnlocked;
		gtLogo.antialiasing = true;
		add(gtLogo);

		var shadowPortrait:FlxSprite = new FlxSprite(-520, monitor.y - 810).loadGraphic(Paths.image('mainmenu/portrait/Character_Portrait_Shadow_Bonnie'));
		shadowPortrait.setGraphicSize(Std.int(shadowPortrait.width * 0.4));
		shadowPortrait.visible = FlxG.save.data.shadowBonnieUnlocked;
		shadowPortrait.antialiasing = true;
		add(shadowPortrait);

		var springPortrait:FlxSprite = new FlxSprite(-520, monitor.y - 810).loadGraphic(Paths.image('mainmenu/portrait/Character_Portrait_Spring_Bonnie'));
		springPortrait.setGraphicSize(Std.int(springPortrait.width * 0.4));
		springPortrait.visible = FlxG.save.data.salvageBeaten;
		springPortrait.antialiasing = true;
		add(springPortrait);

		var springtrapPortrait:FlxSprite = new FlxSprite(-520, monitor.y - 810).loadGraphic(Paths.image('mainmenu/portrait/Character_Portrait_Springtrap'));
		springtrapPortrait.setGraphicSize(Std.int(springtrapPortrait.width * 0.4));
		springtrapPortrait.visible = FlxG.save.data.nightmareBeaten;
		springtrapPortrait.antialiasing = true;
		add(springtrapPortrait);

		var aftonPortrait:FlxSprite = new FlxSprite(-520, monitor.y - 810).loadGraphic(Paths.image('mainmenu/portrait/Character_Portrait_Afton'));
		aftonPortrait.setGraphicSize(Std.int(aftonPortrait.width * 0.4));
		aftonPortrait.visible = true;
		aftonPortrait.antialiasing = true;
		add(aftonPortrait);

		FlxMouseEventManager.add(aftonPortrait, function onMouseDown(aftonPortrait:FlxSprite){fazbarsPlay();}, null);

		var scottPortrait:FlxSprite = new FlxSprite(-520, monitor.y - 810).loadGraphic(Paths.image('mainmenu/portrait/Character_Portrait_Scott'));
		scottPortrait.setGraphicSize(Std.int(scottPortrait.width * 0.4));
		scottPortrait.visible = FlxG.save.data.scottBeaten;
		scottPortrait.antialiasing = true;
		add(scottPortrait);

		var logo:FlxSprite = new FlxSprite(-425, -475).loadGraphic(Paths.image('thelogo'));
		logo.setGraphicSize(Std.int(logo.width * 0.3));
		logo.scrollFactor.set();
		logo.antialiasing = true;
		add(logo);
	//	logo.cameras = [camAchievement];

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		add(camFollowPos);


		//var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		//add(bg);

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		for (i in 0...optionShit.length)
		{
			var offsetY:Float = 400 - (Math.max(optionShit.length, 4) - 4) * 80;
			var menuItem:FlxSprite = new FlxSprite(130, (i * 50)  + offsetY).loadGraphic(Paths.image('mainmenu/menu_afton_' + optionShit[i]));
			menuItem.ID = i;
			menuItems.add(menuItem);
			menuItem.scrollFactor.set(0, 0);
			menuItem.antialiasing = ClientPrefs.globalAntialiasing;
			menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));
			menuItem.updateHitbox();
		}

		FlxG.camera.follow(camFollowPos, null, 1);

		var versionShit:FlxText = new FlxText(12, FlxG.height - 44, 0, "Psych Engine v" + psychEngineVersion, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		//add(versionShit);
		var versionShit:FlxText = new FlxText(12, FlxG.height - 24, 0, "Friday Night Funkin' v" + Application.current.meta.get('version'), 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		//add(versionShit);

		// NG.core.calls.event.logEvent('swag').send();

		changeItem();
		changeDiff();

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
			
		wall.x = FlxMath.lerp(wall.x, wall.x - 10, CoolUtil.boundTo(elapsed * 9, 0, 1));

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 5.6, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

		var finalKey:FlxKey = FlxG.keys.firstJustPressed();
		if(finalKey != FlxKey.NONE) {
			lastKeysPressed.push(finalKey); //Convert int to FlxKey
			if(lastKeysPressed.length > matpatKey.length)
			{
				lastKeysPressed.shift();
			}
				
			if(lastKeysPressed.length == matpatKey.length)
			{
				var isDifferent:Bool = false;
				for (i in 0...lastKeysPressed.length) {
					if(lastKeysPressed[i] != matpatKey[i]) {
						isDifferent = true;
						break;
					}
				}

				if(!isDifferent) {
					FlxG.mouse.visible = false;
					PlayState.storyPlaylist = ['Just-A-Theory'];
					PlayState.isStoryMode = false;
				
					var diffic = "";
					
					PlayState.SONG = Song.loadFromJson('just-a-theory' + diffic, 'just-a-theory');
					PlayState.storyWeek = 0;
					PlayState.campaignScore = 0;
					
					matpatUnlocked = true;

					FlxG.save.data.matpatUnlocked = matpatUnlocked;
					FlxG.save.flush();
		
				
					LoadingState.loadAndSwitchState(new PlayState());
					FlxG.sound.music.fadeOut();

				}
			}
		}
		
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

			if (controls.UI_LEFT_P)
			{
				changeDiff(-1);
			}
	
			if (controls.UI_RIGHT_P)
			{
				changeDiff(1);
			}

			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}

			if (controls.ACCEPT)
			{
				if (optionShit[curSelected] == 'donate')
				{
					CoolUtil.browserLoad('https://ninja-muffin24.itch.io/funkin');
				}
				else
				{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));

					menuItems.forEach(function(spr:FlxSprite)
					{
						FlxFlicker.flicker(arrowMenu, 1, 0.06, false, false, function(flick:FlxFlicker)
						{
							var daChoice:String = optionShit[curSelected];

							switch (daChoice)
							{
								case 'afton':
									playStory();
								case 'extras':
									MusicBeatState.switchState(new FreeplayState());
								case 'credits':
									MusicBeatState.switchState(new CreditsState());
								case 'options':
									MusicBeatState.switchState(new OptionsState());
										
							}
						});
					});
				}
			}
		}

		if (FlxG.keys.justPressed.ONE || FlxG.keys.justPressed.TWO ||FlxG.keys.justPressed.THREE ||FlxG.keys.justPressed.FOUR ||FlxG.keys.justPressed.FIVE ||FlxG.keys.justPressed.SIX ||FlxG.keys.justPressed.SEVEN ||FlxG.keys.justPressed.EIGHT ||FlxG.keys.justPressed.NINE)
			FlxG.sound.play(Paths.sound('scrollMenu'));
		super.update(elapsed);
	}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.offset.y = 0;
			spr.updateHitbox();

			var daChoice:String = optionShit[curSelected];

			menuItems.forEach(function(spr:FlxSprite)
			{
				arrowMenu.x = spr.x - 80;	

				switch (daChoice)
				{
					case 'afton':
						arrowMenu.y = spr.y - 157.5;
					case 'extras':
						arrowMenu.y = spr.y - 105;
					case 'options':
						arrowMenu.y = spr.y - 49;
					case 'credits':
						arrowMenu.y = spr.y - 5;	
				}
			});
		
		});
	}

	public function playStory()
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
	function changeDiff(huh:Int = 0)
	{
		curDifficulty += huh;
	
		if (curDifficulty >= 3)
			curDifficulty = 0;
		if (curDifficulty < 0)
			curDifficulty = 2;

		var difficArray:Array<String> = ['easy','normal','hard'];

		difficultyMenu.animation.play(difficArray[curDifficulty]);
		switch (curDifficulty)
		{
			case 1:
				difficultyMenu.x = -343;
			default:
				difficultyMenu.x = -318;
		}
	}

	function fazbarsPlay()
	{
		fazbarsCounter += 1;

		if(fazbarsCounter == 1987 && !fazbarsBeaten){
			FlxG.mouse.visible = false;
			PlayState.storyPlaylist = ['Fazbars'];
			PlayState.isStoryMode = false;
					
			var diffic = "";
						
			PlayState.SONG = Song.loadFromJson('fazbars' + diffic, 'fazbars');
			PlayState.storyWeek = 0;
			PlayState.campaignScore = 0;
			
			LoadingState.loadAndSwitchState(new PlayState());
			FlxG.sound.music.fadeOut();
		}
	}
}
