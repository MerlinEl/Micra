------------------------------------------------------------------------------------------
MAXScript Editor - Autocompletion | Tools / Global Options File  
------------------------------------------------------------------------------------------

:::Generate Api File >
createMaxscriptApiFileDotnet.ms


:::Modify
C:\Program Files\Autodesk\3ds Max 2014\MSX_Editor.properties

colour.string.verbatim=fore:#CB7A7A
# Autocomplete
autocompleteword.automatic=1
autocomplete.*.ignorecase=1
autocomplete.choose.single=0
autocomplete.*.start.characters=$(chars.alpha)$(chars.numeric)$_@#.
api.*.ms=maxscript.api
 
# Editor Behavior
# home key goes to far left beginning of line
vc.home.key=0
# open up to 20 files at once
buffers=20
# show file tabs on multiple lines
tabbar.multiline=1
# highlighted a file name in a script and open that file using Ctrl-Shift-O
# I use this with files Im adding to a script using include or fileIn
openpath.*.ms=<my script functions folder>
open.suffix.*.ms=.ms
# Ctrl-O defaults to the directory of the currently active file
open.dialog.in.file.directory=1



:::you can use multiple api files like >
api.*.ms=maxscript.api;mytools.api;micra.api


------------------------------------------------------------------------------------------
MAXScript Editor - Customizing Syntax Color Schemes | Tools > Open MAXScript. properties
------------------------------------------------------------------------------------------



