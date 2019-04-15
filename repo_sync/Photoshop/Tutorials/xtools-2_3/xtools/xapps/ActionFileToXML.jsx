//
// ActionFileToXML.js
//   This script reads an ActionFile and converts it to XML.
//
// $Id: ActionFileToXML.jsx,v 1.32 2015/09/16 20:40:23 anonymous Exp $
// Copyright: (c)2007, xbytor
// License: http://www.opensource.org/licenses/bsd-license.php
// Contact: xbytor@gmail.com
//
//@show include
//
app;

//
//@includepath "/c/Program Files/Adobe/xtools;/Developer/xtools"
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
  var self = this;

  self.source = '';
  self.outf = '';
  self.logEnabled = true;

  if (obj) Stdlib.copyFromTo(obj, self);
};

ActionFileXmlOptions.prototype.typename = 'ActionFileXmlOptions';

ActionFileXmlUI = function() {
  var self = this;

  self.title = 'Action File To XML Converter';
  self.notesSize = 170;
  self.winRect = {
    x: 200,
    y: 200,
    w: 700,
    h: 350
  };

  self.documentation =
    "This script converts a valid Photoshop Action (.atn) file to an XML " +
    "representation of the contents of that action file. This file can be " +
    "view with a text editor, XML editor, or web browser such as Firefox " +
    "and IE. Once in this form, the XML can be editted and converted back " +
    "into an Action file with the ActionFileFromXML script.\r\rAn Action " +
    "file must be specified. If an XML output file is not specified, a " +
    "file will be created using the Action file's name with a '.xml' " +
    "extension.";

  self.iniFile = "aftxml.ini";
};

ActionFileXmlUI.prototype = new GenericUI();

ActionFileXmlUI.prototype.createPanel = function(pnl, ini) {
  var def = new ActionFileXmlOptions(ini);

  var xOfs = 10;
  var yOfs = 10;
  var yy = yOfs;
  var xx = xOfs;

  pnl.add('statictext', [xx,yy,xx+80,yy+20], 'Action File:');
  xx += 80;
  pnl.source = pnl.add('edittext', [xx,yy,xx+500,yy+20], ini.source);
  xx += 510;
  pnl.sourceBrowse = pnl.add('button', [xx,yy,xx+25,yy+20], '...');

  yy += 35;
  xx = xOfs;

  pnl.add('statictext', [xx,yy,xx+80,yy+20], 'XML File:');
  xx += 80;
  pnl.outf = pnl.add('edittext', [xx,yy,xx+500,yy+20], ini.outf);
  xx += 510;
  pnl.outfBrowse = pnl.add('button', [xx,yy,xx+25,yy+20], '...');
  yy += 30;
  xx = xOfs;

  pnl.sourceBrowse.onClick = ActionFileXmlUI.sourceBrowse;
  pnl.outfBrowse.onClick = ActionFileXmlUI.outfBrowse;

  return pnl;
};

// placing this in the above function causes an intepreter error
ActionFileXmlUI.sourceBrowse = function() {
  var pnl = this.parent;
  var fsel = Stdlib.createFileSelect("Action Files: *.atn,All Files:*");
  var file = Stdlib.selectFileOpen("Select an Action File",
                                   fsel,
                                   pnl.source.text);
  if (file) {
    pnl.source.text = decodeURI(file.fsName);
    if (!pnl.outf.text) {
      pnl.outf.text = pnl.source.text.replace(/\.atn/i, ".xml");
    }
  }
};
ActionFileXmlUI.outfBrowse = function() {
  var pnl = this.parent;
  var def = pnl.outf.text;

  if (!def && pnl.source.text) {
    def = Folder(pnl.source.text).parent;
  }
  var fsel = Stdlib.createFileSelect("XML Files: *.xml,All Files:*");
  var file = Stdlib.selectFileSave("Select an XML File",
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
        return self.errorPrompt("Action file not found");
      }
    } else {
      return self.errorPrompt("Action file must be specified");
    }
    opts.source = f.toUIString();

    f = undefined;
    if (pnl.outf.text) {
      f = new File(pnl.outf.text);
    } else {
      var nm = opts.source.name.replace(/\.[^.]+$/, ".xml");
      f = new File(opts.source.path + '/' + nm);
    }
    if (!f.open("w")) {
      return self.errorPrompt("Unable to open XML file " + f.fsName + ':'
                              + f.error);
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

  Stdlib.log("ActionFileToXML " + opts.source + ", " + opts.outf);

  XMLWriter.logEnabled = logEnabled;
  XMLReader.logEnabled = logEnabled;
  ActionStream.logEnabled = logEnabled;

  var start = new Date().getTime();
  var actFile = new ActionFile();
  actFile.read(File(opts.source));

  var nm = actFile.file ? actFile.file.name : opts.outf.name;
  Stdlib.log("Converting to XML");

  //$.level = 1; debugger;
  var xml = actFile.toXML(nm);

  Stdlib.log("Serializing to XML");
  var xstr = xml.toXMLString();

  Stdlib.log("Writing XML to file " + opts.outf);
  Stdlib.writeToFile(File(opts.outf), xstr, 'UTF-8', 'unix');

  var stop = new Date().getTime();
  var elapsed = (stop - start)/1000;
  var msg = ("Done (" + Number(elapsed).toFixed(3) + " secs).");
  if (logEnabled) {
    Stdlib.log(msg);
  }
  alert(msg);
};


function main() {
  if (isPS7() || isCS()) {
    alert("Because of missing Javascript APIs, reading binary action files " +
          "is currently only supported in CS2/3/4. Support for CS and possibly " +
          "PS7 may become available in the future.");
    return;
  }

  var ui = new ActionFileXmlUI();
  ui.exec();
};

main();

"ActionFileToXML.js";
// EOF
