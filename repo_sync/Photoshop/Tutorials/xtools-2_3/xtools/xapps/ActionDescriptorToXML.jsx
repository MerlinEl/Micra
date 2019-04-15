//
// ActionDescriptorToXML
//
// $Id: ActionDescriptorToXML.jsx,v 1.4 2010/03/29 02:23:23 anonymous Exp $
// Copyright: (c)2006, xbytor
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
//@include "xlib/LogWindow.js"
//@include "xlib/Action.js"
//@include "xlib/xml/atn2xml.jsx"

function main() {
//   alert("This script will convert an ActionDescriptor that was streamed " +
//         "to a file into XML.");

  var file = Stdlib.selectFileOpen("Select an ActionDescriptor stream file:");

  if (!file) {
    return;
  }

  try {
    var str = Stdlib.readFromFile(file, 'BINARY');
    var desc = new ActionDescriptor();
    desc.fromStream(str);

    var xml = desc.toXML();
    LogWindow.open(xml, 'Descriptor XML');

  } catch (e) {
    alert(e + '@' + e.line);
  }
};

main();

"ActionDescriptorToXML.jsx";
// EOF
