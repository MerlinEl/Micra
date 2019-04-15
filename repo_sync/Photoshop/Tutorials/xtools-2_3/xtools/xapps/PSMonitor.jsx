//
// PSMonitor.jsx
//
// $Id: PSMonitor.jsx,v 1.3 2010/03/29 02:23:23 anonymous Exp $
// Copyright: (c)2008, xbytor
// License: http://www.opensource.org/licenses/bsd-license.php
// Contact: xbytor@gmail.com
//

var MonitorOptions = {
  folder: "/c/temp/monitor",
  outFolder: "/c/temp/monitor/bak",
  minImageCount: 4,
  sleepInterval: 5,
  action: "ActionName",
  actionSet: "ActionSetName",
  stopFile: "stop.txt"
};

var ImageFileExtsComplete =
  "8bps,3ds,ai3,ai4,ai5,ai6,ai7,ai8,ai,arw,bmp,cin,cr2,crw,dae,dc2,dc3,dcr," +
  "dib,dic,dng,dpx,eps,epsf,epsp,erf,exr,fido,flm,gif,hdr,hrr," +
  "icb,jpeg?,jpg,kdc,kmz,m4v,mef,mfw,mos,mov,mp4,mpeg,mrw,nef,obj,orf,pam," +
  "pbm,pcd,pct,pcx,pdd,pdf,pdp,pef,pict?,png,pm," +
  "ps(d|b)?,pxr,raf,raw,rgbe,rle,sct,sdpx,sr2,srf,tga,tiff?,u3d,vda,vst," +
  "wbmp?,x3f,xyze";

var ImageFileExtsCompleteRE =
  new RegExp("\\.(" +
             ImageFileExtsComplete.replace(/,/g, '|') + ")$", 'i');

ImageFileExtsCommon =
  "psd,pdd,jpeg?,jpg,png,8bps,gif,bmp,rle,dib,tiff?,raw,dng,crw,nef,raf,orf";

ImageFileExtsCommonRE =
  new RegExp("\\.(" +
             ImageFileExtsCommon.replace(/,/g, '|')
             + ")$", 'i');

//
// createProgressPalette
//   title     the window title
//   min       the minimum value for the progress bar
//   max       the maximum value for the progress bar
//   parent    the parent ScriptUI window (opt)
//   useCancel flag for having a Cancel button (opt)
//
//   onCancel  This method will be called when the Cancel button is pressed.
//             This method should return 'true' to close the progress window
//
function createProgressPalette(title, min, max,
                              parent, useCancel) {
  var win = new Window('palette', title);

  if (max > min) {
    win.bar = win.add('progressbar', undefined, min, max);
    win.bar.preferredSize = [300, 20];

  } else {
    win.message = win.add('statictext');
    win.message.preferredSize = [300, 20];
  }

  win.parentWin = undefined;
  win.recenter = false;
  win.isDone = false;

  if (parent) {
    if (parent instanceof Window) {
      win.parentWin = parent;
    } else if (useCancel == undefined) {
      useCancel = !!parent;
    }
  }

  if (useCancel) {
    win.onCancel = function() {
      this.isDone = true;
      return true;  // return 'true' to close the window
    }

    win.cancel = win.add('button', undefined, 'Cancel');

    win.cancel.onClick = function() {
      var win = this.parent;
      try {
        win.isDone = true;
        if (win.onCancel) {
          var rc = win.onCancel();
          if (rc != false) {
            win.close();
          }
        } else {
          win.close();
        }
      } catch (e) {
        alert(e);
      }
    }
  }

  win.onClose = function() {
    this.isDone = true;
    return true;
  }

  win.updateProgress = function(val) {
    var win = this;

    if (win.bar) {
      win.bar.value = val;

    } else {
      win.message.text = val;
    }

    if (win.recenter) {
      win.center(win.parentWin);
    }

    win.show();
    win.hide();
    win.show();
  }

  win.recenter = true;
  win.center(win.parent);

  return win;
};

function main() {
  var folder = Folder(MonitorOptions.folder);
  if (!folder.exists) {
    alert("Folder " + decodeURI(folder.fsName) + " does not exist.");
    return;
  }
  var outFolder = Folder(MonitorOptions.outFolder);
  if (!outFolder.exists) {
    alert("Output Folder " + decodeURI(outFolder.fsName) + " does not exist.");
    return;
  }

  var stopFile = File(folder + '/' + MonitorOptions.stopFile);
  var progressBar = createProgressPalette("PSMonitor", 0, 0, undefined, true);
  var napTime = MonitorOptions.sleepInterval * 1000;

  progressBar.updateProgress("PSMonitor");

  while (true) {
    if (progressBar.isDone || stopFile.exists) {
      break;
    }
    var files = folder.getFiles(ImageFileExtsCommonRE);

    if (files.length >= MonitorOptions.minImageCount) {
      for (var i = 0; i < files.length; i++) {
        if (progressBar.isDone || stopFile.exists) {
          break;
        }

        var file = files[i];
        progressBar.updateProgress("Processing file:" + decodeURI(file.name));

        try {
          var doc = app.open(file);
        } catch (e) {
          continue;
        }

        try {
          app.doAction(MonitorOptions.action, MonitorOptions.actionSet);
        } catch (e) {
        }
        doc.close(SaveOptions.DONOTSAVECHANGES);

        var outFile = File(outFolder + '/' + file.name);
        var rc = file.copy(outFile);

        if (!rc) {
          alert("Failed to copy image to output folder.");
          return;
        }

        file.remove();

        delete outFile;
        delete doc;
        delete files[i];
      }

      $.gc();
      continue;
    }

    progressBar.updateProgress("Sleeping...");
    $.sleep(napTime);
  }
};

main();

"PSMonitor";
// EOF
