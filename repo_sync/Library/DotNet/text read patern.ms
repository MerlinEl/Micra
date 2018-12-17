--decode color patern
struct TEXT_DATA (pos, line, hex, clr)
user_file = getDir #maxData+"\\MXS_EditorUser.properties"
all_colors =#\
(
	"colour.global.back=",
	"colour.global.fore=",
	"colour.code.comment.line=",
	"colour.code.comment.box=",
	"colour.notused=",
	"colour.brace.highlight=",
	"colour.brace.incomplete=",
	"colour.indentationguide=",
	"colour.indentationguide=",
	"colour.linenumbers=",
	"colour.linenumbers=",
	"fold.margin.colour=",
	"fold.margin.highlight.colour=",
	"colour.whitespace=",
	"colour.number=",
	"colour.keyword=",
	"colour.reserved=",
	"colour.string=",
	"colour.string.verbatim=",
	"colour.string.open=",
	"colour.string.open=",
	"colour.char=",
	"colour.operator=",
	"colour.argument=",
	"colour.preproc=",
	"colour.pathname=",
	"colour.function=",
	"colour.class=",
	"colour.maxclass=",
	"colour.superclass=",
	"colour.coreinterface=",
	"colour.objectset=",
	"colour.struct=",
	"colour.constantglobals=",
	"colour.globals=",
	"colour.user=",
	"caret.fore=",
	"caret.line.back=",
	"selection.fore=",
	"selection.back="
)
alphaStr = "0123456789ABCDEF"
alphaArr = #("0","1","2","3","4","5","6","7","8","9","A","B","C","D","E","F")

fn findStringInArray arr str =
(
	for i=1 to arr.count where findString arr[ i ] str != undefined do return #( i, arr[ i ])
	return undefined
)
fn getItemColor str =
(
	local fs = FilterString str "#, ,"
	return fs[2]
)

fn hexToDec num = -- used to convert single hex bit to 0-255 color value
(
	n_ = findString alphaStr (substring num 1 1);
	_n = findString alphaStr (substring num 2 1);
	_n -= 1
	n_ -= 1
	return (n_ * 16 + _n);
)
function hexToRGB hex = -- converts HEX code to RGB code
(
	hex = substituteString hex "#" "" -- audits string for pound sign and deletes it
	hex = toUpper hex	
	local r = hexToDec (substring hex 1 2)
	local g = hexToDec (substring hex 3 2)
	local b = hexToDec (substring hex 5 2)
	return (color r  g  b)
)	

user_file_text = netFile.ReadAllLines user_file	
user_settings = #()
for c in all_colors do
(
	local d = (findStringInArray user_file_text c) 
	user_settings += #(TEXT_DATA pos:d[1] line:d[2])
)
for s in user_settings do 
(
	local hex ="#" + getItemColor s.line
	s. hex = hex
	s.clr = hexToRGB hex
)





/*

fn findLineByString fpath str =
(
	if fpath == undefined or not doesFileExist fpath do return false
	local lines = netFile.ReadAllLines fpath	
	for i=1 to lines.count where findString lines[ i ] str != undefined do return i
)


fn findAndReplaceLine fpath str new_str = --dotNet method
(
	if fpath == undefined or not doesFileExist fpath do return false	
	local lines = netFile.ReadAllLines fpath
	for i=1 to lines.count where findString lines[ i ] str != undefined do
	(
		lines[ i ] = new_str
		netFile.WriteAllLines fpath lines
		return true
	)
	return false
 )
*/



/*
colour.global.back=#2C2C45
colour.global.fore=#FEFF00
colour.code.comment.line=fore:#C4C4B7
colour.code.comment.box=fore:#808080
colour.notused=back:#FF0000
colour.brace.highlight=fore:#D6FF34
colour.brace.incomplete=fore:#FF0F0F
colour.indentationguide=fore:#AAAFA5
colour.indentationguide=back:#2C2C45
colour.linenumbers=back:#8C8C8C
colour.linenumbers=fore:#1E1E1E
fold.margin.colour=#B4B4B4
fold.margin.highlight.colour=#B4B4B4
colour.whitespace=fore:#D83939,bold
colour.number=fore:#367C86,bold
colour.keyword=fore:#94A0FC
colour.reserved=fore:#313187
colour.string=fore:#DE5656
colour.string.verbatim:fore:#BC5454
colour.string.open=fore:#AB28284
colour.string.open=back:#C39DBE
colour.char=fore:#B361B2
colour.operator=fore:#E8FFFF,bold
colour.argument=fore:#68686E
colour.preproc=fore:#873162
colour.pathname=fore:#6DBC5B
colour.function=fore:#35A655
colour.class=fore:#8B4CCB
colour.maxclass=fore:#F3FF69
colour.superclass=fore:#4479D6
colour.coreinterface=fore:#0049CA
colour.objectset=fore:#FCE6A3
colour.struct=fore:#AA6A25,bold
colour.constantglobals=fore:#ADF2FF
colour.globals=fore:#9AFF56,bold
colour.user=fore:#FFBABA,bold,italics
caret.fore=#ECECEC
caret.line.back=#FFFFFF
selection.fore=#FAFAFA
selection.back=#405F87
*/