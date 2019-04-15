//
// Flatten.js
//   This takes a javascript file and inlines all of the included
//   files. It avoids recursive and redundant includes.
//
// $Id: Flatten.js,v 1.29 2012/08/08 18:41:14 anonymous Exp $
// Copyright: (c)2005, xbytor
// License: http://www.opensource.org/licenses/bsd-license.php
// Contact: xbytor@gmail.com
//
//@show include
//
app;
//
//@includepath "/c/Program Files/Adobe/xtools;/Developer/xtools"
//
//@include "xlib/TextProcessor.js"
//@include "xlib/GenericUI.jsx"
//

isPS7 = function()  { return version.match(/^7\./); };

throwFileError = function(f, msg) {
  if (msg == undefined) msg = '';
  Error.runtimeError(9002, msg + '\"' + f + "\": " + f.error + '.');
};

function exceptionMessage(e) {
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

XStdlib = function() {};
XStdlib.getFiles = function(folder, mask) {
  var files = [];

  //XStdlib.fullStop();
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

XStdlib.convertFptr = function(fptr) {
  var f;
  if (fptr.constructor == String) {
    f = File(fptr);
  } else if (fptr instanceof File || fptr instanceof Folder) {
    f = fptr;
  } else {
    Error.runtimeError(9002, "Bad file \"" + fptr + "\" specified.");
  }
  return f;
};

XStdlib.writeToFile = function(fptr, str, encoding) {
  var file = XStdlib.convertFptr(fptr);

  file.open("w") || throwFileError(file, "Unable to open output file ");
  if (encoding) {
    file.encoding = encoding;
  }

  file.lineFeed = 'unix';

  if (isPS7() && encoding == 'BINARY') {
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

XStdlib.readFromFile = function(fptr, encoding) {
  var file = XStdlib.convertFptr(fptr);
  file.open("r") || throwFileError("Unable to open input file ");
  if (encoding) {
    file.encoding = encoding;
  }
  var str = file.read();
  file.close();
  return str;
};

XStdlib.createFileSelect = function(str) {
  if (isWindows()) {
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

    for (var i = 0; i < _exts.length; i++) {
      var ext = _exts[i];
      if (ext == '*') {
        return true;
      }
      if (name.match(RegExp("\\." + ext + "$", "i")) != null) {
        return true;
      }
    }

    return false;
  }

  macSelect.exts = exts;
  return macSelect;
};

//
// Open a dialog to prompt the user to select a file.
// An initial folder can optionally be specified
// Change the current directory reference if we it
// seems appropriate
//
//  XStdlib.selectFile("Choose a file", "JPEG Files: *.jpg", "/c/tmp/tmp.jpg")
//
XStdlib.selectFileOpen = function(prompt, select, start) {
  return XStdlib._selectFile(prompt, select, start, true);
};
XStdlib.selectFileSave = function(prompt, select, start) {
  return XStdlib._selectFile(prompt, select, start, false);
};
XStdlib.selectFile = XStdlib.selectFileOpen;

XStdlib._selectFile = function(prompt, select, start, open) {
  var file;

  if (!prompt) {
    prompt = 'Select a file';
  }

  if (start) {
    start = XStdlib.convertFptr(start);
  }

  var classFtn = (open ? File.openDialog : File.saveDialog);

  if (!start) {
    file = classFtn(prompt, select);

  } else {
    if (start instanceof Folder) {
      var folder = start;

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
        start = new File(start + "/file");
      }

      // openDlg and saveDlg are broke in CS6
      if (CSVersion() >= 6) {
        start = folder;
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

XStdlib.selectFolder = function(prompt, start) {
  var folder;

  if (!prompt) {
    prompt = 'Select a folder';
  }
  if (start) {
    start = XStdlib.convertFptr(start);
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

    if (start.selectDlg) {   // for CS2
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

String.prototype.startsWith = function(sub) {
  return this.indexOf(sub) == 0;
};

//===========================================================================

Flattener = function() {
  var self = this;
  this.folders = [];
  this.files = {};
};

Flattener.handleLine = function(line, index, outputBuffer) {
  var self = this;

  if (line == undefined) { // EOF
    return true;
  }

  if (line.startsWith("//@include ")) {
    var re = /\/\/@include\s+\"([^"]+)\"/; ")]"; //" emacs-indent
    var m = line.match(re);
    var fname = m[1];
    var file;
    var folders = self.parent.folders;

    if (fname[0] == '/') {
      file = new File(fname);

    } else {
      for (var i = 0; i < folders.length; i++) {
        file = new File(folders[i] + '/' + fname);
        if (file.exists) {
          break;
        }
      }
    }

    if (!file.exists) {
      Error.runtimeError(9002, "File does not exist: " + fname);
    }

    if (!self.parent.files[file.name]) {
      var contents = self.parent.doFile(file);
      // outputBuffer = outputBuffer.concat(contents);
      for (var i = 0; i < contents.length; i++) {
        outputBuffer.push(contents[i]);
      }
    } else {
      // we've already included this file before...
    }
    
    return true;
  }
  if (line.startsWith("//@includepath ")) {
    var re = /\/\/@includepath\s+\"([^"]+)\"/;  ")]"; //" emacs-indent
    var m = line.match(re);
    var paths = m[1].split(';');
    self.parent.folders = self.parent.folders.concat(paths);
    return true;
  }

  outputBuffer.push(line);
  return true;
};

Flattener.prototype.doFile = function(infile) {
  var self = this;

  infile = TextProcessor.convertFptr(infile);

  var proc = new TextProcessor(infile, undefined, Flattener.handleLine);
  proc.encoding = "UTF-8";
  self.folders.push(infile.parent);
  self.files[infile.name] = true;
  proc.parent = self;
  proc.exec(infile);
  return proc.outputBuffer;
};

Flattener.prototype.exec = function(infile, outfile) {
  try {
    if (!outfile) {
      outfile = infile.toString().replace(/\.([^.]+)$/, "-new.$1");
    }
    var contents = this.doFile(infile);
    TextProcessor.writeToFile(outfile, contents.join("\n") + '\n', "UTF-8");
    return true;

  } catch (e) {
    var msg = ("Error processing " + decodeURI(infile.fsName) + '\r' +
               exceptionMessage(e) + "Do you wish to continue?");

    return confirm(msg);
  }
};

Flattener.prototype.folderExec = function(infolder, outfolder) {
  var self = this;
  var files = XStdlib.getFiles(infolder, /\.jsx?$/);

  if (infolder.toString() == outfolder.toString()) {
    throw "The destination folder must be different than the source folder.";
  }

  for (var i = 0; i < files.length; i++) {
    var infile = files[i];
    var outfile = new File(outfolder + '/' + infile.name);
    self.folders = [];
    self.files = {};
    if (!self.exec(infile, outfile)) {
      break;
    }
  }
};

function main_file() {
  var infile  = "/c/work/xtools/xlib/ActionRunner.js";
  var outfile = "/c/work/ActionRunner.js";

  if (!isPS7()) {
    if (infile.openDlg) {
      infile = infile.openDlg("Select a source javascript file");
    } else {
      Folder.current = infile.path;
      infile = File.openDialog("Select a source javascript file");
    }
    if (!infile) {
      return;
    }

    if (outfile.openDlg) {
      outfile = outfile.openDlg("Select a destination javascript file");
    } else {
      Folder.current = outfile.path;
      outfile = File.openDialog("Select a destination javascript file");
    }
  }

  var f = new Flattener();
  f.exec(infile, outfile);
};



function main_folder() {
  var infolder  = "/c/work/xtools/xapps";
  var outfolder = "/c/work/xtools/xapps-inline";
//   var infolder  = "/c/work/tmp";
//   var outfolder = "/c/work/tmp/xapps-inline";

  infolder = Folder.selectDialog("Select a javascript folder", infolder);
  if (!infolder) {
    return;
  }
  outfolder = Folder.selectDialog("Select a destination folder", outfolder);
  if (!outfolder) {
    return;
  }

  var f = new Flattener();
  f.folderExec(infolder, outfolder);
};

function old_main() {
  if (confirm("Flatten a file?")) {
    main_file();
  } else if (confirm("Flatten a folder?")) {
    main_folder();
  }
};


//==========================================================================

FlattenOptions = function(obj) {
  if (obj) {
    for (var idx in obj) {
      var v = obj[idx];
      if (typeof v != 'function') {
        this[idx] = v;
      }
    }
  }
};

FlattenOptions.prototype.typename = 'FlattenOptions';
FlattenOptions.prototype.source = Folder.current.fsName;
FlattenOptions.prototype.dest = Folder.current.fsName;
FlattenOptions.prototype.mode = File; // Folder; // or File;

FlattenUI = function() {
  var self = this;

  self.title = "Javascript File Flattener";
  self.notesSize = 150;
  self.winRect = {
    x: 200,
    y: 200,
    w: 575,
    h: 350
  };
  self.documentation =
    "This script 'flattens' a Javascript source file that contains " +
    "'//@include' directives. Nested inclusion is handled correctly. " +
    "Reinclusion is not dealt with; a file is inlined the first time it " +
    "is seen. Comment markers are _not_ generated to indicate where files " +
    "contents change in the output, so comment your code well. \r\rSelect " +
    "a target and destination file (or folder) to process.";

  self.iniFile = GenericUI.preferencesFolder + "/flatten.ini";
};
FlattenUI.prototype = new GenericUI();

FlattenUI.prototype.createPanel = function(pnl, ini) {
  var self = this;

  ini = new FlattenOptions(ini);

  var xOfs = 20;
  var yOfs = 10;
  var yy = yOfs;
  var xx = xOfs;

  pnl.add('statictext', [xx,yy,xx+60,yy+20], 'Mode:');
  xx += 65;
  pnl.file = pnl.add('radiobutton', [xx,yy,xx+80,yy+20], "File");
  xx += 80;
  pnl.folder = pnl.add('radiobutton', [xx,yy,xx+80,yy+20], "Folder");

  yy += 30;
  xx = xOfs;

  pnl.add('statictext', [xx,yy,xx+100,yy+20], 'Source:');
  xx += 100;
  pnl.source = pnl.add('edittext', [xx,yy,xx+390,yy+20], ini.source);
  xx += 395;
  pnl.sourceBrowse = pnl.add('button', [xx,yy,xx+25,yy+20], '...');
  yy += 30;
  xx = xOfs;

  pnl.add('statictext', [xx,yy,xx+100,yy+20], 'Destination:');
  xx += 100;
  pnl.dest = pnl.add('edittext', [xx,yy,xx+390,yy+20], ini.dest);
  xx += 395;
  pnl.destBrowse = pnl.add('button', [xx,yy,xx+25,yy+20], '...');

  if (ini.mode == 'Folder') {
    pnl.folder.value = true;
  } else {
    pnl.file.value = true;
  }

  yy += 30;
  xx = xOfs;

  pnl.sourceBrowse.onClick = FlattenUI.sourceBrowse;
  pnl.destBrowse.onClick = FlattenUI.destBrowse;
};

FlattenUI.sourceBrowse = function() {
  try {
    var pnl = this.parent;
    var fileMode = pnl.file.value;
    var source;

    if (fileMode) {
      source = XStdlib.selectFileOpen("Select an source File",
                                     XStdlib.createFileSelect("Javascript Files: *.jsx;*.js,All Files:*"),
                                 pnl.source.text);
    } else {
      source = XStdlib.selectFolder("Select an source Folder",
                                   pnl.source.text);
    }
    if (source) {
      pnl.source.text = source.fsName;
    }
  } catch (e) {
    alert(e.toSource());
  }
};
FlattenUI.destBrowse = function() {
  try {
    var pnl = this.parent;
    var fileMode = pnl.file.value;
    var dest;
    var f = pnl.dest.text;
    if (!f) {
      if (pnl.source.text) {
        f = File(pnl.source.text).parent;
      }
    }
    if (fileMode) {
      var fsel = XStdlib.createFileSelect("Javascript Files: *.jsx;*.js,All Files:*.*");
      dest = XStdlib.selectFileSave("Select an destination File", fsel, f);
    } else {
      dest = XStdlib.selectFolder("Select an destination Folder", f);
    }
    if (dest) {
      pnl.dest.text = dest.fsName;
    }
  } catch (e) {
    alert(e.toSource());
  }
};

FlattenUI.prototype.validatePanel = function(pnl) {
  var self = this;

  try {
    var opts = new FlattenOptions();

    if (pnl.file.value) {
      opts.mode = 'File';
    } else {
      opts.mode = 'Folder';
    }
    var fileMode = (opts.mode == 'File');

    var f;
    if (pnl.source.text) {
      f = File(pnl.source.text);
    }
    if (!f || !f.exists) {
      return self.errorPrompt("Source not found");
    }
    if ((f instanceof File && opts.mode == 'Folder') ||
        (f instanceof Folder && opts.mode == 'File')) {
      return self.errorPrompt("Source must be a " +
                              (fileMode ? "File" : "Folder"));
    }
    opts.source = decodeURI(f.fsName);

    f = undefined;
    if (pnl.dest.text) {
      f = File(pnl.dest.text);
      if (fileMode) {
        if (f instanceof File) {
          if (!f.open("w")) {
            return self.errorPrompt("Unable to open file:" + f.fsName);
          }
          f.close();
        } else {
          if (opts.source.parent.toString() == f.toString()) {
            return self.errorPrompt("Source and Destination must be different");
          }
          f = new File(f + '/' + opts.source.name);
        }
      } else {
        if (!f.exists) {
          if (f.create()) {
            return self.errorPrompt("Unable to create Folder:" + f.fsName);
          }
        }
      }
    }
    if (!f) {
      return self.errorPrompt("Destination must be specified");
    }
    opts.dest = decodeURI(f.fsName);

    if (opts.dest.toString() == opts.source.toString()) {
      return self.errorPrompt("Source and Destination must be different");
    }

    pnl.opts = opts;

  } catch (e) {
    alert(e.toSource());
    return false;
  }

  return opts;
};

FlattenUI.prototype.process = function(opts) {
  if (!opts) {
    return;
  }

  var start = new Date().getTime();
  var f = new Flattener();

  if (opts.mode == 'File') {
    f.exec(new File(opts.source), new File(opts.dest));
  } else {
    f.folderExec(new Folder(opts.source), new Folder(opts.dest));
  }

  var stop = new Date().getTime();
  var elapsed = (stop - start)/1000;
  alert("Done (" + Number(elapsed).toFixed(3) + " secs).");
};


FlattenUI.main = function() {
  var ui = new FlattenUI();
  ui.exec();
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
    FlattenUI.main();
  };

  main();
}


"Flatten.js";
// EOF
