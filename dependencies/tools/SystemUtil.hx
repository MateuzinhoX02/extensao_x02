package tools;

#if android
import android.Hardware;
import android.Permissions;
import android.os.Environment;
#end
#if cpp
import cpp.ConstCharStar;
import cpp.Native;
import cpp.UInt64;
#end
import openfl.system.Capabilities;
import sys.FileSystem;
import flash.system.System;
import flixel.FlxG;
import haxe.CallStack.StackItem;
import haxe.CallStack;
import lime.app.Application;
import openfl.Lib;
import openfl.events.UncaughtErrorEvent;
import flixel.FlxState;
import flixel.addons.ui.FlxUIButton;
import flixel.text.FlxText;
import openfl.utils.Assets;
import sys.io.File;
import flixel.util.FlxColor;
using StringTools;

class SystemUtil {
	
    /**
     * @author: MateuzinhoX02
     * Inspired in Sirox and M.A Jigsaw.
     * And some code stoled of Sirox
     */
    public static var path:String = null;
    //I lost my sanity
    var haveLua = false;
    var haveVlc = false;
    var haveLua2 = false;
    var haveVlc2 = false;
	
    override function create() {
    checaaepo();

    #if debug
    FlxG.log.add('Checking all things');
    #end

    public static function checaaepo() {
       #if android
       path = lime.system.System.applicationStorageDirectory; //WTFFFFFF
       #end

       #if debug //Just sending messages to the flixel console
       FlxG.log.add('Done. Path is ' + path);
       #end
    }

    public static function checkLibs() { //checking the game apk
        //CHECK ARM64-V8A
        if (FileSystem.exists(path + 'lib/arm64-v8a/libluajit.so')) {
        haveLua = true;
        #if debug
        FlxG.log.add('The APK have the lua lib in arm64-v8a');
        #end
        } else {
        haveLua = false;
        #if debug
        FlxG.log.add('The APK dont have the lua lib in arm64-v8a, this mod have modcharts?');
        #end
        }

        if (FileSystem.exists(path + 'lib/arm64-v8a/libvlc.so')) {
        haveVlc = true;
        #if debug 
        FlxG.log.add('The APK have the VLC lib in arm64-v8a')
        #end
        } else {
        haveVlc = false;
        #if debug
        FlxG.log.add('The APK dont have the vlc lib in arm64-v8a');
        #end
        }

        //CHECK ARMEABI-V7A
        if (FileSystem.exists(path + 'lib/armeabi-v7a/libluajit.so')) {
        haveLua2 = true;
        #if debug
        FlxG.log.add('The APK have the lua lib in armeabi-v7a');
        #end
        } else {
        haveLua2 = false;
        #if debug
        FlxG.log.add('The APK dont have the lua lib in armeabi-v7a, this mod have modcharts?');
        #end
        }
    
        if (FileSystem.exists(path + 'lib/armeabi-v7a/libvlc.so')) {
        haveVlc2 = true;
        #if debug 
        FlxG.log.add('The APK have the VLC lib in armeabi-v7a')
        #end
        } else {
        haveVlc2 = false;
        #if debug
        FlxG.log.add('The APK dont have the vlc lib in armeabi-v7a');
        #end
        }
    }
   
    public static function checkLibs() { //checking the phone specs
        var ram:UInt64 = CppAPI.obtainRAM(); //stoled of wednesday inf.

		FlxG.log.add('\n--- SYSTEM INFO ---\nMEMORY AMOUNT: $ram');

		// cpu = false; testing methods
		if (ram >= 4096)
			return true;
		else
		{
			return messageBox("Friday Night Funkin'",
				"Your phone does not meet the requirements Friday Night Funkin' has.\nWhile you can still play the mod, you may experience framedrops and/or lag spikes.\n\nDo you want to play anyway?");
		}

		return true;

    }
	
/**
	 * crash handler (it works only with exceptions thrown by haxe, for example glsl death or fatal signals wouldn't be saved using this)
     * @author: sqirra-rng
     * @edit: Saw (M.A. Jigsaw)
	 */
     public static function initCrashHandler()
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
                {
                    var lmao:String = path;
                    if (!lmao.contains(lime.system.System.applicationStorageDirectory)) {
                        if (!FileSystem.exists(lmao + 'logs')) {
                            FileSystem.createDirectory(lmao + 'logs');
                        }
                        File.saveContent(lmao
                        + 'logs/'
                        + Application.current.meta.get('file')
                        + '-'
                        + Date.now().toString().replace(' ', '-').replace(':', "'")
                        + '.log',
                        errMsg
                        + '\n');
                    }
                }
                #if android
                catch (e:Dynamic)
                Hardware.toast("Error!\nClouldn't save the crash dump because:\n" + e, ToastType.LENGTH_LONG);
                #end
    
                Sys.println(errMsg);
                Application.current.window.alert(errMsg, 'Error!');
    
                System.exit(1);
            });
        }
        
        public static function trace(thing:Dynamic, var_name:String, alert:Bool = false) {
            var dateNow:String = Date.now().toString();
            dateNow = dateNow.replace(" ", "_");
            dateNow = dateNow.replace(":", "'");
            var fp:String = path + "logs/" + var_name + dateNow + ".txt";
            
            var thingToSave:String = forceToString(thing);
            
            if (alert) {
                Application.current.window.alert(thingToSave, 'FileTrace');
            }
    
            if (!FileSystem.exists(path + 'logs')) {
                FileSystem.createDirectory(path + 'logs');
            }
            
            /*if (FileSystem.exists(fp)) {
                for (i in 0.0...Math.POSITIVE_INFINITY) {
                    fp = fp + i;
                    if (FileSystem.exists(fp)) {
                        fp = fp.replace(i, '');
                    } else {
                        break;
                    }
                }
            }*/
            File.saveContent(fp, var_name + " = " + thingToSave + "\n");
        }
        
        public static function forceToString(shit:Dynamic):String {
            var result:String = '';
            if (!Std.isOfType(shit, String)) {
                result = Std.string(shit);
            } else {
                result = shit;
            }
            return result;
        }
        
        public static function match(val1:Dynamic, val2:Dynamic) {
            return Std.isOfType(val1, val2);
        }
        
        public static function copyContent(copyPath:String, savePath:String)
        {
            try
            {
                trace(path);
                trace('saving dir: ' + path + savePath);
                trace(copyPath);
                if (!FileSystem.exists(path + savePath) && Assets.exists(copyPath))
                    File.saveBytes(path + savePath, Assets.getBytes(copyPath));
            }
            #if android
            catch (e:Dynamic)
            Hardware.toast("Error!\nClouldn't copy the file because:\n" + e, ToastType.LENGTH_LONG);
            #end
        }
    }
    
    super.create();
}
	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}

    function messageBox(title:ConstCharStar = null, msg:ConstCharStar = null)
        {
            #if windows
            var msgID:Int = untyped MessageBox(null, msg, title, untyped __cpp__("MB_ICONQUESTION | MB_YESNO"));
    
            if (msgID == 7)
            {
                Sys.exit(0);
            }
    
            return true;
            #else
            lime.app.Application.current.window.alert(cast msg, cast title);
            return true;
            #end
        }


