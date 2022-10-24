package;

import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.media.Sound;
import openfl.utils.Assets;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;
import openfl.display.BitmapData;
import openfl.Lib;
import openfl.display3D.textures.Texture;
import openfl.system.System;

class Paths
{
	inline public static var SOUND_EXT = #if web "mp3" #else "ogg" #end;

	static var currentLevel:String;

        public static var currentTrackedAssets:Map<String, FlxGraphic> = [];
        public static var currentTrackedTextures:Map<String, Texture> = [];
	public static var currentTrackedSounds:Map<String, Sound> = [];
	public static var localTrackedAssets:Array<String> = [];

	public static function clearUnusedMemory()
	{
		for (key in currentTrackedAssets.keys())
		{
			if (!localTrackedAssets.contains(key) && key != null)
			{
				var obj = currentTrackedAssets.get(key);
				@:privateAccess
				if (obj != null)
				{
                                        var isTexture:Bool = currentTrackedTextures.exists(key);
					if (isTexture)
					{
						var texture = currentTrackedTextures.get(key);
						texture.dispose();
						texture = null;
						currentTrackedTextures.remove(key);
					}
					Assets.cache.removeBitmapData(key);
					Assets.cache.clearBitmapData(key);
					Assets.cache.clear(key);
					FlxG.bitmap._cache.remove(key);
					obj.destroy();
					currentTrackedAssets.remove(key);
				}
			}
		}

		for (key in currentTrackedSounds.keys())
		{
			if (!localTrackedAssets.contains(key) && key != null)
			{
				var obj = currentTrackedSounds.get(key);
				if (obj != null)
				{
					Assets.cache.removeSound(key);
					Assets.cache.clearSounds(key);
					Assets.cache.clear(key);
					currentTrackedSounds.remove(key);
				}
			}
		}
                System.gc();
                #if cpp
		cpp.NativeGc.run(true);
		#end
	}

	public static function clearStoredMemory()
	{
		@:privateAccess
		for (key in FlxG.bitmap._cache.keys())
		{
			var obj = FlxG.bitmap._cache.get(key);
			if (obj != null && !currentTrackedAssets.exists(key))
			{
				Assets.cache.removeBitmapData(key);
				Assets.cache.clearBitmapData(key);
				Assets.cache.clear(key);
				FlxG.bitmap._cache.remove(key);
				obj.destroy();
			}
		}

		@:privateAccess
		for (key in Assets.cache.getSoundKeys())
		{
			if (key != null && !currentTrackedSounds.exists(key))
			{
				var obj = Assets.cache.getSound(key);
				if (obj != null)
				{
					Assets.cache.removeSound(key);
					Assets.cache.clearSounds(key);
					Assets.cache.clear(key);
				}
			}
		}

		localTrackedAssets = [];
	}

	static public function setCurrentLevel(name:String)
	{
		currentLevel = name.toLowerCase();
	}

	static function getPath(file:String, type:AssetType, library:Null<String>)
	{
		if (library != null)
			return getLibraryPath(file, library);

		if (currentLevel != null)
		{
			var levelPath = getLibraryPathForce(file, currentLevel);
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;

			levelPath = getLibraryPathForce(file, "shared");
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;
		}

		return getPreloadPath(file);
	}

	static public function getLibraryPath(file:String, library = "preload")
	{
		return if (library == "preload" || library == "default") getPreloadPath(file); else getLibraryPathForce(file, library);
	}

	inline static function getLibraryPathForce(file:String, library:String)
	{
		return '$library:assets/$library/$file';
	}

	inline static function getPreloadPath(file:String)
	{
		return 'assets/$file';
	}

	inline static public function file(file:String, type:AssetType = TEXT, ?library:String)
	{
		return getPath(file, type, library);
	}

	inline static public function lua(key:String,?library:String)
	{
		return getPath('data/$key.lua', TEXT, library);
	}

	inline static public function luaImage(key:String, ?library:String)
	{
		return getPath('data/$key.png', IMAGE, library);
	}

	inline static public function txt(key:String, ?library:String)
	{
		return getPath('data/$key.txt', TEXT, library);
	}

	inline static public function xml(key:String, ?library:String)
	{
		return getPath('data/$key.xml', TEXT, library);
	}

	inline static public function json(key:String, ?library:String)
	{
		return getPath('data/$key.json', TEXT, library);
	}

	static public function sound(key:String, ?library:String)
	{
		return getPath('sounds/$key.$SOUND_EXT', SOUND, library);
	}

	inline static public function soundRandom(key:String, min:Int, max:Int, ?library:String)
	{
		return sound(key + FlxG.random.int(min, max), library);
	}

	inline static public function music(key:String, ?library:String)
	{
		return getPath('music/$key.$SOUND_EXT', MUSIC, library);
	}

	inline static public function voices(song:String)
	{
		return 'songs:assets/songs/${song.toLowerCase()}/Voices.$SOUND_EXT';
	}

	inline static public function inst(song:String)
	{
		return 'songs:assets/songs/${song.toLowerCase()}/Inst.$SOUND_EXT';
	}

	inline static public function image(key:String, ?library:String)
	{
		return getPath('images/$key.png', IMAGE, library);
	}

	inline static public function font(key:String)
	{
		return 'assets/fonts/$key';
	}

	inline static public function video(key:String)
	{
		return 'assets/videos/$key/$key.webm';
	}

	inline static public function getSparrowAtlas(key:String, ?library:String)
	{
		return FlxAtlasFrames.fromSparrow(image(key, library), file('images/$key.xml', library));
	}

	inline static public function getPackerAtlas(key:String, ?library:String)
	{
		return FlxAtlasFrames.fromSpriteSheetPacker(image(key, library), file('images/$key.txt', library));
	}

        public static function returnGraphic(key:String, ?cache:Bool = true):FlxGraphic
	{
		var path:String = 'assets/$key.png';
		if (OpenFlAssets.exists(path, IMAGE))
		{
			if (!currentTrackedAssets.exists(path))
			{
				var newGraphic:FlxGraphic = null;
				var bitmap:BitmapData = OpenFlAssets.getBitmapData(path);

				switch (FlxG.save.data.render)
				{
					case 1:
						var texture = FlxG.stage.context3D.createTexture(bitmap.width, bitmap.height, BGRA, true);
						texture.uploadFromBitmapData(bitmap);
						currentTrackedTextures.set(path, texture);
						bitmap.dispose();
						bitmap.disposeImage();
						bitmap = null;
						newGraphic = FlxGraphic.fromBitmapData(BitmapData.fromTexture(texture), false, path);
					case 2:
						var texture = Lib.current.stage.context3D.createTexture(bitmap.width, bitmap.height, BGRA, true);
						texture.uploadFromBitmapData(bitmap);
						currentTrackedTextures.set(path, texture);
						bitmap.dispose();
						bitmap.disposeImage();
						bitmap = null;
						newGraphic = FlxGraphic.fromBitmapData(BitmapData.fromTexture(texture), false, path);
					default:
						newGraphic = FlxGraphic.fromBitmapData(bitmap, false, path);
				}

				newGraphic.persist = true;
				currentTrackedAssets.set(path, newGraphic);
			}

			localTrackedAssets.push(path);
			return currentTrackedAssets.get(path);
		}

		trace('$key image is null');
		return null;
	}

	public static function returnSound(key:String, ?cache:Bool = true):Sound
	{
		if (Assets.exists('assets/$key.$SOUND_EXT', SOUND))
		{
			var path:String = 'assets/$key.$SOUND_EXT';
			if (!currentTrackedSounds.exists(path))
				currentTrackedSounds.set(path, Assets.getSound(path, cache));

			localTrackedAssets.push(path);
			return currentTrackedSounds.get(path);
		}

		trace('$key sound is null');
		return null;
	}
}
