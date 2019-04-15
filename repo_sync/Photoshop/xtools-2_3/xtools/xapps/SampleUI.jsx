//
// SampleUI.jsx
//   Here is a sample usage of the GenericUI framework. The script prompts
// for source and target folders. PSD files found in the source folder are
// converted to B&W using a Lab conversion technique courtesy of some code
// from Trevor Morris. As part of the conversion, the new files have a keyword
// 'B&W-Luminosity' added.
//
//  Files that are already grayscale or already have the 'B&W-Luminosity'
//  keyword are skipped. This is especially handy if the source and target
//  directories are the same.
//
// $Id: SampleUI.jsx,v 1.21 2010/03/29 02:23:23 anonymous Exp $
// Copyright: (c)2007, xbytor
// License: http://www.opensource.org/licenses/bsd-license.php
// Contact: xbytor@gmail.com
//
//@show include
//
//@includepath "/c/Program Files/Adobe/xtools;/Developer/xtools"
//
app;
//
//@include "xlib/GenericUI.jsx"
//@include "xlib/stdlib.js"  // not really needed except for debugging
//
//@include "xlib/ScrollingPanel.jsx"
//

//
// This is the class that contains our options for this script
// The default values for this class are specified here
//
SampleUIOptions = function(obj) {
  var self = this;

  self.source = '';    // the source folder
  self.target = '';    // the target/destination folder

  // values in obj can override the values set above
  // Stdlib.copyFromTo(obj, self);
  if (obj) {
    for (var idx in obj) {
      self[idx] = obj[idx];
    }
  }
};
SampleUIOptions.prototype = new GenericOptions();

//
// SampleUI is our UI class
//
SampleUI = function() {
  var self = this;

  self.title = "Sample UI"; // our window title
  self.notesSize = 80;      // The height of our Notes panel
  self.winRect = {          // the size of our window
    x: 200,
    y: 200,
    w: 650,
    //h: 700  // use this when testing Filenaming panel
    h: 420
  };
  if (SampleUI.FILENAMING) {
    self.winRect.h = 650;
//     self.winRect.h = 450;
  }
  self.documentation =
    "This script converts color images (.psd files) found in the source " +
    "folder to B&W using a Lab conversion technique. The new files are " +
    "also tagged " +
    "with a new keyword: 'B&W-Luminosity'. Existing grayscale files or " +
    "files already tagged are skipped.";

  self.iniFile = SampleUI.INI_FILE; // our ini file name
  self.saveIni = true;
  self.hasBorder = true;

  self.processTxt = 'Convert';   // use Convert as name of the Process button
  self.settingsPanel = true;
  self.optionsClass = SampleUIOptions;
};

// make it a subclass of GenericUI
SampleUI.prototype = new GenericUI();

SampleUI.FILENAMING = true;

SampleUI.INI_FILE = Stdlib.PREFERENCES_FOLDER + "/sample.ini";

// Here is where we create the components of our panel
SampleUI.prototype.createPanel = function(pnl, ini) {
// Uncomment this block of code for a scrolling panel
  // and change winRect.h to 450 (or whatever) above
//   var self = this;

//   self.createVScrollingPanel(pnl, 'group', 650);
//   self.createInnerPanel(pnl.contents, ini);
// };
// SampleUI.prototype.createInnerPanel = function(pnl, ini) {
  var self = this;
  var xOfs = 10;
  var yy = 10;

  var opts = new SampleUIOptions(ini);   // default values

  if (opts.uiX == undefined) {
    ini.uiX = ini.uiY = 100;
  }

  self.moveWindow(toNumber(opts.uiX), toNumber(opts.uiY));

  // for our panel, we have a source directory input
  var xx = xOfs;
  pnl.add('statictext', [xx,yy,xx+120,yy+20], 'Source Directory:');
  xx += 120;
  pnl.source = pnl.add('edittext', [xx,yy,xx+420,yy+20], opts.source);
  xx += 425;
  pnl.sourceBrowse = pnl.add('button', [xx,yy,xx+30,yy+20], '...');

  yy += 40;
  xx = xOfs;

  // and a target directory input
  pnl.add('statictext', [xx,yy,xx+120,yy+20], 'Target Directory:');
  xx += 120;
  pnl.target = pnl.add('edittext', [xx,yy,xx+420,yy+20], opts.target);
  xx += 425;
  pnl.targetBrowse = pnl.add('button', [xx,yy,xx+30,yy+20], '...');

  // now specify the callbacks for our controls

  pnl.sourceBrowse.onClick = function() {
    try {
      var pnl = this.parent;
      var def = (pnl.source.text ?
                 new Folder(pnl.source.text) : Folder.current);
      var f = Folder.selectDialog("Select a Source folder", def);
      //var f = Stdlib.selectFolder("Select a Source folder", def);
      if (f) {
        pnl.source.text = decodeURI(f.fsName);
        if (!pnl.target.text) {
          pnl.target.text = pnl.source.text;
        }
      }
    } catch (e) {
      alert(e);
    }
  }

  pnl.targetBrowse.onClick = function() {
    try {
      var pnl = this.parent;
      var f;
      var def = pnl.target.text;
      if (!def) {
        if (pnl.source.text) {
          def = pnl.source.text;
        } else {
          def = Folder.current;
        }
      }
      var f = Folder.selectDialog("Select a destination folder", def);
      //var f = Stdlib.selectFolder("Select a destination  folder", def);

      if (f) {
        pnl.target.text = decodeURI(f.fsName);
      }
    } catch (e) {
      alert(e.toSource());
    }
  }

  if (ini) {   // if there was an ini object

    if (ini.source) {
      pnl.source.text = ini.source;  // set the source directory
    }
    if (ini.target) {
      pnl.target.text = ini.target;  // set the target directory
    }
  }

  yy += 43;
  xx = xOfs;

  pnl.font = pnl.add('group', [xx,yy,xx+400,yy+40]);

  self.createFontPanel(pnl.font, ini);

  yy += 50;

  if (SampleUI.FILENAMING) {
    pnl.filenaming = pnl.add('panel', [xx,yy,xx+590,yy+130]);
    self.createFileNamingPanel(pnl.filenaming, ini);

    yy += 140;
    pnl.filesave = pnl.add('panel', [xx,yy,xx+470,yy+110]);
    self.createFileSavePanel(pnl.filesave, ini);
  }

  // return the panel object
  return pnl;
};

//
// code for validating our panel
//
SampleUI.prototype.validatePanel = function(pnl, ini) {
  var self = this;

  var opts = new SampleUIOptions(); // our options object

  // A source directory must be specified and must exist
  var f;
  if (pnl.source.text) {
    f = new Folder(pnl.source.text);
  }
  if (!f || !f.exists) {
    return self.errorPrompt("Source folder not found");
  }
  opts.source = decodeURI(f.fsName);

  // A target directory must be specified and either must already
  // exist or we need to be able to create it now
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
  opts.target = decodeURI(f.fsName);

  opts.uiX = self.winX;
  opts.uiY = self.winY;

  // return our valid options (if we made it this far)
  return opts;
};

//
// The process callback function retrieves all of the .psd file from the
// source directory. Those that are not already grayscale and do not have
// the "B&W-Luminosity" keyword are converted to grayscale using Trevor
// Morris' luminousityChannel function. The new copy of the document has
// the "B&W-Luminosity" added and is written to the target directory.
//
SampleUI.prototype.process = function(opts, doc) {
  // alert("In Sample.process:" + opts.toSource()); // all we do is alert

  var folder = new Folder(opts.source);
  var files = folder.getFiles("*.psd");     // get the .psd files from source
  var fileNameSuffix = 'Lab (Luminousity)';
  var psdSaveOptions = new PhotoshopSaveOptions();  // create the save options

  psdSaveOptions.embedColorProfile = true;
  psdSaveOptions.maximizeCompatibility = true;

  for (var i = 0; i < files.length; i++) {  // for each file
    var file = files[i];
    var doc = app.open(file);
    var keywords = doc.info.keywords;

    // only do processing if the document is not grayscale already and
    // if it doesn't have 'B&W-Luminosity' as a keyword

    if (!/B&W-Luminosity/.test(keywords.toString()) &&
        doc.mode != DocumentMode.GRAYSCALE) {

      var name = doc.name.toString();
      var dupe = luminousityChannel();// convert to B&W a duplicate is returned

      var keywords = dupe.info.keywords;  // add the "B&W-Luminosity" keyword
      keywords.push("B&W-Luminosity");
      dupe.info.keywords = keywords;

      // insert fileNameSuffix between the filename and the extension
      // ex: "file.psd" becomes "file - Lab (Luminousity).psd"
      var fname = name.replace(/(\.[^\.]+)$/, " - " + fileNameSuffix + "$1");
      var file = new File(opts.target + '/' + fname);

      // save and close the B&W document
      dupe.saveAs(file, psdSaveOptions, true, Extension.LOWERCASE);
      dupe.close(SaveOptions.DONOTSAVECHANGES);
    }

    // close the original document
    doc.close(SaveOptions.DONOTSAVECHANGES);
  }
};

//
// The following function was pulled from BWVariations_0-3-5.jsx and slightly
// modified for use in this script.
//
///////////////////////////////////////////////////////////////////////////////
// create Lightness channel variation (L*a*b* mode)
//
// Author: Trevor Morris (tmorris@fundy.net)
// Author Website: http://user.fundy.net/morris/
// Version: 0.3.5
// Source File: http://user.fundy.net/morris/downloads/scripts/BWVariations_0-3-5.jsx
//
///////////////////////////////////////////////////////////////////////////////
function luminousityChannel() {
  // duplicate and flatten the original document
  var duplicateDocument = activeDocument.duplicate();
  duplicateDocument.flatten();

  // convert document to L*a*b* mode
  if (duplicateDocument.mode != DocumentMode.LAB) {
    duplicateDocument.changeMode(ChangeMode.LAB);
  }

  // remove a* and b* channels
  duplicateDocument.channels[2].remove();
  duplicateDocument.channels[1].remove();

  // convert document to grayscale
  duplicateDocument.changeMode(ChangeMode.GRAYSCALE);

  // Modification by xbytor:
  // the call to the function saveFile has been replaced by code
  // in the caller which mimics its behavior.

  // save output
  var fileNameSuffix = 'Lab (Luminousity)';

  //saveFile(fileNameSuffix);

  return duplicateDocument;
};

SampleUI.prototype.cancel = function() {
  //alert("In Sample.cancel");
};


//
// This version uses the current doc and uses the ini options instead of
// opening a window
//
// Sample.main = function() {
//   var doc = undefined;
//   if (app.documents.length) {
//     doc = app.documents;
//   }
//   var ui = new SampleUI();
//   ui.exec(doc, true);
// };

// This version collects options via a window
SampleUI.main = function() {
  var ui = new SampleUI();
  ui.exec();
  ui.updateIniFile({ uiX: ui.winX, uiY: ui.winY });
};

SampleUI.main();

"SampleUI";

// EOF
