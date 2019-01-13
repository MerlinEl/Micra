// Entire contents copyright (C) 1999-2003, Work Write, Inc.
// and KeyWorks Software. All rights reserved.
// Contact: Cheryl Lockett Zubak at cheri@workwrite.com

var KeyScript;	// KeyHelp.KeyScript ActiveX object
var KeyPopup;   // KeyHelp.KeyPopup  ActiveX object

function KeyApplyInfoTypes(section)
{
	if (!KeyScript)
		KeyScript = new ActiveXObject("KeyHelp.KeyScript");
	KeyScript.ApplyInfoTypes(section);
}

function KeyInitializeUserLevelInput(strSection,idNovice,idIntermediate,idAdvanced)
{
	if (!KeyScript)
		KeyScript = new ActiveXObject("KeyHelp.KeyScript");
	// Initialize our UI
	KeyScript.InitializeUserLevelInput(strSection,idNovice,idIntermediate,idAdvanced);
	// Show/Hide Information Types
	KeyScript.ApplyInfoTypes(strSection);
}

function KeySetUserLevel(section,UserLevel)
{
	if (!KeyScript)
		KeyScript = new ActiveXObject("KeyHelp.KeyScript");
	KeyScript.SetUserLevel(section,UserLevel);
}

function KeySetConceptualInfoType(section,display)
{
	if (!KeyScript)
		KeyScript = new ActiveXObject("KeyHelp.KeyScript");
	KeyScript.SetConceptualInfoType(section,display);
}

function KeyToggleConceptualInfoType(section)
{
	if (!KeyScript)
		KeyScript = new ActiveXObject("KeyHelp.KeyScript");
	KeyScript.ToggleConceptualInformation(section);
}

function KeySetCustomInfoType(section,InfoType,display)
{
	if (!KeyScript)
		KeyScript = new ActiveXObject("KeyHelp.KeyScript");
	KeyScript.SetCustomInfoType(section,InfoType,display);
}

function KeyToggleCustomInfoType(section,InfoType)
{
	if (!KeyScript)
		KeyScript = new ActiveXObject("KeyHelp.KeyScript");
	KeyScript.ToggleCustomInformation(section,InfoType);
}

function KeyControlPanel(CplName,PanelName,TabNumber)
{
	if (!KeyScript)
		KeyScript = new ActiveXObject("KeyHelp.KeyScript");
	KeyScript.ControlPanel(CplName,PanelName,TabNumber);
}

function KeyJumpChm(ChmFile)
{
	if (!KeyScript)
		KeyScript = new ActiveXObject("KeyHelp.KeyScript");
	KeyScript.JumpChm(ChmFile,'');
}

function KeyJumpChmFrame(ChmFile,Frame)
{
	if (!KeyScript)
		KeyScript = new ActiveXObject("KeyHelp.KeyScript");
	KeyScript.JumpChm(ChmFile,Frame);
}

function KeyDisplayDocument(Document,MissingUrlTopic)
{
	if (!KeyScript)
		KeyScript = new ActiveXObject("KeyHelp.KeyScript");
	KeyScript.DisplayDocument(Document,MissingUrlTopic);
}

function KeyLaunchTriPane(ChmFile)
{
	if (!KeyScript)
		KeyScript = new ActiveXObject("KeyHelp.KeyScript");
	KeyScript.LaunchTriPane(ChmFile);
}

function KeyRelatedTopicsMenu(URLs,frame)
{
	if (!KeyScript)
		KeyScript = new ActiveXObject("KeyHelp.KeyScript");
	KeyScript.RelatedTopicsMenu(URLs,frame);
}

function KeyShortCut(ClassName,ProgramName,CmdLine,MissingURL)
{
	if (!KeyScript)
		KeyScript = new ActiveXObject("KeyHelp.KeyScript");
	KeyScript.ShortCut(ClassName,ProgramName,CmdLine,MissingURL);
}

function KeySendMessage(ClassName,msg,wParam,lParam)
{
	if (!KeyScript)
		KeyScript = new ActiveXObject("KeyHelp.KeyScript");
	KeyScript.SendMessage(ClassName,msg,wParam,lParam);
}

function KeySendTCard(wParam,lParam)
{
	if (!KeyScript)
		KeyScript = new ActiveXObject("KeyHelp.KeyScript");
	KeyScript.SendTCard(wParam,lParam);
}

function KeySendTCardText(wParam,strText)
{
	if (!KeyScript)
		KeyScript = new ActiveXObject("KeyHelp.KeyScript");
	KeyScript.SendTCardText(wParam,strText);
}

function KeyDisplayPopup(URL,left,top)
{
	if (!KeyPopup)
		KeyPopup = new ActiveXObject("KeyHelp.KeyPopup");
	KeyPopup.DisplayURL(URL,left,top);
}
