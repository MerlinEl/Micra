//
// SeqSave
//
// This script saves the current document as a resized jpg to a
// hardwired folder.
//
// Copyright: (c)2009 xbytor
// License: http://www.opensource.org/licenses/bsd-license.php
// Contact: xbytor@gmail.com
//
// $Id: SeqSave.jsx,v 1.3 2010/03/29 02:23:23 anonymous Exp $
//
//@show include
//
//
//@includepath "/c/Program Files/Adobe/xtools;/Developer/xtools"
//
app;
//

Options = function(){};

Options.FOLDER = Folder.desktop + "/seqTest";
Options.PAD = 4;
Options.RESIZE = false;
Options.FLATTEN = true;
Options.MAX_WIDTH = 600;
Options.MAX_HEIGHT = 800;

Options.PREFIX = "Flattened_";   // defaults to date YYYYMMDD format

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

  var prefix = Options.PREFIX;
  if (!prefix) {
    prefix = new Date().strftime("%Y%m%d-");
  }

  var folder = new Folder(Options.FOLDER);

  var idx = getNextIndex(folder, prefix);

  var fname = folder.absoluteURI + '/' + prefix + idx + '.jpg';
  var file = new File(fname);

  var saveOpts = new JPEGSaveOptions();
  saveOpts.quality = 8;

  var ru = app.preferences.rulerUnits;
  app.preferences.rulerUnits = Units.PIXELS;

  try {
    if (Options.RESIZE || Options.FLATTEN) {
      doc = doc.duplicate(file.name);
    }
    if (Options.FLATTEN) {
      doc.flatten();
    }
    if (Options.RESIZE) {
      PSfitImage(doc, Options.MAX_WIDTH, Options.MAX_HEIGHT);
    }

    if (!file.parent.exist) {
      file.parent.create();
    }

    doc.saveAs(file, saveOpts, false);
    doc.close(SaveOptions.DONOTSAVECHANGES);

  } catch (e) {
    alert(e.toString());

  } finally {
    app.preferences.rulerUnits = ru;
  }
};

cTID = function(s) { return app.charIDToTypeID(s); };
sTID = function(s) { return app.stringIDToTypeID(s); };

PSfitImage = function(doc, width, height) {
  app.activeDocument = doc;
  var desc = new ActionDescriptor();
  desc.putUnitDouble( cTID('Wdth'), cTID('#Pxl'), width );
  desc.putUnitDouble( cTID('Hght'), cTID('#Pxl'), height );

  var fitId = sTID('3caa3434-cb67-11d1-bc43-0060b0a13dc4');
  return executeAction(fitId , desc, DialogModes.NO );
};

main();

"SeqSave.jsx";
// EOF
