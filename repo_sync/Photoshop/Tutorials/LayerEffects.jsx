// ======================================
// Photoshop CS javascript: Apply Layer Effects
// Apply layer style effects to one or all layers
// Copyright (c) 2006 Rags Gardner.  All Rights Reserved.
// Rags Gardner www.rags-int-inc.com
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided the following conditions are met:
//
// 1. Redistribution in source code must contain the above copyright notice,
//    this list of conditions and the following disclaimer.
// 2. Redistribution in binary form must reproduce the above copyright
//    notice, this list of conditions and the following disclaimer in the
//    documentation and/or other matereials provided with the distribution.
// 3. The name of the author may not be used to promote or endorse products
//    derived from this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
// THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
// EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
// PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
// PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
// LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
// NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
// =======================================================
//
// This will set layer style effects based on user options
// Note: only normal art layers that are not in a layer set
// will be included, no background, text, or adjustment layers.
//
// Change History
// 05/31/06 V1.0   Initial Release
// 02/28/08 V1.2   Vista: icon image locked? + showUsage()

/// Things To Do:
/// 1) fix persistentIcon = true;

// ======================================
// Configuration Variables
// ======================================
var scriptVersion = "V1.2";                     // the script version
var scriptName = "LayerEffects";                // this script name
var showPsDlgs = DialogModes.NO;                // layer styles Photoshop dialogs NO/ALL
var useIconPreview = true;                      // should we use an icon image for color preview?
var defaultIconName = "LayerEffectsIcon.png";   // default PNG image
var persistentIcon = false;                     // save icon reference: why does this work???

// ======================================
// layer effects configuration defaults
// ======================================
var applyAllLayers = false;                     // apply effects to all layers
var styleScalePct = 100.0;                      // style effects scaling percent
var styleDelete = false;                        // delete layer effects
var strokeEffect = false;                       // enable stroke effect
var overlayEffect = false;                      // enable color overlay effect
var dropShadowEffect = false;                   // enable drop shadow effect
var embossEffect = false;                       // enable bevel emboss effect
var glowEffect = false;                         // enable glow effect
var satinEffect = false;                        // enable satin effect
var strokeColor = newRGBColor(0, 0, 0);         // black
var strokeSize = 10.0;                          // 0 - 250 px
var strokePosition = "InsF";                    // Outside[OutF], Inside[InsF], Center[CtrF]
var overlayColor = newRGBColor(0, 0, 0);        // black
var overlayOpacity = 100.0;                     // 0 - 100 %
var dropShadowColor = newRGBColor(0, 0, 0);     // black
var dropShadowAngle = 120.0;                    // -180 - +180 °
var dropShadowSize = 10.0;                      // 0 - 250 px
var dropShadowDistance = 20.0;                  // 0 - 30000 px
var dropShadowSpread = 5.0;                     // 0 - 100 px;
var embossDepth = 200.0;                        // 0 - 1000 %
var embossSize = 15.0;                          // 0 - 250 px
var embossSoften = 5.0;                         // 0 - 16 px
var shadingAngle = -120.0;                      // -180- +180 °
var shadingAltitude = 30.0;                     // 0 - 90 °
var glowInner = false;                          // inner or outer glow
var glowColor = newRGBColor(0, 0, 0);           // black
var glowOpacity = 100.0;                        // 0 - 100 %
var glowSize = 20.0;                            // 0 - 250 px
var glowContourName = "Linear";                 // [Linear], [Ring], [Ring - Double]
var satinColor = newRGBColor(0, 0, 0);          // black
var satinOpacity = 50.0;                        // 0 - 100 %
var satinAngle = 19.0;                          // -180 - +180 °
var satinDistance = 11.0;                       // 0 - 250 px
var satinBlur = 14.0;                           // 0 - 250 px

// =======================================================================
// Diagnostics and testing
// level: 0-2 (0:disable, 1:break on error, 2:break at beginning)
// =======================================================================
/// $.level = 2;
/// $.level = 1;
/// debugger; // launch debugger on next line
/// var persistentIcon = true;                      /// why does this fail?

// =======================================================
// LayerMenu Dialog Menu Routines
// =======================================================

// -------------------------------------------------------
// LayerMenu()
// Constructor: menu defaults from global configuration
// -------------------------------------------------------
function LayerMenu(useIcon) {
    this.styleScalePct;
    this.styleDelete;
    this.userActionSet;
    this.userAction;
    this.userActionSetIdx;
    this.userActionIdx;
    this.layerArray;
    this.layerIndex;
    this.strokeEffect;
    this.strokeColor;
    this.strokeSize;
    this.strokePosition;
    this.overlayEffect;
    this.overlayColor;
    this.overlayOpacity;
    this.dropShadowColor;
    this.dropShadowEffect;
    this.dropShadowAngle;
    this.dropShadowSize;
    this.dropShadowDistance;
    this.dropShadowSpread;
    this.embossEffect;
    this.embossDepth;
    this.embossSize;
    this.embossSoften;
    this.shadingAngle;
    this.shadingAltitude;
    this.glowEffect;
    this.glowInner;
    this.glowColor;
    this.glowOpacity;
    this.glowSize;
    this.glowContourName;
    this.satinEffect;
    this.satinColor;
    this.satinOpacity;
    this.satinDistance;
    this.satinAngle;
    this.satinBlur;
    this.showPsDlgs;
    this.applyAllLayers;
    this.actionSetInfo;                      // array of actions and sets
    this.isIconValid = useIcon;              // shuld we use the PNG icon
    this.keepIcon = persistentIcon;          // should we leave it open:
    this.winFrameLocation = null;            // current window placement
    this.menuActive = false;                 // event callback initialization switch
    this.dlg = null;                         // the dialog menu window
    return;
}

// -------------------------------------------------------
// LayerMenu.rePop()
// repopulate global variables
// -------------------------------------------------------
LayerMenu.prototype["rePop"] = function() {
    styleScalePct = this.styleScalePct;
    styleDelete = this.styleDelete;
    userActionSet = this.userActionSet;
    userAction = this.userAction;
    userActionSetIdx = this.userActionSetIdx;
    userActionIdx = this.userActionIdx;
    layerArray = this.layerArray;
    layerIndex = this.layerIndex;
    strokeEffect = this.strokeEffect;
    strokeColor = this.strokeColor;
    strokeSize = this.strokeSize;
    strokePosition = this.strokePosition;
    overlayEffect = this.overlayEffect;
    overlayColor = this.overlayColor;
    overlayOpacity = this.overlayOpacity;
    dropShadowColor = this.dropShadowColor;
    dropShadowEffect = this.dropShadowEffect;
    dropShadowAngle = this.dropShadowAngle;
    dropShadowSize = this.dropShadowSize;
    dropShadowDistance = this.dropShadowDistance;
    dropShadowSpread = this.dropShadowSpread;
    embossEffect = this.embossEffect;
    embossDepth = this.embossDepth;
    embossSize = this.embossSize;
    embossSoften = this.embossSoften;
    shadingAngle = this.shadingAngle;
    shadingAltitude = this.shadingAltitude;
    glowEffect = this.glowEffect;
    glowInner = this.glowInner;
    glowColor = this.glowColor;
    glowOpacity = this.glowOpacity;
    glowSize = this.glowSize;
    glowContourName = this.glowContourName;
    satinEffect = this.satinEffect;
    satinColor = this.satinColor;
    satinOpacity = this.satinOpacity;
    satinDistance = this.satinDistance;
    satinAngle = this.satinAngle;
    satinBlur = this.satinBlur;
    showPsDlgs = this.showPsDlgs;
    applyAllLayers = this.applyAllLayers;
    return;
}

// -------------------------------------------------------
// LayerMenu.createDialog()
// create the UI dialog window
// -------------------------------------------------------
LayerMenu.prototype["createDialog"] = function() {
    var listValues;
    var ctlHgt = 20;
    var ctlSpace = 5;
    var i;

    //----------------
    // refresh options
    //----------------
    this.styleScalePct = styleScalePct;
    this.styleDelete = styleDelete;
    this.layerArray = layerArray;
    this.userActionSet = userActionSet;
    this.userAction = userAction;
    this.userActionSetIdx = userActionSetIdx;
    this.userActionIdx = userActionIdx;
    this.layerIndex = layerIndex;
    this.strokeEffect = strokeEffect;
    this.strokeColor = strokeColor;
    this.strokeSize = strokeSize;
    this.strokePosition = strokePosition;
    this.overlayEffect = overlayEffect;
    this.overlayColor = overlayColor;
    this.overlayOpacity = overlayOpacity;
    this.dropShadowColor = dropShadowColor;
    this.dropShadowEffect = dropShadowEffect;
    this.dropShadowAngle = dropShadowAngle;
    this.dropShadowSize = dropShadowSize;
    this.dropShadowDistance = dropShadowDistance;
    this.dropShadowSpread = dropShadowSpread;
    this.embossEffect = embossEffect;
    this.embossDepth = embossDepth;
    this.embossSize = embossSize;
    this.embossSoften = embossSoften;
    this.shadingAngle = shadingAngle;
    this.shadingAltitude = shadingAltitude;
    this.glowEffect = glowEffect;
    this.glowInner = glowInner;
    this.glowColor = glowColor;
    this.glowOpacity = glowOpacity;
    this.glowSize = glowSize;
    this.glowContourName = glowContourName;
    this.satinEffect = satinEffect;
    this.satinColor = satinColor;
    this.satinOpacity = satinOpacity;
    this.satinDistance = satinDistance;
    this.satinAngle = satinAngle;
    this.satinBlur = satinBlur;
    this.showPsDlgs = showPsDlgs;
    this.applyAllLayers = applyAllLayers;
    //-------------------
    // The UI Dialog Menu
    //-------------------
    this.menuActive = false;
    this.dlg = new Window("dialog", "Chose Layer Effects");
    this.dlg.mainGroup = this.dlg.add("group");
    this.dlg.mainGroup.orientation = "row";
    this.dlg.mainGroup.alignChildren = "fill";
    this.dlg.mainGroup.spacing = ctlSpace;
    //--------------------
    // OK & Cancel buttons
    //--------------------
    this.dlg.okBtn = this.dlg.mainGroup.add("button", undefined, "OK", {name:"ok"});
    this.dlg.okBtn.helpTip = "Apply the Layer Action or Effects";
    this.dlg.cancelBtn = this.dlg.mainGroup.add("button", undefined, "Cancel", {name:"cancel"});
    this.dlg.cancelBtn.helpTip = "Cancel Execution";
    //--------------------
    // Add the layer panel
    //--------------------
    this.dlg.layerPanel = this.dlg.add("panel", undefined, "Layer Options");
    this.dlg.layerPanel.orientation = "column";
    this.dlg.layerPanel.alignChildren = "fill";
    this.dlg.layerPanel.spacing = ctlSpace;
    //----------------------
    // Add the layer groups
    //----------------------
    this.dlg.layer1Group = this.dlg.layerPanel.add("group");
    this.dlg.layer1Group.orientation = "row";
    this.dlg.layer1Group.alignChildren = "fill";
    this.dlg.layer1Group.spacing = ctlSpace;
    this.dlg.layer2Group = this.dlg.layerPanel.add("group");
    this.dlg.layer2Group.orientation = "row";
    this.dlg.layer2Group.alignChildren = "fill";
    this.dlg.layer2Group.spacing = ctlSpace;
    this.dlg.layer3Group = this.dlg.layerPanel.add("group");
    this.dlg.layer3Group.orientation = "row";
    this.dlg.layer3Group.alignChildren = "fill";
    this.dlg.layer3Group.spacing = ctlSpace;
    //--------------------
    // layer panel options
    //--------------------
    listValues = new Array();
    listValues[listValues.length] = "all";
    for (i=0; i<layerArray.length; i++)
        listValues[listValues.length] = layerArray[i][1];
    this.dlg.layerSelectionTxt = this.dlg.layer1Group.add("statictext", undefined, "Sel Layer");
    this.dlg.layerSelectionTxt.preferredSize = [60,ctlHgt];
    this.dlg.layerSelectionLstBx = this.dlg.layer1Group.add("dropdownlist", undefined, listValues);
    this.dlg.layerSelectionLstBx.helpTip = "Select a layer for the layer action/effects";
    this.dlg.layerSelectionLstBx.onChange = function() {layerMenu.tryUpdateMenu("LayerSelect");};
    this.dlg.layerSelectionLstBx.preferredSize = [95,ctlHgt];
    if (this.applyAllLayers)
        this.dlg.layerSelectionLstBx.items[0].selected = true;
    else
        this.dlg.layerSelectionLstBx.items[this.layerIndex+1].selected = true;
    //--------------------
    // scale layer effects
    //--------------------
    this.dlg.styleScaleTxt = this.dlg.layer1Group.add("statictext", undefined, "Style Scale%");
    this.dlg.styleScaleTxt.preferredSize = [115,20];
    this.dlg.styleScaleValue = this.dlg.layer1Group.add("edittext", undefined, this.styleScalePct);
    this.dlg.styleScaleValue.preferredSize = [40,20];
    this.dlg.styleScaleValue.onChange = function () {layerMenu.tryUpdateMenu("StyleScale");};
    this.dlg.styleScaleValue.helpTip = "Scale current layer effects (percentage)";
    //-------------------------
    // enable dialogs check box
    //-------------------------
    this.dlg.dialogCb = this.dlg.layer2Group.add("checkbox", undefined, "Enable Dialogs");
    this.dlg.dialogCb.preferredSize = [160,ctlHgt];
    this.dlg.dialogCb.onClick = function() {layerMenu.tryUpdateMenu("EnableDialogs");};
    this.dlg.dialogCb.helpTip = "Enable Layer Style Photoshop Dialogs";
    if (this.showPsDlgs == DialogModes.ALL)
       this.dlg.dialogCb.value = true;
    else
       this.dlg.dialogCb.value = false;
    //-------------------------
    // delete effects check box
    //-------------------------
    this.dlg.deleteCb = this.dlg.layer2Group.add("checkbox", undefined, "Delete Effects");
    this.dlg.deleteCb.preferredSize = [160,ctlHgt];
    this.dlg.deleteCb.onClick = function() {layerMenu.tryUpdateMenu("EnableDialogs");};
    this.dlg.deleteCb.helpTip = "Delete layer effects";
    if (this.styleDelete)
       this.dlg.deleteCb.value = true;
    else
       this.dlg.deleteCb.value = false;
    //----------------------
    // user actions and sets
    //----------------------
    listValues = new Array();
    this.actionSetInfo = getActionSetInfo();
    for (i=0; i<this.actionSetInfo.length; i++)
        listValues[listValues.length] = this.actionSetInfo[i].name;
    this.dlg.userActionSetTxt = this.dlg.layer3Group.add("statictext", undefined, "Action Set");
    this.dlg.userActionSetTxt.preferredSize = [60,ctlHgt];
    this.dlg.userActionSetLstBx = this.dlg.layer3Group.add("dropdownlist", undefined, listValues);
    this.dlg.userActionSetLstBx.helpTip = "Action set containing the user action";
    this.dlg.userActionSetLstBx.onChange = function() {layerMenu.tryUpdateMenu("UserActionSet");};
    this.dlg.userActionSetLstBx.preferredSize = [95,ctlHgt];
    this.dlg.userActionSetLstBx.items[this.userActionSetIdx].selected = true;
    this.userActionSet = this.dlg.userActionSetLstBx.items[this.userActionSetIdx].text;
    listValues = new Array("none");
    for (i=0; i<this.actionSetInfo[this.userActionSetIdx].children.length; i++)
        listValues[listValues.length] = this.actionSetInfo[this.userActionSetIdx].children[i].name;
    this.dlg.userActionTxt = this.dlg.layer3Group.add("statictext", undefined, "Action");
    this.dlg.userActionTxt.preferredSize = [40,ctlHgt];
    this.dlg.userActionLstBx = this.dlg.layer3Group.add("dropdownlist", undefined, listValues);
    this.dlg.userActionLstBx.helpTip = "Apply user action to selected layer(s)";
    this.dlg.userActionLstBx.onChange = function() {layerMenu.tryUpdateMenu("UserAction");};
    this.dlg.userActionLstBx.preferredSize = [115,ctlHgt];
    this.dlg.userActionLstBx.items[this.userActionIdx].selected = true;
    //-----------------------------
    // Add the stroke effects panel
    //-----------------------------
    this.dlg.strokePanel = this.dlg.add("panel", undefined, "Stroke Options");
    this.dlg.strokePanel.orientation = "column";
    this.dlg.strokePanel.alignChildren = "fill";
    this.dlg.strokePanel.spacing = ctlSpace;
    //-----------------------------
    // Add the stroke effect groups
    //-----------------------------
    this.dlg.stroke1Group = this.dlg.strokePanel.add("group");
    this.dlg.stroke1Group.orientation = "row";
    this.dlg.stroke1Group.alignChildren = "fill";
    this.dlg.stroke1Group.spacing = ctlSpace;
    this.dlg.stroke2Group = this.dlg.strokePanel.add("group");
    this.dlg.stroke2Group.orientation = "row";
    this.dlg.stroke2Group.alignChildren = "fill";
    this.dlg.stroke2Group.spacing = ctlSpace;
    //-----------------------------
    // stroke effects panel options
    //-----------------------------
    this.dlg.strokeEffectCb = this.dlg.stroke1Group.add("checkbox", undefined, "Enable Stroke");
    this.dlg.strokeEffectCb.preferredSize = [160,ctlHgt];
    this.dlg.strokeEffectCb.onClick = function() {layerMenu.tryUpdateMenu("EnableEffects");};
    this.dlg.strokeEffectCb.helpTip = "Enable Layer Stroke Effect";
    if (this.strokeEffect)
       this.dlg.strokeEffectCb.value = true;
    else
       this.dlg.strokeEffectCb.value = false;

    this.dlg.strokeColorBtn = this.dlg.stroke1Group.add("button", undefined, "Color");
    this.dlg.strokeColorBtn.onClick = function() {layerMenu.tryUpdateMenu("StrokeColor");};
    this.dlg.strokeColorBtn.helpTip = "Stroke Color Dialog";
    if (this.isIconValid) {                      // add the PNG image icon
        this.dlg.strokeIcon = this.dlg.stroke1Group.add("image", undefined, "Step1Icon");
        this.dlg.strokeIcon.preferredSize = [40,ctlHgt];
    }
    this.dlg.strokeSizeTxt = this.dlg.stroke2Group.add("statictext", undefined, "Stroke Size");
    this.dlg.strokeSizeTxt.preferredSize = [115,ctlHgt];
    this.dlg.strokeSizeValue = this.dlg.stroke2Group.add("edittext", undefined, this.strokeSize);
    this.dlg.strokeSizeValue.preferredSize = [40,ctlHgt];
    this.dlg.strokeSizeValue.onChange = function() {layerMenu.tryUpdateMenu("StrokeOpts");};
    this.dlg.strokeSizeValue.helpTip = "Stroke Size, 1-250 pixels";
    listValues = new Array("outside", "inside", "center");
    this.dlg.strokePositionTxtBx = this.dlg.stroke2Group.add("statictext", undefined, "Stroke Position");
    this.dlg.strokePositionTxtBx.preferredSize = [90,ctlHgt];
    this.dlg.strokePositionLstBx = this.dlg.stroke2Group.add("dropdownlist", undefined, listValues);
    this.dlg.strokePositionLstBx.helpTip = "Select a stroke position";
    this.dlg.strokePositionLstBx.onChange = function() {layerMenu.tryUpdateMenu("StrokeOpts");};
    switch(this.strokePosition) {
        case "InsF": this.dlg.strokePositionLstBx.items[1].selected = true; break;
        case "CtrF": this.dlg.strokePositionLstBx.items[2].selected = true; break;
        case "OutF":
        default:     this.dlg.strokePositionLstBx.items[0].selected = true; break;
    }
    if (this.strokeEffect) {
        this.dlg.strokeColorBtn.enabled = true;
        this.dlg.strokeSizeValue.enabled = true;
        this.dlg.strokePositionLstBx.enabled = true;
    } else {
        this.dlg.strokeColorBtn.enabled = false;
        this.dlg.strokeSizeValue.enabled = false;
        this.dlg.strokePositionLstBx.enabled = false;
    }
    //------------------------------------
    // Add the color overlay effects panel
    //------------------------------------
    this.dlg.overlayPanel = this.dlg.add("panel", undefined, "Color Overlay Options");
    this.dlg.overlayPanel.orientation = "column";
    this.dlg.overlayPanel.alignChildren = "fill";
    this.dlg.overlayPanel.spacing = ctlSpace;
    //------------------------------------
    // Add the color overlay effect groups
    //------------------------------------
    this.dlg.overlay1Group = this.dlg.overlayPanel.add("group");
    this.dlg.overlay1Group.orientation = "row";
    this.dlg.overlay1Group.alignChildren = "fill";
    this.dlg.overlay1Group.spacing = ctlSpace;
    this.dlg.overlay2Group = this.dlg.overlayPanel.add("group");
    this.dlg.overlay2Group.orientation = "row";
    this.dlg.overlay2Group.alignChildren = "fill";
    this.dlg.overlay2Group.spacing = ctlSpace;
    //----------------------------
    // color overlay panel options
    //----------------------------
    this.dlg.overlayEffectCb = this.dlg.overlay1Group.add("checkbox", undefined, "Enable Color Overlay");
    this.dlg.overlayEffectCb.preferredSize = [160,ctlHgt];
    this.dlg.overlayEffectCb.onClick = function() {layerMenu.tryUpdateMenu("EnableEffects");};
    this.dlg.overlayEffectCb.helpTip = "Enable Layer Color Overlay Effect";
    if (this.overlayEffect)
       this.dlg.overlayEffectCb.value = true;
    else
       this.dlg.overlayEffectCb.value = false;
    this.dlg.overlayColorBtn = this.dlg.overlay1Group.add("button", undefined, "Color");
    this.dlg.overlayColorBtn.onClick = function() {layerMenu.tryUpdateMenu("OverlayColor");};
    this.dlg.overlayColorBtn.helpTip = "Overlay Color Dialog\nTry [43,2,2] for Sepia tone";
    if (this.isIconValid) {                      // add the PNG image icon
        this.dlg.overlayIcon = this.dlg.overlay1Group.add("image", undefined, "Step1Icon");
        this.dlg.overlayIcon.preferredSize = [40,ctlHgt];
    }
    this.dlg.overlayOpacityTxt = this.dlg.overlay2Group.add("statictext", undefined, "Color Overlay Opacity");
    this.dlg.overlayOpacityTxt.preferredSize = [115,ctlHgt];
    this.dlg.overlayOpacityValue = this.dlg.overlay2Group.add("edittext", undefined, this.overlayOpacity);
    this.dlg.overlayOpacityValue.preferredSize = [40,ctlHgt];
    this.dlg.overlayOpacityValue.onChange = function() {layerMenu.tryUpdateMenu("OverlayOpts");};
    this.dlg.overlayOpacityValue.helpTip = "Color Overlay Opacity, 0-100%";
    this.dlg.overlayFillerTxt = this.dlg.overlay2Group.add("statictext", undefined, "");
    this.dlg.overlayFillerTxt.preferredSize = [155+ctlSpace,ctlHgt];
    if (this.overlayEffect) {
        this.dlg.overlayColorBtn.enabled = true;
        this.dlg.overlayOpacityValue.enabled = true;
    } else {
        this.dlg.overlayColorBtn.enabled = false;
        this.dlg.overlayOpacityValue.enabled = false;
    }
    //----------------------------------
    // Add the drop shadow effects panel
    //----------------------------------
    this.dlg.dropShadowPanel = this.dlg.add("panel", undefined, "Drop Shadow Options");
    this.dlg.dropShadowPanel.orientation = "column";
    this.dlg.dropShadowPanel.alignChildren = "fill";
    this.dlg.dropShadowPanel.spacing = ctlSpace;
    //----------------------------------
    // Add the drop shadow effect groups
    //----------------------------------
    this.dlg.shadow1Group = this.dlg.dropShadowPanel.add("group");
    this.dlg.shadow1Group.orientation = "row";
    this.dlg.shadow1Group.alignChildren = "fill";
    this.dlg.shadow1Group.spacing = ctlSpace;
    this.dlg.shadow2Group = this.dlg.dropShadowPanel.add("group");
    this.dlg.shadow2Group.orientation = "row";
    this.dlg.shadow2Group.alignChildren = "fill";
    this.dlg.shadow2Group.spacing = ctlSpace;
    this.dlg.shadow3Group = this.dlg.dropShadowPanel.add("group");
    this.dlg.shadow3Group.orientation = "row";
    this.dlg.shadow3Group.alignChildren = "fill";
    this.dlg.shadow3Group.spacing = ctlSpace;
    //--------------------------
    // drop shadow panel options
    //--------------------------
    this.dlg.shadowEffectCb = this.dlg.shadow1Group.add("checkbox", undefined, "Enable Drop Shadow");
    this.dlg.shadowEffectCb.preferredSize = [160,ctlHgt];
    this.dlg.shadowEffectCb.onClick = function() {layerMenu.tryUpdateMenu("EnableEffects");};
    this.dlg.shadowEffectCb.helpTip = "Enable Layer Drop Shadow Effect";
    if (this.dropShadowEffect)
       this.dlg.shadowEffectCb.value = true;
    else
       this.dlg.shadowEffectCb.value = false;
    this.dlg.shadowColorBtn = this.dlg.shadow1Group.add("button", undefined, "Color");
    this.dlg.shadowColorBtn.onClick = function() {layerMenu.tryUpdateMenu("DropShadowColor");};
    this.dlg.shadowColorBtn.helpTip = "Drop Shadow Color Dialog";
    if (this.isIconValid) {                      // add the PNG image icon
        this.dlg.shadowIcon = this.dlg.shadow1Group.add("image", undefined, "Step1Icon");
        this.dlg.shadowIcon.preferredSize = [40,ctlHgt];
    }
    this.dlg.shadowAngleTxt = this.dlg.shadow2Group.add("statictext", undefined, "Drop Shadow Angle");
    this.dlg.shadowAngleTxt.preferredSize = [115,ctlHgt];
    this.dlg.shadowAngleValue = this.dlg.shadow2Group.add("edittext", undefined, this.dropShadowAngle);
    this.dlg.shadowAngleValue.preferredSize = [40,ctlHgt];
    this.dlg.shadowAngleValue.onChange = function() {layerMenu.tryUpdateMenu("DropShadowOpts");};
    this.dlg.shadowAngleValue.helpTip = "Drop Shadow Angle, -180 - +180 °";
    this.dlg.shadowSizeTxt = this.dlg.shadow2Group.add("statictext", undefined, "Drop Shadow Size");
    this.dlg.shadowSizeTxt.preferredSize = [115,ctlHgt];
    this.dlg.shadowSizeValue = this.dlg.shadow2Group.add("edittext", undefined, this.dropShadowSize);
    this.dlg.shadowSizeValue.preferredSize = [40,ctlHgt];
    this.dlg.shadowSizeValue.onChange = function() {layerMenu.tryUpdateMenu("DropShadowOpts");};
    this.dlg.shadowSizeValue.helpTip = "Drop Shadow Size, 0-250 pixels";
    this.dlg.shadowDistanceTxt = this.dlg.shadow3Group.add("statictext", undefined, "Drop Shadow Distance");
    this.dlg.shadowDistanceTxt.preferredSize = [115,ctlHgt];
    this.dlg.shadowDistanceValue = this.dlg.shadow3Group.add("edittext", undefined, this.dropShadowDistance);
    this.dlg.shadowDistanceValue.preferredSize = [40,ctlHgt];
    this.dlg.shadowDistanceValue.onChange = function() {layerMenu.tryUpdateMenu("DropShadowOpts");};
    this.dlg.shadowDistanceValue.helpTip = "Drop Shadow Distance, 0-30,000 pixels";
    this.dlg.shadowSpreadTxt = this.dlg.shadow3Group.add("statictext", undefined, "Drop Shadow Spread");
    this.dlg.shadowSpreadTxt.preferredSize = [115,ctlHgt];
    this.dlg.shadowSpreadValue = this.dlg.shadow3Group.add("edittext", undefined, this.dropShadowSpread);
    this.dlg.shadowSpreadValue.preferredSize = [40,ctlHgt];
    this.dlg.shadowSpreadValue.onChange = function() {layerMenu.tryUpdateMenu("DropShadowOpts");};
    this.dlg.shadowSpreadValue.helpTip = "Drop Shadow Spread, 0-100 pixels";
    if (this.dropShadowEffect) {
        this.dlg.shadowColorBtn.enabled = true;
        this.dlg.shadowAngleValue.enabled = true;
        this.dlg.shadowSizeValue.enabled = true;
        this.dlg.shadowDistanceValue.enabled = true;
        this.dlg.shadowSpreadValue.enabled = true;
    } else {
        this.dlg.shadowColorBtn.enabled = false;
        this.dlg.shadowAngleValue.enabled = false;
        this.dlg.shadowSizeValue.enabled = false;
        this.dlg.shadowDistanceValue.enabled = false;
        this.dlg.shadowSpreadValue.enabled = false;
    }
    //---------------------------------------
    // Add the bevel and emboss effects panel
    //---------------------------------------
    this.dlg.embossPanel = this.dlg.add("panel", undefined, "Bevel and Emboss Options");
    this.dlg.embossPanel.orientation = "column";
    this.dlg.embossPanel.alignChildren = "fill";
    this.dlg.embossPanel.spacing = ctlSpace;
    //---------------------------------------
    // Add the bevel and emboss effect groups
    //---------------------------------------
    this.dlg.emboss1Group = this.dlg.embossPanel.add("group");
    this.dlg.emboss1Group.orientation = "row";
    this.dlg.emboss1Group.alignChildren = "fill";
    this.dlg.emboss1Group.spacing = ctlSpace;
    this.dlg.emboss2Group = this.dlg.embossPanel.add("group");
    this.dlg.emboss2Group.orientation = "row";
    this.dlg.emboss2Group.alignChildren = "fill";
    this.dlg.emboss2Group.spacing = ctlSpace;
    this.dlg.emboss3Group = this.dlg.embossPanel.add("group");
    this.dlg.emboss3Group.orientation = "row";
    this.dlg.emboss3Group.alignChildren = "fill";
    this.dlg.emboss3Group.spacing = ctlSpace;
    //-------------------------------
    // bevel and emboss panel options
    //-------------------------------
    this.dlg.embossEffectCb = this.dlg.emboss1Group.add("checkbox", undefined, "Enable Bevel and Emboss");
    this.dlg.embossEffectCb.preferredSize = [160,ctlHgt];
    this.dlg.embossEffectCb.onClick = function() {layerMenu.tryUpdateMenu("EnableEffects");};
    this.dlg.embossEffectCb.helpTip = "Enable Layer Bevel and Emboss Effect";
    if (this.embossEffect)
       this.dlg.embossEffectCb.value = true;
    else
       this.dlg.embossEffectCb.value = false;
    this.dlg.embossPanel.orientation = "column";
    this.dlg.embossDepthTxt = this.dlg.emboss1Group.add("statictext", undefined, "Emboss Depth");
    this.dlg.embossDepthTxt.preferredSize = [115,ctlHgt];
    this.dlg.embossDepthValue = this.dlg.emboss1Group.add("edittext", undefined, this.embossDepth);
    this.dlg.embossDepthValue.preferredSize = [40,ctlHgt];
    this.dlg.embossDepthValue.onChange = function() {layerMenu.tryUpdateMenu("EmbossOpts");};
    this.dlg.embossDepthValue.helpTip = "Emboss Depth, 0 - 1000%";
    this.dlg.embossSizeTxt = this.dlg.emboss2Group.add("statictext", undefined, "Emboss Size");
    this.dlg.embossSizeTxt.preferredSize = [115,ctlHgt];
    this.dlg.embossSizeValue = this.dlg.emboss2Group.add("edittext", undefined, this.embossSize);
    this.dlg.embossSizeValue.preferredSize = [40,ctlHgt];
    this.dlg.embossSizeValue.onChange = function() {layerMenu.tryUpdateMenu("EmbossOpts");};
    this.dlg.embossSizeValue.helpTip = "Emboss Size, 0 - 250 pixels";
    this.dlg.embossSoftenTxt = this.dlg.emboss2Group.add("statictext", undefined, "Emboss Soften");
    this.dlg.embossSoftenTxt.preferredSize = [115,ctlHgt];
    this.dlg.embossSoftenValue = this.dlg.emboss2Group.add("edittext", undefined, this.embossSoften);
    this.dlg.embossSoftenValue.preferredSize = [40,ctlHgt];
    this.dlg.embossSoftenValue.onChange = function() {layerMenu.tryUpdateMenu("EmbossOpts");};
    this.dlg.embossSoftenValue.helpTip = "Emboss Soften, 0 - 16 pixels";
    this.dlg.shadingAngleTxt = this.dlg.emboss3Group.add("statictext", undefined, "Shading Angle");
    this.dlg.shadingAngleTxt.preferredSize = [115,ctlHgt];
    this.dlg.shadingAngleValue = this.dlg.emboss3Group.add("edittext", undefined, this.shadingAngle);
    this.dlg.shadingAngleValue.preferredSize = [40,ctlHgt];
    this.dlg.shadingAngleValue.onChange = function() {layerMenu.tryUpdateMenu("EmbossOpts");};
    this.dlg.shadingAngleValue.helpTip = "Shading Angle, -180 to +180 °";
    this.dlg.shadingAltitudeTxt = this.dlg.emboss3Group.add("statictext", undefined, "Shading Altitude");
    this.dlg.shadingAltitudeTxt.preferredSize = [115,ctlHgt];
    this.dlg.shadingAltitudeValue = this.dlg.emboss3Group.add("edittext", undefined, this.shadingAltitude);
    this.dlg.shadingAltitudeValue.preferredSize = [40,ctlHgt];
    this.dlg.shadingAltitudeValue.onChange = function() {layerMenu.tryUpdateMenu("EmbossOpts");};
    this.dlg.shadingAltitudeValue.helpTip = "Shading Altitude, 0 to 90 °";
    if (this.embossEffect) {
        this.dlg.embossDepthValue.enabled = true;
        this.dlg.embossSizeValue.enabled = true;
        this.dlg.embossSoftenValue.enabled = true;
        this.dlg.shadingAngleValue.enabled = true;
        this.dlg.shadingAltitudeValue.enabled = true;
    } else {
        this.dlg.embossDepthValue.enabled = false;
        this.dlg.embossSizeValue.enabled = false;
        this.dlg.embossSoftenValue.enabled = false;
        this.dlg.shadingAngleValue.enabled = false;
        this.dlg.shadingAltitudeValue.enabled = false;
    }
    //---------------------------
    // Add the satin effects panel
    //---------------------------
    this.dlg.satinPanel = this.dlg.add("panel", undefined, "Satin Options");
    this.dlg.satinPanel.orientation = "column";
    this.dlg.satinPanel.alignChildren = "fill";
    this.dlg.satinPanel.spacing = ctlSpace;
    //---------------------------
    // Add the satin effect groups
    //---------------------------
    this.dlg.satin1Group = this.dlg.satinPanel.add("group");
    this.dlg.satin1Group.orientation = "row";
    this.dlg.satin1Group.alignChildren = "fill";
    this.dlg.satin1Group.spacing = ctlSpace;
    this.dlg.satin2Group = this.dlg.satinPanel.add("group");
    this.dlg.satin2Group.orientation = "row";
    this.dlg.satin2Group.alignChildren = "fill";
    this.dlg.satin2Group.spacing = ctlSpace;
    this.dlg.satin3Group = this.dlg.satinPanel.add("group");
    this.dlg.satin3Group.orientation = "row";
    this.dlg.satin3Group.alignChildren = "fill";
    this.dlg.satin3Group.spacing = ctlSpace;
    //--------------------
    // satin panel options
    //--------------------
    this.dlg.satinEffectCb = this.dlg.satin1Group.add("checkbox", undefined, "Enable Satin Effect");
    this.dlg.satinEffectCb.preferredSize = [160,ctlHgt];
    this.dlg.satinEffectCb.onClick = function() {layerMenu.tryUpdateMenu("EnableEffects");};
    this.dlg.satinEffectCb.helpTip = "Enable Satin Effect";
    if (this.satinEffect)
       this.dlg.satinEffectCb.value = true;
    else
       this.dlg.satinEffectCb.value = false;
    this.dlg.satinPanel.orientation = "column";
    this.dlg.satinColorBtn = this.dlg.satin1Group.add("button", undefined, "Color");
    this.dlg.satinColorBtn.onClick = function() {layerMenu.tryUpdateMenu("SatinColor");};
    this.dlg.satinColorBtn.helpTip = "Satin Effect Color Dialog";
    if (this.isIconValid) {                      // add the PNG image icon
        this.dlg.satinIcon = this.dlg.satin1Group.add("image", undefined, "Step1Icon");
        this.dlg.satinIcon.preferredSize = [40,ctlHgt];
    }
    this.dlg.satinOpacityTxt = this.dlg.satin2Group.add("statictext", undefined, "Satin Opacity");
    this.dlg.satinOpacityTxt.preferredSize = [115,ctlHgt];
    this.dlg.satinOpacityValue = this.dlg.satin2Group.add("edittext", undefined, this.satinOpacity);
    this.dlg.satinOpacityValue.preferredSize = [40,ctlHgt];
    this.dlg.satinOpacityValue.onChange = function() {layerMenu.tryUpdateMenu("SatinOpts");};
    this.dlg.satinOpacityValue.helpTip = "Satin Opacity, 0-100%";
    this.dlg.satinDistanceTxt = this.dlg.satin2Group.add("statictext", undefined, "Satin Distance");
    this.dlg.satinDistanceTxt.preferredSize = [115,ctlHgt];
    this.dlg.satinDistanceValue = this.dlg.satin2Group.add("edittext", undefined, this.satinDistance);
    this.dlg.satinDistanceValue.preferredSize = [40,ctlHgt];
    this.dlg.satinDistanceValue.onChange = function() {layerMenu.tryUpdateMenu("SatinOpts");};
    this.dlg.satinDistanceValue.helpTip = "Satin Distance, 0-250 pixels";
    this.dlg.satinAngleTxt = this.dlg.satin3Group.add("statictext", undefined, "Satin Angle");
    this.dlg.satinAngleTxt.preferredSize = [115,ctlHgt];
    this.dlg.satinAngleValue = this.dlg.satin3Group.add("edittext", undefined, this.satinAngle);
    this.dlg.satinAngleValue.preferredSize = [40,ctlHgt];
    this.dlg.satinAngleValue.onChange = function() {layerMenu.tryUpdateMenu("SatinOpts");};
    this.dlg.satinAngleValue.helpTip = "Satin Angle, -180 - +180 °";
    this.dlg.satinBlurTxt = this.dlg.satin3Group.add("statictext", undefined, "Satin Blur");
    this.dlg.satinBlurTxt.preferredSize = [115,ctlHgt];
    this.dlg.satinBlurValue = this.dlg.satin3Group.add("edittext", undefined, this.satinBlur);
    this.dlg.satinBlurValue.preferredSize = [40,ctlHgt];
    this.dlg.satinBlurValue.onChange = function() {layerMenu.tryUpdateMenu("SatinOpts");};
    this.dlg.satinBlurValue.helpTip = "Satin Blur, 0-250 pixels";
    if (this.satinEffect) {
        this.dlg.satinColorBtn.enabled = true;
        this.dlg.satinOpacityValue.enabled = true;
        this.dlg.satinDistanceValue.enabled = true;
        this.dlg.satinAngleValue.enabled = true;
        this.dlg.satinBlurValue.enabled = true;
    } else {
        this.dlg.satinColorBtn.enabled = false;
        this.dlg.satinOpacityValue.enabled = false;
        this.dlg.satinDistanceValue.enabled = false;
        this.dlg.satinAngleValue.enabled = false;
        this.dlg.satinBlurValue.enabled = false;
    }
    //---------------------------
    // Add the glow effects panel
    //---------------------------
    this.dlg.glowPanel = this.dlg.add("panel", undefined, "Glow Options");
    this.dlg.glowPanel.orientation = "column";
    this.dlg.glowPanel.alignChildren = "fill";
    this.dlg.glowPanel.spacing = ctlSpace;
    //---------------------------
    // Add the glow effect groups
    //---------------------------
    this.dlg.glow1Group = this.dlg.glowPanel.add("group");
    this.dlg.glow1Group.orientation = "row";
    this.dlg.glow1Group.alignChildren = "fill";
    this.dlg.glow1Group.spacing = ctlSpace;
    this.dlg.glow2Group = this.dlg.glowPanel.add("group");
    this.dlg.glow2Group.orientation = "row";
    this.dlg.glow2Group.alignChildren = "fill";
    this.dlg.glow2Group.spacing = ctlSpace;
    this.dlg.glow3Group = this.dlg.glowPanel.add("group");
    this.dlg.glow3Group.orientation = "row";
    this.dlg.glow3Group.alignChildren = "fill";
    this.dlg.glow3Group.spacing = ctlSpace;
    //-------------------
    // glow panel options
    //-------------------
    this.dlg.glowEffectCb = this.dlg.glow1Group.add("checkbox", undefined, "Enable Inner or Outer Glow");
    this.dlg.glowEffectCb.preferredSize = [160,ctlHgt];
    this.dlg.glowEffectCb.onClick = function() {layerMenu.tryUpdateMenu("EnableEffects");};
    this.dlg.glowEffectCb.helpTip = "Enable Inner or Outer Glow Effect";
    if (this.glowEffect)
       this.dlg.glowEffectCb.value = true;
    else
       this.dlg.glowEffectCb.value = false;
    this.dlg.glowPanel.orientation = "column";
    this.dlg.glowColorBtn = this.dlg.glow1Group.add("button", undefined, "Color");
    this.dlg.glowColorBtn.onClick = function() {layerMenu.tryUpdateMenu("GlowColor");};
    this.dlg.glowColorBtn.helpTip = "Glow Effect Color Dialog";
    if (this.isIconValid) {                       // add the PNG image icon
        this.dlg.glowIcon = this.dlg.glow1Group.add("image", undefined, "Step1Icon");
        this.dlg.glowIcon.preferredSize = [40,ctlHgt];
    }
    this.dlg.glowInnerRb = this.dlg.glow2Group.add("radiobutton", undefined, "In");
    this.dlg.glowInnerRb.onClick = function() {layerMenu.tryUpdateMenu("GlowOpts");};
    this.dlg.glowInnerRb.helpTip = "Inner Glow";
    this.dlg.glowInnerRb.preferredSize = [40,ctlHgt];
    this.dlg.glowOuterRb = this.dlg.glow2Group.add("radiobutton", undefined, "Out");
    this.dlg.glowOuterRb.onClick = function() {layerMenu.tryUpdateMenu("GlowOpts");};
    this.dlg.glowOuterRb.helpTip = "Outer Glow";
    this.dlg.glowOuterRb.preferredSize = [40,ctlHgt];
    if (this.glowInner)
        this.dlg.glowInnerRb.value = true;
    else
        this.dlg.glowOuterRb.value = true;
    this.dlg.glowFillerTxt = this.dlg.glow2Group.add("statictext", undefined, "");
    this.dlg.glowFillerTxt.preferredSize = [50,ctlHgt];
    listValues = new Array("linear", "ring", "double ring");
    this.dlg.glowContourTxtBx = this.dlg.glow2Group.add("statictext", undefined, "Contour Shape");
    this.dlg.glowContourTxtBx.preferredSize = [80,ctlHgt];
    this.dlg.glowContourLstBx = this.dlg.glow2Group.add("dropdownlist", undefined, listValues);
    this.dlg.glowContourLstBx.helpTip = "Select a glow shape contour";
    this.dlg.glowContourLstBx.onChange = function() {layerMenu.tryUpdateMenu("GlowOpts");};
    switch(this.glowContourName) {
        case "Ring":          this.dlg.glowContourLstBx.items[1].selected = true; break;
        case "Ring - Double": this.dlg.glowContourLstBx.items[2].selected = true; break;
        case "Linear":
        default:              this.dlg.glowContourLstBx.items[0].selected = true; break;
    }
    this.dlg.glowOpacityTxt = this.dlg.glow3Group.add("statictext", undefined, "Glow Opacity");
    this.dlg.glowOpacityTxt.preferredSize = [115,ctlHgt];
    this.dlg.glowOpacityValue = this.dlg.glow3Group.add("edittext", undefined, this.glowOpacity);
    this.dlg.glowOpacityValue.preferredSize = [40,ctlHgt];
    this.dlg.glowOpacityValue.onChange = function() {layerMenu.tryUpdateMenu("GlowOpts");};
    this.dlg.glowOpacityValue.helpTip = "Glow Opacity, 0-100%";
    this.dlg.glowSizeTxt = this.dlg.glow3Group.add("statictext", undefined, "Glow Size");
    this.dlg.glowSizeTxt.preferredSize = [115,ctlHgt];
    this.dlg.glowSizeValue = this.dlg.glow3Group.add("edittext", undefined, this.glowSize);
    this.dlg.glowSizeValue.preferredSize = [40,ctlHgt];
    this.dlg.glowSizeValue.onChange = function() {layerMenu.tryUpdateMenu("GlowOpts");};
    this.dlg.glowSizeValue.helpTip = "Glow Size, 0-250 pixels";
    if (this.glowEffect) {
        this.dlg.glowColorBtn.enabled = true;
        this.dlg.glowInnerRb.enabled = true;
        this.dlg.glowOuterRb.enabled = true;
        this.dlg.glowContourLstBx.enabled = true;
        this.dlg.glowOpacityValue.enabled = true;
        this.dlg.glowSizeValue.enabled = true;
    } else {
        this.dlg.glowColorBtn.enabled = false;
        this.dlg.glowInnerRb.enabled = false;
        this.dlg.glowOuterRb.enabled = false;
        this.dlg.glowContourLstBx.enabled = false;
        this.dlg.glowOpacityValue.enabled = false;
        this.dlg.glowSizeValue.enabled = false;
    }
    //------------------------------------------
    // setup window position and show() callback
    //------------------------------------------
    if (this.winFrameLocation == null)
        this.dlg.center();                                // initially at center of screen
    else
        this.dlg.frameLocation = this.winFrameLocation;   // user location
    this.dlg.onMove = function() {layerMenu.tryUpdateMenu("Move");};
    this.dlg.onShow = function() {layerMenu.tryUpdateMenu("Show");};
    return(this.dlg);
}

// -------------------------------------------------------
// LayerMenu.tryUpdateMenu()
// -------------------------------------------------------
LayerMenu.prototype["tryUpdateMenu"] = function(caller) {
    var ex;

    try {
        if (this.menuActive || caller == "Move" || caller == "Show")
            this.updateMenu(caller);
    } catch(ex) {
        alert(scriptName + " LayerMenu.updateMenu(" + caller +
                           ") exception caught? line[" + ex.line + "]\n"  + ex);
        if (this.menuActive)
            this.dlg.close(0); // there is no point in re-throwing the exception
    }
    return;
}

// -------------------------------------------------------
// LayerMenu.updateMenu()
// -------------------------------------------------------
LayerMenu.prototype["updateMenu"] = function(caller) {
    var selectItem;
    var listValues;
    var testNum, testColor;
    var i;
    var rc = 0;

    switch(caller) {
        case "Move":
            this.winFrameLocation = this.dlg.frameLocation;
            if (this.menuActive)
                waitForRedraw();
            break;
        case "LayerSelect":
            selectItem = Math.round(this.dlg.layerSelectionLstBx.selection);
            if (selectItem == 0) {
                this.applyAllLayers = true;
            } else {
                this.applyAllLayers = false;
                this.layerIndex = selectItem - 1;
            }
            break;
        case "StyleScale":
            testNum = Number(this.dlg.styleScaleValue.text);
            if (isNaN(testNum) || testNum < 1 || testNum > 1000) {
                alert(scriptName + " Scale Layer Styles%=" + testNum + " must be a number: 1 to 1,000");
                this.dlg.styleScaleValue.text = this.styleScalePct;
            } else
                this.styleScalePct = testNum;
            break;
        case "EnableDialogs":
            if (this.dlg.dialogCb.value)
                this.showPsDlgs = DialogModes.ALL;
            else
                this.showPsDlgs = DialogModes.NO;
            if (this.dlg.deleteCb.value )
                this.styleDelete = true;
            else
                this.styleDelete = false;
            break;
        case "UserActionSet":
            selectItem = Math.round(this.dlg.userActionSetLstBx.selection);
            this.userActionSetIdx = selectItem;
            this.userActionSet = this.dlg.userActionSetLstBx.items[selectItem].text;
            this.dlg.userActionLstBx.removeAll();
            listValues = new Array("none");
            for (i=0; i<this.actionSetInfo[this.userActionSetIdx].children.length; i++)
                listValues[listValues.length] = this.actionSetInfo[this.userActionSetIdx].children[i].name;
            for (i=0; i<listValues.length; i++)
                this.dlg.userActionLstBx.add("item", listValues[i]);
            this.userActionIdx = 0;
            this.userAction = this.dlg.userActionLstBx.items[this.userActionIdx].text;
            this.dlg.userActionLstBx.items[this.userActionIdx].selected = true;
            break;
        case "UserAction":
            selectItem = Math.round(this.dlg.userActionLstBx.selection);
            this.userActionIdx = selectItem;
            this.userAction = this.dlg.userActionLstBx.items[selectItem].text;
            break;
        case "EnableEffects":
            if (this.dlg.strokeEffectCb.value) {
                this.strokeEffect = true;
                this.dlg.strokeColorBtn.enabled = true;
                this.dlg.strokeSizeValue.enabled = true;
                this.dlg.strokePositionLstBx.enabled = true;
            } else {
                this.strokeEffect = false;
                this.dlg.strokeColorBtn.enabled = false;
                this.dlg.strokeSizeValue.enabled = false;
                this.dlg.strokePositionLstBx.enabled = false;
            }
            if (this.dlg.overlayEffectCb.value) {
                this.overlayEffect = true;
                this.dlg.overlayColorBtn.enabled = true;
                this.dlg.overlayOpacityValue.enabled = true;
            } else {
                this.overlayEffect = false;
                this.dlg.overlayColorBtn.enabled = false;
                this.dlg.overlayOpacityValue.enabled = false;
            }
            if (this.dlg.shadowEffectCb.value) {
                this.dropShadowEffect = true;
                this.dlg.shadowColorBtn.enabled = true;
                this.dlg.shadowAngleValue.enabled = true;
                this.dlg.shadowSizeValue.enabled = true;
                this.dlg.shadowDistanceValue.enabled = true;
                this.dlg.shadowSpreadValue.enabled = true;
            } else {
                this.dropShadowEffect = false;
                this.dlg.shadowColorBtn.enabled = false;
                this.dlg.shadowAngleValue.enabled = false;
                this.dlg.shadowSizeValue.enabled = false;
                this.dlg.shadowDistanceValue.enabled = false;
                this.dlg.shadowSpreadValue.enabled = false;
            }
            if (this.dlg.embossEffectCb.value) {
                this.embossEffect = true;
                this.dlg.embossDepthValue.enabled = true;
                this.dlg.embossSizeValue.enabled = true;
                this.dlg.embossSoftenValue.enabled = true;
                this.dlg.shadingAngleValue.enabled = true;
                this.dlg.shadingAltitudeValue.enabled = true;
            } else {
                this.embossEffect = false;
                this.dlg.embossDepthValue.enabled = false;
                this.dlg.embossSizeValue.enabled = false;
                this.dlg.embossSoftenValue.enabled = false;
                this.dlg.shadingAngleValue.enabled = false;
                this.dlg.shadingAltitudeValue.enabled = false;
            }
            if (this.dlg.satinEffectCb.value) {
                this.satinEffect = true;
                this.dlg.satinColorBtn.enabled = true;
                this.dlg.satinOpacityValue.enabled = true;
                this.dlg.satinDistanceValue.enabled = true;
                this.dlg.satinAngleValue.enabled = true;
                this.dlg.satinBlurValue.enabled = true;
            } else {
                this.satinEffect = false;
                this.dlg.satinColorBtn.enabled = false;
                this.dlg.satinOpacityValue.enabled = false;
                this.dlg.satinDistanceValue.enabled = false;
                this.dlg.satinAngleValue.enabled = false;
                this.dlg.satinBlurValue.enabled = false;
            }
            if (this.dlg.glowEffectCb.value) {
                this.glowEffect = true;
                this.dlg.glowColorBtn.enabled = true;
                this.dlg.glowInnerRb.enabled = true;
                this.dlg.glowOuterRb.enabled = true;
                this.dlg.glowContourLstBx.enabled = true;
                this.dlg.glowOpacityValue.enabled = true;
                this.dlg.glowSizeValue.enabled = true;
            } else {
                this.glowEffect = false;
                this.dlg.glowColorBtn.enabled = false;
                this.dlg.glowInnerRb.enabled = false;
                this.dlg.glowOuterRb.enabled = false;
                this.dlg.glowContourLstBx.enabled = false;
                this.dlg.glowOpacityValue.enabled = false;
                this.dlg.glowSizeValue.enabled = false;
            }
            break;
        case "StrokeColor":
            testColor = colorMenu.showDialog(this.strokeColor, this.winFrameLocation);
            if (testColor != null) {
                this.strokeColor = testColor;
                if (this.isIconValid) {                       // update the PNG image icon
                    rc = this.changeIcon(this.strokeColor);   /// this is failing ???
                    this.dlg.active = true;                   // lost focus due to icon update?
                    this.dlg.strokeIcon.icon = "Step1Icon";
                    this.dlg.strokeIcon.icon = iconURL;
                    if (!this.keepIcon && docRefIcon != null) {
                        docRefIcon.close(SaveOptions.DONOTSAVECHANGES);
                        docRefIcon = null;
                    }
                }
            }
            break;
        case "OverlayColor":
            testColor = colorMenu.showDialog(this.overlayColor, this.winFrameLocation);
            if (testColor != null)
                this.overlayColor = testColor;
            if (this.isIconValid) {                       // update the PNG image icon
                this.changeIcon(this.overlayColor);
                this.dlg.overlayIcon.icon = "Step1Icon";
                this.dlg.overlayIcon.icon = iconURL;
                if (!this.keepIcon && docRefIcon != null) {
                    docRefIcon.close(SaveOptions.DONOTSAVECHANGES);
                    docRefIcon = null;
                }
                this.dlg.active = true;                   // lost focus due to icon update?
            }
            break;
        case "DropShadowColor":
            testColor = colorMenu.showDialog(this.dropShadowColor, this.winFrameLocation);
            if (testColor != null)
                this.dropShadowColor = testColor;
            if (this.isIconValid) {                       // update the PNG image icon
                this.changeIcon(this.dropShadowColor);
                this.dlg.shadowIcon.icon = "Step1Icon";
                this.dlg.shadowIcon.icon = iconURL;
                if (!this.keepIcon && docRefIcon != null) {
                    docRefIcon.close(SaveOptions.DONOTSAVECHANGES);
                    docRefIcon = null;
                }
                this.dlg.active = true;                   // lost focus due to icon update?
            }
            break;
        case "SatinColor":
            testColor = colorMenu.showDialog(this.satinColor, this.winFrameLocation);
            if (testColor != null)
                this.satinColor = testColor;
            if (1 == 0 && this.isIconValid) {                       // update the PNG image icon
                this.changeIcon(this.satinColor);
                this.dlg.satinIcon.icon = "Step1Icon";
                this.dlg.satinIcon.icon = iconURL;
                if (!this.keepIcon && docRefIcon != null) {
                    docRefIcon.close(SaveOptions.DONOTSAVECHANGES);
                    docRefIcon = null;
                }
                this.dlg.active = true;                   // lost focus due to icon update?
            }
            break;
        case "GlowColor":
            testColor = colorMenu.showDialog(this.glowColor, this.winFrameLocation);
            if (testColor != null)
                this.glowColor = testColor;
            if (this.isIconValid) {                       // update the PNG image icon
                this.changeIcon(this.glowColor);
                this.dlg.glowIcon.icon = "Step1Icon";
                this.dlg.glowIcon.icon = iconURL;
                if (!this.keepIcon && docRefIcon != null) {
                    docRefIcon.close(SaveOptions.DONOTSAVECHANGES);
                    docRefIcon = null;
                }
                this.dlg.active = true;                   // lost focus due to icon update?
            }
            break;
        case "StrokeOpts":
            testNum = Number(this.dlg.strokeSizeValue.text);
            if (isNaN(testNum) || testNum < 1 || testNum > 250) {
                alert(scriptName + " Stroke Size=" + testNum + ", must be a number, 1-250 pixels");
                this.dlg.strokeSizeValue.text = this.strokeSize;
            } else
                this.strokeSize = testNum;
            if (this.dlg.strokePositionLstBx.items[1].selected)
                this.strokePosition = "InsF";
            else if (this.dlg.strokePositionLstBx.items[2].selected)
                this.strokePosition = "CtrF";
            else
                this.strokePosition = "OutF";
            break;
        case "OverlayOpts":
            testNum = Number(this.dlg.overlayOpacityValue.text);
            if (isNaN(testNum) || testNum < 0 || testNum > 100) {
                alert(scriptName + " Color Overlay Opacity=" + testNum + ", must be a number, 0-100%");
                this.dlg.overlayOpacityValue.text = this.overlayOpacity;
            } else
                this.overlayOpacity = testNum;
            break;
        case "DropShadowColor":
            testColor = colorMenu.showDialog(this.dropShadowColor, this.winFrameLocation);
            if (testColor != null)
                this.dropShadowColor = testColor;
            break;
        case "SatinColor":
            testColor = colorMenu.showDialog(this.satinColor, this.winFrameLocation);
            if (testColor != null)
                this.satinColor = testColor;
            break;
        case "GlowColor":
            testColor = colorMenu.showDialog(this.glowColor, this.winFrameLocation);
            if (testColor != null)
                this.glowColor = testColor;
            break;
        case "DropShadowOpts":
            testNum = Number(this.dlg.shadowAngleValue.text);
            if (isNaN(testNum) || testNum < -180 || testNum > +180) {
                alert(scriptName + " Drop Shadow Angle=" + testNum + ", must be a number, -180 to +180 °");
                this.dlg.shadowAngleValue.text = this.dropShadowAngle;
            } else
                this.dropShadowAngle = testNum;
            testNum = Number(this.dlg.shadowSizeValue.text);
            if (isNaN(testNum) || testNum < 0 || testNum > 250) {
                alert(scriptName + " Drop Shadow Size=" + testNum + ", must be a number, 0 - 250 pixels");
                this.dlg.shadowSizeValue.text = this.dropShadowSize;
            } else
                this.dropShadowSize = testNum;
            testNum = Number(this.dlg.shadowDistanceValue.text);
            if (isNaN(testNum) || testNum < 0 || testNum > 30000) {
                alert(scriptName + " Drop Shadow Distance=" + testNum + ", must be a number, 0 - 30,000 pixels");
                this.dlg.shadowDistanceValue.text = this.dropShadowDistance;
            } else
                this.dropShadowDistance = testNum;
            testNum = Number(this.dlg.shadowSpreadValue.text);
            if (isNaN(testNum) || testNum < 0 || testNum > 100) {
                alert(scriptName + " Drop Shadow Spread=" + testNum + ", must be a number, 0 - 100 pixels");
                this.dlg.shadowSpreadValue.text = this.dropShadowSpread;
            } else
                this.dropShadowSpread = testNum;
            break;
        case "EmbossOpts":
            testNum = Number(this.dlg.embossDepthValue.text);
            if (isNaN(testNum) || testNum < 0 || testNum > 1000) {
                alert(scriptName + " Emboss Depth=" + testNum + ", must be a number, 0 - 1000 percent");
                this.dlg.embossDepthValue.text = this.embossDepth;
            } else
                this.embossDepth = testNum;
            testNum = Number(this.dlg.embossSizeValue.text);
            if (isNaN(testNum) || testNum < 0 || testNum > 250) {
                alert(scriptName + " Emboss Size=" + testNum + ", must be a number, 0 - 250 pixels");
                this.dlg.embossSizeValue.text = this.embossSize;
            } else
                this.embossSize = testNum;
            testNum = Number(this.dlg.embossSoftenValue.text);
            if (isNaN(testNum) || testNum < 0 || testNum > 16) {
                alert(scriptName + " Emboss Soften=" + testNum + ", must be a number, 0 - 16 pixels");
                this.dlg.embossSoftenValue.text = this.embossSoften;
            } else
                this.embossSoften = testNum;
            testNum = Number(this.dlg.shadingAngleValue.text);
            if (isNaN(testNum) || testNum < -180 || testNum > +180) {
                alert(scriptName + " Shading Angle=" + testNum + ", must be a number, -180 to +180 °");
                this.dlg.shadingAngleValue.text = this.shadingAngle;
            } else
                this.shadingAngle = testNum;
            testNum = Number(this.dlg.shadingAltitudeValue.text);
            if (isNaN(testNum) || testNum < 0 || testNum > 90) {
                alert(scriptName + " Shading Altitude=" + testNum + ", must be a number, 0 to 90 °");
                this.dlg.shadingAltitudeValue.text = this.shadingAltitude;
            } else
                this.shadingAltitude = testNum;
            break;
        case "SatinOpts":
            testNum = Number(this.dlg.overlayOpacityValue.text);
            if (isNaN(testNum) || testNum < 0 || testNum > 100) {
                alert(scriptName + " Color Overlay Opacity=" + testNum + ", must be a number, 0-100%");
                this.dlg.overlayOpacityValue.text = this.overlayOpacity;
            } else
                this.overlayOpacity = testNum;
            testNum = Number(this.dlg.satinDistanceValue.text);
            if (isNaN(testNum) || testNum < 1 || testNum > 250) {
                alert(scriptName + " Satin Distance=" + testNum + ", must be a number, 1-250 pixels");
                this.dlg.satinDistanceValue.text = this.satinDistance;
            } else
                this.satinDistance = testNum;
            testNum = Number(this.dlg.satinAngleValue.text);
            if (isNaN(testNum) || testNum < -180 || testNum > +180) {
                alert(scriptName + " Satin Angle=" + testNum + ", must be a number, -180 to +180 °");
                this.dlg.satinAngleValue.text = this.satinAngle;
            } else
                this.satinAngle = testNum;
            testNum = Number(this.dlg.satinBlurValue.text);
            if (isNaN(testNum) || testNum < 1 || testNum > 250) {
                alert(scriptName + " Glow Size=" + testNum + ", must be a number, 1-250 pixels");
                this.dlg.satinBlurValue.text = this.satinBlur;
            } else
                this.satinBlur = testNum;
            break;
        case "GlowOpts":
            if (this.dlg.glowInnerRb.value)
                this.glowInner = true;
            else
                this.glowInner = false;
            testNum = Number(this.dlg.glowOpacityValue.text);
            if (isNaN(testNum) || testNum < 0 || testNum > 100) {
                alert(scriptName + " Glow Opacity=" + testNum + ", must be a number, 0-100%");
                this.dlg.glowOpacityValue.text = this.glowOpacity;
            } else
                this.glowOpacity = testNum;
            testNum = Number(this.dlg.glowSizeValue.text);
            if (isNaN(testNum) || testNum < 1 || testNum > 250) {
                alert(scriptName + " Glow Size=" + testNum + ", must be a number, 1-250 pixels");
                this.dlg.glowSizeValue.text = this.glowSize;
            } else
                this.glowSize = testNum;
            if (this.dlg.glowContourLstBx.items[1].selected)
                this.glowContourName = "Ring";
            else if (this.dlg.glowContourLstBx.items[2].selected)
                this.glowContourName = "Ring - Double";
            else
                this.glowContourName = "Linear";
            break;
        case "Show":
            //----------------------------------------
            // if the dialog build is finished (show)
            // we can update the color icon images
            //----------------------------------------
            if (this.isIconValid) {          // update the PNG image icon colors
                this.changeIcon(this.strokeColor);
                this.dlg.strokeIcon.icon = iconURL;
                this.changeIcon(this.overlayColor);
                this.dlg.overlayIcon.icon = iconURL;
                this.changeIcon(this.dropShadowColor);
                this.dlg.shadowIcon.icon = iconURL;
                this.changeIcon(this.satinColor);
                this.dlg.satinIcon.icon = iconURL;
                this.changeIcon(this.glowColor);
                this.dlg.glowIcon.icon = iconURL;
                if (!this.keepIcon && docRefIcon != null) {
                    docRefIcon.close(SaveOptions.DONOTSAVECHANGES);
                    docRefIcon = null;
                }
                this.dlg.active = true;      // lost focus due to icon update?
            }
            this.menuActive = true;          // menu is now initialized
            break;
        default:
            alert("LayerMenu.updateMenu() Invalid caller=" + caller);
            break;
    }
    return;
}

// -------------------------------------------------------
// LayerMenu.changeIcon()
// -------------------------------------------------------
LayerMenu.prototype["changeIcon"] = function(color) {
    var ex;
    var rc;

    try {
        rc = updatePNGicon(color);
    } catch(ex) {
        alert("LayerMenu.changeIcon() exception caught? line[" + ex.line + "] "  + ex);
        this.dlg.close(0); // there is no point in re-throwing the exception
    }
    return(rc);
}

// -------------------------------------------------------
// LayerMenu.showDialog()
// display the UI dialog window
// -------------------------------------------------------
LayerMenu.prototype["showDialog"] = function() {
    var rc;

    this.createDialog();          // create the window
    rc = this.dlg.show();         // show it
    if (rc == 1)                  // user changes accepted
        this.rePop();             // re-populate global variables
    return(rc);
}

// =======================================================
// ColorMenu Dialog Routines
// Rags Gardner from a sample by Larry B. Ligon
// =======================================================

// -------------------------------------------------------
// ColorMenu constructor
// -------------------------------------------------------
ColorMenu = function(useIcon) {
    this.winFrameLocation = null;            // the window location
    this.isIconValid = useIcon;              // shuld we use the PNG icon
    this.keepIcon = persistentIcon;          // should we leave it open:
    this.menuActive = false;                 // initialization switch
    this.cdlg = null;                        // the dialog menu window
    return;
}

// -------------------------------------------------------
// ColorMenu.createDialog()
// -------------------------------------------------------
ColorMenu.prototype["createDialog"] = function(defaultColor) {
    var sliderSize = 256;
    var ctlHgt = 20;
    var ctlSpace = 10;

    this.menuActive = false;
    //-------------------------------
    // Set the location of the dialog
    //-------------------------------
    this.cdlg = new Window("dialog", "Color Chooser");
    this.cdlg.frameLocation = this.winFrameLocation;
    this.cdlg.orientation = "column";
    this.cdlg.newColor = new SolidColor();
    this.cdlg.newColor.rgb = defaultColor.rgb;
    //--------------------------------------
    // Add the default OK and Cancel buttons
    //--------------------------------------
    this.cdlg.mainGroup = this.cdlg.add("group");
    this.cdlg.mainGroup.orientation = "row";
    this.cdlg.mainGroup.alignChildren = "fill";
    this.cdlg.mainGroup.spacing = ctlSpace;
    this.cdlg.okBtn = this.cdlg.mainGroup.add("button", undefined, "OK", {name:"ok"});
    this.cdlg.okBtn.helpTip = "Accept the new color";
    this.cdlg.okBtn.preferredSize = [60,ctlHgt];
    if (this.isIconValid) {                       // add the PNG image icon
        this.cdlg.imageIcon = this.cdlg.mainGroup.add("image", undefined, "Step1Icon");
        this.cdlg.imageIcon.preferredSize = [40,ctlHgt];
    }
    this.cdlg.cancelBtn = this.cdlg.mainGroup.add("button", undefined, "Cancel", {name:"cancel"});
    this.cdlg.cancelBtn.helpTip = "Dismiss the new color";
    this.cdlg.cancelBtn.preferredSize = [60,ctlHgt];
    //---------------------------
    // Add the color choser panel
    //---------------------------
    this.cdlg.colorPanel = this.cdlg.add("panel", undefined, "New Color");
    this.cdlg.colorPanel.orientation = "column";
    this.cdlg.colorPanel.alignChildren = "fill";
    this.cdlg.colorPanel.spacing = ctlSpace;
    //---------------------
    // Add the color groups
    //---------------------
    this.cdlg.redGroup = this.cdlg.colorPanel.add("group");
    this.cdlg.redGroup.orientation = "row";
    this.cdlg.redGroup.alignChildren = "fill";
    this.cdlg.redGroup.spacing = ctlSpace;
    this.cdlg.greenGroup = this.cdlg.colorPanel.add("group");
    this.cdlg.greenGroup.orientation = "row";
    this.cdlg.greenGroup.alignChildren = "fill";
    this.cdlg.greenGroup.spacing = ctlSpace;
    this.cdlg.blueGroup = this.cdlg.colorPanel.add("group");
    this.cdlg.blueGroup.orientation = "row";
    this.cdlg.blueGroup.alignChildren = "fill";
    this.cdlg.blueGroup.spacing = ctlSpace;
    //---------------------
    // Add the red controls
    //---------------------
    this.cdlg.redColorTxt = this.cdlg.redGroup.add("statictext", undefined, "Red");
    this.cdlg.redColorTxt.preferredSize = [40,ctlHgt];
    this.cdlg.redSlider = this.cdlg.redGroup.add("scrollbar", undefined, defaultColor.rgb.red, 0, 255);
    this.cdlg.redSlider.preferredSize = [sliderSize,ctlHgt];
    this.cdlg.redSlider.onChange = function() {colorMenu.tryUpdateMenu("Slider");};
    this.cdlg.redSlider.onChanging = function() {colorMenu.tryUpdateMenu("Changing");};
    this.cdlg.redSlider.helpTip = "Adjust the red cannnel value";
    this.cdlg.redValue = this.cdlg.redGroup.add("edittext");
    this.cdlg.redValue.preferredSize = [40,ctlHgt];
    this.cdlg.redValue.onChange = function() {colorMenu.tryUpdateMenu("Value");};
    this.cdlg.redValue.text = Math.round(this.cdlg.redSlider.value);
    this.cdlg.redValue.helpTip = "Set the red cannnel value, 0 to 255";
    //-----------------------
    // Add the green controls
    //-----------------------
    this.cdlg.greenColorTxt = this.cdlg.greenGroup.add("statictext", undefined, "Green");
    this.cdlg.greenColorTxt.preferredSize = [40,ctlHgt];
    this.cdlg.greenSlider = this.cdlg.greenGroup.add("scrollbar", undefined, defaultColor.rgb.green, 0, 255);
    this.cdlg.greenSlider.preferredSize = [sliderSize,ctlHgt];
    this.cdlg.greenSlider.onChange = function() {colorMenu.tryUpdateMenu("Slider");};
    this.cdlg.greenSlider.onChanging = function() {colorMenu.tryUpdateMenu("Changing");};
    this.cdlg.greenSlider.helpTip = "Adjust the green cannnel value";
    this.cdlg.greenValue = this.cdlg.greenGroup.add("edittext");
    this.cdlg.greenValue.preferredSize = [40,ctlHgt];
    this.cdlg.greenValue.onChange = function() {colorMenu.tryUpdateMenu("Value");};
    this.cdlg.greenValue.text = Math.round(this.cdlg.greenSlider.value);
    this.cdlg.greenValue.helpTip = "Set the green cannnel value, 0 to 255";
    //----------------------
    // Add the blue controls
    //----------------------
    this.cdlg.blueColorTxt = this.cdlg.blueGroup.add("statictext", undefined, "Blue");
    this.cdlg.blueColorTxt.preferredSize = [40,ctlHgt];
    this.cdlg.blueSlider = this.cdlg.blueGroup.add("scrollbar", undefined, defaultColor.rgb.blue, 0, 255);
    this.cdlg.blueSlider.preferredSize = [sliderSize,ctlHgt];
    this.cdlg.blueSlider.onChange = function() {colorMenu.tryUpdateMenu("Slider");};
    this.cdlg.blueSlider.onChanging = function() {colorMenu.tryUpdateMenu("Changing");};
    this.cdlg.blueSlider.helpTip = "Adjust the blue cannnel value";
    this.cdlg.blueValue = this.cdlg.blueGroup.add("edittext");
    this.cdlg.blueValue.preferredSize = [40,ctlHgt];
    this.cdlg.blueValue.onChange = function() {colorMenu.tryUpdateMenu("Value");};
    this.cdlg.blueValue.text = Math.round(this.cdlg.blueSlider.value);
    this.cdlg.blueValue.helpTip = "Set the blue cannnel value, 0 to 255";
    //---------------------
    // Add the text message
    //---------------------
    if (!this.isIconValid) {
        this.cdlg.previewColorTxt = this.cdlg.add("statictext", undefined,
            " Preview selected color in Photoshop Foreground Color");
        app.foregroundColor = defaultColor;   // the starting color
    }
    this.cdlg.onMove = function() {colorMenu.tryUpdateMenu("Move");};
    this.cdlg.onShow = function() {colorMenu.tryUpdateMenu("Show");};
    return(this.cdlg);
}

// -------------------------------------------------------
// ColorMenu.tryUpdateMenu()
// -------------------------------------------------------
ColorMenu.prototype["tryUpdateMenu"] = function(caller) {
    var ex;

    try {
        if (this.menuActive || caller == "Move" || caller == "Show")
            this.updateMenu(caller);
    } catch(ex) {
        alert(scriptName + " ColorMenu.updateMenu(" + caller +
                           ") exception caught? line[" + ex.line + "]\n"  + ex);
        if (this.menuActive)
            this.cdlg.close(0); // there is no point in re-throwing the exception
    }
    return;
}

// -------------------------------------------------------
// ColorMenu.updateMenu()
// -------------------------------------------------------
ColorMenu.prototype["updateMenu"] = function(caller) {
    var testNum;

    switch(caller) {
        case "Show":
            if (this.isIconValid) {
                this.changeIcon(this.cdlg.newColor);       // change the icon color
                this.cdlg.imageIcon.icon = iconURL;        // the updated PNG file
            }
            this.menuActive = true;
            break;
        case "Move":
            this.winFrameLocation = this.cdlg.frameLocation;
            if (this.menuActive)
                waitForRedraw();
            break;
        case "Value":
            testNum = Number(this.cdlg.redValue.text);
            if (isNaN(testNum) || testNum < 0 || testNum > 255) {
                alert("Red" + testNum + ", must be a number 0-255");
                this.cdlg.redValue.text = this.cdlg.newColor.rgb.red;
            }
            this.cdlg.redSlider.value = Number(this.cdlg.redValue.text);
            testNum = Number(this.cdlg.greenValue.text);
            if (isNaN(testNum) || testNum < 0 || testNum > 255) {
                alert("Green=" + testNum + ", must be a number 0-255");
                this.cdlg.greenValue.text = this.cdlg.newColor.rgb.green;
            }
            this.cdlg.greenSlider.value = Number(this.cdlg.greenValue.text);
            testNum = Number(this.cdlg.blueValue.text);
            if (isNaN(testNum) || testNum < 0 || testNum > 255) {
                alert("Blue=" + testNum + ", must be a number 0-255");
                this.cdlg.blueValue.text = this.cdlg.newColor.rgb.blue;
            }
            this.cdlg.blueSlider.value = Number(this.cdlg.blueValue.text);
            break;
        case "Changing":
        case "Slider":
            this.cdlg.redValue.text = Math.round(this.cdlg.redSlider.value);
            this.cdlg.greenValue.text = Math.round(this.cdlg.greenSlider.value);
            this.cdlg.blueValue.text = Math.round(this.cdlg.blueSlider.value);
            break;
        default:
            alert("ColorMenu.updateMenu() Invalid caller=" + caller);
            break;
    }
    if (caller == "Value" || caller == "Slider") {
        this.cdlg.newColor.rgb.red = Math.round(this.cdlg.redValue.text);
        this.cdlg.newColor.rgb.green = Math.round(this.cdlg.greenValue.text);
        this.cdlg.newColor.rgb.blue =  Math.round(this.cdlg.blueValue.text);
        if (this.isIconValid) {
            this.changeIcon(this.cdlg.newColor);           // change the icon color
            this.cdlg.imageIcon.icon = "Step1Icon";        // just to force an icon change
            this.cdlg.imageIcon.icon = iconURL;            // the updated PNG file
        } else {
            app.foregroundColor = this.cdlg.newColor;      // show change in FG color
        }
        this.cdlg.active = true;                           // lost focus due to icon update?
    }
    return;
}

// -------------------------------------------------------
// ColorMenu.changeIcon()
// -------------------------------------------------------
ColorMenu.prototype["changeIcon"] = function(color) {
    var ex;

    try {
        updatePNGicon(color);
    } catch(ex) {
        alert(scriptName + " ColorMenu.changeIcon() exception caught? line[" + ex.line + "] "  + ex);
        this.cdlg.close(0); // there is no point in re-throwing the exception
    }
    return;
}

// -------------------------------------------------------
// ColorMenu.showDialog()
// -------------------------------------------------------
ColorMenu.prototype["showDialog"] = function(color, framePlacement) {
    var fgSaveColor = app.foregroundColor;
    var selectedColor = null;                    // if dialog cancelled
    var rc;

    if (this.winFrameLocation == null)
        this.winFrameLocation = framePlacement;  // initial window position
    this.createDialog(color);                    // create the window
    rc = this.cdlg.show();                       // show it
    if (rc == 1)  // OK
        selectedColor = this.cdlg.newColor;      // the new color
    else          // Cancel
        app.foregroundColor = fgSaveColor;       // restore
    if (!this.keepIcon && docRefIcon != null) {
        docRefIcon.close(SaveOptions.DONOTSAVECHANGES);
        docRefIcon = null;
    }
    return(selectedColor);
}

// =======================================================
// Static Functions
// =======================================================

// -------------------------------------------------------
// updatePNGicon()
// -------------------------------------------------------
function updatePNGicon(color) {
    var ex;
    var rc = false;

    try {
        if (docRefIcon == null) {
            try {
                app.open(File(iconURL));
                docRefIcon = app.activeDocument;
                docRefIcon.activeLayer = docRefIcon.layers[docRefIcon.layers.length-1];
                docRefIcon.selection.selectAll();
            } catch(ex) {
                alert("updatePNGicon() Failed to open icon: " + iconURL + "\n Line(" + ex.line + ") " + ex);
                return(false);
            }
        }
        app.activeDocument = docRefIcon;            // select the icon
        docRefIcon.selection.fill(color);           // fill selection with solid color
        docRefIcon.save();                          // just save color changes
        app.activeDocument = docRefBase;            // current document
        rc = true;
    } catch(ex) {
        alert("updatePNGicon() Exception caught: " + iconURL + "\n Line(" + ex.line + ") " + ex);
        return(false);
    }
    return(rc);
}

// ======================================
// doUserAction()
// ======================================
function doUserAction(actionSet, actionName) {
    var ex;

    try {
       doAction(actionName, actionSet);
    } catch(ex) {
        alert("doUserAction() Exception caught: Line(" + ex.line + ") " + ex);
    }
   return;
}

//--------------------------------------------------------------------------
// getActionSetInfo()
// walk all the items in the action palette and record the action set
// names and all the action children
// Return: the array of all the ActionData
// Note: This will throw an error during a normal execution. There is a bug
// in Photoshop that makes it impossible to get an acurate count of the number
// of action sets.
//--------------------------------------------------------------------------
function getActionSetInfo() {
    var actionSetInfo = new Array();
    var setCounter = 1;
    var ref;
    var desc;
    var actionData;
    var numberChildren;

      while (true) {
        ref = new ActionReference();
        ref.putIndex(charIDToTypeID("ASet"), setCounter);
        desc = undefined;
        try {desc = executeActionGet(ref); }
        catch(e) {break;}
        actionData = new ActionData();
        if(desc.hasKey(charIDToTypeID("Nm  ")))
            actionData.name = desc.getString(charIDToTypeID("Nm  "));
        numberChildren = 0;
        if (desc.hasKey(charIDToTypeID("NmbC")))
            numberChildren = desc.getInteger(charIDToTypeID("NmbC"));
        if (numberChildren) {
            actionData.children = getActionInfo(setCounter, numberChildren);
            actionSetInfo.push(actionData);
        }
        setCounter++;
    }
    return(actionSetInfo);
}

//--------------------------------------------------------------------------
// getActionInfo()
// used when walking through all the actions in the action set
// Input: action set index, number of actions in this action set
// Return: true or false, true if file or folder is to be displayed
//--------------------------------------------------------------------------
function getActionInfo(setIndex, numChildren) {
    var actionInfo = new Array();
    var ref;
    var desc;
    var actionData;
    var numberChildren;
    var i;

    for (i=1; i<=numChildren; i++) {
        ref = new ActionReference();
        ref.putIndex(charIDToTypeID("Actn"), i);
        ref.putIndex(charIDToTypeID("ASet"), setIndex);
        desc = undefined;
        desc = executeActionGet(ref);
        actionData = new ActionData();
        if (desc.hasKey(charIDToTypeID("Nm  ")))
            actionData.name = desc.getString(charIDToTypeID("Nm  "));
        numberChildren = 0;
        if (desc.hasKey(charIDToTypeID("NmbC")))
            numberChildren = desc.getInteger(charIDToTypeID("NmbC"));
        actionInfo.push(actionData);
    }
    return(actionInfo);
}

//=========================================
// ActionData()
// this could be an action set or an action
// Return: a new Object of ActionData
//=========================================
function ActionData() {
    this.name = "";
    this.children = undefined;
    this.toString = function () {
        var strTemp = this.name;
        var i;
        if (this.children != undefined) {
            for (i=0; i<this.children.length; i++) {
                strTemp += " " + this.children[i].toString();
            }
        }
        return(strTemp);
    }
    return;
}

//--------------------------------------------------------
// doLayerActions()
//--------------------------------------------------------
function doLayerActions(layerCount) {
    var effectsArray = new Array();
    var actionSelected = false;
    var i;

    if (!(userActionSet == "" || userActionSet == "none" || userAction == "" || userAction == "none"))
        actionSelected = true;
    //------------------------------
    // set the selected layer active
    //------------------------------
    docRefBase.activeLayer = docRefBase.layers[layerArray[layerIndex][0]];
    //--------------------------------------
    // make an array of custom layer effects
    //--------------------------------------
    if (strokeEffect)
        effectsArray[effectsArray.length] = "Stroke";
    if (overlayEffect)
        effectsArray[effectsArray.length] = "ColorOverlay";
    if (dropShadowEffect)
        effectsArray[effectsArray.length] = "DropShadow";
    if (embossEffect)
        effectsArray[effectsArray.length] = "Emboss";
    if (glowEffect)
        effectsArray[effectsArray.length] = "Glow";
    if (satinEffect)
        effectsArray[effectsArray.length] = "Satin";
    //--------------------------------------
    // apply the custom layer effects
    //--------------------------------------
    if (effectsArray.length > 0) {
        if (applyAllLayers) {
            for (i=0; i<layerArray.length; i++) {
                docRefBase.activeLayer = docRefBase.layers[layerArray[i][0]];
                if (!docRefBase.activeLayer.isBackgroundLayer)
                    newLayerEffect(effectsArray);
            }
        } else {
            if (docRefBase.activeLayer.isBackgroundLayer)
                alert(scriptName + " Error current layer is BG!");
            else
                newLayerEffect(effectsArray);
        }
    } else if (!actionSelected && !styleDelete && styleScalePct == 100.0) {
        alert(scriptName + " No layer action or custom layer effects have been selected!");
    }
    //------------------------
    // apply any layer actions
    //------------------------
    if (applyAllLayers) {
        for (i=0; i<layerArray.length; i++) {
            docRefBase.activeLayer = docRefBase.layers[layerArray[i][0]];
            if (!docRefBase.activeLayer.isBackgroundLayer) {
                if (actionSelected)
                    doUserAction(userActionSet, userAction);
                if (styleScalePct != 100.0)
                    scaleLayerEffects(styleScalePct);
                if (styleDelete)
                    deleteLayerEffects();
            }
        }
    } else {
        if (actionSelected)
            doUserAction(userActionSet, userAction);
        if (styleScalePct != 100.0)
            scaleLayerEffects(styleScalePct);
        if (styleDelete)
            deleteLayerEffects();
    }
    waitForRedraw();
    return;
}

//--------------------------------------------------------
// newLayerEffect()
// creates multiple effects in a Layer Style
//--------------------------------------------------------
function newLayerEffect(effects) {
    var refr01 = new ActionReference();
    var layerProperties = new ActionDescriptor();
    var layerOptions = new ActionDescriptor();
    var layerScale = 400.0;
    var useGlobalLight = false;
    var globalLightDesc = null;
    var layerEffects;
    var ex;
    var i;

    //--------------
    // layer scaling
    //--------------
    layerOptions.putUnitDouble(charIDToTypeID("Scl "), charIDToTypeID("#Prc"), layerScale);
    if (useGlobalLight)
        globalLightDesc = layerOptions;
    //--------------
    // layer effects
    //--------------
    for (i=0; i<effects.length; i++) {
        switch(effects[i]) {
            case "Stroke":
                layerEffects = newStrokeEffect(strokeSize, strokeColor, strokePosition);
                layerOptions.putObject(charIDToTypeID("FrFX"), charIDToTypeID("FrFX"), layerEffects);
                break;
            case "ColorOverlay":
                layerEffects = newColorOverlayEffect(overlayOpacity, overlayColor);
                layerOptions.putObject(charIDToTypeID("SoFi"), charIDToTypeID("SoFi"), layerEffects);
                break;
            case "Emboss":
                layerEffects = newBevelEmbossEffect(globalLightDesc, embossDepth, embossSize, embossSoften,
                                                    shadingAngle, shadingAltitude);
                layerOptions.putObject(charIDToTypeID("ebbl"), charIDToTypeID("ebbl"), layerEffects);
                break;
            case "DropShadow":
                layerEffects = newDropShadowEffect(globalLightDesc, dropShadowColor, dropShadowAngle,
                                               dropShadowSize, dropShadowDistance, dropShadowSpread);
                layerOptions.putObject(charIDToTypeID("DrSh"), charIDToTypeID("DrSh"), layerEffects);
                break;
            case "Glow":
                layerEffects = newGlowEffect(glowColor, glowOpacity, glowSize, glowContourName);
                if (glowInner)
                    layerOptions.putObject(charIDToTypeID("IrGl"), charIDToTypeID("IrGl"), layerEffects);
                else
                    layerOptions.putObject(charIDToTypeID("OrGl"), charIDToTypeID("OrGl"), layerEffects);
                break;
            case "Satin":
                layerEffects = newSatinEffect(satinColor, satinOpacity, satinDistance, satinAngle, satinBlur);
                layerOptions.putObject(charIDToTypeID("ChFX"), charIDToTypeID("ChFX"), layerEffects);
                break;
            default:
                throw("newLayerEffect() Invalid effect=" + effects[i]);
                break;
        }
    }
    //-----------------
    // layer properties
    //-----------------
    refr01.putProperty(charIDToTypeID("Prpr"), charIDToTypeID("Lefx"));
    refr01.putEnumerated(charIDToTypeID("Lyr "), charIDToTypeID("Ordn"), charIDToTypeID("Trgt"));
    layerProperties.putReference(charIDToTypeID("null"), refr01);
    layerProperties.putObject(charIDToTypeID("T   "), charIDToTypeID("Lefx"), layerOptions);
    try {
        executeAction(charIDToTypeID("setd"), layerProperties, showPsDlgs);
    } catch(ex) {
        if (ex != "Error: User cancelled the operation")
            alert(scriptName + " newLayerEffect() exception caught? line[" + ex.line + "] "  + ex);
    }
    return;
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
    var effectDescriptor = new ActionDescriptor();
    var effectColor = new ActionDescriptor();

    effectDescriptor.putBoolean(charIDToTypeID("enab"), true);
    effectDescriptor.putEnumerated(charIDToTypeID("Md  "), charIDToTypeID("BlnM"), charIDToTypeID("Clr "));
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

// -------------------------------------------------------
// waitForRedraw()
//  [necessary if script is invokde by an action]
// -------------------------------------------------------
function waitForRedraw() {
    var eventWait = charIDToTypeID("Wait");
    var enumRedrawComplete = charIDToTypeID("RdCm");
    var typeState = charIDToTypeID("Stte");
    var keyState = charIDToTypeID("Stte");
    var desc = new ActionDescriptor();

    desc.putEnumerated(keyState, typeState, enumRedrawComplete);
    executeAction(eventWait, desc, DialogModes.NO);
    return;
}

// -------------------------------------------------------
// newRGBColor()
// -------------------------------------------------------
function newRGBColor(r, g, b) {
    var newColor = new SolidColor();

    newColor.rgb.red = r;
    newColor.rgb.green = g;
    newColor.rgb.blue = b;
    return(newColor);
}

// -------------------------------------------------------
// showProperties()
// -------------------------------------------------------
function showProperties(obj, str) {
    var propMsg = "";
    var props;
    var i, ex;

    try {
        if (obj == undefined || obj == null) {
            alert("showProperties(" + str + ") is " + obj);
            return;
        }
    } catch(ex) {
        alert("showProperties(" + str + "), Exception: " + ex);
        return;
    }
    try {
        props = obj.reflect.properties;
    } catch(ex) {
        alert("showProperties(" + str + "), length=" + obj.length + ", has no properties " + obj);
        return;
    }
    for (i=0; i<props.length; i++) {
        propMsg += "\nObject.property[" + i + "] " + props[i].name;
    }
    propMsg += "\n" + str + ".__class__ " + obj.__class__;
    propMsg += "\n" + str + ".__proto__ " + obj.__proto__;
    propMsg += "\n" + str + ".__count__ " + obj.__count__;
    alert("showProperties(" + str + ")" + propMsg);
    return;
}

// -----------------------------------------
// replaceUrlBlanks()
// replace %20:" " and trim to max length
// -----------------------------------------
function replaceUrlBlanks(urlString, lth) {
    var newUrl = new String(urlString);     // new url string
    var urlBlanks  = new RegExp(/\%20/g);

    newUrl = newUrl.replace(urlBlanks, " ");
    if (lth != undefined && newUrl.length > lth+1)
        newUrl = "~" + newUrl.substr(newUrl.length-lth, newUrl.length);
    return(newUrl);
}

// -----------------------------------------
// getElapsedTime()
// -----------------------------------------
function getElapsedTime(startTime) {
    var now = new Date();
    var timeDiff = Number(0);
    var timeString = new String("");
    timeDiff = Math.round((now - startTime) / 1000);
    if (timeDiff > 3600) {
        timeString = Math.round(timeDiff / 3600) + " hours ";
        timeDiff = Math.round(timeDiff % 3600);
    }
    if (timeDiff > 60) {
        timeString = timeString + Math.round(timeDiff / 60) + " minutes ";
        timeDiff = Math.round(timeDiff % 60);
    } else if (timeString.length > 0) {
        timeString = timeString + "0 minutes ";
    }
    timeString = timeString + Math.round(timeDiff) + " seconds ";
    return(timeString);
}

// -----------------------------------------
// showUsage()
// -----------------------------------------
function showUsage(reason) {
    var msgStr = "";

    msgStr += "\n" + crSymbol + " 2008 Rags Int., Inc. Rags Gardner: www.rags-int-inc.com\n";
    msgStr += "\nThis LayerEffects script can be run against a template created with";
    msgStr += "\nCollageBuilder.jsx or a collage that includes processsed images.";
    msgStr += "\nThis will allow the user to change existing layer effects";
    msgStr += "\nNote: only normal art layers that are not in a layer set";
    msgStr += "\nwill be included, no background, text, or adjustment layers.";
    alert(scriptName + " " + reason + msgStr);
    return;
}

// -----------------------------------------
// getMyScriptFileName()
// from the exception data
// -----------------------------------------
function getMyScriptFileName() {
    var fname = null;
    var dbLevel;
    var ex;

    try {
        dbLevel = $.level;   // save
        $.level = 0;
        undefined_variable;  // error
    } catch(ex) {
        fname = ex.fileName; // path/file
    } finally {
        $.level = dbLevel;   // restore
    }
    fname = fname.substring(fname.lastIndexOf("/")+1, fname.lastIndexOf("."));
    return(fname);
}

// -----------------------
// getScriptPath()
// from the exception data
// -----------------------
function getScriptPath() {
    var fpath = null;
    var dbLevel;
    var ex;

    try {
        dbLevel = $.level;   // save
        $.level = 0;
        undefined_variable;  // throw an exception
    } catch(ex) {
        fpath = ex.fileName; // path/file
    } finally {
        $.level = dbLevel;   // restore
    }
    fpath = fpath.substring(0, fpath.lastIndexOf("/")+1);
    return(fpath);
}

// -----------------------------------------
// cleanUp()
// -----------------------------------------
function cleanUp() {
    var ex;

    app.preferences.rulerUnits = initRulerUnits;
    app.DisplayDialogs = initDisplayDialogs;
    app.backgroundColor = initBgColor;
    app.foregroundColor = initFgColor;
    try {
        if (iconCreated && File(iconURL).exists)
            File(iconURL).remove();
    } catch(ex) {} // ignore invalid object
    try {
        if (docRefIcon != null)
            docRefIcon.close(SaveOptions.DONOTSAVECHANGES);
    } catch(ex) {} // ignore invalid object
    return;
}

// -----------------------------------------
// mainFunction()
// -----------------------------------------
function mainFunction() {
    var retCd;
    var layerCount;
    var testLayer;
    var saveOpts;
    var i;

    //-----------
    // initialize
    //-----------
    app.preferences.rulerUnits = Units.PIXELS;
    app.DisplayDialogs = DialogModes.NO;
    layerCount = docRefBase.layers.length;
    //----------------------
    // Find the image layers
    //----------------------
    layerArray = new Array();
    for (i=layerCount-1; i>=0; i--) {
        testLayer = docRefBase.layers[i];
        if (!testLayer.isBackgroundLayer
              && testLayer.kind == LayerKind.NORMAL
              && testLayer.visible == true) {
            layerArray[layerArray.length] = new Array(i, testLayer.name);
        }
    }
    if (layerArray.length < 1) {
        showUsage(docRefBase.name + " No usable image artLayers found, aborting");
        return;
    }
    layerIndex = 0;  // the initially selected layer
    iconPath = new String($.getenv ("TEMP") + "/"); // try the OS TEMP directory
    if (iconPath == "/")
        iconPath = getScriptPath();                 // try the ~/presets/scripts directory
    iconURL = iconPath + defaultIconName;
    /// if (!confirm(scriptName + " Use color icon in menus?\n" + replaceUrlBlanks(iconURL)))
    ///     useIconPreview = false;
    //-----------------------------------------
    // open an icon image for the color chooser
    //-----------------------------------------
    if (useIconPreview) {
        if (File(iconURL).exists) {
            if (confirm(" Icon file found:\n  " + replaceUrlBlanks(iconURL) +
                        "\n\nRemove it?")) {
                if (!File(iconURL).remove()) {
                    alert(scriptName + "Could not remove Icon:\n" + replaceUrlBlanks(iconURL));
                    return;
                }
            }
        }
        app.documents.add(40, 20, 72, defaultIconName,
                      NewDocumentMode.RGB, DocumentFill.BACKGROUNDCOLOR);
        docRefIcon = app.activeDocument;
        saveOpts = new PNGSaveOptions();
        saveOpts.interlaced = false;
        docRefIcon.saveAs(File(iconURL), saveOpts, false, Extension.LOWERCASE);
        docRefIcon.close(SaveOptions.DONOTSAVECHANGES);
        docRefIcon = null;                      // close the PS document
        iconCreated = true;                     // icon created by this script
    }
    //------------------------
    // create the menu objects
    //------------------------
    colorMenu = new ColorMenu(useIconPreview);
    layerMenu = new LayerMenu(useIconPreview);
    //----------------------------------
    // apply the user selected effect(s)
    //----------------------------------
    while (1) {
        //--------------
        // show the menu
        //--------------
        retCd = layerMenu.showDialog();    // returns 1 or 2
        //------------------------------------------
        // update the global configuration variables
        //------------------------------------------
        if (retCd != 1)             // user changes accepted?
            return;                 // user cancelled
        //---------------------------------
        // apply the selected layer effectsNONE
        //---------------------------------
        app.activeDocument = docRefBase;        // current document
        doLayerActions(layerCount);             // apply selected effects
    }
    //----------------------------
    // finished
    //----------------------------
    return;
}

// =======================================================
// =======================================================
// JavaScript EntryPoint
// =======================================================
// =======================================================
var crSymbol = new String("\u00A9");         // (c) symbol
var docRefBase = null;                       // base document
var docRefIcon = null;                       // icon document
var iconPath = "";                           // the PNG image file path
var iconURL;                                 // the PNG image path + name
var iconCreated = false;                     // icon created by this script
var userActionSet = "";                      // action set
var userAction = "";                         // user action
var userActionSetIdx = 0;                    // action set index
var userActionIdx = 0;                       // user action index
var initRulerUnits;                          // save ruler units
var initDisplayDialogs;                      // save dialog settings
var initBgColor;                             // save BG color
var initFgColor;                             // save FG color
var baseVer = new String(app.version);       // photoshop version string
var psVer;                                   // photoshop version
var layerArray;                              // selected image layers
var layerIndex;                              // selected layer index
var whiteColor = newRGBColor(255, 255, 255); // white
var blackColor = newRGBColor(0, 0, 0);       // black
var sepiaColor = newRGBColor(43, 2, 2);      // sepia
var iconPath;                                // path to the icon image
var defaultLocation = [200, 300];            // default window location
var layerMenu;                               // layer options menu
var colorMenu;                               // color options menu
var e;                                       // exception information
var lineMsg = " ";                           // exception line number
var codeMsg = "";                            // exception code number

//------------------------
// Dispatch mainFunction()
// Is a document open?
//--------------------
baseVer = baseVer.substring(0, baseVer.lastIndexOf("."));
psVer = parseFloat(baseVer);
if (psVer < 9.0) {
    alert(scriptName + " uses menu functions not avaliable with Photoshop version " + psVer);
} else {
    scriptName = getMyScriptFileName() + " " + scriptVersion;
    if (documents.length == 0) {
        showUsage("There is no active document!");
    } else {
        initRulerUnits = app.preferences.rulerUnits;
        initDisplayDialogs = app.DisplayDialogs;
        initBgColor = app.backgroundColor;
        initFgColor = app.foregroundColor;
        //------------------------
        // Dispatch mainFunction()
        //------------------------
        try {
            docRefBase = app.activeDocument;            // current document
            mainFunction();
        } catch(e) {                                    // show errors
            if (e.number != undefined)
                codeMsg = " errCode[" + e.number + "]"; // exception code number
            if (e.line != undefined)
                lineMsg = " line[" + e.line + "]";      // exception line number
            alert("Main() " + codeMsg + lineMsg + " Exception:\n" + e,
                scriptName + " Exception!");            // show the error
        }
        cleanUp();                                      // restore rulers...
    }
}
// end JavaScript