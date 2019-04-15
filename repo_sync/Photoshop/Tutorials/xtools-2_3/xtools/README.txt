README for xtools
$Id: README,v 1.8 2015/02/09 22:45:39 anonymous Exp $

This is the README file for XToolkit. I (xbytor, that is) am the author and
maintainer of the package. There are a couple of things that I bundled in
from other open source packages, and there are several ideas or code that
came from the good people at adobeforums.com on the Photoshop Script forums
as well as others on ps-scripts.com.

COPYRIGHT
This file contains copyright, copyleft, and license information for the files
in this package. There is nothing scary in there. Basically, you can use this
stuff however you want as long as you give credit where credit is due.

INSTALLATION
The instructions for installing this toolkit are here. It's pretty simple,
really. Just extract the zip file to a temp directory and run
xtools/xapps/Install.js from inside Photoshop and you'll be all set.
If not, you can just move the unzipped xtools folder to a folder of
your choosing.
On OS X, the default installation folder is /Developer/xtools.
On Windows, the default installation folder is C:\Program Files\Adobe\xtools.

Enjoy. And remember:
"The Software shall be used for Good, not Evil."

xbytor@gmail.com
December, 2004
ChangeLog for xtools
	$Id: ChangeLog,v 1.22 2015/12/03 22:51:08 anonymous Exp $

v2.3
	Added support for sidecar xmp files in XMPTools.
	
	Added getDocumentTable to get the color table of an image in
	ColorTable.jsx.
	
	Added new error codes to PSError.jsx and localized strings.

	Added isCC2015().
	
	Miscellaneous fixes for CC2015 including a problem with
	Stdlib.wrapLCLayer.
	
	Added a large number of ZStrings to psx.jsx.

	I18N work on FileSavePanel.
	
	Fixed "ICCProfile" in XMPNameSpaces.jsx.
	
	SLCFix - now handles multi-line strings and checks to see
	if a match to /id/ matches a previously mapped variable name.

	Changed ActionXML Largeinteger to LargeInteger.

v2.2
	Fixed typo in Install.jsx.

	Extended Stdlib.getXMPValue() to support File objects with cavaets.

	Added speedups in Stream when writing files, esp Action files.

	Added fix for layer.resize bug.

	Added new function Stdlib.resizeLayer().

	Added support for DescValueType.LARGEINTEGERTYPE. This affects
	Stream and Action related library, and xapps/xapps scripts.

	Tweaked GetterDemo because of ScriptUI bug in CS6+. Will save to
	file if Application is selected.

	SLCFix code now replaces """ with ". This also affects LastLogEntry.
	There may be some edge cases where this breaks code, but it unbreaks
	far more SL generated code.

	Added isCC2014() and changed isCC().

	Minor tweaks to xapps/apps scripts to improve usability/UI.

	Unfixed Stdlib._selectFile for CS6+. The underlying bug has been
	taken care of in subsequent PS revs.

	Validated compatiblity back to CS4 for most xapps/apps scripts.

v2.1
	CC upgrade.

	Fixed font size bug.

	Added PSCCFontSizeBugFix.jsx.

	Fixed miscellaneous minor bugs.

v2.0
	Fixed bugs, added new stuff, added support for CS6.

	Fixed Stdlib._selectFile to work around openDlg and saveDlg mask bugs.

	Upgraded for DropletDecompiler for CS5+.

v1.5
	Added GenericUI.createProgressWindow().

	Extensive reworking of FileSaveOptions panel - GenericUI.jsx

	Fixed problem with ActionList output - atn2js.jsx

	Added ActionsPaletteFile.write, loadRuntime routines - atn2bin.jsx

	Added dumpAscii - Stream.js

	Added support for Alias for Mac paths - ActionStream.js

	Fixed Stdlib.hasAction to handle case where more than one action set
	has the same name.

	Fixed bug in Getter.jsx for the case when there is no Background layer.

EOF
