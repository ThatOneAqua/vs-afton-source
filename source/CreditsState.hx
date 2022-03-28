package;

#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import lime.utils.Assets;
import flixel.addons.display.FlxBackdrop;

using StringTools;

class CreditsState extends MusicBeatState
{

	var curSelected:Int = 1;

	private var grpOptions:FlxTypedGroup<Alphabet>;
	private var iconArray:Array<AttachedSprite> = [];

	private static var creditsStuff:Array<Dynamic> = [ //Name - Icon name - Description - Link - BG Color
		["Funkin' at Freddy's"],
		['JcJack',		'jcjack',		'Lead Director',					'https://twitter.com/JcJack777',	0xFFFFDD33],
		['SpagOs',			'spagos',		'Co-director\nProfessional Woman Kisser',				'https://twitter.com/SpagOsArt',		0xFFC30085],
		['Aqua',			'aqua',		'Co-director',				'https://twitter.com/AquaThatOne',		0xFFC30085],
		[''],
		['Programmers'],
		['Aqua',				'aqua',			'Lead programmer\n"I put over 100 hours into this code. I will never recover.',						'https://twitter.com/AquaThatOne',			0xFF4494E6],
		['fabs',		'fabs',	'Coded Fourth-Wall visuals',						'https://twitter.com/SGIObama',	0xFFE01F32],
		['Clowfoe',			'clowfoe',			'Helped code UI and Discord RPC',				'https://twitter.com/Clowfoe',			0xFFFF9300],
		[''],
		['Artists'],
		['JcJack',				'jcjack',			'Lead artist of the Afton Week, Pixel UI, and pixel backgrounds/characters',						'https://twitter.com/JcJack777',			0xFF4494E6],
		['SpagOs',		'spagos',	'Lead artist for Matpat, backgrounds, and menu assets',						'https://twitter.com/SpagOsArt',	0xFFE01F32],
		['burnout',			'burnout',			'Artist for the Springtrap sprites',				'https://twitter.com/creepercrunch',			0xFFFF9300],
		['Orbyy',				'orbyy',			'Artist for Ghost BF sprites',						'https://twitter.com/OrbyyNew',			0xFF4494E6],
		['Notakin',		'notakin',	'Artist for Shadow Bonnie, and Afton in Midnight',						'https://twitter.com/ItsNotakin',	0xFFE01F32],
		['fabs',			'fabs',			'Modelled and animated Animdude and Boyfriend in Fourth Wall',				'https://twitter.com/SGIObama',			0xFFFF9300],
		['Snak',				'snak',			'Artist for Pixel Matpat and Pixel Matpat Boyfriend',						'https://twitter.com/TravelerSnak',			0xFF4494E6],
		['Ellis',		'ellis',	'Promotional Art on Gamejolt and Gamebanana, Springtrap Icon',						'https://twitter.com/EllisBros',	0xFFE01F32],
		['ThatGoofyGuy',			'goofy',			'Promotional Art',				'https://twitter.com/TGGtheStickBoy',			0xFFFF9300],
		['Piss Bottler',			'piss',			'Fazbars sprites and helped with the text on the title screen and Fourth-Wall',				'https://twitter.com/PissBottle6',			0xFFFF9300],
		['Clowfoe',			'clowfoe',			'Freeplay portraits',				'https://twitter.com/Clowfoe',			0xFFFF9300],
		[''],
		["Musicians"],
		['Punkett',		'punkett',	"Composer of the main Afton week, Umbra, and Just-A-Theory",				'https://twitter.com/_punkett',	0xFFF73838],
		['Jacaris',		'jacey',	"Composer of Fourth-Wall and Nightmare",					'https://twitter.com/JaceyAmaris',	0xFFFFBB1B],
		['Nimbus Cumulus',			'nimbus',			"Composer of Salvage",					'https://nimbuscumulus.newgrounds.com/',			0xFF53E52C],
		['EthanTheDoodler',			'ethan',		"Composer of Fazbars and vocals of Just-A-Theory",					'https://twitter.com/D00dlerEthan',		0xFF6475F3],
		['Cval',			'cval',		"Original composer of Follow-Me",					'https://twitter.com/cval_brown',		0xFF6475F3],
		['Evan',			'evan',		"Springtrap Voice Actor",					'https://twitter.com/Bravvyy_',		0xFF6475F3],
		[''],
		["Charters"],
		['Gonk',		'gonk',	"Charted Follow-Me, Midnight, You-Can't, Salvage, Nightmare, Just-A-Theory, Fourth-Wall",				'https://twitter.com/StupidGoatMan',	0xFFF73838],
		['Gibz',		'gibz',	"Charted Celebrate, Umbra\nslow ass charter",					'https://twitter.com/gibz679',	0xFFFFBB1B],
		['loggo',			'loggo',			"Charted Fazbars\nsorry",					'https://twitter.com/loggoman512',			0xFF53E52C],
		[''],
		["gongo"],
		['gongo.',		'gongo',	"gongo,,,",				'https://twitter.com/_the_gb_',	0xFFF73838],
		[''],
		['Psych Engine Team'],
		['Shadow Mario',		'shadowmario',		'Main Programmer of Psych Engine',					'https://twitter.com/Shadow_Mario_',	0xFFFFDD33],
		['RiverOaken',			'riveroaken',		'Main Artist/Animator of Psych Engine',				'https://twitter.com/river_oaken',		0xFFC30085],
		[''],
		['Engine Contributors'],
		['shubs',				'shubs',			'New Input System Programmer',						'https://twitter.com/yoshubs',			0xFF4494E6],
		['PolybiusProxy',		'polybiusproxy',	'.MP4 Video Loader Extension',						'https://twitter.com/polybiusproxy',	0xFFE01F32],
		['gedehari',			'gedehari',			'Chart Editor\'s Sound Waveform base',				'https://twitter.com/gedehari',			0xFFFF9300],
		['Keoiki',				'keoiki',			'Note Splash Animations',							'https://twitter.com/Keoiki_',			0xFFFFFFFF],
		[''],
		["Funkin' Crew"],
		['ninjamuffin99',		'ninjamuffin99',	"Programmer of Friday Night Funkin'",				'https://twitter.com/ninja_muffin99',	0xFFF73838],
		['PhantomArcade',		'phantomarcade',	"Animator of Friday Night Funkin'",					'https://twitter.com/PhantomArcade3K',	0xFFFFBB1B],
		['evilsk8r',			'evilsk8r',			"Artist of Friday Night Funkin'",					'https://twitter.com/evilsk8r',			0xFF53E52C],
		['kawaisprite',			'kawaisprite',		"Composer of Friday Night Funkin'",					'https://twitter.com/kawaisprite',		0xFF6475F3]
	];

	var bg:FlxSprite;
	var descText:FlxText;
	var intendedColor:Int;
	var colorTween:FlxTween;

	var wall:FlxBackdrop;
	var banner:FlxBackdrop;

	override function create()
	{
		FlxG.mouse.visible = false;
		
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		add(bg);

		wall = new FlxBackdrop(Paths.image('Vents_and_Wires'), 1, 5, true, true);
		wall.setPosition(0, 750);
		wall.updateHitbox();
		wall.antialiasing = ClientPrefs.globalAntialiasing;
		add(wall);

		banner = new FlxBackdrop(Paths.image('Banner'), 1, 5, true, true);
		banner.setPosition(0, 750);
		banner.updateHitbox();
		banner.antialiasing = ClientPrefs.globalAntialiasing;

		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		for (i in 0...creditsStuff.length)
		{
			var isSelectable:Bool = !unselectableCheck(i);
			var optionText:Alphabet = new Alphabet(0, 70 * i, creditsStuff[i][0], !isSelectable, false);
			optionText.isMenuItem = true;
			optionText.screenCenter(X);
			if(isSelectable) {
				optionText.x -= 70;
			}
			optionText.forceX = optionText.x;
			//optionText.yMult = 90;
			optionText.targetY = i;
			grpOptions.add(optionText);

			if(isSelectable) {
				var icon:AttachedSprite = new AttachedSprite('credits/' + creditsStuff[i][1]);
				icon.xAdd = optionText.width + 10;
				icon.sprTracker = optionText;
	
				// using a FlxGroup is too much fuss!
				iconArray.push(icon);
				add(icon);
			}
		}

		descText = new FlxText(50, 600, 1180, "", 32);
		descText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		descText.scrollFactor.set();
		descText.borderSize = 2.4;
		add(descText);

		add(banner);

		bg.color = creditsStuff[curSelected][4];
		intendedColor = bg.color;
		changeSelection();
		super.create();
	}

	override function update(elapsed:Float)
	{
		wall.y = FlxMath.lerp(wall.y, wall.y + 10, CoolUtil.boundTo(elapsed * 9, 0, 1));
		banner.y = FlxMath.lerp(banner.y, banner.y + 20, CoolUtil.boundTo(elapsed * 9, 0, 1));

		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}

		if (controls.BACK)
		{
			if(colorTween != null) {
				colorTween.cancel();
			}
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new AftonMenuState());
		}
		if(controls.ACCEPT) {
			CoolUtil.browserLoad(creditsStuff[curSelected][3]);
		}
		super.update(elapsed);
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		do {
			curSelected += change;
			if (curSelected < 0)
				curSelected = creditsStuff.length - 1;
			if (curSelected >= creditsStuff.length)
				curSelected = 0;
		} while(unselectableCheck(curSelected));

		var newColor:Int = creditsStuff[curSelected][4];
		if(newColor != intendedColor) {
			if(colorTween != null) {
				colorTween.cancel();
			}
			intendedColor = newColor;
			colorTween = FlxTween.color(bg, 1, bg.color, intendedColor, {
				onComplete: function(twn:FlxTween) {
					colorTween = null;
				}
			});
		}

		var bullShit:Int = 0;

		for (item in grpOptions.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			if(!unselectableCheck(bullShit-1)) {
				item.alpha = 0.6;
				if (item.targetY == 0) {
					item.alpha = 1;
				}
			}
		}
		descText.text = creditsStuff[curSelected][2];
	}

	private function unselectableCheck(num:Int):Bool {
		return creditsStuff[num].length <= 1;
	}
}
