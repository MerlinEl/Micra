f( fso.FileExists( newPath ) ) {
// Selected a file
wsh = ActiveXObject("WScript.Shell")
var WinampPath = wsh.RegRead("HKEY_LOCAL_MACHINE\\SOFTWARE\\Classes\\Winamp.File\\shell\\Enqueue\\command\\");
if( WinampPath != null ) {
new ActiveXObject("Shell.Application").ShellExecute( WinampPath, "\"" + newPath + "\"" );
theTerminal.PopTo( "Winamp" );
}
return false;
} else {

releaseOLEObject <ole_object>
releaseAllOLEObjects()

app_path = "E:/Aprog/Winamp/winamp.exe"

app = CreateOleObject("Shell.Application")

app.IsServiceRunning(app_path)
app.FindFiles ()
app.FindComputer () 
app.FileRun ()  --display run command panel
app.AddToRecent 1 app_path
app.GetSetting 1
app.Windows()
app.MinimizeAll()
app.Open ("E:\Aprog\Winamp") --open folder
app.Help() --display windows help


objFolder = app.NameSpace("E:\Aprog\Winamp") --Creates and returns a Folder object for the specified folder.
objFolderItem = objFolder.ParseName("winamp.exe")
objFolderItem.InvokeVerb("&Delete")
objFolderItem.InvokeVerb("Unp&in from Start Menu")


objWord = createOLEObject("Word.Application")
xl = createOLEObject "Excel.Sheet"
xl.name
createOLEObject("")

registerOLEInterface #(get_object_count,get_object_name,get_object_position) --register functions




Name                 MemberType Definition                                         
----                 ---------- ----------                                         
AddToRecent          Method     void AddToRecent (Variant, string)                 
BrowseForFolder      Method     Folder BrowseForFolder (int, string, int, Variant) 
CanStartStopService  Method     Variant CanStartStopService (string)               
CascadeWindows       Method     void CascadeWindows ()                             
ControlPanelItem     Method     void ControlPanelItem (string)                     
EjectPC              Method     void EjectPC ()                                    
Explore              Method     void Explore (Variant)                             
ExplorerPolicy       Method     Variant ExplorerPolicy (string)                    
FileRun              Method     void FileRun ()                                    
FindComputer         Method     void FindComputer ()                               
FindFiles            Method     void FindFiles ()                                  
FindPrinter          Method     void FindPrinter (string, string, string)          
GetSetting           Method     bool GetSetting (int)                              
GetSystemInformation Method     Variant GetSystemInformation (string)              
Help                 Method     void Help ()                                       
IsRestricted         Method     int IsRestricted (string, string)                  
IsServiceRunning     Method     Variant IsServiceRunning (string)                  
MinimizeAll          Method     void MinimizeAll ()                                
NameSpace            Method     Folder NameSpace (Variant)                         
Open                 Method     void Open (Variant)                                
RefreshMenu          Method     void RefreshMenu ()                                
ServiceStart         Method     Variant ServiceStart (string, Variant)             
ServiceStop          Method     Variant ServiceStop (string, Variant)              
SetTime              Method     void SetTime ()                                    
ShellExecute         Method     void ShellExecute (string, Variant, Variant, Var...
ShowBrowserBar       Method     Variant ShowBrowserBar (string, Variant)           
ShutdownWindows      Method     void ShutdownWindows ()                            
Suspend              Method     void Suspend ()                                    
TileHorizontally     Method     void TileHorizontally ()                           
TileVertically       Method     void TileVertically ()                             
ToggleDesktop        Method     void ToggleDesktop ()                              
TrayProperties       Method     void TrayProperties ()                             
UndoMinimizeALL      Method     void UndoMinimizeALL ()                            
Windows              Method     IDispatch Windows ()                               
WindowsSecurity      Method     void WindowsSecurity ()                            
WindowSwitcher       Method     void WindowSwitcher ()                             
Application          Property   IDispatch Application () {get}                     
Parent               Property   IDispatch Parent () {get}   



  function fnStart(sMethod)
    select case sMethod
      case 0    
          'Minimizes all windows on the desktop
        oShell.MinimizeAll
      case 1  
          'Displays the Run dialog box
        oShell.FileRun
      case 2  
          'Displays the Shut Down Windows dialog box
        oShell.ShutdownWindows
      case 3  
          'Displays the Find dialog box
        oShell.FindFiles
      case 4  
          'Displays the Date/Time dialog box
        oShell.SetTime 
      case 5  
          'Displays the Internet Properties dialog box
        oShell.ControlPanelItem "INETCPL.cpl"
      case 6  
          'Explores the My Documents folder
        oShell.Explore "C:\My Documents"
      case 7  
          'Enables user to select folder from Program Files
        oShell.BrowseForFolder 0, "My Programs", 0, "C:\Program Files" 
      case 8  
          'Opens the Favorites folder
        oShell.Open "C:\WINDOWS\Favorites"
      case 9  
          'Displays the Taskbar Properties dialog box
        oShell.TrayProperties
    end select  
  end function 



DIDiskQuotaUser		Microsoft.DiskQuota.1
DiskQuotaControl	Cannot late bind
Folder				Shell.Application.NameSpace("...")
Folder2				Shell.Application.NameSpace("...")
FolderItem			Shell.Application.NameSpace("...").Self or Folder.Items.Item or Folder.ParseName
FolderItems			Folder.Items
FolderItems2		Folder.Items
FolderItemVerb		Shell.NameSpace("...").Self.Verbs.Item()
FolderItemVerbs		FolderItem.Verbs or Shell.NameSpace("...").Self.Verbs
IShellDispatch2		Shell.Application
IShellLinkDual2		Shell.NameSpace("...").Self.GetLink or Shell.NameSpace("...").Items().GetLink
Shell				Shell.Application
ShellFolderItem		Shell.NameSpace("...").Self or Shell.NameSpace("...").Items()
ShellFolderView		Cannot late bind
ShellFolderViewOC	Cannot late bind
ShellLinkObject		Shell.NameSpace("...").Self.GetLink or Shell.NameSpace("...").Items().GetLink
ShellUIHelper		Cannot late bind
ShellWindows		Shell.Windows or ShellWindows._NewEnum
WebViewFolderContents	Cannot late bind




procedure TForm1.Button1Click(Sender: TObject);
var
    Shell: OleVariant;
begin
    Shell := CreateOleObject('Shell.Application');
    Shell.CascadeWindows;
    Shell := Unassigned;
end;

//-----------------------------------------------------------------------------
//
//  C:\Windows\system32\*.cpl 
procedure TForm1.Button2Click(Sender: TObject);
var
    Shell: OleVariant;
begin
    Shell := CreateOleObject('Shell.Application');
    Shell.ControlPanelItem('desk.cpl');
    Shell := Unassigned;
end;

//-----------------------------------------------------------------------------
//  PC(if your computer supports this command)...
procedure TForm1.Button3Click(Sender: TObject);
var
    Shell: OleVariant;
begin
    Shell := CreateOleObject('Shell.Application');
    Shell.EjectPC;
    Shell := Unassigned;
end;

//-----------------------------------------------------------------------------
//
procedure TForm1.Button4Click(Sender: TObject);
var
    Shell: OleVariant;
begin
    Shell := CreateOleObject('Shell.Application');
    Shell.Explore(Integer(ssfMYPICTURES));
    Shell := Unassigned;
end;

//-----------------------------------------------------------------------------
//
procedure TForm1.Button5Click(Sender: TObject);
var
    Shell: OleVariant;
begin
    Shell := CreateOleObject('Shell.Application');
    Shell.Explore('C:\Windows\');
    Shell := Unassigned;
end;

//-----------------------------------------------------------------------------
//...
procedure TForm1.Button6Click(Sender: TObject);
var
    Shell: OleVariant;
begin
    Shell := CreateOleObject('Shell.Application');
    Shell.FileRun;
    Shell := Unassigned;
end;

//-----------------------------------------------------------------------------
//  
procedure TForm1.Button7Click(Sender: TObject);
var
    Shell: OleVariant;
begin
    Shell := CreateOleObject('Shell.Application');
    Shell.FindComputer;
    Shell := Unassigned;
end;

//-----------------------------------------------------------------------------
//
procedure TForm1.Button8Click(Sender: TObject);
var
    Shell: OleVariant;
begin
    Shell := CreateOleObject('Shell.Application');
    Shell.FindFiles;
    Shell := Unassigned;
end;

//-----------------------------------------------------------------------------
//  
procedure TForm1.Button9Click(Sender: TObject);
var
    Shell: OleVariant;
begin
    Shell := CreateOleObject('Shell.Application');
    Shell.Help;
    Shell := Unassigned;
end;

//-----------------------------------------------------------------------------
//  
procedure TForm1.Button10Click(Sender: TObject);
var
    Shell: OleVariant;
begin
    Shell := CreateOleObject('Shell.Application');
    Shell.MinimizeAll;
    Shell := Unassigned;
end;

//-----------------------------------------------------------------------------
//  
procedure TForm1.Button11Click(Sender: TObject);
var
    Shell: OleVariant;
begin
    Shell := CreateOleObject('Shell.Application');
    Shell.Open(Integer(ssfMYPICTURES));
    Shell := Unassigned;
end;

//-----------------------------------------------------------------------------
//  
procedure TForm1.Button12Click(Sender: TObject);
var
    Shell: OleVariant;
begin
    Shell := CreateOleObject('Shell.Application');
    Shell.Open('C:\Windows\');
    Shell := Unassigned;
end;

//-----------------------------------------------------------------------------
//
procedure TForm1.Button13Click(Sender: TObject);
var
    Shell: OleVariant;
begin
    Shell := CreateOleObject('Shell.Application');
    Shell.RefreshMenu;
    Shell := Unassigned;
end;

//-----------------------------------------------------------------------------
//  
procedure TForm1.Button14Click(Sender: TObject);
var
    Shell: OleVariant;
begin
    Shell := CreateOleObject('Shell.Application');
    Shell.SetTime;
    Shell := Unassigned;
end;

//-----------------------------------------------------------------------------
//  
procedure TForm1.Button15Click(Sender: TObject);
var
    Shell: OleVariant;
begin
    Shell := CreateOleObject('Shell.Application');
    Shell.ShutdownWindows;
    Shell := Unassigned;
end;

//-----------------------------------------------------------------------------
//  (for computers that support suspending)
procedure TForm1.Button16Click(Sender: TObject);
var
    Shell: OleVariant;
begin
    Shell := CreateOleObject('Shell.Application');
    Shell.Suspend;
    Shell := Unassigned;
end;

//-----------------------------------------------------------------------------
//
procedure TForm1.Button17Click(Sender: TObject);
var
    Shell: OleVariant;
begin
    Shell := CreateOleObject('Shell.Application');
    Shell.TileHorizontally;
    Shell := Unassigned;
end;

//-----------------------------------------------------------------------------
//
procedure TForm1.Button18Click(Sender: TObject);
var
    Shell: OleVariant;
begin
    Shell := CreateOleObject('Shell.Application');
    Shell.TileVertically;
    Shell := Unassigned;
end;

//-----------------------------------------------------------------------------
//
procedure TForm1.Button19Click(Sender: TObject);
var
    Shell: OleVariant;
begin
    Shell := CreateOleObject('Shell.Application');
    Shell.TrayProperties;
    Shell := Unassigned;
end;

//-----------------------------------------------------------------------------
//
procedure TForm1.Button20Click(Sender: TObject);
var
    Shell: OleVariant;
begin
    Shell := CreateOleObject('Shell.Application');
    Shell.UndoMinimizeALL;
    Shell := Unassigned;
end;


    TShellSpecialFolderConstants =
    (
        ssfALTSTARTUP = $1d,
        ssfAPPDATA = $1a,
        ssfBITBUCKET = $a,
        ssfCOMMONALTSTARTUP = $1e,
        ssfCOMMONAPPDATA = $23,
        ssfCOMMONDESKTOPDIR = $19,
        ssfCOMMONFAVORITES = $1f,
        ssfCOMMONPROGRAMS = $17,
        ssfCOMMONSTARTMENU = $16,
        ssfCOMMONSTARTUP = $18,
        ssfCONTROLS = $3,
        ssfCOOKIES = $21,
        ssfDESKTOP = $0,
        ssfDESKTOPDIRECTORY = $10,
        ssfDRIVES = $11,
        ssfFAVORITES = $6,
        ssfFONTS = $14,
        ssfHISTORY = $22,
        ssfINTERNETCACHE = $20,
        ssfLOCALAPPDATA = $1c,
        ssfMYPICTURES = $27,
        ssfNETHOOD = $13,
        ssfNETWORK = $12,
        ssfPERSONAL = $5,
        ssfPRINTERS = $4,
        ssfPRINTHOOD = $1b,
        ssfPROFILE = $28,
        ssfPROGRAMFILES = $26,
        ssfPROGRAMS = $2,
        ssfRECENT = $8,
        ssfSENDTO = $9,
        ssfSTARTMENU = $b,
        ssfSTARTUP = $7,
        ssfSYSTEM = $25,
        ssfTEMPLATES = $15,
        ssfWINDOWS = $24
    );
