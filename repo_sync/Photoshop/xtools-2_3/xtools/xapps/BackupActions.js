#target photoshop
//
// BackupActions
//   After bashing my ActionsPalette a couple of times while developing
//   some Action management routines, I wrote this script that makes backing
//   up my ActionsPalette a simple mouse click. With my luck, I should
//   probably hotkey the Action that calls this script as well.
//
// $Id: BackupActions.js,v 1.12 2012/06/15 00:50:23 anonymous Exp $
// Copyright: (c)2005, xbytor
// License: http://www.opensource.org/licenses/bsd-license.php
// Contact: xbytor@gmail.com
//
//@show include
//
//@includepath "/c/Program Files/Adobe/xtools;/Developer/xtools"
//
//@include "xlib/stdlib.js"
//

function main() {
  if (CSVersion() < 2) {
    alert("BackupActions only works in CS2+.");
    return;
  }
  Stdlib.backupActionsPalette();
};

main();

"BackupActions.js";
// EOF
