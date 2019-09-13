/*//////////   SCRIPT:   mono • text • edit • v1.1   //////////*/
/*//////////   WRITTEN BY:   Branko Zivkovic   //////////*/
/*//////////   EMAIL:   barigazy@hotmail.com   //////////*/
if mteForm != undefined do try(mteForm.Close())catch()
(
	local textInput, openTxt, saveTxt, delTxt, fontTxt, wordwTxt, resetTxt, setTxt, getTxt, exeTxt, bordLbl, textFind, \
	textRepl, findTxt, replTxt, infoTxt, bnrLbl, dnOFD, dnSFD, dnFD, dnTTip
/*//////////   CONSTRUCTION FN's   //////////*/			
	fn defPoint x y = (dotNetObject "System.Drawing.Point" x y) ; fn defSize w h = (dotNetObject "System.Drawing.Size" w h)
	fn defRect x y w h = (dotNetObject "System.Drawing.Rectangle" x y w h) ; fn defColor r g b = ((dotNetClass "System.Drawing.Color").FromArgb r g b)
	fn defFontBold fName fSize = (dotNetObject "System.Drawing.Font" fName fSize ((dotNetClass "System.Drawing.FontStyle").bold))	
	fn defFontReg fName fSize = (dotNetObject "System.Drawing.Font" fName fSize ((dotNetClass "System.Drawing.FontStyle").regular))		
	fn defMXSForm dnFrm w h txt = (dnFrm.ClientSize = dnFrm.MinimumSize = (defSize w h) ; dnFrm.Text = txt ; dnFrm.StartPosition = dnFrm.StartPosition.CenterScreen)
	fn defPnl dnPnl bgClr = ( dnPnl.Backcolor = bgClr ; dnPnl.Dock = dnPnl.Dock.Fill)
	fn def1Label dnLbl w h Frm locX locY font bgClr fgClr Crs txtAlign txt =
	(
		dnLbl.Width = w ; dnLbl.Height = h ; dnLbl.Location = defPoint (Frm.Location.x + locX) (Frm.Location.y + locY) ; dnLbl.Font = font	
		dnLbl.BackColor = bgClr ; dnLbl.ForeColor = fgClr ; dnLbl.Cursor = Crs ; dnLbl.Text = txt ; dnLbl.TextAlign = txtAlign
	)
	fn def2Label dnLbl w h Frm locX locY bgClr fgClr font: txtAlign: =
	(
		dnLbl.Width = w ; dnLbl.Height = h ; dnLbl.Location = defPoint (Frm.Location.x + locX) (Frm.Location.y + locY)
		dnLbl.BackColor = bgClr ; dnLbl.ForeColor = fgClr ; dnLbl.Cursor = Crs
		if (font != unsupplied and txtAlign != unsupplied) do (dnLbl.Font = font ; dnLbl.TextAlign = txtAlign)
	)
	fn def1TextBox dnTB w h Frm locX locY font bgClr fgClr bStyle =
	(
		dnTB.Width = w ; dnTB.Height = h ; dnTB.Location = defPoint (Frm.Location.x + locX) (Frm.Location.y + locY) ; dnTB.WordWrap = false	
		dnTB.Font = font ; dnTB.BackColor = bgClr ; dnTB.ForeColor = fgClr ; dnTB.BorderStyle = bStyle
		dnTB.AcceptsTab = textInput.AllowDrop = textInput.AutoSize = textInput.Multiline = true
	)	
	fn def2TextBox dnTB Lbl locY font txt bgClr fgClr bStyle =
	(
		local bnrCR = Lbl.ClientRectangle, crW = 150, crH = (bnrCR.Height/2 - 1), crX = (bnrCR.x + 3), crY = bnrCR.y
		dnTB.Bounds = (defRect crX (crY+locY) crW crH) ; dnTB.Font = font ; dnTB.Text = txt ; dnTB.BackColor = bgClr
		dnTB.ForeColor = fgClr ; dnTB.BorderStyle = bStyle ; dnTB.Multiline = false ; dnTB.AutoSize = true
	)	
	fn defOSFD dnOSFD flt fIdx ms: aue: =
	(
		dnOSFD.Filter = flt ; dnOSFD.RestoreDirectory = false ; dnOSFD.FilterIndex = fIdx ; dnOSFD.SupportMultiDottedExtensions = true
		if ms != unsupplied do (dnOSFD.Multiselect = ms) ; if aue != unsupplied do (dnOSFD.AutoUpgradeEnabled = aue)
	)	
	fn defFontD dnFD font clr = (dnFD.AllowVectorFonts = dnFD.AllowVerticalFonts = dnFD.ShowApply = dnFD.ShowColor = dnFD.ShowEffects = true ; dnFD.Font = font ; dnFD.Color = clr)
	fn defCnxMenu dnCM = (dnCM.RenderMode = dnCM.RenderMode.Professional ; dnCM.Opacity = 0.8d0 ; dnCM.ShowCheckMargin = false ; dnCM.ShowImageMargin = false)
	fn defTSMI itmStr = (dotNetObject "ToolStripMenuItem" itmStr)

	/*//////////   dnCLASS   //////////*/	
	local fiterEXT = "Text Files (*.txt)|*.txt|RTF Files (*.rtf)|*.rtf|Script Files (*.ms)|*.ms|INI files (*.ini)|*.ini|XML files (*.xml)|*.xml|All files (*.*)|*.*"
	local dnBC1 = (defColor 80 80 80), dnBC2 = (defColor 40 40 40), dnBC3 = (defColor 60 60 60), dnBC4 = (defColor 0 0 0), dnFC = (defColor 200 200 200), dnFC1 = (defColor 51 153 225), dnFC2 = (defColor 25 60 80)		
	local tbFont = (defFontBold "Verdana" 7), tbFont1 = (defFontReg "ISOCPEUR" 11), btnFont = (defFontReg "Webdings" 19), btnFont1 = (defFontBold "Wingdings" 19), bnrFont = (defFontBold "Tahoma" 10)
	local dnBS = (dotNetClass "BorderStyle").None, dnBS1 = (dotNetClass "BorderStyle").FixedSingle, dnFS = (dotNetClass "FlatStyle").Popup, dnCrs = (dotNetClass "Cursors").Hand
	local dnCA1 = (dotNetClass "System.Drawing.ContentAlignment").MiddleCenter
	local dnCA2 = (dotNetClass "System.Drawing.ContentAlignment").MiddleLeft
	local dnCA3 = (dotNetClass "System.Drawing.ContentAlignment").TopCenter
	local dnCA4 = (dotNetClass "System.Drawing.ContentAlignment").MiddleRight
	local dnTHA = (dotNetClass "HorizontalAlignment").Center ; dnGarbage = (dotNetClass "System.GC")
	local dnDR = (dotNetClass "DialogResult") ; dnIOFile = (dotNetClass "System.IO.File")
	local dnIOTW = (dotNetClass "System.IO.StreamWriter") ; dnIOTR = (dotNetClass "System.IO.StreamReader")
	local dnRTBF1 = (dotNetClass "RichTextBoxFinds").MatchCase, dnRTBF2 = (dotNetClass "RichTextBoxFinds").WholeWord
	local dnTSS1 = dotNetObject "ToolStripSeparator", dnTSS2 = dotNetObject "ToolStripSeparator", dnTSS3 = dotNetObject "ToolStripSeparator"
	local menuItmArr = #((defTSMI "Undo"), (defTSMI "Redo"), dnTSS1, (defTSMI "Cut"), (defTSMI "Copy"), (defTSMI "Paste"), dnTSS2, \
	(defTSMI "SelectAll"), (defTSMI "DeselectAll"), dnTSS3, (defTSMI "Refresh"), (defTSMI "Clear"))
/*//////////   dnOBJECT's DEFINITION   //////////*/
	mteForm = dotNetObject "MaxCustomControls.MaxForm" ; defMXSForm mteForm 515 300 " mono • text • edit • v1.1a"
	bgPnl = dotNetObject "MaxCustomControls.MaxUserControl" ; defPnl bgPnl dnBC2 	
	dnOFD = dotNetObject "OpenFileDialog" ; defOSFD dnOFD fiterEXT 6 ms:false
	dnSFD = dotNetObject "SaveFileDialog" ; defOSFD dnSFD fiterEXT 1  aue:true
	dnFontD = dotNetObject "FontDialog" ; defFontD dnFontD tbFont1 dnFC
	openTxt = dotNetObject "Label" ; def1Label openTxt 28 28 mteForm 2 2 btnFont dnBC1 dnFC dnCrs dnCA1 "Ì"
	saveTxt = dotNetObject "Label" ; def1Label saveTxt 28 28 mteForm 30 2 btnFont dnBC1 dnFC dnCrs dnCA1 "Í"
	delTxt = dotNetObject "Label" ; def1Label delTxt 28 28 mteForm 58 2 btnFont dnBC1 dnFC dnCrs dnCA1 "r"
	fontTxt = dotNetObject "Label" ; def1Label fontTxt 28 28 mteForm 86 2 btnFont dnBC1 dnFC dnCrs dnCA1 ">"
	wordwTxt = dotNetObject "Label" ; def1Label wordwTxt 28 28 mteForm 114 2 btnFont dnBC1 dnFC dnCrs dnCA1 "`"
	resetTxt = dotNetObject "Label" ; def1Label resetTxt 28 28 mteForm 142 2 btnFont dnBC1 dnFC dnCrs dnCA1 "y"
	setTxt = dotNetObject "Label" ; def1Label setTxt 28 28 mteForm 170 2 btnFont1 dnBC1 dnFC dnCrs dnCA3 "È"
	getTxt = dotNetObject "Label" ; def1Label getTxt 28 28 mteForm 198 2 btnFont1 dnBC1 dnFC dnCrs dnCA3 "Ê"
	exeTxt = dotNetObject "Label" ; def1Label exeTxt 28 28 mteForm 226 2 btnFont1 dnBC1 dnFC dnCrs dnCA3 "Ö"
	findTxt = dotNetObject "Label" ; def1Label findTxt 28 28 mteForm 254 2 btnFont1 dnBC1 dnFC dnCrs dnCA3 "Ø"
	replTxt = dotNetObject "Label" ; def1Label replTxt 28 28 mteForm 438 2 btnFont1 dnBC1 dnFC dnCrs dnCA3 "×"
	infoTxt = dotNetObject "Label" ; def1Label infoTxt 28 28 mteForm 466 2 btnFont dnBC1 dnFC dnCrs dnCA3 "i"
	bordLbl = dotNetObject "Label" ; def2Label bordLbl 156 28 mteForm 282 2 dnBC1 dnBC3
	bnrLbl = dotNetObject "Label" ; def2Label bnrLbl (mteForm.Width - 512) 28 mteForm 494 2 dnBC1 dnBC3 font:bnrFont txtAlign:dnCA4
	textFind = dotNetObject "DevExpress.XtraPrinting.Native.RichTextBoxEx" ; def2TextBox textFind bordLbl 1 tbFont "             f i n d   w o r d" dnBC3 dnBC4 dnBS
	textRepl = dotNetObject "DevExpress.XtraPrinting.Native.RichTextBoxEx" ; def2TextBox textRepl bordLbl 14 tbFont "        r e p l a c e   w o r d" dnBC3 dnBC4 dnBS
	textInput = dotNetObject "DevExpress.XtraPrinting.Native.RichTextBoxEx" ;	def1TextBox textInput (mteForm.Width - 20) (mteForm.Height - 72) mteForm 2 32 tbFont1 dnBC1 dnFC dnBS
	cnxMenu = dotNetObject "ContextMenuStrip" ; defCnxMenu cnxMenu
	for m in 1 to menuItmArr.count do (cnxMenu.Items.Add menuItmArr[m]) ; bordLbl.Controls.AddRange #(textFind, textRepl)
	bgPnl.Controls.AddRange #(openTxt, saveTxt, delTxt, fontTxt, wordwTxt, resetTxt, setTxt, getTxt, exeTxt, bordLbl, findTxt, replTxt, infoTxt, bnrLbl, textInput)
/*//////////   dnTTip   //////////*/
	dnTTip = dotNetObject "ToolTip" ; dnTTip.AutoPopDelay = 10000 ; dnTTip.InitialDelay = dnTTip.ReshowDelay = 1500
	dnTTip.SetToolTip openTxt "Open Text File" ; dnTTip.SetToolTip saveTxt "Save Text File" ; dnTTip.SetToolTip delTxt "Clear TextBox"
	dnTTip.SetToolTip fontTxt "Change Font" ; dnTTip.SetToolTip wordwTxt "Word Wrap" ; dnTTip.SetToolTip resetTxt "Reset Font And Color"
	dnTTip.SetToolTip setTxt "LMB -> Set User Defined Properties\r\nRMB -> Auto 'Set-Mode' Toggle"
	dnTTip.SetToolTip getTxt "LMB -> Get User Defined Properties\r\RMB -> Auto 'Get-Mode' Toggle"
	dnTTip.SetToolTip exeTxt "Execute All / Selected Code" ; dnTTip.SetToolTip findTxt "Find Word" ; dnTTip.SetToolTip replTxt "Replace Word"
	dnTTipInfo = dotNetObject "ToolTip" ; dnTTipInfo.ToolTipTitle = "   mono • text • edit • v1.1"
	dnTTipInfo.SetToolTip infoTxt "  created by: Branko Zivkovic\r\nemail: barigazy@hotmail.com"
	
/*//////////   FUNCTION FOR THE EVENTS   //////////*/	
	fn RedrawActiveView =
	(
		local vav = viewport.activeViewport
		try(if vav == 1 do viewport.setGridVisibility vav (viewport.getGridVisibility vav)) catch()
	)
	fn selObjCheck = (if selection.count == 1 do textInput.text = getUserPropBuffer selection[1])
	fn create_MTE_Callback = ( callbacks.addScript #selectionSetChanged "noteBox.selObjCheck()" id:#monoTE )
	fn remove_MTE_Callback = ( callbacks.removeScripts id:#monoTE )
	fn dnICOMH s e = (s.ForeColor = dnFC1) ; fn dnICOML s e = (s.ForeColor = dnFC) ; fn dnICOMD s e = (s.ForeColor = dnBC2)
	fn cnxMenuClick s e =
	(
		case e.ClickedItem.Text of
		(
			("Undo"): textInput.Undo()
			("Redo"): textInput.Redo()
			("Cut"): textInput.Cut()
			("Copy"): textInput.Copy()
			("Paste"): textInput.Paste()
			("SelectAll"): textInput.SelectAll()
			("DeselectAll"): textInput.DeselectAll()
			("Refresh"): textInput.Refresh()
			("Clear"): textInput.Clear()
		)
	)	
	fn openTxtClick = 
	( 
		if (dnOFD.ShowDialog() == dnDR.OK) do 
		( 
			local txt = "", fStream = dotNetObject dnIOTR dnOFD.FileName
			while ((input = fStream.ReadLine()) != null) do (txt += input+"\r\n") 
			textInput.SuspendLayout() ; textInput.Text = txt ; textInput.ResumeLayout() ; free txt 
			fStream.Close() ; fStream.Dispose() ; dnGarbage.collect() ; gc light:true
		)
	)
	fn textInputDO s e = (e.Effect = if e.Data.ContainsFileDropList() then e.Effect.Move else e.Effect.None)
	fn textInputDD s e =
	(
		local data = e.data.GetFileDropList(), fileN = data.item[0]
		local txt = "", fStream = dotNetObject dnIOTR fileN
		while ((input = fStream.ReadLine()) != null) do (txt += input+"\r\n") 
		textInput.SuspendLayout() ; textInput.Text = txt ; textInput.ResumeLayout() ; free txt 
		fStream.Close() ; fStream.Dispose() ; dnGarbage.collect() ; gc light:true
	)
	fn saveTxtClick =
	(
		if (textInput.Text == "" or textInput.Text == "\r\n" or textInput.Text == "\t") then #abort else
		(
			if dnSFD.ShowDialog() == dnDR.OK do
			(
				local myTxt = dotNetObject dnIOTW (dnIOFile.Create dnSFD.Filename)
				myTxt.WriteLine textInput.Text ; myTxt.Close() ; myTxt.Dispose()
				myTxt = undefined ; dnGarbage.collect() ; gc light:true
			)
		)
	)
	fn delTxtClick = textInput.Clear()
	fn fontTxtClick =
	(
		local oldFont = textInput.Font, oldClr = textInput.ForeColor
		try (if dnFontD.ShowDialog() == dnDR.OK then (textInput.Font = dnFontD.Font ; textInput.ForeColor = dnFontD.Color)
		else ( textInput.Font = oldFont ; textInput.ForeColor = oldClr ; textInput.SelectionStart = textInput.Text.Count ; dnFontD.Dispose() ))
		catch (textInput.Font = tbFont1 ; textInput.ForeColor = dnFC)
	)
	fn wordwTxtClick =
	(
		if textInput.WordWrap != true then
		(
			textInput.WordWrap = true ; textInput.ScrollBars = textInput.ScrollBars.Vertical ; textInput.SelectionStart = textInput.Text.Count
		)
		else ( textInput.WordWrap = false ; textInput.ScrollBars = textInput.ScrollBars.Both ; textInput.SelectionStart = textInput.Text.Count )
	)
	fn resetTxtClick = ( textInput.Font = tbFont1 ; textInput.ForeColor = dnFC ; textInput.SelectionStart = textInput.Text.Count )
	fn getTxtMU s e =
	(
		if e.Button != e.Button.Right then
		(
			local selObj = selection[1]
			if selection.count == 1 do
			(
				local upbTxt = (getUserPropBuffer selObj), upbCount = upbTxt.count
				if upbCount != 0 do (textInput.text = getUserPropBuffer selObj)
			)
		)
		else
		(
			if getTxt.BackColor != dnBC1 then (getTxt.BackColor = dnBC1 ; remove_MTE_Callback())
			else (getTxt.BackColor = dnFC2 ; create_MTE_Callback())
		)
	)
	fn setTxtMU s e =
	(
		if e.Button != e.Button.Right then
		(
			if selection.count != 0 do
			(				
				if textInput.SelectedText.count == 0 then ( for o in selection do setUserPropBuffer o (replace_LF_with_CRLF textInput.Text) ; RedrawActiveView() )
				else ( for o in selection do setUserPropBuffer o (replace_LF_with_CRLF textInput.SelectedText) ; RedrawActiveView() )
			)
		) else (if setTxt.BackColor != dnBC1 then setTxt.BackColor = dnBC1 else setTxt.BackColor = dnFC2)
	)
	fn exeTxtClick =
	(
		if textInput.SelectedText.count != 0 then
		(
			local txtCode = stringstream textInput.SelectedText
			try execute txtCode catch (print (gce = getCurrentException()) ; textInput.AppendText gce)
		)
		else
		(
			local txtCode = stringstream textInput.Text
			try execute txtCode catch (print (gce = getCurrentException()) ; textInput.AppendText ("\r\n"+gce) ; textInput.SelectedText = gce)
		)
	)
	fn findTxtClick = (textInput.Focus() ; a = textInput.Find (textFind.Text) dnRTBF2)
	fn replTxtClick =
	(
		textInput.Focus()
		if textRepl.Text != "        r e p l a c e   w o r d" and textInput.SelectedText.count != 0 do
		(textInput.SelectedText = textRepl.Text) ; if textFind.Text.count != 0 do (textInput.Find (textFind.Text) dnRTBF2)
	)
	fn dnFontDApply = try( textInput.Font = dnFontD.Font ; textInput.ForeColor = dnFontD.Color ) catch()
	fn textInputGF s e = (s.BackColor = dnBC3) ; fn textInputLF s e = ( s.BackColor = dnBC1 /*; format "Lines = %\n" s.Lines[s.Lines.count]*/)
	fn textInputMU s e = (if e.Button == e.Button.Right do (cnxMenu.Show s (defPoint e.x e.y)))
	fn textInputTC =
	(
		if (selection.count == 1 and setTxt.BackColor == dnFC2) do
		(
			setUserPropBuffer selection[1] (replace_LF_with_CRLF textInput.Text) ; RedrawActiveView()
		)
	)
	fn textFindGF =
	(
		if (textFind.Text == "             f i n d   w o r d" and textFind.ForeColor == dnBC4) do
		(textFind.Text = "" ; textFind.ForeColor = dnFC1)
	)
	fn textFindLF =
	(
		if (textFind.Text == "" and textFind.ForeColor == dnFC1) do
		(textFind.Text = "             f i n d   w o r d" ; textFind.ForeColor = dnBC4)
	)
	fn textReplGF =
	(
		if (textRepl.Text == "        r e p l a c e   w o r d" and textRepl.ForeColor == dnBC4) do
		(textRepl.Text = "" ; textRepl.ForeColor = dnFC1)
	)
	fn textReplLF =
	(
		if (textRepl.Text == "" and textRepl.ForeColor == dnFC1) do
		(textRepl.Text = "        r e p l a c e   w o r d" ; textRepl.ForeColor = dnBC4)
	)
	fn mteFormSC s e =
	(
		textInput.Width = (s.Width - 20) ; textInput.Height = (s.Height - 72)
		bnrLbl.Width = (s.Width - 512) ; if bnrLbl.Width >= 160 then bnrLbl.Text = "• mono • text • edit • " else bnrLbl.Text = ""
	)
	fn mteFormClose = 
	(
		textInput.ClearUndo() ; cnxMenu.Dispose()
		for rtb in bordLbl.Controls.count-1 to 0 by -1 do (bordLbl.Controls.item[rtb].Dispose())
		for c in bgPnl.Controls.count-1 to 0 by -1 do (bgPnl.Controls.item[c].Dispose())
		bgPnl.Dispose() ; remove_MTE_Callback() ; dnGarbage.collect() ; gc light:true ; clearListener()
	)

/*//////////   ADD TO FORM  //////////*/
	mteForm.Controls.Add bgPnl
	mteForm.ShowModeless() ; textInput.Focus()

/*//////////   ASSIGN THE EVENTS   //////////*/
	dotNet.addEventHandler cnxMenu "ItemClicked" cnxMenuClick
	dotNet.addEventHandler mteForm "SizeChanged" mteFormSC
	dotNet.addEventHandler mteForm "Closed" mteFormClose	
		
	dotNet.addEventHandler openTxt "MouseHover" dnICOMH
	dotNet.addEventHandler openTxt "MouseLeave" dnICOML
	dotNet.addEventHandler openTxt "MouseDown" dnICOMD
	dotNet.addEventHandler openTxt "Click" openTxtClick
		
	dotNet.addEventHandler saveTxt "MouseHover" dnICOMH
	dotNet.addEventHandler saveTxt "MouseLeave" dnICOML
	dotNet.addEventHandler saveTxt "MouseDown" dnICOMD
	dotNet.addEventHandler saveTxt "Click" saveTxtClick
		
	dotNet.addEventHandler delTxt "MouseHover" dnICOMH
	dotNet.addEventHandler delTxt "MouseLeave" dnICOML
	dotNet.addEventHandler delTxt "MouseDown" dnICOMD
	dotNet.addEventHandler delTxt "Click" delTxtClick
		
	dotNet.addEventHandler fontTxt "MouseHover" dnICOMH
	dotNet.addEventHandler fontTxt "MouseLeave" dnICOML
	dotNet.addEventHandler fontTxt "MouseDown" dnICOMD
	dotNet.addEventHandler fontTxt "Click" fontTxtClick
	
	dotNet.addEventHandler wordwTxt "MouseHover" dnICOMH
	dotNet.addEventHandler wordwTxt "MouseLeave" dnICOML
	dotNet.addEventHandler wordwTxt "MouseDown" dnICOMD
	dotNet.addEventHandler wordwTxt "Click" wordwTxtClick
	
	dotNet.addEventHandler resetTxt "MouseHover" dnICOMH
	dotNet.addEventHandler resetTxt "MouseLeave" dnICOML
	dotNet.addEventHandler resetTxt "MouseDown" dnICOMD
	dotNet.addEventHandler resetTxt "Click" resetTxtClick
	
	dotNet.addEventHandler setTxt "MouseHover" dnICOMH
	dotNet.addEventHandler setTxt "MouseLeave" dnICOML
	dotNet.addEventHandler setTxt "MouseDown" dnICOMD
	dotNet.addEventHandler setTxt "MouseUp" setTxtMU
	
	dotNet.addEventHandler getTxt "MouseHover" dnICOMH
	dotNet.addEventHandler getTxt "MouseLeave" dnICOML
	dotNet.addEventHandler getTxt "MouseDown" dnICOMD
	dotNet.addEventHandler getTxt "MouseUp" getTxtMU
	
	dotNet.addEventHandler exeTxt "MouseHover" dnICOMH
	dotNet.addEventHandler exeTxt "MouseLeave" dnICOML
	dotNet.addEventHandler exeTxt "MouseDown" dnICOMD
	dotNet.addEventHandler exeTxt "Click" exeTxtClick
	
	dotNet.addEventHandler findTxt "MouseHover" dnICOMH
	dotNet.addEventHandler findTxt "MouseLeave" dnICOML
	dotNet.addEventHandler findTxt "MouseDown" dnICOMD
	dotNet.addEventHandler findTxt "Click" findTxtClick
	
	dotnet.AddEventHandler textFind "GotFocus" textFindGF
	dotnet.AddEventHandler textFind "LostFocus" textFindLF
	dotnet.AddEventHandler textRepl "GotFocus" textReplGF
	dotnet.AddEventHandler textRepl "LostFocus" textReplLF
	
	dotNet.addEventHandler replTxt "MouseHover" dnICOMH
	dotNet.addEventHandler replTxt "MouseLeave" dnICOML
	dotNet.addEventHandler replTxt "MouseDown" dnICOMD
	dotNet.addEventHandler replTxt "Click" replTxtClick
	
	dotNet.addEventHandler infoTxt "MouseHover" dnICOMH
	dotNet.addEventHandler infoTxt "MouseLeave" dnICOML
	dotNet.addEventHandler infoTxt "MouseDown" dnICOMD
	
	dotNet.addEventHandler dnFontD "Apply" dnFontDApply
	
	dotnet.AddEventHandler textInput "DragOver" textInputDO
	dotnet.AddEventHandler textInput "DragDrop" textInputDD
	dotnet.AddEventHandler textInput "GotFocus" textInputGF
	dotnet.AddEventHandler textInput "MouseHover" textInputGF
	dotNet.addEventHandler textInput "MouseUp" textInputMU
	dotnet.AddEventHandler textInput "LostFocus" textInputLF
	dotnet.AddEventHandler textInput "TextChanged" textInputTC		
)