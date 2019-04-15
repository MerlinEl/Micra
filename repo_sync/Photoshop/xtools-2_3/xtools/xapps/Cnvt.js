//
// Cnvt.js
//   Take a bunch of psd files, add watermarks, resize (if needed),
//   save as tiff, aRGB JPEG, and sRGB JPEG.
//
//   This is an export-style script. After I've completed tweaking a set of
//   images, I run this script to add a watermark and then save out to some
//   set of image types and sizes.
//
//
// $Id: Cnvt.js,v 1.14 2010/03/29 02:23:23 anonymous Exp $
// Copyright: (c)2005, xbytor
// License: http://www.opensource.org/licenses/bsd-license.php
// Contact: xbytor@gmail.com
//
//@show include
//
//@includepath "/c/Program Files/Adobe/xtools;/Developer/xtools"
//
//@include "xlib/Watermark.js"
//
var app; if (!app) app = this; // for PS7

ConverterOptions = function() {
  var self = this;

  self.watermark = true;

  self.watermarkOptions = {
    shape: undefined,
    style: "Basic Drop Shadow",
    ofsX: -5,
    ofsY: -5,
    fontSize: 48,
    fontColor: "255,255,255",
    copyrightText: "Copyright 2006",
    copyrighted: 'true'
  };

  self.tiff = true;
  self.tiffFolder = "tiff";

  self.jpeg = true;
  self.jpegResize = true;
  self.jpegSize  = 1024;

  self.aRGB = true;
  self.aRGBFolder = "aRGB";

  self.sRGB = true;
  self.sRGBFolder = "sRGB";

  self.sRGBSmall = true;
  self.jpegSmallSize = 640;
  self.sRGBSmallFolder = "sRGBSmall";
};

ColorProfileNames = function ColorProfileNames() {};
ColorProfileNames.ADOBE_RGB    = "Adobe RGB (1998)";
ColorProfileNames.APPLE_RGB    = "Apple RGB";
ColorProfileNames.SRGB         = "sRGB IEC61966-2.1";

Converter = function() {};

Converter.createFolder = function(fptr) {
  if (fptr.constructor == String) {
    fptr = new Folder(fptr);
  }

  if (fptr instanceof File) {
    return Converter.createFolder(fptr.parent);
  }
  if (fptr.exists) {
    return true;
  }
  if (!fptr.parent.exists) {
    if (!Converter.createFolder(fptr.parent)) {
      return false;
    }
  }
  return fptr.create();
};

Converter.defaultTiffOptions = function() {
  var opts = new TiffSaveOptions();
  opts.alphaChannel = false;
  opts.annotations = false;
  opts.embedColorProfile = true;
  opts.imageCompression = TIFFEncoding.TIFFLZW;
  opts.layers = false;
  return opts;
};

Converter.prototype.exec = function(doc, opts) {
  var self = this;
  var fname = doc.name;
  var f;
  var folder;

  // Watermark
  if (opts.watermark) {
    Watermark.exec(doc, opts.watermarkOptions);
  }

  // Tiff
  if (opts.tiff) {
    var tifName = fname.substring(0, fname.lastIndexOf('.')) + ".tif";

    var topts = Converter.defaultTiffOptions();
    folder = doc.path + "/" + opts.tiffFolder;
    if (!Converter.createFolder(folder)) {
      throw "Unable to create folder \"" + folder + "\": " + folder.error;
    }
    f = new File(folder + "/" + tifName);
    doc.saveAs(f, topts, true, Extension.LOWERCASE);
  }


  // JPEG
  if (opts.jpeg) {
    var jpgName = fname.substring(0, fname.lastIndexOf('.')) + ".jpg";

    doc.bitsPerChannel = BitsPerChannelType.EIGHT;
    doc.flatten();

    // Resize code goes here
    if (opts.jpegResize) {
      Converter.pscsFit(doc, opts.jpegSize, opts.jpegSize);
    }
    
    var jpgOpts = new JPEGSaveOptions();
    jpgOpts.embedColorProfile = true;
    jpgOpts.quality = 12;

    // Adobe RGB
    if (opts.aRGB) {
      folder = doc.path + "/" + opts.aRGBFolder;
      if (!Converter.createFolder(folder)) {
        throw "Unable to create folder \"" + folder + "\": " + folder.error;
      }
      f = new File(folder + "/" + jpgName);
      doc.saveAs(f, jpgOpts, true, Extension.LOWERCASE);
    }

    // sRGB
    if (opts.sRGB) {
      doc.convertProfile(ColorProfileNames.SRGB,
                         Intent.RELATIVECOLORIMETRIC, 
                         true, false, false);
      folder = doc.path + "/" + opts.sRGBFolder;
      if (!Converter.createFolder(folder)) {
        throw "Unable to create folder \"" + folder + "\": " + folder.error;
      }
      f = new File(folder + "/" + jpgName);
      doc.saveAs(f, jpgOpts, true, Extension.LOWERCASE);

      // Small
      if (opts.sRGBSmall) {
        Converter.pscsFit(doc, opts.jpegSmallSize, opts.jpegSmallSize);

        folder = doc.path + "/" + opts.sRGBSmallFolder;
        if (!Converter.createFolder(folder)) {
          throw "Unable to create folder \"" + folder + "\": " + folder.error;
        }
        f = new File(folder + "/" + jpgName);
        doc.saveAs(f, jpgOpts, true, Extension.LOWERCASE);
      }

    }
    Converter.revertDocument(doc);
  }
};
Converter.pscsFit = function(doc, width, height) {
  if (doc != app.activeDocument) {
    app.activeDocument = doc;
  }
  var ru = app.preferences.rulerUnits;
  try {
    app.preferences.rulerUnits = Units.PIXELS;
    var desc = new ActionDescriptor();
    desc.putUnitDouble(cTID("Wdth"),  cTID("#Pxl"), width);
    desc.putUnitDouble(cTID("Hght"),  cTID("#Pxl"), height);
    executeAction(sTID("3caa3434-cb67-11d1-bc43-0060b0a13dc4"),
                  desc, DialogModes.NO);
  } finally {
    app.preferences.rulerUnits = ru;
  }
};
Converter.revertDocument = function(doc) {
  executeAction(cTID("Rvrt"), new ActionDescriptor(), DialogModes.NO);
};


function main() {
  if (!app.documents.length) {
    alert("Please open a document before running this script.");
    return;
  }
  var cutoff = 3;
  var doc = app.activeDocument;

  var c = new Converter();
  var opts = new ConverterOptions();
  c.exec(doc, opts);
};

main();

"Cnvt.js";
// EOF
