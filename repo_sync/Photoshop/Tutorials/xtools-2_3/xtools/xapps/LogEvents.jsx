//
// LogEvents.jsx
//
// $Id: LogEvents.jsx,v 1.1 2010/06/04 16:24:29 anonymous Exp $
// Copyright: (c)2010, xbytor
// License: http://www.opensource.org/licenses/bsd-license.php
// Contact: xbytor@gmail.com
//
//@show include
//
//
//@includepath "/c/Program Files/Adobe/xtools;/Developer/xtools"
//
//@include "xlib/stdlib.js"
//@include "xlib/Stream.js"
//@include "xlib/PSConstants.js"
//@include "xlib/Action.js"
//@include "xlib/ActionXML.jsx"

function _main(args) {
  if (!args) {
    return;
  }

  try {
    var event = <event/>;
    if (args[1]) {
      event.id = id2char(args[1]);
    }
    if (args[0]) {
      event.descriptor = args[0].toXML();
    }

    $.writeln(event.toXMLString());

  } catch (e) {
    alert(e + '@' + e.line);
  }
};

try {
  _main(arguments);

} catch (e) {

}
"LogEvents.jsx";
// EOF
