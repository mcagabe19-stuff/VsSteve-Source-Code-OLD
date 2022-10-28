package source;
 
import flixel.util.FlxTimer;
import flixel.util.FlxColor;
import sys.net.Address;
import openfl.text.TextFormat;
import Paths;
import openfl.text.TextField;
import openfl.text.Font;
import flixel.system.FlxBasePreloader;
import openfl.display.Sprite;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.Lib;
import flixel.FlxG;
import flixel.math.FlxMath;
import flash.display.BlendMode;
 
@:bitmap("assets/preload/images/titleBG.png") class A extends BitmapData {}
@:bitmap("assets/preload/images/titleBG.png") class B extends BitmapData {}
@:bitmap("assets/preload/images/logoBumpin.png") class C extends BitmapData {}
@:font("assets/fonts/vcr.ttf") class CustomFont extends Font {}
 
class Preloader extends FlxBasePreloader
{
	public static var max:Float = 10;

    public function new(MinDisplayTime:Float=11) 
    {
        new FlxTimer().start(9.5, function(time:FlxTimer) {
            FlxG.camera.fade(FlxColor.BLACK, 1, false);
        });
        max = MinDisplayTime;
        super(MinDisplayTime);

    }
    var loadtxtProgress:Bitmap;
    var loadtxtBg:Bitmap;
    var text:TextField;
    var logo:Sprite;
    var bg:Sprite;
    var bgclone:Sprite;
    override function create():Void 
    {
        trace('loading from source/Preloader');
        this._width = Lib.current.stage.stageWidth;
        this._height = Lib.current.stage.stageHeight;
         
        var ratio:Float = this._width / 5000;
        
        bg = new Sprite();
        bg.addChild(new Bitmap(new A (-1600,0)));
        addChild(bg);
        
        bgclone = new Sprite();
        bgclone.addChild(new Bitmap(new B (-2880,0)));
        addChild(bgclone);
        
        logo = new Sprite();
        logo.addChild(new Bitmap(new C (311,150)));
        addChild(logo);
         
        loadtxtBg = new Bitmap(new BitmapData(1, -9, false, 0xFF000000));
        loadtxtBg.alpha = 0.8;
        loadtxtBg.scaleX = 1280;
        addChild(loadtxtBg);

        loadtxtProgress = new Bitmap(new BitmapData(1, -9, false, 0xffffff));
        loadtxtProgress.alpha = 0.3;
	addChild(loadtxtProgress);

        Font.registerFont(CustomFont);
        text = new TextField();
        text.defaultTextFormat = new TextFormat("vcr", 24, 0xffffff, false, false ,false , null, null, "right");
        text.embedFonts = true;
        text.text = "Loading...";
        text.width = 189;
        text.y = 700;
        text.x = -60;
        addChild(text);

        text.y += 2;
        loadtxtBg.scaleY = text.height + 5;
        loadtxtBg.y = text.y;
        loadtxtBg.x = text.x + 60;
        loadtxtProgress.scaleY = text.height + 5;
        loadtxtProgress.y = text.y;
        loadtxtProgress.x = text.x + 60;
        super.create();
    }
    override function update(Percent:Float):Void
        {
            loadtxtProgress.scaleX = Percent * (_width - 0.5);
        }
        override function destroy():Void
            {
                bg = null;
                bgclone = null;
                logo = null;
                loadtxtProgress = null;
                text = null;
                loadtxtBg = null;
                super.destroy();
            }
}
