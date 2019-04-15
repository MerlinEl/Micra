#target photoshop
//
// Install
//   This is an installation script for installing the xtoolkit onto
//   someone else's machine.
//
//   This script must be run inside of Photoshop
//
//
// $Id: Install.jsx,v 1.54 2015/02/09 22:45:39 anonymous Exp $
// Copyright: (c)2008, xbytor
// License: http://www.opensource.org/licenses/bsd-license.php
// Contact: xbytor@gmail.com
//

var XTOOLS_REV = "v2.2";

var CONTACT_INFO = "xbytor@gmail.com";

//
// Simple checks for photoshop version
//

function throwFileError(f, msg) {
  if (msg == undefined) msg = '';
  Error.runtimeError(9002, msg + '\"' + f + "\": " + f.error + '.');
};


XStdlib = function() {};       // Let's borrow some stuff....

XStdlib.isCC2014 = function()  { return app.version.match(/^15\./); };
XStdlib.isCC  = function()  { return app.version.match(/^14\./); };
XStdlib.isCS6 = function()  { return app.version.match(/^13\./); };
XStdlib.isCS5 = function()  { return app.version.match(/^12\./); };
XStdlib.isCS4 = function()  { return app.version.match(/^11\./); };
XStdlib.isCS3 = function()  { return app.version.match(/^10\./); };
XStdlib.isCS2 = function()  { return app.version.match(/^9\./); };
XStdlib.isCS  = function()  { return app.version.match(/^8\./); };
XStdlib.isPS7 = function()  { return app.version.match(/^7\./); };

XStdlib.log = function(msg) {
  var file;

  if (!XStdlib.log.enabled) {
    return;
  }

  if (!XStdlib.log.filename) {
    return;
  }

  if (!XStdlib.log.fptr) {
    file = new File(XStdlib.log.filename);

    if (file.exists) file.remove();
    if (!file.open("w")) {
      throwFileError(file, "Unable to open log file");
    }
    if (XStdlib.isMac()) {
      file.lineFeed = "unix";
    }
    XStdlib.log.fptr = file;

  } else {
    file = XStdlib.log.fptr;
    if (!file.open("e"))  {
      throwFileError(file, "Unable to open log file");
    }
    file.seek(0, 2); // jump to the end of the file
  }

  if (!file.writeln(new Date() + " - " + msg)) {
    throwFileError(file, "Unable to write to log file");
  }

   file.close();
};
XStdlib.log.filename = undefined; //"~/logfile.txt";
XStdlib.log.enabled = false;

XStdlib.exceptionMessage = function(e) {
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

XStdlib.btExec = function(code, btapp) {
  if (!btapp) { btapp = BridgeTalk.appSpecifier; }

  BridgeTalk.bringToFront(btapp);

  var bt = new BridgeTalk();
  bt.target = btapp;
  bt.body = code;
  bt.send();
};

XStdlib.createFolder = function(fptr) {
  if (fptr == undefined) {
    Error.runtimeError(19, "fptr");
  }
  var fname = fptr;

  if (fptr.constructor == String) {
    fptr = new Folder(fptr);
  }

  if (fptr instanceof File) {
    return XStdlib.createFolder(fptr.parent);
  }
  if (fptr.exists) {
    return true;
  }

  if (!(fptr instanceof Folder)) {
    XStdlib.log(fptr.constructor);
    Error.runtimeError(21, "fptr");
  }

  if (fptr.parent != null && !fptr.parent.exists) {
    if (!XStdlib.createFolder(fptr.parent)) {
      return false;
    }
  }

  var rc = fptr.create();
  if (!rc) {
    var msg = ("Unable to create folder: " + fptr + " (" + fptr.error + ")\n" +
               "Please create it manually and run this script again.");
    Error.runtimeError(9002, msg);
  }
  return rc;
};

XStdlib.isWindows = function() {
  return $.os.match(/windows/i);
};
XStdlib.isMac = function() {
  return !XStdlib.isWindows();
};
XStdlib.listProps = function(obj) {
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

XStdlib.selectFolder = function(prompt, start) {
  var folder;

  if (!prompt) {
    prompt = 'Select a folder';
  }

  if (start) {
    if (!(start instanceof Folder)) {
      Error.runtimeError(9002, "Internal Error: bad type for 'start'");
    }

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

//========================= InstallerOptions ==============================

InstallerOptions = {};

InstallerOptions.BASE_NAME = "xtools";

InstallerOptions.testMode = false;
InstallerOptions.srcdir = "/c/work/xtools";    // specified here or via the UI

InstallerOptions._init = function() {
  if (InstallerOptions.testMode) {
    InstallerOptions.targetdir = (XStdlib.isWindows() ?
                                  "/c/temp/xtools" : "/tmp");
  } else {
    var winPath = app.path.parent + "/" + InstallerOptions.BASE_NAME;
    var macPath = "/Developer/" + InstallerOptions.BASE_NAME;
    InstallerOptions.targetdir = (XStdlib.isWindows() ? winPath : macPath);
  }
};

InstallerOptions._init();

InstallerOptions.subdirs =
[
 "apps",
 "etc",
 "docs",
 "xapps",
 "xlib",
 "xlib/xml"
];

InstallerOptions.includeDirective =
  "//@includepath \"" + InstallerOptions.targetdir + "\"";

InstallerOptions.LOG_FILE = "~/xtools-install.log";
InstallerOptions.LOG_ENABLED = true;

//============================ Installer =================================

Installer = function(opts) {};
Installer.logstr = '';
Installer.log = function(str) {
  Installer.logstr += str;
};
Installer.getScriptFolder = function() {
  return Installer.getScriptFile().parent;
};
Installer.getScriptFileName = function() {
  var f = Installer.getScriptFile();
  return (f ? f.absoluteURI : '');
};
Installer.getScriptFile = function() {
  if (XStdlib.isCS() || XStdlib.isPS7()) {
    return undefined;
  }

  var path = '';

  if (XStdlib.isCS2()) {
    var dbLevel = $.level;
    $.level = 0;

    try {
      some_undefined_variable;
    } catch (e) {
      path = e.fileName;
    }

    $.level = dbLevel;

  } else {
    path = $.fileName;
  }

  return new File(path);
};

Installer._createFolder = function(fptr) {
  if (fptr.exists) {
    return true;
  }
  if (!fptr.parent.exists) {
    if (!XStdlib.createFolder(fptr.parent)) {
      return false;
    }
  }
  var rc = fptr.create();
  if (!rc) {
    var msg = ("Unable to create folder: " + fptr + " (" + fptr.error + ")\n" +
               "Please create it manually and run this script again.");
    Error.runtimeError(9002, msg);
  }
  return rc;
};

Installer.createFolder = function(fname) {
  var folder = new Folder(fname);

  if (!Installer._createFolder(folder)) {
    return undefined;
  }
  return folder;
};
Installer.verifySourceFolder = function(fname) {

  var src = new Folder(fname);
  if (!src.exists) {
    throwFileError(src, "Could not find source directory");
  }
  return src;
};
Installer.writeToFile = function(file, str) {
  file.open("w") || throwFileError(file, "Unable to open output file");
  file.encoding = 'BINARY';
  file.write(str);
  file.close();
};
Installer.readFromFile = function(file) {
  file.open("r") || throwFileError(file, "Unable to open input file");
  file.encoding = 'BINARY';
  var str = file.read();
  file.close();
  return str;
};

Installer.copyFiles = function(src, target, sub) {
  if (sub) {
    sub = '/' + sub;
  } else {
    sub = '';
  }

  var srcdir = Installer.verifySourceFolder(src + sub);
  var targetdir = Installer.createFolder(target + sub);

  XStdlib.log("Copying files from " + decodeURI(srcdir.fsName) +
              " to " + decodeURI(targetdir.fsName));

  var files = srcdir.getFiles();

  // RegExp used to fix-up includepath directives
  var rex = /\n\/\/@includepath [^\n]+/g;

  for (var i = 0; i < files.length; i++) {
    var ifile = files[i];
    if (ifile instanceof Folder) {
      continue;
    }
    var ofile = new File(targetdir + '/' + ifile.name);

    // if it's a script file, fix any includepath directives
    if (ifile.name.match(/\.jsx?$/)) {
      XStdlib.log("Installing script: " + ifile.name);
      var str = Installer.readFromFile(ifile);
      var ostr = str.replace(rex, '\n' + InstallerOptions.includeDirective);
      Installer.writeToFile(ofile, ostr);

    } else {
      XStdlib.log("Installing file: " + ifile.name);
      if (ofile.exists) {
        ofile.remove();
      }
      if (!ifile.copy(ofile)) {
        throwFileError(ifile, "Could not copy file");
      }
    }
  }

  XStdlib.log("Copy of " + decodeURI(srcdir.fsName) + " completed.\n");
};

//
//  f = File.openDialog(); Installer.loadActionFile(f);
//
Installer.loadActionFile = function(file) {
  XStdlib.log("Loading action file: " + decodeURI(file.fsName));
  Installer.loadActionFiles([file]);
  XStdlib.log("Loading action file completed.");
};

//
// Installer.loadActionFiles(folder.getFiles("*.atn"))'
//
Installer.loadActionFiles = function(files) {
  for (var i = 0; i < files.length; i++) {
    var file = files[i];
    XStdlib.btExec('app.load(new File("' + file.absoluteURI + '"));');
  }
};
Installer.modifyActionFiles = function(opts) {
  var dir = new File(opts.targetdir + "/etc");

  var infile = new File(dir + "/XToolkit-in.xml");
  var outfile = new File(dir + "/XToolkit.atn");

  XStdlib.log("Converting action file: " + decodeURI(infile.fsName));

  var estr = "//@show include\r\n";

  estr += opts.includeDirective +';\r\n';
  estr += '//@include "xapps/ChangeScriptPaths.jsx";\r\n';
  estr += "function main() {\r\n";
  estr += "  changeScriptPaths(\"" + infile + "\", \"";
  estr += outfile + "\", \"" + opts.targetdir + "/xapps\");\r\n";
  estr += "};\r\n";
  estr += 'main()';

  eval(estr);

  Installer.loadActionFile(outfile);
};


Installer.run = function(opts) {
  var rc = false;

  try {
    var src = Installer.verifySourceFolder(opts.srcdir);
    var target = Installer.createFolder(opts.targetdir);
    var subs = opts.subdirs;

    XStdlib.log("Copy start");

    Installer.copyFiles(src, target, '');

    for (var i = 0; i < subs.length; i++) {
      Installer.copyFiles(src, target, subs[i]);
    }

    XStdlib.log("Copy stop");

  } catch (e) {
    var msg = ("Installation failed: " + XStdlib.exceptionMessage(e));
    XStdlib.log(msg);
    alert(msg);
    return rc;
  }

  try {
    if (!XStdlib.isCS()) {
      alert("XToolkit.atn has not been generated.\n" +
            "If you want it, edit the etc/XTookit-in.xml by " +
            "globally replacing '/zdrive/work/xtools/' with '" +
            opts.targetdir + "'\n" +
            "then convert the xml file to a .atn file using the\n"+
            "'apps/ActionFileFromXML.jsx' script.");

      // Installer.modifyActionFiles(opts);
    }

    rc = true;

  } catch (e) {
    var msg = ("Installation failed: XToolkit.atn" +
               XStdlib.exceptionMessage(e));
    XStdlib.log(msg);
    alert(msg);

    return rc;
  }

  return rc;
};

Installer.getSrcDir = function() {
  var srcdir;
  var promptDefault = "Please select the unzipped xtools folder:";
  var promptStr = promptDefault;

  if (!XStdlib.isCS()) {
    srcdir = Installer.getScriptFolder();
    XStdlib.log("Installer dir: " + srcdir);

    var jsh_test = new File(srcdir + "/xapps/jsh.jsx");

    if (!jsh_test.exists) {
      srcdir = srcdir.parent;
      jsh_test = new File(srcdir + "/xapps/jsh.jsx");
      if (!jsh_test.exists) {
        promptStr = "Cannot find xtools package.\r\n" + promptDefault;
        srcdir = undefined;
      }
    }

    if (srcdir) {
      return srcdir;
    }
  }

  // prompt for srcdir
  while (!srcdir) {
    XStdlib.log("Prompt: " + promptStr);
    srcdir = Folder.selectDialog(promptStr);

    if (!srcdir) {
      break;
    }

    var jsh_test = new File(srcdir + "/xapps/jsh.jsx");

    if (!jsh_test.exists) {
      jsh_test = new File(srcdir + "/xtools/xapps/jsh.jsx");
      if (!jsh_test.exists) {
        promptStr = "Cannot find xtools package.\r\n" + promptDefault;
        srcdir = undefined;
      }
    }
  }

  XStdlib.log("srcdir: " + (srcdir ? srcdir.absoluteURI : undefined));

  return srcdir;
};

Installer.createInstallUI = function(dir) {
  var win = new Window('dialog', "xtools installation");
  win.preferredSize = [400, 100];
  win.note = win.add('statictext', undefined,
                     "Install xtools in this folder:");
  win.note.alignment = 'left';
  win.folderPnl = win.add('group');
  win.folderPnl.alignment = 'left';
  win.browse = win.folderPnl.add('button', undefined, 'Browse...');
  win.folder = win.folderPnl.add('statictext', undefined, dir);

  win.browse.onClick = function() {
    try {
      var win = this.parent.parent;
      var old = Folder(win.folder.text);
      var fld = XStdlib.selectFolder("Select the xtools installation folder",
                                    old);

      if (fld) {
        win.folder.text = decodeURI(fld.fsName);
      }

    } catch (e) {
      Installer.alert(e);
    }
  }

  win.btnPnl = win.add('group');
  win.ok = win.btnPnl.add('button', undefined, 'OK');
  win.cancel = win.btnPnl.add('button', undefined, 'Cancel');

  win.ok.onClick = function() {
    var win = this.parent.parent;
    win.installFolder = win.folder.text;
    win.close();
  }

  win.installFolder = undefined;
  return win;
};

Installer.runInstallUI = function(dir) {
  var win = Installer.createInstallUI(decodeURI(dir.fsName));
  win.show();
  return win.installFolder;
};

Installer._main = function(silent) {
  XStdlib.log.filename = InstallerOptions.LOG_FILE;
  XStdlib.log.enabled = InstallerOptions.LOG_ENABLED;

  XStdlib.log("App: " + BridgeTalk.appName);
  try { XStdlib.log("App Version: " + app.version); } catch (e) {}
  XStdlib.log("OS: " + $.os);
  XStdlib.log("Locale: " + $.locale);
  XStdlib.log("Filename: " + $.fileName);
  XStdlib.log("Revision: $RCS$");

  if (BridgeTalk.appName != "photoshop") {
    alert("Please run this script from within Photoshop");
    return;
  }

  var interactive = !silent;

  if (XStdlib.isCS() || XStdlib.isPS7()) {
    if (!interactive) {
      Installer.alert("xtools cannot be installed in " +
                      "silent mode in PSCS or PS7");
      return false;
    }
  }

  var dir = Folder(InstallerOptions.targetdir);

  var dirName;

  if (interactive) {
    dirName = Installer.runInstallUI(dir);

    if (!dirName) {
      return;
    }

  } else {
    dirName = decodeURI(dir.fsName);
  }

  InstallerOptions.targetdir = Folder(dirName);

  XStdlib.log("xtools installation folder: " +
              decodeURI(InstallerOptions.targetdir.fsName));

  InstallerOptions.includeDirective =
     "//@includepath \"" + decodeURI(InstallerOptions.targetdir) + "\"";

  if (interactive) {
    var startMsg = ("About to install xtools " + XTOOLS_REV +
                    " in\r\n\r\n" + dirName + "\r\n\r\nContinue?");

    if (!confirm(startMsg)) {
      return;
    }
  }

  var logName = decodeURI(File(XStdlib.log.filename).fsName);
  var msg = ("Starting installation of xtools. Log file is\r\n" + logName);
  XStdlib.log(msg);

  var info = {
    appName :  app.name,
    appVersion : app.version,
    os : $.os
  };

  XStdlib.log(XStdlib.listProps(info));

  if (interactive) {
    Installer.alert(msg);
  }

  try {
    var srcdir;
    if (interactive) {
      srcdir = Installer.getSrcDir();

      if (!srcdir) {
        alert("Unable to verify xtools source folder");
      }

    } else {
      srcdir = Installer.getScriptFolder().parent;
    }

  } catch (e) {
  }


  if (srcdir) {
    XStdlib("Source folder: " + srcdir);

    var start = new Date().getTime();

    XStdlib.log("Start: " + new Date());

    InstallerOptions.srcdir = srcdir;
    var rc = Installer.run(InstallerOptions);

    var msg;
    if (rc) {
      var stop = new Date().getTime();
      var elapsed = (stop - start)/1000;
      msg = "Done (" + Number(elapsed).toFixed(3) + " secs).";

    } else {
      msg = ("Installation failed.\r" +
             "Please send the log file(" +
             decodeURI(XStdlib.log.fptr.fsName) + ")\r" +
             "to " + CONTACT_INFO);
      XStdlib.log(msg);
      alert(msg);
      return false;
    }

    XStdlib.log(msg);

    if (interactive) {
      Installer.alert(msg);
    }

  } else {
    XStdlib.log("Unable to verify xtools source folder");
  }

  return rc;
};

Installer.alert = function(msg) {
  alert(msg);
};

Installer.main = function(silent) {
  try {
    Installer._main(silent);

  } catch (e) {
    var msg = ("Installation failed: " + XStdlib.exceptionMessage(e));
    XStdlib.log(msg);
    alert(msg);
  }
};

Installer.main();

"Install.jsx";
// EOF
