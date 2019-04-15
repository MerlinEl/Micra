//
// ColorBookDemo
//   A ColorBook, in PS-speak, is a stored color palette. This script reads
//   all of the color books from 'Presets/Color Books' and writes what
//   information it can out to a text file.
//
// $Id: ColorBookDemo.js,v 1.72 2015/12/03 22:01:32 anonymous Exp $
// Copyright: (c)2005, xbytor
// License: http://www.opensource.org/licenses/bsd-license.php
// Contact: xbytor@gmail.com
//
//@show include
//
//
//
// Stream.js
// This file contains code necessary for reading and writing binary data with
// reasonably good performance. There is a lot that can be done to improve this
// but it works well enough for current purposes
//
// $Id: ColorBookDemo.js,v 1.72 2015/12/03 22:01:32 anonymous Exp $
// Copyright: (c)2007, xbytor
// License: http://www.opensource.org/licenses/bsd-license.php
// Contact: xbytor@gmail.com
//
Stream = function(str) {
  var self = this;
  self.str = (str ? str : []); // the actual bytes as String or Array of char
  self.ptr = 0;                // the current index into the stream
  self.byteOrder = Stream.DEFAULT_BYTEORDER;   // or Stream.LITTLE_ENDIAN
  return self;
};
Stream.prototype.typename = "Stream";

Stream.BIG_ENDIAN = "BE";
Stream.LITTLE_ENDIAN = "LE";
Stream.DEFAULT_BYTEORDER = Stream.BIG_ENDIAN;

Stream.TWO_32= Math.pow(2, 32);
Stream.LARGE_LONG_MASK = 0x001FFFFFFFFFFFFF;  // Math.pow(2, 53) - 1;

Stream.RcsId = "$Revision: 1.72 $";

Stream.EOF = -1;

//
// some code for reading and writing files
//
Stream.writeToFile = function(fptr, str) {
  var file = Stream.convertFptr(fptr);
  file.open("w") || Error.runtimeError(9002, "Unable to open output file \"" +
                                      file + "\".\r" + file.error);
  file.encoding = 'BINARY';
  file.write(str);
  file.close();
};
Stream.readFromFile = function(fptr) {
  var file = Stream.convertFptr(fptr);
  file.open("r") || Error.runtimeError(9002, "Unable to open input file \"" +
                                      file + "\".\r" + file.error);
  file.encoding = 'BINARY';
  var str = '';
  str = file.read(file.length);
  file.close();
  return str;
};
Stream.readStream = function(fptr) {
  var str = new Stream();
  str.str = Stream.readFromFile(fptr);
  return str;
};
Stream.convertFptr = function(fptr) {
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

//
// Convert the Stream to a String. Probably not the best choice of names here
//
Stream.prototype.toStream = function() {
  var s;
  if (this.str.constructor == String) {
    s = this.str.slice(0); 
  } else {
    s = this.str.join("");
  }
  return s;
};

Stream.prototype.appendToFile = function(fptr) {
  var self = this;

  fptr.write.apply(fptr, self.str);

  return;

//   this is surprising slow for large values of len
//   var len = self.str.length;
//   for (var i = 0; i < len; i++) {
//     fptr.write(self.str[i]);
//   }
};


Stream.prototype.writeToFile = function(fptr) {
  var self = this;
  var file = Stream.convertFptr(fptr);
  file.open("w") || Error.runtimeError(9002, "Unable to open output file \"" +
                                      file + "\".\r" + file.error);
  file.encoding = 'BINARY';
  // var str = self.toStream();
  // file.write(str);

  self.appendToFile(fptr);

  file.close();
};

Stream.prototype.seek = function(ptr, mode) {
  var self = this;
  var index;

  if (mode == undefined) {
    mode = 0;
  }

  if (mode == 0) {
    index = ptr;
  } else if (mode == 1) {
    index = self.ptr + ptr;
  } else if (mode == 2) {
    index = self.str.length - ptr;
  } else {
    throw "Bad seek mode.";
  }

  if (index < 0 || index > this.str.length) {
    throw "Attempt to seek in Stream out of range.";
  }
  self.ptr = index;
};
Stream.prototype.tell = function() {
  return this.ptr;
};
Stream.prototype.eof = function() {
  return this.ptr == this.str.length;
};
Stream.prototype.length = function() {
  return this.str.length;
};

//
// Write parts into the Stream
//
Stream.prototype.writeByte = function(b) {
  var self = this;
  self.str[self.ptr++] = String.fromCharCode(b);
  return self;
};
Stream.prototype.writeChar = function(c) {
  var self = this;
  self.str[self.ptr++] = c.charCodeAt(0);
  return self;
};
Stream.prototype.writeUnicodeChar = function(c) {
  var self = this;
  self.writeInt16(c.charCodeAt(0));
  return self;
};

Stream.prototype.writeInt16 = function(w) {
  var self = this;
  self.writeByte((w >> 8) & 0xFF);
  self.writeByte(w & 0xFF);
  return self;
};
Stream.prototype.writeShort = Stream.prototype.writeInt16;

Stream.prototype.writeWord = function(w) {
  var self = this;
  self.writeByte((w >> 24) & 0xFF);
  self.writeByte((w >> 16) & 0xFF);
  self.writeByte((w >> 8) & 0xFF);
  self.writeByte(w & 0xFF);
  return self;
};
Stream.prototype.writeLongWord = function(dw) {
  var self = this;
  var desc = new ActionDescriptor();
  desc.putLargeInteger(app.charIDToTypeID('Temp'), dw);
  var str = new Stream(desc.toStream());
  str.seek(8, 2);
  for (var i = 0; i < 8; i++) {
    self.writeByte(str.readByte());
  }
  return self;
};

Stream.prototype.writeDouble = function(d) {
  var self = this;
  var str = IEEE754.doubleToBin(d);
  self.writeRaw(str);
};
Stream.prototype.writeRaw = function(s) {
//  $.writeln(s.length);
//  $.writeln(new Date());
//  $.level = 1; debugger;

  var self = this;

  if (s.constructor == String) {
    for (var i = 0; i < s.length; i++) {
      self.str[self.ptr++] = String.fromCharCode(s.charCodeAt(i));
    }
    // var x = s.split('');
    // $.writeln("x = " + x.length);
    // // alert(x.length);
    // $.writeln(new Date());
    // var str = String.fromCharCode.apply(String, x);

    // $.writeln("str = " + str.length);
    // $.writeln(new Date());

    // // alert(str.length);

    // if (self.str.constructor == Array) {
    //   self.str.concat(str.split(''));
    //   self.ptr += str.length;
    // } else {
    //   for (var i = 0; i < str.length; i++) {
    //     //self.writeByte(s.charCodeAt(0));
    //     $.writeln(i);
    //     // self.str[self.ptr++] = String.fromCharCode(s.charCodeAt(i));
    //     self.str[self.ptr++] = str[i];
    //   }
    // }
  } else {
    for (var i = 0; i < s.length; i++) {
      self.str[self.ptr++] = s[i];
    }
  }
};
Stream.prototype.writeString = function(s) {
  var self = this;
  for (var i = 0; i < s.length; i++) {
    //self.writeChar(s[i]);
    self.str[self.ptr++] = s[i];
  }
};
Stream.prototype.writeAscii = function(s) {
  var self = this;
  self.writeWord(s.length);
  for (var i = 0; i < s.length; i++) {
    //self.writeChar(s[i]);
    self.str[self.ptr++] = s[i];
  }
};
Stream.prototype.writeUnicode = function(s) {
  var self = this;
  self.writeWord(s.length + 1);
  for (var i = 0; i < s.length; i++) {
    //self.writeUnicodeChar(s[i]);
    self.writeInt16(s.charCodeAt(i));
  }
  self.writeInt16(0);  // null pad
};
Stream.prototype.writeUnicodeString = function(s) {
  var self = this;
  for (var i = 0; i < s.length; i++) {
    self.writeInt16(s.charCodeAt(i));
  }
  self.writeInt16(0);  // null pad
};
Stream.prototype.writeBoolean = function(b) {
  var self = this;
  self.writeByte(b ? 1 : 0);
};

//
// Read parts from the Stream
//
Stream.prototype.readByte = function() {
  var self = this;
  if (self.ptr >= self.str.length) {
    return Stream.EOF;
  }
  var ch = self.str[self.ptr++];
  var c = ch.charCodeAt(0);

  if (isNaN(c) && ch == 0) {
    c = 0;
  }

  return c;
};
Stream.prototype.readSignedByte = function() {
  b = this.readByte();
  if (b > 0x7F) {
    b = 0xFFFFFF00^b;
  };
  return b;
};
Stream.prototype.readByteChar = function() {
  var b = this.readByte();
  if (b != Stream.EOF) {
    b = String.fromCharCode(b);
  }
  return b;
};
Stream.prototype.readChar = function() {
  var self = this;
  if (self.ptr >= self.str.length) {
    return Stream.EOF;
  }
  var c = self.str[self.ptr++];
  return c;
};
Stream.prototype.readUnicodeChar = function() {
  var self = this;
  var i = self.readInt16();
  return String.fromCharCode(i);
};

Stream.prototype.readInt16 = function() {
  var self = this;
  var hi = self.readByte();
  var lo = self.readByte();
  if (self.byteOrder == Stream.BIG_ENDIAN) {
    return (hi << 8) + lo;
  } else {
    return (lo << 8) + hi;
  }
};
Stream.prototype.readShort = Stream.prototype.readInt16;

Stream.prototype.readSignedInt16 = function() {
  var i = this.readInt16();
  if(i > 0x7FFF){
    i = 0xFFFF0000^i;
  };
  return i;
};
Stream.prototype.readSignedShort = Stream.prototype.readSignedInt16;

Stream.prototype.readWord = function() {
  var self = this;
  var hi = self.readInt16();
  var lo = self.readInt16();
  var w;
  if (self.byteOrder == Stream.BIG_ENDIAN) {
    w = (hi << 16) + lo;
  } else {
    w = (lo << 16) + hi;
  }
  if (w < 0) {
    w = 0xFFFFFFFF + w + 1;
  }
  return w;
};

Stream.prototype.readSignedWord = function() {
  var w = this.readWord();
  if(w > 0x7FFFFFFF){
    w = 0xFFFFFFFF00000000^w;
  }
  return w;
};

Stream.prototype.readLongWord = function() {
  var self = this;
  var dw = self.readSignedLongWord();

  if (dw < 0) {
    self.ptr -= 8;
    var s = "0x";
    for (var i = 0; i < 8; i++) {
      var b = self.readByte();
      s += b.toString(16);
    }

    dw = parseInt(s);
  }

  return dw;
};

Stream.prototype.readSignedLongWord = function() {
  var self = this;
  var desc = new ActionDescriptor();
  desc.putLargeInteger(app.charIDToTypeID('Temp'), 0);
  var str = new Stream(desc.toStream().split(''));
  str.seek(8, 2);

  for (var i = 0; i < 8; i++) {
    var b = self.readByte();
    str.writeByte(b);
  }

  str.seek(0, 0);
  desc.fromStream(str.toStream());
  dw = desc.getLargeInteger(app.charIDToTypeID('Temp'));

  return dw;
};


Stream.prototype.readRaw = function(len) {
  var self = this;
  var str = self.str;

  var ar = str.slice(self.ptr, self.ptr+len);
  self.ptr += len;

  return ar;

// This is the original paranoid slower version
//   var ar = [];
//   for (var i = 0; i < len; i++) {
//     ar[i] = String.fromCharCode(self.readByte());
//   }
//   return ar.join("");
};

Stream.prototype.readDouble = function() {
  var self = this;
  var bin = self.readRaw(8);
  var v = IEEE754.binToDouble(bin);
  return v;
};

Stream.prototype.readFloat = function() {
  var self = this;
  var bin = self.readRaw(4);
  var ieee32 = new IEEE754(32);

  var v = IEEE754.binToDouble(bin);
  return v;
};

Stream.prototype.readString = function(len) {
  var self = this;
  var s = '';
  for (var i = 0; i < len; i++) {
    s += self.readChar();
  }
  return s;
};
Stream.prototype.readAscii = function() {
  var self = this;
  var len = self.readWord();
  return self.readString(len);
};
Stream.prototype.readUnicode = function(readPad) {
  var self = this;

  var len = self.readWord();
  if (readPad != false) {
    len--;
  }
  var s = '';
  for (var i = 0; i < len; i++) {
    //s += self.readUnicodeChar();
    var uc = self.readInt16();
    if (uc != 0) {
      s += String.fromCharCode(uc);
    }
  }
  if (readPad != false) {
    self.readInt16(); // null pad
  }
  return s;
};
Stream.prototype.readUnicodeZ = function() {
  return this.readUnicode(true);
};
Stream.prototype.readBoolean = function(b) {
  var self = this;
  return self.readByte() != 0;
};

Stream.prototype.toHex = function(start, len) {
  var self = this;
  if (start == undefined) {
    start = self.ptr;
    len = 16;
  }
  if (len == undefined) {
    len = start;
    start = self.ptr;
  }
  var s = self.str.slice(start, start+len);
  if (self.str instanceof Array) {
    s = s.join("");
  }
  return Stream.binToHex(s, true);
};
Stream.binToHex = function(s, whitespace) {
  function hexDigit(d) {
    if (d < 10) return d.toString();
    d -= 10;
    return String.fromCharCode('A'.charCodeAt(0) + d);
  }
  var str = '';

  for (var i = 0; i < s.length; i++) {
    if (i) {
      if (whitespace == true) {
        if (!(i & 0xf)) {
          str += '\n';
        } else if (!(i & 3)) {
          str += ' ';
        }
      }
    }
    var ch = s[i].charCodeAt(0);
    str += hexDigit(ch >> 4) + hexDigit(ch & 0xF);
  }
  return str;
};


Stream.prototype.dump = function(len) {
  return Stream.binToHex(this.str.slice(this.ptr, this.ptr + (len || 32)),
                         true);
};
Stream.prototype.rdump = function(start, len) {
  return Stream.binToHex(this.str.slice(start, start + (len || 32)),
                         true);
};
Stream.prototype.dumpAscii = function(len) {
  return this.str.slice(this.ptr, this.ptr + (len || 32)).replace(/\W/g, '.');
};

"Stream.js";
// EOF

//
// ColorBook
//   This class reads colorbook files from disk. There are a couple of minor
//   bugs under CS2 that I will track down later.
//
// $Id: ColorBookDemo.js,v 1.72 2015/12/03 22:01:32 anonymous Exp $
// Copyright: (c)2005, xbytor
// License: http://www.opensource.org/licenses/bsd-license.php
// Contact: xbytor@gmail.com
//
//

//============================== ColorBook ====================================

ColorBook = function() {
  var self = this;

  self.file      = null;
  self.signature = 0;
  self.version   = 0;

  self.vendorID = 0;
  self.title = '';
  self.prefix = '';
  self.description = '';
  self.numberOfColors = 0;
  self.colorsPerPage  = 0;
  self.keyColorPage   = 0;
  self.colorType      = -1;
  self.colors = [];
};
ColorBook.RcsId = "$Id: ColorBookDemo.js,v 1.72 2015/12/03 22:01:32 anonymous Exp $";
ColorBook.prototype.typename = "ColorBook";
ColorBook.RGB_TYPE  = 0;
ColorBook.CMYK_TYPE = 2;
ColorBook.LAB_TYPE  = 7;

ColorBook.prototype.read = function(str) {
  var self = this;

  self.signature      = str.readWord();
  self.version        = str.readInt16();

  self.vendorID       = str.readInt16();
  self.vendorName     = ColorBookIDMap.reverseLookup(self.vendorID);
  self.title          = self.readLocalizedUnicode(str);
  self.prefix         = self.readLocalizedUnicode(str);
  self.postfix        = self.readLocalizedUnicode(str);
  self.description    = self.readLocalizedUnicode(str);
  self.numberOfColors = str.readInt16();
  self.colorsPerPage  = str.readInt16();
  self.keyColorPage   = str.readInt16();
  self.colorType      = str.readInt16();

  for (var i = 0; i < self.numberOfColors; i++) {
    var c = new ColorBookColor();
    c.parent = self;
    c.name   = self.readLocalizedUnicode(str);
    c.displayName = self.prefix + c.name + self.postfix;
    c.key    = str.readString(6);
    c.setColor(self.readColorBytes(str), self.colorType);

    // Some colors can be nameless. Deal with it here, if you like
    // if (c.name.length != 0) { self.colors.push(c); }
    self.colors.push(c);
  }
};

ColorBook.prototype.toString = function() {
  var self = this;
  var typeMap = [];

  typeMap[ColorBook.RGB_TYPE]  = "RGB";
  typeMap[ColorBook.CMYK_TYPE] = "CMYK";
  typeMap[ColorBook.LAB_TYPE]  = "LAB";

  var str = "{ name: " + self.vendorName + ", title: \"" + self.title +
      "\", description: \"" + self.description + "\", numberOfColors: " +
      self.numberOfColors + ", colorType: " + typeMap[self.colorType] + "}";

  return str;
};

ColorBook.prototype.readLocalizedUnicode = function(str) {
  var s = str.readUnicode(false);
  return s.replace(/\$\$\$.+=/g, '');
};

ColorBook.prototype.readColorBytes = function(str) {
  var self = this;
  var wlen = (self.colorType == ColorBook.CMYK_TYPE) ? 4 : 3;
  var cbytes = [];

  for (var i = 0; i < wlen; i++) {
    cbytes.push(str.readByte());
  }

  if (self.colorType == ColorBook.LAB_TYPE) {
    cbytes[0]  = Math.round(100 * cbytes[0] / 256);
    cbytes[1] -= 128;
    cbytes[2] -= 128;
  }

  // probably need to do a similar conversion for CMYK

  return cbytes;
};

ColorBook.prototype.readFromFile = function(fptr) {
  var self = this;
  self.file = Stream.convertFptr(fptr);
  var str = Stream.readStream(self.file);
  self.read(str);
};


//============================ ColorBookColor =================================

ColorBookColor = function() {
  var self = this;

  self.name   = '';
  self.key    = -1;
  self.color  = null;
  self.displayName = '';
  self.parent = null;
};
ColorBookColor.prototype.typename = "ColorBookColor";
ColorBookColor.prototype.toString = function() {
  var self = this;
  function colorToString(c) {
    var str;
    if (c.typename == "LabColor") {
      str = "{ Lab: [ " + c.l + ", " + c.a + ", " + c.b + " ]}";
    } else if (c.typename == "RGBColor") {
      str = "{ RGB: [ " + c.red + ", " + c.green +  ", " + c.blue + " ]}";
    } else if (c.typename == "CMYKColor") {
      str = "{ CMYK: [ " + c.cyan + ", " + c.magenta + ", " + c.yellow +
        ", " + c.black + " ]}";
    }
    return str;
  }
  var cstr = colorToString(self.color);
  return "{ name: \"" + self.displayName + "\", " + cstr + "}";
};

ColorBookColor.prototype.setColor = function(cbytes, ctype) {
  var self = this;

  switch (ctype) {
    case ColorBook.RGB_TYPE:
      self.color = new RGBColor();
      self.color.red   = cbytes[0];
      self.color.green = cbytes[1];
      self.color.blue  = cbytes[2];
      break;
    case ColorBook.CMYK_TYPE:
      self.color = new CMYKColor();
      self.color.cyan    = cbytes[0];
      self.color.magenta = cbytes[1];
      self.color.yellow  = cbytes[2];
      self.color.black   = cbytes[3];
      break;
    case ColorBook.LAB_TYPE:
      self.color = new LabColor();
      self.color.l = cbytes[0];
      self.color.a = cbytes[1];
      self.color.b = cbytes[2];
      break;
    default:
      throw "Bad color type specified for color book";
  }
};

ColorBookColor.prototype.getSolidColor = function() {
  var self = this;
  var c = self.color;
  var sc = new SolidColor();

  if (c.typename == "LabColor") {
    sc.lab = c;
  } else if (c.typename == "RGBColor") {
    sc.rgb = c;
  } else if (c.typename == "CMYKColor") {
    sc.cmyk = c;
  } else {
    throw "Unsupported color mode";
  }
  return sc;
};

ColorBookIDMap = {
  ANPA:                  3000,
  Focoltone:             3001,
  PantoneCoated:         3002,
  PantoneProcess:        3003,
  PantoneProSlim:        3004,
  PantoneUncoated:       3005,
  Toyo:                  3006,
  Trumatch:              3007,
  HKSE:                  3008,
  HKSK:                  3009,
  HKSN:                  3010,
  HKSZ:                  3011,
  DIC:                   3012,
  PantonePastelCoated:   3020,
  PantonePastelUncoated: 3021,
  PantoneMetallic:       3022
};
ColorBookIDMap.reverseLookup = function(id) {
  for (var prop in ColorBookIDMap) {
    if (ColorBookIDMap[prop] == id) {
      return prop;
    }
  }
  return undefined;
};

"ColorBook.js";
// EOF

//
// LogWindow
// This is UI code that provides a window for logging information
//
// $Id: ColorBookDemo.js,v 1.72 2015/12/03 22:01:32 anonymous Exp $
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
isPS7 = function()  { return version.match(/^7\./); };

function main() {
  if (isPS7()) {
    alert("For unknown reasons, this script cannot execute in PS7 correctly.");
    return;
  }
  var folder = new Folder(app.path + "/Presets/Color Books");
  var files = folder.getFiles("*.acb");
  var file;
  var listAll = false;
  var outfile = new File("/c/temp/ColorBooks.txt");

  if (files) {
    if (isPS7() || listAll) {
      ; // do nothing
    } else {
      if (files[0].openDlg) {
        file = files[0];
        file = file.openDlg("Select a Color Book",
                            "Color Book Files:*.acb,All files:*");
      } else {
        Folder.current = folder;
        file = File.openDialog("Select a Color Book",
                           "Color Book Files:*.acb,All files:*");
      }

      if (file) {
        files = [file];
      } else {
        files = undefined;
      }
    }
  }

  if (!files) {
    return;
  }

  var outstr = '';
  for (var i = 0; i < files.length; i++) {
    var cb = new ColorBook();
    cb.readFromFile(files[i]);
    outstr += cb.toString() + "\r\n";
    for (var j = 0; j < cb.numberOfColors; j++) {
      if (cb.colors[j].name.length != 0) {
        outstr += cb.colors[j].toString() + "\r\n";
      }
    }
  }

  if (isPS7()) {
    if (!outfile.open("w")) {
      throw "Unable to open " + outfile + ". " + outfile.error;
    }
    outfile.writeln(outstr);
    outfile.close();
    alert("ColorBooks written to " + outfile + ".");

  } else {
    var logwin = new LogWindow("ColorBook " + cb.title);
    logwin.append('\r\n' + outstr);
    logwin.show();
  }
};

main();

"ColorBookDemo.js";
// EOF

