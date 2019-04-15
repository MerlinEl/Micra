//
// OnOpenEvent
//   My default color profile is ProPhoto. However, I do a lot of work with
//   JPEGs which means either getting warnings when I open a JPEG or getting
//   the image rendered with the wrong color profile.
//
//   This script, which is intended to be registered via the Script Event 
//   Manager, addresses this problem by checking to see if the file being
//   opened:
//      1) is a JPEG and
//      2) doesn't have a profile associated with it.
//   If both conditions are true, I assign it to sRGB (which will almost always
//   be the correct thing to do).
//
// $Id: OnOpenEvent.jsx,v 1.8 2010/03/29 02:23:23 anonymous Exp $
// Copyright: (c)2008, xbytor
// License: http://www.opensource.org/licenses/bsd-license.php
// Contact: xbytor@gmail.com
//
function main() {
  try {
    var doc = app.activeDocument;
    var sRGB = "sRGB IEC61966-2.1";
    if (doc.name.match(/\.jpg$/i) && doc.mode == DocumentMode.RGB) {
      if (doc.colorProfileType == ColorProfile.NONE) {
//         doc.convertProfile(sRGB, Intent.RELATIVECOLORIMETRIC, true, false);
//         alert("Converted profile");

        doc.colorProfileName = sRGB;
//         alert("Assigned profile");
      }
    }
  } catch (e) {
  }
};

// var desc = arguments[0];
// var eventID = arguments[1];
main();

"OnOpenEvent.jsx";
// EOF
