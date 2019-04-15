//
// UpdateMetadata
//    A basic script for updating metadata.
//
// $Id: UpdateMetadata.js,v 1.72 2015/12/03 22:01:33 anonymous Exp $
// Copyright: (c)2005, xbytor
// License: http://www.opensource.org/licenses/bsd-license.php
// Contact: xbytor@gmail.com
//
//@show include
//
//
var app; if (!app) app = this; // for PS7

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
  if (!app.documents.length) {
    alert("Please open a document before running this script.");
    return;
  }

  var doc = app.activeDocument;

  // update the metadata
  var mdopts = new MetadataOptions();
  Metadata.exec(doc, mdopts);
};

main();

"UpdateMetadata.js";
// EOF

