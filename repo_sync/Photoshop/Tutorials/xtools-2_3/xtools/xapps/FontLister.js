//
// FontLister
//   This returns a list of all of the information about fonts that can be
//   retrieved from the Photoshop runtime.
//
// FontList is the collection of Fonts found
// FontInfo is the information we have on each font. There are 4 properties:
//   FontInfo.name - the human readable name, as seen in the Font menu in PS
//   FontInfo.postscript - the name needed when you are scripting PS
//   FontInfo.family - the family of the font (e.g. Arial, Courier)
//   FontInfo.style - the style of the font (e.g. Bold, Italic, Regular)
//
// The demo app code (main) loads up the FontList and dumps the content to
// a CSV file.
//
// This has been successfully tested in CS and CS2.
//
// Note that this doesn't/can't work PS7 because there is not way to get to
// the information from JavaScript.
//
// $Id: FontLister.js,v 1.9 2010/03/29 02:23:23 anonymous Exp $
// Copyright: (c)2005, xbytor
// License: http://www.opensource.org/licenses/bsd-license.php
// Contact: xbytor@gmail.com
//
//@includepath "/c/Program Files/Adobe/xtools;/Developer/xtools"
//
//@include "xlib/LogWindow.js"
//
var app; if (!app) app = this; // for PS7

// stock stuff
cTID  = function(s) { return app.charIDToTypeID(s); };
sTID  = function(s) { return app.stringIDToTypeID(s); };
isPS7 = function()  { return version.match(/^7\./); };

FontInfo = function() {
  var self = this;
  self.typename = "FontInfo";

  self.name = '';
  self.postscript = '';
  self.family = '';
  self.style = '';
};

FontList = function() {
  var self = this;
  self.typename = "FontList";

  self.length = 0;
};

//FontList.prototype = new Array();  doesn't work in CS

FontList.prototype.push = function(fi) {
  var self = this;
  self[self.length++] = fi;
};

FontList.prototype.loadFonts = function() {
  var self = this;

  var appDesc = FontList.getAppInfo();
  var fontList = appDesc.getObjectValue(sTID("fontList")); // can't work in PS7

  var keyFontName  = cTID("FntN");
  var keyStyleName = cTID("FntS");

  var names    = fontList.getList(keyFontName);
  var psnames  = fontList.getList(sTID("fontPostScriptName"));
  var families = fontList.getList(sTID("fontFamilyName"));
  var styles   = fontList.getList(keyStyleName);

  var max = names.count;

  for (var i = 0; i < max; i++) {
    var fi = new FontInfo();

    fi.name       = names.getString(i);
    fi.postscript = psnames.getString(i);
    fi.family     = families.getString(i);
    fi.style      = styles.getString(i);
    
    self.push(fi);
  }
};

//
// FontList.getByName
// Search for a FontInfo from the list. If 'name' is a string, the first font
// with that exact name will be returned. If 'name' is a regular expression,
// it will return the first match to that regular expression. If 'all' is
// additionally set to true, it will return all fonts that match.
//
FontList.prototype.getByName = function(name, all) {
  var self = this;

  // check for a bad index
  if (!name) throw "'undefined' is an invalid name/index";

  var matchFtn;

  if (name instanceof RegExp) {
    matchFtn = function(s1, re) { return s1.match(re) != null; }
  } else {
    matchFtn = function(s1, s2) { return s1 == s2;  }
  }

  var obj = [];

  for (var i = 0; i < container.length; i++) {
    if (matchFtn(self[i].name, name)) {
      if (all != true) {
        return self[i];     // there can be only one
      }
      obj.push(self[i]);    // add it to the list
    }
  }

  return all ? obj : undefined;
};

//
//
// FontList.getAllByName
// Returns all fonts in the list that match the specified name
//
FontList.prototype.getAllByName = function(name) {
  return this.getByName(name, true);
};

FontList.prototype.asString = function() {
  var self = this;
  var str = '';
  var csvHeader = "Name,PostScript,Family,Style";

  str += csvHeader + "\r\n";
  for (var i = 0; i < self.length; i++) {
    var fnt = self[i];
    str += fnt.name + ',' +
      fnt.postscript + ',' +
      fnt.family + ',' +
      fnt.style + '\r\n';
  }
  return str;
};

FontList.prototype.writeToCSV = function(file) {
  var self = this;
  file.writeln(self.asString());
};

FontList.getAppInfo = function() {
  var classApplication = cTID("capp");
  var typeOrdinal      = cTID("Ordn");
  var enumTarget       = cTID("Trgt");

  var ref = new ActionReference();
  ref.putEnumerated(classApplication, typeOrdinal, enumTarget);
  return app.executeActionGet(ref);
};

throwError = function(e) { throw e; };

function main() {
  if (isPS7()) {
    alert("This script will not run under PS7.");
    return;
  }
  var fl = new FontList();
  fl.loadFonts();
  
  var logwin = new LogWindow('Font Lister');
  logwin.append(fl.asString());
  logwin.show();
};

main();

"FontLister.js";
// EOF
