#target photoshop
//
// RefreshCS3Presets
//
// $Id: RefreshCS3Presets.jsx,v 1.5 2010/03/29 02:23:23 anonymous Exp $
// Copyright: (c)2007, xbytor
// License: http://www.opensource.org/licenses/bsd-license.php
// Contact: xbytor@gmail.com
//
//
//@show include
//
//@includepath "/c/Program Files/Adobe/xtools;/Developer/xtools"

app.bringToFront();

isWindows = function() {
  return $.os.match(/windows/i);
};
isMac = function() {
  return !isWindows();
};

Config = function() {
};

//
// Set this to true if you want aliases/shortcuts created.
// Set this to false if you want the files copied.
//
Config.USE_ALIAS = true;


Config.determineUserPresets = function() {
  if (isWindows()) {
    return new Folder(app.preferencesFolder.parent + '/Presets');

  } else {
    var s1 = localize("$$$/private/AdobeSystemFolder/Adobe=Adobe");
    var s2 = localize("$$$/private/FolderNames/AdobePhotoshopProductVersionFolder");
    var s3 = localize("$$$/private/FolderName/UserPresetsFolder/Presets=Presets");
    
    return new Folder(Folder.userData + '/' + s1 + '/' + s2 + '/' + s3);
  }
};
Config.getFolders = function(folder) {
  return folder.getFiles(function(f) { return f instanceof Folder; });
};

Config.updateFiles = function(src, dest) {
  var files = src.getFiles();

  for (var i = 0; i < files.length; i++) {
    var file = files[i];
    
    if (file instanceof File) {
      var destFile = new File(dest + '/' + file.name);
      if (!destFile.exists) {
        if (Config.USE_ALIAS) {
          var rc = destFile.createAlias(file.toString());
          if (!rc) {
            alert("Failed to create alias " + decodeURI(destFile) + ':' +
                  file.error + '.');
            return rc;
          }
        } else {
          var rc = file.copy(destFile);
          if (!rc) {
            alert("Failed to copy " + decodeURI(destFile) + ':' +
                  file.error + '.');
            return rc;
          }
        }
      }
    } else {
      var fname = file.name.replace(':', '-');
      var destFolder = new Folder(dest + '/' + fname);
      if (!destFolder.exists) {
        var rc = destFolder.create();
        if (!rc) {
          alert("Failed to create " + decodeURI(destFolder) + ':' +
                destFolder.error + '.');
          return rc;
        }
      }
      var rc = Config.updateFiles(file, destFolder);
      if (!rc) {
        return rc;
      }
    }
  }
  return true;
};

Config.appPresets = new Folder(app.path + '/Presets');
Config.userPresets = Config.determineUserPresets();

function main() {
  if (!Config.appPresets.exists) {
    alert("Cannot determine PSCS3 Application Presets folder.");
    return;
  }
  if (!Config.userPresets.exists) {
    alert("Cannot determine PSCS3 User Presets folder.");
    return;
  }

  var userFolders = Config.getFolders(Config.userPresets);

  for (var i = 0; i < userFolders.length; i++) {
    var userFolder = userFolders[i];
    var appFolder = new Folder(Config.appPresets + '/' + userFolder.name);
    if (appFolder.exists) {
      Config.updateFiles(appFolder, userFolder);
    }
  }
};

main();

"RefreshCS3Presets.jsx";
// EOF
