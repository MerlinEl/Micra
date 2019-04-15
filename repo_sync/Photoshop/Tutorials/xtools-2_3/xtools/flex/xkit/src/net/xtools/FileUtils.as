package net.xtools {
  import flash.filesystem.File;
  import flash.filesystem.FileMode;
  import flash.filesystem.FileStream;
  
  public class FileUtils {
    public static var RcsId:String = "$Id: FileUtils.as,v 1.1 2009/09/22 22:00:01 anonymous Exp $";
    
   
    public static function getFiles(folder:File, mask:*):Array {
      var files:Array = [];
      if (folder.isDirectory) {
        var allFiles:Array = folder.getDirectoryListing();
        if (!mask) {
          return allFiles;
        }
        
        // XXX temporary until *.jpg style matching is implemented
        if (mask.constructor == String) {
          mask = new RegExp(mask);
        }
        
        if (mask is RegExp) {
          for (var i:int = 0; i < allFiles.length; i++) {
            var f:File = allFiles[i];
            if (f.nativePath.match(mask)) {
              files.push(f);
            }
          }
          
        } else if (typeof mask == "function") {
          for (i = 0; i < allFiles.length; i++) {
            f = allFiles[i];
            if (mask(f)) {
              files.push(f);
            }
          }
          
        } else {
          //
          mask = mask.toString();
        }
      }
      
      return files;     
    }
  
    public static function strf(file:File, fmt:String):String {
      var name:String = file.name;
      
      // get the portions of the full path name

      // extension
      var m:Array = name.match(/.+\.([^\.\/]+)$/);
      var e:String = m ? m[1] : '';

      // basename
      m = name.match(/(.+)\.[^\.\/]+$/);
      var f:String = m ? m[1] : name;
      
      // full path...
      var d:String = (file.parent != null ? file.parent.nativePath : '/');
      
      // parent directory...
      var p:String = (file.parent != null ? file.parent.name : '');
    
      var str:String = fmt;
      
    
      // a regexp for the format specifiers
    
      var rex:RegExp = /([^%]*)%(-)?(\d+)?(\.\d+)?(%|d|e|f|p)(.*)/;
    
      var result:String = '';
    
      while (m = rex.exec(str)) {
        var pre:String = m[1];
        var sig:String = m[2];
        var len:* = m[3];
        var ign:* = m[4];
        var typ:String = m[5];
        var post:String = m[6];
    
        var subst:String = '';
    
        if (typ == '%') {
          subst = '%';
        } else {
          var s:String = '';
          
          switch (typ) {
            case 'd': s = d; break;
            case 'e': s = e; break;
            case 'f': s = f; break;
            case 'p': s = p; break;
            // default: s = "%" + typ; break; // let others pass through
          }
    
          var strlen:int = s.length;
    
          if (strlen && (len || ign)) {
            ign = (ign ? Number(ign.slice(1)) : 0);
            if (len) {
              len = Number(len);
              if (sig) {
                var _idx:int = strlen - len - ign;
                subst = s.slice(_idx, _idx+len);
              } else {
                subst = s.slice(ign, ign+len);
              }
            } else {
              if (sig) {
                subst = s.slice(0, strlen-ign);
              } else {
                subst = s.slice(ign);
              }
            }
    
          } else {
            subst = s;
          }
        }
    
        result += pre + subst;
        str = post;
      }
    
      result += str;
    
      return result;
    }
    
    public static function readFromFile(file:File):String {
      var fstr:FileStream = new FileStream();
      fstr.open(file, FileMode.READ);
      var str:String = fstr.readUTFBytes(file.size);
      fstr.close();
      return str;
    }
    public static function readXMLFromFile(file:File):XML {
      return new XML(FileUtils.readFromFile(file));
    }
    
    public static function writeToFile(file:File, str:String):void {
      var fstr:FileStream = new FileStream();
      fstr.open(file, FileMode.WRITE);
      fstr.writeUTFBytes(str);
      fstr.close();
    }
    public static function writeXMLToFile(file:File, xml:XML):void {
      FileUtils.writeToFile(file, xml.toXMLString());
    }
  }
}