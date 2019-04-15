//
// Add Watermark.js
// Adds a watermark to a document. Lots of options. In its default mode
// it expects a shape called 'Watermark Shape' and a style 'Watermark Style'
//
// $Id: AddWatermark.jsx,v 1.25 2014/11/27 05:51:24 anonymous Exp $
// Copyright: (c)2005, xbytor
// License: http://www.opensource.org/licenses/bsd-license.php
// Contact: xbytor@gmail.com
//
//@show include
//
app;
//
//@includepath "/c/Program Files/Adobe/xtools;/Developer/xtools"
//
//@include "xlib/Watermark.js"
//@include "xlib/GenericUI.jsx"
//
var app; if (!app) app = this; // for PS7

WatermarkUI = function() {
  var self = this;

  self.iniFile = "watermark.ini";
};
WatermarkUI.prototype = new GenericUI();

WatermarkUI.prototype.process = function(opts, doc) {
  GenericUI.writeIni(this.iniFile, opts);
  Watermark.exec(doc, opts);
};

WatermarkUI.sampleOpts = {
  style: "Basic Drop Shadow",
  shape: "Cat Print", 
  layer: "Watermark Layer",
  size: 10,
  ofsX: 5,
  ofsY: -5,
  fontSize: 36,
  font: "ArialMT",
  fontColor: "0,0,0",
  copyrightNotice: "(c)2008 bob dobbs",
  copyrightUrl: "http://google.com",
  copyrighted: "copyrighted",
  noUI: true
};

function main() {
  if (!app.documents.length) {
    alert("Please open a document before running this script.");
    return;
  }
  var doc = app.activeDocument;
  var ui  = new WatermarkUI();

  var opts = new WatermarkOptions(WatermarkUI.sampleOpts);
  ui.exec(opts, doc);

  // add a second one here
//   opts.ofsX = -5;
//   opts.ofsY = 5;
//   opts.shape = undefined;
//   opts.fontSize = 36;
//   ui.exec(doc, opts);
};

main();

"AddWatermark.js";
// EOF

