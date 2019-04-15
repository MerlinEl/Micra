//
// ActionToJavascript.jsx
//
// $Id: ActionToJavascript.jsx,v 1.12 2014/11/27 05:51:24 anonymous Exp $
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
//@include "xlib/PSConstants.js"
//@include "xlib/stdlib.js"
//@include "xlib/Stream.js"
//@include "xlib/Action.js"
//@include "xlib/ActionEval.jsx"
//@include "xlib/ActionSelector.jsx"
//@include "xlib/xml/atn2bin.jsx"
//@include "xlib/xml/atn2js.jsx"
//
//@include "xlib/ActionStream.js"
//@include "xlib/ieee754.js"
//

function main() {
  if (CSVersion() < 2) {
    alert("Because of missing JavaScript APIs, reading binary action files " +
          "is currently only supported in CS2+.");
    return;
  }

  var sel = new ActionSelector();
  var selact = sel.getActionFromRuntime();
  // selact = { action: "a1", actionSet: "test" };
  if (!selact) {
    return;
  }
  var nm = JSWriter.massageName(selact.action);

  var fsel = Stdlib.createFileSelect("JavaScript Files: *.jsx");
  var file = Stdlib.selectFileSave("Select an output file", fsel,
                                   Folder.desktop + "/" + nm + ".jsx");
  if (!file) {
    return;
  }

  var tm = new Timer();
  tm.start();
  var act = new Action();

  act.readFromPalette(selact.action, selact.actionSet);

  var jw  = new JSWriter();
  jw.writeScript(act, file, nm);
  tm.stop();
  alert("Done (" + tm.elapsed + " secs).");
};

main();

"ActionToJavascript.js";
// EOF
