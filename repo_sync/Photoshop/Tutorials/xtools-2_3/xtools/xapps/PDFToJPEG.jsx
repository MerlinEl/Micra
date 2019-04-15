//
// PDFToJPEG.jsx
//
// $Id: PDFToJPEG.jsx,v 1.2 2010/03/29 02:23:23 anonymous Exp $
// Copyright: (c)2008, xbytor
// License: http://www.opensource.org/licenses/bsd-license.php
// Contact: xbytor@gmail.com
//
app;
//
//@show include
//
//@includepath "/c/Program Files/Adobe/xtools;/Developer/xtools"
//
//@include "xlib/stdlib.js"
//

var JPEG_QUALITY = 8;
var PADDING = 3;

function _zeroPad(str) {
  str = str.toString();
  while (str.length < PADDING) {
    str = "0" + str;
  }
  return str;
};

function main() {
  var file = Stdlib.selectFileOpen("Choose a PDF file",
    Stdlib.createFileSelect("PDF Files: *.pdf"));

  if (!file) {
    return;
  }

  var folder = Stdlib.selectFolder("Select an output folder", file.parent);

  if (!folder) {
    return;
  }

  var opts = new PDFOpenOptions();
  opts.page = 1;
  opts.usePageNumber = true;

  var saveOpts = new JPEGSaveOptions();
  saveOpts.quality = JPEG_QUALITY;

  var basename = file.strf("%f");

  var mode = app.displayDialogs;
  app.displayDialogs = DialogModes.NO;

  try {
    while (true) {
      try {
        var doc = app.open(file, opts);

      } catch (e) {
        return;
      }

      var f = new File(folder + '/' + basename + '-' +
                       _zeroPad(opts.page) + ".jpg");

      doc.saveAs(f, saveOpts, true);
      doc.close(SaveOptions.DONOTSAVECHANGES);
      opts.page++;
    }
  } catch (e) {
  }

  app.displayDialogs = mode;
};

main();

"PDFToJPEG.jsx";
// EOF