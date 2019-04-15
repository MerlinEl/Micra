package net.xtools {
  public class StringUtils {
    
    public function StringUtils() {
    } 
    
    private static var inited:Boolean = _init();
    public static function _init():Boolean {
      
      String.prototype.contains = function(sub:String):Boolean {
        return this.indexOf(sub) != -1;
      };
      
      String.prototype.containsWord = function(str:String):Boolean {
        return this.match(new RegExp("\\b" + str + "\\b")) != null;
      };
      
      String.prototype.endsWith = function(sub:String):Boolean {
        return this.length >= sub.length &&
          this.slice(this.length - sub.length) == sub;
      };
      
      String.prototype.startsWith = function(sub:String):Boolean {
        return this.indexOf(sub) == 0;
      };
      
      String.prototype.reverse = function():String {
        var ar:Array = this.split('');
        ar.reverse();
        return ar.join('');
      };
      
      String.prototype.trim = function():String {
        return this.replace(/^[\s]+|[\s]+$/g, '');
      };
      String.prototype.ltrim = function():String {
        return this.replace(/^[\s]+/g, '');
      };
      String.prototype.rtrim = function():String {
        return this.replace(/[\s]+$/g, '');
      };
     
      return true;
    }
  }
}