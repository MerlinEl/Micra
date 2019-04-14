function alertIncluded(){
  alert('included');
}

// -----------------------------------------
// newStrokeEffect()
//   strokeSize:           // 0 - 250 px
//   strokeColor:          // SolidColor()
// -----------------------------------------
function newStrokeEffect(strokeSize, strokeColor, strokePosition) {
    var effectDescriptor = new ActionDescriptor();
    var effectColor = new ActionDescriptor();
    var strokeOpacity = 100.0;      // 0 - 100 %
    var strokeBlend = "Nrml";       // Normal[Nrml], ColorBurn[CBrn], SoftLight[SftL}, Color[Clr ]

    effectDescriptor.putBoolean(charIDToTypeID("enab"), true);
    effectDescriptor.putEnumerated(charIDToTypeID("Styl"), charIDToTypeID("FStl"), charIDToTypeID(strokePosition));
    effectDescriptor.putEnumerated(charIDToTypeID("PntT"), charIDToTypeID("FrFl"), charIDToTypeID("SClr"));
    effectDescriptor.putEnumerated(charIDToTypeID("Md  "), charIDToTypeID("BlnM"), charIDToTypeID(strokeBlend));
    effectDescriptor.putUnitDouble(charIDToTypeID("Opct"), charIDToTypeID("#Prc"), strokeOpacity);
    effectDescriptor.putUnitDouble(charIDToTypeID("Sz  "), charIDToTypeID("#Pxl"), strokeSize);
    effectColor.putDouble(charIDToTypeID("Rd  "), strokeColor.rgb.red);
    effectColor.putDouble(charIDToTypeID("Grn "), strokeColor.rgb.green);
    effectColor.putDouble(charIDToTypeID("Bl  "), strokeColor.rgb.blue);
    effectDescriptor.putObject(charIDToTypeID("Clr "), charIDToTypeID("RGBC"), effectColor);
    return(effectDescriptor);
}

// -----------------------------------------
// newColorOverlayEffect()
//   overlayOpacity:       // 0 - 100 %
//   overlayColor:         // SolidColor()
// -----------------------------------------
function newColorOverlayEffect(overlayOpacity, overlayColor) {
    
   alert("newColorOverlayEffect")
    var effectDescriptor = new ActionDescriptor();
    var effectColor = new ActionDescriptor();
    effectDescriptor.putBoolean(charIDToTypeID("enab"), true);
    effectDescriptor.putEnumerated(charIDToTypeID("Md  "), charIDToTypeID("BlnM"), charIDToTypeID("Nrml")); //Clr, Nrml, Mltp
    effectDescriptor.putUnitDouble(charIDToTypeID("Opct"), charIDToTypeID("#Prc"), overlayOpacity);
    effectColor.putDouble(charIDToTypeID("Rd  "), overlayColor.rgb.red);
    effectColor.putDouble(charIDToTypeID("Grn "), overlayColor.rgb.green);
    effectColor.putDouble(charIDToTypeID("Bl  "), overlayColor.rgb.blue);
    effectDescriptor.putObject(charIDToTypeID("Clr "), charIDToTypeID("RGBC"), effectColor);
    return(effectDescriptor);
}

// -----------------------------------------
// newDropShadowEffect()
//   dropShadowColor:      // SolidColor()
//   dropShadowDistance:   // 0 - 30000 px
//   dropShadowSpread:     // 0 - 100 px
//   dropShadowSize:       // 0 - 250 px
//   dropShadowAngle:      // -180 - +180 °
// -----------------------------------------
function newDropShadowEffect(globalLightDesc, dropShadowColor, dropShadowAngle,
                             dropShadowSize, dropShadowDistance, dropShadowSpread) {
    var effectDescriptor = new ActionDescriptor();
    var effectColor = new ActionDescriptor();
    var effectContour = new ActionDescriptor();
    var dropShadowOpacity = 100.0;          // 0 - 100 %
    var dropShadowNoise = 0.0;              // 0 - 100 %

    //------------------------------------
    // insert the global light description
    //------------------------------------
    if (globalLightDesc != null)
        globalLightDesc.putUnitDouble(charIDToTypeID("gagl"), charIDToTypeID("#Ang"), dropShadowAngle);
    //----------------------------------
    // build the drop shadow description
    //----------------------------------
    effectDescriptor.putBoolean(charIDToTypeID("enab"), true);
    effectDescriptor.putEnumerated(charIDToTypeID("Md  "), charIDToTypeID("BlnM"), charIDToTypeID("Mltp"));
    effectColor.putDouble(charIDToTypeID("Rd  "), dropShadowColor.rgb.red);
    effectColor.putDouble(charIDToTypeID("Grn "), dropShadowColor.rgb.green);
    effectColor.putDouble(charIDToTypeID("Bl  "), dropShadowColor.rgb.blue);
    effectDescriptor.putObject(charIDToTypeID("Clr "), charIDToTypeID("RGBC"), effectColor);
    effectDescriptor.putUnitDouble(charIDToTypeID("Opct"), charIDToTypeID("#Prc"), dropShadowOpacity);
    if (globalLightDesc != null) {
        effectDescriptor.putBoolean(charIDToTypeID("uglg"), true);
    } else {
        effectDescriptor.putBoolean(charIDToTypeID("uglg"), false);
        effectDescriptor.putUnitDouble(charIDToTypeID("lagl"), charIDToTypeID("#Ang"), dropShadowAngle);
    }
    effectDescriptor.putUnitDouble(charIDToTypeID("Dstn"), charIDToTypeID("#Pxl"), dropShadowDistance);
    effectDescriptor.putUnitDouble(charIDToTypeID("Ckmt"), charIDToTypeID("#Pxl"), dropShadowSize);
    effectDescriptor.putUnitDouble(charIDToTypeID("blur"), charIDToTypeID("#Pxl"), dropShadowSpread);
    effectDescriptor.putUnitDouble(charIDToTypeID("Nose"), charIDToTypeID("#Prc"), dropShadowNoise);
    effectDescriptor.putBoolean(charIDToTypeID("AntA"), false);
    effectContour.putString(charIDToTypeID("Nm  "), "Linear");
    effectDescriptor.putObject(charIDToTypeID("TrnS"), charIDToTypeID("ShpC"), effectContour);
    effectDescriptor.putBoolean(stringIDToTypeID("layerConceals"), true);
    return(effectDescriptor);
}

// -----------------------------------------
// newBevelEmbossEffect()
//   embossDepth:          // 0 - 1000 %
//   embossSize:           // 0 - 250 px
//   embossSoften:         // 0 - 16 px
//   shadingAngle:         // -180 - +180 °
//   shadingAltitude:      // 0 - 90 °
// -----------------------------------------
function newBevelEmbossEffect(globalLightDesc, embossDepth, embossSize, embossSoften,
                              shadingAngle, shadingAltitude) {
    var effectDescriptor = new ActionDescriptor();
    var effectHighlightColor = new ActionDescriptor();
    var effectShadowColor = new ActionDescriptor();
    var effectShadingContour = new ActionDescriptor();
    var effectContour = new ActionDescriptor();
    var shadingShadowColor = new newRGBColor(0, 0, 0);            // black
    var shadingHighlightColor = new newRGBColor(255, 255, 255);   // white
    var shadingHighlightOpacity = 85.0;                           // 0 - 100 %
    var shadingShadowOpacity = 85.0;                              // 0 - 100 %
    var contourRange = 50.0;                                      // 0 - 100 %

    //------------------------------------
    // insert the global light description
    //------------------------------------
    if (globalLightDesc != null) {
        globalLightDesc.putUnitDouble(charIDToTypeID("gagl"), charIDToTypeID("#Ang"), shadingAngle);
        globalLightDesc.putUnitDouble(stringIDToTypeID("globalAltitude"),
                                      charIDToTypeID("#Ang"), shadingAltitude);
    }
    //-------------------------------------
    // build the bevel & emboss description
    //-------------------------------------
    effectDescriptor.putBoolean(charIDToTypeID("enab"), true);
    effectDescriptor.putEnumerated(charIDToTypeID("hglM"), charIDToTypeID("BlnM"), charIDToTypeID("Scrn"));
    effectHighlightColor.putDouble(charIDToTypeID("Rd  "), shadingHighlightColor.rgb.red);
    effectHighlightColor.putDouble(charIDToTypeID("Grn "), shadingHighlightColor.rgb.green);
    effectHighlightColor.putDouble(charIDToTypeID("Bl  "), shadingHighlightColor.rgb.blue);
    effectDescriptor.putObject(charIDToTypeID("hglC"), charIDToTypeID("RGBC"), effectHighlightColor);
    effectDescriptor.putUnitDouble(charIDToTypeID("hglO"), charIDToTypeID("#Prc"), shadingHighlightOpacity);
    effectDescriptor.putEnumerated(charIDToTypeID("sdwM"), charIDToTypeID("BlnM"), charIDToTypeID("Mltp"));
    effectShadowColor.putDouble(charIDToTypeID("Rd  "), shadingShadowColor.rgb.red);
    effectShadowColor.putDouble(charIDToTypeID("Grn "), shadingShadowColor.rgb.green);
    effectShadowColor.putDouble(charIDToTypeID("Bl  "), shadingShadowColor.rgb.blue);
    effectDescriptor.putObject(charIDToTypeID("sdwC"), charIDToTypeID("RGBC"), effectShadowColor);
    effectDescriptor.putUnitDouble(charIDToTypeID("sdwO"), charIDToTypeID("#Prc"), shadingShadowOpacity);
    effectDescriptor.putEnumerated(charIDToTypeID("bvlT"), charIDToTypeID("bvlT"), charIDToTypeID("SfBL"));
    effectDescriptor.putEnumerated(charIDToTypeID("bvlS"), charIDToTypeID("BESl"), charIDToTypeID("InrB"));
    if (globalLightDesc != null) {
        effectDescriptor.putBoolean(charIDToTypeID("uglg"), true);
    } else {
        effectDescriptor.putBoolean(charIDToTypeID("uglg"), false);
        effectDescriptor.putUnitDouble(charIDToTypeID("lagl"), charIDToTypeID("#Ang"), shadingAngle);
        effectDescriptor.putUnitDouble(charIDToTypeID("Lald"), charIDToTypeID("#Ang"), shadingAltitude);
    }
    effectDescriptor.putUnitDouble(charIDToTypeID("srgR"), charIDToTypeID("#Prc"), embossDepth);
    effectDescriptor.putUnitDouble(charIDToTypeID("blur"), charIDToTypeID("#Pxl"), embossSize);
    effectDescriptor.putEnumerated(charIDToTypeID("bvlD"), charIDToTypeID("BESs"), charIDToTypeID("Out "));
    effectShadingContour.putString(charIDToTypeID("Nm  "), "Linear");
    effectDescriptor.putObject(charIDToTypeID("TrnS"), charIDToTypeID("ShpC"), effectShadingContour);
    effectDescriptor.putBoolean(stringIDToTypeID("antialiasGloss"), false);
    effectDescriptor.putUnitDouble(charIDToTypeID("Sftn"), charIDToTypeID("#Pxl"), embossSoften);
    effectDescriptor.putBoolean(stringIDToTypeID("useShape"), true);
    effectContour.putString(charIDToTypeID("Nm  "), "Linear");
    effectDescriptor.putObject(charIDToTypeID("MpgS"), charIDToTypeID("ShpC"), effectContour);
    effectDescriptor.putBoolean(charIDToTypeID("AntA"), false);
    effectDescriptor.putUnitDouble(charIDToTypeID("Inpr"), charIDToTypeID("#Prc"), contourRange);
    effectDescriptor.putBoolean(stringIDToTypeID("useTexture"), false);
    return(effectDescriptor);
}

// -----------------------------------------
// newGlowEffect()
//   glowOpacity = 100.0;            // 0 - 100 %
//   glowSize = 20.0;                // 0 - 250 px
//   contourName = "Ring - Double";  // [Linear], [Ring], [Ring - Double]
// -----------------------------------------
function newGlowEffect(glowColor, glowOpacity, glowSize, contourName) {
    var effectDescriptor = new ActionDescriptor();
    var effectColor = new ActionDescriptor();
    var glowContour = new ActionDescriptor();
    var glowBlendMode = "Nrml";         // normal[Nrml], screen[Scrn]
    var glowSpread = 15.0;              // 0 - 100 %
    var glowNoise = 0.0;                // 0 - 100 %
    var contourRange = 50.0;            // 0 - 100 %
    var contourJitter = 0.0;            // 0 - 100 %

    //-------------------------------------
    // build the glow description
    //-------------------------------------
    effectDescriptor.putEnumerated(charIDToTypeID("Md  "), charIDToTypeID("BlnM"), charIDToTypeID(glowBlendMode));
    effectColor.putDouble(charIDToTypeID("Rd  "), glowColor.rgb.red);
    effectColor.putDouble(charIDToTypeID("Grn "), glowColor.rgb.green);
    effectColor.putDouble(charIDToTypeID("Bl  "), glowColor.rgb.blue);
    effectDescriptor.putObject(charIDToTypeID("Clr "), charIDToTypeID("RGBC"), effectColor);
    effectDescriptor.putUnitDouble(charIDToTypeID("Opct"), charIDToTypeID("#Prc"), glowOpacity);
    effectDescriptor.putEnumerated(charIDToTypeID("GlwT"), charIDToTypeID("BETE"), charIDToTypeID("SfBL"));
    effectDescriptor.putUnitDouble(charIDToTypeID("Ckmt"), charIDToTypeID("#Pxl"), glowSpread);
    effectDescriptor.putUnitDouble(charIDToTypeID("blur"), charIDToTypeID("#Pxl"), glowSize);
    effectDescriptor.putUnitDouble(charIDToTypeID("Nose"), charIDToTypeID("#Prc"), glowNoise);
    effectDescriptor.putUnitDouble(charIDToTypeID("ShdN"), charIDToTypeID("#Prc"), contourJitter);
    effectDescriptor.putBoolean(charIDToTypeID("AntA"), false);
    glowContour.putString(charIDToTypeID("Nm  "), contourName);
    effectDescriptor.putObject(charIDToTypeID("TrnS"), charIDToTypeID("ShpC"), glowContour);
    effectDescriptor.putUnitDouble(charIDToTypeID("Inpr"), charIDToTypeID("#Prc"), contourRange);
    return(effectDescriptor);
}

// -----------------------------------------
// newSatinEffect()
//   satinColor:               // SolidColor()
//   satinOpacity = 50.0;      // 0 - 100 %
//   satinAngle = 19.0;        // -180 - +180 °
//   satinDistance = 11.0;     // 0 - 250 px
//   satinBlur = 14.0;         // 0 - 250 px
// -----------------------------------------
function newSatinEffect(satinColor, satinOpacity, satinDistance, satinAngle, satinBlur) {
    var effectDescriptor = new ActionDescriptor();
    var effectColor = new ActionDescriptor();
    var effectBlur = new ActionDescriptor();

    effectDescriptor.putBoolean(charIDToTypeID("enab"), true);
    effectDescriptor.putEnumerated(charIDToTypeID("Md  "), charIDToTypeID("BlnM"), charIDToTypeID("Mltp"));
    effectColor.putDouble(charIDToTypeID("Rd  "), satinColor.rgb.red);
    effectColor.putDouble(charIDToTypeID("Grn "), satinColor.rgb.green);
    effectColor.putDouble(charIDToTypeID("Bl  "), satinColor.rgb.blue);
    effectDescriptor.putObject(charIDToTypeID("Clr "), charIDToTypeID("RGBC"), effectColor);
    effectDescriptor.putBoolean(charIDToTypeID("AntA"), false);
    effectDescriptor.putBoolean(charIDToTypeID("Invr"), true);
    effectDescriptor.putUnitDouble(charIDToTypeID("Opct"), charIDToTypeID("#Prc"), satinOpacity);
    effectDescriptor.putUnitDouble(charIDToTypeID("lagl"), charIDToTypeID("#Ang"), satinAngle);
    effectDescriptor.putUnitDouble(charIDToTypeID("Dstn"), charIDToTypeID("#Pxl"), satinDistance);
    effectDescriptor.putUnitDouble(charIDToTypeID("blur"), charIDToTypeID("#Pxl"), satinBlur);
    effectBlur.putString(charIDToTypeID("Nm  "), "Gaussian");
    effectDescriptor.putObject(charIDToTypeID("MpgS"), charIDToTypeID("ShpC"), effectBlur);
    return(effectDescriptor);
}

// -----------------------------------------
// scaleLayerEffects() 0-1000%
// -----------------------------------------
function scaleLayerEffects(scale) {
    var desc = new ActionDescriptor();
    var ex;

    try {
        desc.putUnitDouble(charIDToTypeID("Scl "), charIDToTypeID("#Prc"), scale);
        executeAction(stringIDToTypeID("scaleEffectsEvent"), desc, DialogModes.NO);
    } catch(ex) {
        /// alert(scriptName + " scaleLayerEffects(" + scale + "%) exception caught? line[" + ex.line + "] "  + ex);
    }
    return;
}

// -----------------------------------------
// deleteLayerEffects()
// -----------------------------------------
function deleteLayerEffects() {
    var refr = new ActionReference();
    var desc = new ActionDescriptor();
    var ex;

    try {
        refr.putEnumerated(charIDToTypeID("Lyr "), charIDToTypeID("Ordn"), charIDToTypeID("Trgt"));
        desc.putReference(charIDToTypeID("null"), refr);
        executeAction(charIDToTypeID("dlfx"), desc, DialogModes.NO);
    } catch(ex) {
        /// alert(scriptName + " deleteLayerEffects() exception caught? line[" + ex.line + "] "  + ex);
    }
    return;
}