--<><><><><><><><><><><><><><><><><><>
-- Multi Camera Renderer
--
-- Author  : Xavier CROUZY
-- Version : 1.1 English
-- 
-- History
--
-- 1.0		: 	Initial version
--
-- 1.1		:	Update parameters layout
--		  	  	Credits section
--		  	  	Output image format selection
--		  	  	Graphics progress bar
--
-- 1.2		:	Update output file name fiels
--		  	  	Add frame range selection
--  
-- Website : http://www.amarhys.com
--
--<><><><><><><><><><><><><><><><><><>

--macroScript Multi_Cameras_Render category:"XC_SCRIPTS" toolTip:"Multi Camera Render"
--(

global cam_sc_list   = #()
global cam_rd_list   = #()
global cam_rd_prms   = #()
global cam_ms_list   = #()

global cancel_rd     = false

global nb_rd         = 0
global nb_sc         = 0
global scr_name      = "Select a script..."
global current_cam   = ""

global FloaterCancelRender
global FloaterMultiRenderer
global FloaterMissingCams

global daypermonth = #(0,31,59,90,120,151,181,212,243,273,304,334)

--<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
--
-- MISSING CAMERAS ROLLOUT
--
--<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rollout MissingCams "Missing Cameras/Scripts" 
(
label lba
label lbb
label lbc
listbox mcams items:#() height:10
button mcams_ok  "OK"

--=========================
on mcams_ok pressed do
--=========================
	closerolloutfloater FloaterMissingCams
)

--<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
--
-- MAIN ROLLOUT
-- 
--<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rollout MultiRenderer "Parameters"
(

-- RENDERING PARAMETERS
groupbox RENDPARAMBOX "Target Path and Files" pos:[5,10] width:500 height:125
label l_of "Target directory :" pos:[20,40]
edittext file_path  "" text:"C:" width:200 height:20 pos:[130,38]
button get_path ".." width:25 pos:[340,38] 
label l_prf "Output file names :" pos:[20,72]
edittext file_prefix "" text:"img"  width:70 height:20 pos:[130,70]
label l_cmn " + camera + " pos:[200,72]
edittext file_suffix "" text:""  width:73 height:20 pos:[257,70]
dropdownlist filetype "" items:#("tga","jpg","bmp","tif","png") width:45 pos:[340,70]
button p_load "Load.." width:90 pos:[400,38] 
button p_save "Save.." width:90 pos:[400,70] 
button p_options "More Options.." width:90 pos:[400,102]
checkbox logfile "Log file :" pos:[20,103]
edittext log_file ""  text:"C:\maxlog.txt" width:200 height:20 pos:[130,102]
button get_log ".." width:25 pos:[340,102]

-- CAMERAS/SCRIPTS SELECTION
groupbox CAMSELBOX "Cameras Selection" pos:[5,145] width:500 height:260
button cam_add ">>" pos:[205,250]
button cam_sub "<<" pos:[205,310]
button cam_up "up" pos:[445,190] width:40
button cam_down "down" pos:[445,220] width:40
label l_scr "(Scripts)" pos:[445,255]
button scr_add "| <" pos:[449,280]
button scr_sub "> |" pos:[449,310]
spinner ffrm "S:" range:[0,9999,0] fieldwidth:40 type:#integer pos:[435,345] enabled:false
spinner lfrm "L:" range:[0,9999,0] fieldwidth:40 type:#integer pos:[436,370] enabled:false
multilistbox cam_list "Scene cameras"    height:15 pos:[20,170] width:175 
multilistbox cam_rend "Cameras to render / Scripts" height:15 pos:[245,170] width:185


-- PRE-RENDER SELECTION PARAMETERS
groupbox RENDBOX "Rendering Sequence" pos:[5,415] width:500 height:85
checkbox rev_list "Reverse cameras list" pos:[30,472]
checkbox enscr "Enable pre-rendering script" pos:[30,442]
button sel_scr "Select a script..." pos:[200,440] width:200


-- RENDER BUTTON
button render_cam "Render Cameras" pos:[200,520] width:110

-- PROGRESS BAR
label lbprog "0 camera(s) of 0 have been rendered" pos:[165,555]


-- CREDITS
label ct1 "Author : Xavier CROUZY -" pos:[100,610]
hyperLink ct2 "Website : http://www.amarhys.com" address:"http://www.amarhys.com/index-gb.htm" color:(color 120 70 70) visitedColor:(color 120 70 70) pos:[230,610]


--<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
--
-- FUNCTIONS
-- 		
--<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

--=========================================
-- fint
-- Format integer with #n digit
--=========================================
function fint i =
(
	local p = #("00","0","")
	local r = (i as string)
	return ( p[r.count] + r) 
)


--=========================================
-- init_cams
-- Fill cam_sc_list and cam_rd_lis
--=========================================
function init_cams =
(
	local cams_array

	cam_sc_list = #()
	cam_rd_list = #()
	nb_rd = 0
	nb_sc = 0

	cams_array = Cameras as array
	
	for cm in cams_array do
		if (cm.isTarget != true) then
			append cam_sc_list cm.name

	sort cam_sc_list
		
	cam_list.items = cam_sc_list
	cam_rend.items = cam_rd_list
)
	
--=========================================
-- format_cams
-- Format cam_rd_list display
--=========================================
function format_cams =
(
	local cams_array = #()
	
	for i=1 to cam_rd_list.count do
		append cams_array ("[" + (fint cam_rd_prms[i][3][1]) + ":" + (fint cam_rd_prms[i][3][2]) +  "] " + cam_rd_list[i])
		
	return cams_array
)

--=========================================
-- log_onoff()
-- Manage log file button enable/disable
--=========================================
function log_onoff =
(
	if (logfile.checked) then
		(
			log_file.enabled = true
			get_log.enabled  = true
		)
	else
		(
			log_file.enabled = false
			get_log.enabled  = false
		)
)

--=========================================
-- scr_onoff()
-- Manage enable script button
--=========================================
function scr_onoff =
(
	if (enscr.checked) then
			sel_scr.enabled  = true
	else
			sel_scr.enabled = false
)

--=========================================
-- scr_onoff()
-- Manage enable script button
--=========================================
function frm_onoff =
(
	local sc = 1
	
	if (not cam_rend.selection.isEmpty) then
	(
		ffrm.enabled = true
		lfrm.enabled = true
	
		while (cam_rend.selection[sc]==false) do sc=sc+1
		ffrm.Value = cam_rd_prms[sc][3][1]
		lfrm.Value = cam_rd_prms[sc][3][2]
	)
	else
	(
		ffrm.Value   = 0
		lfrm.Value   = 0
		ffrm.enabled = false
		lfrm.enabled = false
	)
)

--=========================================
-- subdate date1 date 2
-- Performs date substraction
--=========================================

function subdate date1 date2 =
(
	local fld1   = filterString date1 "/ :"
	local fld2   = filterString date2 "/ :"
	local nbday1 = (fld1[3] as integer) * 365 + daypermonth[(fld1[2] as integer)] + (fld1[1] as integer)
	local nbday2 = (fld2[3] as integer) * 365 + daypermonth[(fld2[2] as integer)] + (fld2[1] as integer)
	local nbday  = nbday2 - nbday1
	local nbsec1 = (fld1[4] as integer) * 3600 + (fld1[5] as integer) * 60 + (fld1[6] as integer)
	local nbsec2 = (fld2[4] as integer) * 3600 + (fld2[5] as integer) * 60 + (fld2[6] as integer)
	
	if (nbsec2 >= nbsec1) then
		nbsec = nbsec2 - nbsec1
	else
		(
		nbday = nbday-1
		nbsec = (86400-nbsec1) + nbsec2
		)
		
	--------------------	
	-- calculate hours
	--------------------
	nbhour = nbsec/3600
	nbsec  = nbsec - (nbhour * 3600)
	if (nbhour<10) then
		nbhour = "0" + (nbhour as string)
	else
		nbhour = (nbhour as string)
		
	----------------------
	-- calculate minutes
	----------------------
	nbmin  = nbsec/60
	nbsec  = nbsec - (nbmin * 60)
	if (nbmin<10) then
		nbmin = "0" + (nbmin as string)
	else
		nbmin = (nbmin as string)

    ----------------------
	-- calculate seconds
	----------------------
	if (nbsec<10) then
		nbsec = "0" + (nbsec as string)
	else
		nbsec = (nbsec as string)

	if (nbday > 0) then
		disptime = (nbday as string) + " day(s),  " + nbhour + ":" + nbmin + ":" + nbsec
	else
		disptime = nbhour + ":" + nbmin + ":" + nbsec

	return disptime
)

--<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
--
-- Logfile Checkbox Event
--
--<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

on logfile changed state do 
	log_onoff()


--<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
--
-- Update Frame Spinners Event
--
--<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

on cam_rend selectionEnd do
	frm_onoff()

--<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
--
-- Enable Script Checkbox Event
--
--<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

on enscr changed state do 
	scr_onoff()
	
--<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
--
-- Select Script Button
--
--<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

on sel_scr pressed do
(
	scr_name = getOpenFileName()
	if scr_name != undefined then
		sel_scr.text = FilenameFromPath scr_name
)

--<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
--
-- Frame spinners update
--
--<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
on ffrm changed val do
(
	for i = 1 to cam_rend.selection.count do
		if (cam_rend.selection[i] == true) then
			cam_rd_prms[i][3][1]=val

	cam_rend.items = format_cams()
)

on lfrm changed val do
(
	for i = 1 to cam_rend.selection.count do
		if (cam_rend.selection[i] == true) then
			cam_rd_prms[i][3][2]=val

	cam_rend.items = format_cams()
)

--<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
--		
-- SAVE FUNCTION
--
--<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

on p_save pressed do
(
	i_f_name = getSaveFileName()
	if i_f_name != undefined then
		(
		i_f_str = createFile i_f_name
		print cam_rd_list.count    to:i_f_str
		for i=1 to cam_rd_list.count do 
		(
			print cam_rd_list[i]   to:i_f_str
			print cam_rd_prms[i]   to:i_f_str
		)
		print file_prefix.text     to:i_f_str
		print file_suffix.text     to:i_f_str
		print file_path.text       to:i_f_str
		print filetype.selection   to:i_f_str
		print logfile.checked      to:i_f_str
		print log_file.text        to:i_f_str
		print enscr.checked        to:i_f_str
		print scr_name             to:i_f_str
		print rev_list.checked     to:i_f_str
		
 		close i_f_str
	)
)

--<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
--
-- LOAD FUNCTION
--
--<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

on p_load pressed do
(
	local current_rd   = ""
	local current_prms = ""
	local nb_items     = 0
	local nb_valid     = 0

	o_f_name = getOpenFileName()

	if o_f_name != undefined then
		(
		--------------------------------
		-- re-init cameras list
		--------------------------------
		init_cams()
		cam_rd_list = #()
		cam_ms_list = #()
		nb_valid    = 1
		
		--------------------------------
		-- get data from file
		--------------------------------
		
		o_f_str  = openFile o_f_name
		
		nb_items = readValue o_f_str
		
	    --------------------------------
		-- process saved items 1 by 1	
        --------------------------------
	
		for i=1 to nb_items do
			(
			current_rd   = readValue o_f_str
			current_prms = #((readValue o_f_str),(readValue o_f_str),(readValue o_f_str))
			
			---------------------------
			-- process scripts
			---------------------------
			if (current_prms[1] == "S") then
				(
			
				------------------------------------------
				-- Loaded script is OK
				------------------------------------------
				if (doesFileExist current_prms[2]) then
					(
					cam_rd_list[nb_valid] = current_rd
					cam_rd_prms[nb_valid] = current_prms
					nb_valid = nb_valid + 1
					)
				
				------------------------------------------
				-- Loaded script does not exist
				------------------------------------------
				else
					(
					append cam_ms_list current_rd
					)
 				)
			
			---------------------------
			-- process cameras
			---------------------------
			else
				(
	
				index = findItem cam_sc_list current_rd
			
				------------------------------------------
				-- Loaded camera does not exist
				------------------------------------------
				if (index==0) then
					(
					append cam_ms_list current_rd
					)
			
				------------------------------------------
				-- Loaded camera has been found
				------------------------------------------
				else
					(
					nb_rd = nb_rd + 1
					cam_rd_list[nb_valid] = current_rd
					cam_rd_prms[nb_valid] = current_prms
					nb_valid = nb_valid + 1
					deleteItem cam_sc_list index
					)
				)
			)

		cam_rend.items     = format_cams()
		cam_list.items     = cam_sc_list

		file_prefix.text   = readValue o_f_str
		file_suffix.text   = readValue o_f_str
		file_path.text     = readValue o_f_str
		filetype.selection = readValue o_f_str
		
		logfile.checked    = readValue o_f_str
		log_file.text      = readValue o_f_str

		enscr.checked      = readValue o_f_str
		scr_name           = readValue o_f_str
		sel_scr.text 	   = FilenameFromPath scr_name

		rev_list.checked   = readValue o_f_str

		close o_f_str
		
		log_onoff()
		scr_onoff()
		frm_onoff()
		
		--------------------------------------
		-- display missing cams
		--------------------------------------
		
		if (cam_ms_list.count > 0) then
			(
			if FloaterMissingCams != undefined do
				(
				closerolloutfloater FloaterMissingCams
				)		
			FloaterMissingCams = newRolloutFloater "WARNING" 300 260
			addRollout MissingCams FloaterMissingCams
			
			MissingCams.lbb.text    = "Following Cameras/Scripts don't exist in the current scene."
			MissingCams.mcams.items = sort cam_ms_list
			)

		--------------------------------------
		-- update cameras count
		--------------------------------------
		
		lbprog.text = "0 camera(s) of " + nb_rd as string + " have been rendered"
	)
)

--<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
--
-- MORE OPTIONS
--
--<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

on p_options pressed do
	max render scene

--<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
--
-- PATH for saved rendered files
-- 
--<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

on get_path pressed do
(
	file_path_s = getSavePath()
	if (file_path_s != undefined) then
		file_path.text = file_path_s
)

--<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
--
-- PATH and FILENAME for LOG file
-- 
--<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

on get_log pressed do
(
	log_file_s = getSaveFileName()
	if (log_file_s != undefined) then
		log_file.text = log_file_s
)


--<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
--
-- CAMERA UP BUTTON
--
--<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

on cam_up pressed do
(

	local tmp
	local new_rend_selection = cam_rend.selection

	for i=1 to cam_rend.selection.count do
		if (cam_rend.selection[i]==true and i>1) then
			(
			tmp              = cam_rd_list[i]
			cam_rd_list[i]   = cam_rd_list[i-1]
			cam_rd_list[i-1] = tmp
			tmp              = cam_rd_prms[i]
			cam_rd_prms[i]   = cam_rd_prms[i-1]
			cam_rd_prms[i-1] = tmp
			
			new_rend_selection[i]   = false
			new_rend_selection[i-1] = true

			cam_rend.items     = format_cams()
			cam_rend.selection = new_rend_selection	

			frm_onoff()
			)
)

--<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
--
-- CAMERA DOWN BUTTON
--
--<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

on cam_down pressed do
(
	local tmp
	local new_rend_selection = cam_rend.selection

	for i=cam_rend.selection.count to 1 by -1 do
		if (cam_rend.selection[i]==true and i<cam_rend.selection.count) then
			(
			tmp              = cam_rd_list[i]
			cam_rd_list[i]   = cam_rd_list[i+1]
			cam_rd_list[i+1] = tmp
			tmp              = cam_rd_prms[i]
			cam_rd_prms[i]   = cam_rd_prms[i+1]
			cam_rd_prms[i+1] = tmp

			new_rend_selection[i]   = false
			new_rend_selection[i+1] = true

			cam_rend.items     = format_cams()
			cam_rend.selection = new_rend_selection	
			
			frm_onoff()
			)
)

--<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
--
-- SCRIPT -> CAM TO RENDER
--
--<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

on scr_add pressed do
(
	local scr_id          = getOpenFileName()
	
	if scr_id != undefined then
		(
		nb_sc = nb_sc+1		
		append cam_rd_list (FilenameFromPath scr_id)
		
		append cam_rd_prms #("S",scr_id,#(0,0))
 
		cam_rend.items     = format_cams()
		cam_rend.selection = #{}
		
		frm_onoff()
		)
)

--<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
--
-- SCRIPT -> DELETE
--
--<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

on scr_sub pressed do
(

	local cam_tmp_list = #()
	local cam_tmp_prms = #()

	for i= 1 to cam_rend.selection.count do
		if (cam_rend.selection[i]==true and cam_rd_prms[i][1]=="S") then
			nb_sc = nb_sc-1
		else
			(
			append cam_tmp_list cam_rd_list[i]
			append cam_tmp_prms cam_rd_prms[i]
			)
	
	cam_rd_list        = cam_tmp_list
	cam_rd_prms        = cam_tmp_prms

	cam_rend.items     = format_cams()
	cam_rend.selection = #{}
	
	frm_onoff()
)

--<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
--
-- CAM SCENE -> CAM TO RENDER
--
--<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

on cam_add pressed do
(

	local cam_tmp_list    = #()
	
	for i= 1 to cam_list.selection.count do
		if (cam_list.selection[i]==true) then
			(
			nb_rd = nb_rd+1
			append cam_rd_list cam_sc_list[i]
			append cam_rd_prms #("C","0",#(0,0))
			)
		else
			append cam_tmp_list cam_sc_list[i]

	cam_sc_list        = cam_tmp_list
		
	cam_rend.items     = format_cams()
	cam_rend.selection = #{}

	cam_list.items     = sort cam_sc_list
	cam_list.selection = #{}
	
	frm_onoff()

	lbprog.text = "0 camera(s) of " + nb_rd as string + " have been rendered"
)

--<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
--
-- CAM TO RENDER -> CAM SCENE
--
--<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

on cam_sub pressed do
(

	local cam_tmp_list = #()
	local cam_tmp_prms = #()

	for i= 1 to cam_rend.selection.count do
		if (cam_rend.selection[i]==true and cam_rd_prms[i][1]=="C") then
			(
			nb_rd = nb_rd-1
			append cam_sc_list cam_rd_list[i]
			)
		else
			(
			append cam_tmp_list cam_rd_list[i]
			append cam_tmp_prms cam_rd_prms[i]
			)
	
	cam_rd_list        = cam_tmp_list
	cam_rd_prms        = cam_tmp_prms

	cam_list.items     = sort cam_sc_list
	cam_list.selection = #{}
		
	cam_rend.items     = format_cams()
	cam_rend.selection = #{}
	
	frm_onoff()

	lbprog.text = "0 camera(s) of " + nb_rd as string + " have been rendered"
)

--<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
--
-- RENDERING CAMS
--
--<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

on render_cam pressed do
(

	local start_time , end_time
	local autotbk
	local rtn
	local first_cam, last_cam, incr_cam
	local render_ok = true
	local error_mess = ""
	local file_temp
	local r_bitmap

	--===============================
	-- MANAGE ERRORS
	--===============================

	------------------
	-- CAMERA COUNT
	------------------
	if (cam_rd_list.count == 0) then
	(	
		render_ok  = false 
		error_mess = "You must select at least one camera."
	)

	------------------
	-- SAVE PATH
	------------------
	try
	(
		tname = file_path.text + "//" + file_prefix.text + file_suffix.text + "_temp"
		file_temp = createfile (tname)
		close file_temp
		deleteFile (tname)
	)
	catch
	(
		render_ok = false
		error_mess = "File path or file prefix is not valid."
	)

	-------------------
	-- LOG FILE
	-------------------
	try
	(
		file_temp = createfile log_file.text
		close file_temp
		deletefile log_file.text
	)
	catch
		if (logfile.checked) then
		(
			render_ok = false
			error_mess = "Log file is not valid."
		)
	
	-------------------
	-- SCRIPT FILE
	-------------------
	if (enscr.checked and scr_name=="Select a script...") then
	(
		render_ok = false
		error_mess = "You must select a script file."
	)

	--===============================
	-- RENDER IS OK
	--===============================

	if (render_ok) then
	(
		-------------------------------
		-- Remove AUTOBACKUP function
		-------------------------------
		autobk = autoBackup.enabled
		autoBackup.enabled = false

		nb_cam_rd     = 0
		cancel_rd     = false


		-------------------------------
		-- Fill LOG file header
		-------------------------------
		if (logfile.checked) then
			(
			log_f_str = createFile log_file.text
			format "LOG FILE %\n\n" localTime to:log_f_str
			)

		-------------------------------
		-- Create Cams List to Render
		-------------------------------

		cam_ms_list = #()
	
		if (rev_list.checked) then
		(
			first_cam = cam_rd_list.count
			last_cam  = 1
			incr_cam  = -1
		)
		else
		(
			first_cam = 1
			last_cam  = cam_rd_list.count
			incr_cam  = 1
		)

		-------------------------------
		-- Process Cams 1 by 1
		-------------------------------

		for i = first_cam to last_cam by incr_cam do
		(
			for f = cam_rd_prms[i][3][1] to cam_rd_prms[i][3][2] do
			(
				-------------------------
				-- 	EXECUTE LIST SCRIPT
				-------------------------
				if (cam_rd_prms[i][1]=="S") then
				(
					try 
					(
						fileIn cam_rd_prms[i][2]
						logdisplay = cam_rd_prms[i][2] + " : Execution successfull"
					)
					catch
						logdisplay = cam_rd_prms[i][2] + " : ERROR - Script execution failed"
		
					if (logfile.checked) then
						format "%\n" logdisplay to:log_f_str 
				)
			
				-------------------------
				-- RENDER CAMERA
				-------------------------
				else
				(	
					current_time = 0
					current_cam = execute ("$'" + cam_rd_list[i] + "'")
		
					---------------------------
					-- execute post-script
					---------------------------
					if (enscr.checked) then
						fileIn scr_name
		 		
					---------------------------
					-- output file name
					---------------------------
					ofile = file_path.text + "//" + file_prefix.text + cam_rd_list[i] + file_suffix.text 
					ofile = ofile + "_f" + (fint f) + "." + filetype.text
	
					---------------------------
					-- launch render process
					---------------------------
					try
					(
						start_time = localTime
						r_bitmap = render camera:current_cam frame:f outputfile:ofile progressbar:true frame:#current
						end_time = localTime
						logdisplay = cam_rd_list[i] + " : " + (subdate start_time end_time)
					)
					catch
					(
						append cam_ms_list cam_rd_list[i]
						logdisplay = cam_rd_list[i] + " : ERROR - Camera does not exist"
					)
	
					----------------------------------
					-- rendering information update
					----------------------------------
 					nb_cam_rd = nb_cam_rd + 1	
					lbprog.text = nb_cam_rd as string + " Camera(s) of " + nb_rd as string + " have been rendered"

					---------------------------------
					-- check cancel pressed
					---------------------------------
					if (keyboard.escPressed==true) then
					(
						logdisplay = cam_rd_list[i] + " : CANCEL - Rendering interrupted by user"
			
						if queryBox "Do you want to cancel rendering ?" then
						(
							cancel_rd = true
		    				undisplay r_bitmap
							if (logfile.checked) then
								format "%\n" logdisplay to:log_f_str 	
							exit
						)	
					)

					----------------------------------
					-- update log file
					----------------------------------
				
					if (logfile.checked) then
						format "%\n" logdisplay to:log_f_str 	
		
					---------------------------------
					-- delete bitmap buffer
					---------------------------------
					close r_bitmap
				)
			)
			
			-----------------------------
			-- Cancel Rendering
			-----------------------------
			if (cancel_rd == true) then
				exit
		)
	
		---------------------------------
		-- Close LOG file
		---------------------------------
		if (logfile.checked) then
			close log_f_str
		
		---------------------------------
		-- Restore AUTOBACKUP function
		--------------------------------- 
		autoBackup.enabled = autobk
			
		--------------------------------------
		-- display missing cams
		--------------------------------------
		
		if (cam_ms_list.count > 0) then
		(
			if FloaterMissingCams != undefined do
				closerolloutfloater FloaterMissingCams		
			FloaterMissingCams = newRolloutFloater "WARNING" 300 292
			addRollout MissingCams FloaterMissingCams
		
			MissingCams.lbb.text    = "Following camera(s) does not exist."
			MissingCams.mcams.items = cam_ms_list			
		)
	)
		
	--------------------------------
	-- RENDER IS NOT OK
	--------------------------------
	else
		messageBox error_mess
	)
)

--<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
--
-- Initial processing
--
--<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

if FloaterMultiRenderer != undefined do
	closerolloutfloater FloaterMultiRenderer
		
FloaterMultiRenderer = newRolloutFloater "Multi Camera Renderer - v1.1 (English) by Xavier CROUZY" 525 692
addRollout MultiRenderer FloaterMultiRenderer rolledUp:false

--===============================
-- Variables INIT
--===============================

current_time = 0

--===============================
-- Cameras List INIT
--===============================
MultiRenderer.init_cams()

--===============================
-- Interface INIT
--===============================
MultiRenderer.log_onoff()
MultiRenderer.scr_onoff()

--)