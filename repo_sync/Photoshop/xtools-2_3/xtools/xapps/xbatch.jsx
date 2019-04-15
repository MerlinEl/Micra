#target photoshop
//
// xbatch.jsx
//
// xbatch is a replacement for app.batch
// It adds the following properties to BatchOptions
//    mask       - a mask for the files to be processed (default: "*")
//    recurse    - process folders recursively (default: false)
//    keeptree   - keep the directory hierarchy (default: true).
//                 For this to work, recurse must be true and the source
//                 must be a Folder.
//    saveForWeb - flag to use SaveForWeb processing (default: false)
//    saveForWebOptions - see PSJS RefGuide
//
// $Id: xbatch.jsx,v 1.23 2014/11/27 05:51:24 anonymous Exp $
// Copyright: (c)2009, xbytor
// License: http://www.opensource.org/licenses/bsd-license.php
// Contact: xbytor@gmail.com
//

var Prefs = {};

// modify these to turn logging on and off and to specify the name
// of the log file
Prefs.enableLogging = true;
Prefs.logFile       = "~/xbatch.log"; // XXX this is reset below

// only set this one when requested by the author
Prefs.dumpBatch     = false; // for dumping a batch descriptor only

// internal usage
Prefs.stopOnOpenErrors   = false;
Prefs.stopOnScriptErrors = true;
Prefs.stopOnBatchErrors  = true;

Prefs.checkScriptResult = false;
Prefs.scriptResultStop = "stop";
Prefs.scriptResultSkip = "skip";
Prefs.scriptResultOK = "ok";

// Extracts from stdlib.js

//
// Simple checks for photoshop version
//
isCS6 = function()  { return version.match(/^13\./); };
isCS5 = function()  { return version.match(/^12\./); };
isCS4 = function()  { return version.match(/^11\./); };
isCS3 = function()  { return version.match(/^10\./); };
isCS2 = function()  { return version.match(/^9\./); };
isCS  = function()  { return version.match(/^8\./); };
isPS7 = function()  { return version.match(/^7\./); };

cTID = function(s) { return app.charIDToTypeID(s); };
sTID = function(s) { return app.stringIDToTypeID(s); };

Stdlib = function Stdlib() {};
//
// Trim leading and trailing whitepace from a string
//
Stdlib.trim = function(value) {
   return value.replace(/^[\s]+|[\s]+$/g, '');
};

String.prototype.trim = function() {
  return this.replace(/^[\s]+|[\s]+$/g, '');
};

String.prototype.startsWith = function(sub) {
  return this.indexOf(sub) == 0;
};

String.prototype.contains = function(str) {
  return this.indexOf(sub) != -1;
};

String.prototype.endsWith = function(sub) {
  return this.length >= sub.length &&
    this.substr(this.length - sub.length) == sub;
};

String.prototype.containsWord = function(str) {
  return this.match(new RegExp("\\b" + str + "\\b")) != null;
};

String.prototype.reverse = function() {
   var r = '';
   var len = this.length;
   for (var i = 0; i < len; i++) {
     r += this.charAt(len - i - 1);
   }
   return r;
};

//
// Format a Date object into a proper ISO 8601 date string
//
Stdlib.toISODateString = function(date, timeDesignator, dateOnly) {
  if (!date) date = new Date();
  var str = '';
  if (timeDesignator == undefined) { timeDesignator = 'T'; };
  function _zeroPad(val) { return (val < 10) ? '0' + val : val; }
  if (date instanceof Date) {
    str = date.getFullYear() + '-' +
      _zeroPad(date.getMonth()+1,2) + '-' +
      _zeroPad(date.getDate(),2);
    if (!dateOnly) {
      str += timeDesignator +
        _zeroPad(date.getHours(),2) + ':' +
        _zeroPad(date.getMinutes(),2) + ':' +
        _zeroPad(date.getSeconds(),2);
    }
  }
  return str;
};

//
// Make it a Date object method
//
Date.prototype.toISODateString = function(timeDesignator, dateOnly) {
  return Stdlib.toISODateString(this, timeDesignator, dateOnly);
};

Stdlib.listProps = function(obj) {
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
listProps = Stdlib.listProps;

throwFileError = function(f, msg) {
  if (msg == undefined) msg = '';
  throw msg + '\"' + f + "\": " + f.error + '.';
};
Stdlib.convertFptr = function(fptr) {
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
// Open a dialog to prompt the user to select a file.
// An initial folder can optionally be specified
// Change the current directory reference if we it
// seems appropriate
//
// fix this so that the start may also be a file and so that it
// calls the PS7 version when running in PS7
//
Stdlib.selectFile = function(prompt, mask, start) {
  var file;

  if (start) {
    start = Stdlib.convertFptr(start);
  }
  if (!start) {
    file = File.openDialog(prompt, mask);
  } else {
    if (start instanceof File) {
      if (start.openDlg) {
        file = start.openDlg(prompt, mask);
      } else {
        try {
          if (start.exists) {
            Folder.current = start.parent;
          }
        } catch (e) {
        }
        file = File.openDialog(prompt, mask);
      }
    } else {
      Folder.current = start;
      file = File.openDialog(prompt, mask);
    }
  }

  if (file) {
    Folder.current = file.parent;
  }
  return file;
};

Stdlib.selectFolder = function(prompt, start) {
  var folder;

  if (start) {
    start = Stdlib.convertFptr(start);
  }
  if (!start) {
    folder = Folder.selectDialog(prompt);
  } else {
    if (start instanceof File) {
      start = start.parent;
    }

    if (start.selectDlg) {   // for CS2
      folder = start.selectDlg(prompt);

    } else {               // for CS
      var preset;
      if (start.exists) {
        preset = start;
      }
      folder = Folder.selectDialog(prompt, preset);
    }
  }
  return folder;
};

Stdlib.createFolder = function(fptr) {
  if (fptr.constructor == String) {
    fptr = new Folder(fptr);
  }

  if (fptr instanceof File) {
    return Stdlib.createFolder(fptr.parent);
  }
  if (fptr.exists) {
    return true;
  }
  if (!fptr.parent.exists) {
    if (!Stdlib.createFolder(fptr.parent)) {
      return false;
    }
  }
  return fptr.create();
};
Stdlib.writeToFile = function(fptr, str, encoding) {
  var file = Stdlib.convertFptr(fptr);

  file.open("w") || throwFileError(file, "Unable to open output file ");
  if (encoding) {
    file.encoding = encoding;
  }

  if (isPS7() && encoding == 'BINARY') {
    file.lineFeed = 'unix';

    var pos = 0;
    var cr = '\r';
    var next;
    while ((next = str.indexOf(cr, pos)) != -1) {
      file.write(str.substring(pos, next));
      file.lineFeed = 'mac';
      file.write(cr);
      file.lineFeed = 'unix';
      pos = next + 1;
    }
    if (pos < str.length) {
      file.write(str.substring(pos));
    }
  } else {
    file.write(str);
  }
  file.close();
};

Stdlib.readFromFile = function(fptr, encoding) {
  var file = Stdlib.convertFptr(fptr);
  file.open("r") || throwFileError("Unable to open input file ");
  if (encoding) {
    file.encoding = encoding;
  }
  var str = file.read();
  file.close();
  return str;
};

Stdlib.toIniString = function(obj) {
  var str = '';
  for (var idx in obj) {
    if (idx.charAt(0) == '_') {         // private stuff
      continue;
    }
    var val = obj[idx];

    if (typeof val == "string" ||
        typeof val == "number" ||
        typeof val == "boolean") {
      str += (idx + ": " + val.toString() + "\n");
    }
  }
  return str;
};
Stdlib.fromIniString = function(str, obj) {
  if (!obj) {
    obj = {};
  }
  var lines = str.split(/\r|\n/);

  var rexp = new RegExp(/([^:]+):(.*)$/);

  for (var i = 0; i < lines.length; i++) {
    var line = lines[i].trim();
    if (!line || line.charAt(0) == '#') {
      continue;
    }
    var ar = rexp.exec(line);
    if (!ar) {
      alert("Bad line in config file: \"" + line + "\"");
      return;
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
  var str = Stdlib.readFromFile(fptr);
  return Stdlib.fromIniString(str, obj);
};

Stdlib.writeIniFile = function(fptr, obj, header) {
  var str = (header != undefined) ? header : '';

  str += Stdlib.toIniString(obj);

  Stdlib.writeToFile(fptr, str);
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

  var getF;
  if (Folder.prototype._getFiles) {
    getF = function(f, m) { return f._getFiles(m); };
  } else {
    getF = function(f, m) { return f.getFiles(m); };
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

Stdlib.getFolders = function(folder) {
  return Stdlib.getFiles(folder,
                         function(file) { return file instanceof Folder; });
}

//
// Stdlib.findFiles is a recursive version of Stdlib.getFiles
//
Stdlib.findFiles = function(folder, mask) {
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

Stdlib.ImageFileExtsComplete =
  "8bps,bmp,cin,cr2,crw,dc2,dcr,dib,dng,dpx,eps,epsf,exr,fido,flm,gif,hrr," +
  "icb,jpe,jpeg,jpg,mrw,nef,orf,pbm,pcd,pct,pcx,pdd,pdf,pdp,pic,pict,png," +
  "ps,psb,psd,pxr,raf,raw,rgbe,rle,sct,sdpx,tga,tif,tiff,vda,vst,wbm,wbmp," +
  "x3f,xyze";

Stdlib.ImageFileExtsCompleteRE =
  new RegExp("\\.(" +
             Stdlib.ImageFileExtsComplete.replace(/,/g, '|') + ")$", 'i');

Stdlib.ImageFileExtsCommon =
  "psd,pdd,dng,jpeg,jpg,jpe,8bps,gif,bmp,rle,dib,tif,tiff,crw,nef,raf,orf";

Stdlib.ImageFileExtsCommonRE =
  new RegExp("\\.(" +
             Stdlib.ImageFileExtsCommon.replace(/,/g, '|')
             + ")$", 'i');
Stdlib.isImageFile = function(fstr) {
  return fstr.toString().match(Stdlib.ImageFileExtsCommonRE) != null;
};

Stdlib.getActionSets = function() {
  var i = 1;
  var sets = [];

  while (true) {
    var ref = new ActionReference();
    ref.putIndex(cTID("ASet"), i);
    var desc;
    try {
      desc = executeActionGet(ref);
    } catch (e) {
      break;    // all done
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
    throw "Action set must be specified";
  }

  while (true) {
    var ref = new ActionReference();
    ref.putIndex(cTID("ASet"), i);
    var desc;
    try {
      desc = executeActionGet(ref);
    } catch (e) {
      break;    // all done
    }
    if (desc.hasKey(cTID("Nm  "))) {
      var name = desc.getString(cTID("Nm  "));
      if (name == aset) {
        var count = desc.getInteger(cTID("NmbC"));
        var names = [];
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

function isBoolean(s) {
  return (s != undefined && s.constructor == Boolean);
}

//============================ XBatchUI ====================================

XBatchUIOptions = function(obj) {
  var self = this;

  self.source = '';
  self.outf = '';
  self.actionName = '';
  self.actionSet = '';
  self.overrideSave = true;
  self.suppressProfileWarnings = false;
  self.suppressOpenOptions = false;

  if (obj) {
    for (var idx in obj) {
      var v = obj[idx];
      if (typeof v != 'function') {
        this[idx] = v;
      }
    }
  }
};

XBatchUI = function() {};
XBatchUI._getPreferencesFolder = function() {
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

XBatchUI.PREFERENCES_FOLDER = XBatchUI._getPreferencesFolder();

Prefs.logFile = XBatchUI.PREFERENCES_FOLDER + "/xbatch.log";

XBatchUI.INIFILE = XBatchUI.PREFERENCES_FOLDER + "/xbatch.ini";

XBatchUI.createWindow = function() {
  var wrect = {
    x: 200,
    y: 200,
    w: 400,
    h: 490
  };

  var ini = XBatchUI.readIniFile();
  var opts = new XBatchUIOptions(ini);

  var defaultSet = false;

  var win = new Window('dialog', 'XBatch Runner',
                       [wrect.x, wrect.y, wrect.x+wrect.w, wrect.y+wrect.h]);

  win.sets = Stdlib.getActionSets();

  var xOfs = 10;
  var yy = 10;

  var xx = xOfs;
  var docPnl = win.add('panel', [xx, yy, wrect.w-10, yy+110], 'Notes:');

  docPnl.add('statictext', [10, 10, wrect.w-30, 150],
           XBatchUI.documentation, {multiline:true});
  yy += 120;

  var xx = xOfs;
  win.txt1 = win.add('statictext', [xx,yy,xx+110,yy+20], 'Source Directory:');
  xx += 110;
  win.source = win.add('edittext', [xx,yy,xx+220,yy+20], opts.source || '');
  xx += 225;
  win.sourceBrowse = win.add('button', [xx,yy,xx+30,yy+20], '...');

  yy += 30;
  xx = xOfs;

  win.txt2 = win.add('statictext', [xx,yy,xx+110,yy+20], 'Target Directory:');
  xx += 110;
  win.outf = win.add('edittext', [xx,yy,xx+220,yy+20], opts.outf || '');
  xx += 225;
  win.outfBrowse = win.add('button', [xx,yy,xx+30,yy+20], '...');

  yy += 40;
  xx = xOfs;

  win.add('statictext', [xx,yy,xx+110,yy+20], 'Script (optional):');
  xx += 110;
  win.script = win.add('edittext', [xx,yy,xx+220,yy+20], opts.script || '');
  xx += 225;
  win.scriptBrowse = win.add('button', [xx,yy,xx+30,yy+20], '...');

  yy += 40;
  xx = xOfs;

  // Insert action set/name code
  win.add('statictext', [xx, yy, xx+110, yy+20], 'Action Set:');
  xx += 110;

  win.setDropdown = win.add('dropdownlist', [xx,yy,xx+220,yy+25]);

  xx = xOfs;
  yy += 30;

  win.add('statictext', [xx, yy, xx+110, yy+20], 'Action:');
  xx += 110;
  win.actionDropdown = win.add('dropdownlist', [xx,yy,xx+220,yy+25]);

  win.setDropdown.onChange = function() {
    var win = this.parent;

    //$.level = 1; debugger;

    win.actionDropdown.removeAll();

    var set = this.selection.set;

    // setup the actions dropdown for this new set
    var acts = set.actions;
    if (acts.length > 0) {
      for (var i = 0; i < acts.length; i++) {
        var act = acts[i];
        win.actionDropdown.add("item", act);
        if (win.defaultAction == act) {
          win.actionDropdown.items[i].selected = true;
        }
      }
      if (!win.defaultAction) {
        win.actionDropdown.items[0].selected = true;
      } else {
        win.defaultAction = undefined;
      }
    }
  };

  for (var i = 0; i < win.sets.length; i++) {
    win.setDropdown.add("item", win.sets[i].name);
    win.setDropdown.items[i].set = win.sets[i];
  }

  if (opts.actionSet && opts.actionName) {
    var sets = win.sets;
    var set = undefined;
    for (var i = 0; i < sets.length; i++) {
      set = sets[i];
      if (opts.actionSet == set.name) {
        win.setDropdown.items[i].selected = true;
        break;
      }
      set = undefined;
    }
    if (set) {
      // the action name will be selected when the
      // menu is created when the onChange is fired
      // for the set dropdown
      win.defaultAction = opts.actionName;
    }
  }

  // setup the action set dropdown
  if (!win.defaultAction) {
    win.setDropdown.items[0].selected = true;
  }

  if (isCS3()) {
    win.setDropdown.onChange();
  }

  xx = xOfs;
  yy += 40;

  win.overrideSave = win.add('checkbox', [xx,yy,xx+250,yy+20],
                             'Override action "Save As" commands');
  win.overrideSave.value = toBoolean(opts.overrideSave);

  xx = xOfs;
  yy += 40;

  win.suppressProfileWarnings = win.add('checkbox', [xx,yy,xx+250,yy+20],
                                        'Suppress Profile Warnings');
  win.suppressProfileWarnings.value = toBoolean(opts.suppressProfileWarnings);

  xx = xOfs;
  yy += 40;

  win.suppressOpenOptions = win.add('checkbox', [xx,yy,xx+250,yy+20],
                                    'Suppress Open Options');
  win.suppressOpenOptions.value = toBoolean(opts.suppressOpenOptions);

  xx = xOfs;
  yy += 40;


  var btnY = wrect.h - 30;
  xOfs = 70;
  win.process = win.add('button', [xOfs,btnY,xOfs+100,btnY+20], 'Process');
  win.cancel  = win.add('button', [wrect.w-xOfs-100,btnY,wrect.w-xOfs,btnY+20],
                        'Cancel');

  win.process.onClick = function() {
    try {
      var rc = this.parent.validate();
      if (!isBoolean(rc) || !rc) {
        this.parent.close(2);
      }
    } catch (e) {
      alert(e.toSource());
    }
  };

  win.defaultElement = win.process;
  win.cancelElement = win.cancel;

  return win;
};
function toBoolean(s) {
  if (s == undefined) return false;
  if (s.constructor == Boolean) return s;
  if (s.constructor == String)  return s == "true";
  return !(!s);
};

XBatchUI.run = function() {
  var win = XBatchUI.createWindow();

  function errorPrompt(str) {
    var rc = confirm(str + "\r\rContinue?", false, "Input Error");
    return rc;
  }

  win.sourceBrowse.onClick = function() {
    try {
      var win = this.parent;
      var f = Stdlib.selectFolder("Select source folder", win.source.text);
      if (f) {
        win.source.text = decodeURI(f.fsName);
      }
    } catch (e) {
      alert(e);
    }
  };

  win.outfBrowse.onClick = function() {
    var win = this.parent;
    var f;
    var def = win.outf.text;
    if (!def && win.source.text) {
      def = win.source.text;
    }
    f = Stdlib.selectFolder("Select a Destination Folder", def);

    if (f) {
      win.outf.text = decodeURI(f.fsName);
    }
  };

  win.scriptBrowse.onClick = function() {
    try {
      var win = this.parent;
      var def = win.script.text;
      var f = Stdlib.selectFile("Select a Javascript File",
                                "Javascript: *.js;*.jsx",
                                def);
      if (f) {
        win.script.text = decodeURI(f.fsName);
      }
    } catch (e) {
      alert(e);
    }
  };

  win.process.onClick = function() {
    try {
    var win = this.parent;
    var rc = win.validate();
    if (!isBoolean(rc) || !rc) {
      win.close(2);
    }
    } catch (e) {
      alert(e);
    }
  };

  win.validate = function() {
    var opts = new XBatchUIOptions();
    var f;
    if (win.source.text) {
      f = new Folder(win.source.text);
    }
    if (!f || !f.exists) {
      return errorPrompt("Source folder not found");
    }

    opts.source = f;

    if (win.outf.text) {
      f = new Folder(win.outf.text);
      if (!f.exists) {
        if (!f.create()) {
          return errorPrompt("unable to create target folder");
        }
      }
    }
    if (!f || !f.exists) {
      return errorPrompt("Target folder not found");
    }
    opts.outf = f;

    if (win.script.text) {
      f = new File(win.script.text);
      if (!f.exists) {
        return errorPrompt("script file not found: " + f.error);
      }

      opts.script = f;
    } else {
      opts.script = undefined;
    }

    opts.actionName = win.actionDropdown.selection.text;
    opts.actionSet = win.setDropdown.selection.text;

    opts.overrideSave = win.overrideSave.value;
    opts.suppressProfileWarnings = win.suppressProfileWarnings.value;
    opts.suppressOpenOptions = win.suppressOpenOptions.value;

    win.opts = opts;
    return opts;
  };

  win.center();
  win.show();

  if (win.opts) {
    XBatchUI.writeIniFile(win.opts);
  }
  return win.opts;
};

XBatchUI.writeIniFile = function(opts) {
  if (!opts) {
    return;
  }
  var script = (opts.script ? opts.script.fsName : '');
  var iniObj = {
    source : decodeURI(opts.source.fsName),
    outf: decodeURI(opts.outf.fsName),
    script: decodeURI(script),
    actionSet: opts.actionSet,
    actionName: opts.actionName,
    overrideSave: opts.overrideSave,
    suppressProfileWarnings: opts.suppressProfileWarnings,
    suppressOpenOptions: opts.suppressOpenOptions
  };
  Stdlib.writeIniFile(XBatchUI.INIFILE, iniObj);
};

XBatchUI.readIniFile = function() {
  var file = new File(XBatchUI.INIFILE);
  var opts;
  if (file.exists) {
    opts = Stdlib.readIniFile(file);
  }
  return opts;
};
XBatchUI.documentation =
  "This batch tool operates on a hierarchy of folders. That structure is " +
  "is mirrored in the target folder. Each document is processed by running " +
  "an optional script followed by running an action. Errors are recorded in " +
  "a detailed log file.";

function runScript(file) {
  var str = Stdlib.readFromFile(file);
  return eval(str);
};

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
xbatch = function xbatch(src, act, actset, opts, mask, recurse) {
  if (isCS()) {
    throw "Batch is only available in CS2 and later versions.";
  }

  opts.errorCnt = 0;
  if (opts.logFile && Prefs.enableLogging) {
    var f = Stdlib.convertFptr(opts.logFile);
    f.remove();
    if (!f.open("w")) {
      alert("Unable to open log file " + f.fsName + ": " + f.error);
      return;
    }
    opts.logFile = f;
    xbatch.logFile = f;

    xbatch.log("xbatch options:\n" + listProps(opts));
  }

  if (mask != undefined) {
    opts.mask = mask;
  }
  if (!opts.mask) {
    opts.mask = "*";
  }
  if (recurse != undefined) {
    opts.recurse = recurse;
  }

  if (opts.destinationFolder.constructor == String) {
    opts.destinationFolder = new Folder(opts.destinationFolder);
  }

  if (opts.keeptree) {  // we only set the root the first time through
    if (src instanceof Folder) {
      opts.root = src;
      opts.rootStr = opts.root.toString();
    } else if (src.constructor == String) {
      var f = new Folder(src);
      if (f.exists) {
        src = f;
        opts.root = src;
        opts.rootStr = opts.root.toString();
      }
    }
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
      throw "Too many BatchOptions.fileNaming components.";
    }
    var fnrdesc = new ActionDescriptor();
    var fnclist = new ActionList();

    for (var i = 0; i < opts.fileNaming.length; i++) {
      var namingComponent = opts.fileNaming[i];
      var fncdesc = new ActionDescriptor();

      if (namingComponent.constructor ==  String) {
        fncdesc.putString(cTID("Txt "), opts.fileNaming[i]);
      } else {
        var mappedId = xbatch.map[namingComponent];
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

    opts.fnrdesc = fnrdesc;
  }

  xbatch.log("xbatch START", new Date().toISODateString());
  xbatch.run(src, act, actset, opts);
  xbatch.log("xbatch STOP ", new Date().toISODateString());

  if (opts.errorCnt) {
    var s = "Errors detected in xbatch run.";
    if (opts.logFile) {
      s += " Please check " + opts.logFile.fsName + " for details.";
    }
    alert(s);
  }

  // clean up
  opts.errorCnt = undefined;
  opts.fnrdesc = undefined;
  opts.root = undefined;
  opts.rootStr = undefined;
};

xbatch.run = function(src, act, actset, opts) {
  xbatch.log(src);

  // $.level = 1; debugger;
  if (src instanceof Array) {
    for (var i = 0; i < src.length; i++) {
      var rc = xbatch.run(src[i], act, actset, opts);
      if (!rc) {
        return false;
      }
      opts.startingSerial++;  // XXX Why is this here???
    }
    return true;
  }

  if (src.constructor == String) {
    src = Stdlib.convertFptr(src);
  }

  if (src instanceof Folder) {
    xbatch.log("\t" + src.getFiles().join("\r\n\t"));
  }

  //$.level = 1; debugger;
  var subdirs;
  if (src instanceof Folder) {
    if (opts.mask) {
      var files;
      if (opts.recurse == true) {
        files = Stdlib.findFiles(src, opts.mask);
      } else {
        files = Stdlib.getFiles(src, opts.mask);
      }
      if (files.length > 0) {
        var rc = xbatch.run(files, act, actset, opts);
        if (!rc) {
          return false;
        }
      } else {
        xbatch.log("No files found in " + src);
      }
      return true;
    } else {
      throw "xbatch: Internal Error - No mask specified";
    }
    if (recurse == true) {
      subdirs = Stdlib.getFolders(src);
    }
  }

  //$.level = 1; debugger;
  var desc = new ActionDescriptor();

  if (opts.script && src instanceof File) {
    try {
      app.open(src);
    } catch (e) {
      opts.errorCnt++;
      xbatch.log(src, "Failed to open document: " + e.toString());
      return !Prefs.stopOnOpenErrors;
    }
    try {
      var res = runScript(opts.script);
      if (Prefs.checkScriptResult) {
        if (res != undefined) {
          res = res.toLowerCase();
          if (res == Prefs.scriptResultStop) {
            xbatch.log(src, "Stopping processing on script result");
            try {
              app.activeDocument.close(SaveOptions.DONOTSAVECHANGES);
            } catch (e) {
            }
            return false;

          } else if (res == Prefs.scriptResultSkip) {
            xbatch.log(src, "Skipping processing on script result");
            try {
              app.activeDocument.close(SaveOptions.DONOTSAVECHANGES);
            } catch (e) {
            }
            return true;
          }
        }
      }
    } catch (e) {
      opts.errorCnt++;
      xbatch.log(src, "Script failed: " + e.toString());
      try {
        app.activeDocument.close(SaveOptions.DONOTSAVECHANGES);
      } catch (e) {
      }
      return !Prefs.stopOnScriptErrors;
    }
  }

  desc.putPath(cTID("null"), src); // source

  if (opts.suppressProfileWarnings == true) {
    desc.putBoolean(sTID("suppressWarnings"), true);
  }
  if (opts.suppressOpenOptions == true) {
    desc.putBoolean(sTID("suppressOpenOptions"), true);
  }

  var actref = new ActionReference();
  actref.putName(cTID("Actn"), act);
  actref.putName(cTID("ASet"), actset);
  desc.putReference(cTID("Usng"), actref);

  // XXX Not sure how this will interact with docs opened for script invocation
  if (opts.overrideOpen == true) {
    desc.putBoolean(cTID("OvrO"), true);
  }

  // $.level = 1; debugger;
  if (opts.destination != BatchDestinationType.NODESTINATION) {
    var dest = opts.destinationFolder;

    if (opts.keeptree && opts.root) {
      if (src.path.indexOf(opts.rootStr) != 0) {
        throw "xbatch: internal error mapping directory tree";
      }
      dest = dest.toString() + src.path.substr(opts.rootStr.length);
      dest = new Folder(dest);
      if (!Stdlib.createFolder(dest)) {
        throw "xbatch: unable to create folder " + dest.error + " : " + dest;
      }
    }
    desc.putPath(cTID("T   "), dest);
  }

  if (opts.fnrdesc) {
    desc.putObject(sTID("fileNamingRules"), sTID("fileNamingRules"),
                   opts.fnrdesc);
  }

  if (opts.destination != BatchDestinationType.NODESTINATION) {
    if (opts.overrideSave == true) {
      desc.putBoolean(cTID("Ovrd"), true);
    }
  }

  if (opts.destination == BatchDestinationType.SAVEANDCLOSE) {
    desc.putBoolean(cTID("SvAn"), true);
  }

//   if (opts.logFile) {
//     desc.putPath(cTID("Log "), opts.logFile.parent);
//     desc.putString(cTID("Nm  "), opts.logFile.name);
//   }

  try {
    executeAction(cTID("Btch"), desc, DialogModes.NO);

  } catch (e) {
    opts.errorCnt++;
    xbatch.log(src, "Batch failed: " + e.toString());
    if (Prefs.dumpBatch) {
      if (e.number == 8800) {
        var f = xbatch.writeDescriptor(desc);
        alert("Batch failed for " + src + ", debug info saved to " + f);
      }
    }
    return !Prefs.stopOnBatchErrors;
  }

  if (subdirs) {
    for (var i = 0; i < subdirs.length; i++) {
      var rc = xbatch.run(subdirs[i], act, actset, opts);
      if (!rc) {
        return false;
      }
    }
  }
  return true;
};

xbatch.init = function() {
  if (isCS()) {
    return;
  }
  if (xbatch.map) {
    return;
  }
  xbatch.map = {};
  xbatch.map[FileNamingType.DDMM] = sTID("ddmm");
  xbatch.map[FileNamingType.DDMMYY] = sTID("ddmmyy");
  xbatch.map[FileNamingType.DOCUMENTNAMELOWER] = sTID("lowerCase");
  xbatch.map[FileNamingType.DOCUMENTNAMEMIXED] = cTID("Nm  ");
  xbatch.map[FileNamingType.DOCUMENTNAMEUPPER] = sTID("upperCase");
  xbatch.map[FileNamingType.EXTENSIONLOWER] = sTID("lowerCaseExtension");
  xbatch.map[FileNamingType.EXTENSIONUPPER] = sTID("upperCaseExtension");
  xbatch.map[FileNamingType.MMDD] = sTID("mmdd");
  xbatch.map[FileNamingType.MMDDYY] = sTID("mmddyy");
  xbatch.map[FileNamingType.SERIALLETTERLOWER] = sTID("upperCaseSerial");
  xbatch.map[FileNamingType.SERIALLETTERUPPER] = sTID("lowerCaseSerial");
  xbatch.map[FileNamingType.SERIALNUMBER1] = sTID("oneDigit");
  xbatch.map[FileNamingType.SERIALNUMBER2] = sTID("twoDigit");
  xbatch.map[FileNamingType.SERIALNUMBER3] = sTID("threeDigit");
  xbatch.map[FileNamingType.SERIALNUMBER4] = sTID("fourDigit");
  xbatch.map[FileNamingType.YYDDMM] = sTID("yyddmm");
  xbatch.map[FileNamingType.YYMMDD] = sTID("yymmdd");
  xbatch.map[FileNamingType.YYYYMMDD] = sTID("yyyymmdd");
};

xbatch.init();

xbatch.log = function(src, msg) {
  if (xbatch.logFile) {
    var f = xbatch.logFile;
    f.open("e") || throwFileError(f, "Unable to open file");
    f.seek(0, 2);  // jump to the end of the file
    f.write(src);
    if (msg) {
      f.write(" - " + msg);
    }
    f.writeln();
    f.close();
  }
};

//
// Create the BatchOptions for this script. The only parts of the options
// that change from invocation to invocation are the destination directory
// and the text to be embedded in the file name
//
// dest - The destination directory [Folder]
//
xbatch.createXBatchOptions = function(xopts) {
  var opts = new BatchOptions();

  var dest = xopts.outf;

  opts.destination = BatchDestinationType.FOLDER;
  opts.destinationFolder = dest;

  if (Prefs.logFile) {
    opts.logFile = Prefs.logFile;
  } else {
    opts.logFile = '';
  }

  // for names like '001-large.jpg'
  opts.fileNaming = [ FileNamingType.DOCUMENTNAMEMIXED,
                      // txt, // insert a text tag in the filename
                      FileNamingType.EXTENSIONLOWER];

  opts.overrideOpen = xopts.overrideOpen;
  opts.startingSerial = 1;
  opts.suppressProfileWarnings = xopts.suppressProfileWarnings;
  opts.suppressOpenOptions = xopts.suppressOpenOptions;

  opts.overrideSave = xopts.overrideSave;

  opts.macintoshCompatible = false;
  opts.windowsCompatible = false;
  opts.unixCompatible = true;

  // These are the XBatch extensions
  opts.mask = Stdlib.ImageFileExtsCompleteRE;
  opts.recurse    = true;
  opts.keeptree   = true;

  // not yet working...
  opts.saveForWeb = false;
  opts.saveForWebOptions = undefined;
  opts.currentSerial = 0;

  opts.script = undefined;  // script to execute _before_ the action is called

  return opts;
};

xbatch.writeDescriptor = function(desc) {
  var file = new File(Folder.temp + '/batch-' +
                      (new Date().getTime()) + '.bin');
  Stdlib.writeToFile(file, desc.toStream(), desc.toStream());
  return file.fsName;
};


xbatch.test = function() {
  // createXBatchOptions the extended BatchOptions object that we need
  var batchOpts = xbatch.createXBatchOptions({ outf: "/c/work/uwe/test/out" });

  batchOpts.script = "/c/work/uwe/rotate.js";

  // we need a source folder
  var src = new Folder("/c/work/uwe/test/Images");

  // an action set/name
  var actName = "savetiff";
  var actSet = "Uwe";

  // process an entire tree
  xbatch(src, actName, actSet, batchOpts);

  // process only a subset of files
  // xbatch(src, actName, actSet, batchOpts, "1-S*.jpg", true);

  // an example of how to process a single file
  //xbatch(src + "/1-Blizzard.jpg", actName, actSet, batchOpts);
};


//xbatch.test();


function main() {
  if (isPS7() || isCS()) {
    throw "Batch is only available in CS2 and later.";
  }

  var opts = XBatchUI.run();

  if (opts) {
    var batchOpts = xbatch.createXBatchOptions(opts);
    batchOpts.script = opts.script;
    xbatch(opts.source, opts.actionName, opts.actionSet, batchOpts);
  }
};

main();

"xbatch.jsx";

// EOF
