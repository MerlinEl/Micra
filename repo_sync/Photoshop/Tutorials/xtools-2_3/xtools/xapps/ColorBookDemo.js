//
// ColorBookDemo
//   A ColorBook, in PS-speak, is a stored color palette. This script reads
//   all of the color books from 'Presets/Color Books' and writes what
//   information it can out to a text file.
//
// $Id: ColorBookDemo.js,v 1.14 2010/03/29 02:23:23 anonymous Exp $
// Copyright: (c)2005, xbytor
// License: http://www.opensource.org/licenses/bsd-license.php
// Contact: xbytor@gmail.com
//
//@show include
//
//@includepath "/c/Program Files/Adobe/xtools;/Developer/xtools"
//
//@include "xlib/Stream.js"
//@include "xlib/ColorBook.js"
//@include "xlib/LogWindow.js"
//
var app; if (!app) app = this; // for PS7
isPS7 = function()  { return version.match(/^7\./); };

function main() {
  if (isPS7()) {
    alert("For unknown reasons, this script cannot execute in PS7 correctly.");
    return;
  }
  var folder = new Folder(app.path + "/Presets/Color Books");
  var files = folder.getFiles("*.acb");
  var file;
  var listAll = false;
  var outfile = new File("/c/temp/ColorBooks.txt");

  if (files) {
    if (isPS7() || listAll) {
      ; // do nothing
    } else {
      if (files[0].openDlg) {
        file = files[0];
        file = file.openDlg("Select a Color Book",
                            "Color Book Files:*.acb,All files:*");
      } else {
        Folder.current = folder;
        file = File.openDialog("Select a Color Book",
                           "Color Book Files:*.acb,All files:*");
      }

      if (file) {
        files = [file];
      } else {
        files = undefined;
      }
    }
  }

  if (!files) {
    return;
  }

  var outstr = '';
  for (var i = 0; i < files.length; i++) {
    var cb = new ColorBook();
    cb.readFromFile(files[i]);
    outstr += cb.toString() + "\r\n";
    for (var j = 0; j < cb.numberOfColors; j++) {
      if (cb.colors[j].name.length != 0) {
        outstr += cb.colors[j].toString() + "\r\n";
      }
    }
  }

  if (isPS7()) {
    if (!outfile.open("w")) {
      throw "Unable to open " + outfile + ". " + outfile.error;
    }
    outfile.writeln(outstr);
    outfile.close();
    alert("ColorBooks written to " + outfile + ".");

  } else {
    var logwin = new LogWindow("ColorBook " + cb.title);
    logwin.append('\r\n' + outstr);
    logwin.show();
  }
};

main();

"ColorBookDemo.js";
// EOF
