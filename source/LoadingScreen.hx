package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;

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

		loadTxt = new FlxText(1, 21, 0, "Loading...", 30);
		loadTxt.setFormat(Paths.font("MinecraftRegular-Bmg3.ttf"), 24, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		loadTxt.x = 5;
		loadTxt.y = FlxG.height - loadTxt.height - 5;
		add(loadTxt);

		loadTxtBg.makeGraphic(1, 26, 0xFF000000);
		loadTxtBg.updateHitbox();
		loadTxtBg.origin.set();
		loadTxtBg.scale.set(1280, loadTxt.height + 5);
		loadTxtBg.alpha = 0.8;
		loadTxtBg.y = loadTxt.y;

		loadTxtProgress.makeGraphic(1, 26, 0xFFFFFFFF);
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