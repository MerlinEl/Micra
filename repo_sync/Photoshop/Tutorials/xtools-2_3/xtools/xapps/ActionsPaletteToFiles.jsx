//
// ActionsPaletteToFiles
//
// $Id: ActionsPaletteToFiles.jsx,v 1.12 2012/06/15 00:50:23 anonymous Exp $
// Copyright: (c)2005, xbytor
// License: http://www.opensource.org/licenses/bsd-license.php
// Contact: xbytor@gmail.com
//
//@show include
//
//@includepath "/c/Program Files/Adobe/xtools;/Developer/xtools"
//
//@include "xlib/PSConstants.js"
//@include "xlib/Stream.js"
//@include "xlib/stdlib.js"
//@include "xlib/Action.js"
//@include "xlib/ActionStream.js"
//@include "xlib/ActionSelector.jsx"
//@include "xlib/xml/atn2bin.jsx"
//

ExportPaletteOptions = function() {
  var self = this;
  self.source = null; // palette File
  self.output = null; // target Folder
};

ExportPaletteUI = function() {
};
ExportPaletteUI.prototype.createWindow = function() {
  var self = this;
  var winH = 150;
  var winW = 495;
  var winX = 200;
  var winY = 200;
  var win = new Window('dialog', "Actions Palette Extractor",
                       [winX, winY, winX+winW, winY+winH]);

  var yy = 20;

  // Source File
  var defPalette = '';
  if (app.preferencesFolder) {
    defPalette = new File(app.preferencesFolder +
                          "/Actions Palette.psp").fsName;
  }

  win.sourceText = win.add('statictext', [10,yy,100,yy+20],
                           'Actions Palette:');
  win.source = win.add('edittext', [100,yy,450,yy+20], defPalette);
  win.sourceBrowse = win.add('button', [455,yy,485,yy+20], '...');
  yy += 30;

  win.sourceBrowse.onClick = function() {
    var win = this.parent;
    var exemask = "Actions Palette File: *.psp, All files:*";
    var start = win.source.text || Folder.current;
    var f = Stdlib.selectFile("Select an Actions Palette file", exemask, start);
    if (f) {
      win.source.text = f.fsName;
    }
  };

  // Output Folder
  win.outputText = win.add('statictext', [10,yy,100,yy+20], 'Output Folder:');
  win.output = win.add('edittext', [100,yy,450,yy+20], '');
  win.outputBrowse = win.add('button', [455,yy,485,yy+20], '...');
  yy += 30;

  win.outputBrowse.onClick = function() {
    var win = this.parent;
    var start = win.output.text || Folder.current;
    var f = Stdlib.selectFolder("Actions Folder", start);
    if (f) {
      win.output.text = f.fsName;
    }
  };

  win.statusText = win.add('statictext', [10,yy,90,yy+20], 'Status:');
  win.statusText.visible = false;
  win.status = win.add('statictext', [90,yy,300,yy+20], '');
  yy += 30;

  var btnY = winH - 30;
  win.process   = win.add('button', [100,btnY,200,btnY+20], 'OK');
  win.cancel    = win.add('button', [300,btnY,400,btnY+20], 'Cancel');

  win.defaultElement = win.process;

  win.process.onClick = function() {
    var win = this.parent;
    var rc = win.validate(false);
    if (!rc) {
      this.parent.close(2);
    }
    if (typeof rc == "object") {
      win.exec();
    }
  };

  win.validate = function(close) {
    var win = this;
    win.opts = undefined;
    
    var opts = new ExportPaletteOptions();

    var f;
    if (win.source.text) {
      f = new File(win.source.text);
    }
    if (!f || !f.exists) {
      alert("Source file path not found");
      return true;
    }
    opts.source = f;
    f = undefined;

    if (win.output.text) {
      f = new Folder(win.output.text);
      if (!Stdlib.createFolder(f)) {
        alert("Output file path not found");
        return true;
      }
      Folder.current = f;
    }
    if (!f || !f.exists) {
      alert("Output path not found");
      return true;
    }
    opts.output = f;

    win.opts = opts;
    if (close) {
      win.close(1);
    }
    return opts;
  };

  win.exec = ExportPaletteUI.processCB;

  self.win = win;
  return win;
};
ExportPaletteUI.processCB = function() {
  var win = this;
  var opts = win.opts;
  opts.count = 1;
  function saveActionSet(actSet) {
    var opts = this.state;
    var actFile = new ActionFile();
    actFile.actionSet = actSet;
    var nm = actSet.name;
    if (!nm.match(/\.atn$/i)) {
      nm += ".atn";
    }
    actFile.file = new File(opts.output + '/' + nm);
    win.status.text = "writing " + actFile.file.name + "...";
    Stdlib.log("writing " + actFile.file.name + "...");
    try {
      actFile.write();
    } catch (e) {
      Stdlib.logException(e, "failed writing " + actFile.file.name);
    }
    opts.count++;
    win.status.text = "reading action set #" + opts.count + "...";
  }

  var itr = new ActionsPaletteIterator(opts);
  itr.exec = saveActionSet;
  win.statusText.visible = true;
  var palFile = ActionsPaletteFile.iterateOverFile(opts.source, itr);
  win.status.text = 'Done';
  win.process.text = 'Done';
  win.process.onClick = win.close(1);
  win.opts = undefined;
};

ExportPaletteUI.prototype.run = function() {
  var self = this;
  var win = self.createWindow();
  win.show();
  return win.opts;
};

function main() {
  if (CSVersion() < 2) {
    alert("Because of missing Javascript APIs, reading binary action files " +
          "is currently only supported in CS2+. Support for CS and possibly " +
          "PS7 may  become available in the future.");
    return;
  }

  var test = false;
  var opts;

  Stdlib.log.setFile(Stdlib.PREFERENCES_FOLDER + "/stdout.log");
  Stdlib.log("ExportPalette");

  if (!test) {
    var ui = new ExportPaletteUI();
    var opts = ui.run();
  } else {
    opts = {
      source: new File(app.preferencesFolder + "/Actions Palette.psp"),
      output: new Folder("/c/temp")
    };
  }

  if (!opts) {
    return;
  }

  function saveActionSet(actSet) {
    var opts = this.state;
    var actFile = new ActionFile();
    actFile.actionSet = actSet;
    var nm = actSet.name;
    if (!nm.match(/\.atn$/i)) {
      nm += ".atn";
    }
    actFile.file = new File(opts.output + '/' + nm);
    $.writeln('writing ' + actFile.file);
    try {
      actFile.write();
    } catch (e) {
    }
  }
  var itr = new ActionsPaletteIterator(opts);
  itr.exec = saveActionSet;
  var palFile = ActionsPaletteFile.iterateOverFile(opts.source, itr);

  return;

  var palFile = ActionsPaletteFile.readFrom(opts.source);

  var pal = palFile.actionsPalette;
  var actSets = pal.actionSets;

  for (var i = 0; i < actSets.length; i++) {
    var actSet = actSets[i];
    var actFile = new ActionFile();
    actFile.actionSet = actSet;
    var nm = actSet.name;
    if (!nm.match(/\.atn$/i)) {
      nm += ".atn";
    }
    actFile.file = new File(opts.output + '/' + nm);
    $.writeln('writing ' + actFile.file);
    actFile.write();
  }
};

main();

"ActionsPaletteToFiles.jsx";
// EOF
