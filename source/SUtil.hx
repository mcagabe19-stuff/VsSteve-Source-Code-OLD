package;

#if android
import android.Hardware;
import android.Permissions;
import android.os.Build.VERSION;
import android.os.Build.VERSION_CODES;
import android.os.Environment;
#end
import flash.system.System;
import flixel.FlxG;
import haxe.CallStack.StackItem;
import haxe.CallStack;
import haxe.io.Path;
import lime.app.Application;
import openfl.Lib;
import openfl.events.UncaughtErrorEvent;
import openfl.utils.Assets;
import sys.FileSystem;
import sys.io.File;

using StringTools;

/**
 * ...
 * @author: Saw (M.A. Jigsaw)
 * @modified: mcagabe19
 */
class SUtil
{
	/**
	 * Uncaught error handler, original made by: sqirra-rng
	 */
	public static function uncaughtErrorHandler()
	{
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, function(u:UncaughtErrorEvent)
		{
			var callStack:Array<StackItem> = CallStack.exceptionStack(true);
			var errMsg:String = '';

			for (stackItem in callStack)
			{
				switch (stackItem)
				{
					case CFunction:
						errMsg += 'a C function\n';
					case Module(m):
						errMsg += 'module ' + m + '\n';
					case FilePos(s, file, line, column):
						errMsg += file + ' (line ' + line + ')\n';
					case Method(cname, meth):
						errMsg += cname == null ? "<unknown>" : cname + '.' + meth + '\n';
					case LocalFunction(n):
						errMsg += 'local function ' + n + '\n';
				}
			}

			errMsg += u.error;

			try
			{}
			#if android
			catch (e:Dynamic)
			Hardware.toast("Error!\nClouldn't save the crash dump because:\n" + e, ToastType.LENGTH_LONG);
			#end

			Sys.println(errMsg);
			Application.current.window.alert(errMsg, 'Error!');

			System.exit(1);
		});
	}