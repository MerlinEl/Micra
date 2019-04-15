#target photoshop
//
// GetterDemo
//   This is a demo for xlib/Getter.jsx. It defines a new class GetterOptions
// that permits specifying exactly what information to retrive. Some or all
// of this code may be moved to xlib/Getter.jsx in a future release.
//
// $Id: GetterDemo.jsx,v 1.19 2015/03/25 23:22:11 anonymous Exp $
// Copyright: (c)2005, xbytor
// License: http://www.opensource.org/licenses/bsd-license.php
// Contact: xbytor@gmail.com
//
app;
//
//@show include
//
//@includepath "/c/Program Files/Adobe/xtools;/Developer/xtools"
//
//@include "xlib/PSConstants.js"
//@include "xlib/stdlib.js"
//@include "xlib/Stream.js"
//@include "xlib/Action.js"
//@include "xlib/ActionStream.js"
//@include "xlib/ActionXML.jsx"
//@include "xlib/xml/atn2bin.jsx"
//@include "xlib/JSLog.js"
//@include "xlib/Getter.jsx"
//


var GETTER_LOG_FILE = "~/Desktop/Getter.xml";

var log = new JSLog(JSLog.ALL, JSLogType.UI);

Getter.getPSInfo = function(opts) {
  if (opts.appInfo && CSVersion() >= 6 && !(log.logger instanceof JSFileLogger)) {
    log.logger = new JSFileLogger(GETTER_LOG_FILE);
    alert("The requested information will be saved to " + File(GETTER_LOG_FILE).toUIString());
  }

  if (opts.trace) {
    log.write("Getter");
    log.write("Start - " + new Date());
  }
  log.write("<?xml  version=\"1.0\" encoding=\"iso-8859-1\"  ?>");
  log.write("<PhotoshopInfo>");

  if (opts.trace) log.write("Application Info");
  if (opts.appInfo) log.write(Getter.getApplicationInfo());

  if (opts.trace) log.write("Action Info");
  if (opts.action) log.write(Getter.getActionInfo());

  var docs = (opts.doc ? [opts.doc] : app.documents);
  for (var i = 0; i < docs.length; i++) {
    var doc = docs[i];
    app.activeDocument = doc;
    if (opts.trace) log.write("Document Info");

    if (opts.docInfo) log.write(Getter.getDocumentInfo(doc, i+1));

    if (opts.trace) log.write("Background Info");
    if (opts.bg) log.write(Getter.getBackgroundInfo(doc));

    if (opts.trace) log.write("Layer Info");
    if (opts.layer) log.write(Getter.getLayerInfo(doc));

    if (opts.trace) log.write("Channel Info");
    if (opts.channel) log.write(Getter.getChannelInfo(doc));

    if (opts.trace) log.write("Path Info");
    if (opts.path) log.write(Getter.getPathInfo(doc));

    if (opts.trace) log.write("History Info");
    if (opts.history) log.write(Getter.getHistoryInfo(doc));
  }
  if (opts.trace) log.write("Stop  - " + new Date());
  log.write("</PhotoshopInfo>");
  log.flush();
};

//
//
//

GetterOptions = function(){
  var self = this;
  self.appInfo = true;
  self.action  = true;
  self.doc     = undefined; // undefined means all docs...
  self.docInfo = true;
  self.bg      = true;
  self.layer   = true;
  self.channel = true;
  self.path    = true;
  self.history = true;

  self.trace   = false; // spit out trace info
};

GetterOptions.prototype.disableAll = function() {
  var self = this;
  self.appInfo = false;
  self.action  = false;
  self.docInfo = false;
  self.bg      = false;
  self.layer   = false;
  self.channel = false;
  self.path    = false;
  self.history = false;
};
GetterOptions.prototype.enableAll = function() {
  var self = this;
  self.appInfo = true;
  self.action  = true;
  self.docInfo = true;
  self.bg      = true;
  self.layer   = true;
  self.channel = true;
  self.path    = true;
  self.history = true;
};

GetterUI = function() {
};

GetterUI.run = function() {
  var opts;
  var winW = 250;
  var winH = 340;
  var bnds = [100,100];
  bnds[2] = bnds[0] + winW;
  bnds[3] = bnds[1] + winH;
  var win = new Window('dialog', "Getter Demo", bnds);

  var xOfs = 20;
  var yOfs = 20;
  var chkW = 100;
  var chkH = 20;
  var spH = chkH + 10;
  var yy = yOfs;
  win.appInfo = win.add('checkbox',
                        [xOfs,yy,xOfs+chkW,yy+chkH],
                        "Application");
  yy+= spH;

  win.action  = win.add('checkbox',
                        [xOfs,yy,xOfs+chkW,yy+chkH],
                       "Actions");
  yy+= spH;

  win.docInfo = win.add('checkbox',
                        [xOfs,yy,xOfs+chkW,yy+chkH],
                        "Document(s)");
  yy+= spH;

  win.bg      = win.add('checkbox',
                        [xOfs,yy,xOfs+chkW,yy+chkH],
                        "Background");
  yy+= spH;

  win.layer   = win.add('checkbox',
                        [xOfs,yy,xOfs+chkW,yy+chkH],
                        "Layers");
  yy+= spH;

  win.channel = win.add('checkbox',
                        [xOfs,yy,xOfs+chkW,yy+chkH],
                        "Channels");
  yy+= spH;
  
  win.path    = win.add('checkbox',
                        [xOfs,yy,xOfs+chkW,yy+chkH],
                        "Paths");
  yy+= spH;

  win.history = win.add('checkbox', [xOfs,yy,xOfs+chkW,yy+chkH],
                        "History");
  yy+= spH;

  var xx = 15;
  var btnW = 105;

  win.enableAll = win.add('button', [xx,yy,xx+btnW,yy+20], 'Enable All');
  xx += btnW + 10;
  win.disableAll  = win.add('button', [xx,yy,xx+btnW,yy+20], 'Disable All');

  yy+= spH + 15;
  xx = 15;

  win.process = win.add('button', [xx,yy,xx+btnW,yy+20], 'Process');
  xx += btnW + 10;
  win.cancel  = win.add('button', [xx,yy,xx+btnW,yy+20], 'Cancel');

  win.setState = function(state) {
    var win = this;
    for (var idx in win) {
      var p = win[idx];
      if (p && p.type == 'checkbox') {
        p.value = state;
      }
    }
  }
  win.enableAll.onClick = function() { this.parent.setState(true); }
  win.disableAll.onClick = function() { this.parent.setState(false); }

  win.process.onClick = function() {
    var win = this.parent;
    var opts = new GetterOptions();

    var lvl = $.level;
    $.level = 0;
    for (var idx in opts) {
      try { opts[idx] = win[idx].value; } catch (e) {}
    }
    $.level = lvl;
    win.opts = opts;
    win.close(1);
  }

  win.setState(true);

  win.defaultElement = win.process;

  win.center();

  win.show();

  return win.opts;
};

function main() {
  if (CSVersion() < 2) {
    alert("Because of missing Javascript language issues, conversion of " +
          "ActionDescriptors to XML (which occurs in this script) " +
          "is currently only supported in CS2+. Support for CS and possibly " +
          "PS7 may become available in the future.");
    return;
  }

  var opts = GetterUI.run();
  if (opts) {
    Getter.getPSInfo(opts);
  }

  return;
  var opts = new GetterOptions();
  opts.disableAll();
  opts.action = true;

  Getter.getPSInfo(opts);
};

main();

"GetterDemo.jsx";
// EOF
