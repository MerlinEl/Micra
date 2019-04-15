//
// Wrapper for Levels.autoAdjust
//
// $Id: AdjustLevels.js,v 1.16 2010/03/29 02:23:23 anonymous Exp $
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
  var cutoff = 3;
  var doc = app.activeDocument;

  if (doc.activeLayer.kind != LayerKind.NORMAL) {
    alert("Please select a 'Normal' layer.");
    return;
  }
  alert("This script trims histogram tails on the composite channel.");
  Levels.autoAdjust(doc, cutoff);
};

main();

"AdjustLevels.js";
// EOF
