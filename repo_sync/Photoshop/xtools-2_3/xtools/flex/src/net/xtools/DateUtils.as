package net.xtools
{
  import mx.controls.Alert;
  
  public class DateUtils
  { 
    public static var RcsId:String = "$Id: DateUtils.as,v 1.3 2009/09/14 17:12:16 anonymous Exp $";
    
    private static function _init():Boolean {
      Date.prototype.toISO = function():String {
         return this.strftime(DateUtils.iso8601);
      };
    
     Date.prototype.strftime = function (fmt:String):String {
       return DateUtils.strftime(this, fmt);
     };
          
     return true;
    }
    private static var _inited:Boolean = _init(); 
    
    
    public static function toISODateString(date:Date, timeDesignator:*=undefined,
        dateOnly:Boolean=false, precision:*=undefined):String {
          
      if (!date) date = new Date();
      var str:String = '';
      if (timeDesignator == undefined) { timeDesignator = 'T'; };
      
      var _zeroPad:Function = function (val:int, w:int=2):String {
        var str:String = val.toString();
        while (str.length < w) {
          str = '0' + str;
        }
        return str;
      }
      
      if (date is Date) {
        str = (date.getFullYear() + '-' +
               _zeroPad(date.getMonth()+1,2) + '-' +
               _zeroPad(date.getDate(),2));
        if (!dateOnly) {
          str += (timeDesignator +
                  _zeroPad(date.getHours(),2) + ':' +
                  _zeroPad(date.getMinutes(),2) + ':' +
                  _zeroPad(date.getSeconds(),2));
          if (precision && typeof(precision) == "number") {
            var ms:int = date.getMilliseconds();
            if (ms) {
              var millis:String = _zeroPad(ms.toString(), precision);
              var s:String = millis.slice(0, Math.min(precision, millis.length));
              str += "." + s;
            }
          }
        }
      }
      return str;
    };
    public static function alert(msg:Object):void {
      var str:String = msg.toString();
      Alert.show(str);
      trace(str);
    }
    
    public static function testISODate():void {
      var strs:Array = ["2006-09-01",
                  "1997-07-16T19:20",
                  "1997-07-16T19:20Z",
                  "1997-07-16T19:20+01:00",
                  "2006-09-01T16:33:26",
                  "2006-09-01 16:33:26",
                  "2006:09:01 16:33:26",
                  "1997-07-16T19:20:30",
                  "1997-07-16T19:20:30Z",
                  "1997-07-16T19:20:30-01:00",
                  "1997-07-16T19:20:30.45",
                  "1997-07-16T19:20:30.45Z",
                  "1997-07-16T19:20:30.45+01:05"];
    
      for (var i:int = 0; i < strs.length; i++) {
        var s:String = strs[i];
        alert(s + " :: " + DateUtils.parseISODateString(s)['toISODateString']('T', false, 2));
      }
    };
    
    // xmp = new XMPData(doc); Stdlib.parseISODateString(xmp.get('createdate'))
    public static function parseISODateString(str:*):Date {
      if (!str) {
        return undefined;
      }
      // \d{4}(:|-)\d{2}(:-)\d{2}( |T).\d{2}:\d{2}:\d{2}(Z|((\-\+)\d{2}:\d{2}))?
    
      // Date portion /^(\d{4}).?(\d{2}).?(\d{2})/
      // Divider ( |T)
      var d:Date = null;
      //$.level = 1; debugger;
      if (str.length >= 10 && str.length <= 35) {

        // we are assuming that this date is formatted correctly
        var utc:Boolean = str.endsWith('Z');
    
        // handle the data portion e.g. 2006-06-08 or 2006:06:08 or 20060680
        var m:Array = str.match(/^(\d{4}).?(\d{2}).?(\d{2})/);
    
        if (m) {
          var date:Date = new Date();
          if (utc) {
            date.setUTCFullYear(Number(m[1]),
                                Number(m[2])-1,
                                Number(m[3]));
            date.setUTCHours(0, 0, 0);
            date.setUTCMilliseconds(0);
    
          } else {
            date.setFullYear(Number(m[1]),
                             Number(m[2])-1,
                             Number(m[3]));
            date.setHours(0, 0, 0);
            date.setMilliseconds(0);
          }
    
    
          // handle the time portion e.g. 12:15:02
          // or 12:15:02-06:00 or 12:15:02Z or 12:15:02.25Z or 12:15:02.25+10:30
          if (str.length > 10) {
            m = str.match(/( |T)(\d{2}):(\d{2})(?::(\d{2})(\.\d+)?)?(?:(Z)|(\-|\+)(\d{2}):(\d{2}))?$/);
    
            if (m) {
              var hours:int = Number(m[2]);
              var mins:int = Number(m[3]);
    
              var nstr:String = str.slice(m.index);
    
              var secs:int = (m[4] ? Number(m[4]) : 0);
              var ms:int = 0;
              if (m[5]) {
                ms = Number("0" + m[5]) * 1000;
              }
    
              var z:Boolean = (m[6] == 'Z');
              // assert(z == utc);
    
              if (utc) {
                date.setUTCHours(hours, mins, secs);
                date.setUTCMilliseconds(ms);
    
              } else {
                date.setHours(hours, mins, secs);
                date.setMilliseconds(ms);
              }
    
              if (m[6] || (m[7] && m[8] && m[9])) {
                var tzd:String = (z ? 'Z' : m[7] + m[8] + ':' + m[9]);
                date['tzd'] = tzd;
              }
    
            } else {
              date = undefined;
            }
          }
        }
      }
    
      return date;
    };


    //========================= Date formatting ================================
    //
    // Date.strftime
    //    This is a third generation implementation. This is a JavaScript
    //    implementation of C the library function 'strftime'. It supports all
    //    format specifiers except U, W, z, Z, G, g, O, E, and V.
    //    For a full description of this function, go here:
    //       http://www.opengroup.org/onlinepubs/007908799/xsh/strftime.html
    //    Donating implementations can be found here:
    //       http://redhanded.hobix.com/inspect/showingPerfectTime.html
    //    and here:
    //       http://wiki.osafoundation.org/bin/view/Documentation/JavaScriptStrftime
    //
    // Object Method
    // Class Function
    public static function strftime(date:Date, fmt:String):String {
      var t:Date = date;
      var cnvts:Function = DateUtils._cnvt;
      var str:String = fmt;
      var m:Array;
      var rex:RegExp = /([^%]*)%([%aAbBcCdDehHIjmMprRStTuwxXyYZ]{1})(.*)/;
    
      var result:String = '';
      while (m = rex.exec(str)) {
        var pre:String = m[1];
        var typ:String = m[2];
        var post:String = m[3];
        result += pre + cnvts[typ](t);
        str = post;
      }
      result += str;
      return result;
    };
    
    // the specifier conversion function table
    protected static var _cnvt:* = {
      zeropad: function(n:int):String{ return n>9 ? n : '0'+n; },
      spacepad: function(n:int):String{ return n>9 ? n : ' '+n; },
      ytd: function(t:String):String {
        var first:int = new Date(t.getFullYear(), 0, 1).getTime();
        var diff:int = t.getTime() - first;
        return Math.floor((((diff/1000)/60)/60)/24)+1;
      },
      a: function(t:String):String {
        return ['Sun','Mon','Tue','Wed','Thu','Fri','Sat'][t.getDay()];
      },
      A: function(t:String):String {
        return ['Sunday','Monday','Tuesdsay','Wednesday','Thursday','Friday',
                'Saturday'][t.getDay()];
      },
      b: function(t:String):String {
        return ['Jan','Feb','Mar','Apr','May','Jun', 'Jul','Aug','Sep','Oct',
                'Nov','Dec'][t.getMonth()]; },
      B: function(t:String):String {
        return ['January','February','March','April','May','June', 'July','August',
                'September','October','November','December'][t.getMonth()]; },
      c: function(t:String):String {
        return (this.a(t) + ' ' + this.b(t) + ' ' + this.e(t) + ' ' +
                this.H(t) + ':' + this.M(t) + ':' + this.S(t) + ' ' + this.Y(t));
      },
      C: function(t:String):String { return this.Y(t).slice(0, 2); },
      d: function(t:String):String { return this.zeropad(t.getDate()); },
      D: function(t:String):String { return this.m(t) + '/' + this.d(t) + '/' + this.y(t); },
      e: function(t:String):String { return this.spacepad(t.getDate()); },
      // E: function(t:String):String { return '-' },
      F: function(t:String):String { return this.Y(t) + '-' + this.m(t) + '-' + this.d(t); },
      g: function(t:String):String { return '-'; },
      G: function(t:String):String { return '-'; },
      h: function(t:String):String { return this.b(t); },
      H: function(t:String):String { return this.zeropad(t.getHours()); },
      I: function(t:String):String {
        var s:String = this.zeropad((t.getHours() + 12) % 12);
        return (s == "00") ? "12" : s;
      },
      j: function(t:String):String { return this.ytd(t); },
      k: function(t:String):String { return this.spacepad(t.getHours()); },
      l: function(t:String):String {
        var s:String = this.spacepad((t.getHours() + 12) % 12);
        return (s == " 0") ? "12" : s;
      },
      m: function(t:String):String { return this.zeropad(t.getMonth()+1); }, // month-1
      M: function(t:String):String { return this.zeropad(t.getMinutes()); },
      n: function(t:String):String { return '\n'; },
      // O: function(t:String):String { return '-' },
      p: function(t:String):String { return this.H(t) < 12 ? 'AM' : 'PM'; },
      r: function(t:String):String {
        return this.I(t) + ':' + this.M() + ':' + this.S(t) + ' ' + this.p(t);
      },
      R: function(t:String):String { return this.H(t) + ':' + this.M(t); },
      S: function(t:String):String { return this.zeropad(t.getSeconds()); },
      t: function(t:String):String { return '\t'; },
      T: function(t:String):String {
        return this.H(t) + ':' + this.M(t) + ':' + this.S(t) + ' ' + this.p(t);
      },
      u: function(t:String):String {return t.getDay() ? t.getDay()+1 : 7; },
      U: function(t:String):String { return '-'; },
      w: function(t:String):String { return t.getDay(); }, // 0..6 == sun..sat
      W: function(t:String):String { return '-'; },       // not available
      x: function(t:String):String { return this.D(t); },
      X: function(t:String):String { return this.T(t); },
      y: function(t:String):String { return this.zeropad(this.Y(t) % 100); },
      Y: function(t:String):String { return t.getFullYear().toString(); },
      z: function(t:String):String { return ''; },
      Z: function(t:String):String { return ''; },
      '%': function(t:String):String { return '%'; }
    };
    
    // this needs to be worked on...
    private function _weekNumber(date:Date):int {
      var ytd:int = Number(date['strftime']("%j"));
      var week:int = Math.floor(ytd/7);
      if (new Date(date.getFullYear(), 0, 1).getDay() < 4) {
        week++;
      }
      return week;
    };
    
    // some ISO8601 formats
    public static var iso8601_date:String = "%Y-%m-%d";
    public static var iso8601_full:String = "%Y-%m-%dT%H:%M:%S";
    public static var iso8601:String      = "%Y-%m-%d %H:%M:%S";
    public static var iso8601_time:String = "%H:%M:%S";
  }
}