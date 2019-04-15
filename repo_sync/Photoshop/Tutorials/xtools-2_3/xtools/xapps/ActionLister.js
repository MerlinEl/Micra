//
// ActionLister
//    This is a sample application that uses part of the Xtended ActionManger
//    APIs. This file contains all that is needed to examine the action sets
//    and actions loaded in the current runtime action palette.
//
//    While this demo app (the 'main' function) is interesting, I would expect
//    that the more typical use would be to read the runtime palette and use
//    that object to determine if needed action sets and actions have been
//    loaded. In CS/CS2, it could be part of a GUI where a user could select an
//    action to run on an image a some point during the execution of a script.
//    It's also useful as is if you just want to get an inventory of what
//    actions you have loaded. My CS installation, for instance, has 144 action
//    files loaded with a total of 1004 actions. Now, I can dump the string
//    that is built in 'main' to a file to help me get some idea of what I have
//
// $Id: ActionLister.js,v 1.14 2010/03/29 02:23:23 anonymous Exp $
// Copyright: (c)2005, xbytor
// License: http://www.opensource.org/licenses/bsd-license.php
// Contact: xbytor@gmail.com
//
//@includepath "/c/Program Files/Adobe/xtools;/Developer/xtools"
//
//@include "xlib/LogWindow.js"
//

var app;
if (!app) app = this; // for PS7

// stock stuff
cTID = function(s) { return app.charIDToTypeID(s); };
sTID = function(s) { return app.stringIDToTypeID(s); };
isPS7 = function() { return version.match(/^7\./); };

//================================= Action ====================================
Action = function() {
  var self = this;
  self.name = '';
  self.parent = null;
  return self;
};
Action.prototype.typename = "Action";
Action.prototype.getName       = function() { return this.name; };

Action.prototype.readRuntime = function(desc) {
  var self = this;

  // Name
  if (desc.hasKey(cTID("Nm  "))) {
    self.name = desc.getString(cTID("Nm  "));
  }

  return;
};

//================================ ActionSet ==================================
ActionSet = function() {
  var self = this;

  self.parent = null;
  self.name = '';
  self.count = 0;
  self.actions = [];
  return self;
};

ActionSet.prototype.typename = "ActionSet";

ActionSet.prototype.getName     = function(act) { return this.name; }
ActionSet.prototype.getCount    = function(act) { return this.count; }

ActionSet.prototype.getNames = function() {
  var self = this;
  var names = [];
  
  for (var i = 0; i < self.actions.length; i++) {
    var act = self.actions[i];
    names.push(act.name);
  }
  return names;
};
ActionSet.prototype.getByName = function(name) {
  var self = this;
  for (var i = 0; i < self.actions.length; i++) {
    var act = self.actions[i];
    if (act.name == name) {
      return act;
    }
  }
  return undefined;
};
ActionSet.prototype.byIndex = function(index) {
  var self = this;
  return self.actions[index];
};
ActionSet.prototype.readRuntime = function() {
  var self = this;
  var max = self.count;
  self.actions = [];

  for (var i = 1; i <= max; i++) {
    var ref = new ActionReference();
    ref.putIndex(cTID("Actn"), i);            // Action
    ref.putIndex(cTID("ASet"), self.index);   // ActionSet

    var desc = executeActionGet(ref);
    var act = new Action();
    act.index = i;
    act.readRuntime(desc);
    self.add(act);
  }
};
ActionSet.prototype.add = function(action) {
  var self = this;

  action.parent = self;
  self.actions.push(action);
  self.count = self.actions.length;
};


//============================ ActionsPalette =================================
//
// An ActionsPalette is a collection of ActionSets, either from the
// runtime palette or a palette file
//
ActionsPalette = function() {
  var self = this;

  self.name = app.name;
  self.count = 0;
  self.actionSets = [];
};
ActionsPalette.prototype.typename = "ActionsPalette";
ActionsPalette.prototype.getName    = function() { return this.name; };
ActionsPalette.prototype.getCount   = function() { return this.count; };

//
//
//
ActionsPalette.prototype.getNames = function() {
  var self = this;
  var names = [];
  
  for (var i = 0; i < self.actionSets.length; i++) {
    var as = self.actionSets[i];
    names.push(as.name);
  }
  return names;
};
ActionsPalette.prototype.getByName = function(name) {
  var self = this;
  for (var i = 0; i < self.actionSets.length; i++) {
    var as = self.actionSets[i];
    if (as.name == name) {
      return as;
    }
  }
  return undefined;
};
ActionsPalette.prototype.byIndex = function(index) {
  var self = this;
  return self.actionSets[index];
};
ActionsPalette.prototype.readRuntime = function() {
  var self = this;
  var i = 1;

  while (true) {
    var ref = new ActionReference();
    ref.putIndex(cTID("ASet"), i);    // ActionSet
    var desc;
    try {
      desc = executeActionGet(ref);
    } catch (e) {
      break;    // all done
    }
    var as = new ActionSet();
    as.parent = self;
    as.index = i;

    // Name
    if (desc.hasKey(cTID("Nm  "))) {
      as.name = desc.getString(cTID("Nm  "));
    }
    // NumberOfChildren
    if (desc.hasKey(cTID("NmbC"))) {
      as.count = desc.getInteger(cTID("NmbC"));
      as.readRuntime(i);
    }
    self.add(as);
    i++;
  }
  self.count = self.actionSets.length;
};
ActionsPalette.prototype.add = function(actionSet) {
  var self = this;
  actionSet.parent = self;
  self.actionSets.push(actionSet);
  self.count = self.actionSets.length;
};

//
// main()
//

function main() {
  var str = '';
  var pal = new ActionsPalette();
  var outfile = new File("/c/temp/actions.txt");

  //$.level = 1; debugger;
  pal.readRuntime();

  var totalActs = 0;
  var cnt = pal.getCount();
  
  for (var i = 0; i < cnt; i++) {
    var actset = pal.byIndex(i);
    str += '[' + actset.getName() + "]\r\n";
    acnt = actset.getCount();

    for (var j = 0; j < acnt; j++) {
      var act = actset.byIndex(j);
      str += '\t' + act.getName() + "\r\n";
      totalActs++;
    }
  }

  var totalStr =
      "Total ActionSets: " + i + "\r\n" +
      "Total Actions   : " + totalActs;

  // PS7 can't do alerts or confirms longer than 4 lines of text
  if (isPS7()) {
    if (!outfile.open()) {
      throw "Unable to open " + outfile + ": " + outfile.error;
    }
    outfile.writeln(totalStr);
    outfile.writeln(str);
    outfile.close();
    alert("Action list written to " + outfile);

  } else {
    var logwin = new LogWindow('ActionLister');
    logwin.append(totalStr);
    logwin.append(str);
    logwin.show();
  }
};

main();

"ActionLister.js"; // done
