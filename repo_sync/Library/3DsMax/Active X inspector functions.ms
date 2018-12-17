ActiveX Inspector Functions
The following Inspector Functions can be used to acquire lists of available ActiveX Controls and their methods, events, and properties:
showAllActiveXControls [ to:<stream> ]
Prints a list of ActiveX controls with their progID and classID, registered on your system.
showMethods <axControl> [ to:<stream> ] [showHidden:<false>]
Prints a list of methods and their arguments that can be invoked on the control
showEvents <axControl> [ to:<stream> ]
Prints a list of events and their arguments that are sent by the control
showProperties <axControl> [ to:<stream> ] [showHidden:<false>]
Prints a list of the properties and their types, supported by the control. Some properties are marked read-only
getPropNames <axControl> [showHidden:<false>]
Returns an array of the properties supported by the control
where
to:<stream> 
is the output stringstream.
showHidden:<boolean> 
controls whether hidden properties/methods should be included in the enumeration. The default value is false. 
For example, 
rollout test "Test" 

( 
	activeXControl lv "MSComctlLib.ListViewCtrl"
	on test open do 
	(
		format "PROPERTIES:\n"
		showProperties lv
		format "METHODS:\n"
		showMethods lv
		format "EVENTS:\n"
		showEvents lv
	)
)

createDialog test
Result
Rollout:test
PROPERTIES:
.Arrange : ListArrangeConstants( #lvwNone | #lvwAutoLeft | #lvwAutoTop )
.ColumnHeaders : IColumnHeaders
.DropHighlight : IListItem
.DropHighlight : undefined, read-only
.HideColumnHeaders : boolean
.HideSelection : boolean
.Icons : IVBDataObject
.Icons : undefined, read-only
.ListItems : IListItems
.LabelEdit : ListLabelEditConstants( #lvwAutomatic | #lvwManual )
.LabelWrap : boolean
.MouseIcon : IPictureDisp
.MousePointer : MousePointerConstants( #ccDefault | #ccArrow | #ccCross | #ccIBeam | #ccIcon | #ccSize | #ccSizeNESW | #ccSizeNS | #ccSizeNWSE | #ccSizeEW | #ccUpArrow | #ccHourglass | #ccNoDrop | #ccArrowHourglass | #ccArrowQuestion | #ccSizeAll | #ccCustom )
.MultiSelect : boolean
.SelectedItem : IListItem
.SelectedItem : undefined, read-only
.SmallIcons : IVBDataObject
.SmallIcons : undefined, read-only
.Sorted : boolean
.SortKey : integer
.SortOrder : ListSortOrderConstants( #lvwAscending | #lvwDescending )
.View : ListViewConstants( #lvwIcon | #lvwSmallIcon | #lvwList | #lvwReport )
.OLEDragMode : OLEDragConstants( #ccOLEDragManual | #ccOLEDragAutomatic )
.OLEDropMode : OLEDropConstants( #ccOLEDropNone | #ccOLEDropManual )
.Appearance : AppearanceConstants( #ccFlat | #cc3D )
.BackColor : OLE_COLOR
.BorderStyle : BorderStyleConstants( #ccNone | #ccFixedSingle )
.Enabled : boolean
.Font : IFontDisp
.ForeColor : OLE_COLOR
.hWnd : OLE_HANDLE
.AllowColumnReorder : boolean
.Checkboxes : boolean
.FlatScrollBar : boolean
.FullRowSelect : boolean
.GridLines : boolean
.HotTracking : boolean
.HoverSelection : boolean
.Picture : IPictureDisp
.PictureAlignment : ListPictureAlignmentConstants( #lvwTopLeft | #lvwTopRight | #lvwBottomLeft | #lvwBottomRight | #lvwCenter | #lvwTile )
.ColumnHeaderIcons : IVBDataObject
.ColumnHeaderIcons : undefined, read-only
.TextBackground : ListTextBackgroundConstants( #lvwTransparent | #lvwOpaque )
METHODS:
.FindItem sz:string Where:undefined Index:undefined fPartial:undefined
.GetFirstVisible()
.HitTest x:float y:float
.StartLabelEdit()
.OLEDrag()
.Refresh()
EVENTS:
on <control_name> BeforeLabelEdit Cancel:integer do ( ... )
on <control_name> AfterLabelEdit Cancel:integer NewString:string do ( ... )
on <control_name> ColumnClick ColumnHeader:ColumnHeader do ( ... )
on <control_name> ItemClick Item:ListItem do ( ... )
on <control_name> KeyDown KeyCode:integer Shift:integer do ( ... )
on <control_name> KeyUp KeyCode:integer Shift:integer do ( ... )
on <control_name> KeyPress KeyAscii:integer do ( ... )
on <control_name> MouseDown Button:integer Shift:integer x:OLE_XPOS_PIXELS y:OLE_YPOS_PIXELS do ( ... )
on <control_name> MouseMove Button:integer Shift:integer x:OLE_XPOS_PIXELS y:OLE_YPOS_PIXELS do ( ... )
on <control_name> MouseUp Button:integer Shift:integer x:OLE_XPOS_PIXELS y:OLE_YPOS_PIXELS do ( ... )
on <control_name> Click do ( ... )
on <control_name> DblClick do ( ... )
on <control_name> OLEStartDrag &Data:DataObject &AllowedEffects:integer do ( ... )
on <control_name> OLEGiveFeedback &Effect:integer &DefaultCursors:boolean do ( ... )
on <control_name> OLESetData &Data:DataObject &DataFormat:integer do ( ... )
on <control_name> OLECompleteDrag &Effect:integer do ( ... )
on <control_name> OLEDragOver &Data:DataObject &Effect:integer &Button:integer &Shift:integer &x:float &y:float &State:integer do ( ... )
on <control_name> OLEDragDrop &Data:DataObject &Effect:integer &Button:integer &Shift:integer &x:float &y:float do ( ... )
on <control_name> ItemCheck Item:ListItem do ( ... )
true
OK
Type Conversion
All supported COM datatypes are converted to an appropriate MAXScript wrapper when passed to and from a COM object. Here are the supported types and their mapping:
undefined - VT_EMPTY
boolean - VT_BOOL 
integer   - VT_UI1 
integer   - VT_UI2 
integer   - VT_UI4 
integer   - VT_UI8 
integer   - VT_I1 
integer   - VT_I2 
integer   - VT_I4 
integer   - VT_I8 
float  - VT_R4 
float   - VT_R8 
string   - VT_BSTR 
float   - VT_CY 
date   - VT_DATE 
error   - VT_ERROR
color   - VT_COLOR
MSDispatch - VT_DISPATCH
font - VT_FONT 
undefined - VT_UNKNOWN
ComArray - VT_SAFEARRAY
ComArray - VT_CARRAY
ComArray - VT_ARRAY
Valid string handling for property sets and method call arguments, you can safely do 
ax.Navigate "http://beta.discreet.com" 
where: ax is the Microsoft Web Browser Control
Note
Restricted functions like QueryInterface, AddRef, Release are displayed by showMethods() function.
See also
ActiveX Controls in MAXScript Rollouts 

----------------------------------------------------------------------------------------
/*
expDialog.axDirTree.SelectedItem.tag = "D:\\IS_GAMES\\moscow\\edit\\models\\furnitures\\"
expDialog.axDirTree.SelectedItem = "furnitures"
(GetINISetting (mPath() + "Micra.ini") "DefaultPath" "treePath")
setFocus expDialog.axDirTree = "2"
setFocus axDirTree
expDialog.axDirTree.SelectedItem.tag
on <control_name> ColumnClick ColumnHeader:ColumnHeader do ( ... )
on <control_name> ItemClick Item:ListItem do ( ... )
on axDirTree ColumnClick ColumnHeader:ColumnHeader do (print "head tree")
on axDirTree ItemClick Item:ListItem  do(print "folder item")
on axDirTree MouseMove Button Shift x y do format "Button: %, Shift: %, xy: %,%\n" Button Shift x y
setFocus expDialog.axDirTree.tag = "D:\IS_GAMES\moscow\edit\models\\furnitures\"
showProperties expDialog.axDirTree
expDialog.axDirTree.nodes
expDialog.axDirTree.SelectedItem.tag
expDialog.axDirTree.SingleSel
expDialog.axDirTree.DropHighlight
setFocus expDialog.axDirTree
expDialog.axDirTree.SelectItem = "items"
edit (expDialog.axDirTree.selectedItem.tag)
expDialog.axDirTree.SelectedItem.tag = "D:\\IS_GAMES\\moscow\\edit\\models\\furnitures\\"
expDialog.axDirTree.SelectedItem = "furnitures"
setFocus axDirTree
--delete empty folders-----------------------------
--				if (fnFillDirs d tvNode) == 0 do
--					tv.nodes.remove tvNode.index
--------------------------------------------------
*/


--Library Windows scripting host:
F935DC22-1CF0-11D0-ADB9-00C04FD58A0B

--Pouziti knihovny z javou
function writeFile() {
  var fso, file;

  fso = new ActiveXObject("Scripting.FileSystemObject");
  file = fso.CreateTextFile("c:\\helloworld.html", true);
  file.WriteLine("<b>Hello World!</b><p>");
  file.WriteLine("Tímto zpùsobem lze nejen ukládat na disk, ale i 
kopírovat a mazat konkrétní soubory na disku uživatele!");
  file.WriteBlankLines(1);
  file.Close();
}

/*
"RefEdit.Ctrl" "RefEdit.Ctrl" "{00024512-0000-0000-C000-000000000046}" 
"Microsoft Office Chart 9.0" "OWC.Chart.9" "{0002E500-0000-0000-C000-000000000046}" 
"Microsoft Office Spreadsheet 9.0" "OWC.Spreadsheet.9" "{0002E510-0000-0000-C000-000000000046}" 
"Microsoft Office PivotTable 9.0" "OWC.PivotTable.9" "{0002E520-0000-0000-C000-000000000046}" 
"Microsoft Office Data Source Control 9.0" "OWC.DataSourceControl.9" "{0002E530-0000-0000-C000-000000000046}" 
"Microsoft Office Record Navigation Control 9.0" "OWC.RecordNavigationControl.9" "{0002E531-0000-0000-C000-000000000046}" 
"Microsoft Office Expand Control 9.0" "OWC.ExpandControl.9" "{0002E532-0000-0000-C000-000000000046}" 
"Microsoft Office Spreadsheet 10.0" "OWC10.Spreadsheet.10" "{0002E551-0000-0000-C000-000000000046}" 
"Microsoft Office PivotTable 10.0" "OWC10.PivotTable.10" "{0002E552-0000-0000-C000-000000000046}" 
"Microsoft Office Data Source Control 10.0" "OWC10.DataSourceControl.10" "{0002E553-0000-0000-C000-000000000046}" 
"Microsoft Office Record Navigation Control 10.0" "OWC10.RecordNavigationControl.10" "{0002E554-0000-0000-C000-000000000046}" 
"Microsoft Office Chart 10.0" "OWC10.ChartSpace.10" "{0002E556-0000-0000-C000-000000000046}" 
"LEAD Main Control (12.0)" "LEAD.LeadCtrl.120" "{00120000-B1BA-11CE-ABC6-F5B2E79D9E3F}" 
"CRotatedUIText Object" "EPlotViewer.RotatedUIText.1" "{017BC4DC-59CC-4A90-BC82-697938D82B50}" 
"Microsoft UpDown Control, version 5.0 (SP2)" "ComCtl2.UpDown.1" "{026371C0-1B7C-11CF-9D53-00AA003C9CB6}" 
"RotateBvr Class" "(null)" "{027713F2-5FA8-11D2-875B-00A0C93C09B3}" 
"Microsoft DBList Control, version 6.0" "MSDBCtls.DBList.1" "{02A69B00-081B-101B-8933-08002B2F4F5A}" 
"QuickTime Object" "QuickTime.QuickTime.4" "{02BF25D5-8C17-4B23-BC80-D3488ABDDC6B}" 
"Outlook Express Mail Object" "(null)" "{06BE7323-EF34-11D1-ACD8-00C04FA31009}" 
"MSIOff10 Control" "MSIOff10.MSIOffCtrl10.1" "{06CBF134-195C-4A0D-ADA8-9D73C158DBD9}" 
"ActiveXPlugin Object" "Microsoft.ActiveXPlugin.1" "{06DD38D3-D187-11CF-A80D-00C04FD74AD8}" 
"LEDMeter Control" "LEDMETER.LEDMeterCtrl.1" "{070655DC-6AD9-4BB3-A7F9-78359689FBD7}" 
"Microsoft TreeView Control, version 5.0 (SP2)" "COMCTL.TreeCtrl.1" "{0713E8A2-850A-101B-AFC0-4210102A8DA7}" 
"Microsoft ProgressBar Control, version 5.0 (SP2)" "COMCTL.ProgCtrl.1" "{0713E8D2-850A-101B-AFC0-4210102A8DA7}" 
"ActiveSkin Control" "ActiveSkin4.Skin.1" "{0944D16C-D0F4-4389-982A-A085595A9EB3}" 
"WildTangent Multiplayer Class" "WT.WTMultiplayer.1" "{0C097121-C5D6-47EB-841D-30BFF71A71C4}" 
"PDWizard.DepPkgPanels" "PDWizard.DepPkgPanels" "{0DDF3BC1-E692-11D1-AB06-00AA00BDD685}" 
"PDWizard.InetPkgPanels" "PDWizard.InetPkgPanels" "{0DDF3BCB-E692-11D1-AB06-00AA00BDD685}" 
"PDWizard.SetupPkgPanels" "PDWizard.SetupPkgPanels" "{0DDF3BD2-E692-11D1-AB06-00AA00BDD685}" 
"PDWizard.DeployWizPanels" "PDWizard.DeployWizPanels" "{0DDF3BDD-E692-11D1-AB06-00AA00BDD685}" 
"PDWizard.PackageWizPanels" "PDWizard.PackageWizPanels" "{0DDF3BE1-E692-11D1-AB06-00AA00BDD685}" 
"ScriptControl Object" "MSScriptControl.ScriptControl.1" "{0E59F1D5-1FBE-11D0-8FF2-00A0D10038BC}" 
"VocabCtl Class" "Pkmaxctl.VocabCtl.1" "{0E92978A-036B-4353-AFE1-7A8F2129C6C3}" 
"Microsoft Hierarchical FlexGrid Control, Version 6.0 (OLEDB)" "MSHierarchicalFlexGridLib.MSHFlexGrid.6" "{0ECD9B64-23AA-11D0-B351-00A0C9055D8E}" 
"CSheetListCtrl Object" "EPlotViewer.SheetListCtrl.1" "{14576C48-FAB9-4FFB-A206-822B2C25C3BB}" 
"CSheetPropertiesCtrl Object" "EPlotViewer.SheetPropertiesCtrl.1" "{15E51407-130C-47A7-A46C-8A5A136DFF1E}" 
"LM Runtime Control" "LM.LMReader.1" "{183C259A-0480-11D1-87EA-00C04FC29D46}" 
"Outlook Express Mime Editor" "OutlookExpress.MimeEdit.1" "{1C82EAD9-508E-11D1-8DCF-00C04FB951F9}" 
"ThumbCtl Class" "ThumbCtl.ThumbCtl.1" "{1D2B4F40-1F10-11D1-9E88-00C04FDCAB92}" 
"Microsoft Animation Control, version 5.0 (SP2)" "ComCtl2.Animation.1" "{1E216240-1B7D-11CF-9D53-00AA003C9CB6}" 
"Microsoft TabStrip Control 6.0 (SP4)" "MSComctlLib.TabStrip.2" "{1EFB6596-857C-11D1-B16A-00C0F0283628}" 
"Microsoft Date and Time Picker Control, version 6.0" "MSComCtl2.DTPicker.2" "{20DD1B9E-87C4-11D1-8BE3-0000F8754DA1}" 
"Autodesk i-drop Control" "idrop.idrop.2" "{21E0CB95-1198-4945-A3D2-4BF804295F78}" 
"Microsoft MonthView Control, version 6.0" "MSComCtl2.MonthView.2" "{232E456A-87C3-11D1-8BE3-0000F8754DA1}" 
"Outlook Express Message List" "OutlookExpress.MessageList.1" "{233A9692-667E-11D1-9DFB-006097D50408}" 
"CMarkupPropertiesCtrl Object" "CMarkupPropertiesCtrlPID" "{2533EFA9-680D-4C3A-BED2-DFBA9DA92D94}" 
"Msie Control" "MSIE.MsieCtrl.1" "{25959BEF-E700-11D2-A7AF-00C04F806200}" 
"System Information" "Msinfo32.MSInfo.1" "{273380E8-1438-4B2C-95B0-713284FBC302}" 
"ListPad class" "ListPad.ListPad.1" "{289228DE-A31E-11D1-A19C-0000F875B132}" 
"RemoteDesktopClientHost Class" "RDCHost.RemoteDesktopClientHost.1" "{299BE050-E83E-4DB7-A7DA-D86FDEBFE6D0}" 
"Microsoft ImageList Control 6.0 (SP4)" "MSComctlLib.ImageListCtrl.2" "{2C247F23-8591-11D1-B16A-00C0F0283628}" 
"DHTML Edit Control for IE5" "DHTMLEdit.DHTMLEdit.1" "{2D360200-FFF5-11D1-8D03-00A0C959BC0A}" 
"DHTML Edit Control Safe for Scripting for IE5" "DHTMLSafe.DHTMLSafe.1" "{2D360201-FFF5-11D1-8D03-00A0C959BC0A}" 
"CModelCtrl Object" "EModelViewer.CModelCtrl.1" "{2D476B4B-4F5A-41F7-8619-69DFBB7BF3C8}" 
"BrowserHelp" "AssistCtrl.BrowserHelp.1" "{2D47A20D-B782-4AE5-9C25-CA85A0BAD2DC}" 
"CAdEModelViewerCommandHandler Object" "EModelViewer.AdEModelCommandHandler.1" "{2D636E42-21FD-4EC9-82F9-F7DCFF6702C3}" 
"HtmlDlgHelper Class" "HtmlDlgHelper.HtmlDlgHelper.1" "{3050F4E1-98B5-11CF-BB82-00AA00BDCE0B}" 
"Pegasus ImagXpress Control v5.0" "ImagXpr5.ImagXpress.1" "{32DCBA0E-9D05-11D3-A8FB-444553540000}" 
"Tabular Data Control" "TDCCtl.TDCCtl.1" "{333C7BC4-460F-11D0-BC04-0080C7055A83}" 
"Microsoft ProgressBar Control 6.0 (SP4)" "MSComctlLib.ProgCtrl.2" "{35053A22-8589-11D1-B16A-00C0F0283628}" 
"Microsoft RDP Client Control" "MsTscAx.MsTscAx.3" "{3523C2FB-4031-44E4-9A3B-F1E94986EE7F}" 
"Microsoft DirectAnimation Structured Graphics" "DirectAnimation.StructuredGraphicsControl" "{369303C2-D7AC-11D0-89D5-00A0C90833E6}" 
"Microsoft Slider Control, version 5.0 (SP2)" "COMCTL.Slider.1" "{373FF7F0-EB8B-11CD-8820-08002B2F4F5A}" 
"TSHOOTCtrl Class" "Microsoft.TSHOOTCtrl.3.1" "{37536094-0A44-11D3-854B-004005506310}" 
"ColorBvr Class" "(null)" "{3845A174-EB30-11D1-9A23-00A0C879FE5F}" 
"CPropertiesCtrl Object" "EPlotViewer.PropertiesCtrl.1" "{38918CC7-2B3A-462E-B1C3-4DC2D611FD46}" 
"MSWebDVD Class" "MSWebDVD.MSWebDVD.1" "{38EE5CEE-4B62-11D3-854F-00A0C9C898E7}" 
"Application Data Control" "ADCCtl.ADCCtl.1" "{3964D9A0-AC96-11D1-9851-00C04FD91972}" 
"CMarkupsCtrl Object" "EPlotViewer.MarkupsCtrl.1" "{39C9FCE4-83B6-4667-988E-735682E4DD1F}" 
"Microsoft Chart Control, version 6.0 (OLEDB)" "MSChart20Lib.MSChart.2" "{3A2B370C-BA0A-11D1-B137-0000F8753F5D}" 
"WildTangent Active Launcher" "WildTangent.ActiveLauncher.2" "{3A7FE611-1994-4EF1-A09F-99456752289D}" 
"Microsoft Rich Textbox Control 6.0 (SP4)" "RICHTEXT.RichtextCtrl.1" "{3B7C8860-D78F-101B-B9B5-04021C009402}" 
"LEDMeter Control 2.0" "AUDIOCONTROLS2.LEDMeterCtrl.1" "{3CEC18D8-3C79-4570-82E6-81D54AB300C3}" 
"NetMeeting Application" "NetMeeting.App.1" "{3E9BAF2D-7A79-11D2-9334-0000F875AE17}" 
"COMNSView Class" "COMSNAP.COMNSView.1" "{410381DB-AF42-11D1-8F10-00C04FC2C17B}" 
"Recording Control" "RECORDING.RecordingCtrl.1" "{42A3A9AB-F7B4-40B1-B2AA-F31E35459D4A}" 
"Microsoft RemoteData Control, version 6.0" "msrdc20.RemoteDataCtl.2" "{43478D73-78E0-11CF-8E78-00A0D100038E}" 
"TrialEnd Class" "TrialEnd.TrialEnd.1" "{438B8ECD-AD2A-11D1-ADEB-0000F87734F0}" 
"Link Bar" "FPDTC.LINKBAR.1" "{4421FEDE-A45D-11D3-9F7C-005004AE6818}" 
"List View" "FPDTC.LISTVIEW.1" "{4421FEE2-A45D-11D3-9F7C-005004AE6818}" 
"CDDBWinampControl Class" "CDDBControlWinamp.CDDBWinampControl.1" "{44B09A5F-5DEE-4539-8001-D4B2D45C2876}" 
"wpdlx Control" "xwpdlx20.wpdlx" "{44DE2FE5-C775-11D4-AAD4-DA7E8D958A70}" 
"TaskSymbol Class" "Control.TaskSymbol.1" "{44F9A03B-A3EC-4F3B-9364-08E0007F21DF}" 
"WIA Video Preview Class" "DShowPreview.VideoPreview.1" "{457A23DF-6F2A-4684-91D0-317FB768D87C}" 
"Microsoft Forms 2.0 MultiPage" "Forms.MultiPage.1" "{46E31370-3F7A-11CE-BED6-00AA00611080}" 
"Search Assistant Control" "SrchUI.SearchAssistant.1" "{47C6C527-6204-4F91-849D-66E234DEE015}" 
"Microsoft Internet Transfer Control 6.0 (SP4)" "InetCtls.Inet.1" "{48E59293-9880-11CF-9754-00AA00C00908}" 
"DSDisplayPanel Class" "DSDisplayPanel.DSDisplayPanel.1" "{49FC0185-4B32-11D1-A40E-00600831F336}" 
"CAdEModelViewerCommandMap Object" "EModelViewer.AdEModelViewerCommandMap.1" "{4A5142CA-390A-45E8-B6CA-74DF3A2AC0D7}" 
"CHtmlMenuWidget Object" "EModelViewer.HtmlMenuWidget.1" "{4BEFBA1D-E29F-4CC4-B082-E01C87219FBC}" 
"Microsoft Forms 2.0 Image" "Forms.Image.1" "{4C599241-6926-101B-9992-00000B65C6F9}" 
"RegWizCtrl " "RegWizCtrl.RegWizCtrl.1" "{50E5E3D1-C07E-11D0-B9FD-00A0249F6B00}" 
"Preview Class" "Preview.Preview.1" "{50F16B26-467E-11D1-8271-00C04FC3183B}" 
"EffectBvr Class" "(null)" "{54274112-7A5E-11D2-875F-00A0C93C09B3}" 
"MMCCtrl class" "MMCCtrl.MMCCtrl.1" "{545AE700-50BF-11D1-9FE9-00600832DB4A}" 
"Mouse_Events.Mouse" "Mouse_Events.Mouse" "{5754A833-F79C-11D3-A259-0080C8588E1D}" 
"ActionBvr Class" "(null)" "{58A2E406-8304-11D2-9533-0060B0C3C4F4}" 
"Microsoft ListView Control, version 5.0 (SP2)" "COMCTL.ListViewCtrl.1" "{58DA8D8A-9D6A-101B-AFC0-4210102A8DA7}" 
"Microsoft ImageList Control, version 5.0 (SP2)" "COMCTL.ImageListCtrl.1" "{58DA8D8F-9D6A-101B-AFC0-4210102A8DA7}" 
"SkinLabel Class" "ActiveSkin4.SkinLabel.1" "{5954EA75-9BFA-461A-BD34-CEA3A861FF19}" 
"CoverEdCtrl Control" "COVEREDCTRL.CoverEdCtrl.1" "{59FA1D1E-3B4C-4311-BB1B-7BF16C607388}" 
"CRotatedUIText Object" "EModelViewer.RotatedUIText.1" "{5F75EADD-DAB5-4922-BD02-1B9BD8617087}" 
"Microsoft DataRepeater Control, version 6.0" "MSDataRepeaterLib.DataRepeater.1" "{601EB760-8909-11D0-9483-00A0C91110ED}" 
"Microsoft UpDown Control, version 6.0" "MSComCtl2.UpDown.2" "{603C7E80-87C2-11D1-8BE3-0000F8754DA1}" 
"Microsoft Toolbar Control, version 5.0 (SP2)" "COMCTL.Toolbar.1" "{612A8624-0FB3-11CE-8747-524153480004}" 
"Microsoft FlexGrid Control, version 6.0" "MSFlexGridLib.MSFlexGrid.1" "{6262D3A0-531B-11CF-91F6-C2863C385E30}" 
"WTDMMPVersion Class" "Wtdmmpv.WTDMMPVersion.1" "{65E7DB1D-0101-4100-BD66-C5C78C917F93}" 
"Microsoft Toolbar Control 6.0 (SP4)" "MSComctlLib.Toolbar.2" "{66833FE6-8583-11D1-B16A-00C0F0283628}" 
"CurveEdit Control 2.0" "AUDIOCONTROLS2.CurveEditCtrl.1" "{6683A3CD-724F-402E-A2C3-DC410AD12D76}" 
"SelectFile Class" "CompatUI.SelectFile.1" "{66CBC149-A49F-48F9-B17A-6A3EA9B42A87}" 
"Migration Wizard OOBE Automation Object" "MigrationWizard.OOBE.1" "{67331D85-BE17-42F6-8D3F-47B8E8B26637}" 
"Microsoft ADO Data Control, version 6.0 (OLEDB)" "MSAdodcLib.Adodc.6" "{67397AA3-7FB1-11D0-B148-00A0C922E820}" 
"CAdEPlotViewerCommandMap Object" "EPlotViewer.AdEPlotViewerCommandMap.1" "{679A16FB-49EB-45A6-BD78-11A7B67936D8}" 
"Microsoft DirectAnimation Windowed Control" "DirectAnimation.DirectAnimationWindowedIntegratedMediaControl.1" "{69AD90EF-1C20-11D1-8801-00C04FC29D46}" 
"Microsoft StatusBar Control, version 5.0 (SP2)" "COMCTL.SBarCtrl.1" "{6B7E638F-850A-101B-AFC0-4210102A8DA7}" 
"Windows Media Player" "WMPlayer.OCX.7" "{6BF52A52-394A-11D3-B153-00C04F79FAA6}" 
"ActorBvr Class" "(null)" "{6DDE3061-736C-11D2-A5E8-00A0C967A25F}" 
"SVG Document" "Adobe.SVGCtl.1" "{6DE3F233-DBE6-11D2-AE81-00C04F7FE3EF}" 
"Microsoft Forms 2.0 Frame" "Forms.Frame.1" "{6E182020-F460-11CE-9BCD-00AA00608E01}" 
"InstallEngineCtl Object" "ASControls.InstallEngineCtl.1" "{6E449683-C509-11CF-AAFA-00AA00B6015C}" 
"CMissingFontsCtrl Object" "EPlotViewer.MissingFontsCtrl.1" "{6F59AA1D-7896-4E38-88E7-53FA9CBE772A}" 
"CObjectPropertiesCtrl Object" "EPlotViewer.ObjectPropertiesCtrl.1" "{6FD07BA6-1497-4431-87FC-BDE60F073B04}" 
"Autodesk EPlot Viewer Control" "EPlotViewer.AdPageViewer.1" "{715941D4-1AC2-4545-8185-BC40E053B551}" 
"ThumbCtl Class" "ThumbCtl.ThumbCtl.2" "{71650000-E8A8-11D2-9652-00C04FC30871}" 
"GetAM Class" "MGSSSI.GetAM.1" "{72F89B75-654C-4F47-9C3B-938C0248D6DD}" 
"Cr Behavior Factory" "(null)" "{754FF233-5D4E-11D2-875B-00A0C93C09B3}" 
"Autodesk EModelViewer Control" "EModelViewer.EModelViewerControl.1" "{75E513A9-6C41-4C91-BAA6-81E593FAAC10}" 
"HPODThum Control" "HPODTHUM.HPODThumCtrl.1" "{76FFC980-CD4A-4AAA-B796-92C66CABB074}" 
"Microsoft Forms 2.0 SpinButton" "Forms.SpinButton.1" "{79176FB0-B7F2-11CE-97EF-00AA006D2776}" 
"Microsoft RDP Client Control" "MsTscAx.MsTscAx.2" "{7CACBD7B-0D99-468F-AC33-22E495C0AFE5}" 
"CNavigationCtrl Object" "EPlotViewer.NavigationCtrl.1" "{7D4E01A7-A2A0-4C04-9B66-2754E00BE373}" 
"PathBvr Class" "(null)" "{80F49562-6A9A-11D2-875F-00A0C93C09B3}" 
"Knob Control 2.0" "AUDIOCONTROLS2.KnobCtrl.1" "{8352EDFE-28C3-4012-90BC-43B0AF7B7E57}" 
"AddFlow 4 ActiveX Control" "ADDFLOW.AddFlowCtrl.1" "{83B0E426-D4EE-11D4-BEDF-BAB7F1EEA455}" 
"WebViewFolderIcon Class" "WebViewFolderIcon.WebViewFolderIcon.2" "{844F4806-E8A8-11D2-9652-00C04FC30871}" 
"Microsoft Web Browser" "Shell.Explorer.2" "{8856F961-340A-11D0-A96B-00C04FD705A2}" 
"Microsoft ActiveX Upload Control, version 1.5" "MSFlUpl.Flupl.1" "{886E7BF0-C867-11CF-B1AE-00AA00A3F2C3}" 
"VideoRenderCtl Class" "VideoRenderCtl.VideoRenderCtl.1" "{888D5481-CABB-11D1-8505-00A0C91F9CA0}" 
"adbanner Class" "adbanner.adbanner.1" "{89643D21-7B2A-11D1-8271-00A0C91F9CA0}" 
"DSStatusBar Class" "DSStatusBar.DSStatusBar.1" "{8A3F59E1-4994-11D1-A40D-00600831F336}" 
":-) VideoSoft FlexArray Control" "VSFLEX.vsFlexArrayCtrl.1" "{8AE029D3-08E3-11D1-BAA2-444553540000}" 
":-) VideoSoft FlexString Control" "VSFLEX.vsFlexStringCtrl.1" "{8AE029D6-08E3-11D1-BAA2-444553540000}" 
"CAdEPlotCmdHandlers Object" "EPlotViewer.AdEPlotCmdHandlers.1" "{8BA842D8-2069-4EFE-BB24-AFEB40EB470A}" 
"Microsoft Forms 2.0 TextBox" "Forms.TextBox.1" "{8BD21D10-EC42-11CE-9E0D-00AA006002F3}" 
"Microsoft Forms 2.0 ListBox" "Forms.ListBox.1" "{8BD21D20-EC42-11CE-9E0D-00AA006002F3}" 
"Microsoft Forms 2.0 ComboBox" "Forms.ComboBox.1" "{8BD21D30-EC42-11CE-9E0D-00AA006002F3}" 
"Microsoft Forms 2.0 CheckBox" "Forms.CheckBox.1" "{8BD21D40-EC42-11CE-9E0D-00AA006002F3}" 
"Microsoft Forms 2.0 OptionButton" "Forms.OptionButton.1" "{8BD21D50-EC42-11CE-9E0D-00AA006002F3}" 
"Microsoft Forms 2.0 ToggleButton" "Forms.ToggleButton.1" "{8BD21D60-EC42-11CE-9E0D-00AA006002F3}" 
"MSDVDAdm Class" "MSWebDVD.MSDVDAdm.1" "{8D670533-270B-4549-B19B-414FB9C6EBDB}" 
"Microsoft StatusBar Control 6.0 (SP4)" "MSComctlLib.SBarCtrl.2" "{8E3867A3-8586-11D1-B16A-00C0F0283628}" 
"CViewsCtrl Object" "EPlotViewer.ViewsCtrl.1" "{8F437EB3-7ACD-4F5E-9D94-72D30202093E}" 
"CPropertiesCtrl Object" "EModelViewer.CPropertiesCtrl.1" "{90E9665B-C4D9-4625-97DB-34E89129B6A3}" 
"CAdEPlotViewerCommandMap Object" "EPlotViewer.AdEPlotCommandMapEntry.1" "{956F1F7E-32BE-4FAE-8D20-8178B7D12D46}" 
"MSDTHostCtrl Class" "MSDTHostCtrl.MSDTHostCtrl.1" "{97240642-F896-11D0-B255-006097C68E81}" 
"Microsoft Forms 2.0 Label" "Forms.Label.1" "{978C9E23-D4B0-11CE-BF2D-00AA003F40D0}" 
"Microsoft Shell Folder View Router" "Shell.FolderView.1" "{9BA05971-F6A8-11CF-A442-00A0C90A8F39}" 
"Microsoft TabStrip Control, version 5.0 (SP2)" "COMCTL.TabStrip.1" "{9ED94440-E5E8-101B-B9B5-444553540000}" 
"gotobar Class" "gotobar.gotobar.1" "{9F4D2FA2-54A1-11D1-8267-00A0C91F9CA0}" 
"CMissingFontsCtrl Object" "EModelViewer.MissingFontsCtrl.1" "{A0BAC696-6302-4BF3-924A-B06CA8C03F1D}" 
"Microsoft Terminal Services Control" "MsTscAx.MsTscAx.2" "{A41A4187-5A86-4E26-B40A-856F9035D9CB}" 
"Autodesk DWF Viewer Control" "AdView.AdViewer.1" "{A662DA7E-CCB7-4743-B71A-D817F6D575DF}" 
"Axis Control 2.0" "AUDIOCONTROLS2.AxisCtrl.1" "{A7F78220-7648-4826-837B-6001E2AD7824}" 
"LevelSlider Control 2.0" "AUDIOCONTROLS2.LevelSliderCtrl.1" "{A8DC3A14-CBFC-4BE8-995D-2FDB6C7AA9F2}" 
"CBookmarksCtrl Object" "EModelViewer.CBookmarksCtrl.1" "{AA072F8B-364C-4233-84F0-AF1EDA6D5DA6}" 
"WTHoster Class" "WDMHHost.WTHoster.1" "{AB29A544-D6B4-4E36-A1F8-D3E34FC7B00A}" 
"Outlook Express MsgTable Object" "(null)" "{ABC00000-0000-0000-0000-000000000000}" 
"CLayersCtrl Object" "EPlotViewer.LayersCtrl.1" "{ABFBB788-7824-4314-ADE1-C570DD692313}" 
"HHCtrl Object" "Internet.HHCtrl.1" "{ADB880A6-D8FF-11CF-9377-00AA003B7A11}" 
"Microsoft Scriptlet Component" "ScriptBridge.ScriptBridge.1" "{AE24FDAE-03C6-11D1-8B76-0080C744F389}" 
"Autodesk VIZable Control" "AxVizable.AxVizable.1" "{AF2880B4-B183-11D2-ADE7-00A0245D8F3F}" 
"MMC IconControl class" "MMC.IconControl.1" "{B0395DA5-6A15-4E44-9F36-9A9DC7A2F341}" 
"Microsoft Animation Control, version 6.0" "MSComCtl2.Animation.2" "{B09DE715-87C1-11D1-8BE3-0000F8754DA1}" 
"Microsoft DirectAnimation Sequencer" "DirectAnimation.SequencerControl" "{B0A6BAE2-AAF0-11D0-A152-00A0C908DB96}" 
"MS TV Video Control" "MSVidCtl.MSVidCtl.1" "{B0EDF163-910A-11D2-B632-00C04F79498E}" 
"LM Behavior Factory" "(null)" "{B1549E58-3894-11D2-BB7F-00A0C999C4C1}" 
"Microsoft DirectAnimation Control" "DirectAnimation.DirectAnimationIntegratedMediaControl.1" "{B6FFC24C-7E13-11D0-9B47-00C04FC2F51D}" 
"ProgView Class" "CompatUI.ProgView.1" "{B9B7D40C-0C41-4EAF-B0B5-6B41378C7F48}" 
"SetBvr Class" "(null)" "{BA60F742-6F72-11D2-875F-00A0C93C09B3}" 
"LM Auto Effect Behaivor" "(null)" "{BB339A46-7C49-11D2-9BF3-00C04FA34789}" 
"Axis Control" "AXIS.AxisCtrl.1" "{BCD7AC23-9FB7-4E16-9C97-D5225D2567B5}" 
"Microsoft Tabbed Dialog Control, version 6.0" "TabDlg.SSTab.1" "{BDC217C5-ED16-11CD-956C-0000C04E4C0A}" 
"Microsoft ListView Control 6.0 (SP4)" "MSComctlLib.ListViewCtrl.2" "{BDD1F04B-858B-11D1-B16A-00C0F0283628}" 
"OWS Post Data" "OWS.PostData.1" "{BDEADE98-C265-11D0-BCED-00A0C90AB50F}" 
"MSFlexGridWizard.SubWizard" "MSFlexGridWizard.SubWizard" "{BEC6191B-E6C4-11D1-BE7D-C63815000000}" 
"CSpacePropertiesCtrl Object" "EModelViewer.CSpacePropertiesCtrl.1" "{BFDAD882-AF78-4117-BF97-73F583800E1B}" 
"OleInstall Class" "OlePrn.OleInstall.1" "{C3701884-B39B-11D1-9D68-00C04FC30DF6}" 
"SysColorCtrl class" "SysColorCtrl.SysColorCtrl.1" "{C47195EC-CD7A-11D1-8EA3-00C04F9900D7}" 
"System Monitor Control" "Sysmon.3" "{C4D2D8E0-D1DD-11CE-940F-008029004347}" 
"MoveBvr Class" "(null)" "{C5B86F32-69EE-11D2-875F-00A0C93C09B3}" 
"Microsoft TreeView Control 6.0 (SP4)" "MSComctlLib.TreeCtrl.2" "{C74190B6-8589-11D1-B16A-00C0F0283628}" 
"Adobe Acrobat Control for ActiveX" "PDF.PdfCtrl.5" "{CA8A9780-280D-11CF-A24D-444553540000}" 
"LanguageResources Class" "MsoLang.LanguageResources.1" "{CC0B082D-A7FB-11D3-BC35-00C04F79E594}" 
"CTreeView Control" "CTREEVIEW.CTreeViewCtrl.1" "{CD6C7868-5864-11D0-ABF0-0020AF6B0B7A}" 
"Microsoft DataGrid Control, Version 6.0 (OLEDB)" "MSDataGridLib.DataGrid.1" "{CDE57A43-8B86-11D0-B3C6-00A0C90AEA82}" 
"RealPlayer G2 Control" "rmocx.RealPlayer G2 Control.1" "{CFCDAA03-8BE4-11CF-B84B-0020AFBBCCFA}" 
"Shockwave Flash Object" "ShockwaveFlash.ShockwaveFlash.1" "{D27CDB6E-AE6D-11CF-96B8-444553540000}" 
"Macromedia Flash Factory Object" "FlashFactory.FlashFactory.1" "{D27CDB70-AE6D-11CF-96B8-444553540000}" 
"Microsoft Agent Control 2.0" "Agent.Control.2" "{D45FD31B-5C6E-11D1-9EC1-00C04FD7081F}" 
"MSChartWiz.SubWizard" "MSChartWiz.SubWizard" "{D5288403-E6C5-11D1-BE7D-C63815000000}" 
"Microsoft Forms 2.0 CommandButton" "Forms.CommandButton.1" "{D7053240-CE69-11CD-A777-00DD01143C57}" 
"Microsoft DirectAnimation Path" "DirectAnimation.PathControl" "{D7A7D7C3-D47F-11D0-89D3-00A0C90833E6}" 
"WildWeb Class" "WireControl.WildWeb.1" "{D830B35A-45D2-4828-83E9-2338DCB70620}" 
"CAdEModelViewerCommandMapEntry Object" "EModelViewer.AdEModelCommandMapEntry.1" "{D8BD9A1E-E819-4D4C-B682-DF1BF4956316}" 
"Sky Software FolderView ActiveX Control 3.2" "FolderView.FolderViewCtrl.1" "{D9812706-90EB-11D2-887A-BD32CB08A467}" 
"Microsoft ImageComboBox Control 6.0 (SP4)" "MSComctlLib.ImageComboCtl.2" "{DD9DA666-8594-11D1-B16A-00C0F0283628}" 
"CHtmlMenuWidget Object" "EPlotViewer.HtmlMenuWidget.1" "{DDB42DC2-7B8A-4A16-82D7-82E879ADE5E0}" 
"Microsoft Forms 2.0 ScrollBar" "Forms.ScrollBar.1" "{DFD181E0-5E2F-11CE-A449-00AA004A803D}" 
"WebViewFolderIcon Class" "WebViewFolderIcon.WebViewFolderIcon.1" "{E5DF9D10-3B52-11D1-83E8-00A0C90DC849}" 
"Effect Control" "EFFECTCTRL.EffectCtrl.1" "{E6674EE4-57B1-42F2-A953-43705B992AD5}" 
"ScaleBvr Class" "(null)" "{E80353D3-677D-11D2-875E-00A0C93C09B3}" 
"CNavigationCtrl Object" "EModelViewer.CNavigationCtrl.1" "{E8C656D0-11B0-4E71-8B3F-C6384A673079}" 
"CObjectPropertiesCtrl Object" "EModelViewer.CObjectPropertiesCtrl.1" "{E8CFE813-A20B-49EB-9C0F-55F6C56DB775}" 
"AppWizard6.SubWizard" "AppWizard6.SubWizard" "{E9FAECA2-AC84-11D1-8F3B-00A0C9150754}" 
"Microsoft Forms 2.0 TabStrip" "Forms.TabStrip.1" "{EAE50EB0-4A62-11CE-BED6-00AA00611080}" 
"NumberBvr Class" "(null)" "{ECDB03D2-6E99-11D2-875F-00A0C93C09B3}" 
"CBookmarksCtrl Object" "EPlotViewer.BookmarksCtrl.1" "{EE114D79-9A5D-41D2-A659-41CACD781086}" 
"DataFormWizard6.ctlWizard" "DataFormWizard6.ctlWizard" "{EE2AA1E7-E6C1-11D1-BE7D-C63815000000}" 
"Microsoft Slider Control 6.0 (SP4)" "MSComctlLib.Slider.2" "{F08DF954-8592-11D1-B16A-00C0F0283628}" 
"Microsoft DataList Control, version 6.0 (OLEDB)" "MSDataListLib.DataList.1" "{F0D2F219-CCB0-11D0-A316-00AA00688B10}" 
"Microsoft DataCombo Control, version 6.0 (OLEDB)" "MSDataListLib.DataCombo.1" "{F0D2F21C-CCB0-11D0-A316-00AA00688B10}" 
"CAdEPlotViewerCommandHandler Object" "EPlotViewer.AdEPlotCommandHandler.1" "{F1EC979D-8AC2-4FD5-A874-B42F811D0E3F}" 
"Microsoft Common Dialog Control, version 6.0" "MSComDlg.CommonDialog.1" "{F9043C85-F6F2-101A-A3C9-08002B2F49FB}" 
"WildTangent Control" "WT3D.WT.1" "{FA13A9FA-CA9B-11D2-9780-00104B242EA3}" 
"Microsoft DBCombo Control, version 6.0" "MSDBCtls.DBCombo.1" "{FAEEE760-117E-101B-8933-08002B2F4F5A}" 
"CThumbnailCtrl Object" "EPlotViewer.ThumbnailCtrl.1" "{FC05969B-6053-43D3-AD7D-1F799D37D3BD}" 
"HelpViewerWrapper Class" "(null)" "{FC7D9E06-3F9E-11D3-93C0-00C04F72DAF7}" 
"PCHToolBar Class" "(null)" "{FC7D9E08-3F9E-11D3-93C0-00C04F72DAF7}" 
"PCHProgressBar Class" "(null)" "{FC7D9E09-3F9E-11D3-93C0-00C04F72DAF7}" 
"Microsoft DirectAnimation Sprite" "DirectAnimation.SpriteControl" "{FD179533-D86E-11D0-89D6-00A0C90833E6}" 
"Microsoft Flat Scrollbar Control, version 6.0" "MSComCtl2.FlatScrollBar.2" "{FE38753A-44A3-11D1-B5B7-0000C09000C4}" 
"Java Class: com.ms.wfc.html.DhComponentWrapper$DhInnerSafeControl" "(null)" "{FFD709F0-AF39-11D2-B854-0000F81E8872}" 
OK

*/