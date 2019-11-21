-- GeOAutoSave  Copyright © 2011 Jiovanie Velazquez
-- "QuoteWare" license (idea stolen from Martin Breidt):
-- If you use one of my scripts in a production environment with a group of more than two people,
-- or have used it in the past under such conditions, then you are obliged to tell me about it 
-- and allow me to list that project title and your company name as a reference on my website.
-- This tool will remain free and opensource, so this really is a very small thing to ask in exchange
-- for using them. I hope you all agree. Thanks, and looking forward to hearing from your project!

-- Before doing anything else this will destroy the autosave window if it already exists
if GeOAutosave != undefined do destroyDialog GeOAutosave         

-- Check to see if settings exist for this script, if not then it's probably the first-run so set these defaults
if not doesFileExist (getDir #plugCFG + "\\GeOscripts.ini") then                                     
    (
        -- this is the file that will contain settings for this script
        var_settingsFile = (getDir #plugCFG) + "\\GeOscripts.ini"
        setINISetting var_settingsFile "GeOAutosave" "AutosaveVersion" "0.5"
        setINISetting var_settingsFile "GeOAutosave" "AutosavePosition" "[300,300]"
        setINISetting var_settingsFile "GeOAutosave" "SaveState" "True"
        setINISetting var_settingsFile "GeOAutosave" "SaveInterval" "10"
        setINISetting var_settingsFile "GeOAutosave" "LatestFile" "0"
        setINISetting var_settingsFile "GeOAutosave" "ManualMode" "false"
        setINISetting var_settingsFile "GeOAutosave" "MaxNumFiles" "20"
        setINISetting var_settingsFile "GeOAutosave" "HighlightColor" "[255, 100, 0]"
        setINISetting var_settingsFile "GeOAutosave" "PreToggle" "true"
    )

    
-- SCRIPT VARIABLES

-- Max's PlugCFG directory
var_dirPlugCFG =            (getDir #plugCFG)
-- Max's Root directory
var_dirMaxRoot =            (getDir #maxRoot)
-- Max's autoback folder
var_maxAutobackFolder =     (getDir #autoback)

-- This is the file that will contain settings for this script
var_settingsFile =          var_dirPlugCFG + "\\GeOscripts.ini"

-- These are a few variables for settings that are written to and read from the settings file
var_currentFile =                   (getFilenameFile maxFilename)
var_currentFolder =                 (getdir #autoback + "\\" + var_currentFile + "\\")
var_autosavePosition =      execute (getINISetting var_settingsFile "GeOAutosave" "AutosavePosition")
var_saveState =             execute (getINISetting var_settingsFile "GeOAutosave" "SaveState")
var_saveInterval =          execute (getINISetting var_settingsFile "GeOAutosave" "SaveInterval")
var_latestFile =                    (getINISetting var_settingsFile "GeOAutosave" "LatestFile")
var_manualMode =            execute (getINISetting var_settingsFile "GeOAutosave" "ManualMode")
var_maxNumFiles =           execute (getINISetting var_settingsFile "GeOAutosave" "MaxNumFiles")
var_highlightColor =        execute (getINISetting var_settingsFile "GeOAutosave" "HighlightColor")
var_preToggle =             execute (getINISetting var_settingsFile "GeOAutosave" "PreToggle")
var_maxAutobakEnabled    
var_thisFile =              maxFilePath + maxFileName


-- SCRIPT FUNCTIONS

-- Gets the filename of the currently open file without the ".max"
function fn_getCurrentFilename =        (var_currentFile = getFilenameFile maxFilename)                                    

-- Gets the foldername that this file should backup into
function fn_getCurrentFolder =          (var_currentFolder = getdir #autoback + "\\" + var_currentFile + "\\")            

-- update the settings file with recent information
function fn_updateAutosavePosition      var_updateArgument =    (setINISetting var_settingsFile "GeOAutosave" "AutosavePosition" var_updateArgument)
function fn_updateSaveState             var_updateArgument =    (setINISetting var_settingsFile "GeOAutosave" "SaveState" var_updateArgument)
function fn_updateSaveInterval          var_updateArgument =    (setINISetting var_settingsFile "GeOAutosave" "SaveInterval" var_updateArgument)
function fn_updateLatestFile            var_updateArgument =    (setINISetting var_settingsFile "GeOAutosave" "LatestFile" var_updateArgument)
function fn_updateManualMode            var_updateArgument =    (setINISetting var_settingsFile "GeOAutosave" "ManualMode" var_updateArgument)
function fn_updateMaxNumFiles           var_updateArgument =    (setINISetting var_settingsFile "GeOAutosave" "MaxNumFiles" var_updateArgument)
function fn_updateHighlightColor        var_updateArgument =    (setINISetting var_settingsFile "GeOAutosave" "HighlightColor" var_updateArgument)
function fn_updatePreToggle             var_updateArgument =    (setINISetting var_settingsFile "GeOAutosave" "PreToggle" var_updateArgument)

-- retrieve settings from file
function fn_getAutosavePosition =       (var_autosavePosition = execute (getINISetting var_settingsFile "GeOAutosave" "AutosavePosition"))
function fn_getSaveState =              (var_saveState = execute (getINISetting var_settingsFile "GeOAutosave" "SaveState"))
function fn_getSaveInterval =           (var_saveInterval = execute (getINISetting var_settingsFile "GeOAutosave" "SaveInterval"))
function fn_getLatestFile =             (var_latestFile = (getINISetting var_settingsFile "GeOAutosave" "LatestFile"))
function fn_getManualMode =             (var_manualMode = execute (getINISetting var_settingsFile "GeOAutosave" "ManualMode"))
function fn_getMaxNumFiles =            (var_maxNumFiles = execute (getINISetting var_settingsFile "GeOAutosave" "MaxNumFiles"))
function fn_getHighlightColor =         (var_highlightColor = execute (getINISetting var_settingsFile "GeOAutosave" "HighlightColor"))
function fn_getPreToggle =              (var_preToggle = execute (getINISetting var_settingsFile "GeOAutosave" "PreToggle"))

-- Shift Files deletes the oldest file/s if the number of autoback files has reached or exceeded the maximum number set in the options window and shifts each file to a higher number so that "01" can always be the most recent version 
function fn_shiftFiles =
    (--
        -- gets the current filename
        fn_getCurrentFilename()                                                                                            
        -- gets the root autoback foldername and adds the name of the current max file
        fn_getCurrentFolder()                                                                                             
        -- collects an array of existing backups for the current file
        var_incrementFiles = getFiles (var_currentFolder + var_currentFile + "*.max")                                    
        
        --if backup files exist then continue...
        if var_incrementFiles.count > 0 do                                                                              
            (            
                -- gets the filename in the last entry of the array
                f = var_incrementFiles[var_incrementFiles.count]                                                         
                -- if number of backups exceed the currently set maximum...
                if var_incrementFiles.count >= var_maxNumFiles then                                                      
                    ( do            
                        (            
                            -- delete the file that's described in the last entry of the array
                            deleteFile f                                                                                 
                            -- delete the reference to that file from the array itself
                            deleteItem var_incrementFiles var_incrementFiles.count                                         
                            -- update f with the new filename in the last entry of the shortened array
                            f = var_incrementFiles[var_incrementFiles.count]                                             
                        )             
                        -- Keep doing this while there are more backups than the maximum number set in the settings window
                        while (var_incrementFiles.count >= var_maxNumFiles)                                             
                    )            
                -- If backup files still exist the continue...
                if var_incrementFiles.count > 0 then                                                                     
                    ( do         
                        (        
                            -- gets the last file listed in the array
                            var_lastFile = var_incrementFiles[var_incrementFiles.count]                                 
                            -- strips xx.max from the end of the filename
                            var_newFile = substring var_lastFile 1 (var_lastFile.count - 6)                             
                            -- sets c to the number of files in the array
                            c = var_incrementFiles.count                                                                  
                            -- Deletes the last listing from the array
                            deleteitem var_incrementFiles var_incrementFiles.count                                      
                            -- rename file +1
                            if c > 8 do renameFile var_lastFile (var_newFile + ((c + 1) as string) + ".max")             
                            -- rename file +1 changing a <10 single digit to a double digit
                            if c < 9 do renameFile var_lastFile (var_newFile + "0" + ((c + 1) as string) + ".max")         
                            -- sets var_latestFile to the new number of files in the array, if none returns 0
                            try (var_lastFile = var_incrementFiles[var_incrementFiles.count]) catch (0)                  
                        ) 
                        while (var_incrementFiles.count > 0)
                    )
            )
    )--

-- Resets the timer    
function fn_resetTimer = if GeOAutosave.tickTock.active == true do    
    (--
        GeOAutosave.tickTock.active = false
        GeOAutosave.tickTock.ticks = 0
        GeOAutosave.tickTock.active = true
    )--

--This mainly runs the actual autosave, after running the file-shift function
function fn_runAutosave =
    (--
        -- Update the variable that stores the open file's path/name
        var_thisFile =     maxFilePath + maxFileName
        -- Saves this variable to the settings file
        (setINISetting (var_currentFolder + var_currentFile + ".ini") "OriginalFile" "NameAndLocation" var_thisFile as string)
        -- Run the function that shifts all the files to a higher number
        fn_shiftFiles()
        -- Check to see if there is already an autoback folder for this file
        if not doesFileExist var_currentFolder do
            (                                                                                                            
                -- Make the autosave folder for this file
                makeDir var_currentFolder
                -- If the folder didn't exist, then neither did the ini file saving the original name and location, so do this now
                (setINISetting (var_currentFolder + var_currentFile + ".ini") "OriginalFile" "NameAndLocation" var_thisFile as string)
            )
        -- Save the backup...  all this just to build up to this one crucial line! :)
        saveMaxFile (var_currentFolder + var_currentFile + "01") clearNeedSaveFlag:false useNewFile:false
        -- Plug in the most recently saved files information into the settings file
        fn_updateLatestFile (var_currentFolder + var_currentFile + "01" + ".max")
        -- Get that information back into the script variable
        fn_getLatestFile()
        -- Update the reload button to display the file name of the most recent autosave
        GeOAutosave.btn_reloadLatestSave.toolTip = "Reload the most recent Autosave (" + (getFilenameFile var_latestFile) + ")"
        -- Reset the timer so it can start all over again
        fn_resetTimer()
    )--

-- This updates variables critical for autosave to function
function fn_updateVariables =
    (--
        fn_getLatestFile()
        fn_getCurrentFilename()
        fn_getCurrentFolder ()
        case of
            (
                (var_currentFile == ""): GeOAutosave.btn_deleteCurrentFiles.tooltip = "There are no backups for the current file"
                default: (GeOAutosave.btn_deleteCurrentFiles.tooltip = "This will delete all backup files of '" + var_currentFile + "'")
            )
    )--
    
--Main GeOAutoSave Rollout    
rollout GeOAutosave ""
    (--
        checkButton cbtn_activateAutosave "Autosave" visible:(not var_manualMode) highlightColor:var_highlightColor checked:var_saveState pos:[0,0] width:100 height:21 toolTip:"Activate Autosave"
        button btn_manualSave "Manual Backup" visible:var_manualMode pos:[0,0] width:100 height:21
        button btn_reloadLatestSave "®" pos:[101,0] width:21 height:21 toolTip:"Reloads the most recent Autosave" images:#(getdir #startupscripts + "\\GeOToolIcons_16i.bmp", undefined, 4, 1, 1, 1, 1, true)
        checkbutton cbtn_settingsWindow "§" pos:[123,0] width:21 height:21 highlightColor:var_highlightColor toolTip:"Toggle Autosave Options" images:#(getdir #startupscripts + "\\GeOToolIcons_16i.bmp", undefined, 4, 2, 2, 2, 2, true)
        button btn_closeAutosave "©" pos:[144,0] width:21 height:21 toolTip:"Close and Disable GeOAutosave" images:#(getdir #startupscripts + "\\GeOToolIcons_16i.bmp", undefined, 4, 3, 3, 3, 3, true)
        timer tickTock interval:(var_saveInterval * 60000) active:var_saveState
        colorPicker saveColor pos:[0,25] color:var_highlightColor fieldWidth:20 height:20
        spinner spnr_maxNumFiles "Backups per File " pos:[80,25] width:80 height:16 range:[2,99,var_maxNumFiles] type:#integer
        spinner spnr_saveInterval "Save Interval (minutes) " pos:[60,50] width:100 height:16 range:[1,120,var_saveInterval] type:#integer
        checkButton cbtn_toggleManual "Toggle Manual Mode" pos:[6,74] highlightColor:var_highlightColor checked:(var_manualMode)
        button btn_openAutosaveFolder "F" pos: [138, 74] images:#(getdir #startupscripts + "\\GeOToolIcons_16i.bmp", undefined, 4, 4, 4, 4, 4, true)
        group "Careful, not undoable..."
        (
            button btn_deleteCurrentFiles "Delete backups of THIS file"  offset:[0,0] width:137 height:21 tooltip:(if var_currentFile == "" then "There are no backups for the current file" else "This will delete all backup files of " +  var_currentFile)
            button btn_deleteAllFiles "Delete all Backup Files EVER" offset:[4,5] width:140 height:21 bgcolor:[255,0,0]tooltip:"This will delete your entire GeO Autosave folder and all saves within it"
        )

        -- I will use this to register the mouse position when moving the autosave window and as a check before applying mouse movement to the window's new position
        local var_moveMe 
        
        -- Gotta prepare max and some variables before this script will work
        on GeoAutosave open do 
            (--
                fn_getCurrentFilename()
                fn_getCurrentFolder()
                -- Update the caption to indicate the current time interval
                cbtn_activateAutosave.caption = ("Autosave" + " (" + var_saveInterval as string + " m)")            
                -- Remember if max's built-in autobak option is enabled because I'm gonna turn that shit off!
                var_maxAutobakEnabled = autoBackup.enabled                                                            
                autoBackup.enabled = false
                -- When the autosave window is opened, set callback to watch for any file open action
                callbacks.addscript #filePostOpen       "fn_updateVariables()"     id:#AutosaveOpenUpdate        
                -- When the autosave window is opened, set callback to watch for any file saving action
                callbacks.addscript #filePostSave       "fn_resetTimer()"         id:#AutosaveResetTimer        
                -- When the autosave window is opened, set callback to watch for any file resetting action
                callbacks.addscript #systemPostReset    "fn_updateVariables()"     id:#AutosaveResetUpdate        
            )--
            
        -- Move the window
        -- Register a mouse click on the rollout and set the start position of the cursor
        on GeOAutosave lbuttondown var_clickPoint do var_moveMe = var_clickPoint                                     
        -- Register mousemovement on the window while the button is clicked and apply movement to the window
        on GeOAutosave mousemove movement do                                                                         
            (--
                -- Window dragging hack
                if var_moveMe != undefined then setDialogPos GeOAutosave (mouse.screenPos - var_moveMe)             
            )--
        -- Stop registering movement once the mouse button is let up and save new settings
        on GeOAutosave lbuttonup buttUp do                                                                            
            (--
                -- Record the window's new position
                var_autosavePosition = getDialogPos GeOAutosave                                                                
                -- Save the new position to the settings file
                fn_updateAutosavePosition (getDialogPos GeOAutosave as string)                                                    
                -- Update the window's position variable
                fn_getAutosavePosition()                                                                            
                -- This disables the "window dragging" hack above
                var_moveMe = undefined                                                                                 
            )--    

        -- When the user toggles the autosave button...
        on cbtn_activateAutosave changed saveState do
            (--
                -- If active: turn on the timer and save the current state to file 
                if saveState == true do
                    (
                        tickTock.active = true
                        fn_updateSaveState "True"
                        var_preToggle = true
                        fn_updatePreToggle "true"
                    )
                -- If inactive: turn off the timer and save the current state to file 
                if saveState == false do
                    (
                        tickTock.active = false
                        fn_updateSaveState "False"
                        var_preToggle = false
                        fn_updatePreToggle "false"
                    )
            )--

        -- Run the autosave function manually
        on btn_manualSave pressed do (if maxFilename == "" then return 0 else fn_runAutosave())
        
        -- Find out the latest autoback file, if any, and load it up then ask the user to save it (prompting them to re-save it and opening a dialog at the original file's location
        on btn_reloadLatestSave pressed do
            (--
                case of
                    (
                        -- This has never been run before.
                        (var_latestFile == "0"): (messageBox "You've never Autosaved... you can't fool me!" title: "Error Loading File")
                        -- The latest file has been deleted
                        (var_latestFile == ""): messageBox "The latest autosave on        \nrecord no longer exists." title: "Error Loading File"
                        -- Found the latest file and asks if they're sure they want to load it up
                        default: if queryBox ("Are you sure you want to load the latest autosave file?  \n\n          " + var_latestFile) title:"Reload latest Autosave" do
                            (
                                loadMaxFile (var_latestFile)
                                messageBox "Please Re-save this file where you need to..." title: "Save to original location"
                                -- Get the name of the latest file saved without the "xx.max"
                                var_file = substring var_latestFile 1 (var_latestFile.count - 6)
                                -- Get the name of the .ini file associated with this file in order to read the original file's name/location information
                                var_iniFile = var_file + ".ini"
                                origFile = getINISetting var_iniFile "OriginalFile" "NameAndLocation"
                                -- Prompt user to save the file
                                savedAs = getSaveFileName caption: "Save ME!" filename: origFile
                                for i = 1 to savedAs.count do
                                (
                                    if savedAs[i] == "\\" then 
                                    (
                                        savedAs[i] = "/"
                                    )
                                )
                                loadMaxFile savedAs
                            )
                    )
            )--


        -- Update all information related to the maximum number of max files to save
        on spnr_maxNumFiles changed numVal do
            (--
                var_maxNumFiles = numVal
                fn_updateMaxNumFiles (numVal as string)
                fn_getMaxNumFiles()
            )--

        -- Update all information related to the timer settings
        on spnr_saveInterval changed numVal do
            (--
                tickTock.interval = (numVal * 60000)
                fn_updateSaveInterval (numVal as string)
                fn_getSaveInterval()
                cbtn_activateAutosave.caption = "Autosave" + " (" + var_saveInterval as string + " m)"
            )--

        -- Update all information related to the color the user prefers to use
        on saveColor changed newCol do
            (--
                cbtn_activateAutosave.highlightColor = newCol as point3
                -- This toggles the autosave button
                cbtn_activateAutosave.checked = not cbtn_activateAutosave.checked            
                -- This toggles the autosave button again, needed to make sure the new color takes effect
                cbtn_activateAutosave.checked = not cbtn_activateAutosave.checked            
                cbtn_toggleManual.highlightColor = newCol as point3
                -- This toggles the button
                cbtn_toggleManual.checked = not cbtn_toggleManual.checked                    
                -- This toggles the button again, needed to make sure the new color takes effect.  I haaaaate MAX!
                cbtn_toggleManual.checked = not cbtn_toggleManual.checked                    
                cbtn_settingsWindow.highlightColor = newcol as point3
                -- This toggles the button
                cbtn_settingsWindow.checked = not cbtn_settingsWindow.checked                    
                -- This toggles the button again, needed to make sure the new color takes effect.  I haaaaate MAX!
                cbtn_settingsWindow.checked = not cbtn_settingsWindow.checked                    
                fn_updateHighlightColor ((newCol as point3) as string)
                fn_getHighlightColor()
            )--
            
        --Toggle between manual and auto mode, disable the timer if in manual mode, adds settings to ini file.
        on cbtn_toggleManual changed var_toggleManualState do
            (--
                btn_manualSave.visible = var_toggleManualState
                cbtn_activateAutosave.visible = not var_toggleManualState
                case of
                    (
                        (var_toggleManualState == true):
                            (
                                GeOAutosave.tickTock.active = false
                                cbtn_activateAutosave.checked = true
                                fn_updateManualMode "true"
                                fn_getManualMode()
                            )
                        (var_toggleManualState == false):
                            (
                                cbtn_activateAutosave.checked = true
                                GeOAutosave.tickTock.active = true
                                fn_updateManualMode "false"
                                fn_getManualMode()
                            )
                    )
            )--

        -- Open and close the settings window.
        on cbtn_settingsWindow changed settingState do                                                                
            (--
                if settingState == true do GeOAutoSave.height = 180
                if settingState == false do GeOAutoSave.height = 21
            )--

        -- Deletes all backup files for the currently open document, if any 
        on btn_deleteCurrentFiles pressed do
            (--
                case of
                    (
                        ((doesFileExist var_currentFolder) and (var_currentFile != "")):
                            (
                                if queryBox ("Are you sure you want to delete all backup files of " + maxfilename + "?") title:"Delete current Backups?" beep:true do
                                    (dosCommand ("rmdir " + getFilenamePath var_currentFolder + " /s /q"))
                                if (var_latestFile) == (var_currentFile + "_01") do GeOAutosave.btn_reloadLatestSave.tooltip = "Reload Latest Save: Latest save on record does not exist"
                            )
                        default: messageBox "Autosaves for this file do not exist" title: "There are no backups bro!"
                    )
            )--

        -- Deletes all files in the autosave directory 
        on btn_deleteAllFiles pressed do
            (--
                if queryBox "Are you sure you want to delete all your backup files?\n\nTHIS IS NOT UNDO-ABLE" title:"Delete all Backups?! This is SPARTA!!!" beep:true do
                    (
                        hiddenDosCommand ("rmdir " + getdir #autoback + " /s /q")
                        try hiddenDosCommand ("md " + var_maxAutobackFolder) catch (0)
                        fn_updateLatestFile
                        fn_getLatestFile
                    )
            )--

        --The autosave timer. 
        on tickTock tick do
            (--
                if tickTock.interval != (var_saveInterval * 60000) do tickTock.interval = (var_saveInterval * 60000)
                -- Don't Autosave if this is a new maxfile, otherwise save the file
                if maxFilename != "" then fn_runAutosave()
            )--

        -- Open the autosave folder for whatever reason. Maybe you wanna see how many backups you got?
        on btn_openAutosaveFolder pressed do 
            (--
                shellLaunch "explorer.exe" var_maxAutobackFolder
            )--
        -- Clear up some cruft before closing the autoback script
        on btn_closeAutosave pressed do 
            (--
                autoBackup.enabled = var_maxAutobakEnabled                                                            
                fn_updateAutosavePosition   (getDialogPos GeOAutosave as string)
                -- fn_updateSaveState       (if var_saveState == true then return "true" else return "false")
                fn_updateSaveInterval       (var_saveInterval as string)
                fn_updateLatestFile         (var_latestFile as string)
                fn_updateManualMode         (var_manualMode as string)
                fn_updateMaxNumFiles        (var_maxNumFiles as string)
                fn_updateHighlightColor     (var_highlightColor as string)
                fn_updatePreToggle          (var_preToggle as string)
                var_dirPlugCFG = undefined
                var_dirMaxRoot = undefined
                var_settingsFile = undefined
                var_currentFile = undefined
                var_currentFolder = undefined
                var_autosavePosition = undefined
                var_saveState = undefined
                var_saveInterval = undefined
                var_latestFile = undefined
                var_manualMode = undefined
                var_maxNumFiles = undefined
                var_highlightColor = undefined
                var_preToggle = undefined
                var_maxAutobakEnabled = undefined
                gc()
                destroyDialog GeOAutoSave
            )--
        -- When the autosave window is closed, remove the callbacks 
        on GeoAutosave close do
            (--
                -- When this script is closed, set max's built-in autobak option to what it was before this script was run
                callbacks.removescripts #filePostOpen       id:#AutosaveOpenUpdate    
                callbacks.removescripts #filePostSave       id:#AutosaveResetTimer    
                callbacks.removescripts #systemPostReset    id:#AutosaveResetUpdate    
            )--
    )--
    
-- Let's get it on!!!
createDialog GeOAutoSave width:166 height:20 pos:var_autosavePosition style:#(#style_sunkenEdge)
