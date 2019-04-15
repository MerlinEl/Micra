//
// SimpleUI.jsx
//   This is a simple UI that just collections some bits of information
//   and pops up an alert instead of doing anything usefule.
//
// $Id: SimpleUI.jsx,v 1.8 2010/03/29 02:23:23 anonymous Exp $
// Copyright: (c)2009, xbytor
// License: http://www.opensource.org/licenses/bsd-license.php
// Contact: xbytor@gmail.com
//
//@show include
//
app;
//
//@includepath "/c/Program Files/Adobe/xtools;/Developer/xtools"
//
//@include "xlib/stdlib.js"
//@include "xlib/GenericUI.jsx"
//

//
// This is the class that contains our options for this script
// The default values for this class are specified here
//
SimpleUIOptions = function(obj) {
  var self = this;

  self.source = '';    // the source folder
  self.target = '';    // the target/destination folder
  Stdlib.copyFromTo(obj, self);
};
SimpleUIOptions.prototype.typename = "SimpleUIOptions";

SimpleUIOptions.INI_FILE = Stdlib.PREFERENCES_FOLDER + "/simpleui.ini";
SimpleUIOptions.LOG_FILE = Stdlib.PREFERENCES_FOLDER + "/simpleui.log";

//
// SimpleUI is our UI class
//
SimpleUI = function() {
  var self = this;

  self.title = "Simple UI"; // our window title
  self.notesSize = 0;       // no notes
  self.winRect = {          // the size of our window
    x: 200,
    y: 200,
    w: 620,
    h: 360
  };
  self.documentation = undefined; // no notes/docs

  self.iniFile = SimpleUIOptions.INI_FILE;
  self.saveIni = true;
  self.optionsClass = SimpleUIOptions;
};

SimpleUI.prototype = new GenericUI(); // make it a subclass of GenericUI
SimpleUI.prototype.typename = "SimpleUI";

// Here is where we create the components of our panel
SimpleUI.prototype.createPanel = function(pnl, ini) {
  var self = this;
  var xOfs = 10;
  var yy = 10;

  var opts = new SimpleUIOptions(ini);   // default values

  if (ini.uiX == undefined) {
    ini.uiX = ini.uiY = 100;
  }

  // restore the window's location
  self.moveWindow(toNumber(opts.uiX), toNumber(opts.uiY));

  // Source Directory
  var xx = xOfs;
  pnl.sourceLabel = pnl.add('statictext', [xx,yy,xx+120,yy+20],
                            'Source Directory:');
  xx += 120;
  pnl.source = pnl.add('edittext', [xx,yy,xx+420,yy+20],
                       opts.source || '');
  xx += 425;
  pnl.sourceBrowse = pnl.add('button', [xx,yy,xx+30,yy+20], '...');

  pnl.sourceBrowse.onClick = function() {
    try {
      var pnl = this.parent;
      var def = (pnl.source.text ?
                 new Folder(pnl.source.text) : Folder.desktop);
      var f = Folder.selectDialog("Select a Source folder", def);

      if (f) {
        pnl.source.text = f.toUIString();
        if (!pnl.target.text) {
          pnl.target.text = pnl.source.text;
        }
      }
    } catch (e) {
      alert(Stdlib.exceptionMessage(e));
    }
  };

  yy += 40;
  xx = xOfs;

  // Target Directory
  pnl.targetLabel = pnl.add('statictext', [xx,yy,xx+120,yy+20],
                            'Target Directory:');
  xx += 120;
  pnl.target = pnl.add('edittext', [xx,yy,xx+420,yy+20],
                       opts.target || '');
  xx += 425;
  pnl.targetBrowse = pnl.add('button', [xx,yy,xx+30,yy+20], '...');

  pnl.targetBrowse.onClick = function() {
    try {
      var pnl = this.parent;
      var f;
      var def = pnl.target.text;
      if (!def) {
        if (pnl.source.text) {
          def = pnl.source.text;
        } else {
          def = Folder.desktop;
        }
      }
      var f = Stdlib.selectFolder("Select a destination folder", def);

      if (f) {
        pnl.target.text = f.toUIString();
      }
    } catch (e) {
      alert(Stdlib.exceptionMessage(e));
    }
  };

  yy += 43;
  xx = xOfs;

  // other UI components go here

  return pnl;
};

//
// code for validating our panel
//
SimpleUI.prototype.validatePanel = function(pnl, ini) {
  var self = this;

  var opts = new SimpleUIOptions(ini);

  // Source Directory, required
  var f;
  if (pnl.source.text) {
    f = new Folder(pnl.source.text);
  }
  if (!f || !f.exists) {
    return self.errorPrompt("Source folder not found");
  }
  opts.source = f.toUIString();

  // Target Directory, create if needed
  if (pnl.target.text) {
    f = new Folder(pnl.target.text);
    if (!f.exists) {
      if (!f.create()) {
        return self.errorPrompt("Unable to create target folder");
      }
    }
  }
  if (!f || !f.exists) {
    return self.errorPrompt("Target folder not found");
  }
  opts.target = f.toUIString();

  // stash window location
  opts.uiX = self.winX;
  opts.uiY = self.winY;

  return opts;
};

SimpleUI.prototype.process = function(opts, doc) {
  var self = this;

  Stdlib.log.setFile(SimpleUIOptions.LOG_FILE);
  Stdlib.log("Start");
  Stdlib.log("Properties:");
  Stdlib.log(listProps(opts));

  if (!opts.source) {
    var msg = "Source folder not specified.";
    Stdlib.log(msg);
    alert(msg);
    return;
  }
  var f = new Folder(opts.source);
  if (!f.exists) {
    var msg = "Unable to find source folder: " + f.toUIString();
    Stdlib.log(msg);
    alert(msg);
    return;
  }
  opts.source = f;

  if (!opts.target) {
    var msg = "Output folder not specified.";
    Stdlib.log(msg);
    alert(msg);
    return;
  }
  f = new Folder(opts.target);
  if (!f.exists) {
    if (!f.create()) {
      var msg = "Unable to create output folder: " + f.toUIString();
      Stdlib.log(msg);
      alert(msg);
      return;
    }
  }
  opts.target = f;

  var ru = app.preferences.rulerUnits;
  app.preferences.rulerUnits = Units.PIXELS;

  try {
    // alert(listProps(opts));

  } catch (e) {
    var msg = Stdlib.exceptionMessage(e);
    Stdlib.log(msg);
    alert(msg);

  } finally {
    app.preferences.rulerUnits = ru;
  }

  Stdlib.log("Stop");
};

// This version collects options via a window
SimpleUI.main = function() {
  var ui = new SimpleUI();
  var opts = {}; // {noUI: true};
  var doc = (app.documents.length > 0) ? app.activeDocument : undefined;

  ui.exec(opts, doc);
  ui.updateIniFile({ uiX: ui.winX, uiY: ui.winY });
};

SimpleUI.main();

"SimpleUI.jsx";
// EOF
