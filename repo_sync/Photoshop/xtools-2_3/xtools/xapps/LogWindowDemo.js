//
// LogWindowDemo
//
// $Id: LogWindowDemo.js,v 1.5 2010/03/29 02:23:23 anonymous Exp $
// Copyright: (c)2005, xbytor
// License: http://www.opensource.org/licenses/bsd-license.php
// Contact: xbytor@gmail.com
//
//@includepath "/c/Program Files/Adobe/xtools;/Developer/xtools"
//
//@include "xlib/LogWindow.js"
//
isPS7 = function()  { return version.match(/^7\./); };

function main() {
  if (isPS7()) {
    alert("This script cannot be run in PS7.");
    return;
  }

  alert("This is a demo for LogWindow.js");
  var logwin = new LogWindow('Test Log Window');
  logwin.append('Start');
  logwin.append(logwin.bounds);
  logwin.append('more stuff');
  logwin.show();
  logwin.show("That's all, folks...");
};

main();

"LogWindowDemo.js";
// EOF

