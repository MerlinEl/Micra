package net.xtools {
  import flash.filesystem.File;
  import flash.filesystem.FileMode;
  import flash.filesystem.FileStream;
  import mx.controls.Alert;
  
  public class Log {
    public static var RcsId:String = "$Id: Log.as,v 1.2 2009/09/14 01:32:43 anonymous Exp $";
    
    public function Log(lname:*=undefined) {
      if (lname) {
        if (!lname) {
          lname = Log.defaultName;
          
        }
        
        if (lname is String) {
          this.name = lname;
          this.file = Stdlib.preferencesFolder.resolvePath(this.name);
        }
        
        if (lname is File) {
          this.file = lname;
          this.name = lname.name;
        }
      }
    }

    protected static var defaultName:String = "application.log";
    
    public var name:String = Log.defaultName;
    public var file:File = null;
    public var enabled:Boolean = true;
    public var append:Boolean = false;
    public var stream:FileStream = null;
    
    public function log(msg:*):void {
      var self:Log = this;
      
      if (!self.enabled) {
        return;
      }
      try {
        if (!self.file) {
          if (!self.name) {
            self.name = Log.defaultName;
          }
          
          this.file = Stdlib.preferencesFolder.resolvePath(this.name);
        }
        
        var str:String = msg.toString();
        var fstr:FileStream = self.stream;
        
        if (!fstr) {
          fstr = new FileStream();
          if (self.append && self.file.exists) {
            fstr.open(self.file, FileMode.APPEND);
          } else {
            fstr.open(self.file, FileMode.WRITE);
          }
        } else {
          fstr.open(self.file, FileMode.APPEND);
        }
        var d:String = DateUtils.toISODateString(new Date());
        fstr.writeUTFBytes(d + '\t' + str + '\n');
        fstr.close();
        
      } catch (e:Error) {
        Alert.show(e.toString());
      }
    }
  }
}