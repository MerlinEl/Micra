//
// SequentialSave
//
// This script saves the current document as a resized jpg to a
// separate folder using YYYYMMDD-XXX.jpg as the filename format.
// As part of the process, all metadata is stripped.
//
// Copyright: (c)2007 xbytor
// License: http://www.opensource.org/licenses/bsd-license.php
// Contact: xbytor@gmail.com
//
// $Id: SequentialSave.jsx,v 1.8 2011/06/28 05:48:00 anonymous Exp $
//
//@show include
//
//
//@includepath "/c/Program Files/Adobe/xtools;/Developer/xtools"
//
app;
//
//@include "xlib/stdlib.js"
//

Options = function(){};

Options.FOLDER = Folder.desktop + "/upload";
Options.PAD = 3;
// Options.MAX_WIDTH = 480;
// Options.MAX_HEIGHT = 600;
Options.MAX_WIDTH = 1024;
Options.MAX_HEIGHT = 1024;

Options.PREFIX = undefined; // defaults to date YYYYMMDD format

zeroPad = function(num, w) {
  var str = num.toString();

  while (str.length < w) {
    str = "0" + str;
  }
  return str;
};

getNextIndex = function(folder, prefix) {
  var idx = 0;
  var pad = Options.PAD;

  function _folderChk(f) {
    return (f instanceof File) && f.name.match(RegExp(prefix + "(\\d+)\\."));
  }

  var flist = folder.getFiles(_folderChk);
  if (flist && flist.length) {
    for (var i = 0; i < flist.length; i++) {
      var file = flist[i];
      var m = file.name.match(/(\d+)\.[^\.]+$/);
      if (m) {
        var v = Number(m[1]);
        if (v > idx) {
          idx = v;
          pad = m[1].length;
        }
      }
    }
  }

  idx++;
  return zeroPad(idx, pad);
};

function main() {
  if (app.documents.length == 0) {
    return;
  }

  var doc = app.activeDocument;
  doc.selection.selectAll();
  doc.selection.copy(doc.layers.length > 1);
  doc.selection.deselect();

  var prefix = Options.PREFIX;
  if (!prefix) {
    prefix = new Date().strftime("%Y%m%d");
  }

  var target = new Folder(Options.FOLDER);

  var idx = getNextIndex(target, prefix + "-");

  var fname = "%s/%s-%s.jpg".sprintf(target.absoluteURI, prefix, idx);
  var file = new File(fname);

  var saveOpts = new JPEGSaveOptions();
  saveOpts.quality = 8;

  var ru = app.preferences.rulerUnits;
  app.preferences.rulerUnits = Units.PIXELS;

  try {
    var rez = doc.resolution;
    doc.resizeImage(undefined, undefined, 72, ResampleMethod.NONE);
    var cp = Stdlib.newDocument(file.name, "RGBM", doc.width.value,
                                doc.height.value, 72, 8);
    app.activeDocument = doc;
    doc.resizeImage(undefined, undefined, rez, ResampleMethod.NONE);

    app.activeDocument = cp;
    cp.selection.selectAll();
    cp.paste(true);
    cp.flatten();

    if (cp.width.value > Options.MAX_WIDTH ||
        cp.height.value > Options.MAX_HEIGHT) {
      Stdlib.fitImage(cp, Options.MAX_WIDTH, Options.MAX_HEIGHT);
    }

    var file = new File(fname);
    Stdlib.createFolder(file.parent);
    cp.saveAs(file, saveOpts, false);
    cp.close(SaveOptions.DONOTSAVECHANGES);

  } catch (e) {
    alert(Stdlib.exceptionMessage(e));

  } finally {
    app.preferences.rulerUnits = ru;
  }
};

main();

"SequentialSave.jsx";
// EOF
