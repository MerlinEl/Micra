//
// XWatermark.js
// Adds a watermark to a document. Lots of options. In its default mode
// it expects a shape called 'Watermark Shape' and a style 'Watermark Style'
//
// $Id: XWatermark.jsx,v 1.74 2015/12/03 22:01:33 anonymous Exp $
// Copyright: (c)2005, xbytor
// License: http://www.opensource.org/licenses/bsd-license.php
// Contact: xbytor@gmail.com
//
/* 
<javascriptresource>
   <name>XWatermark v1.0...</name>
   <menu>automate</menu>
   <category>xtools</category>

   <about>XWatermark: A flexible watermarking script.
$Revision: 1.74 $
Copyright: (c)2008, xbytor
License: http://www.opensource.org/licenses/bsd-license.php
Contact: xbytor@gmail.com</about>
   <eventid>aa857e40-591a-11dd-ae16-0800200c9a66</eventid>
   <terminology></terminology>
</javascriptresource>
*/
//
//@show include
//
app;
//
//
//
// stdlib.js
//   This file contains a collection of utility routines that I've
//   written, borrowed, rewritten, and occasionally tested and
//   documented.
//
//   Most of this stuff is photoshop specific. I'll break out the parts
//   that aren't sometime in the future.
//
// $Id: XWatermark.jsx,v 1.74 2015/12/03 22:01:33 anonymous Exp $
// Copyright: (c)2015, xbytor
// License: http://www.opensource.org/licenses/bsd-license.php
// Contact: xbytor@gmail.com
//
//@show include
//
//

//================================== misc ====================================
//
// Some shorthand functions for TypeID conversion
//

// these revs follow some discussions with SzopeN
// it turns out that attributes of the Function object will return an 
/// unexpected and incorrect value. These versions are deprecated as a result.
//cTID = function(s) { return cTID[s] || cTID[s] = app.charIDToTypeID(s); };
//sTID = function(s) { return sTID[s] || sTID[s] = app.stringIDToTypeID(s); };

// older revs
// cTID = function(s) {
//   if (s.length != 4) {
//     Error.runtimeError(19, s);  // Bad Argument
//   }
//   return app.charIDToTypeID(s);
// };
cTID = function(s) { return app.charIDToTypeID(s); };
sTID = function(s) { return app.stringIDToTypeID(s); };

xTID = function(s) {
  if (s == undefined) {
    if (!isCS() && !isCS2()) {
      try {
        Stdlib.log("undefined id detected at: " + $.stack);
      } catch (e) {
        Stdlib.log("undefined id detected");
      }
    } else {
      Stdlib.log("undefined id detected");
    }
  }

  if (s.constructor == Number) {
    return s;
  }
  try {
    if (s instanceof XML) {
      var k = s.nodeKind();
      if (k == 'text' || k == 'attribute') {
        s = s.toString();
      }
    }
  } catch (e) {
  }

  if (s.constructor == String) {
    if (s.length > 0) {
      if (s.length != 4) return sTID(s);
      try { return cTID(s); } catch (e) { return sTID(s); }
    }
  }
  Error.runtimeError(19, s);  // Bad Argument

  return undefined;
};

//
// This reverses the mapping from a TypeID to something readable.
// If PSConstants.js has been included, the string returned is even
// more readable
// 'map' is optional. It can be either a string ("Class") or a
// table object from PSConstants (PSClass). Using 'map' will help
// id2char return the most appropriate result since collisions
// happen. For instance, cTID('Rds ') is the id for PSKey.Radius
// and PSEnum.Reds.
//
id2char = function(s, map) {
  if (isNaN(Number(s))){
    return '';
  }
  var v;

  // Use every mechanism available to map the typeID
  var lvl = $.level;
  $.level = 0;
  try {
    if (!v) {
      try { v = PSConstants.reverseNameLookup(s, map); } catch (e) {}
    }
    if (!v) {
      try { v = PSConstants.reverseSymLookup(s); } catch (e) {}
    }
    if (!v) {
      try { v = app.typeIDToCharID(s); } catch (e) {}
    }
    if (!v) {
      try { v = app.typeIDToStringID(s); } catch (e) {}
    }
  } catch (e) {
  }
  $.level = lvl;
  if (!v) {
    v = Stdlib.numberToAscii(s);
  }
  return v ? v : s;
};
id2charId = function(s, map) {
  if (isNaN(Number(s))){
    return '';
  }
  var v;

  // Use every mechanism available to map the typeID
  var lvl = $.level;
  $.level = 0;
  try {
    if (!v) {
      try { v = PSConstants.reverseSymLookup(s); } catch (e) {}
    }
    if (!v) {
      try { v = app.typeIDToCharID(s); } catch (e) {}
    }
    if (!v) {
      try { v = PSConstants.reverseNameLookup(s, map); } catch (e) {}
    }
    if (!v) {
      try { v = app.typeIDToStringID(s); } catch (e) {}
    }
  } catch (e) {
  }
  $.level = lvl;
  if (!v) {
    v = Stdlib.numberToAscii(s);
  }
  return v ? v : s;
};
// deprecated
id2name = function(s) {
  return id2char(s);
};

if (!$.evalFile) {
  // only CS3 defines global and evalFile
  global = this;
} else {
  global = $.global;
}

isPhotoshop = function() {
  return !!app.name.match(/photoshop/i);
};
isPhotoshopElements = function() {
  return !!BridgeTalk.appName.match(/pseeditor/i);
};
isPSE = isPhotoshopElements;
isBridge = function() {
  return !!app.name.match(/bridge/i);
};
isInDesign = function() {
  return !!app.name.match(/indesign/i);
};

//
// Simple checks for photoshop version
//
var psVersion;
var pseVersion;
try {
  var lvl = $.level;
  // $.level = 0;
  psVersion = app.version;

  if (isPSE()) {
    pseVersion = psVersion;
    var _tmp = psVersion.split(/\./);
    _tmp[0] = (toNumber(_tmp[0])+2).toString();
    psVersion = _tmp.join(".");
    delete _tmp;
  }

 } catch (e) {
  psVersion = version;

 } finally {
   $.level = lvl;
   delete lvl;
}

// see XBridgeTalk for more comprehensive isCSX handling
// if (!global["isCS3"]) {
//   isCS3 = function()  { return psVersion.match(/^10\./) != null; };
// }
// if (!global["isCS2"]) {
//   isCS2 = function()  { return psVersion.match(/^9\./) != null; };
// }
CSVersion = function() {
  return toNumber(psVersion.match(/^\d+/)[0]) - 7;
};
CSVersion._version = CSVersion();

// not happy about the CS7+ definitions
isCC2015 = function()  { return CSVersion._version == 9; };
isCC2014 = function()  { return CSVersion._version == 8; }; 
isCC     = function()  { return CSVersion._version == 7; }; 
isCS7    = function()  { return CSVersion._version == 7; };
isCS6    = function()  { return CSVersion._version == 6; };
isCS5    = function()  { return CSVersion._version == 5; };
isCS4    = function()  { return CSVersion._version == 4; };
isCS3    = function()  { return CSVersion._version == 3; };
isCS2    = function()  { return CSVersion._version == 2; };
isCS     = function()  { return CSVersion._version == 1; };
isPS7    = function()  { return psVersion.match(/^7\./) != null; };


if (isPS7()) {  // this does not work for eval-includes
  app = this;
}

isWindows = function() {
  return $.os.match(/windows/i);
};
isMac = function() {
  return !isWindows();
};
isVista = function() {
  return $.os.match(/vista/i);
};
isVista64 = function() {
  return $.os.match(/vista\/64/i);
};

//
// ZStrs is a container for (mostly) localized strings used in psx
// or elsewhere
//
if (typeof(ZStrs) == "undefined") {
  ZStrs = {};
}


// this makes PS7 compatibility a bit easier
function getUnitValue(u) { return (u.value != undefined) ? u.value : u; }

function newLocalString(scope, name, value, prefix, container) {
  if (!scope || !scope.beginsWith('$$$/')) {
    Error.runtimeError(19, 'scope');  // Bad Argument
  }

  if (!name) {
    Error.runtimeError(19, 'name');  // Bad Argument
  }

  if (prefix == undefined) {
    prefix = "str";
  }

  if (value == undefined) {
    value = name;
  }

  if (!scope.endsWith('/')) {
    scope += '/';
  }

  var str = localize(scope + name + '=' + value);

  if (container) {
    container[prefix + name] = str;
  }

  return str;
}

//
//=============================== Stdlib =====================================
// This is the name space for utility functions. This should probably be
// broken up into smaller classes

Stdlib = function Stdlib() {};

Stdlib.PSVersion = Number(app.version.match(/^\d+/)[0]);


Stdlib.VERSION = "2.3";  // update manually

Stdlib.RcsId = "$Id: XWatermark.jsx,v 1.74 2015/12/03 22:01:33 anonymous Exp $";

Stdlib.ERROR_CODE = 9001;
Stdlib.IO_ERROR_CODE = 9002;

Stdlib.IOEXCEPTIONS_ENABLED = true;

//================================= language =================================
//
// throwError
//     throw an exception where you would normally have an
//     expression e.g.
//        var f = File("~/start.ini");
//        f.open("r") || Stdlib.throwError(f.error);
//
Stdlib.throwError = function(e) {
  throw e;
};
throwError = Stdlib.throwError;

Stdlib.quit = function(interactive) {
  // no interactive support yet...
  executeAction(cTID('quit'), new ActionDescriptor(), DialogModes.NO);
};

//
// createObject
//
Stdlib.createObject = function(cls, attrs) {
  var obj = new cls();
  for (var v in attrs) {
    obj[v] = attrs[v];
  }
  return obj;
};

//
// for when you really, really have to wipe-out an object
//
Stdlib.clearObject = function(obj) {
  for (var idx in obj) {
    try { delete obj[idx]; } catch (e) {}
  }
  return obj;
};

Stdlib.copyFromTo = function(from, to) {
  if (!from || !to) {
    return;
  }
  for (var idx in from) {
    var v = from[idx];
    if (typeof v == 'function') {
      continue;
    }
    if (v == 'typename'){
      continue;
    }

    try { to[idx] = v; } catch (e) {}
  }
};

Stdlib.randomElement = function(ary) {
  return ary[Math.floor(Math.random(ary.length) * ary.length)];
};

Stdlib.popRandomElement = function(ar) {
  if (ar.length == 0) {
    return undefined;
  }
  if (ar.length == 1) {
    var el = ar[0];
    ar.length = 0;
    return el;
  }
  var idx = Math.floor(Math.random(ar.length) * ar.length);
  var el = ar[idx];
  ar.splice(idx, 1);
  return el;
};


//
// This is one way of getting an environment variable. This is deprecated
// in CS2.
//
Stdlib.getenv = function(key) {
  if (key == undefined) {
    Error.runtimeError(2, "key");
  }

  if (!isCS() && !isPS7()) {
    return $.getenv(key);
  }

  key = key.toUpperCase();
  if (Stdlib.env != undefined) {
    return key ? Stdlib.env[key]: Stdlib.env;
  }
  Stdlib.env = new Object();

  var f = new File(Folder.temp + "/getenv.bat");
  f.open("w");
  f.writeln("set > env.txt");
  f.writeln("rename env.txt env.dat");
  f.close();
  f.execute();
  var o;

  var maxCount = 100;
  while (maxCount--) {
    // lets take a brief pause here....
    // 10000 seems about right on my box...
    // need to loop this and port to CS2
    Stdlib.pause(10000);
    o = new File("env.dat");
    if (o.exists) {
      break;
    }
    o = undefined;
  }
  if (!o) {
    Error.runtimeError(33); // internal error
  }
  o.open("r");
  var s = o.read();
  o.close();

  f.remove();
  o.remove();

  var envlist = s.split("\n");

  for (var i =0; i < envlist.length; i++) {
    var x = envlist[i].split("=");
    Stdlib.env[x[0].toUpperCase()] = x[1];
  }

  return key ? Stdlib.env[key]: Stdlib.env;
};

//
// runScript
//     load and execute an external script. use the standard
//     xscripts search path if the name is not absolute
//
Stdlib.IncludePathFile = "IncludePath.js";  // deprecated...

Stdlib.runScript = function(name) {
  Stdlib.runScriptByName(name,
                         (name.charAt(0) == '/') ?
                         null : Stdlib.IncludePathFile);
};

Stdlib.runScriptByName = function(name, path) {
  var str = "//@include \"" + name + "\";\r";
  if (path) {
    str = "//@include \"" + path + "\";\r" + str;
  }
  eval(str); // can't do this at top-level so some scoping problems
             // are inevitable
  return true;
};

//
// Thanks to Rags Gardner and Bob Stucky
// news://adobeforums.com:119/3bbff2b9.3@webcrossing.la2eafNXanI
//
Stdlib.getScriptFolder = function() {
  return Stdlib.getScriptFile().parent;
};
Stdlib.getScriptFileName = function() {
  var f = Stdlib.getScriptFile();
  return (f ? f.absoluteURI : '');
};

Stdlib.getScriptFile = function() {
  if (CSVersion() < 2) {
    return undefined;
  }

  if (isCS2()) {
    // this behaves oddly in the presence of @include files in CS3
    var dbLevel = $.level;
    $.level = 0;
    var path = undefined;

    try {
      some_undefined_variable;
    } catch (e) {
      path = e.fileName;
    }

    $.level = dbLevel;

    return new File(path);
  }

  return new File($.fileName);
};

// thanks to Andrew Hall
Stdlib.btRunScript = function(script, btapp) {
  if (!btapp) { btapp = BridgeTalk.appSpecifier; }

  BridgeTalk.bringToFront(btapp);

  var bt = new BridgeTalk();
  bt.target = btapp;
  bt.body = "//@include \"" + script + "\";\r\n";
  bt.send();
};
Stdlib.btExec = function(code, btapp) {
  if (!btapp) { btapp = BridgeTalk.appSpecifier; }

  BridgeTalk.bringToFront(btapp);

  var bt = new BridgeTalk();
  bt.target = btapp;
  bt.body = code;
  bt.send();
};

Stdlib.restartScript = function() {
  Stdlib.btRunScript(Stdlib.getScriptFileName());
};

try {
Stdlib.PRESETS_FOLDER =
  new Folder(app.path + '/' +
             localize("$$$/ApplicationPresetsFolder/Presets=Presets"));

Stdlib.ADOBE_PRESETS_FOLDER = Stdlib.PRESETS_FOLDER;

Stdlib.USER_PRESETS_FOLDER =
    new Folder(Folder.userData + '/' +
               localize("$$$/private/AdobeSystemFolder/Adobe=Adobe") + '/' +
               localize("$$$/private/FolderNames/AdobePhotoshopProductVersionFolder") + '/' +
               localize("$$$/private/FolderName/UserPresetsFolder/Presets=Presets"));

Stdlib.SCRIPTS_FOLDER =
  new Folder(app.path + '/' +
             localize("$$$/ScriptingSupport/InstalledScripts=Presets/Scripts"));

Stdlib.PLUGINS_FOLDER =
    new Folder(app.path + '/' +
               localize("$$$/private/Plugins/DefaultPluginFolder=Plug-Ins"));

Stdlib.FLASH_PANELS_FOLDER =
    new Folder(Stdlib.PLUGINS_FOLDER + '/' +
               localize("$$$/private/Plugins/FlashFolder=Panels"));

Stdlib.PS_SETTINGS_FOLDER =
    new Folder(app.preferencesFolder + '/' +
          localize("$$$/private/WorkSpace/WorkSpaceFolder/WorkSpace=WorkSpaces"));

} catch (e) {
}

Stdlib._getPreferencesFolder = function() {
  var userData = Folder.userData;

  if (!userData || !userData.exists) {
    userData = Folder("~");
  }

  var folder = new Folder(userData + "/xtools");

  if (!folder.exists) {
    folder.create();
  }

  return folder;
};

Stdlib.PREFERENCES_FOLDER = Stdlib._getPreferencesFolder();

Stdlib.scriptListenerOn = function() {
  var desc = new ActionDescriptor;  
  desc.putBoolean(cTID('Log '), true);  
  executeAction(sTID("AdobeScriptListener ScriptListener"),
                desc, DialogModes.NO);  
};

Stdlib.scriptListenerOff = function() {
  var desc = new ActionDescriptor;  
  desc.putBoolean(cTID('Log '), false);  
  executeAction(sTID("AdobeScriptListener ScriptListener"),
                desc, DialogModes.NO);  
};

Stdlib.selectWorkSpace = function(name) {
  var desc1 = new ActionDescriptor();
  var ref1 = new ActionReference();
  ref1.putName( sTID('workspace'), name );
  desc1.putReference( cTID('null'), ref1 );
  executeAction( cTID('slct'), desc1, DialogModes.NO );
};

Stdlib.cleanFileName = function(file, sfw) {
  var fname = file.strf("%f");
  var dir = file.strf("%d");
  var ext = file.strf("%e");
  var chr = '_'; // (sfw ? '-' : '_');

  // clean out any problematic characters
  fname = fname.replace(/[:\/\\*\?\"\<\>\|]/g, chr);  // '/\:*?"<>|' -> '_'
  if (sfw) {
    fname = fname.replace(/\s/g, chr);
  }
  if (ext.length > 0) {
    file = File(dir + '/' + fname + '.' + ext);
  } else {
    file = File(dir + '/' + fname);  
  }

  return file;
};


//
// Format a Date object into a proper ISO 8601 date string
//
Stdlib.toISODateString = function(date, timeDesignator, dateOnly, precision) {
  if (!date) date = new Date();
  var str = '';
  if (timeDesignator == undefined) { timeDesignator = 'T'; };
  function _zeroPad(val) { return (val < 10) ? '0' + val : val; }
  if (date instanceof Date) {
    str = (date.getFullYear() + '-' +
           _zeroPad(date.getMonth()+1,2) + '-' +
           _zeroPad(date.getDate(),2));
    if (!dateOnly) {
      str += (timeDesignator +
              _zeroPad(date.getHours(),2) + ':' +
              _zeroPad(date.getMinutes(),2) + ':' +
              _zeroPad(date.getSeconds(),2));
      if (precision && typeof(precision) == "number") {
        var ms = date.getMilliseconds();
        if (ms) {
          var millis = _zeroPad(ms.toString(),precision);
          var s = millis.slice(0, Math.min(precision, millis.length));
          str += "." + s;
        }
      }
    }
  }
  return str;
};

//
// Make it a Date object method
//
Date.prototype.toISODateString = function(timeDesignator, dateOnly, precision) {
  return Stdlib.toISODateString(this, timeDesignator, dateOnly, precision);
};
Date.prototype.toISOString = Date.prototype.toISODateString;

// Add test sets from
// http://www.pelagodesign.com/blog/2009/05/20/iso-8601-date-validation-that-doesnt-suck/
Stdlib.testISODate = function() {
  var strs = ["2006-09-01",
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

  for (var i = 0; i < strs.length; i++) {
    var s = strs[i];
    alert(s + " :: " + Stdlib.parseISODateString(s).toISODateString('T', false, 2));
  }
};


//
// xmp = new XMPData(doc); Stdlib.parseISODateString(xmp.get('createdate'))
//
//
// Here's a better RegExp to validate with
// ^([\+-]?\d{4}(?!\d{2}\b))((-?)((0[1-9]|1[0-2])(\3([12]\d|0[1-9]|3[01]))?|W([0-4]\d|5[0-2])(-?[1-7])?|(00[1-9]|0[1-9]\d|[12]\d{2}|3([0-5]\d|6[1-6])))([T\s]((([01]\d|2[0-3])((:?)[0-5]\d)?|24\:?00)([\.,]\d+(?!:))?)?(\17[0-5]\d([\.,]\d+)?)?([zZ]|([\+-])([01]\d|2[0-3]):?([0-5]\d)?)?)?)?$
//
Stdlib.parseISODateString = function(str) {
  if (!str) {
    return undefined;
  }
  // \d{4}(:|-)\d{2}(:-)\d{2}( |T).\d{2}:\d{2}:\d{2}(Z|((\-\+)\d{2}:\d{2}))?

  // Date portion /^(\d{4}).?(\d{2}).?(\d{2})/
  // Divider ( |T)
  var date = undefined;
  //$.level = 1; debugger;
  if (str.length >= 10 && str.length <= 35) {

    // we are assuming that this date is formatted correctly
    var utc = str.endsWith('Z');

    // handle the data portion e.g. 2006-06-08 or 2006:06:08 or 20060680
    var m = str.match(/^(\d{4}).?(\d{2}).?(\d{2})/);

    if (m) {
      var date = new Date();
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
          var hours = Number(m[2]);
          var mins = Number(m[3]);

          var nstr = str.slice(m.index);

          var secs = (m[4] ? Number(m[4]) : 0);
          var ms = 0;
          if (m[5]) {
            ms = Number("0" + m[5]) * 1000;
          }

          var z = (m[6] == 'Z');
          // assert(z == utc);

          if (utc) {
            date.setUTCHours(hours, mins, secs);
            date.setUTCMilliseconds(ms);

          } else {
            date.setHours(hours, mins, secs);
            date.setMilliseconds(ms);
          }

          if (m[6] || (m[7] && m[8] && m[9])) {
            var tzd = (z ? 'Z' : m[7] + m[8] + ':' + m[9]);
            date.tzd = tzd;
          }

        } else {
          date = undefined;
        }
      }
    }
  }

  return date;
};

Stdlib.binToHex = function(s, whitespace) {
  function hexDigit(d) {
    if (d < 10) return d.toString();
    d -= 10;
    return String.fromCharCode('A'.charCodeAt(0) + d);
  }
  var str = '';

  if (s.constructor != String) {
    s = s.toString();
  }

  for (var i = 0; i < s.length; i++) {
    if (i) {
      if (whitespace == true) {
        if (!(i & 0xf)) {
          str += '\r\n';
        } else if (!(i & 3)) {
          str += ' ';
        }
      }
    }
    var ch = s.charCodeAt(i) & 0xFF;  // check for unicode here...
    str += hexDigit(ch >> 4) + hexDigit(ch & 0xF);
  }
  return str;
};
Stdlib.hexToBin = function(h) {
  function binMap(n) {
    if (n.match(/[0-9]/)) return parseInt(n);
    return parseInt((n.charCodeAt(0) - 'A'.charCodeAt(0)) + 10);
  }

  h = h.toUpperCase().replace(/\s/g, '');
  var bytes = '';

  for (var i = 0; i < h.length/2; i++) {
    var hi = h.charAt(i * 2);
    var lo = h.charAt(i * 2 + 1);
    var b = (binMap(hi) << 4) + binMap(lo);
    bytes += String.fromCharCode(b);
  }
  return bytes;
};
Stdlib.hexToJS = function(h) {
  var str = '';
  var blockSize = 64;
  var blockCnt = (h.length/blockSize).toFixed();

  for (var i = 0; i < blockCnt; i++) {
    var ofs = i * blockSize;
    str += "  \"" + h.slice(ofs, ofs + blockSize) + "\" +\n";
  }

  str += "  \"" + h.slice(blockCnt * blockSize) + "\"\n";
  return str;
};
Stdlib.shortToHex = function(w) {
  function sfcc(c) { return String.fromCharCode(c); }
  var bytes = [sfcc((w >> 8) & 0xFF),
               sfcc(w & 0xFF)];
  return Stdlib.binToHex(bytes.join(""));
};
Stdlib.longToHex = function(w) {
  function sfcc(c) { return String.fromCharCode(c); }
  var bytes = [sfcc((w >> 24) & 0xFF),
               sfcc((w >> 16) & 0xFF),
               sfcc((w >> 8) & 0xFF),
               sfcc(w & 0xFF)];
  return Stdlib.binToHex(bytes.join(""));
};
Stdlib.hexToLong = function(h) {
  function cca(s, i) { return s.charCodeAt(i); }
  var bytes = Stdlib.hexToBin(h);

  return ((cca(bytes, 0) << 24) +
          (cca(bytes, 1) << 16) +
          (cca(bytes, 2) << 8) +
          cca(bytes, 3));
};

Stdlib.hexTest = function() {
  var f = new File("/c/work/xxx.asl");
  var s = Stdlib.readFromFile(f, 'BINARY');
  var h = Stdlib.binToHex(s);
  var js = Stdlib.hexToJS(h);

  //alert(h.slice(0, 132));
  //alert(js.slice(0, 132));
  eval(" xxx = " + js);
  alert(xxx == h);

  var f = new File("/c/work/xxx2.asl");
  Stdlib.writeToFile(f, Stdlib.hexToBin(xxx), 'BINARY');
};

Stdlib.numberToAscii = function(n) {
  if (isNaN(n)) {
    return n;
  }
  var str = (String.fromCharCode(n >> 24) +
             String.fromCharCode((n >> 16) & 0xFF) +
             String.fromCharCode((n >> 8) & 0xFF) +
             String.fromCharCode(n & 0xFF));

  return (Stdlib.isAscii(str[0]) && Stdlib.isAscii(str[1]) &&
          Stdlib.isAscii(str[2]) && Stdlib.isAscii(str[3])) ? str : n;
};

// Need to implement C-style isAscii functions

Stdlib.ASCII_SPECIAL = "\r\n !\"#$%&'()*+,-./:;<=>?@[\]^_`{|}~";
Stdlib.isSpecialChar = function(c) {
  return Stdlib.ASCII_SPECIAL.contains(c[0]);
};
Stdlib.isAscii = function(c) {
  return !!(c.match(/[\w\s]/) || Stdlib.isSpecialChar(c));
};

//
//==================================== Strings ===============================
//


String.prototype.contains = function(sub) {
  return this.indexOf(sub) != -1;
};

String.prototype.containsWord = function(str) {
  return this.match(new RegExp("\\b" + str + "\\b")) != null;
};

String.prototype.endsWith = function(sub) {
  return this.length >= sub.length &&
    this.slice(this.length - sub.length) == sub;
};

String.prototype.reverse = function() {
  var ar = this.split('');
  ar.reverse();
  return ar.join('');
};

String.prototype.startsWith = function(sub) {
  return this.indexOf(sub) == 0;
};

String.prototype.trim = function() {
  return this.replace(/^[\s]+|[\s]+$/g, '');
};
String.prototype.ltrim = function() {
  return this.replace(/^[\s]+/g, '');
};
String.prototype.rtrim = function() {
  return this.replace(/[\s]+$/g, '');
};


//
// Trim leading and trailing whitepace from a string
//
Stdlib.trim = function(value) {
   return value.replace(/^[\s]+|[\s]+$/g, '');
};

Array.contains = function(ar, el) {
  for (var i = 0; i < ar.length; i++) {
    if (ar[i] == el) {
      return true;
    }
  }
  return false;
};
if (!Array.prototype.contains) {
  Array.prototype.contains = function(el) {
    for (var i = 0; i < this.length; i++) {
      if (this[i] == el) {
        return true;
      }
    }
    return false;
  };
}

if (!Array.prototype.indexOf) {
  Array.prototype.indexOf = function(el) {
    for (var i = 0; i < this.length; i++) {
      if (this[i] == el) {
        return i;
      }
    }
    return -1;
  };
}
if (!Array.prototype.lastIndexOf) {
  Array.prototype.indexOf = function(el) {
    for (var i = this.length-1; i >= 0; i--) {
      if (this[i] == el) {
        return i;
      }
    }
  return -1;
  };
}



// Array.prototype.iterate = function(ftn) {
//   for (var i = 0; i < this.length; i++) {
//     ftn(this[i]);
//   }
// };

// Array.prototype.grep = function(re, ftn, prop) {
//   for (var i = 0; i < this.length; i++) {
//     if (prop) {
//       if (this[i][prop].match(re)) {
//         ftn(re);
//       }
//     } else {
//       if (this[i].match(re)) {
//         ftn(re);
//       }
//     }
//   }
// };

//
//============================= File Utilities ===============================
//

function throwFileError(f, msg) {
  if (msg == undefined) {
    msg = '';
  }
  Error.runtimeError(Stdlib.IO_ERROR_CODE, Stdlib.fileError(f, msg));
};

Stdlib.fileError = function(f, msg) {
  return ("IOError: " + (msg || '') + " \"" + f + "\": " +  f.error + '.');
};

//
// Return a File or Folder object given one of:
//    A File or Folder Object
//    A string literal or a String object that refers to either
//    a File or Folder
//
Stdlib.convertFptr = function(fptr) {
  var f;

  try { if (fptr instanceof XML) fptr = fptr.toString(); } catch (e) {}

  if (fptr.constructor == String) {
    f = File(fptr);

  } else if (fptr instanceof File || fptr instanceof Folder) {
    f = fptr;

  } else {
    Error.runtimeError(19, "fptr");
  }
  return f;
};

Stdlib.createFileSelect = function(str) {
  if (isWindows()) {
    return str;
  }

  if (!str.constructor == String) {
    return str;
  }

  var exts = [];
  var rex = /\*\.(\*|[\w]+)(.*)/;
  var m;
  while (m = rex.exec(str)) {
    exts.push(m[1].toLowerCase());
    str = m[2];
  }

  function macSelect(f) {
    var name = decodeURI(f.absoluteURI).toLowerCase();
    var _exts = macSelect.exts;

    // alert(name);

    while (f.alias) {
      try {
        f = f.resolve();
      } catch (e) {
        f = null;
      }

      if (f == null) {
        return false;
      }
    }

    if (f instanceof Folder) {
      return true;
    }
    var fext = f.strf("%e").toLowerCase();

    for (var i = 0; i < _exts.length; i++) {
      var ext = _exts[i];
      if (ext == '*') {
        return true;
      }
      if (fext == ext) {
        return true;        
      }
      // if (name.match(RegExp("\\." + ext + "$", "i")) != null) {
      //   return true;
      // }
    }
    return false;
  }

  macSelect.exts = exts;
  return macSelect;
};

//
// Open a dialog to prompt the user to select a file.
// An initial file or folder can optionally be specified
// Change the current directory reference if we it
// seems appropriate.
//
//  var file = Stdlib.selectFileOpen("Choose a file to open",
//                                   "JPEG Files: *.jpg", "/c/tmp")
//  var file = Stdlib.selectFileSave("Choose a file to save",
//                                "JPEG Files: *.jpg", File("/c/tmp/tmp.jpg"))
//
Stdlib.selectFileOpen = function(prompt, select, start) {
  return Stdlib._selectFile(prompt, select, start, true);
};
Stdlib.selectFileSave = function(prompt, select, start) {
  return Stdlib._selectFile(prompt, select, start, false);
};
Stdlib.selectFile = Stdlib.selectFileOpen;

Stdlib._selectFile = function(prompt, select, start, open) {
  var file;

  if (!prompt) {
    prompt = 'Select a file';
  }

  if (start) {
    start = Stdlib.convertFptr(start);
  }

  var classFtn = (open ? File.openDialog : File.saveDialog);

  if (!start) {
    file = classFtn(prompt, select);

  } else {
    if (select.constructor == String) {
      var m = select.match(/.*: (.*)/);
      if (m) {
        if (!m.contains(':') && !m.contains(',')) {
          select = m[1];
        } else {
          select = "";
        }
      }
    }

    // Early revs of CS6 had a bug in File.openDlg and File.saveDlg
    // They appear to be fixed in current revs
    //     if (CSVersion() >= 6 && start instanceof File) {
    //       start = start.parent
    //     }

    if (start instanceof Folder) {
      var folder = start;
      while (start && !start.exists) {
        start = start.parent;
      }

      var files = start.getFiles(select);
      if (!files || files.length == 0) {
        files = start.getFiles();
      }
      for (var i = 0; i < files.length; i++) {
        var sf = files[i];
        if (sf instanceof File && sf.name[0] != '.') {
          start = sf;
          break;
        }
      }

      // This may no longer be required
      if (start instanceof Folder) {
        start = new File(start + "/file");
      }

      // openDlg and saveDlg were broke in early CS6 revs
      //       if (CSVersion() >= 6) {
      //         start = folder;
      //       }
    }

    if (start instanceof File) {
      var instanceFtn = (open ? "openDlg" : "saveDlg");

      if (instanceFtn in start) {
        file = start[instanceFtn](prompt, select);

      } else {
        try {
          if (start.exists) {
            Folder.current = start.parent;
          }
        } catch (e) {
        }
        file = classFtn(prompt, select);
      }
    } else {
      Folder.current = start;
      file = classFtn(prompt, select);
    }
  }

  if (file) {
    Folder.current = file.parent;
  }
  return file;
};

Stdlib.selectFolder = function(prompt, start) {
  var folder;

  if (!prompt) {
    prompt = 'Select a folder';
  }

  if (start) {
    start = Stdlib.convertFptr(start);
    while (start && !start.exists) {
      start = start.parent;
    }
  }

  if (!start) {
    folder = Folder.selectDialog(prompt);

  } else {
    if (start instanceof File) {
      start = start.parent;
    }

    if (start.selectDlg) {   // for CS2+
      folder = start.selectDlg(prompt);

    } else {               // for CS
      var preset = Folder.current;
      if (start.exists) {
        preset = start;
      }
      folder = Folder.selectDialog(prompt, preset);
    }
  }
  return folder;
};

Stdlib.ImageFileExtsComplete =
  "8bps,3ds,ai3,ai4,ai5,ai6,ai7,ai8,ai,arw,bmp,cin,cr2,crw,dae,dc2,dc3,dcr," +
  "dib,dic,dng,dpx,eps,epsf,epsp,erf,exr,fido,flm,gif,hdr,hrr," +
  "icb,jpeg?,jpg,kdc,kmz,m4v,mef,mfw,mos,mov,mp4,mpeg,mrw,nef,obj,orf,pam," +
  "pbm,pcd,pct,pcx,pdd,pdf,pdp,pef,pict?,png,pnm," +
  "ps(d|b)?,pxr,raf,raw,rgbe,rle,sct,sdpx,sr2,srf,tga,tiff?,u3d,vda,vst," +
  "wbmp?,x3f,xyze";

Stdlib.ImageFileExtsCompleteRE =
  new RegExp("\\.(" +
             Stdlib.ImageFileExtsComplete.replace(/,/g, '|') + ")$", 'i');

Stdlib.ImageFileExtsCommon =
  "psd,pdd,jpeg?,jpg,png,8bps,gif,bmp,rle,dib,tiff?,raw,dng,crw,cr2,nef,raf,orf";

Stdlib.ImageFileExtsCommonRE =
  new RegExp("\\.(" +
             Stdlib.ImageFileExtsCommon.replace(/,/g, '|')
             + ")$", 'i');

// 3rf,ciff,cs1,k25
Stdlib.RawImageFileExts =
  "arw,cr2,crw,dcr,dng,erf,kdc,mos,mef,mrw,nef,orf,pef,raf,raw," +
  "sr2,sraw,sraw1,srf,x3f";

Stdlib.RawImageFileExtsRE =
  new RegExp("\\.(" +
             Stdlib.RawImageFileExts.replace(/,/g, '|')
             + ")$", 'i');

Stdlib.isImageFile = function(fstr) {
  return fstr.toString().match(Stdlib.ImageFileExtsCommonRE) != null;
};
Stdlib.isRawImageFile = function(fstr) {
  return fstr.toString().match(Stdlib.RawImageFileExtsRE) != null;
};

// deprecated
Stdlib.isPSFileType = Stdlib.isImageFile;


Stdlib.isValidImageFile = function(f) {
  function _winCheck(f) {
    // skip mac system files
    if (f.name.startsWith("._")) {
      return false;
    }

    var ext = f.strf('%e').toUpperCase();
    return (ext.length > 0) && app.windowsFileTypes.contains(ext);
  }
  function _macCheck(f) {
    return app.macintoshFileTypes.contains(f.type) || _winCheck(f);
  }

  return (((File.fs == "Macintosh") && _macCheck(f)) ||
          ((File.fs == "Windows") && _winCheck(f)));
};

//
// Sort an array of files in XP's 'intuitive' sort order
// so that files like [x1.jpg,x2.jpg,x10.jpg,x20.jpg] are
// ordered in numerical sequence
//
Stdlib.XPFileSort = function(list) {
  var rex = /(\d+)\./;

  function xpCmp(a, b) {
    var ap = a.name.match(rex);
    var bp = b.name.match(rex);
    if (ap != null && bp != null) {
      return toNumber(ap[1]) - toNumber(bp[1]);
    }
    if (a.name.toLowerCase() < b.name.toLowerCase()) {
      return -1;
    } else if (a.name > b.name) {
      return 1;
    }
    return 0;
  }

  return list.sort(xpCmp);
};

//
// Adds RegExp support and avoids PS7/CS bug in Folder.getFiles()
// usage:
//    getFiles(folder);
//    getFiles(folder, "*.jpg");
//    getFiles(folder, /\.jpg$/);
//    getFiles(folder, function(f) { return f instanceof Folder; });
//
Stdlib.getFiles = function(folder, mask) {
  var files = [];

  folder = Stdlib.convertFptr(folder);

  if (folder.alias) {
    folder = folder.resolve();
  }

  var getF;
  if (Folder.prototype._getFiles) {
    getF = function(f, m) { return f._getFiles(m); };
  } else {
    getF = function(f, m) { return f.getFiles(m); };
  }

  if (mask == undefined) {
    mask = "";
  }

  if (mask instanceof RegExp) {
    var allFiles = getF(folder);
    for (var i = 0; i < allFiles.length; i = i + 1) {
      var f = allFiles[i];
      if (decodeURI(f.absoluteURI).match(mask)) {
        files.push(f);
      }
    }
  } else if (typeof mask == "function") {
    var allFiles = getF(folder);
    for (var i = 0; i < allFiles.length; i = i + 1) {
      var f = allFiles[i];
      if (mask(f)) {
        files.push(f);
      }
    }
  } else {
    files = getF(folder, mask);
  }

  return files;
};

//
// Install an adaptor to that our getFiles code will be invoked when
// Folder.getFiles is called. The difficulty here is that we need to retain
// a handle to the original implementation so that we can invoke it from
// our version and that this code may be executed multiple times.
//
Stdlib.getFiles.install = function() {
  if (!Folder.prototype._getFiles) {
     // save the original getFiles
    Folder.prototype._getFiles = Folder.prototype.getFiles;
    // slide in an adaptor for our version
    Folder.prototype.getFiles = function(mask) {
      return Stdlib.getFiles(this, mask);
    };
  }
};
//
// Remove our adaptor and restore the original Folder.getFiles method
//
Stdlib.getFiles.uninstall = function() {
  if (Folder.prototype._getFiles) {
    // restore the original getFiles
    Folder.prototype.getFiles = Folder.prototype._getFiles;
    // delete our adaptor
    delete Folder.protoype._getFiles;
  }
};

Stdlib.getFolders = function(folder) {
  if (folder.alias) {
    folder = folder.resolve();
  }
  var folders = Stdlib.getFiles(folder,
                                function(f) { return f instanceof Folder; });
  return folders;
};

Stdlib.getFiles.install();   // install our version of Folder.getFiles

Stdlib.findFiles = function(folder, mask) {
  if (folder.alias) {
    folder = folder.resolve();
  }
  var files = Stdlib.getFiles(folder, mask);
  var folders = Stdlib.getFolders(folder);

  for (var i = 0; i < folders.length; i++) {
    var f = folders[i];
    var ffs = Stdlib.findFiles(f, mask);
    // files.concat(ffs); This occasionally fails for some unknown reason (aka
    // interpreter Bug) so we do it manually instead
    while (ffs.length > 0) {
      files.push(ffs.shift());
    }
  }
  return files;
};

Stdlib.findImageFiles = function(folder) {
  return Stdlib.findFiles(folder, Stdlib.ImageFileExtsCommonRE);
};

Folder.prototype.findFiles = function(mask) {
  return Stdlib.findFiles(this, mask);
};

Stdlib.getImageFiles = function(folder, recursive, complete) {
  if (folder.alias) {
    folder = folder.resolve();
  }

  if (recursive == undefined) recursive = false;
  if (complete == undefined) complete = false;
  var mask = (complete ?
              Stdlib.ImageFileExtsCompleteRE : Stdlib.ImageFileExtsCommonRE);
  if (recursive) {
    return Stdlib.findFiles(folder, mask);
  } else {
    return Stdlib.getFiles(folder, mask);
  }
};

Stdlib.grep = function(folder, rex, frex, recursive) {
  if (folder.alias) {
    folder = folder.resolve();
  }

  if (frex == undefined) {
    frex = /.*/;
  }
  var files = (!!recursive ?
               Stdlib.findFiles(folder, frex) :
               Stdlib.getFiles(folder, frex));

  var hits = [];
  for (var i = 0; i < files.length; i++) {
    var file = files[i];
    if (file instanceof File) {
      var str = Stdlib.readFromFile(file);
      if (str.match(rex)) {
        hits.push(file);
      }
    }
  }
  return hits;
};

//
// Returns null if the match or a string if they don't
// Useful for testing but not much else
//
Stdlib.compareFiles = function(f1, f2) {
  if (!(f1 instanceof File)) f1 = new File(f1);
  if (!(f2 instanceof File)) f2 = new File(f2);

  if (!f1.exists || !f2.exists) {
    return "File(s) do not exist.";
  }
  if (f1.length != f2.length) {
    return "Files are different sizes.";
  }

  try {
    f1.open("r") || throwFileError(f1, "Unable to open input file ");
    f1.encoding = 'BINARY';
    f2.open("r") || throwFileError(f2, "Unable to open input file ");
    f2.encoding = 'BINARY';

  } finally {
    try { f1.close(); } catch (e) {}
    try { f2.close(); } catch (e) {}
  }

  while (!f1.eof && !f2.eof && (f1.read(1) == f2.read(1))) {
    // do nothing
  }
  if (!(f1.eof && f2.eof)) {
    return "File contents do not match.";
  }
  return null;
};

Stdlib.writeToFile = function(fptr, str, encoding, lineFeed) {
  var xfile = Stdlib.convertFptr(fptr);
  var rc;

  if (encoding) {
    xfile.encoding = encoding;
  }

  rc = xfile.open("w");
  if (!rc) {
    Error.runtimeError(Stdlib.IO_ERROR_CODE,
                       Stdlib.fileError(xfile, "Unable to open output file "));
  }

  if (lineFeed) {
    xfile.lineFeed = lineFeed;
  }

  if (isPS7() && encoding == 'BINARY') {
    // This is a little stunt to write binary files on PS7
    // where they are not supported
    
    xfile.lineFeed = 'unix';

    var pos = 0;
    var cr = '\r';
    var next;
    while ((next = str.indexOf(cr, pos)) != -1) {
      rc = xfile.write(str.substring(pos, next));
      if (!rc && Stdlib.IOEXCEPTIONS_ENABLED) {
        Error.runtimeError(Stdlib.IO_ERROR_CODE, Stdlib.fileError(xfile));
      }

      xfile.lineFeed = 'mac';

      rc = xfile.write(cr);
      if (!rc && Stdlib.IOEXCEPTIONS_ENABLED) {
        Error.runtimeError(Stdlib.IO_ERROR_CODE, Stdlib.fileError(xfile));
      }

      xfile.lineFeed = 'unix';
      pos = next + 1;
    }
    if (pos < str.length) {
      xfile.write(str.substring(pos));
    }
  } else {
    rc = xfile.write(str);
    if (!rc && Stdlib.IOEXCEPTIONS_ENABLED) {
      Error.runtimeError(Stdlib.IO_ERROR_CODE, Stdlib.fileError(xfile));
    }
  }

  rc = xfile.close();
  if (!rc && Stdlib.IOEXCEPTIONS_ENABLED) {
    Error.runtimeError(Stdlib.IO_ERROR_CODE, Stdlib.fileError(xfile));
  }
};

Stdlib.readFromFile = function(fptr, encoding, lineFeed) {
  var file = Stdlib.convertFptr(fptr);
  var rc;

  rc = file.open("r");
  if (!rc) {
    Error.runtimeError(Stdlib.IO_ERROR_CODE,
                       Stdlib.fileError(file, "Unable to open input file "));
  }
  if (encoding) {
    file.encoding = encoding;
  }
  if (lineFeed) {
    file.lineFeed = lineFeed;
  }
  var str = file.read();

  // in some situations, read() will set the file.error to
  // 'Character conversion error' but read the file anyway
  // in other situations it won't read anything at all from the file
  // we ignore the error if we were able to read the file anyway
  if (str.length == 0 && file.length != 0) {
    if (!file.error) {
      file.error = 'Probable Character conversion error';
    }
    if (Stdlib.IOEXCEPTIONS_ENABLED) {
      Error.runtimeError(Stdlib.IO_ERROR_CODE, Stdlib.fileError(file));
    }

  }

  rc = file.close();
  if (!rc && Stdlib.IOEXCEPTIONS_ENABLED) {
    Error.runtimeError(Stdlib.IO_ERROR_CODE, Stdlib.fileError(file));
  }

  return str;
};

Stdlib.INI_ENCODING = "LATIN1";

Stdlib.toIniString = function(obj) {
  var str = '';
  for (var idx in obj) {
    if (idx.charAt(0) == '_') {         // private stuff
      continue;
    }
    if (idx == 'typename') {
      continue;
    }
    var val = obj[idx];

    if (val == undefined) {
      val = '';
    }

    if (val.constructor == String ||
        val.constructor == Number ||
        val.constructor == Boolean ||
        typeof(val) == "object") {
      str += (idx + ": " + val.toString() + "\n");
    }
  }
  return str;
};
Stdlib.fromIniString = function(str, obj) {
  if (!obj) {
    obj = {};
  }
  var lines = str.split(/[\r\n]+/);

  var rexp = new RegExp(/([^:]+):(.*)$/);

  for (var i = 0; i < lines.length; i++) {
    var line = lines[i].trim();
    if (!line || line.charAt(0) == '#') {
      continue;
    }
    var ar = rexp.exec(line);
    if (!ar) {
      // $.level = 1; debugger;
      alert("Bad line in config file: \"" + line + "\"");
      return undefined;
    }
    obj[ar[1].trim()] = ar[2].trim();
  }
  return obj;
};
Stdlib.readIniFile = function(fptr, obj) {
  if (!obj) {
    obj = {};
  }

  fptr = Stdlib.convertFptr(fptr);
  if (!fptr.exists) {
    return obj;
  }

  if (fptr.open("r", "TEXT", "????")) {
    fptr.lineFeed = "unix";
    fptr.encoding = Stdlib.INI_ENCODING;
    var str = fptr.read();
    var rc = fptr.close();
    if (!rc && Stdlib.IOEXCEPTIONS_ENABLED) {
      Error.runtimeError(Stdlib.IO_ERROR_CODE, Stdlib.fileError(fptr));
    }

    return Stdlib.fromIniString(str, obj);

  } else if (Stdlib.IOEXCEPTIONS_ENABLED) {
    Error.runtimeError(Stdlib.IO_ERROR_CODE, Stdlib.fileError(fptr));
  }

  return obj;
};

Stdlib.readIniValue = function(fptr, nm) {
  var obj = Stdlib.readIniFile(fptr);
  return obj[nm];
};

Stdlib.writeIniValue = function(fptr, nm, val) {
  var obj = {};
  obj[nm] = val;
  Stdlib.updateIniFile(fptr, obj);
};

Stdlib.writeIniFile = function(fptr, obj, header) {
  var rc;
  var str = (header != undefined) ? header : '';

  str += Stdlib.toIniString(obj);

  var file = Stdlib.convertFptr(fptr);
  file.encoding = Stdlib.INI_ENCODING;
  rc = file.open("w", "TEXT", "????");
  if (!rc && Stdlib.IOEXCEPTIONS_ENABLED) {
    Error.runtimeError(Stdlib.IO_ERROR_CODE, Stdlib.fileError(file));
  }

  file.lineFeed = "unix";

  rc = file.write(str);
  if (!rc && Stdlib.IOEXCEPTIONS_ENABLED) {
    Error.runtimeError(Stdlib.IO_ERROR_CODE, Stdlib.fileError(file));
  }

  rc = file.close();
  if (!rc && Stdlib.IOEXCEPTIONS_ENABLED) {
    Error.runtimeError(Stdlib.IO_ERROR_CODE, Stdlib.fileError(file));
  }
};

Stdlib.updateIniFile = function(fptr, ini) {
  if (!ini || !fptr) {
    return undefined;
  }
  var file = Stdlib.convertFptr(fptr);

  // we can only update the file if it exists
  var update = file.exists;
  var str = '';

  if (update) {
    file.open("r", "TEXT", "????");
    fptr.encoding = Stdlib.INI_ENCODING;
    file.lineFeed = "unix";
    str = file.read();
    file.close();

    for (var idx in ini) {
      if (idx.charAt(0) == '_') {         // private stuff
        continue;
      }
      if (idx == "noUI") {
        continue;
      }
      if (idx == "typename") {
        continue;
      }

      var val = ini[idx];

      if (typeof(val) == "undefined") {
        val = '';
      }

      if (typeof val == "string" ||
          typeof val == "number" ||
          typeof val == "boolean" ||
          typeof val == "object") {
        idx += ':';
        var re = RegExp('^' + idx, 'm');

        if (re.test(str)) {
          re = RegExp('^' + idx + '[^\n]*', 'm');
          str = str.replace(re, idx + ' ' + val);
        } else {
          str += '\n' + idx + ' ' + val;
        }
      }
    }
  } else {
    // write out a new ini file
    for (var idx in ini) {
      if (idx.charAt(0) == '_') {         // private stuff
        continue;
      }
      if (idx == "noUI") {
        continue;
      }
      if (idx == "typename") {
        continue;
      }
      var val = ini[idx];

      if (typeof val == "string" ||
          typeof val == "number" ||
          typeof val == "boolean" ||
          typeof val == "object") {
        str += (idx + ": " + val.toString() + "\n");
      }
    }
  }

  if (str) {
    file.open("w", "TEXT", "????");
    fptr.encoding = Stdlib.INI_ENCODING;
    file.lineFeed = "unix";
    file.write(str);
    file.close();
  }

  return ini;
};

Stdlib.xmlFromIni = function(ini, arg) {
  var xml;

  if (ini == undefined) {
    Error.runtimeError(2, "ini"); // isUndefined
  }

  if (arg) {
    if (arg.constructor.name == 'String') {
      xml = new XML('<' + arg + '></' + arg + '>');
    } else if (arg instanceof XML) {
      xml = arg;
    } else {
      Error.runtimeError(1243); // bad arg 2
    }
  } else {
    xml = new XML('Ini');
  }

  for (var idx in ini) {
    if (idx.charAt(0) == '_') {         // private stuff
      continue;
    }
    if (idx == "noUI") {
      continue;
    }
    if (idx == "typename") {
      continue;
    }
    var val = ini[idx];

    if (typeof val == "string" ||
        typeof val == "number" ||
        typeof val == "boolean" ||
        typeof val == "object") {
      xml[idx] = val;
    }
  }

  return xml;
};

Stdlib.iniFromXML = function(xml, ini) {
  if (!xml) {
    Error.runtimeError(2, "xml");
  }
  if (!ini) {
    ini = {};
  }

  var els = xml.elements();

  for (var i = 0; i < els.length(); i++) {
    var el = els[i];
    ini[el.name()] = el.toString();
  }

  return ini;
};

Stdlib.readXMLFile = function(fptr) {
  var rc;
  var file = Stdlib.convertFptr(fptr);
  if (!file.exists) {
    Error.runtimeError(48); // File/Folder does not exist
  }

  file.encoding = "UTF8";
  file.lineFeed = "unix";

  rc = file.open("r", "TEXT", "????");
  if (!rc && Stdlib.IOEXCEPTIONS_ENABLED) {
    Error.runtimeError(Stdlib.IO_ERROR_CODE, Stdlib.fileError(file));
  }

  var str = file.read();

  // in some situations, read() will set the file.error to
  // 'Character conversion error' but read the file anyway
  // in other situations it won't read anything at all from the file
  // we ignore the error if we were able to read the file anyway
  if (str.length == 0 && file.length != 0) {
    if (!file.error) {
      file.error = 'Probable Character conversion error';
    }
    if (Stdlib.IOEXCEPTIONS_ENABLED) {
      Error.runtimeError(Stdlib.IO_ERROR_CODE, Stdlib.fileError(file));
    }
  }

  rc = file.close();
  if (!rc && Stdlib.IOEXCEPTIONS_ENABLED) {
    Error.runtimeError(Stdlib.IO_ERROR_CODE, Stdlib.fileError(file));
  }

  return new XML(str);
};

Stdlib.writeXMLFile = function(fptr, xml) {
  var rc;
  if (!(xml instanceof XML)) {
    Error.runtimeError(19, "xml"); // "Bad XML parameter";
  }

  var file = Stdlib.convertFptr(fptr);
  file.encoding = "UTF8";

  rc = file.open("w", "TEXT", "????");
  if (!rc && Stdlib.IOEXCEPTIONS_ENABLED) {
    Error.runtimeError(Stdlib.IO_ERROR_CODE, Stdlib.fileError(file));
  }

  // unicode signature, this is UTF16 but will convert to UTF8 "EF BB BF"
  // optional
  //file.write("\uFEFF");
  file.lineFeed = "unix";

  file.writeln('<?xml version="1.0" encoding="utf-8"?>');

  rc = file.write(xml.toXMLString());
  if (!rc && Stdlib.IOEXCEPTIONS_ENABLED) {
    Error.runtimeError(Stdlib.IO_ERROR_CODE, Stdlib.fileError(file));
  }

  rc = file.close();
  if (!rc && Stdlib.IOEXCEPTIONS_ENABLED) {
    Error.runtimeError(Stdlib.IO_ERROR_CODE, Stdlib.fileError(file));
  }

  return file;
};

//
// If the CSV string has headers (default) an array of objects
//   is returned using the headers as property names.
// If the CSV string does not have headers, an array of rows (Arrays)
//   is returned
//
Stdlib.fromCSVString = function(str, ar, hasHeaders) {
  return Stdlib.fromCharSVString(str, ',', ar, hasHeaders);
};
Stdlib.readCSVFile = function(fptr, ar, hasHeaders) {
  return Stdlib.readCharSVFile(fptr, ',', ar, hasHeaders);
};
Stdlib.fromTSVString = function(str, ar, hasHeaders) {
  return Stdlib.fromCharSVString(str, '\t', ar, hasHeaders);
};
Stdlib.readTSVFile = function(fptr, ar, hasHeaders) {
  return Stdlib.readCharSVFile(fptr, '\t', ar, hasHeaders);
};
Stdlib.fromCharSVString = function(str, ch, ar, hasHeaders) {
  hasHeaders = !!hasHeaders;
  if (!ar) {
    ar = [];
  }
  var lines = str.split(/\r|\n/);
  if (lines.length == 0) {
    return ar;
  }

  // This doesn't work '([^",]+)|"((?:[^"]|"")*)"|,(?=(,|$))';
  var rexStr = '([^",]+)|"((?:[^"]|"")*)"|^,';

  if (ch != ',') {
    rexStr = rexStr.replace(/,/g, ch);
  }

  var rexp = new RegExp(rexStr);
  function parseCSVLine(line, ch) {
    var parts = [];
    line = line.trim();
    var res;

    while (line.length && (res = line.match(rexp)) != null) {
      if (res[1] || res[2]) {
        if (res[1]) {
          parts.push(res[1]);
        } else {
          parts.push(res[2].replace(/""/g, '"'));
        }
        line = line.slice(res[0].length + res.index);
        if (line[0] == ch) {
          line = line.slice(1);
        }
      } else {
        while (true) {
          if (line[0] == ch) {
            parts.push('');
            line = line.slice(1);
            continue;
          }
          if (line.startsWith('""')) {
            parts.push('');
            line = line.slice(2);
            if (line[0] == ch) {
              line = line.slice(1);
            }
            continue;
          }
          break;
        }
      }
    }
    return parts;
  }

  var headers = [];
  if (hasHeaders) {
    var line = lines[0].trim();
    headers = parseCSVLine(line, ch);
    lines.shift();
  }
  ar.headers = headers;

  if (lines.length == 0) {
    return ar;
  }

  for (var i = 0; i < lines.length; i++) {
    var row = parseCSVLine(lines[i], ch);
    if (row.length == 0) {
      continue;
    }

    if (hasHeaders) {
      var obj = new Object();
      for (var j = 0; j < row.length; j++) {
        if (headers[j]) {
          obj[headers[j]] = row[j] || '';
        } else {
          obj[j] = row[j] || '';
        }
      }
      ar.push(obj);

    } else {
      ar.push(row);
    }
  }
  return ar;
};
Stdlib.readCharSVFile = function(fptr, ch, ar, hasHeaders) {
  if (!ar) {
    ar = [];
  }
  fptr = Stdlib.convertFptr(fptr);
  if (!fptr.exists) {
    return ar;
  }
  var str = Stdlib.readFromFile(fptr);
  return Stdlib.fromCharSVString(str, ch, ar, hasHeaders);
};

Stdlib.writeCSVFile = function(fptr, content, headers) {

  function arrayAsCSV(ar) {
    var str = '';
    var numRe = /^(\+|\-)?(\d+|\.\d+|\d+\.\d+)$/;

    for (var i = 0; i < ar.length; i++) {
      var v = ar[i].toString();
      
      if (v == '-' || v == '+' || !v.match(numRE)) {
        v = '\"' + v.replace(/"/g, '\"\"') + '\"';
        //");// needed for emacs syntax hilighting
      }
      str += v;
      if (i+1 != ar.length) {
        str += ',';
      }
    }
    
    return str;
  };

  fptr = Stdlib.convertFptr(fptr);
  
  fptr.lineFeed = 'unix';

  if (!fptr.open("w", "TEXT", "????")) {
    Error.runtimeError(Stdlib.IO_ERROR_CODE,
                       "IOError: unable to open file \"" + fptr + "\": " +
                       fptr.error + '.');
  }

  if (headers) {
    fptr.writeln(arrayAsCSV(headers));

    for (var i = 0; i < content.length; i++) {
      var obj = content[i];
      var ar = [];
      for (var j = 0; j < headers.length; j++) {
        var p = headers[j];
        var v = obj[p];
        if (v == undefined) {
          v = '';
        }
        ar.push(v);
      }

      fptr.writeln(arrayAsCSV(ar));
    }
  } else {
    for (var i = 0; i < content.length; i++) {
      var row = content[i];
      fptr.writeln(arrayAsCSV(row));
    }
  }

  fptr.close();
};


//
// The interactive parameter is not fully implemented
//
Stdlib.createFolder = function(fptr, interactive) {
  if (!fptr) {
    Error.runtimeError(19, "fptr");  // Bad Argument
  }

  if (fptr.constructor == String) {
    fptr = new Folder(fptr);
  }

  // XXX this needs testing
  if ((!fptr.exists || (fptr.parent && !fptr.parent.exists)) && interactive) {
    var f = (fptr instanceof File) ? fptr.parent : fptr;
    if (!confirm(f.toUIString() + " does not exist. Create?")) {
      return false;
    }
  }

  if (fptr instanceof File) {
    return Stdlib.createFolder(fptr.parent);
  }
  if (fptr.exists) {
    return true;
  }
  if (fptr.parent && !fptr.parent.exists) {
    if (!Stdlib.createFolder(fptr.parent)) {
      return false;
    }
  }
  return fptr.create();
};

//
// Write a message out to the default log file.
// Prefer UTF8 encoding.
// Prefer \n line endings on OS X.
//
Stdlib.log = function(msg) {
  var file;

  if (!Stdlib.log.enabled) {
    return;
  }

  if (!Stdlib.log.filename) {
    return;
  }

//   if (Stdlib.log.filename.endsWith(".ini")) {
//     debugger;
//     throw "Bad log file name";
//   }

  if (!Stdlib.log.fptr) {
    file = new File(Stdlib.log.filename);
    if (Stdlib.log.append && file.exists) {
      if (!file.open("e", "TEXT", "????"))  {
        Error.runtimeError(Stdlib.IO_ERROR_CODE,
                           "Unable to open log file(1) " +
                           file + ": " + file.error);
      }
      file.seek(0, 2); // jump to the end of the file

    } else {
      if (!file.open("w", "TEXT", "????")) {
        if (!file.open("e", "TEXT", "????")) {
          Error.runtimeError(Stdlib.IO_ERROR_CODE,
                             "Unable to open log file(2) " +
                             file + ": " +  file.error);
        }
        file.seek(0, 0); // jump to the beginning of the file
      }
    }
    Stdlib.log.fptr = file;

  } else {
    file = Stdlib.log.fptr;
    if (!file.open("e", "TEXT", "????"))  {
      Error.runtimeError(Stdlib.IO_ERROR_CODE,
                         "Unable to open log file(3) " +
                         file + ": " + file.error);
    }
    file.seek(0, 2); // jump to the end of the file
  }

  if (isMac()) {
    file.lineFeed = "Unix";
  }

  if (Stdlib.log.encoding) {
    file.encoding = Stdlib.log.encoding;
  }

  if (msg) {
    msg = msg.toString();
  }

  if (!file.writeln(new Date().toISODateString() + " - " + msg)) {
    Error.runtimeError(Stdlib.IO_ERROR_CODE,
                       "Unable to write to log file(4) " +
                       file + ": " + file.error);
  }

  file.close();
};
Stdlib.log.filename = Stdlib.PREFERENCES_FOLDER + "/stdout.log";
Stdlib.log.enabled = false;
Stdlib.log.encoding = "UTF8";
Stdlib.log.append = false;
Stdlib.log.setFile = function(filename, encoding) {
  Stdlib.log.filename = filename;
  Stdlib.log.enabled = filename != undefined;
  Stdlib.log.encoding = encoding || "UTF8";
  Stdlib.log.fptr = undefined;
};
Stdlib.log.setFilename = Stdlib.log.setFile;

//
// Thanks to Bob Stucky for this...
//
Stdlib._maxMsgLen = 5000;
Stdlib.exceptionMessage = function(e) {
  var str = '';
  var fname = (!e.fileName ? '???' : decodeURI(e.fileName));
  str += "   Message: " + e.message + '\n';
  str += "   File: " + fname + '\n';
  str += "   Line: " + (e.line || '???') + '\n';
  str += "   Error Name: " + e.name + '\n';
  str += "   Error Number: " + e.number + '\n';

  if (e.source) {
    var srcArray = e.source.split("\n");
    var a = e.line - 10;
    var b = e.line + 10;
    var c = e.line - 1;
    if (a < 0) {
      a = 0;
    }
    if (b > srcArray.length) {
      b = srcArray.length;
    }
    for ( var i = a; i < b; i++ ) {
      if ( i == c ) {
        str += "   Line: (" + (i + 1) + ") >> " + srcArray[i] + '\n';
      } else {
        str += "   Line: (" + (i + 1) + ")    " + srcArray[i] + '\n';
      }
    }
  }

  try {
    if ($.stack) {
      str += '\n' + $.stack + '\n';
    }
  } catch (e) {
  }

  if (str.length > Stdlib._maxMsgLen) {
    str = str.substring(0, Stdlib._maxMsgLen) + '...';
  }

  if (Stdlib.log.fptr) {
    str += "\nLog File:" + Stdlib.log.fptr.toUIString();
  }

  return str;
};

Stdlib.logException = function(e, msg, doAlert) {
  if (!Stdlib.log.enabled) {
    return;
  }

  if (doAlert == undefined) {
    doAlert = false;

    if (msg == undefined) {
      msg = '';
    } else if (isBoolean(msg)) {
      doAlert = msg;
      msg = '';
    }
  }

  doAlert = !!doAlert;

  var str = ((msg || '') + "\n" +
             "==============Exception==============\n" +
             Stdlib.exceptionMessage(e) +
             "\n==============End Exception==============\n");

  Stdlib.log(str);

  if (doAlert) {
    str += ("\r\rMore information can be found in the file:\r" +
            "    " + Stdlib.log.fptr.toUIString());

    alert(str);
  }
};


//
//========================= Photoshop - General ==============================
//

//
// Return an item called 'name' from the specified container.
// This works for the "magic" on PS containers like Documents.getByName(),
// for instance. However this returns null if an index is not found instead
// of throwing an exception.
//
// The 'name' argument can also be a regular expression.
// If 'all' is set to true, it will return all matches
//
Stdlib.getByName = function(container, name, all) {
  // check for a bad index
  if (!name) {
    Error.runtimeError(2, "name"); // "'undefined' is an invalid name/index");
  }

  var matchFtn;

  if (name instanceof RegExp) {
    matchFtn = function(s1, re) { return s1.match(re) != null; };
  } else {
    matchFtn = function(s1, s2) { return s1 == s2;  };
  }

  var obj = [];

  for (var i = 0; i < container.length; i++) {
    if (matchFtn(container[i].name, name)) {
      if (!all) {
        return container[i];     // there can be only one!
      }
      obj.push(container[i]);    // add it to the list
    }
  }

  return all ? obj : undefined;
};

//
// Returns all items in the container with the specified name.
//
Stdlib.getAllByName = function(container, name) {
  return Stdlib.getByName(container, name, true);
};

Stdlib.getByProperty = function(container, prop, value, all) {
  // check for a bad index
  if (prop == undefined) {
    Error.runtimeError(2, "prop");
  }
  if (value == undefined) {
    Error.runtimeError(2, "value");
  }
  var matchFtn;

  all = !!all;

  if (value instanceof RegExp) {
    matchFtn = function(s1, re) { return s1.match(re) != null; };
  } else {
    matchFtn = function(s1, s2) { return s1 == s2; };
  }

  var obj = [];

  for (var i = 0; i < container.length; i++) {
    if (matchFtn(container[i][prop], value)) {
      if (!all) {
        return container[i];     // there can be only one!
      }
      obj.push(container[i]);    // add it to the list
    }
  }

  return all ? obj : undefined;
};

//
// Stdlib.getByFunction
//   Return an element (or elements) of the container where the match function
//     returns 'true'
//
// Stdlib.getByFunction(doc.artLayers, function(layer) {
//   return layer.name.length > 10; }, true)
//
Stdlib.getByFunction = function(container, matchFtn, all) {
  // check for a match function
  if (!matchFtn) {
    Error.runtimeError(2, "matchFtn"); //"'undefined' is an invalid function"
  }

  if (typeof matchFtn != "function") {
    Error(19, "matchFtn"); // Bad arg "A match function must be specified"
  }

  var obj = [];

  for (var i = 0; i < container.length; i++) {
    if (matchFtn(container[i])) {
      if (!all) {
        return container[i];     // there can be only one!
      }
      obj.push(container[i]);    // add it to the list
    }
  }

  return all ? obj : undefined;
};

Stdlib.setPropertyValues = function(container, prop, value) {
  // check for a bad index
  if (prop == undefined) {
    Error.runtimeError(2, "prop");
  }
  if (value == undefined) {
    Error.runtimeError(2, "value");
  }
  var matchFtn;

  var obj = [];

  for (var i = 0; i < container.length; i++) {
    container[i][prop] = value;
  }

  return;
};


Stdlib.sortByName = function(ary) {
  function nameCmp(a, b) {
    if (a.name < b.name) {
      return -1;
    } else if (a.name > b.name) {
      return 1;
    }
    return 0;
  }

  return ary.sort(nameCmp);
};


// makeActive
// Make the object (regardless of class) the 'active' one. Currently, this
// works for documents and layers. The one that was active before this call
// is returned
//
Stdlib.makeActive = function(obj) {
  var prev = undefined;

  if (!obj) {
    return undefined;
  }

  if (obj.typename == "Document") {
    prev = app.activeDocument;
    if (obj != prev) {
      app.activeDocument = obj;
    }
  } else if (obj.typename.match(/Layer/)) {
    var doc = obj.parent;
    while (!(doc.typename == "Document") && doc) {
      doc = doc.parent;
    }
    if (!doc) {
      Error.runtimeError(19, "obj"); // "Bad Layer object specified"
    }

    prev = doc.activeLayer;
    if (obj != prev) { 
      var d = app.activeDocument;
      app.activeDocument = doc;

      try {
        doc.activeLayer = obj;

      } catch (e) {
        $.level = 1; debugger;
      }
      app.activeDocument = d;
    }
  }

  return prev;
};

//
// via SzopeN
// These two vars are used by wrapLC/Layer and control whether or not
// the existing doc/layer should be restored after the call is complete
// If these are set fo false, the specified doc/layer will remain
// the active doc/layer
//
Stdlib._restoreDoc = true;
Stdlib._restoreLayer = true;

//
// ScriptingListener code operates on the "active" document.
// There are times, however, when that is _not_ what I want.
// This wrapper will make the specified document the active
// document for the duration of the ScriptingListener code and
// swaps in the previous active document as needed
//
Stdlib.wrapLC = function(doc, ftn) {
  var ad = app.activeDocument;
  if (doc) {
    if (ad != doc) {
      app.activeDocument = doc;
    }
  } else {
    doc = ad;
  }

  var res = undefined;
  try {
    res = ftn(doc);

  } finally {
    if (Stdlib._restoreDoc) {
      if (ad && app.activeDocument != ad) {
        app.activeDocument = ad;
      }
    }
  }

  return res;
};

//
// The same as wrapLC except it permits specifying a layer
//
Stdlib.wrapLCLayer = function(doc, layer, ftn) {
  var ad = app.activeDocument;
  if (doc) {
    if (ad != doc) {
      app.activeDocument = doc;
    }
  } else {
    doc = ad;
  }

  var al = doc.activeLayer;
  var alvis = al.visible;

  if (layer && doc.activeLayer != layer) {
    doc.activeLayer = layer;

  } else {
    layer = doc.activeLayer;
  }

  var res = undefined;

  try {
    res = ftn(doc, layer);

  } finally {
    if (Stdlib._restoreLayer) {
      if (doc.activeLayer != al) {
        try {
          doc.activeLayer = al;
        } catch (e) {
          // XXX-CC2015 Mondo bug work-around from Rune L-H
          if (app.displayDialogs == DialogModes.NO) {
            var mode = app.displayDialogs;
            app.displayDialogs = DialogModes.NO
            doc.activeLayer = al;
            app.displayDialogs = mode;
          }
        }
      }
      if (!doc.activeLayer.isBackgroundLayer) {
        doc.activeLayer.visible = alvis;
      }
    }

    if (Stdlib._restoreDoc) {
      if (app.activeDocument != ad) {
        app.activeDocument = ad;
      }
    }
  }

  return res;
};

//
// Invoke a Photoshop Event with no arguments
//
Stdlib.doEvent = function(doc, eid, interactive, noDesc) {
  var id;

  if (doc != undefined && eid == undefined) {
    if (doc.constructor == Number) {
      eid = doc.valueOf();
    } else if (doc.constructor == String) {
      eid = doc;
    }
    doc = undefined;
  }

  if (!eid) {
    Error.runtimeError(8600); // Event key is missing "No event id specified");
  }

  if (eid.constructor != Number) {
    if (eid.length < 4) {
      // "Event id must be at least 4 characters long"
      Error.runtimeError(19, "eventID");
    }

    if (eid.length == 4) {
      id = cTID(eid);
    } else {
      id = sTID(eid);
    }
  } else {
    id  = eid;
  }

  interactive = (interactive == true);
  noDesc = (noDesc == true);

  function _ftn() {
    var dmode = (interactive ? DialogModes.ALL : DialogModes.NO);
    var desc = (noDesc ? undefined : new ActionDescriptor());
    return app.executeAction(id, desc, dmode);
  }

  if (doc) {
    return Stdlib.wrapLC(doc, _ftn);
  } else {
    return _ftn(id);
  }
};

//
// Select/invoke a menu item
//
Stdlib.doMenuItem = function(item, interactive) {
  var desc = new ActionDescriptor();
  var ref = new ActionReference();

  if (item.constructor == String) {
    item = xTID(item);
  }

//  ref.putEnumerated(PSClass.MenuItem, PSType.MenuItem, item);
  ref.putEnumerated(cTID("Mn  "), cTID("MnIt"), item);
  desc.putReference(cTID("null"), ref);

  var lvl = $.level;
  $.level = 0;
  try {
    var mode = (interactive != true ? DialogModes.NO : DialogModes.ALL);
//     executeAction(PSString.select, desc, mode);
    executeAction(sTID("select"), desc, mode);
  } catch (e) {
    $.level = lvl;
    if (e.number != 8007) { // if not "User cancelled"
      throw e;
    } else {
      return false;
    }
  }
  $.level = lvl;

  return true;
};

Stdlib._print = function() {
  var dialogMode = DialogModes.NO;
  var desc1 = new ActionDescriptor();
  desc1.putBoolean(cTID('PstS'), true);
  desc1.putEnumerated(cTID('Inte'), cTID('Inte'), cTID('Clrm'));
  executeAction(cTID('Prnt'), desc1, dialogMode);
};

Stdlib.print = function(doc) {
  if (CSVersion() > 3) {
    function _ftn() {
      app.bringToFront();
      doc.printSettings.flip = false;
      doc.printSettings.setPagePosition(DocPositionStyle.SIZETOFIT);
      doc.printSettings.negative = false;

      doc.printOneCopy();
    }

    Stdlib.wrapLC(doc, _ftn);

  } else {
    function _ftn() {
      Stdlib._print();
    }

    Stdlib.wrapLC(doc, _ftn);
  }
};

Stdlib.copyTextToClipboard = function(text) {
  var desc = new ActionDescriptor();
  desc.putString(sTID("textToClipboard"), text);
};


//
// Select a tool from the tool palette
//   PSString.addKnotTool
//   PSString.artBrushTool
//   PSString.bucketTool
//   PSString.colorReplacementBrushTool
//   PSString.colorSamplerTool
//   PSString.convertKnotTool
//   PSString.cropTool
//   PSString.customShapeTool
//   PSString.deleteKnotTool
//   PSString.directSelectTool
//   PSString.ellipseTool
//   PSString.eyedropperTool
//   PSString.freeformPenTool
//   PSString.handTool
//   PSString.lassoTool
//   PSString.lineTool
//   PSString.magicStampTool
//   PSString.magicWandTool
//   PSString.magneticLassoTool
//   PSString.marqueeEllipTool
//   PSString.marqueeRectTool
//   PSString.marqueeSingleColumnTool
//   PSString.marqueeSingleRowTool
//   PSString.measureTool
//   PSString.moveTool
//   PSString.pathComponentSelectTool
//   PSString.penTool
//   PSString.polySelTool
//   PSString.polygonTool
//   PSString.rectangleTool
//   PSString.redEyeTool
//   PSString.roundedRectangleTool
//   PSString.sliceSelectTool
//   PSString.sliceTool
//   PSString.soundAnnotTool
//   PSString.spotHealingBrushTool
//   PSString.textAnnotTool
//   PSString.typeCreateMaskTool
//   PSString.typeCreateOrEditTool
//   PSString.typeVerticalCreateMaskTool
//   PSString.typeVerticalCreateOrEditTool
//   PSString.zoomTool
//
//   PSClass.ArtHistoryBrushTool
//   PSClass.BackgroundEraserTool
//   PSClass.BlurTool
//   PSClass.BurnInTool
//   PSClass.CloneStampTool
//   PSClass.DodgeTool
//   PSClass.EraserTool
//   PSClass.GradientTool
//   PSClass.HistoryBrushTool
//   PSClass.MagicEraserTool
//   PSClass.PaintbrushTool
//   PSClass.PatternStampTool
//   PSClass.PencilTool
//   PSClass.SaturationTool
//   PSClass.SharpenTool
//   PSClass.SmudgeTool
//   PSClass.SaturationTool aka SpongeTool
//
Stdlib.selectTool = function(tool) {

  if (!Stdlib.selectTool.map) {
    var map = {};
    map[ToolType.ARTHISTORYBRUSH] = cTID('ABTl'); // ArtHistoryBrushTool;
    map[ToolType.BACKGROUNDERASER] = cTID('SETl'); // BackgroundEraserTool;
    map[ToolType.BLUR] = cTID('BlTl'); // BlurTool;
    map[ToolType.BRUSH] = cTID('PbTl'); // PaintbrushTool;
    map[ToolType.BURN] = cTID('BrTl'); // BurnInTool;
    map[ToolType.CLONESTAMP] = cTID('ClTl'); // CloneStampTool;
    map[ToolType.COLORREPLACEMENTTOOL] = sTID('colorReplacementTool');
    map[ToolType.DODGE] = cTID('DdTl'); // DodgeTool;
    map[ToolType.ERASER] = cTID('ErTl'); // EraserTool;
    map[ToolType.HEALINGBRUSH] = sTID('magicStampTool');
    map[ToolType.HISTORYBRUSH] = cTID('HBTl'); // HistoryBrushTool;
    map[ToolType.PATTERNSTAMP] = cTID('PaTl'); // PatternStampTool;
    map[ToolType.PENCIL] = cTID('PcTl'); // PencilTool;
    map[ToolType.SHARPEN] = cTID('ShTl'); // SharpenTool;
    map[ToolType.SMUDGE] = cTID('SmTl'); // SmudgeTool;
    map[ToolType.SPONGE] = cTID('SrTl'); // SpongeTool aka SaturationTool;
    Stdlib.selectTool.map = map;
  }

  var toolID;

  if (tool.toString().startsWith('ToolType')) {
    var tid = Stdlib.selectTool.map[tool];

    if (tid == undefined) {
      var ttype = {};
      ttype._name = tool.substring(9);
      ttype.toString = function() {
        return "ToolType." + this._name.toUpperCase();
      };
      ToolType[ttype._name] = ttype;

      Stdlib.selectTool.map[ToolType[ttype._name]] = xTID(ttype._name);
      tid = Stdlib.selectTool.map[tool];
    }
    toolID = tid;

  } else if (isNumber(tool)) {
    toolID = tool;

  } else if (tool.constructor == String) {
    toolID = xTID(tool);

  } else {
    Error.runtimeError(9001, 'Bad ToolType specified');
  }

  var desc = new ActionDescriptor();
  var ref = new ActionReference();
  ref.putClass(toolID);
  desc.putReference(cTID('null'), ref);
  executeAction(cTID('slct'), desc, DialogModes.NO);
};

Stdlib.getCurrentTool = function() {
  var ref = new ActionReference();
  ref.putEnumerated(cTID("capp"), cTID("Ordn"), cTID("Trgt") );
  var desc = executeActionGet(ref);
  var tid = desc.getEnumerationType(sTID('tool'));
  return typeIDToStringID(tid);
};

Stdlib.getCurrentToolOptions = function() {
  var ref = new ActionReference();
  ref.putEnumerated(cTID("capp"), cTID("Ordn"), cTID("Trgt") );
  var desc = executeActionGet(ref);
  return desc.hasKey(cTID('CrnT')) ? desc.getObjectValue(cTID('CrnT')) : undefined;
};

// Stdlib._toolOptionSetBoolean = function(toolid, pid, val) {
//   var desc = new ActionDerscritor();
//   var ref = new ActionReference();
//   ref.putEnumerated()
// };

Stdlib.zoomIn = function() {
  Stdlib.doMenuItem("ZmIn");
};
Stdlib.zoomOut = function() {
  Stdlib.doMenuItem("ZmOt");
};
Stdlib.zoomActualPixels = function() {
  Stdlib.doMenuItem("ActP");
};
Stdlib.zoomFitOnScreen = function() {
  Stdlib.doMenuItem("FtOn");
};
Stdlib.zoomPrintSize = function() {
  Stdlib.doMenuItem("PrnS");
};

// From Mike Hale
Stdlib.setZoom = function(doc, zoom ) {
  var docRes = doc.resolution;
  doc.resizeImage( undefined, undefined, 72/(zoom/100), ResampleMethod.NONE );

  function _ftn() {
    var desc = new ActionDescriptor();
    var ref = new ActionReference();
    ref.putEnumerated( cTID( "Mn  " ), cTID( "MnIt" ), cTID( 'PrnS' ) );
    desc.putReference( cTID( "null" ), ref );
    executeAction( cTID( "slct" ), desc, DialogModes.NO );
  }

  doc.resizeImage( undefined, undefined, docRes, ResampleMethod.NONE );

  return Stdlib.wrapLC(doc, _ftn);
};

Stdlib.resetSwatches = function() {
  var desc26 = new ActionDescriptor();
  var ref16 = new ActionReference();
  ref16.putProperty( cTID('Clr '), cTID('Clrs') );
  desc26.putReference( cTID('null'), ref16 );
  executeAction( cTID('Rset'), desc26, DialogModes.NO );
};



//
//================================== Document =================================
//

//
// Create a new document with the name, mode, etc..., specified
//
Stdlib.newDocument = function(name, mode, width, height, resolution,
                              depth, colorProfile) {

// Stdlib.newDocument("bbb.psd", "RGBM", 250, 500, 72, 16)

  function _ftn(name, mode, width, height, resolution, depth) {
    var desc = new ActionDescriptor();
    desc.putString(cTID("Nm  "), name);
    desc.putClass(cTID("Md  "), cTID(mode));
    desc.putUnitDouble(cTID("Wdth"), cTID("#Rlt"), width);
    desc.putUnitDouble(cTID("Hght"), cTID("#Rlt"), height);
    desc.putUnitDouble(cTID("Rslt"), cTID("#Rsl"), resolution);
    desc.putDouble(sTID("pixelScaleFactor"), 1.000000 );
    desc.putEnumerated(cTID("Fl  "), cTID("Fl  "), cTID("Wht "));
    desc.putInteger(cTID("Dpth"), depth );
    desc.putString(sTID("profile"), colorProfile);

    var mkdesc = new ActionDescriptor();
    mkdesc.putObject(cTID("Nw  "), cTID("Dcmn"), desc);
    executeAction(cTID("Mk  "), mkdesc, DialogModes.NO );
  }

  if (!colorProfile) {
    colorProfile = ColorProfileNames.SRGB;
  }

  _ftn(name, mode, width, height, resolution, depth);
  return app.activeDocument;
};

Stdlib.newDocumentFromClipboard = function(name) {
  function _newDoc() {
    var desc2 = new ActionDescriptor();
    var desc3 = new ActionDescriptor();
    if (name) {
      desc3.putString( cTID('Nm  '), name);
    }
    desc3.putString( sTID('preset'), "Clipboard" );
    desc2.putObject( cTID('Nw  '), cTID('Dcmn'), desc3 );
    executeAction( cTID('Mk  '), desc2, DialogModes.NO );
  };

  function _paste() {
    var desc = new ActionDescriptor();   // AntiAlias
    desc.putEnumerated(cTID("AntA"), cTID("Annt"), cTID("Anno"));
    executeAction(cTID("past"), desc, DialogModes.NO);
  }

  var doc;
  if (isCS2() || isCS3()) {
    if (!name) {
      name = "Untitled";
    }
    doc = app.documents.add(UnitValue(100, "px"), UnitValue(100, "px"),
                            72, name, NewDocumentMode.RGB);
    _paste();
    var layer = doc.activeLayer;
    var bnds = Stdlib.getLayerBounds(doc, layer);
    doc.resizeCanvas(UnitValue(bnds[2], "px"), UnitValue(bnds[3], "px"));
    _paste();

  } else {
    _newDoc();
    _paste();
    doc = app.activeDocument;
  }
  doc.flatten();

  return doc;
};

//
// Stdlib.getObjectProperty
//   Return the value of a PS object's properties from the underlying
//     ActionDescriptor-based definition.
//   Returns 'undefined' if the property's value cannot be determined
//   This api currently only works on Application, Document, and
//   Layer-family objects.
//   Lower level apis make it possible to access other kinds of objects.
//
// Examples:
// var str = Stdlib.getObjectProperty(0, "Nm  ", "Lyr ")
// var bool = Stdlib.getObjectProperty(doc.activeLayer, "Vsbl", "Lyr ")
// var str = Stdlib.getObjectProperty(doc, 'Ttl ');
// var file = Stdlib.getObjectProperty(app, 'Path');
// var clrDesc = Stdlib.getObjectProperty(app, 'FrgC');
//
Stdlib.getObjectProperty = function(obj, prop, typ) {
  var val = Stdlib._getObjProperty(obj, prop, typ);

  return (val ? val.value : undefined);
};

// Stdlib.getObjectPropertyType
//   For UnitDouble, return the type
//   For Object, return the classId
//   For Enumerated, return the enumerationTypeId
//   All else, return undefined
//
Stdlib.getObjectPropertyType = function(obj, prop, typ) {
  var val = Stdlib._getObjProperty(obj, prop, typ);

  return (val ? val.type : undefined);
};
//
// Stdlib._getObjProperty
//   Returns an object with value and (optional) type of the property.
//   The 'typ' can be used when accessing an object type that this
//   function does not already understand
//
Stdlib._getObjProperty = function(obj, prop, typ) {
  var propId;
  var otyp;

  function _ftn(obj, propId, otyp) {
    var ref = new ActionReference();
    ref.putProperty(cTID("Prpr"), propId);

    if (typeof(obj) == "number") {
      ref.putIndex(cTID(otyp), obj);
    } else {
      ref.putEnumerated(cTID(otyp), cTID("Ordn"), cTID("Trgt") );
    }

    var desc;
    try {
      desc = executeActionGet(ref);
    } catch (e) {
      return undefined;
    }
    var val = {};

    if (desc.hasKey(propId)) {
      var typ = desc.getType(propId);
      switch (typ) {
        case DescValueType.ALIASTYPE:
          val.value = desc.getPath(propId); break;
        case DescValueType.BOOLEANTYPE:
          val.value = desc.getBoolean(propId); break;
        case DescValueType.CLASSTYPE:
          val.value = desc.getClass(propId); break;
        case DescValueType.DOUBLETYPE:
          val.value = desc.getDouble(propId); break;
        case DescValueType.ENUMERATEDTYPE:
          val.value = desc.getEnumeratedValue(propId);
          val.type = desc.getEnumeratedType(propId);
          break;
        case DescValueType.INTEGERTYPE:
          val.value = desc.getInteger(propId); break;
        case DescValueType.LISTTYPE:
          val.value = desc.getList(propId); break;
        case DescValueType.OBJECTTYPE:
          val.value = desc.getObjectValue(propId);
          val.type = desc.getObjectType(propId);
          break;
        case DescValueType.RAWTYPE:
          val.value = desc.getData(propId); break;
        case DescValueType.REFERENCETYPE:
          val.value = desc.getReference(propId); break;
        case DescValueType.STRINGTYPE:
          val.value = desc.getString(propId); break;
        case DescValueType.UNITDOUBLE:
          val.value = desc.getUnitDoubleValue(propId);
          val.type = desc.getUnitDoubleType(propId);
          break;
        default:
          try {
            if (typ == DescValueType.LARGEINTEGERTYPE) {
              val.value = desc.getLargeInteger(propId);
            }
          } catch (e) {
          }
          break;
      }
    }
    return val;
  }

  if (obj == undefined) {
    Error.runtimeError(2, "object");
  }
  if (prop == undefined) {
    Error.runtimeError(2, "property");
  }

  if (prop.constructor == String) {
    propId = xTID(prop);
  } else if (prop.constructor == Number) {
    propId = prop;
  } else {
    Error.runtimeError(19, "property");
  }

  var val; // {value: undefind, type: undefined}

  //$.level = 1; debugger;

  if (app.documents.length > 0) {
    var o_doc = app.activeDocument;   // active doc before this function
    var o_layer = o_doc.activeLayer;  // active layer before this function
  }

  if (typeof(obj) == "object") {
    if (typ == "Dcmn" || obj.typename == "Document") {
      otyp = "Dcmn";
      if (app.activeDocument != obj) {
        o_doc = app.activeDocument;
        app.activeDocument = obj;
      }

    } else if (typ == "Lyr " || obj.typename == "ArtLayer"
               || obj.typename == "LayerSet") {
      otyp = "Lyr ";
      var layer = obj;
      while(layer.parent != undefined &&
            layer.parent.typename != "Document") {
        layer = layer.parent;
      }
      if (app.activeDocument != layer.parent) {
        app.activeDocument = layer.parent;
      }
      if (layer.parent.activeLayer != obj) {
        layer.parent.activeLayer = obj;
      }

    } else if (typ == "capp" || obj.typename == "Application") {
      otyp = "capp";

    } else {
      Error.runtimeError(55, prop);
//       throw ("Unable to get property from " +
//              (obj.typename ? obj.typename : "unknown") +
//              " type of object.");
    }
  } else if (typeof(obj) == "number") {
    if (!typ) {
      Error.runtimeError(55, prop);
//       throw ("Unable to get property from unknown type of object");
    }
    if (typ != "Lyr " && typ != "Dcmn") {
      Error.runtimeError(9001,
                         "Indexed app operations are not yet supported.");
    }
    otyp = typ;
  }

  var val = _ftn(obj, propId, otyp);

  if (app.documents.length > 0) {
    if (o_doc.activeLayer != o_layer) {
      o_doc.activeLayer = o_layer;
    }
    if (app.activeDocument != o_doc) {
      app.activeDocument = o_doc;
    }
  }

  return val;
};

Stdlib.getLayerProperty = function(index, propSym) {
  return Stdlib.getObjectProperty(index, propSym, 'Lyr ');
};
Stdlib.getDocumentProperty = function(index, propSym) {
  return Stdlib.getObjectProperty(index, propSym, 'Dcmn');
};
Stdlib.getApplicationProperty = function(propSym) {
  return Stdlib.getObjectProperty(app, propSym);
};

//
// Duplicate an existing document and use the name specified.
// Optionally merge the layers
//
Stdlib.duplicateDocument = function(doc, name, merged) {
  function _ftn() {
    var desc = new ActionDescriptor();
    var ref = new ActionReference();
    ref.putEnumerated(cTID("Dcmn"), cTID("Ordn"), cTID("Trgt"));
    desc.putReference(cTID("null"), ref );

    if (name) {
      desc.putString(cTID("Nm  "), name);
    }
    if (merged == true) {
      desc.putBoolean(cTID("Mrgd"), true);
    }
    executeAction(cTID("Dplc"), desc, DialogModes.NO );
    return app.activeDocument;
  }

  return Stdlib.wrapLC(doc, _ftn);
};

Stdlib.getDocumentDescriptor = function(doc) {
  function _ftn() {
    var ref = new ActionReference();
    ref.putEnumerated( cTID("Dcmn"),
                       cTID("Ordn"),
                       cTID("Trgt") );  //activeDoc
    return executeActionGet(ref);
  }

  return Stdlib.wrapLC(doc, _ftn);
};

Stdlib.getDocumentIndex = function(doc) {
  return Stdlib.getDocumentProperty(doc, cTID('ItmI'));
};


Stdlib.isDocumentNew = function(doc){
  var desc = Stdlib.getDocumentDescriptor(doc);
  var rc = true;
  if (desc.hasKey(cTID("FilR"))) {  //FileReference
    var path = desc.getPath(cTID("FilR"));
    if (path) {
      rc = (path.absoluteURI.length == 0);
    }
  }
  return rc;
};

Stdlib.hasBackground = function(doc) {
   return doc.layers[doc.layers.length-1].isBackgroundLayer;

//   // Mike Hale's version...
//   function _ftn() {
//     var ref = new ActionReference();
//     ref.putProperty(cTID("Prpr"), cTID("Bckg"));
//     //bottom Layer/background
//     ref.putEnumerated(cTID("Lyr "),cTID("Ordn"),cTID("Back"));
//     var desc =  executeActionGet(ref);
//     var res = desc.getBoolean(cTID("Bckg"));
//     return res;
//   };

//   return Stdlib.wrapLC(doc, _ftn);


//   // or
//   try {
//     doc.backgroundLayer;
//     return true;
//   } catch (e) {
//     return false;
//   }
};
Stdlib.hasBackgroundLayer = Stdlib.hasBackground;

//
// Returns true if the file is an open document
//
Stdlib.isDocumentOpen = function(file) {
  if (file && (app.documents.length > 0)) {
    var doc = Stdlib.getByName(app.documents, file.name);
    if (doc) {
      return file == doc.fullName;
    }
  }
  return false;
};

Stdlib.getDocumentName = function(doc) {
  function _ftn() {
    var ref = new ActionReference();
    ref.putProperty(cTID('Prpr'), cTID('FilR'));
    ref.putEnumerated(cTID('Dcmn'), cTID('Ordn'), cTID('Trgt'));
    var desc = executeActionGet(ref);
    return desc.hasKey(cTID('FilR')) ? desc.getPath(cTID('FilR')) : undefined;
  }
  return Stdlib.wrapLC(doc, _ftn);
};
Stdlib.getDocumentFile = function(doc) {
  return Stdlib.getDocumentName(doc);
};

//
// Revert the document, or active document if one isn't specified
//
Stdlib.revertDocument = function(doc) {
  Stdlib.doEvent(doc, "Rvrt");
};

Stdlib.isLandscapeMode = function(obj) {
  var ru = app.preferences.rulerUnits;
  app.preferences.rulerUnits = Units.PIXELS;

  var rc = obj.width.value > obj.height.value;
  app.preferences.rulerUnits = ru;
  return rc;
};
Stdlib.isPortraitMode = function(obj) {
  var ru = app.preferences.rulerUnits;
  app.preferences.rulerUnits = Units.PIXELS;

  var rc = obj.width.value < obj.height.value;
  app.preferences.rulerUnits = ru;
  return rc;
};
Stdlib.isSquareMode = function(obj) {
  var ru = app.preferences.rulerUnits;
  app.preferences.rulerUnits = Units.PIXELS;

  var rc = obj.width.value == obj.height.value;
  app.preferences.rulerUnits = ru;
  return rc;
};

Stdlib.validateUnitValue = function(str, bu, ru) {
  var self = this;

  if (str instanceof UnitValue) {
    return str;
  }

  if (bu && bu instanceof Document) {
    var doc = bu;
    ru = doc.width.type;
    bu = UnitValue(1/doc.resolution, ru);

  } else {
    if (!ru) {
      ru = Stdlib.getDefaultRulerUnitsString();
    }
    if (!bu) {
      UnitValue.baseUnit = UnitValue(1/72, ru);
    }
  }
  str = str.toString().toLowerCase();

  var zero = new UnitValue("0 " + ru);
  var un = zero;
  if (!str.match(/[a-z%]+/)) {
    str += ' ' + ru.units;
  }
  un = new UnitValue(str);

  if (isNaN(un.value) || un.type == '?') {
    return undefined;
  }

  if (un.value == 0) {
    un = zero;
  }

  return un;
};

//
// Pops open a standard File Open Dialog and returns a Document or
// null if none is selected
// This is primarily for PS7 which does not have File.openDialog
//
Stdlib.openDialogPS7 = function(folder) {
  return Stdlib.selectImageFile(folder);
}

//
// selectImageFile will open a dialog on the folder it chooses,
// totally ignoring the default.
//
Stdlib.selectImageFile = function(file) {
  var ad;
  var doc = undefined;

  if (documents.length) {
    ad = app.activeDocument;
  }

  if (!file) {
    file = Folder.current;
  } else {
    file = Stdlib.convertFptr(file);
    if (!file.exists) {
      file = file.parent;
    }
  }
  if (file instanceof Folder) {
    var files = Stdlib.getImageFiles(file, false, true);
    if (files.length > 0) {
      file = files[0];
    } else {
      file = new File(file + "/untitled.psd");
    }
  }

  try {
    var desc = new ActionDescriptor();
    Folder.current = file.parent;
    desc.putPath( cTID('null'), file);
    executeAction(cTID("Opn "), desc, DialogModes.ALL);

  } catch (e) {
    throw e;
  }

  if (ad != app.activeDocument) {
    doc = app.activeDocument;
  }

  return doc;
};

//
// Paste the contents of the clipboard into the doc with antialias off
//
Stdlib.pasteInto = function(doc) {
  function _ftn() {
    var desc = new ActionDescriptor();   // AntiAlias
    desc.putEnumerated(cTID("AntA"), cTID("Annt"), cTID("Anno"));
    executeAction(cTID("PstI"), desc, DialogModes.NO);
  }
  Stdlib.wrapLC(doc, _ftn);
};


//
// Make it a Document object method
//
// Document.prototype.revert = function() {
//   Stdlib.revertDocument(this);
// };

//============================= History  ===============================
//
// Thanks to Andrew Hall for the idea
// Added named snapshot support
//
Stdlib.takeSnapshot = function(doc, sname) {
  function _ftn() {
    var desc = new ActionDescriptor();  // Make

    var sref = new ActionReference();   // Snapshot
    sref.putClass(cTID("SnpS"));
    desc.putReference(cTID("null"), sref);

    var fref = new ActionReference();    // Current History State
    fref.putProperty(cTID("HstS"), cTID("CrnH"));
    desc.putReference(cTID("From"), fref );

    if (sname) {                         // Named snapshot
      desc.putString(cTID("Nm  "), sname);
    }

    desc.putEnumerated(cTID("Usng"), cTID("HstS"), cTID("FllD"));
    executeAction(cTID("Mk  "), desc, DialogModes.NO );
  }

  Stdlib.wrapLC(doc, _ftn);
};

//
// Revert to named snapshot
//
Stdlib.revertToSnapshot = function(doc, sname) {
  function _ftn() {
    if (!sname) {
      return Stdlib.revertToLastSnapshot(doc);
    }
    var state = Stdlib.getByName(doc.historyStates, sname);
    if (state) {
      doc.activeHistoryState = state;
      return true;
    }
    return false;
  }
  return Stdlib.wrapLC(doc, _ftn);
};

//
// Revert to the last auto-named snapshot
//
Stdlib.revertToLastSnapshot = function(doc) {
  function _ftn() {
    var states = Stdlib.getByName(doc.historyStates, /^Snapshot /, true);
    if (states.length > 0) {
      doc.activeHistoryState = states.pop();
      return true;
    }
    return false;
  }
  return Stdlib.wrapLC(doc, _ftn);
};

Stdlib.deleteSnapshot = function(doc, name) {
  function _ftn() {
    var desc = new ActionDescriptor();
    var ref = new ActionReference();
    ref.putName(cTID('SnpS'), name);
    desc.putReference(cTID('null'), ref);
    executeAction(cTID('Dlt '), desc, DialogModes.NO );
  }
  return Stdlib.wrapLC(doc, _ftn);

//   function _deleteCurrent() {
//     var ref = new ActionReference();
//     ref.putProperty(cTID("HstS"), cTID("CrnH"));

//     var desc = new ActionDescriptor();
//     desc.putReference(cTID("null"), ref );
//     executeAction(cTID("Dlt "), desc, DialogModes.NO );
//   };

//   var state = doc.activeHistoryState;
//   if (!Stdlib.revertToSnapshot(doc, name)) {
//     return false;
//   }
//   try {
//     _deleteCurrent(doc, name);
//   } finally {
//     var level = $.level;
//     try {
//       $.level = 0;
//       doc.activeHistoryState = state;
//     } catch (e) {
//     }
//     $.level = level;
//   }
//   return true;
};

Stdlib.hist = function(dir) {
  function _ftn() {
    var desc = new ActionDescriptor();
    var ref = new ActionReference();
    ref.putEnumerated(cTID("HstS"), cTID("Ordn"), cTID(dir));
    desc.putReference(cTID("null"), ref);
    executeAction(cTID("slct"), desc, DialogModes.NO);
  }

  _ftn();
};
Stdlib.undo = function () {
  Stdlib.hist("Prvs");
};
Stdlib.redo = function () {
  Stdlib.hist("Nxt ");
};
Stdlib.Undo = function () {
  Stdlib.doEvent("undo");
};
Stdlib.Redo = function () {
  Stdlib.doEvent(sTID('redo'));
};


// Makes separate suspendHistory entries undoable (^Z)
Stdlib.suspendHistory = function (doc, name, ftn ) {
   doc.suspendHistory(name, ftn);
   app.activeDocument = app.activeDocument; // NOP
};

Stdlib.NOP = function() {
  try { app.activeDocument = app.activeDocument; } catch (e) { }
};

//
//================================== Layers ===================================
//
Stdlib.convertTextLayerToShape = function(doc, layer) {
  function _ftn() {
    if (layer.kind != LayerKind.TEXT) {
      Error.runtimeError(8177);  // Layer is not a text layer
//       throw "Cannot convert non-text layers to shapes.";
    }

    var desc = new ActionDescriptor();
    var cref = new ActionReference();
    cref.putClass( sTID('contentLayer') );
    desc.putReference( cTID('null'), cref );
    var lref = new ActionReference();
    lref.putEnumerated( cTID('TxLr'), cTID('Ordn'), cTID('Trgt') );
    desc.putReference( cTID('Usng'), lref );
    executeAction( cTID('Mk  '), desc, DialogModes.NO );
  }
  Stdlib.makeActive(doc);
  Stdlib.makeActive(layer);
  _ftn();
  return doc.activeLayer;
};
Stdlib.copyLayerToDocument = function(doc, layer, otherDoc) {
  function _ftn() {
    var desc = new ActionDescriptor();
    var fref = new ActionReference();
    fref.putEnumerated(cTID('Lyr '), cTID('Ordn'), cTID('Trgt'));
    desc.putReference(cTID('null'), fref);
    var tref = new ActionReference();
    tref.putIndex(cTID('Dcmn'), Stdlib.getDocumentIndex(otherDoc));
    // tref.putName(cTID('Dcmn'), otherDoc.name);
    desc.putReference(cTID('T   '), tref);
    desc.putInteger(cTID('Vrsn'), 2 );
    executeAction(cTID('Dplc'), desc, DialogModes.NO);
  };

  if (layer) {
    Stdlib.wrapLCLayer(doc, layer, _ftn);
  } else {
    Stdlib.wrapLC(doc, _ftn);
  }
};

Stdlib.convertToSmartLayer = function(doc, layer) {
  function _ftn() {
    Stdlib.doEvent(sTID('newPlacedLayer'));
  }
  Stdlib.wrapLCLayer(doc, layer, _ftn);
};

Stdlib.getSmartObjectType = function(doc, layer) {

  function _ftn() {
    var type = undefined;
    var ref = new ActionReference();
    ref.putEnumerated(cTID('Lyr '), cTID('Ordn'), sTID('Trgt') );
    var desc = executeActionGet(ref);
    if (desc.hasKey(sTID('smartObject'))) {// is smart object?
      var desc = executeActionGet(ref);
      var smObj = desc.getObjectValue(sTID('smartObject'));
      var place = smObj.getEnumerationValue(sTID('placed'));
      type = id2char(place, "Enum");
    }

    return type;
  }

  var typ = Stdlib.wrapLCLayer(doc, layer, _ftn);

  return typ;
};

Stdlib.getSmartObjectFile = function(doc, layer) {

  function _ftn() {
    var file = undefined;
    var ref = new ActionReference();
    ref.putEnumerated(cTID('Lyr '), cTID('Ordn'), sTID('Trgt') );
    var desc = executeActionGet(ref);
    if (desc.hasKey(sTID('smartObject'))) {// is smart object?
      var smObj = desc.getObjectValue(sTID('smartObject'));
      file = smObj.getString(sTID('FilR'));
    }
    return file;
  }

  var file = Stdlib.wrapLCLayer(doc, layer, _ftn);

  return file;
};


Stdlib.editSmartObject = function(doc, layer) {
  function _ftn() {
    var id21 = sTID( "placedLayerEditContents" );
    var desc7 = new ActionDescriptor();
    executeAction( id21, desc7, DialogModes.NO );
  }
  Stdlib.makeActive(doc);
  Stdlib.makeActive(layer);
  _ftn();
  return app.activeDocument;
};

Stdlib.updateSmartLayer = function(doc, layer) {
  function _ftn() {
    executeAction(sTID('updatePlacedLayer'), undefined, DialogModes.NO);
  };

  Stdlib.wrapLCLayer(doc, layer, _ftn);
};

Stdlib.replaceSmartLayerContents = function(doc, layer, file) {
  function _ftn() {
    var fptr = Stdlib.convertFptr(file);
    var desc = new ActionDescriptor();
    desc.putPath(cTID('null'), fptr);
    executeAction(sTID('placedLayerReplaceContents'), desc, DialogModes.NO);
  };

  Stdlib.wrapLCLayer(doc, layer, _ftn);
};

Stdlib.exportSmartLayer = function(doc, layer, file) {

  file = Stdlib.convertFptr(file);
  file.remove();

  function _ftn() {
    var dialogMode = app.displayDialogs;
    app.displayDialogs = DialogModes.NO;
    try {
      var desc22 = new ActionDescriptor();
      desc22.putPath( cTID('null'), file);
      executeAction( sTID('placedLayerExportContents'), desc22, DialogModes.NO );
    } finally {
      app.displayDialogs = dialogMode;
    }
  }

  Stdlib.wrapLCLayer(doc, layer, _ftn);
};



//
// Traverse the all layers, including nested layers, executing
// the specified function. Traversal can happen in both directions.
//
Stdlib.traverseLayers = function(doc, ftn, reverse, layerSets) {

  function _traverse(doc, layers, ftn, reverse, layerSets) {
    var ok = true;
    var len = layers.length;
    for (var i = 1; i <= len && ok != false; i++) {
      var index = (reverse == true) ? len-i : i - 1;
      var layer = layers[index];

      if (layer.typename == "LayerSet") {
        if (layerSets) {
          ok = ftn(doc, layer);
        }
        if (ok) {
          ok = _traverse(doc, layer.layers, ftn, reverse, layerSets);
        }
      } else {
        ok = ftn(doc, layer);
        try {
          if (app.activeDocument != doc) {
            app.activeDocument = doc;
          }
        } catch (e) {
        }
      }
    }
    return ok;
  };

  return _traverse(doc, doc.layers, ftn, reverse, layerSets);
};

Stdlib.getLayersList = function(doc, reverse, layerSets) {
  function _ftn(doc, layer) {
    _ftn.list.push(layer);
    return true;
  };

  _ftn.list = [];
  Stdlib.traverseLayers(doc, _ftn, reverse, layerSets);

  var lst = _ftn.list;
  _ftn.list = undefined;
  return lst;
};

Stdlib.getVisibleLayers = function(doc) {
  var layers = Stdlib.getLayersList(doc);
  return Stdlib.getByProperty(layers, "visible", true, true);
};

Stdlib._setSelLayerVis = function(doc, state) {
  function _ftn() {
    var desc = new ActionDescriptor();
    var list = new ActionList();
    var ref = new ActionReference();

    ref.putEnumerated(cTID("Lyr "), cTID("Ordn"), cTID("Trgt"));
    list.putReference(ref);
    desc.putList(cTID('null'),  list);

    executeAction(cTID(state), desc, DialogModes.NO);
  }
  Stdlib.wrapLC(doc, _ftn);
};
Stdlib.hideSelectedLayers = function(doc) {
  Stdlib._setSelectLayerVis(doc, 'Hd  ');
};
Stdlib.showSelectedLayers = function(doc) {
  Stdlib._setSelectLayerVis(doc, 'Shw ');
};

Stdlib._setOtherLayerVis = function(doc, layer, state) {
  function _extendLayerSelectionToIndex(doc, index) {
    var desc = new ActionDescriptor();
    var ref = new ActionReference();
    ref.putIndex(cTID('Lyr '), index);
    desc.putReference(cTID('null'), ref);
    desc.putEnumerated(sTID('selectionModifier'),
                       sTID('selectionModifierType'),
                       sTID('addToSelectionContinuous'));
    desc.putBoolean(cTID('MkVs'), false);
    executeAction(cTID('slct'), desc, DialogModes.NO);
  };

  var top = doc.layers[0];
  var lvis = layer.visible;
  var lidx = Stdlib.getLayerIndex(doc, layer);
  var bottom = doc.layers[doc.layers.length-1];

  doc.activeLayer = top;
  var bidx = Stdlib.getLayerIndex(doc, bottom);
  _extendLayerSelectionToIndex(doc, bidx);
  Stdlib._setSelLayerVis(doc, state);
  Stdlib.selectLayerByIndex(doc, lidx);
  layer.visible = lvis;
};

Stdlib.showOtherLayers = function(doc, layer) {
  Stdlib._setOtherLayerVis(doc, layer, 'Shw ');
};

Stdlib.hideOtherLayers = function(doc, layer) {
  Stdlib._setOtherLayerVis(doc, layer, 'Hd  ');
};


Stdlib.findLayer = function(doc, layerName) {
  function _findLayer(doc, layer) {
    if (_findLayer.matchFtn(layer.name, _findLayer.layerName)) {
      _findLayer.layer = layer;
      return false;
    }
    return true;
  }

  var matchFtn;

  if (layerName instanceof RegExp) {
    matchFtn = function(s1, re) { return s1.match(re) != null; };
  } else {
    matchFtn = function(s1, s2) { return s1 == s2;  };
  }

  _findLayer.matchFtn = matchFtn;
  _findLayer.layerName = layerName;
  Stdlib.traverseLayers(doc, _findLayer, false, true);
  return _findLayer.layer;
};


// Ex: layers = Stdlib.findLayerByProperty(doc, "visible", true, true);
Stdlib.findLayerByProperty = function(doc, prop, val, all) {

  function _findLayer(doc, layer) {
    if (_findLayer.matchFtn(layer[_findLayer.property], _findLayer.value)) {

      if (_findLayer.all) {
        _findLayer.result.push(layer);
        return true;

      } else {
        _findLayer.result = layer;
        return false;
      }
    }
    return true;
  }

  var _matchFtn;

  if (val instanceof RegExp) {
    _matchFtn = function(s1, re) { return s1.match(re) != null; };
  } else {
    _matchFtn = function(s1, s2) { return s1 == s2;  };
  }

  _findLayer.matchFtn = _matchFtn;
  _findLayer.property = prop;
  _findLayer.value = val;
  _findLayer.all = all;
  if (all) {
    _findLayer.result = [];
  }

  Stdlib.traverseLayers(doc, _findLayer, false, true);
  return _findLayer.result;
};


Stdlib.isLayerEmpty = function(doc, layer) {
  if (!doc) {
    doc = app.activeDocument;
  }
  if (!layer) {
    layer = doc.activeLayer;
  }

  return layer.bounds.toString().replace(/\D|0/g,"") == '';
};

Stdlib.mergeVisible = function(doc) {
  Stdlib.doEvent(doc, "MrgV");  // "MergeVisible"
};

Stdlib.mergeLayers = function(doc, layers) {
  if (layers) {
    Stdlib.selectLayers(doc, layers);
  }
  Stdlib.doEvent(doc, "Mrg2");  // "MergeLayers"
}

Stdlib.previousLayer = function(doc) {
  function _ftn() {
    var desc = new ActionDescriptor();
    var ref = new ActionReference();
    ref.putEnumerated( cTID('Lyr '), cTID('Ordn'), cTID('Bckw') );
    desc.putReference( cTID('null'), ref );
    desc.putBoolean( cTID('MkVs'), false );
    executeAction( cTID('slct'), desc, DialogModes.NO );
  }
  var layer = doc.activeLayer;
  try {
    var lvl = $.level;
    $.level = 0;
    var idx = Stdlib.getActiveLayerIndex(doc);
    Stdlib.wrapLC(doc, _ftn);
    var idx2 = Stdlib.getActiveLayerIndex(doc);

    if (idx2 > idx) {
      layer = doc.activeLayer;
    } else {
      doc.activeLayer = layer;
      layer = undefined;
    }

  } catch (e) {

  } finally {
   $.level = lvl;
   delete lvl;
  }
  return layer;
};

Stdlib.nextLayer = function(doc) {
  function _ftn() {
    var desc = new ActionDescriptor();
    var ref = new ActionReference();
    ref.putEnumerated( cTID('Lyr '), cTID('Ordn'), cTID('Frwr') );
    desc.putReference( cTID('null'), ref );
    desc.putBoolean( cTID('MkVs'), false );
    executeAction( cTID('slct'), desc, DialogModes.NO );
  }
  var layer = doc.activeLayer;
  try {
    var lvl = $.level;
    $.level = 0;
    var idx = Stdlib.getActiveLayerIndex(doc);
    Stdlib.wrapLC(doc, _ftn);
    var idx2 = Stdlib.getActiveLayerIndex(doc);

    if (idx2 > idx) {
      layer = doc.activeLayer;
    } else {
      doc.activeLayer = layer;
      layer = undefined;
    }

  } catch (e) {
    //$.level = 1; debugger;

  } finally {
   $.level = lvl;
   delete lvl;
  }
  return layer;
};


//
// Copy the styles from the current layer into the styles clipboard
//
Stdlib.copyStyles = function(doc, ignoreError) {
  if (ignoreError == true) {
    var lvl = $.level;
    $.level = 0;
    var rc = false;
    try {
      Stdlib.doEvent(doc, "CpFX"); // "CopyEffects";
      rc = true;
    } catch (e) {}

    $.level = lvl;
    return rc;

  } else if (typeof ignoreError == "object") { // it's probably a layer
    Stdlib.copyEffects(doc, ignoreError);
    return true;
  } else {
    Stdlib.doEvent(doc, "CpFX"); // "CopyEffects";
    return true;
  }
};

//
// Paste the styles from the styles clipboard into the current layer
//
Stdlib.pasteStyles = function(doc, layer, ignoreError) {
  if (ignoreError == true) {
    var lvl = $.level;
    $.level = 0;
    var rc = false;
    try {
      Stdlib.pasteStyles(doc, layer, false);
      rc = true;
    }
    catch (e) {}
    $.level = lvl;
    return rc;

  } else {
    var prev;
    if (layer) {
      prev = Stdlib.makeActive(layer);
    }
    Stdlib.doEvent(doc, "PaFX"); // "PasteEffects";
    if (prev) {
      Stdlib.makeActive(prev);
    }
  }
};

Stdlib.hasEffects = function(doc, layer) {
  var hasEffects = true;
  var lvl = $.level;
  try {
    $.level = 0;
    Stdlib.copyEffects(doc, layer);
  } catch (e) {
    hasEffects = false;
  } finally {
    $.level = lvl;
  }
  return hasEffects;
};
Stdlib.hasLayerStyles = Stdlib.hasEffects;

Stdlib.clearEffects = function(doc, layer) {
  function _ftn() {
    var desc = new ActionDescriptor();
    var ref = new ActionReference();
    ref.putEnumerated( cTID('Lyr '), cTID('Ordn'), cTID('Trgt') );
    desc.putReference( cTID('null'), ref );
    executeAction( sTID('disableLayerStyle'), desc, DialogModes.NO );
  }
  Stdlib.wrapLCLayer(doc, layer, _ftn);
};
Stdlib.clearLayerStyles = Stdlib.clearEffects;

Stdlib.copyEffects = function(doc, layer) {
  var prev;
  if (layer) {
    prev = Stdlib.makeActive(layer);
  }
  Stdlib.doEvent(doc, "CpFX"); // "CopyEffects";
  if (prev) {
    Stdlib.makeActive(prev);
  }
};
Stdlib.pasteEffects = function(doc, layer) {
  var prev;
  if (layer) {
    prev = Stdlib.makeActive(layer);
  }
  Stdlib.doEvent(doc, "PaFX"); // "PasteEffects";
  if (prev) {
    Stdlib.makeActive(prev);
  }
};
Stdlib._setEffectsViz = function(doc, layer, id) {
  function _ftn() {
    var desc = new ActionDescriptor();
    var list = new ActionList();
    var ref = new ActionReference();
    ref.putClass(cTID('Lefx'));
    ref.putEnumerated(cTID("Lyr "), cTID("Ordn"), cTID("Trgt"));
    list.putReference(ref);
    desc.putList(cTID('null'), list);
    executeAction(cTID(id), desc, DialogModes.NO);
  }
  Stdlib.wrapLCLayer(doc, layer, _ftn);
};
Stdlib.hideLayerEffects = function(doc, layer) {
  Stdlib._setEffectsViz(doc, layer, 'Hd  ');
};
Stdlib.hideLayerStyles = Stdlib.hideEffects = Stdlib.hideLayerEffects;
Stdlib.showLayerEffects = function(doc, layer) {
  Stdlib._setEffectsViz(doc, layer, 'Shw ');
};
Stdlib.showLayerStyles = Stdlib.showEffects = Stdlib.showLayerEffects;

//
// Stdlib.layerEffectsVisible(doc, doc.activeLayer);
//
Stdlib.layerEffectsVisible = function(doc, layer) {
  var al = doc.activeLayer;
  if (al != layer) {
    doc.activeLayer = layer;
  }
  var desc = Stdlib.getLayerDescriptor(doc, layer);
  var id = cTID('lfxv');
  var visible = desc.hasKey(id) && desc.getBoolean(id);

  if (al != layer) {
    doc.activeLayer = al;
  }

  return visible;
};

Stdlib.applyLayerStyleInteractive = function(doc, layer, ldesc) {
  return Stdlib.applyLayerStyle(doc, layer, ldesc, true);
};

Stdlib.applyLayerStyle = function(doc, layer, ldesc, interactive) {
  function _ftn() {
    var desc = new ActionDescriptor();
    var ref = new ActionReference();
    ref.putProperty(cTID('Prpr'), cTID('Lefx') );
    ref.putEnumerated(cTID('Lyr '), cTID('Ordn'), cTID('Trgt') );
    desc.putReference(cTID('null'), ref);

    if (!ldesc) {
      ldesc = new ActionDescriptor();
    }
    desc.putObject(cTID('T   '), cTID('Lefx'), ldesc);

    var xdesc = undefined;
    var mode = (interactive ? DialogModes.ALL : DialogModes.NO);
    try {
      xdesc = executeAction(cTID('setd'), desc, mode);
    } catch (e) {
      if (e.number != 8007) { // if not "User cancelled"
        throw e;
      }
    }
    return xdesc;
  }

  return Stdlib.wrapLCLayer(doc, layer, _ftn);
};



//
// Create a new document from the specified layer with the given name
//
Stdlib.makeDocFromLayer = function(doc, layer, docName) {
  function _ftn() {
    var desc = new ActionDescriptor();     // Make

    var dref = new ActionReference();      // Document
    dref.putClass(cTID("Dcmn"));
    desc.putReference(cTID("null"), dref);

    desc.putString(cTID("Nm  "), docName);  // Name

    var lref = new ActionReference();       // Layer
    lref.putName( cTID("Lyr "), layer.name);
    desc.putReference(cTID("Usng"), lref);

    executeAction(cTID("Mk  "), desc, DialogModes.NO);
  }

  // wrapLC is not used because we want to return the new
  // document from this function
  if (doc) {
    app.activeDocument = doc;
  } else {
    doc = app.activeDocument;
  }
  if (layer) {
    doc.activeLayer = layer;
  } else {
    layer = doc.activeLayer;
  }
  _ftn();
  return app.activeDocument;
};

Stdlib.getDocumentFromLayer = function(layer) {
  while(layer.parent != undefined && layer.parent.typename != "Document") {
    layer = layer.parent;
  }
  return layer.parent;
};

// from discussions with Mike Hale
Stdlib.hasLayerMask = function(doc, layer) {
  function _ftn() {
    var ref = new ActionReference();
    ref.putEnumerated(cTID("Lyr "), cTID("Ordn"), cTID("Trgt"));
    var desc = executeActionGet(ref);
    return desc.hasKey(cTID("UsrM"));
  }
  return Stdlib.wrapLCLayer(doc, layer, _ftn);
};


//
// Remove the mask from the layer. Apply the mask if 'apply' is true
//
Stdlib.removeLayerMask = function(doc, layer, apply) {
  function _ftn() {
    var desc = new ActionDescriptor();     // Delete

    var ref = new ActionReference();       // Mask Channel
    ref.putEnumerated(cTID("Chnl"), cTID("Chnl"), cTID("Msk "));
    desc.putReference(cTID("null"), ref);

    apply = (apply == true);
    desc.putBoolean(cTID("Aply"), apply);  // Apply Mask

    executeAction(cTID("Dlt "), desc, DialogModes.NO);
  }

  Stdlib.wrapLCLayer(doc, layer, _ftn);
};
Stdlib.removeMask = Stdlib.removeLayerMask;  // backwards compatibility

Stdlib.applyLayerMask = function(doc, layer) {
  function _ftn() {
    var ref = new ActionReference();
    ref.putEnumerated( cTID('Chnl'), cTID('Ordn'), cTID('Trgt') );

    var desc = new ActionDescriptor();
    desc.putReference( cTID('null'), ref );
    desc.putBoolean( cTID('Aply'), true );

    executeAction( cTID('Dlt '), desc, DialogModes.NO );
  }

  Stdlib.wrapLCLayer(doc, layer, _ftn);
};

Stdlib.selectLayerMask = function(doc, layer) {
  function _ftn() {
    var desc = new ActionDescriptor();
    var ref = new ActionReference();

    ref.putEnumerated(cTID("Chnl"), cTID("Chnl"), cTID("Msk "));
    desc.putReference(cTID("null"), ref);
    desc.putBoolean(cTID("MkVs"), false );
    executeAction(cTID("slct"), desc, DialogModes.NO );
  }

  Stdlib.wrapLCLayer(doc, layer, _ftn);
};
Stdlib.selectLayerMaskEdit = function(doc, layer) {
  function _ftn() {
    var desc11 = new ActionDescriptor();
        var ref8 = new ActionReference();
        ref8.putEnumerated( cTID('Chnl'), cTID('Ordn'), cTID('Trgt') );
    desc11.putReference( cTID('null'), ref8 );
    desc11.putBoolean( cTID('MkVs'), true );
    executeAction( cTID('slct'), desc11, DialogModes.NO );
  };
  Stdlib.selectLayerMask(doc, layer);
  Stdlib.wrapLCLayer(doc, layer, _ftn);
};

Stdlib.selectFilterMask = function(doc, layer) {
  function _ftn() {
    var desc273 = new ActionDescriptor();
        var ref215 = new ActionReference();
        ref215.putEnumerated( cTID('Chnl'), cTID('Chnl'), sTID('filterMask') );
    desc273.putReference( cTID('null'), ref215 );
    desc273.putBoolean( cTID('MkVs'), false );
    executeAction( cTID('slct'), desc273, DialogModes.NO );
  }
  Stdlib.wrapLCLayer(doc, layer, _ftn);
};
Stdlib.selectFilterMaskEdit = function(doc, layer) {
  function _ftn() {
    var desc273 = new ActionDescriptor();
        var ref215 = new ActionReference();
        ref215.putEnumerated( cTID('Chnl'), cTID('Chnl'), sTID('filterMask') );
    desc273.putReference( cTID('null'), ref215 );
    desc273.putBoolean( cTID('MkVs'), true );
    executeAction( cTID('slct'), desc273, DialogModes.NO );
  }
  Stdlib.wrapLCLayer(doc, layer, _ftn);
};


Stdlib.createLayerMask = function(doc, layer, fromSelection) {
  function _ftn() {
    var desc = new ActionDescriptor();
    desc.putClass(cTID("Nw  "), cTID("Chnl"));
    var ref = new ActionReference();
    ref.putEnumerated(cTID("Chnl"), cTID("Chnl"), cTID("Msk "));
    desc.putReference(cTID("At  "), ref);
    if (fromSelection == true) {
      desc.putEnumerated(cTID("Usng"), cTID("UsrM"), cTID("RvlS"));
    } else {
      desc.putEnumerated(cTID("Usng"), cTID("UsrM"), cTID("RvlA"));
    }
    executeAction(cTID("Mk  "), desc, DialogModes.NO);
  }

  Stdlib.wrapLCLayer(doc, layer, _ftn);
};

Stdlib.isLayerMaskEnabled = function(doc, layer) {
  var desc = Stdlib.getLayerDescriptor(doc, layer);
  return (desc.hasKey(cTID("UsrM")) && desc.getBoolean(cTID("UsrM")));
};

Stdlib.disableLayerMask = function(doc, layer) {
  Stdlib.setLayerMaskEnabledState(doc, layer, false);
};
Stdlib.enableLayerMask = function(doc, layer) {
  Stdlib.setLayerMaskEnabledState(doc, layer, true);
};
Stdlib.setLayerMaskEnabledState = function(doc, layer, state) {
  function _ftn() {
    var desc = new ActionDescriptor();

    var ref = new ActionReference();
    ref.putEnumerated(cTID('Lyr '), cTID('Ordn'), cTID('Trgt'));
    desc.putReference(cTID('null'), ref );

    var tdesc = new ActionDescriptor();
    tdesc.putBoolean(cTID('UsrM'), state);
    desc.putObject(cTID('T   '), cTID('Lyr '), tdesc);

    executeAction(cTID('setd'), desc, DialogModes.NO );
  }
  if (state == undefined) {
    state = false;
  }
  Stdlib.wrapLCLayer(doc, layer, _ftn);
};

Stdlib.createClippingMask = function(doc, layer) {

  function _ftn() {
    var desc = new ActionDescriptor();
    var ref = new ActionReference();
    ref.putEnumerated( cTID('Lyr '), cTID('Ordn'), cTID('Trgt') );
    desc.putReference( cTID('null'), ref );
    executeAction( cTID('GrpL'), desc, DialogModes.NO );
  }

  Stdlib.wrapLCLayer(doc, layer, _ftn);
};


Stdlib.releaseClippingMask = function(doc, layer) {

  function _ftn() {
    var desc = new ActionDescriptor();
    var ref = new ActionReference();
    ref.putEnumerated( cTID('Lyr '), cTID('Ordn'), cTID('Trgt') );
    desc.putReference( cTID('null'), ref );
    executeAction( cTID('Ungr'), desc, DialogModes.NO );
  }

  Stdlib.wrapLCLayer(doc, layer, _ftn);
};

Stdlib.hasClippingMask = function(doc, layer) {
  return Stdlib.getLayerProperty(layer, 'Grup');
};

Stdlib.isClippingMask = function(doc, layer) {
  var rc = false;
  try {
    var idx = Stdlib.getLayerIndex(doc, layer);
    Stdlib.selectLayerByIndex(doc, idx+1);
    var rc = Stdlib.getLayerProperty(doc.activeLayer, 'Grup');
    doc.activeLayer = layer;
  } catch (e) {
  }

  return rc;
};

Stdlib.rotateLayer = function(doc, layer, angle) {
  function _ftn() {
    var desc = new ActionDescriptor();
    var ref = new ActionReference();
    ref.putEnumerated(cTID("Lyr "), cTID("Ordn"), cTID("Trgt"));
    desc.putReference(cTID("null"), ref);
    desc.putUnitDouble(cTID("Angl"), cTID("#Ang"), angle);
    executeAction(cTID("Rtte"), desc, DialogModes.NO );
  }

  Stdlib.wrapLCLayer(doc, layer, _ftn);
};

Stdlib.rotateLayerAround = function(doc, layer, angle, x, y) {
  angle = Number(angle);
  if (isNaN(angle)) {
    Error.runtimeError(19, "angle");  // BadArgument
  }
  function _ftn() {
    var desc = new ActionDescriptor();
    var ref = new ActionReference();
    ref.putEnumerated( cTID('Lyr '), cTID('Ordn'), cTID('Trgt') );
    desc.putReference( cTID('null'), ref );
    desc.putEnumerated( cTID('FTcs'), cTID('QCSt'), cTID('Qcsi') );
    var ldesc = new ActionDescriptor();
    ldesc.putUnitDouble( cTID('Hrzn'), cTID('#Pxl'), x );
    ldesc.putUnitDouble( cTID('Vrtc'), cTID('#Pxl'), y );
    desc.putObject( cTID('Pstn'), cTID('Pnt '), ldesc );
    desc.putUnitDouble( cTID('Angl'), cTID('#Ang'), angle );
    executeAction( cTID('Trnf'), desc, DialogModes.NO );
  };

  Stdlib.wrapLCLayer(doc, layer, _ftn);
};


// Stdlib.moveLayerContent(doc, doc.activeLayer, -25, -25);
Stdlib.moveLayerContent = function(doc, layer, dx, dy) {
  function _ftn() {
    var desc = new ActionDescriptor();
    var lref = new ActionReference();
    lref.putEnumerated(cTID("Lyr "), cTID("Ordn"), cTID("Trgt"));
    desc.putReference(cTID("null"), lref);

    var pdesc = new ActionDescriptor();
    pdesc.putUnitDouble(cTID('Hrzn'), cTID('#Pxl'), dx);
    pdesc.putUnitDouble(cTID('Vrtc'), cTID('#Pxl'), dy);
    desc.putObject(cTID('T   '), cTID('Ofst'), pdesc);
    executeAction(cTID('move'), desc, DialogModes.NO);
  }

  if (layer) {
    // var idx = Stdlib.getLayerIndex(doc, layer);
    // Stdlib.moveLayerContentByIndex(doc, idx, dx, dy);

    Stdlib.wrapLCLayer(doc, layer, _ftn);
  } else {
    Stdlib.wrapLC(doc, _ftn);
  }
};

Stdlib.moveLayerContentByIndex = function(doc, idx, dx, dy) {
  function _ftn() {
    var desc = new ActionDescriptor();
    var ref = new ActionReference();
    ref.putIndex(cTID('Lyr '), idx);
    desc.putReference(cTID('null'), ref );
    var pdesc = new ActionDescriptor();
    pdesc.putUnitDouble(cTID('Hrzn'), cTID('#Pxl'), dx);
    pdesc.putUnitDouble(cTID('Vrtc'), cTID('#Pxl'), dy);
    desc.putObject(cTID('T   '), cTID('Ofst'), pdesc);
    executeAction(cTID('move'), desc, DialogModes.NO);
  }

  Stdlib.wrapLC(doc, _ftn);
};

Stdlib.freeTransform = function(doc, layer) {
//   Stdlib.doMenuItem(PSEnum.FreeTransform, true);
  Stdlib.doMenuItem(cTID("FrTr"), true);
};

Stdlib.transformScale = function(doc, layer, linked) {
  //   doc.activeLayer = layer;
  //   Stdlib.doMenuItem(cTID("Scl "), true);
  function _ftn() {
    var desc = new ActionDescriptor();
    var lref = new ActionReference();
    lref.putEnumerated(cTID("Lyr "), cTID("Ordn"), cTID("Trgt"));
    desc.putReference(cTID("null"), lref);
    desc.putEnumerated(cTID("FTcs"), cTID("QCSt"), cTID("Qcsa"));
    if (linked == true) {
      desc.putBoolean(cTID("Lnkd"), true );
    }

    var lvl = $.level;
    $.level = 0;
    try {
      executeAction(cTID("Trnf"), desc, DialogModes.ALL);
    } catch (e) {
      $.level = lvl;
      if (e.number != 8007) { // if not "User cancelled"
        throw e;
      }
    }
    $.level = lvl;
  }
  Stdlib.wrapLCLayer(doc, layer, _ftn);
};

// Based on code from SzopeN
Stdlib.transformScaleEx = function(doc, layer, linked) {
  function _ftn() {
    var state = true;
    function _moveDesc(dx, dy) {
      var desc = new ActionDescriptor();
      var lref = new ActionReference();
      lref.putEnumerated(cTID("Lyr "), cTID("Ordn"), cTID("Trgt"));

      desc.putReference(cTID("null"), lref);
      desc.putEnumerated(cTID("FTcs"), cTID("QCSt"), cTID("Qcsa"));
      var desc75 = new ActionDescriptor();
        desc75.putUnitDouble( cTID('Hrzn'), cTID('#Pxl'), dx );
        desc75.putUnitDouble( cTID('Vrtc'), cTID('#Pxl'), dy );
      desc.putObject( cTID('Ofst'), cTID('Ofst'), desc75 );
      return desc;
    }

    executeAction(cTID("Trnf"), _moveDesc(1, 1), DialogModes.NO);

    var desc = _moveDesc(-1, -1);
    var lvl = $.level;
    $.level = 0;
    try {
      executeAction(cTID("Trnf"), desc, DialogModes.ALL);

    } catch (e) {
      state = false;
      if (e.number != 8007) { // if not "User cancelled"
        throw e;
      }
      executeAction(cTID("Trnf"), desc, DialogModes.NO);
    } finally {
      $.level = lvl;
    }
    return state;
  }

  // true = OK, false = Cancel
  return Stdlib.wrapLCLayer(doc, layer, _ftn);
};


// Stdlib.transformLayer(doc, doc.activeLayer, Stdlib.getMaskBounds(doc, doc.activeLayer))

Stdlib.getLayerBounds = function(doc, layer) {
  var ru = app.preferences.rulerUnits;

  try {
    app.preferences.rulerUnits = Units.PIXELS;

    var reenable = false;
    var st;
    if (Stdlib.hasLayerMask(doc, layer) &&
        Stdlib.isLayerMaskEnabled(doc, layer)) {
      st = doc.activeHistoryState;
      Stdlib.disableLayerMask(doc, layer);
      reenable = true;
    }

    var lbnds = layer.bounds;

    // fix this to modify the history state
    if (reenable) {
      Stdlib.enableLayerMask(doc, layer);
    }
    for (var i = 0; i < 4; i++) {
      lbnds[i] = lbnds[i].value;
    }

  } finally {
    app.preferences.rulerUnits = ru;
  }

  return lbnds;
};

// Stdlib.getLayerBoundsNoEffects = function(doc, layer) {
//   return Stdlib.getLayerProperty(layer, sTID('boundsNoEffects'));
// };


// function ftn1() {
//   function cTID(s) { return app.charIDToTypeID(s); };
//   function sTID(s) { return app.stringIDToTypeID(s); };

//     var desc74 = new ActionDescriptor();
//     desc74.putEnumerated( cTID('FTcs'), cTID('QCSt'), cTID('Qcsa') );
//         var desc75 = new ActionDescriptor();
//         desc75.putUnitDouble( cTID('Hrzn'), cTID('#Pxl'), -2700.000000 );
//         desc75.putUnitDouble( cTID('Vrtc'), cTID('#Pxl'), -1350.000000 );
//     desc74.putObject( cTID('Ofst'), cTID('Ofst'), desc75 );
//     desc74.putUnitDouble( cTID('Wdth'), cTID('#Prc'), 18.181818 );
//     desc74.putUnitDouble( cTID('Hght'), cTID('#Prc'), 35.601266 );
//     executeAction( cTID('Trnf'), desc74, DialogModes.NO );
// };

Stdlib.transformLayer = function(doc, layer, bnds, orient) {
  var lbnds = Stdlib.getLayerBounds(doc, layer);

  var newW = bnds[2]-bnds[0];
  var newH = bnds[3]-bnds[1];
  var oldW = lbnds[2]-lbnds[0];
  var oldH = lbnds[3]-lbnds[1];

  var hrzn = bnds[0] - (lbnds[0] - (newW-oldW)/2);
  var vrtc = bnds[1] - (lbnds[1] - (newH-oldH)/2);

  var prc;
  var hprc;
  var vprc;

  if (!orient) {
    orient = 'both';
  }

  if (orient.toLowerCase() == 'horz') {
    vprc = hprc = (newW/oldW) * 100;
  } else if (orient == 'both') {
    hprc = (newW/oldW) * 100;
    vprc = (newH/oldH) * 100;
  } else {
    vprc = hprc = (newH/oldH) * 100;
  }

  function _ftn() {
    var desc = new ActionDescriptor();
    var ref = new ActionReference();
    ref.putEnumerated( cTID('Lyr '), cTID('Ordn'), cTID('Trgt') );
    desc.putReference( cTID('null'), ref );
    desc.putEnumerated( cTID('FTcs'), cTID('QCSt'), cTID('Qcsa') );
    var ldesc = new ActionDescriptor();
    ldesc.putUnitDouble( cTID('Hrzn'), cTID('#Pxl'), hrzn );
    ldesc.putUnitDouble( cTID('Vrtc'), cTID('#Pxl'), vrtc );
    desc.putObject( cTID('Ofst'), cTID('Ofst'), ldesc );
    desc.putUnitDouble( cTID('Wdth'), cTID('#Prc'), hprc );
    desc.putUnitDouble( cTID('Hght'), cTID('#Prc'), vprc );
//     desc.putUnitDouble( cTID('Angl'), cTID('#Ang'), angle );
    executeAction( cTID('Trnf'), desc, DialogModes.NO );
  };

  Stdlib.wrapLCLayer(doc, layer, _ftn);
};

Stdlib.rasterizeLayer = function(doc, layer) {
  function _ftn() {
    var desc = new ActionDescriptor();
    var ref = new ActionReference();
    ref.putEnumerated( cTID('Lyr '), cTID('Ordn'), cTID('Trgt') );
    desc.putReference( cTID('null'), ref );
    executeAction( sTID('rasterizeLayer'), desc, DialogModes.NO );
  };
  Stdlib.wrapLCLayer(doc, layer, _ftn);
};

// Stdlib.rotateLayer = function(doc, layer, angle) {
//   angle = Number(angle);
//   if (isNaN(angle)) {
//     Error.runtimeError(19, "angle");  // BadArgument
//   }
//   function _ftn() {
//     var desc = new ActionDescriptor();
//     var ref = new ActionReference();
//     ref.putEnumerated( cTID('Lyr '), cTID('Ordn'), cTID('Trgt') );
//     desc.putReference( cTID('null'), ref10 );
//     desc.putEnumerated( cTID('FTcs'), cTID('QCSt'), cTID('Qcsa') );
//     var ldesc = new ActionDescriptor();
//     ldesc.putUnitDouble( cTID('Hrzn'), cTID('#Pxl'), 0 );
//     ldesc.putUnitDouble( cTID('Vrtc'), cTID('#Pxl'), 0 );
//     desc.putObject( cTID('Ofst'), cTID('Ofst'), ldesc );
//     desc.putUnitDouble( cTID('Angl'), cTID('#Ang'), angle );
//     executeAction( cTID('Trnf'), desc, DialogModes.NO );
//   };

//   Stdlib.wrapLCLayer(doc, layer, _ftn);
// };


Stdlib.convertToLayer = function(doc, layer) {
  // layer.rasterize(RasterizeType.ENTIRELAYER);
  function _ftn() {
    var desc = new ActionDescriptor();
    var ref = new ActionReference();
    ref.putEnumerated(cTID('Lyr '), cTID('Ordn'), cTID('Trgt'));
    desc.putReference(cTID('null'), ref);
    desc.putEnumerated(cTID('What'), sTID('rasterizeItem'), sTID('placed'));
    executeAction(sTID('rasterizeLayer'), desc, DialogModes.NO);
  };
  Stdlib.wrapLCLayer(doc, layer, _ftn);
};

Stdlib.placeImage = function(doc, layer, file) {
  Stdlib.makeActive(doc);
  Stdlib.makeActive(layer);

  function _ftn() {
    var desc = new ActionDescriptor();
    desc.putPath( cTID('null'), file);
    desc.putEnumerated( cTID('FTcs'), cTID('QCSt'), cTID('Qcsa') );
        var ldesc = new ActionDescriptor();
        ldesc.putUnitDouble( cTID('Hrzn'), cTID('#Pxl'), 0.000000 );
        ldesc.putUnitDouble( cTID('Vrtc'), cTID('#Pxl'), 0.000000 );
    desc.putObject( cTID('Ofst'), cTID('Ofst'), ldesc );
    executeAction( cTID('Plc '), desc, DialogModes.NO );
  }

  _ftn();

  return doc.activeLayer;
};



// Stdlib.transformInteractive = function() {
//   var desc = new ActionDescriptor();
//   var ref = new ActionReference();
//   ref.putEnumerated( cTID('Lyr '), cTID('Ordn'), cTID('Trgt') );
//   desc.putReference( cTID('null'), ref );
//   desc.putEnumerated( cTID('FTcs'), cTID('QCSt'), cTID('Qcsa') );
//   desc.putBoolean( cTID('Lnkd'), true );
//   executeAction( cTID('Trnf'), desc, DialogModes.ALL );
// };


Stdlib.deleteAllHiddenLayers = function(doc) {
  function _ftn() {
    var ref = new ActionReference();
    ref.putEnumerated(cTID("Lyr "), cTID("Ordn"), sTID("hidden"));
    var dltDesc = new ActionDescriptor();
    dltDesc.putReference(cTID("null"), ref);
    executeAction(cTID("Dlt "), dltDesc, DialogModes.NO);
  }
  Stdlib.wrapLC(doc, _ftn);
};

Stdlib.hideAllLayers = function(doc) {
  var als = Stdlib.getLayersList(doc, false, true);
  for (var i = 0; i < als.length; i++) {
    als[i].visible = false;
  }
};
Stdlib.showAllLayers = function(doc) {
  var als = Stdlib.getLayersList(doc, false, true);
  for (var i = 0; i < als.length; i++) {
    als[i].visible = true;
  }
};


Stdlib.hideSelectedLayers = function(doc) {
  function _ftn() {
    var desc = new ActionDescriptor();
    var list = new ActionList();
    var ref = new ActionReference();
    ref.putEnumerated( cTID('Lyr '), cTID('Ordn'), cTID('Trgt') );
    list.putReference( ref );
    desc.putList( cTID('null'), list );
    executeAction( cTID('Hd  '), desc, DialogModes.NO );
  }
  Stdlib.wrapLC(doc, _ftn);
};
Stdlib.showSelectedLayers = function(doc) {
  function _ftn() {
    var desc = new ActionDescriptor();
    var list = new ActionList();
    var ref = new ActionReference();
    ref.putEnumerated( cTID('Lyr '), cTID('Ordn'), cTID('Trgt') );
    list.putReference( ref );
    desc.putList( cTID('null'), list );
    executeAction( cTID('Shw '), desc, DialogModes.NO );
  }
  Stdlib.wrapLC(doc, _ftn);
};

Stdlib.newGroupFromLayers = function(doc) {
  function _ftn() {
    var desc = new ActionDescriptor();
    var ref = new ActionReference();
    ref.putClass( sTID('layerSection') );
    desc.putReference( cTID('null'), ref );
    var lref = new ActionReference();
    lref.putEnumerated( cTID('Lyr '), cTID('Ordn'), cTID('Trgt') );
    desc.putReference( cTID('From'), lref);
    executeAction( cTID('Mk  '), desc, DialogModes.NO );
  };
  Stdlib.wrapLC(doc, _ftn);
  return doc.activeLayer;
};


Stdlib.ungroupLayers = function(doc, grp) {
  function _ftn() {
    var desc229 = new ActionDescriptor();
    var ref226 = new ActionReference();
    ref226.putEnumerated( cTID('Lyr '), cTID('Ordn'), cTID('Trgt') );
    desc229.putReference( cTID('null'), ref226 );
    executeAction( sTID('ungroupLayersEvent'), desc229, DialogModes.NO );
  }
  Stdlib.wrapLCLayer(doc, grp, _ftn);
};


Stdlib.deleteGroup = function(doc, grp, contents) {
  function _ftn() {
    var desc48 = new ActionDescriptor();
    var ref55 = new ActionReference();
    ref55.putEnumerated( cTID('Lyr '), cTID('Ordn'), cTID('Trgt') );
    desc48.putReference( cTID('null'), ref55 );
    desc48.putBoolean( sTID('deleteContained'), !!contents );
    executeAction( cTID('Dlt '), desc48, DialogModes.NO );
  };
  Stdlib.wrapLCLayer(doc, grp, _ftn);
};


Stdlib.getLayerNameByIndex = function(doc, idx) {
  var ref = new ActionReference();
  ref.putProperty(cTID("Prpr"), cTID( "Nm  " ));
  ref.putIndex(cTID( "Lyr " ), idx);
  return executeActionGet(ref).getString(cTID( "Nm  " ));
};
Stdlib.setLayerName = function(doc, idx, nm) {
  if (idx == 0) {
    return;
  }

  var desc = new ActionDescriptor();

  var ref = new ActionReference();
  ref.putIndex(cTID('Lyr '), idx);
  desc.putReference(cTID('null'), ref);

  var nmdesc = new ActionDescriptor();
  nmdesc.putString(cTID('Nm  '), nm);
  desc.putObject(cTID('T   '), cTID('Lyr '), nmdesc);

  if (isCS6()) {
    Stdlib.wrapLC(doc,
                  function() {
                    executeAction(cTID('setd'), desc, DialogModes.NO);
                  });
  } else {
    executeAction(cTID('setd'), desc, DialogModes.NO);
  }
};

Stdlib.getActiveLayerIndex = function(doc) {
  return Stdlib.getLayerIndex(doc, doc.activeLayer);
};
Stdlib.getActiveLayerDescriptor = function(doc) {
  function _ftn() {
    var ref = new ActionReference();
    ref.putEnumerated(cTID('Lyr '), cTID('Ordn'), cTID('Trgt'));
    return executeActionGet(ref);
  }
  return Stdlib.wrapLC(doc, _ftn);
};

Stdlib.getLayerIndex = function(doc, layer, dontWrap) {
  var idx = Stdlib.getLayerProperty(layer, 'ItmI');
  return Stdlib.hasBackground(doc) ? idx-1 : idx;
};


Stdlib.getLayerID = function(doc, layer) {
  var d = Stdlib.getLayerDescriptor(doc, layer);
  return d.getInteger(cTID('LyrI'));
};


//
// returns one of:
// sTID('layerSectionStart')     Start of a layer set
// sTID('layerSectionEnd')       End of a layer set
// sTID('layerSectionConent')  A content layer
//
Stdlib.getLayerType = function(doc, layer) {
  var idx = Stdlib.getLayerIndex(doc, layer);
  return Stdlib.getLayerTypeByIndex(doc, idx);
};
Stdlib.getLayerTypeByIndex = function(doc, idx) {
  var ref = new ActionReference();
  ref.putProperty(cTID("Prpr") , sTID("layerSection"));
  ref.putIndex(cTID( "Lyr " ), idx);
  return executeActionGet(ref).getEnumerationValue(sTID('layerSection'));
};

Stdlib.isLayerSelected = function(doc, layer) {
  var selLayers = Stdlib.getSelectedLayers(doc, true);
  return selLayers.contains(layer);
};

Stdlib.deleteSelectedLayers = function(doc) {
  function _ftn() {
    var desc = new ActionDescriptor();
    var ref = new ActionReference();
    ref.putEnumerated( cTID('Lyr '), cTID('Ordn'), cTID('Trgt') );
    desc.putReference( cTID('null'), ref );
    executeAction( cTID('Dlt '), desc, DialogModes.NO );
  };

  Stdlib.wrapLC(doc, _ftn);
};

// based on code by  pfaffenbichler, mike hale, via paul riggott
Stdlib.selectLayerByID = function(doc, id, append) {
  if (append = undefined) {
    append = false;
  }
  var ref = new ActionReference();
  ref.putIdentifier(charIDToTypeID("Lyr "), id);
  var desc = new ActionDescriptor();
  desc.putReference(charIDToTypeID("null"), ref );
  if (append) {
    desc.putEnumerated(sTID("selectionModifier"),
                       sTID("selectionModifierType"),
                       sTID("addToSelection"));
  }
  desc.putBoolean(cTID("MkVs"), false);
  executeAction(charIDToTypeID("slct"), desc, DialogModes.NO);
};

Stdlib.selectLayer = function(doc, layer, append) {
  if (isCS()) {
    doc.activeLayer = layer;

  } else {
    Stdlib.selectLayerByIndex(doc,
                              Stdlib.getLayerIndex(doc, layer, true),
                              append);
  }
};
Stdlib.selectLayers = function(doc, layers, append) {
  var idxs = [];
  var vis = [];
  var avis = doc.activeLayer.visible;
  var len = layers.length;
  for (var i = 0; i < len; i++) {
    var l = layers[i];
    vis[i] = l.visible;
    idxs.push(Stdlib.getLayerIndex(doc, l));
  }
  Stdlib.selectLayersByIndex(doc, idxs, append);
  for (var i = 0; i < len; i++) {
    layers[i].visible = vis[i];
  }
  doc.activeLayer.visible = avis;
};

Stdlib.selectLayerByName = function(doc, name) {
  var desc14 = new ActionDescriptor();
  var ref4 = new ActionReference();
  ref4.putName( cTID('Lyr '), name );
  desc14.putReference( cTID('null'), ref4 );
  desc14.putBoolean( cTID('MkVs'), false );
  executeAction( cTID('slct'), desc14, DialogModes.NO );
};


// 1-based indexing
Stdlib.selectLayerByIndex = function(doc, index, append) {
  if (append) {
    var desc = new ActionDescriptor();
    var ref = new ActionReference();
    ref.putIndex( cTID('Lyr '), index );
    desc.putReference( cTID('null'), ref );
    desc.putEnumerated( sTID('selectionModifier'),
                        sTID('selectionModifierType'),
                        sTID('addToSelection') );
    desc.putBoolean( cTID('MkVs'), false );
    executeAction( cTID('slct'), desc, DialogModes.NO );

  } else {
    var ref = new ActionReference();
    ref.putIndex(cTID("Lyr "), index);
    var desc = new ActionDescriptor();
    desc.putReference(cTID("null"), ref );
    executeAction(cTID("slct"), desc, DialogModes.NO );
  }
};
Stdlib.selectLayersByIndex = function(doc, idxs, append) {
  if (!idxs || idxs.length == 0) {
    return;
  }
  idxs = idxs.slice(0);
  if (append != true) {
    Stdlib.selectLayerByIndex(doc, idxs.pop());
  }

  while (idxs.length) {
    Stdlib.selectLayerByIndex(doc, idxs.pop(), true);
  }
};

Stdlib.deselectLayer = function(doc, layer) {
  if (isCS()) {
    return;
  }

  Stdlib.deselectLayerByIndex(doc, Stdlib.getLayerIndex(doc, layer, true));
};

Stdlib.deselectAllLayers = function(doc) {
  function _ftn() {
    var desc = new ActionDescriptor();
    var ref = new ActionReference();
    ref.putEnumerated(cTID('Lyr '), cTID('Ordn'), cTID('Trgt'));
    desc.putReference(cTID('null'), ref);
    executeAction(sTID('selectNoLayers'), desc, DialogModes.NO);
  }

  Stdlib.wrapLC(doc, _ftn);
};

Stdlib.selectAllLayers = function(doc) {
  function _ftn() {
    var desc18 = new ActionDescriptor();
    var ref11 = new ActionReference();
    ref11.putEnumerated( cTID('Lyr '), cTID('Ordn'), cTID('Trgt') );
    desc18.putReference( cTID('null'), ref11 );
    executeAction( sTID('selectAllLayers'), desc18, DialogModes.NO );
  }

  Stdlib.wrapLC(doc, _ftn);
};


Stdlib.deselectLayers = function(doc, layers) {
  if (isCS()) {
    return;
  }

  var idxs = [];
  var vis = [];
  var len = layers.length;
  for (var i = 0; i < len; i++) {
    var l = layers[i];
    vis[i] = l.visible;
    idxs.push(Stdlib.getLayerIndex(doc, l));
  }
  Stdlib.deselectLayersByIndex(doc, idxs);
};

Stdlib.deselectLayerByIndex = function(doc, index) {
  if (isCS()) {
    return;
  }
  var desc = new ActionDescriptor();
  var ref = new ActionReference();
  ref.putIndex(cTID('Lyr '), index);
  desc.putReference(cTID('null'), ref);
  desc.putEnumerated(sTID('selectionModifier'),
                     sTID('selectionModifierType'),
                     sTID('removeFromSelection'));
  desc.putBoolean(cTID('MkVs'), false);
  executeAction(cTID('slct'), desc, DialogModes.NO);
};
Stdlib.deselectLayersByIndex = function(doc, idxs) {
  if (isCS()) {
    return;
  }

  if (!idxs || idxs.length == 0) {
    return;
  }
  idxs = idxs.slice(0);

  while (idxs.length) {
    Stdlib.deselectLayerByIndex(doc, idxs.pop());
  }
};
Stdlib.deselectLayerByName = function(doc, name) {
  var desc151 = new ActionDescriptor();
  var ref122 = new ActionReference();
  ref122.putName( cTID('Lyr '), name );
  desc151.putReference( cTID('null'), ref122 );
  desc151.putEnumerated( sTID('selectionModifier'),
                         sTID('selectionModifierType'),
                         sTID('removeFromSelection') );
  desc151.putBoolean( cTID('MkVs'), false );
  executeAction( cTID('slct'), desc151, DialogModes.NO );
};


Stdlib.getLayerBoundsByIndex = function(doc, idx) {
  var desc = Stdlib.getLayerDescriptorByIndex(doc, idx);
  var bdesc = desc.getObjectValue(sTID('bounds'));

  var bnds = [];
  bnds.push(bdesc.getUnitDoubleValue(cTID('Left')));
  bnds.push(bdesc.getUnitDoubleValue(cTID('Top ')));
  bnds.push(bdesc.getUnitDoubleValue(cTID('Rght')));
  bnds.push(bdesc.getUnitDoubleValue(cTID('Btom')));
  return bnds;
};

Stdlib.getLayerOpacityByIndex = function(doc, idx) {
  var desc = Stdlib.getLayerDescriptorByIndex(doc, idx);
  return desc.getInteger(cTID('Opct'));
};


Stdlib.selectLayerByIdentifier = function(doc, id) {
  var ref = new ActionReference();
  ref.putIdentifier(cTID("Lyr "), id);
  var desc = new ActionDescriptor();
  desc.putReference(cTID("null"), ref );
  executeAction(cTID("slct"), desc, DialogModes.NO );
};

Stdlib.hasBG = function(doc) {
  try {
    var bgref = new ActionReference();
    bgref.putIndex(cTID("Lyr "), 0);
    executeActionGet(bgref);
    return true;
  } catch (e) {
    return false;
  }
}

// 1-based indexing...
Stdlib.getLayerDescriptorByIndex = function(doc, index) {
  var ref = new ActionReference();
  // assume that the index has already been adjusted
//   var hasBG = Stdlib.hasBackground(doc); // need something better here
//   if (hasBG) {
//     index--;
//   }

  ref.putIndex(cTID( "Lyr " ), index);
  return executeActionGet(ref);
};

Stdlib.getLayerDescriptor = function(doc, layer, dontWrap) {
  function _ftn() {
    var ref = new ActionReference();
    ref.putEnumerated(cTID("Lyr "), cTID("Ordn"), cTID("Trgt"));
    return executeActionGet(ref);
  };

  if (dontWrap) {
    Stdlib.makeActive(doc);
    Stdlib.makeActive(layer);
    return _ftn();
  } else {
    return Stdlib.wrapLCLayer(doc, layer, _ftn);
  }
};

// Stdlib.getVectorMaskDescriptor(doc, layer);
Stdlib.getVectorMaskDescriptor = function(doc, layer) {
  function _ftn() {
    var ref = new ActionReference();

    ref.putEnumerated( cTID('Path'), cTID('Ordn'), sTID('vectorMask'));
    try {
      return app.executeActionGet(ref);

    } catch (e) {
      return undefined;
    }
  };

  return Stdlib.wrapLCLayer(doc, layer, _ftn);
};

Stdlib.getPathDescriptor = function(doc, layer, name) {
  var totalPaths = doc.pathItems.length;
  var pathCount = 0;

  var pdesc;

  if (name == "WorkPath") {
    var ref = new ActionReference();
    ref.putProperty(cTID("Path"), cTID("WrPt"));
    pdesc = app.executeActionGet(ref);

  } else {
    for (var i = 1; i <= totalPaths; i++) {
      // try normal paths
      try {
        var ref = new ActionReference();
        ref.putIndex(cTID("Path"), i);
        var desc = app.executeActionGet(ref);

        var pname = desc.getString(cTID('PthN'));
        if (pname == name) {
          pdesc = desc;
          break;
        }

      } catch (e) {
        break;
      }
    }
  }

  return pdesc;
};

Stdlib.getLayerStyleDescriptor = function(doc, layer) {
  function _ftn() {
    var ref = new ActionReference();
    ref.putEnumerated(cTID("Lyr "), cTID("Ordn"), cTID("Trgt"));
    var ldesc = executeActionGet(ref);
    return ldesc.getObjectValue(sTID('layerEffects'));
  }

  return Stdlib.wrapLCLayer(doc, layer, _ftn);
};

//
// Select either the Transparency or Mask Channel
//    kind - "Trsp" or "Msk "
//
Stdlib.loadSelection = function(doc, layer, kind, invert) {
  function _ftn() {
    var desc = new ActionDescriptor();   // Set

    var cref = new ActionReference();    // Channel Selection
    cref.putProperty(cTID("Chnl"), cTID("fsel"));
    desc.putReference(cTID("null"), cref);

    var tref = new ActionReference(); // Channel Kind ("Trsp" or "Msk ")
    tref.putEnumerated(cTID("Chnl"), cTID("Chnl"), cTID(kind));
    desc.putReference(cTID("T   "), tref);
    if (invert == true) {
      desc.putBoolean(cTID("Invr"), true);
    }
    executeAction(cTID("setd"), desc, DialogModes.NO);
  }
  Stdlib.wrapLCLayer(doc, layer, _ftn);
};
Stdlib.selectTransparencyChannel = function(doc, layer, invert) {
  Stdlib.loadSelection(doc, layer, "Trsp", invert);
};
Stdlib.selectMaskChannel = function(doc, layer, invert) {
  Stdlib.loadSelection(doc, layer, "Msk ", invert);
};

Stdlib.saveNamedSelection = function(doc, layer, name) {
  function _ftn() {
    var desc47 = new ActionDescriptor();
    var ref33 = new ActionReference();
    ref33.putProperty( cTID('Chnl'), cTID('fsel') );
    desc47.putReference( cTID('null'), ref33 );
    desc47.putString( cTID('Nm  '), name);
    executeAction( cTID('Dplc'), desc47, DialogModes.NO );
  }

  Stdlib.wrapLCLayer(doc, layer, _ftn);
};

Stdlib.selectNamedSelection = function(doc, layer, name) {
  function _ftn() {
    var desc49 = new ActionDescriptor();
    var ref35 = new ActionReference();
    ref35.putName( cTID('Chnl'), name );
    desc49.putReference( cTID('null'), ref35 );
    executeAction( cTID('slct'), desc49, DialogModes.NO );
  }

  Stdlib.wrapLCLayer(doc, layer, _ftn);
};

Stdlib.loadNamedSelection = function(doc, layer, name, invert) {
  function _ftn() {
    var desc = new ActionDescriptor();   // Set

    var cref = new ActionReference();    // Channel Selection
    cref.putProperty(cTID("Chnl"), cTID("fsel"));
    desc.putReference(cTID("null"), cref);

    var tref = new ActionReference();
    tref.putName(cTID("Chnl"), name);
    desc.putReference(cTID("T   "), tref);
    if (invert == true) {
      desc.putBoolean(cTID("Invr"), true);
    }
    executeAction(cTID("setd"), desc, DialogModes.NO);
  }
  Stdlib.wrapLCLayer(doc, layer, _ftn);
};

Stdlib.deleteNamedSelection = function(doc, layer, name) {
  function _ftn() {
    Stdlib.selectNamedSelection(doc, layer, name);
    var desc43 = new ActionDescriptor();
    var ref29 = new ActionReference();
    ref29.putEnumerated( cTID('Chnl'), cTID('Ordn'), cTID('Trgt') );
    desc43.putReference( cTID('null'), ref29 );
    executeAction( cTID('Dlt '), desc43, DialogModes.NO );
  }
  Stdlib.wrapLCLayer(doc, layer, _ftn);
};


//
// From Mike Hale:
// After you use Stdlib (or scriptlistner) to load the transparency channel
// as a selection you will need to apply a threshold to the selection to
// remove the semi-transparent pixels from the selection.

// activeDocument.quickMaskMode = true;
//     var desc = new ActionDescriptor();
//     desc.putInteger( charIDToTypeID( "Lvl " ), 1 );
// executeAction( charIDToTypeID( "Thrs" ), desc, DialogModes.NO );
// activeDocument.quickMaskMode = false;
//

Stdlib.getMaskBounds = function(doc, layer) {
  function _ftn() {
    var st = doc.activeHistoryState;
    Stdlib.selectMaskChannel(doc, layer);
    var bnds = Stdlib.getSelectionBounds(doc);
    doc.activeHistoryState = st;
    return bnds;
  }

//   Stdlib.undo(doc);
//   //executeAction(cTID("undo"), new ActionDescriptor(), DialogModes.NO);

  var bnds = Stdlib.wrapLCLayer(doc, layer, _ftn);

  return bnds;
};

Stdlib.appendMaskToSelection = function(doc, layer) {
  function _ftn() {
    var desc93 = new ActionDescriptor();
    var ref68 = new ActionReference();
    ref68.putEnumerated( cTID('Chnl'), cTID('Chnl'), cTID('Msk ') );
    desc93.putReference( cTID('null'), ref68 );
    var ref69 = new ActionReference();
    ref69.putProperty( cTID('Chnl'), cTID('fsel') );
    desc93.putReference( cTID('T   '), ref69 );
    executeAction( cTID('Add '), desc93, DialogModes.NO );
  }

  Stdlib.wrapLCLayer(doc, layer, _ftn);
};

Stdlib.appendTransparencyToSelection = function(doc, layer) {
  function _ftn() {
    var desc90 = new ActionDescriptor();
    var ref64 = new ActionReference();
    ref64.putEnumerated( cTID('Chnl'), cTID('Chnl'), cTID('Trsp') );
    desc90.putReference( cTID('null'), ref64 );
    var ref65 = new ActionReference();
    ref65.putProperty( cTID('Chnl'), cTID('fsel') );
    desc90.putReference( cTID('T   '), ref65 );
    executeAction( cTID('Add '), desc90, DialogModes.NO );
  }

  Stdlib.wrapLCLayer(doc, layer, _ftn);
};

//
// link/unlink the image and mask
//
Stdlib.isLayerMaskLinked = function(doc, layer) {
  var desc = Stdlib.getLayerDescriptor(doc, layer);
  return (desc.hasKey(cTID("Usrs")) && desc.getBoolean(cTID("Usrs")));
};

Stdlib._linkMask = function(doc, layer, linkOn) {
  function _ftn() {
    var desc = new ActionDescriptor();

    var lref = new ActionReference();
    lref.putEnumerated(cTID("Lyr "), cTID("Ordn"), cTID("Trgt"));
    desc.putReference(cTID("null"), lref);

    var ldesc = new ActionDescriptor();
    ldesc.putBoolean(cTID("Usrs"), linkOn);

    desc.putObject(cTID("T   "), cTID("Lyr "), ldesc);
    executeAction(cTID("setd"), desc, DialogModes.NO);
  }

  Stdlib.wrapLCLayer(doc, layer, _ftn);
};
Stdlib.unlinkLayerMask = function(doc, layer) {
  Stdlib._linkMask(doc, layer, false);
};
Stdlib.unlinkMask = Stdlib.unlinkLayerMask;

Stdlib.linkLayerMask = function(doc, layer) {
  Stdlib._linkMask(doc, layer, true);
};
Stdlib.linkMask = Stdlib.linkLayerMask;

Stdlib.unlinkSelectedLayers = function(doc) {
  // Stdlib.doMenuItem(sTID("unlinkSelectedLayers"));
  var desc = new ActionDescriptor();
  var ref = new ActionReference();
  ref.putEnumerated( cTID('Lyr '), cTID('Ordn'), cTID('Trgt') );
  desc.putReference( cTID('null'), ref );
  executeAction( sTID('unlinkSelectedLayers'), desc, DialogModes.NO );
};
Stdlib.unlinkLayers = function(doc, layers) {
  var len = layers.length;
  for (var i = 0; i < len; i++) {
    var layer = layers[i];
    var v = layer.visibile;
    layer.unlink();
    layer.visibile = v;
  }
};
Stdlib.linkSelectedLayers = function(doc) {
  // Stdlib.doMenuItem(sTID("linkSelectedLayers"));

  var desc = new ActionDescriptor();
  var ref = new ActionReference();
  ref.putEnumerated( cTID('Lyr '), cTID('Ordn'), cTID('Trgt') );
  desc.putReference( cTID('null'), ref );
  executeAction( sTID('linkSelectedLayers'), desc, DialogModes.NO );
};
Stdlib.linkLayers = function(doc, layers) {
  var base = layers[0];
  base.unlink();
  var len = layers.length;
  for (var i = 1; i < len; i++) {
    var layer = layers[i];
    var v = layer.visible;
    layer.unlink();
    layer.link(base);
    layer.visible = v;
  }
};

Stdlib.selectLinkedLayers = function(doc) {
  function _ftn() {
    var ref = new ActionReference();
    ref.putEnumerated(cTID("Lyr "), cTID("Ordn"), cTID("Trgt"));
    var desc = new ActionDescriptor();
    executeAction(sTID("selectLinkedLayers"), desc, DialogModes.NO);
  }

  Stdlib.wrapLC(doc, _ftn);
};
Stdlib.getLinkedLayers = function(doc, layer) {
  var selLayers;
  selLayers = layer.linkedLayers.slice(0);

  if (selLayers.length > 0) {
    selLayers.unshift(layer);

    var layers = [];
    var allLayers = Stdlib.getLayersList(doc);
    for (var i = 0; i < allLayers.length; i++) {
      var l = allLayers[i];
      if (selLayers.contains(l)) {
        layers.push(l);
      }
    }
    selLayers = layers;

  } else {
    selLayers = [layer];
  }
  return selLayers;
};

Stdlib.getSelectedLayers = function(doc, layerSets) {
  var layers = Stdlib.getLayersList(doc, undefined, layerSets);
  var visible = [];
  var selLayers = [];

  var len = doc.layers.length;

  if (CSVersion() < 2) {
    return [ doc.activeLayer ];
  }

  if (len == 1 && Stdlib.hasBackgroundLayer(doc)) {
    return [ doc.backgroundLayer ];
  }

  // this split takes care of layer sets
  for (var i = 0; i < len; i++) {
    var l = layers[i];
    visible[i] = l.visible;
  }
  for (var i = 0; i < layers.length; i++) {
    var l = layers[i];
    l.visible = false;
  }
  Stdlib.showSelectedLayers(doc);
  for (var i = 0; i < layers.length; i++) {
    var l = layers[i];
    if (l.visible) {
      selLayers.push(l);
    }
    l.visible = visible[i];
  }
  
  return selLayers;

  /*
  // from a PR post. Not yet tested
  var selLayers = [];
  Stdlib.newGroupFromLayers(doc);
  var group = doc.activeLayer;
  var layers = group.layers;
  for (var i = 0; i < layers; i++) {
    selLayers.push(layers[i]);
  }

  Stdlib.Undo();
  */  
  return selLayers;
};

// Stdlib.insertImageIntoMask(doc, doc.activeLayer, "/c/tmp/1.jpg");

Stdlib.insertImageIntoMask = function(doc, layer, im, fit) {
  if (!Stdlib.hasLayerMask(doc, layer)) {
    Error.runtimeError(9001, "A Layer mask is required for this operation.");
  }

  Stdlib.selectMaskChannel(doc, layer);
  var ilayer = Stdlib.insertImageIntoSelection(doc, layer, im, fit);
  Stdlib.linkLayerMask(doc, ilayer);
  doc.selection.deselect();
  return ilayer;
};

Stdlib.insertImageIntoSelection = function(doc, layer, im, fit) {
  var imageDoc;
  var imageFile;

  if (im instanceof Document) {
    imageDoc = im;
  } else {
    imageFile = Stdlib.convertFptr(im);
  }

  if (fit == undefined) fit = true;

  if (!Stdlib.hasSelection(doc)) {
    Error.runtimeError(8152); // "A selection is required for this operation."
  }

  if (!imageDoc) {
    if (!imageFile.exists) {
      alert('Image ' + imageFile + ' does not exist.');
      return undefined;
    }
    imageDoc = app.open(imageFile);

  } else {
    app.activeDocument = imageDoc;
    imageDoc = imageDoc.duplicate();
  }

//   imageDoc.flatten();

  app.activeDocument = doc;

  var ru = app.preferences.rulerUnits;
  try {
    app.preferences.rulerUnits = Units.PIXELS;

    var lname = layer.name;

    // XXX app.activeDocument = doc;

    var bnds = Stdlib.getSelectionBounds(doc);

    // resize the image doc based on the selection bounds
    var width = bnds[2] - bnds[0];
    var height = bnds[3] - bnds[1];

    if (fit) {
      // change the res
      app.activeDocument = imageDoc;
      imageDoc.resizeImage(undefined, undefined, doc.resolution,
                           ResampleMethod.NONE);
      Stdlib.fitImage(imageDoc, width, height);

    } else {
      // fit to the shortest side (image will crop)
      var dwidth = imageDoc.width.value;
      var dheight = imageDoc.height.value;

      var ratio = height/width;
      var dratio = dheight/dwidth;

      if (dratio > ratio) {
        height = undefined;
      } else {
        width = undefined;
      }
      app.activeDocument = imageDoc;
      imageDoc.resizeImage(width, height, doc.resolution,
                           ResampleMethod.BICUBIC);
    }

    imageDoc.selection.selectAll();
    if (imageDoc.layers.length > 1) {
      imageDoc.selection.copy(true);
    } else {
      imageDoc.selection.copy();
    }

    app.activeDocument = doc;
    doc.activeLayer = layer;

    var hasStyles = Stdlib.hasLayerStyles(doc, layer);
    if (hasStyles) {
      Stdlib.copyStyles(doc);
    }

    if (!Stdlib.hasSelection(doc)) {
      Stdlib.selectBounds(doc, bnds);
    }

    Stdlib.pasteInto(doc);
    layer.remove();
    doc.activeLayer.name = lname;

    if (hasStyles) {
      Stdlib.pasteStyles(doc);
    }

  } catch (e) {
    layer = undefined;
    alert(Stdlib.exceptionMessage(e));

  } finally {
    app.preferences.rulerUnits = ru;
    try { imageDoc.close(SaveOptions.DONOTSAVECHANGES); } catch (e) {}
  }

  return doc.activeLayer;
};

//
// Added this because of a bug in CS5+ with layer.resize
// See JJMacks thread: https://forums.adobe.com/thread/1637626 
//
Stdlib.resizeLayer = function(doc, layer, horizontal, vertical, anchor) {
  if (!Stdlib.hasSelection(doc)) {
    layer.resize(horizontal, vertical, anchor);

  } else {
    var channel = doc.channels.add();
    var sel = doc.selection;
    selection.store(channel);
    sel.deselect();
    layer.resize(horizontal, vertical, anchor); // call with bug
    selection.load(channel);
    channel.remove();
  }
};

Stdlib.insertImageIntoSelectionAsSmartObject = function(doc, layer, im, fit) {
  app.activeDocument = doc;
  doc.activeLayer = layer;
  var imageFile = Stdlib.convertFptr(im);

  if (fit == undefined) fit = true;

  if (!Stdlib.hasSelection(doc)) {
    Error.runtimeError(8152); // "A selection is required for this operation."
  }

  if (!imageFile.exists) {
    Error.runtimeError(48); // 'Image ' + imageFile + ' does not exist.'
  }

  var ru = app.preferences.rulerUnits;
  var rez = doc.resolution;

  try {
    if (rez != 72) {
      doc.resizeImage(undefined, undefined, 72, ResampleMethod.NONE);
    }

    app.preferences.rulerUnits = Units.PIXELS;

    var hasStyles = Stdlib.hasLayerStyles(doc, layer);
    if (hasStyles) {
      Stdlib.copyStyles(doc, layer);
    }

    var lname = layer.name;

    var bnds = Stdlib.getSelectionBounds(doc);

    var imageLayer; // = doc.artLayers.add();
    imageLayer = Stdlib.placeImage(doc, layer, imageFile);
    Stdlib.resizeLayer(doc, layer, 100, 100, AnchorPosition.MIDDLECENTER);

    // resize the image doc based on the selection bounds
    var width = bnds[2] - bnds[0];
    var height = bnds[3] - bnds[1];

    var lbnds = Stdlib.getLayerBounds(doc, imageLayer);
    var lw = lbnds[2] - lbnds[0];
    var lh = lbnds[3] - lbnds[1];

    var ratio = height/width;
    var lratio = lh/lw;

    var orient;
    if (fit && (fit == true || fit.toString().toLowerCase() == 'fit')) {
      orient =  (lratio > ratio) ? 'vert' : 'horz';

    } else {
      orient =  (lratio > ratio) ? 'horz' : 'vert';
    }

    Stdlib.transformLayer(doc, imageLayer, bnds, orient);

    imageLayer.name = lname;

    layer.remove();

    if (hasStyles) {
      Stdlib.pasteStyles(doc);
    }
    // layer.remove();

  } catch (e) {
    alert(Stdlib.exceptionMessage(e));

  } finally {
    app.preferences.rulerUnits = ru;
    if (rez != 72) {
      doc.resizeImage(undefined, undefined, rez, ResampleMethod.NONE);
    }
  }

  return imageLayer;
};

Stdlib.resizeCanvas = function(doc, w, h, color, relative) {
  var hsb = color.hsb;
  var desc168 = new ActionDescriptor();
  if (toBoolean(relative)) {
    desc168.putBoolean(cTID('Rltv'), toBoolean(relative));
  }
  desc168.putUnitDouble( cTID('Wdth'), cTID('#Pxl'), w);
  desc168.putUnitDouble( cTID('Hght'), cTID('#Pxl'), h);
  desc168.putEnumerated( cTID('Hrzn'), cTID('HrzL'), cTID('Cntr') );
  desc168.putEnumerated( cTID('Vrtc'), cTID('VrtL'), cTID('Cntr') );
  if (color) {
    desc168.putEnumerated( sTID('canvasExtensionColorType'),
                           sTID('canvasExtensionColorType'),
                           cTID('Clr ') );
    var desc169 = new ActionDescriptor();
    desc169.putUnitDouble( cTID('H   '), cTID('#Ang'), hsb.hue );
    desc169.putDouble( cTID('Strt'), hsb.saturation );
    desc169.putDouble( cTID('Brgh'), hsb.brightness );
    desc168.putObject( sTID('canvasExtensionColor'), cTID('HSBC'), desc169 );
  }
  executeAction( cTID('CnvS'), desc168, DialogModes.NO );
};

_ResizeOptions = function() {
  var self = this;

  self.width = 1024;
  self.weight = 1024;
  self.constrain = true;
  self.scaleStyles = true;
  self.resample = true;
  self.resampleMethod = ResampleMethod.BICUBIC;
};

Stdlib._resizeImage = function(doc, opts) {

  //
  function _ftn() {
    // resample, constrain
    var desc71 = new ActionDescriptor();
    desc71.putUnitDouble( cTID('Wdth'), cTID('#Pxl'), opts.width);
    desc71.putBoolean( sTID('scaleStyles'), opts.scaleStyles );
    desc71.putBoolean( cTID('CnsP'), true );
    desc71.putEnumerated( cTID('Intr'), cTID('Intp'), cTID('Bcbc') );
    executeAction( cTID('ImgS'), desc71, DialogModes.NO );

    // no resample
    var id307 = charIDToTypeID( "ImgS" );
    var desc77 = new ActionDescriptor();
    var id308 = charIDToTypeID( "Wdth" );
    var id309 = charIDToTypeID( "#Rlt" );
    desc77.putUnitDouble( id308, id309, 477.217685 );
    executeAction( id307, desc77, DialogModes.NO );

    // resample, no constrain, no scale
    var desc84 = new ActionDescriptor();
    desc84.putUnitDouble( cTID('Wdth'), cTID('#Pxl'), 1024.000000 );
    desc84.putUnitDouble( cTID('Hght'), cTID('#Rlt'), 468.936026 );
    desc84.putEnumerated( cTID('Intr'), cTID('Intp'), cTID('Bcbc') );
    executeAction( cTID('ImgS'), desc84, DialogModes.NO );

  }

  Stdlib.wrapLC(doc, _ftn);
};

Stdlib.PSfitImage = function(width, height) {
  var desc = new ActionDescriptor();
  desc.putUnitDouble( cTID('Wdth'), cTID('#Pxl'), width );
  desc.putUnitDouble( cTID('Hght'), cTID('#Pxl'), height );

  var fitId = sTID('3caa3434-cb67-11d1-bc43-0060b0a13dc4');
  return executeAction(fitId , desc, DialogModes.NO );
};
Stdlib.fitImage = function(doc, width, height, resample) {
  Stdlib.resizeImage(doc, width, height, true, resample);
};

Stdlib.resizeImage = function(doc, width, height, constrained, resample) {
  function _ftn() {
    if (constrained == undefined) {
      constrained = true;
    }

    if (resample == undefined) {
      resample = ResampleMethod.BICUBIC;
    }

    var w = doc.width.value;
    var h = doc.height.value;
    var rez = doc.resolution;

    if (w == width && h == height) {
      return;
    }
    doc.resizeImage(undefined, undefined, 72, ResampleMethod.NONE);

    if (constrained) {
      var dratio = h/w;
      var ratio = height/width;

      if (dratio > ratio) {
        width = undefined;
      } else {
        height = undefined;
      }
    }

    doc.resizeImage(width, height, 72, resample);

    doc.resizeImage(undefined, undefined, rez, ResampleMethod.NONE);
  };

  var ru = app.preferences.rulerUnits;
  app.preferences.rulerUnits = Units.PIXELS;

  Stdlib.wrapLC(doc, _ftn);

  app.preferences.rulerUnits = ru;
};


//
//================================ Selections ===============================
//

//
// Crop on the current selection
//
Stdlib.crop = function(doc) {
  Stdlib.doEvent(doc, "Crop"); // "Crop";
};


Stdlib.cropBounds = function(doc, bnds) {
  Stdlib.selectBounds(doc, bnds);
  Stdlib.crop(doc);
  doc.selection.deselect();
};

//
// Do an interactive crop. Use the bounds specified or the current selection
// if no bounds are specified
//
Stdlib.interactiveCrop = function(doc, bnds) {
  var cropDesc = new ActionDescriptor();
  var toDesc = new ActionDescriptor();
  toDesc.putUnitDouble( cTID('Top '), cTID('#Pxl'), bnds[0] );
  toDesc.putUnitDouble( cTID('Left'), cTID('#Pxl'), bnds[1] );
  toDesc.putUnitDouble( cTID('Btom'), cTID('#Pxl'), bnds[2] );
  toDesc.putUnitDouble( cTID('Rght'), cTID('#Pxl'), bnds[3] );
  cropDesc.putObject( cTID('T   '), cTID('Rctn'), toDesc );
  cropDesc.putUnitDouble( cTID('Angl'), cTID('Ang '), 0.000000 );
  cropDesc.putUnitDouble( cTID('Wdth'), cTID('#Pxl'), 0.000000 );
  cropDesc.putUnitDouble( cTID('Hght'), cTID('#Pxl'), 0.000000 );
  cropDesc.putUnitDouble( cTID('Rslt'), cTID('#Rsl'), 0.000000 );

  try {
    executeAction( cTID('Crop'), cropDesc, DialogModes.ALL );
  } catch (e) {
    if (e.number != 8007) { // if not "User cancelled"
      throw e;
    }
    return false;
  }
  return true;
};

//
// Transform the current selection
//
Stdlib.transformSelection = function(doc) {
  var desc = new ActionDescriptor();
  var ref = new ActionReference();
  ref.putProperty(cTID("Chnl"), cTID("fsel"));
  desc.putReference(cTID("null"), ref);
  executeAction(cTID("Trnf"), desc, DialogModes.ALL);
};

// ????
Stdlib.freeTransformSelection = function(doc, layer) {
  function _ftn() {
    var desc = new ActionDescriptor();
    var ref = new ActionReference();
    ref.putEnumerated(cTID("Mn  "), cTID("MnIt"), cTID("FrTr"));
    desc.putReference(cTID("null"), ref);
    app.executeAction(cTID("slct"), desc, DialogModes.NO );
//     app.executeAction(cTID("FrTr"),
//                              new ActionDescriptor(),
//                              DialogModes.NO);
  }
  Stdlib.wrapLCLayer(doc, layer, _ftn);
};


Stdlib.magicWand = function(doc, x, y, tol, aa, cntg) {
  function _ftn() {
    var desc = new ActionDescriptor();

    // Selection
    var ref = new ActionReference();
    ref.putProperty(cTID("Chnl"), cTID("fsel"));
    desc.putReference(cTID("null"), ref);

    // Point
    var pdesc = new ActionDescriptor();
    pdesc.putUnitDouble(cTID("Hrzn"), cTID("#Pxl"), x);
    pdesc.putUnitDouble(cTID("Vrtc"), cTID("#Pxl"), y);
    desc.putObject(cTID("T   "), cTID("Pnt "), pdesc);

    // Tolerance
    if (tol != undefined) {
      desc.putInteger(cTID("Tlrn"), tol);
    }

    // Anti-alias
    desc.putBoolean(cTID("AntA"), !!aa);

    // Contiguous
    desc.putBoolean(cTID("Cntg"), !!cntg);

    executeAction(cTID("setd"), desc, DialogModes.NO);
  }

  Stdlib.wrapLC(doc, _ftn);
};

Stdlib.selectSimilar = function(doc, tol, aa) {
  function _ftn() {
    var desc = new ActionDescriptor();

    // Selection
    var ref = new ActionReference();
    ref.putProperty(cTID("Chnl"), cTID("fsel"));
    desc.putReference(cTID("null"), ref);

    // Tolerance
    if (tol != undefined) {
      desc.putInteger(cTID("Tlrn"), tol);
    }

    // Anti-alias - defaults to true
    desc.putBoolean(cTID("AntA"), aa != false);

    executeAction(cTID("Smlr"), desc, DialogModes.NO);
  }

  Stdlib.wrapLC(doc, _ftn);
};

Stdlib.selectBounds = function(doc, b, type, feather, antialias) {
  function _ftn () {
    doc.selection.select([[ b[0], b[1] ],
                          [ b[2], b[1] ],
                          [ b[2], b[3] ],
                          [ b[0], b[3] ]],
                         type, feather, antialias);
  }
  if (feather == undefined) {
    feather = 0;
  }
  if (antialias == undefined) {
    antialias = false;
  }
  Stdlib.wrapLC(doc, _ftn);
};

Stdlib.computeSelectionBoundsLS = function(doc) {
  var bnds = [];
  var ru = app.preferences.rulerUnits;
  app.preferences.rulerUnits = Units.PIXELS;

  var oldLayer = doc.activeLayer;
  try {
    var layerSetRef = doc.layerSets.add();
    var layerRef = layerSetRef.artLayers.add();
    doc.activeLayer = layerRef;
    doc.selection.fill( app.foregroundColor);
    bnds = layerSetRef.bounds;
    layerSetRef.remove();
  } finally {
    doc.activeLayer = oldLayer;
    app.preferences.rulerUnits = ru;
  }

  return bnds;
};

Stdlib.computeSelectionBounds = function(doc) {
  var bnds = [];

  var dbgLevel = $.level;
  try {
    $.level = 0;
    doc.selection.makeWorkPath();
  } catch (e) {
    $.level = dbgLevel;
    return bnds;
  }
  $.level = dbgLevel;

  try {
    var pis = doc.pathItems; // should be doc.pathItems.getByName("WorkPath");
    if (pis.length > 0) {
      for (var i = 0; i < pis.length; i++) {
        var spis = pis[i].subPathItems;
        for (var j = 0; j < spis.length; j++) {
          var pps = spis[j].pathPoints;
          for (var k = 0; k < pps.length; k++) {
            var anchor = pps[k].anchor;
            if (bnds.length == 0) {
              bnds[0] = bnds[2] = anchor[0];
              bnds[1] = bnds[3] = anchor[1];
            } else {
              if (anchor[0] < bnds[0]) {
                bnds[0] = anchor[0];
              } else if (anchor[0] > bnds[2]) {
                bnds[2] = anchor[0];
              }
              if (anchor[1] < bnds[1]) {
                bnds[1] = anchor[1];
              } else if (anchor[1] > bnds[3]) {
                bnds[3] = anchor[1];
              }
            }
          }
        }
      }
    }
  } finally {
    Stdlib.undo();
  }

  return bnds;
};

Stdlib.computeSelectionBoundsPS7 = function(doc) {
  var bnds = [];

  Stdlib.makeWorkPath(doc);

  try {
    var pis = Stdlib.getPathItems(doc);

    for (var i = 0; i < pis.count; i++) {
      var spis = pis.getObjectValue(i).getList(sTID("subpathListKey"));
      var pps = spis.getObjectValue(0).getList(sTID('points'));

      for (var j = 0; j < pps.count; j++) {
        var anchorObj = pps.getObjectValue(j).getObjectValue(sTID("anchor"));
        var anchor = [anchorObj.getUnitDoubleValue(sTID('horizontal')),
                      anchorObj.getUnitDoubleValue(sTID('vertical'))];
        if (bnds.length == 0) {
          bnds[0] = bnds[2] = anchor[0];
          bnds[1] = bnds[3] = anchor[1];
        } else {
          if (anchor[0] < bnds[0]) {
            bnds[0] = anchor[0];
          } else if (anchor[0] > bnds[2]) {
            bnds[2] = anchor[0];
          }
          if (anchor[1] < bnds[1]) {
            bnds[1] = anchor[1];
          } else if (anchor[1] > bnds[3]) {
            bnds[3] = anchor[1];
          }
        }
      }
    }
  } finally {
    Stdlib.undo();
  }

  return bnds;
};

Stdlib.getSelectionBounds = function(doc) {
  function _ftn() {

    if (CSVersion() > 2) {
      var bnds = doc.selection.bounds;
      for (var i = 0; i < bnds.length; i++) {
        bnds[i] = bnds[i].value;
      }
      return bnds;
    }

    var l = doc.artLayers.add();

    doc.selection.fill(app.foregroundColor);

    var bnds = l.bounds;
    var hs = doc.historyStates;

    if (hs[hs.length-2].name == "Layer Order") {
      doc.activeHistoryState = hs[hs.length-4];
    } else {
      doc.activeHistoryState = hs[hs.length-3];
    }

    for (var i = 0; i < bnds.length; i++) {
      bnds[i] = bnds[i].value;
    }
    return bnds;
  }

  return Stdlib.wrapLCLayer(doc, doc.activeLayer, _ftn);
};

// assumes that 0,0 is a background pixel
Stdlib.selectBackground = function(doc, layer) {
  Stdlib.hideAllLayers(doc);
  layer.visible = true;
  Stdlib.magicWand(doc, 0, 0);
  Stdlib.selectSimilar(doc);
  doc.selection.invert();
};


Stdlib.hasSelection = function(doc) {
  var res = false;

  if (CSVersion() > 2) {
    // Thanks to SzopeN for this
    // http://ps-scripts.com/bb/viewtopic.php?p=12118#12118
    var debugLevel = $.level;
    $.level = 0;

    try {
      doc.selection.bounds; // throws if there's no selection
      res = true;
    } catch(e) {
    }
    $.level = debugLevel;

  } else {
    var as = doc.activeHistoryState;
    doc.selection.deselect();
    if (as != doc.activeHistoryState) {
      res = true;
      doc.activeHistoryState = as;
    }
  }

  return res;
};

// This only returns one selected region. If the selection is disjoint,
// another function will have to be implemented
Stdlib.computeSelectionRegion = function(doc) {
  var bnds = [];

  var dbgLevel = $.level;
  try {
    $.level = 0;
    doc.selection.makeWorkPath();
  } catch (e) {
    $.level = dbgLevel;
    return bnds;
  }
  $.level = dbgLevel;

  try {
    var path = doc.pathItems["Work Path"];
    var subPathItems = path.subPathItems;

    for (var i = 0; i < subPathItems.length; i++) {
      var subPath = subPathItems[i];
      var points = subPath.pathPoints;
      for (var j = 0; j < points.length; j++) {
        var point = points[j];
        bnds.push(point.anchor);
      }
    }
  } finally {
    Stdlib.undo();
  }

  return bnds;
};

Stdlib.centerCanvasOnSelection = function(doc) {
  if (!Stdlib.hasSelection(doc)) {
    Error.runtimeError(8152); // "A selection is required for this operation."
  }

  var ru = app.preferences.rulerUnits;
  try {
    app.preferences.rulerUnits = Units.PIXELS;

    var bnds = Stdlib.getSelectionBounds(doc);
    var selX = (bnds[0]+bnds[2])/2;
    var selY = (bnds[1]+bnds[3])/2;

    var docX = doc.width.value/2;
    var docY = doc.height.value/2;

    doc.activeLayer.translate(docX-selX, docY-selY);
    doc.selection.translateBoundary(docX-selX, docY-selY);

  } finally {
    app.preferences.rulerUnits = ru;
  }
};

Stdlib.centerLayer = function(doc, layer) {
  var ru = app.preferences.rulerUnits;
  app.preferences.rulerUnits = Units.PIXELS;
  try {
    var bnds = Stdlib.getLayerBounds(doc, layer);
    var layerW = bnds[2]-bnds[0];
    var layerH = bnds[3]-bnds[1];
    var docW = doc.width.value;
    var docH = doc.height.value;
    var x = (docW/2) - (layerW/2);
    var y = (docH/2) - (layerH/2);
    var deltaX = x - bnds[0];
    var deltaY = y - bnds[1];

    layer.translate(deltaX, deltaY);

  } finally {
    app.preferences.rulerUnits = ru;
  }
};


//============================== Vector Mask ==========================

Stdlib._doVectorMask = function(doc, layer, prop, state) {
  function _ftn() {
    var desc = new ActionDescriptor();
    var ref = new ActionReference();
    ref.putEnumerated( cTID('Lyr '), cTID('Ordn'), cTID('Trgt') );
    desc.putReference( cTID('null'), ref );
    var desc54 = new ActionDescriptor();
    desc54.putBoolean( xTID(prop), state );
    desc.putObject( cTID('T   '), cTID('Lyr '), desc54 );
    executeAction( cTID('setd'), desc, DialogModes.NO );
  };

  return Stdlib.wrapLCLayer(doc, layer, _ftn);
};

Stdlib.disableVectorMask = function(doc, layer) {
  Stdlib._doVectorMask(doc, layer, 'vectorMaskEnabled', false );
};
Stdlib.enableVectorMask = function(doc, layer) {
  Stdlib._doVectorMask(doc, layer, 'vectorMaskEnabled', true);
};
Stdlib.unlinkVectorMask = function(doc, layer) {
  Stdlib._doVectorMask(doc, layer, 'vectorMaskLinked', false );
};
Stdlib.linkVectorMask = function(doc, layer) {
  Stdlib._doVectorMask(doc, layer, 'vectorMaskLinked', true );
};


Stdlib.removeVectorMask = function(doc, layer) {
  function _ftn() {
    var desc317 = new ActionDescriptor();
    var ref302 = new ActionReference();
    ref302.putEnumerated( cTID('Path'), cTID('Path'), sTID('vectorMask') );
    ref302.putEnumerated( cTID('Lyr '), cTID('Ordn'), cTID('Trgt') );
    desc317.putReference( cTID('null'), ref302 );
    executeAction( cTID('Dlt '), desc317, DialogModes.NO );
  };

  return Stdlib.wrapLCLayer(doc, layer, _ftn);
};




Stdlib.hasVectorMask = function(doc, layer) {
  // or check the layer 'hasVectorMask' property
  return Stdlib.getVectorMaskDescriptor(doc, layer) != undefined;
};

Stdlib.isVectorMaskEnabled = function(doc, layer) {
  var rc = false;

  if (Stdlib.hasVectorMask(doc, layer)) {
    try {
      var st = doc.activeHistoryState;
      Stdlib.enableVectorMask(doc, layer);
      if (doc.activeHistoryState == st) {
        rc = true;
      } else {
        doc.activeHistoryState = st;
      }
    } catch (e) {
    }
  }

  return rc;
};

Stdlib.rasterizeVectorMask = function(doc, layer) {
  function _ftn() {
    var desc = new ActionDescriptor();
    var ref = new ActionReference();
    ref.putEnumerated( cTID('Lyr '), cTID('Ordn'), cTID('Trgt') );
    desc.putReference( cTID('null'), ref );
    desc.putEnumerated( cTID('What'),
                        sTID('rasterizeItem'),
                        sTID('vectorMask') );
    executeAction( sTID('rasterizeLayer'), desc, DialogModes.NO );
  };

  return Stdlib.wrapLCLayer(doc, layer, _ftn);
};

Stdlib.selectVectorMask = function(doc, layer) {
  function _ftn() {
    var desc = new ActionDescriptor();
    var ref = new ActionReference();
    ref.putEnumerated(cTID('Path'), cTID('Path'), sTID('vectorMask'));
    ref.putEnumerated(cTID('Lyr '), cTID('Ordn'), cTID('Trgt'));
    desc.putReference(cTID('null'), ref);
    return executeAction(cTID('slct'), desc, DialogModes.NO);
  }
  return Stdlib.wrapLCLayer(doc, layer, _ftn);
};

Stdlib.deselectVectorMask = Stdlib.deselectActivePath;

Stdlib.loadVectorMaskSelection = function(doc, layer) {
  function _ftn() {
    var desc8 = new ActionDescriptor();
    var ref4 = new ActionReference();
    ref4.putProperty( cTID('Chnl'), cTID('fsel') );
    desc8.putReference( cTID('null'), ref4 );
    var ref5 = new ActionReference();
    ref5.putEnumerated( cTID('Path'), cTID('Path'), sTID('vectorMask') );
    ref5.putEnumerated( cTID('Lyr '), cTID('Ordn'), cTID('Trgt') );
    desc8.putReference( cTID('T   '), ref5 );
    desc8.putBoolean( cTID('AntA'), true );
    desc8.putUnitDouble( cTID('Fthr'), cTID('#Pxl'), 0.000000 );
    executeAction( cTID('setd'), desc8, DialogModes.NO );
  }
  return Stdlib.wrapLCLayer(doc, layer, _ftn);
};


Stdlib.rotateVectorMask = function(doc, layer, angle) {
  function _ftn() {
    var desc89 = new ActionDescriptor();
        var ref67 = new ActionReference();
        ref67.putEnumerated( cTID('Path'), cTID('Ordn'), cTID('Trgt') );
    desc89.putReference( cTID('null'), ref67 );
    desc89.putEnumerated( cTID('FTcs'), cTID('QCSt'), cTID('Qcsa') );
        var desc90 = new ActionDescriptor();
        desc90.putUnitDouble( cTID('Hrzn'), cTID('#Pxl'), -0.000000 );
        desc90.putUnitDouble( cTID('Vrtc'), cTID('#Pxl'), 0.000000 );
    desc89.putObject( cTID('Ofst'), cTID('Ofst'), desc90 );
    desc89.putUnitDouble( cTID('Angl'), cTID('#Ang'), angle );
    executeAction( cTID('Trnf'), desc89, DialogModes.NO );
  }
  return Stdlib.wrapLCLayer(doc, layer, _ftn);
};

Stdlib.selectionFromVectorMask = function(doc, layer, aa, feather) {
  if (!feather) {
    feather = 0.0;
  }
  aa = !!aa;
  function _ftn() {
    var desc = new ActionDescriptor();
    var selref = new ActionReference();
    selref.putProperty(cTID('Chnl'), cTID('fsel'));
    desc.putReference(cTID('null'), selref);
    var vmref = new ActionReference();
    vmref.putEnumerated(cTID('Path'), cTID('Path'), sTID('vectorMask'));
    vmref.putEnumerated(cTID('Lyr '), cTID('Ordn'), cTID('Trgt'));
    desc.putReference(cTID('T   '), vmref);
    desc.putBoolean(cTID('AntA'), aa);
    desc.putUnitDouble(cTID('Fthr'), cTID('#Pxl'), feather);
    executeAction(cTID('setd'), desc, DialogModes.NO);
  }
  return Stdlib.wrapLCLayer(doc, layer, _ftn);
};

Stdlib.appendVectorMaskToSelection = function(doc, layer) {
  function _ftn() {
    var desc31 = new ActionDescriptor();
        var ref25 = new ActionReference();
        ref25.putProperty( cTID('Chnl'), cTID('fsel') );
    desc31.putReference( cTID('null'), ref25 );
        var ref26 = new ActionReference();
        ref26.putEnumerated( cTID('Path'), cTID('Path'), sTID('vectorMask') );
        ref26.putEnumerated( cTID('Lyr '), cTID('Ordn'), cTID('Trgt') );
    desc31.putReference( cTID('T   '), ref26 );
    desc31.putBoolean( cTID('AntA'), true );
    desc31.putUnitDouble( cTID('Fthr'), cTID('#Pxl'), 0.000000 );
    executeAction( cTID('AddT'), desc31, DialogModes.NO );
  }

  Stdlib.wrapLCLayer(doc, layer, _ftn);
};

Stdlib.getVectorMaskBounds = function(doc, layer) {
  function _ftn() {
    var st = doc.activeHistoryState;
    Stdlib.selectionFromVectorMask(doc, layer);
    var bnds = Stdlib.getSelectionBounds(doc);
    doc.activeHistoryState = st;
    return bnds;
  }

//   Stdlib.undo(doc);
//   //executeAction(cTID("undo"), new ActionDescriptor(), DialogModes.NO);

  var bnds = Stdlib.wrapLCLayer(doc, layer, _ftn);

  return bnds;
};

// by Damian SzopeN Sepczuk <damian[d0t]sepczuk[a7]o2{do7}pl>
// [in] round (bool) -- whether returned values should be rounded
//                      to the nearest pixel, def: false
// [in] doc -- document containing layer with vector mask
// [in] layer -- layer with vector mask
// returns array [left, top, right, bottom, width, height]
Stdlib.getVectorMaskBounds_cornerPointsOnly = function(round, doc, layer) {
  round = !!round;
  function _ftn() {
    var res = undefined;
    var ref = new ActionReference();
    ref.putEnumerated( cTID('Path'), cTID('Path'), sTID('vectorMask') );
    ref.putEnumerated(cTID("Lyr "), cTID("Ordn"), cTID("Trgt"));
    var vMaskDescr = executeActionGet(ref);
    var pathContents = vMaskDescr.getObjectValue(sTID('pathContents'));
    var pathList = pathContents.getList(sTID('pathComponents'));

    // for each path in current layer
    var minX = Infinity, maxX = -Infinity, minY = Infinity, maxY = -Infinity;
    // using separate variables gives speed gain
    var subpathListKey = sTID("subpathListKey"),
        points_key = sTID("points"),
        anchor_key = sTID("anchor"),
        horizontal_key = sTID('horizontal'),
        vertical_key = sTID('vertical');

    for (var cPath = 0; cPath < pathList.count; ++cPath) {
      var curPath = pathList.getObjectValue(cPath).getList(subpathListKey);
      var points = curPath.getObjectValue(0).getList(points_key);
      // for each point
      for (var cPoint = 0; cPoint < points.count; ++cPoint) {
        var point = points.getObjectValue(cPoint).getObjectValue(anchor_key);
        var x = point.getUnitDoubleValue(horizontal_key);
        var y = point.getUnitDoubleValue(_id5);
        // it is faster than if/else block (benchmarked on PSCS4)
        if ( x < minX ) minX = x;
        if ( x > maxX ) maxX = x;
        if ( y < minY ) minY = y;
        if ( y > maxY ) maxY = y;
      }
    }
    res = [minX, minY, maxX, maxY, maxX-minX, maxY-minY];
    if (round) {
      for (var i = 0; i < res.length; ++i)  {
        res[i] = Math.round(res[i]);
      }
    }
    return res;
  }
  var bnds = Stdlib.wrapLCLayer(doc, layer, _ftn);
  return bnds;
};

// by Damian SzopeN Sepczuk <damian[d0t]sepczuk[a7]o2{do7}pl>
Stdlib.getVectorMaskAngle_cornerPointsOnly = function(round, doc, layer) {
  round = !!round;
  function _ftn() {
    var ref = new ActionReference();
    ref.putEnumerated( cTID('Path'), cTID('Path'), sTID('vectorMask') );
    ref.putEnumerated(cTID("Lyr "), cTID("Ordn"), cTID("Trgt"));
    var vMaskDescr = executeActionGet(ref);
    var pathContents = vMaskDescr.getObjectValue(sTID('pathContents'));
    var pathList = pathContents.getList(sTID('pathComponents'));

    // using separate variables gives speed gain
    var _id3 = sTID("anchor"),
        _id4 = sTID('horizontal'),
        _id5 = sTID('vertical');

    var cPath=0;
    var curPath = pathList.getObjectValue(cPath).getList(sTID("subpathListKey"));
    var points = curPath.getObjectValue(0).getList(sTID("points"));

    var p1  = points.getObjectValue(0).getObjectValue(_id3),
         p1x = p1.getUnitDoubleValue(_id4),
         p1y = p1.getUnitDoubleValue(_id5),
         p2  = points.getObjectValue(1).getObjectValue(_id3),
         p2x = p2.getUnitDoubleValue(_id4),
         p2y = p2.getUnitDoubleValue(_id5);

     var v = [p2x-p1x, p2y-p1y];
     var v_len = Math.sqrt(v[0]*v[0]+v[1]*v[1]);
     var an = Math.acos(v[1]/v_len);
    var res = 90.0-an*180.0/Math.PI;
    if (p1x>p2x) res=-res;
    if (!round)
    {
        res = Math.round(res*100)/100;
    }
    return res;
  }
  return Stdlib.wrapLCLayer(doc, layer, _ftn);
};


Stdlib.createSolidFillLayer = function(doc, color) {
  if (!color) {
    color = Stdlib.createRGBColor(0, 0, 0);
  }
  function _ftn() {
    var desc = new ActionDescriptor();
    var clref = new ActionReference();
    clref.putClass(sTID('contentLayer'));
    desc.putReference(cTID('null'), clref);
    var tdesc = new ActionDescriptor();
    var scldesc = new ActionDescriptor();
    var rgbdesc = new ActionDescriptor();
    rgbdesc.putDouble(cTID('Rd  '), color.rgb.red);
    rgbdesc.putDouble(cTID('Grn '), color.rgb.green);
    rgbdesc.putDouble(cTID('Bl  '), color.rgb.blue);
    scldesc.putObject(cTID('Clr '), cTID('RGBC'), rgbdesc);
    tdesc.putObject(cTID('Type'), sTID('solidColorLayer'), scldesc);
    desc.putObject(cTID('Usng'), sTID('contentLayer'), tdesc);
    executeAction(cTID('Mk  '), desc, DialogModes.NO);
  }
  Stdlib.wrapLC(doc, _ftn);
  return doc.activeLayer;
};

Stdlib.createVectorMaskFromCurrentPath = function(doc, layer) {
  function _ftn(doc) {
    var desc = new ActionDescriptor();
    var ref135 = new ActionReference();
    ref135.putClass( cTID('Path') );
    desc.putReference( cTID('null'), ref135 );
    var ref136 = new ActionReference();
    ref136.putEnumerated( cTID('Path'), cTID('Path'), sTID('vectorMask') );
    desc.putReference( cTID('At  '), ref136 );
    var ref137 = new ActionReference();
    ref137.putEnumerated( cTID('Path'), cTID('Ordn'), cTID('Trgt') );
    desc.putReference( cTID('Usng'), ref137 );
    executeAction( cTID('Mk  '), desc, DialogModes.NO );
  };

  Stdlib.wrapLC(doc, _ftn);
};

Stdlib.saveVectorMaskAsPath = function(doc, layer, name) {
  function _ftn() {
    function cTID(s) { return app.charIDToTypeID(s); };
    function sTID(s) { return app.stringIDToTypeID(s); };

    var desc107 = new ActionDescriptor();
    var ref65 = new ActionReference();
    ref65.putClass( cTID('Path') );
    desc107.putReference( cTID('null'), ref65 );
    var ref66 = new ActionReference();
    ref66.putEnumerated( cTID('Path'), cTID('Path'), sTID('vectorMask') );
    ref66.putEnumerated( cTID('Lyr '), cTID('Ordn'), cTID('Trgt') );
    desc107.putReference( cTID('From'), ref66 );
    desc107.putString( cTID('Nm  '), name);
    executeAction( cTID('Mk  '), desc107, DialogModes.NO );
  };

  Stdlib.wrapLCLayer(doc, layer, _ftn);
  return doc.pathItems.getByName(name);
};



//
//================================ Paths ===============================
//
// PS7 doesn't have one of these so we provide one here...
//
Stdlib.makeWorkPath = function(doc, tolerance) {
  function _ftn(doc) {
    var desc = new ActionDescriptor();

    var pref = new ActionReference();
    pref.putClass(cTID("Path"));
    desc.putReference(cTID("null"), pref );

    var sref = new ActionReference();
    sref.putProperty( cTID("csel"), cTID("fsel"));
    desc.putReference(cTID("From"), sref );

    desc.putUnitDouble(cTID("Tlrn"), cTID("#Pxl"), Stdlib.makeWorkPath.tolerance);

    executeAction(cTID("Mk  "), desc, DialogModes.NO);
  }

  Stdlib.makeWorkPath.tolerance = (tolerance != undefined) ? tolerance : 2.0;

  Stdlib.wrapLC(doc, _ftn);
};

Stdlib.makePathActive = function(doc, pathName) {
  function _ftn() {
    var desc91 = new ActionDescriptor();
    var ref82 = new ActionReference();
    ref82.putName( cTID('Path'), pathName );
    desc91.putReference( cTID('null'), ref82 );
    executeAction( cTID('slct'), desc91, DialogModes.NO );
  };

  Stdlib.wrapLC(doc, _ftn);
};

Stdlib.makeSelectionFromPath = function(doc, pathName) {
  function _ftn() {
    var desc89 = new ActionDescriptor();
    var ref79 = new ActionReference();
    ref79.putProperty( cTID('Chnl'), cTID('fsel') );
    desc89.putReference( cTID('null'), ref79 );
    var ref80 = new ActionReference();
    ref80.putEnumerated( cTID('Path'), cTID('Ordn'), cTID('Trgt') );
    desc89.putReference( cTID('T   '), ref80 );
    desc89.putBoolean( cTID('AntA'), true );
    desc89.putUnitDouble( cTID('Fthr'), cTID('#Pxl'), 0.000000 );
    executeAction( cTID('setd'), desc89, DialogModes.NO );
  };

  Stdlib.makePathActive(doc, pathName);
  Stdlib.wrapLC(doc, _ftn);
};


// if (!Selection.prototype.makeWorkPath) {
// Selection.prototype.makeWorkPath = function(tol) {
//   Stdlib.makeWorkPath(this, tol);
// };
// }

Stdlib.getPathItems = function(doc) {
  function _ftn() {
    var ref = new ActionReference();
    ref.putEnumerated(sTID('path'), sTID('ordinal'), sTID('targetEnum'));
    var pathObj = executeActionGet(ref);
    var pathContents = pathObj.getObjectValue(sTID('pathContents'));
    return pathContents.getList(sTID('pathComponents'));
  }
  return Stdlib.wrapLC(doc, _ftn);
};

//
// deselect the active path. just a piece of UI fluff
//
Stdlib.deselectActivePath = function(doc) {
  function _ftn() {
    var ref = new ActionReference();
    ref.putClass(cTID("Path"));

    var desc = new ActionDescriptor();
    desc.putReference(cTID("null"), ref);
    executeAction( cTID( "Dslc" ), desc, DialogModes.NO );
  };
  Stdlib.wrapLC(doc, _ftn);
};

// by SzopeN
Stdlib.decodePathMode = function( mode ) {
    var pathMode = null;
    switch ( mode ) {
        case ShapeOperation.SHAPEADD:
            pathMode = cTID("AddT");
            break;
        case ShapeOperation.SHAPEINTERSECT:
            pathMode = cTID();
            break;
        case ShapeOperation.SHAPESUBTRACT:
            pathMode = cTID("SbtF");
            break;
        case ShapeOperation.SHAPEXOR:
            pathMode = cTID();
            break;
        default:
            Error.runtimeError(1, "Shape mode not supported");
    }
    return pathMode;
}

// by SzopeN
Stdlib.decodePathUnit = function( unit ) {
    var pathUnit = null;
    switch ( unit ) {
        case Units.PERCENT:
            pathUnit = cTID("#Prc");
            break;
        case Units.PIXELS:
            pathUnit = cTID("#Pxl");
            break;
        case Units.CM:
        case Units.INCHES:
        case Units.MM:
        case Units.PICAS:
        case Units.POINTS:
        default:
            Error.runtimeError(1, "Unit not supported");
    }
    return pathUnit;
}


// by SzopeN
Stdlib.rectPath = function( mode, unit, top, left, bottom, right )
{
    var pathMode = Stdlib.decodePathMode(mode);
    var pathUnit = Stdlib.decodePathUnit(unit);

    var desc = new ActionDescriptor();

    var arStyle = new ActionReference();
        arStyle.putEnumerated( cTID( "Path" ), cTID( "Ordn" ), cTID( "Trgt" ) );

    var adBounds = new ActionDescriptor();
        adBounds.putUnitDouble( cTID( "Top " ), pathUnit, top );
        adBounds.putUnitDouble( cTID( "Left" ), pathUnit, left );
        adBounds.putUnitDouble( cTID( "Btom" ), pathUnit, bottom );
        adBounds.putUnitDouble( cTID( "Rght" ), pathUnit, right );

    desc.putReference( cTID( "null" ), arStyle );
    desc.putObject( cTID( "T   " ), cTID( "Rctn" ), adBounds );

    executeAction( pathMode, desc, DialogModes.NO );
}

// by SzopeN
Stdlib.linePath = function( mode, unit, width, x1, y1, x2, y2 ) {
    var pathMode = Stdlib.decodePathMode(mode);
    var pathUnit = Stdlib.decodePathUnit(unit);

    var idAddT = pathMode;
        var desc90 = new ActionDescriptor();
        var idnull = cTID( "null" );
            var ref47 = new ActionReference();
            var idPath = cTID( "Path" );
            var idOrdn = cTID( "Ordn" );
            var idTrgt = cTID( "Trgt" );
            ref47.putEnumerated( idPath, idOrdn, idTrgt );
        desc90.putReference( idnull, ref47 );
        var idT = cTID( "T   " );
            var desc91 = new ActionDescriptor();
            var idStrt = cTID( "Strt" );
                var desc92 = new ActionDescriptor();
                var idHrzn = cTID( "Hrzn" );
                var idPxl = pathUnit;
                desc92.putUnitDouble( idHrzn, idPxl, x1 );
                var idVrtc = cTID( "Vrtc" );
                var idPxl = pathUnit;
                desc92.putUnitDouble( idVrtc, idPxl, y1 );
            var idPnt = cTID( "Pnt " );
            desc91.putObject( idStrt, idPnt, desc92 );
            var idEnd = cTID( "End " );
                var desc93 = new ActionDescriptor();
                var idHrzn = cTID( "Hrzn" );
                var idPxl = pathUnit;
                desc93.putUnitDouble( idHrzn, idPxl, x2 );
                var idVrtc = cTID( "Vrtc" );
                var idPxl = pathUnit;
                desc93.putUnitDouble( idVrtc, idPxl, y2 );
            var idPnt = cTID( "Pnt " );
            desc91.putObject( idEnd, idPnt, desc93 );
            var idWdth = cTID( "Wdth" );
            var idPxl = pathUnit;
            desc91.putUnitDouble( idWdth, idPxl, width );
        var idLn = cTID( "Ln  " );
        desc90.putObject( idT, idLn, desc91 );
    executeAction( idAddT, desc90, DialogModes.NO );
};

// by SzopeN
Stdlib.flipPath = function(h, v) {
  var idTrnf = cTID( "Trnf" );
  var desc108 = new ActionDescriptor();
  var ref101 = new ActionReference();
  ref101.putEnumerated( cTID( "Path" ), cTID( "Ordn" ), cTID( "Trgt" ));
  desc108.putReference(  cTID( "null" ), ref101 );
  desc108.putEnumerated( cTID( "FTcs" ), cTID( "QCSt" ), cTID( "Qcsa" ) );
  if (h) desc108.putUnitDouble( cTID( "Wdth" ), cTID( "#Prc" ), -100.000000 );
  if (v) desc108.putUnitDouble( cTID( "Hght" ), cTID( "#Prc" ), -100.000000 );
  executeAction( idTrnf, desc108, DialogModes.NO );
};

// by SzopeN
Stdlib.createPathPoint = function(point, lHandle, rHandle) {
  var kind = (lHandle || rHandle)?PointKind.SMOOTHPOINT:PointKind.CORNERPOINT;
  if (!lHandle) lHandle = point;
  if (!rHandle) rHandle = point;

  var o = new PathPointInfo();
  /*o.anchor = [new UnitValue(point[0],'px'),new UnitValue(point[1],'px')];
   o.leftDirection = [new UnitValue(lHandle[0],'px'),new UnitValue(lHandle[1],'px')];
   o.rightDirection = [new UnitValue(rHandle[0],'px'),new UnitValue(rHandle[1],'px')];*/
  o.anchor = point;
  o.leftDirection = lHandle;
  o.rightDirection = rHandle;
  o.kind = kind;
  return o;
};



//
//================================= Actions ==================================
//
// attempt to execute an action. return true if OK, false if not available
// re-throws unknown exceptions.
//
Stdlib.runAction = function(atn, atnSet) {
  try {
    app.doAction(atn, atnSet);
  } catch (e) {
    if (e.toString().match(/action.+is not currently available/)) {
      return false;
    } else {
      throw e;
    }
  }
  return true;
};
runAction = Stdlib.runAction;

Stdlib.hasAction = function(atn, atnSet) {
  var asetDesc;
  var rc = false;
  var i = 1;

  var asMatches = [];

  while (true) {
    var ref = new ActionReference();
    ref.putIndex(cTID("ASet"), i);
    var desc;
    try {
      desc = executeActionGet(ref);
    } catch (e) {
      break;    // all done
    }
    if (desc.hasKey(cTID("Nm  ")) &&
        desc.getString(cTID("Nm  ")) == atnSet) {
      asetDesc = desc;
      asMatches.push({ index: i, desc: desc});
      //break;
    }
    i++;
  }

  if (asMatches.length == 0) {
    return false;
  }

  for (var i = 0; i < asMatches.length; i++) {
    var asmatch = asMatches[i];
    var asetIndex = asmatch.index;
    asetDesc = asmatch.desc;

    if (!asetDesc.hasKey(cTID("NmbC"))) {
      continue;
    }
    var max = asetDesc.getInteger(cTID("NmbC"));
    for (var j = 1; j <= max; j++) {
      var ref = new ActionReference();
      ref.putIndex(cTID("Actn"), j);           // Action index
      ref.putIndex(cTID("ASet"), asetIndex);   // ActionSet index

      var desc;
      try {
        desc = executeActionGet(ref);
      } catch (e) {
        break;   // all done
      }
      if (desc.hasKey(cTID("Nm  ")) &&
          desc.getString(cTID("Nm  ")) == atn) {
        return true;
      }
    }
  }
  return rc;
};

Stdlib.deleteActionStep = function(index, atn, atnSet) {
  function _ftn() {
    var desc = new ActionDescriptor();
    var ref = new ActionReference();
    ref.putIndex(cTID("Cmnd"), index);
    ref.putName(cTID("Actn"), atn);
    ref.putName(cTID("ASet"), atnSet);
    desc.putReference(cTID("null"), ref);
    executeAction(cTID("Dlt "), desc, DialogModes.NO);
  }

  _ftn();
};
Stdlib.deleteAction = function(atn, atnSet) {
  function _ftn() {
    var desc = new ActionDescriptor();
    var ref = new ActionReference();
    ref.putName(cTID("Actn"), atn);
    ref.putName(cTID("ASet"), atnSet);
    desc.putReference(cTID("null"), ref);
    executeAction(cTID("Dlt "), desc, DialogModes.NO);
  }

  _ftn();
};
Stdlib.deleteActionSet = function(atnSet) {
  function _ftn() {
    var desc = new ActionDescriptor();
    var ref = new ActionReference();
    ref.putName(cTID("ASet"), atnSet);
    desc.putReference(cTID("null"), ref);
    executeAction(cTID("Dlt "), desc, DialogModes.NO);
  }

  try {
    _ftn();
  } catch (e) {
    // if this action is the currently executing action,
    // we can't delete it, so we return false. All other
    // exceptions are rethrown
    if (!e.toString().match(/action that is playing or recording/)) {
      throw e;
    }
    return false;
  }
  return true;
};


Stdlib.createDroplet = function(atn, atnSet, fptr) {
  fptr = Stdlib.convertFptr(fptr);

  function _ftn() {
    var desc = new ActionDescriptor();
    desc.putPath(cTID('In  '), fptr);
    var ref = new ActionReference();
    ref.putName(cTID('Actn'), atn);
    ref.putName(cTID('ASet'), atnSet);
    desc.putReference(cTID('Usng'), ref);
    executeAction(cTID('CrtD'), desc, DialogModes.NO);
  }

  _ftn();
};


//
//  f = File.openDialog(); Stdlib.loadActionFile(f);
//
Stdlib.loadActionFile = function(file) {
  Stdlib.btExec('app.load(new File("' + file.absoluteURI + '"));');
};

//
// Stdlib.loadActionFiles(folder.getFiles("*.atn"))'
//
Stdlib.loadActionFiles = function(files) {
  var str = '';

  for (var i = 0; i < files.length; i++) {
    var file = files[0];
    str += 'app.load(new File("' + file.absoluteURI + '"));\n';
  }
  Stdlib.btExec(str);
};

Stdlib.getActionSets = function() {
  var i = 1;
  var sets = [];

  while (true) {
    var ref = new ActionReference();
    ref.putIndex(cTID("ASet"), i);
    var desc;
    var lvl = $.level;
    $.level = 0;
    try {
      desc = executeActionGet(ref);
    } catch (e) {
      break;    // all done
    } finally {
      $.level = lvl;
    }
    if (desc.hasKey(cTID("Nm  "))) {
      var set = {};
      set.index = i;
      set.name = desc.getString(cTID("Nm  "));
      set.toString = function() { return this.name; };
      set.count = desc.getInteger(cTID("NmbC"));
      set.actions = [];
      for (var j = 1; j <= set.count; j++) {
        var ref = new ActionReference();
        ref.putIndex(cTID('Actn'), j);
        ref.putIndex(cTID('ASet'), set.index);
        var adesc = executeActionGet(ref);
        var actName = adesc.getString(cTID('Nm  '));
        set.actions.push(actName);
      }
      sets.push(set);
    }
    i++;
  }

  return sets;
};

Stdlib.getActions = function(aset) {
  var i = 1;
  var names = [];

  if (!aset) {
    throw Error.runtimeError(9001, "Action set must be specified");
  }

  while (true) {
    var ref = new ActionReference();
    ref.putIndex(cTID("ASet"), i);
    var desc;
    try {
      desc = executeActionGet(ref);
    } catch (e) {
      names = undefined;
      break;    // all done
    }
    if (desc.hasKey(cTID("Nm  "))) {
      var aname = desc.getString(cTID("Nm  "));
      if (aname == aset) {
        var count = desc.getInteger(cTID("NmbC"));
        for (var j = 1; j <= count; j++) {
          var ref = new ActionReference();
          ref.putIndex(cTID('Actn'), j);
          ref.putIndex(cTID('ASet'), i);
          var adesc = executeActionGet(ref);
          var actName = adesc.getString(cTID('Nm  '));
          names.push(actName);
        }
        break;
      }
    }
    i++;
  }

  return names;
};

Stdlib.getSelectedAction = function() {
  var obj = {};
  try {
    var ref = new ActionReference();
    ref.putEnumerated(cTID("Actn"), cTID("Ordn"), cTID("Trgt"));
    var desc = executeActionGet(ref);
    obj.name = desc.getString(cTID("Nm  "));
    obj.set = desc.getString(cTID("PrNm"));
  } catch (e) {
  }

  return obj;
};

Stdlib.backupActionsPalette = function(file) {
  if (file) {
    file = Stdlib.convertFptr(file);

  } else {
    file = Stdlib.selectFileSave("Save Backup ActionsPalette", "*.psp",
                                 Folder.desktop + "/Actions Palette.psp");
  }

  if (file) {
    if (!app.preferencesFolder) {
      Error.runtimeError(9001, "\rNo preferencesFolder property found. " +
                         "\rUnable to complete request.");
    }
    var paletteFile = new File(app.preferencesFolder +
                               "/Actions Palette.psp");
    if (!paletteFile.exists) {
      Error.runtimeError(9001, "Unable to locate palette file.");
    }
    paletteFile.copy(file) || throwFileError(file, "Copy failed ");
  }
};

//
// Very dangerous unless you _want_ to empty your Actions Palette.
//
Stdlib.deleteAllActionSets = function(confirmDelete) {
  if (confirmDelete != false) {
    if (!confirm("Do you really want to empty your Actions Palette?")) {
      return;
    }
  }

  var sets = Stdlib.getActionSets();

  for (var i = sets.length-1; i >= 0; i--) {
    Stdlib.deleteActionSet(sets[i].name);
  }
};

Stdlib.setActionPlaybackOption = function(opt, arg) {
  function _ftn() {
    var desc = new ActionDescriptor();
    var ref = new ActionReference();
    ref.putProperty(cTID("Prpr"), cTID("PbkO"));
    ref.putEnumerated(cTID("capp"), cTID("Ordn"), cTID("Trgt"));
    desc.putReference(cTID("null"), ref );
    var pdesc = new ActionDescriptor();
    pdesc.putEnumerated(sTID("performance"), sTID("performance"), sTID(opt));
    if (opt == "pause" && arg != undefined) {
      pdesc.putInteger(sTID("pause"), parseInt(arg));
    }
    desc.putObject(cTID("T   "), cTID("PbkO"), pdesc );
    executeAction(cTID("setd"), desc, DialogModes.NO);
  }
  _ftn();
};
Stdlib.setPlaybackAccelerated = function() {
  Stdlib.setActionPlaybackOption("accelerated");
};
Stdlib.setPlaybackStepByStep = function() {
  Stdlib.setActionPlaybackOption("stepByStep");
};
Stdlib.setPlaybackPaused = function(delaySec) {
  Stdlib.setActionPlaybackOption("pause", delaySec);
};

Stdlib.allowToolRecording = function() {
  var desc = new ActionDescriptor();
  var ref = new ActionReference();
  ref.putEnumerated(cTID('Mn  '), cTID('MnIt'), sTID("allowToolRecording"));
  desc.putReference(cTID('null'), ref);
  executeAction(cTID('slct'), desc, DialogModes.NO);
};


Stdlib.getApplicationDescriptor = function() {
  var ref = new ActionReference();
  ref.putEnumerated(cTID("capp"), cTID("Ordn"), cTID("Trgt"));
  return executeActionGet(ref);
};

Stdlib.getDescriptorKeys = function(desc) {
  var keys = [];

  for (var i = 0; i < desc.count; i++) {
    keys.push(desc.getKey(i));
  }
  return keys;
};
Stdlib.getDescriptorKeySyms = function(desc) {
  var keys = [];

  for (var i = 0; i < desc.count; i++) {
    keys.push(id2char(desc.getKey(i), "Key"));
  }
  return keys;
};

Stdlib.getDescriptorKeyNames = function(desc) {
  var keys = [];

  for (var i = 0; i < desc.count; i++) {
    keys.push(PSConstants.reverseNameLookup(desc.getKey(i), "Key"));
  }
  return keys;
};

//
//=============================== DataSets ===================================
//
// Thanks to mhale for these
//
Stdlib.fileImportDataSets = function(dsfile) {
  var desc = new ActionDescriptor();
  var ref = new ActionReference();
  ref.putClass(sTID("dataSetClass"));
  desc.putReference(cTID("null"), ref);
  desc.putPath(cTID("Usng"), new File(dsfile));
  desc.putEnumerated(cTID("Encd"),
                     sTID("dataSetEncoding"),
                     sTID("dataSetEncodingAuto"));
  desc.putBoolean(sTID("eraseAll"), true);
  desc.putBoolean(sTID("useFirstColumn"), false);
  executeAction(sTID("importDataSets"), desc, DialogModes.NO);
};

Stdlib.applyDataSet = function(setName) {
  var desc = new ActionDescriptor();
  var setRef = new ActionReference();
  setRef.putName(sTID("dataSetClass"), setName);
  desc.putReference(cTID("null"), setRef);
  executeAction(cTID("Aply"), desc, DialogModes.NO);
};

//
//================================= Batch =====================================
//
//
// This is an alternative interface to Batch (instead of app.batch)
// It has the ability to:
//    specify text fragments as file name components.
//    recurse into subfolders
//    use a file mask/regexp to specify files
//
//  src     - a File, Folder, or an Array of Files and Folders
//  act     - the Action name
//  actset  - the ActionSet name
//  opts    - BatchOptions with support for text file naming components
//  mask    - either a simple mask ("*.jpg"), a function mask
//            (see Folder.getFiles()) or a Regular Expression (/\.jpe?g$/i)
//  recurse - if true, recurse into subdirectories
//
Stdlib.batch = function(src, act, actset, opts, mask, recurse) {
  if (CSVersion() < 2) {
    Error.runtimeError(9001, "Batch is only available in CS2+.");
  }

  var desc = new ActionDescriptor();

  if (src instanceof Array) {
    for (var i = 0; i < src.length; i++) {
      Stdlib.batch(src[i], act, actset, opts, mask, recurse);
      opts.startingSerial++;
    }
    return;
  }

  var subdirs;
  if (src instanceof Folder) {
    if (mask) {
      var files;
      if (recurse == true) {
        files = Stdlib.findFiles(src, mask);
      } else {
        files = Stdlib.getFiles(src, mask);
      }
      if (files.length > 0) {
        Stdlib.batch(files, act, actset, opts, mask, recurse);
      }
      return;
    }
    if (recurse == true) {
      subdirs = Stdlib.getFolders(src);
    }
  }

//   $.level = 1; debugger;
  desc.putPath(cTID("null"), src); // source

  if (opts.suppressProfile == true) {
    desc.putBoolean(sTID("suppressWarnings"), true);
  }
  if (opts.suppressOpen == true) {
    desc.putBoolean(sTID("suppressOpenOptions"), true);
  }

  var actref = new ActionReference();
  actref.putName(cTID("Actn"), act);
  actref.putName(cTID("ASet"), actset);
  desc.putReference(cTID("Usng"), actref);

  if (opts.overrideOpen == true) {
    desc.putBoolean(cTID("OvrO"), true);
  }

  if (opts.destination != BatchDestinationType.NODESTINATION) {
    desc.putPath(cTID("T   "), opts.destinationFolder);
  }

  var fileNaming;

  if (opts.destination == BatchDestinationType.FOLDER) {
    fileNaming = opts.fileNaming;

  } else if (opts.destination == BatchDestinationType.SAVEANDCLOSE) {
    fileNaming = [ FileNamingType.DOCUMENTNAMEMIXED,
                   FileNamingType.EXTENSIONLOWER ];
  }

  if (fileNaming) {
    if (fileNaming.length > 6) {
      Error.runtimeError(9001, "Too many BatchOptions.fileNaming components.");
    }
    var fnrdesc = new ActionDescriptor();
    var fnclist = new ActionList();

    for (var i = 0; i < opts.fileNaming.length; i++) {
      var namingComponent = opts.fileNaming[i];
      var fncdesc = new ActionDescriptor();

      if (typeof namingComponent == "string" ||
          namingComponent instanceof String) {
        fncdesc.putString(cTID("Txt "), opts.fileNaming[i]);
      } else {
        var mappedId = Stdlib.batch.map[namingComponent];
        fncdesc.putEnumerated(sTID("component"),
                              sTID("fileNamingComponent"),
                              mappedId);
      }
      fnclist.putObject(sTID("fileNamingComponents"), fncdesc);
    }

    fnrdesc.putList(sTID("fileNamingComponents"), fnclist);

    fnrdesc.putInteger(cTID("Strt"), opts.startingSerial);

    fnrdesc.putBoolean(cTID("Mcnt"), opts.macintoshCompatible);
    fnrdesc.putBoolean(cTID("Win "), opts.windowsCompatible);
    fnrdesc.putBoolean(sTID("unix"), opts.unixCompatible);
    desc.putObject(sTID("fileNamingRules"), sTID("fileNamingRules"), fnrdesc);
  }

  if (opts.destination != BatchDestinationType.NODESTINATION) {
    if (opts.overrideSave == true) {
      desc.putBoolean(cTID("Ovrd"), true);
    }
  }

  if (opts.destination == BatchDestinationType.SAVEANDCLOSE) {
    desc.putBoolean(cTID("SvAn"), true);
  }

  if (opts.errorFile) {
    desc.putPath(cTID("Log "), opts.errorFile.parent);
    desc.putString(cTID("Nm  "), opts.errorFile.name);
  }
  executeAction(cTID("Btch"), desc, DialogModes.NO);

  if (subdirs) {
    for (var i = 0; i < subdirs.length; i++) {
      Stdlib.batch(subdirs[i], act, actset, opts, mask, recurse);
    }
  }
};

Stdlib.batch.init = function() {
  if (!isPhotoshop()) {
    return;
  }
  if (CSVersion() < 2) {
    return;
  }
  Stdlib.batch.map = {};
  Stdlib.batch.map[FileNamingType.DDMM] = sTID("ddmm");
  Stdlib.batch.map[FileNamingType.DDMMYY] = sTID("ddmmyy");
  Stdlib.batch.map[FileNamingType.DOCUMENTNAMELOWER] = sTID("lowerCase");
  Stdlib.batch.map[FileNamingType.DOCUMENTNAMEMIXED] = cTID("Nm  ");
  Stdlib.batch.map[FileNamingType.DOCUMENTNAMEUPPER] = sTID("upperCase");
  Stdlib.batch.map[FileNamingType.EXTENSIONLOWER] = sTID("lowerCaseExtension");
  Stdlib.batch.map[FileNamingType.EXTENSIONUPPER] = sTID("upperCaseExtension");
  Stdlib.batch.map[FileNamingType.MMDD] = sTID("mmdd");
  Stdlib.batch.map[FileNamingType.MMDDYY] = sTID("mmddyy");
  Stdlib.batch.map[FileNamingType.SERIALLETTERLOWER] = sTID("upperCaseSerial");
  Stdlib.batch.map[FileNamingType.SERIALLETTERUPPER] = sTID("lowerCaseSerial");
  Stdlib.batch.map[FileNamingType.SERIALNUMBER1] = sTID("oneDigit");
  Stdlib.batch.map[FileNamingType.SERIALNUMBER2] = sTID("twoDigit");
  Stdlib.batch.map[FileNamingType.SERIALNUMBER3] = sTID("threeDigit");
  Stdlib.batch.map[FileNamingType.SERIALNUMBER4] = sTID("fourDigit");
  Stdlib.batch.map[FileNamingType.YYDDMM] = sTID("yyddmm");
  Stdlib.batch.map[FileNamingType.YYMMDD] = sTID("yymmdd");
  Stdlib.batch.map[FileNamingType.YYYYMMDD] = sTID("yyyymmdd");
};

Stdlib.batch.init();

//
//================================= misc =====================================
//


//
// selectColorRange
//   Selects a range of colors around a specified color.
//   doc     - the document to operate on
//   color   - either a SolidColor or LabColor object
//   range   - the 'fuzziness' factor [default 40]
//   inverse - invert the selection [default 'false']
// Example:
//   Stdlib.selectColorRange(doc, Stdlib.getColorAt(doc, 125, 300), 50)
//
// Thanks to Andrew Hall for the original idea
//
Stdlib.selectColorRange = function(doc, color, range, inverse) {
  var clr = (color instanceof SolidColor) ? color.lab : color;
  if (inverse == undefined) {
    inverse = false;
  }
  if (range == undefined) {
    range = 40;
  }

  function _ftn() {
    var desc = new ActionDescriptor();
    desc.putInteger(cTID("Fzns"), range);

    var mnDesc = new ActionDescriptor();
    mnDesc.putDouble(cTID("Lmnc"), clr.l);
    mnDesc.putDouble(cTID("A   "), clr.a);
    mnDesc.putDouble(cTID("B   "), clr.b);
    desc.putObject(cTID("Mnm "), cTID("LbCl"), mnDesc);

    var mxDesc = new ActionDescriptor();
    mxDesc.putDouble(cTID("Lmnc"), clr.l);
    mxDesc.putDouble(cTID("A   "), clr.a);
    mxDesc.putDouble(cTID("B   "), clr.b);
    desc.putObject(cTID("Mxm "), cTID("LbCl"), mxDesc);

    if (inverse) {
      desc.putBoolean(cTID("Invr"), inverse);
    }

    executeAction(cTID("ClrR"), desc, DialogModes.NO );
  }

  Stdlib.wrapLC(doc, _ftn);
};

//
// selectColorRangeRGB
//   See 'selectColorRange' above
//   clr - either a RGBColor object or an Array with three(rgb) values
// Example:
//   Stdlib.selectColorRangeRGB(doc, [255, 144, 144], 50, true)
//
Stdlib.selectColorRangeRGB = function(doc, clr, range, inverse) {
  if (clr instanceof Array) {
    var c = new RGBColor();
    c.red = clr[0]; c.green = clr[1]; c.blue = clr[2];
    clr = new SolidColor();
    clr.rgb = c;
  } else if (clr instanceof RGBColor) {
    c = new SolidColor();
    c.rgb = clr;
    clr = c;
  } else if (clr instanceof SolidColor) {
    // do nothing
  } else {
    Error.runtimeError(19, "color"); // "Bad color argument");
  }

  Stdlib.selectColorRange(doc, clr, range, inverse);
};

Stdlib.selectOutOfGamutColor = function(doc) {
  function _ftn() {
    var desc = new ActionDescriptor();
    desc.putEnumerated(cTID("Clrs"), cTID("Clrs"), cTID("OtOf"));
    executeAction(cTID("ClrR"), desc, DialogModes.NO );
  }

  Stdlib.wrapLC(doc, _ftn);
};


Stdlib.rgbToString = function(c) {
  return "[" + c.rgb.red + "," + c.rgb.green + "," + c.rgb.blue + "]";
};
Stdlib.rgbToArray = function(c) {
  return [c.rgb.red, c.rgb.green, c.rgb.blue];
};
Stdlib.rgbFromString = function(str) {
  var rex = /([\d\.]+),([\d\.]+),([\d\.]+)/;
  var m = str.match(rex);
  if (m) {
    return Stdlib.createRGBColor(Number(m[1]),
                                 Number(m[2]),
                                 Number(m[3]));
  }
  return undefined;
};
Stdlib.createRGBColor = function(r, g, b) {
  var c = new RGBColor();
  if (r instanceof Array) {
    b = r[2]; g = r[1]; r = r[0];
  }
  c.red = parseInt(r); c.green = parseInt(g); c.blue = parseInt(b);
  var sc = new SolidColor();
  sc.rgb = c;
  return sc;
};

try {
  if (isPhotoshop()) {
    Stdlib.COLOR_BLACK = Stdlib.createRGBColor(0, 0, 0);
    Stdlib.COLOR_RED = Stdlib.createRGBColor(255, 0, 0);
    Stdlib.COLOR_GREEN = Stdlib.createRGBColor(0, 255, 0);
    Stdlib.COLOR_BLUE = Stdlib.createRGBColor(0, 0, 255);
    Stdlib.COLOR_GRAY = Stdlib.createRGBColor(128, 128, 128);
    Stdlib.COLOR_WHITE = Stdlib.createRGBColor(255, 255, 255);
  }
} catch (e) {
}

Stdlib.colorFromString = function(str) {
  var c = Stdlib.rgbFromString(str);
  if (!c) {
    str = str.toLowerCase();
    if (str == "black") {
      c = Stdlib.COLOR_BLACK;
    } else if (str == "white") {
      c = Stdlib.COLOR_WHITE;
    } else if (str == "foreground") {
      c = app.foregroundColor;
    } else if (str == "background") {
      c = app.backgroundColor;
    } else if (str == "gray" || str == "grey") {
      c = Stdlib.COLOR_GRAY;
    } else if (str == "red") {
      c = Stdlib.COLOR_RED;
    } else if (str == "green") {
      c = Stdlib.COLOR_GREEN;
    } else if (str == "blue") {
      c = Stdlib.COLOR_BLUE;
    }
  }
  return c;
};


// the slow way to draw...
Stdlib.setColorAt = function(doc, x, y, color, mode, opacity) {
  Stdlib.selectBounds(doc, [x, y, x+1, y+1], SelectionType.REPLACE, 0, false);
  if (!Stdlib.hasSelection(doc)) {
    Error.runtimeError(20, "Unable to select pixel at " + x + ',' + y);
  }
  if (mode == undefined) {
    mode = ColorBlendMode.NORMAL;
  }
  if (opacity == undefined) {
    opacity = 100;
  }
  if (color) {
    doc.selection.fill(color, mode, opacity);
  } else {
    doc.selection.clear();
  }
};
Stdlib.putColorAt = Stdlib.setColorAt;

// getColorAt
// based on:
//     fazstp@adobeforums.com wrote:
//     news://adobeforums.com:119/3bb84060.0@webx.la2eafNXanI
//
// updated for ColorSampler APIs in CS3+
//
Stdlib.getColorAt = function(doc, x, y, undo) {
  if (CSVersion() >= 3) {
    if (x != Math.ceil(x)){
      x += 0.5;
    }
    if (y != Math.ceil(y)){
      y += 0.5;
    }
    var sample = doc.colorSamplers.add([UnitValue(x, "px"),
      UnitValue(y, "px")]);
    var clr = undefined;
    try { clr = sample.color; } catch (e) {}
    sample.remove();
    return clr;
  }

  if (!!undo) {
    undo = true;
    var st = doc.activeHistoryState;
  }
  // make new 1 pixel selection
  x = Math.floor(x);
  y = Math.floor(y);

  Stdlib.selectBounds(doc, [x, y, x+1, y+1]);

  try {
    function findPV(h) {
      for (var i = 0; i <= 255; i++ ) {
        if (h[i]) { return i; }
      }
      return 0;
    }

    var pColour = new SolidColor();

    if (doc.mode == DocumentMode.RGB) {
      pColour.mode = ColorModel.RGB;
      pColour.rgb.red   = findPV(doc.channels["Red"].histogram);
      pColour.rgb.green = findPV(doc.channels["Green"].histogram);
      pColour.rgb.blue  = findPV(doc.channels["Blue"].histogram);

    } else if (doc.mode == DocumentMode.GRAYSCALE) {
      var gr = findPV(doc.channels["Gray"].histogram);
      pColour.mode = ColorModel.GRAYSCALE;
      pColour.gray.gray = 100 * (gr/255);

    } else {
      Error.runtimeError(9001, "Color Mode not supported: " + doc.mode);
    }

  } finally {
    if (undo) {
      doc.activeHistoryState = st;
    }
  }

  return pColour;
};

Stdlib.convertProfile = function(doc, profile) {
  profile = profile.replace(/\.icc$/i, '');

  function _ftn() {
    var desc = new ActionDescriptor();
    var ref = new ActionReference();
    ref.putEnumerated( cTID('Dcmn'), cTID('Ordn'), cTID('Trgt') );
    desc.putReference( cTID('null'), ref);
    desc.putString( cTID('T   '), profile );
    desc.putEnumerated( cTID('Inte'), cTID('Inte'), cTID('Clrm') );
    desc.putBoolean( cTID('MpBl'), true );
    desc.putBoolean( cTID('Dthr'), false );
    desc.putInteger( cTID('sdwM'), -1 );
    executeAction( sTID('convertToProfile'), desc, DialogModes.NO );
  }

  Stdlib.wrapLC(doc, _ftn);
};


// deprecated: Use Document.changeMode
Stdlib.convertMode = function(doc, cmode) {
  var mode;

  function _ftn() {
    var desc = new ActionDescriptor();
    desc.putClass(cTID("T   "), cTID(mode));
    executeAction(sTID("convertMode"), desc, DialogModes.NO);
  };

  switch (cmode) {
    case DocumentMode.BITMAP:       mode = "BtmM"; break;
    case DocumentMode.CMYK:         mode = "CMYM"; break;
    case DocumentMode.GRAYSCALE:    mode = "Grys"; break;
    case DocumentMode.INDEXEDCOLOR: mode = "IndC"; break;
    case DocumentMode.LAB:          mode = "LbCM"; break;
    case DocumentMode.MULTICHANNEL: mode = "MltC"; break;
    case DocumentMode.RGB:          mode = "RGBM"; break;
    default: Error.runtimeError(9001, "Bad color mode specified: " + cmode);
  }
  Stdlib.wrapLC(doc, _ftn);
};

Stdlib.colorModeString = function(cmode) {
  var mode = "Unknown Mode";

  var cmodeN = toNumber(cmode);

  if (isNaN(cmodeN)) {
    switch (cmode) {
      case DocumentMode.BITMAP:       mode = "Bitmap"; break;
      case DocumentMode.CMYK:         mode = "CMYK"; break;
      case DocumentMode.DUOTONE:      mode = "Duotone"; break;
      case DocumentMode.GRAYSCALE:    mode = "Grayscale"; break;
      case DocumentMode.INDEXEDCOLOR: mode = "Indexed Color"; break;
      case DocumentMode.LAB:          mode = "Lab"; break;
      case DocumentMode.MULTICHANNEL: mode = "Multichannel"; break;
      case DocumentMode.RGB:          mode = "RGB"; break;
    }

  } else {
    switch (cmode) {
      case 0: mode = "Bitmap"; break;
      case 1: mode = "Grayscale"; break;
      case 2: mode = "Indexed Color"; break;
      case 3: mode = "RGB"; break;
      case 4: mode = "CMYK"; break;
      case 7: mode = "Multichannel"; break;
      case 8: mode = "Duotone"; break;
      case 9: mode = "Lab"; break;
    }
  }

  return mode;
};
Stdlib.copyrightedString = function(copy) {
  var str = '';
  switch (copy) {
    case CopyrightedType.COPYRIGHTEDWORK: str = "Copyrighted"; break;
    case CopyrightedType.PUBLICDOMAIN:    str = 'Public Domain'; break;
    case CopyrightedType.UNMARKED:        str = 'Unmarked'; break;
  }

  return str;
};
Stdlib.urgencyString = function(urgency) {
  var str = '';
  switch (urgency) {
    case Urgency.LOW:    str = "Urgency Low"; break;
    case Urgency.TWO:    str = "Urgency Two"; break;
    case Urgency.THREE:  str = "Urgency Three"; break;
    case Urgency.FOUR:   str = "Urgency Four"; break;
    case Urgency.NORMAL: str = "Urgency Normal"; break;
    case Urgency.SIX:    str = "Urgency Six"; break;
    case Urgency.SEVEN:  str = "Urgency Seven"; break;
    case Urgency.HIGH:   str = "Urgency High"; break;
  }

  return str;
};

Stdlib.getFillLayerColor = function(doc, layer) {
  var color = new SolidColor();
  var desc = Stdlib.getLayerDescriptor(doc, layer);
  var adjList = desc.getList(cTID('Adjs'));
  var adjDesc = adjList.getObjectValue(0);
  var clrDesc = adjDesc.getObjectValue(cTID('Clr '));
  color.rgb.red = clrDesc.getDouble(cTID('Rd  '));
  color.rgb.green = clrDesc.getDouble(cTID('Grn '));
  color.rgb.blue = clrDesc.getDouble(cTID('Bl  '));
  return color;
};

Stdlib.setFillLayerColor = function(doc, layer, color) {
  function _ftn() {
    var desc = new ActionDescriptor();
    var ref = new ActionReference();
    ref.putEnumerated(sTID('contentLayer'), cTID('Ordn'), cTID('Trgt'));
    desc.putReference(cTID('null'), ref);
    var cdesc = new ActionDescriptor();
    var rgbdesc = new ActionDescriptor();
    rgbdesc.putDouble(cTID('Rd  '), color.rgb.red);
    rgbdesc.putDouble(cTID('Grn '),  color.rgb.green);
    rgbdesc.putDouble(cTID('Bl  '),  color.rgb.blue);
    cdesc.putObject(cTID('Clr '), cTID('RGBC'), rgbdesc);
    desc.putObject(cTID('T   '), sTID('solidColorLayer'), cdesc);
    return executeAction(cTID('setd'), desc, DialogModes.NO);
  }

  return Stdlib.wrapLCLayer(doc, layer, _ftn);
};

Stdlib.createSwatch = function(name, red, green, blue) {
  var clrDesc = new ActionDescriptor();
  clrDesc.putDouble(cTID("Rd  "), red);
  clrDesc.putDouble(cTID("Grn "), green);
  clrDesc.putDouble(cTID("Bl  "), blue);

  var clrsDesc = new ActionDescriptor();
  clrsDesc.putString(cTID("Nm  "), name);
  clrsDesc.putObject(cTID("Clr "), cTID("RGBC"), clrDesc);

  var ref = new ActionReference();
  ref.putClass(cTID("Clrs"));

  var desc = new ActionDescriptor();
  desc.putReference(cTID("null"), ref);
  desc.putObject(cTID("Usng"), cTID("Clrs"), clrsDesc);

  app.executeAction(cTID("Mk  "), desc, DialogModes.NO);
};

Stdlib.saveAllPatterns = function(file) {
  var desc = new ActionDescriptor();
  desc.putPath(cTID("null"), file);
  var ref = new ActionReference();
  ref.putProperty(cTID("Prpr"), cTID("Ptrn"));
  ref.putEnumerated(cTID("capp"), cTID("Ordn"), cTID("Trgt"));
  desc.putReference(cTID("T   "), ref);
  executeAction(cTID("setd"), desc, DialogModes.NO);
};

Stdlib.savePatterns = function(file, indexArray) {
  var desc = new ActionDescriptor();
  desc.putPath(cTID("null"), file);

  var list = new ActionList();
  for (var i = 0; i < indexArray.length; i++) {
    var ref = new ActionReference();
    ref.putIndex(cTID("Ptrn"), indexArray[i]);
    list.putReference(ref);
  }
  desc.putList(cTID("T   "), list);
  executeAction(cTID("setd"), desc, DialogModes.NO);
};

Stdlib.savePattern = function(file, index) {
  Stdlib.savePatterns(file, [index]);
};

Stdlib.fillPattern = function(doc, name, id) {
  function _ftn() {
    var desc203 = new ActionDescriptor();
    desc203.putEnumerated( cTID('Usng'), cTID('FlCn'), cTID('Ptrn') );
    var desc204 = new ActionDescriptor();
    if (name) {
      desc204.putString( cTID('Nm  '), name);
    }
    if (id) {
      desc204.putString( cTID('Idnt'), id);
    }
    desc203.putObject( cTID('Ptrn'), cTID('Ptrn'), desc204 );
    desc203.putUnitDouble( cTID('Opct'), cTID('#Prc'), 100.000000 );
    desc203.putEnumerated( cTID('Md  '), cTID('BlnM'), cTID('Nrml') );
    executeAction( cTID('Fl  '), desc203, DialogModes.NO );
  }

  Stdlib.wrapLC(doc, _ftn);
};

Stdlib.definePatternFromSelection = function(doc, name) {
  function _ftn() {
    var desc182 = new ActionDescriptor();
    var ref89 = new ActionReference();
    ref89.putClass( cTID('Ptrn') );
    desc182.putReference( cTID('null'), ref89 );
    var ref90 = new ActionReference();
    ref90.putProperty( cTID('Prpr'), cTID('fsel') );
    ref90.putEnumerated( cTID('Dcmn'), cTID('Ordn'), cTID('Trgt') );
    desc182.putReference( cTID('Usng'), ref90 );
    desc182.putString( cTID('Nm  '), name );
    executeAction( cTID('Mk  '), desc182, DialogModes.NO );
  }

  Stdlib.wrapLC(doc, _ftn);
};


Stdlib.createGuide = function(doc, orientation, position) {
  function _ftn() {
    var desc = new ActionDescriptor();
    var gdesc = new ActionDescriptor();
    gdesc.putUnitDouble(cTID("Pstn"), cTID("#Pxl"), position);
    gdesc.putEnumerated(cTID("Ornt"), cTID("Ornt"), cTID(orientation));
    desc.putObject(cTID("Nw  "), cTID("Gd  "), gdesc);
    executeAction(cTID("Mk  "), desc, DialogModes.NO );
  }
  Stdlib.wrapLC(doc, _ftn);
};
Stdlib.createVerticalGuide = function(doc, position) {
  Stdlib.createGuide(doc, "Vrtc", position);
};
Stdlib.createHorizontalGuide = function(doc, position) {
  Stdlib.createGuide(doc, "Hrzn", position);
};

Stdlib.clearGuides = function(doc) {
  function _ftn() {
    var desc = new ActionDescriptor();
    var ref = new ActionReference();
    ref.putEnumerated(cTID("Gd  "), cTID("Ordn"), cTID("Al  "));
    desc.putReference(cTID("null"), ref );
    executeAction(cTID("Dlt "), desc, DialogModes.NO );
  }

  Stdlib.wrapLC(doc, _ftn);
};

Stdlib.renameChannel = function(doc, oldName, newName) {
  var channels = doc.activeChannels;
  for (var i = 0; i < channels.length; i++) {
    var ch = channels[i];
    if (ch.name == oldName) {
      ch.name = newName;
      return;
    }
  }
};
Stdlib.selectChannel = function(doc, layer, chnl) {
  function _ftn() {
    var desc = new ActionDescriptor();
    var ref = new ActionReference();
    ref.putEnumerated(cTID('Chnl'), cTID('Chnl'), cTID(chnl));
    desc.putReference(cTID('null'), ref);
    desc.putBoolean(cTID('MkVs'), false );
    executeAction(cTID('slct'), desc, DialogModes.NO );
  }
  Stdlib.wrapLCLayer(doc, layer, _ftn);
};
Stdlib.selectRGBChannel = function(doc, layer) {
  Stdlib.selectChannel(doc, layer, 'RGB ');
};

Stdlib.drawLine = function(doc, start, stop) {

  var startPoint = new PathPointInfo();
  startPoint.anchor = start;
  startPoint.leftDirection = start;
  startPoint.rightDirection = start;
  startPoint.kind = PointKind.CORNERPOINT;

  var stopPoint = new PathPointInfo();
  stopPoint.anchor = stop;
  stopPoint.leftDirection = stop;
  stopPoint.rightDirection = stop;
  stopPoint.kind = PointKind.CORNERPOINT;

  var spi = new SubPathInfo();
  spi.closed = false;
  spi.operation = ShapeOperation.SHAPEXOR;
  spi.entireSubPath = [startPoint, stopPoint];

  var line = doc.pathItems.add("Line", [spi]);
  line.strokePath(ToolType.PENCIL);
  line.remove();
};

Stdlib.selectEllipse = function(doc, bnds, antiAlias) {
  antiAlias = (antiAlias != false);  // defaults to true

  var desc = new ActionDescriptor();
  var ref = new ActionReference();
  ref.putProperty(cTID('Chnl'), cTID('fsel'));
  desc.putReference(cTID('null'), ref);
  var bdesc = new ActionDescriptor();
  bdesc.putUnitDouble(cTID('Top '), cTID('#Pxl'), bnds[1]);
  bdesc.putUnitDouble(cTID('Left'), cTID('#Pxl'), bnds[0]);
  bdesc.putUnitDouble(cTID('Btom'), cTID('#Pxl'), bnds[3]);
  bdesc.putUnitDouble(cTID('Rght'), cTID('#Pxl'), bnds[2]);
  desc.putObject(cTID('T   '), cTID('Elps'), bdesc);
  desc.putBoolean(cTID('AntA'), true);
  executeAction(cTID('setd'), desc, DialogModes.NO);
};


Stdlib.stop = function(msg, cont) {
  if (msg == undefined) {
    msg = "Operation cancelled.";
  }
  var desc = new ActionDescriptor();
  desc.putString(cTID("Msge"), msg);
  if (cont != undefined) {
    desc.putBoolean(cTID("Cntn"), cont);
  }
  app.executeAction(cTID("Stop"), desc, DialogModes.ALL);
};

//
// Add a new Text layer with some string...
//
Stdlib.addTextLayer = function(doc, contents, name, size) {
  var layer = doc.artLayers.add();

  layer.kind = LayerKind.TEXT;
  if (name) { layer.name = name; }
  layer.blendMode = BlendMode.NORMAL;
  layer.opacity = 100.0;

  //$.level = 1; debugger;
  var text = layer.textItem;
  var ru = app.preferences.rulerUnits;
  var tu = app.preferences.typeUnits;

  try {
    var newColor = Stdlib.createRGBColor(255, 255, 255);

    app.preferences.typeUnits = TypeUnits.POINTS;
    app.preferences.rulerUnits = Units.PIXELS;

    text.size = (size ? size : 24);    //Math.max(doc.height/100, 3);
    text.font = "ArialMT";
    text.kind = TextType.PARAGRAPHTEXT;
    text.color = newColor;

    app.preferences.rulerUnits = Units.PERCENT;
    text.position = new Array(5, 5);
    app.preferences.rulerUnits = Units.PIXELS;
    text.width  = doc.width;
    text.height = doc.height;
    text.contents = contents;

  } finally {
    app.preferences.rulerUnits = ru;
    app.preferences.typeUnits = tu;
  }

  return layer;
};

// deprecated
Stdlib.addInfoTextLayer = Stdlib.addTextLayer;

Stdlib.convertTextLayerToShape = function(doc, layer) {
  function _ftn() {
    var desc96 = new ActionDescriptor();
    var ref61 = new ActionReference();
    ref61.putClass( sTID('contentLayer') );
    desc96.putReference( cTID('null'), ref61 );
    var ref62 = new ActionReference();
    ref62.putEnumerated( cTID('TxLr'), cTID('Ordn'), cTID('Trgt') );
    desc96.putReference( cTID('Usng'), ref62 );
    executeAction( cTID('Mk  '), desc96, DialogModes.NO );
  }

  Stdlib.wrapLCLayer(doc, layer, _ftn);
};



Stdlib.getPSFontList = function() {
  var flist = app.fonts;
  var fontList = [flist.length];
  for (var i = 0; i < flist.length; i++) {
    fontList[i] = flist[i].postScriptName;
  }
  return fontList;
};

Stdlib.findPSFont = function(f) {
  var tf = Stdlib.getByName(app.fonts, f);
  return (tf ? tf.postScriptName : undefined);
};

Stdlib.getFont = function(f) {
  // getByProperty
  var flist = app.fonts;
  for (var i = 0; i < flist.length; i++) {
    if (f == flist[i].postScriptName) {
      return flist[i];
    }
  }
  return undefined;
};

Stdlib.findFont = function(f) {
  // getByName
  var flist = app.fonts;
  for (var i = 0; i < flist.length; i++) {
    if (f == flist[i].name) {
      return flist[i];
    }
  }
  return undefined;
};

Stdlib.determineFont = function(str) {
  return (Stdlib.getByName(app.fonts, str) ||
          Stdlib.getByProperty(app.fonts, 'postScriptName', str));
};

//
// This doesn't really get the default Type Tool font (see below for that)
// but it does make a reasonable attempt at getting a font that is
// locale appropriate
//
Stdlib.getDefaultFont = function() {
  var str;

  if (isMac()) {
    str = localize("$$$/Project/Effects/Icon/Font/Name/Mac=Lucida Grande");
  } else {
    str = localize("$$$/Project/Effects/Icon/Font/Name/Win=Tahoma");
  }

  var font = Stdlib.determineFont(str);

  if (!font) {
    var f = Stdlib.getApplicationProperty(sTID('fontLargeName'));
    if (f != undefined) {
      font = Stdlib.determineFont(f);
    }
  }

  return font;
};

// 
// This attemps gets the default Type Tool font. Since there is no
// direct API for this, we have to save the current type tool settings,
// reset the settings, then restore the saved settings.
// This will fail if there already exists a tool preset called
// "__temp__". Working around this shortcoming would make things even
// more complex than they already are
//
Stdlib.getDefaultTypeToolFont = function() {
  var str = undefined;
  var typeTool = "typeCreateOrEditTool";

  // need to back-port to use Stdlib functions
  try {
    // get the current tool
    var ref = new ActionReference();
    ref.putEnumerated(cTID("capp"), cTID("Ordn"), cTID("Trgt") );
    var desc = executeActionGet(ref);
    var tid = desc.getEnumerationType(sTID('tool'));
    var currentTool = typeIDToStringID(tid);

    // switch to the type tool
    if (currentTool != typeTool) {
      var desc = new ActionDescriptor();
      var ref = new ActionReference();
      ref.putClass(sTID(typeTool));
      desc.putReference(cTID('null'), ref);
      executeAction(cTID('slct'), desc, DialogModes.NO);
    }

    var ref = new ActionReference();
    ref.putEnumerated(cTID("capp"), cTID("Ordn"), cTID("Trgt") );
    var desc = executeActionGet(ref);
    var tdesc = desc.hasKey(cTID('CrnT')) ?
      desc.getObjectValue(cTID('CrnT')) : undefined;

    if (tdesc) {
      // save the current type tool settings
      var desc4 = new ActionDescriptor();
      var ref4 = new ActionReference();
      ref4.putClass( sTID('toolPreset') );
      desc4.putReference( cTID('null'), ref4 );
      var ref5 = new ActionReference();
      ref5.putProperty( cTID('Prpr'), cTID('CrnT') );
      ref5.putEnumerated( cTID('capp'), cTID('Ordn'), cTID('Trgt') );
      desc4.putReference( cTID('Usng'), ref5 );
      desc4.putString( cTID('Nm  '), "__temp__" );

      // this will fail if there is already a preset called __temp__
      executeAction( cTID('Mk  '), desc4, DialogModes.NO );

      // reset the type tool
      var desc2 = new ActionDescriptor();
      var ref2 = new ActionReference();
      ref2.putProperty( cTID('Prpr'), cTID('CrnT') );
      ref2.putEnumerated( cTID('capp'), cTID('Ordn'), cTID('Trgt') );
      desc2.putReference( cTID('null'), ref2 );
      executeAction( cTID('Rset'), desc2, DialogModes.NO );

      // get the current type tool settings
      var ref = new ActionReference();
      ref.putEnumerated(cTID("capp"), cTID("Ordn"), cTID("Trgt") );
      var desc = executeActionGet(ref);
      var tdesc = desc.getObjectValue(cTID('CrnT'));

      // get the default type tool font
      var charOpts = tdesc.getObjectValue(sTID("textToolCharacterOptions"));
      var styleOpts = charOpts.getObjectValue(cTID("TxtS"));
      str = styleOpts.getString(sTID("fontPostScriptName"));

      // restore the type tool settings
      var desc9 = new ActionDescriptor();
      var ref10 = new ActionReference();
      ref10.putName( sTID('toolPreset'), "__temp__" );
      desc9.putReference( cTID('null'), ref10 );
      executeAction( cTID('slct'), desc9, DialogModes.NO );

      // delete the temp setting
      var desc11 = new ActionDescriptor();
      var ref12 = new ActionReference();
      ref12.putEnumerated( sTID('toolPreset'), cTID('Ordn'), cTID('Trgt') );
      desc11.putReference( cTID('null'), ref12 );
      executeAction( cTID('Dlt '), desc11, DialogModes.NO );
    }

    // switch back to the original tool
    if (currentTool != typeTool) {
      var desc = new ActionDescriptor();
      var ref = new ActionReference();
      ref.putClass(tid);
      desc.putReference(cTID('null'), ref);
      executeAction(cTID('slct'), desc, DialogModes.NO);
    }
  } catch (e) {
    return undefined;
  }

  return str;
};


// XXX fix this later
Stdlib.setFontRealName = function( fontName ) {
  var ref = new ActionReference();
  ref.putProperty(sTID('property'), sTID('textStyle'));
  ref.putEnumerated(sTID('textLayer'),
                    sTID('ordinal'),
                    sTID('targetEnum'));

  var desc = new ActionDescriptor();
  desc.putReference(sTID('null'), ref);

  var edesc = new ActionDescriptor();
  edesc.putString(sTID('fontName'), fontName);
  edesc.putObject(sTID('to'), sTID('textStyle'), desc);

  executeAction(sTID('set'), edesc, DialogModes.NO);
};

// UnitValue functions

Stdlib.unitValueRex = /(-)?(\d+)?(\.\d+)? (in|ft|yd|mi|mm|cm|m|km|pt|pc|tpt|ptc|ci|px|%)/;


//
//=============================== Debugging ===================================
//

//
// fullStop
//     Drop into the debugger as long as 'stop' is not false
//
Stdlib.fullStop = function(stop) {
  if (stop != false) {
    $.level = 1;
    debugger;
  }
};
//fullStop = Stdlib.fullStop;

//
// a dumb little piece of code that does a busy-wait
// for some period of time. Crank units up 'til it waits
// long enough for your purposes.
// This is deprecated in CS2.
//
Stdlib.pause = function(units){
  for (var i = 0; i < units; i++) {
    var x = 11.400930;
    var y = 33.902312;
    Stdlib.pause_dummy = eval("Math.sqrt(x/y)");
  }
};
Stdlib.listGlobals = function() {
  var lst = [];
  for (var i in global) {
    lst.push(i);
  }
  lst.sort();
  var str = '';
  for (var j in lst) {
    i = lst[j];
    str += i + ":\t";
    try {
      var o = global[i];
      str += "[" + (typeof o) + "]";
      if (typeof o != "function") {
        str += ":\t" + global[i].toString();
      }
    } catch (e) {
      str += "[]";
    }
    str += "\r\n";
  }
  return str;
};
listGlobals = Stdlib.listGlobals;

Stdlib.listProps = function(obj) {
  var s = [];
  var sep = (isBridge() ? "\r" : "\r\n");

  for (var x in obj) {
    var str = x + ":\t";
    try {
      var o = obj[x];
      str += (typeof o == "function") ? "[function]" : o;
    } catch (e) {
    }
    s.push(str);
  }
  s.sort();

  return s.join(sep);
};
listProps = Stdlib.listProps;

Stdlib.dumpGlobals = function(fname) {
  var f = new File(fname || "/c/temp/globals.log");
  f.open("w", "TEXT", "????");
  f.writeln(listGlobals());
  f.close();
};

Stdlib.showtext = function showtext(msg) {
  confirm(msg);
};

// A helper function for debugging
// It also helps the user see what is going on
// if you turn it off for this example you
// get a flashing cursor for a number (long) time
Stdlib.waitForRedraw = function() {
  var desc = new ActionDescriptor();
  desc.putEnumerated(cTID("Stte"), cTID("Stte"), cTID("RdCm"));
  executeAction(cTID("Wait"), desc, DialogModes.NO);
};

// refresh = Stdlib.waitForRedraw;

Stdlib._dumpRI = function(ri) {
  var str = '';
  var props =
  [ "name",
    "arguments",
    "dataType",
    "defaultValue",
    "description",
    "help",
    "isCollection",
    "max",
    "min",
    "type"];

  str += '\t' + ri.name + '\r\n';

  for (var i = 0; i < props.length; i++) {
    var n = props[i];
    var v = ri[n];

    if (v != undefined) {
      str += "\t\t" + n + " : " + v + "\r\n";
    }
  }
  return str;
}
Stdlib.dumpRTI = function(o) {
  var r = o.reflect;
  var str = '';

  //debugger;
  str += "//\r\n// " + r.name + "\r\n//    " + r.help + "\r\n//\r\n";
  str += "class " + r.name + "\r\n";
  str += "  props:\r\n";
  for (var i = 0; i < r.properties.length; i++) {
    var ri = r.properties[i];
    str += Stdlib._dumpRI(ri);
  }
  str += "  methods:\r\n";
  for (var i = 0; i < r.methods.length; i++) {
    var ri = r.methods[i];
    str += Stdlib._dumpRI(ri);
  }
  return str;
};

Stdlib.getLastJSLogEntry = function(fptr) {
  if (fptr) {
    fptr = Stdlib.convertFptr(fptr);
  } else {
    fptr = new File("/c/ScriptingListenerJS.log");
    if (!fptr.exists) {
      Error.runtimeError(Stdlib.IO_ERROR_CODE, "Unable to find SLC log.");
    }
  }

  fptr.open("r", "TEXT", "????") || throwFileError(fptr, "Unable to open");
  //fptr.lineFeed = "unix";

  fptr.seek(1, 2);  // start of at the end of the file
  var prev = fptr.readch();

  for (var i = 2; i < fptr.length; i++) {
    fptr.seek(i, 2);  // start of at the end of the file
    var c = fptr.readch();
    if (c == '\n' && prev == '/') {
      break;
    }
    prev = c;
  }
  if (i == fptr.length && prev != '/') {
    return undefined;
  }

  fptr.readln();

  if (CSVersion() >= 4) {
    // XXX There is a bug in CS4 that causes the previous readln to
    // read one too many characters. This looks for the bug and works
    // around it.

    var loc = fptr.tell();
    var str = fptr.read();

    if (str[0] == 'a') {
      fptr.seek(loc-1);
      str = fptr.read();
    }

  } else {
    var str = fptr.read();
  }
  fptr.close();
  return str;
};


Stdlib.writeDescriptor = function(fptr, desc) {
  fptr = Stdlib.convertFptr(fptr);
  fptr.encoding = 'BINARY';
  if (!fptr.open("w")) {
    throwFileError(fptr);
  }
  var str = desc.toStream();
  if (!fptr.write(str)) {
    throwFileError(fptr);
  }
  fptr.close();
  delete str;
};

Stdlib.readDescriptor = function(fptr) {
  var fptr = Stdlib.convertFptr(fptr);
  fptr.encoding = 'BINARY';
  if (!fptr.open("r")) {
    throwFileError(fptr);
  }
  var str = fptr.read();
  fptr.close();

  var desc = new ActionDescriptor();
  desc.fromStream(str);
  return desc;
};

//=============================== UnitValue support code ======================
Stdlib._units = undefined;
Stdlib._unitsInit = function() {
  if (!isPhotoshop()) {
    return;
  }
  Stdlib._units = app.preferences.rulerUnits.toString();
  Stdlib._unitMap = {};
  Stdlib._unitMap[Units.INCHES.toString()] =  "in";
  Stdlib._unitMap[Units.CM.toString()] =      "cm";
  Stdlib._unitMap[Units.MM.toString()] =      "mm";
  Stdlib._unitMap[Units.PERCENT.toString()] = "%";
  Stdlib._unitMap[Units.PICAS.toString()] =   "pc";
  Stdlib._unitMap[Units.PIXELS.toString()] =  "px";
  Stdlib._unitMap[Units.POINTS.toString()] =  "pt";

  Stdlib._unitStrMap = {};
  Stdlib._unitStrMap["in"] = "in";
  Stdlib._unitStrMap["cm"] = "cm";
  Stdlib._unitStrMap["mm"] = "mm";
  Stdlib._unitStrMap["%"]  = "%";
  Stdlib._unitStrMap["pc"] = "picas";
  Stdlib._unitStrMap["px"] = "pixels";
  Stdlib._unitStrMap["pt"] = "points";
};
Stdlib._unitsInit();
Stdlib.getDefaultUnits = function() {
  return Stdlib._unitMap[Stdlib._units];
};
Stdlib.getDefaultUnitsString = function() {
  return Stdlib._unitStrMap[Stdlib._unitMap[Stdlib._units]];
};
Stdlib.getDefaultRulerUnitsString = Stdlib.getDefaultUnitsString;

Stdlib.validateUnitValue = function(str, bu, ru) {
  var self = this;

  if (str instanceof UnitValue) {
    return str;
  }

  if (bu && bu.typename == "Document") {
    var doc = bu;
    ru = doc.width.type;
    bu = UnitValue(1/doc.resolution, ru);

  } else {
    if (!ru) {
      ru = Stdlib.getDefaultRulerUnitsString();
    }
    if (!bu) {
      UnitValue.baseUnit = UnitValue(1/72, ru);
    }
  }
  str = str.toString();

  var zero = new UnitValue("0 " + ru);
  var un = zero;
  if (!str.match(/[a-z%]+/)) {
    str += ' ' + ru.units;
  }
  un = new UnitValue(str);

  if (isNaN(un.value) || un.type == '?') {
    return undefined;
  }

  if (un.value == 0) {
    un = zero;
  }

  return un;
};

//
// Stdlib.getPixelValue
// Useful for converting strings input by a user into a pixel value.
// 'val' may be any valid UnitValue string.
//    Stdlib.getPixelValue(doc, "20 in")
//    Stdlib.getPixelValue(300, "20", undefined, "in")
//    Stdlib.getPixelValue(doc, "20%", 1200)
//    Stdlib.getPixelValue(doc, "20", 1200, '%')
//
Stdlib.getPixelValue = function(docRes, val, base, defaultUnits) {
  var res;
  if (val == undefined) {
    return Number.NaN;
  }
  if (val.constructor == Number) {
    val = val.toString();
  }
  if (val.constructor != String) {
    return Number.NaN;
  }
  if (docRes.constructor == Number) {
    res = docRes;
  } else {
    res = docRes.resolution;
  }

  val = val.trim();

  // convert val to a unit value

  if (!defaultUnits) {
    defaultUnits = Stdlib.getDefaultUnits();
  }

  var u = new UnitValue(val);
  if (u.type == '?') {
    var n = parseFloat(val);
    if (isNaN(n)) {
      return Number.NaN;
    }
    u = new UnitValue(n, defaultUnits);
  }

  // handle '%' manually
  if (u.type == '%') {
    u = new UnitValue(base * u.value / 100, "px");
  }

  var pxVal;

  // handle 'in' manually
  if (u.type == 'in') {
    pxVal = res * u.value;

  } else if (u.type == 'px') {
    pxVal = u.value;

  } else {
    u.baseUnit = new UnitValue(1/res, "in");
    pxVal = u.as("px");
  }

  return pxVal;
};

/*

var regex = /\-*\d*\.{0,1}\d* *(?:in|inch|inches|ft|foot|feet|yd|yard|yards|mi|mile|miles|mm|millimeter|millimeters|cm|centimeter|centimeters|m|meter|meters|km|kilometer|kilometers|pt|point|points|pc|pica|picas|ci|cicero|ciceros)?/gi;
var myMatch = myString.match( regex );
try {
  var fieldIsValid = ( myEvent.target.text == myEvent.target.text.match( regex )[ 0 ] );
} catch( e ) {
  var fieldIsValid = false;
}

*/


//
//============================= File Browser =================================
//
// This FileBrowser code works _only_ in PSCS
//

// get all the files in the file browser that are selected or flagged
// this code was lifted from Dr. Brown's Image Processor2.0.js
// and is copyrighted by Adobe

FileBrowser = function FileBrowser() {};

FileBrowser.getSelectedFiles = function() {
  return FileBrowser.getFiles(true, false);
};
FileBrowser.getFlaggedFiles = function() {
  return FileBrowser.getFiles(false, true);
};
FileBrowser.getFiles = function(selected, flagged) {
  var fileArray = new Array();
  var ffIndex = 0;

  var ref = new ActionReference();
  var fileBrowserStrID = sTID( "fileBrowser" );
  ref.putProperty( cTID( 'Prpr' ), fileBrowserStrID );
  ref.putEnumerated( cTID( 'capp' ), cTID( 'Ordn' ),
                     cTID( 'Trgt' ) );
  var desc = executeActionGet( ref );

  if ( desc.count > 0 && desc.hasKey( fileBrowserStrID ) ) {
    var fbDesc = desc.getObjectValue( fileBrowserStrID );
    var keyFilesList = cTID( 'flst' );

    if ( fbDesc.count > 0 && fbDesc.hasKey( keyFilesList ) ) {
      var fileList = fbDesc.getList( keyFilesList );
      var flaggedID = sTID( "flagged" );
      var selectedID = cTID( 'fsel' );
      var keyPath = cTID( 'Path' );

      for ( var i = 0; i < fileList.count; i++ ) {
        var fileDesc = fileList.getObjectValue( i );
        if ( fileDesc.count > 0 && fileDesc.hasKey( keyPath )) {
          if ( flagged == true && fileDesc.hasKey( flaggedID )
               && fileDesc.getBoolean( flaggedID )) {
            var fileOrFolder = fileDesc.getPath( keyPath );
            if ( fileOrFolder instanceof File ) {
              fileArray[ffIndex++] = fileOrFolder;
            }
          }

          // fixed so that a file will not be added twice if its flagged
          // and selected and both options are 'true'
          if ( flagged == true && fileDesc.hasKey( flaggedID )
               && fileDesc.getBoolean( flaggedID )) {
            var fileOrFolder = fileDesc.getPath( keyPath );
            if ( fileOrFolder instanceof File ) {
              fileArray[ffIndex++] = fileOrFolder;
            }
          } else if ( selected == true && fileDesc.hasKey( selectedID )
               && fileDesc.getBoolean( selectedID )) {
            var fileOrFolder = fileDesc.getPath( keyPath );
            if ( fileOrFolder instanceof File ) {
              fileArray[ffIndex++] = fileOrFolder;
            }
          }

          // if neither option is set, add everything
          if (selected != true && flagged != true) {
            var fileOrFolder = fileDesc.getPath( keyPath );
            if ( fileOrFolder instanceof File ) {
              fileArray[ffIndex++] = fileOrFolder;
            }
          }
        }
      }
    }
  }

  return fileArray;
};

//
// Set
//     these are a collection of functions for operating
//     on arrays as proper Set: each entry in the array
//     is unique in the array. This is useful for things
//     like doc.info.keywords
//
Set = function Set() {};
Set.add = function(ar, str) { return Set.merge(ar, new Array(str)); };
Set.remove = function(ar, str) {
  var nar = Set.copy(ar);
  for (var idx in nar) {
    if (nar[idx] == str) {
      nar.splice(idx, 1);
    }
  }
  return nar;
};
Set.contains = function(ar, str) {
  for (var idx in ar) {
    if (ar[idx] == str) {
      return true;
    }
  }
  return false;
};
Set.merge = function(ar1, ar2) {
  var obj = new Object();
  var ar = [];

  if (ar1 != undefined) {
    if (ar1 instanceof Array) {
      for (var i = 0; i < ar1.length; i++) {
        obj[ar1[i]] = 1;
      }
    } else {
      Error.runtimeError(19, "ar1");  // Bad Argument
    }
  }
  if (ar2 != undefined) {
    if (ar2 instanceof Array) {
      for (var i = 0; i < ar2.length; i++) {
        obj[ar2[i]] = 1;
      }
    } else {
      Error.runtimeError(19, "ar2");  // Bad Argument
    }
  }
  for (var idx in obj) {
    if (typeof (obj[idx]) != "function") {
      ar.push(idx);
    }
  }
  ar.sort();
  return ar;
}
Set.copy = function(ar) {
  return ar.slice(0);
};


ColorProfileNames = {};
ColorProfileNames.ADOBE_RGB      = "Adobe RGB (1998)";
ColorProfileNames.APPLE_RGB      = "Apple RGB";
ColorProfileNames.PROPHOTO_RGB   = "ProPhoto RGB";
ColorProfileNames.SRGB           = "sRGB IEC61966-2.1";
ColorProfileNames.COLORMATCH_RGB = "ColorMatch RGB";
ColorProfileNames.WIDEGAMUT_RGB  = "Wide Gamut RGB";

Stdlib.getProfileNameFromFile = function(file) {
  file.encoding = 'BINARY';
  file.open('r');
  var str = file.read();
  file.close();
  var m = str.match(/\x00desc\x00/);
  if (m == null) {
    // if we couldn't find the magic marker, return the base filename
    return file.name.replace(/\.ic(c|m)/i, '');
  }

  var ofs = m.index+12;
  var len = str.charCodeAt(ofs);
  var s = str.substring(ofs+1, ofs+len);
  return s;
};

// ColorProfileNames.KODAK_DC     = "KODAK DC Series Digital Camera";
// ColorProfileNames.MONITOR_SRGB = "Monitor - sRGB IEC61966-2.1";

Stdlib.getColorSettings = function() {
  var desc = Stdlib.getApplicationProperty(sTID("colorSettings"));
  return desc;
};

Timer = function() {
  var self = this;
  self.startTime = 0;
  self.stopTime  = 0;
  self.elapsed = 0;
  self.cummulative = 0;
  self.count = 0;
};

Timer.prototype.start = function() {
  this.startTime = new Date().getTime();
};
Timer.prototype.stop = function() {
  var self = this;
  self.stopTime = new Date().getTime();
  self.elapsed = (self.stopTime - self.startTime)/1000.00;
  self.cummulative += self.elapsed;
  self.count++;
  self.per = self.cummulative/self.count;
};

Stdlib.decimalPoint = ($.decimalPoint || '.');

//========================= String formatting ================================
//
// String.sprintf
//
// Documentation:
//   http://www.opengroup.org/onlinepubs/007908799/xsh/fprintf.html
//
// From these sites:
//   http://forums.devshed.com/html-programming-1/sprintf-39065.html
//   http://jan.moesen.nu/code/javascript/sprintf-and-printf-in-javascript/
//
String.prototype.sprintf = function() {
  var args = [this];
  for (var i = 0; i < arguments.length; i++) {
    args.push(arguments[i]);
  }
  return String.sprintf.apply(null, args);
};
String.sprintf = function() {
  function _sprintf() {
    if (!arguments || arguments.length < 1 || !RegExp)  {
      return "Error";
    }
    var str = arguments[0];
    var re = /([^%]*)%('.|0|\x20)?(-)?(\d+)?(\.\d+)?(%|b|c|d|u|f|o|s|x|X)/m;
            //') /* for xemacs auto-indent  */
    var a = b = [], numSubstitutions = 0, numMatches = 0;
    var result = '';

    while (a = re.exec(str)) {
      var leftpart = a[1], pPad = a[2], pJustify = a[3], pMinLength = a[4];
      var pPrecision = a[5], pType = a[6], rightPart = a[7];

      rightPart = str.slice(a[0].length);

      numMatches++;

      if (pType == '%') {
        subst = '%';
      } else {
        numSubstitutions++;
        if (numSubstitutions >= arguments.length) {
          alert('Error! Not enough function arguments (' +
                (arguments.length - 1)
                + ', excluding the string)\n'
                + 'for the number of substitution parameters in string ('
                + numSubstitutions + ' so far).');
        }
        var param = arguments[numSubstitutions];
        var pad = '';
        if (pPad && pPad.slice(0,1) == "'") {
          pad = leftpart.slice(1,2);
        } else if (pPad) {
          pad = pPad;
        }
        var justifyRight = true;
        if (pJustify && pJustify === "-") {
          justifyRight = false;
        }
        var minLength = -1;
        if (pMinLength) {
          minLength = toNumber(pMinLength);
        }
        var precision = -1;
        if (pPrecision && pType == 'f') {
          precision = toNumber(pPrecision.substring(1));
        }
        var subst = param;
        switch (pType) {
        case 'b':
          subst = toNumber(param).toString(2);
          break;
        case 'c':
          subst = String.fromCharCode(toNumber(param));
          break;
        case 'd':
          subst = toNumber(param) ? Math.round(toNumber(param)) : 0;
            break;
        case 'u':
          subst = Math.abs(Math.round(toNumber(param)));
          break;
        case 'f':
          if (precision == -1) {
            precision = 6;
          }
          subst = parseFloat(param).toFixed(Math.min(precision, 20));
          subst = subst.replace('.', Stdlib.decimalPoint);
//             ? Math.round(parseFloat(param) * Math.pow(10, precision))
//             / Math.pow(10, precision)
//             : ;
            break;
        case 'o':
          subst = toNumber(param).toString(8);
          break;
        case 's':
          subst = param;
          break;
        case 'x':
          subst = ('' + toNumber(param).toString(16)).toLowerCase();
          break;
        case 'X':
          subst = ('' + toNumber(param).toString(16)).toUpperCase();
          break;
        }
        var padLeft = minLength - subst.toString().length;
        if (padLeft > 0) {
          var arrTmp = new Array(padLeft+1);
          var padding = arrTmp.join(pad?pad:" ");
        } else {
          var padding = "";
        }
      }
      result += leftpart + padding + subst;
      str = rightPart;
    }
    result += str;
    return result;
  };

  return _sprintf.apply(null, arguments);
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
Date.prototype.strftime = function (fmt) {
  return Date.strftime(this, fmt);
};

// Class Function
Date.strftime = function(date, fmt) {
  var t = date;
  var cnvts = Date.prototype.strftime._cnvt;
  var str = fmt;
  var m;
  var rex = /([^%]*)%([%aAbBcCdDehHIjmMprRStTuwxXyYZ]{1})(.*)/;

  var result = '';
  while (m = rex.exec(str)) {
    var pre = m[1];
    var typ = m[2];
    var post = m[3];
    result += pre + cnvts[typ](t);
    str = post;
  }
  result += str;
  return result;
};

// some ISO8601 formats
Date.strftime.iso8601_date = "%Y-%m-%d";
Date.strftime.iso8601_full = "%Y-%m-%dT%H:%M:%S";
Date.strftime.iso8601      = "%Y-%m-%d %H:%M:%S";
Date.strftime.iso8601_time = "%H:%M:%S";

Date.prototype.toISO = function() {
  return this.strftime(Date.strftime.iso8601);
};


// the specifier conversion function table
Date.prototype.strftime._cnvt = {
  zeropad: function( n ){ return n>9 ? n : '0'+n; },
  spacepad: function( n ){ return n>9 ? n : ' '+n; },
  ytd: function(t) {
    var first = new Date(t.getFullYear(), 0, 1).getTime();
    var diff = t.getTime() - first;
    return parseInt(((((diff/1000)/60)/60)/24))+1;
  },
  a: function(t) {
    return ['Sun','Mon','Tue','Wed','Thu','Fri','Sat'][t.getDay()];
  },
  A: function(t) {
    return ['Sunday','Monday','Tuesdsay','Wednesday','Thursday','Friday',
            'Saturday'][t.getDay()];
  },
  b: function(t) {
    return ['Jan','Feb','Mar','Apr','May','Jun', 'Jul','Aug','Sep','Oct',
            'Nov','Dec'][t.getMonth()]; },
  B: function(t) {
    return ['January','February','March','April','May','June', 'July','August',
            'September','October','November','December'][t.getMonth()]; },
  c: function(t) {
    return (this.a(t) + ' ' + this.b(t) + ' ' + this.e(t) + ' ' +
            this.H(t) + ':' + this.M(t) + ':' + this.S(t) + ' ' + this.Y(t));
  },
  C: function(t) { return this.Y(t).slice(0, 2); },
  d: function(t) { return this.zeropad(t.getDate()); },
  D: function(t) { return this.m(t) + '/' + this.d(t) + '/' + this.y(t); },
  e: function(t) { return this.spacepad(t.getDate()); },
  // E: function(t) { return '-' },
  F: function(t) { return this.Y(t) + '-' + this.m(t) + '-' + this.d(t); },
  g: function(t) { return '-'; },
  G: function(t) { return '-'; },
  h: function(t) { return this.b(t); },
  H: function(t) { return this.zeropad(t.getHours()); },
  I: function(t) {
    var s = this.zeropad((t.getHours() + 12) % 12);
    return (s == "00") ? "12" : s;
  },
  j: function(t) { return this.ytd(t); },
  k: function(t) { return this.spacepad(t.getHours()); },
  l: function(t) {
    var s = this.spacepad((t.getHours() + 12) % 12);
    return (s == " 0") ? "12" : s;
  },
  m: function(t) { return this.zeropad(t.getMonth()+1); }, // month-1
  M: function(t) { return this.zeropad(t.getMinutes()); },
  n: function(t) { return '\n'; },
  // O: function(t) { return '-' },
  p: function(t) { return this.H(t) < 12 ? 'AM' : 'PM'; },
  r: function(t) {
    return this.I(t) + ':' + this.M(t) + ':' + this.S(t) + ' ' + this.p(t);
  },
  R: function(t) { return this.H(t) + ':' + this.M(t); },
  S: function(t) { return this.zeropad(t.getSeconds()); },
  t: function(t) { return '\t'; },
  T: function(t) {
    return this.H(t) + ':' + this.M(t) + ':' + this.S(t) + ' ' + this.p(t);
  },
  u: function(t) {return t.getDay() ? t.getDay()+1 : 7; },
  U: function(t) { return '-'; },
  w: function(t) { return t.getDay(); }, // 0..6 == sun..sat
  W: function(t) { return '-'; },       // not available
  x: function(t) { return this.D(t); },
  X: function(t) { return this.T(t); },
  y: function(t) { return this.zeropad(this.Y(t) % 100); },
  Y: function(t) { return t.getFullYear().toString(); },
  z: function(t) { return ''; },
  Z: function(t) { return ''; },
  '%': function(t) { return '%'; }
};

// this needs to be worked on...
function _weekNumber(date) {
  var ytd = toNumber(date.strftime("%j"));
  var week = Math.floor(ytd/7);
  if (new Date(date.getFullYear(), 0, 1).getDay() < 4) {
    week++;
  }
  return week;
};

File.prototype.toUIString = function() {
  return decodeURI(this.fsName);
};
Folder.prototype.toUIString = function() {
  return decodeURI(this.fsName);
};

File.prototype.asString = File.prototype.toUIString; // deprecated

//========================= Filename formatting ===============================
//
// File.strf(fmt [, fs])
// Folder.strf(fmt [, fs])
//   This is based on the file name formatting facility in exiftool. Part of
//   the description is copied directly from there. You can find exiftool at:
//      http://www.sno.phy.queensu.ca/~phil/exiftool/
//
// Description:
//   Format a file string using a printf-like format string
//
// fmt is a string where the following substitutions occur
//   %d - the directory name (no trailing /)
//   %f - the file name without the extension
//   %e - the file extension without the leading '.'
//   %p - the name of the parent folder
//   %% - the '%' character
//
// if fs is true the folder is in local file system format
//   (e.g. C:\images instead of /c/images)
//
// Examples:
//
// Reformat the file name:
// var f = new File("/c/work/test.jpg");
// f.strf("%d/%f_%e.txt") == "/c/work/test_jpg.txt"
//
// Change the file extension
// f.strf("%d/%f.psd") == "/c/work/test.psd"
//
// Convert to a file name in a subdirectory named after the extension
// f.strf("%d/%e/%f.%e") == "/c/work/jpg/test.jpg"
//
// Change the file extension and convert to a file name in a subdirectory named
//   after the new extension
// f.strf("%d/psd/%f.psd") == "/c/work/psd/test.psd"
//
// var f = new File("~/.bashrc");
// f.strf("%f") == ".bashrc"
// f.strf("%e") == ""
//
// Advanced Substitution
//   A substring of the original file name, directory or extension may be
//   taken by specifying a string length immediately following the % character.
//   If the length is negative, the substring is taken from the end. The
//   substring position (characters to ignore at the start or end of the
//   string) may be given by a second optional value after a decimal point.
// For example:
//
// var f = new File("Picture-123.jpg");
//
// f.strf("%7f.psd") == "Picture.psd"
// f.strf("%-.4f.psd") == "Picture.psd"
// f.strf("%7f.%-3f") == "Picture.123"
// f.strf("Meta%-3.1f.xmp") == "Meta12.xmp"
//
File.prototype.strf = function(fmt, fs) {
  var self = this;
  var name = decodeURI(self.name);
  //var name = (self.name);

  // get the portions of the full path name

  // extension
  var m = name.match(/.+\.([^\.\/]+)$/);
  var e = m ? m[1] : '';

  // basename
  m = name.match(/(.+)\.[^\.\/]+$/);
  var f = m ? m[1] : name;

  fs |= !($.os.match(/windows/i)); // fs only matters on Windows
  // fs |= isMac();

  // full path...
  var d = decodeURI((fs ? self.parent.fsName : self.parent.absoluteURI));

  // parent directory...
  var p = decodeURI(self.parent.name);

  //var p = ((fs ? self.parent.fsName : self.parent.toString()));

  var str = fmt;

  // a regexp for the format specifiers

  var rex = /([^%]*)%(-)?(\d+)?(\.\d+)?(%|d|e|f|p)(.*)/;

  var result = '';

  while (m = rex.exec(str)) {
    var pre = m[1];
    var sig = m[2];
    var len = m[3];
    var ign = m[4];
    var typ = m[5];
    var post = m[6];

    var subst = '';

    if (typ == '%') {
      subst = '%';

    } else {
      var s = '';
      switch (typ) {
        case 'd': s = d; break;
        case 'e': s = e; break;
        case 'f': s = f; break;
        case 'p': s = p; break;
        // default: s = "%" + typ; break; // let others pass through
      }

      var strlen = s.length;

      if (strlen && (len || ign)) {
        ign = (ign ? Number(ign.slice(1)) : 0);
        if (len) {
          len = Number(len);
          if (sig) {
            var _idx = strlen - len - ign;
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
};
Folder.prototype.strf = File.prototype.strf;


//========================= GPS formatting ===============================
/*
  Stdlib.strfGPSstr([fmtStr], gpsStr);

  From the exiftool documentation:
  Set the print format for GPS coordinates. FMT uses the same syntax as the
  printf format string. The specifiers correspond to degrees, minutes and
  seconds in that order, but minutes and seconds are optional. For example,
  the following table gives the output for the same coordinate using various
  formats:

                FMT                  Output
        -------------------    ------------------
        "%d deg %d' %.2f"\"    54 deg 59' 22.80"   (the default)
        "%d deg %.4f min"      54 deg 59.3800 min
        "%.6f degrees"         54.989667 degrees

The common degree marker is a Unicode literal of \u00B0
*/
//
// Test cases
//
/*
Stdlib.strfGPSstr(undefined, "54.00 59.00' 22.80\"");
Stdlib.strfGPSstr(undefined, "28.00 9.97' 0.00\"");
Stdlib.strfGPSstr("%d deg %.4f min", "28.00 9.97' 0.00\"");
Stdlib.strfGPSstr("%d deg %.4f min", "28.00 9.50' 0.00\"");
Stdlib.strfGPSstr(undefined, "28.00 9.50' 0.00\"");
Stdlib.strfGPSstr("%f", "28.00 9.97' 0.00\"");
Stdlib.strfGPSstr("%f", "28.50 0.00' 0.00\"");
Stdlib.strfGPSstr(undefined, "28.50 0.00' 0.00\"");
Stdlib.strfGPSstr(undefined, "54,59,22");
Stdlib.strfGPSstr(undefined, "54,59.22");
Stdlib.strfGPSstr("%d deg %.4f min", "54,59.22");
Stdlib.strfGPSstr(undefined, "54 59 22");
Stdlib.strfGPSstr(undefined, "54.00 deg 59.00 min 22.23 secs");
*/
//

Stdlib.DEFAULT_GPS_FORMAT = "%d deg %d' %.2f\"";

Stdlib.strfGPSstr = function(fmtStr, gpsStr) {

  // This is the most likely format
  var r = gpsStr.match(/(\d+\.\d+) (\d+\.\d+)\' (\d+\.\d+)\"/);

  // This is the format from the XMP Schema spec
  if (!r) {
    var r2 = r = gpsStr.match(/(\d+)\,(\d+)(\,|\.)(\d+)/);
  }

  // This format should pick up just about anything else
  if (!r) {
    var rex = /(\d+(?:\.\d+)?)[^\d\.]+(\d+(?:\.\d+)?)[^\d\.]+(\d+(?:\.\d+)?)/;
    var r3 = r = gpsStr.match(rex);
  }

  if (!r) {
    return fmtStr;
  }

  // if we matched either the first or third patterns
  if (!r2) {
    var d = Number(r[1]);
    var m = Number(r[2]);
    var s = Number(r[3]);

    var xm = (d - Math.floor(d)) * 60;
    var xs = (m - Math.floor(m)) * 60;

    m += s/60;
    d += m/60;
    if (s == 0) {
      s = xs;
    }
    if (m == 0) {
      m = xm;
    }

    return Stdlib.strfGPS(fmtStr, d, m, s);
  }

  if (r2) {
    var d = Number(r[1]);

    var sep = r[3];

    if (sep == '.') {
      var m = Number(r[2]);
      var s = Number("0." + r[4]) * 60;

    } else {
      var m = Number(r[2]);
      var s = Number(r[4]);
    }
    return Stdlib.strfGPS(fmtStr, d, m, s);
  }

  // if we can't figure out what's going on, just return the format spec
  return fmtStr;
};

Stdlib.strfGPS = function(fmtStr, deg, min, sec) {
  if (sec == undefined) {
    sec = 0;
  }
  if (min == undefined) {
    min = 0;
  }
  if (min == Math.floor(min)) {
    min += sec/60;
  }
  if (deg == Math.floor(deg)) {
    deg += min/60;
  }
  if (fmtStr == undefined) {
    fmtStr = Stdlib.DEFAULT_GPS_FORMAT;
  }

  return String.sprintf(fmtStr, deg, min, sec);
};


//
// Stdlib.getXMPValue(obj, tag)
//
// Get the XMP value for (tag) from the object (obj).
// obj can be a String, XML, File, or Document object.
//
// Some non-simple metadata fields, such as those with
// Seq structures are not handled, except for ISOSpeedRatings
// which is handled as a special case. Others can be added as needed.
//
// Based on getXMPTagFromXML from Adobe's StackSupport.jsx
//
// Examples:
// Stdlib.getXMPValue(xmlStr, "ModifyDate")
// Stdlib.getXMPValue(app.activeDocument, "ModifyDate")
// Stdlib.getXMPValue(xmlObj, "ModifyDate")
// Stdlib.getXMPValue(File("~/Desktop/test.jpg"), "ModifyDate")
//
Stdlib.getXMPValue = function(obj, tag) {
  var xmp = "";

  if (obj == undefined) {
    Error.runtimeError(2, "obj");
  }

  if (tag == undefined) {
    Error.runtimeError(2, "tag");
  }

  if (obj.constructor == String) {
    xmp = new XML(obj);

  } else if (obj.typename == "Document") {
    xmp = new XML(obj.xmpMetadata.rawData);

  } else if (obj instanceof XML) {
    xmp = obj;

  } else if (obj instanceof File) {
    if (!ExternalObject.AdobeXMPScript) {
      ExternalObject.AdobeXMPScript = new ExternalObject('lib:AdobeXMPScript');
    }
    // Stdlib.loadXMPScript();

    if (tag == "CreateDate") {
      var cstr = obj.created.toISODateString();
      var mstr = Stdlib.getXMPValue(obj, "ModifyDate");
      return cstr += mstr.slice(mstr.length-6);
    }

    // add other exceptions here as needed

    var fstr = decodeURI(obj.fsName);
    var xmpFile = undefined;

    try {
      xmpFile = new XMPFile(fstr, XMPConst.UNKNOWN,
                            XMPConst.OPEN_FOR_READ);
    } catch (e) {
      try {
        xmpFile = new XMPFile(fstr, XMPConst.UNKNOWN,
                              XMPConst.OPEN_USE_PACKET_SCANNING);
      } catch (e) {
        Error.runtimeError(19, "obj");
      }
    }

    var xmpMeta = xmpFile.getXMP();
    var str = xmpMeta.serialize()
    xmp = new XML(str);
    xmpFile.closeFile();

  } else {
    Error.runtimeError(19, "obj");
  }

	var s;
	
	// Handle special cases here
	if (tag == "ISOSpeedRatings") {
		s = String(eval("xmp.*::RDF.*::Description.*::ISOSpeedRatings.*::Seq.*::li"));

  }	else {
    // Handle typical non-complex fields
 		s = String(eval("xmp.*::RDF.*::Description.*::" + tag));
  }

  return s;
};

Stdlib.removeXMPData = function(fptr) {
  fptr = Stdlib.convertFptr(fptr);
  
  var f = new XMPFile(fptr.fsName, XMPConst.UNKNOWN, XMPConst.OPEN_FOR_UPDATE);
  var xmp = f.getXMP();

  XMPUtils.removeProperties(xmp, "", "", XMPConst.REMOVE_ALL_PROPERTIES);

  if (f.canPutXMP(xmp)) {
    f.putXMP( xmp );
  }
  f.closeFile(XMPConst.CLOSE_UPDATE_SAFELY);
}

// This only works in CS4+
Stdlib.loadXMPScript = function() {
  if (CSVersion() < 4) {
    Error.runtimeError(Stdlib.ERROR_CODE, "XMPScript required");
  }

  if (!ExternalObject.AdobeXMPScript) {
    ExternalObject.AdobeXMPScript = new ExternalObject('lib:AdobeXMPScript');
  }
};

// This only works in CS4+
Stdlib.unloadXMPScript = function() {
  if (CSVersion() < 4) {
    Error.runtimeError(Stdlib.ERROR_CODE, "XMPScript required");
  }

  if (ExternalObject.AdobeXMPScript) {
    ExternalObject.AdobeXMPScript.unload();
    ExternalObject.AdobeXMPScript = undefined;
  }
};

/*
Stdlib.{to/from}Descriptor should be updated to handle LargeInteger
if there is not a decimal point.

d = Stdlib.toDescriptor({
  name: "test",
  num: 22,
  flag: true
});
o = Stdlib.fromDescriptor(d);
*/
Stdlib.toDescriptor = function(obj) {
  if (arguments.length != 1) {
    Error.runtimeError(1221, "obj"); // wrong number of arguments
  }
  if (obj == undefined) {
    Error.runtimeError(2, "obj");    // undefined
  }
  if (typeof(obj) != "object") {
    Error.runtimeError(21, "obj");   // is not an object
  }

  var nameID = cTID("nm  ");
  var valueID = cTID("Vl  ");
  var componentID = sTID("component");

  function addProperty(desc, nm, val) {
    var typ = typeof(val);

    var pdesc = new ActionDescriptor();
    pdesc.putString(nameID, nm);

    switch (typ) {
      case "number": {
        pdesc.putDouble(valueID, val);
        break;
      }
      case "string": {
        pdesc.putString(valueID, val);
        break;
      }
      case "boolean": {
        pdesc.putBoolean(valueID, val);
        break;
      }
      case "object": {
        pdesc.putString(valueID, val.toString());
        break;
      }
      case "undefined": pdesc = undefined; break;
      case "function":  pdesc = undefined; break;
      default:          pdesc = undefined; break;
    };
    desc.putObject(sTID(nm), componentID, pdesc);
  };

  var desc = new ActionDescriptor();

  for (var idx in obj) {
    if (idx.startsWith("_")) {
      continue;
    }
    var val = obj[idx];
    if (val || typeof(val) == "undefined" || typeof(val) == "function") {
      continue;
    }

    addProperty(desc, idx, val);
  }

  return desc;
};

Stdlib.fromDescriptor = function(desc, obj) {
  if (arguments.length < 1 || arguments.length > 2) {
    Error.runtimeError(1221);        // wrong number of arguments
  }
  if (desc == undefined) {
    Error.runtimeError(2, "desc");   // is undefined
  }
  if (typeof(desc) != "object") {
    Error.runtimeError(21, "desc");   // is not an object
  }
  if (!(desc instanceof ActionDescriptor)) {
    Error.runtimeError(1330);         // Invalid Type
  }

  var nameID = cTID("nm  ");
  var valueID = cTID("Vl  ");

  if (!obj) {
    obj = {};
  }

  function getPropertyValue(pdesc) {
    var typ = pdesc.getType(valueID);
    var val = undefined;

    switch (typ) {
      case DescValueType.DOUBLETYPE: {
        val = pdesc.getDouble(valueID);
        break;
      };
      case DescValueType.INTEGERTYPE: {
        val = pdesc.getInteger(valueID);
        break;
      };
      case DescValueType.STRINGTYPE: {
        val = pdesc.getString(valueID);
        break;
      };
      case DescValueType.BOOLEANTYPE: {
        val = pdesc.getBoolean(valueID);
        break;
      };
    };
    return val;
  };

  for (var i = 0; i < desc.count; i++) {
    var key = desc.getKey(i);
    var nm = desc.getString(nameID);
    var val = getPropertyValue(desc);
    if (val != undefined) {
      obj[nm] = val;
    }
  }

  return obj;
};

function toBoolean(s) {
  if (s == undefined) { return false; }
  if (s.constructor == Boolean) { return s.valueOf(); }
  try { if (s instanceof XML) s = s.toString(); } catch (e) {}
  if (s.constructor == String)  { return s.toLowerCase() == "true"; }

  return Boolean(s);
};

function isBoolean(s) {
  return (s != undefined && s.constructor == Boolean);
}

function toNumber(s, def) {
  if (s == undefined) { return def || NaN; }
  try { if (s instanceof XML) s = s.toString(); } catch (e) {}
  if (s.constructor == String && s.length == 0) { return def || NaN; }
  if (s.constructor == Number) { return s.valueOf(); }
  var n = Number(s.toString());
  return (isNaN(n) ? (def || NaN) : n);
};

function isNumber(s) {
  try { if (s instanceof XML) s = s.toString(); } catch (e) {}
  return !isNaN(s);
};

function isString(s) {
  return (s != undefined && s.constructor == String);
};

function toFont(fs) {
  if (fs.typename == "TextFont") { return fs.postScriptName; }

  var str = fs.toString();
  var f = Stdlib.determineFont(str);  // first, check by PS name

  return (f ? f.postScriptName : undefined);
};



Stdlib.objectToXML = function(obj, name, xml) {
  if (!xml) {
    if (name == undefined) {
      name = "Object";
    }
    xml = new XML('<' + name + "></" + name + '>');
    // do the eval because of non-CS/2 syntax
    eval('xml.@type = (obj instanceof Array) ? "array" : "object"');
  }

  function _addChild(xml, obj, idx) {
    var val = obj[idx];

    var isArray = (obj instanceof Array);

    // skip 'hidden' properties
    if (idx.toString()[0] == '_') {
      return undefined;
    }

    // just skip undefined values
    if (val == undefined) {
      return undefined;
    }
    var type = typeof val;

    var child;

    if (isNumber(idx)) {
      idx = xml.localName() + idx;
    }

    switch (type){
      case "number":
      case "boolean":
      case "string":
        child = new XML('<' + idx + "></" + idx + '>');
        child.appendChild(val);
        // do the eval because of non-CS/2 syntax
        eval('child.@type = type');
      break;

      case "object":
        child = Stdlib.objectToXML(val, idx);
      break;

      default:
        return undefined;
       break;
    }

    xml.appendChild(child);
  };

  if (obj instanceof Array) {
    for (var i = 0; i < obj.length; i++) {
      _addChild(xml, obj, i);
    }
  } else {
    for (var idx in obj) {
      _addChild(xml, obj, idx);
    }
    if (xml.children().length() == 0) {
      xml.appendChild(obj.toString());
      // do the eval because of non-CS/2 syntax
      eval('xml.@type = "string"');
    }
  }

  return xml;
};
Stdlib.xmlToObject = function(xml, obj, parent) {
  if (xml.constructor == String) {
    xml = new XML(xml);
  } else if (xml instanceof XML) {
    xml = xml.copy();
  } else {
    Error.runtimeError(2, "xml");
  }

  xml.normalize();

  if (xml.hasSimpleContent()) {
    var str = xml.toString();
    if (parent) {
      parent[xml.localName()] = str;
    }
    return str;
  }

  var type;
  // do the eval because of non-CS/2 syntax
  eval('type = xml.@type.toString()');

  if (type == 'array') {
    obj = [];
  } else {
    obj = {};
  }

  var els = xml.elements();
  var len = els.length();
  if (len > 0) {
    for (var i = 0; i < len; i++) {
      var child = els[i];
      var val = '';
      var idx = (type == 'array') ? i : child.localName();

      if (child.hasComplexContent()) {
        val = Stdlib.xmlToObject(child);
      }

      if (child.hasSimpleContent()) {
        var ctype;
        // do the eval because of non-CS/2 syntax
        eval('ctype = child.@type.toString()');
        val = child.text().toString();

        if (val) {
          if (ctype == 'number') {
            val = Number(val);
          }
          if (ctype == 'boolean') {
            val = val.toLowerCase() == 'true';
          }
        }
      }

      obj[idx] = val;
    }
  } else {
    obj = xml.toString();
  }

  if (parent) {
    parent[xml.localName()] = obj;
  }

  return obj;
};


/*
function _xmlTest() {
  var
  obj = {
    str: 'A String',
    num: 123,
    bool: true,
    inner: {
      inStr: 'string 2',
      n: 231231,
      opts: SaveOptions.DONOTSAVECHANGES
    },
    ary: ['black', 'blue', 'red', { test: 'green'}]
  };
  var xml = Stdlib.objectToXML(obj, 'Preferences');
  xml.toXMLString();
  var xobj = Stdlib.xmlToObject(xml);
  return xobj;
};
*/

Stdlib.openURL = function(url) {
  var fname = "shortcut.url";
  var shortcut = new File(Folder.temp + '/' + fname);
  shortcut.open('w');
  shortcut.writeln('[InternetShortcut]');
  shortcut.writeln('URL=' + url);
  shortcut.writeln();
  shortcut.close();
  shortcut.execute();
  shortcut.remove();
};

"stdlib.js";
// EOF

//
// GenericUI
// This is a lightweight UI framework. All of the common code that you
// need to write for a ScriptUI-based application is abstracted out here.
//
// $Id: XWatermark.jsx,v 1.74 2015/12/03 22:01:33 anonymous Exp $
// Copyright: (c)2005, xbytor
// License: http://www.opensource.org/licenses/bsd-license.php
// Contact: xbytor@gmail.com
//

isPhotoshop = function() {
  return !!app.name.match(/photoshop/i);
};
isBridge = function() {
  return !!app.name.match(/bridge/i);
};
isInDesign = function() {
  return !!app.name.match(/indesign/i);
};
isESTK = function() {
  return !!app.name.match(/estoolkit|ExtendScript Toolkit/i);
};
isPhotoshopElements = function() {
  return !!BridgeTalk.appName.match(/pseeditor/i);
};
isPSE = isPhotoshopElements;

_initVersionFunctions = function() {
  if (isPhotoshop()) {
    CSVersion = function() {
      return toNumber(app.version.match(/^\d+/)[0]) - 7;
    };
    CSVersion._version = CSVersion();

    isCS6 = function()  { return app.version.match(/^13\./); };
    isCS5 = function()  { return app.version.match(/^12\./); };
    isCS4 = function()  { return app.version.match(/^11\./); };
    isCS3 = function()  { return app.version.match(/^10\./); };
    isCS2 = function()  { return app.version.match(/^9\./); };
    isCS  = function()  { return app.version.match(/^8\./); };
    isPS7 = function()  { return app.version.match(/^7\./); };

  } else {
    var appName = BridgeTalk.appName;
    var version = BridgeTalk.appVersion;

    if (isPSE()) {
      isCS5 = function()  { return false; };
      isCS4 = function()  { return true; };
      isCS3 = function()  { return false; };
      isCS2 = function()  { return false; };
      isCS  = function()  { return false; };
      isPS7 = function()  { return false; };
    }
    if (isBridge()) {
      isCS6 = function()  { return version.match(/^5\./); };
      isCS5 = function()  { return version.match(/^4\./); };
      isCS4 = function()  { return version.match(/^3\./); };
      isCS3 = function()  { return version.match(/^2\./); };
      isCS2 = function()  { return version.match(/^1\./); };
      isCS  = function()  { return false; };
      isPS7 = function()  { return false; };

    } else if (isInDesign()) {
      isCS6 = function()  { return false; };
      isCS5 = function()  { return false; };
      isCS4 = function()  { return false; };
      isCS3 = function()  { return version.match(/^5\./); };
      isCS2 = function()  { return version.match(/^4\./); };
      isCS  = function()  { return false; };
      isPS7 = function()  { return false; };

    } else if (isESTK()) {
      isCS6 = function()  { return version.match(/^3\.8/); };
      isCS5 = function()  { return version.match(/^3\.5/); };
      isCS4 = function()  { return version.match(/^3\./); };
      isCS3 = function()  { return version.match(/^2\./); };
      isCS2 = function()  { return version.match(/^1\./); };
      isCS  = function()  { return false; };
      isPS7 = function()  { return false; };

    } else {
      isCS6 = function()  { Error.runtimeError(9001,
                                               "Unsupported application"); };
      isCS5 = function()  { Error.runtimeError(9001,
                                               "Unsupported application"); };
      isCS4 = function()  { Error.runtimeError(9001,
                                               "Unsupported application"); };
      isCS3 = function()  { Error.runtimeError(9001,
                                               "Unsupported application"); };
      isCS2 = function()  { Error.runtimeError(9001,
                                               "Unsupported application"); };
      isCS  = function()  { Error.runtimeError(9001,
                                               "Unsupported application"); };
      isPS7 = function()  { Error.runtimeError(9001,
                                               "Unsupported application"); };
    }
  }
};

var isCS3;
if (!isCS3 || !isPhotoshop())  {
  _initVersionFunctions();
}

//
// GenericUI is the core class for this framework.
//
GenericUI = function() {
  var self = this;

  self.title = "GenericUI";  // the window title
  self.notesSize = 50;       // the height of the Notes text panel
                             // set to 0 to disable
  self.winRect = {           // the rect for the window
    x: 200,
    y: 200,
    w: 100,
    h: 200
  };
  self.documentation = "This is a Photoshop JavaScript script";

  self.iniFile = undefined; // the name of the ini file used for this script
  self.saveIni = true;      // Set to 'undefined' to disable saving  to the
                            // ini file
  self.hasBorder = true;

  self.windowType = 'dialog'; // 'palette';

  self.notesTxt   = 'Notes:';
  self.processTxt = 'Process';
  self.cancelTxt  = 'Cancel';

  self.buttonOneTxt = undefined;
  self.buttonTwoTxt = undefined;

  self.settingsPanel = false;
  self.optionsClass = undefined;
  self.win = undefined;
  self.window = undefined;
  self.doc = undefined;
  self.ini = undefined;

  self.setDefault = !isCS();

  self._logDebug = false;

  self.parentWin = undefined;

  self.windowCreationProperties = undefined;

  self.buttonWidth = 90;

  self.xmlEnabled = false;

  self.windowType = 'dialog';
};

GenericUI.getTextOfs = function() {
  return (CSVersion() > 2) ? 3 : 0;
};

//
// Returns the xtools preferences folder
//
GenericUI._getPreferencesFolder = function() {
  var userData = Folder.userData;

  if (!userData || !userData.exists) {
    userData = Folder("~");
  }

  var folder = new Folder(userData + "/xtools");

  if (!folder.exists) {
    folder.create();
  }

  return folder;
};

isWindows = function() {
  return !!$.os.match(/windows/i);
};
isMac = function() {
  return !isWindows();
};

GenericUI.ENCODING = "LATIN1";

GenericUI.preferencesFolder = GenericUI._getPreferencesFolder();
GenericUI.PREFERENCES_FOLDER = GenericUI.preferencesFolder;

GenericUI.prototype.isPalette = function() {
  return this.windowType == 'palette';
};
GenericUI.prototype.isDialog = function() {
  return this.windowType == 'dialog';
};

//
// createWindow constructs a window with a documentation panel and a app panel
// and 'Process' and 'Cancel' buttons. 'createPanel' (implemented by the app
// script) is invoked by this method to create the app panel.
//
GenericUI.prototype.createWindow = function(ini, doc) {
  var self = this;
  var wrect = self.winRect;

  function rectToBounds(r) {
    return[r.x, r.y, r.x+r.w, r.y+r.h];
  };
  var win = new Window(self.windowType, self.title, rectToBounds(wrect),
                       self.windowCreationProperties);

  win.mgr = self;  // save a ref to the UI manager
  win.ini = ini;
  if (!self.ini) {
    self.ini = win.ini;
  }
  self.window = self.win = win;
  self.doc = doc;

  var xOfs = 10;
  var yy = 10;

  var hasButtons = (self.processTxt || self.cancelTxt ||
                    self.buttonOneTxt || self.buttonTwoTxt);

  var hasNotesPanel = (self.notesSize && self.documentation);

  if (hasNotesPanel) {
    // define the notes panel (if needed) and insert the documentation text
    var docPnl = win.add('panel',
                         [xOfs, yy, wrect.w-xOfs, self.notesSize+10],
                         self.notesTxt);

    var y = (isCS() ? 20 : 10);
    var ymax = (isCS() ? self.notesSize-10 : self.notesSize-20);
    var docs = self.documentation;

    if (CSVersion() > 2) {
      docs = docs.replace(/&/g, '&&');
    }
    docPnl.add('statictext',
               [10,y,docPnl.bounds.width-10,ymax],
               docs,
               {multiline:true});

    yy += self.notesSize + 10;
  }

  var appBottom = wrect.h - 10;
  if (self.settingsPanel) {
    appBottom -=  70;
  }
  if (hasButtons) {
    appBottom -=  50;
  }

  // Now, create the application panel
  var pnlType = 'panel';
  if (!isCS()) {
    pnlType = (self.hasBorder ? 'panel' : 'group');
  }
  win.appPnl = win.add(pnlType, [xOfs, yy, wrect.w-xOfs, appBottom]);

  win.appPanel = win.appPnl;

  yy = appBottom + 10;

  // and call the application callback function with the ini object
  self.createPanel(win.appPnl, ini, doc);

  // Settings Panel
  if (self.settingsPanel) {
    win.settingsPnl = win.add('panel', [xOfs,yy,wrect.w-xOfs,yy+60]);
    win.settingsPnl.text = 'Settings';
    self.createSettingsPanel(win.settingsPnl, ini);
  }

  if (hasButtons) {
    // Create the Process/Cancel buttons
    var btnY = wrect.h - 40;
    var btnW = self.buttonWidth;
    var btnOfs;

    var btns = ['processTxt', 'cancelTxt', 'buttonOneTxt', 'buttonTwoTxt'];

    var btnCnt = 0;

    for (var i = 0; i < btns.length; i++) {
      if (self[btns[i]]) {
        btnCnt++;
      }
    }

    if (!self.processTxt || !self.cancelTxt) {
      btnOfs = (wrect.w - (btnW)) / 2;
    } else {
      btnOfs = (wrect.w - (2 * btnW)) / 3;
    }

    if (self.processTxt) {
      win.process = win.add('button',
                            [btnOfs,btnY,btnOfs+btnW,btnY+20],
                            self.processTxt);
      if (self.setDefault) {
        win.defaultElement = win.process;
      }

      // And now the callback for the process button.
      win.process.onClick = function() {
        try {
          // validate the contents of the window
          var rc = this.parent.validate();

          if (!rc) {
            // if there was a terminal problem with the validation,
            // close up the window
            this.parent.close(2);
          }

          if (rc && self.isPalette()) {
            self.process(win.opts);
          }
        } catch (e) {
          var msg = Stdlib.exceptionMessage(e);
          Stdlib.log(msg);
          alert(msg);
        }
      };
    }

    if (self.cancelTxt) {
      win.cancel  = win.add('button',
                            [wrect.w-btnOfs-btnW,btnY,wrect.w-btnOfs,btnY+20],
                            self.cancelTxt);

      win.cancelElement = win.cancel;

      win.cancel.onClick = function() {
        this.parent.close(2);
      };
    }
  }

  // Point to the validation
  win.validate = GenericUI.validate;

  return win;
};
GenericUI.processCB = function() {
  try {
    var win = GenericUI.getWindow(this);
    // validate the contents of the window
    var rc = win.validate();

    if (!rc) {
      // if there was a terminal problem with the validation,
      // close up the window
      win.close(2);
    }
  } catch (e) {
    var msg = Stdlib.exceptionMessage(e);
    Stdlib.log(msg);
    alert(msg);
  }
};
GenericUI.cancelCB = function() {
  var win = GenericUI.getWindow(this);
  win.parent.close(2);
};

GenericUI.prototype.moveWindow = function(x, y) {
  var win = this.win;

  if (x != undefined && !isNaN(x)) {
    var width = win.bounds.width;
    if (isCS()) {
      x -= 2;
    }
    win.bounds.left = x;
    win.bounds.width = width; //  Not sure if this is really needed
  }
  if (y != undefined && !isNaN(y)) {
    var height = win.bounds.height;
    if (isCS()) {
      // y -= 22;
    }
    win.bounds.top = y;
    win.bounds.height = height;  //  Not sure if this is really needed
  }
};
GenericUI.getWindow = function(pnl) {
  if (pnl.window) {
    return pnl.window;
  }
  while (pnl && !(pnl instanceof Window)) {
    pnl = pnl.parent;
  }
  return pnl;
};
GenericUI.prototype.createSettingsPanel = function(pnl, ini) {
  var win = GenericUI.getWindow(pnl);

  pnl.text = 'Settings';
  pnl.win = win;

  pnl.fileMask = "INI Files: *.ini, All Files: *.*";
  pnl.loadPrompt = "Please choose a settings file to read";
  pnl.savePrompt = "Please choose a settings file to write";
  pnl.defaultFile = undefined;

  var w = pnl.bounds[2] - pnl.bounds[0];
  var offsets = [w*0.2, w*0.5, w*0.8];
  var y = 15;
  var bw = 90;

  var x = offsets[0]-(bw/2);
  pnl.load = pnl.add('button', [x,y,x+bw,y+20], 'Load...');
  x = offsets[1]-(bw/2);
  pnl.save = pnl.add('button', [x,y,x+bw,y+20], 'Save...');
  x = offsets[2]-(bw/2);
  pnl.reset = pnl.add('button', [x,y,x+bw,y+20], 'Reset');

  pnl.load.onClick = function() {
    var pnl = this.parent;
    var win = pnl.win;
    var mgr = win.mgr;
    var def = pnl.defaultFile;

    if (!def) {
      if (mgr.iniFile) {
        def = GenericUI.iniFileToFile(mgr.iniFile);
      } else {
        def = GenericUI.iniFileToFile("~/settings.ini");
      }
    }

    var f;
    var prmpt = pnl.loadPrompt;
    var sel = Stdlib.createFileSelect(pnl.fileMask);
    if (isMac()) {
      sel = undefined;
    }
    f = Stdlib.selectFileOpen(prmpt, sel, def);
    if (f) {
      win.ini = mgr.readIniFile(f);
      if (f.exists) {
        win.iniContents = Stdlib.readFromFile(f);
      }
      win.close(4);

      if (pnl.onLoad) {
        pnl.onLoad(f);
      }
    }
  };

  pnl.save.onClick = function() {
    var pnl = this.parent;
    var win = pnl.win;
    var mgr = win.mgr;
    var def = pnl.defaultFile;

    if (!def) {
      if (mgr.iniFile) {
        def = GenericUI.iniFileToFile(mgr.iniFile);
      } else {
        def = GenericUI.iniFileToFile("~/settings.ini");
      }
    }

    var f;
    var prmpt = pnl.savePrompt;
    var sel = Stdlib.createFileSelect(pnl.fileMask);

    if (isMac()) {
      sel = undefined;
    }
    f = Stdlib.selectFileSave(prmpt, sel, def);

    if (f) {
      var mgr = win.mgr;
      var res = mgr.validatePanel(win.appPnl, win.ini);

      if (typeof(res) != 'boolean') {
        mgr.writeIniFile(f, res);

        if (pnl.onSave) {
          pnl.onSave(f);
        }
      }
    }
  };

  pnl.reset.onClick = function() {
    var pnl = this.parent;
    var win = pnl.win;
    var mgr = win.mgr;

    if (mgr.defaultIniFile) {
      win.ini = mgr.readIniFile(mgr.defaultIniFile);
      if (File(mgr.defaultIniFile).exists) {
        win.iniContents = Stdlib.readFromFile(mgr.defaultIniFile);
      }
    } else if (mgr.ini) {
      win.ini = mgr.ini;
    }

    win.close(4);
    if (pnl.onReset) {
      pnl.onReset();
    }
  };
};

GenericUI.prototype.createFontPanel = function(pnl, ini, label, lwidth) {
  var win = GenericUI.getWindow(pnl);

  pnl.win = win;

  var w = pnl.bounds[2] - pnl.bounds[0];
  var xofs = 0;
  var y = 0;

  if (pnl.type == 'panel') {
    xofs += 5;
    y += 5;
  }

  var tOfs = GenericUI.getTextOfs();

  var x = xofs;
  if (label == undefined) {
    label = "Font:";
    lwidth = 40;
  }

  if (label != '') {
    pnl.label = pnl.add('statictext', [x,y+tOfs,x+lwidth,y+22+tOfs], label);
    x += lwidth;
  }
  pnl.family = pnl.add('dropdownlist', [x,y,x+180,y+22]);
  x += 185;
  pnl.style  = pnl.add('dropdownlist', [x,y,x+110,y+22]);
  x += 115;
  pnl.fontSize  = pnl.add('edittext', [x,y,x+30,y+22], "12");
  x += 32;
  pnl.sizeLabel = pnl.add('statictext', [x,y+tOfs,x+15,y+22+tOfs], 'pt');

  pnl.fontTable = GenericUI._getFontTable();
  var names = [];
  for (var idx in pnl.fontTable) {
    names.push(idx);
  }
  names.sort();
  for (var i = 0; i < names.length; i++) {
    pnl.family.add('item', names[i]);
  }
  pnl.family.onChange = function() {
    var pnl = this.parent;
    var sel = pnl.family.selection.text;
    var family = pnl.fontTable[sel];

    pnl.style.removeAll();

    var styles = family.styles;

    for (var i = 0; i < styles.length; i++) {
      var it = pnl.style.add('item', styles[i].style);
      it.font = styles[i].font;
    }
    if (pnl._defaultStyle) {
      var it = pnl.style.find(pnl._defaultStyle);
      pnl._defaultStyle = undefined;
      if (it) {
        it.selected = true;
      } else {
        pnl.style.items[0].selected = true;
      }
    } else {
      pnl.style.items[0].selected = true;
    }
  };
  pnl.family.items[0].selected = true;

  pnl.fontSize.onChanging = GenericUI.numberKeystrokeFilter;

  pnl.setFont = function(str, size) {
    var pnl = this;
    if (!str) {
      return;
    }
    var font = (str.typename == "TextFont") ? str : Stdlib.determineFont(str);
    if (font) {
      var it = pnl.family.find(font.family);
      if (it) {
        it.selected = true;
        pnl._defaultStyle = font.style;
      }
    }
    pnl.fontSize.text = size;
    pnl.family.onChange();
  };
  pnl.getFont = function() {
    var pnl = this;
    var font = pnl.style.selection.font;
    return { font: font.postScriptName, size: Number(pnl.fontSize.text) };

    var fsel = pnl.family.selection.text;
    var ssel = pnl.style.selection.text;
    var family = pnl.fontTable[sel];
    var styles = familyStyles;
    var font = undefined;

    for (var i = 0; i < styles.length && font == undefined; i++) {
      if (styles[i].style == ssel) {
        font = styles[i].font;
      }
    }
    return { font: font, size: Number(font.fontSize) };
  }

  return pnl;
};
GenericUI._getFontTable = function() {
  var fonts = app.fonts;
  var fontTable = {};
  for (var i = 0; i < fonts.length; i++) {
    var font = fonts[i];
    var entry = fontTable[font.family];
    if (!entry) {
      entry = { family: font.family, styles: [] };
      fontTable[font.family] = entry;
    }
    entry.styles.push({ style: font.style, font: font });
  }
  return fontTable;
};

GenericUI._getFontArray = function() {
  var fontTable = GenericUI._getFontTable();
  var fonts = [];
  for (var idx in fontTable) {
    var f = fontTable[idx];
    fonts.push(f);
  }
  return fonts;
};

if (!isCS()) {
//============================= FileNaming ====================================
//
// FileNaming is only available in PS at present
//
FileNamingOptions = function(obj, prefix) {
  var self = this;

  self.fileNaming = [];      // array of FileNamingType and/or String
  self.startingSerial = 1;
  self.windowsCompatible = isWindows();
  self.macintoshCompatible = isMac();
  self.unixCompatible = true;

  if (obj) {
    if (prefix == undefined) {
      prefix = '';
    }
    var props = FileNamingOptions.props;
    for (var i = 0; i < props.length; i++) {
      var name = props[i];
      var oname = prefix + name;
      if (oname in obj) {
        self[name] = obj[oname];
      }
    }

    if (self.fileNaming.constructor == String) {
      self.fileNaming = self.fileNaming.split(',');

      // remove "'s from around custom text
    }
  }
};
FileNamingOptions.prototype.typename = FileNamingOptions;
FileNamingOptions.props = ["fileNaming", "startingSerial", "windowsCompatible",
                           "macintoshCompatible", "unixCompatible"];

FileNamingOptions.prototype.format = function(file, cdate) {
  var self = this;
  var str  = '';

  file = Stdlib.convertFptr(file);

  if (!cdate) {
    cdate = file.created || new Date();
  }

  var fname = file.strf("%f");
  var ext = file.strf("%e");

  var parts = self.fileNaming;

  if (parts.constructor == String) {
    parts = parts.split(',');
  }

  var serial = self.startingSerial;
  var aCode = 'a'.charCodeAt(0);
  var ACode = 'A'.charCodeAt(0);

  for (var i = 0; i < parts.length; i++) {
    var p = parts[i];
    var fnel = FileNamingElements.getByName(p);

    if (!fnel) {
      if (p == '--') {
        p = '-';
      }
      // remove "'s from around custom text
      str += p;
      continue;
    }

    var s = '';
    switch (fnel.type) {
    case FileNamingType.DOCUMENTNAMEMIXED: s = fname; break;
    case FileNamingType.DOCUMENTNAMELOWER: s = fname.toLowerCase(); break;
    case FileNamingType.DOCUMENTNAMEUPPER: s = fname.toUpperCase(); break;
    case FileNamingType.SERIALNUMBER1:     s = "%d".sprintf(serial++); break;
    case FileNamingType.SERIALNUMBER2:     s = "%02d".sprintf(serial++); break;
    case FileNamingType.SERIALNUMBER3:     s = "%03d".sprintf(serial++); break;
    case FileNamingType.SERIALNUMBER4:     s = "%04d".sprintf(serial++); break;
    case FileNamingElement.SERIALNUMBER5:  s = "%05d".sprintf(serial++); break;
    case FileNamingType.EXTENSIONLOWER:    s = '.' + ext.toLowerCase(); break;
    case FileNamingType.EXTENSIONUPPER:    s = '.' + ext.toUpperCase(); break;
    case FileNamingType.SERIALLETTERLOWER:
      s = String.fromCharCode(aCode + (serial++)); break;
    case FileNamingType.SERIALLETTERUPPER:
      s = String.fromCharCode(ACode + (serial++)); break;
    }

    if (s) {
      str += s;
      continue;
    }

    var fmt = '';
    switch (fnel.type) {
    case FileNamingType.MMDDYY:   fmt = "%m%d%y"; break;
    case FileNamingType.MMDD:     fmt = "%m%d"; break;
    case FileNamingType.YYYYMMDD: fmt = "%Y%m%d"; break;
    case FileNamingType.YYMMDD:   fmt = "%y%m%d"; break;
    case FileNamingType.YYDDMM:   fmt = "%y%d%m"; break;
    case FileNamingType.DDMMYY:   fmt = "%d%m%y"; break;
    case FileNamingType.DDMM:     fmt = "%d%m"; break;
    }

    if (fmt) {
      str += cdate.strftime(fmt);
      continue;
    }
  }

  self._serial = serial;

  return str;
};

FileNamingOptions.prototype.copyTo = function(opts, prefix) {
  var self = this;
  var props = FileNamingOptions.props;

  for (var i = 0; i < props.length; i++) {
    var name = props[i];
    var oname = prefix + name;
    opts[oname] = self[name];
    if (name == 'fileNaming' && self[name] instanceof Array) {
      opts[oname] = self[name].join(',');
    } else {
      opts[oname] = self[name];
    }
  }
};


// this array is folder into FileNamingElement
FileNamingOptions._examples =
  [ "",
    "Document",
    "document",
    "DOCUMENT",
    "1",
    "01",
    "001",
    "0001",
    "a",
    "A",
    "103107",
    "1031",
    "20071031",
    "071031",
    "073110",
    "311007",
    "3110",
    ".psd",
    ".PSD"
    ];

FileNamingOptions.prototype.getExample = function() {
  var self = this;
  var str = '';
  return str;
};

FileNamingElement = function(name, menu, type, sm, example) {
  var self = this;
  self.name = name;
  self.menu = menu;
  self.type = type;
  self.smallMenu = sm;
  self.example = (example || '');
};
FileNamingElement.prototype.typename = FileNamingElement;

FileNamingElements = [];
FileNamingElements._add = function(name, menu, type, sm, ex) {
  FileNamingElements.push(new FileNamingElement(name, menu, type, sm, ex));
}

FileNamingElement.NONE = "(None)";

FileNamingElement.SERIALNUMBER5 = {
  toString: function() { return "FileNamingElement.SERIALNUMBER5"; }
};

FileNamingElements._init = function() {

  FileNamingElements._add("", "", "", "", "");

  try {
    FileNamingType;
  } catch (e) {
    return;
  }

  // the names here correspond to the sTID symbols used when making
  // a Batch request via the ActionManager interface. Except for "Name",
  // which should be "Nm  ".
  // the names should be the values used when serializing to and from
  // an INI file.
  // A FileNamingOptions object needs to be defined.
  FileNamingElements._add("Name", "Document Name",
                          FileNamingType.DOCUMENTNAMEMIXED,
                          "Name", "Document");
  FileNamingElements._add("lowerCase", "document name",
                          FileNamingType.DOCUMENTNAMELOWER,
                          "name", "document");
  FileNamingElements._add("upperCase", "DOCUMENT NAME",
                          FileNamingType.DOCUMENTNAMEUPPER,
                          "NAME", "DOCUMENT");
  FileNamingElements._add("oneDigit", "1 Digit Serial Number",
                          FileNamingType.SERIALNUMBER1,
                          "Serial #", "1");
  FileNamingElements._add("twoDigit", "2 Digit Serial Number",
                          FileNamingType.SERIALNUMBER2,
                          "Serial ##", "01");
  FileNamingElements._add("threeDigit", "3 Digit Serial Number",
                          FileNamingType.SERIALNUMBER3,
                          "Serial ###", "001");
  FileNamingElements._add("fourDigit", "4 Digit Serial Number",
                          FileNamingType.SERIALNUMBER4,
                          "Serial ####", "0001");
  FileNamingElements._add("fiveDigit", "5 Digit Serial Number",
                          FileNamingElement.SERIALNUMBER5,
                          "Serial #####", "00001");
  FileNamingElements._add("lowerCaseSerial", "Serial Letter (a, b, c...)",
                          FileNamingType.SERIALLETTERLOWER,
                          "Serial a", "a");
  FileNamingElements._add("upperCaseSerial", "Serial Letter (A, B, C...)",
                          FileNamingType.SERIALLETTERUPPER,
                          "Serial A", "A");
  FileNamingElements._add("mmddyy", "mmddyy (date)",
                          FileNamingType.MMDDYY,
                          "mmddyy", "103107");
  FileNamingElements._add("mmdd", "mmdd (date)",
                          FileNamingType.MMDD,
                          "mmdd", "1031");
  FileNamingElements._add("yyyymmdd", "yyyymmdd (date)",
                          FileNamingType.YYYYMMDD,
                          "yyyymmdd", "20071031");
  FileNamingElements._add("yymmdd", "yymmdd (date)",
                          FileNamingType.YYMMDD,
                          "yymmdd", "071031");
  FileNamingElements._add("yyddmm", "yyddmm (date)",
                          FileNamingType.YYDDMM,
                          "yyddmm", "073110");
  FileNamingElements._add("ddmmyy", "ddmmyy (date)",
                          FileNamingType.DDMMYY,
                          "ddmmyy", "311007");
  FileNamingElements._add("ddmm", "ddmm (date)",
                          FileNamingType.DDMM,
                          "ddmm", "3110");
  FileNamingElements._add("lowerCaseExtension", "extension",
                          FileNamingType.EXTENSIONLOWER,
                          "ext", ".psd");
  FileNamingElements._add("upperCaseExtension", "EXTENSION",
                          FileNamingType.EXTENSIONUPPER,
                          "EXT", ".PSD");
};
FileNamingElements._init();
FileNamingElements.getByName = function(name) {
  return Stdlib.getByName(FileNamingElements, name);
};

GenericUI.prototype.createFileNamingPanel = function(pnl, ini,
                                                     prefix,
                                                     useSerial,
                                                     useCompatibility,
                                                     columns) {
  var win = GenericUI.getWindow(pnl);
  if (useSerial == undefined) {
    useSerial = false;
  }
  if (useCompatibility == undefined) {
    useCompatibility = false;
  }
  if (columns == undefined) {
    columns = 3;
  } else {
    if (columns != 2 && columns != 3) {
      Error.runtimeError(9001, "Internal Error: Bad column spec for " +
                         "FileNaming panel");
    }
  }

  pnl.fnmenuElements = [];
  for (var i = 0; i < FileNamingElements.length; i++) {
    var fnel = FileNamingElements[i];
    pnl.fnmenuElements.push(fnel.menu);
  }
  var extrasMenuEls = [
    "-",
    "Create Custom Text",
    "Edit Custom Text",
    "Delete Custom Text",
    "-",
    FileNamingElement.NONE,
    ];
  for (var i = 0; i < extrasMenuEls.length; i++) {
    pnl.fnmenuElements.push(extrasMenuEls[i]);
  }

  pnl.win = win;
  if (prefix == undefined) {
    prefix = '';
  }
  pnl.prefix = prefix;

  var w = pnl.bounds[2] - pnl.bounds[0];
  var xofs = 0;
  var y = 0;

  if (pnl.type == 'panel') {
    xofs += 5;
    y += 10;
  }
  pnl.text = "File Naming";

  var tOfs = GenericUI.getTextOfs();

  if (columns == 2) {
    var menuW = (w - 50)/2;

  } else {
    var menuW = (w - 65)/3;
  }

  var opts = new FileNamingOptions(ini, pnl.prefix);

  x = xofs;

  pnl.exampleLabel = pnl.add('statictext', [x,y+tOfs,x+70,y+22+tOfs],
                             'Example:');
  x += 70;
  pnl.example = pnl.add('statictext', [x,y+tOfs,x+400,y+22+tOfs], '');
  y += 30;
  x = xofs;

  pnl.menus = [];

  pnl.menus[0]  = pnl.add('dropdownlist', [x,y,x+menuW,y+22],
                          pnl.fnmenuElements);
  x += menuW + 5;
  pnl.add('statictext', [x,y+tOfs,x+10,y+22+tOfs], '+');

  x += 15;

  pnl.menus[1]  = pnl.add('dropdownlist', [x,y,x+menuW,y+22],
                          pnl.fnmenuElements);
  x += menuW + 5;
  pnl.add('statictext', [x,y+tOfs,x+10,y+22+tOfs], '+');

  if (columns == 2) {
    y += 30;
    x = xofs;
  } else {
    x += 15;
  }

  pnl.menus[2]  = pnl.add('dropdownlist', [x,y,x+menuW,y+22],
                          pnl.fnmenuElements);
  x += menuW + 5;
  pnl.add('statictext', [x,y+tOfs,x+10,y+22+tOfs], '+');

  if (columns == 3) {
    y += 30;
    x = xofs;

  } else {
    x += 15;
  }

  pnl.menus[3]  = pnl.add('dropdownlist', [x,y,x+menuW,y+22],
                          pnl.fnmenuElements);
  x += menuW + 5;
  pnl.add('statictext', [x,y+tOfs,x+10,y+22+tOfs], '+');

  if (columns == 2) {
    y += 30;
    x = xofs;

  } else {
    x += 15;
  }

  pnl.menus[4]  = pnl.add('dropdownlist', [x,y,x+menuW,y+22],
                          pnl.fnmenuElements);
  x += menuW + 5;
  pnl.add('statictext', [x,y+tOfs,x+10,y+22+tOfs], '+');

  x += 15;

  pnl.menus[5]  = pnl.add('dropdownlist', [x,y,x+menuW,y+22],
                          pnl.fnmenuElements);
  y += 30;
  x = xofs;

  pnl.addMenuElement = function(text) {
    var pnl = this;
    for (var i = 0; i < 6; i++) {
      var vmenu = pnl.menus[i];
      vmenu.add('item', text);
    }
  }

  pnl.useSerial = useSerial;
  if (useSerial) {
    pnl.add('statictext', [x,y+tOfs,x+80,y+22+tOfs], 'Starting serial#:');
    x += 90;
    pnl.startingSerial = pnl.add('edittext', [x,y,x+50,y+22],
                                 opts.startingSerial);
    y += 30;
    x = xofs;
    pnl.startingSerial.onChanging = GenericUI.numberKeystrokeFilter;
    pnl.startingSerial.onChange = function() {
      var pnl = this.parent;
    }
  }

  pnl.useCompatibility = useCompatibility;
  if (useCompatibility) {
    pnl.add('statictext', [x,y+tOfs,x+80,y+22+tOfs], 'Compatibility:');
    x += 90;
    pnl.compatWindows = pnl.add('checkbox', [x,y,x+70,y+22], 'Windows');
    x += 80;
    pnl.compatMac = pnl.add('checkbox', [x,y,x+70,y+22], 'MacOS');
    x += 80;
    pnl.compatUnix = pnl.add('checkbox', [x,y,x+70,y+22], 'Unix');

    pnl.compatWindows.value = opts.windowsCompatible;
    pnl.compatMac.value = opts.macintoshCompatible;
    pnl.compatUnix.value = opts.unixCompatible;
  }

  function menuOnChange() {
    var pnl = this.parent;
    var win = GenericUI.getWindow(pnl);
    if (pnl.processing) {
      return;
    }
    pnl.processing = true;
    try {
      var menu = this;
      if (!menu.selection) {
        return;
      }

      var currentSelection = menu.selection.index;
      var lastSelection = menu.lastMenuSelection;

      menu.lastMenuSelection = menu.selection.index;

      var lastWasCustomText = (lastSelection >= pnl.fnmenuElements.length);

      var sel = menu.selection.text;
      if (sel == FileNamingElement.NONE) {
        menu.selection = menu.items[0];
        sel = menu.selection.text;
      }

      if (sel == "Create Custom Text") {
        var text = GenericUI.createCustomTextDialog(win,
                                                    "Create Custom Text",
                                                    "new");
        if (text) {
          if (text.match(/^\-+$/)) {
            text += '-';
          }
          if (!menu.find(text)) {
            pnl.addMenuElement(text);
          }

          var it = menu.find(text);
          menu.selection = it;
          menu.lastMenuSelection = it.index;

        } else {
          if (lastSelection >= 0) {
            menu.selection = menu.items[lastSelection];
            menu.lastMenuSelection = lastSelection;

          } else {
            menu.selection = menu.items[0];
          }
        }

      } else if (lastWasCustomText) {
        if (sel == "Edit Custom Text") {
          var lastText = menu.items[lastSelection].text;
          var text = GenericUI.createCustomTextDialog(win,
                                                      "Edit Custom Text",
                                                      "edit",
                                                      lastText);
          if (text) {
            for (var i = 0; i < 6; i++) {
              var vmenu = pnl.menus[i];
              var it = vmenu.add('item', text);

              if (vmenu.selection &&
                  vmenu.selection.index == lastSelection) {

                // if a menu already has the previous version of this edited
                // entry, we have to remove the old one before setting the
                // new one or else the menu selection gets lost
                vmenu.remove(lastSelection);
                vmenu.selection = it;

              } else {
                var it = vmenu.selection;
                vmenu.remove(lastSelection);
                vmenu.selection = it;
              }
            }

            var it = menu.find(text);
            menu.selection = it;
            pnl.lastMenuSelection = it.index;

          } else {
            if (lastSelection >= 0) {
              menu.selection = menu.items[lastSelection];
              menu.lastMenuSelection = lastSelection;

            } else {
              menu.selection = menu.items[0];
            }
          }

        } else if (sel == "Delete Custom Text") {
          var lastText = menu.items[lastSelection].text;
          if (confirm("Do you really want to remove \"" + lastText + "\"?")) {
            for (var i = 0; i < 6; i++) {
              var vmenu = pnl.menus[i];
              vmenu.remove(lastSelection);
            }
            menu.selection = menu.items[0];

          } else {
            menu.selection = menu.items[lastSelection];
            menu.lastMenuSelection = lastSelection;
          }

        } else {
          //alert("Internal error, Custom Text request");
        }

      } else {
        if (lastSelection >= 0 && (sel == "Edit Custom Text" ||
                                   sel == "Delete Custom Text")) {
          menu.selection = menu.items[lastSelection];
          menu.lastMenuSelection = lastSelection;
        }
      }

      var example = '';
      var format = [];

      for (var i = 0; i < 6; i++) {
        var vmenu = pnl.menus[i];
        if (vmenu.selection) {
          var fmt = '';
          var text = vmenu.selection.text;
          var fne = Stdlib.getByProperty(FileNamingElements, "menu", text);
          if (fne) {
            text = fne.example;
            fmt = fne.name;
          } else {
            fmt = text;
          }

          if (text) {
            if (text.match(/^\-+$/)) {
              text = text.substr(1);
            }
            example += text;
          }

          if (fmt) {
            if (fmt.match(/^\-+$/)) {
              fmt = fmt.substr(1);
            }
            format.push(fmt);
          }
        }
      }
      if (pnl.example) {
        pnl.example.text = example;
      }
      format = format.join(",");
      var win = GenericUI.getWindow(pnl);
      if (win.mgr.updateNamingFormat) {
        win.mgr.updateNamingFormat(format, example);
      }

    } finally {
      pnl.processing = false;
    }

    if (pnl.onChange) {
      pnl.onChange();
    }
  }

  // default all slots to ''
  for (var i = 0; i < 6; i++) {
    var menu = pnl.menus[i];
    menu.selection = menu.items[0];
    menu.lastMenuSelection = 0;
  }

  for (var i = 0; i < 6; i++) {
    var name = opts.fileNaming[i];
    if (name) {
      var fne = FileNamingElements.getByName(name);
      var it;

      if (!fne) {
        if (name.match(/^\-+$/)) {
          name += '-';
        }
        it = pnl.menus[i].find(name);
        if (!it) {
          pnl.addMenuElement(name);
          it = pnl.menus[i].find(name);
        }
      } else {
        it = pnl.menus[i].find(fne.menu);
      }
      pnl.menus[i].selection = it;
    }
  }

//   pnl.menus[0].selection = pnl.menus[0].find("document name");
//   pnl.menus[0].lastMenuSelection = pnl.menus[0].selection.index;
//   pnl.menus[1].selection = pnl.menus[1].find("extension");
//   pnl.menus[1].lastMenuSelection = pnl.menus[1].selection.index;

  for (var i = 0; i < 6; i++) {
    var menu = pnl.menus[i];
    menu.onChange = menuOnChange;
  }

  pnl.getFileNamingOptions = function(ini) {
    var pnl = this;
    var fileNaming = [];

    for (var i = 0; i < 6; i++) {
      var menu = pnl.menus[i];

      if (menu.selection) {
        var idx = menu.selection.index;

        if (idx) {
          // [0] is the "" item so we ignore it
          var fnel = FileNamingElements[idx];
          if (fnel) {
            fileNaming.push(fnel.name);

          } else {
            // its a custom naming option
            var txt = menu.selection.text;
            if (txt.match(/^\-+$/)) {
              txt = txt.substr(1);
            }

            // txt = '"' + text + '"';
            fileNaming.push(txt);
          }
        }
      }
    }

    var prefix = pnl.prefix;
    var opts = new FileNamingOptions(ini, prefix);
    opts.fileNaming = fileNaming;

    if (pnl.startingSerial) {
      opts.startingSerial = Number(pnl.startingSerial.text);
    }
    if (pnl.compatWindows) {
      opts.windowsCompatible = pnl.compatWindows.value;
    }
    if (pnl.compatMac) {
      opts.macintoshCompatible = pnl.compatMac.value;
    }
    if (pnl.compatUnix) {
      opts.unixCompatible = pnl.compatUnix.value;
    }
    return opts;
  }
  pnl.getFilenamingOptions = pnl.getFileNamingOptions;

  pnl.updateSettings = function(ini) {
    var pnl = this;

    var opts = new FileNamingOptions(ini, pnl.prefix);

    if (pnl.useSerial) {
      pnl.startingSerial.text = opts.startingSerial;
    }

    if (pnl.useCompatibility) {
      pnl.compatWindows.value = opts.windowsCompatible;
      pnl.compatMac.value = opts.macintoshCompatible;
      pnl.compatUnix.value = opts.unixCompatible;
    }

    // default all slots to ''
    for (var i = 0; i < 6; i++) {
      var menu = pnl.menus[i];
      menu.selection = menu.items[0];
      menu.lastMenuSelection = 0;
    }

    for (var i = 0; i < 6; i++) {
      var name = opts.fileNaming[i];
      if (name) {
        var fne = FileNamingElements.getByName(name);
        var it;

        if (!fne) {
          if (name.match(/^\-+$/)) {
            name += '-';
          }
          it = pnl.menus[i].find(name);
          if (!it) {
            pnl.addMenuElement(name);
            it = pnl.menus[i].find(name);
          }
        } else {
          it = pnl.menus[i].find(fne.menu);
        }
        pnl.menus[i].selection = it;
      }
    }

    for (var i = 0; i < 6; i++) {
      var menu = pnl.menus[i];
      menu.onChange = menuOnChange;
    }

    if (!(isCS() || isCS2())) {
      pnl.menus[0].onChange();
    }

    if (pnl.onChange) {
      pnl.onChange();
    }
  }

  if (!(isCS() || isCS2())) {
    pnl.menus[0].onChange();
  }

  if (pnl.onChange) {
    pnl.onChange();
  }

  return pnl;
};
GenericUI.createCustomTextDialog = function(win, title, mode, init) {
  var rect = {
    x: 200,
    y: 200,
    w: 350,
    h: 150
  };

  function rectToBounds(r) {
    return[r.x, r.y, r.x+r.w, r.y+r.h];
  };

  var cwin = new Window('dialog', title || 'Custom Text Editor',
                        rectToBounds(rect));

  cwin.text = title || 'Custom Text Editor';
  if (win) {
    cwin.center(win);
  }

  var xofs = 10;
  var y = 10;
  var x = xofs;

  var tOfs = GenericUI.getTextOfs();

  cwin.add('statictext', [x,y+tOfs,x+300,y+22+tOfs],
           "Please enter the desired Custom Text: ");
  y += 30;
  cwin.customText = cwin.add('edittext', [x,y,x+330,y+22]);

  cwin.customText.onChanging = function() {
    cwin = this.parent;
    var text = cwin.customText.text;

    if (cwin.initText) {
      cwin.saveBtn.enabled = (text.length > 0) && (text != cwin.initText);
    } else {
      cwin.saveBtn.enabled = (text.length > 0);
    }
  }

  if (init) {
    cwin.customText.text = init;
    cwin.initText = init;
  }

  y += 50;
  x += 100;
  cwin.saveBtn = cwin.add('button', [x,y,x+70,y+22], "Save");
  cwin.saveBtn.enabled = false;

  x += 100;
  cwin.cancelBtn = cwin.add('button', [x,y,x+70,y+22], "Cancel");

  cwin.defaultElement = cwin.saveBtn;

  var res = cwin.show();
  return (res == 1) ? cwin.customText.text : undefined;
};

GenericUI.prototype.validateFileNamingPanel = function(pnl, opts) {
  var self = this;
  var win = GenericUI.getWindow(pnl);
  var fopts = pnl.getFileNamingOptions(opts);

  if (fopts.fileNaming.length == 0) {
    return self.errorPrompt("You must specify a name for the files.");
  }

  fopts.copyTo(opts, pnl.prefix);

  return opts;
};
 }
//============================ File Save =====================================
//
// FileSave is only available in Photoshop
//
FileSaveOptions = function(obj) {
  var self = this;

  self.saveDocumentType = undefined; // SaveDocumentType
  self.fileType = "jpg";             // file extension

  self._saveOpts = undefined;

  self.saveForWeb = false; // gif, png, jpg

  self.bmpAlphaChannels = true;
  self.bmpDepth = BMPDepthType.TWENTYFOUR;
  self.bmpRLECompression = false;

  self.gifTransparency = true;
  self.gifInterlaced = false;
  self.gifColors = 256;

  self.jpgQuality = 10;
  self.jpgEmbedColorProfile = true;
  self.jpgFormat = FormatOptions.STANDARDBASELINE;
  self.jpgConvertToSRGB = false;          // requires code

  self.epsEncoding = SaveEncoding.BINARY;
  self.epsEmbedColorProfile = true;

  self.pdfEncoding = PDFEncoding.JPEG;
  self.pdfEmbedColorProfile = true;

  self.psdAlphaChannels = true;
  self.psdEmbedColorProfile = true;
  self.psdLayers = true;
  self.psdMaximizeCompatibility = true;           // requires code for prefs

  self.pngInterlaced = false;

  self.tgaAlphaChannels = true;
  self.tgaRLECompression = true;

  self.tiffEncoding = TIFFEncoding.NONE;
  self.tiffByteOrder = (isWindows() ? ByteOrder.IBM : ByteOrder.MACOS);
  self.tiffEmbedColorProfile = true;

  if (obj) {
    for (var idx in self) {
      if (idx in obj) {       // only copy in FSO settings
        self[idx] = obj[idx];
      }
    }
    if (!obj.fileType) {
      self.fileType = obj.fileSaveType;
      if (self.fileType == "tiff") {
        self.fileType = "tif";
      }
    }
  }
};
//FileSaveOptions.prototype.typename = "FileSaveOptions";
FileSaveOptions._enableDNG = false;

FileSaveOptions.convert = function(fsOpts) {
  var fsType = fsOpts.fileType;
  if (!fsType) {
    fsType = fsOpts.fileSaveType;
  }
  var fs = FileSaveOptionsTypes[fsType];
  if (fs == undefined) {
    return undefined;
  }
  if (!fs.optionsType) {
    return undefined;
  }
  var saveOpts = new fs.optionsType();
  saveOpts._ext = fsType;

  switch (fsType) {
    case "bmp": {
      saveOpts.rleCompression = toBoolean(fsOpts.bmpRLECompression);

      var value = BMPDepthType.TWENTYFOUR;
      var str = fsOpts.bmpDepth.toString();
      if (str.match(/1[^6]|one/i)) {
        value = BMPDepthType.ONE;
      } else if (str.match(/24|twentyfour/i)) {
        // we have to match 24 before 4
        value = BMPDepthType.TWENTYFOUR;
      } else if (str.match(/4|four/i)) {
        value = BMPDepthType.FOUR;
      } else if (str.match(/8|eight/i)) {
        value = BMPDepthType.EIGHT;
      } else if (str.match(/16|sixteen/i)) {
        value = BMPDepthType.SIXTEEN;
      } else if (str.match(/32|thirtytwo/i)) {
        value = BMPDepthType.THIRTYTWO;
      }
      saveOpts.depth = value;
      saveOpts.alphaChannels = toBoolean(fsOpts.bmpAlphaChannels);

      saveOpts._flatten = true;
      saveOpts._8Bit = true; //XXX Should this be true?
      break;
    }
    case "gif": {
      saveOpts.transparency = toBoolean(fsOpts.gifTransparency);
      saveOpts.interlaced = toBoolean(fsOpts.gifInterlaced);
      saveOpts.colors = toNumber(fsOpts.gifColors);

      saveOpts._convertToIndexed = true;
      saveOpts._flatten = true;
      saveOpts._8Bit = true;
      saveOpts._saveForWeb = toBoolean(fsOpts.saveForWeb);
      break;
    }
    case "jpg": {
      saveOpts.quality = toNumber(fsOpts.jpgQuality);
      saveOpts.embedColorProfile = toBoolean(fsOpts.jpgEmbedColorProfile);
      var value = FormatOptions.STANDARDBASELINE;
      var str = fsOpts.jpgFormat.toString();
      if (str.match(/standard/i)) {
        value = FormatOptions.STANDARDBASELINE;
      } else if (str.match(/progressive/i)) {
        value = FormatOptions.PROGRESSIVE;
      } else if (str.match(/optimized/i)) {
        value = FormatOptions.OPTIMIZEDBASELINE;
      }
      saveOpts.formatOptions = value;

      saveOpts._convertToSRGB = toBoolean(fsOpts.jpgConvertToSRGB);
      saveOpts._flatten = true;
      saveOpts._8Bit = true;
      saveOpts._saveForWeb = toBoolean(fsOpts.saveForWeb);
      break;
    }
    case "psd": {
      saveOpts.alphaChannels = toBoolean(fsOpts.psdAlphaChannels);
      saveOpts.embedColorProfile = toBoolean(fsOpts.psdEmbedColorProfile);
      saveOpts.layers = toBoolean(fsOpts.psdLayers);
      saveOpts.maximizeCompatibility =
        toBoolean(fsOpts.psdMaximizeCompatibility);
      break;
    }
    case "eps": {
      var value = SaveEncoding.BINARY;
      var str = fsOpts.epsEncoding.toString();
      if (str.match(/ascii/i)) {
        value = SaveEncoding.ASCII;
      } else if (str.match(/binary/i)) {
        value = SaveEncoding.BINARY;
      } else if (str.match(/jpg|jpeg/i)) {
        if (str.match(/high/i)) {
          value = SaveEncoding.JPEGHIGH;
        } else if (str.match(/low/i)) {
          value = SaveEncoding.JPEGLOW;
        } else if (str.match(/max/i)) {
          value = SaveEncoding.JPEGMAXIMUM;
        } else if (str.match(/med/i)) {
          value = SaveEncoding.JPEGMEDIUM;
        }
      }
      saveOpts.encoding = value;
      saveOpts.embedColorProfile = toBoolean(fsOpts.epsEmbedColorProfile);

      saveOpts._flatten = true;
      break;
    }
    case "pdf": {
      saveOpts.embedColorProfile = toBoolean(fsOpts.pdfEmbedColorProfile);
      break;
    }
    case "png": {
      saveOpts.interlaced = toBoolean(fsOpts.pngInterlaced);

      saveOpts._flatten = true;
      saveOpts._saveForWeb = toBoolean(fsOpts.saveForWeb);
      break;
    }
    case "tga": {
      saveOpts.alphaChannels = toBoolean(fsOpts.tgaAlphaChannels);
      saveOpts.rleCompression = toBoolean(fsOpts.tgaRLECompression);

      saveOpts._flatten = true;
      break;
    }
    case "tif": {
      var value = (isWindows() ? ByteOrder.IBM : ByteOrder.MACOS);
      var str = fsOpts.tiffByteOrder.toString();
      if (str.match(/ibm|pc/i)) {
        value = ByteOrder.IBM;
      } else if (str.match(/mac/i)) {
        value = ByteOrder.MACOS;
      }
      saveOpts.byteOrder = value;

      var value = TIFFEncoding.NONE;
      var str = fsOpts.tiffEncoding.toString();
      if (str.match(/none/i)) {
        value = TIFFEncoding.NONE;
      } else if (str.match(/lzw/i)) {
        value = TIFFEncoding.TIFFLZW;
      } else if (str.match(/zip/i)) {
        value = TIFFEncoding.TIFFZIP;
      } else if (str.match(/jpg|jpeg/i)) {
        value = TIFFEncoding.JPEG;
      }
      saveOpts.imageCompression = value;

      saveOpts.embedColorProfile = toBoolean(fsOpts.tiffEmbedColorProfile);
      break;
    }
    case "dng": {
    }
    default: {
      Error.runtimeError(9001, "Internal Error: Unknown file type: " +
                         fs.fileType);
    }
  }

  return saveOpts;
};

FileSaveOptionsType = function(fileType, menu, saveType, optionsType) {
  var self = this;

  self.fileType = fileType;    // the file extension
  self.menu = menu;
  self.saveType = saveType;
  self.optionsType = optionsType;
};
FileSaveOptionsType.prototype.typename = "FileSaveOptionsType";

FileSaveOptionsTypes = [];
FileSaveOptionsTypes._add = function(fileType, menu, saveType, optionsType) {
  var fsot = new FileSaveOptionsType(fileType, menu, saveType, optionsType);
  FileSaveOptionsTypes.push(fsot);
  FileSaveOptionsTypes[fileType] = fsot;
};
FileSaveOptionsTypes._init = function() {
  if (!isPhotoshop()) {
    return;
  }
  FileSaveOptionsTypes._add("bmp", "Bitmap (BMP)", SaveDocumentType.BMP,
                            BMPSaveOptions);
  FileSaveOptionsTypes._add("gif", "GIF", SaveDocumentType.COMPUSERVEGIF,
                            GIFSaveOptions);
  FileSaveOptionsTypes._add("jpg", "JPEG", SaveDocumentType.JPEG,
                            JPEGSaveOptions);
  FileSaveOptionsTypes._add("psd", "Photoshop PSD", SaveDocumentType.PHOTOSHOP,
                            PhotoshopSaveOptions);
  FileSaveOptionsTypes._add("eps", "Photoshop EPS",
                            SaveDocumentType.PHOTOSHOPEPS, EPSSaveOptions);
  FileSaveOptionsTypes._add("pdf", "Photoshop PDF",
                            SaveDocumentType.PHOTOSHOPPDF, PDFSaveOptions);
  FileSaveOptionsTypes._add("png", "PNG", SaveDocumentType.PNG,
                            PNGSaveOptions);
  FileSaveOptionsTypes._add("tga", "Targa", SaveDocumentType.TARGA,
                            TargaSaveOptions);
  FileSaveOptionsTypes._add("tif", "TIFF", SaveDocumentType.TIFF,
                            TiffSaveOptions);

  if (FileSaveOptions._enableDNG) {
    FileSaveOptionsTypes._add("dng", "DNG", undefined, undefined);
  }
};
FileSaveOptionsTypes._init();

// XXX remove file types _before_ creating a FS panel!
FileSaveOptionsTypes.remove = function(ext) {
  var ar = FileSaveOptionsTypes;
  var fsot = ar[ext];
  if (fsot) {
    for (var i = 0; i < ar.length; i++) {
      if (ar[i] == fsot) {
        ar.splice(i, 1);
        break;
      }
    }
    delete ar[ext];
  }
};

GenericUI.prototype.createFileSavePanel = function(pnl, ini) {
  var win = GenericUI.getWindow(pnl);
  pnl.mgr = this;

  var menuElements = [];

  for (var i = 0; i < FileSaveOptionsTypes.length; i++) {
    menuElements.push(FileSaveOptionsTypes[i].menu);
  }

  var w = pnl.bounds[2] - pnl.bounds[0];
  var xofs = 0;
  var y = 0;

  var opts = new FileSaveOptions(ini);

  if (pnl.type == 'panel') {
    xofs += 5;
    y += 10;
  }
  pnl.text = "Save Options";

  var tOfs = GenericUI.getTextOfs();

  var x = xofs;
  pnl.add('statictext', [x,y+tOfs,x+55,y+22+tOfs], 'File Type:');
  x += 127;
  pnl.fileType = pnl.add('dropdownlist', [x,y,x+150,y+22], menuElements);

  var ftype = opts.fileType || opts.fileSaveType || "jpg";

  var ft = Stdlib.getByProperty(FileSaveOptionsTypes,
                                "fileType",
                                ftype);
  pnl.fileType.selection = pnl.fileType.find(ft.menu);

  x += pnl.fileType.bounds.width + 10;
  pnl.saveForWeb = pnl.add('checkbox', [x,y,x+150,y+22], 'Save for Web');
  pnl.saveForWeb.visible = false;
  pnl.saveForWeb.value = false;

  y += 30;
  var yofs = y;

  x = xofs;

  //=============================== Bitmap ===============================
  if (FileSaveOptionsTypes["bmp"]) {
    pnl.bmpAlphaChannels = pnl.add('checkbox', [x,y,x+125,y+22],
                                   "Alpha Channels");

    x += 150;
    var bmpDepthMenu = ["1", "4", "8", "16", "24", "32"];
    pnl.bmpDepthLabel = pnl.add('statictext', [x,y+tOfs,x+60,y+22+tOfs],
                                'Bit Depth:');
    x += 65;
    pnl.bmpDepth = pnl.add('dropdownlist', [x,y,x+55,y+22], bmpDepthMenu);
    pnl.bmpDepth.selection = pnl.bmpDepth.find("24");

    pnl.bmpDepth.find("1")._value = BMPDepthType.ONE;
    pnl.bmpDepth.find("4")._value = BMPDepthType.FOUR;
    pnl.bmpDepth.find("8")._value = BMPDepthType.EIGHT;
    pnl.bmpDepth.find("16")._value = BMPDepthType.SIXTEEN;
    pnl.bmpDepth.find("24")._value = BMPDepthType.TWENTYFOUR;
    pnl.bmpDepth.find("32")._value = BMPDepthType.THIRTYTWO;

    x = xofs;
    y += 30;
    pnl.bmpRLECompression = pnl.add('checkbox', [x,y,x+145,y+22],
                                    "RLE Compression");

    pnl.bmp = ["bmpAlphaChannels", "bmpDepthLabel", "bmpDepth",
               "bmpRLECompression"];

    pnl.bmpAlphaChannels.value = toBoolean(opts.bmpAlphaChannels);
    var it = pnl.bmpDepth.find(opts.bmpDepth.toString());
    if (it) {
      pnl.bmpDepth.selection = it;
    }
    pnl.bmpRLECompression.value = toBoolean(opts.bmpRLECompression);

    y = yofs;
    x = xofs;
  }


  //=============================== GIF ===============================
  if (FileSaveOptionsTypes["gif"]) {
    pnl.gifTransparency = pnl.add('checkbox', [x,y,x+125,y+22],
                                  "Transparency");

    x += 125;
    pnl.gifInterlaced = pnl.add('checkbox', [x,y,x+125,y+22],
                                "Interlaced");

    x += 125;
    pnl.gifColorsLabel = pnl.add('statictext', [x,y+tOfs,x+55,y+22+tOfs],
                                  'Colors:');

    x += 60;
    pnl.gifColors = pnl.add('edittext', [x,y,x+55,y+22], "256");
    pnl.gifColors.onChanging = GenericUI.numericKeystrokeFilter;
    pnl.gifColors.onChange = function() {
      var pnl = this.parent;
      var n = toNumber(pnl.gifColors.text || 256);
      if (n < 2)   { n = 2; }
      if (n > 256) { n = 256; }
      pnl.gifColors.text = n;
    }

    pnl.gif = ["gifTransparency", "gifInterlaced", "gifColors", "gifColorsLabel",
               "saveForWeb"];

    pnl.gifTransparency.value = toBoolean(opts.gifTransparency);
    pnl.gifInterlaced.value = toBoolean(opts.gifInterlaced);
    pnl.gifColors.text = toNumber(opts.gifColors || 256);

    pnl.saveForWeb.value = toBoolean(opts.saveForWeb);
    y = yofs;
    x = xofs;
  }


  //=============================== JPG ===============================
  if (FileSaveOptionsTypes["jpg"]) {
    pnl.jpgQualityLabel = pnl.add('statictext', [x,y+tOfs,x+55,y+22+tOfs],
                                  'Quality:');
    x += 60;
    var jpqQualityMenu = ["1","2","3","4","5","6","7","8","9","10","11","12"];
    pnl.jpgQuality = pnl.add('dropdownlist', [x,y,x+55,y+22], jpqQualityMenu);
    pnl.jpgQuality.selection = pnl.jpgQuality.find("10");

    y += 30;
    x = xofs;
    pnl.jpgEmbedColorProfile = pnl.add('checkbox', [x,y,x+155,y+22],
                                       "Embed Color Profile");

    y = yofs;
    x += 150;

    var jpgFormatMenu = ["Standard", "Progressive", "Optimized"];
    pnl.jpgFormatLabel = pnl.add('statictext', [x,y+tOfs,x+50,y+22+tOfs],
                                 'Format:');
    x += 55;
    pnl.jpgFormat = pnl.add('dropdownlist', [x,y,x+110,y+22], jpgFormatMenu);
    pnl.jpgFormat.selection = pnl.jpgFormat.find("Standard");

    pnl.jpgFormat.find("Standard")._value = FormatOptions.STANDARDBASELINE;
    pnl.jpgFormat.find("Progressive")._value = FormatOptions.PROGRESSIVE;
    pnl.jpgFormat.find("Optimized")._value = FormatOptions.OPTIMIZEDBASELINE;

    y += 30;
    x = xofs + 150;
    pnl.jpgConvertToSRGB = pnl.add('checkbox', [x,y,x+145,y+22],
                                   "Convert to sRGB");

    pnl.jpg = ["jpgQualityLabel", "jpgQuality", "jpgEmbedColorProfile",
               "jpgFormatLabel", "jpgFormat", "jpgConvertToSRGB", "saveForWeb" ];

    var it = pnl.jpgQuality.find(opts.jpgQuality.toString());
    if (it) {
      pnl.jpgQuality.selection = it;
    }
    pnl.jpgEmbedColorProfile.value = toBoolean(opts.jpgEmbedColorProfile);
    var it = pnl.jpgFormat.find(opts.jpgFormat);
    if (it) {
      pnl.jpgFormat.selection = it;
    }
    pnl.jpgConvertToSRGB.value = toBoolean(opts.jpgConvertToSRGB);

    pnl.saveForWeb.value = toBoolean(opts.saveForWeb);

    x = xofs;
    y = yofs;
  }


  //=============================== PSD ===============================
  if (FileSaveOptionsTypes["psd"]) {
    pnl.psdAlphaChannels = pnl.add('checkbox', [x,y,x+125,y+22],
                                   "Alpha Channels");

    y += 30;
    pnl.psdEmbedColorProfile = pnl.add('checkbox', [x,y,x+155,y+22],
                                       "Embed Color Profile");

    y = yofs;
    x = xofs + 150;

    pnl.psdLayers = pnl.add('checkbox', [x,y,x+125,y+22],
                          "Layers");

    y += 30;
    pnl.psdMaximizeCompatibility = pnl.add('checkbox', [x,y,x+175,y+22],
                                           "Maximize Compatibility");

    pnl.psd = ["psdAlphaChannels", "psdEmbedColorProfile",
               "psdLayers", "psdMaximizeCompatibility"];

    pnl.psdAlphaChannels.value = toBoolean(opts.psdAlphaChannels);
    pnl.psdEmbedColorProfile.value = toBoolean(opts.psdEmbedColorProfile);
    pnl.psdLayers.value = toBoolean(opts.psdLayers);
    pnl.psdMaximizeCompatibility.value =
       toBoolean(opts.psdMaximizeCompatibility);

    x = xofs;
    y = yofs;
  }

  //=============================== EPS ===============================
  if (FileSaveOptionsTypes["eps"]) {
    var epsEncodingMenu = ["ASCII", "Binary", "JPEG High", "JPEG Med",
                           "JPEG Low", "JPEG Max"];
    pnl.epsEncodingLabel = pnl.add('statictext', [x,y+tOfs,x+60,y+22+tOfs],
                                 'Encoding:');
    x += 65;
    pnl.epsEncoding = pnl.add('dropdownlist',
                              [x,y,x+100,y+22],
                              epsEncodingMenu);
    pnl.epsEncoding.selection = pnl.epsEncoding.find("Binary");

    pnl.epsEncoding.find("ASCII")._value = SaveEncoding.ASCII;
    pnl.epsEncoding.find("Binary")._value = SaveEncoding.BINARY;
    pnl.epsEncoding.find("JPEG High")._value = SaveEncoding.JPEGHIGH;
    pnl.epsEncoding.find("JPEG Low")._value = SaveEncoding.JPEGLOW;
    pnl.epsEncoding.find("JPEG Max")._value = SaveEncoding.JPEGMAXIMUM;
    pnl.epsEncoding.find("JPEG Med")._value = SaveEncoding.JPEGMEDIUM;

    x = xofs;
    y += 30;
    pnl.epsEmbedColorProfile = pnl.add('checkbox', [x,y,x+155,y+22],
                                       "Embed Color Profile");

    pnl.eps = ["epsEncodingLabel", "epsEncoding", "epsEmbedColorProfile"];

    var it = pnl.epsEncoding.find(opts.epsEncoding);
    if (it) {
      pnl.epsEncoding.selection = it;
    }
    pnl.epsEmbedColorProfile.value = toBoolean(opts.epsEmbedColorProfile);

    x = xofs;
    y = yofs;
  }


  //=============================== PDF ===============================
  if (FileSaveOptionsTypes["pdf"]) {
    pnl.pdf = ["pdfEmbedColorProfile"];

    x = xofs;
    y = yofs;

    x = xofs;
    y += 30;
    pnl.pdfEmbedColorProfile = pnl.add('checkbox', [x,y,x+155,y+22],
                                       "Embed Color Profile");
    pnl.pdfEmbedColorProfile.value = toBoolean(opts.pdfEmbedColorProfile);

    x = xofs;
    y = yofs;
  }


  //=============================== PNG ===============================
  if (FileSaveOptionsTypes["png"]) {
    pnl.pngInterlaced = pnl.add('checkbox', [x,y,x+125,y+22],
                                "Interlaced");

    pnl.png = ["pngInterlaced", "saveForWeb"];

    pnl.pngInterlaced.value = toBoolean(opts.pngInterlaced);

    pnl.saveForWeb.value = toBoolean(opts.saveForWeb);

    x = xofs;
    y = yofs;
  }


  //=============================== TGA ===============================
  if (FileSaveOptionsTypes["tga"]) {
    pnl.tgaAlphaChannels = pnl.add('checkbox', [x,y,x+125,y+22],
                                   "Alpha Channels");

    y += 30;

    pnl.tgaRLECompression = pnl.add('checkbox', [x,y,x+145,y+22],
                                    "RLE Compression");

    pnl.tga = ["tgaAlphaChannels", "tgaRLECompression"];

    pnl.tgaAlphaChannels.value = toBoolean(opts.tgaAlphaChannels);
    pnl.tgaRLECompression.value = toBoolean(opts.tgaRLECompression);

    x = xofs;
    y = yofs;
  }


  //=============================== TIFF ===============================
  if (FileSaveOptionsTypes["tif"]) {
    var tiffEncodingMenu = ["None", "LZW", "ZIP", "JPEG"];
    pnl.tiffEncodingLabel = pnl.add('statictext', [x,y+tOfs,x+60,y+22+tOfs],
                                    'Encoding:');
    x += 65;
    pnl.tiffEncoding = pnl.add('dropdownlist', [x,y,x+75,y+22],
                               tiffEncodingMenu);
    pnl.tiffEncoding.selection = pnl.tiffEncoding.find("None");

    pnl.tiffEncoding.find("None")._value = TIFFEncoding.NONE;
    pnl.tiffEncoding.find("LZW")._value = TIFFEncoding.TIFFLZW;
    pnl.tiffEncoding.find("ZIP")._value = TIFFEncoding.TIFFZIP;
    pnl.tiffEncoding.find("JPEG")._value = TIFFEncoding.JPEG;

    x += 90;

    var tiffByteOrderMenu = ["IBM", "MacOS"];
    pnl.tiffByteOrderLabel = pnl.add('statictext', [x,y+tOfs,x+65,y+22+tOfs],
                                     'ByteOrder:');
    x += 70;
    pnl.tiffByteOrder = pnl.add('dropdownlist', [x,y,x+85,y+22],
                                tiffByteOrderMenu);
    var bo = (isWindows() ? "IBM" : "MacOS");
    pnl.tiffByteOrder.selection = pnl.tiffByteOrder.find(bo);

    pnl.tiffByteOrder.find("IBM")._value = ByteOrder.IBM;
    pnl.tiffByteOrder.find("MacOS")._value = ByteOrder.MACOS;

    x = xofs;
    y += 30;
    pnl.tiffEmbedColorProfile = pnl.add('checkbox', [x,y,x+155,y+22],
                                        "Embed Color Profile");

    pnl.tif = ["tiffEncodingLabel", "tiffEncoding", "tiffByteOrderLabel",
               "tiffByteOrder", "tiffEmbedColorProfile"];

    pnl.dng = [];

    var it = pnl.tiffEncoding.find(opts.tiffEncoding);
    if (it) {
      pnl.tiffEncoding.selection = it;
    }
    var it = pnl.tiffByteOrder.find(opts.tiffByteOrder);
    if (it) {
      pnl.tiffByteOrder.selection = it;
    }
    pnl.tiffEmbedColorProfile.value = toBoolean(opts.tiffEmbedColorProfile);
  }

  pnl.fileType.onChange = function() {
    var pnl = this.parent;
    var ftsel = pnl.fileType.selection.index;
    var ft = FileSaveOptionsTypes[ftsel];

    for (var i = 0; i < FileSaveOptionsTypes.length; i++) {
      var fsType = FileSaveOptionsTypes[i];
      var parts = pnl[fsType.fileType];

      for (var j = 0; j < parts.length; j++) {
        var part = parts[j];
        pnl[part].visible = (fsType == ft);
      }
    }

    var fsType = ft.fileType;
    pnl.saveForWeb.visible = (pnl[fsType].contains("saveForWeb"));
    pnl._onChange();
  };

  pnl._onChange = function() {
    var self = this;
    if (self.onChange) {
      self.onChange();
    }
  };

  if (false) {
    y = yofs;
    x = 300;
    var btn = pnl.add('button', [x,y,x+50,y+22], "Test");
    btn.onClick = function() {
      try {
        var pnl = this.parent;
        var mgr = pnl.mgr;

        var opts = {};
        mgr.validateFileSavePanel(pnl, opts);
        alert(listProps(opts));
        alert(listProps(FileSaveOptions.convert(opts)));

      } catch (e) {
        var msg = Stdlib.exceptionMessage(e);
        Stdlib.log(msg);
        alert(msg);
      }
    };
  }

  if (!isCS() && !isCS2()) {
    pnl.fileType.onChange();
  }

  pnl.getFileSaveType = function() {
    var pnl = this;
    var fstype = '';
    if (pnl.fileType.selection) {
      var fsSel = pnl.fileType.selection.index;
      var fs = FileSaveOptionsTypes[fsSel];
      fstype = fs.fileType;
    }
    return fstype;
  };

  pnl.updateSettings = function(ini) {
    var pnl = this;

    function _select(m, s, def) {
      var it = m.find(s.toString());
      if (!it && def != undefined) {
        it = m.items[def];
      }
      if (it) {
        m.selection = it;
      }
    }

    var opts = new FileSaveOptions(ini);
    var ftype = opts.fileType || opts.fileSaveType || "jpg";

    var ft = Stdlib.getByProperty(FileSaveOptionsTypes,
                                  "fileType",
                                  ftype);
    pnl.fileType.selection = pnl.fileType.find(ft.menu);

    if (FileSaveOptionsTypes["bmp"]) {
      pnl.bmpAlphaChannels.value = toBoolean(opts.bmpAlphaChannels);
      _select(pnl.bmpDepth, opts.bmpDepth.toString(), 0);
      pnl.bmpRLECompression.value = toBoolean(opts.bmpRLECompression);
    }

    if (FileSaveOptionsTypes["gif"]) {
      pnl.gifTransparency.value = toBoolean(opts.gifTransparency);
      pnl.gifInterlaced.value = toBoolean(opts.gifInterlaced);
      pnl.gifColors.text = toNumber(opts.gifColors || 256);
      pnl.saveForWeb.value = toBoolean(opts.saveForWeb);
    }

    if (FileSaveOptionsTypes["jpg"]) {
      _select(pnl.jpgQuality, opts.jpgQuality.toString(), 0);
      pnl.jpgEmbedColorProfile.value = toBoolean(opts.jpgEmbedColorProfile);
      _select(pnl.jpgFormat, opts.jpgFormat, 0);
      pnl.jpgConvertToSRGB.value = toBoolean(opts.jpgConvertToSRGB);
      pnl.saveForWeb.value = toBoolean(opts.saveForWeb);
    }

    if (FileSaveOptionsTypes["psd"]) {
      pnl.psdAlphaChannels.value = toBoolean(opts.psdAlphaChannels);
      pnl.psdEmbedColorProfile.value = toBoolean(opts.psdEmbedColorProfile);
      pnl.psdLayers.value = toBoolean(opts.psdLayers);
      pnl.psdMaximizeCompatibility.value =
      toBoolean(opts.psdMaximizeCompatibility);
    }
    
    if (FileSaveOptionsTypes["eps"]) {
      _select(pnl.epsEncoding, opts.epsEncoding, 0);
      pnl.epsEmbedColorProfile.value = toBoolean(opts.epsEmbedColorProfile);
    }
    
    if (FileSaveOptionsTypes["pdf"]) {
      pnl.pdfEmbedColorProfile.value = toBoolean(opts.pdfEmbedColorProfile);
    }
    
    if (FileSaveOptionsTypes["png"]) {
      pnl.pngInterlaced.value = toBoolean(opts.pngInterlaced);
      pnl.saveForWeb.value = toBoolean(opts.saveForWeb);
    }
    
    if (FileSaveOptionsTypes["tga"]) {
      pnl.tgaAlphaChannels.value = toBoolean(opts.tgaAlphaChannels);
      pnl.tgaRLECompression.value = toBoolean(opts.tgaRLECompression);
    }
    
    if (FileSaveOptionsTypes["tif"]) {
      _select(pnl.tiffEncoding, opts.tiffEncoding, 0);
      _select(pnl.tiffByteOrder, opts.tiffByteOrder, 0);
      pnl.tiffEmbedColorProfile.value = toBoolean(opts.tiffEmbedColorProfile);
    }
    pnl.fileType.onChange();
  }

  return pnl;
};
GenericUI.prototype.validateFileSavePanel = function(pnl, opts) {
  var win = GenericUI.getWindow(pnl);

  // XXX This function needs to remove any prior file save
  // options and only set the ones needed for the
  // selected file type

  var fsOpts = new FileSaveOptions();
  for (var idx in fsOpts) {
    if (idx in opts) {
      delete opts[idx];
    }
  }

  var fsSel = pnl.fileType.selection.index;
  var fs = FileSaveOptionsTypes[fsSel];

  opts.fileSaveType = fs.fileType;
  opts._saveDocumentType = fs.saveType;

  if (!fs.optionsType) {
    opts._saveOpts = undefined;
    return;
  }

  var saveOpts = new fs.optionsType();

  switch (fs.fileType) {
    case "bmp": {
      saveOpts.rleCompression = pnl.bmpRLECompression.value;
      saveOpts.depth = pnl.bmpDepth.selection._value;
      saveOpts.alphaChannels = pnl.bmpAlphaChannels.value;

      opts.bmpRLECompression = pnl.bmpRLECompression.value;
      opts.bmpDepth = Number(pnl.bmpDepth.selection.text);
      opts.bmpAlphaChannels = pnl.bmpAlphaChannels.value;
      break;
    }
    case "gif": {
      saveOpts.transparency = pnl.gifTransparency.value;
      saveOpts.interlaced = pnl.gifInterlaced.value;
      var colors = toNumber(pnl.gifColors.text || 256);
      if (colors < 2)   { colors = 2; }
      if (colors > 256) { colors = 256; }
      saveOpts.colors = colors; 
      saveOpts._saveForWeb = pnl.saveForWeb.value;

      opts.gifTransparency = pnl.gifTransparency.value;
      opts.gifInterlaced = pnl.gifInterlaced.value;
      opts.gifColors = colors;
      opts.saveForWeb = pnl.saveForWeb.value;
      break;
    }
    case "jpg": {
      saveOpts.quality = Number(pnl.jpgQuality.selection.text);
      saveOpts.embedColorProfile = pnl.jpgEmbedColorProfile.value;
      saveOpts.formatOptions = pnl.jpgFormat.selection._value;
      saveOpts._convertToSRGB = pnl.jpgConvertToSRGB.value;
      saveOpts._saveForWeb = pnl.saveForWeb.value;

      opts.jpgQuality = Number(pnl.jpgQuality.selection.text);
      opts.jpgEmbedColorProfile = pnl.jpgEmbedColorProfile.value;
      opts.jpgFormat = pnl.jpgFormat.selection.text;
      opts.jpgConvertToSRGB = pnl.jpgConvertToSRGB.value;
      opts.saveForWeb = pnl.saveForWeb.value;
      break;
    }
    case "psd": {
      saveOpts.alphaChannels = pnl.psdAlphaChannels.value;
      saveOpts.embedColorProfile = pnl.psdEmbedColorProfile.value;
      saveOpts.layers = pnl.psdLayers.value;
      saveOpts.maximizeCompatibility = pnl.psdMaximizeCompatibility.value;

      opts.psdAlphaChannels = pnl.psdAlphaChannels.value;
      opts.psdEmbedColorProfile = pnl.psdEmbedColorProfile.value;
      opts.psdLayers = pnl.psdLayers.value;
      opts.psdMaximizeCompatibility = pnl.psdMaximizeCompatibility.value;
      break;
    }
    case "eps": {
      saveOpts.encoding = pnl.epsEncoding.selection._value;
      saveOpts.embedColorProfile = pnl.epsEmbedColorProfile.value;

      opts.epsEncoding = pnl.epsEncoding.selection.text;
      opts.epsEmbedColorProfile = pnl.epsEmbedColorProfile.value;
      break;
    }
    case "pdf": {
      saveOpts.embedColorProfile = pnl.pdfEmbedColorProfile.value;

      opts.pdfEmbedColorProfile = pnl.pdfEmbedColorProfile.value;
      break;
    }
    case "png": {
      saveOpts.interlaced = pnl.pngInterlaced.value;
      saveOpts._saveForWeb = pnl.saveForWeb.value;

      opts.pngInterlaced = pnl.pngInterlaced.value;
      opts.saveForWeb = pnl.saveForWeb.value;
      break;
    }
    case "tga": {
      saveOpts.alphaChannels = pnl.tgaAlphaChannels.value;
      saveOpts.rleCompression = pnl.tgaRLECompression.value;

      opts.tgaAlphaChannels = pnl.tgaAlphaChannels.value;
      opts.tgaRLECompression = pnl.tgaRLECompression.value;
      break;
    }
    case "tif": {
      saveOpts.byteOrder = pnl.tiffByteOrder.selection._value;
      saveOpts.imageCompression = pnl.tiffEncoding.selection._value;
      saveOpts.embedColorProfile = pnl.tiffEmbedColorProfile.value;

      opts.tiffByteOrder = pnl.tiffByteOrder.selection.text;
      opts.tiffEncoding = pnl.tiffEncoding.selection.text;
      opts.tiffEmbedColorProfile = pnl.tiffEmbedColorProfile.value;
      break;
    }
    default:
      Error.runtimeError(9001, "Internal Error: Unknown file type: " +
                         fs.fileType);
  }

  opts._saveOpts = saveOpts;

  return;
};


//================================== exec ==================================
//
// exec runs the ui and the application callback
//   doc is the document to operate on (optional)
//   if noUI is true, the window is not open. The runtime parameters
//      are taken from the ini file.
//
GenericUI.prototype.runUI = function(ovOpts, doc) {
  var self = this;

  // read the ini file (if present)
  var ini = {};

  if (self.iniFile) {
    ini = self.readIniFile();
  }

  // copyFromTo
  if (ovOpts) {
    for (var idx in ovOpts) {
      var v = ovOpts[idx];
      if (typeof v != 'function') {
        ini[idx] = v;
      }
    }
  }

  var opts = undefined;
  var win = undefined;

  if (toBoolean(ini.noUI)) {
    // if we don't want a UI, just use the ini object
    opts = ini;

  } else {
    // create window
    win = self.createWindow(ini, doc);

    self.win = win;

    // run the window and return the parameters mapped from the window
    opts = self.run(win);

    if (win.iniContents) {
      self.iniContents = win.iniContents;
    }
  }

  return opts;
};


GenericUI.prototype.exec = function(arg1, arg2) {
  var self = this;

  var ovOpts = undefined;
  var doc = undefined;

  // either or both a document and options may be specified or neither
  if (arg1 || arg2) {
    if (!arg1) {  // if only arg2 is set, swap the args
      arg1 = arg2;
      arg2 = undefined;
    }

    ovOpts = arg1; // assume that arg1 is the options

    var dbgLevel = $.level;
    $.level = 0;
    try {
      if (arg1.typename == "Document") {
        doc = arg1;
        ovOpts = arg2;
      } else if (arg2 && arg2.typename == "Document") {
        doc = arg2;
      }
    } catch (e) {
    }
    $.level = dbgLevel;
  }

  var opts = self.runUI(ovOpts, doc);

  return self.runProcess(opts, doc);
};

GenericUI.prototype.runProcess = function(opts, doc) {
  var self = this;
  var result = undefined;

  // if we got options back, we can do some processing
  if (opts) {
    if (self.saveIni) {
      self.writeIniFile(opts);
    }

    result = self.process(opts, doc);

  } else if (self.win && self.win.canceled) { // if not, we just cancel out...
    self.cancel(doc);
  }

  return result;
};


//
// the run method 'show's the window. If it ran successfully, the options
// returned are written to an ini file (if one has been specified
//
GenericUI.prototype.run = function(win) {
  var self = this;
  var done = false;

  if (win.show) {
    while (!done) {
      if (self.center == true) {
        win.center(self.parentWin);
      }
      var x = win.show();

      self.winX = win.bounds.x;
      self.winY = win.bounds.y;

      if (x == 0 || x == 2) {  // the window was closed or canceled
        win.canceled = true;   // treat it like a 'cancel'
        win.opts = undefined;
        done = true;
      } else if (x == 1) {
        done = true;
      } else if (x == 4) {     // reset window
        win = self.createWindow(win.ini, win.doc);
      }
      self.runCode = x;
    }
  }

  return win.opts;
};
GenericUI.prototype._checkIniArgs = function(arg1, arg2, xmlMode) {
  var self = this;
  var obj = {
    file: undefined,
    opts: undefined,
    xml: (xmlMode == undefined) ? self.xmlEnabled : xmlMode
  };

  if (arg1) {
    if (!obj.file && ((arg1 instanceof File) ||
                      (arg1.constructor == String))) {
      obj.file = GenericUI.iniFileToFile(arg1);

    } else {
      obj.opts = arg1;
    }
  }

  if (arg2) {
    if (!obj.file && ((arg2 instanceof File) ||
                      (arg2.constructor == String))) {
      obj.file = GenericUI.iniFileToFile(arg2);

    } else if (!obj.opts) {
      obj.opts = arg2;
    }
  }

  return obj;
};
GenericUI.prototype.updateIniFile = function(arg1, arg2, xmlMode) {
  var self = this;
  var args = self._checkIniArgs(arg1, arg2, xmlMode);
  var file = args.file || self.iniFile;
  var opts = args.opts;
  var xml = args.xml;

  if (!file) {
    Error.runtimeError(9001, "Internal Error: No valid settings file specified for update");
  }

  GenericUI.updateIni(file, opts, xml);
};
GenericUI.prototype.writeIniFile = function(arg1, arg2, xmlMode) {
  var self = this;
  var args = self._checkIniArgs(arg1, arg2, xmlMode);
  var file = args.file || self.iniFile;
  var opts = args.opts;
  var xml = args.xml;

  if (!file) {
    Error.runtimeError(9001, "Internal Error: No valid settings " +
                       "file specified for write");
  }
  GenericUI.writeIni(file, opts, xml);
};
GenericUI.prototype.readIniFile = function(arg1, arg2, xmlMode) {
  var self = this;
  var args = self._checkIniArgs(arg1, arg2, xmlMode);
  var file = args.file || self.iniFile;
  var opts = args.opts;
  var xml = args.xml;

  if (!file) {
    Error.runtimeError(9001, "Internal Error: No valid settings " +
                       "file specified for read");
  }

  var ini = GenericUI.readIni(file, opts, xml);
  file = new File(file);
  if (file.open("r", "TEXT", "????")) {
    file.lineFeed = "unix";
    file.encoding = GenericUI.ENCODING;
    self.iniContents = file.read();
    file.close();
  }
  return ini;
};

//
// errorPrompt is used in window/panel validation. It pops up a 'confirm'
// with the prompt 'str'. If the user selects 'Yes', the 'confirm' is closed
// and the user is returned to the window for further interaction. If the user
// selects 'No', the 'confirm' is closed, the window is closed, and the script
// terminates.
//
GenericUI.prototype.errorPrompt = function(str) {
  return GenericUI.errorPrompt(str);
};
GenericUI.errorPrompt = function(str) {
  return confirm(str + "\r\rDo you wish to continue?");
//                  false, "Input Validation Error");
};

//
// 'validate' is called by the win.process.onClick method to validate the
// contents of the window. To validate the window, we call the application
// defined 'validatePanel' method. 'validate' returns 'true', 'false', or
// an options object with the values collected from the application panel.
// If 'true' is returned, this means that there was a problem with validation
// but the user wants to continue. If 'false' is returned, there was a problem
// with validation and the user wants to stop. If an object is returned, the
// window is closed and processing continues based on the options values
//
GenericUI.validate = function() {
  var win = this;
  var mgr = win.mgr;

  mgr.winX = win.bounds.x;
  mgr.winY = win.bounds.y;

  try {
    var res = mgr.validatePanel(win.appPnl, win.ini);

    if (typeof(res) == 'boolean') {
      return res;
    }
    win.opts = res;
    if (!mgr.isPalette()) {
      win.close(1);
    }
    return true;

  } catch (e) {
    var msg = Stdlib.exceptionMessage(e);
    Stdlib.log(msg);
    alert(msg);
    return false;
  }
};

//
// Convert a fptr to a valid ini File object.
// If the arg is already a File, make sure it has a valid path
// If the arg is a string and
//    begins with / or ~ or contains a :, then it is a complete path
//       so return it as a File object
//
//
GenericUI.iniFileToFile = function(iniFile) {
  if (!iniFile) {
    return undefined;
  }

  if (iniFile instanceof File) {
    if (!iniFile.parent.exists) {
      Stdlib.createFolder(iniFile.parent);
    }
    return iniFile;
  }

  if (iniFile.constructor == String) {
    var c = iniFile.charAt(0);

    // This is not a partial/relative path
    if (c == '/' || c == '~' || iniFile.charAt(1) == ':') {
      iniFile = new File(iniFile);

    } else {
      var prefs = GenericUI.preferencesFolder;

      // if the path starts with 'xtools/' strip it off
      var sub = "xtools/";
      if (iniFile.startsWith(sub)) {
        iniFile = iniFile.substr(sub.length);
      }

      // and place the ini file in the prefs folder
      iniFile = new File(prefs + '/' + iniFile);
    }

    // make sure any intermediate paths have been created
    if (!iniFile.parent.exists) {
      Stdlib.createFolder(iniFile.parent);
    }

    return iniFile;
  }

  return undefined;
};

GenericUI.iniFromString = function(str, ini) {
  var lines = str.split(/\r|\n/);
  var rexp = new RegExp(/([^:]+):(.*)$/);

  if (!ini) {
    ini = {};
  }

  for (var i = 0; i < lines.length; i++) {
    var line = lines[i].trim();
    if (!line || line.charAt(0) == '#') {
      continue;
    }
    var ar = rexp.exec(line);
    if (!ar) {
      alert("Bad line in config: \"" + line + "\"");
      continue;
      //return undefined;
    }
    ini[ar[1].trim()] = ar[2].trim();
  }

  return ini;
};

//
// readIni
// writeIni
//   Methods for reading and writing ini files in this framework. This only
//   occurs if an ini file has been specified
//
//   These can be replaced with other storage mechanisms such as Rob Stucky's
//   ScriptStore class.
//
GenericUI.readIni = function(iniFile, ini) {
  //$.level = 1; debugger;

  if (!ini) {
    ini = {};
  }
  if (!iniFile) {
    return ini;
  }
  var file = GenericUI.iniFileToFile(iniFile);

  if (!file) {
    Error.runtimeError(9001, Error("Bad ini file specified: \"" + iniFile + "\"."));
  }

  if (!file.exists) {
    //
    // XXX Check for an ini path .ini file in the script's folder.
    //
  }

  if (file.exists && file.open("r", "TEXT", "????")) {
    file.lineFeed = "unix";
    file.encoding = GenericUI.ENCODING;
    var str = file.read();
    ini = GenericUI.iniFromString(str, ini);
    file.close();
  }

  if (ini.noUI) {
    ini.noUI = toBoolean(ini.noUI);
  }

  return ini;
};
GenericUI.iniToString = function(ini) {
  var str = '';
  for (var idx in ini) {
    if (idx.charAt(0) == '_') {         // private stuff
      continue;
    }
    if (idx == 'typename') {
      continue;
    }
    if (idx == "noUI") {                // GenericUI property
      continue;
    }
    var val = ini[idx];

    if (val == undefined) {
      continue;
    }

    if (val.constructor == String ||
        val.constructor == Number ||
        val.constructor == Boolean ||
        typeof(val) == "object") {
      str += (idx + ": " + val.toString() + "\n");
    }
  }
  return str;
};
GenericUI.overwriteIni = function(iniFile, ini) {
  //$.level = 1; debugger;
  if (!ini || !iniFile) {
    return;
  }
  var file = GenericUI.iniFileToFile(iniFile);

  if (!file) {
    Error.runtimeError(9001, Error("Bad ini file specified: \"" + iniFile + "\"."));
  }

  if (file.open("w", "TEXT", "????")) {
    file.lineFeed = "unix";
    file.encoding = GenericUI.ENCODING;
    var str = GenericUI.iniToString(ini);
    file.write(str);
    file.close();
  }
  return ini;
};

GenericUI.iniToDescriptor = function(ini, desc) {
  if (!desc) {
    desc = new ActionDescriptor();
  }
  var str = GenericUI.iniToString(ini);
  desc.putString(sTID("INI Data"), str);
  return desc;
};
GenericUI.iniFromDescriptor = function(desc) {
  var ini = {};
  if (!desc || desc.count == 0) {
    return ini;
  }
  if (desc.hasString(sTID("INI Data"))) {
    var str = desc.getString(sTID("INI Data"));
    ini = GenericUI.iniFromString(str);
  }
  return ini;
};

//
// Updating the ini file retains the ini file layout including any externally
// add comments, blank lines, and the property sequence
//
GenericUI.updateIni = function(iniFile, ini) {
  if (!ini || !iniFile) {
    return undefined;
  }
  var file = GenericUI.iniFileToFile(iniFile);

  // we can only update the file if it exists
  var update = file.exists;
  var str = '';

  if (update) {
    file.open("r", "TEXT", "????");
    file.encoding = GenericUI.ENCODING;
    file.lineFeed = "unix";
    str = file.read();
    file.close();

    for (var idx in ini) {
      if (idx.charAt(0) == '_') {         // private stuff
        continue;
      }
      if (idx == "noUI") {
        continue;
      }
      if (idx == "typename") {
        continue;
      }

      var val = ini[idx];

      if (typeof(val) == "undefined") {
        val = '';
      }

      if (typeof val == "string" ||
          typeof val == "number" ||
          typeof val == "boolean" ||
          typeof val == "object") {
        idx += ':';
        var re = RegExp('^' + idx, 'm');

        if (re.test(str)) {
          re = RegExp('^' + idx + '[^\n]*', 'm');
          str = str.replace(re, idx + ' ' + val);
        } else {
          str += '\n' + idx + ' ' + val;
        }
      }
    }
  } else {
    // write out a new ini file
    for (var idx in ini) {
      if (idx.charAt(0) == '_') {         // private stuff
        continue;
      }
      if (idx == "noUI") {
        continue;
      }
      var val = ini[idx];

      if (typeof val == "string" ||
          typeof val == "number" ||
          typeof val == "boolean" ||
          typeof val == "object") {
        str += (idx + ": " + val.toString() + "\n");
      }
    }
  }

  if (str) {
    file.open("w", "TEXT", "????");
    file.encoding = GenericUI.ENCODING;
    file.lineFeed = "unix";
    file.write(str);
    file.close();
  }

  return ini;
};

GenericUI.writeIni = GenericUI.updateIni;

//XXX this widget stuff is untested
GenericUI._widgetMap = {
  button: 'text',
  checkbox: 'value',
  dropdownlist: 'selection',
  edittext: 'text',
  iconbutton: 'icon',
  image: 'icon',
  listbox: 'selection',
  panel: 'text',
  progressbar: 'value',
  radiobutton: 'value',
  scrollbar: 'value',
  slider:  'value',
  statictext: 'text',
};
//
// These next two need to be tweaked for dropdownlist and listbox
// I'm not sure quite yet what the best interface should be, so I'll
// pass for now.
//
GenericUI.getWidgetValue = function(w) {
  var prop = GenericUI._widgetMap[w.type];
  var t = w.type;
  var v = undefined;
  if (prop) {
    if (t == 'listbox' || t == 'dropdownlist') {
      v = w.selection.text;
    } else {
      v = w[prop];
    }
  }
  return prop ? w[prop] : undefined;
};
GenericUI.setWidgetValue = function(w, v) {
  var prop = GenericUI._widgetMap[w.type];
  if (prop) {
    var t = w.type;
    if (t == 'checkbox' || t == 'radiobox') {
      w[prop] = v.toString().toLowerCase() == 'true';
    } else if (t == 'progressbar' || t == 'scrollbar' || t == 'slider') {
      var n = Number(v);
      if (!isNaN(n)) {
        w[prop] = n;
      }
    } else if (t == 'listbox' || t == 'dropdownlist') {
      var it = w.find(v);
      if (it) {
        w.selection = it;
        it.selected = true;
      }
    } else {
      w[prop] = v;
    }
  }
  return v;
};

//
// createPanel returns a panel specific to this app
//    win is the window into which the panel to be inserted
//    ini is an object containing default values for the panel
//
GenericUI.prototype.createPanel = function(pnl, ini, doc) {};

//
// validatePanel returns
//    - an object representing the gather input
//    - true if there was an error, but continue gathering input
//    - false if there was an error and terminate
//
GenericUI.prototype.validatePanel = function(pnl, ini) {};

//
// Called by the framework to do whatever processing the script is
// supposed to perform.
//
GenericUI.prototype.process = function(opts, doc) {};

//
// Called by the framework if the user 'canceled' the UI
//
GenericUI.prototype.cancel = function(doc) {};

GenericUI.numberKeystrokeFilter = function() {
  if (this.text.match(/[^\-\.\d]/)) {
    this.text = this.text.replace(/[^\-\.\d]/g, '');
  }
};
GenericUI.numericKeystrokeFilter = function() {
  if (this.text.match(/[^\d]/)) {
    this.text = this.text.replace(/[^\d]/g, '');
  }
};

GenericUI.unitValueKeystrokeFilter = function() {
  if (this.text.match(/[^a-z0-9% \.]/)) {
    this.text = this.text.toLowerCase().replace(/[^a-z0-9% \.]/g, '');
  }
};

GenericUI.rexKeystrokeFilter = function(w, rex) {
  // XXX fix this
  w._rex = rex;
  w._rexG = new RegExp(rex.toString(), 'g');
  w._rexFilter = function() {
    if (this.text.match(this._rex)) {
      this.text = this.text.toLowerCase().replace(this._regG, '');
    }
  };
};

GenericUI.setMenuSelection = function(menu, txt, def) {
  var it = menu.find(txt);
  if (!it) {
    if (def != undefined) {
      var n = toNumber(def);
      if (!isNaN(n)) {
        it = def;

      } else {
        it = menu.find(def);
      }
    }
  }

  if (it != undefined) {
    menu.selection = it;
  }
};

//
// createProgressPalette
//   title     the window title
//   min       the minimum value for the progress bar
//   max       the maximum value for the progress bar
//   parent    the parent ScriptUI window (opt)
//   useCancel flag for having a Cancel button (opt)
//   msg       a message that can be displayed (and changed) in the palette (opt)
//
//   onCancel  This method will be called when the Cancel button is pressed.
//             This method should return 'true' to close the progress window
//
GenericUI.createProgressPalette = function(title, min, max,
                                           parent, useCancel, msg) {
  var win = new Window('palette', title);
  win.bar = win.add('progressbar', undefined, min, max);
  if (msg) {
    win.msg = win.add('statictext');
    win.msg.text = msg;
  }
  win.bar.preferredSize = [500, 20];

  win.parentWin = undefined;
  win.recenter = false;
  win.isDone = false;

  if (parent) {
    if (parent instanceof Window) {
      win.parentWin = parent;
    } else if (useCancel == undefined) {
      useCancel = !!parent;
    }
  }

  if (useCancel) {
    win.onCancel = function() {
      this.isDone = true;
      return true;  // return 'true' to close the window
    };

    win.cancel = win.add('button', undefined, 'Cancel');

    win.cancel.onClick = function() {
      var win = this.parent;
      try {
        win.isDone = true;
        if (win.onCancel) {
          var rc = win.onCancel();
          if (rc != false) {
            if (!win.onClose || win.onClose()) {
              win.close();
            }
          }
        } else {
          if (!win.onClose || win.onClose()) {
            win.close();
          }
        }
      } catch (e) {
        var msg = Stdlib.exceptionMessage(e);
        Stdlib.log(msg);
        alert(msg);
      }
    };
  }

  win.onClose = function() {
    this.isDone = true;
    return true;
  };

  win.updateProgress = function(val) {
    var win = this;

    if (val != undefined) {
      win.bar.value = val;
    }
//     else {
//       win.bar.value++;
//     }

    if (win.recenter) {
      win.center(win.parentWin);
    }

    win.show();
    win.hide();
    win.show();
  };

  win.recenter = true;
  win.center(win.parent);

  return win;
};

// might need something like this later...
GenericUI.confirm = function(msg) {
  var win = new Window('palette', 'Script Alert');
  win.msg = win.add('statictext', undefined, msg, {multiline: true});

  win._state = false;
  win.ok = win.add('button', undefined, 'Yes');
  win.ok.onClick = function() {
    this.parent._state = true;
  };
  win.cancel = win.add('button', undefined, 'No');
  win.show();

  return win._state;
};

// GenericUI.alert(Stdlib.readFromFile("~/Desktop/test.xml"), [500, 300]);
// GenericUI.alert("This is a simple alert");

GenericUI.alert = function(msg, size, parent, showAlertText) {
  // alert(msg); return;

  var props = {minimize: false, maximize: false};
  var win = new Window('dialog', 'Script Alert', undefined, props);
  win.orientation = "column";

  if (showAlertText) {
    win.alertTitle = win.add('statictext', undefined, "ALERT");

    // set ALERT to red
    var gfx = win.alertTitle.graphics;
    gfx.foregroundColor = gfx.newPen(gfx.BrushType.SOLID_COLOR, [1,0,0], 1);
  }

  var tprops = {multiline: true, scrolling: true};
  if (!size) {
    size = [GenericUI.alert.DEFAULT_WIDTH, GenericUI.alert.DEFAULT_HEIGHT];
    tprops.scrolling = false;
  }
  win.msg = win.add('statictext', undefined, msg, tprops);

  win.msg.preferredSize = size;

  win.ok = win.add('button', undefined, 'OK');
  win.ok.onClick = function() {
    this.parent.close(1);
  };
  // win.cancel = win.add('button', undefined, 'No');

  win.center(parent);
  return win.show();
};

GenericUI.alert.DEFAULT_WIDTH = 300;
GenericUI.alert.DEFAULT_HEIGHT = 75;

//
//=============================== GenericOptions ==============================
//
GenericOptions = function(obj) {
  if (obj) {
    GenericOptions.copyFromTo(obj, this);
  }
};

function toBoolean(s) {
  if (s == undefined) { return false; }
  if (s.constructor == Boolean) { return s.valueOf(); }
  try { if (s instanceof XML) s = s.toString(); } catch (e) {}
  if (s.constructor == String)  { return s.toLowerCase() == "true"; }
  return Boolean(s);
};

function toNumber(s, def) {
  if (s == undefined) { return NaN; }
  try { if (s instanceof XML) s = s.toString(); } catch (e) {}
  if (s.constructor == String && s.length == 0) { return NaN; }
  if (s.constructor == Number) { return s.valueOf(); }
  return Number(s.toString());
};

function toFont(fs) {
  if (fs.typename == "TextFont") { return fs.postScriptName; }

  var str = fs.toString();
  var f = Stdlib.determineFont(str);  // first, check by PS name

  return (f ? f.postScriptName : undefined);
};

GenericOptions.copyFromTo = function(from, to) {
  if (!from || !to) {
    return;
  }
  for (var idx in from) {
    var v = from[idx];
    if (typeof v != 'function') {
        to[idx] = v;
    }
  }
};

GenericOptions.prototype.hasKey = function(k) {
  return this[key] != undefined;
};
GenericOptions.prototype.getBoolean = function(k, def) {
  var self = this;
  return self.hasKey(k) ? toBoolean(self[k]) : def;
};
GenericOptions.prototype.getInteger = function(k, def) {
  var self = this;
  return self.hasKey(k) ? toNumber(self[k]).toFixed(0) : def;
};
GenericOptions.prototype.getDouble = function(k, def) {
  var self = this;
  return self.hasKey(k) ? toNumber(self[k]) : def;
};
GenericOptions.prototype.getPath = function(k, def) {
  var self = this;
  return self.hasKey(k) ? File(self[k]) : def;
};
GenericOptions.prototype.getArray = function(k, def) {
  var self = this;
  if (!self.hasKey(k)) {
    return def;
  }
  var s = self[k];
  return s.split(',');
};

GenericOptions.prototype.getColor = function(k, def) {
  var self = this;
  if (!self.hasKey(k)) {
    return def;
  }
  var c = self[k];
  if (!(c instanceof SolidColor)) {
    if (c.constructor == String) {
      c = s.split(',');
    }
    if (c instanceof Array) {
      var rgbc = new SolidColor();
      rgbc.rgb.red = c[0];
      rgbc.rgb.green = c[1];
      rgbc.rgb.blue = c[2];
      c = rgbc;
    } else {
      c = undefined;
    }
  }
  return c;
};

GenericOptions.prototype.getObject = function(k, def) {
  var self = this;
  if (!self.hasKey(k)) {
    return def;
  }
  var os = self[k];
  var obj = undefined;
  try { eval('obj = ' + os); } finally {}
  return obj;
};

if (!String.prototype.contains) {

String.prototype.contains = function(sub) {
  return this.indexOf(sub) != -1;
};

String.prototype.containsWord = function(str) {
  return this.match(new RegExp("\\b" + str + "\\b")) != null;
};

String.prototype.endsWith = function(sub) {
  return this.length >= sub.length &&
    this.substr(this.length - sub.length) == sub;
};

String.prototype.reverse = function() {
  var ar = this.split('');
  ar.reverse();
  return ar.join('');
};

String.prototype.startsWith = function(sub) {
  return this.indexOf(sub) == 0;
};

String.prototype.trim = function() {
  return this.replace(/^[\s]+|[\s]+$/g, '');
};
String.prototype.ltrim = function() {
  return this.replace(/^[\s]+/g, '');
};
String.prototype.rtrim = function() {
  return this.replace(/[\s]+$/g, '');
};

}  // String.prototype.contains.

// see SampleUI for an example of how to use this framework.

"GenericUI.jsx";

// EOF

//
// ColorChooser
//
// This script has undergone a lof of change. Larry's basic idea is still
// in there, but much of it has been reworked.
//
// This script is an extension of Larry Ligon's color picker script.
// Found at: http://www.ps-scripts.com/bb/viewtopic.php?t=659
//
// I have left as much of his code intact as is possible. I did fix
// one typo, added code to make the text entry fields functional,
// and set it up so that app.foreground is reset after the chooser is closed
//
// Description:
//   This class has one public function ('run') that will open an RGB
//   color selection dialog and return the selected color or 'undefined'
//   if the user canceled the operation.
//
// Usage:
//    var color = ColorChooser.run();
//
// $Id: XWatermark.jsx,v 1.74 2015/12/03 22:01:33 anonymous Exp $
//
// Program Name:  Set the foreground color
//
// Author:        Larry B. Ligon
//
// Purpose:       This JavaScript will allow the user to change the foreground color
//

ColorChooser = function() {
};

ColorChooser.selectedColor = undefined;

ColorChooser.numericKeystrokeFilter = function() {
  if (this.text.match(/[^\d]/)) {
    this.text = this.text.replace(/[^\d]/g, '');
  }
};

ColorChooser.createDialog = function(defColor, winX, winY) {
  if (!winX) {
    winX = 100;
  }
  if (!winY) {
    winY= 100;
  }

  var winW = 400;
  var winH = 400;

  var bounds = { x : winX, y : winY, width : winW, height : winH };

  var win = new Window('dialog', 'Color Chooser' );

  if (!defColor) {
    defColor = app.foregroundColor;
  }

  win.orientation = 'column';

  win.updateColor = function() {
    var win = this;
    var clr = new SolidColor();
    clr.rgb.red   = Math.round(win.redPnl.cslider.value);
    clr.rgb.green = Math.round(win.greenPnl.cslider.value);
    clr.rgb.blue  = Math.round(win.bluePnl.cslider.value);
    win._color = clr;
    app.foregroundColor = clr;
  };

  function createChannelPanel(win, name) {
    var pnl = win.add("panel", undefined, name);
    pnl.updateColor = function() {
      var win = this.parent;
      win.updateColor();
    }
    pnl.alignChildren = "right";
    pnl.orientation = 'row';
    pnl.cslider = pnl.add('scrollbar', undefined,
                                255, 0, 255);
    pnl.cslider.csize = [100,20];
    pnl.cvalue = pnl.add('edittext');
    pnl.cvalue.preferRedSize = [40,25];

    pnl.cvalue.onChanging = ColorChooser.numericKeystrokeFilter;

    pnl.cvalue.onChange = function () {
      var pnl = this.parent;
      var cn = Number(pnl.cvalue.text);
      if (isNaN(cn)) {
        alert(pnl.name + " value is not a valid number");
      }
      if (cn > 255) {
        cn = 255;
        pnl.cvalue.text = 255;
      }
      if (cn < 0) {
        cn = 0;
        pnl.cvalue.text = 0;
      }
      pnl.cslider.value = cn;
      pnl.cslider.onChanging();
    };

    pnl.cvalue.text = Math.round(pnl.cslider.value);
    pnl.cslider.onChanging = function () {
      var pnl = this.parent;
      pnl.cvalue.text = Math.round(pnl.cslider.value);
      pnl.updateColor();
    };

    return pnl;
  }

  win.redPnl = createChannelPanel(win, "Red");
  win.greenPnl = createChannelPanel(win, "Green");
  win.bluePnl = createChannelPanel(win, "Blue");

  win.ok = win.add("button", undefined, "OK" );
  win.ok.onClick = function() {
    this.parent.close(1);
  };

  win.layout.layout(true);

  win.redPnl.cslider.value = defColor.rgb.red;
  win.redPnl.cslider.onChanging();
  win.greenPnl.cslider.value = defColor.rgb.green;
  win.greenPnl.cslider.onChanging();
  win.bluePnl.cslider.value = defColor.rgb.blue;
  win.bluePnl.cslider.onChanging();

  return win;
};

ColorChooser.runColorPicker = function(defColor) {
  if (isBridge()) {
    if (!defColor) {
      defColor = "0x000000";
    } else {
      defColor = "0x" + defColor.replace(/#/g, '');
    }

    var c = parseInt(defColor);
    var bytes = $.colorPicker(c);

    if (bytes != -1) {
      var str = Stdlib.longToHex(bytes);
      return str.substring(2);
    }
    return undefined;
  }


  var color = undefined;
  if (!defColor) {
    defColor = app.foregroundColor;
  }

  try {
    var bytes;
    var rgb = defColor.rgb;
    bytes = (rgb.red << 16) + (rgb.green << 8) + rgb.blue;
    bytes = $.colorPicker(bytes);
    
    if (bytes != -1) {
      var c = new SolidColor();
      c.rgb.red = (bytes >> 16);
      c.rgb.green = (bytes >> 8) & 0xFF;
      c.rgb.blue = bytes & 0xFF;
      color = c;
    }
  } catch (e) {
    alert(e);
  }

  return color;
};

ColorChooser.run = function(def) {
  var rev = toNumber(app.version.match(/^\d+/)[0]);
  if (rev > 10 || isBridge()) {
    return ColorChooser.runColorPicker(def);
  }

  var fgOrig = app.foregroundColor;
  var fgColor = app.foregroundColor;
  if (def) {
    app.foregroundColor = def;
    fgColor = def;
  }

  try {
    var win = ColorChooser.createDialog(fgColor);
    var rc = win.show();

    if (rc == 1) {
      ColorChooser.selectedColor = win._color;
    }

  } finally {
    app.foregroundColor = fgOrig;
  }

  return ColorChooser.selectedColor;
};

//
// Sample usage
//
ColorChooser.main = function() {
  var c = ColorChooser.run();
  if (c) {
    c = c.rgb;
    alert("RGB=[" + c.red + ", " + c.green + ", " + c.blue + "]");
  } else {
    alert("No color chosen");
  }
};
//ColorChooser.main();

"ColorChooser.jsx";
// EOF


//
// ColorSelectorPanel
//    pnl.fontColor = pnl.add('group', [xx,yy,xx+300,yy+45]);
//    ColorSelectorPanel.createPanel(pnl.fontColor, opts.fontColor, '');
//    ...
//    var color = pnl.fontColor.getColor();
//
// $Id: XWatermark.jsx,v 1.74 2015/12/03 22:01:33 anonymous Exp $
// Copyright: (c)2008, xbytor
// License: http://www.opensource.org/licenses/bsd-license.php
// Contact: xbytor@gmail.com
//

ColorSelectorPanel = function() {
};

ColorSelectorPanel.temp = Folder.temp;
ColorSelectorPanel.cachesFiles = true;

ColorSelectorPanel.RGB = "RGB...";

ColorSelectorPanel.rgbFromString = function(str) {
  var rex = /([\d\.]+),([\d\.]+),([\d\.]+)/;
  var m = str.match(rex);
  if (m) {
    return ColorSelectorPanel.createRGBColor(Number(m[1]),
                                 Number(m[2]),
                                 Number(m[3]));
  }
  return undefined;
};
ColorSelectorPanel.rgbToString = function(c) {
  return c.rgb.red + "," + c.rgb.green + "," + c.rgb.blue;
};

ColorSelectorPanel.createRGBColor = function(r, g, b) {
  var c = new RGBColor();
  if (r instanceof Array) {
    b = r[2]; g = r[1]; r = r[0];
  }
  c.red = parseInt(r); c.green = parseInt(g); c.blue = parseInt(b);
  var sc = new SolidColor();
  sc.rgb = c;
  return sc;
};

ColorSelectorPanel.COLOR_BLACK = ColorSelectorPanel.createRGBColor(0, 0, 0);
ColorSelectorPanel.COLOR_WHITE = ColorSelectorPanel.createRGBColor(255, 255, 255);

ColorSelectorPanel.hexColorFromString = function(str) {
  var clr = undefined;
  var hexColorRex = /^#?[A-Fa-f0-9]{6}$/;

  if (str.constructor == String) {
    if (str.match(hexColorRex)) {
      clr = new SolidColor();
      if (str[0] == '#') {
        str = str.slice(1);
      }

      clr.rgb.hexValue = str;
    }
  } else if (str instanceof SolidColor) {
    clr = str;
  }

  return clr;
};

ColorSelectorPanel.colorFromString = function(str) {
  var c = undefined;

  if (str && str.constructor == String) {
    str = str.toLowerCase();

    if (str.match(/,/)) {
      c = ColorSelectorPanel.rgbFromString(str);
    } else if (str[0] == '#') {
      c = ColorSelectorPanel.hexColorFromString(color);
    } else if (str == "black") {
      c = ColorSelectorPanel.COLOR_BLACK;
    } else if (str == "white") {
      c = ColorSelectorPanel.COLOR_WHITE;
    } else if (str == "foreground") {
      c = app.foregroundColor;
    } else if (str == "background") {
      c = app.backgroundColor;
    }
  }

  return c;
};

ColorSelectorPanel.stringFromColor = function(clr) {
  var str = '';

  if (clr && clr.typename == 'SolidColor') {
    if (clr.rgb.hexValue == '000000') {
      str = 'Black';
    } else if (clr.rgb.hexValue == 'FFFFFF') {
      str = 'White';
    } else if (clr.isEqual(app.foregroundColor)) {
      str = "Foreground";
    } else if (clr.isEqual(app.backgroundColor)) {
      str = "Background";
    } else {
      str = ColorSelectorPanel.rgbToString(clr);
    }
  }

  return str;
};
ColorSelectorPanel.menuItemFromColor = function(clr) {
  var str = ColorSelectorPanel.stringFromColor(clr);

  if (str.match(/,/)) {
    str = ColorSelectorPanel.RGB;
  }
  return str;
};

//
// ColorSelectorPanel.configColorButton
//   This function adds a callback to iconBtn to launch a ColorChooser
//   to allow a user to select a new color. The color of the button changes
//   to reflect the chosen color.
//   The clrStr is the default color. It can be a color object, array, or
//   string. See ColorSelectorPanel.getColorIcon for format details for the
//   parameter.
//   When a color has been chosen, the iconBtn._color property will be
//   set to the corresponding color object. The button will also call
//   a new onColorChange callback when the color is changed.
//
ColorSelectorPanel.configColorButton = function(iconBtn) {

  iconBtn.onColorChange = function() {
    var pnl = this.parent;
    var clr = pnl.colorIconButton._color;

    var menuItem = ColorSelectorPanel.menuItemFromColor(clr);

    var it = pnl.colorList.find(menuItem);
    it.selected = true;
    pnl.colorList.selection = it;
  };

  iconBtn.setColor = function(clr) {
    var self = this;

    if (!clr) {
      return;
    }
    var icon = ColorSelectorPanel.getColorIcon(clr);
    if (icon) {
      self.icon = icon.file;
      self._color = icon.color;

      if (self.onColorChange) {
        self.onColorChange();
      }
    }
    return icon.color;
  };

  iconBtn.onClick = function() {
    var self = this;
    var pnl = this.parent;
    var color = ColorChooser.run(self._color);

    pnl._settingColor = true;
    if (color) {
      self.setColor(color);
    }
    pnl._settingColor = false;

    return color;
  };

  iconBtn.setColor("Black");
};

//
// ColorSelectorPanel.getColorIcon (color)
//   Returns an plain object with two fields  or undefined if it couldn't
//               figure out what 'color' was.
//       file:   is a 40x20 png of the specified color
//       color:  is the actual underlying SolidColor. If you passed a
//               SolidColor object, that's what you get back, if not, this
//               is what happened when your 'color' got converted
//
//   'color' can be a SolidColor, RGBColor, Array, or a String.
//   If it's an Array, it must be 3 RGB numbers.
//   If it's a String, it must be in one of these formats:
//     "255,255,255"
//     "#FFFFFF"
//     "FEFEFE"
//
//   The png file that is returned has a name format like this: 'FFFF00.png'
//   and it created in the Folder.temp directory. This folder can be overridden
//   by setting the property ColorSelectorPanel.getColorIcon.temp to
//  another folder.
//
//   The property ColorSelectorPanel.getColorIcon.cacheFiles controls whether or
//   not a new png icon file is generated with each request or the cache is
//   used.
//   Files are cached by default.
//
ColorSelectorPanel.getColorIcon = function(color) {
  var clr = undefined;

  if (!color) {
    return undefined;
  }

  // Try to make sense of the 'color' we've been given
  if (color.constructor == String) {
    clr = ColorSelectorPanel.colorFromString(color);

  } else if (color.constructor == Array && color.length == 3) {
    clr = Stdlib.createRGBColor(color);

  } else if (color instanceof RGBColor) {
    clr = new SolidColor();
    clr.rgb = color;

  } else if (color instanceof SolidColor) {
    clr = color;
  }

  if (!clr) {
    return undefined;
  }

  // Now lets make sure that we have a good 'temp' Folder
  if (ColorSelectorPanel.temp.constructor == String) {
    var f = new Folder(ColorSelectorPanel.temp);

    if (!f.exists) {
      if (!f.create()) {
        f = Folder.temp;
      }
    }
    ColorSelectorPanel.temp = f;

  } else if (!(ColorSelectorPanel.temp instanceof Folder)) {
    ColorSelectorPanel.temp = Folder.temp;
  }

  var cname = clr.rgb.hexValue;
  var file = new File(ColorSelectorPanel.temp + '/' + cname + '.png');

  // this checks to see if we've already built the preview before
  if (ColorSelectorPanel.cachesFiles) {
    if (file.exists) {
      return { file: file, color: clr };
    }
  }

  var ru = app.preferences.rulerUnits;
  app.preferences.rulerUnits = Units.PIXELS;

  try {
    var doc = Stdlib.newDocument(cname, "RGBM", 40, 20, 72, 8);

  } finally {
    app.preferences.rulerUnits = ru;
  }

  doc.selection.selectAll();
  doc.selection.fill(clr, ColorBlendMode.NORMAL, 100);
  var saveOpts = new PNGSaveOptions();
  doc.saveAs(file, saveOpts, true);
  doc.close(SaveOptions.DONOTSAVECHANGES);

  return { file: file, color: clr };
};

ColorSelectorPanel.createPanel = function(pnl, defaultColor, label, lwidth) {
  var xx = 0;
  var yy = 0;
  var tOfs = ((CSVersion() > 2) ? 3 : 0);

  if (pnl.type == 'panel') {
    xx += 5;
    yy += 5;
  }

  if (!defaultColor) {
    defaultColor = "Black";
  }

  if (label == undefined) {
    label = "Color:";
    lwidth = 40;
  }

  if (label != '') {
    pnl.colorListLabel = pnl.add("statictext",
                                 [xx,yy+tOfs,xx+lwidth,yy+22+tOfs],
                                 label);
    xx += lwidth;
  }

  pnl.colorList = pnl.add('dropdownlist',
                          [xx,yy,xx+130,yy+22],
                          ['Black',
                           'White',
                           'Foreground',
                           'Background',
                           ColorSelectorPanel.RGB]);

  pnl.colorList.isRGB = function() {
    return this.selection && this.selection.text == ColorSelectorPanel.RGB;
  }

  xx += 150;
  pnl.colorIconButton = pnl.add('iconbutton', [xx,yy,xx+44,yy+24],
                              undefined, {style: 'button'});

  ColorSelectorPanel.configColorButton(pnl.colorIconButton);

  pnl.colorList.onChange = function() {
    var pnl = this.parent
    if (pnl._settingColor) {
      return;
    }

    var txt = pnl.colorList.selection.text;
    var clr = ColorSelectorPanel.colorFromString(txt);

    if (clr) {
      pnl.colorIconButton.setColor(clr);

    } else {
      clr = pnl.colorIconButton.onClick();

      if (!clr && pnl._lastMenuItem && pnl._lastMenuItem !=  txt) {
        pnl._settingColor = true;

        txt = pnl._lastMenuItem;
        var it = pnl.colorList.find(txt);

        if (it) {
          pnl.colorList.selection = it;
        } else {
          pnl.colorList.selection = pnl.colorList.items[0];
        }

        pnl._settingColor = false;
      }
    }

    pnl._lastMenuItem = txt;
  }

  pnl._settingColor = false;
  pnl.setColor = function(color) {
    var pnl = this;

    if (pnl._settingColor) {
      return;
    }
    pnl._settingColor = true;

    try {
      if (!color) {
        return;
      }

      if (color.constructor == String) {
        color = ColorSelectorPanel.colorFromString(color);
      }

      if (color && color.typename == "SolidColor") {
        var txt = ColorSelectorPanel.menuItemFromColor(color);

        var it = pnl.colorList.find(txt);
        // notification is turned off...

        if (it) {
          pnl.colorList.selection = it;
        } else {
          pnl.colorList.selection = pnl.colorList.items[0];
        }
        pnl._lastMenuItem = pnl.colorList.selection.text;

        pnl.colorIconButton.setColor(color);
      }

    } finally {
      pnl._settingColor = false;
    }
  }

  pnl.getColor = function() {
    var pnl = this;
    var ctxt = pnl.colorList.selection.text;
    var cstr;

    if (ctxt == ColorSelectorPanel.RGB) {
      cstr = Stdlib.rgbToString(pnl.colorIconButton._color);

    } else {
      cstr = ctxt;
    }

    return pnl.colorIconButton._color;
  }

  //
  // Set the initial color
  //
  pnl.setColor(defaultColor);

  return pnl;
};

"ColorSelectorPanel.jsx";
// EOF

//
// PresetsManager
//
// var mgr = new PresetsManager()
// var brushes = mgr.getNames(PresetType.BRUSHES);
//
//
//
//
//
// $Id: XWatermark.jsx,v 1.74 2015/12/03 22:01:33 anonymous Exp $
// Copyright: (c)2005, xbytor
// License: http://www.opensource.org/licenses/bsd-license.php
// Contact: xbytor@gmail.com
//
//
//--include "xlib/Stdlib.js"

//
// PresetType
//   This is an enumeration of the preset types available
//
PresetType = function(name, toolID, classID) {
  this.sym = toolID;
  this.name = name;
  this.id = xTID(toolID);
  this.classID = xTID(classID);
  this.toString = function() { return this.name; };
};
PresetType.BRUSHES        = new PresetType("Brushes", 'Brsh', 'Brsh');
PresetType.COLORS         = new PresetType("Colors", 'Clr ', 'Clr ');
PresetType.GRADIENTS      = new PresetType("Gradients", 'Grdn', 'Grad');
PresetType.STYLES         = new PresetType("Styles", 'StyC', 'Styl');
PresetType.PATTERNS       = new PresetType("Patterns", 'PttR', 'Ptrn');
PresetType.SHAPING_CURVES = new PresetType("Shaping Curves", 'ShpC', 'Shp ');
PresetType.CUSTOM_SHAPES  = new PresetType("Custom Shapes", 'customShape',
                                           'customShape');
PresetType.TOOL_PRESETS   = new PresetType("Tool Presets", 'toolPreset',
                                           'toolPreset');


//
//
// PresetsManager
//   This class is a container for all of the information that we can gather
//   about presets in Photoshop.
//
PresetsManager = function() {
  var self = this;

//   self.brushes       = [];
//   self.colors        = [];
//   self.gradients     = [];
//   self.styles        = [];
//   self.patterns      = [];
//   self.shapingCurves = [];
//   self.customShapes  = [];
//   self.toolPresets   = [];

  self.manager = null;
};
PresetsManager.prototype.typename = "PresetsManager";

//
// PresetsManager.getPresetsManager
//   Retrieves the PresetsManager object/list from Photoshop
//
PresetsManager.prototype.getPresetsManager = function() {
  var self = this;

  if (!self.manager) {
    var classApplication = cTID('capp');
    var typeOrdinal      = cTID('Ordn');
    var enumTarget       = cTID('Trgt');

    var ref = new ActionReference();
    ref.putEnumerated(classApplication, typeOrdinal, enumTarget);

    var appDesc = app.executeActionGet(ref);
    self.manager = appDesc.getList(sTID('presetManager'));
  }

  return self.manager;
};

PresetsManager.getManager = function(presetType) {
  var mgr = new PresetsManager();
  return new PTM(mgr, presetType);
};

PresetsManager.prototype.resetManager = function() {
  var self = this;
  self.manager = undefined;
};

PresetsManager.prototype.getCount = function(presetType) {
  if (presetType == undefined) {
    Error.runtimeError(2, "presetType");   // undefined
  }
  if (!(presetType instanceof PresetType)) {
    Error.runtimeError(19, "presetType");  // bad argument type
  }

  var self = this;

  var names = [];
  var key = presetType.id;
  var mgr = self.getPresetsManager();
  var max = mgr.count;

  for (var i = 0; i < max; i++) {
    var objType = mgr.getObjectType(i);
    if (objType == key) {
      break;
    }
  }

  if (i == max) {
    return -1;
  }
  var preset = mgr.getObjectValue(i);
  var list = preset.getList(cTID('Nm  '));
  return list.count;
};

//
//
PresetsManager.prototype.getNames = function(presetType) {
  if (presetType == undefined) {
    Error.runtimeError(2, "presetType");   // undefined
  }
  if (!(presetType instanceof PresetType)) {
    Error.runtimeError(19, "presetType");  // bad argument type
  }

  var self = this;

  var names = [];
  var key = presetType.id;
  var mgr = self.getPresetsManager();
  var max = mgr.count;

  for (var i = 0; i < max; i++) {
    var objType = mgr.getObjectType(i);
    if (objType == key) {
      break;
    }
  }

  if (i != max) {
    var preset = mgr.getObjectValue(i);
    var list = preset.getList(cTID('Nm  '));
    var max = list.count;
    for (var i = 0; i < max; i++) {
      var str = list.getString(i);
      names.push(str);
    }
    self[key] = names;
  }

  return names;
};

PresetsManager.prototype.resetPreset = function(presetType) {
  if (presetType == undefined) {
    Error.runtimeError(2, "presetType");   // undefined
  }
  if (!(presetType instanceof PresetType)) {
    Error.runtimeError(19, "presetType");  // bad argument type
  }

  var self = this;
  var ref = new ActionReference();
  ref.putProperty(cTID('Prpr'), presetType.classID);
  ref.putEnumerated(cTID('capp'), cTID('Ordn'), cTID('Trgt'));

  var desc = new ActionDescriptor();
  desc.putReference(cTID('null'), ref);

  executeAction(cTID('Rset'), desc, DialogModes.NO);
};

PresetsManager.prototype.saveAllPresets = function(presetType, fptr) {
  if (presetType == undefined) {
    Error.runtimeError(2, "presetType");   // undefined
  }
  if (fptr == undefined) {
    Error.runtimeError(2, "fptr");         // undefined
  }
  if (!(presetType instanceof PresetType)) {
    Error.runtimeError(19, "presetType");  // bad argument type
  }

  var self = this;

  var file = Stdlib.convertFptr(fptr);
  var desc = new ActionDescriptor();
  desc.putPath( cTID('null'), file);

  var ref = new ActionReference();
  ref.putProperty(cTID('Prpr'), presetType.classID);
  ref.putEnumerated(cTID('capp'), cTID('Ordn'), cTID('Trgt'));
  desc.putReference(cTID('T   '), ref);

  executeAction(cTID('setd'), desc, DialogModes.NO);
};

PresetsManager.prototype.loadPresets = function(presetType, fptr, append) {
  if (presetType == undefined) {
    Error.runtimeError(2, "presetType");   // undefined
  }
  if (fptr == undefined) {
    Error.runtimeError(2, "fptr");         // undefined
  }
  if (!(presetType instanceof PresetType)) {
    Error.runtimeError(19, "presetType");  // bad argument type
  }

  var self = this;

  var file = Stdlib.convertFptr(fptr);

  var ref = new ActionReference();
  ref.putProperty(cTID('Prpr'), presetType.classID);
  ref.putEnumerated(cTID('capp'), cTID('Ordn'), cTID('Trgt'));

  var desc = new ActionDescriptor();
  desc.putReference(cTID('null'), ref);
  desc.putPath(cTID('T   '), file);

  if (Boolean(append)) {
    desc.putBoolean(cTID('Appe'), true);
  }

  executeAction(cTID('setd'), desc, DialogModes.NO);
  self.resetManager();
};

PresetsManager.prototype.appendPresets = function(presetType, fptr) {
  this.loadPresets(presetType, fptr, true);
};

PresetsManager.prototype.getIndexOfElement = function(presetType, name) {
  if (presetType == undefined) {
    Error.runtimeError(2, "presetType");   // undefined
  }
  if (name == undefined) {
    Error.runtimeError(2, "name");         // undefined
  }
  if (!(presetType instanceof PresetType)) {
    Error.runtimeError(19, "presetType");  // bad argument type
  }

  var self = this;

  var names = self.getNames(presetType);
  for (var i = 0; i < names.length; i++) {
    if (names[i] == name) {
      return i+1;
    }
  }
  return -1;
};
PresetsManager.prototype.deleteElementAt = function(presetType, index) {
  if (presetType == undefined) {
    Error.runtimeError(2, "presetType");   // undefined
  }
  if (index == undefined) {
    Error.runtimeError(2, "index");       // undefined
  }
  if (!(presetType instanceof PresetType)) {
    Error.runtimeError(19, "presetType");  // bad argument type
  }

  var self = this;
  self.resetManager();

  var ref = new ActionReference();
  ref.putIndex(presetType.classID, index);

  var list = new ActionList();
  list.putReference(ref);

  var desc = new ActionDescriptor();
  desc.putList(cTID('null'), list);

  executeAction(cTID('Dlt '), desc, DialogModes.NO);
  self.resetManager();
};

PresetsManager.prototype.deleteElement = function(presetType, name) {
  var self = this;

  var idx = self.getIndexOfElement(presetType, name);

  if (idx == -1) {
    Error.runtimeError(9001, "Preset name '" + name + "' not found.");
  }

  self.deleteElementAt(presetType, idx);
};
PresetsManager.prototype.renameByIndex = function(presetType, index, name) {
  if (presetType == undefined) {
    Error.runtimeError(2, "presetType");   // undefined
  }
  if (index == undefined) {
    Error.runtimeError(2, "index");       // undefined
  }
  if (name == undefined) {
    Error.runtimeError(2, "name");        // undefined
  }
  if (!(presetType instanceof PresetType)) {
    Error.runtimeError(19, "presetType");  // bad argument type
  }

  var self = this;
  self.resetManager();
  var ref = new ActionReference();
  ref.putIndex(presetType.classID, index);

  var desc = new ActionDescriptor();
  desc.putReference(cTID('null'), ref);
  desc.putString(cTID('T   '), name);

  executeAction(cTID('Rnm '), desc, DialogModes.NO );
  self.resetManager();
};
PresetsManager.prototype.renameElement = function(presetType, oldName, newName) {
  var self = this;

  var idx = self.getIndexOfElement(oldName);

  if (idx == -1) {
    Error.runtimeError(9001, "Preset name '" + name + "' not found.");
  }

  self.renameByIndex(idx, newName);
};

PresetsManager.prototype.saveElementByIndex = function(presetType, index, fptr) {
  if (presetType == undefined) {
    Error.runtimeError(2, "presetType");   // undefined
  }
  if (index == undefined) {
    Error.runtimeError(2, "index");        // undefined
  }
  if (fptr == undefined) {
    Error.runtimeError(2, "fptr");         // undefined
  }
  if (!(presetType instanceof PresetType)) {
    Error.runtimeError(19, "presetType");  // bad argument type
  }

  var self = this;

  var file = Stdlib.convertFptr(fptr);

  if (file.exists) {
    file.remove();
  }

  var desc = new ActionDescriptor();
  desc.putPath(cTID('null'), file);
  var list = new ActionList();
  var ref = new ActionReference();
  ref.putIndex(presetType.classID, index);
  list.putReference(ref);
  desc.putList(cTID('T   '), list);
  executeAction(cTID('setd'), desc, DialogModes.NO );
};

PresetsManager.prototype.saveElement = function(presetType, name, fptr) {
  var self = this;

  var idx = self.getIndexOfElement(presetType, name);

  if (idx == -1) {
    Error.runtimeError(9001, "Preset name '" + name + "' not found.");
  }

  self.saveElementByIndex(presetType, idx, fptr);
};

// XXX add code here.... This is broken... fix later
PresetsManager.prototype.newElement = function(presetType, name, obj,
                                               interactive) {
  var desc = new ActionDescriptor();
  var ref = new ActionReference();
  ref.putClass( presetType.classID );
  desc.putReference( cTID('null'), ref );

  switch (presetType) {
    case PresetType.STYLES: {
      desc.putString(cTID('Nm  '), name);

      var lref = new ActionReference();
      lref.putEnumerated(cTID('Lyr '), cTID('Ordn'), cTID('Trgt'));
      desc.putReference(cTID('Usng'), lref);
      desc.putBoolean(sTID('blendOptions'), false);
      desc.putBoolean(cTID('Lefx'), true);
      break;
    };
    case PresetType.COLORS: {
      var color = obj;
      var swdesc = new ActionDescriptor();

      swdesc.putString(cTID('Nm  '), name);
      var cdesc = new ActionDescriptor();
      cdesc.putDouble(cTID('Rd  '), color.rgb.red);
      cdesc.putDouble(cTID('Grn '), color.rgb.green);
      cdesc.putDouble(cTID('Bl  '), color.rgb.blue);
      swdesc.putObject( cTID('Clr '), cTID('RGBC'), cdesc);
      desc.putObject(cTID('Usng'), cTID('Clrs'), swdesc);
    };
    case PresetType.PATTERNS: {
      var ref = new ActionReference();
        ref.putProperty(cTID('Prpr'), cTID('fsel'));
        ref.putEnumerated(cTID('Dcmn'), cTID('Ordn'), cTID('Trgt'));
        desc.putReference(cTID('Usng'), ref);
    };

    case PresetType.BRUSHES:
    case PresetType.CUSTOM_SHAPE:
    case PresetType.TOOL_PRESETS: {
      desc.putString(cTID('Nm  '), name);
      var ref = new ActionReference();
      ref.putProperty(cTID('Prpr'), cTID('CrnT'));
      ref.putEnumerated(cTID('capp'), cTID('Ordn'), cTID('Trgt'));
      desc.putReference(cTID('Usng'), ref);
    };

    case PresetType.SHAPING_CURVES:
    case PresetType.GRADIENTS:
    default: break;
  }
  var mode = (interactive ? DialogModes.ALL : DialogModes.NO);

  var xdesc = executeAction(cTID('Mk  '), desc, mode);
  return xdesc;
};


PresetsManager.prototype.populateDropdownList = function(presetType, ddlist,
                                                         none) {
  var self = this;
  var names = self.getNames(presetType);

  if (none) {
    ddlist.add("item", "None");
  }
  for (var i = 0; i < names.length; i++) {
    ddlist.add("item", names[i]);
  }
};

/*
//  //@include "xlib/PresetsManager.jsx"
//  PresetsManager.placeShape(doc, 'Cat Print', undefined, true);
//
*/
PresetsManager.placeShape = function(doc, name, bnds) {
  if (bnds) {
    if (bnds[0] instanceof UnitValue) {
      // assume we have an array of pixels...
      bnds[0].type = "px";
      var b = [];
      b.push(bnds[0].value);
      b.push(bnds[1].value);
      b.push(bnds[2].value);
      b.push(bnds[3].value);
      bnds = b;
    }
  } else {
    var ru = app.preferences.rulerUnits;
    app.preferences.rulerUnits = Units.PIXELS;
    bnds = [0,0,0,0];
    bnds[2] = doc.width.value / 4;
    bnds[3] = doc.height.value / 4;
    app.preferences.rulerUnits = ru;
  }

  function _ftn() {
    var desc = new ActionDescriptor();
    var ref = new ActionReference();
    ref.putClass(sTID('contentLayer'));
    desc.putReference(cTID('null'), ref);
    var tdesc = new ActionDescriptor();
    tdesc.putClass(cTID('Type'), sTID('solidColorLayer'));
    var sdesc = new ActionDescriptor();
    sdesc.putString(cTID('Nm  '), name);
    if (bnds) {
      sdesc.putUnitDouble(cTID('Left'), cTID('#Pxl'), bnds[0]);
      sdesc.putUnitDouble(cTID('Top '), cTID('#Pxl'), bnds[1]);
      sdesc.putUnitDouble(cTID('Rght'), cTID('#Pxl'), bnds[2]);
      sdesc.putUnitDouble(cTID('Btom'), cTID('#Pxl'), bnds[3]);
    }
    tdesc.putObject(cTID('Shp '), sTID('customShape'), sdesc);
    desc.putObject(cTID('Usng'), sTID('contentLayer'), tdesc);
    executeAction(cTID('Mk  '), desc, DialogModes.NO);
  }

  return Stdlib.wrapLC(doc, _ftn);
};


//
// PresetTypeManager
//
PTM = function(mgr, presetType) {
  var self = this;
  if (mgr) {
    self.mgr = mgr;
  } else {
    self.mgr = new PresetsManager();
  }
  self.presetType = presetType;
};

PTM.prototype.reset = function() {
  this.mgr.resetManager();
};
PTM.prototype.getCount = function() {
  return this.mgr.getCount(this.presetType);
};
PTM.prototype.getNames = function() {
  return this.mgr.getNames(this.presetType);
};
PTM.prototype.resetPreset = function() {
  return this.mgr.resetPreset(this.presetType);
};
PTM.prototype.saveAllPresets = function(fptr) {
  return this.mgr.saveAllPresets(this.presetType, fptr);
};
PTM.prototype.loadPresets = function(fptr, append) {
  return this.mgr.loadPresets(this.presetType, fptr, append);
};
PTM.prototype.appendPresets = function(fptr) {
  return this.mgr.appendPresets(this.presetType, fptr);
};
PTM.prototype.getIndexOfElement = function(name) {
  return this.mgr.getIndexOfElement(this.presetType, name);
};
PTM.prototype.deleteElementAt = function(index) {
  return this.mgr.deleteElementAt(this.presetType, index);
};
PTM.prototype.deleteElement = function(name) {
  return this.mgr.deleteElement(this.presetType, name);
};
PTM.prototype.renameByIndex = function(index, name) {
  return this.mgr.renameByIndex(this.presetType, index, name);
};
PTM.prototype.renameElement = function(oldName, newName) {
  return this.mgr.renameElement(this.presetType, oldName, newName);
};
PTM.prototype.saveElementByIndex = function(index, fptr) {
  return this.mgr.saveElementByIndex(this.presetType, index, fptr);
};
PTM.prototype.saveElement = function(name, fptr) {
  return this.mgr.saveElement(this.presetType, name, fptr);
};
PTM.prototype.newElement = function(name, obj, interactive) {
  return this.mgr.newElement(this.presetType, name, obj, interactive);
};
PTM.prototype.populateDropdownList = function(ddlist, none) {
  return this.mgr.populateDropdownList(this.presetType, ddlist, none);
};

// _newStyle = function(name) {
//   var desc = new ActionDescriptor();
//   var ref = new ActionReference();
//   ref.putClass( cTID('Styl') );
//   desc.putReference( cTID('null'), ref );
//   desc.putString( cTID('Nm  '), name );
//   var lref = new ActionReference();
//   lref.putEnumerated(cTID('Lyr '), cTID('Ordn'), cTID('Trgt') );
//   desc.putReference( cTID('Usng'), lref );
//   desc.putBoolean( sTID('blendOptions'), false );
//   desc.putBoolean( cTID('Lefx'), true );
//   executeAction( cTID('Mk  '), desc, DialogModes.NO );
// };

// // _styleToHex();
// _styleToHex = function() {
//   debugger;
//   var styleMgr = new PTM(new PresetsManager(), PresetType.STYLES);

//   var sname = "__TEMP_STYLE__";

//   //var file = new File(Folder.temp + "/" + sname + ".asl");
//   var file = new File("/c/work/tmp/" + sname + ".asl");
//   if (file.exists) {
//     file.remove();
//   }

//   var idx = styleMgr.getIndexOfElement(sname);
//   if (idx != -1) {
//     styleMgr.deleteElementAt(idx);
//   }

//   var bin = '';
//   try {
//     _newStyle(sname);
//     styleMgr.saveElement(sname, file);
//     //styleMgr.deleteElement(sname);

//     var bin = Stdlib.readFromFile(file, 'BINARY');
//     alert(file.length);
//     //file.remove();

//   } catch (e) {
//     throw e;
//   }

//   return  Stdlib.binToHex(bin);
// };

"PresetsManager.jsx";
// EOF

//
// WatermarkUI
//
// $Id: XWatermark.jsx,v 1.74 2015/12/03 22:01:33 anonymous Exp $
// Copyright: ©2008, xbytor
// License: http://www.opensource.org/licenses/bsd-license.php
// Contact: xbytor@gmail.com
//
//@show include
//
app;
//
//
//include "xlib/stdlib.js"
//include "xlib/GenericUI.jsx"
//include "xlib/ColorChooser.jsx"
//include "xlib/ColorSelectorPanel.jsx"
//include "xlib/PresetsManager.jsx"
//include "xlib/ShapesFile.js"
//include "xlib/PreviewWindow.jsx"
//include "xlib/Styles.js"

WatermarkUIOptions = function(obj) {
  var self = this;

  // Shape settings
  self.shapeName = "Watermark Shape";
  self.shapeSize = "10 %";    // percent of largest document dimension

  // Image settings
  self.imagePath = "~/Desktop/Watermark.jpg";
  self.imageSize = "10 %";    // percent of largest document dimension

  // Text settings
  self.watermarkText = 'xbytor';

  self.font = "Arial";
  self.fontSize = 42;

  self.color = "Black";

  self.layerStyle = null;
  self.layerName  = "Watermark Layer";

  self.valign  = 'Middle';   // Top,Middle,Bottom
  self.halign  = 'Center';   // Left,Center,Right

  self.vspace  = "50 px";    // offset from the verical side
  self.hspace  = "50 px";    // offset from the horizontal side

  self.watermarkType = "text";   // text or shape

  // Copyright settings
  self.copyrightNoticeEnabled = false;
  self.copyrightNotice = '';
  self.copyrightUrlEnabled = false;
  self.copyrightUrl = '';
  self.copyrightedEnabled = false;
  self.copyrighted = "unmarked";

  Stdlib.copyFromTo(obj, self);
};
WatermarkUIOptions.prototype.typename = "WatermarkUIOptions";

WatermarkUIOptions.INI_FILE = Stdlib.PREFERENCES_FOLDER + "/watermark.ini";
WatermarkUIOptions.LOG_FILE = Stdlib.PREFERENCES_FOLDER + "/watermark.log";
WatermarkUIOptions.PREVIEW_IMG = Stdlib.PREFERENCES_FOLDER + "/wm-preview.png";
WatermarkUIOptions.DEFAULT_PRESETS_FOLDER = Stdlib.PREFERENCES_FOLDER;
WatermarkUIOptions.DESCRIPTOR_KEY = sTID('WatermarkOptions');


WatermarkUIOptions.prototype.rationalize = function() {
  var self = this;

  if (!self.watermarkType && !self.watermarkText) {
    self.watermarkType = "shape";
  } else {
    self.watermarkType = (self.watermarkType.toLowerCase());
  }

  if (self.watermarkText) {
//     self.watermarkText = self.watermarkText.replace(/\\n/g, "\r");
  }

  if (self.copyrightNotice) {
    self.copyrightNotice = self.copyrightNotice.replace(/\\n/g, "\r");
  }

  var oprops = ["shapeSize","vspace","hspace","imageSize", "fontSize"];

  for (var i = 0; i < oprops.length; i++) {
    var idx = oprops[i];
    var un = UnitValue(self[idx]);

    if (un.type == '?') {
      var type = 'px';
      var defVal = 100;

      if (idx == 'fontSize') {
        type = 'pt';
        defVal = 42;
      }
      un = new UnitValue(0, type);

      var num = toNumber(self[idx]);
      un.value = isNaN(num) ? defVal : num;
    }

    self[idx] = un;
  }

  if (self.imagePath) {
    self.imagePath = Stdlib.convertFptr(self.imagePath);
  }

  if (self.font && self.font.constructor == String) {
    self.font = toFont(self.font);
  }

  if (self.color && self.color.constructor == String) {
    var c = Stdlib.colorFromString(self.color);

    if (c) {
      self.color = c;
    }
  }
//   self.fontSize = toNumber(self.fontSize);

  self.copyrightNoticeEnabled = toBoolean(self.copyrightNoticeEnabled);
  self.copyrightUrlEnabled = toBoolean(self.copyrightUrlEnabled);
  self.copyrightedEnabled = toBoolean(self.copyrightedEnabled);

  if (self.copyrighted && self.copyrighted.constructor == String) {
    var str = self.copyrighted.toLowerCase().replace(/\s/g, '');
    var s = '';

    if (str == "true" || str == "copyrighted") {
      s = CopyrightedType.COPYRIGHTEDWORK;
    } else if (str == "false" || str == "" ||
               str == "unmarked" || str == "unknown") {
      s = CopyrightedType.UNMARKED;
    } else if (str == "publicdomain") {
      s = CopyrightedType.PUBLICDOMAIN;
    }

    self.copyrighted = s;
  }
};

WatermarkUIOptions.prototype.toIni = function() {
  var self = this;
  var obj = {};

  Stdlib.copyFromTo(self, obj);

  var oprops = ["shapeSize","fontSize","vspace","hspace","imageSize"];
  for (var i = 0; i < oprops.length; i++) {
    var idx = oprops[i];
    obj[idx] = obj[idx].toString();
  }

  var color = obj.color;
  if (color instanceof SolidColor) {
    obj.color = Stdlib.rgbToString(color);

  } else if (color.constructor == String) {
    var str = color;
    var c = undefined;
    if (str == "Black") {
      c = Stdlib.COLOR_BLACK;
    } else if (str == "White") {
      c = Stdlib.COLOR_WHITE;
    } else if (str == "Foreground") {
      c = app.foregroundColor;
    } else if (str == "Background") {
      c = app.backgroundColor;
    }
    if (c) {
      obj.color = Stdlib.rgbToString(c);
    }
  }

  if (obj.imagePath && (obj.imagePath instanceof File)) {
    obj.imagePath = obj.imagePath.toUIString();
  }

  return obj;
};

WatermarkUIOptions.toDescriptor = function(opts) {
  if (!(opts instanceof WatermarkUIOptions)) {
    opts = new WatermarkUIOptions(opts);
    opts.rationalize();
  }
  if (opts.color.constructor != String) {
    opts.color = Stdlib.rgbToString(opts.color);
  }

  var desc = new ActionDescriptor();
  var str = Stdlib.toIniString(opts);
  desc.putString(WatermarkUIOptions.DESCRIPTOR_KEY, str);

  return desc;
};

WatermarkUIOptions.prototype.toDescriptor = function() {
  return WatermarkUIOptions.toDescriptor(this);
};

WatermarkUIOptions.fromDescriptor = function(desc, opts) {
  if (desc.hasKey(WatermarkUIOptions.DESCRIPTOR_KEY)) {
    var str = desc.getString(WatermarkUIOptions.DESCRIPTOR_KEY);
    opts = Stdlib.fromIniString(str, opts);
  }
  return opts;
};
WatermarkUIOptions.prototype.fromDescriptor = function(desc) {
  return WatermarkUIOptions.fromDescriptor(desc, this);
};

WatermarkUI = function() {
  var self = this;

  self.title = "XWatermark"; // our window title
  self.notesSize = 0;          // no notes
  self.winRect = {             // the size of our window
    x: 100,
    y: 100,
    w: 525,
    h: 720
  };
  self.documentation = undefined; // no notes/docs

  self.iniFile = WatermarkUIOptions.INI_FILE;
  self.saveIni = true;
  self.optionsClass = WatermarkUIOptions;

  self.processTxt = "OK";
  self.setDefault = false;

  self.previewFile = undefined;
  self.presetsFolder = undefined;
  self.styles = {};   // name->ActionDescriptor for dynamically loaded styles
  self.shapes = {};   // name->Shape Info for dynamically loaded shapes
};
WatermarkUI.prototype = new GenericUI();
WatermarkUI.TEMP_STYLE_NAME = "[Temp Style]";

WatermarkUI.prototype.createPanel = function(pnl, ini) {
  var self = this;
  var xOfs = 10;
  var yy = 10;
  var xx = xOfs;
  var gutter = 130;
  var tOfs = (isCS2() ? 0 : 3);
  var txtWidth = 300;

  pnl.mgr = self;

  var opts = new WatermarkUIOptions(ini);   // default values

  opts.rationalize();

  if (ini.uiX == undefined) {
    ini.uiX = ini.uiY = 100;
  }

  if (isWindows() && $.screens[0].bottom <= 768) {
    ini.uiX = 0;
    ini.uiY = 100;
  }

  //
  // Watermark Type Selectors
  //

  // restore the window's location
  self.moveWindow(toNumber(opts.uiX), toNumber(opts.uiY));

  pnl.shapeCheck = pnl.add("radiobutton",
                           [xx,yy+tOfs,xx+gutter-30,yy+22+tOfs],
                           "Shape:");

  pnl.imageCheck = pnl.add("radiobutton",
                          [xx,yy+tOfs+35*2,xx+gutter-30,yy+22+tOfs+35*2],
                          "Image:");

  pnl.textCheck = pnl.add("radiobutton",
                          [xx,yy+tOfs+35*4,xx+gutter-30,yy+22+tOfs+35*4],
                          "Text:");

  xOfs = 30;
  gutter -= 20;

  xx = xOfs + gutter;

  //
  // Shape Name
  //
  pnl.shapeName = pnl.add("dropdownlist", [xx,yy,xx+160,yy+22]);
  var pm = new PresetsManager();
  pm.populateDropdownList(PresetType.CUSTOM_SHAPES, pnl.shapeName, true);
  var it = pnl.shapeName.find(opts.shapeName);
  if (it) {
    it.selected = true;
  } else {
    pnl.shapeName.items[0].selected = true;
  }

  pnl.shapeName.add('separator');
  pnl.shapeName.add('item', 'Load Shape...');

  pnl.shapeName.onChange = function() {
    var pnl = this.parent;

    if (pnl.shapeName.selection.text != 'Load Shape...') {
      return;
    }

    try {
      var mgr = pnl.mgr;
      var shapeInfo = mgr.loadShape(pnl);

      if (shapeInfo) {
        var it = pnl.shapeName.add('item', shapeInfo.name);
        pnl.shapeName.selection = it;

        mgr.shapes[shapeInfo.name] = shapeInfo;
      }

    } catch (e) {
      var msg = (e + '@' + (e.line || '??'));
      alert(msg);
    }
  }

  //
  // Preview button
  //
  var pfile = new File(WatermarkUIOptions.PREVIEW_IMG);
  if (pfile.exists) {
    self.previewFile = pfile;
  }
  if (app.documents.length || pfile.exists) {
    xx += 260;
    pnl.preview = pnl.add("button", [xx,yy,xx+80,yy+22], 'Preview...');
    pnl.preview.onClick = function() {
      var win = this.window;
      var mgr = win.mgr;
      mgr.preview();
    }
  }

  pnl.shapeCheck.onClick = pnl.textCheck.onClick = pnl.imageCheck.onClick =
  function() {
    var pnl = this.parent;
    var isShape = pnl.shapeCheck.value;
    var isImage = pnl.imageCheck.value;
    var isText = pnl.textCheck.value;

    var flds = ["shapeName", "sizeLabel", "shapeSize"];
    for (var i = 0; i < flds.length; i++) {
      pnl[flds[i]].enabled = isShape;
    }

    var flds = ["imagePath", "imageBrowse", "imageSizeLabel", "imageSize"];
    for (var i = 0; i < flds.length; i++) {
      pnl[flds[i]].enabled = isImage;
    }

    var flds = ["watermarkText", "fontLabel", "font"];

    for (var i = 0; i < flds.length; i++) {
      pnl[flds[i]].enabled = isText;
    }
  }

  yy += 38;

  xx = xOfs;

  //
  // Shape Size
  //
  pnl.sizeLabel = pnl.add('statictext', [xx,yy+tOfs,xx+gutter,yy+22+tOfs],
                          'Size:');
  xx += gutter;
  pnl.shapeSize = pnl.add('edittext', [xx,yy,xx+75,yy+20],
                          (opts.shapeSize || "5 %"));
  pnl.shapeSize.onChanging = GenericUI.unitValueKeystrokeFilter;

  yy += 35;
  xx = xOfs + gutter;

  //
  // Image Path
  //
  var textType = (isMac() ? 'statictext' : 'edittext');
  pnl.imagePath = pnl.add(textType, [xx,yy,xx+txtWidth,yy+23],
                          '', { readonly : true});

  if (opts.imagePath) {
    pnl.imagePath.text = Stdlib.convertFptr(opts.imagePath).toUIString();
  }

  xx += txtWidth + 5;
  var bnds = [xx,yy+1,xx,yy+20+1];

  pnl.imageBrowse = pnl.add('button', [xx,yy+1,xx+10,yy+20], '...');
  pnl.imageBrowse.bounds.width = 30;

  pnl.imageBrowse.onClick = function() {
    try {
      var pnl = this.parent;
      pnl.imageBrowse.bounds.width = 30;

      var def = (pnl.imagePath.text ?
                 new File(pnl.imagePath.text) : Folder.current);
      var f = Stdlib.selectFileOpen('Browse for Watermark Image',
                                    undefined, def);
      if (f) {
        pnl.imagePath.text = decodeURI(f.fsName);
      }
    } catch (e) {
      var msg = (e + '@' + (e.line || '??'));
      alert(msg);
    }
  }
  yy += 35;
  xx = xOfs;

  //
  // Image Size
  //
  pnl.imageSizeLabel = pnl.add('statictext', [xx,yy+tOfs,xx+gutter,yy+22+tOfs],
                               'Size:');
  xx += gutter;
  pnl.imageSize = pnl.add('edittext', [xx,yy,xx+75,yy+20],
                              (opts.imageSize || "5 %"));
  pnl.imageSize.onChanging = GenericUI.unitValueKeystrokeFilter;

  yy += 35;
  xx = xOfs + gutter;

  //
  // Watermark Text
  //
  var text = opts.watermarkText || '';
  //   text = text.replace(/\\n/g, "\r");

  pnl.watermarkText = pnl.add('edittext', [xx,yy,xx+txtWidth,yy+20], text);

  yy += 35;
  xx = xOfs;

  //
  // Font
  //
  pnl.fontLabel = pnl.add('statictext',
                          [xx,yy+tOfs,xx+gutter,yy+22+tOfs],
                          'Font:');

  xx += gutter;
  pnl.font = pnl.add('group', [xx,yy,xx+440,yy+30]);
  self.createFontPanel(pnl.font, opts, '');

  pnl.font.sizeLabel.visible = false;
  pnl.font.fontSize.bounds.width += 20;
  pnl.font.fontSize.onChanging = GenericUI.unitValueKeystrokeFilter;

  pnl.font.setFont(opts.font, opts.fontSize);

  pnl.font.getFont = function() {
    var pnl = this;
    var font = pnl.style.selection.font;
    return { font: font.postScriptName, size: pnl.fontSize.text };
  }

  xx = xOfs;

  yy += 45;

  var xOfs = 10;
  var xx = xOfs;
  var gutter = 130;

  //
  // LayerName
  //
  pnl.add('statictext', [xx,yy+tOfs,xx+gutter,yy+22+tOfs], 'Layer Name:');
  xx += gutter;
  pnl.layerName = pnl.add('edittext', [xx,yy,xx+140,yy+20],
                          opts.layerName || '');

  yy += 40;
  xx = xOfs;

  //
  // Color
  //
  pnl.colorLabel = pnl.add('statictext',
                               [xx,yy+tOfs,xx+gutter,yy+22+tOfs],
                               'Watermark Color:');
  xx += gutter;
  pnl.color = pnl.add('group', [xx,yy,xx+300,yy+40]);
  ColorSelectorPanel.createPanel(pnl.color, opts.color, '');

  yy += 40;
  xx = xOfs;

  //
  // Layer Style
  //
  pnl.layerStyleLabel = pnl.add("statictext",
                                [xx,yy+tOfs,xx+gutter,yy+22+tOfs],
                                "Layer Style:");
  xx += gutter;

  pnl.layerStyle = pnl.add("dropdownlist", [xx,yy,xx+200,yy+22]);
  var pm = new PresetsManager();
  pm.populateDropdownList(PresetType.STYLES, pnl.layerStyle, true);

  var it = pnl.layerStyle.find(opts.layerStyle);
  if (it) {
    it.selected = true;
  } else {
    pnl.layerStyle.items[0].selected = true;
  }

  pnl.layerStyle.add('separator');
  pnl.layerStyle.add('item', 'Load Style...');
  pnl.layerStyle.add('item', 'Define Style...');

  pnl.layerStyle.onChange = function() {
    var pnl = this.parent;

    if (pnl.layerStyle.selection.text == 'Load Style...') {
      try {
        var mgr = pnl.mgr;
        var sdesc = mgr.loadStyle(pnl);

        if (sdesc) {
          var fileInfo = sdesc.getObjectValue(cTID('FlIn'));
          var name = fileInfo.getString(cTID('Nm  '));
          var it = pnl.layerStyle.add('item', name);
          pnl.layerStyle.selection = it;
          mgr.styles[name] = sdesc;
        }

      } catch (e) {
        var msg = (e + '@' + (e.line || '??'));
        alert(msg);
      }
    }

    if (pnl.layerStyle.selection.text == 'Define Style...') {
      try {
        var mgr = pnl.mgr;
        if (!isCS4()) { // PSBUG
          self.window.visible = false;
        }
        var sdesc = mgr.defineStyle(pnl);

        if (sdesc) {
          var lefx = sdesc.getObjectValue(cTID('T   '));
          var name = WatermarkUI.TEMP_STYLE_NAME;
          var it = pnl.layerStyle.find(name);
          if (!it) {
            it = pnl.layerStyle.add('item', name);
          }

          pnl.layerStyle.selection = it;
          mgr.styles[name] = lefx;
        }

      } catch (e) {
        var msg = (e + '@' + (e.line || '??'));
        alert(msg);

      } finally {
        if (!isCS4()) { // PSBUG
          self.window.visible = true;
        }
      }
    }
  }

  yy += 35;
  xx = xOfs;

  //
  // Vertical Alignment
  //
  pnl.add('statictext', [xx,yy+tOfs,xx+gutter,yy+22+tOfs], 'Alignment:');
  xx += gutter;
  pnl.valign = pnl.add('dropdownlist', [xx,yy,xx+140,yy+20],
                       ['Top','Middle', 'Bottom']);

  var idx = 1;
  if (opts.valign == 'Top')    idx = 0;
  if (opts.valign == 'Middle') idx = 1;
  if (opts.valign == 'Bottom') idx = 2;
  pnl.valign.items[idx].selected = true;

  pnl.valign.onChange = function() {
    var pnl = this.parent;
    pnl.vspace.enabled = (pnl.valign.selection.text != 'Middle');
  }

  xx += 145;

  //
  // Horizontal Alignment
  //
  pnl.halign = pnl.add('dropdownlist', [xx,yy,xx+138,yy+20],
                       ['Left','Center', 'Right']);

  var idx = 1;
  if (opts.halign == 'Left')   idx = 0;
  if (opts.halign == 'Center') idx = 1;
  if (opts.halign == 'Right')  idx = 2;
  pnl.halign.items[idx].selected = true;

  pnl.halign.onChange = function() {
    var pnl = this.parent;
    pnl.hspace.enabled = (pnl.halign.selection.text != 'Center');
  }

  yy += 35;
  xx = xOfs;

  //
  // Vertical Space
  //
  pnl.add('statictext', [xx,yy+tOfs,xx+gutter,yy+22+tOfs], 'Vertical Offset:');
  xx += gutter;
  pnl.vspace = pnl.add('edittext', [xx,yy,xx+75,yy+20],
                       opts.vspace || "50 px");
  pnl.vspace.onChanging = GenericUI.unitValueKeystrokeFilter;


  yy += 35;
  xx = xOfs;

  //
  // Horizontal Space
  //
  pnl.add('statictext', [xx,yy+tOfs,xx+gutter,yy+22+tOfs],
          'Horizontal Offset:');
  xx += gutter;
  pnl.hspace = pnl.add('edittext', [xx,yy,xx+75,yy+20],
                       opts.hspace || "50 px");
  pnl.hspace.onChanging = GenericUI.unitValueKeystrokeFilter;

  yy += 35;
  xx = xOfs;

  pnl.valign.onChange();
  pnl.halign.onChange();

  //
  // Copyrighted
  //
  var en = 17;
  pnl.copyrightedEnabled = pnl.add('checkbox',
                                   [xx,yy,xx+en,yy+22]);
  pnl.copyrightedEnabled.value = opts.copyrightedEnabled;
  pnl.copyrightedEnabled.onClick = function() {
    var pnl = this.parent;
    var st = pnl.copyrightedEnabled.value;;
    pnl.copyrighted.enabled = st;
  };

  xx += en;

  pnl.copyrightedLabel = pnl.add('statictext',
                                 [xx,yy+tOfs,xx+gutter-en,yy+22+tOfs],
                                 'Copyright Status:');

  xx += gutter - en;

  var lst = ["Unknown", "Copyrighted", "Public Domain"];
  pnl.copyrighted = pnl.add("dropdownlist", [xx,yy,xx+160,yy+22], lst);
  var it = pnl.copyrighted.find(opts.copyrighted);
  if (it) {
    it.selected = true;
  } else {
    pnl.copyrighted.items[0].selected = true;
  }

  pnl.copyrightedEnabled.onClick();

  yy += 35;
  xx = xOfs;

  //
  // Copyright Notice
  //
  pnl.copyrightNoticeEnabled = pnl.add('checkbox',
                                   [xx,yy,xx+en,yy+22]);
  pnl.copyrightNoticeEnabled.value = opts.copyrightNoticeEnabled;
  pnl.copyrightNoticeEnabled.onClick = function() {
    var pnl = this.parent;
    var st = pnl.copyrightNoticeEnabled.value;;
    pnl.copyrightNotice.enabled = st;
  };

  xx += en;

  var notice = opts.copyrightNotice || '';
  notice = notice.replace(/\\n/g, "\r");
  pnl.copyrightNoticeLabel = pnl.add('statictext',
                                     [xx,yy+tOfs,xx+gutter-en,yy+22+tOfs],
                                     'Copyright Notice:');
  xx += gutter-en;
  pnl.copyrightNotice = pnl.add('edittext', [xx,yy,xx+txtWidth,yy+90],
                                notice, {multiline:true});
  yy += 90;
  pnl.formatNote = pnl.add('statictext',
                           [xx,yy+tOfs,xx+txtWidth,yy+22+tOfs],
                           '[Ctrl-Enter(XP)/Ctrl-m(OSX) to add a line]');

  pnl.copyrightNoticeEnabled.onClick();

  yy += 30;
  xx = xOfs;

  //
  // Copyright Url
  //
  pnl.copyrightUrlEnabled = pnl.add('checkbox',
                                   [xx,yy,xx+en,yy+22]);
  pnl.copyrightUrlEnabled.value = opts.copyrightUrlEnabled;
  pnl.copyrightUrlEnabled.onClick = function() {
    var pnl = this.parent;
    var st = pnl.copyrightUrlEnabled.value;
    pnl.copyrightUrl.enabled = st;
  };

  xx += en;

  pnl.copyrightUrlLabel = pnl.add('statictext',
                                     [xx,yy+tOfs,xx+gutter-en,yy+22+tOfs],
                                     'Copyright URL:');
  xx += gutter - en;
  pnl.copyrightUrl = pnl.add('edittext', [xx,yy,xx+txtWidth,yy+20],
                             opts.copyrightUrl || '');

  pnl.copyrightUrlEnabled.onClick();

  yy += 45;
  xx = xOfs;

  if (opts.watermarkType == "shape") {
    pnl.shapeCheck.value = true;
    pnl.shapeCheck.onClick();

  } else if (opts.watermarkType == "image") {
    pnl.imageCheck.value = true;
    pnl.imageCheck.onClick();

  } else {
    pnl.textCheck.value = true;
    pnl.textCheck.onClick();
  }
};

WatermarkUI.prototype.validatePanel = function(pnl, ini) {
  var self = this;
  var opts = new WatermarkUIOptions(ini);

  function _getUN(str, defType) {
    var un = UnitValue(str);
    if (un.type == '?') {
      un = UnitValue(str + " " + (defType || 'px'));
      if (un.type == '?') {
        un = undefined;
      }
    }
    return un;
  }

  if (pnl.shapeCheck.value) {
    opts.watermarkType = "shape";
    opts.shapeName = pnl.shapeName.selection.text;

    var un = _getUN(pnl.shapeSize.text);
    if (!un) {
      return self.errorPrompt("Bad value for Shape Size");
    }

    opts.shapeSize = un;
  }

  if (pnl.imageCheck.value) {
    opts.watermarkType = "image";
    var f;
    if (pnl.imagePath.text) {
      f = new File(pnl.imagePath.text);
    }
    if (!f || !f.exists) {
      return self.errorPrompt("Watermark Image not found.");
    }
    opts.imagePath = f.toUIString();

    var un = _getUN(pnl.imageSize.text);
    if (!un) {
      return self.errorPrompt("Bad value for Image Size");
    }

    opts.imageSize = un;
  }

  if (pnl.textCheck.value) {
    opts.watermarkType = "text";
    opts.watermarkText = pnl.watermarkText.text;
//     opts.watermarkText = pnl.watermarkText.text.replace(/[\r\n]+/g, '\\n');

    var f = pnl.font.getFont();
    if (!f.font) {
      Error.runtimeError(9001, "Very bad font: " + listProps(f));
    }
    opts.font     = f.font;
    opts.fontSize = _getUN(f.size, 'pt');
  }

  opts.color = Stdlib.rgbToString(pnl.color.getColor());

  opts.layerName = pnl.layerName.text;
  opts.layerStyle = (pnl.layerStyle.selection ?
                     pnl.layerStyle.selection.text : "");

  opts.valign = pnl.valign.selection.text;
  opts.halign = pnl.halign.selection.text;

  var un = _getUN(pnl.vspace.text);
  if (!un) {
    return self.errorPrompt("Bad value for Vertical Offset");
  }
  opts.vspace = un;

  var un = _getUN(pnl.hspace.text);
  if (!un) {
    return self.errorPrompt("Bad value for Horizontal Offset");
  }
  opts.hspace = un;

  opts.copyrightedEnabled = pnl.copyrightedEnabled.value;
  if (opts.copyrightedEnabled) {
    opts.copyrighted = pnl.copyrighted.selection.text;
  }

  opts.copyrightNoticeEnabled = pnl.copyrightNoticeEnabled.value;
  if (opts.copyrightNoticeEnabled) {
    opts.copyrightNotice = pnl.copyrightNotice.text.replace(/[\r\n]+/g, '\\n');
  }

  opts.copyrightUrlEnabled = pnl.copyrightUrlEnabled.value;
  if (opts.copyrightUrlEnabled) {
    opts.copyrightUrl = pnl.copyrightUrl.text;
  }

  return opts;
};

WatermarkUI.prototype.process = function(ini, doc) {
  var self = this;

  var opts = new WatermarkUIOptions(ini);
  opts.rationalize();

  return opts;
};

WatermarkUI.prototype.applyWatermark = function(opts, doc) {
  var self = this;
  var ru = app.preferences.rulerUnits;

  try {
    app.preferences.rulerUnits = Units.PIXELS;

    var modified = true;

    if (opts.watermarkType == 'shape') {
      if (opts.shapeName && opts.shapeName != "None") {
        // place the shape
        self.placeShape(opts, doc);

        var layer = doc.activeLayer;
        Stdlib.setFillLayerColor(doc, layer, opts.color);

        Stdlib.deselectActivePath(doc);

      } else {
        modified = false;
      }

      if (modified) {
        if (opts.layerName) {
          layer.name = opts.layerName;
        } else {
          layer.name = 'Watermark Layer';
        }

        if (opts.layerStyle && opts.layerStyle != 'None') {
          self.applyStyle(opts, doc, layer, opts.layerStyle);
        }
      }

    } else if (opts.watermarkType == 'image') {
      var bnds = self.computeImageBounds(opts, doc);
      var file = Stdlib.convertFptr(opts.imagePath);

      var layer = doc.artLayers.add();

      Stdlib.selectBounds(doc, bnds);
      Stdlib.insertImageIntoSelection(doc, layer, file, true);
      layer = doc.activeLayer;

      // re-align the image _before_ applying the layer style
      var dx = 0;
      var dy = 0;
      var lbnds = Stdlib.getLayerBounds(doc, layer);
      if (opts.halign == 'Left' && bnds[0] != lbnds[0]) {
        dx = bnds[0] - lbnds[0];
      }
      if (opts.halign == 'Right' && bnds[2] != lbnds[2]) {
        dx = bnds[2] - lbnds[2];
      }

      if (opts.valign == 'Top' && bnds[1] != lbnds[1]) {
        dy = bnds[0] - lbnds[0];
      }
      if (opts.valign == 'Bottom' && bnds[3] != lbnds[3]) {
        dy = bnds[3] - lbnds[3];
      }

      if (dx || dy) {
        layer.translate(dx, dy);
        // var lbnds = Stdlib.getLayerBounds(doc, layer);
        // alert("bnds = " + bnds + "\rlbnds = " + lbnds);
      }

      if (opts.layerName) {
        layer.name = opts.layerName;
      } else {
        layer.name = 'Watermark Shape Layer';
      }

      if (opts.layerStyle && opts.layerStyle != 'None') {
        self.applyStyle(opts, doc, layer, opts.layerStyle);
      }

    } else if (opts.watermarkType == 'text') {

      if (opts.copyrightNotice || opts.watermarkText) {

        var text = opts.copyrightNotice;
        if (opts.watermarkText) {
          text = opts.watermarkText.replace(/\\n/g, '\r');
          var md = new Metadata(doc);
          if (text.contains('%')) {
            text = md.strf(text);
          }
        }

        self.addWatermarkText(opts, doc, text);

      } else {
        modified = false;
      }

      if (modified) {
        var layer = doc.activeLayer;
        // set the style
        if (opts.layerStyle && opts.layerStyle != 'None') {
          self.applyStyle(opts, doc, layer, opts.layerStyle);
        }

        // set the layer name
        if (opts.layerName) {
          layer.name = opts.layerName;
        } else {
          layer.name = 'Watermark Text Layer';
        }
      }

      // set any copyright info requested
      if (opts.copyrightedEnabled && opts.copyrighted) {
        doc.info.copyrighted = opts.copyrighted;
      }

      if (opts.copyrightNoticeEnabled && opts.copyrightNotice) {
        doc.info.copyrightNotice = opts.copyrightNotice;
      }

      if (opts.copyrightUrlEnabled && opts.copyrightUrl) {
        doc.info.ownerUrl = opts.copyrightUrl;
      }
    }

  } catch (e) {
    Stdlib.logException(e, true);

  } finally {
    app.preferences.rulerUnits = ru;
  }

  return;
};

WatermarkUI.prototype.applyStyle = function(opts, doc, layer, styleName) {
  var self = this;
  try {
    var pm = new PresetsManager();
    var sdesc = self.styles[styleName];

    if (!sdesc) {
      layer.applyStyle(styleName);
    } else {
      Styles.setLayerStyleDescriptor(doc, layer, sdesc);
    }

  } catch (e) {
    var msg = ("Failed to apply style '" + styleName + "': " +
               (e + '@' + (e.line || '??')));
    Stdlib.log(msg);
    alert(msg);
  }
};

WatermarkUI.prototype.computeOffsets = function(opts, doc) {
  var self = this;
  var height = doc.height.as("px");
  var width = doc.width.as("px");
  var rez = doc.resolution;

  var h = Stdlib.getPixelValue(rez, opts.hspace.toString(), width, "px");
  var v = Stdlib.getPixelValue(rez, opts.vspace.toString(), height, "px");

  if (opts.hspace.type == '%' && (opts.hspace == opts.vspace)) {
    v = h = Math.min(v, h);
  }

  return [h, v];
};


//
// returns the bounds of the watermark to be placed...
// top, left, bottom, right
//
WatermarkUI.prototype.computeShapeBounds = function(opts, doc, shapeName) {
  var self = this;

  var shapeInfo = CustomShapeInfo.getShapeInfo(shapeName);

  var dheight = doc.height.as("px");
  var dwidth = doc.width.as("px");

  var ratio = shapeInfo.h/shapeInfo.w;
  var dratio = dheight/dwidth;

  var rez = doc.resolution;

  var width;
  var height;

  // calc the size in pixels based on the largest dimension
  var size;
  if (dheight > dwidth) {
    height = Stdlib.getPixelValue(rez, opts.shapeSize.toString(),
                                  dheight, "px");
    width = height/ratio;

  } else {
    width = Stdlib.getPixelValue(rez, opts.shapeSize.toString(), dwidth, "px");
    height = width/ratio;
  }

  var pos = self.computeOffsets(opts, doc);
  var hspace = pos[0];
  var vspace = pos[1];

  var x;
  if (opts.halign == 'Left') {
    x = hspace;
    rx = x + width;
  } else if (opts.halign == 'Right') {
    var rx = dwidth - hspace;
    x = rx - width;
  } else {
    x = (dwidth/2 - width/2);
  }

  var y;
  if (opts.valign == 'Top') {
    y = vspace;
  } else if (opts.valign == 'Bottom') {
    var ry = dheight - vspace;
    y = ry - height;
  } else {
    y = (dheight/2 - height/2);
  }

  // The set up is all done.
  var b = new Object();
  b.top = Math.floor(y);
  b.left = Math.floor(x);
  b.bottom = b.top + Math.floor(height); // Math.floor(ry);
  b.right = b.left + Math.floor(width); // Math.floor(rx);

  return b;
};

WatermarkUI.prototype.placeShape = function(opts, doc) {
  var self = this;
  var bounds;
  var shape;

  function _placeShape() {
    // This is the lovely ScriptListener output for dropping a shape
    // into a document with position, size, and style information
    var desc = new ActionDescriptor();
    var ref = new ActionReference();
    ref.putClass(sTID('contentLayer'));
    desc.putReference(cTID('null'), ref);
    var tdesc = new ActionDescriptor();
    tdesc.putClass(cTID('Type'), sTID('solidColorLayer'));
    var sdesc = new ActionDescriptor();
    sdesc.putString(cTID('Nm  '), shape);
    sdesc.putUnitDouble(cTID('Top '), cTID('#Pxl'), bounds.top);
    sdesc.putUnitDouble(cTID('Left'), cTID('#Pxl'), bounds.left);
    sdesc.putUnitDouble(cTID('Btom'), cTID('#Pxl'), bounds.bottom);
    sdesc.putUnitDouble(cTID('Rght'), cTID('#Pxl'), bounds.right);
    tdesc.putObject(cTID('Shp '), sTID('customShape'), sdesc);
    desc.putObject(cTID('Usng'), sTID('contentLayer'), tdesc);
    executeAction(cTID('Mk  '), desc, DialogModes.NO);
  }

  var shapeInfo = self.shapes[opts.shapeName];

  if (shapeInfo) {
    // if we are loading a shape off the disk, append it to the current
    // palette set, rename it (in case of dupes), place it, then delete it

    var pm = new PresetsManager();
    var names = pm.getNames(PresetType.CUSTOM_SHAPES);
    var length = names.length;
    pm.appendPresets(PresetType.CUSTOM_SHAPES, shapeInfo.file);

    shape = "_WM_" + (new Date().getTime());
    pm.renameByIndex(PresetType.CUSTOM_SHAPES, length+1, shape);

    // compute the bounding box for the watermark shape
    bounds = self.computeShapeBounds(opts, doc, shape);
    Stdlib.wrapLC(doc, _placeShape);

    pm.deleteElementAt(PresetType.CUSTOM_SHAPES, length+1);

  } else {
    shape = opts.shapeName;
    bounds = self.computeShapeBounds(opts, doc, shape);
    Stdlib.wrapLC(doc, _placeShape);
  }
};

//
// returns the bounds of the watermark to be placed...
// top, left, bottom, right
//
WatermarkUI.prototype.computeImageBounds = function(opts, doc) {
  var self = this;

  var dheight = doc.height.as("px");
  var dwidth = doc.width.as("px");

  var rez = doc.resolution;

  var dim = Math.max(doc.height.as("px"), dwidth);
  var size = Stdlib.getPixelValue(rez, opts.imageSize.toString(), dim, "px");

  var width = height = size;

  var pos = self.computeOffsets(opts, doc);
  var hspace = pos[0];
  var vspace = pos[1];

  var x;
  if (opts.halign == 'Left') {
    x = hspace;
    rx = x + width;
  } else if (opts.halign == 'Right') {
    var rx = dwidth - hspace;
    x = rx - width;
  } else {
    x = (dwidth/2 - width/2);
  }

  var y;
  if (opts.valign == 'Top') {
    y = vspace;
  } else if (opts.valign == 'Bottom') {
    var ry = dheight - vspace;
    y = ry - height;
  } else {
    y = (dheight/2 - height/2);
  }

  // The set up is all done.
  var b = new Object();
  b.top = Math.floor(y);
  b.left = Math.floor(x);
  b.bottom = b.top + Math.floor(height); // Math.floor(ry);
  b.right = b.left + Math.floor(width); // Math.floor(rx);

  return [b.left, b.top, b.right, b.bottom];
};


WatermarkUI.prototype.addWatermarkText = function(opts, doc, str) {
  var self = this;

  var pos = self.computeOffsets(opts, doc);
  var x = pos[0];
  var y = pos[1];

  var height = doc.height.as("px");
  var width = doc.width.as("px");
  var rez = doc.resolution;

  var layer = doc.artLayers.add();

  layer.kind = LayerKind.TEXT;
  layer.blendMode = BlendMode.NORMAL;
  layer.opacity = 100.0;

  var text = layer.textItem;
  var ru = app.preferences.rulerUnits;
  var tu = app.preferences.typeUnits;

  try {
    app.preferences.typeUnits = TypeUnits.POINTS;
    app.preferences.rulerUnits = Units.PIXELS;

    var fontSize;
    if (opts.fontSize.type == 'pt' || opts.fontSize.type == '?') {
      fontSize = opts.fontSize;

    } else {
      // convert the fontSize to pixels first
      fontSize = Stdlib.getPixelValue(rez, opts.fontSize.toString(),
                                      height, "pt");
      // then to points
      fontSize *= (72/rez);
    }

    text.contents = str;

    text.size = fontSize;
    if (text.size != fontSize) {
      PSCCFontSizeFix.setFontSizePoints(layer, fontSize);
    }
    text.font = opts.font || "ArialMT";
    text.color = opts.color;

    text.kind = (str.match(/\r|\n/) ?
                 TextType.PARAGRAPHTEXT : TextType.POINTTEXT);

    var bnds = layer.bounds;
    var twidth = (bnds[2].as("px") - bnds[0].as("px"));
    var theight = (bnds[3].as("px") - bnds[1].as("px"));

    if (opts.halign == 'Right') {
      x = width - x - twidth;

    } else if (opts.halign == 'Center') {
      x = Math.floor(width/2 - twidth/2);
    }

    if (opts.valign == 'Top') {
      y += theight;

    } else if (opts.valign == 'Bottom') {
      y = height - y;

    } else {
      y = Math.floor(height/2 - theight/2) + theight;
    }

    text.position = new Array(x, y);

  } finally {
    app.preferences.rulerUnits = ru;
    app.preferences.typeUnits = tu;
  }

  return layer;
};

WatermarkUI.prototype.preview = function() {
  try {
    var self = this;
    var opts = self.validatePanel(self.win.appPanel, {});

    try {
      var doc;
      if (app.documents.length > 0) {
        doc = app.activeDocument.duplicate();

      } else if (self.previewFile) {
        doc = app.open(self.previewFile);

      } else {
        if (confirm("No preview image was specified.\r\r" +
                    "Select a preview image?")) {

          var def = WatermarkUIOptions.PREVIEW_IMG;
          var f = Stdlib.selectFileOpen("Select a Preview image",
                                        undefined, def);
          if (f) {
            self.previewFile = f;
            doc = app.open(self.previewFile);
          }
        }
      }

    } catch (e) {
      Stdlib.logException(e, "Unable to open/find preview image.", true);
    }

    if (typeof(res) == 'boolean') {
      return;
    }

    var snapname = "PreviewSnapshot";
    opts.rationalize();
    try { Stdlib.deleteSnapshot(doc, snapname); } catch (e) {};
    Stdlib.takeSnapshot(doc, snapname);
    self.applyWatermark(opts, app.activeDocument);

    if (doc.width.as("px") > PreviewWindow.MAX_WIDTH ||
        doc.height.as("px") > PreviewWindow.MAX_HEIGHT) {
      Stdlib.fitImage(doc, PreviewWindow.MAX_WIDTH, PreviewWindow.MAX_HEIGHT);
    }
    var file = new File(Folder.temp + "/wm-preview.png");
    file.remove();
    doc.saveAs(file, new PNGSaveOptions(), true);

    var w = doc.width.as("px");
    var h = doc.height.as("px");

    Stdlib.revertToSnapshot(doc, snapname);
    Stdlib.deleteSnapshot(doc, snapname);

    doc.close(SaveOptions.DONOTSAVECHANGES);

    if (!isCS4()) { // PSBUG
      self.win.visible = false;
    }

    try {
      PreviewWindow.openFile(file, w, h, undefined, undefined, self.win);

    } finally {
      if (!isCS4()) { // PSBUG
        self.win.visible = true;
      }
    }

    file.remove();

    Stdlib.waitForRedraw();
    Stdlib.waitForRedraw();
    Stdlib.waitForRedraw();

  } catch (e) {
    var msg = (e + '@' + (e.line || '??'));
    alert(msg);
    debugger;
  }
};

WatermarkUI.prototype.loadStyle = function(pnl) {
  var self = this;
  var folder = (self.stylesFolder || WatermarkUIOptions.DEFAULT_PRESETS_FOLDER);
  var stylesFolder = Stdlib.convertFptr(folder);
  var sdesc = undefined;

  var fsel = Stdlib.createFileSelect("Styles Files: *.asl");
  var files = folder.getFiles("*.asl");
  var def = files[0] || stylesFolder;

  while (true) {
    var stylesFile = Stdlib.selectFileOpen("Select a Style",
                                           fsel, def);
    if (!stylesFile) {
      break;
    }

    try {
      sdesc = Styles.loadFileDescriptor(stylesFile);

    } catch (e) {
      var msg = (e + '@' + (e.line || '??'));
      alert(msg);
      continue;
    }

    if (sdesc) {
      break;
    }
  }

  return sdesc;
};

WatermarkUI.prototype.defineStyle = function(pnl) {
  var self = this;
  var color = pnl.color.getColor();
  var text = pnl.watermarkText.text || "Watermark Text";
  var f = pnl.font.getFont();

  var desc = Styles.defineStyle(text, f.font, color);

  return desc;
};

WatermarkUI.prototype.loadShape = function(pnl) {
  var self = this;
  var folder = (self.presetsFolder || WatermarkUIOptions.DEFAULT_PRESETS_FOLDER);
  var shapesFolder = Stdlib.convertFptr(folder);
  var shapeInfo = undefined;

  var fsel = Stdlib.createFileSelect("Custom Shape Files: *.csh");
  var files = folder.getFiles("*.csh");
  var def = files[0] || shapesFolder;

  while (true) {
    var file = Stdlib.selectFileOpen("Select a Custom Shape",
                                     fsel, def);
    if (!file) {
      break;
    }

    try {
      var shapesFile = new ShapesFile();
      var shapes = shapesFile.read(file);

      if (!shapes || shapes.length == 0) {
        Error.runtimeError(9001, "Failed to read shape from: " +
                           file.toUIString());
      }

      if (shapes.length > 1) {
        Error.runtimeError(9001, "Custom Shapes can only be loaded from .csh " +
                           "files with a single shape");
      }

      shapeInfo = shapes[0];
      shapeInfo.file = file;

    } catch (e) {
      var msg = (e + '@' + (e.line || '??'));
      alert(msg);
      continue;
    }

    if (shapeInfo) {
      break;
    }
  }

  return shapeInfo;
};

//
// scratch code. may use later
//
function _strokeStyle(doc, layer, size, opacity, color) {
  function _ftn() {
    var descSet = new ActionDescriptor();

    // descSet = Styles.getLayerStyleDescriptor(doc, layer);
    // var styleDesc = descSet.getObjectValue(cTID('T   ');
    // if (styleDesc.hasKey(cTID('FrFX')) { styleDesc.remove(cTID('FrFX'); }

    var refProp = new ActionReference();
    refProp.putProperty( cTID('Prpr'), cTID('Lefx') );
    refProp.putEnumerated( cTID('Lyr '), cTID('Ordn'), cTID('Trgt') );
    descSet.putReference( cTID('null'), refProp );

    var descStyle = new ActionDescriptor();
    descStyle.putUnitDouble( cTID('Scl '), cTID('#Prc'), 100.000000 );

    // Start Stroke style
    var descStrk = new ActionDescriptor();
    // Enabled
    descStrk.putBoolean( cTID('enab'), true );
    // Position
    descStrk.putEnumerated( cTID('Styl'), cTID('FStl'), cTID('OutF') );
    // Fill Type
    descStrk.putEnumerated( cTID('PntT'), cTID('FrFl'), cTID('SClr') );
    // Blend Mode
    descStrk.putEnumerated( cTID('Md  '), cTID('BlnM'), cTID('Nrml') );
    // Opacity
    descStrk.putUnitDouble( cTID('Opct'), cTID('#Prc'), opacity );
    // Size
    descStrk.putUnitDouble( cTID('Sz  '), cTID('#Pxl'), size );

    // Color
    var descClr = new ActionDescriptor();
    descClr.putDouble( cTID('Rd  '), color.rgb.red );
    descClr.putDouble( cTID('Grn '), color.rgb.green );
    descClr.putDouble( cTID('Bl  '), color.rgb.blue );

    descStrk.putObject( cTID('Clr '), cTID('RGBC'), descClr );
    // End Stroke style

    // Insert stroke style
    descStyle.putObject( cTID('FrFX'), cTID('FrFX'), descStrk );

    // Insert style descriptor
    descSet.putObject( cTID('T   '), cTID('Lefx'), descStyle );

    executeAction( cTID('setd'), descSet, DialogModes.NO );
  }

  _ftn();
};


WatermarkUI.main = function() {
  if (!app.documents.length) {
    alert("Please open a document before running this script.");
    return;
  }
  var doc = app.activeDocument;
  var ui  = new WatermarkUI();

  var ini = {
//     watermarkText: "Lisa"
  };

  var opts = ui.exec(ini, doc);

  if (!opts) {
    return;
  }

//   alert(listProps(opts)); return;

  ui.applyWatermark(opts, doc);

  // Text location tests
  if (false) {
    var ini = new WatermarkUIOptions();
    ini.valign = 'Top';
    ini.halign = 'Left';
    ini.fontSize = 12;
    ini.shapeName = '';
    ini.watermarkText = "Lisa";

    var opts = ui.process(ini, doc);
    if (!opts) {
      return;
    }
    ui.applyWatermark(opts, doc);

    opts.valign = 'Top';
    opts.halign = 'Center';
    ui.applyWatermark(opts, doc);

    opts.valign = 'Top';
    opts.halign = 'Right';
    ui.applyWatermark(opts, doc);

    opts.valign = 'Middle';
    opts.halign = 'Left';
    ui.applyWatermark(opts, doc);

    opts.valign = 'Middle';
    opts.halign = 'Center';
    ui.applyWatermark(opts, doc);

    opts.valign = 'Middle';
    opts.halign = 'Right';
    ui.applyWatermark(opts, doc);

    opts.valign = 'Bottom';
    opts.halign = 'Left';
    ui.applyWatermark(opts, doc);

    opts.valign = 'Bottom';
    opts.halign = 'Center';
    ui.applyWatermark(opts, doc);

    opts.valign = 'Bottom';
    opts.halign = 'Right';
    ui.applyWatermark(opts, doc);
  }

  // Shape location tests
  if (false) {
    var ini = new WatermarkUIOptions();
    ini.valign = 'Top';
    ini.halign = 'Left';

    var opts = ui.process(ini, doc);

    if (!opts) {
      return;
    }
    ui.applyWatermark(opts, doc);

    opts.valign = 'Top';
    opts.halign = 'Center';
    ui.applyWatermark(opts, doc);

    opts.valign = 'Top';
    opts.halign = 'Right';
    ui.applyWatermark(opts, doc);

    opts.valign = 'Middle';
    opts.halign = 'Left';
    ui.applyWatermark(opts, doc);

    opts.valign = 'Middle';
    opts.halign = 'Center';
    ui.applyWatermark(opts, doc);

    opts.valign = 'Middle';
    opts.halign = 'Right';
    ui.applyWatermark(opts, doc);

    opts.valign = 'Bottom';
    opts.halign = 'Left';
    ui.applyWatermark(opts, doc);

    opts.valign = 'Bottom';
    opts.halign = 'Center';
    ui.applyWatermark(opts, doc);

    opts.valign = 'Bottom';
    opts.halign = 'Right';
    ui.applyWatermark(opts, doc);
  }
  if (ui.saveIni) {
    ui.updateIniFile({ uiX: ui.winX, uiY: ui.winY });
  }
};

//WatermarkUI.main();  // for testing

"WatermarkUI.jsx";
// EOF

//
// Stream.js
// This file contains code necessary for reading and writing binary data with
// reasonably good performance. There is a lot that can be done to improve this
// but it works well enough for current purposes
//
// $Id: XWatermark.jsx,v 1.74 2015/12/03 22:01:33 anonymous Exp $
// Copyright: (c)2007, xbytor
// License: http://www.opensource.org/licenses/bsd-license.php
// Contact: xbytor@gmail.com
//
Stream = function(str) {
  var self = this;
  self.str = (str ? str : []); // the actual bytes as String or Array of char
  self.ptr = 0;                // the current index into the stream
  self.byteOrder = Stream.DEFAULT_BYTEORDER;   // or Stream.LITTLE_ENDIAN
  return self;
};
Stream.prototype.typename = "Stream";

Stream.BIG_ENDIAN = "BE";
Stream.LITTLE_ENDIAN = "LE";
Stream.DEFAULT_BYTEORDER = Stream.BIG_ENDIAN;

Stream.TWO_32= Math.pow(2, 32);
Stream.LARGE_LONG_MASK = 0x001FFFFFFFFFFFFF;  // Math.pow(2, 53) - 1;

Stream.RcsId = "$Revision: 1.74 $";

Stream.EOF = -1;

//
// some code for reading and writing files
//
Stream.writeToFile = function(fptr, str) {
  var file = Stream.convertFptr(fptr);
  file.open("w") || Error.runtimeError(9002, "Unable to open output file \"" +
                                      file + "\".\r" + file.error);
  file.encoding = 'BINARY';
  file.write(str);
  file.close();
};
Stream.readFromFile = function(fptr) {
  var file = Stream.convertFptr(fptr);
  file.open("r") || Error.runtimeError(9002, "Unable to open input file \"" +
                                      file + "\".\r" + file.error);
  file.encoding = 'BINARY';
  var str = '';
  str = file.read(file.length);
  file.close();
  return str;
};
Stream.readStream = function(fptr) {
  var str = new Stream();
  str.str = Stream.readFromFile(fptr);
  return str;
};
Stream.convertFptr = function(fptr) {
  var f;
  if (fptr.constructor == String) {
    f = File(fptr);
  } else if (fptr instanceof File || fptr instanceof Folder) {
    f = fptr;
  } else {
    throw "Bad file \"" + fptr + "\" specified.";
  }
  return f;
};

//
// Convert the Stream to a String. Probably not the best choice of names here
//
Stream.prototype.toStream = function() {
  var s;
  if (this.str.constructor == String) {
    s = this.str.slice(0); 
  } else {
    s = this.str.join("");
  }
  return s;
};

Stream.prototype.appendToFile = function(fptr) {
  var self = this;

  fptr.write.apply(fptr, self.str);

  return;

//   this is surprising slow for large values of len
//   var len = self.str.length;
//   for (var i = 0; i < len; i++) {
//     fptr.write(self.str[i]);
//   }
};


Stream.prototype.writeToFile = function(fptr) {
  var self = this;
  var file = Stream.convertFptr(fptr);
  file.open("w") || Error.runtimeError(9002, "Unable to open output file \"" +
                                      file + "\".\r" + file.error);
  file.encoding = 'BINARY';
  // var str = self.toStream();
  // file.write(str);

  self.appendToFile(fptr);

  file.close();
};

Stream.prototype.seek = function(ptr, mode) {
  var self = this;
  var index;

  if (mode == undefined) {
    mode = 0;
  }

  if (mode == 0) {
    index = ptr;
  } else if (mode == 1) {
    index = self.ptr + ptr;
  } else if (mode == 2) {
    index = self.str.length - ptr;
  } else {
    throw "Bad seek mode.";
  }

  if (index < 0 || index > this.str.length) {
    throw "Attempt to seek in Stream out of range.";
  }
  self.ptr = index;
};
Stream.prototype.tell = function() {
  return this.ptr;
};
Stream.prototype.eof = function() {
  return this.ptr == this.str.length;
};
Stream.prototype.length = function() {
  return this.str.length;
};

//
// Write parts into the Stream
//
Stream.prototype.writeByte = function(b) {
  var self = this;
  self.str[self.ptr++] = String.fromCharCode(b);
  return self;
};
Stream.prototype.writeChar = function(c) {
  var self = this;
  self.str[self.ptr++] = c.charCodeAt(0);
  return self;
};
Stream.prototype.writeUnicodeChar = function(c) {
  var self = this;
  self.writeInt16(c.charCodeAt(0));
  return self;
};

Stream.prototype.writeInt16 = function(w) {
  var self = this;
  self.writeByte((w >> 8) & 0xFF);
  self.writeByte(w & 0xFF);
  return self;
};
Stream.prototype.writeShort = Stream.prototype.writeInt16;

Stream.prototype.writeWord = function(w) {
  var self = this;
  self.writeByte((w >> 24) & 0xFF);
  self.writeByte((w >> 16) & 0xFF);
  self.writeByte((w >> 8) & 0xFF);
  self.writeByte(w & 0xFF);
  return self;
};
Stream.prototype.writeLongWord = function(dw) {
  var self = this;
  var desc = new ActionDescriptor();
  desc.putLargeInteger(app.charIDToTypeID('Temp'), dw);
  var str = new Stream(desc.toStream());
  str.seek(8, 2);
  for (var i = 0; i < 8; i++) {
    self.writeByte(str.readByte());
  }
  return self;
};

Stream.prototype.writeDouble = function(d) {
  var self = this;
  var str = IEEE754.doubleToBin(d);
  self.writeRaw(str);
};
Stream.prototype.writeRaw = function(s) {
//  $.writeln(s.length);
//  $.writeln(new Date());
//  $.level = 1; debugger;

  var self = this;

  if (s.constructor == String) {
    for (var i = 0; i < s.length; i++) {
      self.str[self.ptr++] = String.fromCharCode(s.charCodeAt(i));
    }
    // var x = s.split('');
    // $.writeln("x = " + x.length);
    // // alert(x.length);
    // $.writeln(new Date());
    // var str = String.fromCharCode.apply(String, x);

    // $.writeln("str = " + str.length);
    // $.writeln(new Date());

    // // alert(str.length);

    // if (self.str.constructor == Array) {
    //   self.str.concat(str.split(''));
    //   self.ptr += str.length;
    // } else {
    //   for (var i = 0; i < str.length; i++) {
    //     //self.writeByte(s.charCodeAt(0));
    //     $.writeln(i);
    //     // self.str[self.ptr++] = String.fromCharCode(s.charCodeAt(i));
    //     self.str[self.ptr++] = str[i];
    //   }
    // }
  } else {
    for (var i = 0; i < s.length; i++) {
      self.str[self.ptr++] = s[i];
    }
  }
};
Stream.prototype.writeString = function(s) {
  var self = this;
  for (var i = 0; i < s.length; i++) {
    //self.writeChar(s[i]);
    self.str[self.ptr++] = s[i];
  }
};
Stream.prototype.writeAscii = function(s) {
  var self = this;
  self.writeWord(s.length);
  for (var i = 0; i < s.length; i++) {
    //self.writeChar(s[i]);
    self.str[self.ptr++] = s[i];
  }
};
Stream.prototype.writeUnicode = function(s) {
  var self = this;
  self.writeWord(s.length + 1);
  for (var i = 0; i < s.length; i++) {
    //self.writeUnicodeChar(s[i]);
    self.writeInt16(s.charCodeAt(i));
  }
  self.writeInt16(0);  // null pad
};
Stream.prototype.writeUnicodeString = function(s) {
  var self = this;
  for (var i = 0; i < s.length; i++) {
    self.writeInt16(s.charCodeAt(i));
  }
  self.writeInt16(0);  // null pad
};
Stream.prototype.writeBoolean = function(b) {
  var self = this;
  self.writeByte(b ? 1 : 0);
};

//
// Read parts from the Stream
//
Stream.prototype.readByte = function() {
  var self = this;
  if (self.ptr >= self.str.length) {
    return Stream.EOF;
  }
  var ch = self.str[self.ptr++];
  var c = ch.charCodeAt(0);

  if (isNaN(c) && ch == 0) {
    c = 0;
  }

  return c;
};
Stream.prototype.readSignedByte = function() {
  b = this.readByte();
  if (b > 0x7F) {
    b = 0xFFFFFF00^b;
  };
  return b;
};
Stream.prototype.readByteChar = function() {
  var b = this.readByte();
  if (b != Stream.EOF) {
    b = String.fromCharCode(b);
  }
  return b;
};
Stream.prototype.readChar = function() {
  var self = this;
  if (self.ptr >= self.str.length) {
    return Stream.EOF;
  }
  var c = self.str[self.ptr++];
  return c;
};
Stream.prototype.readUnicodeChar = function() {
  var self = this;
  var i = self.readInt16();
  return String.fromCharCode(i);
};

Stream.prototype.readInt16 = function() {
  var self = this;
  var hi = self.readByte();
  var lo = self.readByte();
  if (self.byteOrder == Stream.BIG_ENDIAN) {
    return (hi << 8) + lo;
  } else {
    return (lo << 8) + hi;
  }
};
Stream.prototype.readShort = Stream.prototype.readInt16;

Stream.prototype.readSignedInt16 = function() {
  var i = this.readInt16();
  if(i > 0x7FFF){
    i = 0xFFFF0000^i;
  };
  return i;
};
Stream.prototype.readSignedShort = Stream.prototype.readSignedInt16;

Stream.prototype.readWord = function() {
  var self = this;
  var hi = self.readInt16();
  var lo = self.readInt16();
  var w;
  if (self.byteOrder == Stream.BIG_ENDIAN) {
    w = (hi << 16) + lo;
  } else {
    w = (lo << 16) + hi;
  }
  if (w < 0) {
    w = 0xFFFFFFFF + w + 1;
  }
  return w;
};

Stream.prototype.readSignedWord = function() {
  var w = this.readWord();
  if(w > 0x7FFFFFFF){
    w = 0xFFFFFFFF00000000^w;
  }
  return w;
};

Stream.prototype.readLongWord = function() {
  var self = this;
  var dw = self.readSignedLongWord();

  if (dw < 0) {
    self.ptr -= 8;
    var s = "0x";
    for (var i = 0; i < 8; i++) {
      var b = self.readByte();
      s += b.toString(16);
    }

    dw = parseInt(s);
  }

  return dw;
};

Stream.prototype.readSignedLongWord = function() {
  var self = this;
  var desc = new ActionDescriptor();
  desc.putLargeInteger(app.charIDToTypeID('Temp'), 0);
  var str = new Stream(desc.toStream().split(''));
  str.seek(8, 2);

  for (var i = 0; i < 8; i++) {
    var b = self.readByte();
    str.writeByte(b);
  }

  str.seek(0, 0);
  desc.fromStream(str.toStream());
  dw = desc.getLargeInteger(app.charIDToTypeID('Temp'));

  return dw;
};


Stream.prototype.readRaw = function(len) {
  var self = this;
  var str = self.str;

  var ar = str.slice(self.ptr, self.ptr+len);
  self.ptr += len;

  return ar;

// This is the original paranoid slower version
//   var ar = [];
//   for (var i = 0; i < len; i++) {
//     ar[i] = String.fromCharCode(self.readByte());
//   }
//   return ar.join("");
};

Stream.prototype.readDouble = function() {
  var self = this;
  var bin = self.readRaw(8);
  var v = IEEE754.binToDouble(bin);
  return v;
};

Stream.prototype.readFloat = function() {
  var self = this;
  var bin = self.readRaw(4);
  var ieee32 = new IEEE754(32);

  var v = IEEE754.binToDouble(bin);
  return v;
};

Stream.prototype.readString = function(len) {
  var self = this;
  var s = '';
  for (var i = 0; i < len; i++) {
    s += self.readChar();
  }
  return s;
};
Stream.prototype.readAscii = function() {
  var self = this;
  var len = self.readWord();
  return self.readString(len);
};
Stream.prototype.readUnicode = function(readPad) {
  var self = this;

  var len = self.readWord();
  if (readPad != false) {
    len--;
  }
  var s = '';
  for (var i = 0; i < len; i++) {
    //s += self.readUnicodeChar();
    var uc = self.readInt16();
    if (uc != 0) {
      s += String.fromCharCode(uc);
    }
  }
  if (readPad != false) {
    self.readInt16(); // null pad
  }
  return s;
};
Stream.prototype.readUnicodeZ = function() {
  return this.readUnicode(true);
};
Stream.prototype.readBoolean = function(b) {
  var self = this;
  return self.readByte() != 0;
};

Stream.prototype.toHex = function(start, len) {
  var self = this;
  if (start == undefined) {
    start = self.ptr;
    len = 16;
  }
  if (len == undefined) {
    len = start;
    start = self.ptr;
  }
  var s = self.str.slice(start, start+len);
  if (self.str instanceof Array) {
    s = s.join("");
  }
  return Stream.binToHex(s, true);
};
Stream.binToHex = function(s, whitespace) {
  function hexDigit(d) {
    if (d < 10) return d.toString();
    d -= 10;
    return String.fromCharCode('A'.charCodeAt(0) + d);
  }
  var str = '';

  for (var i = 0; i < s.length; i++) {
    if (i) {
      if (whitespace == true) {
        if (!(i & 0xf)) {
          str += '\n';
        } else if (!(i & 3)) {
          str += ' ';
        }
      }
    }
    var ch = s[i].charCodeAt(0);
    str += hexDigit(ch >> 4) + hexDigit(ch & 0xF);
  }
  return str;
};


Stream.prototype.dump = function(len) {
  return Stream.binToHex(this.str.slice(this.ptr, this.ptr + (len || 32)),
                         true);
};
Stream.prototype.rdump = function(start, len) {
  return Stream.binToHex(this.str.slice(start, start + (len || 32)),
                         true);
};
Stream.prototype.dumpAscii = function(len) {
  return this.str.slice(this.ptr, this.ptr + (len || 32)).replace(/\W/g, '.');
};

"Stream.js";
// EOF

//
// ShapesFile
//
// $Id: XWatermark.jsx,v 1.74 2015/12/03 22:01:33 anonymous Exp $
// Copyright: (c)2008, xbytor
// License: http://www.opensource.org/licenses/bsd-license.php
// Contact: xbytor@gmail.com
//
//@show include
//
app;
//
//
//include "xlib/stdlib.js"
//include "xlib/Stream.js"
//include "xlib/PresetsManager.jsx"
//

CustomShapeInfo = function() {
  var self = this;
  self.name = '';
  self.id = '';
  self.x = 0;
  self.x = 0;
  self.w = 0;
  self.h = 0;
};
CustomShapeInfo.prototype.typename = "CustomShapeInfo";
CustomShapeInfo.prototype.toString = function() {
  var self = this;
  var str = "{ name: \"" + self.name + "\", ";
  str += "id: \"" + this.id + "\", ";
  str += "[" + self.x + ", " + self.y + ", ";
  str += (self.x + self.w) + ", " + (self.y + self.h) + "] }";
  return str;
};

CustomShapeInfo.massageName = function(name) {
  var n = localize(name);
  n = n.replace(/\s+/g, '');  // remove any embedded spaces
  n = n.replace(/\W/g, '_');  // replace any non-word characters with '_'
  n = n.replace(/[_]+$/, ''); // remove any trailing '_'
  return n;
};

CustomShapeInfo.getShapeInfo = function(name) {
  var pm = new PresetsManager();
  var csm = new PTM(pm, PresetType.CUSTOM_SHAPES);

  var tempFile = new File(Folder.temp + '/' + CustomShapeInfo.massageName(name) + ".csh");
  csm.saveElement(name, tempFile);

  var shapesFile = new ShapesFile();
  shapesFile.read(tempFile);
  var info = shapesFile.shapes[0];
  tempFile.remove();

  return info || {};
};

ShapesFile = function() {
  var self = this;
  self.file = null;
  self.shapes = [];
};
ShapesFile.prototype.typename = "ShapesFile";

ShapesFile.prototype.toString = function() {
  var self = this;

  var str = "[ShapesFile " + decodeURI(self.file) + "\r\n";
  var shapes = self.shapes;
  for (var i = 0; i < shapes.length; i++) {
    str += shapes[i] + ",\r\n";
  }
  str += "]\r\n";

  return str;
};

ShapesFile.prototype.readFirstShape = function(fptr) {
  var self = this;

//   debugger;
  var idLen = 37;

  self.file = File(fptr);

  var str = Stream.readStream(self.file);

  var fileID = str.readKey();

  if (fileID != 'cush') {
    throw "File is not a custom shape file";
  }

  var n = str.readWord(); // 2??
  var cnt = str.readWord();
  var name = str.readUnicode();
  if (str.ptr % 4) {
    str.readUnicodeChar(); // pad
  }

  var idx = str.readWord();
  var len = str.readWord();
  var id = str.readString(idLen);

  var shapeInfo = {
    name: name,
    file: self.file,
    id: id,
    index: idx
  };
  return shapeInfo;
};

ShapesFile.prototype.read = function(fptr) {
  var self = this;

  self.file = File(fptr);
  self.shapes = [];

  var str = Stream.readStream(self.file);

  var fileID = str.readKey();

  if (fileID != 'cush') {
    throw "File is not a custom shape file";
  }

  var re = /(\x00\w|\x00\d)(\x00\w|\x00\s|\x00\d|\x00\.|\x00\'|\x00\-)+(.|\n){10}\$[-a-z\d]+/g;//'

  var raw = str.str;
  var parts = raw.match(re);
  if (parts == null) {
    re = /(\x00\w|\x00\d)(\x00\w|\x00\s|\x00\d|\x00\.|\x00\'|\x00\-)+(.|\n){12}\$[-a-z\d]+/g;//'
    parts = raw.match(re);

    if (!parts) {
//       debugger;
      return undefined;
    }
  }

  for (var i = 0; i < parts.length; i++) {
    var p = parts[i];
    var sp = p.replace(/\x00/g, '').split('$');
    
    sp[0] = sp[0].match(/[\w\d][\w\s\d\.\'\-]+/)[0]; //'

    var shape = new CustomShapeInfo();
    shape.name = sp[0];
    var id = sp[1];
    shape.id = '$' + sp[1];
    var m = str.str.match(sp[1]);
    str.ptr = m.index + m[0].length;
    shape.y = str.readWord() + 2;
    shape.x = str.readWord() + 2;
    shape.h = str.readWord() - shape.y - 2;
    shape.w = str.readWord() - shape.x - 2;
    self.shapes.push(shape);
  }

  return self.shapes;
};


if (!Stream.prototype.readAsciiOrKey) {
  //===========================================================================
  //   Stream Extensions
  //===========================================================================
  Stream.prototype.readAsciiOrKey = function() {
    var self = this;
    var len = self.readWord();
    if (len > 20000) {
      throw "Read of string longer than 20K requested.";
    }
    return self.readString(len ? len : 4);
  };

  Stream.prototype.readKey = function() {
    return this.readString(4);
  };
  Stream.prototype.readUnicodeString = function(len, readPad) {
    var self = this;
    var s = '';
    for (var i = 0; i < len; i++) {
      var uc = self.readInt16();
      s += String.fromCharCode(uc);
    }
    if (readPad == true) {
      self.readInt16();     // null pad
    }
    return s;
  };
  Stream.prototype.readUnicodeOrKey = function() {
    var self = this;
    //var len = self.int16();
    var len = self.readWord();
    if (len > 20000) {
      throw "Read of string longer than 20K requested.";
    }
    var v;
    if (len == 0) {
      v = self.readString(4);
    } else {
      //self.ptr -= 4;
      v = self.readUnicodeString(len);
    }
    return v;
  };
};

ShapesFile.test = function() {
  if (false) {
    var shapeInfo = CustomShapeInfo.getShapeInfo("EricaXHeart");
    alert(listProps(shapeInfo));

    return;

    var pm = new PresetsManager();
    var names = pm.getNames(PresetType.CUSTOM_SHAPES);

    var str = '';
    for (var i = 0; i < names.length; i++) {
      var name = names[i];
      var shapeInfo = CustomShapeInfo.getShapeInfo(name);
      str += name + '::' + shapeInfo.toString() + '\r';
//       if (!confirm(shapeInfo + "\rContinue?")) {
//         break;
//       }
    }
    alert(str);
  }

  if (false) {
    var shapeFile = "/c/work/xes/test/presets/Square100x200.csh";
    var sf = new ShapesFile();
    sf.read(shapeFile);
    alert(sf);
    return;
  }

  if (false) {
    var shapeFolder = new Folder(app.path + "/Presets/Custom Shapes");
    var shapeFiles = shapeFolder.getFiles("*.csh");

    var str = '';
    for (var i = 0; i < shapeFiles.length; i++) {
      var file = shapeFiles[i];
      var shapes = new ShapesFile();
      shapes.read(file);
      str += shapes;
    }
    
    alert(str);
  }
};

// ShapesFile.test();

"ShapesFile.js";
// EOF

//
// metadata.js
//
// routines for manipulating IPTC, EXIF, XMP, and any other
// metadata
//
// Functions:
//
// History:
//  2005-01-20 v0.8 Name change
//  2004-09-27 v0.1 Creation date
//
// Copyright: (c)2007, xbytor
// License: http://www.opensource.org/licenses/bsd-license.php
// Contact: xbytor@gmail.com
//
// $Id: XWatermark.jsx,v 1.74 2015/12/03 22:01:33 anonymous Exp $
//
// To use XMPScript/File metatdata access, you need to first
//include "xlib/XMPTools.jsx"
//

//================================= EXIF ===============================

EXIF = function EXIF(obj) {
  if (obj.typename == "Document") {
    this.exif = obj.info.exif;
  } else {
    this.exif = obj;
  }
  this.caseSensitive = false;
};
EXIF.prototype.get = function(tag) {
  var exif = this.exif;

  for (var i = 0; i < exif.length; i++) {
    var name = exif[i][0];
    if (name == tag) {
      return exif[i][1];
    }
  }

  if (!this.caseSensitive) {
    tag = tag.toLowerCase().replace(/\s/g, '');

    for (var i = 0; i < exif.length; i++) {
      var name = exif[i][0];
      name = name.toLowerCase().replace(/\s/g, '');
      if (name == tag) {
        return exif[i][1];
      }
    }
  }

  return '';
};
EXIF.prototype.toString = function(indent) {
  var exif = this.exif;

  var s = '';
  if (indent == undefined) { indent = ''; }
  for (var i = 0; i < exif.length; i++) {
    var name = exif[i][0];
    var val  = exif[i][1] || '';
    s += indent + name + ': ' + val + '\r\n';
  }

  return s;
};
EXIF.prototype.toXMLString = function() {
  return "<EXIF>\r\n<![CDATA" + "[\n" + this.toString() + "\r\n]" + "]>\r\n</EXIF>\r\n";
};


//================================== IPTC ===================================

IPTC = function IPTC(obj) {
  if (obj.typename == "Document") {
    this.info = obj.info;
  } else if (obj.typename == "DocumentInfo") {
    this.info = obj;
  }
};

IPTC._names = {
  creator: "author",
  creatorstitle: "authorPosition",
  description: "caption",
  descriptionwriter: "captionWriter",
  provinceorstate: "provinceState",
};
IPTC.prototype.get = function(tag) {
  var info = this.info;
  tag = tag.toLowerCase();

  var nm = IPTC._names[tag];

  if (nm) {
    tag = nm.toLowerCase();
  }

  for (var idx in info) {
    if (idx.toLowerCase() == tag) {
      return info[idx];
    }
  }
  return '';
};
IPTC.prototype.set = function(tag, value) {
  var info = this.info;

  for (var idx in info) {
    if (idx.toLowerCase() == tag) {
      info[idx] = value;
    }
  }
  return value;
};
IPTC.prototype.getCreationDate = function() {
  var info = this.info;

  var dstr = info.creationDate;
  var date;
  if (dstr && dstr.length != 0) {
    date = IPTC.DocumentInfoStringToDate(dstr);
  }
  return date;
};
IPTC.prototype.setCreationDate = function(date) {
  var info = this.info;

  var dstr = null;
  if (date) {
    if (typeof date != "object" || !(date instanceof Date)) {
      return null;
    }
    dstr = IPTC.DateToDocumentInfoString(date);
  } else {
    dstr = null;
  }
  return info.creationDate = dstr;
};
IPTC.prototype.getKeywords = function() {
  var info = this.info;

  return IPTC.get(info, "keywords");
};
IPTC.prototype.setKeywords = function(keywords) {
  var info = this.info;

  if (keywords == undefined) { keywords = []; }
  return info.keywords = keywords;
};
IPTC.prototype.addKeyword = function(keyword) {
  return this.addKeywords([keyword]);
};
IPTC.prototype.addKeywords = function(keywords) {
  var info = this.info;
  var keys = info.keywords;
  if (!keywords || keywords.length == 0 || !(keywords instanceof Array)) {
    return keys;
  }

  return info.keywords = Set.merge(keys, keywords);
};
IPTC.prototype.removeKeyword = function(keyword) {
  var info = this.info;

  if (!keyword) {
    return undefined;
  }
  return info.keywords = Set.remove(info.keywords, keyword);
};
IPTC.prototype.containsKeyword = function(keyword) {
  var info = this.info;

  if (!keyword) {
    return undefined;
  }
  return Set.contains(info.keywords, keyword);
};
IPTC.prototype.toString = function(exif) {
  var info = this.info;

  var str = '';
  if (exif == undefined) { exif = false; }
  for (var x in info) {
    if (x == "exif") {
      if (exif) {
        str += "exif:\r\n" + EXIF.toString(doc.info.exif, '\t');
      } else {
        str += "exif: [EXIF]\r\n";
      }
    } else if (x == "keywords" || x == "supplementalCategories") {
      str += x + ":\t\r\n";
      var list = info[x];
      for (var y in list){
        str += '\t' + list[y] + "\r\n";
      }
    } else if (x == "creationDate") {
      var dstr = IPTC.DocumentInfoStringToISODate(info[x]);
      str += x + ":\t" + dstr + "\r\n";
    } else {
      str += x + ":\t" + info[x] + "\r\n";
    }
  }
  return str;
};
IPTC.prototype.toXMLString = function(info) {
  return "<IPTC>\r\n<![CDATA" + "[\n" + IPTC.toString(info) + "\r\n]" + "]>\r\n</IPTC>\r\n";
};
IPTC.DateToDocumentInfoString = function(date) {
  if (!date) {
    date = new Date();
  } else if (typeof date != "object" || !(date instanceof Date)) {
    return undefined;
  }
  var str = '';
  function _zeroPad(val) { return (val < 10) ? '0' + val : val; }
  str = date.getFullYear() + '-' +
  _zeroPad(date.getMonth()+1,2) + '-' +
  _zeroPad(date.getDate(),2);

  return str;
};
// IPTC.DocumentInfoStringToDate("20060410");
IPTC.DocumentInfoStringToDate = function(str) {
  if (!str || str.length != 8) {
    return undefined;
  }
  return new Date(Number(str.substr(0, 4)),
                  Number(str.substr(4, 2))-1,
                  Number(str.substr(6,2)));
};
IPTC.DocumentInfoStringToISODate = function(str) {
  return str.substr(0, 4) + '-' + str.substr(4, 2) + '-' + str.substr(6,2);
};

//================================= XMP ==================================
// var str = doc.xmpMetadata.rawData;

// var rex = /<([^>]+)>([^<]+)<\/(?:\1)>/m;
// var m;

// while (m = rex.exec(str)) {
//   var tag = m[1];
//   var value = m[2];
//   alert(tag + ' : ' + value);

//   str = RegExp.rightContext;
// }
//  /<([^>]+)>([^<]+)<\/(?:\1)>/

XMPData = function(obj) {
  var self = this;

  if (obj.typename == "Document") {
    self.xmp = obj.xmpMetadata.rawData;

  } else if (obj.constructor == String) {
    self.xmp = obj;

  } else if (obj instanceof XMPMeta) {
    self.xmpMeta = obj;

  } else if (obj != undefined) {
    Error.runtimeError(9001, "XMPData constructor argument must be a " +
                       "Document or a String");
  }

  self.caseSensitive = false;
};

XMPData.SEPARATOR = ',';
XMPData.hasXMPTools = function() {
  if (!XMPData._hasXMPTools) {
    try {
      XMPTools;
      XMPData._hasXMPTools = XMPTools.isCompatible() && XMPTools.loadXMPScript();
    } catch (e) {
      XMPData._hasXMPTools = false;
    }
  }
  return XMPData._hasXMPTools;
}

XMPData._xmp_extract = function(str, startTag, stopTag) {
  var re = new RegExp(startTag, 'i');
  var start = str.match(re);

  if (!start) {
    return undefined;
  }

  var re = new RegExp(stopTag, 'i');
  var stop = str.match(re);
  if (!stop) {
    return undefined;
  }

  var startIndex = start.index + start[0].length;

  var val = str.substring(startIndex, stop.index).trim();

  // This takes care of matches against </rdf:Description> and others
  // which are not valid...
  if (val.match('^</rdf:[^>]+>')) {
    return undefined;
  }

  // Order/Unordered Arrays
  // return a comma delimited list
  //
  if (val.match('^<rdf:Seq>') || val.match('^<rdf:Bag>')) {
    var res = [];
    var rex = /<rdf:li>([^<]+)<\/rdf:li>/m;
    var m;
    while (m = rex.exec(val)) {
      res.push(m[1].trim());
      val = RegExp.rightContext;
    }

    var s = res.join(XMPData.SEPARATOR);
    return (res.length > 1) ? ('[' + s + ']') : s;
  }

  // Alternative Arrays
  // return the 'default' or first element
  //
  if (val.match('^<rdf:Alt>')) {
    var m = val.match(/<rdf:li.+default.+>([^<]+)<\/rdf:li>/);
    if (!m) {
      m = val.match(/<rdf:li.+>([^<]+)<\/rdf:li>/);
      if (!m) {
        return val;
      }
    }
    return m[1].trim();
  }

  // Structures
  // result looks like "{key1:"value1",key2:"value2"}
  // should probably use json for this
  //
  if (val.match('<stDim:')) {
    var res = [];
    var rex = /<stDim:([\w]+)>([^<]+)<\/stDim:\w+>/;
    var m;
    while (m = rex.exec(val)) {
      res.push(m[1] + ":\"" + m[2].trim() + '\"');
      val = RegExp.rightContext;
    }

    return '{' + res.join(XMPData.SEPARATOR) + '}';
  }

  return val;
};

XMPData.prototype.getFromXMPMeta = function(tag) {
  var self = this;
  var xmeta = self.xmpMeta;

  if (!xmeta) {
    xmeta = self.xmpMeta = new XMPMeta(self.xmp);
  }

  var val = XMPTools.getMetadataValue(xmeta, tag);
  return val;
};

// function _xmlFix(v) {
// };

// _xmlFix.run = function(v) {
//   if (v) {
//     var str = v;
//     var t = _xmlFix.table;
//     var result = '';
//     var rex = t._rex;
//     var m;

//     while (m = str.exec(str)) {
//     var pre = m[1];
//     var typ = m[2];
//     var post = m[3];
//     result += pre + cnvts[typ](t);
//     str = post;
//   }
//   result += str;
//   return result;
// };

// _xmlFix.table = {};
// _xmlFix.table._add = function(enc, hex) {
//   _xmlFix.table[enc] = hex;
// };
// _xmlFix.table._init = function() {
//   var t = _xmlFix.table;
//   t.add('quot', '\x22');
//   t.add('amp', '\x26');
//   t.add('lt', '\x3C');
//   t.add('gt', '\x3E');

//   var str = '';
//   for (var idx in t) {
//     if (!idx.startsWith('_')) {
//       str += "|" + idx;
//     }
//   }
//   str = "([^&])&(" + str.substring(1) + ");(.*)":

//   // fix this
//   t._rex = new RegExp(str);
// };
// _xmlFix.table._init();

XMPData.prototype.get = function(tag) {
  var self = this;

  if (XMPData.hasXMPTools()) {
    var val = self.getFromXMPMeta(tag);
    if (!val) {
      // try a reverse localization lookup to get the actual exif tag
    }
    return val;
  }

  //  $.level = 1; debugger;

  var hasNmSpc = tag.contains(':');

  if (hasNmSpc) {
    var val = XMPData._xmp_extract(self.xmp,
      '<' + tag + '>', '</' + tag + '>');

    if (val != undefined) {
      return val;
    }

  } else {
    // XXX Fix later
    // the startTag should probably look more like this:
    // '<[^(:|\\/)]+:' + tag + '>'
    var val = XMPData._xmp_extract(self.xmp,
      '<[^:]+:' + tag + '>',
      '</[^:]+:' + tag + '>');

    if (val != undefined) {
      return val;
    }
  }

  // handle embedded spaces
  if (tag.contains(' ')) {
    var t = tag.replace(' ', '');
    var val = self.get(t);
    if (val != undefined && val != '') {
      return val;
    }
  }

  // check for missing 'Value' suffix
  if (!tag.endsWith('Value')) {
    var t = tag + 'Value';
    var val = self.get(t);
    if (val != undefined && val != '') {
      return val;
    }
  }

  // The rest of this code handles metadata formatted in a non-canonical
  // format.

  // tag with a namespace
  var restr3 = "\\W" + tag + "=\"([^\"]*)\"";

  // tag without a namespace
  var restr4 = "\\W[\\w]+:" + tag + "=\"([^\"]*)\"";

  var re = new RegExp(restr3);
  var m = self.xmp.match(re);

  if (!m) {
    re = new RegExp(restr4);
    m = self.xmp.match(re);
  }

  if (!self.caseSensitive) {
    // now check the rex's again but case-insensitive
    if (!m) {
      re = new RegExp(restr3, 'i');
      m = self.xmp.match(re);
    }

    if (!m) {
      re = new RegExp(restr4, 'i');
      m = self.xmp.match(re);
    }
  }

  if (m) {
    return m[1];
  }

  // In CS4, Adobe will apparently use xmp* name spaces instead of xap*
  // namespaces. This code addresses that equivalence.

  var nm = undefined;
  var nmspc = undefined;
  var m = tag.split(':');

  if (m.length == 2) {
    nmspc = m[0];
    nm = m[1];
  }

  if (!nmspc || !nmspc.startsWith('xap')) {
    return '';
  }

  nmspc = nmspc.replace(/xap/, 'xmp');

  var rtag = nmspc + ':' + nm;

  // CS3 style
  var restr5 = '<' + rtag + '>(.+)</' + rtag + '>';

  // CS4 style
  var restr6 = "\\W" + rtag + "=\"([^\"]*)\"";

  var re = new RegExp(restr5);
  var m = self.xmp.match(re);

  if (!m) {
    re = new RegExp(restr6);
    m = self.xmp.match(re);
  }

  if (!self.caseSensitive) {
    // now check the rex's again but case-insensitive
    if (!m) {
      re = new RegExp(restr5, 'i');
      m = self.xmp.match(re);
    }

    if (!m) {
      re = new RegExp(restr6, 'i');
      m = self.xmp.match(re);
    }
  }

  if (m) {
    return m[1];
  }

  return '';
};


//================================= Metadata ==================================

Metadata = function(obj) {
  var self = this;

  if (obj != undefined) {
    if (obj.typename == "Document") {
      self.doc = obj;

    } else if (obj instanceof File) {
      self.file = obj;
      if (XMPData.hasXMPTools()) {
        self.xmpMeta = XMPTools.loadMetadata(self.file);
      }

    } else if (obj instanceof String || typeof(obj) == "string") {
      self.str = obj;
      if (XMPData.hasXMPTools()) {
        self.xmpMeta = new XMPMeta(self.str);
      }

    } else if (XMPData.hasXMPTools() && obj instanceof XMPMeta) {
      self.xmpMeta = obj;

    } else {
      var md = {};
      for (var idx in obj) {
        var v = obj[idx];
        if (typeof v != 'function') {
          md[idx] = v;
        }
      }
      self.obj = md;
      self.obj.get = function(tag) {
        return this.obj[tag] || '';
      };
    }
  }
  self.defaultDateTimeFormat = Metadata.defaultDateTimeFormat;
  self.defaultGPSFormat = Metadata.defaultGPSFormat;
};
Metadata.DEFAULT_DATE_FORMAT = "%Y-%m-%d";
Metadata.DEFAULT_GPS_FORMAT = "%d\u00B0 %d' %.2f\"";

Metadata.defaultDateTimeFormat = Metadata.DEFAULT_DATE_FORMAT;
Metadata.defaultGPSFormat = Metadata.DEFAULT_GPS_FORMAT;

Metadata.prototype.get = function(tags) {
  var self = this;

  var single = false;

  try {
    if (!tags) {
      return undefined;
    }
    if (tags.constructor == String) {
      tags = [tags];
      single = true;
    }
    if (!(tags instanceof Array)) {
      return undefined;
    }

    var res = {};
    var re = /\$\{([^:]+):(.+)\}/;
    var re2 = /([^:]+):(.+)/;

    if (self.obj) {
      for (var i = 0; i < tags.length; i++) {
        var tag = tags[i];
        var m = tag.match(re);
        if (m) {
          tag = m[2];
        }

        val = self.obj[tag];
        res[tag] = val || '';

        if (single) {
          single = val;
        }
      }

    } else if (self.str || self.xmpMeta) {
      var xmp;
      if (self.xmpMeta) {
        xmp = new XMPData(self.xmpMeta);
      } else {
        xmp = new XMPData(self.str);
      }

      for (var i = 0; i < tags.length; i++) {
        var tag = tags[i];
        var m = tag.match(re);
        if (!m) {
          m = tag.match(re2);
          if (!m) {
            Error.runtimeError(9001, "Bad tag value: " + tag);
          }
        }
        var type = m[1];
        var name = m[2];
        var val;

        if (type == 'EXIF') {
          val = xmp.get(name);

        } else if (type == 'IPTC') {
          val = xmp.get('Iptc4xmpCore:' + name);
          if (!val) {
            val = xmp.get(name);
          }
        } else if (type == 'XMP') {
          val = xmp.get(name);

        } else {
          Error.runtimeError(9001, "Bad tag type: " + type);
        }

        res[tag] = val || '';
        if (single) {
          single = val;
        }
      }

    } else if (self.doc && self.doc.typename == "Document") {
      var exif = new EXIF(self.doc);
      var iptc = new IPTC(self.doc);
      var xmp  = new XMPData(self.doc);

      for (var i = 0; i < tags.length; i++) {
        var tag = tags[i];
        var m = tag.match(re);

        if (!m) {
          m = tag.match(re2);
          if (!m) {
            Error.runtimeError(9001, "Bad tag value: " + tag);
          }
        }

        var type = m[1];
        var name = m[2];
        var val;

        if (type == 'EXIF') {
          val = exif.get(name);
          if (!val) {
            val = xmp.get(name);
          }
        } else if (type == 'IPTC') {
          val = iptc.get(name.toLowerCase());
          if (!val) {
            val = iptc.get(name);
          }
          if (!val) {
            val = xmp.get('Iptc4xmpCore:' + name);
          }
          if (!val) {
            val = xmp.get(name);
          }
        } else if (type == 'XMP') {
          val = xmp.get(name);
        } else {
          throw "Bad tag type " + type;
        }

        res[tag] = val || '';
        if (single) {
          single = val;
        }
      }

    } else {
      Error.runtimeError(9001, "Internal Error: Unable to determine " +
                         "metadata for images");
    }

  } catch (e) {
    Stdlib.logException(e);
    return undefined;
  }

  return (single ? single : res[0]);
};

Metadata.prototype.formatDate = function(date, fmt) {
  var self = this;
  var str = fmt || self.defaultDateTimeFormat;

  if (!str.contains('%')) {
    str = str.replace(/YYYY/g, '%Y');
    str = str.replace(/YY/g, '%y');
    str = str.replace(/MM/g, '%m');
    str = str.replace(/DD/g, '%d');
    str = str.replace(/H/g, '%H');
    str = str.replace(/I/g, '%I');
    str = str.replace(/M/g, '%M');
    str = str.replace(/S/g, '%S');
    str = str.replace(/P/g, '%p');
  }
  return date.strftime(str);
};

Metadata.prototype.strf = function(fmt) {
  var self = this;
  var ru = app.preferences.rulerUnits;
  app.preferences.rulerUnits = Units.PIXELS;
  
  try {
  var str = fmt;

  var doc = self.doc;
  var file;

  if (doc) {
    file = Stdlib.getDocumentName(doc);

  } else {
    file = self.file;
  }

  // just used as a boolean check
  var xmp = self.xmpMeta;
  
  var restrBase = "%|B|F|H|M|P|R|s|S|W|n|t| "; // d|e|f|p
  var restrC = "|C(?:\\{([^\\}]+)\\})?";
  var restrT = "|T(?:\\{([^\\}]+)\\})?";
  var restrN = "|N(?:\\{([^\\}]+)\\})?";
  var restrIE = "|(?:I|E)\\{([^\\}]+)\\}";
  var restrX = "|X\\{([^:]+)\:([^\\}]+)\\}";
  var restrX2 = "|X\\{([^\\}]+)\\}";

  var restrFile = "|(-)?(\\d+)?(\\.\\d+)?(d|e|f|p)";

  var restr = ("([^%]*)%(" + restrBase + restrC + restrT + restrN +
               restrIE + restrX + restrX2 + restrFile + ")(.*)");

  var re = new RegExp(restr);

  var dateFormat = self.defaultDateTimeFormat;

  var a = [];
  var b = [];

  //$.level = 1; debugger;

  var result = '';

  while (a = re.exec(str)) {
    var leftpart     = a[1];
    var pType        = a[2].charAt(0);

    var createTime   = a[3];
    var fileTime     = a[4];
    var currentTime  = a[5];
    var ieTag        = a[6];
    var xmpSpace     = a[7];
    var xmpTag       = a[8];
    var xTag         = a[9];
    var rightPart    = a[10];

    var fsig         = a[10];
    var flen         = a[11];
    var fign         = a[12];
    var ftyp         = a[13];

    var rightPart    = a[14];

    var subst = '';

    if (pType == '%') {
      subst = '%';

    } else if (ftyp) {
      subst = file.strf('%' + a[2]);

    } else {
      switch (pType) {
        case 'd':
          if (file) {
            subst = file.strf("%d");
          }
          break;
        case 'e':
          if (file) {
            subst =  file.strf("%e");
          }
          break;
        case 'p':
          if (file) {
            subst = decodeURI(file.parent.name);
          }
          break;
        case 'f':
          if (file) {
            subst = file.strf("%f");
          }
          break;
        case 'F':
          if (file) {
            subst = decodeURI(file.name);
          }
          break;
        case 's':
          if (file) {
            subst =  file.length;
          }
          break;
        case 'S':
          if (file) {
            var len = file.length;
            if (len > 1000000000) {
              subst = Math.round(len/1000000000) + 'G';
            } else if (len > 1000000) {
              subst = Math.round(len/1000000) + 'M';
            } else if (len > 1000) {
              subst = Math.round(len/1000) + 'K';
            } else {
              subst = len;
            }
          }
          break;
        case 'C':
          if (file) {
            subst = self.formatDate(file.created, createTime);
          }
          break;
        case 'T':
          if (file) {
            subst = self.formatDate(file.modified, fileTime);
          }
          break;
        case 'N':
          if (file) {
            subst = self.formatDate(new Date(), currentTime);
          }
          break;
        case 'W':
          if (doc) {
            subst = doc.width.value;
          } else if (xmp) {
            self.get('${XMP:ImageWidth}');
            if (!subst && self._width) {
              subst = self._width;
            }
          }
          break;
        case 'H':
          if (doc) {
            subst = doc.height.value;
          } else if (xmp) {
            subst = self.get('${XMP:ImageHeight}');
            if (!subst && self._height) {
              subst = self._height;
            }
          }
          break;
        case 'M':
          if (doc) {
            subst = Stdlib.colorModeString(doc.mode);

          } else if (xmp) {
            var mstr = self.get('${XMP:ColorMode}');
            if (mstr) {
              var cmode = toNumber(mstr);
              if (!isNaN(cmode)) {
                subst = Stdlib.colorModeString(cmode);
              }
            }
            if (!subst && self._mode) {
              subst = self._mode;
            }
          }
          break;
        case 'P':
          if (doc) {
            var lvl = $.level;
            try {
              $.level = 0;
              subst = doc.colorProfileName;
            } catch (e) {
              subst = '';
            }
            $.level = lvl;
          } else if (xmp) {
            subst = self.get('${XMP:ICCProfile}');
            if (!subst && self._profile) {
              subst = self._profile;
            }
          }
          break;
        case 'R':
          if (doc) {
            subst = doc.resolution;
          } else if (xmp) {
            subst = self.get('${XMP:XResolution}');
            if (!subst && self._resolution) {
              subst = self._resolution;
            }
          }
          break;
        case 'B':
          if (doc) {
            var bpc = doc.bitsPerChannel;
            if (bpc == BitsPerChannelType.ONE) {
              subst = "1";
            } else if (bpc == BitsPerChannelType.EIGHT) {
              subst = "8";
            } else if (bpc == BitsPerChannelType.SIXTEEN) {
              subst = "16";
            } else if (bpc == BitsPerChannelType.THIRTYTWO) {
              subst = "32";
            } else {
              Error.runtimeError(9001, "Bad bits per channel value");
            }
          } else if (xmp) {
            // BitDepth
            if (self._bitDepth) {
              subst = self._bitDepth;
            } else {
              var bpc = self.get("${XMP:BitsPerSample}");
              if (bpc) {
                var m = bpc.match(/d+/);
                if (m) {
                  subst = m[0];
                }
              } else  {
                subst = "8";  // just as a default
              }
            }
          }
          break;
        case 'I':
          if (doc || xmp) {
            var doFormat = true;
            if (ieTag.startsWith('-')) {
              doFormat = false;
              ieTag = ieTag.substring(1);
            }
            subst = self.get("${IPTC:" + ieTag + '}') || '';
            if (subst) {
              try {
                var itag = ieTag.toLowerCase();
                if (itag == "creationdate" && doFormat) {
                  var date = IPTC.DocumentInfoStringToDate(subst);
                  if (date) {
                    subst = self.formatDate(date, dateFormat);
                  }
                } else if (itag == "urgency") {
                  if (subst.toString().startsWith("Urgency.")) {
                    subst = Stdlib.urgencyString(subst);
                  }
                } else if (itag == "copyrighted") {
                  if (subst.toString().startsWith("CopyrightedType.")) {
                    subst = Stdlib.copyrightedString(subst);
                  }
                }
              } catch (e) {
              }
            }
          }
          break;
        case 'E':
          // md = new Metadata(doc); md.strf("%E{GPSLongitude}")
          if (doc || xmp) {
            var doFormat = true;
            if (ieTag.startsWith('-')) {
              doFormat = false;
              ieTag = ieTag.substring(1);
            }
            subst = self.get("${EXIF:" + ieTag + '}') || '';
            if (subst && doFormat) {
              if (ieTag.match(/date/i)) {
                var date = Stdlib.parseISODateString(subst);
                if (date) {
                  subst = self.formatDate(date, dateFormat);
                }
              } else if (ieTag.match(/gps/i)) {
                if (ieTag.match(/(longitude|latitude)/i)) {
                  subst = Stdlib.strfGPSstr(self.defaultGPSFormat, subst);
                }
              }
            }
          }
          break;
        case 'X':
          if (doc || xmp) {
            var doFormat = true;
            if (xmpTag && xmpTag.startsWith('-')) {
              doFormat = false;
              xmpTag = xmpTag.substring(1);
            }
            if (xTag && xTag.startsWith('-')) {
              doFormat = false;
              xTag = xTag.substring(1);
            }
            if (!xTag) {
              xTag = xmpSpace + ':' + xmpTag;
            }
            subst = self.get("${XMP:" + xTag + '}') || '';
            if (subst) {
              if (xTag.match(/date/i) && doFormat) {
                var date = Stdlib.parseISODateString(subst);
                if (date) {
                  subst = self.formatDate(date, dateFormat);
                }
              }
            }
          }
          break;
        case 'n':
          subst = '\n';
          break;
        case 't':
          subst = '\t';
          break;
        case ' ':
          subst = ' ';
          break;

        default:
          break;
      }
    }

    result += leftpart + subst;
    str = rightPart;
  }

  result += str;

  } catch (e) {
    Stdlib.logException(e);

  } finally {
    app.preferences = ru;
  }
  return result;
};

Metadata.strf = function(fmt, obj) {
  return new Metadata(obj).strf(fmt);
};

Metadata.test = function() {
  listProps = function(obj) {
    var s = '';
    for (var x in obj) {
      s += x + ":\t";
      try {
        var o = obj[x];
        s += (typeof o == "function") ? "[function]" : o;
      } catch (e) {
      }
      s += "\r\n";
    }
    return s;
  };

  var doc = app.activeDocument;
//   alert(new EXIF(doc).toString());
//   return;

  var md = new Metadata(doc);
  var tags = ["${EXIF:Exposure Time}",
              "${EXIF:GPS Latitude}",
              "${EXIF:ISO Speed Ratings}",
              "${IPTC:Author}"];
  var res = md.get(tags);

  alert(listProps(res));
};

//Metadata.test();

Metadata.mdTest = function() {
  var doc = app.activeDocument;
  var md = new Metadata(doc);

  var str1 = "%d %p %f %F %e %s";
  alert(md.strf(str1));

  var str2 = "%T{%y-%m-%d} %N{%D} %W %H %R %B";
  alert(md.strf(str2));

  var str3 = "%X{xap:CreateDate} %I{Author} %X{dc:format}";
  alert(md.strf(str3));
};

//md = new Metadata(doc.xmpMetadata.rawData)
//Metadata.mdTest();


"metadata.js";
// EOF

//
// XBridgeTalk.jsx
//
// $Id: XWatermark.jsx,v 1.74 2015/12/03 22:01:33 anonymous Exp $
// Copyright: (c)2008, xbytor
// License: http://www.opensource.org/licenses/bsd-license.php
// Contact: xbytor@gmail.com
//
//@show include
//
//

XBridgeTalk = function() {};

XBridgeTalk.ERROR_CODE = 9006;
XBridgeTalk.IO_ERROR_CODE = 9002;  // same as Stdlib.IO_ERROR_CODE

//
// XBridgeTalk._getSource
//   In CS2, the function 'toSource()' is broken for functions. The return
//   value includes the text of the function plus whatever else is left
//   in the file.
//   This function gets around the problem if you follow some conventions.
//   First, the function definition _must_NOT_ end with a ';'.
//   Second, the next line must contain '// EOF'
//   The result string can then be passed on to Bridge as needed.
//   ftn is the (variable) name of the function
//
XBridgeTalk._getSource = function(ftn) {
  if (XBridgeTalk.isCS2()) {
    var str = ftn.toSource();
    var len = str.indexOf("// EOF");
    return (len == -1) ? str : str.substring(0, len) + ')';
  }

  return ftn.toSource();
};

XBridgeTalk.hasBridge = function() {
  try {
    BridgeTalk;
    return true;

  } catch (e) {
    return false;
  }
};

XBridgeTalk.isCS2 = function() {
  var lvl = $.level;
  $.level = 0;
  try {
    BridgeTalk;
  } catch (e) {
    $.level = lvl;
    return false;
  }
  $.level = lvl;
  var appName = BridgeTalk.appName;
  var version = BridgeTalk.appVersion;

  if (appName == 'photoshop') {
    return app.version.match(/^9\./);
  }
  if (appName == 'bridge') {
    return version.match(/^1\./);
  }
  if (appName == 'estoolkit') {
    return version.match(/^1\./);
  }
  if (appName == 'indesign') {
    return version.match(/^4\./);
  }
  if (appName == 'golive') {
    return version.match(/^8\./);
  }
  if (appName == 'acrobat') {
    return version.match(/^7\./);
  }
  if (appName == 'helpcenter') {
    return version.match(/^1\./);
  }

  return false;
};

XBridgeTalk.isCS3 = function() {
  var lvl = $.level;
  $.level = 0;
  try {
    BridgeTalk;
  } catch (e) {
    $.level = lvl;
    return false;
  }
  $.level = lvl;
  var appName = BridgeTalk.appName;
  var version = BridgeTalk.appVersion;

  if (appName == 'photoshop') {
    return app.version.match(/^10\./);
  }
  if (appName == 'bridge') {
    return version.match(/^2\./);
  }
  if (appName == 'estoolkit') {
    return version.match(/^2\./);
  }
  if (appName == 'indesign') {
    return version.match(/^5\./);
  }
  if (appName == 'devicecentral') {
    return version.match(/^1\./);
  }
  return false;
};

XBridgeTalk.isCS4 = function() {
  var lvl = $.level;
  $.level = 0;
  try {
    BridgeTalk;
  } catch (e) {
    $.level = lvl;
    return false;
  }
  $.level = lvl;
  var appName = BridgeTalk.appName;
  var version = BridgeTalk.appVersion;

  if (appName == 'photoshop') {
    return app.version.match(/^11\./);
  }
  if (appName == 'bridge') {
    return version.match(/^3\./);
  }
  if (appName == 'estoolkit') {
    return version.match(/^3\./);
  }
  if (appName == 'indesign') {
    return version.match(/^6\./);
  }
  if (appName == 'devicecentral') {
    return version.match(/^1\./);
  }
  return false;
};

XBridgeTalk.isCS5 = function() {
  var lvl = $.level;
  $.level = 0;
  try {
    BridgeTalk;
  } catch (e) {
    $.level = lvl;
    return false;
  }
  $.level = lvl;
  var appName = BridgeTalk.appName;
  var version = BridgeTalk.appVersion;

  if (appName == 'photoshop') {
    return app.version.match(/^12\./);
  }
  if (appName == 'bridge') {
    return version.match(/^4\./);
  }
  // XXX fix this..
  if (appName == 'estoolkit') {
    return version.match(/^3\.5/);
  }

  return false;
};

XBridgeTalk.isCS6 = function() {
  var lvl = $.level;
  $.level = 0;
  try {
    BridgeTalk;
  } catch (e) {
    $.level = lvl;
    return false;
  }
  $.level = lvl;
  var appName = BridgeTalk.appName;
  var version = BridgeTalk.appVersion;

  if (appName == 'photoshop') {
    return app.version.match(/^13\./);
  }
  if (appName == 'bridge') {
    return version.match(/^5\./);
  }
  // XXX fix this..
  if (appName == 'estoolkit') {
    return version.match(/^3\.8/);
  }

  return false;
};

XBridgeTalk.log = function(msg) {
  var self = this;
  var file;

  function currentTime() {
    var date = new Date();
    var str = '';
    var timeDesignator = 'T';
    function _zeroPad(val) { return (val < 10) ? '0' + val : val; }
    str = (date.getFullYear() + '-' +
           _zeroPad(date.getMonth()+1,2) + '-' +
           _zeroPad(date.getDate(),2));
    str += (timeDesignator +
            _zeroPad(date.getHours(),2) + ':' +
            _zeroPad(date.getMinutes(),2) + ':' +
            _zeroPad(date.getSeconds(),2));
    return str;
  };

  msg = currentTime() + " - " + msg;

  if (!self.log.enabled) {
    return;
  }
  if (!self.log.filename) {
    return;
  }

  if (!self.log.fptr) {
    file = new File(self.log.filename);
    if (!file.open("e"))  {
      Error.runtimeError(XBridgeTalk.IO_ERROR_CODE,
                         "Unable to open log file(1) " +
                         file + ": " + file.error);
    }

    if (self.log.append) {
      file.seek(0, 2); // jump to the end of the file

    } else {
      file.close();
      file.length = 0;
      file.open("w");
    }

    self.log.fptr = file;

  } else {

    file = self.log.fptr;
    if (!file.open("e"))  {
      Error.runtimeError(XBridgeTalk.IO_ERROR_CODE,
                         "Unable to open log file(2) " +
                         file + ": " + file.error);
    }
    file.seek(0, 2); // jump to the end of the file
  }

  if (!$.os.match(/windows/i)) {
    file.lineFeed = "unix";
  }

  if (self.log.encoding) {
    file.encoding = self.log.encoding;
  }

  if (!file.writeln(msg)) {
    Error.runtimeError(XBridgeTalk.IO_ERROR_CODE,
                       "Unable to write to log file(3) " +
                       file + ": " + file.error);
  }

  file.close();
};
XBridgeTalk.exceptionMessage = function(e) {
  var str = '';
  var fname = (!e.fileName ? '???' : decodeURI(e.fileName));
  str += "   Message: " + e.message + '\n';
  str += "   File: " + fname + '\n';
  str += "   Line: " + (e.line || '???') + '\n';
  str += "   Error Name: " + e.name + '\n';
  str += "   Error Number: " + e.number + '\n';

  if (e.source) {
    var srcArray = e.source.split("\n");
    var a = e.line - 10;
    var b = e.line + 10;
    var c = e.line - 1;
    if (a < 0) {
      a = 0;
    }
    if (b > srcArray.length) {
      b = srcArray.length;
    }
    for ( var i = a; i < b; i++ ) {
      if ( i == c ) {
        str += "   Line: (" + (i + 1) + ") >> " + srcArray[i] + '\n';
      } else {
        str += "   Line: (" + (i + 1) + ")    " + srcArray[i] + '\n';
      }
    }
  }

  if ($.stack) {
    str += '\n' + $.stack + '\n';
  }

  return str;
};
XBridgeTalk._getPreferencesFolder = function() {
  var appData = Folder.userData;

  var folder = new Folder(appData + "/xtools");

  if (!folder.exists) {
    folder.create();
  }

  return folder;
};

XBridgeTalk.log.filename = (XBridgeTalk._getPreferencesFolder() +
                            "/xbridge.log");
XBridgeTalk.log.enabled = false;
XBridgeTalk.log.append = false;
XBridgeTalk.log.setFile = function(file, encoding) {
  XBridgeTalk.log.filename = filename;
  XBridgeTalk.log.enabled = filename != undefined;
  XBridgeTalk.log.encoding = encoding;
};

XBridgeTalk.getAppSpecifier = function(appName) {
  var rev = undefined;

//   $.level = 1; debugger;

  if (XBridgeTalk.isCS2()) {
    if (appName == 'photoshop') {
        rev = '9';
    }
    if (appName == 'bridge') {
        rev = '1';
    }
    if (appName == 'estoolkit') {
        rev = '1';
    }
    if (appName == 'golive') {
        rev = '8';
    }
    if (appName == 'acrobat') {
        rev = '7';
    }
    if (appName == 'helpcenter') {
        rev = '1';
    }
    // add other apps here
  }

  if (XBridgeTalk.isCS3()) {
    if (appName == 'photoshop') {
        rev = '10';
    }
    if (appName == 'bridge') {
        rev = '2';
    }
    if (appName == 'estoolkit') {
        rev = '2';
    }
    // add other apps here
  }

  if (XBridgeTalk.isCS4()) {
    if (appName == 'photoshop') {
        rev = '11';
    }
    if (appName == 'bridge') {
        rev = '3';
    }
    if (appName == 'estoolkit') {
        rev = '3';
    }
    // add other apps here
  }

  if (XBridgeTalk.isCS5()) {
    if (appName == 'photoshop') {
        rev = '12';
    }
    if (appName == 'bridge') {
        rev = '4';
    }
    if (appName == 'estoolkit') {
        rev = '3.5';
    }
    // add other apps here
  }

  if (XBridgeTalk.isCS6()) {
    if (appName == 'photoshop') {
        rev = '13';
    }
    if (appName == 'bridge') {
        rev = '5';
    }
    if (appName == 'estoolkit') {
        rev = '3.8';
    }
    // add other apps here
  }

  return (rev ? (appName + '-' + rev) : appName);

//   if (!prefix) {
//     return undefined;
//   }

//   var targets = BridgeTalk.getTargets(null);

//   var appSpec = undefined;
//   var rex = new RegExp('^' + prefix);

//   // find the most recent minor version
//   for (var i = 0; i < targets.length; i++) {
//     var spec = targets[i];
//     if (spec.match(rex)) {
//       appSpec = spec;
//     }
//   }
//   return appSpec;
};

XBridgeTalk.splitSpecifier = function(appSpec) {
  var rex = /([a-z]+)(_\d+)?(?:-([\d\.]+)(-[a-z]{2}_[a-z]{2})?)?/;
  var str = appSpec.toString();
  var m = str.match(rex);
  // m[1] name (required)
  // m[2] instance (opt)
  // m[3] version (opt)
  // m[4] locale (opt)
  if (!m) {
    return undefined;
  }
  var spec = {};
  spec.name = m[1];
  if (m[2]) {
    spec.instance = m[2].substr(1);
  }
  if (m[3]) {
    spec.version = m[3];
    var v = spec.version.split('.');
    spec.majorVersion = v[0];
    spec.minorVersion = (v[1] != undefined) ? v[1] : "0";
  }
  if (m[4]) {
    spec.locale = m[4].substr(1);
  }

  function specAsString() {
    var self = this;
    var str = self.name;
    if (self.instance) {
      str += '_' + self.instance;
    }
    if (self.version) {
      str += '-' + self.version;
    }
    if (self.locale) {
      str += '-' + self.locale;
    }

    return str;
  }

  spec.toString = specAsString;

  return spec;
};

XBridgeTalk.runSpecTest = function() {
  var specTest = ["photoshop",
                  "bridge-2.0",
                  "indesign_1-5.0",
                  "illustrator-13.0",
                  "illustrator-13.0-de_de",
                  ];
  var str = '';
  for (var i = 0; i < specTest.length; i++) {
    str += XBridgeTalk.splitSpecifier(specTest[i]) + '\r\n';
  }
  return str;
};


XBridgeTalk.START_DELAY = 1000;           // 2 seconds
XBridgeTalk.START_TIMEOUT = 1000 * 120;   // 2 minutes

XBridgeTalk.DEFAULT_TIMEOUT = 10;  // seconds

XBridgeTalk.ping = function(appSpec, timeout) {
  if (timeout == undefined) {
    timeout = XBridgeTalk.DEFAULT_TIMEOUT;
  }
  var bt = new BridgeTalk();
  bt.target = appSpec;
  bt.body = "var t = \'" + appSpec + "\';";
  bt.onResult = function(btObj) {
    return true;
  };
  return bt.sendSync(timeout);
};

XBridgeTalk.isRunning = function(appSpec) {
  var ok = false;

  var spec = XBridgeTalk.splitSpecifier(appSpec);
  var name = spec.name;

  spec = XBridgeTalk.getAppSpecifier(name);

  if (BridgeTalk.isRunning(spec)) {
    try {
      if (XBridgeTalk.ping(spec)) {
        ok = true;
      }

    } catch (e) {
      XBridgeTalk.log(XBridgeTalk.exceptionMessage(e));
    }

    if (!ok) {
      Error.runtimeError(XBridgeTalk.IO_ERROR_CODE,
                         "Unable to communicate with " + appSpec +
                         ". 'ping' timed out.");
    }
  } else {
    if (BridgeTalk.isRunning(name)) {
      Error.runtimeError(XBridgeTalk.IO_ERROR_CODE,
                         "Unable to communicate with " + spec +
                         ". Possible wrong version running.");
    }
  }

  return ok;
};

XBridgeTalk.startApplication = function(appSpec) {
  XBridgeTalk.log("XBridgeTalk.startApplication(" + appSpec + ")");

  if (!appSpec) {
    Error.runtimeError(19, "appSpec");
  }
  var spec = XBridgeTalk.splitSpecifier(appSpec);
  if (!spec) {
    Error.runtimeError(19, appSpec);
  }

  var appSpec = spec.toString();
  if (!XBridgeTalk.isApplicationInstalled(appSpec)) {
    Error.runtimeError(56, appSpec);
  }

  var appName = spec.name;

  if (BridgeTalk.isRunning(appSpec)) {
    var ok = false;
    try {
      if (XBridgeTalk.ping(appSpec)) {
        ok = true;
      }

    } catch (e) {
      XBridgeTalk.log(XBridgeTalk.exceptionMessage(e));
    }

    if (!ok) {
      Error.runtimeError(XBridgeTalk.IO_ERROR_CODE,
                         "Unable to communicate with " + appSpec +
                         ". Possible wrong version running.");
    }
  }

  if (!BridgeTalk.isRunning(appSpec)) {
    XBridgeTalk.log("Launching " + appSpec);
    BridgeTalk.launch(appSpec);

    var cnt = 0;
    while (!BridgeTalk.isRunning(appSpec)) {
      $.sleep(XBridgeTalk.START_DELAY);

      if ((++cnt) * XBridgeTalk.START_DELAY >= XBridgeTalk.START_TIMEOUT) {
        XBridgeTalk.log(appSpec + " failed to launch(1)");
        return false;
      }
    }

    var cnt = 0;
    var startProp = "start" + appName;
    XBridgeTalk[startProp] = false;
    var startupComplete = false;

    while (!XBridgeTalk[startProp]) {

      // fix this block
      var bt = new BridgeTalk();
      bt.target = appSpec;
      bt.body = "var t = \'" + appSpec + "\';";
      bt.onResult = function(btObj) {
        var str = ('XBridgeTalk.start' + appName + ' = true;');
        eval(str);
      };

      bt.send();
      $.sleep(XBridgeTalk.START_DELAY);
      BridgeTalk.pump();
      if ((++cnt) * XBridgeTalk.START_DELAY >= XBridgeTalk.START_TIMEOUT) {
        delete XBridgeTalk[startProp];
        XBridgeTalk.log(appSpec + " failed to launch(2)");
        return false;
      }
    }
    delete XBridgeTalk[startProp];
  }

  return true;
};

XBridgeTalk.isApplicationInstalled = function(appSpec) {
  var apps = BridgeTalk.getTargets(null);
  for (var i = 0; i < apps.length; i++) {
    if (apps[i].startsWith(appSpec)) {
      return true;
    }
  }
  return false;
};

XBridgeTalk.getBridgeSelection = function(timeout) {
  if (timeout == undefined) {
    timeout = XBridgeTalk.DEFAULT_TIMEOUT;
  }

  function getBridgeFiles() {
    var v = app.document.selections;
    var files = [];
    for (var i = 0; i < v.length; i++) {
      var t = v[i];
      if (t != undefined) { files.push(t.spec); }
    }
    return files.toSource();
  }
  // EOF

  var src = XBridgeTalk._getSource(getBridgeFiles);

  var brCode = ("function _run() {\n" +
                "  var getBridgeFiles = " + src +
                ";\n\n" +
                "  return getBridgeFiles();\n" +
                "};\n" +
                "_run();\n");

  XBridgeTalk.log("XBridgeTalk.getBridgeSelection()");

//   var _dbg = "try {\n" + brCode + "} catch (e) {\nalert(e)\n}";
//   brCode = _dbg;

  var br = "bridge";
  if (!BridgeTalk.isRunning(br)) {
    XBridgeTalk.log("Bridge is not running.");
    return undefined;
  }
  var bt = new BridgeTalk();
  bt.target = br;
  bt.body = brCode;
  var str = bt.sendSync(timeout);
  var res = str ? eval(str) : [];
  XBridgeTalk.log(res);

  return res;
};

XBridgeTalk.send = function(brCode, timeout) {
  var br = "bridge";
  if (!BridgeTalk.isRunning(br)) {
    XBridgeTalk.log("Bridge is not running.");
    return undefined;
  }
  var bt = new BridgeTalk();
  bt.target = br;
  bt.body = brCode;
  var str = bt.sendSync(timeout);
  var res = (str ? eval(str) : '');

  XBridgeTalk.log(res);

  return res;
};


//
//XBridgeTalk.getMetadata(File("/c/tmp/207.jpg"))
//
XBridgeTalk.getMetadata = function(files, timeout) {
  // $.level = 1; debugger;

  if (!timeout) {
    timeout = XBridgeTalk.DEFAULT_TIMEOUT;
  }

  if (XBridgeTalk.isCS2()) {
    Error.runtimeError(XBridgeTalk.ERROR_CODE,
                       "XBridgeTalk.getMetadata does not work in CS2");
  }

  var isFile = false;
  if (!(files instanceof Array)) {
    if (!(files instanceof File)) {
      Error.runtimeError(19, files);
    }
    files = [files];
    isFile = true;
  }

  function getMetadata(files) {
    var mds = [];
    for (var i = 0; i < files.length; i++) {
      var t = new Thumbnail(files[i]);
      mds.push(t.synchronousMetadata.serialize());
    }
    return mds.toSource();
  }

  var src = getMetadata.toSource();

  var brCode = ("function _run(files) {\n" +
                 "  var getMetadata = " + src + ";\n\n" +
                 "  return getMetadata(files);\n" +
                "};\n" +
                "_run(" + files.toSource() + ");\n");

  XBridgeTalk.log("XBridgeTalk.getMetadata()");

  var br = "bridge";
  if (!BridgeTalk.isRunning(br)) {
    XBridgeTalk.log("Bridge is not running.");
    return undefined;
  }
  var bt = new BridgeTalk();
  bt.target = br;
  bt.body = brCode;
  var str = bt.sendSync(timeout);
  var res = (str ? eval(str) : '');

  XBridgeTalk.log(res);

  return ((isFile && res && res.length == 1) ? res[0] : res);
};

//
//XBridgeTalk.getBitDepth(File("/c/tmp/207.jpg"))
//XBridgeTalk.getBitDepth(doc.fullName);
//
XBridgeTalk.getBitDepth = function(files, timeout) {
  if (!timeout) {
    timeout = XBridgeTalk.DEFAULT_TIMEOUT;
  }

  if (XBridgeTalk.isCS2()) {
    Error.runtimeError(XBridgeTalk.ERROR_CODE,
                       "XBridgeTalk.getMetadata does not work in CS2");
  }

  var isFile = false;
  if (!(files instanceof Array)) {
    if (!(files instanceof File)) {
      Error.runtimeError(19, files);
    }
    files = [files];
    isFile = true;
  }

  function getBitDepth(files) {
    var bds = [];
    for (var i = 0; i < files.length; i++) {
      var t = new Thumbnail(files[i]);
      app.synchronousMode = true;
      t.core.preview.preview;
      app.synchronousMode = false;
      bds.push(t.core.quickMetadata.bitDepth);
    }

    return (bds.length == 1) ? bds[0] : bds.toSource();
  }

  var brCode = ("function _run(files) {\n" +
                 "  var getBitDepth = " + getBitDepth.toSource() + ";\n\n" +
                 "  return getBitDepth(files);\n" +
                "};\n" +
                "_run(" + files.toSource() + ");\n");

  XBridgeTalk.log("XBridgeTalk.getBitDepth()");

  var res = XBridgeTalk.send(brCode, timeout);

  XBridgeTalk.log(res);

  return ((isFile && res && res.length == 1) ? res[0] : res);
};

//
//XBridgeTalk.getKeywords(File("/c/tmp/207.jpg"))
//
XBridgeTalk.getKeywords = function(files, timeout) {
  if (!timeout) {
    timeout = XBridgeTalk.DEFAULT_TIMEOUT;
  }

  var isFile = false;
  if (!(files instanceof Array)) {
    if (!(files instanceof File)) {
      Error.runtimeError(19, files);
    }
    files = [files];
    isFile = true;
  }

  function getKeywordsBR(files) {
    function _getKeywords(md) {
      var kwds = [];
      var ns = md.namespace;
      md.namespace = 'http://ns.adobe.com/photoshop/1.0/';
      try {
        for (var i = 0; i < md.Keywords.length; ++i) {
          kwds.push(md.Keywords[i]);
        }
      } finally {
        md.namespace = ns;
      }
      return kwds;
    }
    try {
      var res = [];
      for (var i = 0; i < files.length; i++) {
        var file = files[i];
        var th = new Thumbnail(file);
        var md = th.synchronousMetadata;
        var kwds = _getKeywords(md);
        var obj = {
          filename: file.absoluteURI,
          keywords: kwds
        };
        res.push(obj);
      }

      return res.toSource();

    } catch (e) {
      var msg = "Internal error (getKeywordsBR): " + Stdlib.exceptionMessage(e);
      alert(msg);
      Stdlib.log(msg);
      // $.level = 1; debugger;
      return [];
    }
  }
  // EOF

  var src = XBridgeTalk._getSource(getKeywordsBR);

  var brCode = ("function _run(files) {\n" +
                "  var getKeywordsBR = " + src +  ";\n\n" +
                "  return getKeywordsBR(files);\n" +
                "};\n" +
                "_run(" + files.toSource() + ");\n");

  var _dbg = ("$.writeln('parse OK'); try {\n" + brCode + "} " +
              "catch (e) {\nalert(e)\n}");

  // brCode = _dbg;

  XBridgeTalk.log("XBridgeTalk.getKeywords(" + files + ", " + timeout + ")");

  var str = XBridgeTalk.send(brCode, timeout);

  var res = (str ? eval(str) : []);

  XBridgeTalk.log("XBridgeTalk.getKeywords => " + res);

  return ((isFile && res && res.length == 1) ? res[0].keywords : res);
};

//
//XBridgeTalk.getMetadataValue(File("/c/tmp/207.jpg"),"photoshop:City");
//
XBridgeTalk.getMetadataValue = function(files, name, timeout) {
  if (!timeout) {
    timeout = XBridgeTalk.DEFAULT_TIMEOUT;
  }

  var isFile = false;

  if (!(files instanceof Array)) {
    if (!(files instanceof File)) {
      Error.runtimeError(19, files);
    }
    files = [files];
    isFile = true;
  }

  //
  // the bs bs in the getMetadata function has to do with the fact
  // that getting \ characters correctly to Bridge via BridgeTalk
  // is busted. RegExp literals appear to be busted, too.
  //
  function getMetadata(files, cname) {
    var res = [];
    try {
      var bs = '\\'.charCodeAt(0);
      var bsCh = String.fromCharCode(bs);
      var rexStr = "^(.*" + bsCh + "/)([^" + bsCh + "/]+)$";
      var rex = RegExp(rexStr);
      var m = cname.match(rex);
      var ns = m[1];
      var pname = m[2];
      for (var i = 0; i < files.length; i++) {
        var th = new Thumbnail(files[i]);
        var md = th.synchronousMetadata;
        md.namespace = ns;
        res.push(md[pname]);
      }
    } catch (e) {
      alert(e);
    }
    return res.toSource();
  }
  // EOF

  var src = XBridgeTalk._getSource(getMetadata);

  var cname = XMPNameSpaces.getCanonicalName(name);
  if (!cname) {
    Error.runtimeError(XBridgeTalk.ERROR_CODE,
                       "Invalid metadata name: " + name);
  }

  var brCode = ("function _run(files, name, value) {\n" +
                "  var getMetadata = " + src + ";\n\n" +
                "  return getMetadata(files, name);\n" +
                "};\n" +
                "_run(" + files.toSource() + ", " + cname.toSource() + ");\n");

  var _dbg = ("$.writeln('parse OK'); try {\n" + brCode + "} " +
              "catch (e) {\nalert(e)\n}");

  // brCode = "$.writeln('parse OK');";

  XBridgeTalk.log("XBridgeTalk.getMetadata()");

  var res = XBridgeTalk.send(brCode, timeout);

  XBridgeTalk.log(res);

  return ((isFile && res && res.length == 1) ? res[0] : res);
};

//
//XBridgeTalk.getMetadataValues(File("/c/tmp/207.jpg"),["photoshop:City"]);
//
XBridgeTalk.getMetadataValues = function(file, names, timeout) {
  if (!timeout) {
    timeout = XBridgeTalk.DEFAULT_TIMEOUT;
  }

  if (!(file instanceof File)) {
    Error.runtimeError(19, files);
  }

  //
  // the bs bs in the getMetadata function has to do with the fact
  // that getting \ characters correctly to Bridge via BridgeTalk
  // is busted. RegExp literals appear to be busted, too.
  //
  function getMetadata(file, cnames, prefixedNames) {
    var res = {};

    try {
      var th = new Thumbnail(file);
      var md = th.synchronousMetadata;
      var bs = '\\'.charCodeAt(0);
      var bsCh = String.fromCharCode(bs);
      var rexStr = "^(.*" + bsCh + "/)([^" + bsCh + "/]+)$";
      var rex = RegExp(rexStr);

      for (var i = 0; i < cnames.length; i++) {
        var cname = cnames[i];
        var m = cname.match(rex);
        var ns = m[1];
        var pname = m[2];
        md.namespace = ns;
        var nm = prefixedNames[i];
        var v = md[pname];
        if (v instanceof Array && v.length == 1) {
          res[nm] = v[0];
        } else {
          res[nm] =v;
        }
      }
    } catch (e) {
      alert(e);
    }
    return res.toSource();
  }
  // EOF

  var src = XBridgeTalk._getSource(getMetadata);

  var cnames = [];
  var pnames = [];
  for (var i = 0; i < names.length; i++) {
    var name = names[i];
    var cname = XMPNameSpaces.getCanonicalName(name);
    if (!cname) {
      Error.runtimeError(XBridgeTalk.ERROR_CODE,
                         "Invalid metadata name: " + name);
    }
    cnames.push(cname);
    if (name instanceof QName) {
      pnames[i] = XMPNameSpaces.convertQName(name);
    } else {
      pnames[i] = name;
    }
  }

  var brCode = ("function _run(file, names, prefixes) {\n" +
                "  var getMetadata = " + src + ";\n\n" +
                "  return getMetadata(file, names, prefixes);\n" +
                "};\n" +
                "_run(" + file.toSource() + ", " + cnames.toSource() +
                ", " + pnames.toSource() + ");\n");

  var _dbg = ("$.writeln('parse OK'); try {\n" + brCode + "} " +
              "catch (e) {\nalert(e)\n}");
//   brCode = _dbg;

  XBridgeTalk.log("XBridgeTalk.getMetadataValues()");

  var res = XBridgeTalk.send(brCode, timeout);

  XBridgeTalk.log(res);

  return res;
};

//
//XBridgeTalk.setMetadataValue(File("/c/tmp/207.jpg"),"photoshop:City","NYC");
//
XBridgeTalk.setMetadataValue = function(files, name, value, timeout) {
  if (!timeout) {
    timeout = XBridgeTalk.DEFAULT_TIMEOUT;
  }

  if (!(files instanceof Array)) {
    if (!(files instanceof File)) {
      Error.runtimeError(19, files);
    }
    files = [files];
  }

  //
  // the bs bs in the setMetadata function has to do with the fact
  // that getting \ characters correctly to Bridge via BridgeTalk
  // is busted. RegExp literals appear to be busted, too.
  //
  function setMetadata(files, cname, value) {
    var rc = false;
    try {
      var bs = '\\'.charCodeAt(0);
      var bsCh = String.fromCharCode(bs);
      var rexStr = "^(.*" + bsCh + "/)([^" + bsCh + "/]+)$";
      var rex = RegExp(rexStr);
      var m = cname.match(rex);
      var ns = m[1];
      var pname = m[2];

      try {
        XMPMeta;
      } catch (e) {
        if (!ExternalObject.AdobeXMPScript) {
          ExternalObject.AdobeXMPScript = new ExternalObject('lib:AdobeXMPScript');
        }
      }
      for (var i = 0; i < files.length; i++) {
        var file = files[i];
        var xmpFile = new XMPFile(decodeURI(file.fsName), XMPConst.UNKNOWN,
                                  XMPConst.OPEN_FOR_UPDATE);
        var xmp = xmpFile.getXMP();

        if (value instanceof Array) {
          for (var j = 0; j < value.length; j++) {
            var val = value[j];
            xmp.appendArrayItem(ns, pname, val, 0, XMPConst.ARRAY_IS_ORDERED);
          }
        } else {
          xmp.deleteProperty(ns, pname);
          xmp.setProperty(ns, pname, value);
        }

        if (xmpFile.canPutXMP(xmp)) {
          xmpFile.putXMP(xmp);
        }

        xmpFile.closeFile(XMPConst.CLOSE_UPDATE_SAFELY);
      }

      rc = true;
    } catch (e) {
      alert(e);
    }
    return rc;
  }
  // EOF

  var src = XBridgeTalk._getSource(setMetadata);

  var cname = XMPNameSpaces.getCanonicalName(name);
  if (!cname) {
    Error.runtimeError(XBridgeTalk.ERROR_CODE,
                       "Invalid metadata name: " + name);
  }

  var brCode = ("function _run(files, name, value) {\n" +
                "  var setMetadata = " + src + ";\n\n" +
                "  return setMetadata(files, name, value);\n" +
                "};\n" +
                "_run(" + files.toSource() + ", " + cname.toSource() +
                ", " + value.toSource() + ");\n");

  var _dbg = ("$.writeln('parse OK'); try {\n" + brCode + "} " +
              "catch (e) {\nalert(e)\n}");
//   brCode = _dbg;

  XBridgeTalk.log("XBridgeTalk.setMetadata()");

  var res = XBridgeTalk.send(brCode, timeout);

  XBridgeTalk.log(res);

  return res;
};

//
// var obj = {};
// obj["photoshop:City"] = "NYC";
// obj["iptcCore:Provider"] = "XBytor";
//
//XBridgeTalk.setMetadataValues(File("/c/tmp/207.jpg"), obj);
//
XBridgeTalk.setMetadataValues = function(files, nvPairs, timeout) {
  if (!timeout) {
    timeout = XBridgeTalk.DEFAULT_TIMEOUT;
  }

  if (!(files instanceof Array)) {
    if (!(files instanceof File)) {
      Error.runtimeError(19, files);
    }
    files = [files];
  }

  //
  // the bs bs in the setMetadata function has to do with the fact
  // that getting \ characters correctly to Bridge via BridgeTalk
  // is busted. RegExp literals appear to be busted, too.
  //
  // nvPairs is an object that looks like
  // { 'http://ns.adobe.com/camera-raw-settings/1.0/HasSettings': 'True' }
  //
  function setMetadata(files, nvPairs) {
    var rc = false;
    try {
      var bs = '\\'.charCodeAt(0);
      var bsCh = String.fromCharCode(bs);
      var rexStr = "^(.*" + bsCh + "/)([^" + bsCh + "/]+)$";
      var rex = RegExp(rexStr);

      try {
        XMPMeta;
      } catch (e) {
        if (!ExternalObject.AdobeXMPScript) {
          ExternalObject.AdobeXMPScript = new ExternalObject('lib:AdobeXMPScript');
        }
      }

      for (var i = 0; i < files.length; i++) {
        var file = files[i];
        var xmpFile = new XMPFile(decodeURI(file.fsName), XMPConst.UNKNOWN,
                                  XMPConst.OPEN_FOR_UPDATE);
        var xmp = xmpFile.getXMP();

        for (var cname in nvPairs) {
          var value = nvPairs[cname];

          var m = cname.match(rex);
          var ns = m[1];
          var pname = m[2];

          if (value instanceof Array) {
            for (var j = 0; j < value.length; j++) {
              var val = value[j];
              xmp.appendArrayItem(ns, pname, val, 0, XMPConst.ARRAY_IS_ORDERED);
            }
          } else {
            xmp.deleteProperty(ns, pname);
            xmp.setProperty(ns, pname, value);
          }
        }

        if (xmpFile.canPutXMP(xmp)) {
          xmpFile.putXMP(xmp);
        }

        xmpFile.closeFile(XMPConst.CLOSE_UPDATE_SAFELY);
      }

      rc = true;
    } catch (e) {
      alert(e);
    }
    return rc;
  }
  // EOF

  var src = XBridgeTalk._getSource(setMetadata);

  var mdObj = {};
  for (var name in nvPairs) {
    var cname = XMPNameSpaces.getCanonicalName(name);
    if (!cname) {
      Error.runtimeError(XBridgeTalk.ERROR_CODE,
                         "Invalid metadata name: " + name);
    }

    mdObj[cname] = nvPairs[name];
  }

  var brCode = ("function _run(files, name, value) {\n" +
                "  var setMetadata = " + src + ";\n\n" +
                "  return setMetadata(files, name, value);\n" +
                "};\n" +
                "_run(" + files.toSource() + ", " + mdObj.toSource() + ");\n");

  var _dbg = ("$.writeln('parse OK'); try {\n" + brCode + "} " +
              "catch (e) {\nalert(e)\n}");
//   brCode = _dbg;

  XBridgeTalk.log("XBridgeTalk.setMetadata()");

  var res = XBridgeTalk.send(brCode, timeout);

  XBridgeTalk.log(res);

  return res;
};

//
//
//XBridgeTalk.copyMetadataValues(File("/c/tmp/207.jpg"),
//                               File("/c/tmp/208.jpg"),
//                               ["photoshop:City", "dc:creator"]);
//
XBridgeTalk.APPEND_ON_COPY = 1;  // append array items
XBridgeTalk.REMOVE_ON_COPY = 2;  // always remove existing property value
XBridgeTalk.ON_COPY_DEFAULT = XBridgeTalk.APPEND_ON_COPY;

XBridgeTalk.copyMetadataValues = function(file, dest, names, opts, timeout) {
  if (!timeout) {
    timeout = XBridgeTalk.DEFAULT_TIMEOUT;
  }

  if (opts == undefined) {
    opts = XMPTools.ON_COPY_DEFAULT;
  }

  if (!file.exists) {
    Error.runtimeError(9002, "File does not exist: " + file);
  }
  if (!dest.exists) {
    Error.runtimeError(9002, "File does not exist: " + dest);
  }
  if (!names || names.length == 0) {
    return false;
  }

  for (var i = 0; i < names.length; i++) {
    var name = names[i];
    if (name instanceof QName) {
      continue;
    }

    if (name.constructor == String) {
      var ar = name.split(':');
      if (ar.length == 2) {
        names[i] = XMPNameSpaces.getQName(name);
        continue;
      }
    }
    Error.runtimeError(9002, "Bad metadata descriptor: " + name);
  }

  //
  // the bs bs in the setMetadata function has to do with the fact
  // that getting \ characters correctly to Bridge via BridgeTalk
  // is busted. RegExp literals appear to be busted, too.
  //
  // nvPairs is an object that looks like
  // { 'http://ns.adobe.com/camera-raw-settings/1.0/HasSettings': 'True' }
  //
  function copyMetadata(file, dest, names, opts) {
    function copyProperties(src, dest, qnames, opts) {
      for (var i = 0; i < qnames.length; i++) {
        var qname = qnames[i];
        var ns = qname.uri;
        var name = qname.localName;

        var prop = src.getProperty(ns, name);
        if (!prop) {
          continue;
        }
        dest.deleteProperty(ns, name);
        XMPUtils.duplicateSubtree(src, dest, ns, name, ns, name);
      }
    };

    var rc = false;
    try {
      try {
        XMPMeta;
      } catch (e) {
        if (!ExternalObject.AdobeXMPScript) {
          ExternalObject.AdobeXMPScript = new ExternalObject('lib:AdobeXMPScript');
        }
      }
      for (var i = 0; i < names.length; i++) {
        var name = names[i];
        if (name instanceof QName) {
          continue;
        }
        /*
        if (name.constructor == String) {
          var ar = name.split(':');
          if (ar.length != 2) {
            alert("Bad Metatdata descriptor: " + name);
            continue;
          }
        }
         */
        if (typeof name == "object") {
          names[i] = new QName(name.uri, name.localName);
          continue;
        }
        alert("Bad Metatdata descriptor: " + name);
      }

      var srcXMP = new XMPFile(decodeURI(file.fsName), XMPConst.UNKNOWN,
                               XMPConst.OPEN_FOR_READ).getXMP();

      var xmpFile = new XMPFile(decodeURI(dest.fsName), XMPConst.UNKNOWN,
                                XMPConst.OPEN_FOR_UPDATE);
      var xmp = xmpFile.getXMP();

      copyProperties(srcXMP, xmp, names, opts);

      if (xmpFile.canPutXMP(xmp)) {
        xmpFile.putXMP(xmp);
      }

      xmpFile.closeFile(XMPConst.CLOSE_UPDATE_SAFELY);

      rc = true;

    } catch (e) {
      alert(e);

      try { if (xmpFile) xmpFile.closeFile(); } catch (e) {}
    }

    return rc;
  }
  // EOF

  var src = XBridgeTalk._getSource(copyMetadata);

  var brCode = ("function _run(src, dest, names, opts) {\n" +
                "  var copyMetadata = " + src + ";\n\n" +
                "  return copyMetadata(src, dest, names, opts);\n" +
                "};\n" +
                "_run(" + file.toSource() + ", " + dest.toSource() + ", " +
                names.toSource() + ", " + opts.toSource() + ");\n");

  var _dbg = ("$.writeln('parse OK'); try {\n" + brCode + "} " +
              "catch (e) {\nalert(e)\n}");
  //brCode = _dbg;

  //brCode = "$.writeln('testing');";

  XBridgeTalk.log("XBridgeTalk.copyMetadata()");

  var res = XBridgeTalk.send(brCode, timeout);

  XBridgeTalk.log(res);

  return res;
};

//
//XBridgeTalk.chooseMenuItem("CRClear", File("/c/tmp/207.jpg"))
//
XBridgeTalk.chooseMenuItem = function(menuItem, files, timeout) {
  if (!timeout) {
    timeout = XBridgeTalk.DEFAULT_TIMEOUT;
  }

  if (!(files instanceof Array)) {
    if (!(files instanceof File)) {
      Error.runtimeError(19, files);
    }
    files = [files];
  }

  function applyMenuItem(menuItem, files) {
    try {
      /* we only want to select the files we want to operate on */
      app.document.deselectAll();

      for (var i = 0; i < files.length; i++) {
        var th = new Thumbnail(files[i]);

        app.document.select(th);
      }

      /* now choose the menu item for all of the selected files */
      app.document.chooseMenuItem(menuItem);

    } catch (e) {
      alert(e + '@' + e.line);
    }

    return true;
  }
  // EOF

  var src = applyMenuItem.toSource();

  var brCode = ("function _run(menuItem, files) {\n" +
                "  var applyMenuItem = " + src + ";\n\n" +
                "  return applyMenuItem(menuItem, files);\n" +
                "};\n" +
                "_run(\"" + menuItem + "\", " + files.toSource() + ");\n");

  XBridgeTalk.log("XBridgeTalk.applyMenuItem()");

  var res = XBridgeTalk.send(brCode, timeout);

  XBridgeTalk.log(res);

  return res;
};

XBridgeTalk._init = function() {
  if (!XBridgeTalk.hasBridge()) {
    Error.runtimeError(XBridgeTalk.ERROR_CODE,
                       "This application does not support Bridge");
  }

  BridgeTalk.prototype.sendSync = function(timeout) {
    XBridgeTalk.log("BridgeTalk.sendSync(" + timeout + ")");

    var self = this;

    //if (isCS3() || isCS4) {
    //  return this.send(timeout);
    //}

    self.onResult = function(res) {
      // $.writeln('onResult');
      this.result = res.body;
      this.complete = true;
    };
    self.complete = false;
    self.result = undefined;

    self.send();

    // ??? fix this so that its a doubling decay timeout
    if (timeout) {
      for (var i = 0; i < timeout; i++) {
        var rc = BridgeTalk.pump();       // process any outstanding messages
        // $.writeln(rc);
        if (!self.complete) {
          $.sleep(1000);
        } else {
          break;
        }
      }
    }

    var res = self.result;
    self.result = self.complete = self.onResult = undefined;

    XBridgeTalk.log("BridgeTalk.sendSync => " + res);

    return res;
  };

  BridgeTalk.prototype.sendSynch = BridgeTalk.prototype.sendSync;
};
XBridgeTalk._init();

XBridgeTalk.test = function() {
  var br = "bridge";
  if (!br) {
    alert("Bridge not installed");
    return;
  }
  if (!XBridgeTalk.isRunning(br)) {
    alert("Bridge is not running. Starting now...");
    if (!XBridgeTalk.startApplication(br)) {
      alert("Failed to launch " + br);
      return;
    }
    alert("Bridge started");
  }

  var bt = new BridgeTalk();
  bt.target = br;
  bt.body = "new Date().toString()";
  var res = bt.sendSync(10);
  alert(res);

  alert(XBridgeTalk.getBridgeSelection());

  //XBridgeTalk.getMetadata(File("/c/tmp/207.jpg"))
  //XBridgeTalk.getBitDepth(File("/c/tmp/207.jpg"))
  //XBridgeTalk.getBitDepth(doc.fullName);
  //XBridgeTalk.getKeywords(File("/c/tmp/207.jpg"))
  //XBridgeTalk.setMetadataValue(File("/c/tmp/207.jpg"),"photoshop:City","NYC");

  // obj = {};
  // obj["photoshop:City"] = "Antwerp";
  // obj["iptcCore:Provider"] = "XBytor";
  // XBridgeTalk.setMetadataValues(File("/c/tmp/207.jpg"), obj);
};

//XBridgeTalk.test();

"xbridge.jsx";
// EOF


//
// PreviewWindow
//
// $Id: XWatermark.jsx,v 1.74 2015/12/03 22:01:33 anonymous Exp $
// Copyright: (c)2008, xbytor
// License: http://www.opensource.org/licenses/bsd-license.php
// Contact: xbytor@gmail.com
//

// All values are in pixels

PreviewWindow = function() {
};
PreviewWindow.MAX_WIDTH = 1024;
PreviewWindow.MAX_HEIGHT = 1024;
PreviewWindow.DELTA_H = 200;

PreviewWindow.getPrimaryScreenSize = function() {
  var scrs = $.screens;

  for (var i = 0; i < scrs.length; i++) {
    var scr = scrs[i];
    if (scr.primary == true) {
      return [scr.right-scr.left, scr.bottom-scr.top];
    }
  }

  return undefined;
};

// Returns a valid File object
PreviewWindow._checkFile = function(file) {
  if (!file) {
    return undefined;
  }
  if (file.constructor == String) {
    file = new File(file);
  }
  if (!(file instanceof File)) {
    return undefined;
  }
  if (!file.exists) {
    return undefined;
  }

  return file;
};

PreviewWindow.open = function(file, w, h, title, ms, parent) {
  file = PreviewWindow._checkFile(file);

  if (!file) {
    return;
  }

  if (!w) {
    w = PreviewWindow.MAX_WIDTH;
  }
  if (!h) {
    var size = PreviewWindow.getPrimaryScreenSize();
    h = Math.min(PreviewWindow.MAX_HEIGHT, size[1]-PreviewWindow.DELTA_H);
  }

  var doc = app.open(file);

  var resized = false;
  if (doc.width.as("px") > w || doc.height.as("px") > h) {
    function cTID(s) { return app.charIDToTypeID(s); };
    function sTID(s) { return app.stringIDToTypeID(s); };

    var desc = new ActionDescriptor();
    desc.putUnitDouble( cTID('Wdth'), cTID('#Pxl'), w );
    desc.putUnitDouble( cTID('Hght'), cTID('#Pxl'), h );

    var fitId = sTID('3caa3434-cb67-11d1-bc43-0060b0a13dc4');
    executeAction(fitId , desc, DialogModes.NO );
    resized = true;
  }

  w = doc.width.as("px");
  h = doc.height.as("px");

  var remove = false;
  if (resized || !file.name.match(/.png$/i)) {
    remove = true;
    file = new File(Folder.temp + "/preview.png");
    file.remove();

    doc.saveAs(file, new PNGSaveOptions(), true);
  }

  doc.close(SaveOptions.DONOTSAVECHANGES);

  PreviewWindow.openFile(file, w, h, title, ms, parent);

  if (remove) {
    file.remove();
  }
};

PreviewWindow.openFile = function(file, w, h, title, ms, parent) {
  var type = (ms > 0) ? 'palette' : 'dialog';
  var win = new Window(type, title || "Preview: " + decodeURI(file.name));

  win.closeBtn = win.add('button', undefined, 'Close');
  win.preview = win.add('image', undefined);
  win.preview.icon = file;

  if (w && h) {
    win.preview.preferredSize = [w, h];
  }

  if (parent) {
    win.center(parent);
  }

  win.closeBtn.onClick = function() {
    this.parent.close(1);
  }

  win.show();
  if (ms > 0) {
    $.sleep(ms);
  }

  delete win;
  $.gc();
};


PreviewWindow.main = function() {
  PreviewWindow.open("~/Desktop/test.jpg");

  PreviewWindow.open("~/Desktop/test.jpg", undefined, undefined,
                     "Preview Test", 3000);
};

// PreviewWindow.main();

"PreviewWindow.jsx";
// EOF

//
// Styles
//   This file contains a variety of functions for working with styles and,
//   in particular, layer styles.
//
// Functions:
//   getLayerStyleDescriptor(doc, layer) does work although it may need more
//                                       extensive testing.
//   setLayerStyleDescriptor(doc, layer, dec) does NOT yet work. See note below
//
//   newStyle(name)
//   loadStyles(file)
//   saveAllStyles(file)
//   saveStyle(file, index)
//   saveCurrentStyle(file)
//   deleteStyle(index)
//   getPresetManager()
//   getPresets()
//
// $Id: XWatermark.jsx,v 1.74 2015/12/03 22:01:33 anonymous Exp $
// Copyright: (c)2005, xbytor
// License: http://www.opensource.org/licenses/bsd-license.php
// Contact: xbytor@gmail.com
//
//@show include
//
//

Styles = function() {};
Styles.TEMP_NAME = "$$$TempStyle";
Styles.TEMP_FOLDER = Folder.temp;  // Folder.temp;

/* new layer style */
Styles.newStyle = function(name) {
  function _ftn() {
    var desc = new ActionDescriptor();
    var ref = new ActionReference();
    ref.putClass( PSKey.Style );
    desc.putReference( cTID('null'), ref );
    desc.putString( PSKey.Name, name );
    var lref = new ActionReference();
    lref.putEnumerated( PSClass.Layer, PSType.Ordinal, PSEnum.Target );
    desc.putReference( PSKey.Using, lref );
    desc.putBoolean( PSString.blendOptions, true );
    desc.putBoolean( PSClass.LayerEffects, true );
    executeAction( PSEvent.Make, desc, DialogModes.NO );
  }

  _ftn();
};

/* load styles file */
Styles.loadStyles = function(file) {
  function _ftn() {
    var desc = new ActionDescriptor();
    var ref = new ActionReference();
    ref.putProperty( PSClass.Property, PSKey.Style );
    ref.putEnumerated( PSClass.Application, PSType.Ordinal, PSEnum.Target );
    desc.putReference( cTID('null'), ref );
    desc.putPath( PSKey.To, file);
    desc.putBoolean( PSKey.Append, true);
    executeAction( PSEvent.Set, desc, DialogModes.NO );
  }

  _ftn();
};

/* save all styles */
Styles.saveAllStyles = function(file) {
  function _ftn() {
    var desc125 = new ActionDescriptor();
    desc125.putPath( cTID('null'), file);
    var ref128 = new ActionReference();
    ref128.putProperty( PSClass.Property, PSKey.Style );
    ref128.putEnumerated( PSClass.Application, PSType.Ordinal, PSEnum.Target );
    desc125.putReference( PSKey.To, ref128 );
    executeAction( PSEvent.Set, desc125, DialogModes.NO );
  }

  _ftn();
};

/* save style to file */
Styles.saveStyle = function(file, index) {

  if (file.exists) {
    file.remove();
  }

  function _ftn() {
    var desc = new ActionDescriptor();
    desc.putPath( cTID('null'), file);
    var list = new ActionList();
    var ref = new ActionReference();
    ref.putIndex( PSKey.Style, index + 1);
    list.putReference( ref );
    desc.putList( PSKey.To, list );
    executeAction( PSEvent.Set, desc, DialogModes.NO );
  }

  _ftn();
};

Styles.saveCurrentStyle = function(file) {
  var idx = Styles.getPresets().length;

  Styles.newStyle(Styles.TEMP_NAME);
  Styles.saveStyle(file, idx);
  Styles.deleteStyle(idx);
};

/* delete style by index */
Styles.deleteStyle = function(index) {
  function _ftn() {
    var desc = new ActionDescriptor();
    var list = new ActionList();
    var ref = new ActionReference();
    ref.putIndex( PSKey.Style, index + 1);
    list.putReference( ref );
    desc.putList( cTID('null'), list );
    executeAction( PSEvent.Delete, desc, DialogModes.NO );
  }

  _ftn();
};

Styles.getPresetManager = function() {
  var classApplication = cTID('capp');
  var typeOrdinal      = cTID('Ordn');
  var enumTarget       = cTID('Trgt');

  var ref = new ActionReference();
  ref.putEnumerated(classApplication, typeOrdinal, enumTarget);

  var appDesc = app.executeActionGet(ref);
  return appDesc.getList(sTID('presetManager'));
};

Styles.getPresets = function() {
  var styleKey = cTID('StyC');
  var names = [];

  var mgr = Styles.getPresetManager();
  var max = mgr.count;

  for (var i = 0; i < max; i++) {
    var objType = mgr.getObjectType(i);
    if (objType == styleKey) {
      break;
    }
  }

  if (i != max) {
    var preset = mgr.getObjectValue(i);
    var list = preset.getList(cTID('Nm  '));
    var max = list.count;
    for (var i = 0; i < max; i++) {
      var str = list.getString(i);
      names.push(str);
    }
  }

  return names;
};

Styles.loadTypeIDs = function () {
  var needsDefs = true;
  var lvl = $.level;
  $level = 0;
  try {
    PSClass;
    needsDefs = false;
  } catch (e) {
  }
  $.level = lvl;

  cTID = function(s) { return app.charIDToTypeID(s); };
  sTID = function(s) { return app.stringIDToTypeID(s); };
  xTID = function(s) {
    if (s.constructor == Number) {
      return s;
    }
    if (s.constructor == String) {
      if (s.length != 4) return sTID(s);
      try { return cTID(s); } catch (e) { return sTID(s); }
    }
    throw "Bad typeid: " + s;
  };

  if (needsDefs) {
    PSClass  = function() {};
    PSEnum   = function() {};
    PSEvent  = function() {};
    PSForm   = function() {};
    PSKey    = function() {};
    PSType   = function() {};
    PSUnit   = function() {};
    PSString = function() {};
  }

  PSClass.Application = cTID('capp');
  PSClass.Layer = cTID('Lyr ');
  PSClass.LayerEffects = cTID('Lefx');
  PSClass.Property = cTID('Prpr');
  PSClass.Document = cTID('Dcmn');
  PSClass.FileInfo = cTID("FlIn");
  PSEnum.Scale = cTID('Scl ');
  PSEnum.Target = cTID('Trgt');
  PSEvent.Delete = cTID('Dlt ');
  PSEvent.Make = cTID('Mk  ');
  PSEvent.Set = cTID('setd');
  PSKey.Append = cTID('Appe');
  PSKey.FileInfo = cTID("FlIn");
  PSKey.LayerEffects = cTID("Lefx");
  PSKey.Name = cTID('Nm  ');
  PSKey.Style = cTID('Styl');
  PSKey.To = cTID('T   ');
  PSKey.Using = cTID('Usng');
  PSType.Ordinal = cTID('Ordn');
  PSUnit.Percent = cTID('#Prc');

  PSString.blendOptions = sTID('blendOptions');
  PSString.Null = cTID('null');
};

Styles.loadTypeIDs();

Styles.throwError = function(e) {
  throw e;
};
Styles.readFromFile = function(fptr) {
  var file = Styles.convertFptr(fptr);
  file.open("r") || Styles.throwError("Unable to open input file \"" +
                                      file + "\".\r" + file.error);
  file.encoding = 'BINARY';
  var str = '';
  str = file.read(file.length);
  file.close();
  return str;
};
Styles.writeToFile = function(fptr, str) {
  var file = Styles.convertFptr(fptr);
  file.open("w") || Styles.throwError("Unable to open output file \"" +
                                      file + "\".\r" + file.error);
  file.encoding = 'BINARY';
  file.write(str);
  file.close();
};
Styles.convertFptr = function(fptr) {
  var f;
  if (fptr.constructor == String) {
    f = File(fptr);
  } else if (fptr instanceof File || fptr instanceof Folder) {
    f = fptr;
  } else {
    throw "Bad file \"" + fptr + "\" specified.";
  }
  return f;
};

//
// Styles.loadDescriptor
//   This function loads information from an Layer Styles file. This only works
//   if there is a single style in the file.
//   The input parameter can either be a File or a string representation of
//      a file.
//
//   The descriptor returned has two elements:
//      FileInfo ('FlIn') contains styles palette information about the style,
//         specifically its Name and Identifier.
//      LayerEffects contains the actually Layer Style information. This is
//         the block of information that you would normally see in the
//         ScriptingListener log file whenever you add or change a layer style.
//         This descriptor can be used to set the layer style of a layer.
//
Styles.loadFileDescriptor = function(fptr) {
  var str = Styles.readFromFile(fptr);

  if (str.substring(2, 6) != "8BSL") {
    throw "File is not a Styles file.";
  }

  // trim of the file header stuff
  str = str.slice(0x14);

  // There may be extra stuff at the beginning of the file,
  // like other non-standard object definitions (like patterns).
  // This is the simplest check (for the AD format number) for that.
  if (str.charCodeAt(3) != 0x10) {

    // Now, search for a marker that would only occur in the Layer Styles Def
    var idx = str.search(/Nm  TEXT/);
    if (idx == -1) {
      throw "Layer Style not found in file";
    }
    // The beginning of the AD def is 26 characters before "Nm  TEXT"
    str = str.slice(idx - 26);
  }

  // Read in the first descriptor
  var desc = new ActionDescriptor();
  desc.fromStream(str);

  // Create a StylesFile descriptor for return
  var sfdesc = new ActionDescriptor();

  // The first AD has some styles file info, actually just the Name and ID
  sfdesc.putObject(PSClass.FileInfo, PSKey.FileInfo, desc);

  // Skip past the first AD definition
  str = str.slice(desc.toStream().length);

  // And read in the next
  desc = new ActionDescriptor();
  desc.fromStream(str);

  // if the layer style doesn't really contain anything,
  // there won't be a descriptor for it, so we don't place
  // anything in the return descriptor
  if (desc.hasKey(PSKey.LayerEffects)) {
    var lefx = desc.getObjectValue(PSKey.LayerEffects);

    // Now store the LayerEffects AD
    sfdesc.putObject(PSKey.LayerEffects, PSClass.LayerEffects, lefx);
  }

  if (desc.hasKey(PSString.blendOptions)) {
    var blndOpts = desc.getObjectValue(PSString.blendOptions);
    sfdesc.putObject(PSString.blendOptions, PSString.blendOptions, blndOpts);
  }

  // And return our manufactured AD
  return sfdesc;
};

//
// Styles.getLayerStyleDescriptor
//   Returns the LayerStyles descriptor for the specified doc/layer
//
//   This is implemented by
//      1) creating a new named style based on the current layer
//      2) saving the new style to a file
//      3) removing the named style from PS
//      4) loading the LayerStyle file descriptor
//      5) returning the LayerStyle descriptor found in the file descriptor
//
// With 'complete' set to true, it returns the entire style descriptor, including
// the file name and blend options
//
Styles.getLayerStyleDescriptor = function(doc, layer, complete) {
  var ad;
  var al;

  complete = !!complete;

  if (doc != app.activeDocument) {
    ad = app.activeDocument;
    app.activeDocument = doc;
  }

  if (layer != doc.activeLayer) {
    al = doc.activeLayer;
    doc.activeLayer = layer;
  }

  var file;
  var lsdesc = undefined;
  try {
    var idx = Styles.getPresets().length;
    file = new File(Styles.TEMP_FOLDER + '/' + Styles.TEMP_NAME + ".asl");

    Styles.newStyle(Styles.TEMP_NAME);
    Styles.saveStyle(file, idx);
    Styles.deleteStyle(idx);

    var desc = Styles.loadFileDescriptor(file);
    if (complete) {
      lsdesc = desc;
    } else if (desc.hasKey(PSKey.LayerEffects)) {
      lsdesc = desc.getObjectValue(PSKey.LayerEffects);
    }

  } catch (e) {
    alert(e.toSource().replace(/,/g, '\r'));

  } finally {
    if (file) {
      file.remove();
    }
    if (al) {
      doc.activeLayer = al;
    }
    if (ad) {
      app.activeDocument = ad;
    }
  }
  return lsdesc;
};

Styles.setLayerStyleDescriptor = function(doc, layer, lsdesc) {
  var ad;
  var al;

  if (doc != app.activeDocument) {
    ad = app.activeDocument;
    app.activeDocument = doc;
  }

  if (layer != doc.activeLayer) {
    al = doc.activeLayer;
    doc.activeLayer = layer;
  }

  try {
    var ref = new ActionReference();
    ref.putProperty(PSClass.Property, PSKey.LayerEffects);
    ref.putEnumerated(PSClass.Layer, PSType.Ordinal, PSEnum.Target);

    var desc = new ActionDescriptor();
    desc.putReference(PSString.Null, ref);

    desc.putObject(PSKey.To, PSClass.LayerEffects, lsdesc);

    executeAction(cTID('setd'), desc, DialogModes.NO);

  } catch (e) {
    alert(e.toSource().replace(/,/g, '\r'));

  } finally {
    if (al) {
      doc.activeLayer = al;
    }
    if (ad) {
      app.activeDocument = ad;
    }
  }
};

Styles.defineStyle = function(str, font, color) {
  function _styleDesc() {
    var descSet = new ActionDescriptor();
    var refProp = new ActionReference();
    refProp.putProperty( cTID('Prpr'), cTID('Lefx') );
    refProp.putEnumerated( cTID('Lyr '), cTID('Ordn'), cTID('Trgt') );
    descSet.putReference( cTID('null'), refProp );

    var descStyle = new ActionDescriptor();
    descStyle.putUnitDouble( cTID('Scl '), cTID('#Prc'), 100.000000 );
    descSet.putObject( cTID('T   '), cTID('Lefx'), descStyle );

    return descSet;
  };

  var doc = Stdlib.newDocument("New Style", "RGBM", 660, 480, 72, 16);
  doc.activeLayer.isBackgroundLayer = false;

  if (!str) {
    str = "Watermark Text";
  }

  var text = Stdlib.addTextLayer(doc, str, "Watermark", 128);

  if (!color) {
    color = Stdlib.createRGBColor(158, 158, 158);
  }
  text.textItem.color = color;
  if (font) {
    text.textItem.font = font;
  }

  var sdesc = undefined;
  var desc = _styleDesc();
  try {
    sdesc = executeAction(cTID('setd'), desc, DialogModes.ALL);

  } catch (e) {
    if (e.number != 8007) {
      throw e;
    }
  } finally {
    doc.close(SaveOptions.DONOTSAVECHANGES);
  }

  return sdesc;
};

//
//include "xlib/PSConstants.js"
//include "xlib/stdlib.js"
//include "xlib/Stream.js"
//include "xlib/Action.js"
//include "xlib/xml/atn2xml.jsx"

Styles.testXML = function(desc) {
  // if you want to dump the XML for a layer styles descriptor
  // fix up the include directives above and make a call like this:
  Stdlib.writeToFile("~/LayerStyle.xml", desc.toXML());
};


Styles.test = function() {
  var doc = app.activeDocument;

// this is some leftover test code. Leave it here for now.
//  $.level = 1; debugger;
//   Styles.saveCurrentStyle(new File("/c/work/Blank.asl"));
//   return;

//   var desc = Styles.loadFileDescriptor("/c/work/Blank.asl");
//   var sdesc = desc.getObjectValue(PSKey.LayerEffects);
//   Styles.writeToFile("/c/work/b2.bin", gdesc.toStream());

  var layer0 = doc.artLayers[0];
  var gdesc = Styles.getLayerStyleDescriptor(doc, layer0);

  if (!gdesc) {
    alert("There is no layer style associated with the layer");
    return;
  }

//   this will set the layer style to another layer.
//   var layer1 = doc.artLayers[1];
//   Styles.setLayerStyleDescriptor(doc, layer1, gdesc);

  if (!gdesc.hasKey(cTID('FrFX'))) {  // look for a stroke effect
    return;
  }
  var frfx = gdesc.getObjectValue(cTID('FrFX'));
  if (!frfx.hasKey(cTID('Clr '))) {   // look for the color
    return;
  }
  var clr = frfx.getObjectValue(cTID('Clr '));
  // we should really check that the objectType is RGBC
  var r = clr.getDouble(cTID('Rd  '));
  var g = clr.getDouble(cTID('Grn '));
  var b = clr.getDouble(cTID('Bl  '));
  if (r == 0 && g == 0xFF && b == 0xFF) {
    return;
  }
  clr.putDouble(cTID('Rd  '), 0);
  clr.putDouble(cTID('Grn '), 0xFF);
  clr.putDouble(cTID('Bl  '), 0xFF);

  frfx.putObject(cTID('Clr '), cTID('RGBC'), clr);
  gdesc.putObject(cTID('FrFX'), cTID('FrFX'), frfx);

  Styles.setLayerStyleDescriptor(doc, layer0, gdesc);
};

//Styles.test();

"Styles.jsx";
// EOF

//
// PSCCFontSizeFix.jsx
//   setFontSizePoints
//   setFontSizePixels
//
// This file contains a couple of functions that work around
// a bug in PSCC+ that prevents setting the size of the font
// for text layer via the DOM. There is also a test function
// provided.
// 
// NOTE: This function will bash both the font typeface and
//       contents of thelayer so it's best to use it right
//       after creating the layer.
//
// $Id: XWatermark.jsx,v 1.74 2015/12/03 22:01:33 anonymous Exp $
// Copyright: (c)2014, xbytor
// License: http://www.opensource.org/licenses/bsd-license.php
// Contact: xbytor@gmail.com
//

PSCCFontSizeFix = {
};

PSCCFontSizeFix.setFontSizePoints = function(layer, pt) {
  function cTID(s) { return app.charIDToTypeID(s); };
  function sTID(s) { return app.stringIDToTypeID(s); };

  var magicNumber = cTID("0042");

  var desc23 = new ActionDescriptor();  

    var ref6 = new ActionReference();  
    ref6.putProperty( cTID('Prpr'), cTID('TxtS') );  
    ref6.putEnumerated( cTID('TxLr'), cTID('Ordn'), cTID('Trgt') );  
  desc23.putReference( cTID('null'), ref6 );  

    var desc24 = new ActionDescriptor();  
    desc24.putInteger( sTID('textOverrideFeatureName'), magicNumber );  
   desc24.putInteger( sTID('typeStyleOperationType'), 3 );  
    desc24.putUnitDouble( cTID('Sz  '), cTID('#Pnt'), pt );  
  desc23.putObject( cTID('T   '), cTID('TxtS'), desc24 );
 
  executeAction( cTID('setd'), desc23, DialogModes.NO );  
  return;

};
PSCCFontSizeFix.setFontSizePixels = function(layer, px) {
  function cTID(s) { return app.charIDToTypeID(s); };
  function sTID(s) { return app.stringIDToTypeID(s); };

  var magicNumber = cTID("0042");

  var desc23 = new ActionDescriptor();  

    var ref6 = new ActionReference();  
    ref6.putProperty( cTID('Prpr'), cTID('TxtS') );  
    ref6.putEnumerated( cTID('TxLr'), cTID('Ordn'), cTID('Trgt') );  
  desc23.putReference( cTID('null'), ref6 );  

    var desc24 = new ActionDescriptor();  
    desc24.putInteger( sTID('textOverrideFeatureName'), magicNumber );  
    desc24.putInteger( sTID('typeStyleOperationType'), 3 );  
    desc24.putUnitDouble( cTID('Sz  '), cTID('#Pxl'), px );  
  desc23.putObject( cTID('T   '), cTID('TxtS'), desc24 );
 
  executeAction( cTID('setd'), desc23, DialogModes.NO );  
  return;
};


PSCCFontSizeFix.test = function() {
  var doc = app.documents.add(UnitValue("5 in"), UnitValue("7 in"), 300);
  var layer = doc.artLayers.add();  
  layer.kind = LayerKind.TEXT;  
  layer.name = "Test";  
  var titem = layer.textItem;

  titem.size = new UnitValue("50", "pt");
  
  if (Math.round(titem.size.as("pt")) != 50) {
    PSCCFontSizeFix.setFontSizePoints(layer, 50);
  }
  
  titem.contents = "This text should be 50pt";  
  titem.font = "Monaco";
  alert(Math.round(titem.size.as("pt")) + " pt");

  doc.close(SaveOptions.DONOTSAVECHANGES);

  var doc = app.documents.add(UnitValue("5 in"), UnitValue("7 in"), 300);
  var layer = doc.artLayers.add();  
  layer.kind = LayerKind.TEXT;  
  layer.name = "Test";  
  var titem = layer.textItem;
  titem.size = new UnitValue("50", "px");
  
  if (Math.round(titem.size.as("px")) != 50) {
    PSCCFontSizeFix.setFontSizePixels(layer, 50);
  }
  
  titem.contents = "This text should be 50px/12pt";  
  titem.font = "Monaco";
  alert(Math.round(titem.size.as("px")) + " px");

  doc.close(SaveOptions.DONOTSAVECHANGES);
};

//PSCCFontSizeFix.test();

//

// override the default log and ini files
WatermarkUIOptions.LOG_FILE = Stdlib.PREFERENCES_FOLDER + "/xwatermark.log";
WatermarkUIOptions.INI_FILE = Stdlib.PREFERENCES_FOLDER + "/xwatermark.ini";

WatermarkUI.bridgeFiles = [];

XWatermark = function() {
};

XWatermark.main = function() {
  try {
    Stdlib.log.setFile(WatermarkUIOptions.LOG_FILE);
    XWatermark._main(desc);

  } catch (e) {
    Stdlib.logException(e, true);
  }
};
XWatermark.main = function() {
  // This start up logic may not cover everything, but it's good enough
  // for now...
  //
  // For app.displayDialogs
  // ALL - direct exec (menu/browse) or from action with dialogs
  // ERROR - from action no dialogs
  // NO - from debugger
  //
  var mode = app.playbackDisplayDialogs;

  // if we are launched from the debugger OR we have no parameters
  // we need a UI
  if (mode == DialogModes.NO || app.playbackParameters.count == 0) {
    mode = DialogModes.ALL;
  }

  // only turn off the ui if we have parameters and are called from an action
  var noUI = (app.playbackDisplayDialogs == DialogModes.ERROR);

  var binFile;

  // now set up our options based on the parameters
  // for use with Adobe Automation framework
  var desc;

  var wmKey = sTID('WatermarkOptions');

  var embedded = {};

  var ini = GenericUI.readIni(WatermarkUIOptions.INI_FILE)

  ini.noUI = noUI;

  var opts = new WatermarkUIOptions(ini);

  if (app.playbackParameters.count > 0) {
    // Playback parameters can come from an Action playback or
    // from a Bridge remote call

    var desc = app.playbackParameters;

    if (desc.hasKey(wmKey)) {
      var str = desc.getString(wmKey);
      opts = Stdlib.fromIniString(str, opts);
    }

    opts.noUI = noUI;

//     if (opts.calledFromBridge) {
//       opts.filesList = XBridgeTalk.getBridgeSelection();
//     }

    opts.embedded = (desc.hasKey(sTID('EmbeddedMode')) &&
                     desc.getBoolean(sTID('EmbeddedMode')));
    opts.configUI = (desc.hasKey(sTID('ConfigUI')) &&
                     desc.getBoolean(sTID('ConfigUI')));
    opts.apply = (desc.hasKey(sTID('Apply')) &&
                  desc.getBoolean(sTID('Apply')));

    if (desc.hasKey(sTID('BinFile'))) {
      binFile = desc.getPath(sTID('BinFile'));
    }

    if (desc.hasKey(sTID('filesList'))) {
      var files = [];
      var flist = app.playbackParameters.getList(sTID('filesList'));

      for (var i = 0; i < flist.count; i++) {
        files.push(flist.getPath(i));
      }

      opts.filesList = files;
    }

    // $.level = 1; debugger;
    opts.noUI = (opts.noUI && !opts.configUI);

  } else {
    // If we don't have any parameters, we need a UI
    // opts.noUI = false;
  }

  if (!opts.noUI) {
    app.bringToFront();
    app.displayDialogs = DialogModes.ERROR;

  } else {
    app.displayDialogs = DialogModes.NO;
  }

  var doc = (app.documents.length ? app.activeDocument : undefined);
  var ui = new WatermarkUI(opts);

  if (opts.embedded) {
    ui.iniFile = undefined;
    ui.saveIni = false;

    var xopts = opts;

    if (opts.configUI) {
      xopts = ui.exec(opts);
    }

    if (opts.apply && xopts) {
      xopts.rationalize();

      if (opts.filesList) {
        var files = opts.filesList;
        for (var i = 0; i < files.length; i++) {
          var file = files[i];
          var doc = app.open(file);
          ui.applyWatermark(xopts, doc);
          doc.close(SaveOptions.SAVECHANGES);
        }

      } else {
        ui.applyWatermark(opts, doc);
      }
    }

    opts = xopts;

  } else {
    opts = ui.exec(opts, doc);

    if (opts) {
      if (doc) {
        ui.applyWatermark(opts, doc);
      }
      
      if (ui.saveIni) {
        ui.updateIniFile({ uiX: ui.winX, uiY: ui.winY });
      }
    }
  }

  if (!opts) {
    return;
  }

  if (opts) {
//     if (opts.color.constructor != String) {
//       opts.color = Stdlib.rgbToString(opts.color);
//     }
//     var desc = new ActionDescriptor();
//     var str = Stdlib.toIniString(opts);
//     desc.putString(wmKey, str);

//     alert(listProps(opts));

    var desc = opts.toDescriptor();
    desc.putString(cTID('Msge'), "Settings for XWatermark Script");
    app.playbackParameters = desc;

    if (binFile) {
      Stdlib.writeDescriptor(binFile, desc);
//       alert("Stored settings to: " + binFile.toUIString());
    }
 }
};

XWatermark.main();

// app.playbackParameters = new ActionDescriptor();

"XAddWatermark.jsx";
// EOF


