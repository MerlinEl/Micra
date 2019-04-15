//
// ChangeScriptPaths.jsx
//   Converts all of the script paths in an Action File.
//
// $Id: ChangeScriptPaths.jsx,v 1.12 2012/06/15 00:50:23 anonymous Exp $
// Copyright: (c)2009, xbytor
// License: http://www.opensource.org/licenses/bsd-license.php
// Contact: xbytor@gmail.com
//
//@show include
//
//@includepath "/c/Program Files/Adobe/xtools;/Developer/xtools"
//
//@include "xlib/PSConstants.js"
//@include "xlib/Stream.js"
//@include "xlib/stdlib.js"
//@include "xlib/Action.js"
//@include "xlib/ActionStream.js"
//@include "xlib/xml/atn2bin.jsx"
//@include "xlib/xml/action2xml.jsx"
//

changeScriptPaths = function(infile, outfile, newpath) {
  infile = Stdlib.convertFptr(infile);
  var ext = infile.strf("%e").toLowerCase();

  if (ext == "atn") {
    var actFile = new ActionFile();
    actFile.read(infile);

    var xmlstr = actFile.serialize(actFile.name);

  } else if (ext == "xml") {
    var xmlstr = Stdlib.readFromFile(infile);

  } else {
    throw "Cannot process unknown file type \"" + ext + "\"";
  }

  var re2 = /path="[^"]+\/([^\/"]+)"/g;
  var str = xmlstr.replace(re2,
                          "path=\"" + newpath + "/$1\"");
  actFile = ActionFile.deserialize(str);
  actFile.write(outfile);
};

function csp_main() {
  if (CSVersion() < 2) {
    alert("Because of missing Javascript APIs, reading binary action " +
          "files is currently only supported in CS2+. Support for CS and " +
          "possibly PS7 may  become available in the future.");
    return;
  }

  var interactive = true;
  var infile = new File("/c/work/XToolkit.atn");
  var outfile = new File("/c/work/XToolkit-out.atn");
  var scriptPath = "/c/temp";

  if (interactive) {
    var atnmask = "Action Files: *.atn,All files:*";

    infile = File.openDialog("Select an Action File to Read", atnmask);
    if (!infile) return;

    outfile = File.saveDialog("Select an Action File to Write", atnmask);
    if (!outfile) return;

    scriptPath = prompt("Enter a new script path:", "/");
    if (!scriptPath) return;
  }

  var start = new Date().getTime();

  changeScriptPaths(infile, outfile, scriptPath);

  var stop = new Date().getTime();
  var elapsed = (stop - start)/1000;
  alert("Done (" + Number(elapsed).toFixed(3) + " secs).");
};

// check to see if there is already a 'main' function
try {
  main;

} catch (e) {
  if (e.toString().search("ReferenceError") == -1) {
    throw e;
  }
  csp_main();
}

"ChangeScriptPaths.jsx";
//EOF
