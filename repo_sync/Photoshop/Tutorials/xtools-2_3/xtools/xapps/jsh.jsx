//
// jsh
// Launch a window for interactively executing JavaScript commands
//
// $Id: jsh.jsx,v 1.29 2010/03/29 02:23:23 anonymous Exp $
// Copyright: (c)2007, xbytor
// License: http://www.opensource.org/licenses/bsd-license.php
// Contact: xbytor@gmail.com
//
app;
//
//@show include
//
//@includepath "/c/Program Files/Adobe/xtools;/Developer/xtools"
//
//@include "xlib/JShell.js"
//@include "xlib/stdlib.js"
//@include "xlib/xexec.js"
//@include "xlib/GenericUI.jsx"
if (isPhotoshop()) {
//@include "xlib/ColorSwatches.jsx"
//@include "xlib/PSError.jsx"
//@include "xlib/PSConstants.js"
//@include "xlib/metadata.js"
//@include "xlib/XMPNameSpaces.jsx"
//@include "xlib/PresetsManager.jsx"
//@include "xlib/Action.js"
//@include "xlib/xml/atn2xml.jsx"
//@include "xlib/Stream.js"
}
if (!isCS()) {
//@include "xlib/XBridgeTalk.jsx"
}

function main() {
  if (isPS7()) {
    alert("This script cannot be run in PS7.");
    return;
  }

  if ((new File("/c/tmp/jshinit.js")).exists) {
//     eval('//@show include\r\n' +
//          '//@include "/c/tmp/jshinit.js"');
  }

  JShell.exec();
};

main();

"jsh.js";
// EOF
