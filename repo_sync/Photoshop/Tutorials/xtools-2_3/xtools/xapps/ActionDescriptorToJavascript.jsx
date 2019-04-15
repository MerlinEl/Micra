//
// ActionDescriptorToJavascript
//
// $Id: ActionDescriptorToJavascript.jsx,v 1.2 2010/03/29 02:23:23 anonymous Exp $
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
//@include "xlib/xml/atn2js.jsx"

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

    var jw  = new JSWriter();

    var str = jw.write("ActionDescriptor", undefined, undefined, desc, "desc");

    var ftn = ("function ftn() {\n" +
               "    cTID = function(s) { return app.charIDToTypeID(s); };\n" +
               "    sTID = function(s) { return app.stringIDToTypeID(s); };\n"+
               str + "\n" +
               "    return desc\n" +
               "};\n\n");

    LogWindow.open(ftn, 'Descriptor Javascript');

  } catch (e) {
    alert(e + '@' + e.line);
  }
};

main();

"ActionDescriptorToXML.jsx";
// EOF
