//
// ActionFileFromXML.js
//   This script reads an ActionFile and converts it to XML.
//
// $Id: ActionFileFromXML.jsx,v 1.29 2015/09/17 00:45:37 anonymous Exp $
// Copyright: (c)2007, xbytor
// License: http://www.opensource.org/licenses/bsd-license.php
// Contact: xbytor@gmail.com
//
//@show include
//
//@includepath "/c/Program Files/Adobe/xtools;/Developer/xtools"
//
app;
//
//@include "xlib/PSConstants.js"
//@include "xlib/Stream.js"
//@include "xlib/stdlib.js"
//@include "xlib/GenericUI.jsx"
//@include "xlib/Action.js"
//@include "xlib/xml/atn2bin.jsx"
//@include "xlib/xml/action2xml.jsx"
//@include "xlib/ActionStream.js"
//@include "xlib/ieee754.js"
//
ActionFileXmlOptions = function(obj) {
  this.logEnabled = true;

  Stdlib.copyFromTo(obj, this);
};

ActionFileXmlOptions.prototype.typename = 'ActionFileXmlOptions';
ActionFileXmlOptions.prototype.source = '';
ActionFileXmlOptions.prototype.outf = '';

ActionFileXmlUI = function() {
  var self = this;

  self.title = 'XML To Action File Converter';
  self.notesSize = 130;
  self.winRect = {
    x: 200,
    y: 200,
    w: 700,
    h: 290
  };
  self.documentation =
    "This script converts an XML file to an Action File. If the name of the " +
    "Action file is not specified via the UI, the 'file' property of the " +
    "'ActionFile' node is used. If that is not specified, the name of the " +
    "XML file is used with a '.atn' extension. Note that there is no formal " +
    "definition of the DOM used to describe PhotoShop Action files.";

  self.iniFile = "affxml.ini";
};

ActionFileXmlUI.prototype = new GenericUI();

ActionFileXmlUI.prototype.createPanel = function(pnl, ini) {
  var ini = new ActionFileXmlOptions(ini);

  var xOfs = 10;
  var yOfs = 10;
  var yy = yOfs;
  var xx = xOfs;

  pnl.add('statictext', [xx,yy,xx+80,yy+20], 'XML File:');
  xx += 80;
  pnl.source = pnl.add('edittext', [xx,yy,xx+500,yy+20], ini.source);
  xx += 510;
  pnl.sourceBrowse = pnl.add('button', [xx,yy,xx+25,yy+20], '...');

  yy += 35;
  xx = xOfs;

  pnl.add('statictext', [xx,yy,xx+80,yy+20], 'Action File:');
  xx += 80;
  pnl.outf = pnl.add('edittext', [xx,yy,xx+500,yy+20], ini.outf);
  xx += 510;
  pnl.outfBrowse = pnl.add('button', [xx,yy,xx+25,yy+20], '...');

  pnl.sourceBrowse.onClick = ActionFileXmlUI.sourceBrowse;
  pnl.outfBrowse.onClick = ActionFileXmlUI.outfBrowse;

  return pnl;
};

// placing this in the above function causes an intepreter error
ActionFileXmlUI.sourceBrowse = function() {
  var pnl = this.parent;
  var fsel = Stdlib.createFileSelect("XML Files: *.xml,All Files:*");
  var file = Stdlib.selectFileOpen("Select an XML File",
                                   fsel,
                                   pnl.source.text);
  if (file) {
    pnl.source.text = decodeURI(file.fsName);

    if (!pnl.outf.text) {
      pnl.outf.text = pnl.source.text.replace(/\.xml/i, ".atn");
    }
  }
};
ActionFileXmlUI.outfBrowse = function() {
  var pnl = this.parent;
  var def = pnl.outf.text;
  if (!def && pnl.source.text) {
    def = Folder(pnl.source.text).parent;
  }
  var fsel = Stdlib.createFileSelect("Action Files: *.atn,All Files:*");
  var file = Stdlib.selectFileSave("Select an Action File",
                                   fsel, def);
  if (file) {
    pnl.outf.text = decodeURI(file.fsName);
  }
};

ActionFileXmlUI.prototype.validatePanel = function(pnl) {
  var self = this;

  try {
    var opts = new ActionFileXmlOptions();

    var f;
    if (pnl.source.text) {
      f = new File(pnl.source.text);
      if (!f.exists) {
        return self.errorPrompt("XML file not found");
      }
    } else {
      return self.errorPrompt("XML file must be specified");
    }
    opts.source = f.toUIString();

    f = undefined;
    if (pnl.outf.text) {
      f = new File(pnl.outf.text);
    } else {
      var nm = opts.source.name.replace(/\.[^.]+$/, ".atn");
      f = new File(opts.source.path + '/' + nm);
    }
    if (!f.open("w")) {
      return self.errorPrompt("Unable to open Action file: " + f.error);
    }
    f.close();

    opts.outf = f.toUIString();

    pnl.opts = opts;

  } catch (e) {
    alert(Stdlib.exceptionMessage(e));
    return false;
  }

  return opts;
};

ActionFileXmlUI.prototype.process = function(opts) {
  if (!opts) {
    return;
  }

  var logEnabled = toBoolean(opts.logEnabled);
  Stdlib.log.enabled = logEnabled;

  Stdlib.log("ActionFileFromXML " + opts.source + ", " + opts.outf);

  XMLWriter.logEnabled = logEnabled;
  XMLReader.logEnabled = logEnabled;
  ActionStream.logEnabled = logEnabled;

  var start = new Date().getTime();
  //var xmlstr = Stdlib.readFromFile(opts.source, "UTF-8");

  Stdlib.log("Deserializing source XML file");
  //$.level = 1; debugger;
  var actFile = ActionFile.deserialize(Stdlib.convertFptr(opts.source));

  Stdlib.log("Writing target atn file");

  //$.level = 1; debugger;
  actFile.write(opts.outf);

  var stop = new Date().getTime();
  var elapsed = (stop - start)/1000;
  var msg = ("Done (" + Number(elapsed).toFixed(3) + " secs).");
  if (logEnabled) {
    Stdlib.log(msg);
  }
  alert(msg);
};


function main() {
  if (CSVersion() < 2) {
    alert("Because of missing Javascript APIs, reading binary action files " +
          "is currently only supported in CS2+. Support for CS and possibly " +
          "PS7 may  become available in the future.");
    return;
  }

  var ui = new ActionFileXmlUI();
  ui.exec();
};

main();

"ActionFileFromXML.js";
// EOF
