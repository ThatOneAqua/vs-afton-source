package;

#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.display.FlxBackdrop;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import lime.utils.Assets;
import flixel.system.FlxSound;
import openfl.utils.Assets as OpenFlAssets;
import WeekData;

using StringTools;

class FreeplayState extends MusicBeatState
{
	var songs:Array<SongMetadata> = [];

	var selector:FlxText;
	private static var curSelected:Int = 0;
	private static var curDifficulty:Int = 1;

	var scoreBG:FlxSprite;
	var scoreText:FlxText;
	var diffText:FlxText;
	var lerpScore:Int = 0;
	var lerpRating:Float = 0;
	var intendedScore:Int = 0;
	var intendedRating:Float = 0;

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;

	private var iconArray:Array<HealthIcon> = [];

	var bg:FlxSprite;
	var grid1:FlxBackdrop;
	var grid2:FlxBackdrop;
	var songImage:FlxSprite;
	var challenger:FlxSprite;
	var intendedColor:Int;
	var colorTween:FlxTween;

	var newSong:Bool;
	var unlocked:Bool = false;

	override function create()
	{
		FlxG.mouse.visible = false;
		
		#if MODS_ALLOWED
		Paths.destroyLoadedImages();
		#end
		WeekData.reloadWeekFiles(false);
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		for (i in 0...WeekData.weeksList.length) {
			var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
			var leSongs:Array<String> = [];
			var leChars:Array<String> = [];
			for (j in 0...leWeek.songs.length) {
				leSongs.push(leWeek.songs[j][0]);
				leChars.push(leWeek.songs[j][1]);
			}

			WeekData.setDirectoryFromWeek(leWeek);
			for (song in leWeek.songs) {
				var colors:Array<Int> = song[2];
				if(colors == null || colors.length < 3) {
					colors = [146, 113, 253];
				}
				addSong(song[0], i, song[1], FlxColor.fromRGB(colors[0], colors[1], colors[2]));
			}
		}
		WeekData.setDirectoryFromWeek();

		var initSonglist = CoolUtil.coolTextFile(Paths.txt('freeplaySonglist'));
		for (i in 0...initSonglist.length)
		{
			if(initSonglist[i] != null && initSonglist[i].length > 0) {
				var songArray:Array<String> = initSonglist[i].split(":");
				addSong(songArray[0], 0, songArray[1], Std.parseInt(songArray[2]));
			}
		}

		// LOAD MUSIC

		// LOAD CHARACTERS

		bg = new FlxSprite().makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		grid1 = new FlxBackdrop(Paths.image('fpstuff/gridsquarelol'), 5, 5, true, true);
		grid1.antialiasing = ClientPrefs.globalAntialiasing;
		add(grid1);

		grid2 = new FlxBackdrop(Paths.image('fpstuff/gridsquarelmao'), 3, 3, true, true);
		grid2.antialiasing = ClientPrefs.globalAntialiasing;
		add(grid2);

		grpSongs = new FlxTypedGroup<Alphabet>();
		//add(grpSongs);

		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i].songName, true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpSongs.add(songText);

			Paths.currentModDirectory = songs[i].folder;
			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			icon.sprTracker = songText;

			// using a FlxGroup is too much fuss!
			iconArray.push(icon);
			//add(icon);

			// songText.x += 40;
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
			// songText.screenCenter(X);
		}
		WeekData.setDirectoryFromWeek();

		scoreText = new FlxText(0, 5, 0, "", 32);
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, LEFT);

		scoreBG = new FlxSprite(scoreText.x - 6, 0).makeGraphic(1, 66, 0xFF000000);
		scoreBG.alpha = 0.6;
		//add(scoreBG);

		diffText = new FlxText(scoreText.x, 630, 0, "", 24);
		diffText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER);
		diffText.font = scoreText.font;
		diffText.screenCenter(X);
		add(diffText);

		add(scoreText);

		if(curSelected >= songs.length) curSelected = 0;
		grid1.color = songs[curSelected].color;
		grid2.color = songs[curSelected].color;
		intendedColor = grid1.color;
		changeSelection();
		changeDiff();

		var swag:Alphabet = new Alphabet(1, 0, "swag");

		// JUST DOIN THIS SHIT FOR TESTING!!!
		/* 
			var md:String = Markdown.markdownToHtml(Assets.getText('CHANGELOG.md'));

			var texFel:TextField = new TextField();
			texFel.width = FlxG.width;
			texFel.height = FlxG.height;
			// texFel.
			texFel.htmlText = md;

			FlxG.stage.addChild(texFel);

			// scoreText.textField.htmlText = md;

			trace(md);
		 */

		var textBG:FlxSprite = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
		textBG.alpha = 0.6;
		//add(textBG);
		#if PRELOAD_ALL
		var leText:String = "Press SPACE to listen to this Song / Press RESET to Reset your Score and Accuracy.";
		#else
		var leText:String = "Press RESET to Reset your Score and Accuracy.";
		#end
		var text:FlxText = new FlxText(textBG.x, textBG.y + 4, FlxG.width, leText, 18);
		text.setFormat(Paths.font("vcr.ttf"), 18, FlxColor.WHITE, RIGHT);
		text.scrollFactor.set();
		//add(text);

		songImage = new FlxSprite();

		songImage.frames = Paths.getSparrowAtlas('fpstuff/freeplay');
		
		songImage.animation.addByPrefix('newsong', "freeplay newsong", 2);
		songImage.animation.addByPrefix('locked', "freeplay lock", 12);
		songImage.animation.addByPrefix('celebrate', "freeplay celebrate", 12);
		songImage.animation.addByPrefix('follow-me', "freeplay follow-me", 12);
		songImage.animation.addByPrefix('midnight', "freeplay midnight", 12);
		songImage.animation.addByPrefix("you-can't", "freeplay you-can't", 12);
		songImage.animation.addByPrefix('salvage', "freeplay salvage", 12);
		songImage.animation.addByPrefix('nightmare', "freeplay nightmare", 12);
		songImage.animation.addByPrefix('umbra', "freeplay umbra", 12);
		songImage.animation.addByPrefix('just-a-theory', "freeplay just-a-theory", 12);
		songImage.animation.addByPrefix('fourth-wall', "freeplay fourth-wall", 12);
		songImage.animation.addByPrefix('fazbars', "freeplay fazbars", 12);
		songImage.animation.addByPrefix('consequences', "freeplay consequences", 12);
		songImage.screenCenter();
		add(songImage);
		songImage.animation.play("you-can't");

		var arrowleft:FlxSprite = new FlxSprite(songImage.x - 200, -100).loadGraphic(Paths.image('fpstuff/selectArrow'));
		arrowleft.antialiasing = ClientPrefs.globalAntialiasing;
		arrowleft.flipX = true;
		arrowleft.setGraphicSize(Std.int(arrowleft.width * 0.5));
		add(arrowleft);

		var arrowRight:FlxSprite = new FlxSprite(songImage.x + 450, -100).loadGraphic(Paths.image('fpstuff/selectArrow'));
		arrowRight.antialiasing = ClientPrefs.globalAntialiasing;
		arrowRight.setGraphicSize(Std.int(arrowRight.width * 0.5));
		add(arrowRight);

		scoreText.x = songImage.x;
		scoreText.y = songImage.y -40;

		challenger = new FlxSprite(0, songImage.y + 520);

		challenger.frames = Paths.getSparrowAtlas('fpstuff/challenge_appear');
		challenger.animation.addByPrefix('rainbow', "challenge_appear rainbow", 24);
		challenger.setGraphicSize(Std.int(challenger.width * 1.5));
		challenger.updateHitbox();
		challenger.screenCenter(X);
		challenger.antialiasing = true;
		add(challenger);
		challenger.alpha = 0;
		challenger.animation.play("rainbow");

		changeSelection(0);
		updateSongImage();

		super.create();
	}

	override function closeSubState() {
		changeSelection();
		super.closeSubState();
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String, color:Int)
	{
		songs.push(new SongMetadata(songName, weekNum, songCharacter, color));
	}

	/*public function addWeek(songs:Array<String>, weekNum:Int, weekColor:Int, ?songCharacters:Array<String>)
	{
		if (songCharacters == null)
			songCharacters = ['bf'];

		var num:Int = 0;
		for (song in songs)
		{
			addSong(song, weekNum, songCharacters[num]);
			this.songs[this.songs.length-1].color = weekColor;

			if (songCharacters.length != 1)
				num++;
		}
	}*/

	var instPlaying:Int = -1;
	private static var vocals:FlxSound = null;
	override function update(elapsed:Float)
	{
		grid1.x = FlxMath.lerp(grid1.x, grid1.x + 10, CoolUtil.boundTo(elapsed * 9, 0, 1));
		grid1.y = FlxMath.lerp(grid1.y, grid1.y - 10, CoolUtil.boundTo(elapsed * 9, 0, 1));

		grid2.x = FlxMath.lerp(grid2.x, grid2.x - 5, CoolUtil.boundTo(elapsed * 9, 0, 1));
		grid2.y = FlxMath.lerp(grid2.y, grid2.y + 2.5, CoolUtil.boundTo(elapsed * 9, 0, 1));

		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, CoolUtil.boundTo(elapsed * 24, 0, 1)));
		lerpRating = FlxMath.lerp(lerpRating, intendedRating, CoolUtil.boundTo(elapsed * 12, 0, 1));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;
		if (Math.abs(lerpRating - intendedRating) <= 0.01)
			lerpRating = intendedRating;

		scoreText.text = 'Score: ' + lerpScore + ' (' + Math.floor(lerpRating * 100) + '%)';

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var leftP = controls.UI_LEFT_P;
		var rightP = controls.UI_RIGHT_P;
		var accepted = controls.ACCEPT;
		var space = FlxG.keys.justPressed.SPACE;

		var shiftMult:Int = 1;
		if(FlxG.keys.pressed.SHIFT) shiftMult = 3;

		if (leftP)
		{
			changeSelection(-shiftMult);
		}
		if (rightP)
		{
			changeSelection(shiftMult);
		}

		if(songs[curSelected].week == 0)
		{	
			if (upP)
				changeDiff(-1);
			if (downP)
				changeDiff(1);
		}

		updateSongImage();

		remove(diffText);

		if(songs[curSelected].week != 1)
			add(diffText);

		if (controls.BACK)
		{
			if(colorTween != null) {
				colorTween.cancel();
			}
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new AftonMenuState());
		}

		#if PRELOAD_ALL
		if(space && instPlaying != curSelected && unlocked == true)
		{
			destroyFreeplayVocals();
			Paths.currentModDirectory = songs[curSelected].folder;
			var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(), curDifficulty);
			PlayState.SONG = Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase());
			if (PlayState.SONG.needsVoices)
				vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
			else
				vocals = new FlxSound();

			FlxG.sound.list.add(vocals);
			FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 0.7);
			vocals.play();
			vocals.persist = true;
			vocals.looped = true;
			vocals.volume = 0.7;
			instPlaying = curSelected;
		}
		else #end if (accepted && unlocked)
		{
			var songLowercase:String = Paths.formatToSongPath(songs[curSelected].songName);
			var poop:String = Highscore.formatSong(songLowercase, curDifficulty);
			#if MODS_ALLOWED
			if(!sys.FileSystem.exists(Paths.modsJson(songLowercase + '/' + poop)) && !sys.FileSystem.exists(Paths.json(songLowercase + '/' + poop))) {
			#else
			if(!OpenFlAssets.exists(Paths.json(songLowercase + '/' + poop))) {
			#end
				poop = songLowercase;
				curDifficulty = 1;
				trace('Couldnt find file');
			}
			trace(poop);

			PlayState.SONG = Song.loadFromJson(poop, songLowercase);
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = curDifficulty;

			PlayState.storyWeek = songs[curSelected].week;
			trace('CURRENT WEEK: ' + WeekData.getWeekFileName());
			if(colorTween != null) {
				colorTween.cancel();
			}
			LoadingState.loadAndSwitchState(new PlayState());
			FlxG.mouse.visible = false;

			FlxG.sound.music.volume = 0;
					
			destroyFreeplayVocals();
		}
		else if(controls.RESET)
		{
			openSubState(new ResetScoreSubState(songs[curSelected].songName, curDifficulty, songs[curSelected].songCharacter));
			FlxG.sound.play(Paths.sound('scrollMenu'));
		}
		super.update(elapsed);
	}

	public static function destroyFreeplayVocals() {
		if(vocals != null) {
			vocals.stop();
			vocals.destroy();
		}
		vocals = null;
	}

	function changeDiff(change:Int = 0)
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = CoolUtil.difficultyStuff.length-1;
		if (curDifficulty >= CoolUtil.difficultyStuff.length)
			curDifficulty = 0;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);
		#end

		PlayState.storyDifficulty = curDifficulty;
		if(songs[curSelected].week != 2){
			diffText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER);
			diffText.text = "< " + CoolUtil.difficultyString() + " >";
		}
		else{
			diffText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.RED, CENTER);
			diffText.text = '< MASSACRE >';
		}
		diffText.screenCenter(X);
		//diffText.x -= 50;
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		var newColor:Int = songs[curSelected].color;
		if(newColor != intendedColor) {
			if(colorTween != null) {
				colorTween.cancel();
			}
			intendedColor = newColor;
			colorTween = FlxTween.color(grid1, 1, grid1.color, intendedColor);
			colorTween = FlxTween.color(grid2, 1, grid2.color, intendedColor, {
				onComplete: function(twn:FlxTween) {
					colorTween = null;
				}
			});
		}

		// selector.y = (70 * curSelected) + 30;

		if(songs[curSelected].week != 0)
			curDifficulty = 1;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);
		#end

		var bullShit:Int = 0;

		for (i in 0...iconArray.length)
		{
			iconArray[i].alpha = 0.6;
		}

		iconArray[curSelected].alpha = 1;

		for (item in grpSongs.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
		
		changeDiff();
		Paths.currentModDirectory = songs[curSelected].folder;
	}

	function updateSongImage()
	{
		if(AftonMenuState.nightmareBeaten && AftonMenuState.shadowBonnieUnlocked && AftonMenuState.matpatUnlocked){
			AftonMenuState.scottUnlocked = true;

			FlxG.save.data.scottUnlocked = AftonMenuState.scottUnlocked;
			FlxG.save.flush();
		}
		
		songImage.animation.play(songs[curSelected].songName.toLowerCase());

		switch(songs[curSelected].songName.toLowerCase())
		{
			case 'salvage':
				unlocked = FlxG.save.data.springtrapUnlocked;
			case 'nightmare':
				unlocked = FlxG.save.data.salvageBeaten;
			case 'umbra':
				unlocked = FlxG.save.data.shadowBonnieUnlocked;
			case 'just-a-theory':
				unlocked = FlxG.save.data.matpatUnlocked;
			case 'fourth-wall':
				unlocked = FlxG.save.data.matpatBeaten;
			case 'consequences':
				unlocked = FlxG.save.data.omcUnlocked;
			case 'fazbars':
				unlocked = FlxG.save.data.fazbarsUnlocked;
		}
		
		if(songs[curSelected].week == 0){
			unlocked = true;
		}

		if(intendedScore == 0 && songs[curSelected].week != 0 && unlocked){
			newSong = true;
			challenger.alpha = 1;
		}
		else{
			newSong = false;
			challenger.alpha = 0;
		}

		if(songs[curSelected].week != 0){
			if(!unlocked)
				songImage.animation.play('locked');
			else if(newSong)
				songImage.animation.play('newsong');
		}
	}
}

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";
	public var color:Int = -7179779;
	public var folder:String = "";

	public function new(song:String, week:Int, songCharacter:String, color:Int)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.color = color;
		this.folder = Paths.currentModDirectory;
		if(this.folder == null) this.folder = '';
	}
}
