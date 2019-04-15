//
// ActionFileToJavascript
//
// $Id: ActionFileToJavascript.jsx,v 1.42 2010/03/29 02:23:23 anonymous Exp $
// Copyright: (c)2007, xbytor
// License: http://www.opensource.org/licenses/bsd-license.php
// Contact: xbytor@gmail.com
//
//@show include
//

app;

//
//@includepath "/c/Program Files/Adobe/xtools;/Developer/xtools"
//
//@include "xlib/PSConstants.js"
//@include "xlib/Stream.js"
//@include "xlib/stdlib.js"
//@include "xlib/GenericUI.jsx"
//@include "xlib/Action.js"
//@include "xlib/xml/atn2bin.jsx"
//@include "xlib/xml/atn2js.jsx"
//
//@include "xlib/ActionStream.js"
//@include "xlib/ieee754.js"
//

ActionFileToJavascriptOptions = function(obj) {
  var self = this;

  self.source = '';
  self.outf = '';
  self.singleFile = true;
  Stdlib.copyFromTo(obj, self);
};

ActionFileToJavascriptUI = function() {
  var self = this;

  self.title = 'Action File To Javascript Translator';
  self.notesSize = 100;
  self.winRect = {
    x: 200,
    y: 200,
    w: 680,
    h: 350
  };

  self.documentation =
    "This script translates an action file into executable javascript. You " +
    "may have the action file translated in to a single file containing a " +
    "javascript function for all of the actions, or you may specify that an " +
    "executable javascript file be generated for each action in the action " +
    "file. If nothing is specified in the output field, the file(s) will be " +
    "written into the same directory as the action file.";

  self.iniFile = "atj.ini";
};
ActionFileToJavascriptUI.prototype = new GenericUI();
ActionFileToJavascriptUI.LOG_FILE = "~/atj.log";

ActionFileToJavascriptUI.prototype.createPanel = function(pnl, ini) {
  var xOfs = 10;
  var yy = 10;

  ini = new ActionFileToJavascriptOptions(ini);

  var xx = xOfs;
  pnl.add('statictext', [xx,yy,xx+80,yy+20], 'Action File:');
  xx += 80;
  pnl.source = pnl.add('edittext', [xx,yy,xx+520,yy+20], ini.source);
  xx += 525;
  pnl.sourceBrowse = pnl.add('button', [xx,yy,xx+30,yy+20], '...');

  yy += 40;
  xx = xOfs;

  pnl.add('statictext', [xx,yy,xx+80,yy+20], 'Destination:');
  xx += 80;
  pnl.outf = pnl.add('edittext', [xx,yy,xx+520,yy+20], ini.outf);
  xx += 525;
  pnl.outfBrowse = pnl.add('button', [xx,yy,xx+30,yy+20], '...');

  yy += 50;
  xx = xOfs;

  pnl.separateFiles = pnl.add('radiobutton', [xx,yy,xx+200,yy+20],
                           'All Actions in Separate Files');

  xx += 220;

  pnl.singleFile = pnl.add('radiobutton', [xx,yy,xx+200,yy+20],
                           'All Actions in a Single File');

  pnl.sourceBrowse.onClick = ActionFileToJavascriptUI.sourceBrowse;
  pnl.outfBrowse.onClick = ActionFileToJavascriptUI.outfBrowse;

  if (toBoolean(ini.singleFile)) {
    pnl.singleFile.value = true;
  } else {
    pnl.separateFiles.value = true;
  }

  yy += 35;
  xx = xOfs;

  pnl.symbols = pnl.add('checkbox', [xx,yy,xx+200,yy+20], 'Use Symbols');
  pnl.symbols.value = toBoolean(ini.symbols);

  return pnl;
};

ActionFileToJavascriptUI.sourceBrowse = function() {
  var pnl = this.parent;
  var fsel = Stdlib.createFileSelect("ATN files: *.atn");
  var f = Stdlib.selectFileOpen("Select an Action File",
                                fsel,
                                pnl.source.text);
  if (f) {
    pnl.source.text = f.fsName;
    if (!pnl.outf.text) {
      pnl.outf.text = f.parent.fsName;
    }
  }
};
ActionFileToJavascriptUI.outfBrowse = function() {
  var pnl = this.parent;
  var f;
  var def = pnl.outf.text;
  if (!def && pnl.source.text) {
    def = Folder(pnl.source.text).parent;
  }
  if (pnl.singleFile.value) {
    var fsel = Stdlib.createFileSelect("Javascript: *.js;*.jsx");
    var f = Stdlib.selectFileSave("Select a Destination File",
                                  fsel,
                                  def);
  } else {
    var f = Stdlib.selectFolder("Select a Destination Folder", def);
  }
  if (f) {
    pnl.outf.text = f.fsName;
  }
};

ActionFileToJavascriptUI.prototype.validatePanel = function(pnl) {
  //$.level = 1; debugger;
  var self = this;

  try {
    var opts = new ActionFileToJavascriptOptions();

    var f;
    if (pnl.source.text) {
      f = new File(pnl.source.text);
      if (!f.exists) {
        return self.errorPrompt("Action file not found");
      }
    } else {
      return self.errorPrompt("Action file must be specified");
    }

    opts.source = f.toUIString();
    opts.singleFile = pnl.singleFile.value;
    opts.symbols = pnl.symbols.value;

    f = undefined;

    if (pnl.outf.text) {
      if (opts.singleFile) {
        f = File(pnl.outf.text);
        if (f.exists && f instanceof Folder) {
          var tf = File(opts.source);
          var nm = tf.name.replace(/\.[^\.]+$/, ".jsx");
          f = new File(f + '/' + nm);
        }
      } else {
        f = Folder(pnl.outf.text);
        if (f.exists && f instanceof File) {
          return self.errorPrompt("Destination folder is already a file");
        }
      }
    } else {
      if (opts.singleFile) {
        var nm = opts.source.name.replace(/\.[^\.]+$/, ".jsx");
        f = new File(opts.source.parent + '/' + nm);
      } else {
        f = opts.source.parent;
      }
    }
    opts.outf = f.toUIString();

  } catch (e) {
    alert(e + '@' + e.line);
    return false;
  }

  return opts;
};

ActionFileToJavascriptUI.prototype.process = function(opts) {
  if (!opts) {
    return;
  }

  Stdlib.log.enabled = false;
  Stdlib.log.filename = ActionFileToJavascriptUI.LOG_FILE;

  Stdlib.log("ActionFileToJavascript Start");
  Stdlib.log(listProps(opts));
  var start = new Date().getTime();
  var actFile = new ActionFile();

  actFile.read(new File(opts.source));

  if (opts.singleFile) {
    var jw  = new JSWriter();
    jw.symbols = toBoolean(opts.symbols);
    jw.writeScript(actFile, new File(opts.outf));

  } else {
    var outf = new Folder(opts.outf);
    Stdlib.createFolder(outf);
    if (!outf.exists && !outf.create()) {
      throwFileError(outf, "Unable to create folder");
    }

    var set = actFile.actionSet;
    for (var i = 0; i < set.count; i++) {
      var act = set.actions[i];
      var nm = JSWriter.massageName(act.name);
      var f = new File(outf + '/' + nm + ".jsx");
      var jw  = new JSWriter();
      jw.symbols = toBoolean(opts.symbols);
      jw.writeScript(act, f, nm);
    }
  }
  var stop = new Date().getTime();
  var elapsed = (stop - start)/1000;
  var msg  = ("Done (" + Number(elapsed).toFixed(3) + " secs).");
  Stdlib.log(msg);
  alert(msg);
};

function main() {
  // PS7 and CS
  if (isPS7() || isCS()) {
    alert("Because of missing Javascript APIs, reading binary action files " +
          "is currently only supported in CS2. Support for CS and possibly " +
          "PS7 may become available in the future.");
    return;
  }

  var opts;
// When I get the ActionFile reader working for PS7, this is where
// the UI options can be set.
//   if (isPS7()) {
//     opts = new ActionFileToJavascriptOptions();
//     opts.singleFile = false;
//     opts.source = new File("/c/work/XActions/Rotate.atn");
//     opts.outf = new Folder("/c/work/XActions/outf");
//    };
//   }

  var ui = new ActionFileToJavascriptUI();
  ui.exec();
};

main();

"ActionFileToJavascript.jsx";
// EOF
