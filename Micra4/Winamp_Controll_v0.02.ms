Global Winamp_Is_Playing
Global Winamp_Shell_App

if winampControllDialog != undefined do destroyDialog winampControllDialog
rollout winampControllDialog "Untitled" width:172 height:28
(
	local elapsed_time = 0
	local pause_duration = 45
	local winamp     = "E:\Aprog\Winamp\winamp.exe"
	local clamp      = "E:\Micra3\App\CLAmp.exe"
	local radio_path = "http://yp.shoutcast.com/sbin/tunein-station.pls?id=7135"
	local diag = dotnetclass "System.Diagnostics.Process"

	label lbl4 "Radio reklama konci za:" pos:[4,4] width:116 height:12
	label lbl_elapsed_time "0.59 sec" pos:[124,4] width:48 height:16
	Timer tmr_re "Timer" pos:[0,0] width:24 height:24 interval:1000 active:false
	fn winampCtrl =
	(
		--HiddenDOSCommand AVG Required
		if not doesFileExist winamp or not doesFileExist clamp do return false
		--Create Ole Object
		if Winamp_Shell_App == undefined do try (Winamp_Shell_App = CreateOleObject("Shell.Application")) catch (return false)
		--Controll Winamp--
		local running = (diag.GetProcessesByName "winamp").count != 0
		if not running then
		(
			print ("Winamp_Is_Playing: "+ Winamp_Is_Playing as string)
			Winamp_Is_Playing = true
			print ("Winamp_Is_Playing: "+ Winamp_Is_Playing as string)
			Winamp_Shell_App.ShellExecute clamp "/PLAY"
			Winamp_Shell_App.ShellExecute clamp "/MINIMIZE"
			destroyDialog winampControllDialog
		)
		else if keyboard.controlPressed then --play/stop
		(
			if Winamp_Is_Playing == true 
			then (Winamp_Shell_App.ShellExecute clamp "/PAUSE" ; Winamp_Is_Playing = false)
			else (Winamp_Shell_App.ShellExecute clamp "/PLAY"  ; Winamp_Is_Playing = true )
			destroyDialog winampControllDialog
		)
		else if keyboard.shiftPressed then
		(
			Winamp_Shell_App.ShellExecute winamp radio_path "0"
			Winamp_Is_Playing = true
			destroyDialog winampControllDialog
		)
		else if Winamp_Is_Playing == true then --spot paser
		(
			--Winamp_Shell_App.ShellExecute clamp "/PAUSE"
			Winamp_Shell_App.ShellExecute clamp "/STOP"
			Winamp_Is_Playing = false
			tmr_re.active = true --limited pause
		)
	)
	on winampControllDialog open  do (winampCtrl())
	on winampControllDialog close  do
	(
		--releaseOLEObject Winamp_Shell_App
		--Winamp_Is_Playing = undefined
		--Winamp_Shell_App = undefined
	)
	on tmr_re tick do
	(
		elapsed_time += 1
		lbl_elapsed_time.text = "0." + ((pause_duration - elapsed_time) as string) + " sec"
		if elapsed_time == pause_duration do
		(
			--Winamp_Shell_App.ShellExecute winamp radio_path "0"
			Winamp_Shell_App.ShellExecute clamp "/PLAY"
			Winamp_Is_Playing = true
			destroyDialog winampControllDialog
		)
	)
)
createDialog winampControllDialog  pos:[10,10] style:#(#style_sysMenu)

/*
--Winamp_Shell_App.ShellExecute winamp "stop"
--last command
'0 hide
'1 show
'2 min
'3 max
--or
Winamp = createobject("WinampCOM.Application")
Winamp.AddFile("C:\My Music\Elmer Fudd Sings The Blues.mp3")
Winamp.Play
--run by CLAmp.exe
clamp = "E:\Aprog\Winamp\CLAmp.exe"
clamp = "E:\Micra3\App\CLAmp.exe"
Winamp_Shell_App.ShellExecute clamp "/PAUSE"
Winamp_Shell_App.ShellExecute clamp "/PLAY"
Winamp_Shell_App.ShellExecute clamp "/ONTOP"
Winamp_Shell_App.ShellExecute clamp "/QUIT"
Winamp_Shell_App.ShellExecute clamp "/MINIMIZE"
*/

/*
Items you can read or set:

Boolean .Autoload        - ?? No idea.
Long .CurrentPos         - ?? Either position in the 'song' or the 'playlist'. Not sure.
Bool .EqEnabled          - Equalizer use status.
Long .EqPosition         - ?? Not sure.
Bool .EqualizerVisible   - Hide/show the equalizer.
Bool .MiniBrowserVisible - Hide/Show MiniBrowser.
Long .PlayListPos        - Current song location in playlist.
Bool .PlayListVisible    - Hide/Show playlist.
Long .PreAmpPosition     - Change Pre-Amp amount.
Bool .RepeatStatus       - Repeat On/Off.
Bool .ShuffleStatus      - Shuffle On/Off.
String .SkinName         - Get/set skin.
Bool .Visible            - Show/hide winamp.

Commands:

.AddFile ("Filename")         - Add a new file to the current playlist.
.ChangeDirectory("Directory") - Change current song directory.
.ClearPlayList                - Remove all the files in the current list.
.FastForward
.FastFwd5Secs
.Pause
.Play
.Rewind
.Rewind5Secs
.SendCommand (Command)        - See the API docs (basically does same thing as the
                                commands I am listing here, maybe some other things).
.SetPanning(Long)             - Haven't a clue.
.SetVolume(Long)              - Sets Winamp's Volume.
.StartPlugin("Name")          - Starts up a winamp plugin.
.Stop
.ToggleRepeat
.ToggleShuffle

Read only:

Long = .BitRate                  - Bit rate the current song is playing at.
Long = .Channels                 - ?? Not sure.
String = .CurrentSongFileName
Long = .CurrentSongLength
String = .CurrentSongTitle
String = .ID3Tag(Long)           - Get specific tag for this song.
Long = .PlayListCount            - Number of songs in playlist.
Long = SampleRate                - Get sample rate.
String = .SongFileName(Position) - Get filename of song in 'Position' within playlist.
String = .SongTitle(Position)    - Get name of song in 'Position' within playlist.
Status = .Status                 - May return an array, but not sure.
Long = .Version                  - Plugin version or winamp??

Also, there is a SongChange event. Normally you would do:

sub SongChange
  'Do something...
end sub
*/
