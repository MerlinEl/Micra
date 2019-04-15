//
// AdjustRGBLevels.js
//
// $Id: AdjustRGBLevels.js,v 1.11 2010/03/29 02:23:23 anonymous Exp $
// Copyright: (c)2005, xbytor
// License: http://www.opensource.org/licenses/bsd-license.php
// Contact: xbytor@gmail.com
//
//@show include
//
//@includepath "/c/Program Files/Adobe/xtools;/Developer/xtools"
//
//@include "xlib/Levels.js"
//

var app; if (!app) app = this; // for PS7


function main() {
  if (!app.documents.length) {
    alert("Please open a document before running this script.");
    return;
  }
  alert("This script trims histogram tails on the RGB channels.");
  var cutoff = 3;
  var doc = app.activeDocument;

  Levels.autoAdjustRGBChannels(doc, cutoff);
};

main();

"AdjustRGBLevels.js"
// EOF
