//
// XMPTools.jsx
//
// $Id: XMPTools.jsx,v 1.25 2015/12/01 23:56:10 anonymous Exp $
// Copyright: (c)2008, xbytor
// License: http://www.opensource.org/licenses/bsd-license.php
// Contact: xbytor@gmail.com
//
//@show include
//
//
//@includepath "/c/Program Files/Adobe/xtools;/Developer/xtools"
//
//-include "xlib/XMPNameSpaces.jsx"

// This code does not work in PSCS3 but may work in Bridge CS3
// It has been tested in BridgeCS4 and PSCS4

// To use most of the functions in this file, you will need
// to call XMPTools.loadXMPScript() first.

XMPTools = function() {
};

XMPTools.ERROR_CODE = 9005;
XMPTools.IO_ERROR_CODE = 9002;  // same as Stdlib.ERROR_CODE

XMPTools.APPEND_ON_COPY = 1;  // append array items
XMPTools.REMOVE_ON_COPY = 2;  // always remove existing property value
XMPTools.ON_COPY_DEFAULT = XMPTools.APPEND_ON_COPY;

XMPTools.isBridge = function() {
  return app.name.match(/bridge/i);
};
XMPTools.isPhotoshop = function() {
  return app.name.match(/photoshop/i);
};

XMPTools.isCompatible  = function() {
  var ver = Number(app.version.split('.')[0]);
  return ((XMPTools.isPhotoshop() && ver >= 11) ||
          (XMPTools.isBridge() && ver >= 2));
};

XMPTools.loadXMPScript = function() {
  if (!XMPTools.isCompatible()) {
    Error.runtimeError(XMPTools.ERROR_CODE,
                       "This version of " + app.name +
                       " is not compatible with XMPScript.");
  }
  if (!ExternalObject.AdobeXMPScript) {
    ExternalObject.AdobeXMPScript = new ExternalObject('lib:AdobeXMPScript');
  }

  return ExternalObject.AdobeXMPScript;
};

XMPTools.unloadXMPScript = function(){
  if (ExternalObject.AdobeXMPScript) {
    ExternalObject.AdobeXMPScript.unload();
    ExternalObject.AdobeXMPScript = undefined;
  }
};

XMPTools.getMetadataFromBridge = function(files, timeout) {
  var br = "bridge";
  if (!BridgeTalk.isRunning(br)) {
    Stdlib.log("Bridge is not running.");
    return undefined;
  }

  if (isCS2()) {
    Error.runtimeError(Stdlib.ERROR_CODE,
                       "XMPTools.getMetadataFromBridge does not work in CS2");
  }

  if (!timeout) {
    timeout = 1000 * 30; // 30 seconds
  }

  var isFile = false;
  if (!(files instanceof Array)) {
    if (!(files instanceof File)) {
      Error.runtimeError(19, files);
    }
    files = [files];
    isFile = true;
  }

  function getMetadata(files) {
    var mds = [];
    for (var i = 0; i < files.length; i++) {
      var t = new Thumbnail(files[i]);
      mds.push(t.synchronousMetadata.serialize());
    }
    return mds.toSource();
  }

  var src = getMetadata.toSource();

  var brCode = ("function _run(files) {\n" +
                 "  var getMetadata = " + src + ";\n\n" +
                 "  return getMetadata(files);\n" +
                "};\n" +
                "_run(" + files.toSource() + ");\n");

  Stdlib.log("XMPTools.getMetadataFromBridge()");

  var bt = new BridgeTalk();
  bt.target = br;
  bt.body = brCode;
  var str = bt.sendSync(timeout);
  var res = (str ? eval(str) : '');

  Stdlib.log(res);

  return ((isFile && res && res.length == 1) ? res[0] : res);
};


// Return the XMPMeta object for the file(s)
XMPTools.loadMetadata = function(files) {

  function _loadMetadata(file) {
    if (!file.exists) {
      Error.runtimeError(XMPTools.IO_ERROR_CODE,
                         "File does not exist: " + file.absoluteURI);
    }

    var fstr = decodeURI(file.fsName);

    var xmp;

    try {
      var xmpFile = new XMPFile(fstr, XMPConst.UNKNOWN,
                                XMPConst.OPEN_FOR_READ);
      xmp = xmpFile.getXMP();
    } catch (e) {
    }

    if (!xmp) {
      try {
        var xmpFile = new XMPFile(fstr, XMPConst.UNKNOWN,
                                  XMPConst.OPEN_ONLY_XMP);
        xmp = xmpFile.getXMP(); 
      } catch (e) {
      }
    }
    if (!xmp) {
      try {
        var xmpFile = new XMPFile(fstr, XMPConst.UNKNOWN,
                                  XMPConst.OPEN_USE_PACKET_SCANNING);
        xmp = xmpFile.getXMP();
      } catch (e) {
      }
    }

    // try to read from a possible XMP sidecar
    if (!xmp) {
      // this is needed because of a bug in CC2015+
      var xfile = File(file.strf("%d/%f.xmp"));
      var str = "";
      
      if (xfile.exists) {
        try {
          var xml = Stdlib.readXMLFile(xfile);
          xmp = new XMPMeta(xml.toXMLString());
        } catch (e) {
        }
      }
    }

    // Try using Bridge
    if (!xmp) {
      var xml = XMPTools.getMetadataFromBridge(file);
      if (xml) {
        xmp = new XMPMeta(xml);
      }
    }

    if (!xmp) {
      var str = "XMPFile exception prologue:\n";
      var props = ["absoluteURI", "alias", "displayName", "exists",
                   "fsName", "fullName", "hidden", "length",
                   "localizedName", "readonly"];
      for (var i = 0; i < props.length; i++) {
        var nm = props[i];
        str += (nm + ": " + file[nm] + "\n");
      }
      
      Stdlib.log(str + "\n\n" );
      
      return undefined;
    }

    return xmp;
  };

  if (!(files instanceof Array)) {
    if (!(files instanceof File)) {
      Error.runtimeError(19, files);
    }

    return _loadMetadata(files);
  }

  var mds = [];

  for (var i = 0; i < files.length; i++) {
    var file = files[i];
    if (!(file instanceof File)) {
      Error.runtimeError(19, file);
    }
    mds.push(_loadMetadata(file));
  }

  return mds;
};

// Names can be in whatever format,
// Returns an array of values for the names
//
XMPTools.getMetadataValue = function(xmpMeta, name) {
  var property = XMPTools.getMetadataValues(xmpMeta, [name]);
  var val = '';
  if (property) {
    for (var idx in property) {
      val = property[idx];
      break;
    }
  }
  return val;
};
XMPTools.getMetadataValues = function(xmpMeta, names) {
  if (!xmpMeta) {
    Error.runtimeError(2, "xmpMeta");
  }

  if (!names) {
    Error.runtimeError(2, "names");
  }

  if (xmpMeta.constructor == String) {
    xmpMeta = new XMPMeta(xmpMeta);
  }

  if (!(xmpMeta instanceof XMPMeta)) {
    Error.runtimeError(19, "xmpMeta");
  }

  var multi = true;
  if (!(names instanceof Array)) {
    names = [names];
    multi = false;
  }

  var qnames = [];

  // convert the names/tags to qnames
  for (var i = 0; i < names.length; i++) {
    var name = names[i];
    var obj = {};
    var qname;

    if (name instanceof QName) {
      qname = name;

    } else if (name.contains(':')) {
      var ar = name.split(':');

      if (ar.length == 2) {
        // we have a namespace and a property name
        // tiff:Artist
        qname = XMPNameSpaces.getQName(name);

      } else if (ar[0].indexOf('http') == 0) {
        var namespace = '';
        var pname = '';

        // we have a URI
        // http://ns.adobe.com/tiff/1.0/:Artist
        ar = name.split('/');
        pname = ar.pop();
        while (pname[0] == ':') {
          pname = pname.substring(1);
        }
        namespace = ar.join('/');
        if (!namespace.endsWith('/')) {
          namespace += '/';
        }
        qname = new QName(namespace, pname);

      } else {
        Error.runtimeError(19, "name");
      }

    } else {
      // we just have a property name
      // get the first namespace that has a property with this name
      qname = XMPNameSpaces.getQName(name);
    }

    qnames[i] = qname;
  }


  var obj = {};

  for (var i = 0; i < qnames.length; i++) {
    var qname = qnames[i];
    var property;
    var name;

    if (qname != undefined) {
      property = xmpMeta.getProperty(qname.uri, qname.localName);
      name = XMPNameSpaces.convertQName(qname);
    } else {
      obj[names[i]] = '';
      continue;
    }

    if (property) {
      var str = XMPTools.xmpPropertyAsString(xmpMeta, qname.uri,
                                             qname.localName,
                                             property);
      obj[name] = (str || '');

    } else {
      obj[name] = '';
    }
  }

  return obj;
};

XMPTools.setMetadataValue = function(xmpMeta, tag, value) {
  var obj = {};
  obj[tag] = value;
  XMPTools.setMetadataValues(xmpMeta, obj);
};

XMPTools.setMetadataValues = function(xmpMeta, obj) {
  if (!xmpMeta) {
    Error.runtimeError(2, "xmpMeta");
  }

  if (typeof obj != "object") {
    Error.runtimeError(2, "obj");
  }

  if (xmpMeta.constructor == String) {
    xmpMeta = new XMPMeta(xmpMeta);
  }

  if (!(xmpMeta instanceof XMPMeta)) {
    Error.runtimeError(19, "xmpMeta");
  }

  var qnames = [];
  // convert the names/tags to qnames
  for (var idx in obj) {
    var val = obj[idx];

    if (!val) {
      continue;
    }

    var qname = XMPNameSpaces.getQName(idx);

    // Probably need to handle alt-lang constructs as well
    if (val instanceof Array) {
      // This appends items to an existing array or creates a new one.
      for (var i = 0; i < val.length; i++) {
        var v = val[i];
        xmpMeta.appendArrayItem(qname.uri, qname.localName, v, 0,
                                XMPConst.ARRAY_IS_ORDERED);
      }
    } else {
      xmpMeta.deleteProperty(qname.uri, qname.localName);
      xmpMeta.setProperty(qname.uri, qname.localName, val);
    }
  }
};

XMPTools.xmpPropertyAsString = function(xmpMeta, ns, pname, property) {
  var opts = property.options;
//   $.level = 1; debugger;

  function encodeValue(v) {
    var n = toNumber(v);
    if (!isNaN(n)) {
      return n;
    }
    if (v.toLowerCase() == 'true' || v.toLowerCase() == 'false') {
      return toBoolean(v);
    }

    return v;
  }

  if (opts == 0) {
    return encodeValue(property.value);
  }

  if (opts & XMPConst.PROP_IS_ARRAY) {
    var isMulti = (xmpMeta.countArrayItems(ns, pname) > 1);
    var str = (isMulti ? "[" : "");
    var q = (isMulti ? '"' : '');

    if (opts & XMPConst.ARRAY_IS_ORDERED) {
      if (opts & XMPConst.ARRAY_IS_ALTERNATIVE) {
        str += xmpMeta.getLocalizedText(ns, pname, null, "en-US");

      } else {
        if (isMulti) {
          // Change to use XMPIterator
          str += XMPUtils.catenateArrayItems(xmpMeta, ns, pname, '; ', q,
                                             XMPConst.SEPARATE_ALLOW_COMMAS);
        } else {
          str = xmpMeta.getArrayItem(ns, pname, 1);
        }
      }
    } else {
      if (isMulti) {
        // Change to use XMPIterator
        str += XMPUtils.catenateArrayItems(xmpMeta, ns, pname, '; ', q,
                                           XMPConst.SEPARATE_ALLOW_COMMAS);
      } else {
        str = xmpMeta.getArrayItem(ns, pname, 1);
      }
    }

    return str + (isMulti ? "]" : '');
  }

  if (opts == XMPConst.PROP_IS_STRUCT) {
    var str = "{ ";
    var itr = xmpMeta.iterator(XMPConst.ITERATOR_JUST_CHILDREN, ns, pname);
    var prop = itr.next();

    while (prop != null) {
      var fname = prop.path.split(':').pop();
      var fprop = xmpMeta.getStructField(ns, pname, prop.namespace, fname);
      str += fname + ': ' + XMPTools.xmpPropertyAsString(xmpMeta,
                                                         prop.namespace,
                                                         prop.path, fprop);

      prop = itr.next();
      if (prop) {
        str += ", ";
      }
    }

    return str + " }";
  }

  return '';
};

XMPTools.xmpPropertyAsObject = function(xmpMeta, ns, pname, property) {
  var obj = undefined;
  // ???
  return obj;
};

XMPTools.copyProperty = function(src, dest, ns, name, opts) {
  if (opts == undefined) {
    opts = XMPTools.ON_COPY_DEFAULT;
  }
  if (opts & XMPTools.REMOVE_ON_COPY) {
    dest.deleteProperty(ns, name);
  }
  var prop = src.getProperty(ns, name);

  if (!prop) {
    return false;
  }

  dest.deleteProperty(ns, name);
  XMPUtils.duplicateSubtree(src, dest, ns, name, ns, name);
  return true;
};

XMPTools.copyProperties = function(src, dest, qnames, opts) {
  if (opts == undefined) {
    opts = XMPTools.ON_COPY_DEFAULT;
  }
  for (var i = 0; i < qnames.length; i++) {
    var qname = qnames[i];
    var namespace = qname.uri;
    var pname = qname.localName;

    XMPTools.copyProperty(src, dest, namespace, pname, opts);
  }
};

XMPTools.copyMetadataValues = function(src, dest, tags, opts) {
  if (opts == undefined) {
    opts = XMPTools.ON_COPY_DEFAULT;
  }

  var qnames = [];
  for (var i = 0; i < tags.length; i++) {
    var tag = tags[i];

    // verify the XMP tag
    var qname = XMPNameSpaces.getQName(tag);
    if (!qname) {
      Error.runtimeError("Bad metadata tag: " + tag);
    }
    qnames.push(qname);
  }

  XMPTools.copyProperties(src, dest, qnames, opts);
};


// src - File or String that is a File path
// based on code from Paul Riggot
// https://forums.adobe.com/message/5036820#5036820
//
XMPTools.removeAllMetadata = function(src) {
  var file;

  if (!src) {
    Error.runtimeError(2, "src");
  }

  if (src instanceof File) {
    file = src;

  } else if (src.constructor == String) {
    file = new File(src);
  }

  if (!(file instanceof File)) {
    Error.runtimeError(19, "src");

  } else if(!file.exists) {
    Error.runtimeError(48, "src");
  }

  var xmpFile = new XMPFile(file.fsName, XMPConst.UNKNOWN,
                            XMPConst.OPEN_FOR_UPDATE);
  
  var xmpMeta = xmpFile.getXMP();

  XMPUtils.removeProperties(xmpMeta, "", "", XMPConst.REMOVE_ALL_PROPERTIES);

  if (xmpFile.canPutXMP(xmpMeta)) {
    xmpFile.putXMP(xmpMeta);
  }

  if (xmpFile) {
    xmpFile.close(XMPConst.CLOSE_UPDATE_SAFELY);
  }
};

//include "xlib/stdlib.js"
//include "xlib/XMPNameSpaces.jsx"

XMPTools.test = function() {
  if (!XMPTools.isCompatible()) {
    Error.runtimeError(XMPTools.ERROR_CODE,
                       "This version of " + app.name +
                       " is not compatible with XMPScript.");
  }

  XMPTools.loadXMPScript();

//   var f = new File(Folder.desktop + '/test.psd');

//   var xf = new XMPFile(f.absoluteURI,
//                        XMPConst.UNKNOWN,
//                        XMPConst.OPEN_FOR_UPDATE);


//   var f = new XMPFile("/tmp/test.psd",
//   var f = new XMPFile("/Users/xbytor/Desktop/images/spaceball.gif",
//     XMPConst.UNKNOWN,
//     XMPConst.OPEN_FOR_UPDATE);

  try {
    var testFolder = new Folder(XMPTools.test.FOLDER);
    var images = Stdlib.getImageFiles(testFolder);

    var image = images[0];
    var image = new File(XMPTools.test.FOLDER + "/test.psd");
    var md = XMPTools.loadMetadata(image);

    //alert(md.getProperty(XMPConst.NS_PHOTOSHOP, "ColorMode").value);
    //alert(XMPTools.getMetadataValue(md, 'photoshop:ColorMode'));

    alert(XMPTools.getMetadataValue(md, 'crs:ToneCurve'));
    alert(XMPTools.getMetadataValue(md, 'photoshop:ColorMode'));
    alert(XMPTools.getMetadataValue(md, 'Description'));
    alert(XMPTools.getMetadataValue(md, 'exif:Flash'));
    alert(XMPTools.getMetadataValue(md, 'xmpMM:History'));

//     alert(md.serialize(XMPConst.SERIALIZE_OMIT_PACKET_WRAPPER | XMPConst.SERIALIZE_USE_COMPACT_FORMAT ));
//     alert(md.dumpObject());

  } catch (e) {
    alert(Stdlib.exceptionMessage(e));
  }

  XMPTools.unloadXMPScript();
};

XMPTools.test.FOLDER = "~/Desktop/images";

//XMPTools.loadXMPScript();

// XMPTools.test();

"XMPTools.jsx";
// EOF
