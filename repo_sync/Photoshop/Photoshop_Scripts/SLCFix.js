//
// SLCFix.js
//   This script does some minor massaging of ScriptListener output
//   primarily by substituting charIDToTypeID and stringIDToTypeID with
//   cTID and sTID. In the process of doing this replacement, the
//   'var id##' style declarations are removed in the c/sTID calls
//   placed inline. You'll need to copy the c/sTID definitions from
//   this file into whatever file you decide to use the converted code.
//
//   One other piece of corrective surgery is to canonicalize all
//   filename strings to use '/' instead of '\' characters. I didn't bother
//   messing with the drive names.
//
//   The only thing left that I don't really have a solution for is Actions
///  that invoke scripts. For some reason, the return value of the script
//   is placed in the action and gets output to the ScriptingListener log
//   file as well. Search for 'jsMs' to see what I mean. Unforunately, in
//   many case, the return value is effectively the last piece of textual
//   code parsed, I think. There is not an easy way that I have found to
//   remove this travesty after the fact, except to do it manually by replacing
//   the code with an empty string, "". You can, however, remove it before
//   the fact. Make the last line of your script files 'true;' or, like I do,
//   the name of the script as a string, e.g. "SLCFix.js"; This has the nice
//   added benefit of showing up in the debugger console if you are running
//   the script from within the debugger.
//
//   I've converted upto 20,000 lines of ScriptingListenerJS.log code in one
//   pass with the only problems being the 'jsMs' garbage. That can, as I said
//   before, be fixed manually.
//
// $Id: SLCFix.js,v 1.72 2015/12/03 22:01:32 anonymous Exp $
// Copyright: (c)2005, xbytor
// License: http://www.opensource.org/licenses/bsd-license.php
// Contact: xbytor@gmail.com
//
//@show include
//
var app; if (!app) app = this; // for PS7

isWindows = function() {
  return $.os.match(/windows/i);
};
isMac = function() {
  return !isWindows();
};

//
//
//
// PSConstants
// Javascript definitions for Class, Enum, Event, Form, Key,
//    Type, and Unit symbols
//
//  $Id: SLCFix.js,v 1.72 2015/12/03 22:01:32 anonymous Exp $
//
// Manual fix at line 2302
//
PSConstants = function PSConstants() {};
// PSConstants.prototype = new Array();

PSConstants.symbolTypes = new Object();
PSConstants.add = function(kind, name) {
  if (!name) { throw "Internal error PSConstants.add()"; }
  kind._name = name;
  kind._reverseName = new Object();
  kind._reverseSym = new Object();
  kind._add = function(name, sym) {
    if (!name || !sym) { throw "Internal error kind._add()"; }
    kind[name] = app.charIDToTypeID(sym);
    // collision detection...
    // if (kind._reverseName[kind[name]]) {
    //   writeln('PS' + kind._name + ', ' + sym + ', ' +
    //             kind._reverseName[kind[name]] + ', ' + name);
    // }
    kind._reverseName[kind[name]] = name;
    kind._reverseSym[kind[name]] = sym;
  };

  PSConstants.symbolTypes[kind._name] = kind;
};

// deprecated version
PSConstants._reverseNameLookup = function(id) {
  var tbl = PSConstants.symbolTypes;

  for (var name in tbl) {
    //writeln(id + " " + tbl + " " + name + " " + tbl[name]);
    var kind = tbl[name];
    var r = kind._reverseName[id];
    if (r) return r;
  }
  return undefined;
};
// deprecated version
PSConstants._reverseSymLookup = function(id) {
  var tbl = PSConstants.symbolTypes;

  for (var name in tbl) {
    //writeln(id + " " + tbl + " " + name + " " + tbl[name]);
    var kind = tbl[name];
    var r = kind._reverseSym[id];
    if (r) return r;
  }
  return undefined;
};


PSConstants._getTbl = function(id, ns) {
  var tbl = PSConstants.symbolTypes;

  if (ns) {
    // if a namespace is specified, it is searched first,
    // followed by String and then the rest...

    var nm;
    tbl = [];
    if (ns.constructor == String) {
      nm = ns;

    } else if (ns._name) {
      nm = ns._name;

    } else {
      Error.runtimeError(9100, "Bad map specified: " + ns.toString());
    }

    tbl.push(PSConstants.symbolTypes[nm]);

    for (var name in PSConstants.symbolTypes) {
      if (name != nm && name != "String") {
        tbl.push(PSConstants.symbolTypes[name]);
      }
    }

    if (nm != "String") {
      tbl.push(PSConstants.symbolTypes["String"]);
    }
  }

  return tbl;
};


// 'ns' is the optional 'namespace' in these reverse lookup functions.
// It can be either a string ("Class") or a
// table object from PSConstants (PSClass). Using 'ns' will help
// these functions return the most appropriate results since collisions
// happen. For instance, cTID('Rds ') is the id for PSKey.Radius
// and PSEnum.Reds.
//
PSConstants.reverseNameLookup = function(id, ns) {
 var tbl = PSConstants._getTbl(id, ns);

  for (var name in tbl) {
    //writeln(id + " " + tbl + " " + name + " " + tbl[name]);
    var kind = tbl[name];
    var r = kind._reverseName[id];
    if (r) return r;
  }
  return undefined;
};
PSConstants.reverseSymLookup = function(id, ns) {
  var tbl = PSConstants._getTbl(id, ns);

  for (var name in tbl) {
    //writeln(id + " " + tbl + " " + name + " " + tbl[name]);
    var kind = tbl[name];
    var r = kind._reverseSym[id];
    if (r) return r;
  }
  return undefined;
};
PSConstants.reverseStringLookup = function(id) {
  return PSString._reverseSym[id];
};
// PSContants._massageName = function(name) {
//   name = name.replace(/\s/g, '');
//   return name;
// };
PSConstants.lookup = function(kname) {
  kname = kname.replace(/\s/g, '');
  var tbl = PSConstants.symbolTypes;
  for (var name in tbl) {
    //writeln(id + " " + tbl + " " + name + " " + tbl[name]);
    var kind = tbl[name];
    var r = kind[kname];
    if (r) return r;
  }
  return undefined;
};
PSConstants.lookupSym = function(kname) {
  kname = kname.replace(/\s/g, '');
  var id = PSConstants.lookup(kname);
  return !id ? undefined : PSConstants.reverseSymLookup(id);
};
PSConstants.list = function(kind) {
  var tbl = PSConstants.symbolTypes[kind._name];
  var lst = '';
  for (var name in tbl) {
    if (name.match(/^[A-Z]/)) {
      lst += (kind._name + '.' + name + " = '" + kind[name] + '\';\r\n');
    }
  }
  return lst;
};
PSConstants.listAll = function() {
  var tbl = PSConstants.symbolTypes;
  var lst = '';
  for (var name in tbl) {
    var kind = tbl[name];
    lst += PSConstants.list(kind);
  }
  return lst;
};

PSClass = function PSClass() {};
PSConstants.add(PSClass, "Class");

PSEnum = function PSEnum() {};
PSConstants.add(PSEnum, "Enum");

PSEvent = function PSEvent() {};
PSConstants.add(PSEvent, "Event");

PSForm = function PSForm() {};
PSConstants.add(PSForm, "Form");

PSKey = function PSKey() {};
PSConstants.add(PSKey, "Key");

PSType = function PSType() {};
PSConstants.add(PSType, "Type");

PSUnit = function PSUnit() {};
PSConstants.add(PSUnit, "Unit");


PSString = function PSString() {};
PSConstants.add(PSString, "String");
PSString._add = function(name, sym) {
  if (!name) { throw "Internal error PSString._add()"; }
  if (!sym) sym = name;
  var kind = this;
  kind[name] = app.stringIDToTypeID(sym);
  kind._reverseName[kind[name]] = sym;
  kind._reverseSym[kind[name]] = sym;

  if (!kind[sym]) {
    PSString._add(sym);
  }
};


PSString._add("3DCurrentEngine", "key3DCurrentEngine");

PSKey._add("Z", "Z   ");
PSKey._add("GlobalAmbientRed", "GamR");
PSKey._add("GlobalAmbientGreen", "GamG");
PSKey._add("GlobalAmbientBlue", "GamB");
PSKey._add("GlobalUnits", "Gunt");
PSKey._add("GlobalAnimStart", "Gast");
PSKey._add("GlobalFrames", "Gfrm");
PSKey._add("GlobalFPS", "Gfps");
PSKey._add("CustomData", "GRNm");
PSKey._add("GlobalGeoRef", "GeoR");
PSKey._add("GlobalGeoList", "GeoL");
PSKey._add("GlobalGeoLat", "GeLa");
PSKey._add("GlobalGeoLon", "GeLo");
PSKey._add("GlobalGeoAlt", "GeAl");
PSKey._add("GlobalGeoAltM", "GeAm");
PSKey._add("GlobalGeoHead", "GeHd");
PSKey._add("GlobalGeoTilt", "GeTt");
PSKey._add("GlobalGeoRoll", "GeRl");
PSKey._add("GlobalGeoSclX", "GeSx");
PSKey._add("GlobalGeoSclY", "GeSy");
PSKey._add("GlobalGeoSclZ", "GeSz");
PSKey._add("LightList", "lite");
PSKey._add("LightClass", "litc");
PSKey._add("CameraList", "caml");
PSKey._add("CameraClass", "camc");
PSKey._add("MeshList", "mshl");
PSKey._add("MeshClass", "msho");
PSKey._add("MaterialList", "mtll");
PSKey._add("MaterialClass", "mtlo");
PSKey._add("MeshIsVolume", "misv");
PSKey._add("MeshIsShadCtch", "misc");
PSKey._add("MeshIsShadCast", "miss");
PSKey._add("MeshIsShadInv", "misi");
PSKey._add("RerenderPaint", "rrwp");
PSKey._add("RerenderOnUp", "rrmu");
PSKey._add("ModelHadTrans", "mhtp");
PSKey._add("VertexCount", "verc");
PSKey._add("PolyCount", "plyc");
PSKey._add("Multiple", "mult");
PSKey._add("SSMultiple", "ssml");
PSKey._add("IsOn", "ison");
PSKey._add("TargetX", "tarx");
PSKey._add("TargetY", "tary");
PSKey._add("TargetZ", "tarz");
PSKey._add("Hotspot", "hots");
PSKey._add("Shadow", "shdw");
PSKey._add("Attenuation", "attn");
PSKey._add("AttenType", "attt");
PSKey._add("AttenA", "atta");
PSKey._add("AttenB", "attb");
PSKey._add("AttenC", "attc");
PSKey._add("OuterRadius", "orad");
PSKey._add("InnerRadius", "irad");
PSKey._add("Bank", "bank");
PSKey._add("Ortho", "orth");
PSKey._add("Apsect", "aspr");
PSKey._add("ZoomFactor", "zmfc");
PSKey._add("Flags", "flag");
PSKey._add("Smoothing", "smth");
PSKey._add("3DIndexList", "indl");
PSKey._add("3DIndex", "indx");
PSKey._add("Hidden", "hidn");
PSKey._add("HasMatrix", "hmat");
PSKey._add("HasSmoothing", "hsmt");
PSKey._add("AmbientRed", "ared");
PSKey._add("AmbientGreen", "agrn");
PSKey._add("AmbientBlue", "ablu");
PSKey._add("DiffuseRed", "dred");
PSKey._add("DiffuseGreen", "dgrn");
PSKey._add("DiffuseBlue", "dblu");
PSKey._add("SpecularRed", "sred");
PSKey._add("SpecularGreen", "sgrn");
PSKey._add("SpecularBlue", "sblu");
PSKey._add("EmissiveRed", "ered");
PSKey._add("EmissiveGreen", "egrn");
PSKey._add("EmissiveBlue", "eblu");
PSKey._add("Shininess", "shin");
PSKey._add("Shininess2", "shi2");
PSKey._add("Reflection", "refl");
PSKey._add("SelfIllumination", "self");
PSKey._add("Shading", "shad");
PSKey._add("TwoSide", "twos");
PSKey._add("Wireframe", "wire");
PSKey._add("Decal", "decl");
PSKey._add("3DSStyle", "msty");
PSKey._add("WireframeSize", "wfsz");
PSKey._add("UScale", "uscl");
PSKey._add("VScale", "vscl");
PSKey._add("UOffset", "uoff");
PSKey._add("VOffset", "voff");
PSKey._add("FullMapName", "fMnM");
PSKey._add("VertexList", "verl");
PSKey._add("NormalList", "nrml");
PSKey._add("UVList", "uvl ");
PSKey._add("VertexColorList", "vnvl");
PSKey._add("LineList", "lnfl");
PSKey._add("FaceList", "facl");
PSKey._add("FaceIndexes", "faci");
PSKey._add("MapList", "mapl");
PSKey._add("MapClass", "mapo");
PSKey._add("MaterialIndList", "matl");
PSKey._add("MaterialIndObj", "mato");
PSKey._add("Refraction", "RfAc");
PSKey._add("PreservationClass", "pRes");
PSKey._add("PreservationObject", "pRob");
PSKey._add("Keys", "KeyS");
PSKey._add("FrameNumber", "FrNm");
PSKey._add("FlagsAnim", "FlAn");
PSKey._add("NameAnim", "FlNn");
PSKey._add("Tension", "KtEn");
PSKey._add("Bias", "KBia");
PSKey._add("Easto", "Keto");
PSKey._add("Easefrom", "Kfro");
PSKey._add("RotationRad", "RoRd");
PSKey._add("AnimVectorX", "vctX");
PSKey._add("AnimVectorY", "vctY");
PSKey._add("AnimVectorZ", "vctZ");
PSKey._add("AnimVectorObject", "vctO");
PSKey._add("AnimationDataClass", "AniC");
PSKey._add("AnimActionClass", "AnAc");
PSKey._add("InstanceName", "InsN");
PSKey._add("Flags1", "flgO");
PSKey._add("Flags2", "flgT");
PSKey._add("U3DNodeID", "NoID");
PSKey._add("U3DParentID", "PrID");
PSKey._add("U3DType", "tYpE");
PSKey._add("PivotX", "PvtX");
PSKey._add("PivotY", "PvtY");
PSKey._add("PivotZ", "PvtZ");
PSKey._add("PivotObject", "PvtO");
PSKey._add("PivotList", "PvLs");
PSKey._add("HasPivot", "PvPr");
PSKey._add("HasRange", "RgBl");
PSKey._add("HasLocalMatrix", "LcMt");
PSKey._add("RangeName", "RgNm");
PSKey._add("KeyFrameList", "KeFL");
PSKey._add("KeyFrameClass", "KeCS");
PSKey._add("AnimationList", "AnLs");
PSKey._add("AnimFrameNumber", "KAfn");
PSKey._add("AnimFrameFlags", "KAff");
PSKey._add("AnimFrameTension", "KAft");
PSKey._add("AnimFrameContinuity", "KAfc");
PSKey._add("AnimFrameBias", "KAfb");
PSKey._add("AnimFrameEaseTo", "KAet");
PSKey._add("AnimFrameEaseFrom", "KAef");
PSKey._add("AnimFrameRotation", "KAro");
PSKey._add("AnimFrameValue", "KAvl");
PSKey._add("AnimFrameVectorX", "KAvx");
PSKey._add("AnimFrameVectorY", "KAvy");
PSKey._add("AnimFrameVectorZ", "KAvz");
PSKey._add("AnimFrameUseQuat", "KAuq");
PSKey._add("AnimFrameQuatW", "KAqw");
PSKey._add("AnimFrameQuatX", "KAqx");
PSKey._add("AnimFrameQuatY", "KAqy");
PSKey._add("AnimFrameQuatZ", "KAqz");
PSKey._add("AnimFrameClass", "KAFC");
PSKey._add("AnimFrameList", "KAFL");
PSString._add("eventToolStart", "keventToolStart");
PSString._add("eventToolStop", "keventToolStop");
PSString._add("renderState", "krenderState");
PSString._add("renderFunction", "krenderFunction");
PSString._add("tool3D");
PSString._add("3DRenderFunctionPtr", "key3DRenderFunction");
PSString._add("3DDirectScenePtr", "key3DDirectScenePtr");
PSString._add("FrameReaderClass", "FrameReader");
PSString._add("FrameReaderTypeKey", "frameReaderType");
PSString._add("DescVersionKey", "descVersion");
PSString._add("DocumentSizeKey", "documentSize");
PSString._add("3DSceneKey", "key3DScene");
PSString._add("3DDataKey", "key3DData");
PSString._add("3DFileNameKey", "key3DFileName");
PSString._add("3DFileListKey", "fileList");
PSString._add("3DMeshTexturePathKey", "key3DMeshTexturePath");
PSString._add("3DTexturesExternalKey", "key3DTexturesExternal");
PSString._add("3DTexturesVisibleKey", "key3DTexturesVisible");
PSString._add("3DTextureListKey", "key3DTextureList");
PSString._add("3DTextureObjectKey", "key3DTextureObject");
PSString._add("3DTextureNameKey", "key3DTextureName");
PSString._add("3DTexturePathKey", "key3DTexturePath");
PSString._add("3DTextureDataKey", "key3DTextureData");
PSString._add("3DTextureVisibleKey", "key3DTextureVisible");
PSString._add("3DTextureTypeKey", "key3DTextureType");
PSString._add("3DDurationKey", "key3DDuration");
PSString._add("3DScriptKey", "key3DScript");
PSString._add("3DState", "key3DState");
PSString._add("3DPositionKey", "key3DPosition");
PSString._add("3DStateListKey", "key3DStateList");
PSString._add("3DStateNameKey", "key3DStateName");
PSString._add("3DXPosKey", "key3DXPos");
PSString._add("3DYPosKey", "key3DYPos");
PSString._add("3DZPosKey", "key3DZPos");
PSString._add("3DXAngleKey", "key3DXAngle");
PSString._add("3DYAngleKey", "key3DYAngle");
PSString._add("3DZAngleKey", "key3DZAngle");
PSString._add("3DFOVKey", "key3DFOV");
PSString._add("3DSpeedKey", "key3DSpeed");
PSString._add("3DCameraDistanceKey", "key3DCameraDistance");
PSString._add("3DCurrentCameraPositionKey", "key3DCurrentCameraPosition");
PSString._add("3DCurrentFOVKey", "key3DCurrentFOV");
PSString._add("3DCurrentPositionKey", "key3DCurrentPosition");
PSString._add("3DCurrentOrthographicKey", "key3DOrthographic");
PSString._add("3DCurrentOrthographicScaleKey", "key3DOrthographicScale");
PSString._add("3DCurrentRenderModeKey", "key3DRenderMode");
PSString._add("3DCurrentLightModeKey", "key3DLightMode");
PSString._add("3DCurrentTimeKey", "key3DTime");
PSString._add("3DCurrentCrossSectionKey", "key3DCrossSection");
PSString._add("3DCrossSectionPlaneColorKey", "key3DCrossSectionPlaneColor");
PSString._add("3DCrossSectionIntersectionColorKey", "key3DCrossSectionIntersectionColor");
PSString._add("3DCrossSectionOffsetKey", "key3DCrossSectionOffset");
PSString._add("3DCrossSectionPlaneTilt1Key", "key3DCrossSectionPlaneTilt1");
PSString._add("3DCrossSectionPlaneTilt2Key", "key3DCrossSectionPlaneTilt2");
PSString._add("3DCrossSectionPlaneOpacityKey", "key3DCrossSectionPlaneOpacity");
PSString._add("3DCrossSectionAlignmentKey", "key3DCrossSectionAlignment");
PSString._add("3DCrossSectionEnabledKey", "key3DCrossSectionEnabled");
PSString._add("3DCrossSectionPlaneFlipKey", "key3DCrossSectionPlaneFlip");
PSString._add("3DCrossSectionPlaneVisibleKey", "key3DCrossSectionPlaneVisible");
PSString._add("3DCrossSectionIntersectionVisibleKey", "key3DCrossSectionIntersectionVisible");
PSString._add("3DCurrentObjectXScaleKey", "key3DCurrentObjectXScale");
PSString._add("3DCurrentObjectYScaleKey", "key3DCurrentObjectYScale");
PSString._add("3DCurrentObjectZScaleKey", "key3DCurrentObjectZScale");
PSString._add("3DAuxilaryColorKey", "key3DAuxilaryColor");
PSString._add("3DFaceColorKey", "key3DFaceColor");
PSString._add("3DOpacityKey", "key3DOpacity");
PSString._add("3DLineWidthKey", "key3DLineWidth");
PSString._add("3DCreaseValueKey", "key3DCreaseValue");
PSString._add("3DViewIndexKey", "key3DViewIndex");
PSString._add("3DEngineIndexKey", "key3DEngineIndex");
PSString._add("3DViewNameKey", "key3DViewName");
PSString._add("3DPaintTypeKey", "key3DPaintType");
PSString._add("3DStateTypeKey", "key3DStateType");
PSString._add("3DTextureFunctionPtr", "key3DTextureFunction");
PSString._add("3DTextureSizeFunctionPtr", "key3DTextureSizeFunction");
PSString._add("3DKeepLayersSeparateKey", "key3DKeepLayersSeparate");
PSKey._add("PolyCount", "plyc");
PSString._add("3DCurrentRenderSettingsKey", "key3DRenderSettings");
PSString._add("3DSecondaryRenderSettingsKey", "key3DRenderSettings2");
PSString._add("3DLineColorKey", "key3DLineColor");
PSString._add("3DVertexColorKey", "key3DVertexColor");
PSString._add("3DRenderFacesKey", "key3DRenderFaces");
PSString._add("3DRenderEdgesKey", "key3DRenderEdges");
PSString._add("3DRenderVerticesKey", "key3DRenderVertices");
PSString._add("3DRenderFaceStyleKey", "key3DRenderFaceStyle");
PSString._add("3DRenderEdgeStyleKey", "key3DRenderEdgeStyle");
PSString._add("3DRenderVerticesStyleKey", "key3DRenderVerticesStyle");
PSString._add("3DRenderAntiAliasKey", "key3DRenderAntiAlias");
PSString._add("3DRenderRayDepthKey", "key3DRenderRayDepth");
PSString._add("3DRenderReflectionsKey", "key3DRenderReflections");
PSString._add("3DRenderRefractionsKey", "key3DRenderRefractions");
PSString._add("3DRenderShadowsKey", "key3DRenderShadows");
PSString._add("3DRenderRemoveBackfacesKey", "key3DRenderRemoveBackfaces");
PSString._add("3DRenderRemoveBackfaceLinesKey", "key3DRenderRemoveBackfaceLines");
PSString._add("3DRenderRemoveBackfaceVerticesKey", "key3DRenderRemoveBackfaceVertices");
PSString._add("3DRenderVolumesKey", "key3DRenderVolume");
PSString._add("3DRenderSeteroKey", "key3DRenderStereo");
PSString._add("3DRenderVolumeStyleKey", "key3DRenderVolumeStyle");
PSString._add("3DRenderStereoStyleKey", "key3DRenderStereoStyle");
PSString._add("3DRenderGradientEnhancedKey", "key3DRenderGradientEnhanced");
PSString._add("3DStereoOffsetKey", "key3DStereoOffset");
PSString._add("3DStereoSpacingKey", "key3DStereoLenticularSpacing");
PSString._add("3DStereoFocalPlaneKey", "key3DStereoFocalPlane");
PSString._add("3DVertexRadiusKey", "key3DVertexRadius");
PSString._add("3DRenderAdvancedIllumKey", "key3DRenderAdvancedIllumVideo");
PSString._add("3DRenderRemoveHiddenLinesKey", "key3DRenderRemoveHiddenLines");
PSString._add("3DRenderRemoveHiddenVerticesKey", "key3DRenderRemoveHiddenVertices");
PSString._add("3DRenderOpacityScaleKey", "key3DRenderOpacityScale");
PSString._add("3DShowGroundPlaneKey", "key3DShowGroundPlane");
PSString._add("3DShowLightsKey", "key3DShowLights");
PSString._add("BBoxCenterX", "keyBBoxCenterX");
PSString._add("BBoxCenterY", "keyBBoxCenterY");
PSString._add("BBoxCenterZ", "keyBBoxCenterZ");
PSString._add("BBoxMinX", "keyBBoxMinX");
PSString._add("BBoxMinY", "keyBBoxMinY");
PSString._add("BBoxMinZ", "keyBBoxMinZ");
PSString._add("BBoxMaxX", "keyBBoxMaxX");
PSString._add("BBoxMaxY", "keyBBoxMaxY");
PSString._add("BBoxMaxZ", "keyBBoxMaxZ");
PSString._add("PreservationId", "keyPreservationId");
PSString._add("PreservationSubId", "keyPreservationSubId");
PSString._add("PreservationName", "keyPreservationName");
PSString._add("PreservationExtra", "keyPreservationExtra");
PSString._add("PreservationFlags", "keyPreservationFlags");
PSString._add("PreservationController", "keyPreservationController");
PSString._add("PreservationAnimations", "keyPreservationAnimations");
PSString._add("PreservationEffectProfiles", "keyPreservationEffectProfiles");
PSString._add("EnumSerialization", "_enum");
PSString._add("ValueSerialization", "_value");
PSString._add("UnitSerialization", "_unit");
PSString._add("PathSerialization", "_path");
PSString._add("ClassSerialization", "_class");
PSString._add("ObjSerialization", "_obj");
PSString._add("IdSerialization", "_id");
PSString._add("IndexSerialization", "_index");
PSString._add("NameSerialization", "_name");
PSString._add("OffsetSerialization", "_offset");
PSString._add("PropertySerialization", "_property");
PSString._add("RefSerialization", "_ref");
PSString._add("JsonNullClassID", "jsonNull");
PSString._add("128BitFloatingPoint");
PSString._add("16BitsPerPixel");
PSString._add("1BitPerPixel");
PSString._add("2BitsPerPixel");
PSString._add("2upHorizontal");
PSString._add("2upVertical");
PSString._add("32BitsPerPixel");
PSString._add("32BitPreviewOptions");
PSString._add("3DSetGlobalAmbient", "set3DGlobalAmbient");
PSString._add("3DBackgroundType", "set3DBackgroundType");
PSString._add("3DBackgroundCount", "set3DBackgroundCount");
PSString._add("3DDisableColorLinearization", "set3DDisableColorLinearization");
PSString._add("3DBackgroundDisparity", "set3DBackgroundDisparity");
PSString._add("3DBackgroundOffset", "set3DBackgroundOffset");
PSString._add("3DAddLayerFromFile", "add3DLayerFromFile");
PSString._add("3DUpdateSceneObjects", "updateSceneObjects");
PSString._add("3DLayerOpenTexture", "open3DLayerTexture");
PSString._add("3DSaveTextures", "save3DTextures");
PSString._add("3DExportLayer", "export3DModel");
PSString._add("3DExportSingleMesh", "export3DSingleMesh");
PSString._add("3DCreatePath", "createPathFrom3D");
PSString._add("3DLightsNewLight");
PSString._add("3DReloadLayer", "reload3DModel");
PSString._add("3DToggleTexture", "toggle3DTexture");
PSString._add("3DResumeFinalRender", "resumeFinal3DRender");
PSString._add("3DRenderSelection", "render3DSelection");
PSString._add("3DSplitRepousseMesh", "splitRepousseMesh");
PSString._add("3DToggleTextures", "toggle3DTextures");
PSString._add("3DSetState", "set3DState");
PSString._add("3DSetUnits", "set3DUnits");
PSString._add("3DCreatePostcard", "create3DPostcard");
PSString._add("3DCreateTiledPainting", "create3DTiledPainting");
PSString._add("3DCreateVolume", "createVolume");
PSString._add("3DAntiAlias");
PSString._add("3DSetLightImageType", "set3DLightImageType");
PSString._add("3DInsertGroundPlane", "insertGroundPlane");
PSString._add("3DRenderQualityPaint");
PSString._add("3DRenderQualityModel");
PSString._add("3DRenderQualityARTInteractive");
PSString._add("3DRenderQualityARTDraft");
PSString._add("3DRenderQualityARTFinal");
PSString._add("3DRenderUVWireframe", "renderUVWireframe");
PSString._add("3DRenderUVVertexColors", "renderUVVertexColors");
PSString._add("3DRenderUVShaded", "renderUVShaded");
PSString._add("3DRenderUVNormalMap", "renderUVNormalMap");
PSString._add("3DRenderUVBrushStrokes", "renderUVBrushStrokes");
PSString._add("3DPrint", "print3D");
PSString._add("3DCancelPrint", "cancelPrint3D");
PSString._add("3DPrintProperties", "print3DProperties");
PSString._add("3DPrintSetProperties", "setPrint3DProperties");
PSString._add("3DPrintScaffoldingMaterial", "k3DPrintScaffoldingMaterial");
PSString._add("3DPrintRaftMaterial", "k3DPrintRaftMaterial");
PSString._add("3DPrintRaftOn", "k3DPrintRaftOn");
PSString._add("3DPrintScaffoldingOn", "k3DPrintScaffoldingOn");
PSString._add("3DPrintSupportsOn", "k3DPrintSupportsOn");
PSString._add("3DHeatPlateOn", "k3DHeatPlateOn");
PSString._add("3DSurfaceDetailOn", "k3DSurfaceDetailOn");
PSString._add("3DAllowBumpsOn", "k3DAllowBumpsOn");
PSString._add("3DAllowNormalsOn", "k3DAllowNormalsOn");
PSString._add("3DSelectedNozzle", "k3DSelectedNozzle");
PSString._add("3DPrinterVolumeOn", "k3DPrinterVolumeOn");
PSString._add("3DShellThickness", "k3DShellThickness");
PSString._add("3DCreateShell", "k3DCreateShell");
PSString._add("3DPrintSetProperties", "setPrint3DProperties");
PSString._add("3DInstallTorus", "installTorus");
PSString._add("3DSceneProperties", "scene3DProperties");
PSString._add("3DPrintUtilities", "print3DUtilities");
PSString._add("3DPrintLastSuccessfulConnection", "print3DLastSuccessfulConnection");
PSString._add("3DRibbonEffect");
PSString._add("3DTransform");
PSString._add("3DTransformObject", "transform3DObject");
PSString._add("3DSetCamera", "set3DCamera");
PSString._add("3DSetObjectPosition", "set3DObjectPosition");
PSString._add("3DSetCrossSection", "set3DCrossSection");
PSString._add("3DBakeCrossSection", "bake3DCrossSection");
PSString._add("3DBakeForPrinting", "bakeFor3DPrinting");
PSString._add("3DUploadToSketchFab", "upload3DToSketchFab");
PSString._add("3DSetLightMode", "set3DLightMode");
PSString._add("3DSetRenderMode", "set3DRenderMode");
PSString._add("3DSetEngine", "set3DEngine");
PSString._add("3DSetPaintType", "set3DPaintType");
PSString._add("3DSetTransferFunction", "set3DTransferFunction");
PSString._add("3DAdd3DView", "add3DView");
PSString._add("3DDelete3DView", "delete3DView");
PSString._add("3DAdd3DObjectPosition", "add3DObjectPosition");
PSString._add("3DDelete3DObjectPosition", "delete3DObjectPosition");
PSString._add("3DSetLightSwitch", "set3DLightSwitch");
PSString._add("3DSetLightPosition", "set3DLightPosition");
PSString._add("3DSetLightDirection", "set3DLightDirection");
PSString._add("3DSetLightType", "set3DLightType");
PSString._add("3DSetLightColor", "set3DLightColor");
PSString._add("3DSetLightHotspotAngle", "set3DLightHotspotAngle");
PSString._add("3DSetLightFalloffAngle", "set3DLightFalloffAngle");
PSString._add("3DSetLightInnerRadius", "set3DLightInnerRadius");
PSString._add("3DSetLightOuterRadius", "set3DLightOuterRadius");
PSString._add("3DSetLightIntensity", "set3DLightIntensity");
PSString._add("3DSetLightCastsShadowsSwitch", "set3DLightCastsShadowsSwitch");
PSString._add("3DSetLightAttenuationSwitch", "set3DLightAttenuationSwitch");
PSString._add("3DSetLightAttenuationType", "set3DLightAttenuationType");
PSString._add("3DSetLightAttenuationCoeff", "set3DLightAttenuationCoeff");
PSString._add("3DSetLightPointAtOrigin", "set3DLightPointAtOrigin");
PSString._add("3DSetLightMoveToCurrView", "set3DLightMoveToCurrView");
PSString._add("3DSetLightSoftShadows", "set3DLightSoftShadows");
PSString._add("3DSetMeshPosition", "set3DMeshPosition");
PSString._add("3DSetGroupPosition", "set3DGroupPosition");
PSString._add("3DSceneToGroup", "sceneToGroup");
PSString._add("3DAlignEdges", "set3DMeshAlignmentEdges");
PSString._add("3DAlignCenters", "set3DMeshAlignmentCenters");
PSString._add("3DDistribute", "set3DMeshDistribution");
PSString._add("3DSetMeshDirection", "set3DMeshDirection");
PSString._add("3DSetMeshSwitch", "set3DMeshSwitch");
PSString._add("3DSetMeshGroupSwitch", "set3DMeshGroupSwitch");
PSString._add("3DSetGroupSwitch", "set3DGroupSwitch");
PSString._add("3DSetMeshShadowCatcher", "set3DMeshShadowCatcher");
PSString._add("3DSetMeshShadowOpacity", "set3DMeshShadowOpacity");
PSString._add("3DSetMeshShadowCasting", "set3DMeshShadowCasting");
PSString._add("3DSetMeshShadowInvisible", "set3DMeshShadowInvisible");
PSString._add("3DSetMaterialSwitch", "set3DMaterialSwitch");
PSString._add("3DSetMaterialScalar", "set3DMaterialScalar");
PSString._add("3DSetMaterialColor", "set3DMaterialColor");
PSString._add("3DSetMaterialColors", "set3DMaterialColors");
PSString._add("3DSetMaterialTexturePath", "set3DMaterialTexturePath");
PSString._add("3DSetMaterialTextureInfo", "set3DMaterialTextureInfo");
PSString._add("3DSetPaintFalloff", "set3DPaintFalloff");
PSString._add("3DHideAllSurfaces", "hideAll3DSelected");
PSString._add("3DHideTopSurface", "hideTop3DSelected");
PSString._add("3DHideEnclosedOnly", "hide3DEnclosedOnly");
PSString._add("3DRevealAll", "revealAll3D");
PSString._add("3DInvertVisible", "invert3DSelected");
PSString._add("3DPaintTypeDiffuse", "paint3DDiffuse");
PSString._add("3DPaintTypeEnvironment", "paint3DEnvironment");
PSString._add("3DPaintTypeBump", "paint3DBump");
PSString._add("3DPaintTypeSpecular", "paint3DSpecular");
PSString._add("3DPaintTypeOpacity", "paint3DOpacity");
PSString._add("3DPaintTypeShininess", "paint3DShininess");
PSString._add("3DPaintTypeSelfIllumination", "paint3DSelfIllumination");
PSString._add("3DPaintTypeReflection", "paint3DReflection");
PSString._add("3DPaintTypeNormal", "paint3DNormal");
PSString._add("3DPaintTypeCustom", "paint3DCustom");
PSString._add("3DRenderSettings", "renderSettings3D");
PSString._add("3DToggleGroundPlaneShadowCatcher", "toggleGroundPlaneShadowCatcher");
PSString._add("3DSimplifyMesh", "simplify3DModel");
PSString._add("3DReparameterizeModel", "reparameterize3DModel");
PSString._add("3DMergeMaterials", "merge3DMaterials");
PSString._add("3DRepairModel", "repair3DModel");
PSString._add("3DRotateObjectTool", "3DObjectRotateTool");
PSString._add("3DRollObjectTool", "3DObjectRollTool");
PSString._add("3DPanObjectTool", "3DObjectPanTool");
PSString._add("3DSlideObjectTool", "3DObjectSlideTool");
PSString._add("3DScaleObjectTool", "3DObjectScaleTool");
PSString._add("3DRotateMeshTool", "3DMeshRotateTool");
PSString._add("3DRollMeshTool", "3DMeshRollTool");
PSString._add("3DPanMeshTool", "3DMeshPanTool");
PSString._add("3DSlideMeshTool", "3DMeshSlideTool");
PSString._add("3DScaleMeshTool", "3DMeshScaleTool");
PSString._add("3DRotateConstraintTool", "3DConstraintRotateTool");
PSString._add("3DRollConstraintTool", "3DConstraintRollTool");
PSString._add("3DPanConstraintTool", "3DConstraintPanTool");
PSString._add("3DSlideConstraintTool", "3DConstraintSlideTool");
PSString._add("3DScaleConstraintTool", "3DConstraintScaleTool");
PSString._add("3DSelectMaterialTool", "3DMaterialSelectTool");
PSString._add("3DPickMaterialTool", "3DMaterialPickTool");
PSString._add("3DDroptMaterialTool", "3DMaterialDropTool");
PSString._add("3DRotateLightTool", "3DLightRotateTool");
PSString._add("3DRollLightTool", "3DLightRollTool");
PSString._add("3DPanLightTool", "3DLightPanTool");
PSString._add("3DSlideLightTool", "3DLightSlideTool");
PSString._add("3DOrbitCameraTool");
PSString._add("3DRollCameraTool");
PSString._add("3DPanCameraTool");
PSString._add("3DWalkCameraTool");
PSString._add("3DFOVTool");
PSString._add("3DPanelKey");
PSString._add("3DFromDepthPlane", "create3DFromDepthPlane");
PSString._add("3DFromDepthTwoSidedPlane", "create3DFromDepthTwoSidedPlane");
PSString._add("3DFromDepthCylinder", "create3DFromDepthCylinder");
PSString._add("3DFromDepthSphere", "create3DFromDepthSphere");
PSString._add("3DFromRepousseText", "create3DFromRepousseText");
PSString._add("3DFromRepousseWorkPath", "create3DFromRepousseWorkPath");
PSString._add("3DFromRepousseSheetMask", "create3DFromRepousseSheetMask");
PSString._add("3DFromRepousseAISO", "create3DFromRepousseAISO");
PSString._add("3DFromRepousseSelection", "create3DFromRepousseSelection");
PSString._add("3DFromRGBD", "create3DFromRGBD");
PSString._add("3DRepousseConstraintFromWorkPath", "createConstraintFromWorkPath");
PSString._add("3DRepousseConstraintFromSelection", "createConstraintFromSelection");
PSString._add("3DRepousseObject", "repousseObject");
PSString._add("3DRepousseInflationSide", "repousseInflationSide");
PSString._add("3DRepousseBevelSide", "repousseBevelSide");
PSString._add("3DRepousseInflationHeight", "repousseInflationHeight");
PSString._add("3DRepousseInflationAngle", "repousseInflationAngle");
PSString._add("3DRepousseBevelWidth", "repousseBevelWidth");
PSString._add("3DRepousseBevelAngle", "repousseBevelAngle");
PSString._add("3DRepousseBevelCountour", "repousseBevelCountour");
PSString._add("3DRepousseExtrusionHeight", "repousseExtrusionHeight");
PSString._add("3DRepousseExtrusionXAngle", "repousseExtrusionXAngle");
PSString._add("3DRepousseExtrusionYAngle", "repousseExtrusionYAngle");
PSString._add("3DRepousseExtrusionXYAngle", "repousseExtrusionXYAngle");
PSString._add("3DRepousseExtrusionScale", "repousseExtrusionScale");
PSString._add("3DRepousseExtrusionTwist", "repousseExtrusionTwist");
PSString._add("3DRepousseExtrusionOrigin", "repousseExtrusionOrigin");
PSString._add("3DRepousseExtrusionTextureType", "repousseExtrusionTextureType");
PSString._add("3DRepousseExtrusionShear", "repousseExtrusionShear");
PSString._add("3DRepousseMeshQuality", "repousseMeshQuality");
PSString._add("3DRepousseConstraintType", "repousseConstraintType");
PSString._add("3DRepousseConstraintHeight", "repousseConstraintHeight");
PSString._add("3DRepousseConstraintAngle", "repousseConstraintAngle");
PSString._add("3DRepousseConstraintSide", "repousseConstraintSide");
PSString._add("3DRepousseConstraintDelete", "repousseConstraintDelete");
PSString._add("3DRepousseConstraintHome", "repousseConstraintHome");
PSString._add("3DRepousseConstraintPosition", "repousseConstraintPosition");
PSString._add("3DRepoussePreset", "repoussePreset");
PSString._add("3DRepousseNewPaths", "repousseNewPaths");
PSString._add("3DRepousseLoadPreset", "repousseLoadPresets");
PSString._add("3DRepousseReplacePreset", "repousseReplacePresets");
PSString._add("3DSaveRepoussePreset");
PSString._add("3DNewRepoussePreset", "New3DRepoussePreset");
PSString._add("3DSaveRepoussePresets", "Save3DRepoussePresets");
PSString._add("3DDeleteRepoussePreset", "Delete3DRepoussePreset");
PSString._add("3DDeleteAllRepoussePresets", "DeleteAll3DRepoussePresets");
PSString._add("3DRestoreRepoussePresets", "Restore3DRepoussePresets");
PSString._add("3DRenameRepoussePreset", "Rename3DRepoussePresets");
PSString._add("3DSet3DVisibility", "objectVisibilitySwitch");
PSString._add("3DDeleteObj", "objectDelete");
PSString._add("3DGroupObj", "objectGroup");
PSString._add("3DReorderObj", "objectReorder");
PSString._add("3DBakeObj", "objectBake");
PSString._add("3DReplaceMeshObj", "replaceMesh");
PSString._add("3DSetMaterialVisibleSwitch", "materialSwitch");
PSString._add("3DUnGroupObj", "objectUnGroup");
PSString._add("3DInstanceObj", "objectInstance");
PSString._add("3DReplicateObj", "objectReplicate");
PSString._add("3DNewObj", "objectNew");
PSString._add("3DNewSceneObj", "objectSceneNew");
PSString._add("3DNewSceneFileObj", "objectSceneNewFile");
PSString._add("3DRenameObj", "objectRename");
PSString._add("3DAddLightsFromPreset", "add3DLightsFromPreset");
PSString._add("3DDeleteLightsPreset", "delete3DLightsPreset");
PSString._add("3DAddPathToRepousse", "addPathToRepousse");
PSString._add("3DDropToGroundPlane", "dropTo3DGroundPlane");
PSString._add("3DPackToGroundPlane", "packTo3DGroundPlane");
PSString._add("3DReplaceLightsFromPreset", "replace3DLightsFromPreset");
PSString._add("3DReplaceMaterialFromPreset", "replace3DMaterialFromPreset");
PSString._add("3DSaveLightsToPreset", "save3DLightsToPreset");
PSString._add("3DSelectPaintable", "select3DPaintable");
PSString._add("3DProjectionPaintToggle", "projectionPaintToggle");
PSString._add("3DBrowseOnline", "browse3DOnline");
PSString._add("3DAutoHideLayers", "autoHide3D");
PSString._add("3DToggleGroundPlane");
PSString._add("3DToggleLightGuides");
PSString._add("3DNewPointLight");
PSString._add("3DNewSpotLight");
PSString._add("3DNewInfiniteLight");
PSString._add("3DNewImageBasedLight");
PSString._add("3DAddLights");
PSString._add("3DReplaceLights");
PSString._add("3DSaveLightPreset");
PSString._add("3DDeleteLight");
PSString._add("3DAddObjects");
PSString._add("3DDeleteObjects");
PSString._add("3DDuplicateObjects");
PSString._add("3DInstanceObjects");
PSString._add("3DGroupUngroupObjects");
PSString._add("3DReorderObjects");
PSString._add("3DAddMeshObject", "3DAddMesh");
PSString._add("3DAddMeshPreset");
PSString._add("3DAddFromFile");
PSString._add("3DSelectInstances", "select3DInstances");
PSString._add("3DSelectReference", "select3DReference");
PSString._add("3DreferenceObjectName", "ref3DObjectName");
PSString._add("3DinstancesObjectName", "instance3DObjectName");
PSString._add("3DcenterObjectName", "center3DObjectName");
PSString._add("3DCenterMesh", "center3DMesh");
PSString._add("3DReplaceMaterial");
PSString._add("3DSaveMaterialPreset");
PSString._add("3DNewMaterialPreset", "New3DMaterialPreset");
PSString._add("3DSaveMaterialPresets", "Save3DMaterialPresets");
PSString._add("3DLoadMaterialPresets", "Load3DMaterialPresets");
PSString._add("3DReplaceMaterialPresets", "Replace3DMaterialPresets");
PSString._add("3DDeleteMaterialPreset", "Delete3DMaterialPreset");
PSString._add("3DDeleteAllMaterialPresets", "DeleteAll3DMaterialPresets");
PSString._add("3DRestoreMaterialPresets", "Restore3DMaterialPresets");
PSString._add("3DRenameMaterialPreset", "Rename3DMaterialPresets");
PSString._add("3DSetPrintScale", "set3DPrintScale");
PSString._add("3DLUTFileData", "LUT3DFileData");
PSString._add("3DLUTFileName", "LUT3DFileName");
PSString._add("3DLUT");
PSString._add("3DObjectPlace", "3dobject");
PSString._add("3DPrefDropToGL", "Z3DPrefDropToGL");
PSString._add("3DPrefGLDirectToScreen", "Z3DPrefGLDirectToScreen");
PSString._add("3DPrefGLAutoHideLayers", "Z3DPrefGLAutoHideLayers");
PSString._add("3DPrefARTUseShadows", "Z3DPrefARTUseShadows");
PSString._add("3DPrefARTUseRefractions", "Z3DPrefARTUseRefractions");
PSString._add("3DPrefARTUseReflections", "Z3DPrefARTUseReflections");
PSString._add("3DPrefColorMeshSelection", "Z3DPrefColorMeshSelection");
PSString._add("3DPrefColorMaterialSelection", "Z3DPrefColorMaterialSelection");
PSString._add("3DPrefColorLightsourceSelection", "Z3DPrefColorLightsourceSelection");
PSString._add("3DPrefColorLightsourceDisplay", "Z3DPrefColorLightsourceDisplay");
PSString._add("3DPrefColorConstraintSelection", "Z3DPrefColorConstraintSelection");
PSString._add("3DPrefColorConstraintDisplay", "Z3DPrefColorConstraintDisplay");
PSString._add("3DPrefColorProgressiveRenderingTilesDisplay", "Z3DPrefColorProgressiveRenderingTilesDisplay");
PSString._add("3DPrefColorGroundPlaneDisplay", "Z3DPrefColorGroundPlaneDisplay");
PSString._add("3DPrefColorUVOverlayDisplay", "Z3DPrefColorUVOverlayDisplay");
PSString._add("3DPrefUVOverlayVisible", "Z3DPrefUVOverlayVisible");
PSString._add("3DPrefUVOverlayOpacity", "Z3DPrefUVOverlayOpacity");
PSString._add("3DPrefGroundPlaneSpacing", "Z3DPrefGroundPlaneSize");
PSString._add("3DPrefGroundPlaneSize", "Z3DPrefGroundPlaneSpacing");
PSString._add("3DPrefHighQualityErrorThreshold", "Z3DPrefHighQualityErrorThreshold");
PSString._add("3DPrefDrawProgressiveRenderingOverlay", "Z3DPrefDrawProgressiveRenderingOverlay");
PSString._add("3DPrefOnCanvasAxisWidgetScale", "Z3DPrefOnCanvasAxisWidgetScale");
PSString._add("3DPrefFileLoadingLightThreshold", "Z3DPrefFileLoadingLightThreshold");
PSString._add("3DPrefFileLoadingTextureThreshold", "Z3DPrefFileLoadingTextureThreshold");
PSString._add("3DPrefShowRichCursorsOnHover", "Z3DPrefShowRichCursorsOnHover");
PSString._add("3DPrefShowRichCursorsOnInteraction", "Z3DPrefShowRichCursorsOnInteraction");
PSString._add("3DPrefInvertCameraControlYAxis", "Z3DPrefInvertCameraControlYAxis");
PSString._add("3DPrefHideAxisWidgetControlsDependingOnCurrent3DTool", "Z3DPrefHideAxisWidgetControlsDependingOnCurrent3DTool");
PSString._add("3DPrefShowLightingEffectsControlsOnTheGroundPlane", "Z3DPrefShowLightingEffectsControlsOnTheGroundPlane");
PSString._add("3DPrefProjectionPaintingOn", "Z3DPrefProjectionPaintingOn");
PSString._add("3DPrefLastUsed3DUnits", "Z3DPrefLastUsed3DUnits");
PSString._add("3DShowDimensionsOnRegular3DOverlays", "Z3DShowDimensionsOnRegular3DOverlays");
PSString._add("3DShowFaceRepairColorIn3DPrintPreview", "Z3DShowFaceRepairColorIn3DPrintPreview");
PSString._add("3DUseRaytracingIn3DPrintPreview", "Z3DUseRaytracingIn3DPrintPreview");
PSString._add("3upHorizontal");
PSString._add("3upStacked");
PSString._add("3upVertical");
PSString._add("4BitsPerPixel");
PSString._add("4upTile");
PSString._add("5000");
PSString._add("5500");
PSString._add("6500");
PSString._add("6upTile");
PSString._add("72Color");
PSString._add("72Gray");
PSString._add("7500");
PSString._add("8BitsPerPixel");
PSString._add("9300");
PSString._add("Acrobat3dEngineEnabled", "acrobat3dEnabled");
PSString._add("addAudioClipsToTimeline");
PSString._add("addClipsToTimeline");
PSString._add("AddLayerFromFile", "addLayerFromFile");
PSString._add("AddLayerFromViewlessDoc", "addLayerFromViewlessDoc");
PSString._add("AddStrokeToRecording", "addStrokeToRecording");
PSString._add("addTimelineTransition");
PSString._add("AdobePSLTest");
PSString._add("ADSBottoms");
PSString._add("ADSCentersH");
PSString._add("ADSCentersV");
PSString._add("ADSContent");
PSString._add("ADSHorizontal");
PSString._add("ADSLefts");
PSString._add("ADSRights");
PSString._add("ADSTops");
PSString._add("ADSVertical");
PSString._add("advanced");
PSString._add("AEList");
PSString._add("AERecord");
PSString._add("agmVectorSheet");
PSString._add("agmVectorSheetClass");
PSString._add("AGMStrokeStyleInfo");
PSString._add("AGMStrokeStyleInfoClass", "CAGMStrokeStyleInfo");
PSString._add("AOLPreferences");
PSString._add("AppBar", "appBar");
PSString._add("AppContainer", "appContainer");
PSString._add("applicationPreferences");
PSString._add("ASCII85");
PSString._add("ASCII");
PSString._add("AntialiasGloss", "antialiasGloss");
PSString._add("artboards");
PSString._add("artboardList");
PSString._add("artboardTool");
PSString._add("artSprayerTool");
PSString._add("audioFadeList");
PSString._add("audioLevel");
PSString._add("autoCanvasResizeShift");
PSString._add("autoFill");
PSString._add("autoClean");
PSString._add("average");
PSString._add("bengaliIndiaLanguage");
PSString._add("BevelContour", "bevelContour");
PSString._add("BevelContourBack", "bevelContourBack");
PSString._add("BevelHeight", "bevelHeight");
PSString._add("BevelHeightBack", "bevelHeightBack");
PSString._add("BevelWidth", "bevelWidth");
PSString._add("BevelWidthBack", "bevelWidthBack");
PSString._add("blackAndWhiteTool");
PSString._add("blackDissolve");
PSString._add("blackPointTool");
PSString._add("brushPoseLock");
PSString._add("DefaultBrushPoseAngle", "brushPoseAngle");
PSString._add("DefaultBrushPoseTiltX", "brushPoseTiltX");
PSString._add("DefaultBrushPoseTiltY", "brushPoseTiltY");
PSString._add("DefaultBrushPosePressure", "brushPosePressure");
PSString._add("cache");
PSString._add("cameraRaw");
PSString._add("cameraRawJPEG");
PSString._add("cameraRawPrefs");
PSString._add("centimetersUnit");
PSString._add("CIERGB");
PSString._add("CineonHalf");
PSString._add("CineonFull");
PSString._add("ClassCustomHSFPair", "classCustomHSFPair");
PSString._add("clockDir");
PSString._add("clockwise");
PSString._add("CloseActionsPanel", "closeActionsPanel");
PSString._add("CloseAdjustmentsPanel", "closeAdjustmentsPanel");
PSString._add("CloseAnimationPanel", "closeAnimationPanel");
PSString._add("CloseBrushesPanel", "closeBrushesPanel");
PSString._add("CloseBrushPresetsPanel", "closeBrushPresetsPanel");
PSString._add("CloseChannelsPanel", "closeChannelsPanel");
PSString._add("CloseCharacterPanel", "closeCharacterPanel");
PSString._add("CloseCharacterStylesPanel", "closeCharacterStylesPanel");
PSString._add("CloseCloneSourcePanel", "closeCloneSourcePanel");
PSString._add("CloseColorPanel", "closeColorPanel");
PSString._add("CloseHistogramPanel", "closeHistogramPanel");
PSString._add("CloseHistoryPanel", "closeHistoryPanel");
PSString._add("CloseInfoPanel", "closeInfoPanel");
PSString._add("CloseLayerCompsPanel", "closeLayerCompsPanel");
PSString._add("CloseLayersPanel", "closeLayersPanel");
PSString._add("CloseMaskPanel", "closeMaskPanel");
PSString._add("CloseMeasurementPanel", "closeMeasurementPanel");
PSString._add("CloseNavigatorPanel", "closeNavigatorPanel");
PSString._add("CloseParagraphPanel", "closeParagraphPanel");
PSString._add("CloseParagraphStylesPanel", "closeParagraphStylesPanel");
PSString._add("ClosePathsPanel", "closePathsPanel");
PSString._add("CloseStylesPanel", "closeStylesPanel");
PSString._add("CloseSwatchesPanel", "closeSwatchesPanel");
PSString._add("CloseTimelinePanel", "closeTimelinePanel");
PSString._add("CloseToolPresetsPanel", "closeToolPresetsPanel");
PSString._add("Close3DPanel", "close3DPanel");
PSString._add("ClosePropertiesPanel", "closePropertiesPanel");
PSString._add("CloseCreatePanel", "closeCreatePanel");
PSString._add("CloseActionsPanelGroup", "closeActionsPanelGroup");
PSString._add("CloseAdjustmentsPanelGroup", "closeAdjustmentsPanelGroup");
PSString._add("CloseAnimationPanelGroup", "closeAnimationPanelGroup");
PSString._add("CloseBrushesPanelGroup", "closeBrushesPanelGroup");
PSString._add("CloseBrushPresetsPanelGroup", "closeBrushPresetsPanelGroup");
PSString._add("CloseChannelsPanelGroup", "closeChannelsPanelGroup");
PSString._add("CloseCharacterPanelGroup", "closeCharacterPanelGroup");
PSString._add("CloseCharacterStylesPanelGroup", "closeCharacterStylesPanelGroup");
PSString._add("CloseCloneSourcePanelGroup", "closeCloneSourcePanelGroup");
PSString._add("CloseColorPanelGroup", "closeColorPanelGroup");
PSString._add("CloseHistogramPanelGroup", "closeHistogramPanelGroup");
PSString._add("CloseHistoryPanelGroup", "closeHistoryPanelGroup");
PSString._add("CloseInfoPanelGroup", "closeInfoPanelGroup");
PSString._add("CloseLayerCompsPanelGroup", "closeLayerCompsPanelGroup");
PSString._add("CloseLayersPanelGroup", "closeLayersPanelGroup");
PSString._add("CloseMaskPanelGroup", "closeMaskPanelGroup");
PSString._add("CloseMeasurementPanelGroup", "closeMeasurementPanelGroup");
PSString._add("CloseNavigatorPanelGroup", "closeNavigatorPanelGroup");
PSString._add("CloseParagraphPanelGroup", "closeParagraphPanelGroup");
PSString._add("CloseParagraphStylesPanelGroup", "closeParagraphStylesPanelGroup");
PSString._add("ClosePathsPanelGroup", "closePathsPanelGroup");
PSString._add("CloseStylesPanelGroup", "closeStylesPanelGroup");
PSString._add("CloseSwatchesPanelGroup", "closeSwatchesPanelGroup");
PSString._add("CloseTimelinePanelGroup", "closeTimelinePanelGroup");
PSString._add("CloseToolPresetsPanelGroup", "closeToolPresetsPanelGroup");
PSString._add("CloseViewlessDocument", "closeViewlessDocument");
PSString._add("Close3DPanelGroup", "close3DPanelGroup");
PSString._add("ClosePropertiesPanelGroup", "closePropertiesPanelGroup");
PSString._add("CloseCreatePanelGroup", "closeCreatePanelGroup");
PSString._add("CMYK64");
PSString._add("CMYKColorClass");
PSString._add("CMYKColorEnum");
PSString._add("CMYKColorMode");
PSString._add("CMYKSetupEngine");
PSString._add("CMYKSetup");
PSString._add("CMYKSpectrum");
PSString._add("CMYK");
PSString._add("colCount");
PSString._add("colWidth");
PSString._add("colGutter");
PSString._add("colorModel");
PSString._add("color2Gray");
PSString._add("colorLookup");
PSString._add("patchColorAdaptation");
PSString._add("columnsUnit");
PSString._add("ContourCustom", "shapeCurveCustom");
PSString._add("ContourDouble", "shapeCurveDouble");
PSString._add("ContourGaussian", "shapeCurveGaussian");
PSString._add("ContourLinear", "shapeCurveLinear");
PSString._add("ContourSingle", "shapeCurveSingle");
PSString._add("Contour", "shapingCurve");
PSString._add("Contour2", "shapingCurve2");
PSString._add("ContourTriple", "shapeCurveTriple");
PSString._add("ContourType", "shapeCurveType");
PSString._add("counterclockwise");
PSString._add("curvesTool");
PSString._add("CustomHSFIsStd", "customHSFIsStd");
PSString._add("CustomHSFList", "customHSFList");
PSString._add("CustomHSFName", "customHSFName");
PSString._add("CustomHSFValue", "customHSFValue");
PSString._add("deepMonitor");
PSString._add("DCS");
PSString._add("DICOMFormat", "Dicom");
PSString._add("dryout", "dryness");
PSString._add("DSEncodingAuto", "dataSetEncodingAuto");
PSString._add("DSEncodingISOLatin1", "dataSetEncodingISOLatin1");
PSString._add("DSEncodingMacRoman", "dataSetEncodingMacRoman");
PSString._add("DSEncodingUTF8", "dataSetEncodingUTF8");
PSString._add("DSEncodingUTF16", "dataSetEncodingUTF16");
PSString._add("DSEncodingNative", "dataSetEncodingNative");
PSString._add("dtipsType");
PSString._add("dtipsLengthRatio");
PSString._add("dtipsHardness");
PSString._add("dtipsGridSize");
PSString._add("dtipsErodibleTipHeightMap");
PSString._add("dtipsErodibleTipCustomized");
PSString._add("dtipsAirbrushCutoffAngle");
PSString._add("dtipsAirbrushGranularity");
PSString._add("dtipsAirbrushStreakiness");
PSString._add("dtipsAirbrushSplatSize");
PSString._add("dtipsAirbrushSplatCount");
PSString._add("EPSGenericFormat");
PSString._add("EPSPICTPreview");
PSString._add("EPSPreview");
PSString._add("EPSTIFFPreview");
PSString._add("eraseAll");
PSString._add("EXIF");
PSString._add("externalConstraints");
PSString._add("ExtrusionHeight", "extrusionHeight");
PSString._add("ExtrusionXAngle", "extrusionXAngle");
PSString._add("ExtrusionYAngle", "extrusionYAngle");
PSString._add("ExtrusionScale", "extrusionScale");
PSString._add("ExtrusionTwist", "extrusionTwist");
PSString._add("ExtrusionShear", "extrusionShear");
PSString._add("ExtrusionOrigin", "extrusionOrigin");
PSString._add("FileAutoSaveEnabled", "fileAutoSaveEnabled");
PSString._add("FileAutoSaveInterval", "fileAutoSaveInterval");
PSString._add("FileBrowserBackgroundProcessing");
PSString._add("FileBrowserCacheSizeLimit");
PSString._add("FileBrowserCustomThumbSize");
PSString._add("FileBrowserFileSizeLimit");
PSString._add("FileBrowserHighQualityPreview");
PSString._add("FileBrowserMaintainSidecarFiles");
PSString._add("FileBrowserParseNonImageXMPMetadata");
PSString._add("FileBrowserParseVectorFiles");
PSString._add("FileBrowserPrefsClass");
PSString._add("FileBrowserPrefsEnum");
PSString._add("FileBrowserPrefsKey");
PSString._add("FileFormats");
PSString._add("FileSaveToOriginalFolder");
PSString._add("FileSaveInBackground", "fileSaveInBackground");
PSString._add("Film2k");
PSString._add("Film4k");
PSString._add("FPXCompressLossyJPEG");
PSString._add("FPXCompressNone");
PSString._add("FPXCompress");
PSString._add("FPXQuality");
PSString._add("FPXSize");
PSString._add("FPXView");
PSString._add("FSS");
PSString._add("FourDigit", "fourDigit");
PSString._add("GCR");
PSString._add("GetTransforms", "getTransforms");
PSString._add("GIF89aExport");
PSString._add("GIFColorFileColorTable");
PSString._add("GIFColorFileColors");
PSString._add("GIFColorFileMicrosoftPalette");
PSString._add("GIFColorFileType");
PSString._add("GIFColorLimit");
PSString._add("GIFExportCaption");
PSString._add("GIFFormat");
PSString._add("GIFMaskChannelIndex");
PSString._add("GIFMaskChannelInverted");
PSString._add("GIFPaletteAdaptive");
PSString._add("GIFPaletteExact");
PSString._add("GIFPaletteFile");
PSString._add("GIFPaletteOther");
PSString._add("GIFPaletteSystem");
PSString._add("GIFPaletteType");
PSString._add("GIFRequiredColorSpaceIndexed");
PSString._add("GIFRequiredColorSpaceRGB");
PSString._add("GIFRequiredColorSpaceType");
PSString._add("GIFRowOrderInterlaced");
PSString._add("GIFRowOrderNormal");
PSString._add("GIFRowOrderType");
PSString._add("GIFTransparentColor");
PSString._add("GIFTransparentIndexBlue");
PSString._add("GIFTransparentIndexGreen");
PSString._add("GIFTransparentIndexRed");
PSString._add("GIFUseBestMatch");
PSString._add("GlobalSyncEnable");
PSString._add("GPUEnabled", "gpuEnabled");
PSString._add("OpenGLACEEnabled", "openglACEEnabled");
PSString._add("OpenGLAdvAntiAliasEnabled", "openglAdvAntiAliasEnabled");
PSString._add("OpenGLAdvDTSEnabled", "openglAdvDTSEnabled");
PSString._add("OpenGLAdvImageEnabled", "openglAdvImageEnabled");
PSString._add("OpenGLAdvancedEnabled", "glAdvancedEnabled");
PSString._add("OpenGLAdvanced", "openglAdvanced");
PSString._add("OpenGLAllowed", "openglAllowed");
PSString._add("OpenGLAutoTune", "autoTune");
PSString._add("OpenGLBilerpEnabled", "openglBilerpEnabled");
PSString._add("OpenGLCheckCompEnum", "gpuCheckerComposite");
PSString._add("OpenGLCheckComp", "openglCheckerComposite");
PSString._add("OpenGLD2SEnabled", "openglD2SEnabled");
PSString._add("OpenGLDeepColorEnabled", "openglDeepColorEnabled");
PSString._add("OpenGLEnabled", "openglEnabled");
PSString._add("OpenGLModeEnabled", "openglModeEnabled");
PSString._add("OpenGLModeEnum", "gpuMode");
PSString._add("OpenGLMode", "openglmode");
PSString._add("OpenGLPOTEnabled", "openglPOTEnabled");
PSString._add("OpenGLReset", "openglReset");
PSString._add("OpenGLSimpleTextUploadsEnabled", "openglSimpleTextUploadsEnabled");
PSString._add("OpenGLTuneSize", "openglTunedSize");
PSString._add("OpenGLVBLSyncEnabled", "openglVBLSyncEnabled");
PSString._add("OpenGLVBLSyncChangeable", "openglVBLSyncChangeable");
PSString._add("OpenViewlessDocument", "openViewlessDocument");
PSString._add("OverrideBrushPoseAngle", "overridePoseAngle");
PSString._add("OverrideBrushPoseTiltX", "overridePoseTiltX");
PSString._add("OverrideBrushPoseTiltY", "overridePoseTiltY");
PSString._add("OverrideBrushPosePressure", "overridePosePressure");
PSString._add("OverscrollMode", "overscrollMode");
PSString._add("overscrollEnabled");
PSString._add("PhotoshopCrashed");
PSString._add("HDTV");
PSString._add("HDTV1080p");
PSString._add("HDVHDTV720p");
PSString._add("HDV1080p");
PSString._add("HSBColorClass");
PSString._add("HSBColorEnum");
PSString._add("HSBColorMode");
PSString._add("HSLColor");
PSString._add("IBMPC");
PSString._add("ICCEngine");
PSString._add("ICCSetupName");
PSString._add("ICC");
PSString._add("ID");
PSString._add("IEEE32BitFloatingPoint");
PSString._add("IEEE64BitFloatingPoint");
PSString._add("internalConstraints");
PSString._add("JIS78Form");
PSString._add("JIS83Form");
PSString._add("JPEGFormat");
PSString._add("JPEGQuality");
PSString._add("JPEG");
PSString._add("JPEGTileExport");
PSString._add("JP2KThumb", "Growing Thumbnail");
PSString._add("JP2KProg", "Progressive");
PSString._add("JP2KColor", "Color");
PSString._add("JP2KFloat", "Float");
PSString._add("JP2KInteger", "Integer");
PSString._add("JP2KTile128", "128 x 128");
PSString._add("JP2KTile256", "256 x 256");
PSString._add("JP2KTile512", "512 x 512");
PSString._add("JP2KTile1024", "1024 x 1024");
PSString._add("lensCorrection");
PSString._add("JPSFormat", "JPS");
PSString._add("LUTAnimation");
PSString._add("LUTFormatType");
PSString._add("LUTFormatCUBE");
PSString._add("LUTFormat3DL");
PSString._add("LUTFormat3DLS");
PSString._add("LUTFormat1DLS");
PSString._add("LUTFormatLOOK");
PSString._add("LUTFormatCSP");
PSString._add("LZWCompression");
PSString._add("MPOFormat", "MPO");
PSString._add("MouseUp", "mouseUp");
PSString._add("NTSCColors");
PSString._add("NTSC");
PSString._add("ntsc");
PSString._add("ntscWide");
PSString._add("NTSCWidescreen");
PSString._add("OS2");
PSString._add("P22EBU");
PSString._add("PAL");
PSString._add("pal");
PSString._add("palWide");
PSString._add("PDFExport");
PSString._add("PDFGenericFormat");
PSString._add("PICTFileFormat");
PSString._add("PICTResourceFormat");
PSString._add("PNGFilterAdaptive");
PSString._add("PNGFilterAverage");
PSString._add("PNGFilterNone");
PSString._add("PNGFilterPaeth");
PSString._add("PNGFilter");
PSString._add("PNGFilterSub");
PSString._add("PNGFilterUp");
PSString._add("PNGFormat");
PSString._add("PNGInterlaceAdam7");
PSString._add("PNGInterlaceNone");
PSString._add("PNGInterlaceType");
PSString._add("PixelScaleFactor", "pixelScaleFactor");
PSString._add("PromptedForColorSetup", "promptedForColorSetup");
PSString._add("ProtectAll", "protectAll");
PSString._add("ProtectComposite", "protectComposite");
PSString._add("ProtectNone", "protectNone");
PSString._add("ProtectPosition", "protectPosition");
PSString._add("ProtectTransparency", "protectTransparency");
PSString._add("PSOpenFileDialog");
PSString._add("QCSAverage");
PSString._add("QCSCorner0");
PSString._add("QCSCorner1");
PSString._add("QCSCorner2");
PSString._add("QCSCorner3");
PSString._add("QCSIndependent");
PSString._add("QCSSide0");
PSString._add("QCSSide1");
PSString._add("QCSSide2");
PSString._add("QCSSide3");
PSString._add("QDRectangle");
PSString._add("RGB48");
PSString._add("RGBBlendGamma");
PSString._add("RGBColorMode");
PSString._add("RGBColor");
PSString._add("RGBFloatColor");
PSString._add("RGBSetupClass");
PSString._add("RGBSetupSource");
PSString._add("RGBSetup");
PSString._add("RGBSpectrum");
PSString._add("RGB");
PSString._add("RLE");
PSString._add("SMPTEC");
PSString._add("SnifferCrashes");
PSString._add("TextBlendGamma");
PSString._add("TIFFFormat");
PSString._add("TIFF");
PSString._add("time");
PSString._add("UCA");
PSString._add("URL");
PSString._add("UseFacesKey");
PSString._add("XMPMetadataAsUTF8");
PSString._add("ZoomView", "Zoomify");
PSString._add("a");
PSString._add("abbreviatedName");
PSString._add("aboutApp");
PSString._add("absColorimetric");
PSString._add("absolute");
PSString._add("abstractProfile");
PSString._add("accelerated");
PSString._add("accentedEdges");
PSString._add("actionData");
PSString._add("actionReference");
PSString._add("actionSet");
PSString._add("action");
PSString._add("actions");
PSString._add("activeFrameIndex");
PSString._add("activeFrameSetID");
PSString._add("activeViewChanged");
PSString._add("actualPixels");
PSString._add("view200Percent");
PSString._add("actualSample");
PSString._add("actualSize");
PSString._add("adaptationLoosest", "adaptationMostLoose");
PSString._add("adaptationVeryLoose");
PSString._add("adaptationLoose");
PSString._add("adaptationMedium");
PSString._add("adaptationStrict");
PSString._add("adaptationVeryStrict");
PSString._add("adaptationStrictest", "adaptationMostStrict");
PSString._add("adaptCorrect");
PSString._add("adaptive");
PSString._add("addFilterMaskToSelection");
PSString._add("addKeyframe");
PSString._add("addKnotTool");
PSString._add("addLayerTogroupByDrag");
PSString._add("addNoise");
PSString._add("add");
PSString._add("addBlankVideoLayer");
PSString._add("addTo");
PSString._add("addToSelection");
PSString._add("addToSelectionContinuous");
PSString._add("addVideoLayer");
PSString._add("addressAttr");
PSString._add("addUserMaskToSelection");
PSString._add("addVectorMaskToSelection");
PSString._add("adjustImage");
PSString._add("adjustmentAddMask");
PSString._add("adjustmentAutoOptions");
PSString._add("adjustmentClip");
PSString._add("adjustmentClose");
PSString._add("adjustmentCloseGroup");
PSString._add("adjustmentComposite");
PSString._add("adjustmentDeletePreset");
PSString._add("adjustmentAutoSelectParameter");
PSString._add("adjustmentSelectOnscreenAdjustor");
PSString._add("adjustmentLayer");
PSString._add("adjustmentLoad");
PSString._add("adjustmentLoadPreset");
PSString._add("adjustmentOptions");
PSString._add("adjustmentReset");
PSString._add("adjustmentSave");
PSString._add("adjustmentSavePreset");
PSString._add("adjustmentShowClipping");
PSString._add("adjustment");
PSString._add("adobeOnlineHome");
PSString._add("adobeOnlineRegistration");
PSString._add("adobeOnlineUpdates");
PSString._add("adobeRGB1998");
PSString._add("airbrushEraser");
PSString._add("airbrushTool");
PSString._add("alias");
PSString._add("alignByAscent");
PSString._add("alignByCapHeight");
PSString._add("alignByLeading");
PSString._add("alignByMinimumValueRoman");
PSString._add("alignByMinimumValueAsian");
PSString._add("alignByXHeight");
PSString._add("alignDistributeSelector");
PSString._add("align");
PSString._add("alignGroup");
PSString._add("aligned");
PSString._add("alignment");
PSString._add("alignmentType");
PSString._add("allCaps");
PSString._add("allEnum");
PSString._add("allExcept");
PSString._add("allMeasurements");
PSString._add("allSmallCaps");
PSString._add("all");
PSString._add("allToolOptions");
PSString._add("allowPasteFXOnLayerSet");
PSString._add("allowSystemShortcuts");
PSString._add("allowToolRecording");
PSString._add("allowUserModify");
PSString._add("alpha");
PSString._add("alphaChannelOptionsClass");
PSString._add("alphaChannelOptions");
PSString._add("alphaChannels");
PSString._add("alphaInterpretation");
PSString._add("altTag");
PSString._add("alternate");
PSString._add("alternateLigatures");
PSString._add("altligature");
PSString._add("ambientBrightness");
PSString._add("ambientColor");
PSString._add("amountHigh");
PSString._add("amountLow");
PSString._add("amountMedium");
PSString._add("amount");
PSString._add("amplitudeMax");
PSString._add("amplitudeMin");
PSString._add("anamorphic");
PSString._add("anchor");
PSString._add("anchorTime");
PSString._add("ancient");
PSString._add("angle1");
PSString._add("angle2");
PSString._add("angle3");
PSString._add("angle4");
PSString._add("angleDynamics");
PSString._add("angle");
PSString._add("angleUnit");
PSString._add("angledStrokes");
PSString._add("animate");
PSString._add("animationFrameActivate");
PSString._add("animationFrameClass");
PSString._add("animationFrameExtendSelection");
PSString._add("animationClass");
PSString._add("animationFrameList");
PSString._add("animationFrameDelay");
PSString._add("animationFrameReplace");
PSString._add("animationFrameReplaceType");
PSString._add("animationFrameReplaceDontDispose");
PSString._add("animationFrameReplaceDispose");
PSString._add("animationFrameReplaceAutoDispose");
PSString._add("animationFramesByDefault");
PSString._add("animationFramesContiguous");
PSString._add("animationFramesFromLayers");
PSString._add("animationFramesToLayers");
PSString._add("animationGoToNextFrame");
PSString._add("animationGoToPreviousFrame");
PSString._add("animationGoToFirstFrame");
PSString._add("animationGoToLastFrame");
PSString._add("animationPanelKey");
PSString._add("animationFXRefPoint");
PSString._add("animationImageMask");
PSString._add("animationKey");
PSString._add("animationLayerID");
PSString._add("animationLayerSettings");
PSString._add("animationLayerSpecific");
PSString._add("animationMakeAnimation");
PSString._add("animationMatchLayer");
PSString._add("animationMatchLayerPosition");
PSString._add("animationMatchLayerVisibility");
PSString._add("animationMatchLayerStyle");
PSString._add("animationNewLayerPerFrame");
PSString._add("animationOldLayerSpecific", "_LSpec");
PSString._add("animationOptionsAuto");
PSString._add("animationOptionsHide");
PSString._add("animationOptionsShow");
PSString._add("animationFrameIDList");
PSString._add("animationLoopCount");
PSString._add("animationLoopEnum");
PSString._add("animationLoopForever");
PSString._add("animationLoopOnce");
PSString._add("animationLoopType");
PSString._add("animationOptimize");
PSString._add("animationOptByBounds");
PSString._add("animationOptByPixelRemoval");
PSString._add("animationPaletteOptions");
PSString._add("animationPasteFrames");
PSString._add("animationPasteFramesMethod");
PSString._add("animationPasteFramesOver");
PSString._add("animationPasteFramesBefore");
PSString._add("animationPasteFramesAfter");
PSString._add("animationPasteFramesReplace");
PSString._add("animationPasteFramesLink");
PSString._add("animationPictSize");
PSString._add("animationPropagate");
PSString._add("animationProtection");
PSString._add("animationSelectAll");
PSString._add("animationShowNewLayersInFrames");
PSString._add("animationToFrame");
PSString._add("animationTween");
PSString._add("animationTweenWithNext");
PSString._add("animationTweenWithPrev");
PSString._add("animationTweenSel");
PSString._add("animationTweenAllLayers");
PSString._add("animationTweenSelLayers");
PSString._add("animationTweenNumFrames");
PSString._add("animationTweenPosition");
PSString._add("animationTweenOpacity");
PSString._add("animationTweenEffects");
PSString._add("animationUnifyPosition");
PSString._add("animationUnifyEffects");
PSString._add("animationUnifyVisibility");
PSString._add("animationVectorMask");
PSString._add("animationTrack");
PSString._add("animInterpStyle");
PSString._add("animKey");
PSString._add("animTransition");
PSString._add("animTransitionTypeID");
PSString._add("anisotropic");
PSString._add("annotSound");
PSString._add("annotText");
PSString._add("annotType");
PSString._add("annotUnknown");
PSString._add("annotation");
PSString._add("antiAliasCrisp");
PSString._add("antiAliasHigh");
PSString._add("antiAliasLow");
PSString._add("antiAliasMedium");
PSString._add("antiAliasNone");
PSString._add("antiAliasSharp");
PSString._add("antiAliasSmooth");
PSString._add("antiAlias");
PSString._add("antiAliasStrong");
PSString._add("antiAliasPlatformLCD");
PSString._add("antiAliasPlatformGray");
PSString._add("antiAliasType");
PSString._add("antiAliasedPICTAcquire");
PSString._add("any");
PSString._add("appParameters");
PSString._add("appendCopy");
PSString._add("append");
PSString._add("applSignature");
PSString._add("appleEvent");
PSString._add("appleRGB");
PSString._add("application");
PSString._add("applyComp");
PSString._add("applyImageEnum");
PSString._add("applyImageEvent");
PSString._add("applyimageStackPluginRenderer", "applyImageStackPluginRenderer");
PSString._add("applyLocking");
PSString._add("apply");
PSString._add("applyBrushFile");
PSString._add("applyStyle");
PSString._add("applyStyleFile");
PSString._add("areaSelector");
PSString._add("area");
PSString._add("aroundCenter");
PSString._add("arrange");
PSString._add("arrowhead");
PSString._add("artBox");
PSString._add("artBrushTool");
PSString._add("as");
PSString._add("ascenderAlignment");
PSString._add("askLayeredTIFF");
PSString._add("askMismatchOpening");
PSString._add("askMismatchPasting");
PSString._add("askMissing");
PSString._add("ask");
PSString._add("askWhenOpening");
PSString._add("aspectHeight");
PSString._add("aspectRatio");
PSString._add("aspectWidth");
PSString._add("assert");
PSString._add("assignProfile");
PSString._add("assumeOptions");
PSString._add("assumedCMYK");
PSString._add("assumedGray");
PSString._add("assumedProfile");
PSString._add("assumedRGB");
PSString._add("at");
PSString._add("ate1");
PSString._add("attachEMail");
PSString._add("authorName");
PSString._add("autoAdvanceSeconds");
PSString._add("autoAdvance");
PSString._add("autoBlackWhite");
PSString._add("autoBlendType");
PSString._add("autoCollapseDrawers");
PSString._add("autoContrast");
PSString._add("autoErase");
PSString._add("autoFixCorrect");
PSString._add("autoKern");
PSString._add("autoLeadingPercentage");
PSString._add("autoLeading");
PSString._add("autoMachineLearning");
PSString._add("autoNeutrals");
PSString._add("autoFaces");
PSString._add("autoCameraMetadata");
PSString._add("autoShowRevealStrips");
PSString._add("auto");
PSString._add("autoTCY");
PSString._add("autoTransparencyFill");
PSString._add("autoUpdateFile", "autoUpdateFiles");
PSString._add("axis");
PSString._add("bMPFormat");
PSString._add("b");
PSString._add("backLight");
PSString._add("back");
PSString._add("backgroundColorChanged");
PSString._add("backgroundColor");
PSString._add("backgroundEraserTool");
PSString._add("backgroundLayer");
PSString._add("backgroundLevel");
PSString._add("background");
PSString._add("backwardEnum");
PSString._add("backward");
PSString._add("balance");
PSString._add("basRelief");
PSString._add("baseName");
PSString._add("baseShapeStyle");
PSString._add("base");
PSString._add("baselineAlignment");
PSString._add("baselineDirection");
PSString._add("baselineShift");
PSString._add("baseline");
PSString._add("baseParentStyle");
PSString._add("batchFromDroplet");
PSString._add("batchSourceType");
PSString._add("batch");
PSString._add("beepWhenDone");
PSString._add("beforeRunning");
PSString._add("beginRamp");
PSString._add("beginSustain");
PSString._add("behind");
PSString._add("below");
PSString._add("best");
PSString._add("better");
PSString._add("bevelDirection");
PSString._add("bevelEmbossStampStyle");
PSString._add("bevelEmboss");
PSString._add("bevelEmbossStyle");
PSString._add("bevelJoin");
PSString._add("bevelStyle");
PSString._add("bevelTechnique");
PSString._add("bicubic");
PSString._add("bicubicAutomatic");
PSString._add("bicubicSmoother");
PSString._add("bicubicSharper");
PSString._add("bigNudgeH");
PSString._add("bigNudgeV");
PSString._add("bilateral", "surfaceBlur");
PSString._add("bilinear");
PSString._add("binary");
PSString._add("bitDepth1");
PSString._add("bitDepth24");
PSString._add("bitDepth4");
PSString._add("bitDepth8");
PSString._add("bitDepth");
PSString._add("bitmapMode");
PSString._add("bitmap");
PSString._add("blackAndWhite");
PSString._add("blackAndWhitePresetMode");
PSString._add("blackAndWhitePresetFileName");
PSString._add("blackBody");
PSString._add("blackClip");
PSString._add("blackGenerationCurve");
PSString._add("blackGeneration");
PSString._add("blackGenerationType");
PSString._add("blackIntensity");
PSString._add("blackLevel");
PSString._add("blackLimit");
PSString._add("black");
PSString._add("blacks");
PSString._add("blankFrameReader");
PSString._add("blast");
PSString._add("bleed");
PSString._add("bleedBox");
PSString._add("blendClipped");
PSString._add("blendDivide");
PSString._add("blendInterior");
PSString._add("blendMode");
PSString._add("blendOptions");
PSString._add("blendRange");
PSString._add("blendSubtraction");
PSString._add("blindsHorz");
PSString._add("blindsVert");
PSString._add("blockEraser");
PSString._add("blocks");
PSString._add("blueBlackPoint");
PSString._add("blueChannelCleanup");
PSString._add("blueFloat");
PSString._add("blueGamma");
PSString._add("blue");
PSString._add("blueWhitePoint");
PSString._add("blueX");
PSString._add("blueY");
PSString._add("blues");
PSString._add("blurEvent");
PSString._add("blurMethod");
PSString._add("blurMore");
PSString._add("blurQuality");
PSString._add("blur");
PSString._add("blurTool");
PSString._add("blurType");
PSString._add("bokmalNorwegianLanguage");
PSString._add("bold");
PSString._add("bolditalic");
PSString._add("bookColorKey", "bookKey");
PSString._add("bookColor");
PSString._add("bookID");
PSString._add("book");
PSString._add("boolean");
PSString._add("border");
PSString._add("borderThickness");
PSString._add("bothAxes");
PSString._add("both");
PSString._add("bottomEnum");
PSString._add("bottomRightPixelColor");
PSString._add("bottom");
PSString._add("bottomLeft");
PSString._add("bottomRight");
PSString._add("bounds");
PSString._add("boundsNoEffects");
PSString._add("boundingBox");
PSString._add("box");
PSString._add("boxBlur", "boxblur");
PSString._add("boxIn");
PSString._add("boxOut");
PSString._add("brazilianPortugueseLanguage");
PSString._add("brightnessContrast");
PSString._add("brightnessCube");
PSString._add("brightnessEvent");
PSString._add("brightness");
PSString._add("bringToFront");
PSString._add("broadcastKey");
PSString._add("browserHeight");
PSString._add("browserWidth");
PSString._add("brushColorRed");
PSString._add("brushColorGreen");
PSString._add("brushColorBlue");
PSString._add("brushDarkRough");
PSString._add("brushDetail");
PSString._add("brushGroup");
PSString._add("brushLightRough");
PSString._add("brushPreset");
PSString._add("brushProjection");
PSString._add("brushSimple");
PSString._add("brushSize");
PSString._add("brushSparkle");
PSString._add("brush");
PSString._add("brushType");
PSString._add("BrushTipDynamicsLock", "brushTipDynamicsLock");
PSString._add("brushWideBlurry");
PSString._add("brushWideSharp");
PSString._add("brushesAppend");
PSString._add("brushesDefine");
PSString._add("brushesDelete");
PSString._add("brushesLoad");
PSString._add("brushesNew");
PSString._add("brushesOptions");
PSString._add("brushesReset");
PSString._add("brushesSave");
PSString._add("brushes");
PSString._add("bucketTool");
PSString._add("buildNumber");
PSString._add("builtInContour", "builtInShapeCurve");
PSString._add("builtinProfile");
PSString._add("builtinProof");
PSString._add("builtin");
PSString._add("bulgarianLanguage");
PSString._add("bumpAmplitude");
PSString._add("bumpChannel");
PSString._add("burasagariNone");
PSString._add("burasagariStandard");
PSString._add("burasagari");
PSString._add("burasagariStrong");
PSString._add("burasagariType");
PSString._add("burnInH");
PSString._add("burnInM");
PSString._add("burnInS");
PSString._add("burnInTool");
PSString._add("buttCap");
PSString._add("buttonMode");
PSString._add("by");
PSString._add("byline");
PSString._add("bylineTitle");
PSString._add("byteOrder");
PSString._add("bwPresetKind");
PSString._add("bwPresetFileName");
PSString._add("cachePrefs");
PSString._add("calculation");
PSString._add("calculationType");
PSString._add("calculations");
PSString._add("calibrationBars");
PSString._add("cameraRotation");
PSString._add("canOpenByPhotoshop");
PSString._add("canadianFrenchLanguage");
PSString._add("canadianEnglishLanguage");
PSString._add("canvasBackgroundColors");
PSString._add("cancel");
PSString._add("canvasAttributes");
PSString._add("canvasColor");
PSString._add("canvasColorMode");
PSString._add("canvasExtensionColor");
PSString._add("canvasExtensionColorType");
PSString._add("CanvasFrame", "canvasFrame");
PSString._add("canvasSize");
PSString._add("caption");
PSString._add("captionWriter");
PSString._add("cascade");
PSString._add("caseSensitive");
PSString._add("catalanLanguage");
PSString._add("category");
PSString._add("ccittFax");
PSString._add("cellSize");
PSString._add("centerAlignment");
PSString._add("centerCropMarks");
PSString._add("centerDocumentWindows");
PSString._add("centerGlow");
PSString._add("center");
PSString._add("centeredFrame");
PSString._add("chalkArea");
PSString._add("chalkCharcoal");
PSString._add("changePathDetails");
PSString._add("channelDenoise");
PSString._add("channelDenoiseParams");
PSString._add("channelMatrix");
PSString._add("channelMixer");
PSString._add("channelName");
PSString._add("channelOptions");
PSString._add("channelReference");
PSString._add("channelRestrictions");
PSString._add("channel");
PSString._add("channelsInterleaved");
PSString._add("channelsPaletteOptions");
PSString._add("channels");
PSString._add("char");
PSString._add("characterRotation");
PSString._add("charcoalAmount");
PSString._add("charcoalArea");
PSString._add("charcoal");
PSString._add("checkAll");
PSString._add("checkForBackgroundLayer");
PSString._add("checkForOpenDoc");
PSString._add("checkForRasterLayer");
PSString._add("checkForSelection");
PSString._add("checkForTextLayer");
PSString._add("checkForVectorLayer");
PSString._add("checked");
PSString._add("checkerboardLarge");
PSString._add("checkerboardMedium");
PSString._add("checkerboardNone");
PSString._add("checkerboardSize");
PSString._add("checkerboardSmall");
PSString._add("chineseLanguage");
PSString._add("chokeMatte");
PSString._add("chroma");
PSString._add("chromeFXClass");
PSString._add("chromeFX");
PSString._add("chrome");
PSString._add("city");
PSString._add("classFloatRect");
PSString._add("classBrowserFile");
PSString._add("classBrowser");
PSString._add("classColor");
PSString._add("classContour", "classFXShapeCurve");
PSString._add("classElement");
PSString._add("classExport");
PSString._add("classFormat");
PSString._add("classHueSatHueSatV2");
PSString._add("classImport");
PSString._add("classMode");
PSString._add("classPanel");
PSString._add("class");
PSString._add("classStringFormat");
PSString._add("classTextExport");
PSString._add("classTextImport");
PSString._add("clearAmount");
PSString._add("clearBrushControls");
PSString._add("clearEnum");
PSString._add("clearEvent");
PSString._add("clearGuides");
PSString._add("clearRecentFiles");
PSString._add("clearRuler");
PSString._add("clearSlices");
PSString._add("clearStyle");
PSString._add("clearWarning");
PSString._add("clipboardTIFFTransparencyPref");
PSString._add("clipTopDraggedLayer");
PSString._add("clip");
PSString._add("clipboard");
PSString._add("clippingInfo");
PSString._add("clippingPathEPS");
PSString._add("clippingPathFlatness");
PSString._add("clippingPathIndex");
PSString._add("clippingPathInfo");
PSString._add("clippingPath");
PSString._add("clone");
PSString._add("cloneSource");
PSString._add("cloneSourceAutoHideOverlay");
PSString._add("cloneSourceInvertOverlay");
PSString._add("cloneSourceLockFrame");
PSString._add("cloneSourceResetTransform");
PSString._add("cloneSourceShowOverlay");
PSString._add("cloneSourceClipOverlay");
PSString._add("cloneSourceSource1");
PSString._add("cloneSourceSource2");
PSString._add("cloneSourceSource3");
PSString._add("cloneSourceSource4");
PSString._add("cloneSourceSource5");
PSString._add("cloneSourceToolOptions");
PSString._add("cloneStampTool");
PSString._add("closeAll");
PSString._add("closeQuickStart");
PSString._add("close");
PSString._add("closedDocument");
PSString._add("closedSubpath");
PSString._add("clouds");
PSString._add("clumping");
PSString._add("coarseDots");
PSString._add("colorBalance");
PSString._add("colorBurn");
PSString._add("colorCast");
PSString._add("colorChannel");
PSString._add("colorChannels");
PSString._add("colorCorrection");
PSString._add("colorDodge");
PSString._add("colorDissolve");
PSString._add("colorDynamicsLock");
PSString._add("colorDynamicsPerTip");
PSString._add("colorHalftone");
PSString._add("colorIndicates");
PSString._add("colorManagement");
PSString._add("colorMatch");
PSString._add("colorMode");
PSString._add("colorNoise");
PSString._add("colorOverlay");
PSString._add("colorPalette");
PSString._add("colorPickerHUDMode", "colorPickerHUD");
PSString._add("colorPickerPanel");
PSString._add("colorPickerPrefsClass");
PSString._add("colorPickerPrefs");
PSString._add("colorPickerRamp");
PSString._add("colorProfileList");
PSString._add("colorRange");
PSString._add("colorReplacementBrushTool");
PSString._add("colorSamplerList");
PSString._add("colorSampler");
PSString._add("colorSamplerTool");
PSString._add("colorSettingsChanged");
PSString._add("colorSettings");
PSString._add("colorSpace");
PSString._add("colorStop");
PSString._add("colorStopType");
PSString._add("color");
PSString._add("colorTable");
PSString._add("coloredPencil");
PSString._add("colorimetric");
PSString._add("colorize");
PSString._add("colorsList");
PSString._add("colorLookupType");
PSString._add("colorLookupOrderType", "colorLookupOrder");
PSString._add("colorLookupRGBOrder", "rgbOrder");
PSString._add("colorLookupBGROrder", "bgrOrder");
PSString._add("colors");
PSString._add("columnCount");
PSString._add("columnGutter");
PSString._add("columnWidth");
PSString._add("combine");
PSString._add("commandKey");
PSString._add("command");
PSString._add("comment");
PSString._add("commit");
PSString._add("commonIssues", "common");
PSString._add("comp");
PSString._add("compatible");
PSString._add("compensation");
PSString._add("component");
PSString._add("composite");
PSString._add("compression");
PSString._add("compsClass");
PSString._add("compsList");
PSString._add("compsPanelKey");
PSString._add("computedBrush");
PSString._add("concavity");
PSString._add("concise");
PSString._add("condition");
PSString._add("conditional");
PSString._add("connectionForms");
PSString._add("consolidateAllTabs");
PSString._add("constant");
PSString._add("constrainProportions");
PSString._add("constrain");
PSString._add("constrainedSides");
PSString._add("constructionFOV");
PSString._add("contactSheet");
PSString._add("conteCrayon");
PSString._add("contentAwareColorAdaptationFill");
PSString._add("contentAware");
PSString._add("contentAwareGainBias");
PSString._add("contentLayer");
PSString._add("content");
PSString._add("contextualLigatures");
PSString._add("contiguous");
PSString._add("continue");
PSString._add("continuity");
PSString._add("contourBrush");
PSString._add("contourEdge");
PSString._add("contract");
PSString._add("contrast");
PSString._add("convertKnotTool");
PSString._add("convertMode");
PSString._add("convert");
PSString._add("convertAnimation");
PSString._add("convertTimeline");
PSString._add("convertToCMYK");
PSString._add("convertToGray");
PSString._add("convertToLab");
PSString._add("convertToProfile");
PSString._add("convertToRGB");
PSString._add("convertToShape");
PSString._add("copyAsHTML");
PSString._add("copyAsHex");
PSString._add("copyBrushTexture");
PSString._add("copyEffects");
PSString._add("copyEvent");
PSString._add("copyKeyframes");
PSString._add("copyLayerCSS");
PSString._add("copyMerged");
PSString._add("copy");
PSString._add("copyToLayer");
PSString._add("copyrightNotice");
PSString._add("copyrightStatus");
PSString._add("copyright");
PSString._add("copyrightedWork");
PSString._add("cornerCropMarks");
PSString._add("corner");
PSString._add("correctionMethod");
PSString._add("countDynamics");
PSString._add("count");
PSString._add("countAuto");
PSString._add("countClear");
PSString._add("countAdd");
PSString._add("countDelete");
PSString._add("countMove");
PSString._add("countClass");
PSString._add("countColor");
PSString._add("countGroupVisible");
PSString._add("countGroupMarkerSize");
PSString._add("countGroupFontSize");
PSString._add("countRenameGroup");
PSString._add("countAddGroup");
PSString._add("countDeleteGroup");
PSString._add("countSetCurrentGroup");
PSString._add("countCustomColor");
PSString._add("countTool");
PSString._add("countryName");
PSString._add("coverDown");
PSString._add("coverRight");
PSString._add("crackBrightness");
PSString._add("crackDepth");
PSString._add("crackSpacing");
PSString._add("craquelure");
PSString._add("createDroplet");
PSString._add("createDuplicate");
PSString._add("createInterpolation");
PSString._add("createLayersFromLayerFX");
PSString._add("createWorkPath");
PSString._add("creatorAddr");
PSString._add("creatorAddrCity");
PSString._add("creatorAddrRegion");
PSString._add("creatorAddrPost", "creatorAddrPostCode");
PSString._add("creatorAddrCountry");
PSString._add("creatorPhone");
PSString._add("creatorEmail");
PSString._add("creatorURL");
PSString._add("credit");
PSString._add("croatianLanguage");
PSString._add("cropRectBottom");
PSString._add("cropRectLeft");
PSString._add("cropRectRight");
PSString._add("cropRectTop");
PSString._add("crop");
PSString._add("cropBox");
PSString._add("cropPreset");
PSString._add("cropTo");
PSString._add("cropTool");
PSString._add("cropWhenPrinting");
PSString._add("cross");
PSString._add("crossDissolve");
PSString._add("crosshatch");
PSString._add("crossover");
PSString._add("crystallize");
PSString._add("ctrlPPrint");
PSString._add("ctrlPSystemPrint");
PSString._add("ctrlShiftZEnum");
PSString._add("ctrlYEnum");
PSString._add("ctrlZEnum");
PSString._add("currentColors");
PSString._add("currentDocumentChanged");
PSString._add("currentFrame");
PSString._add("currentHistoryState");
PSString._add("currentLayer");
PSString._add("currentLeftRight");
PSString._add("currentLight");
PSString._add("current");
PSString._add("currentToolOptions");
PSString._add("cursorCrosshair");
PSString._add("cursorCrosshairStroke", "cursorCrosshairWhileStroking");
PSString._add("cursorKind");
PSString._add("cursorShape");
PSString._add("curveFile");
PSString._add("curvePoint");
PSString._add("curve");
PSString._add("curvesAdjustment");
PSString._add("curvesDisplayOptions");
PSString._add("curvesPresetKind");
PSString._add("curvesPresetFileName");
PSString._add("curves");
PSString._add("customEnum");
PSString._add("customEnvelopeWarp");
PSString._add("customForced");
PSString._add("customMatte");
PSString._add("customPaletteClass");
PSString._add("customPalette");
PSString._add("customPattern");
PSString._add("customPhosphors");
PSString._add("customScaleFactor");
PSString._add("customShape");
PSString._add("customShapeTool");
PSString._add("cookieCutterTool");
PSString._add("customStops");
PSString._add("custom");
PSString._add("customWhitePoint");
PSString._add("cut");
PSString._add("cutToLayer");
PSString._add("cutout");
PSString._add("cylindrical");
PSString._add("cyan");
PSString._add("cyans");
PSString._add("cycleComp");
PSString._add("czechLanguage");
PSString._add("danishLanguage");
PSString._add("darkGray");
PSString._add("darkIntensity");
PSString._add("dark");
PSString._add("darkStrokes");
PSString._add("darkenOnly");
PSString._add("darken");
PSString._add("darkerColor");
PSString._add("darkness");
PSString._add("dashedLines");
PSString._add("dataOrder");
PSString._add("dataPoints");
PSString._add("dataSetClass");
PSString._add("dataSetEncoding");
PSString._add("dataSetName");
PSString._add("dataSetNumberLeadingZeros");
PSString._add("dataSetNumber");
PSString._add("dateCreated");
PSString._add("dateModified");
PSString._add("datum");
PSString._add("dBrush");
PSString._add("dTips");
PSString._add("ddmm");
PSString._add("ddmmyy");
PSString._add("decontaminate");
PSString._add("deInterlace");
PSString._add("deinterlaceMethod");
PSString._add("dePosterize");
PSString._add("debugExecutionModeClass");
PSString._add("debugExecutionMode");
PSString._add("debugDescriptor");
PSString._add("decimalStruct");
PSString._add("decoPattern");
PSString._add("decoRenderFlame");
PSString._add("decoRenderPictureFrame");
PSString._add("decoRenderTree");
PSString._add("decoScriptFile");
PSString._add("decoScriptParameters");
PSString._add("deepDepth");
PSString._add("deep");
PSString._add("defaultAppScript");
PSString._add("defaultFill");
PSString._add("defaultForm");
PSString._add("defaultGray");
PSString._add("defaultStyle");
PSString._add("defaultTabWidth");
PSString._add("defaultWorkspace");
PSString._add("defineBrush");
PSString._add("defineCustomShape");
PSString._add("defineVariables");
PSString._add("definePattern");
PSString._add("defineSprayer");
PSString._add("definition");
PSString._add("defringe");
PSString._add("deghosting");
PSString._add("degreesUnit");
PSString._add("deleteAllAnnot");
PSString._add("deleteAudioClips");
PSString._add("deleteContained");
PSString._add("deleteFrame");
PSString._add("deleteKeyframe");
PSString._add("deleteKnotTool");
PSString._add("deleteMeasurements");
PSString._add("deleteScaleFactor");
PSString._add("deleteSelectedKeyframes");
PSString._add("deleteSelection");
PSString._add("deleteShapeStyle");
PSString._add("delete");
PSString._add("deleteTimeline");
PSString._add("deleteTransitions");
PSString._add("deleteWorkspace");
PSString._add("denoise");
PSString._add("denoisePresets");
PSString._add("denominator");
PSString._add("density");
PSString._add("densityUnit");
PSString._add("deposterize");
PSString._add("depth");
PSString._add("desaturate");
PSString._add("descenderAlignment");
PSString._add("description");
PSString._add("deselect");
PSString._add("despeckle");
PSString._add("destBlackMax");
PSString._add("destBlackMin");
PSString._add("destWhiteMax");
PSString._add("destWhiteMin");
PSString._add("destinationMode");
PSString._add("detail");
PSString._add("detailed");
PSString._add("deviceCentral");
PSString._add("deviceLinkProfile");
PSString._add("diameter");
PSString._add("diamond");
PSString._add("differenceClouds");
PSString._add("difference");
PSString._add("diffuseGlow");
PSString._add("diffuseMode");
PSString._add("diffuse");
PSString._add("diffusionDitherEnum");
PSString._add("diffusionDither");
PSString._add("diffusion");
PSString._add("dimension");
PSString._add("directSelectTool");
PSString._add("directionBalance");
PSString._add("direction");
PSString._add("disablePSDCompression");
PSString._add("disable");
PSString._add("disableLayerFX");
PSString._add("disableLayerStyle");
PSString._add("disableSingleFXEvent", "disableSingleFX");
PSString._add("discardVectorMask");
PSString._add("dispatcherID");
PSString._add("displaceFile");
PSString._add("displace");
PSString._add("displacementMap");
PSString._add("displayCursorsPreferences");
PSString._add("displayName");
PSString._add("displayPrefs");
PSString._add("disposeFrame");
PSString._add("dissolve");
PSString._add("distance");
PSString._add("distanceUnit");
PSString._add("distort");
PSString._add("distortion");
PSString._add("distribute");
PSString._add("distribution");
PSString._add("ditherAmount");
PSString._add("ditherPreserve");
PSString._add("ditherQuality");
PSString._add("dither");
PSString._add("divide");
PSString._add("dlDocInfoChanged");
PSString._add("documentChanged");
PSString._add("documentID");
PSString._add("documentMode");
PSString._add("documentReference");
PSString._add("document");
PSString._add("documentTimelineSettings");
PSString._add("docViewRectChanged");
PSString._add("docZoomChanged");
PSString._add("dodgeH");
PSString._add("dodgeM");
PSString._add("dodgeS");
PSString._add("dodgeTool");
PSString._add("doGainBias");
PSString._add("dontRecord");
PSString._add("dotGainCurves");
PSString._add("dotGain");
PSString._add("dots");
PSString._add("downgradeProfile");
PSString._add("draft");
PSString._add("draw");
PSString._add("dropCapMultiplier");
PSString._add("dropShadow");
PSString._add("dropShadowMulti");
PSString._add("dryBrush");
PSString._add("dualBrush");
PSString._add("dualBrushLock");
PSString._add("duotoneInk");
PSString._add("duotoneMode");
PSString._add("duotone");
PSString._add("duplicateAudioClips");
PSString._add("duplicateFrame");
PSString._add("duplicate");
PSString._add("duplication");
PSString._add("duration");
PSString._add("dustAndScratches");
PSString._add("dutchLanguage");
PSString._add("dutchLanguageOldRules", "kdutchLanguageOldRules");
PSString._add("DVCPRO720p");
PSString._add("DVCPRO1080p");
PSString._add("dvcProHD");
PSString._add("dynamicColorSliders");
PSString._add("eBUITU");
PSString._add("eMBoxStrikethroughOn");
PSString._add("easyTextSelection");
PSString._add("edgeBrightness");
PSString._add("edgeFidelity");
PSString._add("edgeGlow");
PSString._add("edgeIntensity");
PSString._add("edgeSimplicity");
PSString._add("edge");
PSString._add("edgeSmoothness");
PSString._add("edgeThickness");
PSString._add("edgeWidth");
PSString._add("editComment");
PSString._add("editDataSets");
PSString._add("editInImageReady");
PSString._add("editLogItems");
PSString._add("editLogItemsType");
PSString._add("editVariables");
PSString._add("effectBevel");
PSString._add("effectColorOverlay");
PSString._add("effectDropShadow");
PSString._add("effectGradientOverlay");
PSString._add("effectInnerGlow");
PSString._add("effectInnerShadow");
PSString._add("effectNone");
PSString._add("effectOuterGlow");
PSString._add("effectOverlay");
PSString._add("effectParams");
PSString._add("effectPatternOverlay");
PSString._add("effectSatin");
PSString._add("effect");
PSString._add("effectStroke");
PSString._add("elementReference");
PSString._add("element");
PSString._add("eliminateEvenFields");
PSString._add("eliminateOddFields");
PSString._add("ellipse");
PSString._add("ellipseTool");
PSString._add("else");
PSString._add("embedCMYK");
PSString._add("embedFonts");
PSString._add("embedGray");
PSString._add("embedLab");
PSString._add("embedLayer");
PSString._add("embedProfiles");
PSString._add("embedRGB");
PSString._add("emboss");
PSString._add("emulsionDown");
PSString._add("enable");
PSString._add("3Denable", "enable3D");
PSString._add("enabled");
PSString._add("enableExtendedNotification");
PSString._add("enableFloatingDocDocking");
PSString._add("enableFontFallback");
PSString._add("enableGestures");
PSString._add("enableMENATextEngine");
PSString._add("enableNarrowOptionBar");
PSString._add("enablePlugins");
PSString._add("enableWariChu");
PSString._add("encoding");
PSString._add("endArrowhead");
PSString._add("endFrameNumber");
PSString._add("endIndent");
PSString._add("endRamp");
PSString._add("end");
PSString._add("endSustain");
PSString._add("endTime");
PSString._add("engine");
PSString._add("englishLanguage");
PSString._add("enter");
PSString._add("entireImage");
PSString._add("entryStatusInvalid", "invalid");
PSString._add("entryStatusIsDirectory", "isDirectory");
PSString._add("entryStatusIsFile", "isFile");
PSString._add("entryStatusIsVolume", "isVolume");
PSString._add("entryStatusNotProcessed", "notprocessed");
PSString._add("entryStatus");
PSString._add("entryStatusType");
PSString._add("enumerated", "enumerated"); // manual fix
PSString._add("envelopeWarpStyle", "envelopewarpStyle");
PSString._add("equalize");
PSString._add("eraseToHistory");
PSString._add("eraserKind");
PSString._add("eraserTool");
PSString._add("estonianLanguage");
PSString._add("even");
PSString._add("eventClassAttr");
PSString._add("eventIDAttr");
PSString._add("eventRecord");
PSString._add("eventSourceAttr");
PSString._add("everShown");
PSString._add("exactPoints");
PSString._add("exact");
PSString._add("exchange");
PSString._add("excludeIntersection");
PSString._add("exclusion");
PSString._add("executablePath");
PSString._add("exit");
PSString._add("expand");
PSString._add("expertForm");
PSString._add("expFeaturesLearnMore", "expFeatureLearnMore");
PSString._add("expFeaturesPrefs", "experimentalFeatures");
PSString._add("expFeature3DMultitonePrinting");
PSString._add("expFeatureArtboards");
PSString._add("expFeaturePlayground");
PSString._add("exportClipboard");
PSString._add("exportDataSet");
PSString._add("exportMeasurements");
PSString._add("export");
PSString._add("exportTimelineComments");
PSString._add("exportTimelineCommentsAsHTML");
PSString._add("exportTimelineCommentsAsText");
PSString._add("exposure");
PSString._add("extend");
PSString._add("extendedQuality");
PSString._add("extended");
PSString._add("extendKeyframeSelection");
PSString._add("extension");
PSString._add("extensionsQuery");
PSString._add("extractAssets");
PSString._add("externalPreviewParams");
PSString._add("extractWorkArea");
PSString._add("extraLarge");
PSString._add("extrudeDepth");
PSString._add("extrudeMaskIncomplete");
PSString._add("extrudeRandom");
PSString._add("extrudeSize");
PSString._add("extrudeSolidFace");
PSString._add("extrude");
PSString._add("extrudeType");
PSString._add("eyeDropperSample");
PSString._add("eyeDropperSampleSheet");
PSString._add("eyeDropperSampleType");
PSString._add("eyedropperTool");
PSString._add("eyedropper2Tool");
PSString._add("eyedropperPlusTool");
PSString._add("eyedropperMinusTool");
PSString._add("eyeDropperHUD");
PSString._add("facet");
PSString._add("fade");
PSString._add("fadeIn");
PSString._add("fadeOut");
PSString._add("fadeTo");
PSString._add("fadeoutSteps");
PSString._add("falloff");
PSString._add("false");
PSString._add("faster");
PSString._add("feather");
PSString._add("fiberLength");
PSString._add("fidelity");
PSString._add("fieldBlur");
PSString._add("figureStyle");
PSString._add("fileBrowser");
PSString._add("fileCreator");
PSString._add("fileEnum");
PSString._add("fileInfo");
PSString._add("fileNamingComponent");
PSString._add("fileNamingComponents");
PSString._add("fileNamingRules");
PSString._add("fileOpenContext");
PSString._add("fileOpenContextCCLibrariesAsset");
PSString._add("fileOpenContextEmbededLinkedFile");
PSString._add("fileOpenContextExternallyLinkedFile");
PSString._add("fileReference");
PSString._add("fileSavePrefsClass");
PSString._add("fileSavePrefs");
PSString._add("file");
PSString._add("filesList");
PSString._add("fileType");
PSString._add("fillBack");
PSString._add("fillCanvas");
PSString._add("fillColor");
PSString._add("fillContents");
PSString._add("fillContentType");
PSString._add("fillEnabled");
PSString._add("fillFirst");
PSString._add("fillFore");
PSString._add("fillInverse");
PSString._add("fillMode");
PSString._add("fillNeutral");
PSString._add("fillOpacity");
PSString._add("fillOverPrint");
PSString._add("fillSame");
PSString._add("fill");
PSString._add("fillflash");
PSString._add("filmGrain");
PSString._add("filterFX");
PSString._add("filterFXList");
PSString._add("filterFXStyle");
PSString._add("filterFXTrackID");
PSString._add("filterMaskDensity");
PSString._add("FilterMaskEnabled", "filterMaskEnable");
PSString._add("FilterMaskExtendWithWhite", "filterMaskExtendWithWhite");
PSString._add("filterMaskFeather");
PSString._add("FilterMaskLinked", "filterMaskLinked");
PSString._add("filterMaskOptions");
PSString._add("filterMask");
PSString._add("filter");
PSString._add("filterID");
PSString._add("findEdges");
PSString._add("findReplace");
PSString._add("find");
PSString._add("fineDots");
PSString._add("fingerpainting");
PSString._add("finnishLanguage");
PSString._add("firstBaselineMinimum");
PSString._add("firstIdle");
PSString._add("firstLineIndent");
PSString._add("first");
PSString._add("fitOnScreen");
PSString._add("fitPage");
PSString._add("fixed");
PSString._add("fixMissingLinkedAssets");
PSString._add("flagged");
PSString._add("flareCenter");
PSString._add("flashDebugEnableAll", "flashDebugEnable");
PSString._add("flashMaxOpenOrRunning");
PSString._add("flashPixFormat");
PSString._add("flatness");
PSString._add("flattenImage");
PSString._add("flatten");
PSString._add("flick");
PSString._add("flip");
PSString._add("flipX");
PSString._add("flipY");
PSString._add("floatingPointPredictor", "floatPredictor");
PSString._add("floatAllWindows");
PSString._add("floatType");
PSString._add("floatUnit");
PSString._add("floatWindow");
PSString._add("flow");
PSString._add("flushImageChangedEvents");
PSString._add("focalLength");
PSString._add("focus");
PSString._add("focusMask");
PSString._add("focusMaskInFocusRadius");
PSString._add("focusMaskImageNoiseLevel");
PSString._add("focusMaskBinarySegLambda");
PSString._add("focusMaskBinarySegSigma");
PSString._add("focusMaskPowerLaw");
PSString._add("focusMaskUseAutoInFocusRadius");
PSString._add("focusMaskUseAutoImageNoiseLevel");
PSString._add("focusMaskUseAutoBinarySegSigma");
PSString._add("focusMaskUseSoftMask");
PSString._add("focusMaskOutput");
PSString._add("folders");
PSString._add("fontCaps");
PSString._add("fontDesignAxes");
PSString._add("fontDesignAxesVectors");
PSString._add("fontFamilyName");
PSString._add("fontLargeName");
PSString._add("fontLargeSize");
PSString._add("fontList");
PSString._add("fontListChanged");
PSString._add("fontName");
PSString._add("fontPostScriptName");
PSString._add("fontScript");
PSString._add("fontSize");
PSString._add("fontSmallName");
PSString._add("fontSmallSize");
PSString._add("fontStyleName");
PSString._add("fontTechnology");
PSString._add("footageInfo");
PSString._add("footageInterpretation");
PSString._add("footageSize");
PSString._add("forcedColors");
PSString._add("forcedNoDebugger");
PSString._add("forceFormatOptions");
PSString._add("forceNotify");
PSString._add("foregroundColorChanged");
PSString._add("foregroundColor");
PSString._add("foregroundLevel");
PSString._add("forceRecording");
PSString._add("format");
PSString._add("forwardEnum");
PSString._add("forward");
PSString._add("fractions");
PSString._add("fragment");
PSString._add("frameCount");
PSString._add("frameDelay");
PSString._add("frameDispose");
PSString._add("frameBaselineAlignment");
PSString._add("frameNumber");
PSString._add("frameFXClass");
PSString._add("frameFX");
PSString._add("frameFXMulti");
PSString._add("frameFill");
PSString._add("frameFromVideo");
PSString._add("frameGlobalAngle");
PSString._add("frameGlobalAltitude");
PSString._add("frame");
PSString._add("frameID");
PSString._add("frameInfo");
PSString._add("frameRate");
PSString._add("frameSetID");
PSString._add("frameSkip");
PSString._add("frames");
PSString._add("frameStep");
PSString._add("frameStyle");
PSString._add("frameSets");
PSString._add("frameWidth");
PSString._add("freeTransformCenterState");
PSString._add("freeTransform");
PSString._add("freeformPenTool");
PSString._add("frequency");
PSString._add("fresco");
PSString._add("fromBuiltin");
PSString._add("fromMode");
PSString._add("from");
PSString._add("front");
PSString._add("fullDocument");
PSString._add("fullName");
PSString._add("fullSize");
PSString._add("fullWidthForm");
PSString._add("fullySelected");
PSString._add("functionKey");
PSString._add("fuzziness");
PSString._add("gain");
PSString._add("gamma");
PSString._add("gammaCorrection");
PSString._add("gamutWarning");
PSString._add("gaussian");
PSString._add("gaussianBlur");
PSString._add("gaussianDistribution");
PSString._add("generalPreferences");
PSString._add("generalPrefs");
PSString._add("generalUnitsType");
PSString._add("generate");
PSString._add("generateAssets");
PSString._add("generatorEnabled");
PSString._add("generatorDisabled");
PSString._add("generatorStatus");
PSString._add("generatorSettings");
PSString._add("generatorTrackingEnable");
PSString._add("genieBrushTool");
PSString._add("geometryOnly");
PSString._add("geometryRecord");
PSString._add("geometryToolMode");
PSString._add("get");
PSString._add("glass");
PSString._add("glitterRight");
PSString._add("glitterDown");
PSString._add("glitterRDown");
PSString._add("globalAltitude");
PSString._add("globalAngle");
PSString._add("globalClass");
PSString._add("globalLightingAltitude", "globalAltitude");
PSString._add("globalLightingAngle");
PSString._add("globalLighting");
PSString._add("globalObject");
PSString._add("gloss");
PSString._add("glowAmount");
PSString._add("glowTechnique");
PSString._add("glowingEdges");
PSString._add("good");
PSString._add("gradientClassEvent");
PSString._add("gradientFill");
PSString._add("gradientFillMulti");
PSString._add("gradientForm");
PSString._add("gradientLayer");
PSString._add("gradientMapClass");
PSString._add("gradientMapEvent");
PSString._add("gradientOverlay");
PSString._add("gradient");
PSString._add("gradientTool");
PSString._add("gradientType");
PSString._add("grainClumped");
PSString._add("grainContrasty");
PSString._add("grainEnlarged");
PSString._add("grainHorizontal");
PSString._add("grainRegular");
PSString._add("grainSoft");
PSString._add("grainSpeckle");
PSString._add("grainSprinkles");
PSString._add("grainStippled");
PSString._add("grain");
PSString._add("grainType");
PSString._add("grainVertical");
PSString._add("graininess");
PSString._add("grainyDots");
PSString._add("graphicPen");
PSString._add("graphics");
PSString._add("gravityEffect");
PSString._add("gray16");
PSString._add("gray18");
PSString._add("gray22");
PSString._add("gray50");
PSString._add("grayBehavior");
PSString._add("grayFloat");
PSString._add("grayScaleRamp");
PSString._add("grayScale");
PSString._add("graySetup");
PSString._add("gray");
PSString._add("grayPointTool");
PSString._add("grayscaleMode");
PSString._add("grayscale");
PSString._add("grayscaleFloat");
PSString._add("greekLanguage");
PSString._add("greenBlackPoint");
PSString._add("greenFloat");
PSString._add("greenGamma");
PSString._add("green");
PSString._add("greenWhitePoint");
PSString._add("greenX");
PSString._add("greenY");
PSString._add("greens");
PSString._add("gridAlignment");
PSString._add("gridColor");
PSString._add("gridCustomColor");
PSString._add("gridMajor");
PSString._add("gridMinor");
PSString._add("gridStyle");
PSString._add("gridUnits");
PSString._add("groupEvent");
PSString._add("group");
PSString._add("groutWidth");
PSString._add("grow");
PSString._add("gujaratiLanguage");
PSString._add("guideGridColor");
PSString._add("guideGridStyle");
PSString._add("guide");
PSString._add("guideLayout");
PSString._add("guidesColor");
PSString._add("guidesCustomColor");
PSString._add("guidesGridPreferences");
PSString._add("guidesPrefs");
PSString._add("guides");
PSString._add("guidesStyle");
PSString._add("guidesVisibility");
PSString._add("guideSet");
PSString._add("guideSetClass");
PSString._add("guideSetName");
PSString._add("guideSetGuideCount");
PSString._add("gutterWidth");
PSString._add("halfWidthForm");
PSString._add("halftoneFile");
PSString._add("halftoneScreen");
PSString._add("halftoneSize");
PSString._add("halftoneSpec");
PSString._add("handTool");
PSString._add("hangingRoman");
PSString._add("hardLight");
PSString._add("hardMix");
PSString._add("hardProof");
PSString._add("hardness");
PSString._add("hasAlpha");
PSString._add("hasBackgroundLayer");
PSString._add("hasMotion");
PSString._add("hasOptions", "hasoptions");
PSString._add("hasFilterMask");
PSString._add("hasUserMask");
PSString._add("hasVectorMask");
PSString._add("vectorMaskParams");
PSString._add("vectorToolMode");
PSString._add("hdAnamorphic");
PSString._add("hdrOptions");
PSString._add("hdrToningMethodType");
PSString._add("hdrToning");
PSString._add("header");
PSString._add("headlightsLogEvent", "headlightsLog");
PSString._add("headlightsLogInfo", "headlightsInfo");
PSString._add("headline");
PSString._add("healFromDest2Src");
PSString._add("healFromSrc2Dest");
PSString._add("healJPEG");
PSString._add("healSelection");
PSString._add("healingBrushTool");
PSString._add("healingDirection");
PSString._add("heavy");
PSString._add("height");
PSString._add("height1");
PSString._add("height2");
PSString._add("help");
PSString._add("hidden");
PSString._add("hideAll");
PSString._add("hideCurrentPath");
PSString._add("hideSelection");
PSString._add("hide");
PSString._add("hideDocumentTabs");
PSString._add("highPass");
PSString._add("highQuality");
PSString._add("highQualityWarp");
PSString._add("high");
PSString._add("highlightArea");
PSString._add("highlightColor");
PSString._add("highlightLevels");
PSString._add("highlightMode");
PSString._add("highlightOpacity");
PSString._add("highlightStrength");
PSString._add("highlightsFuzziness");
PSString._add("highlightsLowerLimit");
PSString._add("highlights");
PSString._add("hindiLanguage");
PSString._add("histogramPaletteAllChannelsView");
PSString._add("histogramPaletteCompactView");
PSString._add("histogramPaletteExpandedView");
PSString._add("histogramPaletteShowChannelsInColor");
PSString._add("histogramPaletteShowStatistics");
PSString._add("histogramPaletteUncachedRefresh");
PSString._add("histogram");
PSString._add("historyBrushSource");
PSString._add("historyBrushTool");
PSString._add("historyLog");
PSString._add("historyPaletteOptions");
PSString._add("historyPreferences");
PSString._add("historyPrefsClass");
PSString._add("historyPrefs");
PSString._add("historyStateSource");
PSString._add("historyStateSourceType");
PSString._add("historyState");
PSString._add("historyStates");
PSString._add("history");
PSString._add("hitTest");
PSString._add("hold");
PSString._add("horizontalLocation");
PSString._add("horizontalOnly");
PSString._add("horizontalScale");
PSString._add("horizontal");
PSString._add("hostName");
PSString._add("hostVersion");
PSString._add("hours");
PSString._add("html");
PSString._add("htmlText");
PSString._add("hueCube");
PSString._add("hueSatAdjustment");
PSString._add("hueSatAdjustmentV2");
PSString._add("hueSaturation");
PSString._add("hueSatTool");
PSString._add("hue");
PSString._add("huge");
PSString._add("hungarianLanguage");
PSString._add("hyphenateCapitalized");
PSString._add("hyphenateLimit");
PSString._add("hyphenatePostLength");
PSString._add("hyphenatePreLength");
PSString._add("hyphenate");
PSString._add("hyphenateWordSize");
PSString._add("hyphenationPreference");
PSString._add("hyphenationZone");
PSString._add("hyphen");
PSString._add("icelandicLanguage");
PSString._add("icfbottom");
PSString._add("icftop");
PSString._add("icon");
PSString._add("idle");
PSString._add("idleVM");
PSString._add("ignoreRotationMetadata");
PSString._add("ignore");
PSString._add("illustratorPathsExport");
PSString._add("imageBalance");
PSString._add("imageCachePreferences");
PSString._add("imageCenter");
PSString._add("imageCoords");
PSString._add("imageInterpolation");
PSString._add("imageLocation");
PSString._add("imagePoint");
PSString._add("imageReference");
PSString._add("imageSize");
PSString._add("imageStateChanged");
PSString._add("imageStatistics");
PSString._add("image");
PSString._add("imageStack");
PSString._add("imageStackConvertSmartObject");
PSString._add("imageStackEditContents");
PSString._add("imageStackPlugin");
PSString._add("imageType");
PSString._add("impliedFontSize");
PSString._add("impliedLeading");
PSString._add("impliedBaselineShift");
PSString._add("impliedEndIndent");
PSString._add("impliedFirstLineIndent");
PSString._add("impliedSpaceAfter");
PSString._add("impliedSpaceBefore");
PSString._add("impliedStartIndent");
PSString._add("importAnnots");
PSString._add("importDataSet", "importDataSets");
PSString._add("import");
PSString._add("importVideoTapestry");
PSString._add("importVideoToLayers");
PSString._add("impressionist");
PSString._add("inAPath");
PSString._add("indices");
PSString._add("in");
PSString._add("inOut");
PSString._add("inchesUnit");
PSString._add("includeAnnotations");
PSString._add("includeAuthor");
PSString._add("includeCopyright");
PSString._add("includeDescription");
PSString._add("includeEXIFData");
PSString._add("includeExtension");
PSString._add("includeFilename");
PSString._add("includeTitle");
PSString._add("includeVectorData");
PSString._add("indent");
PSString._add("index");
PSString._add("indexedColorMode");
PSString._add("indexedColor");
PSString._add("inflationSide");
PSString._add("infoPaletteOptions");
PSString._add("infoPaletteToggleSamplers");
PSString._add("inherits");
PSString._add("inkBlack");
PSString._add("inkColors");
PSString._add("inkOutlines");
PSString._add("inkTransfer");
PSString._add("inks");
PSString._add("innerBevel");
PSString._add("innerGlowSource");
PSString._add("innerGlowSourceType");
PSString._add("innerGlow");
PSString._add("innerShadow");
PSString._add("innerShadowMulti");
PSString._add("inPlace");
PSString._add("inputMapRange");
PSString._add("inputRange");
PSString._add("input");
PSString._add("insertBlankFrame");
PSString._add("insetFrame");
PSString._add("inside");
PSString._add("integerChannel");
PSString._add("integer");
PSString._add("intellectualGenre");
PSString._add("intensity");
PSString._add("intent");
PSString._add("interactive");
PSString._add("interactLevelAttr");
PSString._add("interfaceBevelHighlight");
PSString._add("interfaceBevelShadow");
PSString._add("interfaceBlack");
PSString._add("interfaceBorder");
PSString._add("interfaceButtonDarkShadow");
PSString._add("interfaceButtonDownFill");
PSString._add("interfaceButtonShadow");
PSString._add("interfaceButtonText");
PSString._add("interfaceButtonUpFill");
PSString._add("interfaceCanvasColor");
PSString._add("interfaceColorBlue2");
PSString._add("interfaceColorBlue32");
PSString._add("interfaceColorGreen2");
PSString._add("interfaceColorGreen32");
PSString._add("interfaceColorRed2");
PSString._add("interfaceColorRed32");
PSString._add("interfaceColor");
PSString._add("interfaceIconFillActive");
PSString._add("interfaceIconFillDimmed");
PSString._add("interfaceIconFillSelected");
PSString._add("interfaceIconFrameActive");
PSString._add("interfaceIconFrameDimmed");
PSString._add("interfaceIconFrameSelected");
PSString._add("interfaceOWLPaletteFill");
PSString._add("interfacePaletteFill");
PSString._add("interfacePrefs");
PSString._add("interfaceStaticText");
PSString._add("interface3DPrefs", "z3DPrefs");
PSString._add("toolsPrefs", "toolsPreferences");
PSString._add("historyLogPrefs", "historyLogPreferences");
PSString._add("workspacePrefs", "workspacePreferences");
PSString._add("3DPrefDropToGL", "Z3DPrefDropToGL");
PSString._add("3DPrefGLDirectToScreen", "Z3DPrefGLDirectToScreen");
PSString._add("3DPrefGLAutoHideLayers", "Z3DPrefGLAutoHideLayers");
PSString._add("3DPrefARTUseShadows", "Z3DPrefARTUseShadows");
PSString._add("3DPrefARTUseRefractions", "Z3DPrefARTUseRefractions");
PSString._add("3DPrefARTUseReflections", "Z3DPrefARTUseReflections");
PSString._add("3DPrefColorMeshSelection", "Z3DPrefColorMeshSelection");
PSString._add("3DPrefColorMaterialSelection", "Z3DPrefColorMaterialSelection");
PSString._add("3DPrefColorLightsourceSelection", "Z3DPrefColorLightsourceSelection");
PSString._add("3DPrefColorLightsourceDisplay", "Z3DPrefColorLightsourceDisplay");
PSString._add("3DPrefColorConstraintSelection", "Z3DPrefColorConstraintSelection");
PSString._add("3DPrefColorConstraintDisplay", "Z3DPrefColorConstraintDisplay");
PSString._add("3DPrefColorProgressiveRenderingTilesDisplay", "Z3DPrefColorProgressiveRenderingTilesDisplay");
PSString._add("3DPrefColorGroundPlaneDisplay", "Z3DPrefColorGroundPlaneDisplay");
PSString._add("3DPrefGroundPlaneSpacing", "Z3DPrefGroundPlaneSize");
PSString._add("3DPrefGroundPlaneSize", "Z3DPrefGroundPlaneSpacing");
PSString._add("3DPrefHighQualityErrorThreshold", "Z3DPrefHighQualityErrorThreshold");
PSString._add("3DPrefDrawProgressiveRenderingOverlay", "Z3DPrefDrawProgressiveRenderingOverlay");
PSString._add("3DPrefOnCanvasAxisWidgetScale", "Z3DPrefOnCanvasAxisWidgetScale");
PSString._add("3DPrefFileLoadingLightThreshold", "Z3DPrefFileLoadingLightThreshold");
PSString._add("3DPrefFileLoadingTextureThreshold", "Z3DPrefFileLoadingTextureThreshold");
PSString._add("3DPrefDropToGL", "Z3DPrefDropToGL");
PSString._add("3DPrefGLDirectToScreen", "Z3DPrefGLDirectToScreen");
PSString._add("3DPrefGLAutoHideLayers", "Z3DPrefGLAutoHideLayers");
PSString._add("3DPrefARTUseShadows", "Z3DPrefARTUseShadows");
PSString._add("3DPrefARTUseRefractions", "Z3DPrefARTUseRefractions");
PSString._add("3DPrefARTUseReflections", "Z3DPrefARTUseReflections");
PSString._add("3DPrefColorMeshSelection", "Z3DPrefColorMeshSelection");
PSString._add("3DPrefColorMaterialSelection", "Z3DPrefColorMaterialSelection");
PSString._add("3DPrefColorLightsourceSelection", "Z3DPrefColorLightsourceSelection");
PSString._add("3DPrefColorLightsourceDisplay", "Z3DPrefColorLightsourceDisplay");
PSString._add("3DPrefColorConstraintSelection", "Z3DPrefColorConstraintSelection");
PSString._add("3DPrefColorConstraintDisplay", "Z3DPrefColorConstraintDisplay");
PSString._add("3DPrefColorProgressiveRenderingTilesDisplay", "Z3DPrefColorProgressiveRenderingTilesDisplay");
PSString._add("3DPrefColorGroundPlaneDisplay", "Z3DPrefColorGroundPlaneDisplay");
PSString._add("3DPrefGroundPlaneSpacing", "Z3DPrefGroundPlaneSize");
PSString._add("3DPrefGroundPlaneSize", "Z3DPrefGroundPlaneSpacing");
PSString._add("3DPrefShadowQuality", "Z3DPrefShadowQuality");
PSString._add("3DPrefHighQualityErrorThreshold", "Z3DPrefHighQualityErrorThreshold");
PSString._add("3DPrefDrawProgressiveRenderingOverlay", "Z3DPrefDrawProgressiveRenderingOverlay");
PSString._add("3DPrefOnCanvasAxisWidgetScale", "Z3DPrefOnCanvasAxisWidgetScale");
PSString._add("3DPrefFileLoadingLightThreshold", "Z3DPrefFileLoadingLightThreshold");
PSString._add("3DPrefFileLoadingTextureThreshold", "Z3DPrefFileLoadingTextureThreshold");
PSString._add("3DPrefRenderTileSize", "Z3DPrefRenderTileSize");
PSString._add("interfaceRed");
PSString._add("interfaceToolTipBackground");
PSString._add("interfaceToolTipText");
PSString._add("interfaceTransparencyBackground");
PSString._add("interfaceTransparencyForeground");
PSString._add("interfaceWhite");
PSString._add("interiorOpacityOnly");
PSString._add("interlaceCreateType");
PSString._add("interlaceEliminateType");
PSString._add("interlace");
PSString._add("interpolationHold");
PSString._add("interpolationLinear");
PSString._add("interpolationMethod");
PSString._add("interpolation");
PSString._add("interpolationType");
PSString._add("interpretAlpha");
PSString._add("interpretation");
PSString._add("interpretFootage");
PSString._add("inTime");
PSString._add("intersectFilterMaskWithSelection");
PSString._add("intersect");
PSString._add("intersectUserMaskWithSelection");
PSString._add("intersectVectorMaskWithSelection");
PSString._add("intersectWith");
PSString._add("inverse");
PSString._add("invertAlpha");
PSString._add("invertMask");
PSString._add("invertSource2");
PSString._add("invert");
PSString._add("invertTexture");
PSString._add("iptcScene");
PSString._add("iptcSubjectCode");
PSString._add("irisBlur");
PSString._add("isDirty");
PSString._add("isoCountryCode");
PSString._add("italianLanguage");
PSString._add("italic");
PSString._add("italics");
PSString._add("itemIndex");
PSString._add("japaneseAlternate");
PSString._add("japaneseLanguage");
PSString._add("japanese");
PSString._add("javaScriptMessage");
PSString._add("javaScriptOptions");
PSString._add("javaScriptOptionsClass");
PSString._add("javaScriptName");
PSString._add("javaScript");
PSString._add("javaScriptText");
PSString._add("jiDori");
PSString._add("jitter");
PSString._add("jobName");
PSString._add("join");
PSString._add("json");
PSString._add("jsonAction");
PSString._add("justificationGlyphDesired");
PSString._add("justificationGlyphMaximum");
PSString._add("justificationGlyphMinimum");
PSString._add("justificationLetterDesired");
PSString._add("justificationLetterMaximum");
PSString._add("justificationLetterMinimum");
PSString._add("justificationWordDesired");
PSString._add("justificationWordMaximum");
PSString._add("justificationWordMinimum");
PSString._add("justifyAll");
PSString._add("justifyCenter");
PSString._add("justifyFull");
PSString._add("justifyLeft");
PSString._add("justifyRight");
PSString._add("kana");
PSString._add("kannadaLanguage");
PSString._add("keepProfile");
PSString._add("keepTogether");
PSString._add("kelvinCustomWhitePoint");
PSString._add("kelvin");
PSString._add("kernelProcessID");
PSString._add("kernelType");
PSString._add("kerningRange");
PSString._add("kerning");
PSString._add("keyboardCustomization");
PSString._add("keyboardShortcutsChanged");
PSString._add("ccLibrariesElement");
PSString._add("customization");
PSString._add("browseAndClose");
PSString._add("browseFilters");
PSString._add("browseScripts");
PSString._add("keyboardPreferences");
PSString._add("keyList");
PSString._add("keyword");
PSString._add("keywords");
PSString._add("kind");
PSString._add("kinsokuSetName");
PSString._add("edgePreservingUpscale", "preserveDetailsUpscale");
PSString._add("automaticBestFit", "automaticInterpolation");
PSString._add("knockoutBlocking");
PSString._add("knockout");
PSString._add("knotComponent");
PSString._add("knotData");
PSString._add("knotEdit");
PSString._add("knotIndex");
PSString._add("croatianLanguage");
PSString._add("kurikaeshiMojiShori");
PSString._add("lab48");
PSString._add("labColorMode");
PSString._add("labColor");
PSString._add("lab");
PSString._add("labels");
PSString._add("landscape");
PSString._add("largeDocumentFormat");
PSString._add("large");
PSString._add("lassoTool");
PSString._add("lastFilter");
PSString._add("last");
PSString._add("lastTransform");
PSString._add("layer3D");
PSString._add("layerCompression");
PSString._add("layerConceals");
PSString._add("layerCreated");
PSString._add("layerDeleted");
PSString._add("layerEffects");
PSString._add("layerFXVisible");
PSString._add("layerID");
PSString._add("layerKind");
PSString._add("layerLocking");
PSString._add("layerMaskAsGlobalMask");
PSString._add("layerName");
PSString._add("layerOptions");
PSString._add("layerGroupContent", "layerSectionContent");
PSString._add("layerGroupEnd", "layerSectionEnd");
PSString._add("layerGroupStart", "layerSectionStart");
PSString._add("layerGroup", "layerSection");
PSString._add("layerGroupType", "layerSectionType");
PSString._add("layerGroupFromLinkedEvent", "layerSetFromLinkedEvent");
PSString._add("layerGroupFromSelectedEvent", "layerSetFromSelectedEvent");
PSString._add("layerGroupExpanded", "layerSectionExpanded");
PSString._add("newArtboardEvent");
PSString._add("artboardFromLayerGroupEvent");
PSString._add("artboardFromLayersEvent");
PSString._add("editArtboardEvent");
PSString._add("artboard");
PSString._add("artboardSection");
PSString._add("artboard");
PSString._add("artboardEnabled");
PSString._add("artboardRect");
PSString._add("changeSizes");
PSString._add("layerPathComponentCount");
PSString._add("layerSVGdata");
PSString._add("layerSVGcoordinateOffset");
PSString._add("layerThumbnailSize");
PSString._add("layerTransformation");
PSString._add("layerVectorPointData");
PSString._add("collapseAllGroupsEvent");
PSString._add("groupLayersEvent");
PSString._add("ungroupLayersEvent");
PSString._add("latvianLanguage");
PSString._add("layer");
PSString._add("layersPaletteOptions");
PSString._add("layers");
PSString._add("layerStyle");
PSString._add("layerTime");
PSString._add("layerVisibilityChanged");
PSString._add("layerXMP");
PSString._add("layout");
PSString._add("leAdobeOnlineWeb");
PSString._add("leHealingBrush");
PSString._add("leHelpContent");
PSString._add("leHelpSupport");
PSString._add("leSystemInfo");
PSString._add("leTutorials");
PSString._add("leUserForums");
PSString._add("leadingAbove");
PSString._add("leadingBelow");
PSString._add("leading");
PSString._add("leadingType");
PSString._add("leftAki");
PSString._add("leftPlugin");
PSString._add("left");
PSString._add("length");
PSString._add("lensBlur");
PSString._add("lensFlare");
PSString._add("lens");
PSString._add("levelBased");
PSString._add("level");
PSString._add("levelsAdjustment");
PSString._add("levels");
PSString._add("libraryName");
PSString._add("liftWorkArea");
PSString._add("ligature");
PSString._add("lightBlue");
PSString._add("lightDark");
PSString._add("lightDirBottomLeft");
PSString._add("lightDirBottomRight");
PSString._add("lightDirBottom");
PSString._add("lightDirLeft");
PSString._add("lightDirRight");
PSString._add("lightDirTopLeft");
PSString._add("lightDirTopRight");
PSString._add("lightDirTop");
PSString._add("lightDirection");
PSString._add("lightDirectional");
PSString._add("lightFilterLightingEffects");
PSString._add("lightFilterExtractLight");
PSString._add("lightFilterExtractColor");
PSString._add("lightFilterGradient");
PSString._add("lightFilterGradientMagnitude");
PSString._add("lightGray");
PSString._add("lightIntensity");
PSString._add("lightOmni");
PSString._add("lightroomBridgetalkID");
PSString._add("lightroomDocID");
PSString._add("lightroomSaveParams");
PSString._add("lightPosBottomLeft");
PSString._add("lightPosBottomRight");
PSString._add("lightPosBottom");
PSString._add("lightPosLeft");
PSString._add("lightPosRight");
PSString._add("lightPosTopLeft");
PSString._add("lightPosTopRight");
PSString._add("lightPosTop");
PSString._add("lightPosition");
PSString._add("lightRed");
PSString._add("lightSource");
PSString._add("lightSpot");
PSString._add("light");
PSString._add("lightType");
PSString._add("lightenGrout");
PSString._add("lightenOnly");
PSString._add("lighten");
PSString._add("lighterColor");
PSString._add("lightingEffects");
PSString._add("lightness");
PSString._add("limited");
PSString._add("lineCap");
PSString._add("lineClass");
PSString._add("lineDashOffset", "lineDashoffset");
PSString._add("lineDash");
PSString._add("lineJoin");
PSString._add("line");
PSString._add("lineTool");
PSString._add("lineWidth");
PSString._add("linearBurn");
PSString._add("linearDodge");
PSString._add("linearHeight");
PSString._add("linearLight");
PSString._add("linear");
PSString._add("spherical");
PSString._add("lines");
PSString._add("link");
PSString._add("linkSelectedLayers");
PSString._add("linkEnable", "enableLayerLink");
PSString._add("linkDisable", "disableLayerLink");
PSString._add("linkToOtherEffects");
PSString._add("lithuanianLanguage");
PSString._add("selectAllLayers");
PSString._add("selectNoLayers");
PSString._add("findLayers");
PSString._add("isolateLayers");
PSString._add("deIsolateLayers");
PSString._add("renameLayer");
PSString._add("linkedLayerIDs");
PSString._add("linked");
PSString._add("list");
PSString._add("hideLayers");
PSString._add("showAlteredVideo");
PSString._add("hideAlteredVideo");
PSString._add("showLayers");
PSString._add("legacyPathDrag");
PSString._add("vectorSelectionModifiesLayerSelection");
PSString._add("local");
PSString._add("localLightingAltitude");
PSString._add("localLightingAngle");
PSString._add("localRange");
PSString._add("locationReference");
PSString._add("location");
PSString._add("locked");
PSString._add("loadSolidColorOnly");
PSString._add("load");
PSString._add("logicalLength");
PSString._add("logicalUnits");
PSString._add("log");
PSString._add("longFloat");
PSString._add("longInteger");
PSString._add("longLines");
PSString._add("longStrokes");
PSString._add("lookupType");
PSString._add("loop");
PSString._add("loopCount");
PSString._add("lowQuality");
PSString._add("low");
PSString._add("lowerCaseExtension");
PSString._add("lowerCaseSerial");
PSString._add("lowerCase");
PSString._add("lower");
PSString._add("luminance");
PSString._add("luminosity");
PSString._add("lutFormat", "LUTFormat");
PSString._add("macPaintFormat");
PSString._add("macThumbnail");
PSString._add("macintosh");
PSString._add("macintoshSystem");
PSString._add("magenta");
PSString._add("magentas");
PSString._add("magicEraserTool");
PSString._add("magicPoint");
PSString._add("magicStampTool");
PSString._add("magicWandTool");
PSString._add("magneticLassoTool");
PSString._add("magnification");
PSString._add("magnitude");
PSString._add("makeAnimation");
PSString._add("makeFrameAnimation");
PSString._add("makeFramesFromLayers");
PSString._add("makeLayersFromFrames");
PSString._add("makeShapeLayers");
PSString._add("makeTimeline");
PSString._add("make");
PSString._add("makeVisible");
PSString._add("malayalamLanguage");
PSString._add("manage");
PSString._add("manipulationFOV");
PSString._add("manual");
PSString._add("mapBlack");
PSString._add("mappingShape");
PSString._add("mapping");
PSString._add("marathiLanguage");
PSString._add("marginLeft");
PSString._add("marginTop");
PSString._add("marginRight");
PSString._add("marginBottom");
PSString._add("marqueeEllipTool");
PSString._add("marqueeRectTool");
PSString._add("marqueeSingleColumnTool");
PSString._add("marqueeSingleRowTool");
PSString._add("maskIndicator");
PSString._add("maskParameters");
PSString._add("mask");
PSString._add("maskedAreas");
PSString._add("masterAdaptive");
PSString._add("masterDiameter");
PSString._add("masterFXSwitch");
PSString._add("masterOpacityOnly");
PSString._add("masterPerceptual");
PSString._add("masterSelective");
PSString._add("matchColor");
PSString._add("matchLocation");
PSString._add("matchRotation");
PSString._add("matchZoomAndLocation");
PSString._add("matchZoom");
PSString._add("material");
PSString._add("material1");
PSString._add("material2");
PSString._add("material3");
PSString._add("material4");
PSString._add("material5");
PSString._add("matrix");
PSString._add("matteColor");
PSString._add("matte");
PSString._add("matteTechnique");
PSString._add("maxDOF");
PSString._add("maximizeCompatibility");
PSString._add("maximumEnum");
PSString._add("maximumQuality");
PSString._add("maximumStates");
PSString._add("maximum");
PSString._add("means");
PSString._add("measurementDataPoint");
PSString._add("measurementDataPointsCustom");
PSString._add("measurementLogAutoDisplayPalette");
PSString._add("measurementLogDataClass");
PSString._add("measurementLogDataPointClass");
PSString._add("measurementLogDataPointDataClass");
PSString._add("measurementLogDataPointDataTypeClass");
PSString._add("measurementLogDeleteSelected");
PSString._add("measurementLogDeselectAll");
PSString._add("measurementLogErrorClass");
PSString._add("measurementLogExportSelected");
PSString._add("measurementLogExtentClass");
PSString._add("measurementLogOptions");
PSString._add("measurementLogPanelKey");
PSString._add("measurementLogSelectAll");
PSString._add("measurementRange");
PSString._add("measurementRecordMeasurements");
PSString._add("measurementScale");
PSString._add("measurementScaleCustom");
PSString._add("measurementScaleDefault");
PSString._add("measurementScaleMarker");
PSString._add("measurementScaleMarkerColor");
PSString._add("measurementScaleMarkerLength");
PSString._add("measurementScaleMarkerDisplayTicks");
PSString._add("measurementScaleMarkerDisplayText");
PSString._add("measurementScaleMarkerTextPositionBottom");
PSString._add("measurementScaleMarkerLocationBottom");
PSString._add("measurementScaleMarkerLocationLeft");
PSString._add("measurementSource");
PSString._add("median");
PSString._add("mediaBox");
PSString._add("mediumBlue");
PSString._add("mediumDots");
PSString._add("mediumLines");
PSString._add("mediumQuality");
PSString._add("medium");
PSString._add("mediumGray");
PSString._add("mediumStrokes");
PSString._add("memoryPreferences");
PSString._add("memoryUsagePercent");
PSString._add("menuCustomization");
PSString._add("menuItemClass");
PSString._add("menuItemType");
PSString._add("mergeAlignedLayers");
PSString._add("mergeChannels");
PSString._add("mergeLayers", "mergeLayersNew");
PSString._add("oldMergeLayers", "mergeLayers");
PSString._add("mergeSpotChannel");
PSString._add("merge");
PSString._add("mergeVisible");
PSString._add("mergedLayers");
PSString._add("merged");
PSString._add("meshExtraData");
PSString._add("meshName");
PSString._add("meshPoints");
PSString._add("message");
PSString._add("method");
PSString._add("metadata");
PSString._add("metricsKern");
PSString._add("mezzotint");
PSString._add("mezzotintType");
PSString._add("middle");
PSString._add("midpoint");
PSString._add("midtoneLevels");
PSString._add("midtonesFuzziness");
PSString._add("midtonesLowerLimit");
PSString._add("midtonesUpperLimit");
PSString._add("midtones");
PSString._add("mix");
PSString._add("mixerPresetKind");
PSString._add("mixerPresetFileName");
PSString._add("millimetersUnit");
PSString._add("minDepth", "minimumDepth");
PSString._add("minDiameter", "minimumDiameter");
PSString._add("minDigits");
PSString._add("minRoundness", "minimumRoundness");
PSString._add("minScale", "minimumScale");
PSString._add("minutes");
PSString._add("minimum");
PSString._add("mismatchCMYK");
PSString._add("mismatchGray");
PSString._add("mismatchRGB");
PSString._add("missedKeywordAttr");
PSString._add("missing");
PSString._add("miterJoin");
PSString._add("miterLimit");
PSString._add("mmdd");
PSString._add("mmddyy");
PSString._add("modalStateChanged");
PSString._add("modalToolChangeKindMouse", "mouse");
PSString._add("modalToolChangeKindPaint", "paint");
PSString._add("modalToolChangeKindTool", "tool");
PSString._add("modeGray");
PSString._add("modeRGB");
PSString._add("mode");
PSString._add("mojiKumiName");
PSString._add("MojiKumiNone", "Photoshop6MojiKumiNone");
PSString._add("MojikumiTable1", "Photoshop6MojiKumiSet1");
PSString._add("MojikumiTable2", "Photoshop6MojiKumiSet2");
PSString._add("MojikumiTable3", "Photoshop6MojiKumiSet3");
PSString._add("MojikumiTable4", "Photoshop6MojiKumiSet4");
PSString._add("mojiZume");
PSString._add("monitorCompression");
PSString._add("monitorRGB");
PSString._add("monitorSetup");
PSString._add("monitor");
PSString._add("monochromatic");
PSString._add("monotone");
PSString._add("mosaicPlugin");
PSString._add("mosaic");
PSString._add("motionBlur");
PSString._add("motionTrackEffectParams");
PSString._add("moreAccurate");
PSString._add("move");
PSString._add("moveAllTime");
PSString._add("moveInTime");
PSString._add("moveKeyframes");
PSString._add("moveOutTime");
PSString._add("moveStartTime");
PSString._add("moveTo");
PSString._add("moveToolOnCommit");
PSString._add("moveTool");
PSString._add("moveWorkArea");
PSString._add("movieFrameReader");
PSString._add("MRUFolderSize");
PSString._add("multi72Color");
PSString._add("multi72Gray");
PSString._add("multiAdjustor");
PSString._add("multiNoCompositePS");
PSString._add("multichannelMode");
PSString._add("multichannel");
PSString._add("multiply");
PSString._add("muted");
PSString._add("muteVideo");
PSString._add("name");
PSString._add("navigatorPaletteOptions");
PSString._add("nearestNeighbor");
PSString._add("negative");
PSString._add("neonGlow");
PSString._add("negGaussClusters");
PSString._add("negGaussParams");
PSString._add("negGaussTolerance");
PSString._add("negSpaGaussTolerance");
PSString._add("netscapeGray");
PSString._add("networkEventSubscribe");
PSString._add("networkEventUnsubscribe");
PSString._add("neutralizeColor");
PSString._add("neutrals");
PSString._add("neverShowDebugger");
PSString._add("newDocPresetPrintResolution");
PSString._add("newDocPresetPrintScale");
PSString._add("newDocPresetScreenResolution");
PSString._add("newDocPresetScreenScale");
PSString._add("newDocumentViewCreated");
PSString._add("newFromClipboard");
PSString._add("newGuide");
PSString._add("newGuideLayout");
PSString._add("newGuidesFromTarget");
PSString._add("newPlacedLayer");
PSString._add("new");
PSString._add("newView");
PSString._add("next");
PSString._add("nextFrame");
PSString._add("nextKeyframe");
PSString._add("nikon105");
PSString._add("nikon");
PSString._add("noBreak");
PSString._add("noCompositePS");
PSString._add("noImage");
PSString._add("noReference");
PSString._add("no");
PSString._add("nodeConnection");
PSString._add("nodeMenuInitialize");
PSString._add("nodeMenu");
PSString._add("nodePluginInitialize");
PSString._add("nodePlugin");
PSString._add("noise");
PSString._add("noiseLock");
PSString._add("noiseReduction");
PSString._add("nonAffineTransform");
PSString._add("nonImageData");
PSString._add("nonLinear");
PSString._add("none");
PSString._add("noneUnit");
PSString._add("normalPath");
PSString._add("normal");
PSString._add("noteLocation");
PSString._add("notePaper");
PSString._add("notify");
PSString._add("NTSCDV");
PSString._add("NTSCDVWide");
PSString._add("NTSCD1");
PSString._add("NTSCD1Wide");
PSString._add("NTSCD1Square");
PSString._add("NTSCD1WideSquare");
PSString._add("nudge");
PSString._add("null");
PSString._add("nullFrameReader");
PSString._add("numLights");
PSString._add("numberOfCacheLevels");
PSString._add("numberOfChannels");
PSString._add("numberOfChildren");
PSString._add("numberOfDocuments");
PSString._add("numberOfGenerators");
PSString._add("numberOfGuides");
PSString._add("numberOfLayers");
PSString._add("numberOfLevels");
PSString._add("numberOfPaths");
PSString._add("numberOfRipples");
PSString._add("numberOfSiblings");
PSString._add("number");
PSString._add("numberUnit");
PSString._add("numerator");
PSString._add("numericSequenceFrameReader");
PSString._add("numericSequenceSpec");
PSString._add("nynorskNorwegianLanguage");
PSString._add("objectName");
PSString._add("objectReference");
PSString._add("object");
PSString._add("obscured");
PSString._add("obsoleteTextLayer");
PSString._add("oceanRipple");
PSString._add("odd");
PSString._add("off");
PSString._add("offset");
PSString._add("ok");
PSString._add("oldStyle");
PSString._add("oldText");
PSString._add("oldTextAge");
PSString._add("onACurve");
PSString._add("onError");
PSString._add("onOff");
PSString._add("on");
PSString._add("oneDigit");
PSString._add("opacityClass");
PSString._add("opacity");
PSString._add("opacityFloat");
PSString._add("openAs");
PSString._add("openAsSmartObject");
PSString._add("openedDocument");
PSString._add("open");
PSString._add("openNewDocsAsTabs");
PSString._add("opticalKern");
PSString._add("optimized");
PSString._add("optionalKeywordAttr");
PSString._add("orange");
PSString._add("ordinal");
PSString._add("ordinals");
PSString._add("orientation");
PSString._add("origin");
PSString._add("originalAddressAttr");
PSString._add("originalHeader");
PSString._add("originalTransmissionReference");
PSString._add("oriyaLanguage");
PSString._add("ornaments");
PSString._add("osPrintInfo", "osSpecificPrintInfo");
PSString._add("otbaseline");
PSString._add("otherCursors");
PSString._add("out");
PSString._add("outFromCenter");
PSString._add("outOfGamut");
PSString._add("outerBevel");
PSString._add("outerGlow");
PSString._add("output");
PSString._add("outsetFrame");
PSString._add("outside");
PSString._add("outTime");
PSString._add("overlap");
PSString._add("overlay");
PSString._add("Overprint", "overprint");
PSString._add("overprintColors");
PSString._add("overrideNode");
PSString._add("overrideOpen");
PSString._add("overridePrinter");
PSString._add("overrideSave");
PSString._add("pInherits");
PSString._add("packageFile");
PSString._add("page");
PSString._add("pageFormat");
PSString._add("pageNumber");
PSString._add("page3DNumber");
PSString._add("pagePosCentered");
PSString._add("pagePosTopLeft");
PSString._add("pagePosition");
PSString._add("pageSetup");
PSString._add("paintDaubs");
PSString._add("paint");
PSString._add("paintDynamicsLock");
PSString._add("paintStroke");
PSString._add("paintType");
PSString._add("paintbrushEraser");
PSString._add("paintbrushTool");
PSString._add("paintingCursors");
PSString._add("PALD1DV");
PSString._add("PALD1DVWide");
PSString._add("PALD1DVSquare");
PSString._add("PALD1DVWideSquare");
PSString._add("palSecam");
PSString._add("paletteFile");
PSString._add("paletteKnife");
PSString._add("palette");
PSString._add("panAngle");
PSString._add("panaVision");
PSString._add("PanelBrightnessDarkGray", "kPanelBrightnessDarkGray");
PSString._add("PanelBrightnessMediumGray", "kPanelBrightnessMediumGray");
PSString._add("PanelBrightnessLightGray", "kPanelBrightnessLightGray");
PSString._add("PanelBrightnessOriginal", "kPanelBrightnessOriginal");
PSString._add("panelList");
PSString._add("panorama");
PSString._add("paperBrightness");
PSString._add("paperWhite");
PSString._add("paragraphStyleRange");
PSString._add("paragraphStyle");
PSString._add("characterStyle");
PSString._add("paraStyleSheetName");
PSString._add("parentID");
PSString._add("parentIndex");
PSString._add("parentName");
PSString._add("passThrough");
PSString._add("passwords");
PSString._add("pasteEffects");
PSString._add("pasteInto");
PSString._add("pasteKeyframes");
PSString._add("pasteNewDoc", "pasteNewDocument");
PSString._add("pasteOutside");
PSString._add("paste");
PSString._add("patch");
PSString._add("patchContentAware");
PSString._add("patchMode");
PSString._add("patchModeType");
PSString._add("patchNormal");
PSString._add("patchSelection");
PSString._add("RecomposeMode", "recomposeMode");
PSString._add("recomposeSelection");
PSString._add("reorderEffects", "reorderFX");
PSString._add("patchAdaptationType");
PSString._add("patchAdaptation");
PSString._add("patchStructureAdaptation", "patchStructureAdapt");
PSString._add("TransformOnDrop", "transformOnDrop");
PSString._add("InitialCorner", "initialCorner");
PSString._add("FinalCorner", "finalCorner");
PSString._add("patchwork");
PSString._add("pathBlur");
PSString._add("pathBounds");
PSString._add("pathClass");
PSString._add("pathComponentSelectTool");
PSString._add("pathComponent");
PSString._add("pathComponents");
PSString._add("pathContents");
PSString._add("pathKind");
PSString._add("pathName");
PSString._add("pathOperation");
PSString._add("pathPoint");
PSString._add("pathReference");
PSString._add("path");
PSString._add("pathTypeAlignTo");
PSString._add("pathTypeAlignment");
PSString._add("pathTypeEffect");
PSString._add("pathTypeSpacing");
PSString._add("pathsPaletteOptions");
PSString._add("patternDither");
PSString._add("patternFillClass");
PSString._add("patternFill");
PSString._add("patternKey");
PSString._add("patternLayer");
PSString._add("patternOverlay");
PSString._add("patternStampTool");
PSString._add("pattern");
PSString._add("pattern2");
PSString._add("pattern3");
PSString._add("pattern4");
PSString._add("pauseForAudio");
PSString._add("pause");
PSString._add("pdfxStandard");
PSString._add("pdfx1a2001");
PSString._add("pdfx1a2003");
PSString._add("pdfx32001");
PSString._add("pdfx32003");
PSString._add("pdfx42008");
PSString._add("pdfx42010");
PSString._add("pdfCompatibilityLevel");
PSString._add("pdf13");
PSString._add("pdf14");
PSString._add("pdf15");
PSString._add("pdf16");
PSString._add("pdf17");
PSString._add("pdf18");
PSString._add("pdfPreserveEditing");
PSString._add("pdfEmbedThumbnails");
PSString._add("pdfOptimizeForWeb");
PSString._add("pdfViewAfterSave");
PSString._add("pdfSubsetFontThreshold");
PSString._add("pdfDownSample");
PSString._add("pdfDownsampleResolution");
PSString._add("pdfThresholdResolution");
PSString._add("pdfTileSize");
PSString._add("pdfCompressionType");
PSString._add("pdfConvert16To8");
PSString._add("pdfPrinterTrimMarks");
PSString._add("pdfPrinterRegistrationMarks");
PSString._add("pdfPrinterColorBars");
PSString._add("pdfPrinterPageInfo");
PSString._add("pdfPrinterMarkType");
PSString._add("pdfMarkWeight");
PSString._add("pdfMarkOffset");
PSString._add("pdfTopBleed");
PSString._add("pdfBottomBleed");
PSString._add("pdfLeftBleed");
PSString._add("pdfRightBleed");
PSString._add("pdfColorConversion");
PSString._add("pdfDestinationProfileDescription");
PSString._add("pdfIncludeProfile");
PSString._add("pdfOutputCondition");
PSString._add("pdfOutputConditionIdentifier");
PSString._add("pdfRegistryName");
PSString._add("pdfRequireOpenPassword");
PSString._add("pdfOpenPassword");
PSString._add("pdfRequirePermissionPassword");
PSString._add("pdfPermissionPassword");
PSString._add("pdfPrintingAllowed");
PSString._add("pdfChangesAllowed");
PSString._add("pdfEnableCopying");
PSString._add("pdfEnableReaders");
PSString._add("pdfEnablePlaintextMetadata");
PSString._add("pdfPresetFilename");
PSString._add("pdfSelection");
PSString._add("penTool");
PSString._add("pencilEraser");
PSString._add("pencilTool");
PSString._add("pencilWidth");
PSString._add("percentUnit");
PSString._add("perceptual");
PSString._add("performance");
PSString._add("persistentScreenMode");
PSString._add("perspectiveCrop");
PSString._add("perspectiveCropTool");
PSString._add("perspectiveIndex");
PSString._add("perspective");
PSString._add("phase");
PSString._add("photoBinAutoHide");
PSString._add("phosphorsCustomPhosphors");
PSString._add("phosphors");
PSString._add("photoFilter");
PSString._add("photocopy");
PSString._add("photomerge");
PSString._add("photoshop20Format");
PSString._add("photoshop35Format");
PSString._add("photoshopDCS2Format");
PSString._add("photoshopDCSFormat");
PSString._add("photoshopEPSFormat");
PSString._add("photoshopPDFFormat");
PSString._add("photoshopPicker");
PSString._add("physics");
PSString._add("picasUnit");
PSString._add("pickCMYK");
PSString._add("pickGray");
PSString._add("pickHSB");
PSString._add("pickLab");
PSString._add("pickOptions");
PSString._add("pickRGB");
PSString._add("pickWeb");
PSString._add("pickerID");
PSString._add("pickerKind");
PSString._add("pickerKindType");
PSString._add("pickingForeground");
PSString._add("picturePackage");
PSString._add("pillowEmboss");
PSString._add("pinLight");
PSString._add("pinch");
PSString._add("pixelDoubling");
PSString._add("pixelLength");
PSString._add("pixelHeight");
PSString._add("pixelPaintFormat");
PSString._add("pixelPaintSize1");
PSString._add("pixelPaintSize2");
PSString._add("pixelPaintSize3");
PSString._add("pixelPaintSize4");
PSString._add("pixelPaintSize");
PSString._add("pixel");
PSString._add("pixelWidth");
PSString._add("pixelsAcross");
PSString._add("pixelsDown");
PSString._add("pixelsUnit");
PSString._add("placeEnum");
PSString._add("placeEvent");
PSString._add("placeMeasurementScaleMarker");
PSString._add("placed");
PSString._add("placedLayerConvertToEmbedded");
PSString._add("placedLayerConvertToLinked");
PSString._add("placedLayerMakeCopy");
PSString._add("placedLayerEditContents");
PSString._add("placedLayerEmbedAll");
PSString._add("placedLayerExportContents");
PSString._add("placedLayerRelinkToFile");
PSString._add("placedLayerRelinkToLibraries");
PSString._add("placedLayerReplaceContents");
PSString._add("placedLayerReplaceMissing");
PSString._add("placedLayerRevealInOS");
PSString._add("placedLayerUpdateAllModified");
PSString._add("placedLayerUpdateModified");
PSString._add("placeRasterSmartObject");
PSString._add("placement");
PSString._add("planar");
PSString._add("plaster");
PSString._add("plasticWrap");
PSString._add("platform");
PSString._add("play");
PSString._add("playbackOptions");
PSString._add("playbackStrokeFromFile");
PSString._add("pluginFolder");
PSString._add("pluginPicker");
PSString._add("pluginPrefs");
PSString._add("pluginsScratchDiskPreferences");
PSString._add("point16");
PSString._add("point");
PSString._add("pointillize");
PSString._add("points");
PSString._add("pointsUnit");
PSString._add("polar");
PSString._add("polarToRect");
PSString._add("policyCMYK");
PSString._add("policyGray");
PSString._add("policyRGB");
PSString._add("policy");
PSString._add("polishLanguage");
PSString._add("polySelTool");
PSString._add("polygon");
PSString._add("polygonTool");
PSString._add("pondRipples");
PSString._add("posGaussClusters");
PSString._add("posGaussParams");
PSString._add("posGaussTolerance");
PSString._add("posSpaGaussTolerance");
PSString._add("position");
PSString._add("postScriptColor");
PSString._add("posterEdges");
PSString._add("posterization");
PSString._add("posterize");
PSString._add("power");
PSString._add("preciseMatte");
PSString._add("precise");
PSString._add("predefinedColors");
PSString._add("preferBuiltin");
PSString._add("preferACRForHDRToning");
PSString._add("preferEnhancedTIFF");
PSString._add("preferXMPFromACR");
PSString._add("preferencesChanged");
PSString._add("preferencesClass");
PSString._add("preferencesFolder");
PSString._add("preferences");
PSString._add("preferredKinsokuOrder");
PSString._add("prefix");
PSString._add("premultipliedBlack");
PSString._add("premultipliedColor");
PSString._add("premultipliedWhite");
PSString._add("present");
PSString._add("presentation");
PSString._add("fullpath", "fullPath");
PSString._add("preserveAdditional");
PSString._add("preserveLuminosity");
PSString._add("preserve");
PSString._add("preserveShape");
PSString._add("preserveTransparency");
PSString._add("presetManagerCommand", "presetManager");
PSString._add("preset");
PSString._add("preset1");
PSString._add("preset2");
PSString._add("preset3");
PSString._add("preset4");
PSString._add("preset5");
PSString._add("presetFileMode");
PSString._add("presetFileName");
PSString._add("presetFileSpec");
PSString._add("presetLightName");
PSString._add("presetKind");
PSString._add("presetKindEnum");
PSString._add("presetKindType");
PSString._add("presetKindCustom");
PSString._add("presetKindDefault");
PSString._add("presetKindFactory");
PSString._add("presetKindUserDefined");
PSString._add("pressure");
PSString._add("pressureCaps");
PSString._add("previewBlack");
PSString._add("previewCMYKEnum");
PSString._add("previewCMYK");
PSString._add("previewCMYKType");
PSString._add("previewCMY");
PSString._add("previewCyan");
PSString._add("previewFullSize");
PSString._add("previewIcon");
PSString._add("previewMacThumbnail");
PSString._add("previewMagenta");
PSString._add("previewOff");
PSString._add("preview");
PSString._add("previewWinThumbnail");
PSString._add("previewYellow");
PSString._add("previewsQuery");
PSString._add("previous");
PSString._add("previousFrame");
PSString._add("previousKeyframe");
PSString._add("primaries");
PSString._add("printBBUnitsInches", "printBBInches");
PSString._add("printBBUnitsMM", "printBBmm");
PSString._add("printBBUnitsPoints", "printBBPoints");
PSString._add("printBBUnitsType", "printBleedBorderUnits");
PSString._add("printBleedWidth");
PSString._add("printBleedUnits");
PSString._add("printBorderFloat", "printBorderThickness");
PSString._add("printBorderUnits");
PSString._add("printColorHandling");
PSString._add("printCopies");
PSString._add("printCurrentPrinter");
PSString._add("printKeys");
PSString._add("printKeysType");
PSString._add("printNotManaged");
PSString._add("printOne", "printOneCopy");
PSString._add("printOptions");
PSString._add("printOutput");
PSString._add("printPhotoshopManaged", "photoshopManaged");
PSString._add("printPrintersList", "printerList");
PSString._add("printPrinterManaged", "printerManaged");
PSString._add("printProofSetup");
PSString._add("printViewProofSetup");
PSString._add("printResolution", "printerResolution");
PSString._add("printSeparations");
PSString._add("printSettings");
PSString._add("printSixteenBitData", "printSixteenBit");
PSString._add("printSize");
PSString._add("printSizeUnits");
PSString._add("print");
PSString._add("printStyleInfo", "printOutputOptions");
PSString._add("printStyleResolution");
PSString._add("printToFit");
PSString._add("printerName");
PSString._add("printingInksSetup");
PSString._add("processSerialNumber");
PSString._add("profileMismatch");
PSString._add("profileSetup");
PSString._add("profile");
PSString._add("profileToProfile");
PSString._add("progressDone");
PSString._add("progressFinish");
PSString._add("progressStart");
PSString._add("progressStartTask");
PSString._add("progressTotal");
PSString._add("progressUpdate");
PSString._add("progressive");
PSString._add("projection");
PSString._add("proofBlack");
PSString._add("proofCMYK");
PSString._add("proofCMY");
PSString._add("proofCustom");
PSString._add("proofCyan");
PSString._add("proofDeuteranopia");
PSString._add("proofInkBlack");
PSString._add("proofMacintosh");
PSString._add("proofMagenta");
PSString._add("proofMonitor");
PSString._add("proofPaperWhite");
PSString._add("proofProtanopia");
PSString._add("proofSetup");
PSString._add("proofWindows");
PSString._add("proofYellow");
PSString._add("property");
PSString._add("proportionalLining");
PSString._add("proportionalMetrics");
PSString._add("proportionalNumbers");
PSString._add("proportionalOldStyle");
PSString._add("proportionalScaling");
PSString._add("proportionalWidthForm");
PSString._add("protectTexture");
PSString._add("protectTextureLock");
PSString._add("provinceState");
PSString._add("publicDomain");
PSString._add("punjabiLanguage");
PSString._add("purgeItem");
PSString._add("purge");
PSString._add("purity");
PSString._add("purple");
PSString._add("pushDown");
PSString._add("pushIn");
PSString._add("pushOutFirst");
PSString._add("pushOut");
PSString._add("pushRight");
PSString._add("pushToDesignLibraries");
PSString._add("KinsokuNone", "None");
PSString._add("KinsokuHard", "Hard");
PSString._add("KinsokuSoft", "Soft");
PSString._add("pyramids");
PSString._add("quadAnchor");
PSString._add("quadCenterState");
PSString._add("quadCorner0");
PSString._add("quadCorner1");
PSString._add("quadCorner2");
PSString._add("quadCorner3");
PSString._add("quadrilateral");
PSString._add("quads");
PSString._add("quadtone");
PSString._add("quality");
PSString._add("quarterWidthForm");
PSString._add("queryAlways");
PSString._add("queryAsk");
PSString._add("queryNever");
PSString._add("queryState");
PSString._add("quickFix");
PSString._add("quickMaskStateChanged");
PSString._add("quickMask");
PSString._add("quickSelectAutoEnhance", "autoEnhance");
PSString._add("quickSelectBrushSize");
PSString._add("quickSelectSampleAllLayers");
PSString._add("quickSelectMode");
PSString._add("quickSelectSpread");
PSString._add("quickSelectStickiness");
PSString._add("quickSelectTool");
PSString._add("quickTimeAvail", "quickTimeInstalled");
PSString._add("detailBoost");
PSString._add("refineEdgeBrushTool");
PSString._add("quit");
PSString._add("radialBlur");
PSString._add("radial");
PSString._add("radialDistort");
PSString._add("radii");
PSString._add("radius");
PSString._add("rainbowEffect");
PSString._add("randomSeed");
PSString._add("randomSeedForced");
PSString._add("random");
PSString._add("range");
PSString._add("rasterizeAll");
PSString._add("rasterizeAllPlaced");
PSString._add("rasterizeContent");
PSString._add("rasterizeImageStack");
PSString._add("rasterizeItem");
PSString._add("rasterizeLayer");
PSString._add("rasterizeLayerStyle");
PSString._add("vectorStrokeToFill");
PSString._add("rasterizeLinked");
PSString._add("rasterizePlaced");
PSString._add("rasterizeShape");
PSString._add("rasterize");
PSString._add("rasterizeTypeLayer");
PSString._add("rasterizeVectorMask");
PSString._add("rasterizeVideo");
PSString._add("ratio");
PSString._add("rational");
PSString._add("rationalPoint");
PSString._add("rawData");
PSString._add("rawFormat");
PSString._add("rawPixmapFilePath");
PSString._add("readableFileExtensions");
PSString._add("readBytes");
PSString._add("readMessages");
PSString._add("readStatus");
PSString._add("recapture");
PSString._add("recentFiles");
PSString._add("recentFilesAsStrings");
PSString._add("record");
PSString._add("recordMeasurements");
PSString._add("rect16");
PSString._add("rect");
PSString._add("rectToPolar");
PSString._add("rectangle");
PSString._add("rectangleTool");
PSString._add("redBlackPoint");
PSString._add("redEyeTool");
PSString._add("redFloat");
PSString._add("redGamma");
PSString._add("redEyeTool");
PSString._add("red");
PSString._add("redWhitePoint");
PSString._add("redX");
PSString._add("redY");
PSString._add("redo");
PSString._add("redoType");
PSString._add("redrawComplete");
PSString._add("reds");
PSString._add("referenceRect");
PSString._add("refineEdgeAutoRadius");
PSString._add("refineEdgeChoke");
PSString._add("refineEdgeContrast", "refineEdgeBorderContrast");
PSString._add("refineEdgeDecontaminate");
PSString._add("refineEdgeDeconWeight");
PSString._add("refineEdgeFeatherRadius");
PSString._add("refineEdgeOutput");
PSString._add("refineEdgeSmooth");
PSString._add("refineEdgeRadius", "refineEdgeBorderRadius");
PSString._add("refineSelectionEdge");
PSString._add("reflected");
PSString._add("regionCode");
PSString._add("registrationMarks");
PSString._add("relative");
PSString._add("relief");
PSString._add("reloadFrame");
PSString._add("remapFonts");
PSString._add("remixMode");
PSString._add("remixModeType");
PSString._add("remixMove");
PSString._add("remixExtend");
PSString._add("remote");
PSString._add("removeBlackMatte");
PSString._add("removeClipMotionProperties");
PSString._add("removeFromSelection");
PSString._add("removeJPEGArtifact");
PSString._add("removeLayerMask");
PSString._add("removeWhiteMatte");
PSString._add("rename");
PSString._add("renderFlame");
PSString._add("renderFidelity");
PSString._add("renderPictureFrame");
PSString._add("renderSceneReferred");
PSString._add("renderTree");
PSString._add("repeatEdgePixels");
PSString._add("repeat");
PSString._add("repeatLock");
PSString._add("replaceColor");
PSString._add("replaceExisting");
PSString._add("replaceFootage");
PSString._add("replace");
PSString._add("replaceAudioClip");
PSString._add("replaceSubstitutes");
PSString._add("representation");
PSString._add("resample");
PSString._add("reserveMemory");
PSString._add("reservoirChannelNumber");
PSString._add("reservoirChannels");
PSString._add("reservoirCols");
PSString._add("reservoirImageMode");
PSString._add("reservoirSampleData");
PSString._add("reservoirRows");
PSString._add("reservoirState");
PSString._add("resetFromComp");
PSString._add("resetGPUStats");
PSString._add("resetPalettes");
PSString._add("resetMenus");
PSString._add("resetShortcuts");
PSString._add("resetScaleFactor");
PSString._add("reset");
PSString._add("resetDocumentChanged");
PSString._add("resetDocumentFormat", "resetDocumentFormatStr");
PSString._add("resize");
PSString._add("resizePastePlace");
PSString._add("resizeWindowsOnZoom");
PSString._add("resolution");
PSString._add("resourceID");
PSString._add("response");
PSString._add("restoreAllFrames");
PSString._add("restoreFrame");
PSString._add("reshuffle");
PSString._add("retainHeader");
PSString._add("reticulation");
PSString._add("returnIDAttr");
PSString._add("revealAll");
PSString._add("revealCurrentPath");
PSString._add("revealSelection");
PSString._add("reverse");
PSString._add("revert");
PSString._add("rightAki");
PSString._add("right");
PSString._add("rightsUsage");
PSString._add("rigidTransformType", "rigidType");
PSString._add("rigidOriginalVertexArray", "originalVertexArray");
PSString._add("rigidDeformedVertexArray", "deformedVertexArray");
PSString._add("rigidIndexArray", "indexArray");
PSString._add("rigidPinOffsets", "pinOffsets");
PSString._add("rigidFinalPins", "posFinalPins");
PSString._add("rigidExpansion", "meshExpansion");
PSString._add("rigidMeshQuality", "meshQuality");
PSString._add("rigidPinVertexIndices", "pinVertexIndices");
PSString._add("rigidTransform");
PSString._add("blurbTransformType", "blurbType");
PSString._add("blurbTransform");
PSString._add("perspectiveWarpMode");
PSString._add("perspectiveWarpQuad");
PSString._add("perspectiveWarpSide");
PSString._add("perspectiveWarpTransform");
PSString._add("rippleMagnitude");
PSString._add("rippleSize");
PSString._add("ripple");
PSString._add("rollover");
PSString._add("romanRotationInVertical");
PSString._add("roman");
PSString._add("romanianLanguage");
PSString._add("rotateAll");
PSString._add("rotateEventEnum");
PSString._add("rotate");
PSString._add("rotated");
PSString._add("rotateTool");
PSString._add("rotation");
PSString._add("rotationCaps");
PSString._add("rotationDirection");
PSString._add("rotoscopingPreferences");
PSString._add("roughness");
PSString._add("roughPastels");
PSString._add("roundCap");
PSString._add("roundJoin");
PSString._add("round");
PSString._add("roundness");
PSString._add("roundedRectangleTool");
PSString._add("roundnessDynamics");
PSString._add("roundness");
PSString._add("rowCount");
PSString._add("rowGutter");
PSString._add("rowHeight");
PSString._add("rowMajorOrder");
PSString._add("ruby");
PSString._add("rulerCm");
PSString._add("rulerInches");
PSString._add("rulerMm");
PSString._add("rulerOriginH");
PSString._add("rulerOriginV");
PSString._add("rulerPercent");
PSString._add("rulerPicas");
PSString._add("rulerPixels");
PSString._add("rulerPoints");
PSString._add("rulerTool");
PSString._add("rulerUnits");
PSString._add("rulersVisibility");
PSString._add("rumanianLanguage");
PSString._add("russianLanguage");
PSString._add("sInt16");
PSString._add("sInt32");
PSString._add("sInt64");
PSString._add("sMFloat");
PSString._add("sMInt");
PSString._add("sRGB");
PSString._add("sample");
PSString._add("safe");
PSString._add("sample3x3");
PSString._add("sample5x5");
PSString._add("samplePoint");
PSString._add("sampledBlur", "shapeBlur");
PSString._add("sampledBrush");
PSString._add("sampledData");
PSString._add("saturate");
PSString._add("saturation");
PSString._add("saturationTool");
PSString._add("saveAndClose");
PSString._add("saveBrushFile");
PSString._add("saveStyleFile");
PSString._add("saveComposite");
PSString._add("saveForCCLibrariesElement");
PSString._add("saveForWeb");
PSString._add("saveHistoryTo");
PSString._add("saveHistoryToType");
PSString._add("savePaletteLocations");
PSString._add("savePaths");
PSString._add("savePyramids");
PSString._add("save");
PSString._add("saveStage");
PSString._add("saveStageType");
PSString._add("saveStageBegin", "saveBegin");
PSString._add("saveStageEndSucceed", "saveSucceeded");
PSString._add("saveStageEndFailed", "saveFailed");
PSString._add("saveTransparency");
PSString._add("saveWorkspace");
PSString._add("saved");
PSString._add("savedBrightnessLevel");
PSString._add("savingFilesPreferences");
PSString._add("scrubbyZoom");
PSString._add("Z3DPreferences", "z3DPreferences");
PSString._add("saving");
PSString._add("scaleEffectsEvent");
PSString._add("scaleEffects");
PSString._add("scaleHorizontal");
PSString._add("scaleKeyframes");
PSString._add("scale");
PSString._add("scaleStyles");
PSString._add("scaleVertical");
PSString._add("scaling");
PSString._add("scans");
PSString._add("scatterDynamics");
PSString._add("scatterDynamicsLock");
PSString._add("scatter");
PSString._add("sceneCollage");
PSString._add("sceneGroup", "sceneSection");
PSString._add("scitexCTFormat");
PSString._add("scratchDisks");
PSString._add("scratchDiskPreferences");
PSString._add("screenCircle");
PSString._add("screenDot");
PSString._add("screenFile");
PSString._add("screenLine");
PSString._add("screenModeChanged");
PSString._add("screenMode");
PSString._add("screenModeFullScreen");
PSString._add("screenModeFullScreenWithMenubar");
PSString._add("screenModeStandard");
PSString._add("screen");
PSString._add("screenType");
PSString._add("scriptListenerResult");
PSString._add("seconds");
PSString._add("secondsUnit");
PSString._add("sectionH");
PSString._add("select");
PSString._add("selected");
PSString._add("selectAllLayers");
PSString._add("selectNoLayers");
PSString._add("selectSimilarLayers");
PSString._add("selectedAreas");
PSString._add("selectedChannelChanged");
PSString._add("selectedItems");
PSString._add("selectedLayerChanged");
PSString._add("selectedLayer");
PSString._add("selectedMeasurements");
PSString._add("selectedSourceAreas");
PSString._add("selectionBrushTool");
PSString._add("selectionClass");
PSString._add("selectionEnum");
PSString._add("selectionMode");
PSString._add("selectionModifier");
PSString._add("selectionModifierType");
PSString._add("selectModifyAtCanvasBounds", "selectionModifyEffectAtCanvasBounds");
PSString._add("selectModifyContractAtCanvasBounds", "selectionModifyContractEffectAtCanvasBounds");
PSString._add("selectModifyExpandAtCanvasBounds", "selectionModifyExpandEffectAtCanvasBounds");
PSString._add("selectModifyFeatherAtCanvasBounds", "selectionModifyFeatherEffectAtCanvasBounds");
PSString._add("selectModifySmoothAtCanvasBounds", "selectionModifySmoothEffectAtCanvasBounds");
PSString._add("selectionOrder");
PSString._add("selectionOutputNative");
PSString._add("selectionOutputToSelection");
PSString._add("selectionOutputToUserMask");
PSString._add("selectionOutputToNewSheet");
PSString._add("selectionOutputToNewSheetAndMask");
PSString._add("selectionOutputToNewDocument");
PSString._add("selectionOutputToNewDocumentAndMask");
PSString._add("selection");
PSString._add("selectiveColor");
PSString._add("selective");
PSString._add("selectKeyframe");
PSString._add("selectLinkedLayers");
PSString._add("sendDocumentThumbnailToNetworkClient");
PSString._add("sendLayerThumbnailToNetworkClient");
PSString._add("sendLayerShapeToNetworkClient");
PSString._add("sendDocumentInfoToNetworkClient");
PSString._add("sendJSONToNetworkClient");
PSString._add("separationSetup");
PSString._add("separationTables");
PSString._add("separations");
PSString._add("sequence");
PSString._add("serbianLanguage");
PSString._add("serialString");
PSString._add("sessionID");
PSString._add("session");
PSString._add("set");
PSString._add("setClipMotionProperties");
PSString._add("setCurrentTime");
PSString._add("setOverscrollMode");
PSString._add("setPanZoom");
PSString._add("setPlacedLayerComp");
PSString._add("setTransitionDuration");
PSString._add("shade");
PSString._add("shadingIntensity");
PSString._add("shadingNoise");
PSString._add("shadingShape");
PSString._add("shadowColor");
PSString._add("shadowIntensity");
PSString._add("shadowLevels");
PSString._add("shadowMode");
PSString._add("shadowOpacity");
PSString._add("shadows");
PSString._add("shadowsFuzziness");
PSString._add("shadowsUpperLimit");
PSString._add("shallow");
PSString._add("shapeClass");
PSString._add("shapeClipboardOperation");
PSString._add("shapeCopyShapeAll");
PSString._add("shapeCopyFill");
PSString._add("shapeCopyStroke");
PSString._add("shapeCopyStrokeDetails");
PSString._add("shapeCopyStrokeAll");
PSString._add("shapePasteShapeAll");
PSString._add("shapePasteFill");
PSString._add("shapePasteStroke");
PSString._add("shapePasteStrokeDetails");
PSString._add("shapePasteStrokeAll");
PSString._add("shapeOperation");
PSString._add("shape");
PSString._add("shapeStyle");
PSString._add("shapeburst");
PSString._add("sharpenEdges");
PSString._add("sharpenMethod");
PSString._add("sharpenMore");
PSString._add("sharpen");
PSString._add("sharpenTool");
PSString._add("sharpness");
PSString._add("shearEd");
PSString._add("shearPoints");
PSString._add("shearSt");
PSString._add("shear");
PSString._add("sheetStyle");
PSString._add("shiftKey");
PSString._add("shiftKeyToolSwitch");
PSString._add("shortFloat");
PSString._add("shortInteger");
PSString._add("shortLines");
PSString._add("shortNames");
PSString._add("shortStrokes");
PSString._add("showInDialog");
PSString._add("showAll");
PSString._add("ShowAllFilterGalleryEntries", "showAllFilterGalleryEntries");
PSString._add("showBBox");
PSString._add("showCJKFeatures");
PSString._add("defaultComposer", "defaultTextInterface");
PSString._add("AdvancedCJKComposer", "advancedAsianInterface");
PSString._add("ComplexScriptComposer", "middleEasternInterface");
PSString._add("composerChoice", "textComposerChoice");
PSString._add("textCompMode");
PSString._add("showColorPicker");
PSString._add("showComboFXPalette");
PSString._add("showDirectories");
PSString._add("showEffectsPalette");
PSString._add("showEnglishFontNames");
PSString._add("showExternalUI");
PSString._add("showFileBrowserPalette");
PSString._add("showFiltersPalette");
PSString._add("showHelpPalette");
PSString._add("showHideOptions");
PSString._add("showHistogramPalette");
PSString._add("showHistoryPalette");
PSString._add("showInfoPalette");
PSString._add("showLayersPalette");
PSString._add("showMenuColors");
PSString._add("showMiniBridge");
PSString._add("showMoreOptions");
PSString._add("showNavigatorPalette");
PSString._add("showNone");
PSString._add("showPaletteBin");
PSString._add("showPanelOnShapeCreation");
PSString._add("showQuickStartPalette");
PSString._add("showRecipesPalette");
PSString._add("showSearchPalette");
PSString._add("showSliceNumbers");
PSString._add("show");
PSString._add("showStylesPalette");
PSString._add("showSwatchesPalette");
PSString._add("showHUD");
PSString._add("showHUDState");
PSString._add("showHUDNever");
PSString._add("showHUDTopLeft");
PSString._add("showHUDTopRight");
PSString._add("showHUDBottomLeft");
PSString._add("showHUDBottomRight");
PSString._add("showToolTips");
PSString._add("showTransparency");
PSString._add("sides");
PSString._add("similar");
PSString._add("simplifyLayer");
PSString._add("single72Color");
PSString._add("single72Gray");
PSString._add("singleColumn");
PSString._add("singleNoCompositePS");
PSString._add("singleRow");
PSString._add("singleWordJustification");
PSString._add("size");
PSString._add("sizeSelector");
PSString._add("skewEffect");
PSString._add("skew");
PSString._add("skinTone");
PSString._add("sliceBGColor", "sliceBackgroundColor");
PSString._add("sliceBGType", "sliceBackgroundType");
PSString._add("sliceColor");
PSString._add("sliceFromLayer");
PSString._add("sliceImageType");
PSString._add("sliceSelectTool");
PSString._add("slice");
PSString._add("sliceTool");
PSString._add("sliceType");
PSString._add("slicesAcross");
PSString._add("slicesDown");
PSString._add("slopeLimitMatte");
PSString._add("slot");
PSString._add("slovakLanguage");
PSString._add("slovenianLanguage");
PSString._add("smallCaps");
PSString._add("small");
PSString._add("smartBlurModeEdgeOnly");
PSString._add("smartBlurModeNormal");
PSString._add("smartBlurModeOverlayEdge");
PSString._add("smartBlurMode");
PSString._add("smartBlurQualityHigh");
PSString._add("smartBlurQualityLow");
PSString._add("smartBlurQualityMedium");
PSString._add("smartBlurQuality");
PSString._add("smartBlur");
PSString._add("smartFilterEnableAll");
PSString._add("smartGuidesColor");
PSString._add("smartGuidesCustomColor");
PSString._add("smartGuidesVisibility");
PSString._add("smartObject");
PSString._add("smartQuotes");
PSString._add("smartSharpen");
PSString._add("smartSharpenPreviousSettings");
PSString._add("smoothCorners");
PSString._add("smoothIndents");
PSString._add("smooth");
PSString._add("smoothing");
PSString._add("smoothingLock");
PSString._add("smoothness");
PSString._add("smudgeStick");
PSString._add("smudgeTool");
PSString._add("snapAll");
PSString._add("snapNone");
PSString._add("snap");
PSString._add("snapToDocBounds");
PSString._add("snapToGrid");
PSString._add("snapToGuides");
PSString._add("snapToLayerBounds");
PSString._add("snapToSlices");
PSString._add("snapshotClass");
PSString._add("snapshotEnum");
PSString._add("snapshotInitial");
PSString._add("softLight");
PSString._add("softMatte");
PSString._add("softness");
PSString._add("solarize");
PSString._add("solid");
PSString._add("solidColorLayer");
PSString._add("solidColor");
PSString._add("solidFill");
PSString._add("solidFillMulti");
PSString._add("soundAnnotTool");
PSString._add("source2");
PSString._add("sourceFolder");
PSString._add("sourceImport");
PSString._add("sourceMode");
PSString._add("sourceModeType");
PSString._add("sourceOpenFiles");
PSString._add("source");
PSString._add("spaceAfter");
PSString._add("spaceBefore");
PSString._add("space");
PSString._add("spacing");
PSString._add("spanishLanguage");
PSString._add("spatter");
PSString._add("specialInstructions");
PSString._add("spectrum");
PSString._add("speed");
PSString._add("spellCheck");
PSString._add("spherical");
PSString._add("spherizeMode");
PSString._add("spherize");
PSString._add("spin");
PSString._add("splitChannels");
PSString._add("splitHorizontalIn");
PSString._add("splitHorizontalOut");
PSString._add("splitVerticalIn");
PSString._add("splitVerticalOut");
PSString._add("splitVideoLayer");
PSString._add("sponge");
PSString._add("spotColorChannel");
PSString._add("spotColor");
PSString._add("spotHealingBrushTool");
PSString._add("spot");
PSString._add("sprayRadius");
PSString._add("sprayedStrokes");
PSString._add("squareCap");
PSString._add("squareSize");
PSString._add("squareScaleFactor");
PSString._add("square");
PSString._add("squareness");
PSString._add("srcBlackMax");
PSString._add("srcBlackMin");
PSString._add("srcWhiteMax");
PSString._add("srcWhiteMin");
PSString._add("stackWithOriginal");
PSString._add("stagger");
PSString._add("stainedGlass");
PSString._add("stairStepEffect");
PSString._add("stampIn");
PSString._add("stampOut");
PSString._add("stamp");
PSString._add("standardDeviations");
PSString._add("standardFrenchLanguage");
PSString._add("standardGermanLanguage");
PSString._add("germanLanguageReformed1996");
PSString._add("getGPUStats");
PSString._add("getGPUInfo");
PSString._add("GLCompute");
PSString._add("CLCompute");
PSString._add("oldGermanLanguage");
PSString._add("standardPortugueseLanguage");
PSString._add("standard");
PSString._add("star");
PSString._add("startArrowhead");
PSString._add("startExternalUIOnLaunch");
PSString._add("startFrameNumber");
PSString._add("startIndent");
PSString._add("startPaintProfiling");
PSString._add("startStrokeRecording");
PSString._add("start");
PSString._add("startTime");
PSString._add("state");
PSString._add("stdA");
PSString._add("stdB");
PSString._add("stdC");
PSString._add("stdE");
PSString._add("stdTrackID");
PSString._add("stepByStep");
PSString._add("stiffness");
PSString._add("stopPaintProfiling");
PSString._add("stopStrokeRecording");
PSString._add("stop");
PSString._add("straight");
PSString._add("strengthPlugin");
PSString._add("strengthRatio");
PSString._add("strength");
PSString._add("stretchToFit");
PSString._add("strikethroughOff");
PSString._add("strikethrough");
PSString._add("stringChannel");
PSString._add("stringClassFormat");
PSString._add("stringCompensation");
PSString._add("stringFSS");
PSString._add("stringInteger");
PSString._add("strokeColor");
PSString._add("strokeDetail");
PSString._add("strokeDirHorizontal");
PSString._add("strokeDirLeftDiag");
PSString._add("strokeDirRightDiag");
PSString._add("strokeDirVertical");
PSString._add("strokeDirection");
PSString._add("strokeDirectionType");
PSString._add("strokeEmboss");
PSString._add("strokeLength");
PSString._add("strokeLocation");
PSString._add("strokeOverPrint");
PSString._add("strokePressure");
PSString._add("strokeSize");
PSString._add("stroke");
PSString._add("strokeWidth");
PSString._add("strokebehavior");
PSString._add("strokeEnabled");
PSString._add("strokeStyle");
PSString._add("strokeStyleBlendMode");
PSString._add("strokeStyleOpacity");
PSString._add("strokeStyleContent");
PSString._add("strokeStyleContentType");
PSString._add("strokeStyleLineCapType");
PSString._add("strokeStyleLineDashOffset");
PSString._add("strokeStyleLineDashSet");
PSString._add("strokeStyleLineJoinType");
PSString._add("strokeStyleLineAlignment");
PSString._add("strokeStyleLineWidth");
PSString._add("strokeStyleMiterLimit");
PSString._add("strokeStyleScaleLock");
PSString._add("strokeStyleStrokeAdjust");
PSString._add("strokeStyleVersion");
PSString._add("strokeStyleBevelJoin");
PSString._add("strokeStyleMiterJoin");
PSString._add("strokeStyleRoundJoin");
PSString._add("strokeStyleAlignCenter");
PSString._add("strokeStyleAlignInside");
PSString._add("strokeStyleAlignOutside");
PSString._add("strokeStyleButtCap");
PSString._add("strokeStyleRoundCap");
PSString._add("strokeStyleSquareCap");
PSString._add("strokeStyleStrokeOnly");
PSString._add("strokeStylePresetSet");
PSString._add("styleBrush");
PSString._add("styleClass");
PSString._add("stylePreset");
PSString._add("style");
PSString._add("stylesAppend");
PSString._add("stylesDelete");
PSString._add("stylesDetailView");
PSString._add("stylesLoad");
PSString._add("stylesNew");
PSString._add("stylesReset");
PSString._add("stylesSave");
PSString._add("styleSheetHasParent");
PSString._add("styleSheetName");
PSString._add("stylesSmallTextView");
PSString._add("stylesSmallThumbnailView");
PSString._add("styles");
PSString._add("stylesTextThumbnailView");
PSString._add("stylesTextView");
PSString._add("stylesThumbnailView");
PSString._add("stylisticAlternates");
PSString._add("stylusIsColor");
PSString._add("stylusIsOpacity");
PSString._add("stylusIsPressure");
PSString._add("stylusIsSize");
PSString._add("subcategory");
PSString._add("subScript");
PSString._add("subpathListKey");
PSString._add("subpath");
PSString._add("subpathsList");
PSString._add("subsample");
PSString._add("substitutesUsed");
PSString._add("subtractFilterMaskFromSelection");
PSString._add("subtractFrom");
PSString._add("subtract");
PSString._add("subtractUserMaskFromSelection");
PSString._add("subtractVectorMaskFromSelection");
PSString._add("suffix");
PSString._add("sumie");
PSString._add("superScript");
PSString._add("supplementalCategories");
PSString._add("suppressOpenOptions");
PSString._add("suppressWarnings");
PSString._add("SVGExport", "SVPExport");
PSString._add("swash");
PSString._add("swatchExchangeFile");
PSString._add("swatchesAppend");
PSString._add("swatchesNew");
PSString._add("swatchesReplace");
PSString._add("swatchesReset");
PSString._add("swatchesSave");
PSString._add("swatchesTextThumbnailView");
PSString._add("swatchesThumbnailView");
PSString._add("swatchesLargeThumbnailView");
PSString._add("swatchesLargeListView");
PSString._add("swedishLanguage");
PSString._add("swissGermanLanguage");
PSString._add("swissGermanLanguageOldRules");
PSString._add("syncManageAcct");
PSString._add("syncSettings");
PSString._add("syncSettingsPush");
PSString._add("syncSettingsPull");
PSString._add("syncSettingsDone");
PSString._add("syncPrefs");
PSString._add("syncAdvanced");
PSString._add("syncEverything");
PSString._add("syncChooseWhat");
PSString._add("syncNothing");
PSString._add("syntheticBold");
PSString._add("syntheticItalic");
PSString._add("syntheticStyle");
PSString._add("systemCall");
PSString._add("systemCMYK");
PSString._add("systemGray");
PSString._add("systemInfo");
PSString._add("systemMetrics");
PSString._add("systemPalette");
PSString._add("systemPicker");
PSString._add("systemRGB");
PSString._add("tRange");
PSString._add("tabStops");
PSString._add("tables");
PSString._add("tableOrder");
PSString._add("tabularLining");
PSString._add("tabularOldStyle");
PSString._add("takeMergedSnapshot");
PSString._add("takeSnapshot");
PSString._add("tamilLanguage");
PSString._add("targaFormat");
PSString._add("targetChannels");
PSString._add("targetEnum");
PSString._add("targetedAdjustorTool");
PSString._add("targetID");
PSString._add("targetLayers");
PSString._add("targetLayersIDs");
PSString._add("targetLayersIndexes");
PSString._add("targetPathIndex");
PSString._add("targetPath");
PSString._add("targetPathVisibility");
PSString._add("target");
PSString._add("tcyLeftRight");
PSString._add("tcyUpDown");
PSString._add("teluguLanguage");
PSString._add("template");
PSString._add("texTypeBlocks");
PSString._add("texTypeBrick");
PSString._add("texTypeBurlap");
PSString._add("texTypeCanvas");
PSString._add("texTypeFrosted");
PSString._add("texTypeSandstone");
PSString._add("texTypeTinyLens");
PSString._add("textAllCaps");
PSString._add("textAnnotTool");
PSString._add("textBurasagari");
PSString._add("textClickPoint");
PSString._add("textData");
PSString._add("textEveryLineComposer");
PSString._add("textFauxBold");
PSString._add("textFauxItalic");
PSString._add("textFile");
PSString._add("textFractionalWidths");
PSString._add("textGridding");
PSString._add("textHyphenation");
PSString._add("textJustification");
PSString._add("textKey");
PSString._add("textLanguage");
PSString._add("textLayer");
PSString._add("textLigatures");
PSString._add("textNewTextMode");
PSString._add("textNewTextOrientation");
PSString._add("textNoBreak");
PSString._add("textOidashi");
PSString._add("textOikomi");
PSString._add("textOldStyle");
PSString._add("textOrientation");
PSString._add("textOverrideFeature", "textOverrideFeatureName");
PSString._add("typeStyleOperationType");
PSString._add("textParagraph");
PSString._add("textRotateHankaku");
PSString._add("textShape");
PSString._add("textSingleLineComposer");
PSString._add("textSmallCaps");
PSString._add("text");
PSString._add("textStrikethrough");
PSString._add("textCharStyleImport");
PSString._add("textPgphStyleImport");
PSString._add("textLoadDefaultTypeStyles");
PSString._add("textSaveDefaultTypeStyles");
PSString._add("textStyleRange");
PSString._add("textStyle");
PSString._add("textSubscript");
PSString._add("textSuperscript");
PSString._add("textTValue");
PSString._add("textTateChuuYoko");
PSString._add("textThumbnail");
PSString._add("textToClipboard");
PSString._add("textToolCharacterOptions");
PSString._add("textToolOptions");
PSString._add("textToolParagraphOptions");
PSString._add("textToolTreatsESCAsCommit");
PSString._add("textToolTreatsESCAsCommitPromptShown");
PSString._add("textType");
PSString._add("textUnderline");
PSString._add("textureBlendMode");
PSString._add("textureBrightness");
PSString._add("textureContrast");
PSString._add("textureCoverage");
PSString._add("textureDepthDynamics");
PSString._add("textureDepth");
PSString._add("textureFile");
PSString._add("textureFill");
PSString._add("textureScale");
PSString._add("texture");
PSString._add("textureType");
PSString._add("textureInteractionLock");
PSString._add("texturizer");
PSString._add("textWarp");
PSString._add("then");
PSString._add("thickness");
PSString._add("thirdWidthForm");
PSString._add("threeDigit");
PSString._add("thresholdClassEvent");
PSString._add("thresholdEnum");
PSString._add("threshold");
PSString._add("thumbnail");
PSString._add("thumbnailSize");
PSString._add("thumbnailStyleFile");
PSString._add("thumbwheel");
PSString._add("thumbwheelCaps");
PSString._add("tileHorizontally");
PSString._add("tileNumber");
PSString._add("tileOffset");
PSString._add("tilePlugin");
PSString._add("tileSize");
PSString._add("tileSize64");
PSString._add("tile");
PSString._add("tiles");
PSString._add("tileVertically");
PSString._add("tileHorizontally");
PSString._add("tilt");
PSString._add("tiltBlur");
PSString._add("tiltScale");
PSString._add("timecode");
PSString._add("timeDenominator");
PSString._add("timelinePanelKey");
PSString._add("timeline");
PSString._add("timelineCommentsFormat");
PSString._add("timelineDeleteKeyframes");
PSString._add("timelineDeleteTimeline");
PSString._add("timelineEnableShortcutKeys");
PSString._add("timelineEnable3DTracks", "timelineEnable3DTracksKeys");
PSString._add("timelineKeyframeInterpolationLinear");
PSString._add("timelineKeyframeInterpolationHold");
PSString._add("timelineKeyframeInterpolationSpherical");
PSString._add("timelineSelectAllKeyframes");
PSString._add("timelineSelectNoKeyframes");
PSString._add("timelineCopyKeyframes");
PSString._add("timelinePasteKeyframes");
PSString._add("timelineSetStartOfWorkArea");
PSString._add("timelineSetEndOfWorkArea");
PSString._add("timelineGoToTime");
PSString._add("timelineGoToNextFrame");
PSString._add("timelineGoToPreviousFrame");
PSString._add("timelineGoToFirstFrame");
PSString._add("timelineGoToLastFrame");
PSString._add("timelineGoToWorkAreaStart");
PSString._add("timelineGoToWorkAreaEnd");
PSString._add("timelineAllowFrameSkipping");
PSString._add("timelineMakeTimeline");
PSString._add("timelineMoveLayerInPoint");
PSString._add("timelineMoveLayerEndPoint");
PSString._add("timelineTrimLayerStart");
PSString._add("timelineTrimLayerEnd");
PSString._add("timelineTrimDocumentDuration");
PSString._add("timelineSplitLayer");
PSString._add("timelineLiftWorkArea");
PSString._add("timelineExtractWorkArea");
PSString._add("timelineMakeFramesFromLayers");
PSString._add("timelineFlattenFramesIntoLayers");
PSString._add("timelineEditTimelineComment");
PSString._add("timelineDocumentSettings");
PSString._add("timelineConvertToFrames");
PSString._add("timelineOnionSkinSettings");
PSString._add("timelineEnableOnionSkins");
PSString._add("timelineShowAllLayers");
PSString._add("timelineShowFavoriteLayers");
PSString._add("timelineShowSetFavoriteLayers");
PSString._add("timelinePaletteOptions");
PSString._add("timeNumerator");
PSString._add("timeOffset");
PSString._add("timeString");
PSString._add("timeoutAttr");
PSString._add("tintColor");
PSString._add("tintFilter");
PSString._add("title");
PSString._add("titling");
PSString._add("toBuiltin");
PSString._add("toLinked");
PSString._add("toMode");
PSString._add("toNextWholeSecond");
PSString._add("topLeft");
PSString._add("topRight");
PSString._add("toPathBottom");
PSString._add("toPathCenter");
PSString._add("toPathTop");
PSString._add("to");
PSString._add("toggle3DPanel");
PSString._add("togglePropertiesPanel");
PSString._add("toggleCreatePanel");
PSString._add("irisBlur");
PSString._add("fieldBlur");
PSString._add("tiltBlur");
PSString._add("2upHorizontal");
PSString._add("2upVertical");
PSString._add("3upHorizontal");
PSString._add("3upStacked");
PSString._add("3upVertical");
PSString._add("4upTile");
PSString._add("6upTile");
PSString._add("toggle3DAxis");
PSString._add("toggle3DGroundPlane");
PSString._add("toggle3DLights");
PSString._add("toggle3DSelection");
PSString._add("toggle3DUVOverlay");
PSString._add("toggleActionsPalette");
PSString._add("toggleAdjustmentPalette");
PSString._add("toggleAnimationPalette");
PSString._add("toggleAnnotationPalette");
PSString._add("toggleAnnots");
PSString._add("toggleAutoSlices");
PSString._add("toggleBlackPreview");
PSString._add("toggleBrushPreview");
PSString._add("toggleBrushStylerPalette");
PSString._add("toggleBrushesExpandedView");
PSString._add("toggleBrushesPalette");
PSString._add("toggleBrushPresetsPalette");
PSString._add("toggleCloneSourcePalette");
PSString._add("toggleCMYKPreview");
PSString._add("toggleCMYPreview");
PSString._add("toggleChannelsPalette");
PSString._add("toggleCharacterPalette");
PSString._add("toggleCharacterStylesPalette");
PSString._add("toggleColorPalette");
PSString._add("toggleComboFXPalette");
PSString._add("toggleCompsPalette");
PSString._add("toggleControlCenter");
PSString._add("toggleCount");
PSString._add("toggleCyanPreview");
PSString._add("toggleEdges");
PSString._add("toggleEffectsPalette");
PSString._add("toggleFileBrowserPalette");
PSString._add("toggleFiltersPalette");
PSString._add("toggleGamutWarning");
PSString._add("toggleGrid");
PSString._add("toggleGuides");
PSString._add("toggleHintsPalette");
PSString._add("toggleHistogramPalette");
PSString._add("toggleHistoryPalette");
PSString._add("toggleInfoPalette");
PSString._add("toggleKeyframeSelection");
PSString._add("toggleLayerMask");
PSString._add("toggleLayersPalette");
PSString._add("toggleLockGuides");
PSString._add("toggleLockSlices");
PSString._add("toggleMagentaPreview");
PSString._add("toggleMaskPalette");
PSString._add("toggleBlurbPalette");
PSString._add("toggleBlurbPalette2");
PSString._add("toggleBlurbPalette3");
PSString._add("toggleMeasurementLogPalette");
PSString._add("toggleNavigatorPalette");
PSString._add("toggleOptionsPalette");
PSString._add("toggleOthers");
PSString._add("togglePalettes");
PSString._add("toggleParagraphPalette");
PSString._add("toggleParagraphStylesPalette");
PSString._add("togglePathsPalette");
PSString._add("togglePaths");
PSString._add("togglePixelGrid");
PSString._add("toggleProofColors");
PSString._add("toggleProofVideo");
PSString._add("toggleQuickMaskMode");
PSString._add("toggleQuickStartPalette");
PSString._add("toggleRGBMacPreview");
PSString._add("toggleRGBUncompensatedPreview");
PSString._add("toggleRGBWindowsPreview");
PSString._add("toggleRecipesPalette");
PSString._add("toggleRulers");
PSString._add("toggleSearchPalette");
PSString._add("toggleShortcutsPalette");
PSString._add("toggleShowExtras");
PSString._add("toggleLayerEdges");
PSString._add("toggleShowMRUInBrushesPanel");
PSString._add("toggleShowMRUInSwatchesPanel");
PSString._add("toggleSlices");
PSString._add("toggleSmartGuides");
PSString._add("toggleSnapToGrid");
PSString._add("toggleSnapToGuides");
PSString._add("toggleStatusBar");
PSString._add("toggle");
PSString._add("toggleStylesPalette");
PSString._add("toggleSwatchesPalette");
PSString._add("toggleTextLayerType");
PSString._add("toggleToolPresetsPalette");
PSString._add("toggleToolsPalette");
PSString._add("toggleVectorMask");
PSString._add("toggleYellowPreview");
PSString._add("tolerance");
PSString._add("toolChanged");
PSString._add("toolModalStateChanged");
PSString._add("toolOptionsChanged");
PSString._add("toolPreset");
PSString._add("toolRefineEdgeBorderContrast");
PSString._add("toolRefineEdgeBorderRadius");
PSString._add("toolRefineEdgeChoke");
PSString._add("toolRefineEdgeFeatherRadius");
PSString._add("toolRefineEdgeViewMode");
PSString._add("toolRefineEdgePreviewState");
PSString._add("toolRefineEdgeSmooth");
PSString._add("tool");
PSString._add("toolSupportsBrushes");
PSString._add("topLeftPixelColor");
PSString._add("top");
PSString._add("tornEdges");
PSString._add("totalLimit");
PSString._add("totalPages");
PSString._add("traceContour");
PSString._add("trackID");
PSString._add("tracking");
PSString._add("trackerEndedWithoutBreakingHysteresis");
PSString._add("traditionalForm");
PSString._add("transactionIDAttr");
PSString._add("transferFunction");
PSString._add("transferPoint");
PSString._add("transferSpecClass");
PSString._add("transferSpec");
PSString._add("transform");
PSString._add("transformsSnapToPixels");
PSString._add("transition");
PSString._add("transitionPlacement");
PSString._add("translation");
PSString._add("transparencyEnum");
PSString._add("transparencyGamutPreferences");
PSString._add("transparencyGridColors");
PSString._add("transparencyGridColorsType");
PSString._add("transparencyGridSize");
PSString._add("transparencyGrid");
PSString._add("transparencyPrefs");
PSString._add("transparencyShape");
PSString._add("transparencyShapesLayer");
PSString._add("transparencyStop");
PSString._add("transparency");
PSString._add("transparentIndex");
PSString._add("transparent");
PSString._add("transparentWhites");
PSString._add("trap");
PSString._add("trimBasedOn");
PSString._add("trim");
PSString._add("trimBox");
PSString._add("trimDocumentToWorkArea");
PSString._add("trinitron");
PSString._add("tritone");
PSString._add("true");
PSString._add("tsume");
PSString._add("turkishLanguage");
PSString._add("tutorials");
PSString._add("twirl");
PSString._add("twist");
PSString._add("twoDigit");
PSString._add("tx");
PSString._add("ty");
PSString._add("typeClassModeOrClassMode");
PSString._add("typeCreateMaskTool");
PSString._add("typeCreateOrEditTool");
PSString._add("typeID");
PSString._add("type");
PSString._add("type1");
PSString._add("type2");
PSString._add("TypeCanvasColorType", "canvasColorType");
PSString._add("TypeCanvasFrameStyle", "canvasFrameStyle");
PSString._add("TypeCanvasScreenMode", "canvasScreenMode");
PSString._add("typeStyles");
PSString._add("typeUnits");
PSString._add("typeVerticalCreateMaskTool");
PSString._add("typeVerticalCreateOrEditTool");
PSString._add("typeFrameDispose");
PSString._add("uIBitmap");
PSString._add("uiBrightness");
PSString._add("uiBrightnessEnabled");
PSString._add("uiBrightnessLevel", "kuiBrightnessLevel");
PSString._add("uiBrightnessLevelEnumType");
PSString._add("uICMYK");
PSString._add("uIDuotone");
PSString._add("uIGrayscale");
PSString._add("uIIndexed");
PSString._add("uILab");
PSString._add("uIMultichannel");
PSString._add("uIRGB");
PSString._add("uInt32");
PSString._add("ukenglishLanguage");
PSString._add("ukrainianLanguage", "ukranianLanguage");
PSString._add("uncoverDown");
PSString._add("uncoverRight");
PSString._add("undefinedArea");
PSString._add("underlineOff");
PSString._add("underlineOffset");
PSString._add("underlineOnLeftInVertical");
PSString._add("underlineOnRightInVertical");
PSString._add("underline");
PSString._add("underpainting");
PSString._add("underscore");
PSString._add("undoEnum");
PSString._add("undoEvent");
PSString._add("undoWhile3DPainting");
PSString._add("ungroup");
PSString._add("uniformDistribution");
PSString._add("uniform");
PSString._add("unitsPrefs");
PSString._add("unitsRulersPreferences");
PSString._add("unitRect");
PSString._add("unitTest");
PSString._add("unitValueQuadVersion");
PSString._add("unix");
PSString._add("unlink");
PSString._add("unlinkSelectedLayers");
PSString._add("unmarked");
PSString._add("unsharpMask");
PSString._add("unspecifiedColor");
PSString._add("untitled");
PSString._add("unwrapLayers");
PSString._add("uOrder");
PSString._add("update");
PSString._add("updateLayouts");
PSString._add("updatePlacedLayer");
PSString._add("upperCaseExtension");
PSString._add("upperCaseSerial");
PSString._add("upperCase");
PSString._add("upper");
PSString._add("upperY");
PSString._add("urgency");
PSString._add("useAccurateScreens");
PSString._add("useAdditionalPlugins");
PSString._add("useAlignedRendering");
PSString._add("useAppearance");
PSString._add("useToolBrushSize", "useBrushSize");
PSString._add("useBrushGroup");
PSString._add("useBrushPose");
PSString._add("useToolDefaultBrushPose", "useDefaultBrushPose");
PSString._add("useCacheForHistograms");
PSString._add("useColorDynamics");
PSString._add("useCurves");
PSString._add("useDefault");
PSString._add("useDualBrush");
PSString._add("useField");
PSString._add("useFirstColumn");
PSString._add("useGlobalAngle");
PSString._add("useICCProfile");
PSString._add("useLegacy");
PSString._add("useFace");
PSString._add("useMetadata");
PSString._add("useMask");
PSString._add("usePaintDynamics");
PSString._add("usePosition");
PSString._add("usePressureOverridesOpacity");
PSString._add("usePressureOverridesSize");
PSString._add("useScatter");
PSString._add("useShape");
PSString._add("useSnapToPixel");
PSString._add("useTabletTabGroupAppearance");
PSString._add("useTextOutlines");
PSString._add("useTexture");
PSString._add("useTipDynamics");
PSString._add("useTint");
PSString._add("useVisibility");
PSString._add("userDefined");
PSString._add("userMaskDensity");
PSString._add("userMaskFeather");
PSString._add("vectorMaskClass");
PSString._add("vectorMaskDensity");
PSString._add("vectorMaskFeather");
PSString._add("vibrance");
PSString._add("userMaskEnabled");
PSString._add("userMaskLinked");
PSString._add("userMaskOptions");
PSString._add("userStop");
PSString._add("user");
PSString._add("useSource");
PSString._add("using");
PSString._add("unzip");
PSString._add("vMPreferences");
PSString._add("validAtPosition");
PSString._add("valueList");
PSString._add("value");
PSString._add("valueOnly");
PSString._add("variableClass");
PSString._add("variations");
PSString._add("vector0");
PSString._add("vector1");
PSString._add("vectorColor");
PSString._add("vectorData");
PSString._add("vectorMaskAsGlobalMask");
PSString._add("vectorMaskCurrentPath");
PSString._add("vectorMaskEnabled");
PSString._add("vectorMaskHideAll");
PSString._add("vectorMaskLinked");
PSString._add("vectorMaskRevealAll");
PSString._add("vectorMask");
PSString._add("verbose");
PSString._add("versionFix");
PSString._add("versionMajor");
PSString._add("versionMinor");
PSString._add("version");
PSString._add("verticalLeftToRight");
PSString._add("verticalLocation");
PSString._add("verticalOnly");
PSString._add("verticalScale");
PSString._add("vertical");
PSString._add("verticalUnderlineLeft");
PSString._add("verticalUnderlinePosition");
PSString._add("verticalUnderlineRight");
PSString._add("verticalMovementsBrushHUD");
PSString._add("vertices");
PSString._add("video");
PSString._add("videoAlpha");
PSString._add("videoExport");
PSString._add("videoField");
PSString._add("videoLayer");
PSString._add("videoNextFrame");
PSString._add("videoPreviousFrame");
PSString._add("vignette");
PSString._add("violet");
PSString._add("visibleChannels");
PSString._add("visible");
PSString._add("vividLight");
PSString._add("volume");
PSString._add("vOrder");
PSString._add("wait");
PSString._add("wariChuAutoJustify");
PSString._add("wariChuCenterJustify");
PSString._add("wariChuCount");
PSString._add("wariChuFullJustifyLastLineCenter");
PSString._add("wariChuFullJustifyLastLineFull");
PSString._add("wariChuFullJustifyLastLineLeft");
PSString._add("wariChuFullJustifyLastLineRight");
PSString._add("wariChuJustification");
PSString._add("wariChuLeftJustify");
PSString._add("wariChuLineGap");
PSString._add("wariChuOrphan");
PSString._add("wariChuRightJustify");
PSString._add("wariChuScale");
PSString._add("wariChuSize");
PSString._add("wariChuWidow");
PSString._add("warpArcLower");
PSString._add("warpArc");
PSString._add("warpArcUpper");
PSString._add("warpArch");
PSString._add("warpBulge");
PSString._add("warpCustom");
PSString._add("warpedVertices");
PSString._add("warpFish");
PSString._add("warpFisheye");
PSString._add("warpFlag");
PSString._add("warpInflate");
PSString._add("warpNone");
PSString._add("warpPerspectiveOther");
PSString._add("warpPerspective");
PSString._add("warpRise");
PSString._add("warpRotate");
PSString._add("warpShellLower");
PSString._add("warpShellUpper");
PSString._add("warpSqueeze");
PSString._add("warp");
PSString._add("warpStyle");
PSString._add("warpTwist");
PSString._add("warpValue");
PSString._add("warpWave");
PSString._add("watchSuspension");
PSString._add("waterPaper");
PSString._add("watercolor");
PSString._add("watermark");
PSString._add("waveSine");
PSString._add("waveSquare");
PSString._add("wave");
PSString._add("waveTriangle");
PSString._add("waveType");
PSString._add("wavelengthMax");
PSString._add("wavelengthMin");
PSString._add("webPhotoGallery");
PSString._add("webPhotoGallery");
PSString._add("webSafeRamp");
PSString._add("web");
PSString._add("weight");
PSString._add("welcomeScreen");
PSString._add("wetBrushTool");
PSString._add("wetEdges");
PSString._add("wetEdgesLock");
PSString._add("wetness");
PSString._add("what");
PSString._add("wheelSpinBlur");
PSString._add("whichEffect");
PSString._add("whichEffectType");
PSString._add("whiteClip");
PSString._add("whiteDissolve");
PSString._add("whiteIntensity");
PSString._add("whiteIsHigh");
PSString._add("whiteLevel");
PSString._add("whitePoint");
PSString._add("white");
PSString._add("whites");
PSString._add("whitePointTool");
PSString._add("wholePath");
PSString._add("wholeWord");
PSString._add("wholeFXClass");
PSString._add("wideGamutRGB");
PSString._add("widePhosphors");
PSString._add("width");
PSString._add("wildCard");
PSString._add("winThumbnail");
PSString._add("windMethod");
PSString._add("wind");
PSString._add("windingFill");
PSString._add("windows");
PSString._add("windowsSystem");
PSString._add("wipeDown");
PSString._add("wipeLeft");
PSString._add("wipeRight");
PSString._add("wipeUp");
PSString._add("with");
PSString._add("withStream");
PSString._add("workInTime");
PSString._add("workOutTime");
PSString._add("workPathIndex");
PSString._add("workPath");
PSString._add("workingCMYK");
PSString._add("workingGray");
PSString._add("workingRGB");
PSString._add("workingSpaceCode");
PSString._add("workingSpot");
PSString._add("workspaceChanged");
PSString._add("workspaceDefaultFolder");
PSString._add("workspaceMenu");
PSString._add("workspacesCustomOrder");
PSString._add("workspacesDisabledPresets");
PSString._add("workspaceSwitcherUserWidth");
PSString._add("workspaceSwitcherIsCollapsed");
PSString._add("workspace");
PSString._add("workspaceList");
PSString._add("wrapAround");
PSString._add("wrapPath");
PSString._add("wrap");
PSString._add("writeBytes");
PSString._add("writeMessages");
PSString._add("writeStatus");
PSString._add("xHeightStrikethroughOn");
PSString._add("x");
PSString._add("xYYColor");
PSString._add("xor");
PSString._add("xTilt");
PSString._add("xx");
PSString._add("xy");
PSString._add("y");
PSString._add("yellowColor");
PSString._add("yellow");
PSString._add("yellows");
PSString._add("yesNo");
PSString._add("yes");
PSString._add("yTilt");
PSString._add("yx");
PSString._add("yy");
PSString._add("yyddmm");
PSString._add("yymmdd");
PSString._add("yyyymmdd");
PSString._add("z");
PSString._add("zed");
PSString._add("zigZag");
PSString._add("zigZagType");
PSString._add("zip");
PSString._add("zoomIn");
PSString._add("zoomOut");
PSString._add("zoom");
PSString._add("zoomDirection");
PSString._add("zoomOrigin");
PSString._add("zoomTool");
PSString._add("zoomWithScrollWheel");
PSString._add("PreferTinyFontType", "preferTinyPaletteFontType");
PSString._add("PreferSmallFontType", "preferSmallPaletteFontType");
PSString._add("PreferMediumFontType", "preferMediumPaletteFontType");
PSString._add("PreferLargeFontType", "preferLargePaletteFontType");
PSString._add("showFontPreviews");
PSString._add("fontPreviewsSize");
PSString._add("typePreferences");
PSString._add("newDocument");
PSString._add("HelpLauncher", "helpLauncher");
PSString._add("HelpID", "helpID");
PSString._add("workflow");
PSString._add("workflowIsManaged");
PSString._add("workflowURL");
PSString._add("checkIn");
PSString._add("checkOut");
PSString._add("undoCheckOut");
PSString._add("uploadToServer");
PSString._add("downloadFromServer");
PSString._add("addToWorkflow");
PSString._add("workflowOptions");
PSString._add("openFromWorkflow");
PSString._add("verifyState");
PSString._add("logoffAllServers");
PSString._add("workOffline");
PSString._add("workgroupServers");
PSString._add("workgroupOptionsKey");
PSString._add("workflowIsOwned");
PSString._add("workflowLockedLocally");
PSString._add("workflowEditOffline");
PSString._add("workflowIsCurrent");
PSString._add("workflowIsModified");
PSString._add("WorkflowEnabledPref", "workflowEnabled");
PSString._add("WorkflowUpdatePref", "workflowUpdatePref");
PSString._add("WorkflowCheckoutPref", "workflowCheckoutPref");
PSString._add("assetManagementEnabled");
PSString._add("hdrToningType1", "hdrtype1");
PSString._add("hdrToningType2", "hdrtype2");
PSString._add("hdrToningType3", "hdrtype3");
PSString._add("hdrToningType4", "hdrtype4");
PSString._add("hdrToningType5", "hdrtype5");
PSString._add("hdrToningType6", "hdrtype6");
PSString._add("arabicDigits");
PSString._add("arabicLanguage");
PSString._add("arabicSpellingOptions", "arabicSpellOptions");
PSString._add("defaultDigits");
PSString._add("diacVPosOff");
PSString._add("diacVPosLoose");
PSString._add("diacVPosMedium");
PSString._add("diacVPosTight");
PSString._add("diacVPosOpenType");
PSString._add("diacVPos");
PSString._add("diacXOffset");
PSString._add("diacYOffset");
PSString._add("justificationAlternates");
PSString._add("markYDistFromBaseline");
PSString._add("digitSet");
PSString._add("directionType");
PSString._add("dirLeftToRight");
PSString._add("dirRightToLeft");
PSString._add("dirOverrideDefault");
PSString._add("digitSet");
PSString._add("directionType");
PSString._add("dirLeftToRight");
PSString._add("dirRightToLeft");
PSString._add("dirOverrideDefault");
PSString._add("dirOverrideLTR");
PSString._add("dirOverrideRTL");
PSString._add("dirOverride");
PSString._add("farsiDigits");
PSString._add("hebrewLanguage");
PSString._add("hindiDigits");
PSString._add("ignoreAccents");
PSString._add("justificationMethodType");
PSString._add("justifMethodArabic");
PSString._add("justifMethodDefault");
PSString._add("justifMethodNaskh");
PSString._add("justifMethodNaskhTatweel");
PSString._add("justifMethodNaskhKashida");
PSString._add("justifMethodAutomaticKashida", "justifMethodAutomatic");
PSString._add("kashidaDefault");
PSString._add("kashidaOff");
PSString._add("kashidas");
PSString._add("textToolDiacriticsOptions");
PSString._add("textComposerEngine");
PSString._add("LatinCJKComposer", "textLatinCJKComposer");
PSString._add("OptycaComposer", "textOptycaComposer");
PSString._add("toggleDiacritics");
PSString._add("typeCreateMaskToolME");
PSString._add("typeCreateOrEditToolME");
PSString._add("kashidaWidthType");
PSString._add("kashidaWidthNone");
PSString._add("kashidaWidthSmall");
PSString._add("kashidaWidthMedium");
PSString._add("kashidaWidthLong");
PSString._add("kashidaWidthStylistic");
PSString._add("FuntaFormat");
PSString._add("exportAssetsPref", "exportAssetsPrefs");
PSString._add("exportAssetsFileType", "exportFileType");
PSString._add("exportAssetsPath", "exportFilePath");
PSString._add("exportAssetsLocationSetting");
PSString._add("exportAssetJPGQuality", "exportAssetsJPGQuality");
PSString._add("exportPNGTransparency");
PSString._add("exportDocumentAsFileTypePressed");
PSString._add("exportSelectionAsFileTypePressed");
PSString._add("exportShownPrefsChangeAlert");
PSString._add("exportDocumentAsDialog");
PSString._add("exportSelectionAsDialog");
PSString._add("HTTPCommandSet", "httpsCommandSet");
PSString._add("HTTPCommandGet", "httpsCommandGet");
PSString._add("HTTPRequestJSON", "httpsRequestJSON");

PSClass._add("Action", "Actn");
PSClass._add("ActionSet", "ASet");
PSClass._add("Adjustment", "Adjs");
PSClass._add("AdjustmentLayer", "AdjL");
PSClass._add("AirbrushTool", "AbTl");
PSClass._add("AlphaChannelOptions", "AChl");
PSClass._add("AntiAliasedPICTAcquire", "AntA");
PSClass._add("Application", "capp");
PSClass._add("Arrowhead", "cArw");
PSClass._add("Assert", "Asrt");
PSClass._add("AssumedProfile", "AssP");
PSClass._add("BMPFormat", "BMPF");
PSClass._add("BackgroundLayer", "BckL");
PSClass._add("BevelEmboss", "ebbl");
PSClass._add("BitmapMode", "BtmM");
PSClass._add("BlendRange", "Blnd");
PSClass._add("BlurTool", "BlTl");
PSClass._add("BookColor", "BkCl");
PSClass._add("BrightnessContrast", "BrgC");
PSClass._add("Brush", "Brsh");
PSClass._add("BurnInTool", "BrTl");
PSClass._add("CachePrefs", "CchP");
PSClass._add("CMYKColor", "CMYC");
PSClass._add("CMYKColorMode", "CMYM");
PSClass._add("CMYKSetup", "CMYS");
PSClass._add("Calculation", "Clcl");
PSClass._add("Channel", "Chnl");
PSClass._add("ChannelMatrix", "ChMx");
PSClass._add("ChannelMixer", "ChnM");
PSClass._add("CineonFormat", "SDPX");
PSClass._add("ClippingInfo", "Clpo");
PSClass._add("ClippingPath", "ClpP");
PSClass._add("CloneStampTool", "ClTl");
PSClass._add("Color", "Clr ");
PSClass._add("ColorBalance", "ClrB");
PSClass._add("ColorCorrection", "ClrC");
PSClass._add("ColorPickerPrefs", "Clrk");
PSClass._add("ColorSampler", "ClSm");
PSClass._add("ColorStop", "Clrt");
PSClass._add("Command", "Cmnd");
PSClass._add("Curves", "Crvs");
PSClass._add("CurvePoint", "CrPt");
PSClass._add("CustomPalette", "Cstl");
PSClass._add("CurvesAdjustment", "CrvA");
PSClass._add("CustomPhosphors", "CstP");
PSClass._add("CustomWhitePoint", "CstW");
PSClass._add("DicomFormat", "Dicm");
PSClass._add("DisplayPrefs", "DspP");
PSClass._add("Document", "Dcmn");
PSClass._add("DodgeTool", "DdTl");
PSClass._add("DropShadow", "DrSh");
PSClass._add("DuotoneInk", "DtnI");
PSClass._add("DuotoneMode", "DtnM");
PSClass._add("EPSGenericFormat", "EPSG");
PSClass._add("EPSPICTPreview", "EPSC");
PSClass._add("EPSTIFFPreview", "EPST");
PSClass._add("Element", "Elmn");
PSClass._add("Ellipse", "Elps");
PSClass._add("EraserTool", "ErTl");
PSClass._add("Export", "Expr");
PSClass._add("FileInfo", "FlIn");
PSClass._add("FileSavePrefs", "FlSv");
PSClass._add("FlashPixFormat", "FlsP");
PSClass._add("FontDesignAxes", "FntD");
PSClass._add("Format", "Fmt ");
PSClass._add("FrameFX", "FrFX");
PSClass._add("Contour", "FxSc");
PSClass._add("GeneralPrefs", "GnrP");
PSClass._add("GIF89aExport", "GF89");
PSClass._add("GIFFormat", "GFFr");
PSClass._add("GlobalAngle", "gblA");
PSClass._add("Gradient", "Grdn");
PSClass._add("GradientFill", "Grdf");
PSClass._add("GradientMap", "GdMp");
PSClass._add("GradientTool", "GrTl");
PSClass._add("GraySetup", "GrSt");
PSClass._add("Grayscale", "Grsc");
PSClass._add("GrayscaleMode", "Grys");
PSClass._add("Guide", "Gd  ");
PSClass._add("GuidesPrefs", "GdPr");
PSClass._add("HalftoneScreen", "HlfS");
PSClass._add("HalftoneSpec", "Hlfp");
PSClass._add("HSBColor", "HSBC");
PSClass._add("HSBColorMode", "HSBM");
PSClass._add("HistoryBrushTool", "HBTl");
PSClass._add("HistoryPrefs", "CHsP");
PSClass._add("HistoryState", "HstS");
PSClass._add("HueSatAdjustment", "HStA");
PSClass._add("HueSatAdjustmentV2", "Hst2");
PSClass._add("HueSaturation", "HStr");
PSClass._add("IFFFormat", "IFFF");
PSClass._add("IllustratorPathsExport", "IlsP");
PSClass._add("ImagePoint", "ImgP");
PSClass._add("Import", "Impr");
PSClass._add("IndexedColorMode", "IndC");
PSClass._add("InkTransfer", "InkT");
PSClass._add("InnerGlow", "IrGl");
PSClass._add("InnerShadow", "IrSh");
PSClass._add("InterfaceColor", "IClr");
PSClass._add("Invert", "Invr");
PSClass._add("JPEGFormat", "JPEG");
PSClass._add("LabColor", "LbCl");
PSClass._add("LabColorMode", "LbCM");
PSClass._add("Layer", "Lyr ");
PSClass._add("LayerEffects", "Lefx");
PSClass._add("LayerFXVisible", "lfxv");
PSClass._add("Levels", "Lvls");
PSClass._add("LevelsAdjustment", "LvlA");
PSClass._add("LightSource", "LghS");
PSClass._add("Line", "Ln  ");
PSClass._add("MacPaintFormat", "McPn");
PSClass._add("MagicEraserTool", "MgEr");
PSClass._add("MagicPoint", "Mgcp");
PSClass._add("Mask", "Msk ");
PSClass._add("MenuItem", "Mn  ");
PSClass._add("Mode", "Md  ");
PSClass._add("MultichannelMode", "MltC");
PSClass._add("ObsoleteTextLayer", "TxLy");
PSClass._add("Null", "null");
PSClass._add("Offset", "Ofst");
PSClass._add("Opacity", "Opac");
PSClass._add("OuterGlow", "OrGl");
PSClass._add("PDFGenericFormat", "PDFG");
PSClass._add("PICTFileFormat", "PICF");
PSClass._add("PICTResourceFormat", "PICR");
PSClass._add("PNGFormat", "PNGF");
PSClass._add("PageSetup", "PgSt");
PSClass._add("PaintbrushTool", "PbTl");
PSClass._add("Path", "Path");
PSClass._add("PathComponent", "PaCm");
PSClass._add("PathPoint", "Pthp");
PSClass._add("Pattern", "PttR");
PSClass._add("PatternStampTool", "PaTl");
PSClass._add("PencilTool", "PcTl");
PSClass._add("Photoshop20Format", "Pht2");
PSClass._add("Photoshop35Format", "Pht3");
PSClass._add("PhotoshopDCS2Format", "PhD2");
PSClass._add("PhotoshopDCSFormat", "PhD1");
PSClass._add("PhotoshopEPSFormat", "PhtE");
PSClass._add("PhotoshopPDFFormat", "PhtP");
PSClass._add("Pixel", "Pxel");
PSClass._add("PixelPaintFormat", "PxlP");
PSClass._add("PluginPrefs", "PlgP");
PSClass._add("Point", "Pnt ");
PSClass._add("Point16", "Pnt1");
PSClass._add("Polygon", "Plgn");
PSClass._add("Posterize", "Pstr");
PSClass._add("Preferences", "GnrP");
PSClass._add("ProfileSetup", "PrfS");
PSClass._add("Property", "Prpr");
PSClass._add("Range", "Rang");
PSClass._add("Rect16", "Rct1");
PSClass._add("RGBColor", "RGBC");
PSClass._add("RGBColorMode", "RGBM");
PSClass._add("RGBSetup", "RGBt");
PSClass._add("RawFormat", "Rw  ");
PSClass._add("Rectangle", "Rctn");
PSClass._add("SaturationTool", "SrTl");
PSClass._add("ScitexCTFormat", "Sctx");
PSClass._add("Selection", "csel");
PSClass._add("SelectiveColor", "SlcC");
PSClass._add("ShapingCurve", "ShpC");
PSClass._add("SharpenTool", "ShTl");
PSClass._add("SingleColumn", "Sngc");
PSClass._add("SingleRow", "Sngr");
PSClass._add("BackgroundEraserTool", "SETl");
PSClass._add("SolidFill", "SoFi");
PSClass._add("ArtHistoryBrushTool", "ABTl");
PSClass._add("SmudgeTool", "SmTl");
PSClass._add("Snapshot", "SnpS");
PSClass._add("SpotColorChannel", "SCch");
PSClass._add("Style", "StyC");
PSClass._add("SubPath", "Sbpl");
PSClass._add("TIFFFormat", "TIFF");
PSClass._add("TargaFormat", "TrgF");
PSClass._add("TextLayer", "TxLr");
PSClass._add("TextStyle", "TxtS");
PSClass._add("TextStyleRange", "Txtt");
PSClass._add("Threshold", "Thrs");
PSClass._add("Tool", "Tool");
PSClass._add("TransferSpec", "Trfp");
PSClass._add("TransferPoint", "DtnP");
PSClass._add("TransparencyPrefs", "TrnP");
PSClass._add("TransparencyStop", "TrnS");
PSClass._add("UnitsPrefs", "UntP");
PSClass._add("UnspecifiedColor", "UnsC");
PSClass._add("Version", "Vrsn");
PSClass._add("WebdavPrefs", "Wdbv");
PSClass._add("XYYColor", "XYYC");
PSClass._add("ChromeFX", "ChFX");
PSClass._add("BackLight", "BakL");
PSClass._add("FillFlash", "FilF");
PSClass._add("ColorCast", "ColC");

PSEnum._add("Add", "Add ");
PSEnum._add("AmountHigh", "amHi");
PSEnum._add("AmountLow", "amLo");
PSEnum._add("AmountMedium", "amMd");
PSEnum._add("AntiAliasNone", "Anno");
PSEnum._add("AntiAliasLow", "AnLo");
PSEnum._add("AntiAliasMedium", "AnMd");
PSEnum._add("AntiAliasHigh", "AnHi");
PSEnum._add("AntiAliasCrisp", "AnCr");
PSEnum._add("AntiAliasStrong", "AnSt");
PSEnum._add("AntiAliasSmooth", "AnSm");
PSEnum._add("AppleRGB", "AppR");
PSEnum._add("ASCII", "ASCI");
PSEnum._add("AskWhenOpening", "AskW");
PSEnum._add("Bicubic", "Bcbc");
PSEnum._add("Binary", "Bnry");
PSEnum._add("MonitorSetup", "MntS");
PSEnum._add("16BitsPerPixel", "16Bt");
PSEnum._add("1BitPerPixel", "OnBt");
PSEnum._add("2BitsPerPixel", "2Bts");
PSEnum._add("32BitsPerPixel", "32Bt");
PSEnum._add("4BitsPerPixel", "4Bts");
PSEnum._add("5000", "5000");
PSEnum._add("5500", "5500");
PSEnum._add("6500", "6500");
PSEnum._add("72Color", "72Cl");
PSEnum._add("72Gray", "72Gr");
PSEnum._add("7500", "7500");
PSEnum._add("8BitsPerPixel", "EghB");
PSEnum._add("9300", "9300");
PSEnum._add("A", "A   ");
PSEnum._add("AbsColorimetric", "AClr");
PSEnum._add("ADSBottoms", "AdBt");
PSEnum._add("ADSCentersH", "AdCH");
PSEnum._add("ADSCentersV", "AdCV");
PSEnum._add("ADSHorizontal", "AdHr");
PSEnum._add("ADSLefts", "AdLf");
PSEnum._add("ADSRights", "AdRg");
PSEnum._add("ADSTops", "AdTp");
PSEnum._add("ADSVertical", "AdVr");
PSEnum._add("AboutApp", "AbAp");
PSEnum._add("Absolute", "Absl");
PSEnum._add("ActualPixels", "ActP");
PSEnum._add("Adaptive", "Adpt");
PSEnum._add("AdjustmentOptions", "AdjO");
PSEnum._add("AirbrushEraser", "Arbs");
PSEnum._add("All", "Al  ");
PSEnum._add("Amiga", "Amga");
PSEnum._add("Angle", "Angl");
PSEnum._add("Any", "Any ");
PSEnum._add("ApplyImage", "AplI");
PSEnum._add("AroundCenter", "ArnC");
PSEnum._add("Arrange", "Arng");
PSEnum._add("Ask", "Ask ");
PSEnum._add("B", "B   ");
PSEnum._add("Back", "Back");
PSEnum._add("Background", "Bckg");
PSEnum._add("BackgroundColor", "BckC");
PSEnum._add("Backward", "Bckw");
PSEnum._add("Behind", "Bhnd");
PSEnum._add("Best", "Bst ");
PSEnum._add("Better", "Dthb");
PSEnum._add("Bilinear", "Blnr");
PSEnum._add("BitDepth1", "BD1 ");
PSEnum._add("BitDepth16", "BD16");
PSEnum._add("BitDepth24", "BD24");
PSEnum._add("BitDepth32", "BD32");
PSEnum._add("BitDepth4", "BD4 ");
PSEnum._add("BitDepth8", "BD8 ");
PSEnum._add("BitDepthA1R5G5B5", "1565");
PSEnum._add("BitDepthR5G6B5", "x565");
PSEnum._add("BitDepthX4R4G4B4", "x444");
PSEnum._add("BitDepthA4R4G4B4", "4444");
PSEnum._add("BitDepthX8R8G8B8", "x888");
PSEnum._add("Bitmap", "Btmp");
PSEnum._add("Black", "Blck");
PSEnum._add("BlackAndWhite", "BanW");
PSEnum._add("BlackBody", "BlcB");
PSEnum._add("Blacks", "Blks");
PSEnum._add("BlockEraser", "Blk ");
PSEnum._add("Blast", "Blst");
PSEnum._add("Blocks", "Blks");
PSEnum._add("Blue", "Bl  ");
PSEnum._add("Blues", "Bls ");
PSEnum._add("Bottom", "Bttm");
PSEnum._add("BrushDarkRough", "BrDR");
PSEnum._add("BrushesAppend", "BrsA");
PSEnum._add("BrushesDefine", "BrsD");
PSEnum._add("BrushesDelete", "Brsf");
PSEnum._add("BrushesLoad", "Brsd");
PSEnum._add("BrushesNew", "BrsN");
PSEnum._add("BrushesOptions", "BrsO");
PSEnum._add("BrushesReset", "BrsR");
PSEnum._add("BrushesSave", "Brsv");
PSEnum._add("BrushLightRough", "BrsL");
PSEnum._add("BrushSimple", "BrSm");
PSEnum._add("BrushSize", "BrsS");
PSEnum._add("BrushSparkle", "BrSp");
PSEnum._add("BrushWideBlurry", "BrbW");
PSEnum._add("BrushWideSharp", "BrsW");
PSEnum._add("Builtin", "Bltn");
PSEnum._add("BurnInH", "BrnH");
PSEnum._add("BurnInM", "BrnM");
PSEnum._add("BurnInS", "BrnS");
PSEnum._add("ButtonMode", "BtnM");
PSEnum._add("CIERGB", "CRGB");
PSEnum._add("WidePhosphors", "Wide");
PSEnum._add("WideGamutRGB", "WRGB");
PSEnum._add("CMYK", "CMYK");
PSEnum._add("CMYK64", "CMSF");
PSEnum._add("CMYKColor", "ECMY");
PSEnum._add("Calculations", "Clcl");
PSEnum._add("Cascade", "Cscd");
PSEnum._add("Center", "Cntr");
PSEnum._add("CenterGlow", "SrcC");
PSEnum._add("CenteredFrame", "CtrF");
PSEnum._add("ChannelOptions", "ChnO");
PSEnum._add("ChannelsPaletteOptions", "ChnP");
PSEnum._add("CheckerboardNone", "ChcN");
PSEnum._add("CheckerboardSmall", "ChcS");
PSEnum._add("CheckerboardMedium", "ChcM");
PSEnum._add("CheckerboardLarge", "ChcL");
PSEnum._add("Clear", "Clar");
PSEnum._add("ClearGuides", "ClrG");
PSEnum._add("Clipboard", "Clpb");
PSEnum._add("ClippingPath", "ClpP");
PSEnum._add("CloseAll", "ClsA");
PSEnum._add("CoarseDots", "CrsD");
PSEnum._add("Color", "Clr ");
PSEnum._add("ColorBurn", "CBrn");
PSEnum._add("ColorDodge", "CDdg");
PSEnum._add("ColorMatch", "ClMt");
PSEnum._add("ColorNoise", "ClNs");
PSEnum._add("Colorimetric", "Clrm");
PSEnum._add("Composite", "Cmps");
PSEnum._add("ConvertToCMYK", "CnvC");
PSEnum._add("ConvertToGray", "CnvG");
PSEnum._add("ConvertToLab", "CnvL");
PSEnum._add("ConvertToRGB", "CnvR");
PSEnum._add("CreateDuplicate", "CrtD");
PSEnum._add("CreateInterpolation", "CrtI");
PSEnum._add("Cross", "Crs ");
PSEnum._add("CurrentLayer", "CrrL");
PSEnum._add("Custom", "Cst ");
PSEnum._add("CustomPattern", "Cstm");
PSEnum._add("CustomStops", "CstS");
PSEnum._add("Cyan", "Cyn ");
PSEnum._add("Cyans", "Cyns");
PSEnum._add("Dark", "Drk ");
PSEnum._add("Darken", "Drkn");
PSEnum._add("DarkenOnly", "DrkO");
PSEnum._add("DashedLines", "DshL");
PSEnum._add("Desaturate", "Dstt");
PSEnum._add("Diamond", "Dmnd");
PSEnum._add("Difference", "Dfrn");
PSEnum._add("Diffusion", "Dfsn");
PSEnum._add("DiffusionDither", "DfnD");
PSEnum._add("DisplayCursorsPreferences", "DspC");
PSEnum._add("Dissolve", "Dslv");
PSEnum._add("Distort", "Dstr");
PSEnum._add("DodgeH", "DdgH");
PSEnum._add("DodgeM", "DdgM");
PSEnum._add("DodgeS", "DdgS");
PSEnum._add("Dots", "Dts ");
PSEnum._add("Draft", "Drft");
PSEnum._add("Duotone", "Dtn ");
PSEnum._add("EBUITU", "EBT ");
PSEnum._add("EdgeGlow", "SrcE");
PSEnum._add("EliminateEvenFields", "ElmE");
PSEnum._add("EliminateOddFields", "ElmO");
PSEnum._add("Ellipse", "Elps");
PSEnum._add("Emboss", "Embs");
PSEnum._add("Exact", "Exct");
PSEnum._add("Exclusion", "Xclu");
PSEnum._add("FPXCompressLossyJPEG", "FxJP");
PSEnum._add("FPXCompressNone", "FxNo");
PSEnum._add("Faster", "Dthf");
PSEnum._add("File", "Fle ");
PSEnum._add("FileInfo", "FlIn");
PSEnum._add("FillBack", "FlBc");
PSEnum._add("FillFore", "FlFr");
PSEnum._add("FillInverse", "FlIn");
PSEnum._add("FillSame", "FlSm");
PSEnum._add("FineDots", "FnDt");
PSEnum._add("First", "Frst");
PSEnum._add("FirstIdle", "FrId");
PSEnum._add("FitOnScreen", "FtOn");
PSEnum._add("ForegroundColor", "FrgC");
PSEnum._add("Forward", "Frwr");
PSEnum._add("FreeTransform", "FrTr");
PSEnum._add("Front", "Frnt");
PSEnum._add("FullDocument", "FllD");
PSEnum._add("FullSize", "FlSz");
PSEnum._add("GaussianDistribution", "Gsn ");
PSEnum._add("GIFColorFileColorTable", "GFCT");
PSEnum._add("GIFColorFileColors", "GFCF");
PSEnum._add("GIFColorFileMicrosoftPalette", "GFMS");
PSEnum._add("GIFPaletteAdaptive", "GFPA");
PSEnum._add("GIFPaletteExact", "GFPE");
PSEnum._add("GIFPaletteOther", "GFPO");
PSEnum._add("GIFPaletteSystem", "GFPS");
PSEnum._add("GIFRequiredColorSpaceIndexed", "GFCI");
PSEnum._add("GIFRequiredColorSpaceRGB", "GFRG");
PSEnum._add("GIFRowOrderInterlaced", "GFIN");
PSEnum._add("GIFRowOrderNormal", "GFNI");
PSEnum._add("GeneralPreferences", "GnrP");
PSEnum._add("Good", "Gd  ");
PSEnum._add("GradientFill", "GrFl");
PSEnum._add("GrainClumped", "GrnC");
PSEnum._add("GrainContrasty", "GrCn");
PSEnum._add("GrainEnlarged", "GrnE");
PSEnum._add("GrainHorizontal", "GrnH");
PSEnum._add("GrainRegular", "GrnR");
PSEnum._add("GrainSoft", "GrSf");
PSEnum._add("GrainSpeckle", "GrSp");
PSEnum._add("GrainSprinkles", "GrSr");
PSEnum._add("GrainStippled", "GrSt");
PSEnum._add("GrainVertical", "GrnV");
PSEnum._add("GrainyDots", "GrnD");
PSEnum._add("Graphics", "Grp ");
PSEnum._add("Gray", "Gry ");
PSEnum._add("Gray16", "GryX");
PSEnum._add("Gray18", "Gr18");
PSEnum._add("Gray22", "Gr22");
PSEnum._add("Gray50", "Gr50");
PSEnum._add("GrayScale", "Gryc");
PSEnum._add("Grayscale", "Grys");
PSEnum._add("Green", "Grn ");
PSEnum._add("Greens", "Grns");
PSEnum._add("GuidesGridPreferences", "GudG");
PSEnum._add("HDTV", "HDTV");
PSEnum._add("HSBColor", "HSBl");
PSEnum._add("HSLColor", "HSLC");
PSEnum._add("HalftoneFile", "HlfF");
PSEnum._add("HalftoneScreen", "HlfS");
PSEnum._add("HardLight", "HrdL");
PSEnum._add("Heavy", "Hvy ");
PSEnum._add("HideAll", "HdAl");
PSEnum._add("HideSelection", "HdSl");
PSEnum._add("High", "High");
PSEnum._add("HighQuality", "Hgh ");
PSEnum._add("Highlights", "Hghl");
PSEnum._add("Histogram", "Hstg");
PSEnum._add("History", "Hsty");
PSEnum._add("HistoryPaletteOptions", "HstO");
PSEnum._add("HistoryPreferences", "HstP");
PSEnum._add("Horizontal", "Hrzn");
PSEnum._add("HorizontalOnly", "HrzO");
PSEnum._add("Hue", "H   ");
PSEnum._add("IBMPC", "IBMP");
PSEnum._add("ICC", "ICC ");
PSEnum._add("Icon", "Icn ");
PSEnum._add("IdleVM", "IdVM");
PSEnum._add("Ignore", "Ignr");
PSEnum._add("Image", "Img ");
PSEnum._add("ImageCachePreferences", "ImgP");
PSEnum._add("IndexedColor", "Indl");
PSEnum._add("InfoPaletteOptions", "InfP");
PSEnum._add("InfoPaletteToggleSamplers", "InfT");
PSEnum._add("InnerBevel", "InrB");
PSEnum._add("InsetFrame", "InsF");
PSEnum._add("Inside", "Insd");
PSEnum._add("JPEG", "JPEG");
PSEnum._add("JustifyAll", "JstA");
PSEnum._add("JustifyFull", "JstF");
PSEnum._add("KeepProfile", "KPro");
PSEnum._add("KeyboardPreferences", "KybP");
PSEnum._add("Lab", "Lab ");
PSEnum._add("Lab48", "LbCF");
PSEnum._add("LabColor", "LbCl");
PSEnum._add("Large", "Lrg ");
PSEnum._add("Last", "Lst ");
PSEnum._add("LastFilter", "LstF");
PSEnum._add("LayerOptions", "LyrO");
PSEnum._add("LayersPaletteOptions", "LyrP");
PSEnum._add("Left", "Left");
PSEnum._add("LevelBased", "LvlB");
PSEnum._add("Light", "Lgt ");
PSEnum._add("LightBlue", "LgtB");
PSEnum._add("LightDirBottom", "LDBt");
PSEnum._add("LightDirBottomLeft", "LDBL");
PSEnum._add("LightDirBottomRight", "LDBR");
PSEnum._add("LightDirLeft", "LDLf");
PSEnum._add("LightDirRight", "LDRg");
PSEnum._add("LightDirTop", "LDTp");
PSEnum._add("LightDirTopLeft", "LDTL");
PSEnum._add("LightDirTopRight", "LDTR");
PSEnum._add("LightGray", "LgtG");
PSEnum._add("LightDirectional", "LghD");
PSEnum._add("LightenOnly", "LghO");
PSEnum._add("LightOmni", "LghO");
PSEnum._add("LightPosBottom", "LPBt");
PSEnum._add("LightPosBottomLeft", "LPBL");
PSEnum._add("LightPosBottomRight", "LPBr");
PSEnum._add("LightPosLeft", "LPLf");
PSEnum._add("LightPosRight", "LPRg");
PSEnum._add("LightPosTop", "LPTp");
PSEnum._add("LightPosTopLeft", "LPTL");
PSEnum._add("LightPosTopRight", "LPTR");
PSEnum._add("LightRed", "LgtR");
PSEnum._add("LightSpot", "LghS");
PSEnum._add("Lighten", "Lghn");
PSEnum._add("Lightness", "Lght");
PSEnum._add("Line", "Ln  ");
PSEnum._add("Lines", "Lns ");
PSEnum._add("Linear", "Lnr ");
PSEnum._add("Linked", "Lnkd");
PSEnum._add("LongLines", "LngL");
PSEnum._add("LongStrokes", "LngS");
PSEnum._add("Low", "Low ");
PSEnum._add("Lower", "Lwr ");
PSEnum._add("LowQuality", "Lw  ");
PSEnum._add("Luminosity", "Lmns");
PSEnum._add("Maya", "Maya");
PSEnum._add("MacThumbnail", "McTh");
PSEnum._add("Macintosh", "Mcnt");
PSEnum._add("MacintoshSystem", "McnS");
PSEnum._add("Magenta", "Mgnt");
PSEnum._add("Magentas", "Mgnt");
PSEnum._add("Mask", "Msk ");
PSEnum._add("MaskedAreas", "MskA");
PSEnum._add("MasterAdaptive", "MAdp");
PSEnum._add("MasterPerceptual", "MPer");
PSEnum._add("MasterSelective", "MSel");
PSEnum._add("Maximum", "Mxmm");
PSEnum._add("MaximumQuality", "Mxm ");
PSEnum._add("Medium", "Mdim");
PSEnum._add("MediumBlue", "MdmB");
PSEnum._add("MediumQuality", "Mdm ");
PSEnum._add("MediumDots", "MdmD");
PSEnum._add("MediumLines", "MdmL");
PSEnum._add("MediumStrokes", "MdmS");
PSEnum._add("MemoryPreferences", "MmrP");
PSEnum._add("MergeChannels", "MrgC");
PSEnum._add("Merged", "Mrgd");
PSEnum._add("MergedLayers", "Mrg2");
PSEnum._add("MergedLayersOld", "MrgL");
PSEnum._add("Middle", "Mddl");
PSEnum._add("Midtones", "Mdtn");
PSEnum._add("ModeGray", "MdGr");
PSEnum._add("ModeRGB", "MdRG");
PSEnum._add("Monitor", "Moni");
PSEnum._add("Monotone", "Mntn");
PSEnum._add("Multi72Color", "72CM");
PSEnum._add("Multi72Gray", "72GM");
PSEnum._add("Multichannel", "Mlth");
PSEnum._add("MultiNoCompositePS", "NCmM");
PSEnum._add("Multiply", "Mltp");
PSEnum._add("NavigatorPaletteOptions", "NvgP");
PSEnum._add("NearestNeighbor", "Nrst");
PSEnum._add("NetscapeGray", "NsGr");
PSEnum._add("Neutrals", "Ntrl");
PSEnum._add("NewView", "NwVw");
PSEnum._add("Next", "Nxt ");
PSEnum._add("Nikon", "Nkn ");
PSEnum._add("Nikon105", "Nkn1");
PSEnum._add("No", "N   ");
PSEnum._add("NoCompositePS", "NCmp");
PSEnum._add("None", "None");
PSEnum._add("Normal", "Nrml");
PSEnum._add("NormalPath", "NrmP");
PSEnum._add("NTSC", "NTSC");
PSEnum._add("Null", "null");
PSEnum._add("OS2", "OS2 ");
PSEnum._add("Off", "Off ");
PSEnum._add("On", "On  ");
PSEnum._add("OpenAs", "OpAs");
PSEnum._add("Orange", "Orng");
PSEnum._add("OutFromCenter", "OtFr");
PSEnum._add("OutOfGamut", "OtOf");
PSEnum._add("OuterBevel", "OtrB");
PSEnum._add("Outside", "Otsd");
PSEnum._add("OutsetFrame", "OutF");
PSEnum._add("Overlay", "Ovrl");
PSEnum._add("PaintbrushEraser", "Pntb");
PSEnum._add("PencilEraser", "Pncl");
PSEnum._add("P22EBU", "P22B");
PSEnum._add("PNGFilterAdaptive", "PGAd");
PSEnum._add("PNGFilterAverage", "PGAv");
PSEnum._add("PNGFilterNone", "PGNo");
PSEnum._add("PNGFilterPaeth", "PGPt");
PSEnum._add("PNGFilterSub", "PGSb");
PSEnum._add("PNGFilterUp", "PGUp");
PSEnum._add("PNGInterlaceAdam7", "PGIA");
PSEnum._add("PNGInterlaceNone", "PGIN");
PSEnum._add("PagePosCentered", "PgPC");
PSEnum._add("PagePosTopLeft", "PgTL");
PSEnum._add("PageSetup", "PgSt");
PSEnum._add("PalSecam", "PlSc");
PSEnum._add("PanaVision", "PnVs");
PSEnum._add("PathsPaletteOptions", "PthP");
PSEnum._add("Pattern", "Ptrn");
PSEnum._add("PatternDither", "PtnD");
PSEnum._add("Perceptual", "Perc");
PSEnum._add("Perspective", "Prsp");
PSEnum._add("PhotoshopPicker", "Phtk");
PSEnum._add("PickCMYK", "PckC");
PSEnum._add("PickGray", "PckG");
PSEnum._add("PickHSB", "PckH");
PSEnum._add("PickLab", "PckL");
PSEnum._add("PickOptions", "PckO");
PSEnum._add("PickRGB", "PckR");
PSEnum._add("PillowEmboss", "PlEb");
PSEnum._add("PixelPaintSize1", "PxS1");
PSEnum._add("PixelPaintSize2", "PxS2");
PSEnum._add("PixelPaintSize3", "PxS3");
PSEnum._add("PixelPaintSize4", "PxS4");
PSEnum._add("Place", "Plce");
PSEnum._add("PlaybackOptions", "PbkO");
PSEnum._add("PluginPicker", "PlgP");
PSEnum._add("PluginsScratchDiskPreferences", "PlgS");
PSEnum._add("PolarToRect", "PlrR");
PSEnum._add("PondRipples", "PndR");
PSEnum._add("Precise", "Prc ");
PSEnum._add("PreciseMatte", "PrBL");
PSEnum._add("PreviewOff", "PrvO");
PSEnum._add("PreviewCMYK", "PrvC");
PSEnum._add("PreviewCyan", "Prvy");
PSEnum._add("PreviewMagenta", "PrvM");
PSEnum._add("PreviewYellow", "PrvY");
PSEnum._add("PreviewBlack", "PrvB");
PSEnum._add("PreviewCMY", "PrvN");
PSEnum._add("Previous", "Prvs");
PSEnum._add("Primaries", "Prim");
PSEnum._add("PrintSize", "PrnS");
PSEnum._add("PrintingInksSetup", "PrnI");
PSEnum._add("Purple", "Prp ");
PSEnum._add("Pyramids", "Pyrm");
PSEnum._add("QCSAverage", "Qcsa");
PSEnum._add("QCSCorner0", "Qcs0");
PSEnum._add("QCSCorner1", "Qcs1");
PSEnum._add("QCSCorner2", "Qcs2");
PSEnum._add("QCSCorner3", "Qcs3");
PSEnum._add("QCSIndependent", "Qcsi");
PSEnum._add("QCSSide0", "Qcs4");
PSEnum._add("QCSSide1", "Qcs5");
PSEnum._add("QCSSide2", "Qcs6");
PSEnum._add("QCSSide3", "Qcs7");
PSEnum._add("Quadtone", "Qdtn");
PSEnum._add("QueryAlways", "QurA");
PSEnum._add("QueryAsk", "Qurl");
PSEnum._add("QueryNever", "QurN");
PSEnum._add("Repeat", "Rpt ");
PSEnum._add("RGB", "RGB ");
PSEnum._add("RGB48", "RGBF");
PSEnum._add("RGBColor", "RGBC");
PSEnum._add("Radial", "Rdl ");
PSEnum._add("Random", "Rndm");
PSEnum._add("RectToPolar", "RctP");
PSEnum._add("Red", "Rd  ");
PSEnum._add("RedrawComplete", "RdCm");
PSEnum._add("Reds", "Rds ");
PSEnum._add("Reflected", "Rflc");
PSEnum._add("Relative", "Rltv");
PSEnum._add("RepeatEdgePixels", "RptE");
PSEnum._add("RevealAll", "RvlA");
PSEnum._add("RevealSelection", "RvlS");
PSEnum._add("Revert", "Rvrt");
PSEnum._add("Right", "Rght");
PSEnum._add("Rotate", "Rtte");
PSEnum._add("RotoscopingPreferences", "RtsP");
PSEnum._add("Round", "Rnd ");
PSEnum._add("RulerCm", "RrCm");
PSEnum._add("RulerInches", "RrIn");
PSEnum._add("RulerPercent", "RrPr");
PSEnum._add("RulerPicas", "RrPi");
PSEnum._add("RulerPixels", "RrPx");
PSEnum._add("RulerPoints", "RrPt");
PSEnum._add("AdobeRGB1998", "SMPT");
PSEnum._add("SMPTEC", "SMPC");
PSEnum._add("SRGB", "SRGB");
PSEnum._add("Sample3x3", "Smp3");
PSEnum._add("Sample5x5", "Smp5");
PSEnum._add("SamplePoint", "SmpP");
PSEnum._add("Saturate", "Str ");
PSEnum._add("Saturation", "Strt");
PSEnum._add("Saved", "Sved");
PSEnum._add("SaveForWeb", "Svfw");
PSEnum._add("SavingFilesPreferences", "SvnF");
PSEnum._add("Scale", "Scl ");
PSEnum._add("Screen", "Scrn");
PSEnum._add("ScreenCircle", "ScrC");
PSEnum._add("ScreenDot", "ScrD");
PSEnum._add("ScreenLine", "ScrL");
PSEnum._add("SelectedAreas", "SlcA");
PSEnum._add("Selection", "Slct");
PSEnum._add("Selective", "Sele");
PSEnum._add("SeparationSetup", "SprS");
PSEnum._add("SeparationTables", "SprT");
PSEnum._add("Shadows", "Shdw");
PSEnum._add("ContourLinear", "sp01");
PSEnum._add("ContourGaussian", "sp02");
PSEnum._add("ContourSingle", "sp03");
PSEnum._add("ContourDouble", "sp04");
PSEnum._add("ContourTriple", "sp05");
PSEnum._add("ContourCustom", "sp06");
PSEnum._add("ShortLines", "ShrL");
PSEnum._add("ShortStrokes", "ShSt");
PSEnum._add("Single72Color", "72CS");
PSEnum._add("Single72Gray", "72GS");
PSEnum._add("SingleNoCompositePS", "NCmS");
PSEnum._add("Skew", "Skew");
PSEnum._add("SlopeLimitMatte", "Slmt");
PSEnum._add("Small", "Sml ");
PSEnum._add("SmartBlurModeEdgeOnly", "SBME");
PSEnum._add("SmartBlurModeNormal", "SBMN");
PSEnum._add("SmartBlurModeOverlayEdge", "SBMO");
PSEnum._add("SmartBlurQualityHigh", "SBQH");
PSEnum._add("SmartBlurQualityLow", "SBQL");
PSEnum._add("SmartBlurQualityMedium", "SBQM");
PSEnum._add("Snapshot", "Snps");
PSEnum._add("SolidColor", "SClr");
PSEnum._add("SoftLight", "SftL");
PSEnum._add("SoftMatte", "SfBL");
PSEnum._add("Spectrum", "Spct");
PSEnum._add("Spin", "Spn ");
PSEnum._add("SpotColor", "Spot");
PSEnum._add("Square", "Sqr ");
PSEnum._add("Stagger", "Stgr");
PSEnum._add("StampIn", "In  ");
PSEnum._add("StampOut", "Out ");
PSEnum._add("Standard", "Std ");
PSEnum._add("StdA", "StdA");
PSEnum._add("StdB", "StdB");
PSEnum._add("StdC", "StdC");
PSEnum._add("StdE", "StdE");
PSEnum._add("StretchToFit", "StrF");
PSEnum._add("StrokeDirHorizontal", "SDHz");
PSEnum._add("StrokeDirLeftDiag", "SDLD");
PSEnum._add("StrokeDirRightDiag", "SDRD");
PSEnum._add("StrokeDirVertical", "SDVt");
PSEnum._add("StylesAppend", "SlsA");
PSEnum._add("StylesDelete", "Slsf");
PSEnum._add("StylesLoad", "Slsd");
PSEnum._add("StylesNew", "SlsN");
PSEnum._add("StylesReset", "SlsR");
PSEnum._add("StylesSave", "Slsv");
PSEnum._add("Subtract", "Sbtr");
PSEnum._add("SwatchesAppend", "SwtA");
PSEnum._add("SwatchesReplace", "Swtp");
PSEnum._add("SwatchesReset", "SwtR");
PSEnum._add("SwatchesSave", "SwtS");
PSEnum._add("SystemPicker", "SysP");
PSEnum._add("Tables", "Tbl ");
PSEnum._add("Target", "Trgt");
PSEnum._add("TargetPath", "Trgp");
PSEnum._add("TexTypeBlocks", "TxBl");
PSEnum._add("TexTypeBrick", "TxBr");
PSEnum._add("TexTypeBurlap", "TxBu");
PSEnum._add("TexTypeCanvas", "TxCa");
PSEnum._add("TexTypeFrosted", "TxFr");
PSEnum._add("TexTypeSandstone", "TxSt");
PSEnum._add("TexTypeTinyLens", "TxTL");
PSEnum._add("Threshold", "Thrh");
PSEnum._add("Thumbnail", "Thmb");
PSEnum._add("TIFF", "TIFF");
PSEnum._add("Tile", "Tile");
PSEnum._add("ToggleActionsPalette", "TglA");
PSEnum._add("ToggleBlackPreview", "TgBP");
PSEnum._add("ToggleBrushesPalette", "TglB");
PSEnum._add("ToggleCMYKPreview", "TglC");
PSEnum._add("ToggleCMYPreview", "TgCM");
PSEnum._add("ToggleChannelsPalette", "Tglh");
PSEnum._add("ToggleColorPalette", "Tglc");
PSEnum._add("ToggleCyanPreview", "TgCP");
PSEnum._add("ToggleEdges", "TglE");
PSEnum._add("ToggleGamutWarning", "TglG");
PSEnum._add("ToggleGrid", "TgGr");
PSEnum._add("ToggleGuides", "Tgld");
PSEnum._add("ToggleHistoryPalette", "TglH");
PSEnum._add("ToggleInfoPalette", "TglI");
PSEnum._add("ToggleLayerMask", "TglM");
PSEnum._add("ToggleLayersPalette", "Tgly");
PSEnum._add("ToggleLockGuides", "TglL");
PSEnum._add("ToggleMagentaPreview", "TgMP");
PSEnum._add("ToggleNavigatorPalette", "TglN");
PSEnum._add("ToggleOptionsPalette", "TglO");
PSEnum._add("TogglePaths", "TglP");
PSEnum._add("TogglePathsPalette", "Tglt");
PSEnum._add("ToggleRGBMacPreview", "TrMp");
PSEnum._add("ToggleRGBWindowsPreview", "TrWp");
PSEnum._add("ToggleRGBUncompensatedPreview", "TrUp");
PSEnum._add("ToggleRulers", "TglR");
PSEnum._add("ToggleSnapToGrid", "TgSn");
PSEnum._add("ToggleSnapToGuides", "TglS");
PSEnum._add("ToggleStatusBar", "Tgls");
PSEnum._add("ToggleStylesPalette", "TgSl");
PSEnum._add("ToggleSwatchesPalette", "Tglw");
PSEnum._add("ToggleToolsPalette", "TglT");
PSEnum._add("ToggleYellowPreview", "TgYP");
PSEnum._add("Top", "Top ");
PSEnum._add("Transparency", "Trsp");
PSEnum._add("TransparencyGamutPreferences", "TrnG");
PSEnum._add("Transparent", "Trns");
PSEnum._add("Trinitron", "Trnt");
PSEnum._add("Tritone", "Trtn");
PSEnum._add("UIBitmap", "UBtm");
PSEnum._add("UICMYK", "UCMY");
PSEnum._add("UIDuotone", "UDtn");
PSEnum._add("UIGrayscale", "UGry");
PSEnum._add("UIIndexed", "UInd");
PSEnum._add("UILab", "ULab");
PSEnum._add("UIMultichannel", "UMlt");
PSEnum._add("UIRGB", "URGB");
PSEnum._add("Undo", "Und ");
PSEnum._add("Uniform", "Unfm");
PSEnum._add("UniformDistribution", "Unfr");
PSEnum._add("UnitsRulersPreferences", "UntR");
PSEnum._add("Upper", "Upr ");
PSEnum._add("UserStop", "UsrS");
PSEnum._add("VMPreferences", "VMPr");
PSEnum._add("Vertical", "Vrtc");
PSEnum._add("VerticalOnly", "VrtO");
PSEnum._add("Violet", "Vlt ");
PSEnum._add("WaveSine", "WvSn");
PSEnum._add("WaveSquare", "WvSq");
PSEnum._add("WaveTriangle", "WvTr");
PSEnum._add("Web", "Web ");
PSEnum._add("White", "Wht ");
PSEnum._add("Whites", "Whts");
PSEnum._add("WinThumbnail", "WnTh");
PSEnum._add("Wind", "Wnd ");
PSEnum._add("Windows", "Win ");
PSEnum._add("WindowsSystem", "WndS");
PSEnum._add("Wrap", "Wrp ");
PSEnum._add("WrapAround", "WrpA");
PSEnum._add("WorkPath", "WrkP");
PSEnum._add("Yellow", "Yllw");
PSEnum._add("YellowColor", "Ylw ");
PSEnum._add("Yellows", "Ylws");
PSEnum._add("Yes", "Ys  ");
PSEnum._add("Zip", "ZpEn");
PSEnum._add("Zoom", "Zm  ");
PSEnum._add("ZoomIn", "ZmIn");
PSEnum._add("ZoomOut", "ZmOt");

PSEvent._add("3DTransform", "TdT ");
PSEvent._add("Average", "Avrg");
PSEvent._add("ApplyStyle", "ASty");
PSEvent._add("Assert", "Asrt");
PSEvent._add("AccentedEdges", "AccE");
PSEvent._add("Add", "Add ");
PSEvent._add("AddNoise", "AdNs");
PSEvent._add("AddTo", "AddT");
PSEvent._add("Align", "Algn");
PSEvent._add("All", "All ");
PSEvent._add("AngledStrokes", "AngS");
PSEvent._add("ApplyImage", "AppI");
PSEvent._add("BasRelief", "BsRl");
PSEvent._add("Batch", "Btch");
PSEvent._add("BatchFromDroplet", "BtcF");
PSEvent._add("Blur", "Blr ");
PSEvent._add("BlurMore", "BlrM");
PSEvent._add("Border", "Brdr");
PSEvent._add("Brightness", "BrgC");
PSEvent._add("CanvasSize", "CnvS");
PSEvent._add("ChalkCharcoal", "ChlC");
PSEvent._add("ChannelMixer", "ChnM");
PSEvent._add("Charcoal", "Chrc");
PSEvent._add("Chrome", "Chrm");
PSEvent._add("Clear", "Cler");
PSEvent._add("Close", "Cls ");
PSEvent._add("Clouds", "Clds");
PSEvent._add("ColorBalance", "ClrB");
PSEvent._add("ColorHalftone", "ClrH");
PSEvent._add("ColorRange", "ClrR");
PSEvent._add("ColoredPencil", "ClrP");
PSEvent._add("ConteCrayon", "CntC");
PSEvent._add("Contract", "Cntc");
PSEvent._add("ConvertMode", "CnvM");
PSEvent._add("Copy", "copy");
PSEvent._add("CopyEffects", "CpFX");
PSEvent._add("CopyMerged", "CpyM");
PSEvent._add("CopyToLayer", "CpTL");
PSEvent._add("Craquelure", "Crql");
PSEvent._add("CreateDroplet", "CrtD");
PSEvent._add("Crop", "Crop");
PSEvent._add("Crosshatch", "Crsh");
PSEvent._add("Crystallize", "Crst");
PSEvent._add("Curves", "Crvs");
PSEvent._add("Custom", "Cstm");
PSEvent._add("Cut", "cut ");
PSEvent._add("CutToLayer", "CtTL");
PSEvent._add("Cutout", "Ct  ");
PSEvent._add("DarkStrokes", "DrkS");
PSEvent._add("DeInterlace", "Dntr");
PSEvent._add("DefinePattern", "DfnP");
PSEvent._add("Defringe", "Dfrg");
PSEvent._add("Delete", "Dlt ");
PSEvent._add("Desaturate", "Dstt");
PSEvent._add("Deselect", "Dslc");
PSEvent._add("Despeckle", "Dspc");
PSEvent._add("DifferenceClouds", "DfrC");
PSEvent._add("Diffuse", "Dfs ");
PSEvent._add("DiffuseGlow", "DfsG");
PSEvent._add("DisableLayerFX", "dlfx");
PSEvent._add("Displace", "Dspl");
PSEvent._add("Distribute", "Dstr");
PSEvent._add("Draw", "Draw");
PSEvent._add("DryBrush", "DryB");
PSEvent._add("Duplicate", "Dplc");
PSEvent._add("DustAndScratches", "DstS");
PSEvent._add("Emboss", "Embs");
PSEvent._add("Equalize", "Eqlz");
PSEvent._add("Exchange", "Exch");
PSEvent._add("Expand", "Expn");
PSEvent._add("Export", "Expr");
PSEvent._add("Extrude", "Extr");
PSEvent._add("Facet", "Fct ");
PSEvent._add("Fade", "Fade");
PSEvent._add("Feather", "Fthr");
PSEvent._add("Fibers", "Fbrs");
PSEvent._add("Fill", "Fl  ");
PSEvent._add("FilmGrain", "FlmG");
PSEvent._add("Filter", "Fltr");
PSEvent._add("FindEdges", "FndE");
PSEvent._add("FlattenImage", "FltI");
PSEvent._add("Flip", "Flip");
PSEvent._add("Fragment", "Frgm");
PSEvent._add("Fresco", "Frsc");
PSEvent._add("GaussianBlur", "GsnB");
PSEvent._add("Get", "getd");
PSEvent._add("Glass", "Gls ");
PSEvent._add("GlowingEdges", "GlwE");
PSEvent._add("Gradient", "Grdn");
PSEvent._add("GradientMap", "GrMp");
PSEvent._add("Grain", "Grn ");
PSEvent._add("GraphicPen", "GraP");
PSEvent._add("Group", "GrpL");
PSEvent._add("Grow", "Grow");
PSEvent._add("HalftoneScreen", "HlfS");
PSEvent._add("Hide", "Hd  ");
PSEvent._add("HighPass", "HghP");
PSEvent._add("HSBHSL", "HsbP");
PSEvent._add("HueSaturation", "HStr");
PSEvent._add("ImageSize", "ImgS");
PSEvent._add("Import", "Impr");
PSEvent._add("InkOutlines", "InkO");
PSEvent._add("Intersect", "Intr");
PSEvent._add("IntersectWith", "IntW");
PSEvent._add("Inverse", "Invs");
PSEvent._add("Invert", "Invr");
PSEvent._add("LensFlare", "LnsF");
PSEvent._add("Levels", "Lvls");
PSEvent._add("LightingEffects", "LghE");
PSEvent._add("Link", "Lnk ");
PSEvent._add("Make", "Mk  ");
PSEvent._add("Maximum", "Mxm ");
PSEvent._add("Median", "Mdn ");
PSEvent._add("MergeLayers", "Mrg2");
PSEvent._add("MergeLayersOld", "MrgL");
PSEvent._add("MergeSpotChannel", "MSpt");
PSEvent._add("MergeVisible", "MrgV");
PSEvent._add("Mezzotint", "Mztn");
PSEvent._add("Minimum", "Mnm ");
PSEvent._add("Mosaic", "Msc ");
PSEvent._add("MotionBlur", "MtnB");
PSEvent._add("Move", "move");
PSEvent._add("NTSCColors", "NTSC");
PSEvent._add("NeonGlow", "NGlw");
PSEvent._add("Next", "Nxt ");
PSEvent._add("NotePaper", "NtPr");
PSEvent._add("Notify", "Ntfy");
PSEvent._add("Null", "null");
PSEvent._add("OceanRipple", "OcnR");
PSEvent._add("Offset", "Ofst");
PSEvent._add("Open", "Opn ");
PSEvent._add("PaintDaubs", "PntD");
PSEvent._add("PaletteKnife", "PltK");
PSEvent._add("Paste", "past");
PSEvent._add("PasteEffects", "PaFX");
PSEvent._add("PasteInto", "PstI");
PSEvent._add("PasteOutside", "PstO");
PSEvent._add("Patchwork", "Ptch");
PSEvent._add("Photocopy", "Phtc");
PSEvent._add("Pinch", "Pnch");
PSEvent._add("Place", "Plc ");
PSEvent._add("Plaster", "Plst");
PSEvent._add("PlasticWrap", "PlsW");
PSEvent._add("Play", "Ply ");
PSEvent._add("Pointillize", "Pntl");
PSEvent._add("Polar", "Plr ");
PSEvent._add("PosterEdges", "PstE");
PSEvent._add("Posterize", "Pstr");
PSEvent._add("Previous", "Prvs");
PSEvent._add("Print", "Prnt");
PSEvent._add("ProfileToProfile", "PrfT");
PSEvent._add("Purge", "Prge");
PSEvent._add("Quit", "quit");
PSEvent._add("RadialBlur", "RdlB");
PSEvent._add("Rasterize", "Rstr");
PSEvent._add("RasterizeTypeSheet", "RstT");
PSEvent._add("RemoveBlackMatte", "RmvB");
PSEvent._add("RemoveLayerMask", "RmvL");
PSEvent._add("RemoveWhiteMatte", "RmvW");
PSEvent._add("Rename", "Rnm ");
PSEvent._add("ReplaceColor", "RplC");
PSEvent._add("Reset", "Rset");
PSEvent._add("Reticulation", "Rtcl");
PSEvent._add("Revert", "Rvrt");
PSEvent._add("Ripple", "Rple");
PSEvent._add("Rotate", "Rtte");
PSEvent._add("RoughPastels", "RghP");
PSEvent._add("Save", "save");
PSEvent._add("Select", "slct");
PSEvent._add("SelectiveColor", "SlcC");
PSEvent._add("Set", "setd");
PSEvent._add("SharpenEdges", "ShrE");
PSEvent._add("Sharpen", "Shrp");
PSEvent._add("SharpenMore", "ShrM");
PSEvent._add("Shear", "Shr ");
PSEvent._add("Show", "Shw ");
PSEvent._add("Similar", "Smlr");
PSEvent._add("SmartBlur", "SmrB");
PSEvent._add("Smooth", "Smth");
PSEvent._add("SmudgeStick", "SmdS");
PSEvent._add("Solarize", "Slrz");
PSEvent._add("Spatter", "Spt ");
PSEvent._add("Spherize", "Sphr");
PSEvent._add("SplitChannels", "SplC");
PSEvent._add("Sponge", "Spng");
PSEvent._add("SprayedStrokes", "SprS");
PSEvent._add("StainedGlass", "StnG");
PSEvent._add("Stamp", "Stmp");
PSEvent._add("Stop", "Stop");
PSEvent._add("Stroke", "Strk");
PSEvent._add("Subtract", "Sbtr");
PSEvent._add("SubtractFrom", "SbtF");
PSEvent._add("Sumie", "Smie");
PSEvent._add("TakeMergedSnapshot", "TkMr");
PSEvent._add("TakeSnapshot", "TkSn");
PSEvent._add("TextureFill", "TxtF");
PSEvent._add("Texturizer", "Txtz");
PSEvent._add("Threshold", "Thrs");
PSEvent._add("Tiles", "Tls ");
PSEvent._add("TornEdges", "TrnE");
PSEvent._add("TraceContour", "TrcC");
PSEvent._add("Transform", "Trnf");
PSEvent._add("Trap", "Trap");
PSEvent._add("Twirl", "Twrl");
PSEvent._add("Underpainting", "Undr");
PSEvent._add("Undo", "undo");
PSEvent._add("Ungroup", "Ungr");
PSEvent._add("Unlink", "Unlk");
PSEvent._add("UnsharpMask", "UnsM");
PSEvent._add("Variations", "Vrtn");
PSEvent._add("Wait", "Wait");
PSEvent._add("WaterPaper", "WtrP");
PSEvent._add("Watercolor", "Wtrc");
PSEvent._add("Wave", "Wave");
PSEvent._add("Wind", "Wnd ");
PSEvent._add("ZigZag", "ZgZg");
PSEvent._add("BackLight", "BacL");
PSEvent._add("FillFlash", "FilE");
PSEvent._add("ColorCast", "ColE");
PSEvent._add("OpenUntitled", "OpnU");

PSForm._add("Class", "Clss");
PSForm._add("Enumerated", "Enmr");
PSForm._add("Identifier", "Idnt");
PSForm._add("Index", "indx");
PSForm._add("Offset", "rele");
PSForm._add("Property", "prop");

PSKey._add("3DAntiAlias", "Alis");
PSKey._add("A", "A   ");
PSKey._add("Adjustment", "Adjs");
PSKey._add("Aligned", "Algd");
PSKey._add("Alignment", "Algn");
PSKey._add("AllPS", "All ");
PSKey._add("AllExcept", "AllE");
PSKey._add("AllToolOptions", "AlTl");
PSKey._add("AlphaChannelOptions", "AChn");
PSKey._add("AlphaChannels", "AlpC");
PSKey._add("AmbientBrightness", "AmbB");
PSKey._add("AmbientColor", "AmbC");
PSKey._add("Amount", "Amnt");
PSKey._add("AmplitudeMax", "AmMx");
PSKey._add("AmplitudeMin", "AmMn");
PSKey._add("Anchor", "Anch");
PSKey._add("Angle", "Angl");
PSKey._add("Angle1", "Ang1");
PSKey._add("Angle2", "Ang2");
PSKey._add("Angle3", "Ang3");
PSKey._add("Angle4", "Ang4");
PSKey._add("AntiAlias", "AntA");
PSKey._add("Append", "Appe");
PSKey._add("Apply", "Aply");
PSKey._add("Area", "Ar  ");
PSKey._add("Arrowhead", "Arrw");
PSKey._add("As", "As  ");
PSKey._add("AssetBin", "Asst");
PSKey._add("AssumedCMYK", "AssC");
PSKey._add("AssumedGray", "AssG");
PSKey._add("AssumedRGB", "AssR");
PSKey._add("At", "At  ");
PSKey._add("Auto", "Auto");
PSKey._add("AutoContrast", "AuCo");
PSKey._add("AutoErase", "Atrs");
PSKey._add("AutoKern", "AtKr");
PSKey._add("AutoUpdate", "AtUp");
PSKey._add("ShowMenuColors", "SwMC");
PSKey._add("Axis", "Axis");
PSKey._add("B", "B   ");
PSKey._add("Background", "Bckg");
PSKey._add("BackgroundColor", "BckC");
PSKey._add("BackgroundLevel", "BckL");
PSKey._add("Backward", "Bwd ");
PSKey._add("Balance", "Blnc");
PSKey._add("BaselineShift", "Bsln");
PSKey._add("BeepWhenDone", "BpWh");
PSKey._add("BeginRamp", "BgnR");
PSKey._add("BeginSustain", "BgnS");
PSKey._add("BevelDirection", "bvlD");
PSKey._add("BevelEmboss", "ebbl");
PSKey._add("BevelStyle", "bvlS");
PSKey._add("BevelTechnique", "bvlT");
PSKey._add("BigNudgeH", "BgNH");
PSKey._add("BigNudgeV", "BgNV");
PSKey._add("BitDepth", "BtDp");
PSKey._add("Black", "Blck");
PSKey._add("BlackClip", "BlcC");
PSKey._add("BlackGeneration", "Blcn");
PSKey._add("BlackGenerationCurve", "BlcG");
PSKey._add("BlackIntensity", "BlcI");
PSKey._add("BlackLevel", "BlcL");
PSKey._add("BlackLimit", "BlcL");
PSKey._add("Bleed", "Bld ");
PSKey._add("BlendRange", "Blnd");
PSKey._add("Blue", "Bl  ");
PSKey._add("BlueBlackPoint", "BlBl");
PSKey._add("BlueGamma", "BlGm");
PSKey._add("BlueWhitePoint", "BlWh");
PSKey._add("BlueX", "BlX ");
PSKey._add("BlueY", "BlY ");
PSKey._add("Blur", "blur");
PSKey._add("BlurMethod", "BlrM");
PSKey._add("BlurQuality", "BlrQ");
PSKey._add("Book", "Bk  ");
PSKey._add("BorderThickness", "BrdT");
PSKey._add("Bottom", "Btom");
PSKey._add("Brightness", "Brgh");
PSKey._add("BrushDetail", "BrsD");
PSKey._add("Brushes", "Brsh");
PSKey._add("BrushSize", "BrsS");
PSKey._add("BrushType", "BrsT");
PSKey._add("BumpAmplitude", "BmpA");
PSKey._add("BumpChannel", "BmpC");
PSKey._add("By", "By  ");
PSKey._add("Byline", "Byln");
PSKey._add("BylineTitle", "BylT");
PSKey._add("ByteOrder", "BytO");
PSKey._add("CachePrefs", "CchP");
PSKey._add("ChokeMatte", "Ckmt");
PSKey._add("CloneSource", "ClnS");
PSKey._add("CMYKSetup", "CMYS");
PSKey._add("Calculation", "Clcl");
PSKey._add("CalibrationBars", "Clbr");
PSKey._add("Caption", "Cptn");
PSKey._add("CaptionWriter", "CptW");
PSKey._add("Category", "Ctgr");
PSKey._add("CellSize", "ClSz");
PSKey._add("Center", "Cntr");
PSKey._add("CenterCropMarks", "CntC");
PSKey._add("ChalkArea", "ChlA");
PSKey._add("Channel", "Chnl");
PSKey._add("ChannelMatrix", "ChMx");
PSKey._add("ChannelName", "ChnN");
PSKey._add("Channels", "Chns");
PSKey._add("ChannelsInterleaved", "ChnI");
PSKey._add("CharcoalAmount", "ChAm");
PSKey._add("CharcoalArea", "ChrA");
PSKey._add("ChromeFX", "ChFX");
PSKey._add("City", "City");
PSKey._add("ClearAmount", "ClrA");
PSKey._add("ClippingPath", "ClPt");
PSKey._add("ClippingPathEPS", "ClpP");
PSKey._add("ClippingPathFlatness", "ClpF");
PSKey._add("ClippingPathIndex", "ClpI");
PSKey._add("ClippingPathInfo", "Clpg");
PSKey._add("ClosedSubpath", "Clsp");
PSKey._add("Color", "Clr ");
PSKey._add("ColorChannels", "Clrh");
PSKey._add("ColorCorrection", "ClrC");
PSKey._add("ColorIndicates", "ClrI");
PSKey._add("ColorManagement", "ClMg");
PSKey._add("ColorPickerPrefs", "Clrr");
PSKey._add("ColorTable", "ClrT");
PSKey._add("Colorize", "Clrz");
PSKey._add("Colors", "Clrs");
PSKey._add("ColorsList", "ClrL");
PSKey._add("ColorSpace", "ClrS");
PSKey._add("ColumnWidth", "ClmW");
PSKey._add("CommandKey", "CmdK");
PSKey._add("Compensation", "Cmpn");
PSKey._add("Compression", "Cmpr");
PSKey._add("Concavity", "Cncv");
PSKey._add("Condition", "Cndt");
PSKey._add("Constant", "Cnst");
PSKey._add("Constrain", "Cnst");
PSKey._add("ConstrainProportions", "CnsP");
PSKey._add("ConstructionFOV", "Cfov");
PSKey._add("Contiguous", "Cntg");
PSKey._add("Continue", "Cntn");
PSKey._add("Continuity", "Cnty");
PSKey._add("Contrast", "Cntr");
PSKey._add("Convert", "Cnvr");
PSKey._add("Copy", "Cpy ");
PSKey._add("Copyright", "Cpyr");
PSKey._add("CopyrightNotice", "CprN");
PSKey._add("CornerCropMarks", "CrnC");
PSKey._add("Count", "Cnt ");
PSKey._add("CountryName", "CntN");
PSKey._add("CrackBrightness", "CrcB");
PSKey._add("CrackDepth", "CrcD");
PSKey._add("CrackSpacing", "CrcS");
PSKey._add("CreateLayersFromLayerFX", "blfl");
PSKey._add("Credit", "Crdt");
PSKey._add("Crossover", "Crss");
PSKey._add("Current", "Crnt");
PSKey._add("CurrentHistoryState", "CrnH");
PSKey._add("CurrentLight", "CrnL");
PSKey._add("CurrentToolOptions", "CrnT");
PSKey._add("Curve", "Crv ");
PSKey._add("CurveFile", "CrvF");
PSKey._add("Custom", "Cstm");
PSKey._add("CustomForced", "CstF");
PSKey._add("CustomMatte", "CstM");
PSKey._add("CustomPalette", "CstP");
PSKey._add("Cyan", "Cyn ");
PSKey._add("DarkIntensity", "DrkI");
PSKey._add("Darkness", "Drkn");
PSKey._add("DateCreated", "DtCr");
PSKey._add("Datum", "Dt  ");
PSKey._add("DCS", "DCS ");
PSKey._add("Definition", "Dfnt");
PSKey._add("Density", "Dnst");
PSKey._add("Depth", "Dpth");
PSKey._add("DestBlackMax", "Dstl");
PSKey._add("DestBlackMin", "DstB");
PSKey._add("DestinationMode", "DstM");
PSKey._add("DestWhiteMax", "Dstt");
PSKey._add("DestWhiteMin", "DstW");
PSKey._add("Detail", "Dtl ");
PSKey._add("Diameter", "Dmtr");
PSKey._add("DiffusionDither", "DffD");
PSKey._add("Direction", "Drct");
PSKey._add("DirectionBalance", "DrcB");
PSKey._add("DisplaceFile", "DspF");
PSKey._add("DisplacementMap", "DspM");
PSKey._add("DisplayPrefs", "DspP");
PSKey._add("Distance", "Dstn");
PSKey._add("Distortion", "Dstr");
PSKey._add("Distribution", "Dstr");
PSKey._add("Dither", "Dthr");
PSKey._add("DitherAmount", "DthA");
PSKey._add("DitherPreserve", "Dthp");
PSKey._add("DitherQuality", "Dthq");
PSKey._add("DocumentID", "DocI");
PSKey._add("DotGain", "DtGn");
PSKey._add("DotGainCurves", "DtGC");
PSKey._add("DPXFormat", "DPXf");
PSKey._add("DropShadow", "DrSh");
PSKey._add("Duplicate", "Dplc");
PSKey._add("DynamicColorSliders", "DnmC");
PSKey._add("Edge", "Edg ");
PSKey._add("EdgeBrightness", "EdgB");
PSKey._add("EdgeFidelity", "EdgF");
PSKey._add("EdgeIntensity", "EdgI");
PSKey._add("EdgeSimplicity", "EdgS");
PSKey._add("EdgeThickness", "EdgT");
PSKey._add("EdgeWidth", "EdgW");
PSKey._add("Effect", "Effc");
PSKey._add("EmbedProfiles", "EmbP");
PSKey._add("EmbedCMYK", "EmbC");
PSKey._add("EmbedGray", "EmbG");
PSKey._add("EmbedLab", "EmbL");
PSKey._add("EmbedRGB", "EmbR");
PSKey._add("EmulsionDown", "EmlD");
PSKey._add("Enabled", "enab");
PSKey._add("EnableGestures", "EGst");
PSKey._add("EnableDropShadowText", "Edst");
PSKey._add("Encoding", "Encd");
PSKey._add("End", "End ");
PSKey._add("EndArrowhead", "EndA");
PSKey._add("EndRamp", "EndR");
PSKey._add("EndSustain", "EndS");
PSKey._add("Engine", "Engn");
PSKey._add("EraserKind", "ErsK");
PSKey._add("EraseToHistory", "ErsT");
PSKey._add("ExactPoints", "ExcP");
PSKey._add("Export", "Expr");
PSKey._add("ExportClipboard", "ExpC");
PSKey._add("Exposure", "Exps");
PSKey._add("Extend", "Extd");
PSKey._add("Extension", "Extn");
PSKey._add("ExtensionsQuery", "ExtQ");
PSKey._add("ExtrudeDepth", "ExtD");
PSKey._add("ExtrudeMaskIncomplete", "ExtM");
PSKey._add("ExtrudeRandom", "ExtR");
PSKey._add("ExtrudeSize", "ExtS");
PSKey._add("ExtrudeSolidFace", "ExtF");
PSKey._add("ExtrudeType", "ExtT");
PSKey._add("EyeDropperSample", "EyDr");
PSKey._add("FadeoutSteps", "FdtS");
PSKey._add("FadeTo", "FdT ");
PSKey._add("Falloff", "FlOf");
PSKey._add("FPXCompress", "FxCm");
PSKey._add("FPXQuality", "FxQl");
PSKey._add("FPXSize", "FxSz");
PSKey._add("FPXView", "FxVw");
PSKey._add("Feather", "Fthr");
PSKey._add("FiberLength", "FbrL");
PSKey._add("File", "File");
PSKey._add("FileCreator", "FlCr");
PSKey._add("FileInfo", "FlIn");
PSKey._add("FileReference", "FilR");
PSKey._add("FileSavePrefs", "FlSP");
PSKey._add("FilesList", "flst");
PSKey._add("FileType", "FlTy");
PSKey._add("Fill", "Fl  ");
PSKey._add("FillColor", "FlCl");
PSKey._add("FillNeutral", "FlNt");
PSKey._add("FilterLayerRandomSeed", "FlRs");
PSKey._add("FilterLayerPersistentData", "FlPd");
PSKey._add("Fingerpainting", "Fngr");
PSKey._add("FlareCenter", "FlrC");
PSKey._add("Flatness", "Fltn");
PSKey._add("Flatten", "Fltt");
PSKey._add("FlipVertical", "FlpV");
PSKey._add("Focus", "Fcs ");
PSKey._add("Folders", "Fldr");
PSKey._add("FontDesignAxes", "FntD");
PSKey._add("FontDesignAxesVectors", "FntV");
PSKey._add("FontName", "FntN");
PSKey._add("FontScript", "Scrp");
PSKey._add("FontStyleName", "FntS");
PSKey._add("FontTechnology", "FntT");
PSKey._add("ForcedColors", "FrcC");
PSKey._add("ForegroundColor", "FrgC");
PSKey._add("ForegroundLevel", "FrgL");
PSKey._add("Format", "Fmt ");
PSKey._add("Forward", "Fwd ");
PSKey._add("FrameFX", "FrFX");
PSKey._add("FrameWidth", "FrmW");
PSKey._add("FreeTransformCenterState", "FTcs");
PSKey._add("Frequency", "Frqn");
PSKey._add("From", "From");
PSKey._add("FromBuiltin", "FrmB");
PSKey._add("FromMode", "FrmM");
PSKey._add("FunctionKey", "FncK");
PSKey._add("Fuzziness", "Fzns");
PSKey._add("GamutWarning", "GmtW");
PSKey._add("GCR", "GCR ");
PSKey._add("GeneralPrefs", "GnrP");
PSKey._add("GIFColorFileType", "GFPT");
PSKey._add("GIFColorLimit", "GFCL");
PSKey._add("GIFExportCaption", "GFEC");
PSKey._add("GIFMaskChannelIndex", "GFMI");
PSKey._add("GIFMaskChannelInverted", "GFMV");
PSKey._add("GIFPaletteFile", "GFPF");
PSKey._add("GIFPaletteType", "GFPL");
PSKey._add("GIFRequiredColorSpaceType", "GFCS");
PSKey._add("GIFRowOrderType", "GFIT");
PSKey._add("GIFTransparentColor", "GFTC");
PSKey._add("GIFTransparentIndexBlue", "GFTB");
PSKey._add("GIFTransparentIndexGreen", "GFTG");
PSKey._add("GIFTransparentIndexRed", "GFTR");
PSKey._add("GIFUseBestMatch", "GFBM");
PSKey._add("Gamma", "Gmm ");
PSKey._add("GlobalAngle", "gblA");
PSKey._add("GlobalLightingAngle", "gagl");
PSKey._add("Gloss", "Glos");
PSKey._add("GlowAmount", "GlwA");
PSKey._add("GlowTechnique", "GlwT");
PSKey._add("Gradient", "Grad");
PSKey._add("GradientFill", "Grdf");
PSKey._add("Grain", "Grn ");
PSKey._add("GrainType", "Grnt");
PSKey._add("Graininess", "Grns");
PSKey._add("Gray", "Gry ");
PSKey._add("GrayBehavior", "GrBh");
PSKey._add("GraySetup", "GrSt");
PSKey._add("Green", "Grn ");
PSKey._add("GreenBlackPoint", "GrnB");
PSKey._add("GreenGamma", "GrnG");
PSKey._add("GreenWhitePoint", "GrnW");
PSKey._add("GreenX", "GrnX");
PSKey._add("GreenY", "GrnY");
PSKey._add("GridColor", "GrdC");
PSKey._add("GridCustomColor", "Grds");
PSKey._add("GridMajor", "GrdM");
PSKey._add("GridMinor", "Grdn");
PSKey._add("GridStyle", "GrdS");
PSKey._add("GridUnits", "Grdt");
PSKey._add("Group", "Grup");
PSKey._add("GroutWidth", "GrtW");
PSKey._add("GrowSelection", "GrwS");
PSKey._add("Guides", "Gdes");
PSKey._add("GuidesColor", "GdsC");
PSKey._add("GuidesCustomColor", "Gdss");
PSKey._add("GuidesStyle", "GdsS");
PSKey._add("GuidesPrefs", "GdPr");
PSKey._add("GutterWidth", "GttW");
PSKey._add("HalftoneFile", "HlfF");
PSKey._add("HalftoneScreen", "HlfS");
PSKey._add("HalftoneSpec", "Hlfp");
PSKey._add("HalftoneSize", "HlSz");
PSKey._add("Hardness", "Hrdn");
PSKey._add("HasCmdHPreference", "HCdH");
PSKey._add("Header", "Hdr ");
PSKey._add("Headline", "Hdln");
PSKey._add("Height", "Hght");
PSKey._add("HostName", "HstN");
PSKey._add("HighlightArea", "HghA");
PSKey._add("HighlightColor", "hglC");
PSKey._add("HighlightLevels", "HghL");
PSKey._add("HighlightMode", "hglM");
PSKey._add("HighlightOpacity", "hglO");
PSKey._add("HighlightStrength", "HghS");
PSKey._add("HistoryBrushSource", "HstB");
PSKey._add("HistoryPrefs", "HstP");
PSKey._add("HistoryStateSource", "HsSS");
PSKey._add("HistoryStates", "HsSt");
PSKey._add("Horizontal", "Hrzn");
PSKey._add("HorizontalScale", "HrzS");
PSKey._add("HostVersion", "HstV");
PSKey._add("Hue", "H   ");
PSKey._add("ICCEngine", "ICCE");
PSKey._add("ICCSetupName", "ICCt");
PSKey._add("ID", "Idnt");
PSKey._add("Idle", "Idle");
PSKey._add("ImageBalance", "ImgB");
PSKey._add("Import", "Impr");
PSKey._add("Impressionist", "Imps");
PSKey._add("In", "In  ");
PSKey._add("Inherits", "c@#^");
PSKey._add("InkColors", "InkC");
PSKey._add("Inks", "Inks");
PSKey._add("InnerGlow", "IrGl");
PSKey._add("InnerGlowSource", "glwS");
PSKey._add("InnerShadow", "IrSh");
PSKey._add("Input", "Inpt");
PSKey._add("InputBlackPoint", "kIBP");
PSKey._add("InputMapRange", "Inmr");
PSKey._add("InputRange", "Inpr");
PSKey._add("InputWhitePoint", "kIWP");
PSKey._add("Intensity", "Intn");
PSKey._add("Intent", "Inte");
PSKey._add("InterfaceBevelHighlight", "IntH");
PSKey._add("InterfaceBevelShadow", "Intv");
PSKey._add("InterfaceBlack", "IntB");
PSKey._add("InterfaceBorder", "Intd");
PSKey._add("InterfaceButtonDarkShadow", "Intk");
PSKey._add("InterfaceButtonDownFill", "Intt");
PSKey._add("InterfaceButtonUpFill", "InBF");
PSKey._add("InterfaceColorBlue2", "ICBL");
PSKey._add("InterfaceColorBlue32", "ICBH");
PSKey._add("InterfaceColorGreen2", "ICGL");
PSKey._add("InterfaceColorGreen32", "ICGH");
PSKey._add("InterfaceColorRed2", "ICRL");
PSKey._add("InterfaceColorRed32", "ICRH");
PSKey._add("InterfaceIconFillActive", "IntI");
PSKey._add("InterfaceIconFillDimmed", "IntF");
PSKey._add("InterfaceIconFillSelected", "Intc");
PSKey._add("InterfaceIconFrameActive", "Intm");
PSKey._add("InterfaceIconFrameDimmed", "Intr");
PSKey._add("InterfaceIconFrameSelected", "IntS");
PSKey._add("InterfacePaletteFill", "IntP");
PSKey._add("InterfaceRed", "IntR");
PSKey._add("InterfaceWhite", "IntW");
PSKey._add("InterfaceToolTipBackground", "IntT");
PSKey._add("InterfaceToolTipText", "ITTT");
PSKey._add("InterfaceTransparencyForeground", "ITFg");
PSKey._add("InterfaceTransparencyBackground", "ITBg");
PSKey._add("Interlace", "Intr");
PSKey._add("InterlaceCreateType", "IntC");
PSKey._add("InterlaceEliminateType", "IntE");
PSKey._add("Interpolation", "Intr");
PSKey._add("InterpolationMethod", "IntM");
PSKey._add("Invert", "Invr");
PSKey._add("InvertMask", "InvM");
PSKey._add("InvertSource2", "InvS");
PSKey._add("InvertTexture", "InvT");
PSKey._add("IsDirty", "IsDr");
PSKey._add("ItemIndex", "ItmI");
PSKey._add("JPEGQuality", "JPEQ");
PSKey._add("Kerning", "Krng");
PSKey._add("Keywords", "Kywd");
PSKey._add("Kind", "Knd ");
PSKey._add("LZWCompression", "LZWC");
PSKey._add("Labels", "Lbls");
PSKey._add("Landscape", "Lnds");
PSKey._add("LastTransform", "LstT");
PSKey._add("LayerEffects", "Lefx");
PSKey._add("LayerFXVisible", "lfxv");
PSKey._add("Layer", "Lyr ");
PSKey._add("LayerID", "LyrI");
PSKey._add("LayerName", "LyrN");
PSKey._add("Layers", "Lyrs");
PSKey._add("Leading", "Ldng");
PSKey._add("Left", "Left");
PSKey._add("Length", "Lngt");
PSKey._add("TermLength", "Lngt");
PSKey._add("Lens", "Lns ");
PSKey._add("Level", "Lvl ");
PSKey._add("Levels", "Lvls");
PSKey._add("LightDark", "LgDr");
PSKey._add("LightDirection", "LghD");
PSKey._add("LightIntensity", "LghI");
PSKey._add("LightPosition", "LghP");
PSKey._add("LightSource", "LghS");
PSKey._add("LightType", "LghT");
PSKey._add("LightenGrout", "LghG");
PSKey._add("Lightness", "Lght");
PSKey._add("Line", "Line");
PSKey._add("LinkedLayerIDs", "LnkL");
PSKey._add("LocalLightingAngle", "lagl");
PSKey._add("LocalLightingAltitude", "Lald");
PSKey._add("LocalRange", "LclR");
PSKey._add("Location", "Lctn");
PSKey._add("Log", "Log ");
PSKey._add("Logarithmic", "kLog");
PSKey._add("LowerCase", "LwCs");
PSKey._add("Luminance", "Lmnc");
PSKey._add("LUTAnimation", "LTnm");
PSKey._add("Magenta", "Mgnt");
PSKey._add("MakeVisible", "MkVs");
PSKey._add("ManipulationFOV", "Mfov");
PSKey._add("MapBlack", "MpBl");
PSKey._add("Mapping", "Mpng");
PSKey._add("MappingShape", "MpgS");
PSKey._add("Material", "Mtrl");
PSKey._add("Matrix", "Mtrx");
PSKey._add("MatteColor", "MttC");
PSKey._add("Maximum", "Mxm ");
PSKey._add("MaximumStates", "MxmS");
PSKey._add("MemoryUsagePercent", "MmrU");
PSKey._add("Merge", "Mrge");
PSKey._add("Merged", "Mrgd");
PSKey._add("Message", "Msge");
PSKey._add("Method", "Mthd");
PSKey._add("MezzotintType", "MztT");
PSKey._add("Midpoint", "Mdpn");
PSKey._add("MidtoneLevels", "MdtL");
PSKey._add("Minimum", "Mnm ");
PSKey._add("MismatchCMYK", "MsmC");
PSKey._add("MismatchGray", "MsmG");
PSKey._add("MismatchRGB", "MsmR");
PSKey._add("Mode", "Md  ");
PSKey._add("Monochromatic", "Mnch");
PSKey._add("MoveTo", "MvT ");
PSKey._add("Name", "Nm  ");
PSKey._add("Negative", "Ngtv");
PSKey._add("New", "Nw  ");
PSKey._add("Noise", "Nose");
PSKey._add("NonImageData", "NnIm");
PSKey._add("NonLinear", "NnLn");
PSKey._add("Null", "null");
PSKey._add("NumLights", "Nm L");
PSKey._add("Number", "Nmbr");
PSKey._add("NumberOfCacheLevels", "NCch");
PSKey._add("NumberOfCacheLevels64", "NC64");
PSKey._add("NumberOfChannels", "NmbO");
PSKey._add("NumberOfChildren", "NmbC");
PSKey._add("NumberOfDocuments", "NmbD");
PSKey._add("NumberOfGenerators", "NmbG");
PSKey._add("NumberOfLayers", "NmbL");
PSKey._add("NumberOfLevels", "NmbL");
PSKey._add("NumberOfPaths", "NmbP");
PSKey._add("NumberOfRipples", "NmbR");
PSKey._add("NumberOfSiblings", "NmbS");
PSKey._add("ObjectName", "ObjN");
PSKey._add("Offset", "Ofst");
PSKey._add("On", "On  ");
PSKey._add("Opacity", "Opct");
PSKey._add("Optimized", "Optm");
PSKey._add("Orientation", "Ornt");
PSKey._add("OriginalHeader", "OrgH");
PSKey._add("OriginalTransmissionReference", "OrgT");
PSKey._add("OtherCursors", "OthC");
PSKey._add("OuterGlow", "OrGl");
PSKey._add("Output", "Otpt");
PSKey._add("OutputBlackPoint", "kOBP");
PSKey._add("OutputWhitePoint", "kOWP");
PSKey._add("OverprintColors", "OvrC");
PSKey._add("OverrideOpen", "OvrO");
PSKey._add("OverridePrinter", "ObrP");
PSKey._add("OverrideSave", "Ovrd");
PSKey._add("PaintCursorKind", "PnCK");
PSKey._add("ParentIndex", "PrIn");
PSKey._add("ParentName", "PrNm");
PSKey._add("PNGFilter", "PNGf");
PSKey._add("PNGInterlaceType", "PGIT");
PSKey._add("PageFormat", "PMpf");
PSKey._add("PageNumber", "PgNm");
PSKey._add("PageSetup", "PgSt");
PSKey._add("PagePosition", "PgPs");
PSKey._add("PaintingCursors", "PntC");
PSKey._add("PaintType", "PntT");
PSKey._add("Palette", "Plt ");
PSKey._add("PaletteFile", "PltF");
PSKey._add("PaperBrightness", "PprB");
PSKey._add("Path", "Path");
PSKey._add("PathContents", "PthC");
PSKey._add("PathName", "PthN");
PSKey._add("Pattern", "Pttn");
PSKey._add("PencilWidth", "Pncl");
PSKey._add("PerspectiveIndex", "Prsp");
PSKey._add("Phosphors", "Phsp");
PSKey._add("PickerID", "PckI");
PSKey._add("PickerKind", "Pckr");
PSKey._add("PixelPaintSize", "PPSz");
PSKey._add("Platform", "Pltf");
PSKey._add("PluginFolder", "PlgF");
PSKey._add("PluginPrefs", "PlgP");
PSKey._add("Points", "Pts ");
PSKey._add("Position", "Pstn");
PSKey._add("Posterization", "Pstr");
PSKey._add("PostScriptColor", "PstS");
PSKey._add("PredefinedColors", "PrdC");
PSKey._add("PreferBuiltin", "PrfB");
PSKey._add("PreserveAdditional", "PrsA");
PSKey._add("PreserveLuminosity", "PrsL");
PSKey._add("PreserveTransparency", "PrsT");
PSKey._add("Pressure", "Prs ");
PSKey._add("Preferences", "Prfr");
PSKey._add("Preview", "Prvw");
PSKey._add("PreviewCMYK", "PrvK");
PSKey._add("PreviewFullSize", "PrvF");
PSKey._add("PreviewIcon", "PrvI");
PSKey._add("PreviewMacThumbnail", "PrvM");
PSKey._add("PreviewWinThumbnail", "PrvW");
PSKey._add("PreviewsQuery", "PrvQ");
PSKey._add("PrintSettings", "PMps");
PSKey._add("ProfileSetup", "PrfS");
PSKey._add("ProvinceState", "PrvS");
PSKey._add("Quality", "Qlty");
PSKey._add("ExtendedQuality", "EQlt");
PSKey._add("QuickMask", "QucM");
PSKey._add("RGBSetup", "RGBS");
PSKey._add("Radius", "Rds ");
PSKey._add("RandomSeed", "RndS");
PSKey._add("Ratio", "Rt  ");
PSKey._add("RecentFiles", "Rcnf");
PSKey._add("Red", "Rd  ");
PSKey._add("RedBlackPoint", "RdBl");
PSKey._add("RedGamma", "RdGm");
PSKey._add("RedWhitePoint", "RdWh");
PSKey._add("RedX", "RdX ");
PSKey._add("RedY", "RdY ");
PSKey._add("RegistrationMarks", "RgsM");
PSKey._add("Relative", "Rltv");
PSKey._add("Relief", "Rlf ");
PSKey._add("RenderFidelity", "Rfid");
PSKey._add("Resample", "Rsmp");
PSKey._add("ResizeWindowsOnZoom", "RWOZ");
PSKey._add("Resolution", "Rslt");
PSKey._add("ResourceID", "RsrI");
PSKey._add("Response", "Rspn");
PSKey._add("RetainHeader", "RtnH");
PSKey._add("Reverse", "Rvrs");
PSKey._add("Right", "Rght");
PSKey._add("RippleMagnitude", "RplM");
PSKey._add("RippleSize", "RplS");
PSKey._add("Rotate", "Rtt ");
PSKey._add("Roundness", "Rndn");
PSKey._add("RulerOriginH", "RlrH");
PSKey._add("RulerOriginV", "RlrV");
PSKey._add("RulerUnits", "RlrU");
PSKey._add("Saturation", "Strt");
PSKey._add("SaveAndClose", "SvAn");
PSKey._add("SaveComposite", "SvCm");
PSKey._add("SavePaletteLocations", "PltL");
PSKey._add("SavePaths", "SvPt");
PSKey._add("SavePyramids", "SvPy");
PSKey._add("Saving", "Svng");
PSKey._add("Scale", "Scl ");
PSKey._add("ScaleHorizontal", "SclH");
PSKey._add("ScaleVertical", "SclV");
PSKey._add("Scaling", "Scln");
PSKey._add("Scans", "Scns");
PSKey._add("ScratchDisks", "ScrD");
PSKey._add("ScreenFile", "ScrF");
PSKey._add("ScreenType", "ScrT");
PSKey._add("ShadingIntensity", "ShdI");
PSKey._add("ShadingNoise", "ShdN");
PSKey._add("ShadingShape", "ShdS");
PSKey._add("ContourType", "ShpC");
PSKey._add("SerialString", "SrlS");
PSKey._add("Separations", "Sprt");
PSKey._add("ShadowColor", "sdwC");
PSKey._add("ShadowIntensity", "ShdI");
PSKey._add("ShadowLevels", "ShdL");
PSKey._add("ShadowMode", "sdwM");
PSKey._add("ShadowOpacity", "sdwO");
PSKey._add("Shape", "Shp ");
PSKey._add("Sharpness", "Shrp");
PSKey._add("ShearEd", "ShrE");
PSKey._add("ShearPoints", "ShrP");
PSKey._add("ShearSt", "ShrS");
PSKey._add("ShiftKey", "ShfK");
PSKey._add("ShiftKeyToolSwitch", "ShKT");
PSKey._add("ShortNames", "ShrN");
PSKey._add("ShowEnglishFontNames", "ShwE");
PSKey._add("ShowToolTips", "ShwT");
PSKey._add("ShowTransparency", "ShTr");
PSKey._add("SizeKey", "Sz  ");
PSKey._add("Skew", "Skew");
PSKey._add("SmartBlurMode", "SmBM");
PSKey._add("SmartBlurQuality", "SmBQ");
PSKey._add("Smooth", "Smoo");
PSKey._add("Smoothness", "Smth");
PSKey._add("SnapshotInitial", "SnpI");
PSKey._add("SoftClip", "SfCl");
PSKey._add("Softness", "Sftn");
PSKey._add("SmallFontType", "Sfts");
PSKey._add("OldSmallFontType", "Sftt");
PSKey._add("SolidFill", "SoFi");
PSKey._add("Source", "Srce");
PSKey._add("Source2", "Src2");
PSKey._add("SourceMode", "SrcM");
PSKey._add("Spacing", "Spcn");
PSKey._add("SpecialInstructions", "SpcI");
PSKey._add("SpherizeMode", "SphM");
PSKey._add("Spot", "Spot");
PSKey._add("SprayRadius", "SprR");
PSKey._add("SquareSize", "SqrS");
PSKey._add("SrcBlackMax", "Srcl");
PSKey._add("SrcBlackMin", "SrcB");
PSKey._add("SrcWhiteMax", "Srcm");
PSKey._add("SrcWhiteMin", "SrcW");
PSKey._add("Start", "Strt");
PSKey._add("StartArrowhead", "StrA");
PSKey._add("State", "Stte");
PSKey._add("Strength", "srgh");
PSKey._add("StrengthRatio", "srgR");
PSKey._add("StrokeDetail", "StDt");
PSKey._add("StrokeDirection", "SDir");
PSKey._add("StrokeLength", "StrL");
PSKey._add("StrokePressure", "StrP");
PSKey._add("StrokeSize", "StrS");
PSKey._add("StrokeWidth", "StrW");
PSKey._add("Style", "Styl");
PSKey._add("Styles", "Stys");
PSKey._add("StylusIsPressure", "StlP");
PSKey._add("StylusIsColor", "StlC");
PSKey._add("StylusIsOpacity", "StlO");
PSKey._add("StylusIsSize", "StlS");
PSKey._add("SubPathList", "SbpL");
PSKey._add("SupplementalCategories", "SplC");
PSKey._add("SystemInfo", "SstI");
PSKey._add("SystemPalette", "SstP");
PSKey._add("Target", "null");
PSKey._add("TargetPath", "Trgp");
PSKey._add("TargetPathIndex", "TrgP");
PSKey._add("Text", "Txt ");
PSKey._add("TextClickPoint", "TxtC");
PSKey._add("TextData", "TxtD");
PSKey._add("TextStyle", "TxtS");
PSKey._add("TextStyleRange", "Txtt");
PSKey._add("Texture", "Txtr");
PSKey._add("TextureCoverage", "TxtC");
PSKey._add("TextureFile", "TxtF");
PSKey._add("TextureType", "TxtT");
PSKey._add("Threshold", "Thsh");
PSKey._add("TileNumber", "TlNm");
PSKey._add("TileOffset", "TlOf");
PSKey._add("TileSize", "TlSz");
PSKey._add("Title", "Ttl ");
PSKey._add("To", "T   ");
PSKey._add("ToBuiltin", "TBl ");
PSKey._add("ToLinked", "ToLk");
PSKey._add("ToMode", "TMd ");
PSKey._add("ToggleOthers", "TglO");
PSKey._add("Tolerance", "Tlrn");
PSKey._add("Top", "Top ");
PSKey._add("TotalLimit", "TtlL");
PSKey._add("Tracking", "Trck");
PSKey._add("TransferSpec", "TrnS");
PSKey._add("TransparencyGrid", "TrnG");
PSKey._add("TransferFunction", "TrnF");
PSKey._add("Transparency", "Trns");
PSKey._add("TransparencyGridColors", "TrnC");
PSKey._add("TransparencyGridSize", "TrnG");
PSKey._add("TransparencyPrefs", "TrnP");
PSKey._add("TransparencyShape", "TrnS");
PSKey._add("TransparentIndex", "TrnI");
PSKey._add("TransparentWhites", "TrnW");
PSKey._add("Twist", "Twst");
PSKey._add("Type", "Type");
PSKey._add("UCA", "UC  ");
PSKey._add("UnitsPrefs", "UntP");
PSKey._add("URL", "URL ");
PSKey._add("UndefinedArea", "UndA");
PSKey._add("Underline", "Undl");
PSKey._add("Untitled", "Untl");
PSKey._add("UpperY", "UppY");
PSKey._add("Urgency", "Urgn");
PSKey._add("UseAccurateScreens", "AcrS");
PSKey._add("UseAdditionalPlugins", "AdPl");
PSKey._add("UseCacheForHistograms", "UsCc");
PSKey._add("UseCurves", "UsCr");
PSKey._add("UseDefault", "UsDf");
PSKey._add("UseGlobalAngle", "uglg");
PSKey._add("UseICCProfile", "UsIC");
PSKey._add("UseMask", "UsMs");
PSKey._add("UserMaskEnabled", "UsrM");
PSKey._add("UserMaskLinked", "Usrs");
PSKey._add("LinkEnable", "lnkE");
PSKey._add("Using", "Usng");
PSKey._add("Value", "Vl  ");
PSKey._add("Variance", "Vrnc");
PSKey._add("Vector0", "Vct0");
PSKey._add("Vector1", "Vct1");
PSKey._add("VectorColor", "VctC");
PSKey._add("VersionFix", "VrsF");
PSKey._add("VersionMajor", "VrsM");
PSKey._add("VersionMinor", "VrsN");
PSKey._add("Vertical", "Vrtc");
PSKey._add("VerticalScale", "VrtS");
PSKey._add("VideoAlpha", "Vdlp");
PSKey._add("Visible", "Vsbl");
PSKey._add("WatchSuspension", "WtcS");
PSKey._add("Watermark", "watr");
PSKey._add("WaveType", "Wvtp");
PSKey._add("WavelengthMax", "WLMx");
PSKey._add("WavelengthMin", "WLMn");
PSKey._add("WebdavPrefs", "WbdP");
PSKey._add("WetEdges", "Wtdg");
PSKey._add("What", "What");
PSKey._add("WhiteClip", "WhtC");
PSKey._add("WhiteIntensity", "WhtI");
PSKey._add("WhiteIsHigh", "WhHi");
PSKey._add("WhiteLevel", "WhtL");
PSKey._add("WhitePoint", "WhtP");
PSKey._add("WholePath", "WhPt");
PSKey._add("Width", "Wdth");
PSKey._add("WindMethod", "WndM");
PSKey._add("With", "With");
PSKey._add("WorkPath", "WrPt");
PSKey._add("WorkPathIndex", "WrkP");
PSKey._add("X", "X   ");
PSKey._add("Y", "Y   ");
PSKey._add("Yellow", "Ylw ");
PSKey._add("ZigZagType", "ZZTy");
PSKey._add("Lighter", "Ligh");
PSKey._add("Darker", "Dark");
PSKey._add("StartUpInPrefs", "Stup");
PSKey._add("LegacySerialString", "lSNs");

PSType._add("ActionReference", "#Act");
PSType._add("ActionData", "ActD");
PSType._add("AlignDistributeSelector", "ADSt");
PSType._add("Alignment", "Alg ");
PSType._add("Amount", "Amnt");
PSType._add("AntiAlias", "Annt");
PSType._add("AreaSelector", "ArSl");
PSType._add("AssumeOptions", "AssO");
PSType._add("BevelEmbossStampStyle", "BESs");
PSType._add("BevelEmbossStyle", "BESl");
PSType._add("BitDepth", "BtDp");
PSType._add("BlackGeneration", "BlcG");
PSType._add("BlendMode", "BlnM");
PSType._add("BlurMethod", "BlrM");
PSType._add("BlurQuality", "BlrQ");
PSType._add("BrushType", "BrsT");
PSType._add("BuiltinProfile", "BltP");
PSType._add("BuiltInContour", "BltC");
PSType._add("CMYKSetupEngine", "CMYE");
PSType._add("Calculation", "Clcn");
PSType._add("Channel", "Chnl");
PSType._add("ChannelReference", "#ChR");
PSType._add("CheckerboardSize", "Chck");
PSType._add("ClassColor", "#Clr");
PSType._add("ClassElement", "#ClE");
PSType._add("ClassExport", "#Cle");
PSType._add("ClassFormat", "#ClF");
PSType._add("ClassHueSatHueSatV2", "#HsV");
PSType._add("ClassImport", "#ClI");
PSType._add("ClassMode", "#ClM");
PSType._add("ClassStringFormat", "#ClS");
PSType._add("ClassTextExport", "#CTE");
PSType._add("ClassTextImport", "#ClT");
PSType._add("Color", "Clr ");
PSType._add("ColorChannel", "#ClC");
PSType._add("ColorPalette", "ClrP");
PSType._add("ColorSpace", "ClrS");
PSType._add("ColorStopType", "Clry");
PSType._add("Colors", "Clrs");
PSType._add("Compensation", "Cmpn");
PSType._add("ContourEdge", "CntE");
PSType._add("Convert", "Cnvr");
PSType._add("CorrectionMethod", "CrcM");
PSType._add("CursorKind", "CrsK");
PSType._add("DCS", "DCS ");
PSType._add("DeepDepth", "DpDp");
PSType._add("Depth", "Dpth");
PSType._add("DiffuseMode", "DfsM");
PSType._add("Direction", "Drct");
PSType._add("DisplacementMap", "DspM");
PSType._add("Distribution", "Dstr");
PSType._add("Dither", "Dthr");
PSType._add("DitherQuality", "Dthq");
PSType._add("DocumentReference", "#DcR");
PSType._add("EPSPreview", "EPSP");
PSType._add("ElementReference", "#ElR");
PSType._add("Encoding", "Encd");
PSType._add("EraserKind", "ErsK");
PSType._add("ExtrudeRandom", "ExtR");
PSType._add("ExtrudeType", "ExtT");
PSType._add("EyeDropperSample", "EyDp");
PSType._add("FPXCompress", "FxCm");
PSType._add("Fill", "Fl  ");
PSType._add("FillColor", "FlCl");
PSType._add("FillContents", "FlCn");
PSType._add("FillMode", "FlMd");
PSType._add("ForcedColors", "FrcC");
PSType._add("FrameFill", "FrFl");
PSType._add("FrameStyle", "FStl");
PSType._add("GIFColorFileType", "GFPT");
PSType._add("GIFPaletteType", "GFPL");
PSType._add("GIFRequiredColorSpaceType", "GFCS");
PSType._add("GIFRowOrderType", "GFIT");
PSType._add("GlobalClass", "GlbC");
PSType._add("GlobalObject", "GlbO");
PSType._add("GradientType", "GrdT");
PSType._add("GradientForm", "GrdF");
PSType._add("GrainType", "Grnt");
PSType._add("GrayBehavior", "GrBh");
PSType._add("GuideGridColor", "GdGr");
PSType._add("GuideGridStyle", "GdGS");
PSType._add("HistoryStateSource", "HstS");
PSType._add("HorizontalLocation", "HrzL");
PSType._add("ImageReference", "#ImR");
PSType._add("InnerGlowSource", "IGSr");
PSType._add("IntegerChannel", "#inC");
PSType._add("Intent", "Inte");
PSType._add("InterlaceCreateType", "IntC");
PSType._add("InterlaceEliminateType", "IntE");
PSType._add("Interpolation", "Intp");
PSType._add("Kelvin", "Klvn");
PSType._add("KelvinCustomWhitePoint", "#Klv");
PSType._add("Lens", "Lns ");
PSType._add("LightDirection", "LghD");
PSType._add("LightPosition", "LghP");
PSType._add("LightType", "LghT");
PSType._add("LocationReference", "#Lct");
PSType._add("MaskIndicator", "MskI");
PSType._add("MatteColor", "MttC");
PSType._add("MatteTechnique", "BETE");
PSType._add("MenuItem", "MnIt");
PSType._add("Method", "Mthd");
PSType._add("MezzotintType", "MztT");
PSType._add("Mode", "Md  ");
PSType._add("Notify", "Ntfy");
PSType._add("Object", "Objc");
PSType._add("ObjectReference", "obj ");
PSType._add("OnOff", "OnOf");
PSType._add("Ordinal", "Ordn");
PSType._add("Orientation", "Ornt");
PSType._add("PNGFilter", "PNGf");
PSType._add("PNGInterlaceType", "PGIT");
PSType._add("PagePosition", "PgPs");
PSType._add("PathKind", "PthK");
PSType._add("PathReference", "#PtR");
PSType._add("Phosphors", "Phsp");
PSType._add("PhosphorsCustomPhosphors", "#Phs");
PSType._add("PickerKind", "PckK");
PSType._add("PixelPaintSize", "PPSz");
PSType._add("Platform", "Pltf");
PSType._add("Preview", "Prvw");
PSType._add("PreviewCMYK", "Prvt");
PSType._add("ProfileMismatch", "PrfM");
PSType._add("PurgeItem", "PrgI");
PSType._add("QuadCenterState", "QCSt");
PSType._add("Quality", "Qlty");
PSType._add("QueryState", "QurS");
PSType._add("RGBSetupSource", "RGBS");
PSType._add("RawData", "tdta");
PSType._add("RippleSize", "RplS");
PSType._add("RulerUnits", "RlrU");
PSType._add("ScreenType", "ScrT");
PSType._add("Shape", "Shp ");
PSType._add("SmartBlurMode", "SmBM");
PSType._add("SmartBlurQuality", "SmBQ");
PSType._add("SourceMode", "Cndn");
PSType._add("SpherizeMode", "SphM");
PSType._add("State", "Stte");
PSType._add("StringClassFormat", "#StC");
PSType._add("StringChannel", "#sth");
PSType._add("StringCompensation", "#Stm");
PSType._add("StringFSS", "#Stf");
PSType._add("StringInteger", "#StI");
PSType._add("StrokeDirection", "StrD");
PSType._add("StrokeLocation", "StrL");
PSType._add("TextureType", "TxtT");
PSType._add("TransparencyGridColors", "Trnl");
PSType._add("TransparencyGridSize", "TrnG");
PSType._add("TypeClassModeOrClassMode", "#TyM");
PSType._add("UndefinedArea", "UndA");
PSType._add("UnitFloat", "UntF");
PSType._add("Urgency", "Urgn");
PSType._add("UserMaskOptions", "UsrM");
PSType._add("ValueList", "VlLs");
PSType._add("VerticalLocation", "VrtL");
PSType._add("WaveType", "Wvtp");
PSType._add("WindMethod", "WndM");
PSType._add("YesNo", "YsN ");
PSType._add("ZigZagType", "ZZTy");

PSUnit._add("Angle", "#Ang");
PSUnit._add("Density", "#Rsl");
PSUnit._add("Distance", "#Rlt");
PSUnit._add("None", "#Nne");
PSUnit._add("Percent", "#Prc");
PSUnit._add("Pixels", "#Pxl");
PSUnit._add("Millimeters", "#Mlm");
PSUnit._add("Points", "#Pnt");

// this fixes the part where "target" whacks/collides-with "null"
PSString._add("Null", "null");
PSString._reverseName[PSString.Null] = "Null";
PSString._reverseName[PSString.rasterizeLayer] = "rasterizeLayer";

PSString["then"] = app.charIDToTypeID("then");
PSString._reverseName[PSString["then"]] = "then";
PSString._reverseSym[PSString["then"]] = "then";

PSString["else"] = app.charIDToTypeID("else");
PSString._reverseName[PSString["else"]] = "else";
PSString._reverseSym[PSString["else"]] = "else";

PSConstants.test = function() {
// this really is not any kind of test yet...
  print('name   = ' + PSClass._name);
  print('action = ' + PSClass.Action);
  print('reverse of ' + PSClass.Action + " = " +
      PSConstants.reverseNameLookup(PSClass.Action));
  print(PSConstants.listAll());
};

"PSConstants.js";
// EOF

//
// TextProcessor
//   This class abstracts out the idea of iterating through a text file and
//   processing it one line at a time.
//
// $Id: SLCFix.js,v 1.72 2015/12/03 22:01:32 anonymous Exp $
// Copyright: (c)2005, xbytor
// License: http://www.opensource.org/licenses/bsd-license.php
// Contact: xbytor@gmail.com
//
//@show include
//

String.prototype.trim = function() {
  return this.replace(/^[\s]+|[\s]+$/g, '');
};
String.prototype.startsWith = function(sub) {
  return this.indexOf(sub) == 0;
};
String.prototype.endsWith = function(sub) {
  return this.length >= sub.length &&
    this.substr(this.length - sub.length) == sub;
};

function throwFileError(f, msg) {
  if (msg == undefined) msg = '';
  Error.runtimeError(9002, msg + '\"' + f + "\": " + f.error + '.');
};

//
//=============================== TextProcessor ==============================
//
// The contructors creates a new object with the input and output files,
// and a function 'processor'. This processor function is not used in this
// version. All arguments are optional.
//
TextProcessor = function(infile, outfile, processor) {
  var self = this;
  self.infile = infile;
  self.outfile = outfile;
  self.encoding = undefined;

  if (typeof processor == "function") {
    self.processor = processor;
  }
};
TextProcessor.prototype.typename = "TextProcessor";

TextProcessorStatus = {};
TextProcessorStatus.OK   = "StatusOK";
TextProcessorStatus.DONE = "StatusDONE";
TextProcessorStatus.FAIL = "StatusFAIL";


//
// convertFptr
//   Return a File or Folder object given one of:
//    A File or Folder Object
//    A string literal or a String object that refers to either
//    a File or Folder
//
TextProcessor.convertFptr = function(fptr) {
  var f;
  if (fptr.constructor == String) {
    f = File(fptr);
  } else if (fptr instanceof File || fptr instanceof Folder) {
    f = fptr;
  } else {
    Error.runtimeError(9002, "Bad file \"" + fptr + "\" specified.");
  }
  return f;
};

TextProcessor.writeToFile = function(fptr, str) {
  var file = TextProcessor.convertFptr(fptr);
  file.open("w") || throwFileError(file, "Unable to open output file ");
  file.lineFeed = 'unix';
  file.write(str);
  file.close();
};

TextProcessor.readFromFile = function(fptr) {
  var file = TextProcessor.convertFptr(fptr);
  file.open("r") || throwFileError(file, "Unable to open input file ");

  var str = file.read();

  // this insanity is to detect Character conversion errors
  if (str.length == 0 && file.length != 0) {
    file.close();
    file.encoding = (file.encoding == "UTF8" ? "ASCII" : "UTF8");
    file.open("r");
    str = file.read();
    if (str.length == 0 && file.length != 0) {
      throwFileError(f, "Unable to read from file");
    }
    file.close();

  } else {
    file.close();
  }
  return str;
};

//
// exec
//  This function is called to actually process the input file. If the input
//  file is not specified here, is must have been specified before. The output
//  file is completely optional.
//
//  This function loads the input text file, splits the contents into an
//  array of strings and calls the processor function. The processor function
//  handles the string as needed, possibly modifying some of the strings and
//  copying them to an output buffer.
//  When the end of the input file has been reached, the line handler is called
//  with the line argument set to undefined to indicate the end of the file.
//  When all the lines have been processed, the output buffer is written to the
//  output file. The number of lines processed is returned as a result. If
//  processing was stopped because of a STATUS_FAIL, -1 is returned.
//
TextProcessor.prototype.exec = function(infile, outfile) {
  var self = this;

  if (!self.processor) {
    self.processor = self.handleLine;
  }
  if (!self.handleLine) {
    throw "No processor function has been specified.";
  }

  if (infile) {
    self.infile = infile;
  }
  if (!self.infile) {
    throw "No input file has been specified.";
  }
  if (outfile) {
    self.outfile = outfile;
  }

  var str = TextProcessor.readFromFile(self.infile);
  self.lines = str.split("\n");

  var outputBuffer = [];

  // loop through the lines...
  for (var i = 0; i < self.lines.length; i++) {
    var line = self.lines[i];
    var rc = self.processor(line, i, outputBuffer);
    if (rc == TextProcessorStatus.OK || rc == true) {
      continue;
    }
    if (rc == TextProcessorStatus.DONE) {
      break;
    }
    if (rc == TextProcessorStatus.FAIL || rc == false) {
      return -1;
    }
    throw "Unexpected status code returned by line handler.";
  }

  self.processor(undefined, i, outputBuffer);
  self.outputBuffer = outputBuffer;

  // write out the results, if needed
  if (self.outfile) {
    var outStr = outputBuffer.join("\n");
    TextProcessor.writeToFile(self.outfile, outStr + '\n');
  }
  return i;
};

//
// handleLine
//   This is the function that will get called for each line.
//   It must be set for the processor to work. The processor
//   function takes these arguments:
// line         - the line to be processed
// index        - the line number
// outputBuffer - an array of strings representing the output buffer
//   The processor function should return STATUS_OK if everything is OK,
//   STATUS_DONE to stop processing and write out the results, or STATUS_FAIL
//   if the processing should be halted completely for this file.
//
//  The default handleLine method just copies the input to the output.
//
TextProcessor.prototype.handleLine = function(line, index, outputBuffer) {
  if (line != undefined) {
    outputBuffer.push(line);
  }
  return TextProcessorStatus.OK;
};

//============================== Demo Code ====================================
//
// lineNumbers
//   This is a _sample_ line handler. It just prepends the line with the
//   current line number and a colon and copies it to the outputBuffer
//   This function must be replaced/overridden
//
TextProcessor.lineNumbers = function(line, index, outputBuffer) {
  if (line != undefined) {
    outputBuffer.push('' + index + ": " + line);
  }
  return TextProcessorStatus.OK;
};

//
// This is a demo to show how the TextProcessor class can be used
//
TextProcessor.demo = function() {
  var proc = new TextProcessor();
  proc.handleLine = TextProcessor.lineNumbers;
  proc.exec("/c/work/mhale/Info.txt", "/c/work/mhale/Info.out");
};

//TextProcessor.demo();

"TextProcessor.js";
// EOF

//
// GenericUI
// This is a lightweight UI framework. All of the common code that you
// need to write for a ScriptUI-based application is abstracted out here.
//
// $Id: SLCFix.js,v 1.72 2015/12/03 22:01:32 anonymous Exp $
// Copyright: (c)2005, xbytor
// License: http://www.opensource.org/licenses/bsd-license.php
// Contact: xbytor@gmail.com
//

isPhotoshop = function() {
  return !!app.name.match(/photoshop/i);
};
isBridge = function() {
  return !!app.name.match(/bridge/i);
};
isInDesign = function() {
  return !!app.name.match(/indesign/i);
};
isESTK = function() {
  return !!app.name.match(/estoolkit|ExtendScript Toolkit/i);
};
isPhotoshopElements = function() {
  return !!BridgeTalk.appName.match(/pseeditor/i);
};
isPSE = isPhotoshopElements;

_initVersionFunctions = function() {
  if (isPhotoshop()) {
    CSVersion = function() {
      return toNumber(app.version.match(/^\d+/)[0]) - 7;
    };
    CSVersion._version = CSVersion();

    isCS6 = function()  { return app.version.match(/^13\./); };
    isCS5 = function()  { return app.version.match(/^12\./); };
    isCS4 = function()  { return app.version.match(/^11\./); };
    isCS3 = function()  { return app.version.match(/^10\./); };
    isCS2 = function()  { return app.version.match(/^9\./); };
    isCS  = function()  { return app.version.match(/^8\./); };
    isPS7 = function()  { return app.version.match(/^7\./); };

  } else {
    var appName = BridgeTalk.appName;
    var version = BridgeTalk.appVersion;

    if (isPSE()) {
      isCS5 = function()  { return false; };
      isCS4 = function()  { return true; };
      isCS3 = function()  { return false; };
      isCS2 = function()  { return false; };
      isCS  = function()  { return false; };
      isPS7 = function()  { return false; };
    }
    if (isBridge()) {
      isCS6 = function()  { return version.match(/^5\./); };
      isCS5 = function()  { return version.match(/^4\./); };
      isCS4 = function()  { return version.match(/^3\./); };
      isCS3 = function()  { return version.match(/^2\./); };
      isCS2 = function()  { return version.match(/^1\./); };
      isCS  = function()  { return false; };
      isPS7 = function()  { return false; };

    } else if (isInDesign()) {
      isCS6 = function()  { return false; };
      isCS5 = function()  { return false; };
      isCS4 = function()  { return false; };
      isCS3 = function()  { return version.match(/^5\./); };
      isCS2 = function()  { return version.match(/^4\./); };
      isCS  = function()  { return false; };
      isPS7 = function()  { return false; };

    } else if (isESTK()) {
      isCS6 = function()  { return version.match(/^3\.8/); };
      isCS5 = function()  { return version.match(/^3\.5/); };
      isCS4 = function()  { return version.match(/^3\./); };
      isCS3 = function()  { return version.match(/^2\./); };
      isCS2 = function()  { return version.match(/^1\./); };
      isCS  = function()  { return false; };
      isPS7 = function()  { return false; };

    } else {
      isCS6 = function()  { Error.runtimeError(9001,
                                               "Unsupported application"); };
      isCS5 = function()  { Error.runtimeError(9001,
                                               "Unsupported application"); };
      isCS4 = function()  { Error.runtimeError(9001,
                                               "Unsupported application"); };
      isCS3 = function()  { Error.runtimeError(9001,
                                               "Unsupported application"); };
      isCS2 = function()  { Error.runtimeError(9001,
                                               "Unsupported application"); };
      isCS  = function()  { Error.runtimeError(9001,
                                               "Unsupported application"); };
      isPS7 = function()  { Error.runtimeError(9001,
                                               "Unsupported application"); };
    }
  }
};

var isCS3;
if (!isCS3 || !isPhotoshop())  {
  _initVersionFunctions();
}

//
// GenericUI is the core class for this framework.
//
GenericUI = function() {
  var self = this;

  self.title = "GenericUI";  // the window title
  self.notesSize = 50;       // the height of the Notes text panel
                             // set to 0 to disable
  self.winRect = {           // the rect for the window
    x: 200,
    y: 200,
    w: 100,
    h: 200
  };
  self.documentation = "This is a Photoshop JavaScript script";

  self.iniFile = undefined; // the name of the ini file used for this script
  self.saveIni = true;      // Set to 'undefined' to disable saving  to the
                            // ini file
  self.hasBorder = true;

  self.windowType = 'dialog'; // 'palette';

  self.notesTxt   = 'Notes:';
  self.processTxt = 'Process';
  self.cancelTxt  = 'Cancel';

  self.buttonOneTxt = undefined;
  self.buttonTwoTxt = undefined;

  self.settingsPanel = false;
  self.optionsClass = undefined;
  self.win = undefined;
  self.window = undefined;
  self.doc = undefined;
  self.ini = undefined;

  self.setDefault = !isCS();

  self._logDebug = false;

  self.parentWin = undefined;

  self.windowCreationProperties = undefined;

  self.buttonWidth = 90;

  self.xmlEnabled = false;

  self.windowType = 'dialog';
};

GenericUI.getTextOfs = function() {
  return (CSVersion() > 2) ? 3 : 0;
};

//
// Returns the xtools preferences folder
//
GenericUI._getPreferencesFolder = function() {
  var userData = Folder.userData;

  if (!userData || !userData.exists) {
    userData = Folder("~");
  }

  var folder = new Folder(userData + "/xtools");

  if (!folder.exists) {
    folder.create();
  }

  return folder;
};

isWindows = function() {
  return !!$.os.match(/windows/i);
};
isMac = function() {
  return !isWindows();
};

GenericUI.ENCODING = "LATIN1";

GenericUI.preferencesFolder = GenericUI._getPreferencesFolder();
GenericUI.PREFERENCES_FOLDER = GenericUI.preferencesFolder;

GenericUI.prototype.isPalette = function() {
  return this.windowType == 'palette';
};
GenericUI.prototype.isDialog = function() {
  return this.windowType == 'dialog';
};

//
// createWindow constructs a window with a documentation panel and a app panel
// and 'Process' and 'Cancel' buttons. 'createPanel' (implemented by the app
// script) is invoked by this method to create the app panel.
//
GenericUI.prototype.createWindow = function(ini, doc) {
  var self = this;
  var wrect = self.winRect;

  function rectToBounds(r) {
    return[r.x, r.y, r.x+r.w, r.y+r.h];
  };
  var win = new Window(self.windowType, self.title, rectToBounds(wrect),
                       self.windowCreationProperties);

  win.mgr = self;  // save a ref to the UI manager
  win.ini = ini;
  if (!self.ini) {
    self.ini = win.ini;
  }
  self.window = self.win = win;
  self.doc = doc;

  var xOfs = 10;
  var yy = 10;

  var hasButtons = (self.processTxt || self.cancelTxt ||
                    self.buttonOneTxt || self.buttonTwoTxt);

  var hasNotesPanel = (self.notesSize && self.documentation);

  if (hasNotesPanel) {
    // define the notes panel (if needed) and insert the documentation text
    var docPnl = win.add('panel',
                         [xOfs, yy, wrect.w-xOfs, self.notesSize+10],
                         self.notesTxt);

    var y = (isCS() ? 20 : 10);
    var ymax = (isCS() ? self.notesSize-10 : self.notesSize-20);
    var docs = self.documentation;

    if (CSVersion() > 2) {
      docs = docs.replace(/&/g, '&&');
    }
    docPnl.add('statictext',
               [10,y,docPnl.bounds.width-10,ymax],
               docs,
               {multiline:true});

    yy += self.notesSize + 10;
  }

  var appBottom = wrect.h - 10;
  if (self.settingsPanel) {
    appBottom -=  70;
  }
  if (hasButtons) {
    appBottom -=  50;
  }

  // Now, create the application panel
  var pnlType = 'panel';
  if (!isCS()) {
    pnlType = (self.hasBorder ? 'panel' : 'group');
  }
  win.appPnl = win.add(pnlType, [xOfs, yy, wrect.w-xOfs, appBottom]);

  win.appPanel = win.appPnl;

  yy = appBottom + 10;

  // and call the application callback function with the ini object
  self.createPanel(win.appPnl, ini, doc);

  // Settings Panel
  if (self.settingsPanel) {
    win.settingsPnl = win.add('panel', [xOfs,yy,wrect.w-xOfs,yy+60]);
    win.settingsPnl.text = 'Settings';
    self.createSettingsPanel(win.settingsPnl, ini);
  }

  if (hasButtons) {
    // Create the Process/Cancel buttons
    var btnY = wrect.h - 40;
    var btnW = self.buttonWidth;
    var btnOfs;

    var btns = ['processTxt', 'cancelTxt', 'buttonOneTxt', 'buttonTwoTxt'];

    var btnCnt = 0;

    for (var i = 0; i < btns.length; i++) {
      if (self[btns[i]]) {
        btnCnt++;
      }
    }

    if (!self.processTxt || !self.cancelTxt) {
      btnOfs = (wrect.w - (btnW)) / 2;
    } else {
      btnOfs = (wrect.w - (2 * btnW)) / 3;
    }

    if (self.processTxt) {
      win.process = win.add('button',
                            [btnOfs,btnY,btnOfs+btnW,btnY+20],
                            self.processTxt);
      if (self.setDefault) {
        win.defaultElement = win.process;
      }

      // And now the callback for the process button.
      win.process.onClick = function() {
        try {
          // validate the contents of the window
          var rc = this.parent.validate();

          if (!rc) {
            // if there was a terminal problem with the validation,
            // close up the window
            this.parent.close(2);
          }

          if (rc && self.isPalette()) {
            self.process(win.opts);
          }
        } catch (e) {
          var msg = Stdlib.exceptionMessage(e);
          Stdlib.log(msg);
          alert(msg);
        }
      };
    }

    if (self.cancelTxt) {
      win.cancel  = win.add('button',
                            [wrect.w-btnOfs-btnW,btnY,wrect.w-btnOfs,btnY+20],
                            self.cancelTxt);

      win.cancelElement = win.cancel;

      win.cancel.onClick = function() {
        this.parent.close(2);
      };
    }
  }

  // Point to the validation
  win.validate = GenericUI.validate;

  return win;
};
GenericUI.processCB = function() {
  try {
    var win = GenericUI.getWindow(this);
    // validate the contents of the window
    var rc = win.validate();

    if (!rc) {
      // if there was a terminal problem with the validation,
      // close up the window
      win.close(2);
    }
  } catch (e) {
    var msg = Stdlib.exceptionMessage(e);
    Stdlib.log(msg);
    alert(msg);
  }
};
GenericUI.cancelCB = function() {
  var win = GenericUI.getWindow(this);
  win.parent.close(2);
};

GenericUI.prototype.moveWindow = function(x, y) {
  var win = this.win;

  if (x != undefined && !isNaN(x)) {
    var width = win.bounds.width;
    if (isCS()) {
      x -= 2;
    }
    win.bounds.left = x;
    win.bounds.width = width; //  Not sure if this is really needed
  }
  if (y != undefined && !isNaN(y)) {
    var height = win.bounds.height;
    if (isCS()) {
      // y -= 22;
    }
    win.bounds.top = y;
    win.bounds.height = height;  //  Not sure if this is really needed
  }
};
GenericUI.getWindow = function(pnl) {
  if (pnl.window) {
    return pnl.window;
  }
  while (pnl && !(pnl instanceof Window)) {
    pnl = pnl.parent;
  }
  return pnl;
};
GenericUI.prototype.createSettingsPanel = function(pnl, ini) {
  var win = GenericUI.getWindow(pnl);

  pnl.text = 'Settings';
  pnl.win = win;

  pnl.fileMask = "INI Files: *.ini, All Files: *.*";
  pnl.loadPrompt = "Please choose a settings file to read";
  pnl.savePrompt = "Please choose a settings file to write";
  pnl.defaultFile = undefined;

  var w = pnl.bounds[2] - pnl.bounds[0];
  var offsets = [w*0.2, w*0.5, w*0.8];
  var y = 15;
  var bw = 90;

  var x = offsets[0]-(bw/2);
  pnl.load = pnl.add('button', [x,y,x+bw,y+20], 'Load...');
  x = offsets[1]-(bw/2);
  pnl.save = pnl.add('button', [x,y,x+bw,y+20], 'Save...');
  x = offsets[2]-(bw/2);
  pnl.reset = pnl.add('button', [x,y,x+bw,y+20], 'Reset');

  pnl.load.onClick = function() {
    var pnl = this.parent;
    var win = pnl.win;
    var mgr = win.mgr;
    var def = pnl.defaultFile;

    if (!def) {
      if (mgr.iniFile) {
        def = GenericUI.iniFileToFile(mgr.iniFile);
      } else {
        def = GenericUI.iniFileToFile("~/settings.ini");
      }
    }

    var f;
    var prmpt = pnl.loadPrompt;
    var sel = Stdlib.createFileSelect(pnl.fileMask);
    if (isMac()) {
      sel = undefined;
    }
    f = Stdlib.selectFileOpen(prmpt, sel, def);
    if (f) {
      win.ini = mgr.readIniFile(f);
      if (f.exists) {
        win.iniContents = Stdlib.readFromFile(f);
      }
      win.close(4);

      if (pnl.onLoad) {
        pnl.onLoad(f);
      }
    }
  };

  pnl.save.onClick = function() {
    var pnl = this.parent;
    var win = pnl.win;
    var mgr = win.mgr;
    var def = pnl.defaultFile;

    if (!def) {
      if (mgr.iniFile) {
        def = GenericUI.iniFileToFile(mgr.iniFile);
      } else {
        def = GenericUI.iniFileToFile("~/settings.ini");
      }
    }

    var f;
    var prmpt = pnl.savePrompt;
    var sel = Stdlib.createFileSelect(pnl.fileMask);

    if (isMac()) {
      sel = undefined;
    }
    f = Stdlib.selectFileSave(prmpt, sel, def);

    if (f) {
      var mgr = win.mgr;
      var res = mgr.validatePanel(win.appPnl, win.ini);

      if (typeof(res) != 'boolean') {
        mgr.writeIniFile(f, res);

        if (pnl.onSave) {
          pnl.onSave(f);
        }
      }
    }
  };

  pnl.reset.onClick = function() {
    var pnl = this.parent;
    var win = pnl.win;
    var mgr = win.mgr;

    if (mgr.defaultIniFile) {
      win.ini = mgr.readIniFile(mgr.defaultIniFile);
      if (File(mgr.defaultIniFile).exists) {
        win.iniContents = Stdlib.readFromFile(mgr.defaultIniFile);
      }
    } else if (mgr.ini) {
      win.ini = mgr.ini;
    }

    win.close(4);
    if (pnl.onReset) {
      pnl.onReset();
    }
  };
};

GenericUI.prototype.createFontPanel = function(pnl, ini, label, lwidth) {
  var win = GenericUI.getWindow(pnl);

  pnl.win = win;

  var w = pnl.bounds[2] - pnl.bounds[0];
  var xofs = 0;
  var y = 0;

  if (pnl.type == 'panel') {
    xofs += 5;
    y += 5;
  }

  var tOfs = GenericUI.getTextOfs();

  var x = xofs;
  if (label == undefined) {
    label = "Font:";
    lwidth = 40;
  }

  if (label != '') {
    pnl.label = pnl.add('statictext', [x,y+tOfs,x+lwidth,y+22+tOfs], label);
    x += lwidth;
  }
  pnl.family = pnl.add('dropdownlist', [x,y,x+180,y+22]);
  x += 185;
  pnl.style  = pnl.add('dropdownlist', [x,y,x+110,y+22]);
  x += 115;
  pnl.fontSize  = pnl.add('edittext', [x,y,x+30,y+22], "12");
  x += 32;
  pnl.sizeLabel = pnl.add('statictext', [x,y+tOfs,x+15,y+22+tOfs], 'pt');

  pnl.fontTable = GenericUI._getFontTable();
  var names = [];
  for (var idx in pnl.fontTable) {
    names.push(idx);
  }
  names.sort();
  for (var i = 0; i < names.length; i++) {
    pnl.family.add('item', names[i]);
  }
  pnl.family.onChange = function() {
    var pnl = this.parent;
    var sel = pnl.family.selection.text;
    var family = pnl.fontTable[sel];

    pnl.style.removeAll();

    var styles = family.styles;

    for (var i = 0; i < styles.length; i++) {
      var it = pnl.style.add('item', styles[i].style);
      it.font = styles[i].font;
    }
    if (pnl._defaultStyle) {
      var it = pnl.style.find(pnl._defaultStyle);
      pnl._defaultStyle = undefined;
      if (it) {
        it.selected = true;
      } else {
        pnl.style.items[0].selected = true;
      }
    } else {
      pnl.style.items[0].selected = true;
    }
  };
  pnl.family.items[0].selected = true;

  pnl.fontSize.onChanging = GenericUI.numberKeystrokeFilter;

  pnl.setFont = function(str, size) {
    var pnl = this;
    if (!str) {
      return;
    }
    var font = (str.typename == "TextFont") ? str : Stdlib.determineFont(str);
    if (font) {
      var it = pnl.family.find(font.family);
      if (it) {
        it.selected = true;
        pnl._defaultStyle = font.style;
      }
    }
    pnl.fontSize.text = size;
    pnl.family.onChange();
  };
  pnl.getFont = function() {
    var pnl = this;
    var font = pnl.style.selection.font;
    return { font: font.postScriptName, size: Number(pnl.fontSize.text) };

    var fsel = pnl.family.selection.text;
    var ssel = pnl.style.selection.text;
    var family = pnl.fontTable[sel];
    var styles = familyStyles;
    var font = undefined;

    for (var i = 0; i < styles.length && font == undefined; i++) {
      if (styles[i].style == ssel) {
        font = styles[i].font;
      }
    }
    return { font: font, size: Number(font.fontSize) };
  }

  return pnl;
};
GenericUI._getFontTable = function() {
  var fonts = app.fonts;
  var fontTable = {};
  for (var i = 0; i < fonts.length; i++) {
    var font = fonts[i];
    var entry = fontTable[font.family];
    if (!entry) {
      entry = { family: font.family, styles: [] };
      fontTable[font.family] = entry;
    }
    entry.styles.push({ style: font.style, font: font });
  }
  return fontTable;
};

GenericUI._getFontArray = function() {
  var fontTable = GenericUI._getFontTable();
  var fonts = [];
  for (var idx in fontTable) {
    var f = fontTable[idx];
    fonts.push(f);
  }
  return fonts;
};

if (!isCS()) {
//============================= FileNaming ====================================
//
// FileNaming is only available in PS at present
//
FileNamingOptions = function(obj, prefix) {
  var self = this;

  self.fileNaming = [];      // array of FileNamingType and/or String
  self.startingSerial = 1;
  self.windowsCompatible = isWindows();
  self.macintoshCompatible = isMac();
  self.unixCompatible = true;

  if (obj) {
    if (prefix == undefined) {
      prefix = '';
    }
    var props = FileNamingOptions.props;
    for (var i = 0; i < props.length; i++) {
      var name = props[i];
      var oname = prefix + name;
      if (oname in obj) {
        self[name] = obj[oname];
      }
    }

    if (self.fileNaming.constructor == String) {
      self.fileNaming = self.fileNaming.split(',');

      // remove "'s from around custom text
    }
  }
};
FileNamingOptions.prototype.typename = FileNamingOptions;
FileNamingOptions.props = ["fileNaming", "startingSerial", "windowsCompatible",
                           "macintoshCompatible", "unixCompatible"];

FileNamingOptions.prototype.format = function(file, cdate) {
  var self = this;
  var str  = '';

  file = Stdlib.convertFptr(file);

  if (!cdate) {
    cdate = file.created || new Date();
  }

  var fname = file.strf("%f");
  var ext = file.strf("%e");

  var parts = self.fileNaming;

  if (parts.constructor == String) {
    parts = parts.split(',');
  }

  var serial = self.startingSerial;
  var aCode = 'a'.charCodeAt(0);
  var ACode = 'A'.charCodeAt(0);

  for (var i = 0; i < parts.length; i++) {
    var p = parts[i];
    var fnel = FileNamingElements.getByName(p);

    if (!fnel) {
      if (p == '--') {
        p = '-';
      }
      // remove "'s from around custom text
      str += p;
      continue;
    }

    var s = '';
    switch (fnel.type) {
    case FileNamingType.DOCUMENTNAMEMIXED: s = fname; break;
    case FileNamingType.DOCUMENTNAMELOWER: s = fname.toLowerCase(); break;
    case FileNamingType.DOCUMENTNAMEUPPER: s = fname.toUpperCase(); break;
    case FileNamingType.SERIALNUMBER1:     s = "%d".sprintf(serial++); break;
    case FileNamingType.SERIALNUMBER2:     s = "%02d".sprintf(serial++); break;
    case FileNamingType.SERIALNUMBER3:     s = "%03d".sprintf(serial++); break;
    case FileNamingType.SERIALNUMBER4:     s = "%04d".sprintf(serial++); break;
    case FileNamingElement.SERIALNUMBER5:  s = "%05d".sprintf(serial++); break;
    case FileNamingType.EXTENSIONLOWER:    s = '.' + ext.toLowerCase(); break;
    case FileNamingType.EXTENSIONUPPER:    s = '.' + ext.toUpperCase(); break;
    case FileNamingType.SERIALLETTERLOWER:
      s = String.fromCharCode(aCode + (serial++)); break;
    case FileNamingType.SERIALLETTERUPPER:
      s = String.fromCharCode(ACode + (serial++)); break;
    }

    if (s) {
      str += s;
      continue;
    }

    var fmt = '';
    switch (fnel.type) {
    case FileNamingType.MMDDYY:   fmt = "%m%d%y"; break;
    case FileNamingType.MMDD:     fmt = "%m%d"; break;
    case FileNamingType.YYYYMMDD: fmt = "%Y%m%d"; break;
    case FileNamingType.YYMMDD:   fmt = "%y%m%d"; break;
    case FileNamingType.YYDDMM:   fmt = "%y%d%m"; break;
    case FileNamingType.DDMMYY:   fmt = "%d%m%y"; break;
    case FileNamingType.DDMM:     fmt = "%d%m"; break;
    }

    if (fmt) {
      str += cdate.strftime(fmt);
      continue;
    }
  }

  self._serial = serial;

  return str;
};

FileNamingOptions.prototype.copyTo = function(opts, prefix) {
  var self = this;
  var props = FileNamingOptions.props;

  for (var i = 0; i < props.length; i++) {
    var name = props[i];
    var oname = prefix + name;
    opts[oname] = self[name];
    if (name == 'fileNaming' && self[name] instanceof Array) {
      opts[oname] = self[name].join(',');
    } else {
      opts[oname] = self[name];
    }
  }
};


// this array is folder into FileNamingElement
FileNamingOptions._examples =
  [ "",
    "Document",
    "document",
    "DOCUMENT",
    "1",
    "01",
    "001",
    "0001",
    "a",
    "A",
    "103107",
    "1031",
    "20071031",
    "071031",
    "073110",
    "311007",
    "3110",
    ".psd",
    ".PSD"
    ];

FileNamingOptions.prototype.getExample = function() {
  var self = this;
  var str = '';
  return str;
};

FileNamingElement = function(name, menu, type, sm, example) {
  var self = this;
  self.name = name;
  self.menu = menu;
  self.type = type;
  self.smallMenu = sm;
  self.example = (example || '');
};
FileNamingElement.prototype.typename = FileNamingElement;

FileNamingElements = [];
FileNamingElements._add = function(name, menu, type, sm, ex) {
  FileNamingElements.push(new FileNamingElement(name, menu, type, sm, ex));
}

FileNamingElement.NONE = "(None)";

FileNamingElement.SERIALNUMBER5 = {
  toString: function() { return "FileNamingElement.SERIALNUMBER5"; }
};

FileNamingElements._init = function() {

  FileNamingElements._add("", "", "", "", "");

  try {
    FileNamingType;
  } catch (e) {
    return;
  }

  // the names here correspond to the sTID symbols used when making
  // a Batch request via the ActionManager interface. Except for "Name",
  // which should be "Nm  ".
  // the names should be the values used when serializing to and from
  // an INI file.
  // A FileNamingOptions object needs to be defined.
  FileNamingElements._add("Name", "Document Name",
                          FileNamingType.DOCUMENTNAMEMIXED,
                          "Name", "Document");
  FileNamingElements._add("lowerCase", "document name",
                          FileNamingType.DOCUMENTNAMELOWER,
                          "name", "document");
  FileNamingElements._add("upperCase", "DOCUMENT NAME",
                          FileNamingType.DOCUMENTNAMEUPPER,
                          "NAME", "DOCUMENT");
  FileNamingElements._add("oneDigit", "1 Digit Serial Number",
                          FileNamingType.SERIALNUMBER1,
                          "Serial #", "1");
  FileNamingElements._add("twoDigit", "2 Digit Serial Number",
                          FileNamingType.SERIALNUMBER2,
                          "Serial ##", "01");
  FileNamingElements._add("threeDigit", "3 Digit Serial Number",
                          FileNamingType.SERIALNUMBER3,
                          "Serial ###", "001");
  FileNamingElements._add("fourDigit", "4 Digit Serial Number",
                          FileNamingType.SERIALNUMBER4,
                          "Serial ####", "0001");
  FileNamingElements._add("fiveDigit", "5 Digit Serial Number",
                          FileNamingElement.SERIALNUMBER5,
                          "Serial #####", "00001");
  FileNamingElements._add("lowerCaseSerial", "Serial Letter (a, b, c...)",
                          FileNamingType.SERIALLETTERLOWER,
                          "Serial a", "a");
  FileNamingElements._add("upperCaseSerial", "Serial Letter (A, B, C...)",
                          FileNamingType.SERIALLETTERUPPER,
                          "Serial A", "A");
  FileNamingElements._add("mmddyy", "mmddyy (date)",
                          FileNamingType.MMDDYY,
                          "mmddyy", "103107");
  FileNamingElements._add("mmdd", "mmdd (date)",
                          FileNamingType.MMDD,
                          "mmdd", "1031");
  FileNamingElements._add("yyyymmdd", "yyyymmdd (date)",
                          FileNamingType.YYYYMMDD,
                          "yyyymmdd", "20071031");
  FileNamingElements._add("yymmdd", "yymmdd (date)",
                          FileNamingType.YYMMDD,
                          "yymmdd", "071031");
  FileNamingElements._add("yyddmm", "yyddmm (date)",
                          FileNamingType.YYDDMM,
                          "yyddmm", "073110");
  FileNamingElements._add("ddmmyy", "ddmmyy (date)",
                          FileNamingType.DDMMYY,
                          "ddmmyy", "311007");
  FileNamingElements._add("ddmm", "ddmm (date)",
                          FileNamingType.DDMM,
                          "ddmm", "3110");
  FileNamingElements._add("lowerCaseExtension", "extension",
                          FileNamingType.EXTENSIONLOWER,
                          "ext", ".psd");
  FileNamingElements._add("upperCaseExtension", "EXTENSION",
                          FileNamingType.EXTENSIONUPPER,
                          "EXT", ".PSD");
};
FileNamingElements._init();
FileNamingElements.getByName = function(name) {
  return Stdlib.getByName(FileNamingElements, name);
};

GenericUI.prototype.createFileNamingPanel = function(pnl, ini,
                                                     prefix,
                                                     useSerial,
                                                     useCompatibility,
                                                     columns) {
  var win = GenericUI.getWindow(pnl);
  if (useSerial == undefined) {
    useSerial = false;
  }
  if (useCompatibility == undefined) {
    useCompatibility = false;
  }
  if (columns == undefined) {
    columns = 3;
  } else {
    if (columns != 2 && columns != 3) {
      Error.runtimeError(9001, "Internal Error: Bad column spec for " +
                         "FileNaming panel");
    }
  }

  pnl.fnmenuElements = [];
  for (var i = 0; i < FileNamingElements.length; i++) {
    var fnel = FileNamingElements[i];
    pnl.fnmenuElements.push(fnel.menu);
  }
  var extrasMenuEls = [
    "-",
    "Create Custom Text",
    "Edit Custom Text",
    "Delete Custom Text",
    "-",
    FileNamingElement.NONE,
    ];
  for (var i = 0; i < extrasMenuEls.length; i++) {
    pnl.fnmenuElements.push(extrasMenuEls[i]);
  }

  pnl.win = win;
  if (prefix == undefined) {
    prefix = '';
  }
  pnl.prefix = prefix;

  var w = pnl.bounds[2] - pnl.bounds[0];
  var xofs = 0;
  var y = 0;

  if (pnl.type == 'panel') {
    xofs += 5;
    y += 10;
  }
  pnl.text = "File Naming";

  var tOfs = GenericUI.getTextOfs();

  if (columns == 2) {
    var menuW = (w - 50)/2;

  } else {
    var menuW = (w - 65)/3;
  }

  var opts = new FileNamingOptions(ini, pnl.prefix);

  x = xofs;

  pnl.exampleLabel = pnl.add('statictext', [x,y+tOfs,x+70,y+22+tOfs],
                             'Example:');
  x += 70;
  pnl.example = pnl.add('statictext', [x,y+tOfs,x+400,y+22+tOfs], '');
  y += 30;
  x = xofs;

  pnl.menus = [];

  pnl.menus[0]  = pnl.add('dropdownlist', [x,y,x+menuW,y+22],
                          pnl.fnmenuElements);
  x += menuW + 5;
  pnl.add('statictext', [x,y+tOfs,x+10,y+22+tOfs], '+');

  x += 15;

  pnl.menus[1]  = pnl.add('dropdownlist', [x,y,x+menuW,y+22],
                          pnl.fnmenuElements);
  x += menuW + 5;
  pnl.add('statictext', [x,y+tOfs,x+10,y+22+tOfs], '+');

  if (columns == 2) {
    y += 30;
    x = xofs;
  } else {
    x += 15;
  }

  pnl.menus[2]  = pnl.add('dropdownlist', [x,y,x+menuW,y+22],
                          pnl.fnmenuElements);
  x += menuW + 5;
  pnl.add('statictext', [x,y+tOfs,x+10,y+22+tOfs], '+');

  if (columns == 3) {
    y += 30;
    x = xofs;

  } else {
    x += 15;
  }

  pnl.menus[3]  = pnl.add('dropdownlist', [x,y,x+menuW,y+22],
                          pnl.fnmenuElements);
  x += menuW + 5;
  pnl.add('statictext', [x,y+tOfs,x+10,y+22+tOfs], '+');

  if (columns == 2) {
    y += 30;
    x = xofs;

  } else {
    x += 15;
  }

  pnl.menus[4]  = pnl.add('dropdownlist', [x,y,x+menuW,y+22],
                          pnl.fnmenuElements);
  x += menuW + 5;
  pnl.add('statictext', [x,y+tOfs,x+10,y+22+tOfs], '+');

  x += 15;

  pnl.menus[5]  = pnl.add('dropdownlist', [x,y,x+menuW,y+22],
                          pnl.fnmenuElements);
  y += 30;
  x = xofs;

  pnl.addMenuElement = function(text) {
    var pnl = this;
    for (var i = 0; i < 6; i++) {
      var vmenu = pnl.menus[i];
      vmenu.add('item', text);
    }
  }

  pnl.useSerial = useSerial;
  if (useSerial) {
    pnl.add('statictext', [x,y+tOfs,x+80,y+22+tOfs], 'Starting serial#:');
    x += 90;
    pnl.startingSerial = pnl.add('edittext', [x,y,x+50,y+22],
                                 opts.startingSerial);
    y += 30;
    x = xofs;
    pnl.startingSerial.onChanging = GenericUI.numberKeystrokeFilter;
    pnl.startingSerial.onChange = function() {
      var pnl = this.parent;
    }
  }

  pnl.useCompatibility = useCompatibility;
  if (useCompatibility) {
    pnl.add('statictext', [x,y+tOfs,x+80,y+22+tOfs], 'Compatibility:');
    x += 90;
    pnl.compatWindows = pnl.add('checkbox', [x,y,x+70,y+22], 'Windows');
    x += 80;
    pnl.compatMac = pnl.add('checkbox', [x,y,x+70,y+22], 'MacOS');
    x += 80;
    pnl.compatUnix = pnl.add('checkbox', [x,y,x+70,y+22], 'Unix');

    pnl.compatWindows.value = opts.windowsCompatible;
    pnl.compatMac.value = opts.macintoshCompatible;
    pnl.compatUnix.value = opts.unixCompatible;
  }

  function menuOnChange() {
    var pnl = this.parent;
    var win = GenericUI.getWindow(pnl);
    if (pnl.processing) {
      return;
    }
    pnl.processing = true;
    try {
      var menu = this;
      if (!menu.selection) {
        return;
      }

      var currentSelection = menu.selection.index;
      var lastSelection = menu.lastMenuSelection;

      menu.lastMenuSelection = menu.selection.index;

      var lastWasCustomText = (lastSelection >= pnl.fnmenuElements.length);

      var sel = menu.selection.text;
      if (sel == FileNamingElement.NONE) {
        menu.selection = menu.items[0];
        sel = menu.selection.text;
      }

      if (sel == "Create Custom Text") {
        var text = GenericUI.createCustomTextDialog(win,
                                                    "Create Custom Text",
                                                    "new");
        if (text) {
          if (text.match(/^\-+$/)) {
            text += '-';
          }
          if (!menu.find(text)) {
            pnl.addMenuElement(text);
          }

          var it = menu.find(text);
          menu.selection = it;
          menu.lastMenuSelection = it.index;

        } else {
          if (lastSelection >= 0) {
            menu.selection = menu.items[lastSelection];
            menu.lastMenuSelection = lastSelection;

          } else {
            menu.selection = menu.items[0];
          }
        }

      } else if (lastWasCustomText) {
        if (sel == "Edit Custom Text") {
          var lastText = menu.items[lastSelection].text;
          var text = GenericUI.createCustomTextDialog(win,
                                                      "Edit Custom Text",
                                                      "edit",
                                                      lastText);
          if (text) {
            for (var i = 0; i < 6; i++) {
              var vmenu = pnl.menus[i];
              var it = vmenu.add('item', text);

              if (vmenu.selection &&
                  vmenu.selection.index == lastSelection) {

                // if a menu already has the previous version of this edited
                // entry, we have to remove the old one before setting the
                // new one or else the menu selection gets lost
                vmenu.remove(lastSelection);
                vmenu.selection = it;

              } else {
                var it = vmenu.selection;
                vmenu.remove(lastSelection);
                vmenu.selection = it;
              }
            }

            var it = menu.find(text);
            menu.selection = it;
            pnl.lastMenuSelection = it.index;

          } else {
            if (lastSelection >= 0) {
              menu.selection = menu.items[lastSelection];
              menu.lastMenuSelection = lastSelection;

            } else {
              menu.selection = menu.items[0];
            }
          }

        } else if (sel == "Delete Custom Text") {
          var lastText = menu.items[lastSelection].text;
          if (confirm("Do you really want to remove \"" + lastText + "\"?")) {
            for (var i = 0; i < 6; i++) {
              var vmenu = pnl.menus[i];
              vmenu.remove(lastSelection);
            }
            menu.selection = menu.items[0];

          } else {
            menu.selection = menu.items[lastSelection];
            menu.lastMenuSelection = lastSelection;
          }

        } else {
          //alert("Internal error, Custom Text request");
        }

      } else {
        if (lastSelection >= 0 && (sel == "Edit Custom Text" ||
                                   sel == "Delete Custom Text")) {
          menu.selection = menu.items[lastSelection];
          menu.lastMenuSelection = lastSelection;
        }
      }

      var example = '';
      var format = [];

      for (var i = 0; i < 6; i++) {
        var vmenu = pnl.menus[i];
        if (vmenu.selection) {
          var fmt = '';
          var text = vmenu.selection.text;
          var fne = Stdlib.getByProperty(FileNamingElements, "menu", text);
          if (fne) {
            text = fne.example;
            fmt = fne.name;
          } else {
            fmt = text;
          }

          if (text) {
            if (text.match(/^\-+$/)) {
              text = text.substr(1);
            }
            example += text;
          }

          if (fmt) {
            if (fmt.match(/^\-+$/)) {
              fmt = fmt.substr(1);
            }
            format.push(fmt);
          }
        }
      }
      if (pnl.example) {
        pnl.example.text = example;
      }
      format = format.join(",");
      var win = GenericUI.getWindow(pnl);
      if (win.mgr.updateNamingFormat) {
        win.mgr.updateNamingFormat(format, example);
      }

    } finally {
      pnl.processing = false;
    }

    if (pnl.onChange) {
      pnl.onChange();
    }
  }

  // default all slots to ''
  for (var i = 0; i < 6; i++) {
    var menu = pnl.menus[i];
    menu.selection = menu.items[0];
    menu.lastMenuSelection = 0;
  }

  for (var i = 0; i < 6; i++) {
    var name = opts.fileNaming[i];
    if (name) {
      var fne = FileNamingElements.getByName(name);
      var it;

      if (!fne) {
        if (name.match(/^\-+$/)) {
          name += '-';
        }
        it = pnl.menus[i].find(name);
        if (!it) {
          pnl.addMenuElement(name);
          it = pnl.menus[i].find(name);
        }
      } else {
        it = pnl.menus[i].find(fne.menu);
      }
      pnl.menus[i].selection = it;
    }
  }

//   pnl.menus[0].selection = pnl.menus[0].find("document name");
//   pnl.menus[0].lastMenuSelection = pnl.menus[0].selection.index;
//   pnl.menus[1].selection = pnl.menus[1].find("extension");
//   pnl.menus[1].lastMenuSelection = pnl.menus[1].selection.index;

  for (var i = 0; i < 6; i++) {
    var menu = pnl.menus[i];
    menu.onChange = menuOnChange;
  }

  pnl.getFileNamingOptions = function(ini) {
    var pnl = this;
    var fileNaming = [];

    for (var i = 0; i < 6; i++) {
      var menu = pnl.menus[i];

      if (menu.selection) {
        var idx = menu.selection.index;

        if (idx) {
          // [0] is the "" item so we ignore it
          var fnel = FileNamingElements[idx];
          if (fnel) {
            fileNaming.push(fnel.name);

          } else {
            // its a custom naming option
            var txt = menu.selection.text;
            if (txt.match(/^\-+$/)) {
              txt = txt.substr(1);
            }

            // txt = '"' + text + '"';
            fileNaming.push(txt);
          }
        }
      }
    }

    var prefix = pnl.prefix;
    var opts = new FileNamingOptions(ini, prefix);
    opts.fileNaming = fileNaming;

    if (pnl.startingSerial) {
      opts.startingSerial = Number(pnl.startingSerial.text);
    }
    if (pnl.compatWindows) {
      opts.windowsCompatible = pnl.compatWindows.value;
    }
    if (pnl.compatMac) {
      opts.macintoshCompatible = pnl.compatMac.value;
    }
    if (pnl.compatUnix) {
      opts.unixCompatible = pnl.compatUnix.value;
    }
    return opts;
  }
  pnl.getFilenamingOptions = pnl.getFileNamingOptions;

  pnl.updateSettings = function(ini) {
    var pnl = this;

    var opts = new FileNamingOptions(ini, pnl.prefix);

    if (pnl.useSerial) {
      pnl.startingSerial.text = opts.startingSerial;
    }

    if (pnl.useCompatibility) {
      pnl.compatWindows.value = opts.windowsCompatible;
      pnl.compatMac.value = opts.macintoshCompatible;
      pnl.compatUnix.value = opts.unixCompatible;
    }

    // default all slots to ''
    for (var i = 0; i < 6; i++) {
      var menu = pnl.menus[i];
      menu.selection = menu.items[0];
      menu.lastMenuSelection = 0;
    }

    for (var i = 0; i < 6; i++) {
      var name = opts.fileNaming[i];
      if (name) {
        var fne = FileNamingElements.getByName(name);
        var it;

        if (!fne) {
          if (name.match(/^\-+$/)) {
            name += '-';
          }
          it = pnl.menus[i].find(name);
          if (!it) {
            pnl.addMenuElement(name);
            it = pnl.menus[i].find(name);
          }
        } else {
          it = pnl.menus[i].find(fne.menu);
        }
        pnl.menus[i].selection = it;
      }
    }

    for (var i = 0; i < 6; i++) {
      var menu = pnl.menus[i];
      menu.onChange = menuOnChange;
    }

    if (!(isCS() || isCS2())) {
      pnl.menus[0].onChange();
    }

    if (pnl.onChange) {
      pnl.onChange();
    }
  }

  if (!(isCS() || isCS2())) {
    pnl.menus[0].onChange();
  }

  if (pnl.onChange) {
    pnl.onChange();
  }

  return pnl;
};
GenericUI.createCustomTextDialog = function(win, title, mode, init) {
  var rect = {
    x: 200,
    y: 200,
    w: 350,
    h: 150
  };

  function rectToBounds(r) {
    return[r.x, r.y, r.x+r.w, r.y+r.h];
  };

  var cwin = new Window('dialog', title || 'Custom Text Editor',
                        rectToBounds(rect));

  cwin.text = title || 'Custom Text Editor';
  if (win) {
    cwin.center(win);
  }

  var xofs = 10;
  var y = 10;
  var x = xofs;

  var tOfs = GenericUI.getTextOfs();

  cwin.add('statictext', [x,y+tOfs,x+300,y+22+tOfs],
           "Please enter the desired Custom Text: ");
  y += 30;
  cwin.customText = cwin.add('edittext', [x,y,x+330,y+22]);

  cwin.customText.onChanging = function() {
    cwin = this.parent;
    var text = cwin.customText.text;

    if (cwin.initText) {
      cwin.saveBtn.enabled = (text.length > 0) && (text != cwin.initText);
    } else {
      cwin.saveBtn.enabled = (text.length > 0);
    }
  }

  if (init) {
    cwin.customText.text = init;
    cwin.initText = init;
  }

  y += 50;
  x += 100;
  cwin.saveBtn = cwin.add('button', [x,y,x+70,y+22], "Save");
  cwin.saveBtn.enabled = false;

  x += 100;
  cwin.cancelBtn = cwin.add('button', [x,y,x+70,y+22], "Cancel");

  cwin.defaultElement = cwin.saveBtn;

  var res = cwin.show();
  return (res == 1) ? cwin.customText.text : undefined;
};

GenericUI.prototype.validateFileNamingPanel = function(pnl, opts) {
  var self = this;
  var win = GenericUI.getWindow(pnl);
  var fopts = pnl.getFileNamingOptions(opts);

  if (fopts.fileNaming.length == 0) {
    return self.errorPrompt("You must specify a name for the files.");
  }

  fopts.copyTo(opts, pnl.prefix);

  return opts;
};
 }
//============================ File Save =====================================
//
// FileSave is only available in Photoshop
//
FileSaveOptions = function(obj) {
  var self = this;

  self.saveDocumentType = undefined; // SaveDocumentType
  self.fileType = "jpg";             // file extension

  self._saveOpts = undefined;

  self.saveForWeb = false; // gif, png, jpg

  self.bmpAlphaChannels = true;
  self.bmpDepth = BMPDepthType.TWENTYFOUR;
  self.bmpRLECompression = false;

  self.gifTransparency = true;
  self.gifInterlaced = false;
  self.gifColors = 256;

  self.jpgQuality = 10;
  self.jpgEmbedColorProfile = true;
  self.jpgFormat = FormatOptions.STANDARDBASELINE;
  self.jpgConvertToSRGB = false;          // requires code

  self.epsEncoding = SaveEncoding.BINARY;
  self.epsEmbedColorProfile = true;

  self.pdfEncoding = PDFEncoding.JPEG;
  self.pdfEmbedColorProfile = true;

  self.psdAlphaChannels = true;
  self.psdEmbedColorProfile = true;
  self.psdLayers = true;
  self.psdMaximizeCompatibility = true;           // requires code for prefs

  self.pngInterlaced = false;

  self.tgaAlphaChannels = true;
  self.tgaRLECompression = true;

  self.tiffEncoding = TIFFEncoding.NONE;
  self.tiffByteOrder = (isWindows() ? ByteOrder.IBM : ByteOrder.MACOS);
  self.tiffEmbedColorProfile = true;

  if (obj) {
    for (var idx in self) {
      if (idx in obj) {       // only copy in FSO settings
        self[idx] = obj[idx];
      }
    }
    if (!obj.fileType) {
      self.fileType = obj.fileSaveType;
      if (self.fileType == "tiff") {
        self.fileType = "tif";
      }
    }
  }
};
//FileSaveOptions.prototype.typename = "FileSaveOptions";
FileSaveOptions._enableDNG = false;

FileSaveOptions.convert = function(fsOpts) {
  var fsType = fsOpts.fileType;
  if (!fsType) {
    fsType = fsOpts.fileSaveType;
  }
  var fs = FileSaveOptionsTypes[fsType];
  if (fs == undefined) {
    return undefined;
  }
  if (!fs.optionsType) {
    return undefined;
  }
  var saveOpts = new fs.optionsType();
  saveOpts._ext = fsType;

  switch (fsType) {
    case "bmp": {
      saveOpts.rleCompression = toBoolean(fsOpts.bmpRLECompression);

      var value = BMPDepthType.TWENTYFOUR;
      var str = fsOpts.bmpDepth.toString();
      if (str.match(/1[^6]|one/i)) {
        value = BMPDepthType.ONE;
      } else if (str.match(/24|twentyfour/i)) {
        // we have to match 24 before 4
        value = BMPDepthType.TWENTYFOUR;
      } else if (str.match(/4|four/i)) {
        value = BMPDepthType.FOUR;
      } else if (str.match(/8|eight/i)) {
        value = BMPDepthType.EIGHT;
      } else if (str.match(/16|sixteen/i)) {
        value = BMPDepthType.SIXTEEN;
      } else if (str.match(/32|thirtytwo/i)) {
        value = BMPDepthType.THIRTYTWO;
      }
      saveOpts.depth = value;
      saveOpts.alphaChannels = toBoolean(fsOpts.bmpAlphaChannels);

      saveOpts._flatten = true;
      saveOpts._8Bit = true; //XXX Should this be true?
      break;
    }
    case "gif": {
      saveOpts.transparency = toBoolean(fsOpts.gifTransparency);
      saveOpts.interlaced = toBoolean(fsOpts.gifInterlaced);
      saveOpts.colors = toNumber(fsOpts.gifColors);

      saveOpts._convertToIndexed = true;
      saveOpts._flatten = true;
      saveOpts._8Bit = true;
      saveOpts._saveForWeb = toBoolean(fsOpts.saveForWeb);
      break;
    }
    case "jpg": {
      saveOpts.quality = toNumber(fsOpts.jpgQuality);
      saveOpts.embedColorProfile = toBoolean(fsOpts.jpgEmbedColorProfile);
      var value = FormatOptions.STANDARDBASELINE;
      var str = fsOpts.jpgFormat.toString();
      if (str.match(/standard/i)) {
        value = FormatOptions.STANDARDBASELINE;
      } else if (str.match(/progressive/i)) {
        value = FormatOptions.PROGRESSIVE;
      } else if (str.match(/optimized/i)) {
        value = FormatOptions.OPTIMIZEDBASELINE;
      }
      saveOpts.formatOptions = value;

      saveOpts._convertToSRGB = toBoolean(fsOpts.jpgConvertToSRGB);
      saveOpts._flatten = true;
      saveOpts._8Bit = true;
      saveOpts._saveForWeb = toBoolean(fsOpts.saveForWeb);
      break;
    }
    case "psd": {
      saveOpts.alphaChannels = toBoolean(fsOpts.psdAlphaChannels);
      saveOpts.embedColorProfile = toBoolean(fsOpts.psdEmbedColorProfile);
      saveOpts.layers = toBoolean(fsOpts.psdLayers);
      saveOpts.maximizeCompatibility =
        toBoolean(fsOpts.psdMaximizeCompatibility);
      break;
    }
    case "eps": {
      var value = SaveEncoding.BINARY;
      var str = fsOpts.epsEncoding.toString();
      if (str.match(/ascii/i)) {
        value = SaveEncoding.ASCII;
      } else if (str.match(/binary/i)) {
        value = SaveEncoding.BINARY;
      } else if (str.match(/jpg|jpeg/i)) {
        if (str.match(/high/i)) {
          value = SaveEncoding.JPEGHIGH;
        } else if (str.match(/low/i)) {
          value = SaveEncoding.JPEGLOW;
        } else if (str.match(/max/i)) {
          value = SaveEncoding.JPEGMAXIMUM;
        } else if (str.match(/med/i)) {
          value = SaveEncoding.JPEGMEDIUM;
        }
      }
      saveOpts.encoding = value;
      saveOpts.embedColorProfile = toBoolean(fsOpts.epsEmbedColorProfile);

      saveOpts._flatten = true;
      break;
    }
    case "pdf": {
      saveOpts.embedColorProfile = toBoolean(fsOpts.pdfEmbedColorProfile);
      break;
    }
    case "png": {
      saveOpts.interlaced = toBoolean(fsOpts.pngInterlaced);

      saveOpts._flatten = true;
      saveOpts._saveForWeb = toBoolean(fsOpts.saveForWeb);
      break;
    }
    case "tga": {
      saveOpts.alphaChannels = toBoolean(fsOpts.tgaAlphaChannels);
      saveOpts.rleCompression = toBoolean(fsOpts.tgaRLECompression);

      saveOpts._flatten = true;
      break;
    }
    case "tif": {
      var value = (isWindows() ? ByteOrder.IBM : ByteOrder.MACOS);
      var str = fsOpts.tiffByteOrder.toString();
      if (str.match(/ibm|pc/i)) {
        value = ByteOrder.IBM;
      } else if (str.match(/mac/i)) {
        value = ByteOrder.MACOS;
      }
      saveOpts.byteOrder = value;

      var value = TIFFEncoding.NONE;
      var str = fsOpts.tiffEncoding.toString();
      if (str.match(/none/i)) {
        value = TIFFEncoding.NONE;
      } else if (str.match(/lzw/i)) {
        value = TIFFEncoding.TIFFLZW;
      } else if (str.match(/zip/i)) {
        value = TIFFEncoding.TIFFZIP;
      } else if (str.match(/jpg|jpeg/i)) {
        value = TIFFEncoding.JPEG;
      }
      saveOpts.imageCompression = value;

      saveOpts.embedColorProfile = toBoolean(fsOpts.tiffEmbedColorProfile);
      break;
    }
    case "dng": {
    }
    default: {
      Error.runtimeError(9001, "Internal Error: Unknown file type: " +
                         fs.fileType);
    }
  }

  return saveOpts;
};

FileSaveOptionsType = function(fileType, menu, saveType, optionsType) {
  var self = this;

  self.fileType = fileType;    // the file extension
  self.menu = menu;
  self.saveType = saveType;
  self.optionsType = optionsType;
};
FileSaveOptionsType.prototype.typename = "FileSaveOptionsType";

FileSaveOptionsTypes = [];
FileSaveOptionsTypes._add = function(fileType, menu, saveType, optionsType) {
  var fsot = new FileSaveOptionsType(fileType, menu, saveType, optionsType);
  FileSaveOptionsTypes.push(fsot);
  FileSaveOptionsTypes[fileType] = fsot;
};
FileSaveOptionsTypes._init = function() {
  if (!isPhotoshop()) {
    return;
  }
  FileSaveOptionsTypes._add("bmp", "Bitmap (BMP)", SaveDocumentType.BMP,
                            BMPSaveOptions);
  FileSaveOptionsTypes._add("gif", "GIF", SaveDocumentType.COMPUSERVEGIF,
                            GIFSaveOptions);
  FileSaveOptionsTypes._add("jpg", "JPEG", SaveDocumentType.JPEG,
                            JPEGSaveOptions);
  FileSaveOptionsTypes._add("psd", "Photoshop PSD", SaveDocumentType.PHOTOSHOP,
                            PhotoshopSaveOptions);
  FileSaveOptionsTypes._add("eps", "Photoshop EPS",
                            SaveDocumentType.PHOTOSHOPEPS, EPSSaveOptions);
  FileSaveOptionsTypes._add("pdf", "Photoshop PDF",
                            SaveDocumentType.PHOTOSHOPPDF, PDFSaveOptions);
  FileSaveOptionsTypes._add("png", "PNG", SaveDocumentType.PNG,
                            PNGSaveOptions);
  FileSaveOptionsTypes._add("tga", "Targa", SaveDocumentType.TARGA,
                            TargaSaveOptions);
  FileSaveOptionsTypes._add("tif", "TIFF", SaveDocumentType.TIFF,
                            TiffSaveOptions);

  if (FileSaveOptions._enableDNG) {
    FileSaveOptionsTypes._add("dng", "DNG", undefined, undefined);
  }
};
FileSaveOptionsTypes._init();

// XXX remove file types _before_ creating a FS panel!
FileSaveOptionsTypes.remove = function(ext) {
  var ar = FileSaveOptionsTypes;
  var fsot = ar[ext];
  if (fsot) {
    for (var i = 0; i < ar.length; i++) {
      if (ar[i] == fsot) {
        ar.splice(i, 1);
        break;
      }
    }
    delete ar[ext];
  }
};

GenericUI.prototype.createFileSavePanel = function(pnl, ini) {
  var win = GenericUI.getWindow(pnl);
  pnl.mgr = this;

  var menuElements = [];

  for (var i = 0; i < FileSaveOptionsTypes.length; i++) {
    menuElements.push(FileSaveOptionsTypes[i].menu);
  }

  var w = pnl.bounds[2] - pnl.bounds[0];
  var xofs = 0;
  var y = 0;

  var opts = new FileSaveOptions(ini);

  if (pnl.type == 'panel') {
    xofs += 5;
    y += 10;
  }
  pnl.text = "Save Options";

  var tOfs = GenericUI.getTextOfs();

  var x = xofs;
  pnl.add('statictext', [x,y+tOfs,x+55,y+22+tOfs], 'File Type:');
  x += 127;
  pnl.fileType = pnl.add('dropdownlist', [x,y,x+150,y+22], menuElements);

  var ftype = opts.fileType || opts.fileSaveType || "jpg";

  var ft = Stdlib.getByProperty(FileSaveOptionsTypes,
                                "fileType",
                                ftype);
  pnl.fileType.selection = pnl.fileType.find(ft.menu);

  x += pnl.fileType.bounds.width + 10;
  pnl.saveForWeb = pnl.add('checkbox', [x,y,x+150,y+22], 'Save for Web');
  pnl.saveForWeb.visible = false;
  pnl.saveForWeb.value = false;

  y += 30;
  var yofs = y;

  x = xofs;

  //=============================== Bitmap ===============================
  if (FileSaveOptionsTypes["bmp"]) {
    pnl.bmpAlphaChannels = pnl.add('checkbox', [x,y,x+125,y+22],
                                   "Alpha Channels");

    x += 150;
    var bmpDepthMenu = ["1", "4", "8", "16", "24", "32"];
    pnl.bmpDepthLabel = pnl.add('statictext', [x,y+tOfs,x+60,y+22+tOfs],
                                'Bit Depth:');
    x += 65;
    pnl.bmpDepth = pnl.add('dropdownlist', [x,y,x+55,y+22], bmpDepthMenu);
    pnl.bmpDepth.selection = pnl.bmpDepth.find("24");

    pnl.bmpDepth.find("1")._value = BMPDepthType.ONE;
    pnl.bmpDepth.find("4")._value = BMPDepthType.FOUR;
    pnl.bmpDepth.find("8")._value = BMPDepthType.EIGHT;
    pnl.bmpDepth.find("16")._value = BMPDepthType.SIXTEEN;
    pnl.bmpDepth.find("24")._value = BMPDepthType.TWENTYFOUR;
    pnl.bmpDepth.find("32")._value = BMPDepthType.THIRTYTWO;

    x = xofs;
    y += 30;
    pnl.bmpRLECompression = pnl.add('checkbox', [x,y,x+145,y+22],
                                    "RLE Compression");

    pnl.bmp = ["bmpAlphaChannels", "bmpDepthLabel", "bmpDepth",
               "bmpRLECompression"];

    pnl.bmpAlphaChannels.value = toBoolean(opts.bmpAlphaChannels);
    var it = pnl.bmpDepth.find(opts.bmpDepth.toString());
    if (it) {
      pnl.bmpDepth.selection = it;
    }
    pnl.bmpRLECompression.value = toBoolean(opts.bmpRLECompression);

    y = yofs;
    x = xofs;
  }


  //=============================== GIF ===============================
  if (FileSaveOptionsTypes["gif"]) {
    pnl.gifTransparency = pnl.add('checkbox', [x,y,x+125,y+22],
                                  "Transparency");

    x += 125;
    pnl.gifInterlaced = pnl.add('checkbox', [x,y,x+125,y+22],
                                "Interlaced");

    x += 125;
    pnl.gifColorsLabel = pnl.add('statictext', [x,y+tOfs,x+55,y+22+tOfs],
                                  'Colors:');

    x += 60;
    pnl.gifColors = pnl.add('edittext', [x,y,x+55,y+22], "256");
    pnl.gifColors.onChanging = GenericUI.numericKeystrokeFilter;
    pnl.gifColors.onChange = function() {
      var pnl = this.parent;
      var n = toNumber(pnl.gifColors.text || 256);
      if (n < 2)   { n = 2; }
      if (n > 256) { n = 256; }
      pnl.gifColors.text = n;
    }

    pnl.gif = ["gifTransparency", "gifInterlaced", "gifColors", "gifColorsLabel",
               "saveForWeb"];

    pnl.gifTransparency.value = toBoolean(opts.gifTransparency);
    pnl.gifInterlaced.value = toBoolean(opts.gifInterlaced);
    pnl.gifColors.text = toNumber(opts.gifColors || 256);

    pnl.saveForWeb.value = toBoolean(opts.saveForWeb);
    y = yofs;
    x = xofs;
  }


  //=============================== JPG ===============================
  if (FileSaveOptionsTypes["jpg"]) {
    pnl.jpgQualityLabel = pnl.add('statictext', [x,y+tOfs,x+55,y+22+tOfs],
                                  'Quality:');
    x += 60;
    var jpqQualityMenu = ["1","2","3","4","5","6","7","8","9","10","11","12"];
    pnl.jpgQuality = pnl.add('dropdownlist', [x,y,x+55,y+22], jpqQualityMenu);
    pnl.jpgQuality.selection = pnl.jpgQuality.find("10");

    y += 30;
    x = xofs;
    pnl.jpgEmbedColorProfile = pnl.add('checkbox', [x,y,x+155,y+22],
                                       "Embed Color Profile");

    y = yofs;
    x += 150;

    var jpgFormatMenu = ["Standard", "Progressive", "Optimized"];
    pnl.jpgFormatLabel = pnl.add('statictext', [x,y+tOfs,x+50,y+22+tOfs],
                                 'Format:');
    x += 55;
    pnl.jpgFormat = pnl.add('dropdownlist', [x,y,x+110,y+22], jpgFormatMenu);
    pnl.jpgFormat.selection = pnl.jpgFormat.find("Standard");

    pnl.jpgFormat.find("Standard")._value = FormatOptions.STANDARDBASELINE;
    pnl.jpgFormat.find("Progressive")._value = FormatOptions.PROGRESSIVE;
    pnl.jpgFormat.find("Optimized")._value = FormatOptions.OPTIMIZEDBASELINE;

    y += 30;
    x = xofs + 150;
    pnl.jpgConvertToSRGB = pnl.add('checkbox', [x,y,x+145,y+22],
                                   "Convert to sRGB");

    pnl.jpg = ["jpgQualityLabel", "jpgQuality", "jpgEmbedColorProfile",
               "jpgFormatLabel", "jpgFormat", "jpgConvertToSRGB", "saveForWeb" ];

    var it = pnl.jpgQuality.find(opts.jpgQuality.toString());
    if (it) {
      pnl.jpgQuality.selection = it;
    }
    pnl.jpgEmbedColorProfile.value = toBoolean(opts.jpgEmbedColorProfile);
    var it = pnl.jpgFormat.find(opts.jpgFormat);
    if (it) {
      pnl.jpgFormat.selection = it;
    }
    pnl.jpgConvertToSRGB.value = toBoolean(opts.jpgConvertToSRGB);

    pnl.saveForWeb.value = toBoolean(opts.saveForWeb);

    x = xofs;
    y = yofs;
  }


  //=============================== PSD ===============================
  if (FileSaveOptionsTypes["psd"]) {
    pnl.psdAlphaChannels = pnl.add('checkbox', [x,y,x+125,y+22],
                                   "Alpha Channels");

    y += 30;
    pnl.psdEmbedColorProfile = pnl.add('checkbox', [x,y,x+155,y+22],
                                       "Embed Color Profile");

    y = yofs;
    x = xofs + 150;

    pnl.psdLayers = pnl.add('checkbox', [x,y,x+125,y+22],
                          "Layers");

    y += 30;
    pnl.psdMaximizeCompatibility = pnl.add('checkbox', [x,y,x+175,y+22],
                                           "Maximize Compatibility");

    pnl.psd = ["psdAlphaChannels", "psdEmbedColorProfile",
               "psdLayers", "psdMaximizeCompatibility"];

    pnl.psdAlphaChannels.value = toBoolean(opts.psdAlphaChannels);
    pnl.psdEmbedColorProfile.value = toBoolean(opts.psdEmbedColorProfile);
    pnl.psdLayers.value = toBoolean(opts.psdLayers);
    pnl.psdMaximizeCompatibility.value =
       toBoolean(opts.psdMaximizeCompatibility);

    x = xofs;
    y = yofs;
  }

  //=============================== EPS ===============================
  if (FileSaveOptionsTypes["eps"]) {
    var epsEncodingMenu = ["ASCII", "Binary", "JPEG High", "JPEG Med",
                           "JPEG Low", "JPEG Max"];
    pnl.epsEncodingLabel = pnl.add('statictext', [x,y+tOfs,x+60,y+22+tOfs],
                                 'Encoding:');
    x += 65;
    pnl.epsEncoding = pnl.add('dropdownlist',
                              [x,y,x+100,y+22],
                              epsEncodingMenu);
    pnl.epsEncoding.selection = pnl.epsEncoding.find("Binary");

    pnl.epsEncoding.find("ASCII")._value = SaveEncoding.ASCII;
    pnl.epsEncoding.find("Binary")._value = SaveEncoding.BINARY;
    pnl.epsEncoding.find("JPEG High")._value = SaveEncoding.JPEGHIGH;
    pnl.epsEncoding.find("JPEG Low")._value = SaveEncoding.JPEGLOW;
    pnl.epsEncoding.find("JPEG Max")._value = SaveEncoding.JPEGMAXIMUM;
    pnl.epsEncoding.find("JPEG Med")._value = SaveEncoding.JPEGMEDIUM;

    x = xofs;
    y += 30;
    pnl.epsEmbedColorProfile = pnl.add('checkbox', [x,y,x+155,y+22],
                                       "Embed Color Profile");

    pnl.eps = ["epsEncodingLabel", "epsEncoding", "epsEmbedColorProfile"];

    var it = pnl.epsEncoding.find(opts.epsEncoding);
    if (it) {
      pnl.epsEncoding.selection = it;
    }
    pnl.epsEmbedColorProfile.value = toBoolean(opts.epsEmbedColorProfile);

    x = xofs;
    y = yofs;
  }


  //=============================== PDF ===============================
  if (FileSaveOptionsTypes["pdf"]) {
    pnl.pdf = ["pdfEmbedColorProfile"];

    x = xofs;
    y = yofs;

    x = xofs;
    y += 30;
    pnl.pdfEmbedColorProfile = pnl.add('checkbox', [x,y,x+155,y+22],
                                       "Embed Color Profile");
    pnl.pdfEmbedColorProfile.value = toBoolean(opts.pdfEmbedColorProfile);

    x = xofs;
    y = yofs;
  }


  //=============================== PNG ===============================
  if (FileSaveOptionsTypes["png"]) {
    pnl.pngInterlaced = pnl.add('checkbox', [x,y,x+125,y+22],
                                "Interlaced");

    pnl.png = ["pngInterlaced", "saveForWeb"];

    pnl.pngInterlaced.value = toBoolean(opts.pngInterlaced);

    pnl.saveForWeb.value = toBoolean(opts.saveForWeb);

    x = xofs;
    y = yofs;
  }


  //=============================== TGA ===============================
  if (FileSaveOptionsTypes["tga"]) {
    pnl.tgaAlphaChannels = pnl.add('checkbox', [x,y,x+125,y+22],
                                   "Alpha Channels");

    y += 30;

    pnl.tgaRLECompression = pnl.add('checkbox', [x,y,x+145,y+22],
                                    "RLE Compression");

    pnl.tga = ["tgaAlphaChannels", "tgaRLECompression"];

    pnl.tgaAlphaChannels.value = toBoolean(opts.tgaAlphaChannels);
    pnl.tgaRLECompression.value = toBoolean(opts.tgaRLECompression);

    x = xofs;
    y = yofs;
  }


  //=============================== TIFF ===============================
  if (FileSaveOptionsTypes["tif"]) {
    var tiffEncodingMenu = ["None", "LZW", "ZIP", "JPEG"];
    pnl.tiffEncodingLabel = pnl.add('statictext', [x,y+tOfs,x+60,y+22+tOfs],
                                    'Encoding:');
    x += 65;
    pnl.tiffEncoding = pnl.add('dropdownlist', [x,y,x+75,y+22],
                               tiffEncodingMenu);
    pnl.tiffEncoding.selection = pnl.tiffEncoding.find("None");

    pnl.tiffEncoding.find("None")._value = TIFFEncoding.NONE;
    pnl.tiffEncoding.find("LZW")._value = TIFFEncoding.TIFFLZW;
    pnl.tiffEncoding.find("ZIP")._value = TIFFEncoding.TIFFZIP;
    pnl.tiffEncoding.find("JPEG")._value = TIFFEncoding.JPEG;

    x += 90;

    var tiffByteOrderMenu = ["IBM", "MacOS"];
    pnl.tiffByteOrderLabel = pnl.add('statictext', [x,y+tOfs,x+65,y+22+tOfs],
                                     'ByteOrder:');
    x += 70;
    pnl.tiffByteOrder = pnl.add('dropdownlist', [x,y,x+85,y+22],
                                tiffByteOrderMenu);
    var bo = (isWindows() ? "IBM" : "MacOS");
    pnl.tiffByteOrder.selection = pnl.tiffByteOrder.find(bo);

    pnl.tiffByteOrder.find("IBM")._value = ByteOrder.IBM;
    pnl.tiffByteOrder.find("MacOS")._value = ByteOrder.MACOS;

    x = xofs;
    y += 30;
    pnl.tiffEmbedColorProfile = pnl.add('checkbox', [x,y,x+155,y+22],
                                        "Embed Color Profile");

    pnl.tif = ["tiffEncodingLabel", "tiffEncoding", "tiffByteOrderLabel",
               "tiffByteOrder", "tiffEmbedColorProfile"];

    pnl.dng = [];

    var it = pnl.tiffEncoding.find(opts.tiffEncoding);
    if (it) {
      pnl.tiffEncoding.selection = it;
    }
    var it = pnl.tiffByteOrder.find(opts.tiffByteOrder);
    if (it) {
      pnl.tiffByteOrder.selection = it;
    }
    pnl.tiffEmbedColorProfile.value = toBoolean(opts.tiffEmbedColorProfile);
  }

  pnl.fileType.onChange = function() {
    var pnl = this.parent;
    var ftsel = pnl.fileType.selection.index;
    var ft = FileSaveOptionsTypes[ftsel];

    for (var i = 0; i < FileSaveOptionsTypes.length; i++) {
      var fsType = FileSaveOptionsTypes[i];
      var parts = pnl[fsType.fileType];

      for (var j = 0; j < parts.length; j++) {
        var part = parts[j];
        pnl[part].visible = (fsType == ft);
      }
    }

    var fsType = ft.fileType;
    pnl.saveForWeb.visible = (pnl[fsType].contains("saveForWeb"));
    pnl._onChange();
  };

  pnl._onChange = function() {
    var self = this;
    if (self.onChange) {
      self.onChange();
    }
  };

  if (false) {
    y = yofs;
    x = 300;
    var btn = pnl.add('button', [x,y,x+50,y+22], "Test");
    btn.onClick = function() {
      try {
        var pnl = this.parent;
        var mgr = pnl.mgr;

        var opts = {};
        mgr.validateFileSavePanel(pnl, opts);
        alert(listProps(opts));
        alert(listProps(FileSaveOptions.convert(opts)));

      } catch (e) {
        var msg = Stdlib.exceptionMessage(e);
        Stdlib.log(msg);
        alert(msg);
      }
    };
  }

  if (!isCS() && !isCS2()) {
    pnl.fileType.onChange();
  }

  pnl.getFileSaveType = function() {
    var pnl = this;
    var fstype = '';
    if (pnl.fileType.selection) {
      var fsSel = pnl.fileType.selection.index;
      var fs = FileSaveOptionsTypes[fsSel];
      fstype = fs.fileType;
    }
    return fstype;
  };

  pnl.updateSettings = function(ini) {
    var pnl = this;

    function _select(m, s, def) {
      var it = m.find(s.toString());
      if (!it && def != undefined) {
        it = m.items[def];
      }
      if (it) {
        m.selection = it;
      }
    }

    var opts = new FileSaveOptions(ini);
    var ftype = opts.fileType || opts.fileSaveType || "jpg";

    var ft = Stdlib.getByProperty(FileSaveOptionsTypes,
                                  "fileType",
                                  ftype);
    pnl.fileType.selection = pnl.fileType.find(ft.menu);

    if (FileSaveOptionsTypes["bmp"]) {
      pnl.bmpAlphaChannels.value = toBoolean(opts.bmpAlphaChannels);
      _select(pnl.bmpDepth, opts.bmpDepth.toString(), 0);
      pnl.bmpRLECompression.value = toBoolean(opts.bmpRLECompression);
    }

    if (FileSaveOptionsTypes["gif"]) {
      pnl.gifTransparency.value = toBoolean(opts.gifTransparency);
      pnl.gifInterlaced.value = toBoolean(opts.gifInterlaced);
      pnl.gifColors.text = toNumber(opts.gifColors || 256);
      pnl.saveForWeb.value = toBoolean(opts.saveForWeb);
    }

    if (FileSaveOptionsTypes["jpg"]) {
      _select(pnl.jpgQuality, opts.jpgQuality.toString(), 0);
      pnl.jpgEmbedColorProfile.value = toBoolean(opts.jpgEmbedColorProfile);
      _select(pnl.jpgFormat, opts.jpgFormat, 0);
      pnl.jpgConvertToSRGB.value = toBoolean(opts.jpgConvertToSRGB);
      pnl.saveForWeb.value = toBoolean(opts.saveForWeb);
    }

    if (FileSaveOptionsTypes["psd"]) {
      pnl.psdAlphaChannels.value = toBoolean(opts.psdAlphaChannels);
      pnl.psdEmbedColorProfile.value = toBoolean(opts.psdEmbedColorProfile);
      pnl.psdLayers.value = toBoolean(opts.psdLayers);
      pnl.psdMaximizeCompatibility.value =
      toBoolean(opts.psdMaximizeCompatibility);
    }
    
    if (FileSaveOptionsTypes["eps"]) {
      _select(pnl.epsEncoding, opts.epsEncoding, 0);
      pnl.epsEmbedColorProfile.value = toBoolean(opts.epsEmbedColorProfile);
    }
    
    if (FileSaveOptionsTypes["pdf"]) {
      pnl.pdfEmbedColorProfile.value = toBoolean(opts.pdfEmbedColorProfile);
    }
    
    if (FileSaveOptionsTypes["png"]) {
      pnl.pngInterlaced.value = toBoolean(opts.pngInterlaced);
      pnl.saveForWeb.value = toBoolean(opts.saveForWeb);
    }
    
    if (FileSaveOptionsTypes["tga"]) {
      pnl.tgaAlphaChannels.value = toBoolean(opts.tgaAlphaChannels);
      pnl.tgaRLECompression.value = toBoolean(opts.tgaRLECompression);
    }
    
    if (FileSaveOptionsTypes["tif"]) {
      _select(pnl.tiffEncoding, opts.tiffEncoding, 0);
      _select(pnl.tiffByteOrder, opts.tiffByteOrder, 0);
      pnl.tiffEmbedColorProfile.value = toBoolean(opts.tiffEmbedColorProfile);
    }
    pnl.fileType.onChange();
  }

  return pnl;
};
GenericUI.prototype.validateFileSavePanel = function(pnl, opts) {
  var win = GenericUI.getWindow(pnl);

  // XXX This function needs to remove any prior file save
  // options and only set the ones needed for the
  // selected file type

  var fsOpts = new FileSaveOptions();
  for (var idx in fsOpts) {
    if (idx in opts) {
      delete opts[idx];
    }
  }

  var fsSel = pnl.fileType.selection.index;
  var fs = FileSaveOptionsTypes[fsSel];

  opts.fileSaveType = fs.fileType;
  opts._saveDocumentType = fs.saveType;

  if (!fs.optionsType) {
    opts._saveOpts = undefined;
    return;
  }

  var saveOpts = new fs.optionsType();

  switch (fs.fileType) {
    case "bmp": {
      saveOpts.rleCompression = pnl.bmpRLECompression.value;
      saveOpts.depth = pnl.bmpDepth.selection._value;
      saveOpts.alphaChannels = pnl.bmpAlphaChannels.value;

      opts.bmpRLECompression = pnl.bmpRLECompression.value;
      opts.bmpDepth = Number(pnl.bmpDepth.selection.text);
      opts.bmpAlphaChannels = pnl.bmpAlphaChannels.value;
      break;
    }
    case "gif": {
      saveOpts.transparency = pnl.gifTransparency.value;
      saveOpts.interlaced = pnl.gifInterlaced.value;
      var colors = toNumber(pnl.gifColors.text || 256);
      if (colors < 2)   { colors = 2; }
      if (colors > 256) { colors = 256; }
      saveOpts.colors = colors; 
      saveOpts._saveForWeb = pnl.saveForWeb.value;

      opts.gifTransparency = pnl.gifTransparency.value;
      opts.gifInterlaced = pnl.gifInterlaced.value;
      opts.gifColors = colors;
      opts.saveForWeb = pnl.saveForWeb.value;
      break;
    }
    case "jpg": {
      saveOpts.quality = Number(pnl.jpgQuality.selection.text);
      saveOpts.embedColorProfile = pnl.jpgEmbedColorProfile.value;
      saveOpts.formatOptions = pnl.jpgFormat.selection._value;
      saveOpts._convertToSRGB = pnl.jpgConvertToSRGB.value;
      saveOpts._saveForWeb = pnl.saveForWeb.value;

      opts.jpgQuality = Number(pnl.jpgQuality.selection.text);
      opts.jpgEmbedColorProfile = pnl.jpgEmbedColorProfile.value;
      opts.jpgFormat = pnl.jpgFormat.selection.text;
      opts.jpgConvertToSRGB = pnl.jpgConvertToSRGB.value;
      opts.saveForWeb = pnl.saveForWeb.value;
      break;
    }
    case "psd": {
      saveOpts.alphaChannels = pnl.psdAlphaChannels.value;
      saveOpts.embedColorProfile = pnl.psdEmbedColorProfile.value;
      saveOpts.layers = pnl.psdLayers.value;
      saveOpts.maximizeCompatibility = pnl.psdMaximizeCompatibility.value;

      opts.psdAlphaChannels = pnl.psdAlphaChannels.value;
      opts.psdEmbedColorProfile = pnl.psdEmbedColorProfile.value;
      opts.psdLayers = pnl.psdLayers.value;
      opts.psdMaximizeCompatibility = pnl.psdMaximizeCompatibility.value;
      break;
    }
    case "eps": {
      saveOpts.encoding = pnl.epsEncoding.selection._value;
      saveOpts.embedColorProfile = pnl.epsEmbedColorProfile.value;

      opts.epsEncoding = pnl.epsEncoding.selection.text;
      opts.epsEmbedColorProfile = pnl.epsEmbedColorProfile.value;
      break;
    }
    case "pdf": {
      saveOpts.embedColorProfile = pnl.pdfEmbedColorProfile.value;

      opts.pdfEmbedColorProfile = pnl.pdfEmbedColorProfile.value;
      break;
    }
    case "png": {
      saveOpts.interlaced = pnl.pngInterlaced.value;
      saveOpts._saveForWeb = pnl.saveForWeb.value;

      opts.pngInterlaced = pnl.pngInterlaced.value;
      opts.saveForWeb = pnl.saveForWeb.value;
      break;
    }
    case "tga": {
      saveOpts.alphaChannels = pnl.tgaAlphaChannels.value;
      saveOpts.rleCompression = pnl.tgaRLECompression.value;

      opts.tgaAlphaChannels = pnl.tgaAlphaChannels.value;
      opts.tgaRLECompression = pnl.tgaRLECompression.value;
      break;
    }
    case "tif": {
      saveOpts.byteOrder = pnl.tiffByteOrder.selection._value;
      saveOpts.imageCompression = pnl.tiffEncoding.selection._value;
      saveOpts.embedColorProfile = pnl.tiffEmbedColorProfile.value;

      opts.tiffByteOrder = pnl.tiffByteOrder.selection.text;
      opts.tiffEncoding = pnl.tiffEncoding.selection.text;
      opts.tiffEmbedColorProfile = pnl.tiffEmbedColorProfile.value;
      break;
    }
    default:
      Error.runtimeError(9001, "Internal Error: Unknown file type: " +
                         fs.fileType);
  }

  opts._saveOpts = saveOpts;

  return;
};


//================================== exec ==================================
//
// exec runs the ui and the application callback
//   doc is the document to operate on (optional)
//   if noUI is true, the window is not open. The runtime parameters
//      are taken from the ini file.
//
GenericUI.prototype.runUI = function(ovOpts, doc) {
  var self = this;

  // read the ini file (if present)
  var ini = {};

  if (self.iniFile) {
    ini = self.readIniFile();
  }

  // copyFromTo
  if (ovOpts) {
    for (var idx in ovOpts) {
      var v = ovOpts[idx];
      if (typeof v != 'function') {
        ini[idx] = v;
      }
    }
  }

  var opts = undefined;
  var win = undefined;

  if (toBoolean(ini.noUI)) {
    // if we don't want a UI, just use the ini object
    opts = ini;

  } else {
    // create window
    win = self.createWindow(ini, doc);

    self.win = win;

    // run the window and return the parameters mapped from the window
    opts = self.run(win);

    if (win.iniContents) {
      self.iniContents = win.iniContents;
    }
  }

  return opts;
};


GenericUI.prototype.exec = function(arg1, arg2) {
  var self = this;

  var ovOpts = undefined;
  var doc = undefined;

  // either or both a document and options may be specified or neither
  if (arg1 || arg2) {
    if (!arg1) {  // if only arg2 is set, swap the args
      arg1 = arg2;
      arg2 = undefined;
    }

    ovOpts = arg1; // assume that arg1 is the options

    var dbgLevel = $.level;
    $.level = 0;
    try {
      if (arg1.typename == "Document") {
        doc = arg1;
        ovOpts = arg2;
      } else if (arg2 && arg2.typename == "Document") {
        doc = arg2;
      }
    } catch (e) {
    }
    $.level = dbgLevel;
  }

  var opts = self.runUI(ovOpts, doc);

  return self.runProcess(opts, doc);
};

GenericUI.prototype.runProcess = function(opts, doc) {
  var self = this;
  var result = undefined;

  // if we got options back, we can do some processing
  if (opts) {
    if (self.saveIni) {
      self.writeIniFile(opts);
    }

    result = self.process(opts, doc);

  } else if (self.win && self.win.canceled) { // if not, we just cancel out...
    self.cancel(doc);
  }

  return result;
};


//
// the run method 'show's the window. If it ran successfully, the options
// returned are written to an ini file (if one has been specified
//
GenericUI.prototype.run = function(win) {
  var self = this;
  var done = false;

  if (win.show) {
    while (!done) {
      if (self.center == true) {
        win.center(self.parentWin);
      }
      var x = win.show();

      self.winX = win.bounds.x;
      self.winY = win.bounds.y;

      if (x == 0 || x == 2) {  // the window was closed or canceled
        win.canceled = true;   // treat it like a 'cancel'
        win.opts = undefined;
        done = true;
      } else if (x == 1) {
        done = true;
      } else if (x == 4) {     // reset window
        win = self.createWindow(win.ini, win.doc);
      }
      self.runCode = x;
    }
  }

  return win.opts;
};
GenericUI.prototype._checkIniArgs = function(arg1, arg2, xmlMode) {
  var self = this;
  var obj = {
    file: undefined,
    opts: undefined,
    xml: (xmlMode == undefined) ? self.xmlEnabled : xmlMode
  };

  if (arg1) {
    if (!obj.file && ((arg1 instanceof File) ||
                      (arg1.constructor == String))) {
      obj.file = GenericUI.iniFileToFile(arg1);

    } else {
      obj.opts = arg1;
    }
  }

  if (arg2) {
    if (!obj.file && ((arg2 instanceof File) ||
                      (arg2.constructor == String))) {
      obj.file = GenericUI.iniFileToFile(arg2);

    } else if (!obj.opts) {
      obj.opts = arg2;
    }
  }

  return obj;
};
GenericUI.prototype.updateIniFile = function(arg1, arg2, xmlMode) {
  var self = this;
  var args = self._checkIniArgs(arg1, arg2, xmlMode);
  var file = args.file || self.iniFile;
  var opts = args.opts;
  var xml = args.xml;

  if (!file) {
    Error.runtimeError(9001, "Internal Error: No valid settings file specified for update");
  }

  GenericUI.updateIni(file, opts, xml);
};
GenericUI.prototype.writeIniFile = function(arg1, arg2, xmlMode) {
  var self = this;
  var args = self._checkIniArgs(arg1, arg2, xmlMode);
  var file = args.file || self.iniFile;
  var opts = args.opts;
  var xml = args.xml;

  if (!file) {
    Error.runtimeError(9001, "Internal Error: No valid settings " +
                       "file specified for write");
  }
  GenericUI.writeIni(file, opts, xml);
};
GenericUI.prototype.readIniFile = function(arg1, arg2, xmlMode) {
  var self = this;
  var args = self._checkIniArgs(arg1, arg2, xmlMode);
  var file = args.file || self.iniFile;
  var opts = args.opts;
  var xml = args.xml;

  if (!file) {
    Error.runtimeError(9001, "Internal Error: No valid settings " +
                       "file specified for read");
  }

  var ini = GenericUI.readIni(file, opts, xml);
  file = new File(file);
  if (file.open("r", "TEXT", "????")) {
    file.lineFeed = "unix";
    file.encoding = GenericUI.ENCODING;
    self.iniContents = file.read();
    file.close();
  }
  return ini;
};

//
// errorPrompt is used in window/panel validation. It pops up a 'confirm'
// with the prompt 'str'. If the user selects 'Yes', the 'confirm' is closed
// and the user is returned to the window for further interaction. If the user
// selects 'No', the 'confirm' is closed, the window is closed, and the script
// terminates.
//
GenericUI.prototype.errorPrompt = function(str) {
  return GenericUI.errorPrompt(str);
};
GenericUI.errorPrompt = function(str) {
  return confirm(str + "\r\rDo you wish to continue?");
//                  false, "Input Validation Error");
};

//
// 'validate' is called by the win.process.onClick method to validate the
// contents of the window. To validate the window, we call the application
// defined 'validatePanel' method. 'validate' returns 'true', 'false', or
// an options object with the values collected from the application panel.
// If 'true' is returned, this means that there was a problem with validation
// but the user wants to continue. If 'false' is returned, there was a problem
// with validation and the user wants to stop. If an object is returned, the
// window is closed and processing continues based on the options values
//
GenericUI.validate = function() {
  var win = this;
  var mgr = win.mgr;

  mgr.winX = win.bounds.x;
  mgr.winY = win.bounds.y;

  try {
    var res = mgr.validatePanel(win.appPnl, win.ini);

    if (typeof(res) == 'boolean') {
      return res;
    }
    win.opts = res;
    if (!mgr.isPalette()) {
      win.close(1);
    }
    return true;

  } catch (e) {
    var msg = Stdlib.exceptionMessage(e);
    Stdlib.log(msg);
    alert(msg);
    return false;
  }
};

//
// Convert a fptr to a valid ini File object.
// If the arg is already a File, make sure it has a valid path
// If the arg is a string and
//    begins with / or ~ or contains a :, then it is a complete path
//       so return it as a File object
//
//
GenericUI.iniFileToFile = function(iniFile) {
  if (!iniFile) {
    return undefined;
  }

  if (iniFile instanceof File) {
    if (!iniFile.parent.exists) {
      Stdlib.createFolder(iniFile.parent);
    }
    return iniFile;
  }

  if (iniFile.constructor == String) {
    var c = iniFile.charAt(0);

    // This is not a partial/relative path
    if (c == '/' || c == '~' || iniFile.charAt(1) == ':') {
      iniFile = new File(iniFile);

    } else {
      var prefs = GenericUI.preferencesFolder;

      // if the path starts with 'xtools/' strip it off
      var sub = "xtools/";
      if (iniFile.startsWith(sub)) {
        iniFile = iniFile.substr(sub.length);
      }

      // and place the ini file in the prefs folder
      iniFile = new File(prefs + '/' + iniFile);
    }

    // make sure any intermediate paths have been created
    if (!iniFile.parent.exists) {
      Stdlib.createFolder(iniFile.parent);
    }

    return iniFile;
  }

  return undefined;
};

GenericUI.iniFromString = function(str, ini) {
  var lines = str.split(/\r|\n/);
  var rexp = new RegExp(/([^:]+):(.*)$/);

  if (!ini) {
    ini = {};
  }

  for (var i = 0; i < lines.length; i++) {
    var line = lines[i].trim();
    if (!line || line.charAt(0) == '#') {
      continue;
    }
    var ar = rexp.exec(line);
    if (!ar) {
      alert("Bad line in config: \"" + line + "\"");
      continue;
      //return undefined;
    }
    ini[ar[1].trim()] = ar[2].trim();
  }

  return ini;
};

//
// readIni
// writeIni
//   Methods for reading and writing ini files in this framework. This only
//   occurs if an ini file has been specified
//
//   These can be replaced with other storage mechanisms such as Rob Stucky's
//   ScriptStore class.
//
GenericUI.readIni = function(iniFile, ini) {
  //$.level = 1; debugger;

  if (!ini) {
    ini = {};
  }
  if (!iniFile) {
    return ini;
  }
  var file = GenericUI.iniFileToFile(iniFile);

  if (!file) {
    Error.runtimeError(9001, Error("Bad ini file specified: \"" + iniFile + "\"."));
  }

  if (!file.exists) {
    //
    // XXX Check for an ini path .ini file in the script's folder.
    //
  }

  if (file.exists && file.open("r", "TEXT", "????")) {
    file.lineFeed = "unix";
    file.encoding = GenericUI.ENCODING;
    var str = file.read();
    ini = GenericUI.iniFromString(str, ini);
    file.close();
  }

  if (ini.noUI) {
    ini.noUI = toBoolean(ini.noUI);
  }

  return ini;
};
GenericUI.iniToString = function(ini) {
  var str = '';
  for (var idx in ini) {
    if (idx.charAt(0) == '_') {         // private stuff
      continue;
    }
    if (idx == 'typename') {
      continue;
    }
    if (idx == "noUI") {                // GenericUI property
      continue;
    }
    var val = ini[idx];

    if (val == undefined) {
      continue;
    }

    if (val.constructor == String ||
        val.constructor == Number ||
        val.constructor == Boolean ||
        typeof(val) == "object") {
      str += (idx + ": " + val.toString() + "\n");
    }
  }
  return str;
};
GenericUI.overwriteIni = function(iniFile, ini) {
  //$.level = 1; debugger;
  if (!ini || !iniFile) {
    return;
  }
  var file = GenericUI.iniFileToFile(iniFile);

  if (!file) {
    Error.runtimeError(9001, Error("Bad ini file specified: \"" + iniFile + "\"."));
  }

  if (file.open("w", "TEXT", "????")) {
    file.lineFeed = "unix";
    file.encoding = GenericUI.ENCODING;
    var str = GenericUI.iniToString(ini);
    file.write(str);
    file.close();
  }
  return ini;
};

GenericUI.iniToDescriptor = function(ini, desc) {
  if (!desc) {
    desc = new ActionDescriptor();
  }
  var str = GenericUI.iniToString(ini);
  desc.putString(sTID("INI Data"), str);
  return desc;
};
GenericUI.iniFromDescriptor = function(desc) {
  var ini = {};
  if (!desc || desc.count == 0) {
    return ini;
  }
  if (desc.hasString(sTID("INI Data"))) {
    var str = desc.getString(sTID("INI Data"));
    ini = GenericUI.iniFromString(str);
  }
  return ini;
};

//
// Updating the ini file retains the ini file layout including any externally
// add comments, blank lines, and the property sequence
//
GenericUI.updateIni = function(iniFile, ini) {
  if (!ini || !iniFile) {
    return undefined;
  }
  var file = GenericUI.iniFileToFile(iniFile);

  // we can only update the file if it exists
  var update = file.exists;
  var str = '';

  if (update) {
    file.open("r", "TEXT", "????");
    file.encoding = GenericUI.ENCODING;
    file.lineFeed = "unix";
    str = file.read();
    file.close();

    for (var idx in ini) {
      if (idx.charAt(0) == '_') {         // private stuff
        continue;
      }
      if (idx == "noUI") {
        continue;
      }
      if (idx == "typename") {
        continue;
      }

      var val = ini[idx];

      if (typeof(val) == "undefined") {
        val = '';
      }

      if (typeof val == "string" ||
          typeof val == "number" ||
          typeof val == "boolean" ||
          typeof val == "object") {
        idx += ':';
        var re = RegExp('^' + idx, 'm');

        if (re.test(str)) {
          re = RegExp('^' + idx + '[^\n]*', 'm');
          str = str.replace(re, idx + ' ' + val);
        } else {
          str += '\n' + idx + ' ' + val;
        }
      }
    }
  } else {
    // write out a new ini file
    for (var idx in ini) {
      if (idx.charAt(0) == '_') {         // private stuff
        continue;
      }
      if (idx == "noUI") {
        continue;
      }
      var val = ini[idx];

      if (typeof val == "string" ||
          typeof val == "number" ||
          typeof val == "boolean" ||
          typeof val == "object") {
        str += (idx + ": " + val.toString() + "\n");
      }
    }
  }

  if (str) {
    file.open("w", "TEXT", "????");
    file.encoding = GenericUI.ENCODING;
    file.lineFeed = "unix";
    file.write(str);
    file.close();
  }

  return ini;
};

GenericUI.writeIni = GenericUI.updateIni;

//XXX this widget stuff is untested
GenericUI._widgetMap = {
  button: 'text',
  checkbox: 'value',
  dropdownlist: 'selection',
  edittext: 'text',
  iconbutton: 'icon',
  image: 'icon',
  listbox: 'selection',
  panel: 'text',
  progressbar: 'value',
  radiobutton: 'value',
  scrollbar: 'value',
  slider:  'value',
  statictext: 'text',
};
//
// These next two need to be tweaked for dropdownlist and listbox
// I'm not sure quite yet what the best interface should be, so I'll
// pass for now.
//
GenericUI.getWidgetValue = function(w) {
  var prop = GenericUI._widgetMap[w.type];
  var t = w.type;
  var v = undefined;
  if (prop) {
    if (t == 'listbox' || t == 'dropdownlist') {
      v = w.selection.text;
    } else {
      v = w[prop];
    }
  }
  return prop ? w[prop] : undefined;
};
GenericUI.setWidgetValue = function(w, v) {
  var prop = GenericUI._widgetMap[w.type];
  if (prop) {
    var t = w.type;
    if (t == 'checkbox' || t == 'radiobox') {
      w[prop] = v.toString().toLowerCase() == 'true';
    } else if (t == 'progressbar' || t == 'scrollbar' || t == 'slider') {
      var n = Number(v);
      if (!isNaN(n)) {
        w[prop] = n;
      }
    } else if (t == 'listbox' || t == 'dropdownlist') {
      var it = w.find(v);
      if (it) {
        w.selection = it;
        it.selected = true;
      }
    } else {
      w[prop] = v;
    }
  }
  return v;
};

//
// createPanel returns a panel specific to this app
//    win is the window into which the panel to be inserted
//    ini is an object containing default values for the panel
//
GenericUI.prototype.createPanel = function(pnl, ini, doc) {};

//
// validatePanel returns
//    - an object representing the gather input
//    - true if there was an error, but continue gathering input
//    - false if there was an error and terminate
//
GenericUI.prototype.validatePanel = function(pnl, ini) {};

//
// Called by the framework to do whatever processing the script is
// supposed to perform.
//
GenericUI.prototype.process = function(opts, doc) {};

//
// Called by the framework if the user 'canceled' the UI
//
GenericUI.prototype.cancel = function(doc) {};

GenericUI.numberKeystrokeFilter = function() {
  if (this.text.match(/[^\-\.\d]/)) {
    this.text = this.text.replace(/[^\-\.\d]/g, '');
  }
};
GenericUI.numericKeystrokeFilter = function() {
  if (this.text.match(/[^\d]/)) {
    this.text = this.text.replace(/[^\d]/g, '');
  }
};

GenericUI.unitValueKeystrokeFilter = function() {
  if (this.text.match(/[^a-z0-9% \.]/)) {
    this.text = this.text.toLowerCase().replace(/[^a-z0-9% \.]/g, '');
  }
};

GenericUI.rexKeystrokeFilter = function(w, rex) {
  // XXX fix this
  w._rex = rex;
  w._rexG = new RegExp(rex.toString(), 'g');
  w._rexFilter = function() {
    if (this.text.match(this._rex)) {
      this.text = this.text.toLowerCase().replace(this._regG, '');
    }
  };
};

GenericUI.setMenuSelection = function(menu, txt, def) {
  var it = menu.find(txt);
  if (!it) {
    if (def != undefined) {
      var n = toNumber(def);
      if (!isNaN(n)) {
        it = def;

      } else {
        it = menu.find(def);
      }
    }
  }

  if (it != undefined) {
    menu.selection = it;
  }
};

//
// createProgressPalette
//   title     the window title
//   min       the minimum value for the progress bar
//   max       the maximum value for the progress bar
//   parent    the parent ScriptUI window (opt)
//   useCancel flag for having a Cancel button (opt)
//   msg       a message that can be displayed (and changed) in the palette (opt)
//
//   onCancel  This method will be called when the Cancel button is pressed.
//             This method should return 'true' to close the progress window
//
GenericUI.createProgressPalette = function(title, min, max,
                                           parent, useCancel, msg) {
  var win = new Window('palette', title);
  win.bar = win.add('progressbar', undefined, min, max);
  if (msg) {
    win.msg = win.add('statictext');
    win.msg.text = msg;
  }
  win.bar.preferredSize = [500, 20];

  win.parentWin = undefined;
  win.recenter = false;
  win.isDone = false;

  if (parent) {
    if (parent instanceof Window) {
      win.parentWin = parent;
    } else if (useCancel == undefined) {
      useCancel = !!parent;
    }
  }

  if (useCancel) {
    win.onCancel = function() {
      this.isDone = true;
      return true;  // return 'true' to close the window
    };

    win.cancel = win.add('button', undefined, 'Cancel');

    win.cancel.onClick = function() {
      var win = this.parent;
      try {
        win.isDone = true;
        if (win.onCancel) {
          var rc = win.onCancel();
          if (rc != false) {
            if (!win.onClose || win.onClose()) {
              win.close();
            }
          }
        } else {
          if (!win.onClose || win.onClose()) {
            win.close();
          }
        }
      } catch (e) {
        var msg = Stdlib.exceptionMessage(e);
        Stdlib.log(msg);
        alert(msg);
      }
    };
  }

  win.onClose = function() {
    this.isDone = true;
    return true;
  };

  win.updateProgress = function(val) {
    var win = this;

    if (val != undefined) {
      win.bar.value = val;
    }
//     else {
//       win.bar.value++;
//     }

    if (win.recenter) {
      win.center(win.parentWin);
    }

    win.show();
    win.hide();
    win.show();
  };

  win.recenter = true;
  win.center(win.parent);

  return win;
};

// might need something like this later...
GenericUI.confirm = function(msg) {
  var win = new Window('palette', 'Script Alert');
  win.msg = win.add('statictext', undefined, msg, {multiline: true});

  win._state = false;
  win.ok = win.add('button', undefined, 'Yes');
  win.ok.onClick = function() {
    this.parent._state = true;
  };
  win.cancel = win.add('button', undefined, 'No');
  win.show();

  return win._state;
};

// GenericUI.alert(Stdlib.readFromFile("~/Desktop/test.xml"), [500, 300]);
// GenericUI.alert("This is a simple alert");

GenericUI.alert = function(msg, size, parent, showAlertText) {
  // alert(msg); return;

  var props = {minimize: false, maximize: false};
  var win = new Window('dialog', 'Script Alert', undefined, props);
  win.orientation = "column";

  if (showAlertText) {
    win.alertTitle = win.add('statictext', undefined, "ALERT");

    // set ALERT to red
    var gfx = win.alertTitle.graphics;
    gfx.foregroundColor = gfx.newPen(gfx.BrushType.SOLID_COLOR, [1,0,0], 1);
  }

  var tprops = {multiline: true, scrolling: true};
  if (!size) {
    size = [GenericUI.alert.DEFAULT_WIDTH, GenericUI.alert.DEFAULT_HEIGHT];
    tprops.scrolling = false;
  }
  win.msg = win.add('statictext', undefined, msg, tprops);

  win.msg.preferredSize = size;

  win.ok = win.add('button', undefined, 'OK');
  win.ok.onClick = function() {
    this.parent.close(1);
  };
  // win.cancel = win.add('button', undefined, 'No');

  win.center(parent);
  return win.show();
};

GenericUI.alert.DEFAULT_WIDTH = 300;
GenericUI.alert.DEFAULT_HEIGHT = 75;

//
//=============================== GenericOptions ==============================
//
GenericOptions = function(obj) {
  if (obj) {
    GenericOptions.copyFromTo(obj, this);
  }
};

function toBoolean(s) {
  if (s == undefined) { return false; }
  if (s.constructor == Boolean) { return s.valueOf(); }
  try { if (s instanceof XML) s = s.toString(); } catch (e) {}
  if (s.constructor == String)  { return s.toLowerCase() == "true"; }
  return Boolean(s);
};

function toNumber(s, def) {
  if (s == undefined) { return NaN; }
  try { if (s instanceof XML) s = s.toString(); } catch (e) {}
  if (s.constructor == String && s.length == 0) { return NaN; }
  if (s.constructor == Number) { return s.valueOf(); }
  return Number(s.toString());
};

function toFont(fs) {
  if (fs.typename == "TextFont") { return fs.postScriptName; }

  var str = fs.toString();
  var f = Stdlib.determineFont(str);  // first, check by PS name

  return (f ? f.postScriptName : undefined);
};

GenericOptions.copyFromTo = function(from, to) {
  if (!from || !to) {
    return;
  }
  for (var idx in from) {
    var v = from[idx];
    if (typeof v != 'function') {
        to[idx] = v;
    }
  }
};

GenericOptions.prototype.hasKey = function(k) {
  return this[key] != undefined;
};
GenericOptions.prototype.getBoolean = function(k, def) {
  var self = this;
  return self.hasKey(k) ? toBoolean(self[k]) : def;
};
GenericOptions.prototype.getInteger = function(k, def) {
  var self = this;
  return self.hasKey(k) ? toNumber(self[k]).toFixed(0) : def;
};
GenericOptions.prototype.getDouble = function(k, def) {
  var self = this;
  return self.hasKey(k) ? toNumber(self[k]) : def;
};
GenericOptions.prototype.getPath = function(k, def) {
  var self = this;
  return self.hasKey(k) ? File(self[k]) : def;
};
GenericOptions.prototype.getArray = function(k, def) {
  var self = this;
  if (!self.hasKey(k)) {
    return def;
  }
  var s = self[k];
  return s.split(',');
};

GenericOptions.prototype.getColor = function(k, def) {
  var self = this;
  if (!self.hasKey(k)) {
    return def;
  }
  var c = self[k];
  if (!(c instanceof SolidColor)) {
    if (c.constructor == String) {
      c = s.split(',');
    }
    if (c instanceof Array) {
      var rgbc = new SolidColor();
      rgbc.rgb.red = c[0];
      rgbc.rgb.green = c[1];
      rgbc.rgb.blue = c[2];
      c = rgbc;
    } else {
      c = undefined;
    }
  }
  return c;
};

GenericOptions.prototype.getObject = function(k, def) {
  var self = this;
  if (!self.hasKey(k)) {
    return def;
  }
  var os = self[k];
  var obj = undefined;
  try { eval('obj = ' + os); } finally {}
  return obj;
};

if (!String.prototype.contains) {

String.prototype.contains = function(sub) {
  return this.indexOf(sub) != -1;
};

String.prototype.containsWord = function(str) {
  return this.match(new RegExp("\\b" + str + "\\b")) != null;
};

String.prototype.endsWith = function(sub) {
  return this.length >= sub.length &&
    this.substr(this.length - sub.length) == sub;
};

String.prototype.reverse = function() {
  var ar = this.split('');
  ar.reverse();
  return ar.join('');
};

String.prototype.startsWith = function(sub) {
  return this.indexOf(sub) == 0;
};

String.prototype.trim = function() {
  return this.replace(/^[\s]+|[\s]+$/g, '');
};
String.prototype.ltrim = function() {
  return this.replace(/^[\s]+/g, '');
};
String.prototype.rtrim = function() {
  return this.replace(/[\s]+$/g, '');
};

}  // String.prototype.contains.

// see SampleUI for an example of how to use this framework.

"GenericUI.jsx";

// EOF

//
isPS7 = function()  { return version.match(/^7\./); };
cTID = function(s) { return app.charIDToTypeID(s); };
sTID = function(s) { return app.stringIDToTypeID(s); };

String.prototype.trim = function() {
  return this.replace(/^[\s]+|[\s]+$/g, '');
};
String.prototype.startsWith = function(sub) {
  return this.indexOf(sub) == 0;
};

String.prototype.endsWith = function(sub) {
  return this.length >= sub.length &&
    this.substr(this.length - sub.length) == sub;
};

SLCFix = function() {
  var self = this;

  self.idMap = {};       // maps ids to names
                         // e.g. id22 -> cTID("Rtte") or PSEvent.Rotate
  self.nameMap = {};     // maps syms to names, e.g. "Rtte" -> PSEvent.Rotate

  self.ftnIndex = 1;
  self.useFtns = true;
  self.first = true;
};

SLCFix.checkPSConstants = function() {
  try {
    eval("PSConstants");
    return true;
  } catch (e) {
    return false;
  }
};

SLCFix.usePSConstants = SLCFix.checkPSConstants();
SLCFix.insertFtnCalls = false;

SLCFix.prototype.nextFunction = function() {
  var str = "function ftn" + (this.ftnIndex++) + "() {\n";
  str += "  function cTID(s) { return app.charIDToTypeID(s); };\n";
  str += "  function sTID(s) { return app.stringIDToTypeID(s); };\n";
  return str;
};

SLCFix.prototype.mapSym = function(idName, sym, ftn) {
  var self = this;
  var v;

  sym = sym.replace(/\'|\"/g, '');  // trim and remove any quotes

//   if (sym == 'pointsUnit') {
//     $.level = 1; debugger;
//   }
  if (SLCFix.usePSConstants) {
    v = self.nameMap[sym];
    if (!v) {
      var id = eval(ftn + "('" + sym + "')");
      if (ftn == 'sTID') {
        var v = PSString._reverseName[id];
        if (v) {
          v = "PSString." + v;
        } else {
          v = "sTID('" + sym + "')";
        }
      } else {
        var tbl = PSConstants.symbolTypes;

        for (var name in tbl) {
          var kind = tbl[name];
          v = kind._reverseName[id];
          if (v) {
            v = "PS" + kind._name + "." + v;
            break;
          }
        }
        if (!v) {
          if (sym.length > 4) {
            ftn = 'sTID';
          }
          v = ftn + "('" + sym + "')";
        }
        if (v.endsWith(".null")) {
          v = "cTID('null')";
        }
      }
      self.nameMap[sym] = v;
    }

  } else {
     v = ftn + "('" + sym + "')";
  }
  self.idMap[idName] = v;
};

SLCFix.prototype.header = function() {
  var self = this;
  var str = '';
  str += "//\n";
  str += "// Generated from " + self.infile.absoluteURI + " on " + Date() + "\n";
  str += "//\n";
  return str.split('\n');
};

SLCFix.prototype.trailer = function() {
  var self = this;
  var str = '';

  str += "cTID = function(s) { return app.charIDToTypeID(s); };\n";
  str += "sTID = function(s) { return app.stringIDToTypeID(s); };\n\n";

  str += "function _initDefs() {\n";
  str += ("  var needDefs = true;\n" +
          "  try {\n" +
          "    PSClass;\n" +
          "    needDefs = false;\n" +
          "  } catch (e) {\n" +
          "  }\n");

  str += "  if (needDefs) {\n";

  var tbl = PSConstants.symbolTypes;
  for (var name in tbl) {
    var kind = tbl[name];
    str += "    PS" + kind._name + " = function() {};\n";
  }
  str += "  }\n};\n\n";

  str += "_initDefs();\n\n";

  var names = [];
  for (var sym in self.nameMap) {
    var n = self.nameMap[sym];
    if (n.startsWith("cTID(") || n.startsWith('sTID')) {
      continue;
    }
    var idk = (n.startsWith("PSString") ? 'sTID' : 'cTID');
    names.push(n + " = " + idk + "('" + sym + "');\n");
  }
  names.sort();
  str += names.join("");
  return str;
};


SLCFix.prototype.exec = function(infile, outfile) {
  this.symIDMap = {};
  this.infile = infile;
  var proc = new TextProcessor(infile, outfile, SLCFix.handleLine);
  proc.parent = this;
  proc.exec();
};

SLCFix.handleLine = function(line, index, outputBuffer) {
  var self = this;
  var fixer = self.parent;

  if (fixer.first) {
    // this new bit of code should fix parsing of SL log segments that
    // do not have a // ======= prefix
    fixer.first = false;
    if (fixer.useFtns) {
      outputBuffer.push(fixer.nextFunction());
      if (line.startsWith("// ========")) {
        outputBuffer.push(line);
        return TextProcessorStatus.OK;
      }
    }
  }

  // At the end of the file, print out the trailier containing
  // all of the symbol table information
  if (line == undefined) {  // EOF
    if (SLCFix.usePSConstants) {
      var str = fixer.trailer();
      var ar = str.split('\n');
      for (var i = ar.length-1; i >= 0; i--) {
        outputBuffer.unshift(ar[i]);
      }
    }

    // now, for some odd reason, we print out the header block
    var ar = fixer.header();
    for (var i = ar.length-1; i >= 0; i--) {
      outputBuffer.unshift(ar[i]);
    }

    return TextProcessorStatus.OK; // EOF
  }

  // pass empty lines through
  if (line == '') {
    outputBuffer.push('');
    return TextProcessorStatus.OK;
  }

  // handle a charID variable definition
  var m;
  if ((m = line.match(/\s*var (id\w+) = charIDToTypeID\((.+)\);/)) != null) {
    fixer.mapSym(m[1], m[2].trim(), "cTID");
    return TextProcessorStatus.OK;
  }

  // handle a stringID variable definition
  if ((m = line.match(/\s*var (id\w+) = stringIDToTypeID\((.+)\);/)) != null){
    fixer.mapSym(m[1], m[2].trim(), "sTID");
    return TextProcessorStatus.OK;
  }

  // swap out the SL var usages with our symbols
  if ((m = line.match(/ id\w+/g)) != null) {
    for (var i = 0; i < m.length; i++) {
      var nm = m[i].substring(1);
      if (fixer.idMap[nm]) {
        line = line.replace(nm, fixer.idMap[nm]);
      }
    }
  }

  // Fix up the mangled File references
  var fps;
  if ((fps = line.match(/new File\((.+)\)/)) != null) {
     line = line.replace(fps[1], fps[1].replace(/\\\\?/g, '/'));
  }

  // Look for the beginning (and ending of) SL code segments
  if (fixer.useFtns) {
    if (line.startsWith("// ========")) {
      outputBuffer.push(line);
      line = fixer.nextFunction();
    }
    if (line.match("executeAction")) {
      outputBuffer.push("    " + line);
      line = "};";

      if (SLCFix.insertFtnCalls) {
        outputBuffer.push(line);
        line = "ftn" + (fixer.ftnIndex-1) + "();";
      }
    }
  }

  line = line.replace(/"""/g, '"'); //'// File formatting fix for xemacs
  
  var ar = line.match(RegExp("\"", "g")); ; //" //File formatting fix for xemacs

  if (ar != null && ar.length == 1) {
//     $.level = 1; debugger;

    if (line[0] == '"') {
      line = '"' + line;
      self.inString = false;
    } else {
      if (self.inString) {
        line = line.replace(/"/g, '\\\"');
        line = '"' + line + '\\n" +';
      } else {
        line += '\\n" +'; 
        self.inString = true;
      }
    }
  } else if (self.inString) {
    line = '"' + line + '\\n" +';
  }

  outputBuffer.push(line);

  return TextProcessorStatus.OK;
};

//============================ SLCFixUI =====================================

SLCFixOptions = function(obj) {
  this.source = '';
  this.dest = '';
  this.useSymbols = false;
  this.insertCall = true;

  if (obj) {
    for (var idx in obj) {
      var v = obj[idx];
      if (typeof v != 'function') {
        this[idx] = v;
      }
    }
  }
};
SLCFixOptions.prototype.typename = 'SLCFixOptions';

SLCFixUI = function() {
  var self = this;

  self.title = "ScriptingListener Code Cleaner";
  self.notesSize = 310;
  self.winRect = {
    x: 200,
    y: 200,
    w: 600,
    h: 510
  };
  self.documentation =
    "This script converts the output of the ScriptingListener plugin into " +
    "a set of functions, one for each chunk of code. As part of the " +
    "conversion process this script cleans and transforms the code " +
    "primarily by substituting charIDToTypeID and stringIDToTypeID function " +
    "calls with calls to cTID and sTID. While doing this replacement, the " +
    "'var id##' style declarations are removed in the c/sTID calls " +
    "placed inline.\r   " +
    "One other piece of corrective surgery is to canonicalize all " +
    "filename strings to use '/' instead of '\\' characters. I didn't " +
    "bother messing with the drive names.\r   " +
    "The only thing left that I don't really have a solution for is Actions " +
    "that invoke scripts. For some reason, the return value of the script " +
    "is placed in the action and gets output to the ScriptingListener log " +
    "file as well. Search for 'jsMs' to see what I mean. Unforunately, in " +
    "many case, the return value is effectively the last piece of textual " +
    "code parsed, I think. There is not an easy way that I have found to " +
    "remove this travesty after the fact, except to do it manually by " +
    "replacing the code with an empty string, \"\". You can, however, " +
    "remove it before the fact. Make the last line of your script files " +
    "'true;' or, like I do, the name of the script as a string, e.g. " +
    "\"SLCFix.js\"; This has the nice added benefit of showing up in the " +
    "debugger console if you are running the script from within the debugger.";

  self.iniFile = "slcfix.ini";
};

SLCFixUI.prototype = new GenericUI();

SLCFixUI.prototype.createPanel = function(pnl, ini) {
  var self = this;
  ini = new SLCFixOptions(ini);

  var xOfs = 20;
  var yOfs = 10;
  var yy = yOfs;
  var xx = xOfs;

  pnl.add('statictext', [xx,yy,xx+110,yy+20], 'SL Log:');
  xx += 110;
  pnl.source = pnl.add('edittext', [xx,yy,xx+400,yy+20], ini.source);
  xx += 405;
  pnl.sourceBrowse = pnl.add('button', [xx,yy,xx+25,yy+20], '...');

  yy += 35;
  xx = xOfs;

  pnl.add('statictext', [xx,yy,xx+110,yy+20], 'Javascript File:');
  xx += 110;
  pnl.dest = pnl.add('edittext', [xx,yy,xx+400,yy+20], ini.dest);
  xx += 405;
  pnl.destBrowse = pnl.add('button', [xx,yy,xx+25,yy+20], '...');

  yy += 35;
  xx = xOfs;

  pnl.useSymbols = pnl.add('checkbox', [xx,yy,xx+100, yy+25], 'Use Symbols');
  pnl.useSymbols.value = toBoolean(ini.useSymbols);

  pnl.sourceBrowse.onClick = SLCFixUI.sourceBrowse;
  pnl.destBrowse.onClick = SLCFixUI.destBrowse;

  return pnl;
};

SLCFixUI.sourceBrowse = function() {
  var pnl = this.parent;
  var file = SLCFixUI.selectFileOpen("Select an SL Log File",
                 SLCFixUI.createFileSelect("Log Files: *.log,All Files:*"),
                 pnl.source.text);
  if (file) {
    pnl.source.text = file.fsName;
  }
};
SLCFixUI.destBrowse = function() {
  try {
    //$.level = 1; debugger;
    var pnl = this.parent;
    var file = SLCFixUI.selectFileSave("Select a Javascript File",
           SLCFixUI.createFileSelect("Javascript Files: *.js;*.jsx,All Files:*"),
           pnl.dest.text);

    if (file) {
      pnl.dest.text = file.fsName;
    }
  } catch (e) {
    alert(e.toSource());
  }
};

SLCFixUI.createFileSelect = function(str) {
  if (isWindows()) {
    return str;
  }

  var exts = [];
  var rex = /\*\.(\*|[\w]+)(.*)/;
  var m;
  while (m = rex.exec(str)) {
    exts.push('.' + m[1].toLowerCase());
    str = m[2];
  }

  function macSelect(f) {
    var name = decodeURI(f.absoluteURI).toLowerCase();
    var _exts = macSelect.exts;

    if (f instanceof Folder) {
      return true;
    }

    for (var i = 0; i < _exts.length; i++) {
      var ext = _exts[i];
      if (ext == '.*') {
        return true;
      }
      if (name.endsWith(ext)) {
        return true;
      }
    }
    return false;
  }

  macSelect.exts = exts;
  return macSelect;
};

SLCFixUI.selectFileOpen = function(prompt, select, start) {
  return SLCFixUI._selectFile(prompt, select, start, true);
};
SLCFixUI.selectFileSave = function(prompt, select, start) {
  return SLCFixUI._selectFile(prompt, select, start, false);
};
SLCFixUI.selectFile = SLCFixUI.selectFileOpen;

SLCFixUI._selectFile = function(prompt, select, start, open) {
  var file;

  if (!prompt) {
    prompt = 'Select a file';
  }

  if (start) {
    start = SLCFixUI.convertFptr(start);
  }

  var classFtn = (open ? File.openDialog : File.saveDialog);

  if (!start) {
    file = classFtn(prompt, select);

  } else {
    if (start instanceof Folder) {

      while (start && !start.exists) {
        start = start.parent;
      }

      var files = start.getFiles();
      for (var i = 0; i < files.length; i++) {
        if (files[i] instanceof File) {
          start = files[i];
          break;
        }
      }
      if (start instanceof Folder) {
        start = new File(start + "/file.ext");
      }
    }

    if (start instanceof File) {
      var instanceFtn = (open ? "openDlg" : "saveDlg");

      if (instanceFtn in start) {
        file = start[instanceFtn](prompt, select);

      } else {
        try {
          if (start.exists) {
            Folder.current = start.parent;
          }
        } catch (e) {
        }
        file = classFtn(prompt, select);
      }
    } else {
      Folder.current = start;
      file = classFtn(prompt, select);
    }
  }

  if (file) {
    Folder.current = file.parent;
  }
  return file;
};
SLCFixUI.convertFptr = function(fptr) {
  var f;
  if (fptr.constructor == String) {
    f = File(fptr);
  } else if (fptr instanceof File || fptr instanceof Folder) {
    f = fptr;
  } else {
    throw "Bad file \"" + fptr + "\" specified.";
  }
  return f;
};


SLCFixUI.prototype.validatePanel = function(pnl) {
  var self = this;

  try {
    var opts = new SLCFixOptions();

    var f;
    if (pnl.source.text) {
      f = new File(pnl.source.text);
      if (!f.exists) {
        return self.errorPrompt("Log file not found");
      }
    } else {
      return self.errorPrompt("Log file must be specified");
    }
    opts.source = decodeURI(f.fsName);

    f = undefined;
    if (pnl.dest.text) {
      f = new File(pnl.dest.text);
    } else {
      var nm = opts.source.name.replace(/\.[^.]+$/, ".jsx");
      f = new File(opts.source.path + '/' + nm);
    }
    if (!f.open("w")) {
      return self.errorPrompt("Unable to open Javascript file: " + f.error);
    }
    f.close();

    opts.dest = decodeURI(f.fsName);

    opts.useSymbols = pnl.useSymbols.value;

    pnl.opts = opts;

  } catch (e) {
    alert(e.toSource());
    return false;
  }

  return opts;
};

SLCFixUI.prototype.process = function(opts) {
  if (!opts) {
    return;
  }

  var start = new Date().getTime();

  var src = new File(opts.source);
  var dest = new File(opts.dest);

  SLCFix.usePSConstants = opts.useSymbols;

  var fixer = new SLCFix();
  fixer.exec(src, dest);

  var stop = new Date().getTime();
  var elapsed = (stop - start)/1000;
  alert("Done (" + Number(elapsed).toFixed(3) + " secs).");
};

function ps7Main() {
  var infile  = new File("/c/work/batch.log");
  var outfile = new File("/c/work/batch.js");

  var start = new Date().getTime();
  var fixer = new SLCFix();
  fixer.exec(infile, outfile);

  var stop = new Date().getTime();
  var elapsed = (stop - start)/1000;
  alert("Done (" + Number(elapsed).toFixed(3) + " secs).");
};

// this bit of code checks to see if there is already a 'main' function
// defined. If there isn't, we create ours and execute it.

var dbLevel = $.level;
$.level = 0;
try {
  main;

} catch (e) {
$.level = dbLevel;

  function main() {
    if (isPS7()) {
      ps7Main();
    } else {
      var ui = new SLCFixUI();
//       $.level = 1; debugger;
      ui.exec();
    }
  };

  main();
}

"SLCFix.js";

// EOF

