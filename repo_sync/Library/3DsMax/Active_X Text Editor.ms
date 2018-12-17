Global MyFileName = undefined 
rollout xxxx "Untitled" width:452 height:524
(
	local cRGB = (color 0 0 0)
	ActiveXControl ax "{3B7C8860-D78F-101B-B9B5-04021C009402}" pos:[4,36] width:354 height:436
	spinner spnR "R" pos:[380,408] width:58 height:16 range:[0,255,237] type:#integer scale:1
	spinner spnG "G" pos:[380,428] width:58 height:16 range:[0,255,187] type:#integer scale:1
	spinner spnB "B" pos:[380,448] width:58 height:16 range:[0,255,168] type:#integer scale:1
	GroupBox grp1 "Background" pos:[364,388] width:80 height:84
	button btn1 "B" pos:[372,332] width:17 height:19
	button btn2 "I" pos:[396,332] width:17 height:19
	button btn3 "." pos:[420,332] width:17 height:19
	button btn7 "Open" pos:[372,48] width:64 height:24
	label lbl1 "Text Box:" pos:[4,16] width:140 height:16
	colorPicker cp1 "" pos:[400,304] width:28 height:20
	dropDownList ddl1 "Font Name" pos:[8,476] width:212 height:40
	GroupBox grp6 "Text" pos:[364,288] width:80 height:96
	label lbl3 "Color:" pos:[372,304] width:32 height:20
	spinner spn28 "Size:" pos:[392,360] width:44 height:16 range:[0,100,0] type:#integer scale:1
	GroupBox grp8 "File:" pos:[364,32] width:80 height:104
	button btn17 "Save" pos:[372,76] width:64 height:24
	button btn18 "Save As" pos:[372,104] width:64 height:24
	/*
	fn initTreeView =
	(
		ax.ScrollBars = rtfBoth	
	)
	*/

	on xxxx open do
	(
		enableAccelerators = false
		ax.BackColor = (color 168 187 237)
		--xxxx.ax.SelProtected
		--xxxx.ax.Appearance --#rtfThreeD
		--xxxx.ax.FileName
		--xxxx.ax.LoadFile "c:\\temp\\test.txt"
		--xxxx.ax.SelText ="[Sphere01]"
		--xxxx.ax.Text --get|set text
		--xxxx.ax.SelBold = true --selectet text to bold
	)
	on xxxx close do
	(
		enableAccelerators = true
		MyFileName = undefined 
	)
	/*
	on ax change do
		( print "changes" )
	on ax click do
		( print "click" )
	on ax dblclick do
		( print "doubleclick" )
	on ax OLECompleteDrag &Effect:1 do (print "drag" )
	*/
	on spnR changed val do
	(
		cRGB.r = val
		ax.BackColor = cRGB
	)
	on spnG changed val do
	(
		cRGB.g = val
		ax.BackColor = cRGB
	)
	on spnB changed val do
	(
		cRGB.b = val
		ax.BackColor = cRGB
	)
	on btn1 pressed do
		(if ax.SelBold == on then ax.SelBold = off else ax.SelBold = on)
	on btn2 pressed do
		(if ax.SelItalic == on then ax.SelItalic = off else ax.SelItalic = on)
	on btn3 pressed do
		(if ax.SelBullet == on then ax.SelBullet = off else ax.SelBullet = on)
	on btn7 pressed do
	(
		MyFileName = getOpenFileName caption: "Open File" filename:"C:\\temp\\" types:"ScriptFiles (*.ms,*.mcr)|*.ms,*.mcr|Ini file (*.ini)|*.ini|Text file(*.txt)|*.txt|Data file(*.dat)|*.dat" --MPath()
		if MyFileName != undefined do xxxx.ax.LoadFile MyFileName
	)
	on cp1 changed col do
	(
		ax.SelColor = col
	)
	on ddl1 selected sel do
	(
	 	ax.SelFontName = sel
	)
	on spn28 changed val do
	(
		ax.SelFontSize = val
	)
	on btn17 pressed do
	(
		if MyFileName != undefined then
		(
			xxxx.ax.SaveFile MyFileName
			print ("Saved to: "+ MyFileName)
		)
		else
		(
			local MySaveName = getSaveFileName \
			types:"ScriptFiles (*.ms)|*.ms|ScriptFiles (*.mcr)|*.mcr|Ini file (*.ini)|*.ini|Text file(*.txt)|*.txt|Data file(*.dat)|*.dat|All |*.*|"

			if MySaveName != undefined do
			(
				xxxx.ax.SaveFile MySaveName
				print ("Saved to: "+ MySaveName)
			)
		)
	)
	on btn18 pressed do
	(
		local MySaveName = getSaveFileName \
		types:"ScriptFiles (*.ms)|*.ms|ScriptFiles (*.mcr)|*.mcr|Ini file (*.ini)|*.ini|Text file(*.txt)|*.txt|Data file(*.dat)|*.dat|All |*.*|"

		if MySaveName != undefined do
		(
			xxxx.ax.SaveFile MySaveName
			print ("Saved to: "+ MySaveName)
		)
	)

)
createdialog xxxx

/*
PROPERTIES:
  .defTextRTF : string, default, hidden
  .Appearance : AppearanceConstants( #rtfFlat | #rtfThreeD )
  .BackColor : OLE_COLOR
  .BorderStyle : BorderStyleConstants( #rtfNoBorder | #rtfFixedSingle )
  .BulletIndent : float
  .DisableNoScroll : boolean
  .Enabled : boolean
  .FileName : string
  .Font : IFontDisp
  .HideSelection : boolean
  .Hwnd : OLE_HANDLE
  .Locked : boolean
  .MaxLength : integer
  .MouseIcon : IPictureDisp
  .MousePointer : MousePointerConstants( #rtfDefault | #rtfArrow | #rtfCross | #rtfIBeam | #rtfIcon | #rtfSize | #rtfSizeNESW | #rtfSizeNS | #rtfSizeNWSE | #rtfSizeEW | #rtfUpArrow | #rtfHourglass | #rtfNoDrop | #rtfArrowHourglass | #rtfArrowQuestion | #rtfSizeAll | #rtfCustom )
  .MultiLine : boolean
  .RightMargin : float
  .ScrollBars : ScrollBarsConstants( #rtfNone | #rtfHorizontal | #rtfVertical | #rtfBoth )
  .SelAlignment : undefined
  .SelBold : undefined
  .SelBullet : undefined
  .SelCharOffset : undefined
  .SelColor : undefined
  .SelFontName : undefined
  .SelFontSize : undefined
  .SelHangingIndent : undefined
  .SelIndent : undefined
  .SelItalic : undefined
  .SelLength : integer
  .SelProtected : undefined
  .SelRightIndent : undefined
  .SelRTF : string
  .SelStart : integer
  .SelStrikeThru : undefined
  .SelTabCount : undefined
  .SelText : string
  .SelUnderline : undefined
  .Text : string
  .TextRTF : string
  .OLEObjects : IOLEObjects, read-only
  .AutoVerbMenu : boolean
  .OLEDragMode : OLEDragConstants( #rtfOLEDragManual | #rtfOLEDragAutomatic )
  .OLEDropMode : OLEDropConstants( #rtfOLEDropNone | #rtfOLEDropManual | #rtfOLEDropAutomatic )
  .SelTabs[sElement:integer] : undefined
METHODS:
  .AboutBox()
  .Find bstrString:string vStart:undefined vEnd:undefined vOptions:undefined
  .GetLineFromChar lChar:integer
  .LoadFile bstrFilename:string vFileType:undefined
  .Refresh()
  .SaveFile bstrFilename:string vFlags:undefined
  .UnusedSelPrint lHDC:integer
  .Span bstrCharacterSet:string vForward:undefined vNegate:undefined
  .UpTo bstrCharacterSet:string vForward:undefined vNegate:undefined
  .OLEDrag()
  .SelPrint lHDC:integer vStartDoc:undefined
EVENTS:
  on <control_name> Change do ( ... )
  on <control_name> Click do ( ... )
  on <control_name> DblClick do ( ... )
  on <control_name> KeyDown KeyCode:integer Shift:integer do ( ... )
  on <control_name> KeyUp KeyCode:integer Shift:integer do ( ... )
  on <control_name> KeyPress KeyAscii:integer do ( ... )
  on <control_name> MouseDown Button:integer Shift:integer x:OLE_XPOS_PIXELS y:OLE_YPOS_PIXELS do ( ... )
  on <control_name> MouseMove Button:integer Shift:integer x:OLE_XPOS_PIXELS y:OLE_YPOS_PIXELS do ( ... )
  on <control_name> MouseUp Button:integer Shift:integer x:OLE_XPOS_PIXELS y:OLE_YPOS_PIXELS do ( ... )
  on <control_name> SelChange do ( ... )
  on <control_name> OLEStartDrag &Data:DataObject &AllowedEffects:integer do ( ... )
  on <control_name> OLEGiveFeedback &Effect:integer &DefaultCursors:boolean do ( ... )
  on <control_name> OLESetData &Data:DataObject &DataFormat:integer do ( ... )
  on <control_name> OLECompleteDrag &Effect:integer do ( ... )
  on <control_name> OLEDragOver &Data:DataObject &Effect:integer &Button:integer &Shift:integer &x:float &y:float &State:integer do ( ... )
  on <control_name> OLEDragDrop &Data:DataObject &Effect:integer &Button:integer &Shift:integer &x:float &y:float do ( ... )
NAMES:

*/