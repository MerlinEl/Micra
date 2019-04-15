#target photoshop
//
// ColorChooserIcon
//
//   This IconButton functionality has been subsumed by ColorIconSelector.jsx.
//   This script needs to be updated to use that code.
//
//   This script shows how to bind a color chooser to a button that
//   becomes the choosen color. It uses the CS3 color chooser and a decendent
//   of Larry L's ColorChooser for CS2.
//
// $Id: ColorChooserIcon.jsx,v 1.5 2010/11/19 00:29:53 anonymous Exp $
// Copyright: (c)2008, xbytor
// License: http://www.opensource.org/licenses/bsd-license.php
// Contact: xbytor@gmail.com
//
//@show include
//
//@includepath "/c/Program Files/Adobe/xtools;/Developer/xtools"
//
app;

//
//@include "xlib/stdlib.js"
//@include "xlib/ColorChooser.jsx"
//-include "xlib/ColorIconSelector.jsx"
//

//
// CCI => ColorChooserIcon
//
CCI = function() {};

//
// CCI.configColorButton
//   This function adds a callback to iconBtn to launch a ColorChooser
//   to allow a user to select a new color. The color of the button changes
//   to reflect the chosen color.
//   The clrStr is the default color. It can be a color object, array, or
//   string. See CCI.getColorIcon for format details for the parameter.
//   When a color has been chosen, the iconBtn._color property will be
//   set to the corresponding color object. The button will also call
//   a new onColorChange callback when the color is changed.
//
CCI.configColorButton = function(iconBtn, clrStr) {
  if (!iconBtn) {
    throw "iconbutton must be provided.";
  }

  iconBtn.setColor = function(clr) {
    if (!clr) {
      return;
    }
    var self = this;
    var icon = CCI.getColorIcon(clr);
    if (icon) {
      self.icon = icon.file;
      self._color = icon.color;
      if (self.onColorChange) {
        self.onColorChange();
      }
    }
    return icon.color;
  };

  iconBtn.setColor(clrStr);

  iconBtn.onClick = function() {
    var pnl = this.parent;
    var self = this;
    var color = ColorChooser.run(self._color);

    if (color) {
      self.setColor(color);
    }
    return;
  };
};

CCI.HEXCOLOR_REX = /^#?[A-Fa-f0-9]{6}$/;

// CCI.fromHexColorString("#FFFFFF");
// CCI.fromHexColorString("FFFFFF");
CCI.fromHexColorString = function(str) {
  var clr = undefined;

  if (str.constructor == String) {
    if (str.match(CCI.HEXCOLOR_REX)) {
      clr = new SolidColor();
      if (str[0] == '#') {
        str = str.slice(1);
      }

      clr.rgb.hexValue = str;
    }
  }

  return clr;
};

CCI.RGBCOLOR_REX = /([\d\.]+),([\d\.]+),([\d\.]+)/;

// CCI.fromRGBString("255,255,255");
CCI.fromRGBString = function(str) {
  var clr = undefined;
  if (m = str.match(CCI.RGBCOLOR_REX)) {
    clr = new SolidColor();
    clr.rgb.red = Number(m[1]);
    clr.rgb.green = Number(m[2]);
    clr.rgb.blue = Number(m[3]);
  }
  return clr;
};

// CCI.newDocument("bbb.psd", "RGBM", 250, 500, 72, 16)
CCI.newDocument = function(name, mode, width, height, resolution, depth) {
  function cTID(s) { return app.charIDToTypeID(s); };
  function sTID(s) { return app.stringIDToTypeID(s); };

  var desc = new ActionDescriptor();
  desc.putString(cTID("Nm  "), name);
  desc.putClass(cTID("Md  "), cTID(mode));
  desc.putUnitDouble(cTID("Wdth"), cTID("#Rlt"), width);
  desc.putUnitDouble(cTID("Hght"), cTID("#Rlt"), height);
  desc.putUnitDouble(cTID("Rslt"), cTID("#Rsl"), resolution);
  desc.putDouble(sTID("pixelScaleFactor"), 1.000000 );
  desc.putEnumerated(cTID("Fl  "), cTID("Fl  "), cTID("Wht "));
  desc.putInteger(cTID("Dpth"), depth );
  desc.putString(sTID("profile"), "sRGB IEC61966-2.1");

  var mkdesc = new ActionDescriptor();
  mkdesc.putObject(cTID("Nw  "), cTID("Dcmn"), desc);
  executeAction(cTID("Mk  "), mkdesc, DialogModes.NO );

  return app.activeDocument;
};


//
// CCI.getColorIcon (color)
//   Returns an plain object with two fields  or undefined if it couldn't
//               figure out what 'color' was.
//       file:   is a 40x20 png of the specified color
//       color:  is the actual underlying SolidColor. If you passed a
//               SolidColor object, that's what you get back, if not, this
//               is what happened when your 'color' got converted
//
//   'color' can be a SolidColor, RGBColor, Array, or a String.
//   If it's an Array, it must be 3 RGB numbers.
//   If it's a String, it must be in one of these formats:
//     "255,255,255"
//     "#FFFFFF"
//     "FEFEFE"
//
//   The png file that is returned has a name format like this: 'FFFF00.png'
//   and it created in the Folder.temp directory. This folder can be overridden
//   by setting the property CCI.getColorIcon.temp to another folder.
//
//   The property CCI.getColorIcon.cacheFiles controls whether or not
//   a new png icon file is generated with each request or the cache is used.
//   Files are cached by default.
//
CCI.getColorIcon = function(color) {
  var clr = undefined;

  if (!color) {
    return undefined;
  }

  // Try to make sense of the 'color' we've been given
  if (color.constructor == String) {
    clr = CCI.fromHexColorString(color);
    if (!clr) {
      clr = CCI.fromRGBString(color);
    }

  } else if (color.constructor == Array && color.length == 3) {
    clr = new SolidColor();
    clr.rgb.red = color[1];
    clr.rgb.green = color[2];
    clr.rgb.blue = color[3];

  } else if (color instanceof RGBColor) {
    clr = new SolidColor();
    clr.rgb = color;

  } else if (color instanceof SolidColor) {
    clr = color;
  }

  if (!clr) {
    return undefined;
  }

  // Now lets make sure that we have a good 'temp' Folder
  if (CCI.getColorIcon.temp.constructor == String) {
    var f = new Folder(CCI.getColorIcon.temp);

    if (!f.exists) {
      if (!f.create()) {
        f = Folder.temp;
      }
    }
    CCI.getColorIcon.temp = f;

  } else if (!(CCI.getColorIcon.temp instanceof Folder)) {
    CCI.getColorIcon.temp = Folder.temp;
  }

  var cname = clr.rgb.hexValue;
  var file = new File(Folder.temp + '/' + cname + '.png');

  // this checks to see if we've already built the preview before
  if (CCI.getColorIcon.cachesFiles) {
    if (file.exists) {
      return { file: file, color: clr };
    }
  }

  var ru = app.preferences.rulerUnits;
  app.preferences.rulerUnits = Units.PIXELS;

  try {
    var doc = Stdlib.newDocument(cname, "RGBM", 40, 20, 72, 8);

  } finally {
    app.preferences.rulerUnits = ru;
  }

  doc.selection.selectAll();
  doc.selection.fill(clr, ColorBlendMode.NORMAL, 100);
  var saveOpts = new PNGSaveOptions();
  doc.saveAs(file, saveOpts, true);
  doc.close(SaveOptions.DONOTSAVECHANGES);

  return { file: file, color: clr };
};



CCI.getColorIcon.temp = Folder.temp;
CCI.getColorIcon.cachesFiles = true;


CCI.demo = function() {
  var demo = {};
  demo.winRect = {           // the rect for the window
    x: 200,
    y: 200,
    w: 200,
    h: 140
  };
  demo.title = 'Color Chooser Icon Demo';

  function rectToBounds(r) {
    return[r.x, r.y, r.x+r.w, r.y+r.h];
  };
  var win = new Window('dialog', demo.title, rectToBounds(demo.winRect));

  var xx = 20;
  var yy = 20;
  var gutter = 80;

  // Background
  win.backgroundColor = win.add('statictext',
                                [xx,yy,xx+gutter,yy+22],
                                'Background:');

  xx += gutter;
  win.backgroundColorIcon = win.add('iconbutton',
                                    [xx,yy,xx+44,yy+24],
                                    undefined,
                                    {style: 'button'});

  CCI.configColorButton(win.backgroundColorIcon, "#000000");

  win.backgroundColorIcon.onColorChange = function() {
    var win = this.parent;
    var color = win.backgroundColorIcon._color;
    alert("Color choosen: " + color.rgb.hexValue);
  }

  xx = 80;
  yy += 80;
  win.okBtn = win.add('button', [xx,yy,xx+40,yy+20], "OK");

  var rc = win.show();
  if (rc == 1) {
    var color = win.backgroundColorIcon._color;
    alert("Final color choosen: " + color.rgb.hexValue);
  }
};

// function main() {
//   CCI.demo();
// };

// main();

"ColorChooserIcon.jsx";
// EOF
