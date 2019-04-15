#target photoshop
//
// PackScript.jsx
//
// This script is used for packaging other scripts for clients.
// It does the following:
// - Checks the script into CVS with supplied message. (optional)
// - Flattens the file. The flattend file has the CVS version of the
//      file embedded in the filename.
// - Creates a zip file for the flattened file. (optional)
//
//
// $Id: PackScript.jsx,v 1.16 2011/09/05 09:49:16 anonymous Exp $
// Copyright: (c)2005, xbytor
// License: http://www.opensource.org/licenses/bsd-license.php
// Contact: xbytor@gmail.com
//
app;
//
//@show include
//
//@includepath "/c/Program Files/Adobe/xtools;/Developer/xtools"
//
//@include "xlib/stdlib.js"
//@include "xlib/GenericUI.jsx"
//@include "xlib/xexec.js"
//@include "xlib/fexec.js"
//@include "xapps/Flatten.js"
//

//
// This is the class that contains our options for this script
// The default values for this class are specified here
//
PackScriptOptions = function(obj) {
  var self = this;

  self.source = '';    // the source folder
  self.runzip = false;
  self.cvsmsg = 'nc';  // no comment
  self.runcvs = true;

  self.fileExt = '.jsx';

  // values in obj can override the values set above
  if (obj) {
    for (var idx in obj) {
      self[idx] = obj[idx];
    }
  }
};

//
// PackScript is our UI class
//
PackScript = function() {
  var self = this;

  self.title = "PackScript"; // our window title
  self.notesSize = 75;      // The height of our Notes panel
  self.winRect = {          // the size of our window
    x: 200, 
    y: 200,
    w: 620, 
    h: 280
  };
  self.documentation =
  ("This script checks a file into CVS, flattens the file, and zips " +
   "the flattened file for delivery to clients.");

  self.iniFile = "packscript.ini"; // our ini file name
  self.saveIni = true;
  self.hasBorder = true;

  self.processTxt = 'Pack';      // use 'Pack' as name of the Process button
};

// make it a subclass of GenericUI
PackScript.prototype = new GenericUI();

PackScript.CVS_ROOT = "-d:pserver:anonymous@localhost:/opt/cvsroot";

// Here is where we create the components of our panel
PackScript.prototype.createPanel = function(pnl, ini) {
  var xOfs = 10;
  var yy = 10;

  var opts = new PackScriptOptions(ini);   // default values

  // for our panel, we have a source directory input
  var xx = xOfs;
  pnl.add('statictext', [xx,yy,xx+110,yy+20], 'Javascript File:');
  xx += 110;
  pnl.source = pnl.add('edittext', [xx,yy,xx+420,yy+20], opts.source);
  xx += 425;
  pnl.sourceBrowse = pnl.add('button', [xx,yy,xx+30,yy+20], '...');

  yy += 40;
  xx = xOfs;
  
  pnl.runcvs = pnl.add('checkbox', [xx,yy,xx+110,yy+20], 'Run CVS');
  xx += 110;
  pnl.cvsmsg = pnl.add('edittext', [xx,yy,xx+455,yy+20]);

  pnl.runcvs.value = toBoolean(opts.runcvs);
//   pnl.cvsmsg.text = opts.cvsmsg;
  pnl.cvsmsg.enabled = pnl.runcvs.value;

  pnl.runcvs.onClick = function() {
    pnl.cvsmsg.enabled = this.value;
  }

  yy += 40;
  xx = xOfs;
  pnl.runzip = pnl.add('checkbox', [xx,yy,xx+110,yy+20], 'Run ZIP');
  pnl.runzip.value = toBoolean(opts.runzip);

  // now specify the callbacks for our controls

  pnl.sourceBrowse.onClick = function() {
    try {
      var pnl = this.parent;
      var def = (pnl.source.text ? new File(pnl.source.text) : ''); 
      var fsel = Stdlib.createFileSelect("Javascript: *.js;*.jsx");
      var f = Stdlib.selectFileOpen("Select a Script File", fsel, def);

      if (f) {
        pnl.source.text = decodeURI(f.fsName);
      }
    } catch (e) {
      alert(e);
    }
  }

  // return the panel object
  return pnl;
};

PackScript.prototype._createWindow = GenericUI.prototype.createWindow;

PackScript.prototype.createWindow = function(ini, doc) {
  var win = this._createWindow(ini, doc);
  win.defaultElement = win.process;
  return win;
};

//
// code for validating our panel
//
PackScript.prototype.validatePanel = function(pnl, ini) {
  var self = this;

  var opts = new PackScriptOptions(); // our options object

  // A source directory must be specified and must exist
  var f;
  if (pnl.source.text) {
    f = new File(pnl.source.text);
  }
  if (!f || !f.exists) {
      return self.errorPrompt("Source folder not found");
  }
  opts.source = decodeURI(f.fsName);

  opts.runcvs = pnl.runcvs.value;
  opts.cvsmsg = pnl.cvsmsg.text;

  opts.runzip = pnl.runzip.value;

  // return our valid options (if we made it this far)
  return opts;
};

PackScript.prototype.process = function(opts) {
  try {
    CVS.ROOT = PackScript.CVS_ROOT;

    var file = Stdlib.convertFptr(opts.source);
    var path = file.path;

    opts.cvsmsg = (opts.csvmsg ? opts.csvmsg.replace(/'/, "\\'") : "nc");
    /"))/; // emacs syntax indent hack

    if (opts.runcvs) {
      CVS.commit(file, opts.cvsmsg);
    }

    var str = Stdlib.readFromFile(file);
    var m = str.match(/\$(Id.*)\$$/m);
    if (!m) {
      alert("No CVS Id string found");
      return;
    }
    m = m[1].match(/,v ([\d\.]+)/);
    if (!m) {
      alert("Version not found in Id string");
      return;
    }
    str = '-' + m[1].replace(/\./g, '_');
    var ext = opts.fileExt || ".%e";
    var fname = file.strf("%d/%f" + str + ext);

    var flat = new Flattener();
    var flatFile = new File(fname);
    flat.exec(file, flatFile);

    if (opts.runzip) {
      var zfile = new File(flatFile.strf("%d/%f.zip"));

      if (isWindows()) {
        SevenZip.archive(zfile, [flatFile]);
      } else {
        Zip.archive(zfile, [flatFile]);
      }

      alert("File " + zfile.toUIString() + " created.");

    } else {
      alert("File " + flatFile.toUIString() + " created.");
    }

  } catch (e) {
    var msg = Stdlib.exceptionMessage(e); 
    alert(msg);
  }
};


// This version collects options via a window
PackScript.main = function() {
  var ui = new PackScript();
  ui.exec();
};


function main() {
  Exec.log.enabled = true;

  PackScript.main();
};


main();

"PackScript";

// EOF
