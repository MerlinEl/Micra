--"Windows Media Player" "WMPlayer.OCX.7" "{6BF52A52-394A-11D3-B153-00C04F79FAA6}" 
rollout mplayerDialog "Windows Media Player" width:348 height:232
(
	activeXControl actx14 "{6BF52A52-394A-11D3-B153-00C04F79FAA6}" pos:[4,4] width:340 height:224
	on unnamedRollout open  do
(
	
	)
	on unnamedRollout close  do
(
	
	)
)
createDialog mplayerDialog
/*
PROPERTIES:
  .URL : string
  .openState : WMPOpenState( #wmposUndefined | #wmposPlaylistChanging | #wmposPlaylistLocating | #wmposPlaylistConnecting | #wmposPlaylistLoading | #wmposPlaylistOpening | #wmposPlaylistOpenNoMedia | #wmposPlaylistChanged | #wmposMediaChanging | #wmposMediaLocating | #wmposMediaConnecting | #wmposMediaLoading | #wmposMediaOpening | #wmposMediaOpen | #wmposBeginCodecAcquisition | #wmposEndCodecAcquisition | #wmposBeginLicenseAcquisition | #wmposEndLicenseAcquisition | #wmposBeginIndividualization | #wmposEndIndividualizºýŒhë, read-only
  .playState : WMPPlayState( #wmppsUndefined | #wmppsStopped | #wmppsPaused | #wmppsPlaying | #wmppsScanForward | #wmppsScanReverse | #wmppsBuffering | #wmppsWaiting | #wmppsMediaEnded | #wmppsTransitioning | #wmppsReady | #wmppsReconnecting | #wmppsLast ), read-only
  .controls : IWMPControls, read-only
  .settings : IWMPSettings, read-only
  .currentMedia : IWMPMedia
  .mediaCollection : IWMPMediaCollection, read-only
  .playlistCollection : IWMPPlaylistCollection, read-only
  .versionInfo : string, read-only
  .network : IWMPNetwork, read-only
  .currentPlaylist : IWMPPlaylist
  .cdromCollection : IWMPCdromCollection, read-only
  .closedCaption : IWMPClosedCaption, read-only
  .isOnline : boolean, read-only
  .Error : IWMPError, read-only
  .status : string, read-only
  .dvd : IWMPDVD, read-only
  .enabled : boolean
  .fullScreen : boolean
  .enableContextMenu : boolean
  .uiMode : undefined
  .stretchToFit : boolean
  .windowlessVideo : boolean
  .isRemote : boolean, read-only
  .playerApplication : IWMPPlayerApplication, read-only
METHODS:
  .close()
  .launchURL bstrURL:string
  .newPlaylist bstrName:string bstrURL:string
  .newMedia bstrURL:string
  .openPlayer bstrURL:string
EVENTS:
  on <control_name> OpenStateChange NewState:integer do ( ... )
  on <control_name> PlayStateChange NewState:integer do ( ... )
  on <control_name> AudioLanguageChange LangID:integer do ( ... )
  on <control_name> StatusChange do ( ... )
  on <control_name> ScriptCommand scType:string Param:string do ( ... )
  on <control_name> NewStream do ( ... )
  on <control_name> Disconnect Result:integer do ( ... )
  on <control_name> Buffering Start:boolean do ( ... )
  on <control_name> Error do ( ... )
  on <control_name> Warning WarningType:integer Param:integer Description:string do ( ... )
  on <control_name> EndOfStream Result:integer do ( ... )
  on <control_name> PositionChange oldPosition:float newPosition:float do ( ... )
  on <control_name> MarkerHit MarkerNum:integer do ( ... )
  on <control_name> DurationUnitChange NewDurationUnit:integer do ( ... )
  on <control_name> CdromMediaChange CdromNum:integer do ( ... )
  on <control_name> PlaylistChange Playlist:IWMPEvents change:WMPPlaylistChangeEventType( #wmplcUnknown | #wmplcClear | #wmplcInfoChange | #wmplcMove | #wmplcDelete | #wmplcInsert | #wmplcAppend | #wmplcPrivate | #wmplcNameChange | #wmplcMorph | #wmplcSort | #wmplcLast ) do ( ... )
  on <control_name> CurrentPlaylistChange change:WMPPlaylistChangeEventType( #wmplcUnknown | #wmplcClear | #wmplcInfoChange | #wmplcMove | #wmplcDelete | #wmplcInsert | #wmplcAppend | #wmplcPrivate | #wmplcNameChange | #wmplcMorph | #wmplcSort | #wmplcLast ) do ( ... )
  on <control_name> CurrentPlaylistItemAvailable bstrItemName:string do ( ... )
  on <control_name> MediaChange Item:IWMPEvents do ( ... )
  on <control_name> CurrentMediaItemAvailable bstrItemName:string do ( ... )
  on <control_name> CurrentItemChange pdispMedia:IWMPEvents do ( ... )
  on <control_name> MediaCollectionChange do ( ... )
  on <control_name> MediaCollectionAttributeStringAdded bstrAttribName:string bstrAttribVal:string do ( ... )
  on <control_name> MediaCollectionAttributeStringRemoved bstrAttribName:string bstrAttribVal:string do ( ... )
  on <control_name> MediaCollectionAttributeStringChanged bstrAttribName:string bstrOldAttribVal:string bstrNewAttribVal:string do ( ... )
  on <control_name> PlaylistCollectionChange do ( ... )
  on <control_name> PlaylistCollectionPlaylistAdded bstrPlaylistName:string do ( ... )
  on <control_name> PlaylistCollectionPlaylistRemoved bstrPlaylistName:string do ( ... )
  on <control_name> PlaylistCollectionPlaylistSetAsDeleted bstrPlaylistName:string varfIsDeleted:boolean do ( ... )
  on <control_name> ModeChange ModeName:string NewValue:boolean do ( ... )
  on <control_name> MediaError pMediaObject:IWMPEvents do ( ... )
  on <control_name> OpenPlaylistSwitch pItem:IWMPEvents do ( ... )
  on <control_name> DomainChange strDomain:string do ( ... )
  on <control_name> SwitchedToPlayerApplication do ( ... )
  on <control_name> SwitchedToControl do ( ... )
  on <control_name> PlayerDockedStateChange do ( ... )
  on <control_name> PlayerReconnect do ( ... )
  on <control_name> Click nButton:integer nShiftState:integer fX:integer fY:integer do ( ... )
  on <control_name> DoubleClick nButton:integer nShiftState:integer fX:integer fY:integer do ( ... )
  on <control_name> KeyDown nKeyCode:integer nShiftState:integer do ( ... )
  on <control_name> KeyPress nKeyAscii:integer do ( ... )
  on <control_name> KeyUp nKeyCode:integer nShiftState:integer do ( ... )
  on <control_name> MouseDown nButton:integer nShiftState:integer fX:integer fY:integer do ( ... )
  on <control_name> MouseMove nButton:integer nShiftState:integer fX:integer fY:integer do ( ... )
  on <control_name> MouseUp nButton:integer nShiftState:integer fX:integer fY:integer do ( ... )
NAMES:
*/