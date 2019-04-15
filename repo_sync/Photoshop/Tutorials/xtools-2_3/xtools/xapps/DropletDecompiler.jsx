//
// DropletDecompiler
//   Ever need to decompile a droplet to recover the Action is was contructed
//   from? Then this is the script for you. Coming soon, a Droplet compiler.
//
// $Id: DropletDecompiler.jsx,v 1.24 2015/07/17 17:20:20 anonymous Exp $
// Copyright: (c)2005, xbytor
// License: http://www.opensource.org/licenses/bsd-license.php
// Contact: xbytor@gmail.com
//
//@includepath "/c/Program Files/Adobe/xtools;/Developer/xtools"
//
//@show include
//
app;
//
//@include "xlib/PSConstants.js"
//@include "xlib/stdlib.js"
//@include "xlib/Stream.js"
//@include "xlib/GenericUI.jsx"
//@include "xlib/Action.js"
//@include "xlib/xml/atn2bin.jsx"
//@include "xlib/xml/atn2js.jsx"
//
//@include "xlib/ActionStream.js"
//@include "xlib/ieee754.js"
//

DropletFile = function(infile) {
  var self = this;

  self.file = infile;
  self.action = undefined;
};
DropletFile.prototype.typename = "DropletFile";

DropletFile.prototype.decompile = function(infile) {
  var self = this;

  if (infile) {
    self.file = Stream.convertFptr(infile);
  }

  var str = Stream.readStream(self.file);

  self.action = new Action();
  try {
    self.action.readDroplet(str);

  } catch (e) {
    $.level = 1; debugger;
    if (isMac() && e.number == ATN_ERR) {
      var contents = Stream.convertFptr(self.file).parent.parent;
      var file = File(contents + "/Resources/Droplet.8BDR");
      var str = Stream.readStream(file);
      self.action = new Action();
      self.action.readDroplet(str);
    } else {
      Error.runtimeError(e.number, e.message);
    }
  }
  return self.action;
};

DecompilerOptions = function(opts) {
  var self = this;
  self.source = ''; // File
  self.output = ''; // File
  self.mode = 'atn';   // 'jsx' or 'atn'
  self.doAlert = true;
  Stdlib.copyFromTo(opts, self);
};

DecompilerUI = function() {
  var self = this;
  self.iniFile = "decompiledroplet.ini";
  self.title = "Droplet Decompiler";
  self.notesSize = 100;
  self.winRect = {
    x: 200,
    y: 200,
    w: 600,
    h: 320
  };
  self.documentation =
    "Droplets are created by 'compiling' an Action into an executable " +
    "program. This script does the reverse. It a takes droplet, decompiles " +
    "it, and extracts the Action from which it was created. This is " +
    "particularly useful when you have deleted an Action but still have its " +
    "droplet.";
};

DecompilerUI.prototype = new GenericUI();

DecompilerUI.prototype.createPanel = function(pnl, ini) {
  var self = this;

  ini = new DecompilerOptions(ini);

  var xOfs = 10;
  var yOfs = 10;
  var xx = xOfs;
  var yy = yOfs;

  // Source File
  pnl.add('statictext', [xx,yy,xx+100,yy+20], 'Droplet:');
  xx += 100;
  pnl.source = pnl.add('edittext', [xx,yy,xx+420,yy+20], ini.source);
  xx += 425;
  pnl.sourceBrowse = pnl.add('button', [xx,yy,xx+25,yy+20], '...');

  xx = xOfs;
  yy += 35;

  // Output File
  pnl.add('statictext', [xx,yy,xx+100,yy+20], 'Output File:');
  xx += 100;
  pnl.output = pnl.add('edittext', [xx,yy,xx+420,yy+20], ini.output);
  xx += 425;
  pnl.outputBrowse = pnl.add('button', [xx,yy,xx+25,yy+20], '...');

  xx = xOfs;
  yy += 35;


  // To Action/Javascript RadioButtons
  pnl.add('statictext', [xx,yy,xx+90,yy+20], 'Decompile to:');
  xx += 100;
  pnl.atn = pnl.add('radiobutton', [xx,yy,xx+90,yy+20], 'Action');
  xx += 100;
  pnl.jsx = pnl.add('radiobutton', [210,yy,310,yy+20], 'Javascript');

  xx = xOfs;
  yy += 35;

  if (ini.mode.toLowerCase() == 'jsx') {
    pnl.jsx.value = true;
  } else {
    pnl.atn.value = true;
  }

  pnl.atn.onClick = DecompilerUI.atnClick;
  pnl.jsx.onClick = DecompilerUI.jsxClick;

  pnl.sourceBrowse.onClick = DecompilerUI.sourceBrowse;
  pnl.outputBrowse.onClick = DecompilerUI.outputBrowse;

  return pnl;
};
DecompilerUI.atnClick = function() {
  var pnl = this.parent;
  if (pnl.output.text) {
    pnl.output.text = pnl.output.text.replace(/\.[^\.\/]+$/, ".atn");
  }
};
DecompilerUI.jsxClick = function() {
  var pnl = this.parent;
  if (pnl.output.text) {
    pnl.output.text = pnl.output.text.replace(/\.[^\.\/]+$/, ".jsx");
  }
};
DecompilerUI.sourceBrowse = function() {
  var pnl = this.parent;
  var exemask = Stdlib.createFileSelect("Droplet File: *.exe, All files:*.*");
  var start = Stdlib.convertFptr(pnl.source.text).parent || Folder.current;
  if (isMac()) {
    // var f = Stdlib.selectFileOpen("Select a Droplet", "", start);
    var f = File.openDialog("Select a Droplet");
  } else {
    var f = Stdlib.selectFileOpen("Select a Droplet", exemask, start);
  }

  if (f) {
    pnl.source.text = decodeURI(f);
    var out = pnl.output.text;
    if (!out) {
      pnl.output.text = pnl.source.text.replace(/\.[^\.\/]+$/,
                                                (pnl.atn.value ?
                                                 ".atn" : ".jsx"));
    }
  }
};
DecompilerUI.outputBrowse = function() {
  var pnl = this.parent;

  var atn = {
    mask: Stdlib.createFileSelect("Action File: *.atn, All files:*"),
    prompt: "Select an Action File",
    ext: 'atn'
  };
  var jsx = {
    mask: Stdlib.createFileSelect("Javascript File: *.js;*.jsx, All files:*"),
    prompt: "Select a Javascript File",
    ext: 'jsx'
  };

  var ftype = (pnl.atn.value ? atn : jsx);

  var start;
  if (pnl.output.text) {
    start = pnl.output.text;
  } else if (pnl.source.text) {
    start = pnl.source.text.replace(/\.[^\.]+$/, '.' + ftype.ext);
  } else {
    start = Folder.current;
  }
  var f = Stdlib.selectFileSave(ftype.prompt, ftype.mask, start);
  if (f) {
    var nm = decodeURI(f);
    if (!nm.match(/\.[^\.]+$/)) {
      nm += '.' + ext;
    }
    pnl.output.text = nm;
  }
};


DecompilerUI.prototype.validatePanel = function(pnl) {
  var self = this;
  pnl.opts = undefined;

  var opts = new DecompilerOptions();

  opts.mode = (pnl.atn.value ? 'atn' : 'jsx');

  var f;
  if (pnl.source.text) {
    f = new File(pnl.source.text);
  }
  if (!f || !f.exists) {
    alert("Source file path not found");
    return true;
  }
  opts.source = decodeURI(f);
  f = undefined;

  if (pnl.output.text) {
    f = new File(pnl.output.text);
  }
  if (!f || !f.parent.exists) {
    alert("Output file path not found");
    return true;
  }
  opts.output = decodeURI(f);

  pnl.opts = opts;

  return opts;
};

DecompilerUI.prototype.process = function(opts) {
  if (!opts) {
    return;
  }

  var start = new Date().getTime();

  var droplet;
  // if this is a MacOS packaged...
  if (isMac() && File(opts.source).getFiles) {
    droplet = new DropletFile(File(opts.source + "/Contents/MacOS/Droplet"));
  } else {
    droplet = new DropletFile(opts.source);
  }

  var act;
  try {
    act = droplet.decompile();
  } catch (e) {
    var str = Stdlib.exceptionMessage(e);
    alert(str);
    return;
  }

  if (opts.mode == 'atn') {
    var actFile = new ActionFile();
    actFile.actionSet = new ActionSet();
    actFile.actionSet.name = "Droplet";  // this actually doesn't matter
    actFile.actionSet.add(act);
    actFile.write(opts.output);

  } else if (opts.mode == 'jsx') {
    var nm = JSWriter.massageName(act.name);
    var jw  = new JSWriter();
    jw.writeScript(act, opts.output, nm);
  }

  var stop = new Date().getTime();
  var elapsed = (stop - start)/1000;
  if (opts.doAlert) {
    alert("Done (" + Number(elapsed).toFixed(3) + " secs).");
  }
};

DecompilerUI.decompile = function(source, output, mode) {
  var obj = {
    mode: mode,
    source: source,
    output: output,
    doAlert: false
  };
  var ui = new DecompilerUI();
  ui.process(obj);
};


DecompilerUI.main = function() {
  if (CSVersion() < 2) {
    alert("Because of missing Javascript APIs, reading binary action files " +
          "is currently only supported in CS2. Support for CS and possibly " +
          "PS7 may  become available in the future.");
    return;
  }

  var ui = new DecompilerUI();
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
    DecompilerUI.main();
  };

  main();
}

"DropletDecompiler.jsx";
// EOF
