//
// ImportImages.js
//   Imports images by the Create Date metadata field.
//   Folders for each day are created in the target directory.
//
// $Id: ImportImages.jsx,v 1.13 2014/11/27 05:51:24 anonymous Exp $
// Copyright: (c)2008, xbytor
// License: http://www.opensource.org/licenses/bsd-license.php
// Contact: xbytor@gmail.com
//
//@show include
//
app;
//
//@includepath "/c/Program Files/Adobe/xtools;/Developer/xtools"
//
//@include "xlib/stdlib.js"
//@include "xlib/XMPTools.jsx"
//@include "xlib/XMPNameSpaces.jsx"
//@include "xlib/GenericUI.jsx"
//@include "xlib/xexec.js"
//@include "xlib/XBridgeTalk.jsx"
//

var inFolder = new Folder(Folder.desktop + "/Incoming");
var outFolder = new Folder(Folder.desktop + "/Sorted");

var dateTag = 'CreateDate';

function main() {
  // We have to use Bridge because XMPTools does handle RAW
  // files very well.
  XBridgeTalk.startApplication("bridge");

  var files = Stdlib.getImageFiles(inFolder);
  if (!files) {
    alert("No files found in Incoming folder");
    return 0;
  }

  var dates = XBridgeTalk.getMetadataValue(files, dateTag, 100);

  var palette = GenericUI.createProgressPalette("Importing images", 0,
    files.length, undefined, true);

  var len = files.length;
  for (var i = 0; i < len; i++) {
    var file = files[i];
    var dateStr = dates[i];

    if (!dateStr) {
      var str = Exec.system("exiftool -j " + file.absoluteURI);
      var md = eval(str);

      dateStr = md[0].CreateDate;
    }

    palette.updateProgress(i);
    palette.text = "Importing %d of %s".sprintf(i, len);

    var date = Stdlib.parseISODateString(dateStr);
    var fname = date.strftime("%Y-%m-%d");
    var folder = new Folder(outFolder + '/' + fname);
    if (!folder.exists) {
      folder.create();
    }

    var ext = file.strf("%e").toLowerCase();
    var fname = file.strf("%f") + "." + ext;
    var name = fname.replace(/_DSC/, "DSC_");
    var outf;

    if (name.endsWith('nef')) {
      var nefFolder = new Folder(folder + '/nef');
      nefFolder.create();
      outf = new File(nefFolder + '/' + name);

    } else if (name.endsWith('jpg')) {
      var jpgFolder = new Folder(folder + '/jpg');
      jpgFolder.create();
      outf = new File(jpgFolder + '/' + name);

    } else {
      var f = new Folder(folder + '/' + ext);
      f.create();
      outf = new File(f + '/' + name);
    }

    file.copy(outf);
  }

  palette.close();

  XMPTools.unloadXMPScript();

  alert(i + " images imported");
};


main();

"ImportImages.jsx";
// EOF
