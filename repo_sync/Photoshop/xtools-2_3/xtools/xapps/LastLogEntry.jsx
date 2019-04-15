#target photoshop
//
// LastLogEntry.js
//   Get the last entry from a ScriptingListenerJS.log file.
//
// $Id: LastLogEntry.jsx,v 1.13 2010/06/15 23:59:23 anonymous Exp $
// Copyright: (c)2005, xbytor
// License: http://www.opensource.org/licenses/bsd-license.php
// Contact: xbytor@gmail.com
//
//@show include
//
//
//@includepath "/c/Program Files/Adobe/xtools;/Developer/xtools"
//
app;

function main() {
  var fptr = new File(Folder.desktop +"/ScriptingListenerJS.log");

  if (!fptr.exists) {
    fptr = new File("/c/ScriptingListenerJS.log");
  }

  if (!fptr.exists) {
    fptr = File.openDialog("Please select a ScriptingListener log file");
    if (!fptr) {
      return;
    }
  }

  var str = Stdlib.getLastJSLogEntry(fptr);
  if (str && str.length > 0) {
    str = str.replace(/\n/g, '\r\n');
    var logwin = new LogWindow("Last Scripting Log Entry", undefined, str);
    logwin.debug = true;
    logwin.init();
    var win = logwin.win;

    var btn = win.btnPanel.debugBtn;
    btn.text = 'Fix';
    logwin.debugBtn = function() {
      try {
        var self = this;
        var text = self.text;
        var infile = new File(Folder.temp + '/' + File().name);
        infile.open("w");
        infile.write(this.text);
        infile.close();

        var outfile = new File(Folder.temp + '/' + File().name);
        var fixer = new SLCFix();
        SLCFix.usePSConstants = false;
        fixer.exec(infile, outfile);
        outfile.open("r");
        var str = outfile.read();
        outfile.close();

        self.setText(str.replace(/\n/g, '\r\n'));

      } catch (e) {
        alert(Stdlib.exceptionMessage(e));

      } finally {
        if (infile) infile.remove();
        if (outfile) outfile.remove();
      }
    };

    logwin.show();
  }
};

//@include "xlib/stdlib.js"
//@include "xlib/LogWindow.js"
//@include "xapps/SLCFix.js"

main();

"LastLogEntry.jsx";

// EOF
