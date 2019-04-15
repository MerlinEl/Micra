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
// $Id: PresetLister.js,v 1.72 2015/12/03 22:01:32 anonymous Exp $
// Copyright: (c)2005, xbytor
// License: http://www.opensource.org/licenses/bsd-license.php
// Contact: xbytor@gmail.com
//
//
//
// LogWindow
// This is UI code that provides a window for logging information
//
// $Id: PresetLister.js,v 1.72 2015/12/03 22:01:32 anonymous Exp $
// Copyright: (c)2005, xbytor
// License: http://www.opensource.org/licenses/bsd-license.php
// Contact: xbytor@gmail.com
//
//@show include

LogWindow = function LogWindow(title, bounds, text) {
  var self = this;

  self.title = (title || 'Log Window');
  self.bounds = (bounds || [100,100,740,580]);
  self.text = (text ? text : '');
  self.useTS = false;
  self.textType = 'edittext'; // or 'statictext'
  self.inset = 15;
  self.debug = false;

  LogWindow.prototype.textBounds = function() {
    var self = this;
    var ins = self.inset;
    var bnds = self.bounds;
    var tbnds = [ins,ins,bnds[2]-bnds[0]-ins,bnds[3]-bnds[1]-35];
    return tbnds; 
  }
  LogWindow.prototype.btnPanelBounds = function() {
    var self = this;
    var ins = self.inset;
    var bnds = self.bounds;
    var tbnds = [ins,bnds[3]-bnds[1]-35,bnds[2]-bnds[0]-ins,bnds[3]-bnds[1]];
    return tbnds; 
  }
  
  LogWindow.prototype.setText = function setText(text) {
    var self = this;
    self.text = text;
    //fullStop();
    if (self.win != null) {
      try { self.win.log.text = self.text; } catch (e) {}
    }
  }
  LogWindow.prototype.init = function(text) {
    var self = this;
    if (!text) text = '';
    self.win = new Window('dialog', self.title, self.bounds);
    var win = self.win;
    win.owner = self;
    win.log = win.add(self.textType, self.textBounds(), text,
                                {multiline:true});
    win.btnPanel = win.add('panel', self.btnPanelBounds());
    var pnl = win.btnPanel;
    pnl.okBtn = pnl.add('button', [15,5,115,25], 'OK', {name:'ok'});
    pnl.clearBtn = pnl.add('button', [150,5,265,25], 'Clear', {name:'clear'});
    if (self.debug) {
      pnl.debugBtn = pnl.add('button', [300,5,415,25], 'Debug',
                             {name:'debug'});
    }
    pnl.saveBtn = pnl.add('button', [450,5,565,25], 'Save', {name:'save'});
    self.setupCallbacks();
  }
  LogWindow.prototype.setupCallbacks = function() {
    var self = this;
    var pnl = self.win.btnPanel;
    
    pnl.okBtn.onClick = function()    { this.parent.parent.owner.okBtn(); }
    pnl.clearBtn.onClick = function() { this.parent.parent.owner.clearBtn(); }
    if (self.debug) {
      pnl.debugBtn.onClick = function() {
        this.parent.parent.owner.debugBtn();
      }
    }
    pnl.saveBtn.onClick = function()  { this.parent.parent.owner.saveBtn(); }
  }
  LogWindow.prototype.okBtn    = function() { this.close(1); }
  LogWindow.prototype.clearBtn = function() { this.clear(); }
  LogWindow.prototype.debugBtn = function() { $.level = 1; debugger; }
  LogWindow.prototype.saveBtn    = function() {
    var self = this;
    // self.setText(self.text + self._prefix() + '\r\n');
    self.save();
  }

  LogWindow.prototype.save = function() {
    try {
      var self = this;
      var f = LogWindow.selectFileSave("Log File",
                                       "Log file:*.log,All files:*",
                                       "/c/temp");
      if (f) {
        f.open("w") || throwError(f.error);
        try { f.write(self.text); }
        finally { try { f.close(); } catch (e) {} }
      }
    } catch (e) {
      alert(e.toSource());
    }
  }
  
  LogWindow.prototype.show = function(text) {
    var self = this;
    if (self.win == undefined) {
      self.init();
    }
    self.setText(text || self.text);
    return self.win.show();
  }
  LogWindow.prototype.close = function(v) {
    var self = this;
    self.win.close(v);
    self.win = undefined;
  }
  LogWindow.prototype._prefix = function() {
    var self = this;
    if (self.useTS) {
      return LogWindow.toISODateString() + "$ ";
    }
    return '';
  }
  LogWindow.prototype.prefix = LogWindow.prototype._prefix;
  LogWindow.prototype.append = function(str) {
    var self = this;
    self.setText(self.text + self.prefix() + str + '\r\n');
  }
  LogWindow.prototype.clear = function clear() {
    this.setText('');
  }

  LogWindow.toISODateString = function (date) {
    if (!date) date = new Date();
    var str = '';
    function _zeroPad(val) { return (val < 10) ? '0' + val : val; }
    if (date instanceof Date) {
      str = date.getFullYear() + '-' +
      _zeroPad(date.getMonth()+1) + '-' +
      _zeroPad(date.getDate()) + ' ' +
      _zeroPad(date.getHours()) + ':' +
      _zeroPad(date.getMinutes()) + ':' +
      _zeroPad(date.getSeconds());
    }
    return str;
  }

 LogWindow.selectFileSave = function(prompt, select, startFolder) {
   var oldFolder = Folder.current;
   if (startFolder) {
     if (typeof(startFolder) == "object") {
       if (!(startFolder instanceof "Folder")) {
         throw "Folder object wrong type";
       }
       Folder.current = startFolder;
     } else if (typeof(startFolder) == "string") {
       var s = startFolder;
       startFolder = new Folder(s);
       if (startFolder.exists) {
         Folder.current = startFolder;
       } else {
         startFolder = undefined;
         // throw "Folder " + s + "does not exist";
       }
     }
   }
   var file = File.saveDialog(prompt, select);
   //alert("File " + file.path + '/' + file.name + " selected");
   if (Folder.current == startFolder) {
     Folder.current = oldFolder;
   }
   return file;
 };
};

LogWindow.open = function(str, title) {
  var logwin = new LogWindow(title, undefined, str);
  logwin.show();
  return logwin;
};

function throwError(e) {
  throw e;
};

"LogWindow.js";
// EOF


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

