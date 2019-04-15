//
// ActionEvalDemo
//
// $Id: ActionFileBrowser.jsx,v 1.2 2012/06/15 00:50:23 anonymous Exp $
// Copyright: (c)2005, xbytor
// License: http://www.opensource.org/licenses/bsd-license.php
// Contact: xbytor@gmail.com
//
//@show include
//
//@includepath "/c/Program Files/Adobe/xtools;/Developer/xtools"
//
//@include "xlib/PSConstants.js"
//@include "xlib/stdlib.js"
//@include "xlib/Stream.js"
//@include "xlib/Action.js"
//@include "xlib/ActionStream.js"
//@include "xlib/ActionEval.jsx"
//@include "xlib/ActionSelector.jsx"
//@include "xlib/xml/atn2bin.jsx"
//@include "xlib/xml/action2xml.jsx"
//

function main() {
  if (CSVersion() < 2) {
    alert("Because of missing Javascript APIs, reading binary action files " +
          "is currently only supported in CS2 and CS3.");
    return;
  }

  var interactive = true;
  var act;

  if (interactive) {
    var sel = new ActionSelector();
    act = sel.getActionFromFile();
    if (!act) {
      return;
    }

  } else {
    act = {};
    act.actionFile = new File("/c/work/XActions.atn");
    //or act.actionFile = new File("/c/work/XActions.xml");
    act.action = "Alert";
    if (!act.actionFile.exists) {
      return ;
    }
  }

  ActionEval.runAction(act.actionFile, act.action);
};

main();

"ActionEvalDemo.jsx";
// EOF
