package;

import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxG;
import flixel.FlxState;
import flixel.graphics.FlxGraphic;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import openfl.utils.Assets;
#if sys
import sys.thread.Thread;
import sys.FileSystem;
#end
//#if mobile
//import SUtil;
//#end

using StringTools;

class LoadingScreen extends FlxTypedGroup<FlxSprite>
{
	public var progress:Int = 0;
	public var max:Int = 10;

	var pano:FlxSprite;
	var panoclone:FlxSprite;
	var logoBl:FlxSprite;
	var loadTxtBg:FlxSprite;
	var loadTxtProgress:FlxSprite;
	var loadTxt:FlxText;

	public function new()
	{
		super();

		pano = new FlxSprite(-1600, 0).loadGraphic(Paths.image('titleBG'));
		pano.antialiasing = true;
		pano.updateHitbox();
		add(pano);

		panoclone = new FlxSprite(-2880, 0).loadGraphic(Paths.image('titleBG'));
		panoclone.antialiasing = true;
		panoclone.updateHitbox();
		add(panoclone);

		logoBl = new FlxSprite(110, -0);
		logoBl.frames = Paths.getSparrowAtlas('logoBumpinPreFinal');
		logoBl.antialiasing = true;
		logoBl.animation.addByPrefix('bump', 'logo bumpin', 24);
		logoBl.animation.play('bump');
		logoBl.updateHitbox();
		logoBl.y += 150;
		logoBl.x += 200;
		add(logoBl);

		loadTxtBg = new FlxSprite();
		add(loadTxtBg);

		loadTxtProgress = new FlxSprite();
		add(loadTxtProgress);

		loadTxt = new FlxText(0, 0, 0, "Loading...", 30);
		loadTxt.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		loadTxt.x = 5;
		loadTxt.y = FlxG.height - loadTxt.height - 5;
		add(loadTxt);

		loadTxtBg.makeGraphic(1, 1, 0xFF000000);
		loadTxtBg.updateHitbox();
		loadTxtBg.origin.set();
		loadTxtBg.scale.set(1280, loadTxt.height + 5);
		loadTxtBg.alpha = 0.8;
		loadTxtBg.y = loadTxt.y;

		loadTxtProgress.makeGraphic(1, 1, 0xFFFFFFFF);
		loadTxtProgress.updateHitbox();
		loadTxtProgress.origin.set();
		loadTxtProgress.scale.set(0, loadTxt.height + 5);
		loadTxtProgress.alpha = 0.3;
		loadTxtProgress.y = loadTxt.y;

		loadTxt.y += 2;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		var lerpTarget:Float = 1280.0 * (progress / max);
		loadTxtProgress.scale.x = FlxMath.lerp(loadTxtProgress.scale.x, lerpTarget, elapsed * 5);
	}

	public function setLoadingText(text:String)
	{
		loadTxt.text = text;
	}
}

class LoadingState extends MusicBeatState
{
	public static var target:FlxState;
	public static var stopMusic = false;
	static var imagesToCache:Array<String> = [];
	//static var soundsToCache:Array<String> = [];

	var screen:LoadingScreen;

	public function new()
	{
		super();

		FlxTransitionableState.skipNextTransIn = true;
		FlxTransitionableState.skipNextTransOut = true;
	}

	override function create()
	{
		super.create();

		screen = new LoadingScreen();
		add(screen);

		screen.max = imagesToCache.length;

		FlxG.camera.fade(FlxG.camera.bgColor, 0.5, true);

		FlxGraphic.defaultPersist = true;
		Thread.create(() ->
		{
			screen.setLoadingText("Loading images...");
			for (image in imagesToCache)
			{
				trace("Caching image " + image);
				FlxG.bitmap.add(Paths.image(image));
				screen.progress += 1;
			}

			FlxGraphic.defaultPersist = false;

			screen.setLoadingText("Done!");
			trace("Done caching");

			FlxG.camera.fade(FlxColor.BLACK, 1, false);
			new FlxTimer().start(1, function(_:FlxTimer)
			{
				screen.kill();
				screen.destroy();
				loadAndSwitchState(target, false);
			});
		});
	}
	
	function onLoad()
	{
		if (stopMusic && FlxG.sound.music != null)
			FlxG.sound.music.stop();
		
		FlxG.switchState(target);
	}
	
	static function getSongPath()
	{
		return Paths.inst(PlayState.SONG.song);
	}
	
	static function getVocalPath()
	{
		return Paths.voices(PlayState.SONG.song);
	}

	public static function loadAndSwitchState(target:FlxState, stopMusic = false)
	{
		FlxG.switchState(getNextState(target, stopMusic));
	}
	
	static function getNextState(target:FlxState, stopMusic = false):FlxState
	{
		var loaded = isSoundLoaded(getSongPath()) && (!PlayState.SONG.needsVoices || isSoundLoaded(getVocalPath()));
		
		if (!loaded)
			return new LoadingState(target, stopMusic);
		if (stopMusic && FlxG.sound.music != null)
			FlxG.sound.music.stop();
		
		return target;
	}
	
	static function isSoundLoaded(path:String):Bool
	{
		return Assets.cache.hasSound(path);
	}
}