//
// ColorTable
//   This class reads and writes color table files from disk.
//   This assumes that the index color table is (at most) 256 colors long.
//   If the file contains less, toString will pad with 0,0,0 entries.
//
// $Id: ColorTable.jsx,v 1.16 2015/08/08 22:53:34 anonymous Exp $
// Copyright: (c)2015, xbytor
// License: http://www.opensource.org/licenses/bsd-license.php
// Contact: xbytor@gmail.com
//
// Need to add parameter checking everywhere
//

//============================= ColorTable ====================================

ColorTable = function() {
  var self = this;

  self.file   = undefined;
  self.colors = [];
};
ColorTable.RcsId = "$Id: ColorTable.jsx,v 1.16 2015/08/08 22:53:34 anonymous Exp $";

ColorTable.prototype.typename = "ColorTable";

//
// toString returns only the colors present, not any padding colors
//
ColorTable.prototype.toString = function() {
  var self = this;
  var str = "[ColorTable ";

  if (!self.colors || self.colors.length == 0) {
    return str + "]";
  }

  for (var i = 0; i < 256; i++) {
    if (i >= self.colors.length) {
//       str += "0,0,0\n";
    } else {
      var sc = self.colors[i];
      var rgb = sc.rgb;
      str += '\n  [' + rgb.red + ',' + rgb.green + ',' + rgb.blue + ']';
    }
  };

  return str + "\n]";
};

ColorTable.prototype.read = function(str, len) {
  var self = this;
  var trim = false;
  var colors = [];

  if (!len) {
    if (str.str.length > 768) {
      str.ptr = 768;
      var hi = str.readByte();
      var lo = str.readByte();
      len = (hi << 8) + (lo & 0xFF);
      str.ptr = 0;
    } else {
      len = 256;
    }
  }

  for (var i = 0; i < len; i++) {
    var sc = new SolidColor();
    var rgb = sc.rgb;

    try {
      rgb.red = str.readByte();
      rgb.green = str.readByte();
      rgb.blue = str.readByte();
      
      colors[i] = sc;
      
    } catch (e) {
      break;
    }
    
    if (str.eof()) {
      break;
    }
  }

  self.colors = colors;
};

ColorTable.readFromFile = function(fptr) {
  var ct = new ColorTable();
  ct.readFromFile(fptr) 
  return ct;
};

ColorTable.prototype.readFromFile = function(fptr) {
  var self = this;

  if (fptr.constructor == String) {
    fptr = File(fptr);
  }

  var file = self.file = fptr;

  file.open("r");
  file.encoding = 'BINARY';
  var s = file.read();
  file.close();

  var str = {
    str: s,
    ptr: 0
  };
  
  str.readByte = function() {
    var self = this;
    if (self.ptr >= self.str.length) {
      return -1;
    }
    return self.str.charCodeAt(self.ptr++);
  };
  
  str.eof = function() {
    return this.ptr >= this.str.length;
  };

  self.read(str);

  return self;
};

ColorTable.apply = function(fptr, doc) {
  var ct = new ColorTable();
  ct.apply(fptr);
  return ct;
};

ColorTable.prototype.apply = function(fptr, doc) {
  var self = this;

  if (fptr) {
    self.readFromFile(fptr);
  }

  function cTID(s) { return app.charIDToTypeID(s); };
  function sTID(s) { return app.stringIDToTypeID(s); };
  var desc  = new ActionDescriptor();
  var ref = new ActionReference();
  ref.putProperty(cTID('Clr '), cTID('ClrT'));
  desc.putReference(cTID('null'), ref);

  var list = new ActionList();

  var colors = self.colors;

  for (var i = 0; i < colors.length; i++) {
    var color = colors[i];
    var cdesc = new ActionDescriptor();
    cdesc.putDouble(cTID('Rd  '), color.rgb.red);
    cdesc.putDouble(cTID('Grn '), color.rgb.green);
    cdesc.putDouble(cTID('Bl  '), color.rgb.blue);
    list.putObject(cTID('RGBC'), cdesc);
  }

  desc.putList(cTID('T   '), list);
  return executeAction(cTID('setd'), desc, DialogModes.NO);
};

ColorTable.prototype.writeToFile = function(file) {
  var self = this;

  if (file.constructor == String) {
    file = File(file);
  }

  file.open("w") || Error.runtimeError(9002, "Unable to open output file \"" +
                                       file + "\".\r" + file.error);
  file.encoding = 'BINARY';

  var str = {
    str: [],
    ptr: 0
  };

  str.writeByte = function(b) {
    var self = this;
    self.str[self.ptr++] = String.fromCharCode(b);
    return self;
  };

  var colors = self.colors;
  var len = Math.min(colors.length, 256);

  for (var i = 0; i < len; i++) {
    var color = colors[i];
    str.writeByte(color.rgb.red);
    str.writeByte(color.rgb.green);
    str.writeByte(color.rgb.blue);
  }

  if (len < 256) {
    for (var i = len; i < 256; i++) {
      str.writeByte(0);
      str.writeByte(0);
      str.writeByte(0);
    }
  }

  str.writeByte(len >> 8);
  str.writeByte(len & 0xff);
  str.writeByte(0xff); 
  str.writeByte(0xff);

  var len = str.str.length;
  for (var i = 0; i < len; i++) {
    file.write(str.str[i]);
  }

  file.close();
};

ColorTable.getDocumentTable = function(doc) {
  var self = this;

  var gifOpts = new GIFSaveOptions();
  var f = File(Folder.temp + "/tmp.gif");
  doc.saveAs(f, gifOpts);
  
  f.encoding = 'BINARY';
  f.open("r");
  f.seek(0xA);
  var ch = f.read(1).charCodeAt(0);
  var len = (1 << ((ch &= 7) + 1));
  f.seek(0xD);
  var s = f.read(3 * len);
  f.close();
  f.remove();

  var str = {
    str: s,
    ptr: 0
  };
  str.readByte = function() {
    var self = this;
    if (self.ptr >= self.str.length) {
      return -1;
    }
    return self.str.charCodeAt(self.ptr++);
  };

  str.eof = function() {
    return this.ptr >= this.str.length;
  };

  var str = new Stream(s);
  var ct = new ColorTable();
  ct.read(str, len);

  return ct;
};

ColorTable.saveDocumentTable = function(doc, file) {
  if (file.constructor == String) {
    file = File(file);
  }
  var ct = ColorTable.getDocumentTable(doc);
  ct.writeToFile(file);
};


/*
Sample Usage


var clrTbl = new ColorTable();
clrTbl.apply("~/Desktop/temp/bianca.act");

var clrTbl = new ColorTable();
clrTbl.readFromFile("~/someTable.act");
var str = clrTbl.toString();
alert(str);
*/

// for testing
ColorTable.main = function() {
  var clrTbl = new ColorTable();
  clrTbl.apply("~/Desktop/temp/bianca.act");
};
// ColorTable.main();

// more testing
// ColorTable.saveDocumentTable(app.activeDocument, "~/Desktop/test.act");

// var clrTbl = new ColorTable();
// clrTbl.readFromFile("~/Desktop/test.act");
// $.writeln(clrTbl.toString());

"ColorTable.jsx";
// EOF
