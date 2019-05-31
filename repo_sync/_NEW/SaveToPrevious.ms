/* SaveVersionHandler Comment Header
-------------------------------------------------------------------------------------------------------------------------------------------
---- SaveVersionHandler V1.10
-------------------------------------------------------------------------------------------------------------------------------------------
---- Global accessable Maxscript struct for easy SaveToPrevious Maxversions handling
---- Created:  October  12, 2012
---- Modified:  October  13, 2012
---- Requirement: Max 2011 and higher
-------------------------------------------------------------------------------------------------------------------------------------------

IMPORTANT: remove any previous copies of this script sitting in your "scripts/startup" folder !!! ( old install location)

HISTORY:

---- 	Version:  V1.10 - Hotfx Release, DC20121013
----		corrected install instructions, script should go to "stdplugs\stdscripts" folder !!!!
----		otherwise the created macroscripts would report "undefined", access  via maxscript works though
----		saving now prints status info to the listener
----		Limited saving to three versions back at maximum 
----		This only will be relevant for future Max Versions (no reinstall necessary)
----
---- 	Version:  V1.00 - Initial Release, DC20121012

INSTALLATION:

----    IMPORTANT: remove any copies of this script sitting in your "scripts/startup" folder !!! ( Old location)
---- 	Copy this file ( "SF_SaveToPrevious.ms" ) to your "<3dsMaxFolder>\stdplugs\stdscripts" folder 
----	As written above you should find that folder int your 3ds Max root directory
----    Re(start) 3ds Max, now a global struct "SaveVersionHandler" is available to maxscript.

----	To make the new functionality available to keyboard/button/menu bindings, perform the following steps ONE TIME:
----	Type "SaveVersionHandler.CreateMacroScripts()" and hit enter in the listener.
----	If this returns something like "undefined", the script was not placed in the correct place. Recheck and redo above steps.
----  	If it returns "Ok", several "SaveToMax201x" entries in the UI Configuration Dialog have been made available, 
----	ready to be mapped to the Keyboard/Button/Menu etc. 
----	The entries appear in the "Spacefrog Tools" category ( called "SaveToMax2010" etc... )
----	The above steps ensure functionality of the script even with future versions of Max to come...

USAGE:
----	The struct "SaveVersionHandler" provides a "SaveToVersion" method taking the desired version number as argument 
----	eg. "SaveVersionHandler.SaveToVersion 2010" saves the current scene as Max 2010 file, appending "_M2010" to the filename
----	If you pass an invalid Max version, a messagebox will pop up.
----
----	Note: the freshly saved legacy scene will NOT become the current scene in the running 3ds Max session 
----	This prevents accidently overwriting legacy scenes and dataloss ( legacy scenes loose support for all newer Max features )
----	If the legacy scene already exists on that place, a prompt is displayed, allowing to cancel or overwrite
----	
----	A specific filename and path can be passed via a "fileName:<yourfilename>" named argument
----	
----	if "quiet:true" is passed, no prompt is displayed when the targetfile already exists
----	
----	Here's the syntax of SaveVersionhandler's methods:
----	
----	SaveVersionHandler.SaveToVersion <MaxVersion Number> [fileName:<targetpath and filename>] [quiet:true|false]
----	
----	SaveVersionHandler.CreateMacroScripts()
----	
-------------------------------------------------------------------------------------------------------------------------------------------
---- Author:
----	Josef Wienerroither aka "spacefrog"  www.frogsinspace.at  | spacefrog@chello.at
-------------------------------------------------------------------------------------------------------------------------------------------
*/


struct SaveVersionHandler
(
		private
		validVersions,
		
		function OnCreate=
		(
			-- Max version 12 (Max 2010) is the oldest version we can save to, we include current version to
			-- Hotfix V1.0a: Apparently Max allows only saving 3 Versions back  ( compared to the current Version)
			local oldest = (maxversion())[1]/1000-3
				
			if oldest < 12 then oldest = 12
			
			validVersions=for i=oldest to (maxversion())[1]/1000 collect 1998+i
			ok
		),
		
		public
		function SaveToVersion version Filename:(maxfilepath+maxfilename) quiet:false=
		(
			local _result=false
			
			--- if the scene does'nt have a filenamee already, enforce a standard save now
			if( GetFileNameFile Filename == "" ) then
			(
				MessageBox "Current Scene is still unnamed.\nPlease save the Scene and retry." title:"SaveToVersion"
			)			
			else
			(
				if( findItem validVersions version != 0 ) then
				(
					local saveFilename= getFilenamePath Filename + getFilenameFile Filename +"_M"+(version as string) + getFilenameType FileName
					
					if( quiet OR not (doesfileexist saveFileName)) OR querybox ("Warning: File '"+saveFileName + "'\n alrady exists. Overwrite?") then
					(
						try
						(
						
							_result = saveMaxFile saveFileName saveAsVersion:version useNewFile:false			

							if(_result) then format "SaveToVersion(M%): successfully saved %\n" version saveFileName
							else format "SaveToVersion(M%): failed to save \"%\"\n" version saveFileName
						)
						catch( format "SaveToVersion(M%): failed to save \"%\" :%\n" version saveFileName (getCurrentException()))
					)
					
				)
				else MessageBox("Invalid Target Version:\t"+ version as string + "\n\tsupported versions:" + validVersions as string) title:"SaveToVersion"
			)
			_result
		),
		
		function CreateMacroscripts=
		(
			for i = 1 to validVersions.count do
			(
				macroString ="macroScript SaveToMax" + validVersions[i] as string +" category:\"Spacefrog Tools\" toolTip:\"SaveToMax"+validVersions[i] as string+ "\""
				
				append macroString ("\n(\n\tSaveVersionHandler.SaveToVersion " + validVersions[i] as string  + "\n)")
				execute macroString
			)
		),
		created=OnCreate()
)
global SaveVersionHandler=SaveVersionHandler()
