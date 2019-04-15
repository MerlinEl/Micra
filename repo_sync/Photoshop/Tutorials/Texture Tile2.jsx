#target photoshop
//
// Texture Tile2.jsx
//

//
// Generated Mon Apr 15 2019 15:39:32 GMT+0200
//

cTID = function(s) { return app.charIDToTypeID(s); };
sTID = function(s) { return app.stringIDToTypeID(s); };

//
// Texture Tile
//
//
//==================== offset_x ==============
//
function offset_x() {
  // Offset
  function step1(enabled, withDialog) {
    if (enabled != undefined && !enabled)
      return;
    var dialogMode = (withDialog ? DialogModes.ALL : DialogModes.NO);
    var desc1 = new ActionDescriptor();
    desc1.putInteger(cTID('Hrzn'), 256);
    desc1.putInteger(cTID('Vrtc'), 0);
    desc1.putEnumerated(cTID('Fl  '), cTID('FlMd'), cTID('Wrp '));
    executeAction(cTID('Ofst'), desc1, dialogMode);
  };

  step1();      // Offset
};

//
//==================== offset_y ==============
//
function offset_y() {
  // Offset
  function step1(enabled, withDialog) {
    if (enabled != undefined && !enabled)
      return;
    var dialogMode = (withDialog ? DialogModes.ALL : DialogModes.NO);
    var desc1 = new ActionDescriptor();
    desc1.putInteger(cTID('Hrzn'), 0);
    desc1.putInteger(cTID('Vrtc'), 256);
    desc1.putEnumerated(cTID('Fl  '), cTID('FlMd'), cTID('Wrp '));
    executeAction(cTID('Ofst'), desc1, dialogMode);
  };

  step1();      // Offset
};

// EOF

"Texture Tile2.jsx"
// EOF
