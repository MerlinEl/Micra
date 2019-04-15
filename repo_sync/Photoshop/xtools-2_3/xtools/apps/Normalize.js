//
// Normalize
//   This is a script for converting old jpg images to
//   larger, resized, 16bit, aRBG, PSD files.
//   The script imports images and 'normalizes' them so that they have
//   consistent metatdata, color profile, bit depth, size, etc... A noise
//   reduction action may also be run as a part of the normalization
//   process.
//
//
// $Id: Normalize.js,v 1.72 2015/12/03 22:01:32 anonymous Exp $
// Copyright: (c)2005, xbytor
// License: http://www.opensource.org/licenses/bsd-license.php
// Contact: xbytor@gmail.com
//
//@show include
//
//
//
// Levels.js
//
// $Id: Normalize.js,v 1.72 2015/12/03 22:01:32 anonymous Exp $
// Copyright: (c)2005, xbytor
// License: http://www.opensource.org/licenses/bsd-license.php
// Contact: xbytor@gmail.com
//
//@show include
//
// Trim histogram tails
// Levels.autoAdjustRGBChannels(doc, cutoff);
// Levels.autoAdjust(doc, cutoff);
//   doc      The document to be modified
//   cutoff   The maximum value in the histogram we will ignore,
//            typically 1 or 0 (the default)
//
//   [return] true if the doc was modified, false if not
//

//============================= Levels =====================================
Levels = function Levels() {};

Levels.autoAdjustChannel = function(doc, name, cutoff) {
  var modified = false;
  if (doc == undefined) {
    throw "Document must be specified to adjust level(s)";
  }
  if (name == null) {
    throw "Channel name must be specified";
  }
  if (cutoff == undefined) {
    cutoff = 0;
  }
  var channel;
  var channels = doc.activeChannels;
  for (var i = 0; i < channels.length; i++) {
    if (name == channels[i].name) {
      channel = channels[i];
    }
  }

  var HIST_MAX = channel.histogram.length;
  var r = Histogram.range(channel.histogram, cutoff);

  if (r) {
    modified = true;
    var state = [];
    // make this channel the only active/selected/visible one
    for (var i = 0; i < channels.length; i++) {
      var ch = channels[i];
      state[i] = ch.visible;
      if (ch.name == name) {
        ch.visible = true;
        doc.activeChannels = new Array(ch);
      } else {
        ch.visible = false;
      }
    }
    // do the adjustment
    doc.activeLayer.adjustLevels(r.min, r.max, 1.00, 0, (HIST_MAX-1));
    doc.activeChannels = channels;
    // turn all of the channels back on
    for (var i = 0; i < channels.length; i++) {
      channels[i].visible = true;
    }
  }
  return modified;
};
Levels.autoAdjustRGBChannels = function(doc, cutoff) {
  var modified = Levels.autoAdjustChannel(doc, "Red", cutoff);
  modified = Levels.autoAdjustChannel(doc, "Green", cutoff) && modified;
  modified = Levels.autoAdjustChannel(doc, "Blue", cutoff) && modified;
  return modified;
};
Levels.autoAdjustAllChannels = function(doc, cutoff) {
  var modified = true;
  var channels = doc.activeChannels;
  for (var i = 0; i < channels.length; i++) {
    modified = Levels.autoAdjustChannel(doc, channels[i].name, cutoff)
      && modified;
  }
  return modified;
};

Levels.autoAdjust = function(doc, cutoff) {
  if (doc == undefined) {
    throw "Document must be specified to adjust levels";
  }
  if (cutoff == undefined) {
    cutoff = 0;
  }
  //$.level = 1; debugger;

  var modified = false;
  // noop for text layer
  if (doc.activeLayer.kind != LayerKind.TEXT) {

    // make sure we have enough bits per channel
    var bits = doc.bitsPerChannel;
    if (bits == BitsPerChannelType.EIGHT
        || bits == BitsPerChannelType.SIXTEEN) {

      // make sure we can deal with this mode
      var mode = doc.mode;
      if (mode == DocumentMode.CMYK
          || mode == DocumentMode.RGB
          || mode == DocumentMode.LAB) {
        
        var hist = doc.histogram;
        var HIST_MAX = hist.length;
        var r = Histogram.range(hist, cutoff);

        if (r) {
          doc.activeLayer.adjustLevels(r.min, r.max, 1.00, 0, (HIST_MAX-1));
          modified = true;
        }
      }
    }
  }

  return modified;
};


//--------------------------------- Histogram ----------------------------

Histogram = function Histogram() {};

Histogram.range = function(hist, lo_cutoff, hi_cutoff) {
  var HIST_MAX = hist.length;
  if (lo_cutoff == undefined) lo_cutoff = 0;
  if (hi_cutoff == undefined) hi_cutoff = lo_cutoff;

  // change this to true to see what
  // the histogram numbers really are
  if (Levels.dumpHistogram) {
    // debug stuff...
    var str = '';
    for (var i = 0; i < HIST_MAX; i++) {
      str += hist[i] + ",";
    }
    confirm(lo_cutoff + '\r' + hi_cutoff + '\r' + str);
  }

  // find the minimum level
  var min = 0;
  while (min < HIST_MAX && hist[min] <= lo_cutoff) {
    min++;
  }
  // find the maximum level
  var max = HIST_MAX-1;
  while (max >= 0 && hist[max] <= hi_cutoff) {
    max--;
  }
  var r = {};
  r.min = min;
  r.max = max;
  if (false) {
    alert(r.min + ':' + r.max);
  }

  // we need at least 2 distinct levels
  if (r.min != HIST_MAX && r.max != -1 && r.max != r.min) {
    // we also need to be sure that we're not already auto-leveled
    if (!(r.min == 0 && r.max == (HIST_MAX-1))) {
      return r;
    }
  }

  return null;
};

Histogram.mean = function(hist) {
  var acc  = 0;
  var cnt = 0;
  for (var i = 0; i < hist.length; i++) {
    acc += i*hist[i];
    cnt += hist[i];
  }
  return acc/cnt;
};
Histogram.median = function(hist) {
  var cnt = 0;
  for (var i = 0; i < hist.length; i++) {
    cnt += hist[i];
  }
  cnt = cnt/2;
  var acc = 0;
  for (var i = 0; i < hist.length; i++) {
    acc += hist[i];
    if (acc > cnt) return i-1;
  }
  return -1;
};

//
// These two aggregate functions produce interesting results,
// but I don't know how meaningful they actually are.
//
Histogram.aggregateMean = function(doc) {
  var chCnt = doc.channels.length;
  var acc = 0;
  for (var i = 0; i < chCnt; i++) {
    var ch = doc.channels[i];
    acc += Histogram.mean(ch.histogram);
  }
  return acc/chCnt;
};

Histogram.aggregateMedian = function(doc) {
  var chCnt = doc.channels.length;
  var acc = 0;
  for (var i = 0; i < chCnt; i++) {
    var ch = doc.channels[i];
    acc += Histogram.median(ch.histogram);
  }
  return acc/chCnt;
};

/*

// Sample usage
// Lets do some work, here..
var app;
if (!app) app = this;  // for PS7

var doc;
try { doc = app.activeDocument; } catch (e) {}
if (doc) {
   var adjusted = Levels.autoAdjustRGBChannels(doc, 3);
   // or 
   // Levels.autoAdjust(doc, 3);
   if (adjusted) {
     alert("Levels adjusted");
   } else {
     alert("Levels not adjusted");
   }
} else {
  alert("No document available");
}

*/

// $.level = 1; debugger;
// var doc = app.activeDocument;
// Histogram.aggregateMedian(doc);
// Histogram.aggregateMean(doc);

"Levels.js";
// EOF

//

var app; if (!app) app = this; // for PS7
isPS7 = function()  { return version.match(/^7\./); };
cTID = function(s) { return app.charIDToTypeID(s); };
sTID = function(s) { return app.stringIDToTypeID(s); };

NormalizeOptions = function(obj) {
  var self = this;

  self.colorProfile = ColorProfileNames.PROPHOTO_RGB;
  self.bitDepth = 16; 
  self.maxSize = 0;
  self.adjustLevels = true;
  self.histogramCutoff = 2;
  self.convertProfile = true;
  //self.nrAction = "Normal";
  self.nrActionSet = "ISO PS NR.atn";

  self.setBitDepth = function(depth) {
    switch (depth) {
      case BitsPerChannelType.ONE: this.bitDepth = 1; break;
      case BitsPerChannelType.EIGHT: this.bitDepth = 8; break;
      case BitsPerChannelType.SIXTEEN: this.bitDepth = 16; break;
      case BitsPerChannelType.THIRTYTWO: this.bitDepth = 32; break;
    }
  }
  self.getBitDepth = function() {
    var d = undefined;
    switch (this.bitDepth) {
      case 1:  d = BitsPerChannelType.ONE; break;
      case 8:  d = BitsPerChannelType.EIGHT; break;
      case 16: d = BitsPerChannelType.SIXTEEN; break;
      case 32: d = BitsPerChannelType.THIRTYTWO; break;
    }
    return d;
  }
  if (obj) {
    for (var idx in obj) {
      var v = obj[idx];
      if (typeof v != 'function') {
        self[idx] = v;
      }
    }
  }
};

ColorProfileNames = function ColorProfileNames() {};
ColorProfileNames.PROPHOTO_RGB = "ProPhoto RGB";
ColorProfileNames.ADOBE_RGB    = "Adobe RGB (1998)";
ColorProfileNames.APPLE_RGB    = "Apple RGB";
ColorProfileNames.SRGB         = "sRGB IEC61966-2.1";


Normalize = function() {};

Normalize.exec = function(doc, opts) {
  // we need to make this document the active document
  // because may be running actions later
  if (doc != app.activeDocument) {
    app.activeDocument = doc;
  }

  // Step 1: Save the file as a PSD and switch to it
  // step removed...

  // Step 2: Switch to RGB mode, if needed
  if (doc.mode != DocumentMode.RGB) {
    doc.changeMode(ChangeMode.RGB)
  }

  // Step 3: Assign/Convert the color profile to match the desired profile
  if (doc.colorProfileType == ColorProfile.NONE) {
    // Assign the doc to the Working Color Profile
    // but don't convert it
    doc.colorProfileType = ColorProfile.WORKING;
    if (doc.colorProfileName != opts.colorProfile) {
      throw "The working color profile must be adjusted to match: "
        + opts.colorProfile;
    }

  } else {
    var profName = doc.colorProfileName;
    if (profName != opts.colorProfile) {
      // this stunt gets us the name of the
      // profile name for the WORKING space
      doc.colorProfileType = ColorProfile.WORKING;
      var workingProfile = doc.colorProfileName;
      doc.colorProfileName = profName;
      
      if (workingProfile != opts.colorProfile) {
        throw "The working color profile must be adjusted to match: "
          + opts.colorProfile;
      }
      
      // Convert or Assign the doc to the Working Color Profile
      // if the profile is really different
      if (doc.colorProfileType == ColorProfile.CUSTOM) {
        if (opts.colorProfile != profName) {
          if (opts.convertProfile) {
            // Convert
            doc.convertProfile(opts.colorProfile,
                               Intent.RELATIVECOLORIMETRIC,
                               true, false, false);
          } else {
            // Assign
            doc.colorProfileType = ColorProfile.WORKING;
          }
        }
      }
    }
  }
    
  // Step 4: Set the bit depth
  doc.bitsPerChannel = opts.getBitDepth();

  // Step 4.5: Noise Reduction (optional)
  if (opts.nrAction) {
    app.doAction(opts.nrAction, opts.nrActionSet);
  }

  // Step 5: Resize (optional)
  if (opts.maxSize > 100) {
    Normalize.pscsFit(doc, opts.maxSize, opts.maxSize);
  }

  // Step 6: Adjust Levels
  if (opts.adjustLevels) {
    Levels.autoAdjustRGBChannels(doc, opts.histogramCutoff);
  }
  
  // Step 6.5 USM Haze
  // fix later...
  // app.doAction("USM Haze", "XUtils.atn");

  // Step 7: Save changes
  if (!doc.name.match(/\.psd$/i)) {
    var file = new File(doc.fullName.absoluteURI.replace(/\.[^\.]+$/, ".psd"));
    doc.saveAs(file, Normalize.defaultPSDOptions(), true);
    Normalize.revertDocument(doc);
  } else {
    doc.saveAs(file, Normalize.defaultPSDOptions());
  }
};
Normalize.defaultPSDOptions = function() {
  var opts = new PhotoshopSaveOptions();
  opts.alphaChannels = true;
  opts.annotations = true;
  opts.embedColorProfile = true;
  opts.layers = true;
  opts.maximizeCompatibility = true;
  opts.spotColors = true;
  return opts;
};
Normalize.pscsFit = function(doc, width, height) {
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
Normalize.revertDocument = function(doc) {
  executeAction(cTID("Rvrt"), new ActionDescriptor(), DialogModes.NO);
};

MetadataOptions = function(obj) {
  var self = this;

  self.title = "New Years Eve ";
  self.copyrighted   = CopyrightedType.COPYRIGHTEDWORK;
  self.copyrightNotice = "©Buckaroo Banzai";
  self.city = "New Orleans";
  self.country = "USA";
  self.keywords = new Array('New Years Eve', 'Les Bon Temps Roule');
  self.provinceState = "LA";

  if (obj) {
    for (var idx in obj) {
      var v = obj[idx];
      if (typeof v != 'function') {
        self[idx] = v;
      }
    }
  }
};

Metadata = function() {};

//
// I typically store files in a directory like 2004-10-31. This
// code looks for that formate and converts it to 20041031 which
// is the format that PSCS expects for its creationDate field
//
Metadata.cnvtDate = function(str) {
  var d;
  if (str.length == 10 && str.charAt(4) == '-' && str.charAt(7) == '-') {
    return str.replace(/-/g, '');
  }
  return undefined;
};

Metadata.exec = function(doc, opts) {
  var cdate = Metadata.cnvtDate(doc.path.name);
  if (cdate) {
    opts.creationDate = cdate;
    opts.title += doc.path.name;
  } else {
    opts.title += doc.name.substr(0, doc.name.lastIndexOf("."));
  }

  for (var idx in opts) {
    var p = opts[idx];
    if (typeof p != "function") {
      doc.info[idx] = p;
    }
  }
};


function main() {
  if (isPS7()) {
    alert("This script will not run in PS7.");
    return;
  }
  if (!app.documents.length) {
    alert("Please open a document before running this script.");
    return;
  }


  var doc = app.activeDocument;

  // first, update the metadata
  var mdopts = new MetadataOptions();
  Metadata.exec(doc, mdopts);

  // then 'normalize' the image
  var opts = new NormalizeOptions();
  opts.histogramCutoff = 4; // move the upper and lower level sliders
                            // until a pixel count greater than 4 is reached.
                            // in otherwords, trim the histogram tails
  opts.maxSize = 0;         // max width/height 0 == don't resize
  
  Normalize.exec(doc, opts);
};

main();

"Normalize.js";
// EOF

