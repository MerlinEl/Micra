//
// ReplaceSmartLayers.js
//
// $Id: ReplaceSmartLayers.jsx,v 1.2 2010/06/16 06:02:30 anonymous Exp $
// Copyright: (c)2010, xbytor
// License: http://www.opensource.org/licenses/bsd-license.php
// Contact: xbytor@gmail.com
//
//@show include
//
app;
//
//@includepath "/c/Program Files/Adobe/xtools;/Developer/xtools"
//
//@include "xlib/stdlib.js"
//

function copyMask(targetIdx) {
  var idMk = charIDToTypeID( "Mk  " );
  var desc87 = new ActionDescriptor();
  desc87.putClass( cTID('Nw  '), cTID('Chnl') );
  var ref74 = new ActionReference();
  ref74.putEnumerated( cTID('Chnl'), cTID('Chnl'), cTID('Msk ') );
  ref74.putIndex( cTID('Lyr '), targetIdx );
  desc87.putReference( cTID('At  '), ref74 );
  var ref75 = new ActionReference();
  ref75.putEnumerated( cTID('Chnl'), cTID('Chnl'), cTID('Msk ') );
  ref75.putEnumerated( cTID('Lyr '), cTID('Ordn'), cTID('Trgt') );
  desc87.putReference( cTID('Usng'), ref75 );
  executeAction( idMk, desc87, DialogModes.NO );
};


function copyVectorMask(targetIdx) {
  var desc18 = new ActionDescriptor();
  var ref22 = new ActionReference();
  ref22.putClass( cTID('Path') );
  desc18.putReference( cTID('null'), ref22 );
  var ref23 = new ActionReference();
  ref23.putEnumerated( cTID('Path'), cTID('Path'), sTID('vectorMask') );
  ref23.putIndex( cTID('Lyr '), targetIdx);
  desc18.putReference( cTID('At  '), ref23 );
  var ref24 = new ActionReference();
  ref24.putEnumerated( cTID('Path'), cTID('Path'), sTID('vectorMask') );
  ref24.putEnumerated( cTID('Lyr '), cTID('Ordn'), cTID('Trgt') );
  desc18.putReference( cTID('Usng'), ref24 );
  executeAction( cTID('Mk  '), desc18, DialogModes.NO );
};


function copyLayers(targetIdx) {
  var desc34 = new ActionDescriptor();
  var ref41 = new ActionReference();
  ref41.putEnumerated( cTID('Lyr '), cTID('Ordn'), cTID('Trgt') );
  desc34.putReference( cTID('null'), ref41 );
  var ref42 = new ActionReference();
  ref42.putIndex( cTID('Dcmn'), targetIdx);
  desc34.putReference( cTID('T   '), ref42 );
  desc34.putInteger( cTID('Vrsn'), 5 );
  executeAction( cTID('Dplc'), desc34, DialogModes.NO );
};

function main() {
  if (app.documents.length == 0) {
    return;
  }

  var ru = app.preferences.rulerUnits;

  try {
    app.preferences.rulerUnits = Units.PIXELS;

    var doc = app.activeDocument;
    var rez = doc.resolution;
    doc.resizeImage( undefined, undefined, 72, ResampleMethod.NONE );

    var layers = Stdlib.getLayersList(doc);
    doc.activeLayer = layers[layers.length-1];

    // var layers = [doc.activeLayer];

    for (var i = 0; i < layers.length; i++) {
      var layer = layers[i];
      if (layer.isBackgroundLayer || layer.kind != LayerKind.SMARTOBJECT) {
        continue;
      }

      doc.activeLayer = layer;
      Stdlib.newGroupFromLayers(doc);

      var grouped = layer.grouped;
      if (grouped) {
        layer.grouped = false;
      }

      var group = doc.activeLayer;
      var didx = Stdlib.getDocumentIndex(doc);

      group.name = layer.name;
      doc.activeLayer = layer;

      if (Stdlib.hasLayerMask(doc, layer)) {
        Stdlib.disableLayerMask(doc, layer, false);
      }
      if (Stdlib.hasVectorMask(doc, layer)) {
        Stdlib.disableVectorMask(doc, layer);
      }

      group.blendMode = layer.blendMode;
      group.fillOpacity = layer.fillOpacity;
      group.opacity = layer.opacity;
      var bnds = Stdlib.getLayerBounds(doc, layer);

      var so = Stdlib.editSmartObject(doc, layer);
      so.resizeImage( undefined, undefined, 72, ResampleMethod.NONE );

      var lset = Stdlib.getLayersList(so);
      if (lset.length > 0) {
        Stdlib.selectLayers(so, lset);
      }

      copyLayers(didx);
      so.close(SaveOptions.DONOTSAVECHANGES);

      var grp = Stdlib.newGroupFromLayers(doc);

      Stdlib.transformLayer(doc, grp, bnds);
      Stdlib.deleteGroup(doc, grp);

      var gidx = Stdlib.getLayerIndex(doc, group);
      doc.activeLayer = layer;

      if (Stdlib.hasLayerMask(doc, layer)) {
        copyMask(gidx);
      }
      if (Stdlib.hasVectorMask(doc, layer)) {
        copyVectorMask(gidx);
      }
      layer.remove();
      group.grouped = grouped;
    }

    doc.resizeImage( undefined, undefined, rez, ResampleMethod.NONE );

  } finally {
    app.preferences.rulerUnits = ru;
  }
}

main();

"ReplaceSmartLayers.jsx";
// EOF