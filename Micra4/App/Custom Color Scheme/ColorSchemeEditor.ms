-Maxscript Color Editor
--http://forums.cgsociety.org/showthread.php?t=1045880
try(destroyDialog mcMaxScriptColorEditorDialog)catch()
--Create a rollout
rollout mcMaxScriptColorEditorDialog "MaxScript Theme Editor:" width:680 height:516
(
local alphaStr = "0123456789ABCDEF"
local alphaArr = #("0","1","2","3","4","5","6","7","8","9","A","B","C","D","E","F")
local user_file = getDir #maxData+"\\MXS_EditorUser.properties"
struct TEXT_DATA (pos, line, hex, clr, hint, ftype="Arial", fstyle="Regular", fsize=12)
local user_data = #(), selected_num = 0, str_stream
local all_colors =#\ --40
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
local key_names =#\ --40
(
"background",
"foreground",
"comment line",
"comment box",
"not used",
"brace hilight",
"brace incomplete",
"indentation guide fore",
"indentation guide back",
"line numbers fore",
"line numbers back",
"margin",
"margin hilight",
"whitespace",
"number",
"keyword",
"reserved",
"string",
"string verbatim",
" string open fore",
"string open back",
"char",
"operator",
"argument",
"preproc",
"path name",
"function",
"class",
"maxclass",
"superclass",
"coreinterface",
"objectset",
"struct",
"constant globals",
"globals",
"user",
"caret fore",
"caret line back",
"selection fore",
"selection back"
)
local keywords_01=#\
(
"global","local","struct","fn","function","for","in","do","or","case","return","on","while","when","collect","and",
"then","else","animate","attributes","by","exit","from","rollout","set","mapped","rcmenu","throw","max","rollout"
)
local keywords_02=#\--preproc
(
"subRollout","slider","button","spinner","checkbox","checkButton","pickButton","radioButtons","activeXControl",
"groupBox","label","editText","dropDownList","listBox","multiListBox","colorPicker","timer","progressBar","colorpicker",
"dotNetControl"
)
local keywords_03=#\--functions
(
"messagebox","querybox","yesNoCancelBox","disableSceneRedraw","enableSceneRedraw","forceCompleteRedraw",
"redrawViews","CompleteRedraw","render","createDialog","destroyDialog","select","random","closeRolloutFloater",
"addRollout","removeRollout","open","displaycontroldialog","skipspace","readfloat","reset",
"collectFileData","findStringInArray","getItemColor","hexToRGB"
)
local keywords_04=#\--class
(
"maxtvutility","moflow","trackviewpick","array","matrix3","integer","dotnetObject","stringStream","Color"
)
local keywords_05=#\
(
"box","ffd_2x2x2","cameramapspacewarp"
)
local keywords_06=#\
(
"camera","shape","soundclass","texturemap"
)
local keywords_07=#\
(
"assemblymgr","channelinfo","iparserloader","trackselectionsets","pluginmanager"
)
local keywords_08=#\
(
"objects","geometry","lights","cameras","helpers","shapes","systems","spacewarps","selection"
)
local keywords_09=#\
(
"meshops","mouse","dof","cui","camerafov","xrefs","listView"
)
local keywords_10=#\
(
"red","pi","true","false","undefined","meditmaterials","x_axis"
)
local keywords_11=#\
(
"animationrange","slidertime","backgroundcolor","rootnode"
)
local keywords_12=#\
(
"treeView","textBox","entered","changed","selected","pressed","selectionEnd","doubleClicked","picked","clicked",
"buttondown","buttonup","tick","resized","mousedown","mouseup","click","dblclick","mouseover","mouseout","selChanged",
"ptChanged","tangentChanged","deleted","ColumnClick","keyUp","DoubleClick","keyPress","KeyDown","MouseMove",
"netDrColor","netDrFont","netFile","mc2Path","mc2System"
)
local operators=#("[","]","{","}","(",")","+","-","*","=","/","\\",".",",","&","^","%","!","?","<",">")
local numbers =for i=0 to 9 collect i as string

local edit_text =\
"
Global ColorPattern
struct TEXT_DATA (pos, line, hex, clr, hint)
--line comment
\"string comment\"
--function
fn collectFileData =
(
local user_file_text = netFile.ReadAllLines user_file
for c in all_colors do
(
local d = ( findStringInArray user_file_text c )
user_data += #( TEXT_DATA pos: d [ 1 ] line: d [ 2 ] )
)
for s in user_data do
(
local hex =\"#\" + getItemColor s.line
s. hex = hex
s.clr = hexToRGB hex
)
return user_data
)
--class
#( dotnetObject, stringStream, color )
--char
#( #char, #integer, #name )
--preproc
#( dotNetControl, colorPicker, spinner, dropDownList )
/*
#(
\"colour.global.back=\",
\"colour.global.fore=\",
\"colour.code.comment.line=\"
)
*/
"
--Create the dotNet listview control
dotNetControl lv "listView" pos:[392,4] width:283 height:504
dotNetControl text_box "RichTextBox" pos:[8,4] width:380 height:428
colorPicker cp_clr "" pos:[4,468] width:64 height:40 enabled:true --color:red title:"Choose a color"
spinner spn_r "R:" pos:[84,468] width:64 height:16 range:[0,255,0] type:#integer scale:1
spinner spn_g "G:" pos:[164,468] width:64 height:16 range:[0,255,0] type:#integer scale:1
spinner spn_b "B:" pos:[244,468] width:64 height:16 range:[0,255,0] type:#integer scale:1
spinner spn_h "H:" pos:[84,492] width:64 height:16 range:[0,255,0] type:#integer scale:1
spinner spn_s "S:" pos:[164,492] width:64 height:16 range:[0,255,0] type:#integer scale:1
spinner spn_v "V:" pos:[244,492] width:64 height:16 range:[0,255,0] type:#integer scale:1
button btn_gen "Generate" pos:[312,468] width:76 height:40
dropDownList ddl_font "" pos:[8,440] width:268 height:21
button btn_bold "B" pos:[328,440] width:20 height:20
button btn_italic "I" pos:[348,440] width:20 height:20
button btn_under "U" pos:[368,440] width:20 height:20
dropDownList ddl_size "" pos:[280,440] width:44 height:21
fn netDrFont font:"Arial" size:12 style:"Regular" =
(
local f_style=execute ( "(dotNetClass \"Drawing.FontStyle\")."+style)
dotNetObject "Drawing.Font" font size f_style
)
fn netDrColor clr = ((dotNetClass "Drawing.Color").fromArgb clr.r clr.g clr.b)
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
fn decToHex dec = -- used to convert single color value 0-255 to hex bit
(
n_ = floor (dec / 16)
_n = dec - n_ * 16
n_ += 1
_n += 1
return alphaArr[n_] + alphaArr[_n]
)
fn hexToRGB hex = -- converts HEX code to RGB code
(
hex = substituteString hex "#" "" -- audits string for pound sign and deletes it
hex = toUpper hex
local r = hexToDec (substring hex 1 2)
local g = hexToDec (substring hex 3 2)
local b = hexToDec (substring hex 5 2)
return (color r g b)
)
fn rgbToHEX clr =-- converts RGB code to HEX code
(
return ("#"+decToHex clr.r + decToHex clr.g + decToHex clr.b )
)
fn collectFileData =
(
local netFile = (dotnetClass "IO.File")
local user_file_text = netFile.ReadAllLines user_file
for c=1 to all_colors.count do
(
local d = (findStringInArray user_file_text all_colors[c])
user_data += #(TEXT_DATA pos:d[1] line:d[2] hint:key_names[c])
)
for s in user_data do
(
local hex ="#" + getItemColor s.line
s. hex = hex
s.clr = hexToRGB hex
)
return user_data
)
fn initLv theLv=
(
--Setup the forms view
theLv.view=(dotNetClass "system.windows.forms.view").details
theLv.FullRowSelect=true --Set so full width of listView is selected and not just first column.
theLv.GridLines=true --Show lines between the items.
theLv.MultiSelect=false --Allow for multiple selections.
theLv.foreColor = netDrColor black
)
--Add columns.
fn addColumns theLv columnsAr sizeArr = (for i=1 to columnsAr.count do theLv.columns.add columnsAr[i] sizeArr[i])
--Adds rows of data to the listView
fn populateList theLv=
(
rows=#() --Empty array to collect rows of data
for i in user_data do --Loop through all the objects in the scene.
(

local li=dotNetObject "ListViewItem" "" --Create a listViewItem object and name it.
li.UseItemStyleForSubItems = false
li.backColor = netDrColor i.clr
li.subitems.add i.hex --Add data to the second column.
li.subitems.add i.hint --Add data to the third column.

append rows li --Added the listViewItem to the rows array
)
theLv.items.addRange rows --Add the array of rows to the listView control.
)
fn colorize str clr font:"Arial" size:10 style:"regular" search:1=
(
if classOf clr != Color do return false
text_box.SelectionStart = 0
local search_type = case search of
(
1: (dotnetClass "RichTextBoxFinds").WholeWord
2: (dotnetClass "RichTextBoxFinds").MatchCase
3: (dotnetClass "RichTextBoxFinds").NoHighlight
4: (dotnetClass "RichTextBoxFinds").Reverse
5: (dotnetClass "RichTextBoxFinds").None
)
while (text_box.find str text_box.SelectionStart search_type) != -1 and not keyboard.escPressed do
(
text_box.SelectionFont = netDrFont font:font size:size style:style
text_box.SelectionColor = netDrColor clr
--.text_box.SelectionBackColor
text_box.SelectionStart+=1
)
)
fn higlightLine num clr:green =
(
local first = text_box.GetFirstCharIndexFromLine num
local last = text_box.GetFirstCharIndexFromLine (num + 1)
If last == -1 do last = text_box.TextLength
text_box.Select first (last - first)
text_box.SelectionBackColor = netDrColor clr
)
fn colorizeLineComments=
(
text_box.SelectionStart = 0
local start_pos=0
struct STRING_DATA (txt, line, pos)
local sd = #()
local fs = undefined
for i=1 to text_box.lines.count where (fs=findString text_box.lines[i] "--") !=undefined do sd += #(STRING_DATA text_box.lines[i] i fs)
local search_type = (dotnetClass "RichTextBoxFinds").None
for i in sd do
(
--format "start_pos:%\n" start_pos
local commented_text=substring i .txt i.pos -1
text_box.Find commented_text start_pos search_type
text_box.SelectionColor = netDrColor user_data[3].clr
text_box.SelectionFont = netDrFont font:"Arial" size:10 style:"regular"
start_pos=(text_box.GetFirstCharIndexFromLine i.line)
)
)
fn colorizeBoxComments=
(
text_box.SelectionStart = 0
local start_pos=0
local search_type = (dotnetClass "RichTextBoxFinds").None
start_pos=text_box.Find "/*" start_pos search_type
if start_pos == -1 do return false
end_pos =text_box.Find "*/" start_pos search_type
if end_pos == -1 do return false
text_box.select start_pos end_pos
text_box.SelectionColor = netDrColor user_data[4].clr
)
fn colorizeStrings=
(
local start_pos=0
text_box.SelectionStart = 0
local search_type = (dotnetClass "RichTextBoxFinds").None

while start_pos != -1 do
(
start_pos=text_box.Find "\"" start_pos search_type
if start_pos == -1 do return false
end_pos =text_box.Find "\"" (start_pos+1) search_type
if end_pos == -1 do return false
local text_length = end_pos - (start_pos-1)
text_box.select start_pos text_length
text_box.SelectionColor = netDrColor user_data[18].clr
text_box.SelectionFont = netDrFont font:"Arial" size:10 style:"regular"
start_pos = start_pos+text_length
)
--text_box.HideSelection = false
)
fn colorizeKeyword k_array clr:1 size:10 style:"regular" comments:true=
(
for k in k_array do colorize k user_data[clr+1].clr size:size style:style
if comments do
(
colorizeStrings()
colorizeLineComments()
colorizeBoxComments()
)
)
fn inicializeColors =
(
text_box.BackColor = netDrColor user_data[1].clr
text_box.ForeColor = netDrColor user_data[2].clr
colorizeKeyword keywords_01 clr:15 size:10 style:"bold" comments:false
colorizeKeyword operators clr:22 size:10 style:"bold" comments:false
colorizeKeyword numbers clr:14 style:"bold"
colorizeKeyword keywords_03 clr:26 size:10 style:"bold"
colorizeKeyword keywords_04 clr:27 style:"bold"
colorizeKeyword #("#") clr:13 style:"bold"
colorizeKeyword #("#char", "#integer", "#name") clr:21 style:"bold"
colorizeKeyword #("line:","pos:") clr:23
colorizeKeyword keywords_02 clr:24
--colorize comments
colorizeStrings()
colorizeLineComments()
colorizeBoxComments()
higlightLine 8 clr:user_data[38].clr
)
fn findItem2 arr str caseSensitive:false=
(
str = toLower str
for i=1 to arr.count where (toLower arr[i]) == str do return i
return 0
)
fn colorizeSimpleText =
(
--text_box.ForeColor = netDrColor clr

--collect all keywords
local all_keywords =(keywords_01+keywords_02+keywords_03+keywords_04+keywords_05+
keywords_06+keywords_07+keywords_08+keywords_09+keywords_10+keywords_11+keywords_12)
--get text_box text
--for i in all_keywords do print i
local box_text = filterString text_box.text " .,/\\!?:*-=(){}[]+\"#0123456789\t\n"
--remove all keywords from text
for k in all_keywords do
(
local index = findItem2 box_text k
while index != 0 do
(
deleteItem box_text index
index = findItem2 box_text k
)
)
--colorize remain text
local next_pos=0
text_box.SelectionStart = 0
for i in box_text do
(
next_pos=text_box.Find i next_pos (dotnetClass "RichTextBoxFinds").WholeWord
text_box.SelectionColor = netDrColor user_data[2].clr
)
--colorize all comment lines -- and boxes /* */
colorizeLineComments()
colorizeBoxComments()
text_box.update()
text_box.refresh()
)
fn inicializeColorsBySelection type:"user" =
(
local sel=selected_num+1
local clr=user_data[sel].clr
case user_data[sel].hint of
(
"background":(text_box.BackColor = netDrColor clr )
"foreground":(colorizeSimpleText() )
"comment line":(colorizeLineComments() )
"comment box":(colorizeBoxComments() )
"not used":( )
"brace hilight":( )
"brace incomplete":( )
"indentation guide fore":( )
"indentation guide back":( )
"line numbers fore":( )
"line numbers back":( )
"margin":()
"margin hilight":()
"whitespace":(colorizeKeyword #("#") clr:13 style:"bold")
"number":(colorizeKeyword numbers clr:14 style:"bold")
"keyword":(colorizeKeyword keywords_01 clr:15 size:10 style:"bold")
"reserved":( )
"string":(colorizeStrings();colorizeLineComments(); colorizeBoxComments())
"string verbatim":( )
" string open fore":( )
"string open back":( )
"char":(colorizeKeyword #("#char", "#integer", "#name") clr:21 style:"bold")
"operator":(colorizeKeyword operators clr:22 size:10 style:"bold")
"argument":(colorizeKeyword #("line:","pos:") clr:23 )
"preproc":(colorizeKeyword keywords_02 clr:24 )
"path name":( )
"function":(colorizeKeyword keywords_03 clr:26 size:10 style:"bold")
"class":(colorizeKeyword keywords_04 clr:27 style:"bold" )
"maxclass":( )
"superclass":( )
"coreinterface":( )
"objectset":( )
"struct":( )
"constant globals":( )
"globals":( )
"user":( )
"caret fore":( )
"caret line back":(higlightLine 8 clr:user_data[38].clr)
"selection fore":( )
"selection back":( )
)
)
fn sendColorInfo clr =
(
lv.items.item[selected_num].backColor = netDrColor clr
user_data[selected_num+1].clr = clr
local hex = rgbToHEX clr
user_data[selected_num+1].hex = hex
lv.items.item[selected_num].subItems.item[1].text = hex
inicializeColorsBySelection()
)
fn setupInterfaceBySelectedItem =
(
local clr = user_data[selected_num+1].clr
spn_r.value = clr.r
spn_g.value = clr.g
spn_b.value = clr.b
spn_h.value = clr.h
spn_s.value = clr.s
spn_v.value = clr.v
cp_clr.color = clr
)
fn setupIntefaceByChangedValue type val =
(
local clr = cp_clr.color
case type of
(
#r:(clr.r = val)
#g:(clr.g=val)
#b:(clr.b=val)
#h:(clr.h=val)
#s:(clr.s=val)
#v:(clr.v=val)
)

spn_r.value = clr.r
spn_g.value = clr.g
spn_b.value = clr.b
spn_h.value = clr.h
spn_s.value = clr.s
spn_v.value = clr.v

cp_clr.color = clr
sendColorInfo clr
)
fn inicializeInterface =
(
user_data = collectFileData()
initLv lv
addColumns lv #("RGB","HEX","Name") #(32, 68, lv.width-(32+68)-22)
populateList lv
lv.Items.item[0].Selected = true
selected_num = 0
setupInterfaceBySelectedItem()
--setup tabs size
local int_arr = dotnetObject "System.Int32[]" 6
local tab_size = 0
for i=0 to 5 do int_arr.SetValue (tab_size+=20) i
text_box.SelectAll()
text_box.SelectionTabs = int_arr
--
--mcSystem.show text_box
text_box.ShowSelectionMargin = true
--text_box.RightMargin = text_box.width
--text_box.Margin = dotnetObject "Padding" 0
text_box.ReadOnly = true
text_box.text=edit_text
str_stream= stringStream edit_text
inicializeColors()
)
on lv mouseDown arg do
(
local hit=(lv.HitTest (dotNetObject "System.Drawing.Point" arg.x arg.y))
selected_num = hit.item.Index
setupInterfaceBySelectedItem()
print selected_num
)
on cp_clr changed clr do
(
sendColorInfo clr
setupInterfaceBySelectedItem()
)
on btn_gen pressed do
(
text_box.text = ""
for i in user_data do
(
local hex_pos = (findString i.line "#")
local line_array = filterstring i.line "# ,"
local hex_len = line_array[2].count+1
i.line = replace i.line hex_pos hex_len i.hex
text_box.text += i.line+"\n"
)
)
on mcMaxScriptColorEditorDialog open do inicializeInterface()
on spn_r changed val do setupIntefaceByChangedValue #r val
on spn_g changed val do setupIntefaceByChangedValue #g val
on spn_b changed val do setupIntefaceByChangedValue #b val
on spn_h changed val do setupIntefaceByChangedValue #h val
on spn_s changed val do setupIntefaceByChangedValue #s val
on spn_v changed val do setupIntefaceByChangedValue #v val


)
CreateDialog mcMaxScriptColorEditorDialog