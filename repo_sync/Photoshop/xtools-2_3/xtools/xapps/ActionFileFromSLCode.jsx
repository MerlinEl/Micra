#target photoshop
//
// ActionFileFromSLCode.js
//
// $Id: ActionFileFromSLCode.jsx,v 1.10 2015/04/28 03:25:50 anonymous Exp $
// Copyright: (c)2009, xbytor
// License: http://www.opensource.org/licenses/bsd-license.php
// Contact: xbytor@gmail.com
//
//@show include
//
app;
//
//@includepath "/c/Program Files/Adobe/xtools;/Developer/xtools"
//
//-include "xlib/PSConstants.js"
//@include "xlib/Stream.js"
//@include "xlib/stdlib.js"
//-include "xlib/GenericUI.jsx"
//@include "xlib/Action.js"
//@include "xlib/ActionStream.js"
//@include "xlib/xml/atn2bin.jsx"
//

function main() {
  Stdlib.log.setFile(SLCToATNOptions.LOG_FILE);
  Stdlib.log(File(SLCToATNOptions.LOG_FILE));
  Stdlib.log("Start");
  Stdlib.log("Revision: $Revision: 1.10 $");
  Stdlib.log("App: " + app.name);
  Stdlib.log("App Version: " + app.version);
  Stdlib.log("OS: " + $.os);

  var ui = new SLCToATNUI();
  ui.exec();
};

//@include "xapps/SLCFix.js"

//============================ SLCToATNUI =====================================

SLCToATNOptions = function(obj) {
  var self = this;
  self.source = '~/Desktop/ScriptingListenerJS.log';
  self.dest = '~/Desktop/Session.atn';

  Stdlib.copyFromTo(obj, self);
};
SLCToATNOptions.prototype.typename = 'SLCToATNOptions';

SLCToATNOptions.INI_FILE = Stdlib.PREFERENCES_FOLDER + "/atnfslc.ini";
SLCToATNOptions.LOG_FILE = Stdlib.PREFERENCES_FOLDER + "/atnfslc.log";

SLCToATNUI = function() {
  var self = this;

  self.title = "ScriptingListener Code To Action File";
  self.notesSize = 100;
  self.winRect = {
    x: 200,
    y: 200,
    w: 600,
    h: 310
  };
  self.documentation =
    "This script converts the output of the ScriptingListener plugin into " +
    "an Action file. Part of processing requires cleaning the SL Code to remove " +
    "syntactic errors. This is done by code from the SLCFix script.";

  self.iniFile = SLCToATNOptions.INI_FILE;
};

SLCToATNUI.prototype = new GenericUI();

SLCToATNUI.prototype.createPanel = function(pnl, ini) {
  var self = this;
  ini = new SLCToATNOptions(ini);

  var xOfs = 20;
  var yOfs = 10;
  var yy = yOfs;
  var xx = xOfs;

  pnl.add('statictext', [xx,yy,xx+110,yy+20], 'SL Log:');
  xx += 110;
  pnl.source = pnl.add('edittext', [xx,yy,xx+400,yy+20], ini.source);
  xx += 405;
  pnl.sourceBrowse = pnl.add('button', [xx,yy,xx+25,yy+20], '...');

  yy += 35;
  xx = xOfs;

  pnl.add('statictext', [xx,yy,xx+110,yy+20], 'Action File:');
  xx += 110;
  pnl.dest = pnl.add('edittext', [xx,yy,xx+400,yy+20], ini.dest);
  xx += 405;
  pnl.destBrowse = pnl.add('button', [xx,yy,xx+25,yy+20], '...');

  pnl.sourceBrowse.onClick = SLCToATNUI.sourceBrowse;
  pnl.destBrowse.onClick = SLCToATNUI.destBrowse;

  return pnl;
};

SLCToATNUI.sourceBrowse = function() {
  var pnl = this.parent;
  var file = Stdlib.selectFileOpen("Select an ScriptingListener Log File",
                 Stdlib.createFileSelect("Log Files: *.log,All Files:*"),
                 pnl.source.text);
  if (file) {
    pnl.source.text = file.fsName;
  }
};
SLCToATNUI.destBrowse = function() {
  try {
    //$.level = 1; debugger;
    var pnl = this.parent;
    var file = Stdlib.selectFileSave("Select an Action File",
           Stdlib.createFileSelect("Action Files: *.atn"),
           pnl.dest.text);

    if (file) {
      pnl.dest.text = file.fsName;
    }
  } catch (e) {
    alert(e.toSource());
  }
};


SLCToATNUI.prototype.validatePanel = function(pnl) {
  var self = this;

  try {
    var opts = new SLCToATNOptions();

    var f;
    if (pnl.source.text) {
      f = new File(pnl.source.text);
      if (!f.exists) {
        return self.errorPrompt("Log file not found");
      }
    } else {
      return self.errorPrompt("Log file must be specified");
    }
    opts.source = decodeURI(f.fsName);

    f = undefined;
    if (pnl.dest.text) {
      f = new File(pnl.dest.text);
    } else {
      return self.errorPrompt("Action file must be specified");
    }

    if (!f.open("w")) {
      return self.errorPrompt("Unable to open Action file: " + f.error);
    }
    f.close();

    opts.dest = decodeURI(f.fsName);

    pnl.opts = opts;

  } catch (e) {
    alert(e.toSource());
    return false;
  }

  return opts;
};

SLCToATNUI.executeAction = function(eid, desc, mode) {
  var atn = SLCToATNUI.action;

  Stdlib.log('Adding item: event: ' + id2char(eid, "Event"));

  var aitem = new ActionItem();
  aitem.withDialog = (mode != DialogModes.NO);
  var event = undefined;

  try {
    event = app.typeIDToCharID(eid);
  } catch (e) {
  }

  if (!event) {
    try {
      event = app.typeIDToStringID(eid);
    } catch (e) {
    }
  }

  if (event) {
    aitem.setEvent(event);
  } else {
    aitem.setItemID(eid);
  }

  aitem.setDescriptor(desc);

  aitem.name = id2char(eid, "Event");

  atn.add(aitem);
};

SLCToATNUI.prefixStr = "executeAction = SLCToATNUI.executeAction;\n";

SLCToATNUI.prototype.process = function(opts) {
  if (!opts) {
    return;
  }

  Stdlib.log("processing " + opts.source);

  try {
    var start = new Date().getTime();

    var src = new File(opts.source);
    var jsxFile = new File(Folder.temp + new File().name);
    var dest = new File(opts.dest);

    var fixer = new SLCFix();
    SLCFix.usePSConstants = false;
    SLCFix.insertFtnCalls = true;

    fixer.exec(src, jsxFile);

    jsxFile.open("r");
    var str = jsxFile.read();
    jsxFile.close();

    var estr = SLCToATNUI.prefixStr + str;

    var atn = SLCToATNUI.action = new Action();
    atn.name = dest.strf('%f');
    atn.expanded = true;

    eval(estr);

    var atnFile = new ActionFile();

    var atnSet = new ActionSet();
    atnSet.expanded = true;

    atnSet.name = atn.getName();
    atnSet.add(atn);

    atnFile.setActionSet(atnSet);

    atnFile.write(dest);

    var stop = new Date().getTime();
    var elapsed = (stop - start)/1000;
    alert("Done (" + Number(elapsed).toFixed(3) + " secs).");

  } catch (e) {
    Stdlib.logException(e, true);
  }
};


main();

"ActionFileFromSLCode.jsx";
// EOF
