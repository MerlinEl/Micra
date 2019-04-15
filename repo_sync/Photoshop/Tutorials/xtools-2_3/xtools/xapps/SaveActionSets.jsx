#target photoshop
//
// SaveActionSets
//  This script saves the current Actions Palette out as a set of ATN files.
//
// $Id: SaveActionSets.jsx,v 1.5 2014/11/27 05:51:24 anonymous Exp $
// Copyright: (c)2008, xbytor
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
//@include "xlib/stdlib.js"
//@include "xlib/GenericUI.jsx"
//@include "xlib/Stream.js"
//@include "xlib/Action.js"
//@include "xlib/ActionStream.js"
//@include "xlib/xml/atn2bin.jsx"
//@include "xlib/xml/atn2js.jsx"
//

function massageName(name) {
  var n = name;
  n = n.replace(/\s+/g, '');  // remove any embedded spaces
  n = n.replace(/\W/g, '_');  // replace any non-word characters with '_'
  n = n.replace(/[_]+$/, ''); // remove any trailing '_'
  return n;
};

function main() {
  var folder = Stdlib.selectFolder("Select the destination folder",
                                   Folder.desktop);

  if (!folder) {
    return;
  }

  var pal = new ActionsPalette();
  pal.readRuntime();

  var sets = pal.actionSets;

  var progressBar = GenericUI.createProgressPalette("Saving .atn files...",
                                                   0, sets.length, undefined,
                                                   true);
  for (var i = 0; i < sets.length; i++) {
    if (progressBar.isDone) {
      break;
    }
    var atnSet = sets[i];
    var fname = massageName(atnSet.name) + ".atn";
    var fptr = folder + '/' + fname;

    progressBar.text = "Saving " + fname;
    progressBar.updateProgress(i);

    atnSet.loadRuntime();
    var atnFile = new ActionFile();
    atnFile.setActionSet(atnSet);

    atnFile.write(fptr);
    if (!progressBar.visible) {
      break;
    }
  }
};

main();

"SaveActionSets.jsx";
// EOF
