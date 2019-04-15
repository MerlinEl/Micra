#target photoshop
//
// ActionToXML.jsx
//
// $Id: ActionToXML.jsx,v 1.5 2011/05/07 15:43:47 anonymous Exp $
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

//@include "xlib/xml/action2xml.jsx"
//--include "xlib/xml/atn2xml.jsx"
//--include "xlib/ActionXML.jsx"
//
//@include "xlib/ActionStream.js"
//@include "xlib/ieee754.js"
//

function main() {
  if (isCS() || isPS7()) {
    alert("Because of missing JavaScript APIs, reading binary action files " +
          "is currently only supported in CS2.");
    return;
  }

  var sel = new ActionSelector();
  var selact = sel.getActionFromRuntime();
  // selact = { action: "a1", actionSet: "test" };
  if (!selact) {
    return;
  }
  var nm = JSWriter.massageName(selact.action);

  //var file = new File("/c/tmp/a1.jsx");
  var fsel = Stdlib.createFileSelect("XML Files: *.xml");
  var file = Stdlib.selectFileSave("Select an output file",
                                   fsel, nm + ".xml");
  if (!file) {
    return;
  }

  var tm = new Timer();
  tm.start();
  var act = new Action();

  act.readFromPalette(selact.action, selact.actionSet);

  var actFile = new ActionFile();
  var actSet = new ActionSet();
  actSet.name = nm;
  actSet.add(act);

  actFile.file = new File(Folder.temp + '/' + nm + '.atn');
  actFile.setActionSet(actSet);

  var xmlstr = actFile.serialize(actFile.file.name);
//   xmlstr = xmlstr.replace(/></g, ">\n<")

  Stdlib.writeToFile(file, xmlstr, 'UTF-8');

  tm.stop();
  alert("Done (" + tm.elapsed + " secs).");
};

main();

"ActionToXML.js";
// EOF
