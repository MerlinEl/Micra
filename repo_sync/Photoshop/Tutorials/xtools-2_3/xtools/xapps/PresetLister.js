//
// PresetLister
//
// This script gathers all of the information that it can about presets, which
// is basically a set of arrays with the names of things like Brushes, Shapes,
// and Styles.
//
// This script has been successfully tested in CS and CS2. While it does run
// fine (doesn't crash) in PS7, all of the names returned are truncated by one
// character making its usefulness somewhat limited.
//
// The demo(main) just dumps these arrays a LogWindow.
//
// $Id: PresetLister.js,v 1.12 2010/03/29 02:23:23 anonymous Exp $
// Copyright: (c)2005, xbytor
// License: http://www.opensource.org/licenses/bsd-license.php
// Contact: xbytor@gmail.com
//
//@includepath "/c/Program Files/Adobe/xtools;/Developer/xtools"
//
//@include "xlib/LogWindow.js"
//
var app; if (!app) app = this; // for PS7

cTID = function(s) { return app.charIDToTypeID(s); };
sTID = function(s) { return app.stringIDToTypeID(s); };
isPS7 = function()  { return version.match(/^7\./); };

//
// PresetManager
//   This class is a container for all of the information that we can gather
//   about presets in Photoshop.
//
PresetManager = function() {
  var self = this;

  self.brushes       = [];
  self.colors        = [];
  self.gradients     = [];
  self.styles        = [];
  self.patterns      = [];
  self.shapingCurves = [];
  self.customShapes  = [];
  self.toolPresets   = [];

  self.manager = null;
};
PresetManager.prototype.typename = "PresetManager";


//
// PresetManager.prototype.loadNames
//   Return an array of all of the names for the particular preset category
//   indicated by 'key'
//
PresetManager.prototype.loadNames = function(key) {
  var self = this;
  var names = [];

  var mgr = self.manager;
  var max = mgr.count;

  for (var i = 0; i < max; i++) {
    var objType = mgr.getObjectType(i);
    if (objType == key) {
      break;
    }
  }

  if (i != max) {
    var preset = mgr.getObjectValue(i);
    var list = preset.getList(cTID('Nm  '));
    var max = list.count;
    for (var i = 0; i < max; i++) {
      var str = list.getString(i);
      names.push(str);
    }
  }

  return names;
};

//
// PresetManager.loadPresets
//   Load up all available information on presets
//
PresetManager.prototype.loadPresets = function() {
  var self = this;
  var map = PresetManager.getKeyMap();

  self.manager = PresetManager.getManager();

  for (var i in map) {
    var propertyName = i;
    self[propertyName] = self.loadNames(map[i]);
  }
};

//
// PresetManager.writeToFile
//   Write all of the information to a file
//
PresetManager.prototype.writeToFile = function(file) {
  file.writeln(this.asString());
};

PresetManager.prototype.asString = function() {
  var self = this;
  var str = '';

  var map = new Object();  // for output labels
  map["brushes"]       = "Brushes";
  map["colors"]        = "Colors";
  map["gradients"]     = "Gradients";
  map["styles"]        = "Styles";
  map["patterns"]      = "Patterns";
  map["shapingCurves"] = "Shaping Curves";
  map["customShapes"]  = "Custom Shapes";
  map["toolPresets"]   = "Tool Presets";

  for (var i in map) {
    str += '[' + map[i] + "]\r\n";
    str += '\t' + self[i].join("\r\n\t");
    str += "\r\n";
  }

  return str;
};


//
// PresetManager.getKeyMap
//   Defines a map between property names in the PresetManager and the TypeID
//   used to access those presets via ActionManager API.
//
PresetManager.getKeyMap = function() {

  // This is "lazy initialization". We only compute the value of '_keyMap' once
  // when this function is first called. Each call after the first returns the
  // cached value '_keyMap'

  if (!PresetManager._keyMap) {
    var map = new Object();
    map["brushes"]       = cTID('Brsh');
    map["colors"]        = cTID('Clr ');
    map["gradients"]     = cTID('Grdn');
    map["styles"]        = cTID('StyC');
    map["patterns"]      = cTID('PttR');
    map["shapingCurves"] = cTID('ShpC');
    map["customShapes"]  = sTID('customShape');
    map["toolPresets"]   = sTID('toolPreset');
  
    PresetManager._keyMap = map;
  }
  return PresetManager._keyMap;
};

//
// PresetManager.getManager
//   Retrives the PresetManager object/list from Photoshop
// 
PresetManager.getManager = function() {
  var classApplication = cTID('capp');
  var typeOrdinal      = cTID('Ordn');
  var enumTarget       = cTID('Trgt');

  var ref = new ActionReference();
  ref.putEnumerated(classApplication, typeOrdinal, enumTarget);

  var appDesc = app.executeActionGet(ref);
  return appDesc.getList(sTID('presetManager'));
};

//
// Throw an error in an expression context.
// E.g. "f = new File(fname); f.open("r") || throwError(f.error);
//
throwError = function(e) { throw e; };

function main() {
  var outfile = new File("/c/temp/presetsPS7.txt");

  var mgr = new PresetManager();
  mgr.loadPresets();

  if (isPS7()) {
    outfile.open("w") || throwError(outfile.error);
    mgr.writeToFile(outfile);
    outfile.close() || throwError(outfile.error);
    alert("Preset data saved to " + outfile + ".");

  } else {
    var logwin = new LogWindow('Presets Lister');
    logwin.append(mgr.asString());
    logwin.show();
  }
};

main();

"PresetLister.js";
// EOF
