package net.xtools {
  import flash.display.Sprite;
  import flash.filesystem.File;  
  import mx.controls.Alert;
  import mx.core.Window;
  
  public class Stdlib {
    public static var RcsId:String = "$Id: Stdlib.as,v 1.7 2009/09/21 21:16:58 anonymous Exp $";

   protected static var _inited:Boolean = Stdlib._init();
    protected static function _init():Boolean {
      new StringUtils();
      new DateUtils();
      return true;
    }    
         
    public static function toBoolean(s:*):Boolean {
      if (s == undefined) { return false; }
      if (s.constructor == Boolean) { return s.valueOf(); }
      try { if (s is XML) s = s.toString(); } catch (e:Error) {}
      try { if (s is XMLList) s = s[0].toString(); } catch (e:Error) {}
      if (s.constructor == String)  { return s.toLowerCase() == "true"; }
    
      return Boolean(s);
    }

    public static var preferencesFolder:File = File.applicationStorageDirectory;
    
    public static var logFile:Log = new Log();
    
    public static function log(msg:*):void {
      if (msg && msg is Error) {
        var e:Error = msg as Error;
        msg = 'Error: ' + e.message + '\n' + e.getStackTrace();
      }
      Stdlib.logFile.log(msg);
    }
    
     public static function getByProperty(container:*, prop:String, value:*,
                                         all:Boolean=false):* {
      // check for a bad index
      if (!prop) {
        // Error.runtimeError(2, "prop");
      }
      if (value == undefined) {
        //Error.runtimeError(2, "value");
      }
      var matchFtn:Function;
    
      all = !!all;
    
      if (value is RegExp) {
        matchFtn = function(s1:String, re:RegExp):Boolean { return s1.match(re) != null; };
      } else {
        matchFtn = function(s1:String, s2:String):Boolean { return s1 == s2; };
      }
    
      var obj:Array = [];
    
      for (var i:int = 0; i < container.length; i++) {
        if (matchFtn(container[i][prop], value)) {
          if (!all) {
            return container[i];     // there can be only one!
          }
          obj.push(container[i]);    // add it to the list
        }
      }
    
      return all ? obj : undefined;
    }
    
    public static function alert(msg:Object, win:Sprite=undefined):void {
      var str:String = msg.toString();
      Alert.show(str, '*** Alert ***', 0x4, win);
      trace(str);
    }
  }
}