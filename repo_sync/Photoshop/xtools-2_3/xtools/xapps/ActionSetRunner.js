//
// ActionSetRunner
// For lack of a better name for this script, I am calling it an Action
// Set Runner.
//
// Here's how it works:
// 1) Open up an image
// 2) This script will pop up a prompt for you to specify an Action Set name.
//    This really needs to be replace with a Selection List UI.
// 3) The script will step through and execute each Action in the set
//    individually.
// 4.1) In Batch Mode, it will save the result of each Action to a file
// 4.2) In Interactive Mode it will display the result and ask you it you want
//      to continue or not.
// 5) After each Action, it does an 'undo' back to the original image and
//    moves on to the next Action.
//
// The files are stored in a subdirectory with the Action Set's name beneath
// the document's directory. The files are have the name of the action
// inserted before the extension.
//
// To test this out, open an image and choose the Image Effects action set
// that comes with CS/CS2.
//
// A set of Frame actions would be well suited for this. I am frequently
// wondering what the best frame from my collection of frame actions would be
// most appropriate for a given image.
//
// There is one configuration variable called 'batchMode' to control whether
// it runs in Batch Mode or Interactive Mode.
//
// The one thing that does present a problem is that some actions require
// some kind of setup (like an active selection) or they require interaction.
// The requirement for interaction makes the batch mode somewhat useless.
//
// Another problem is that the actions cannot call scripts.
//
// Things that would be nice to have are a pulldown list for selecting the
// action set and a bunch of check boxes for selection the actions that you
// want to run instead of having all of them in the set run.
//
// Note that this could easily be changed to run all of the actions in a set
// consecutively on an image instead of doing an 'Undo' after each step.
//
// $Id: ActionSetRunner.js,v 1.24 2014/11/27 05:51:24 anonymous Exp $
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
//@include "xlib/stdlib.js"
//@include "xlib/GenericUI.jsx"
//

RunnerOptions = function(obj) {
  Stdlib.copyFromTo(obj, this);
};
RunnerOptions.prototype.typename = 'RunnerOptions';

// actionSetName must be the name of an ActionSet loaded in PS
RunnerOptions.prototype.setName = "Image Effects";

// actions must be the names of the actions selected.
RunnerOptions.prototype.actions = "Blizzard,Aged Photo";

// If batch mode is true, all actions in the set are run.
// If false, a Confirm will popup after each action
// Currently not used
//RunnerOptions.prototype.batchMode = true;

// If sequential is true, the actions selected will be run in sequence
// If false, they are run independently
RunnerOptions.prototype.sequential = false;

// This is the output folder. If it is not specified in the UI,
// one is created with the name of the action set as a subdirectory of the
// path of the original directory
RunnerOptions.prototype.outf = undefined;

RunnerOptions.SNAPSHOT_NAME = 'SetRunner';

RunnerUI = function() {
  var self = this;

  self.title = 'Action Set Runner';
  self.notesSize = 130;
  self.winRect = {
    x: 200,
    y: 200,
    w: 500,
    h: 660
  };
  self.documentation =
    "This script provides a way to run one or more actions from an action " +
    "set on the current document. The actions may be run one at a time " +
    "(with each version saved) or sequentially (with one file saved at " +
    "the end). If an output folder (by default) is not specified, the " +
    "file(s) are saved in a subdirectory with the Action Set's name " +
    "beneath the subdirectory in which the current document was found.";

  self.iniFile = "asr.ini";
  self.center = true;
};

RunnerUI.prototype = new GenericUI();

RunnerUI.prototype.createPanel = function(pnl, ini, doc) {
  var ini = new RunnerOptions(ini);

  var xOfs = 20;
  var yOfs = 20;
  var yy = yOfs;
  var xx = xOfs;

  var sets = Stdlib.getActionSets();
  pnl.sets = sets;

  if (sets.length == 0) {
    alert("No action sets available");
    return;
  }

  pnl.add('statictext', [xx, yy, xx+200, yy+20], 'Select an Action Set');
  xx += 230;
  pnl.add('statictext', [xx, yy, xx+250, yy+20], 'Select one or more Actions');
  xx = xOfs;
  yy += 30;

  pnl.aslist = pnl.add('listbox', [xx, yy, xx+200, yy+300]);
  pnl.aslist.multiselect = false;

  var litems = [];
  for (var i = 0; i < sets.length; i++) {
    var set = sets[i];
    pnl.aslist[set.name] = pnl.aslist.add('item', set.name);
    pnl.aslist[set.name].set = set;
  }

  xx += 230;

  pnl.alist = pnl.add('listbox', [xx, yy, xx+200, yy+300], [],
                      {multiselect:true});

  yy += 320;
  xx = xOfs;

  pnl.add('statictext', [xx, yy, xx+140, yy+20], 'Process Actions:');

  xx += 140;

  pnl.independent = pnl.add('radiobutton', [xx,yy,xx+130,yy+20],
                           'Independently');
  xx += 130;
  pnl.sequential = pnl.add('radiobutton', [xx,yy,xx+130,yy+20],
                           'Sequentially');

  if (toBoolean(ini.sequential)) {
    pnl.sequential.value = true;
  } else {
    pnl.independent.value = true;
  }

  yy += 40;
  xx = xOfs;

  pnl.add('statictext', [xx,yy,xx+90,yy+20], 'Output Folder:');
  xx += 100;
  pnl.outf = pnl.add('edittext', [xx,yy,xx+300,yy+20], ini.outf);
  xx += 305;
  pnl.outfBrowse = pnl.add('button', [xx,yy,xx+25,yy+20], '...');
  yy += 30;
  xx = xOfs;

  pnl.aslist.onChange = RunnerUI.actionListChange;
  pnl.outfBrowse.onClick = RunnerUI.outfBrowse;

  if (ini.setName) {
    if (pnl.aslist[ini.setName]) {
      pnl.aslist[ini.setName].selected = true;
      pnl.aslist.selection = pnl.aslist[ini.setName];
      
      if (ini.actions) {
        pnl.defaultActions = ini.actions;
      }
    } else {
      pnl.aslist.items[0].selected = true;
      pnl.aslist.selection = pnl.aslist.items[0];
    }
  }

  if (CSVersion() > 2) {
    pnl.aslist.onChange();
  }

  return pnl;
};
RunnerUI.actionListChange = function() {
  var self = this;
  var pnl = self.parent;

  pnl.alist.removeAll();
  var set = pnl.aslist.selection.set;
  for (var i = 0; i < set.count; i++) {
    pnl.alist.add('item', set.actions[i]);
  }

  if (pnl.defaultActions) {
    var acts = pnl.defaultActions;
    pnl.defaultActions = undefined;

    //$.level = 1; debugger;
    if (acts.constructor == String) {
      acts = acts.split(',');
    }
    var actsMap = {};
    for (var i = 0; i < acts.length; i++) {
      actsMap[acts[i]] = true;
    }
    var cnt = 0;
    var items = pnl.alist.items;
    for (var i = 0; i < items.length; i++) {
      if (actsMap[items[i].text]) {
        items[i].selected = true;
        cnt++;
      }
    }
    if (!cnt) {
      pnl.alist.items[0].selected = true;
    }

  } else if (set.count) { // if there are no default acts
    pnl.alist.items[0].selected = true;
  }
};
RunnerUI.outfBrowse = function() {
  var pnl = this.parent;
  var def = pnl.outf.text || Folder.current;

  var folder = Stdlib.selectFolder("Select destination folder", def);
  if (folder) {
    pnl.outf.text = folder.fsName;
  }
};

RunnerUI.prototype.validatePanel = function(pnl) {
  var self = this;

  try {
    var opts = new RunnerOptions();

    opts.setName = pnl.aslist.selection.text;

    opts.actions = [];
    var items = pnl.alist.items
    for (var i = 0; i < items.length; i++) {
      if (items[i].selected) {
        opts.actions.push(items[i].text);
      }
    }

    if (opts.actions.length == 0) {
      return self.errorPrompt("No Action Selected");
    }

    opts.sequential = pnl.sequential.value;

    var f = undefined;
    if (pnl.outf.text) {
      f = new Folder(pnl.outf.text);
      if (!f.exists && !f.create()) {
        return self.errorPrompt("Cannot find or create folder '" + f + "'"
                                + f.error);
      }
    } else {
      if (!opts.sequential && opts.actions.length > 1) {
        return self.errorPrompt("Output folder must be specified.");
      }
    }

    opts.outf = f;

    pnl.opts = opts;

  } catch (e) {
    alert(e.toSource());
    return false;
  }

  return opts;
};

RunnerUI.prototype.process = function(opts, doc) {
  if (!opts) {
    return;
  }

  var multiImage = true;
  var setName = opts.setName.replace(/[\W]/g, '-');
  setName = setName.replace(/[_]+$/, '');
  opts.sequential = toBoolean(opts.sequential);
  var actions = opts.actions;

  if (actions.constructor == String) {
    actions = actions.split(',');
  }

  var folder;
  if (!opts.outf) {
    if (!opts.sequential && actions.length > 1) {
      folder = new Folder(doc.path + '/' + setName);
      if (!folder.exists) {
        folder.create() || throwError(folder.error);
      }
    } else {
      multiImage = false;
    }
  } else {
    folder = new Folder(opts.outf.toString());
  }

  var name = doc.name;
  var idx  = name.lastIndexOf('.');
  var base = name.substr(0, idx);
  var ext  = name.substr(idx);
  var saveOpts;
  if (ext.toLowerCase() == '.jpg') {
    saveOpts = new JPEGSaveOptions();
    saveOpts.quality = 10;
  }

  Stdlib.takeSnapshot(doc);

  if (multiImage) {
    try {
      Stdlib.deleteSnapshot(doc, RunnerOptions.SNAPSHOT_NAME);
    } catch (e) {
    }

    Stdlib.takeSnapshot(doc, RunnerOptions.SNAPSHOT_NAME);
  }

  try {
    if (opts.sequential) {
      var save = true;
      for (var i = 0; i < actions.length; i++) {
        var act = actions[i];
        try {
          if (!runAction(act, opts.setName)) {
            if (!confirm("Action: " + opts.setName + ':' +
                         act + " Failed\rContinue?")) {
              save = false;
              break;
            }
          }
        } catch (e) {
          svae = false;
        }
      }
      if (multiImage) {
        if (save) {
          var file = new File(folder + '/' + base + '-' + setName + ext);
          doc.saveAs(file, saveOpts, true);
        }

        Stdlib.revertToSnapshot(doc, RunnerOptions.SNAPSHOT_NAME);
      }
      
    } else {
      var save = true;
      for (var i = 0; i < actions.length; i++) {
        var act = actions[i];
        if (runAction(act, opts.setName)) {
          if (multiImage) {
            var file = new File(folder + '/' + base + '-' + act + ext);
            file = Stdlib.cleanFileName(file);
            doc.saveAs(file, saveOpts, true);
          }
        }
        if (multiImage) {
          Stdlib.revertToSnapshot(doc, RunnerOptions.SNAPSHOT_NAME);
        }
      }
    }
  } finally {
    if (multiImage) {
      Stdlib.revertToSnapshot(doc, RunnerOptions.SNAPSHOT_NAME);
      Stdlib.deleteSnapshot(doc, RunnerOptions.SNAPSHOT_NAME);
    }
  }
};

function main() {
  if (app.documents.length == 0) {
    alert("Please open a document before running this script.");
    return;
  }

  var doc = app.activeDocument;
  var ui = new RunnerUI();
  ui.exec(doc);
  return;
};

main();

"ActionSetRunner.js";
// EOF
