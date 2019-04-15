//
// SLCFix.js
//   This script does some minor massaging of ScriptListener output
//   primarily by substituting charIDToTypeID and stringIDToTypeID with
//   cTID and sTID. In the process of doing this replacement, the
//   'var id##' style declarations are removed in the c/sTID calls
//   placed inline. You'll need to copy the c/sTID definitions from
//   this file into whatever file you decide to use the converted code.
//
//   One other piece of corrective surgery is to canonicalize all
//   filename strings to use '/' instead of '\' characters. I didn't bother
//   messing with the drive names.
//
//   The only thing left that I don't really have a solution for is Actions
///  that invoke scripts. For some reason, the return value of the script
//   is placed in the action and gets output to the ScriptingListener log
//   file as well. Search for 'jsMs' to see what I mean. Unforunately, in
//   many case, the return value is effectively the last piece of textual
//   code parsed, I think. There is not an easy way that I have found to
//   remove this travesty after the fact, except to do it manually by replacing
//   the code with an empty string, "". You can, however, remove it before
//   the fact. Make the last line of your script files 'true;' or, like I do,
//   the name of the script as a string, e.g. "SLCFix.js"; This has the nice
//   added benefit of showing up in the debugger console if you are running
//   the script from within the debugger.
//
//   I've converted upto 20,000 lines of ScriptingListenerJS.log code in one
//   pass with the only problems being the 'jsMs' garbage. That can, as I said
//   before, be fixed manually.
//
// $Id: SLCFix.js,v 1.33 2015/03/25 23:22:11 anonymous Exp $
// Copyright: (c)2005, xbytor
// License: http://www.opensource.org/licenses/bsd-license.php
// Contact: xbytor@gmail.com
//
//@show include
//
var app; if (!app) app = this; // for PS7

isWindows = function() {
  return $.os.match(/windows/i);
};
isMac = function() {
  return !isWindows();
};

//
//@includepath "/c/Program Files/Adobe/xtools;/Developer/xtools"
//
//@include "xlib/PSConstants.js"
//@include "xlib/TextProcessor.js"
//@include "xlib/GenericUI.jsx"
//
isPS7 = function()  { return version.match(/^7\./); };
cTID = function(s) { return app.charIDToTypeID(s); };
sTID = function(s) { return app.stringIDToTypeID(s); };

String.prototype.trim = function() {
  return this.replace(/^[\s]+|[\s]+$/g, '');
};
String.prototype.startsWith = function(sub) {
  return this.indexOf(sub) == 0;
};

String.prototype.endsWith = function(sub) {
  return this.length >= sub.length &&
    this.substr(this.length - sub.length) == sub;
};

SLCFix = function() {
  var self = this;

  self.idMap = {};       // maps ids to names
                         // e.g. id22 -> cTID("Rtte") or PSEvent.Rotate
  self.nameMap = {};     // maps syms to names, e.g. "Rtte" -> PSEvent.Rotate

  self.ftnIndex = 1;
  self.useFtns = true;
  self.first = true;
};

SLCFix.checkPSConstants = function() {
  try {
    eval("PSConstants");
    return true;
  } catch (e) {
    return false;
  }
};

SLCFix.usePSConstants = SLCFix.checkPSConstants();
SLCFix.insertFtnCalls = false;

SLCFix.prototype.nextFunction = function() {
  var str = "function ftn" + (this.ftnIndex++) + "() {\n";
  str += "  function cTID(s) { return app.charIDToTypeID(s); };\n";
  str += "  function sTID(s) { return app.stringIDToTypeID(s); };\n";
  return str;
};

SLCFix.prototype.mapSym = function(idName, sym, ftn) {
  var self = this;
  var v;

  sym = sym.replace(/\'|\"/g, '');  // trim and remove any quotes

//   if (sym == 'pointsUnit') {
//     $.level = 1; debugger;
//   }
  if (SLCFix.usePSConstants) {
    v = self.nameMap[sym];
    if (!v) {
      var id = eval(ftn + "('" + sym + "')");
      if (ftn == 'sTID') {
        var v = PSString._reverseName[id];
        if (v) {
          v = "PSString." + v;
        } else {
          v = "sTID('" + sym + "')";
        }
      } else {
        var tbl = PSConstants.symbolTypes;

        for (var name in tbl) {
          var kind = tbl[name];
          v = kind._reverseName[id];
          if (v) {
            v = "PS" + kind._name + "." + v;
            break;
          }
        }
        if (!v) {
          if (sym.length > 4) {
            ftn = 'sTID';
          }
          v = ftn + "('" + sym + "')";
        }
        if (v.endsWith(".null")) {
          v = "cTID('null')";
        }
      }
      self.nameMap[sym] = v;
    }

  } else {
     v = ftn + "('" + sym + "')";
  }
  self.idMap[idName] = v;
};

SLCFix.prototype.header = function() {
  var self = this;
  var str = '';
  str += "//\n";
  str += "// Generated from " + self.infile.absoluteURI + " on " + Date() + "\n";
  str += "//\n";
  return str.split('\n');
};

SLCFix.prototype.trailer = function() {
  var self = this;
  var str = '';

  str += "cTID = function(s) { return app.charIDToTypeID(s); };\n";
  str += "sTID = function(s) { return app.stringIDToTypeID(s); };\n\n";

  str += "function _initDefs() {\n";
  str += ("  var needDefs = true;\n" +
          "  try {\n" +
          "    PSClass;\n" +
          "    needDefs = false;\n" +
          "  } catch (e) {\n" +
          "  }\n");

  str += "  if (needDefs) {\n";

  var tbl = PSConstants.symbolTypes;
  for (var name in tbl) {
    var kind = tbl[name];
    str += "    PS" + kind._name + " = function() {};\n";
  }
  str += "  }\n};\n\n";

  str += "_initDefs();\n\n";

  var names = [];
  for (var sym in self.nameMap) {
    var n = self.nameMap[sym];
    if (n.startsWith("cTID(") || n.startsWith('sTID')) {
      continue;
    }
    var idk = (n.startsWith("PSString") ? 'sTID' : 'cTID');
    names.push(n + " = " + idk + "('" + sym + "');\n");
  }
  names.sort();
  str += names.join("");
  return str;
};


SLCFix.prototype.exec = function(infile, outfile) {
  this.symIDMap = {};
  this.infile = infile;
  var proc = new TextProcessor(infile, outfile, SLCFix.handleLine);
  proc.parent = this;
  proc.exec();
};

SLCFix.handleLine = function(line, index, outputBuffer) {
  var self = this;
  var fixer = self.parent;

  if (fixer.first) {
    // this new bit of code should fix parsing of SL log segments that
    // do not have a // ======= prefix
    fixer.first = false;
    if (fixer.useFtns) {
      outputBuffer.push(fixer.nextFunction());
      if (line.startsWith("// ========")) {
        outputBuffer.push(line);
        return TextProcessorStatus.OK;
      }
    }
  }

  // At the end of the file, print out the trailier containing
  // all of the symbol table information
  if (line == undefined) {  // EOF
    if (SLCFix.usePSConstants) {
      var str = fixer.trailer();
      var ar = str.split('\n');
      for (var i = ar.length-1; i >= 0; i--) {
        outputBuffer.unshift(ar[i]);
      }
    }

    // now, for some odd reason, we print out the header block
    var ar = fixer.header();
    for (var i = ar.length-1; i >= 0; i--) {
      outputBuffer.unshift(ar[i]);
    }

    return TextProcessorStatus.OK; // EOF
  }

  // pass empty lines through
  if (line == '') {
    outputBuffer.push('');
    return TextProcessorStatus.OK;
  }

  // handle a charID variable definition
  var m;
  if ((m = line.match(/\s*var (id\w+) = charIDToTypeID\((.+)\);/)) != null) {
    fixer.mapSym(m[1], m[2].trim(), "cTID");
    return TextProcessorStatus.OK;
  }

  // handle a stringID variable definition
  if ((m = line.match(/\s*var (id\w+) = stringIDToTypeID\((.+)\);/)) != null){
    fixer.mapSym(m[1], m[2].trim(), "sTID");
    return TextProcessorStatus.OK;
  }

  // swap out the SL var usages with our symbols
  if ((m = line.match(/ id\w+/g)) != null) {
    for (var i = 0; i < m.length; i++) {
      var nm = m[i].substring(1);
      if (fixer.idMap[nm]) {
        line = line.replace(nm, fixer.idMap[nm]);
      }
    }
  }

  // Fix up the mangled File references
  var fps;
  if ((fps = line.match(/new File\((.+)\)/)) != null) {
     line = line.replace(fps[1], fps[1].replace(/\\\\?/g, '/'));
  }

  // Look for the beginning (and ending of) SL code segments
  if (fixer.useFtns) {
    if (line.startsWith("// ========")) {
      outputBuffer.push(line);
      line = fixer.nextFunction();
    }
    if (line.match("executeAction")) {
      outputBuffer.push("    " + line);
      line = "};";

      if (SLCFix.insertFtnCalls) {
        outputBuffer.push(line);
        line = "ftn" + (fixer.ftnIndex-1) + "();";
      }
    }
  }

  line = line.replace(/"""/g, '"'); //'// File formatting fix for xemacs
  
  var ar = line.match(RegExp("\"", "g")); ; //" //File formatting fix for xemacs

  if (ar != null && ar.length == 1) {
//     $.level = 1; debugger;

    if (line[0] == '"') {
      line = '"' + line;
      self.inString = false;
    } else {
      if (self.inString) {
        line = line.replace(/"/g, '\\\"');
        line = '"' + line + '\\n" +';
      } else {
        line += '\\n" +'; 
        self.inString = true;
      }
    }
  } else if (self.inString) {
    line = '"' + line + '\\n" +';
  }

  outputBuffer.push(line);

  return TextProcessorStatus.OK;
};

//============================ SLCFixUI =====================================

SLCFixOptions = function(obj) {
  this.source = '';
  this.dest = '';
  this.useSymbols = false;
  this.insertCall = true;

  if (obj) {
    for (var idx in obj) {
      var v = obj[idx];
      if (typeof v != 'function') {
        this[idx] = v;
      }
    }
  }
};
SLCFixOptions.prototype.typename = 'SLCFixOptions';

SLCFixUI = function() {
  var self = this;

  self.title = "ScriptingListener Code Cleaner";
  self.notesSize = 310;
  self.winRect = {
    x: 200,
    y: 200,
    w: 600,
    h: 510
  };
  self.documentation =
    "This script converts the output of the ScriptingListener plugin into " +
    "a set of functions, one for each chunk of code. As part of the " +
    "conversion process this script cleans and transforms the code " +
    "primarily by substituting charIDToTypeID and stringIDToTypeID function " +
    "calls with calls to cTID and sTID. While doing this replacement, the " +
    "'var id##' style declarations are removed in the c/sTID calls " +
    "placed inline.\r   " +
    "One other piece of corrective surgery is to canonicalize all " +
    "filename strings to use '/' instead of '\\' characters. I didn't " +
    "bother messing with the drive names.\r   " +
    "The only thing left that I don't really have a solution for is Actions " +
    "that invoke scripts. For some reason, the return value of the script " +
    "is placed in the action and gets output to the ScriptingListener log " +
    "file as well. Search for 'jsMs' to see what I mean. Unforunately, in " +
    "many case, the return value is effectively the last piece of textual " +
    "code parsed, I think. There is not an easy way that I have found to " +
    "remove this travesty after the fact, except to do it manually by " +
    "replacing the code with an empty string, \"\". You can, however, " +
    "remove it before the fact. Make the last line of your script files " +
    "'true;' or, like I do, the name of the script as a string, e.g. " +
    "\"SLCFix.js\"; This has the nice added benefit of showing up in the " +
    "debugger console if you are running the script from within the debugger.";

  self.iniFile = "slcfix.ini";
};

SLCFixUI.prototype = new GenericUI();

SLCFixUI.prototype.createPanel = function(pnl, ini) {
  var self = this;
  ini = new SLCFixOptions(ini);

  var xOfs = 20;
  var yOfs = 10;
  var yy = yOfs;
  var xx = xOfs;

  pnl.add('statictext', [xx,yy,xx+110,yy+20], 'SL Log:');
  xx += 110;
  pnl.source = pnl.add('edittext', [xx,yy,xx+400,yy+20], ini.source);
  xx += 405;
  pnl.sourceBrowse = pnl.add('button', [xx,yy,xx+25,yy+20], '...');

  yy += 35;
  xx = xOfs;

  pnl.add('statictext', [xx,yy,xx+110,yy+20], 'Javascript File:');
  xx += 110;
  pnl.dest = pnl.add('edittext', [xx,yy,xx+400,yy+20], ini.dest);
  xx += 405;
  pnl.destBrowse = pnl.add('button', [xx,yy,xx+25,yy+20], '...');

  yy += 35;
  xx = xOfs;

  pnl.useSymbols = pnl.add('checkbox', [xx,yy,xx+100, yy+25], 'Use Symbols');
  pnl.useSymbols.value = toBoolean(ini.useSymbols);

  pnl.sourceBrowse.onClick = SLCFixUI.sourceBrowse;
  pnl.destBrowse.onClick = SLCFixUI.destBrowse;

  return pnl;
};

SLCFixUI.sourceBrowse = function() {
  var pnl = this.parent;
  var file = SLCFixUI.selectFileOpen("Select an SL Log File",
                 SLCFixUI.createFileSelect("Log Files: *.log,All Files:*"),
                 pnl.source.text);
  if (file) {
    pnl.source.text = file.fsName;
  }
};
SLCFixUI.destBrowse = function() {
  try {
    //$.level = 1; debugger;
    var pnl = this.parent;
    var file = SLCFixUI.selectFileSave("Select a Javascript File",
           SLCFixUI.createFileSelect("Javascript Files: *.js;*.jsx,All Files:*"),
           pnl.dest.text);

    if (file) {
      pnl.dest.text = file.fsName;
    }
  } catch (e) {
    alert(e.toSource());
  }
};

SLCFixUI.createFileSelect = function(str) {
  if (isWindows()) {
    return str;
  }

  var exts = [];
  var rex = /\*\.(\*|[\w]+)(.*)/;
  var m;
  while (m = rex.exec(str)) {
    exts.push('.' + m[1].toLowerCase());
    str = m[2];
  }

  function macSelect(f) {
    var name = decodeURI(f.absoluteURI).toLowerCase();
    var _exts = macSelect.exts;

    if (f instanceof Folder) {
      return true;
    }

    for (var i = 0; i < _exts.length; i++) {
      var ext = _exts[i];
      if (ext == '.*') {
        return true;
      }
      if (name.endsWith(ext)) {
        return true;
      }
    }
    return false;
  }

  macSelect.exts = exts;
  return macSelect;
};

SLCFixUI.selectFileOpen = function(prompt, select, start) {
  return SLCFixUI._selectFile(prompt, select, start, true);
};
SLCFixUI.selectFileSave = function(prompt, select, start) {
  return SLCFixUI._selectFile(prompt, select, start, false);
};
SLCFixUI.selectFile = SLCFixUI.selectFileOpen;

SLCFixUI._selectFile = function(prompt, select, start, open) {
  var file;

  if (!prompt) {
    prompt = 'Select a file';
  }

  if (start) {
    start = SLCFixUI.convertFptr(start);
  }

  var classFtn = (open ? File.openDialog : File.saveDialog);

  if (!start) {
    file = classFtn(prompt, select);

  } else {
    if (start instanceof Folder) {

      while (start && !start.exists) {
        start = start.parent;
      }

      var files = start.getFiles();
      for (var i = 0; i < files.length; i++) {
        if (files[i] instanceof File) {
          start = files[i];
          break;
        }
      }
      if (start instanceof Folder) {
        start = new File(start + "/file.ext");
      }
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
SLCFixUI.convertFptr = function(fptr) {
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


SLCFixUI.prototype.validatePanel = function(pnl) {
  var self = this;

  try {
    var opts = new SLCFixOptions();

    var f;
    if (pnl.source.text) {
      f = new File(pnl.source.text);
      if (!f.exists) {
        return self.errorPrompt("Log file not found");
      }
    } else {
      return self.errorPrompt("Log file must be specified");
    }
    opts.source = decodeURI(f.fsName);

    f = undefined;
    if (pnl.dest.text) {
      f = new File(pnl.dest.text);
    } else {
      var nm = opts.source.name.replace(/\.[^.]+$/, ".jsx");
      f = new File(opts.source.path + '/' + nm);
    }
    if (!f.open("w")) {
      return self.errorPrompt("Unable to open Javascript file: " + f.error);
    }
    f.close();

    opts.dest = decodeURI(f.fsName);

    opts.useSymbols = pnl.useSymbols.value;

    pnl.opts = opts;

  } catch (e) {
    alert(e.toSource());
    return false;
  }

  return opts;
};

SLCFixUI.prototype.process = function(opts) {
  if (!opts) {
    return;
  }

  var start = new Date().getTime();

  var src = new File(opts.source);
  var dest = new File(opts.dest);

  SLCFix.usePSConstants = opts.useSymbols;

  var fixer = new SLCFix();
  fixer.exec(src, dest);

  var stop = new Date().getTime();
  var elapsed = (stop - start)/1000;
  alert("Done (" + Number(elapsed).toFixed(3) + " secs).");
};

function ps7Main() {
  var infile  = new File("/c/work/batch.log");
  var outfile = new File("/c/work/batch.js");

  var start = new Date().getTime();
  var fixer = new SLCFix();
  fixer.exec(infile, outfile);

  var stop = new Date().getTime();
  var elapsed = (stop - start)/1000;
  alert("Done (" + Number(elapsed).toFixed(3) + " secs).");
};

// this bit of code checks to see if there is already a 'main' function
// defined. If there isn't, we create ours and execute it.

var dbLevel = $.level;
$.level = 0;
try {
  main;

} catch (e) {
$.level = dbLevel;

  function main() {
    if (isPS7()) {
      ps7Main();
    } else {
      var ui = new SLCFixUI();
//       $.level = 1; debugger;
      ui.exec();
    }
  };

  main();
}

"SLCFix.js";

// EOF
