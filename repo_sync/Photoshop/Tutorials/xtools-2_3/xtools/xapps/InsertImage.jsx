#target photoshop
app; 
//
// InsertImage
//
// $Id: InsertImage.jsx,v 1.13 2010/03/29 02:23:23 anonymous Exp $
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
//@include "xlib/GenericUI.jsx"
//
// startup
app.bringToFront();

InsertImageOptions = function(obj) {
  var self = this;
 
  self.dir = "~";
  self.mode = "fit"; // or fill

  Stdlib.copyFromTo(obj, self);
};

InsertImageOptions.INI_FILE = "insertimage.ini";

Processor = function(opts) {
  var self = this;

  self.opts = opts;
};

Processor.prototype.insertImageIntoBounds = function(doc, layer, bnds,
                                                     file, fit) {
  var lname = layer.name;

  var width = bnds[2] - bnds[0];
  var height = bnds[3] - bnds[1];
  var lname = layer.name;

  var l = layer;
  var bgSelected = l.isBackgroundLayer;
  var hasMask = (Stdlib.hasLayerMask(doc, l) &&
                 Stdlib.isLayerMaskEnabled(doc, l));

  Stdlib.placeImage(doc, layer, file);
  layer = doc.activeLayer;

  if (layer.kind == LayerKind.SMARTOBJECT) {
    Stdlib.convertToLayer(doc, layer);
  }

  if (hasMask) {
    Stdlib.mergeLayers(doc);
  }

  layer = doc.activeLayer;
  layer.name = lname;

  var lbnds = Stdlib.getLayerBounds(doc, layer);
  var lw = lbnds[2]-lbnds[0];
  var lh = lbnds[3]-lbnds[1];

  var lrat = lh/lw;
  var rat  = height/width;

  var orient;

  if (lrat > rat) {
    orient = (fit ? 'vert' : 'horz');
  } else {
    orient = (fit ? 'horz' : 'vert');
  }

  var isLinked = Stdlib.isLayerMaskLinked(doc, layer);
  if (isLinked) {
    Stdlib.unlinkLayerMask(doc, layer);
  }
  Processor.transformLayer(doc, layer, bnds, orient);

  if (isLinked) {
    Stdlib.linkLayerMask(doc, layer);
  }

  if (bgSelected) {
    Stdlib.mergeLayers(doc);
    doc.activeLayer.background = true;
  }
};

Processor.prototype.insertImageIntoLayer = function(doc, layer) {
  var self = this;
  var dir;

  if (self.opts.dir) {
    dir = new Folder(self.opts.dir);
  }

  var file = Stdlib.selectFileOpen("Select an Image", undefined, dir);
  if (!file) {
    return;
  }
  self.opts.dir = file.parent.toUIString();
  GenericUI.writeIni(InsertImageOptions.INI_FILE, self.opts);

  var fit = (self.opts.mode != 'fill');

  var bnds;
  if (Stdlib.hasSelection(doc)) {
    bnds = Stdlib.getSelectionBounds(doc);

  } else if (Stdlib.hasLayerMask(doc, layer)) {
    bnds = Stdlib.getMaskBounds(doc, layer);

  } else {
    doc.selection.selectAll();
    bnds = Stdlib.getSelectionBounds(doc);
    doc.selection.deselect();
  }

  self.insertImageIntoBounds(doc, layer, bnds, file, fit);
};

Processor.transformLayer = function(doc, layer, bnds, orient) {
  var lbnds = Stdlib.getLayerBounds(doc, layer);

  var newW = bnds[2]-bnds[0];
  var newH = bnds[3]-bnds[1];
  var oldW = lbnds[2]-lbnds[0];
  var oldH = lbnds[3]-lbnds[1];

  var hrzn = bnds[0] - (lbnds[0] - (newW-oldW)/2);
  var vrtc = bnds[1] - (lbnds[1] - (newH-oldH)/2);

  var prc;
  if (orient == 'horz') {
    prc = (newW/oldW) * 100;
  } else {
    prc = (newH/oldH) * 100;
  }

  function _ftn() {
    var desc = new ActionDescriptor();
    var ref = new ActionReference();
    ref.putEnumerated( cTID('Lyr '), cTID('Ordn'), cTID('Trgt') );
    desc.putReference( cTID('null'), ref );
    desc.putEnumerated( cTID('FTcs'), cTID('QCSt'), cTID('Qcsa') );
    var ldesc = new ActionDescriptor();
    ldesc.putUnitDouble( cTID('Hrzn'), cTID('#Pxl'), hrzn );
    ldesc.putUnitDouble( cTID('Vrtc'), cTID('#Pxl'), vrtc );
    desc.putObject( cTID('Ofst'), cTID('Ofst'), ldesc );
    desc.putUnitDouble( cTID('Wdth'), cTID('#Prc'), prc );
    desc.putUnitDouble( cTID('Hght'), cTID('#Prc'), prc );
    executeAction( cTID('Trnf'), desc, DialogModes.NO );
  };

  Stdlib.wrapLCLayer(doc, layer, _ftn);
};

function main() {
  if (app.documents.length == 0) {
    alert("Please open a template document before running this script.");
    return;
  }
  var doc = app.activeDocument;
  var layer = doc.activeLayer;
  if (layer.kind != LayerKind.NORMAL) {
    var oldLayer = layer;
    layer = doc.artLayers.add();
    layer.kind = LayerKind.NORMAL;
    layer.move(oldLayer, ElementPlacement.PLACEAFTER);
  }

  var ini = GenericUI.readIni(InsertImageOptions.INI_FILE);
  var opts = new InsertImageOptions(ini);
  var proc = new Processor(opts);

  var ru = app.preferences.rulerUnits;
  app.preferences.rulerUnits = Units.PIXELS;

  try {
    opts = proc.insertImageIntoLayer(doc, layer);

  } catch (e) {
    alert("Unexpected error: " + e.toString() + '@' + e.line);
    return;

  } finally {
    app.preferences.rulerUnits = ru;
  }

  if (opts) {
    GenericUI.writeIni(InsertImageOptions.INI_FILE, opts);
  }
};

main();

"InsertImage.jsx";
// EOF
