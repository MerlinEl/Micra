rollout FolderExplorer "Untitled" width:500 height:424
(
	activeXControl actx15 "{D9812706-90EB-11D2-887A-BD32CB08A467}" pos:[8,8] width:484 height:408
	on unnamedRollout open  do
(
	
	)
	on unnamedRollout close  do
(
	
	)
)
createdialog FolderExplorer

/*
PROPERTIES:
  .ShowContextMenus : boolean
  .ShowFiles : boolean
  .ShowSpecailFolders : boolean
  .ShowHiddenObjects : boolean
  .SelectedNode : ITreeNode
  .HasLines : boolean
  .HasLinesAtRoot : boolean
  .HasButtons : boolean
  .ShowCheckBoxes : boolean
  .Indent : integer
  .Enabled : boolean
  .HotTracking : boolean
  .ForeColor : OLE_COLOR
  .AutoUpdate : boolean
  .root : integer, hidden
  .RootFolder : string
  .RootPidl : integer
  .AllowNodeRenaming : boolean
  .DefaultKeyHandling : boolean
  .SelectionDelay : integer
  .BackColor : OLE_COLOR
  .ShowInfoTips : boolean
  .AllowDragDrop : boolean
  .Font : Font
  .WindowHandle : integer
  .FileView : CheckStates( #NoCheckBoxes | #UnChecked | #Checked | #ChildChecked | #SelfAndChildChecked )
  .BorderStyle : BorderStyles( #None | #Flat | #Sunken )
  .SLink : CheckStates( #NoCheckBoxes | #UnChecked | #Checked | #ChildChecked | #SelfAndChildChecked ), hidden
  .UFoV : integer, hidden
  .UShB : integer, hidden
  .CancelEvent : boolean
METHODS:
  .SelectRootFolder()
  .SelectParent()
  .ResetToDesktop()
  .SetSpecialFolderAsRoot nFolder:SpecialFolderTypes( #DESKTOP | #INTERNET | #PROGRAMS | #CONTROLS | #PRINTERS | #PERSONAL | #FAVORITES | #STARTUP | #RECENT | #SENDTO | #BITBUCKET | #STARTMENU | #DESKTOPDIRECTORY | #DRIVES | #NETWORK | #NETHOOD | #FONTS | #TEMPLATES | #COMMON_STARTMENU | #COMMON_PROGRAMS | #COMMON_STARTUP | #COMMON_DESKTOPDIRECTORY | #APPDATA | #PRINTHOOD | #ALTSTARTUP | #COMMON_ALTSTARTUP | #COMMON_FAVORITES | #INTERNET_CACHE | #COOKIES | #HISTORY )
  .SelectNode Path:string PIDL:integer Add:boolean
  .SelectChild DisplayName:string PIDL:integer
  .GetFirstItem()
  .GetNextItem()
  .CreateNewFolder EditNow:boolean
  .RefreshView()
  .HitTest HitTestInfo:FOVHitTestInformation( #FOVNoWhere | #FOVOnNodeIcon | #FOVOnNodeText | #FOVOnNode | #FOVOnNodeIndent | #FOVOnNodeButton | #FOVOnNodeCheckBox ) x:float y:float
  .AboutBox()
EVENTS:
  on <control_name> NodeExpanding Node:ITreeNode Cancel:boolean do ( ... )
  on <control_name> NodeChecking Node:ITreeNode Cancel:boolean do ( ... )
  on <control_name> NodeCollapsing Node:ITreeNode Cancel:boolean do ( ... )
  on <control_name> NodeRightClick Node:ITreeNode do ( ... )
  on <control_name> KeyDown KeyCode:integer Shift:integer do ( ... )
  on <control_name> KeyUp KeyCode:integer Shift:integer do ( ... )
  on <control_name> MouseDown Button:integer Shift:integer x:OLE_XPOS_PIXELS y:OLE_YPOS_PIXELS do ( ... )
  on <control_name> MouseMove Button:integer Shift:integer x:OLE_XPOS_PIXELS y:OLE_YPOS_PIXELS do ( ... )
  on <control_name> OnContextMenuHint Hint:string do ( ... )
  on <control_name> OnBeforeNodeSelect Node:ITreeNode Cancel:boolean do ( ... )
  on <control_name> OnAfterNodeSelect Node:ITreeNode do ( ... )
  on <control_name> MouseUp Button:integer Shift:integer x:OLE_XPOS_PIXELS y:OLE_YPOS_PIXELS do ( ... )
  on <control_name> Click do ( ... )
  on <control_name> DblClick do ( ... )
  on <control_name> NodeChecked Node:ITreeNode do ( ... )
  on <control_name> OnBeforeNodeRename Node:ITreeNode Cancel:boolean do ( ... )
  on <control_name> OnAfterNodeRename Node:ITreeNode NewName:string Cancel:boolean do ( ... )
  on <control_name> OnAfterNodeAdd Node:ITreeNode do ( ... )
  on <control_name> OnBeforeNodeDelete Node:ITreeNode do ( ... )
NAMES:

*/
