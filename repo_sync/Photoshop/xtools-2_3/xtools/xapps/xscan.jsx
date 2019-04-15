#target photoshop
//
// xscan.jsx
//
// $Id: xscan.jsx,v 1.6 2010/03/29 02:23:23 anonymous Exp $
// Copyright: (c)2005, xbytor
// License: http://www.opensource.org/licenses/bsd-license.php
// Contact: xbytor@gmail.com
//
//@show include
//
//@includepath "/c/Program Files/Adobe/xtools;/Developer/xtools"
//
//@include "xlib/stdlib.js"
//@include "xlib/LogWindow.js"
//@include "xlib/GenericUI.jsx"
//

//============================ XScan ====================================
XScanOptions = function(obj) {
  var self = this;
  self.logFile        = "~/xscan.log";
  self.source         = undefined;
  self.scanSubfolders = true;
  self.moveBad = false;
  self.copyBad = false;
  self.badFolder = undefined;

  if (obj) {
    for (var idx in obj) {
      self[idx] = obj[idx];
    }
  }
};

XScan = function() {
  var self = this;

  self.title = "XScan";
  self.notesSize = 75;      // The height of our Notes panel
  self.winRect = {          // the size of our window
    x: 200, 
    y: 200,
    w: 520, 
    h: 500
  };
  self.documentation =
  ("This script scans a folder or hierarchy of folders and attempts " +
   "to open and close each image file. Any image file that cannot be " +
   "opened is logged and optionally moved to a 'bad' folder.");

  self.iniFile = XScan.INI_FILE;
  self.saveIni = true;
  self.hasBorder = true;

  self.processTxt = 'Scan';   // use Convert as name of the Process button
};

// make it a subclass of GenericUI
XScan.prototype = new GenericUI();

XScan.INI_FILE = Stdlib.PREFERENCES_FOLDER + "/xscan.ini"; 



// Here is where we create the components of our panel
XScan.prototype.createPanel = function(pnl, ini) {
  var self = this;
  var xOfs = 10;
  var yy = 10;

  var opts = new XScanOptions(ini);   // default values

  if (ini.uiX == undefined) {
    ini.uiX = ini.uiY = 100;
  }

  self.moveWindow(toNumber(opts.uiX), toNumber(opts.uiY));

  // Source Directory
  var xx = xOfs;
  pnl.add('statictext', [xx,yy,xx+110,yy+20], 'Source Directory:');
  xx += 110;
  pnl.source = pnl.add('edittext', [xx,yy,xx+320,yy+20], opts.source);
  xx += 325;
  pnl.sourceBrowse = pnl.add('button', [xx,yy,xx+30,yy+20], '...');

  if (!opts.source) {
    pnl.source.text = decodeURI(Folder.current.fsName);
  }
      
  // Scan Subfolders
  yy += 40;
  xx = xOfs;

  pnl.scanSubfolders = pnl.add('checkbox', [xx,yy,xx+220,yy+20],
                               "Scan Subfolders");
  pnl.scanSubfolders.value = toBoolean(opts.scanSubfolders);

  // Move Bad Images
  yy += 60;
  xx = xOfs;

  pnl.moveBad = pnl.add('checkbox', [xx,yy,xx+150,yy+20],
                        "Move Bad Images");
  pnl.moveBad.value = toBoolean(opts.moveBad);

  pnl.moveBad.onClick = function() {
    var pnl = this.parent;
    if (pnl.moveBad.value) {
      pnl.copyBad.value = false;
    }

    pnl.badFolder.enabled = pnl.badFolderLabel.enabled =
       pnl.badFolderBrowse.enabled =
    (pnl.moveBad.value || pnl.copyBad.value);
  }

  // Copy Bad Images
  xx += 150;

  pnl.copyBad = pnl.add('checkbox', [xx,yy,xx+150,yy+20],
                        "Copy Bad Images");
  pnl.copyBad.value = toBoolean(opts.copyBad);

  pnl.copyBad.onClick = function() {
    var pnl = this.parent;
    if (pnl.copyBad.value) {
      pnl.moveBad.value = false;
    }
    pnl.badFolder.enabled = pnl.badFolderLabel.enabled =
       pnl.badFolderBrowse.enabled =
    (pnl.moveBad.value || pnl.copyBad.value);
  }

  // Log File
  yy += 40;
  xx = xOfs;

  // Bad Images
  pnl.badFolderLabel = pnl.add('statictext', [xx,yy,xx+110,yy+20],
                                'Bad Images:');
  xx += 110;
  pnl.badFolder = pnl.add('edittext', [xx,yy,xx+320,yy+20], opts.badFolder);
  xx += 325;
  pnl.badFolderBrowse = pnl.add('button', [xx,yy,xx+30,yy+20], '...');

  if (!opts.badFolder) {
    pnl.badFolder.text = decodeURI(Folder.current.fsName);
  }

  pnl.copyBad.onClick();
  pnl.moveBad.onClick();


  // Log File
  yy += 60;
  xx = xOfs;
 
  pnl.add('statictext', [xx,yy,xx+110,yy+20], 'Log File:');
  xx += 110;
  pnl.logFile = pnl.add('edittext', [xx,yy,xx+320,yy+20], opts.logFile);
  xx += 325;
  pnl.logFileBrowse = pnl.add('button', [xx,yy,xx+30,yy+20], '...');



  // now specify the callbacks for our controls

  pnl.sourceBrowse.onClick = function() {
    try {
      var pnl = this.parent;
      var def = (pnl.source.text ?
                 new Folder(pnl.source.text) : Folder.current); 

      var f = Stdlib.selectFolder("Select a Source folder", def);
      if (f) {
        pnl.source.text = decodeURI(f.fsName);
      }
    } catch (e) {
      alert(e);
    }
  }

  pnl.badFolderBrowse.onClick = function() {
    try {
      var pnl = this.parent;
      var def = (pnl.badFolder.text ?
                 new Folder(pnl.badFolder.text) : Folder.current); 

      var f = Stdlib.selectFolder("Select a Bad Images folder", def);
      if (f) {
        pnl.badFolder.text = decodeURI(f.fsName);
      }
    } catch (e) {
      alert(e);
    }
  }

  pnl.logFileBrowse.onClick = function() {
    try {
      var pnl = this.parent;
      var f;
      var def = pnl.logFile.text;

      if (!def) {
        def = "~/xscan.log";
      }

      var f = Stdlib.selectFile("Select a log file", undefined, def);

      if (f) {
        pnl.logFile.text = decodeURI(f.fsName);
      }
    } catch (e) {
      alert(e.toSource());
    }
  }

  return pnl;
};

//
// code for validating our panel
//
XScan.prototype.validatePanel = function(pnl, ini) {
  var self = this;

  var opts = new XScanOptions(); // our options object

  // Source Directory
  var f;
  if (pnl.source.text) {
    f = new Folder(pnl.source.text);
  }
  if (!f || !f.exists) {
      return self.errorPrompt("Source folder not found");
  }
  opts.source = decodeURI(f.fsName);

  opts.moveBad = pnl.moveBad.value;
  opts.copyBad = pnl.copyBad.value;


  if (opts.copyBad || opts.moveBad) {
    // Bad Folder
    var f;
    if (pnl.badFolder.text) {
      f = new Folder(pnl.badFolder.text);
    }
    if (!f || !f.exists) {
      return self.errorPrompt("Bad folder not found");
    }
    opts.badFolder = decodeURI(f.fsName);
  }
  
  // Log File
  if (pnl.logFile.text) {
    f = new File(pnl.logFile.text);
  }
  if (!f) {
    return self.errorPrompt("No Log file specified");
  }
  opts.target = decodeURI(f.fsName);

  opts.scanSubfolders = pnl.scanSubfolders.value;

  opts.uiX = self.winX;
  opts.uiY = self.winY;

  // return our valid options (if we made it this far)
  return opts;
};

function setCheckProfileMatch(state) {
  var desc = new ActionDescriptor();
  var ref = new ActionReference();
  ref.putProperty(cTID('Prpr'), sTID('colorSettings'));
  ref.putEnumerated(cTID('capp'), cTID('Ordn'), cTID('Trgt'));
  desc.putReference(cTID('null'), ref );
  var stDesc = new ActionDescriptor();
  stDesc.putBoolean(sTID('askMismatchOpening'), state);
  desc.putObject(cTID('T   '), sTID('colorSettings'), stDesc);
  executeAction(cTID('setd'), desc, DialogModes.NO);
};

function setCheckProfileMissing(state) {
  var desc = new ActionDescriptor();
  var ref = new ActionReference();
  ref.putProperty(cTID('Prpr'), sTID('colorSettings'));
  ref.putEnumerated(cTID('capp'), cTID('Ordn'), cTID('Trgt'));
  desc.putReference(cTID('null'), ref);
  var stDesc = new ActionDescriptor();
  stDesc.putBoolean(sTID('askMissing'), state);
  desc.putObject(cTID('T   '), sTID('colorSettings'), stDesc);
  executeAction(cTID('setd'), desc, DialogModes.NO );
};

XScan.prototype.process = function(opts) {
  var self = this;

  //alert(listProps(opts));

  var settings = app.colorSettings;

  try {
    self._process(opts);

  } finally {
    if (settings != "Custom" && app.colorSettings != settings) {
      app.colorSettings = settings;
    }
  }
};

XScan.prototype._process = function(opts) {
  var self = this;
  var isCustom = (app.colorSettings == "Custom");
  var cdesc = Stdlib.getApplicationProperty('colorSettings');

  var askMismatch = true;
  var askMissing = true;

  if (isCustom) {
    askMismatch = cdesc.getBoolean(sTID('askMismatchOpening'));
    askMissing = cdesc.getBoolean(sTID('askMissing'));
  }

  opts.scanSubfolders = toBoolean(opts.scanSubfolders);
  opts.moveBad = toBoolean(opts.moveBad);
  opts.copyBad = toBoolean(opts.copyBad);

  var source = new Folder(opts.source);
  if (!source.exists) {
    throw "Source folder does not exist.";
  }

  if (opts.moveBad || opts.copyBad) {
    var badFolder = new Folder(opts.badFolder);
    if (!badFolder.exists) {
      throw "Source folder does not exist.";
    }
  }

  var log = new File(opts.logFile);
  if (!log.open("w")) {
    throw "Unable to open log file.";
  }

  var files;

  if (opts.scanSubfolders) {
    files = Stdlib.findFiles(source, Stdlib.ImageFileExtsCompleteRE);
  } else {
    files = Stdlib.getFiles(source, Stdlib.ImageFileExtsCompleteRE);
  }

  //debugger;
  if (askMissing) {
    try {
      setCheckProfileMissing(false);
    } catch (e) {
      if (e.number != 8007) {  // user cancelled
        alert("askMissing: " + e);
      }
    }
  }
  if (askMismatch) {
    try {
      setCheckProfileMatch(false);
    } catch (e) {
      if (e.number != 8007) {  // user cancelled
        alert("askMismatch: " + e);
      }
    }
  }

  var failed = [];
  var ok = [];

  var broken = false;
  try {
    var errCnt = 0;

    for (var i = 0; i < files.length; i++) {
      var file = files[i];
      try {
        var doc = app.open(file);
        doc.close(SaveOptions.DONOTSAVECHANGES);
        ok.push(decodeURI(file.fsName));

      } catch (e) {
        failed.push(decodeURI(file.fsName));
        log.writeln(decodeURI(file.fsName));
        errCnt++;

        if (opts.copyBad || opts.moveBad) {
          var badFile = new File(opts.badFolder + "/" + file.name);
          var rc = file.copy(badFile);
          if (rc) {
            if (opts.moveBad) {
              rc = file.remove();
              if (!rc) {
                log.writeln("Failed to remove file: " + file.name);
              }
            }
          } else {
            log.writeln("Failed to copy file: " + file.name);
          }

          if (rc) {
            log.writeln("File " + file.name +
                        (opts.copyBad ? " copied." : " moved."));
          }
        }
      }
      if ((i & 7) == 7) {
        $.sleep(100);
      }
    }

  } catch (e) {
    alert(e);
    broken = true;

  } finally {
    if (isCustom) {
      if (askMismatch) {
        setCheckProfileMatch(true);
      }
      if (askMissing) {
        setCheckProfileMissing(true);
      }
    }
  }

  if (broken) {
    return;
  }

  log.close();
  var str = "Errors detected in " + errCnt + " files.\r\n";
  if (errCnt) {
    str += failed.join('\r\n') + '\r\n\r\n';
  }

  str += (files.length - errCnt) + " files passed.\r\n";
  str += ok.join('\r\n');

  var logWin = new LogWindow();
  logWin.show(str);

//   if (!errCnt) {
//     alert(files.length + " files found. No errors detected.");

//   } else {
//     alert(files.length + " files found. " + errCnt +
//           " error(s) detected.\r" +
//           "Please see " + decodeURI(log.fsName) +
//           " for a list of corrupt files.");
//   }
};


XScan.main = function() {
  var ui = new XScan();
  ui.exec();
  ui.updateIniFile({ uiX: ui.winX, uiY: ui.winY });
};

XScan.main();

"XScan";

// EOF
