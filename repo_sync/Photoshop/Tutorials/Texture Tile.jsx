#target photoshop
//
// Texture Tile.jsx
//

//
// Generated Mon Apr 15 2019 11:31:47 GMT+0200
//

cTID = function(s) { return app.charIDToTypeID(s); };
sTID = function(s) { return app.stringIDToTypeID(s); };

//
// Texture Tile
//
//
//==================== Define_Pattern ==============
//
function Define_Pattern() {
  // Make
  function step1(enabled, withDialog) {
    if (enabled != undefined && !enabled)
      return;
    var dialogMode = (withDialog ? DialogModes.ALL : DialogModes.NO);
    var desc1 = new ActionDescriptor();
    var ref1 = new ActionReference();
    ref1.putClass(cTID('Ptrn'));
    desc1.putReference(cTID('null'), ref1);
    var ref2 = new ActionReference();
    ref2.putProperty(cTID('Prpr'), sTID("selection"));
    ref2.putEnumerated(cTID('Dcmn'), cTID('Ordn'), cTID('Trgt'));
    desc1.putReference(cTID('Usng'), ref2);
    desc1.putString(cTID('Nm  '), "TILE_PATTERN_TEXTURE");
    executeAction(cTID('Mk  '), desc1, dialogMode);
  };

  step1();      // Make
};

//
//==================== Preview_Tile ==============
//
function Preview_Tile() {
  // Make
  function step1(enabled, withDialog) {
    if (enabled != undefined && !enabled)
      return;
    var dialogMode = (withDialog ? DialogModes.ALL : DialogModes.NO);
    var desc1 = new ActionDescriptor();
    var desc2 = new ActionDescriptor();
    desc2.putBoolean(sTID("artboard"), false);
    desc2.putClass(cTID('Md  '), sTID("RGBColorMode"));
    desc2.putUnitDouble(cTID('Wdth'), cTID('#Rlt'), 2048);
    desc2.putUnitDouble(cTID('Hght'), cTID('#Rlt'), 2048);
    desc2.putUnitDouble(cTID('Rslt'), cTID('#Rsl'), 72);
    desc2.putDouble(sTID("pixelScaleFactor"), 1);
    desc2.putEnumerated(cTID('Fl  '), cTID('Fl  '), cTID('Wht '));
    desc2.putInteger(cTID('Dpth'), 8);
    desc2.putString(sTID("profile"), "sRGB IEC61966-2.1");
    var list1 = new ActionList();
    desc2.putList(cTID('Gdes'), list1);
    desc1.putObject(cTID('Nw  '), cTID('Dcmn'), desc2);
    desc1.putInteger(cTID('DocI'), 217);
    executeAction(cTID('Mk  '), desc1, dialogMode);
  };

  // Set
  function step2(enabled, withDialog) {
    if (enabled != undefined && !enabled)
      return;
    var dialogMode = (withDialog ? DialogModes.ALL : DialogModes.NO);
    var desc1 = new ActionDescriptor();
    var ref1 = new ActionReference();
    ref1.putProperty(cTID('Lyr '), cTID('Bckg'));
    desc1.putReference(cTID('null'), ref1);
    var desc2 = new ActionDescriptor();
    desc2.putUnitDouble(cTID('Opct'), cTID('#Prc'), 100);
    desc2.putEnumerated(cTID('Md  '), cTID('BlnM'), cTID('Nrml'));
    desc1.putObject(cTID('T   '), cTID('Lyr '), desc2);
    desc1.putInteger(cTID('LyrI'), 2);
    executeAction(cTID('setd'), desc1, dialogMode);
  };

  // Set
  function step3(enabled, withDialog) {
    if (enabled != undefined && !enabled)
      return;
    var dialogMode = (withDialog ? DialogModes.ALL : DialogModes.NO);
    var desc1 = new ActionDescriptor();
    var ref1 = new ActionReference();
    ref1.putProperty(cTID('Prpr'), cTID('Lefx'));
    ref1.putEnumerated(cTID('Lyr '), cTID('Ordn'), cTID('Trgt'));
    desc1.putReference(cTID('null'), ref1);
    var desc2 = new ActionDescriptor();
    desc2.putUnitDouble(cTID('Scl '), cTID('#Prc'), 100);
    var desc3 = new ActionDescriptor();
    desc3.putBoolean(cTID('enab'), true);
    desc3.putBoolean(sTID("present"), true);
    desc3.putBoolean(sTID("showInDialog"), true);
    desc3.putEnumerated(cTID('Md  '), cTID('BlnM'), cTID('Nrml'));
    desc3.putUnitDouble(cTID('Opct'), cTID('#Prc'), 100);
    var desc4 = new ActionDescriptor();
    desc4.putString(cTID('Nm  '), "TILE_PATTERN_TEXTURE");
    desc4.putString(cTID('Idnt'), "0015f8ad-2b72-eb42-8ef8-fc232a98a33b");
    desc3.putObject(cTID('Ptrn'), cTID('Ptrn'), desc4);
    desc3.putUnitDouble(cTID('Scl '), cTID('#Prc'), 100);
    desc3.putBoolean(cTID('Algn'), true);
    var desc5 = new ActionDescriptor();
    desc5.putDouble(cTID('Hrzn'), 0);
    desc5.putDouble(cTID('Vrtc'), 0);
    desc3.putObject(sTID("phase"), cTID('Pnt '), desc5);
    desc2.putObject(sTID("patternFill"), sTID("patternFill"), desc3);
    desc1.putObject(cTID('T   '), cTID('Lefx'), desc2);
    executeAction(cTID('setd'), desc1, dialogMode);
  };

  step1();      // Make
  step2();      // Set
  step3();      // Set
};

//
//==================== Update_Tile ==============
//
function Update_Tile() {
  // Make
  function step1(enabled, withDialog) {
    if (enabled != undefined && !enabled)
      return;
    var dialogMode = (withDialog ? DialogModes.ALL : DialogModes.NO);
    var desc1 = new ActionDescriptor();
    var ref1 = new ActionReference();
    ref1.putClass(cTID('Ptrn'));
    desc1.putReference(cTID('null'), ref1);
    var ref2 = new ActionReference();
    ref2.putProperty(cTID('Prpr'), sTID("selection"));
    ref2.putEnumerated(cTID('Dcmn'), cTID('Ordn'), cTID('Trgt'));
    desc1.putReference(cTID('Usng'), ref2);
    desc1.putString(cTID('Nm  '), "TILE_PATTERN_TEXTURE");
    executeAction(cTID('Mk  '), desc1, dialogMode);
  };

  // Select
  function step2(enabled, withDialog) {
    if (enabled != undefined && !enabled)
      return;
    var dialogMode = (withDialog ? DialogModes.ALL : DialogModes.NO);
    var desc1 = new ActionDescriptor();
    var ref1 = new ActionReference();
    ref1.putOffset(cTID('Dcmn'), 1);
    desc1.putReference(cTID('null'), ref1);
    desc1.putInteger(cTID('DocI'), 217);
    executeAction(cTID('slct'), desc1, dialogMode);
  };

  // Set
  function step3(enabled, withDialog) {
    if (enabled != undefined && !enabled)
      return;
    var dialogMode = (withDialog ? DialogModes.ALL : DialogModes.NO);
    var desc1 = new ActionDescriptor();
    var ref1 = new ActionReference();
    ref1.putProperty(cTID('Prpr'), cTID('Lefx'));
    ref1.putEnumerated(cTID('Lyr '), cTID('Ordn'), cTID('Trgt'));
    desc1.putReference(cTID('null'), ref1);
    var desc2 = new ActionDescriptor();
    desc2.putUnitDouble(cTID('Scl '), cTID('#Prc'), 100);
    var desc3 = new ActionDescriptor();
    desc3.putBoolean(cTID('enab'), true);
    desc3.putBoolean(sTID("present"), true);
    desc3.putBoolean(sTID("showInDialog"), true);
    desc3.putEnumerated(cTID('Md  '), cTID('BlnM'), cTID('Nrml'));
    desc3.putUnitDouble(cTID('Opct'), cTID('#Prc'), 100);
    var desc4 = new ActionDescriptor();
    desc4.putString(cTID('Nm  '), "TILE_PATTERN_TEXTURE");
    desc4.putString(cTID('Idnt'), "d1768e52-b71c-154b-9d7b-e642a73c625a");
    desc3.putObject(cTID('Ptrn'), cTID('Ptrn'), desc4);
    desc3.putUnitDouble(cTID('Scl '), cTID('#Prc'), 100);
    desc3.putBoolean(cTID('Algn'), true);
    var desc5 = new ActionDescriptor();
    desc5.putDouble(cTID('Hrzn'), 0);
    desc5.putDouble(cTID('Vrtc'), 0);
    desc3.putObject(sTID("phase"), cTID('Pnt '), desc5);
    desc2.putObject(sTID("patternFill"), sTID("patternFill"), desc3);
    desc1.putObject(cTID('T   '), cTID('Lefx'), desc2);
    executeAction(cTID('setd'), desc1, dialogMode);
  };

  // Select
  function step4(enabled, withDialog) {
    if (enabled != undefined && !enabled)
      return;
    var dialogMode = (withDialog ? DialogModes.ALL : DialogModes.NO);
    var desc1 = new ActionDescriptor();
    var ref1 = new ActionReference();
    ref1.putOffset(cTID('Dcmn'), -1);
    desc1.putReference(cTID('null'), ref1);
    desc1.putInteger(cTID('DocI'), 202);
    executeAction(cTID('slct'), desc1, dialogMode);
  };

  step1();      // Make
  step2();      // Select
  step3();      // Set
  step4();      // Select
};

//
//==================== Update ==============
//
function Update() {
  // Make
  function step1(enabled, withDialog) {
    if (enabled != undefined && !enabled)
      return;
    var dialogMode = (withDialog ? DialogModes.ALL : DialogModes.NO);
    var desc1 = new ActionDescriptor();
    var ref1 = new ActionReference();
    ref1.putClass(cTID('Ptrn'));
    desc1.putReference(cTID('null'), ref1);
    var ref2 = new ActionReference();
    ref2.putProperty(cTID('Prpr'), sTID("selection"));
    ref2.putEnumerated(cTID('Dcmn'), cTID('Ordn'), cTID('Trgt'));
    desc1.putReference(cTID('Usng'), ref2);
    desc1.putString(cTID('Nm  '), "TILE_PATTERN_TEXTURE");
    executeAction(cTID('Mk  '), desc1, dialogMode);
  };

  // Select
  function step2(enabled, withDialog) {
    if (enabled != undefined && !enabled)
      return;
    var dialogMode = (withDialog ? DialogModes.ALL : DialogModes.NO);
    var desc1 = new ActionDescriptor();
    var ref1 = new ActionReference();
    ref1.putOffset(cTID('Dcmn'), 1);
    desc1.putReference(cTID('null'), ref1);
    desc1.putInteger(cTID('DocI'), 217);
    executeAction(cTID('slct'), desc1, dialogMode);
  };

  // Delete
  function step3(enabled, withDialog) {
    if (enabled != undefined && !enabled)
      return;
    var dialogMode = (withDialog ? DialogModes.ALL : DialogModes.NO);
    var desc1 = new ActionDescriptor();
    var ref1 = new ActionReference();
    ref1.putIndex(cTID('Ptrn'), 29);
    desc1.putReference(cTID('null'), ref1);
    executeAction(cTID('Dlt '), desc1, dialogMode);
  };

  // Set
  function step4(enabled, withDialog) {
    if (enabled != undefined && !enabled)
      return;
    var dialogMode = (withDialog ? DialogModes.ALL : DialogModes.NO);
    var desc1 = new ActionDescriptor();
    var ref1 = new ActionReference();
    ref1.putProperty(cTID('Prpr'), cTID('Lefx'));
    ref1.putEnumerated(cTID('Lyr '), cTID('Ordn'), cTID('Trgt'));
    desc1.putReference(cTID('null'), ref1);
    var desc2 = new ActionDescriptor();
    desc2.putUnitDouble(cTID('Scl '), cTID('#Prc'), 100);
    var desc3 = new ActionDescriptor();
    desc3.putBoolean(cTID('enab'), true);
    desc3.putBoolean(sTID("present"), true);
    desc3.putBoolean(sTID("showInDialog"), true);
    desc3.putEnumerated(cTID('Md  '), cTID('BlnM'), cTID('Nrml'));
    desc3.putUnitDouble(cTID('Opct'), cTID('#Prc'), 100);
    var desc4 = new ActionDescriptor();
    desc4.putString(cTID('Nm  '), "TILE_PATTERN_TEXTURE");
    desc4.putString(cTID('Idnt'), "e0cf28b3-78a2-2842-a7d8-44bdea23402c");
    desc3.putObject(cTID('Ptrn'), cTID('Ptrn'), desc4);
    desc3.putUnitDouble(cTID('Scl '), cTID('#Prc'), 100);
    desc3.putBoolean(cTID('Algn'), true);
    var desc5 = new ActionDescriptor();
    desc5.putDouble(cTID('Hrzn'), 0);
    desc5.putDouble(cTID('Vrtc'), 0);
    desc3.putObject(sTID("phase"), cTID('Pnt '), desc5);
    desc2.putObject(sTID("patternFill"), sTID("patternFill"), desc3);
    desc1.putObject(cTID('T   '), cTID('Lefx'), desc2);
    executeAction(cTID('setd'), desc1, dialogMode);
  };

  // Select
  function step5(enabled, withDialog) {
    if (enabled != undefined && !enabled)
      return;
    var dialogMode = (withDialog ? DialogModes.ALL : DialogModes.NO);
    var desc1 = new ActionDescriptor();
    var ref1 = new ActionReference();
    ref1.putOffset(cTID('Dcmn'), -1);
    desc1.putReference(cTID('null'), ref1);
    desc1.putInteger(cTID('DocI'), 202);
    executeAction(cTID('slct'), desc1, dialogMode);
  };

  step1();      // Make
  step2();      // Select
  step3();      // Delete
  step4();      // Set
  step5();      // Select
};

//
//==================== Edit_Pattern ==============
//
function Edit_Pattern() {
  // Rename
  function step1(enabled, withDialog) {
    if (enabled != undefined && !enabled)
      return;
    var dialogMode = (withDialog ? DialogModes.ALL : DialogModes.NO);
    var desc1 = new ActionDescriptor();
    var ref1 = new ActionReference();
    ref1.putIndex(cTID('Ptrn'), 28);
    desc1.putReference(cTID('null'), ref1);
    desc1.putString(cTID('T   '), "TILE_PATTERN_TEXTURE2");
    executeAction(cTID('Rnm '), desc1, dialogMode);
  };

  // Fill
  function step2(enabled, withDialog) {
    if (enabled != undefined && !enabled)
      return;
    var dialogMode = (withDialog ? DialogModes.ALL : DialogModes.NO);
    var desc1 = new ActionDescriptor();
    desc1.putEnumerated(cTID('Usng'), cTID('FlCn'), cTID('Ptrn'));
    var desc2 = new ActionDescriptor();
    desc2.putString(cTID('Nm  '), "TILE_PATTERN_TEXTURE2");
    desc2.putString(cTID('Idnt'), "1e8b0550-f8c9-5946-a14c-eca6644e2535");
    desc1.putObject(cTID('Ptrn'), cTID('Ptrn'), desc2);
    desc1.putUnitDouble(cTID('Opct'), cTID('#Prc'), 100);
    desc1.putEnumerated(cTID('Md  '), cTID('BlnM'), cTID('Nrml'));
    executeAction(cTID('Fl  '), desc1, dialogMode);
  };

  step1();      // Rename
  step2();      // Fill
};

// EOF

"Texture Tile.jsx"
// EOF
