//
// XWatermark.js
// Adds a watermark to a document. Lots of options. In its default mode
// it expects a shape called 'Watermark Shape' and a style 'Watermark Style'
//
// $Id: XWatermark.jsx,v 1.22 2015/08/30 21:04:36 anonymous Exp $
// Copyright: (c)2005, xbytor
// License: http://www.opensource.org/licenses/bsd-license.php
// Contact: xbytor@gmail.com
//
/* 
<javascriptresource>
   <name>XWatermark v1.0...</name>
   <menu>automate</menu>
   <category>xtools</category>

   <about>XWatermark: A flexible watermarking script.
$Revision: 1.22 $
Copyright: (c)2008, xbytor
License: http://www.opensource.org/licenses/bsd-license.php
Contact: xbytor@gmail.com</about>
   <eventid>aa857e40-591a-11dd-ae16-0800200c9a66</eventid>
   <terminology></terminology>
</javascriptresource>
*/
//
//@show include
//
app;
//
//@includepath "/c/Program Files/Adobe/xtools;/Developer/xtools"
//
//@include "xlib/stdlib.js"
//@include "xlib/GenericUI.jsx"
//@include "xlib/ColorChooser.jsx"
//@include "xlib/ColorSelectorPanel.jsx"
//@include "xlib/PresetsManager.jsx"
//@include "xlib/WatermarkUI.jsx"
//@include "xlib/Stream.js"
//@include "xlib/ShapesFile.js"
//@include "xlib/metadata.js"
//@include "xlib/XBridgeTalk.jsx"
//@include "xlib/PreviewWindow.jsx"
//@include "xlib/Styles.js"
//@include "xlib/PSCCFontSizeBugFix.jsx"
//

// override the default log and ini files
WatermarkUIOptions.LOG_FILE = Stdlib.PREFERENCES_FOLDER + "/xwatermark.log";
WatermarkUIOptions.INI_FILE = Stdlib.PREFERENCES_FOLDER + "/xwatermark.ini";

WatermarkUI.bridgeFiles = [];

XWatermark = function() {
};

XWatermark.main = function() {
  try {
    Stdlib.log.setFile(WatermarkUIOptions.LOG_FILE);
    XWatermark._main(desc);

  } catch (e) {
    Stdlib.logException(e, true);
  }
};
XWatermark.main = function() {
  // This start up logic may not cover everything, but it's good enough
  // for now...
  //
  // For app.displayDialogs
  // ALL - direct exec (menu/browse) or from action with dialogs
  // ERROR - from action no dialogs
  // NO - from debugger
  //
  var mode = app.playbackDisplayDialogs;

  // if we are launched from the debugger OR we have no parameters
  // we need a UI
  if (mode == DialogModes.NO || app.playbackParameters.count == 0) {
    mode = DialogModes.ALL;
  }

  // only turn off the ui if we have parameters and are called from an action
  var noUI = (app.playbackDisplayDialogs == DialogModes.ERROR);

  var binFile;

  // now set up our options based on the parameters
  // for use with Adobe Automation framework
  var desc;

  var wmKey = sTID('WatermarkOptions');

  var embedded = {};

  var ini = GenericUI.readIni(WatermarkUIOptions.INI_FILE)

  ini.noUI = noUI;

  var opts = new WatermarkUIOptions(ini);

  if (app.playbackParameters.count > 0) {
    // Playback parameters can come from an Action playback or
    // from a Bridge remote call

    var desc = app.playbackParameters;

    if (desc.hasKey(wmKey)) {
      var str = desc.getString(wmKey);
      opts = Stdlib.fromIniString(str, opts);
    }

    opts.noUI = noUI;

//     if (opts.calledFromBridge) {
//       opts.filesList = XBridgeTalk.getBridgeSelection();
//     }

    opts.embedded = (desc.hasKey(sTID('EmbeddedMode')) &&
                     desc.getBoolean(sTID('EmbeddedMode')));
    opts.configUI = (desc.hasKey(sTID('ConfigUI')) &&
                     desc.getBoolean(sTID('ConfigUI')));
    opts.apply = (desc.hasKey(sTID('Apply')) &&
                  desc.getBoolean(sTID('Apply')));

    if (desc.hasKey(sTID('BinFile'))) {
      binFile = desc.getPath(sTID('BinFile'));
    }

    if (desc.hasKey(sTID('filesList'))) {
      var files = [];
      var flist = app.playbackParameters.getList(sTID('filesList'));

      for (var i = 0; i < flist.count; i++) {
        files.push(flist.getPath(i));
      }

      opts.filesList = files;
    }

    // $.level = 1; debugger;
    opts.noUI = (opts.noUI && !opts.configUI);

  } else {
    // If we don't have any parameters, we need a UI
    // opts.noUI = false;
  }

  if (!opts.noUI) {
    app.bringToFront();
    app.displayDialogs = DialogModes.ERROR;

  } else {
    app.displayDialogs = DialogModes.NO;
  }

  var doc = (app.documents.length ? app.activeDocument : undefined);
  var ui = new WatermarkUI(opts);

  if (opts.embedded) {
    ui.iniFile = undefined;
    ui.saveIni = false;

    var xopts = opts;

    if (opts.configUI) {
      xopts = ui.exec(opts);
    }

    if (opts.apply && xopts) {
      xopts.rationalize();

      if (opts.filesList) {
        var files = opts.filesList;
        for (var i = 0; i < files.length; i++) {
          var file = files[i];
          var doc = app.open(file);
          ui.applyWatermark(xopts, doc);
          doc.close(SaveOptions.SAVECHANGES);
        }

      } else {
        ui.applyWatermark(opts, doc);
      }
    }

    opts = xopts;

  } else {
    opts = ui.exec(opts, doc);

    if (opts) {
      if (doc) {
        ui.applyWatermark(opts, doc);
      }
      
      if (ui.saveIni) {
        ui.updateIniFile({ uiX: ui.winX, uiY: ui.winY });
      }
    }
  }

  if (!opts) {
    return;
  }

  if (opts) {
//     if (opts.color.constructor != String) {
//       opts.color = Stdlib.rgbToString(opts.color);
//     }
//     var desc = new ActionDescriptor();
//     var str = Stdlib.toIniString(opts);
//     desc.putString(wmKey, str);

//     alert(listProps(opts));

    var desc = opts.toDescriptor();
    desc.putString(cTID('Msge'), "Settings for XWatermark Script");
    app.playbackParameters = desc;

    if (binFile) {
      Stdlib.writeDescriptor(binFile, desc);
//       alert("Stored settings to: " + binFile.toUIString());
    }
 }
};

XWatermark.main();

// app.playbackParameters = new ActionDescriptor();

"XAddWatermark.jsx";
// EOF

