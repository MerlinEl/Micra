text_box=mcMaxScriptColorEditorDialog.text_box
text_box.AutoWordSelection = true
mcSystem.show  text_box
text_box.lines -- all text lines in an array
text_box.Text --all text
text_box.SelectedRtf
text_box.Rtf
li=text_box.GetFirstCharIndexOfCurrentLine()
text_box.GetLineFromCharIndex li --get current line number
text_box.GetFirstCharIndexFromLine 1
--------------------------------------------------------------------------
--select all text and colorize 
--------------------------------------------------------------------------
text_box.SelectAll()
text_box.SelectionColor = netDrColor gray
--------------------------------------------------------------------------
--clear all text
--------------------------------------------------------------------------
text_box.clear()
--------------------------------------------------------------------------
--append colorized text
--------------------------------------------------------------------------
text_box.AppendText "dlaren"
text_box.SelectionStart -= "dlaren".count
text_box.SelectionLength = "dlaren".count
text_box.SelectionColor = netDrColor green
--or
 AppendText(this.m_richTextBox1, Color.Empty, "empty");
--------------------------------------------------------------------------
--find one string and colorize
--------------------------------------------------------------------------
text_box.SelectionStart
text_box.SelectionLength
text_box.SelectionColor = netDrColor green
text_box.SelectionBackColor = netDrColor yellow
--------------------------------------------------------------------------
--find one string and colorize
--------------------------------------------------------------------------
start_pos=text_box.Find "table" (dotnetClass "RichTextBoxFinds").WholeWord       
text_box.SelectionStart = if start_pos != -1 then start_pos else 0
text_box.SelectionColor = netDrColor green
--------------------------------------------------------------------------
--find and colorize all string matches
--------------------------------------------------------------------------
text_box.SelectionStart = 0
(text_box.find word (text_box.SelectionStart+=1)  (dotnetClass "RichTextBoxFinds").WholeWord)
text_box.SelectionColor = netDrColor green
--------------------------------------------------------------------------
--find string by range from to
--------------------------------------------------------------------------
search_type = (dotnetClass "RichTextBoxFinds").WholeWord
start_pos = 10
end_pos = 45
str = "local" 
text_box.Find str start_pos end_pos search_type
text_box.SelectionColor = netDrColor green
--------------------------------------------------------------------------
search_type = (dotnetClass "RichTextBoxFinds").WholeWord
search_type = (dotnetClass "RichTextBoxFinds").NoHighlight
search_type = (dotnetClass "RichTextBoxFinds").None
text_box.SelectionStart = 0
str = "global" 
str = "--" 
text_box.Find str search_type
text_box.SelectionColor = netDrColor red
--fn getCurrentLine =
fn getCurrentLineStart=(text_box.GetFirstCharIndexOfCurrentLine())
fn getCurrentLineEnd=
(
	local first_char_pos=text_box.GetFirstCharIndexOfCurrentLine()
	local current_line=(text_box.GetLineFromCharIndex first_char_pos)+1
	return (first_char_pos + text_box.lines[current_line].count)
)

--------------------------------------------------------------------------
--Highlight the entire line where a given word is found. eg "fox"
--------------------------------------------------------------------------
fn hilightLineByWord str clr =
(
	local search_type = (dotnetClass "RichTextBoxFinds").WholeWord
	local index = text_box.Find str search_type
	If index == -1 do return false
	local lineindex = text_box.GetLineFromCharIndex index
	local first = text_box.GetFirstCharIndexFromLine lineindex
	local last = text_box.GetFirstCharIndexFromLine (lineindex + 1)
	If last == -1 do last = text_box.TextLength
	text_box.Select first (last - first)
	text_box.SelectionBackColor = netDrColor clr
)
hilightLineByWord "user_file" green
--------------------------------------------------------------------------
--Colorize Line Comments
--------------------------------------------------------------------------
fn colorizeLineComments clr:green =
(
	text_box.SelectionStart = 0
	local start_pos=0
	struct STRING_DATA (txt, line, pos)
	local sd = #()
	local fs = undefined
	local str = "--" 
	for i=1 to text_box.lines.count where (fs=findString text_box.lines[i] str) !=undefined do sd += #(STRING_DATA text_box.lines[i] i fs)
	local search_type = (dotnetClass "RichTextBoxFinds").None
	for i in sd do
	(
		format "start_pos:%\n" start_pos
		local commented_text=substring i .txt i.pos -1
		text_box.Find commented_text start_pos search_type
		text_box.SelectionColor = netDrColor clr
		start_pos=(text_box.GetFirstCharIndexFromLine i.line)
	)
)
colorizeLineComments clr:yellow
colorizeLineComments clr:green


	fn colorizeBoxComments=
	(
		text_box.SelectionStart = 0
		local start_pos=0
		local search_type = (dotnetClass "RichTextBoxFinds").None
		start_pos=text_box.Find "/*" start_pos search_type
		end_pos =text_box.Find "*/" start_pos search_type
		text_box.select start_pos end_pos
		text_box.SelectionColor = netDrColor green
	)

--------------------------------------------------------------------------
--tabs
--this will set the indent for the first Tab at 10 pixels from the left, 20 pixels for the second Tab, and so on. You can add more values of course.
--If you set this values in the script before you put any text in, e.g. when initializing the Richtextbox, it will apply to any text that is put in the box after that.
--------------------------------------------------------------------------
		int_arr = dotnetObject "System.Int32[]" 6
		tab_size = 0
		for i=0 to 5 do int_arr.SetValue (tab_size+=20) i
		text_box.SelectAll()
		text_box.SelectionTabs = int_arr
--------------------------------------------------------------------------

--------------------------------------------------------------------------
fn colorize str clr font:"Arial" size:10 style:"regular" =
(
	if classOf clr != Color do return false 
	text_box.SelectionStart = 0
	while (text_box.find str text_box.SelectionStart  (dotnetClass "RichTextBoxFinds").WholeWord) != -1 and not keyboard.escPressed do
	(
		text_box.SelectionFont = netDrFont font:font size:size style:style
		text_box.SelectionColor = netDrColor clr
		--.text_box.SelectionBackColor
		text_box.SelectionStart+=1
	)
)
 colorize "("  white
 colorize ")"  white

fn colorizeLineBrackets clr:green =
(
	text_box.SelectionStart = 0
	local start_pos=0
	struct STRING_DATA (txt, line, pos)
	local sd = #()
	local fs = undefined
	for i=1 to text_box.lines.count where (fs=findString text_box.lines[i] "(") !=undefined do sd += #(STRING_DATA text_box.lines[i] i fs)
	for i=1 to text_box.lines.count where (fs=findString text_box.lines[i] ")") !=undefined do sd += #(STRING_DATA text_box.lines[i] i fs)
	local search_type = (dotnetClass "RichTextBoxFinds").None
	local str = "--" 
	for i in sd do
	(
		format "start_pos:%\n" start_pos
		local commented_text=substring i .txt i.pos -1
		text_box.Find commented_text start_pos search_type
		text_box.SelectionColor = netDrColor clr
		start_pos=(text_box.GetFirstCharIndexFromLine i.line)
	)
)
colorizeLineBrackets clr:yellow
colorizeLineBrackets clr:green

--------------------------------------------------------------------------

--------------------------------------------------------------------------
fn colorizeComment start_pos:0 clr:green =
(
	text_box.SelectionStart = start_pos
	search_type = (dotnetClass "RichTextBoxFinds").None
	str = "--" 
	start_pos= text_box.Find str start_pos search_type
	line_start=getCurrentLineStart()
	line_end=getCurrentLineEnd()
	text_length =(line_end - start_pos) - (start_pos - line_start)
	text_box.Select start_pos text_length
	text_box.SelectionColor = netDrColor clr
	return end_pos
)
start_pos=120
start_pos=colorizeComment start_pos:0 clr:green
colorizeComment start_pos:(start_pos+1) clr:green

text_box.SelectionStart = text_box.Text.count
text_box.SelectionLength = 0 



text_box.SelectionRightIndent
text_box.SelectionLength
text_box.SelectionTabs
text_box.SelectionType.toString()
text_box.TextLength
text_box.TabIndex


--------------------------------------------------------------------------
match pattern
--------------------------------------------------------------------------
Private Sub SearchRichTextBox(ByVal Pattern As String, _
                              ByVal HighlightColor As Color, _
                              Optional ByVal RemovePreviousHighlight As Boolean = True)
    'Make sure we are ready to continue.
    If String.IsNullOrEmpty(Pattern) Then Exit Sub 'no pattern text for text seach
    If Me.MyRichTextBox.TextLength = 0 Then Exit Sub 'no text to be searched
 
    'If no color is passed then assign a default color of Yellow.
    If HighlightColor = Color.Empty Then HighlightColor = Color.Yellow
 
    'Get the position of the cursors
    Dim initialSelection As Integer = Me.MyRichTextBox.SelectionStart
 
    'Un-Highlight all text if RemovePreviousHighlight is true
    If RemovePreviousHighlight Then
        Me.MyRichTextBox.SelectAll()
        Me.MyRichTextBox.SelectionBackColor = Me.MyRichTextBox.BackColor
    End If
 
    'Get an instance of the Regex class using our Pattern.
    Dim regex As New System.Text.RegularExpressions.Regex(Pattern)
 
    'Loop through each match, select it, and then highlight it.
    For Each match As System.Text.RegularExpressions.Match In regex.Matches(Me.MyRichTextBox.Text)
        With Me.MyRichTextBox
            .Select(match.Index, match.Length)
            .SelectionBackColor = HighlightColor
        End With
    Next
 
    'Set the selection back to the beginning
    Me.MyRichTextBox.Select(initialSelection, 0)
End Sub
--------------------------------------------------------------------------

--------------------------------------------------------------------------
trr=dotnetClass "Text.RegularExpressions.Regex"
mcsystem.show trr
(trr.match "cxcvx_v02s_v02_asdvccc.max" "_v(\d+)(_|\.|$)").groups.item[1].value
-- result: "02"
--------------------------------------------------------------------------
fn getFilenameVersion1 file = 
 (
	 local ver
	 local ss = filterstring (getfilenamefile file) "_"
	 for s in ss while ver == undefined where s[1] == "v" do ver = (substring s 2 -1) as integer
	 ver
 )
 
 fn getFilenameVersion2 file regex: =
 (
	 if regex == unsupplied do 
	 (
		local search_type = (dotnetclass "System.Text.RegularExpressions.RegexOptions").Compiled --.IgnoreCase, .Singleline
		 regex = dotnetobject "System.Text.RegularExpressions.Regex" "_v(\d+)(_|\.|$)"  search_type
	 )
	 ss = (regex.match (getfilenamefile file)).groups
	 if ss.item[1].value != "" do ss.item[1].value as integer
 )
 --The function #2 uses .net "Regex". Even if I pass the compiled regex to the function it still 8 times slower than the function #1 (mxs code). So .net solution is not always better!
--------------------------------------------------------------------------

global processOutput_RLT
 try (destroyDialog processOutput_RLT) catch()
 
 rollout processOutput_RLT "Results" width:640 height:350
 (
 	dotnetControl text_RTB "RichTextBox" width:640 height:350 offset:[-14,-4]
 	
 	on processOutput_RLT open do
 	(
 		text_RTB.BorderStyle = text_RTB.BorderStyle.None
 		text_RTB.BackColor = text_RTB.BackColor.WhiteSmoke
 		text_RTB.ReadOnly= true
 	)
 )
 
 createDialog processOutput_RLT 
 
 
 fn outputDataReceivedHandler obj evt =
 (
 	if evt.data != undefined then
 	(
 		processOutput_RLT.text_RTB.text += (evt.data + "\n")
 		format "%\n" evt.data
 	)
 )
 
 fn errorDataReceivedHandler obj evt =
 (
 	if evt.data != undefined then
 	(
 		processOutput_RLT.text_RTB.text += ("Error: " + evt.data + "\n")
 		format "Error: %\n" evt.data
 	)
 )
 
 fn onExitHandler obj evt =
 (
 	processOutput_RLT.text_RTB.text += "Finished!"
 	format "Finished!\n"
 )
 
 proc = dotNetObject "System.Diagnostics.Process"
 proc.EnableRaisingEvents = true
 -- add program info here
 proc.StartInfo.WorkingDirectory = <folder string>
 proc.StartInfo.FileName = <program string>
 proc.StartInfo.Arguments = <argument string>
 --
 proc.StartInfo.UseShellExecute = false
 proc.StartInfo.RedirectStandardOutput = true
 proc.StartInfo.RedirectStandardError = true
 proc.StartInfo.CreateNoWindow = true
  
 dotNet.AddEventHandler proc "OutputDataReceived" outputDataReceivedHandler
 dotNet.AddEventHandler proc "ErrorDataReceived" errorDataReceivedHandler
 dotNet.AddEventHandler proc "Exited" onExitHandler
  
 proc.Start()
 
 proc.BeginErrorReadLine()
 proc.BeginOutputReadLine()
 
 
 
	fn netDrFont font:"Arial" size:12 style:"regular" =
	(
		local f_style=execute ( "(dotNetClass \"Drawing.FontStyle\")."+style)
		dotNetObject "Drawing.Font" font size f_style
	) 
 
	rtb=mcMaxScriptColorEditorDialog.text_box
	mcsystem.show rtb


	pos=(rtb.find "local" (dotnetClass "RichTextBoxFinds").WholeWord)
	pos=(rtb.find "local" (pos+1) (dotnetClass "RichTextBoxFinds").WholeWord) --search next string
	if pos == -1 do return false
	rtb.Select pos "items".count
	rtb.SelectionFont = netDrFont font:"Arial" size:12 style:"underline"
	rtb.SelectionColor = netDrColor white
	
 
   --Clear all text from the RichTextBox
   rtb.Clear()
   --Set the font for the opening text to a larger Arial font
   rtb.SelectionFont = netDrFont font:"Arial" size:16 style:"Underline" 
   --Assign the introduction text to the RichTextBox control.
   rtb.SelectedText = "The following is a list of bulleted items:\n"
   --Set the Font for the first item to a smaller size Arial font.
   rtb.SelectionFont = netDrFont font:"Arial" size:12 
   --Specify that the following items are to be added to a bulleted list.
   rtb.SelectionBullet = true
   --Set the color of the item text.
   rtb.SelectionColor = netDrColor Red
   --Assign the text to the bulleted item.
   rtb.SelectedText = "Apples" + "\n"
   --Apply same font since font settings do not carry to next line.
   rtb.SelectionFont = netDrFont font:"Arial" size:12 style:"Strikeout"
   rtb.SelectionColor = netDrColor Orange
   rtb.SelectedText = "Oranges" + "\n"
   rtb.SelectionFont = netDrFont font:"Arial" size:12 style:"bold"
   rtb.SelectionColor = netDrColor (color 200 90 20)
   rtb.SelectedText = "Grapes" + "\n"
   --End the bulleted list.
   rtb.SelectionBullet = false
   --Specify the font size and string for text displayed below bulleted list.
   rtb.SelectionFont = netDrFont font:"Arial" size:12 style:"Italic"
   rtb.SelectedText = "Bulleted Text Complete!"