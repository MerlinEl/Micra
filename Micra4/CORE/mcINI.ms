--------------------------------------------------------------------------------
/* mcINI by Orien 2019 */
--------------------------------------------------------------------------------
Global mcINI
Global mcINIKey
Global mcINIHead
/*
*@Used Structures
	Micra
	mcXML
*
*@Used Objects
*
*@Usage
	Read-Write-Convert INI files
*
*@Example
	ini = mcINI(Micra.ActionsINI)
	ini.toString()
	ini.getData "Object" "Clone_2"
	
*@Example Conversion
	--Convert Simple Methods Ini Files
	fn iniToXmlSipmle fpath fname root_node_name  method:undefined = (

		local ini = mcINI(fpath + fname + ".ini")
		local xml_str = ini.toXMLStringAll root_node_name method:method
		local xml = mcXML(fpath + fname + ".xml") --set save location
		xml.fromString xml_str
		xml.save()
	)
	--Convert Combined Methods INI Files
	fn iniToXmlComplex fpath fname root_node_name = (

		format "PROCESS INI:%\n" fpath
		local ini = mcINI(fpath + fname + ".ini")
		local xml_str = "<"+root_node_name+">\n"
		xml_str += ini.toXMLString "Properties_1" pattern:#("active", "pos", "size", "title", "btnCount")
		xml_str += ini.toXMLString "Properties_2" pattern:#("active", "pos", "size", "title")
		xml_str += ini.toXMLString "Buttons"
		xml_str += "</"+root_node_name+">\n"
		local xml = mcXML(fpath + fname + ".xml") --set save location
		xml.fromString xml_str
		xml.save()
	)
	--
	files_array = #("Skeleton", "LS3D_ReplaceModel", "Actions_Help") --Micra.RootDir
	iniToXmlSipmle Micra.RootDir files_array[1] "SKELETON" method:"default"
	iniToXmlSipmle Micra.UserDir + "Default\\Settings" "DEFAULT" method:"default"
	--
	nodes_array = #("DEFAULT", "EMPTY", "TEMP")
	files_array = #("Profile_Default", "Profile_Empty", "Profile_Temp") --Micra.UserDir + "Default\\
	for i=1 to files_array.count do iniToXmlComplex (Micra.UserDir + "Default\\") files_array[i] nodes_array[i]
	--
	files_array = #("Profile_1","Profile_2","Profile_3","Profile_4","Profile_5","Profile_6","Profile_7","Profile_8")
	for i=1 to files_array.count do iniToXmlComplex Micra.UserDir files_array[i] "USER"
	--
	files_array = #("Profile_1","Profile_2","Profile_3","Profile_4","Profile_5","Profile_6","Profile_7","Profile_8")
	for i=1 to files_array.count do iniToXmlComplex "e:\\Aprog\\Orien\\Micra\\Micra4\\User\\rene.baca\\" files_array[i] "USER"
	--
	iniToXmlSipmle "e:\\Aprog\\Orien\\Micra\\Micra4\\User\\rene.baca\\" "Settings" "USER" method:"default"
*
*/

struct MICRA_INI_TEMPLATES (
	_template_1 = ( --value key simple method(1) (use getIniSetting)
		"[Profiles]\n" +
		"\t1=Default\n" +
		"\t2=Empty\n" +
		"\t3=Empty\n" +
		"\t4=Test\n" +
		"\t[ColorPalete]\n" +
		"\t1 =(color 38 8 0)\n" +
		"\t2 =(color 74 35 0)\n" +
		"\t3 =(color 66 67 0)\n" +
		"\t[3dGallery]\n" +
		"\tThumb_Render_Size = [200,150]\n" +
		"\tThumb_Size  =[160,128]\n" +
		"\tThumb_Color =(color 33 70 112)\n" +
		"\tOpacity=1.0\n" +
		"\tCurrent_Dir=E:/3DGallery/Nature/Leafs/\n" +
		"\trootPath=D:/ReneBaca/3DsMax/3DGallery/\n" +
		"\tRoot_Dir=E:/3DGallery/\n"
	),
	_template_2 = ( --array method(2) (use split str ",")
		"[Object]\n" +
		"\tGallery_3D		= 221, mcFile.fileInVersion 3DGallery,3D Gallery\n" +
		"\tAlign			= 63, mcMax.alignObject(),Align\n" +
		"\tAlign_By_2Edges	= 198,mcAction.objectAlignByTwoEdges(), Align By 2Edges\n" +
		"\tClone_2			= 62, mcFile.fileInVersion Clone2,Clone 2\n" +
		"\tColor_Palete		= 66, mcFile.fileInVersion Color_Palete,Color Palete\n" +
		"\tConcave_Check	= 237,mcAction.concaveCheck(), Quad Check\n" +
		"\t[Pivot]\n" +
		"\tAfect_Pivot_Only	= 51, mcAction.pivot_affect_only(), Afect Pivot Only\n" +
		"\tAlign_To_Edge	= 134, mcAction.pivot_align_to_edge(), Pivot To Edge\n" +
		"\tPick_Edge_Pivot	= 134, mcAction.pickEdgePivot(), Pick Edge Pivot\n" +
		"\tPivot_To_Center	= 10, mcAction.pivot_move_to_center(), Pivot To Center\n" +
		"\tPivot_To_X		= 12, mcAction.pivot_move_to_x(), Pivot To X\n"
	),
	_template_3 = ( --array method(3) (use execute)
		"[Properties_1]\n" +
		"\tmc_Dialog_A		=#(true, [2172,872], [148,66], 'Menu:', [6,2])\n" +
		"\tmc_Dialog_B		=#(true, [2172,288], [148,162], 'Object:', [6,6])\n" +
		"\tmc_Dialog_C		=#(true, [2172,450], [148,66], 'Pivot:', [6,2])\n" +
		"\tmc_Dialog_D		=#(true, [2172,516], [148,90], 'Select:', [6,3])\n" +
		"\t[Properties_2]\n" +
		"\tmcMicraDialog	=#(true, [2172,222], [148,66], '')\n" +
		"\tmcCustomizeDialog=#(false, [1380,500], [600,404], '')\n" +
		"\tmcProgramDialog	=#(undefined, [2298,0], [256,232], '')\n" +
		"\tmcisoDialog		=#(false, [181,152], [140,400], '')\n" +
		"\tmcModifierDialog=#(undefined, [100,100], [400,400], '')\n"
	),
	_template_4 = ( --object based method(4) (use parser)
		"[Buttons]\n" +
		"\tbtn_B2=action:Move_To_X icon:28\n" +
		"\tbtn_B3=action:Create_3PGrid icon:81\n" +
		"\tbtn_B4=action:Mirror_2 icon:64\n" +
		"\tbtn_B5=action:Reset_Transform icon:33\n" +
		"\tbtn_B7=action:Move_To_Ground icon:54\n" +
		"\tbtn_B8=action:Clone_2 icon:62\n" +
		"\tbtn_B9=action:Rename icon:67\n"
	)
)
Global mcINITemp = MICRA_INI_TEMPLATES()

struct mcINIKey (key="", val="")
struct mcINIHead (head="", keys=#())


struct mcINI (
public	
	url		= undefined,
	loaded	= false,
	_data = #(),
	fn getSource = getSourceFileName(), --get path of this script
	fn exists = (url != undefined and doesFileExist url),
	/**
	*@Usage

	*@Example
	*/
	fn toString = (
	
		local data_str = ""
		for d in _data do (
		
			data_str += "[" + d.head + "]\n"
			for k in d.keys do (
			
				data_str += "\t" + k.key + " = "+ k.val +"\n"
			)
		)
		data_str
	),
	fn trimLeftRight str = (trimLeft(trimRight str)),
	fn getData head key = (
	
		if not loaded do (print "You must load INI file first"; return undefined)
		local head_data = for d in _data where d.head == head do exit with d
		if classOf head_data != mcINIHead do (format "At head [ % ] not found\n" head; return undefined)
		local key_data = for k in head_data.keys where k.key == key do exit with k
		if classOf key_data != mcINIKey do (format "At key [ % ] not found\n" key; return undefined)
		key_data.val
	),
	fn getParseMethod str = (
		
		str = trimLeftRight str
		if str[1] == "[" then "default" else --[1572,818]
		if findString str ":\\" != undefined then "default" else  --"E:\Aprog\Orien\Micra\Micra4\Default\"
		if findString str ":/" != undefined then "default" else  --"E:/Aprog/Orien/Micra/Micra4/Default/"
		if findString str "#(" != undefined then "execute_array" else --#(true, [1572,818], [148,66], "Menu:", [6,2])")
		if findString str "," != undefined then "split_array" else --true, [1572,818], [148,66], "Menu:", [6,2])"
		if findString str ":" != undefined then "parse_object" else --action:LS3D_Model_Manager icon:254
		"default"
	),
	fn parseObject str = ( --action:Move_To_X icon:28
		
		local ini_data = trimLeftRight str --remove white space left and right
		--local rgx = dotnetObject "System.Text.RegularExpressions.Regex" ini_data
		--ini_data = rgx.Replace ":" "="
		local data_array = filterString ini_data " " --split string in to array
		if classof data_array != array do return "" --conversion failed
		local attribs_str = ""
		for d in data_array do (
		
			local arr = filterString d ":"	
			attribs_str += arr[1] + "=" + "\"" + arr[2] + "\" "
		)
		attribs_str = trimRight attribs_str --remove last space
		attribs_str
	),
	fn makeAttribs keys values = (
	
		format "mcIni > makeAttribs > \nkeys:%\nvalues:%\n" keys values 
		if keys.count != values.count do (format "mcINI > makeAttribs > Number of Keys( % ) and Values( % )  do not match.\n"; return "")
		local attribs_str = ""
		for i=1 to keys.count do (
			
			local key_str = trimLeftRight (keys[i] as String)
			local val_str = trimLeftRight (values[i] as String)
			attribs_str +=	key_str + "=\"" + val_str + "\" "
		)
		attribs_str = trimRight attribs_str --remove last space
		attribs_str
	),
	/**
	*@Usage		
		INPUT: INI File
		[Object]
		Gallery_3D			= 221, mcFile.fileInVersion 3DGallery,3D Gallery
		Align				= 63, mcMax.alignObject(),Align
		Align_By_2Edges		= 198,mcAction.objectAlignByTwoEdges(), Align By 2Edges
		...
		OUTPUT: XML String
		<Object>
			<Gallery_3D icon="221"cmd="mcFile.fileInVersion 3DGallery"tooltip="3D Gallery"/>
			<Align icon="63"cmd="mcMax.alignObject()"tooltip="Align"/>
			<Align_By_2Edges icon="198"cmd="mcAction.objectAlignByTwoEdges()"tooltip="Align By 2Edges"/>
		</Object>
		...
	*@Example
		ini = mcINI(Micra.ActionsINI)
		xml_str = ini.toXMLString "Object" pattern:#("icon", "cmd", "tooltip")

		ini = mcINI(Micra.TempProfileINI)
		xml_str = ini.toXMLString "Properties_1" pattern:#("active", "pos", "size", "title", "btnCount")

		ini = mcINI(Micra.TempProfileINI)
		xml_str = ini.toXMLString "Buttons"
	*/
	fn toXMLString head pattern:#() = (
	
		if not loaded do (print "You must load INI file first"; return false)
		local head_data = for d in _data where d.head == head do exit with d
		if classOf head_data != mcINIHead do (format "At head [ % ] not found\n" head; return undefined)
		--format "mcINI > toXMLString > head_data:%\n" head_data
		local xml_str = "<"+head+">\n"
		for k in head_data.keys do (

			local val_str = k.val 
			local method = getParseMethod val_str
			--format "mcINI > toXMLString > method:% val_str:%\n" method val_str
			local val = case method of (
		
				"split_array": makeAttribs pattern (filterString val_str ",")
				"execute_array": makeAttribs pattern (execute val_str)
				"parse_object": parseObject val_str
				default: "val=\"" + val_str + "\""
			)
			xml_str += "\t<" + k.key + " " + val +"/>\n"
		)
		xml_str += "</"+head+">\n"
		xml_str
	),
	/**
	*@Example
		--(1) all heads uses the same patern (complex data a=1, b=2, c=3,... need pattern)
		ini = mcINI(Micra.ActionsINI)
		single_patern = #("icon", "cmd", "tooltip")
		all_paterns = for i = 1 to ini._data.count collect single_patern 
		xml_str = ini.toXMLStringAll "ACTIONS" all_paterns 
		xml = mcXML(Micra.RootDir + "Actions.xml") --set save location
		xml.exists()
		xml.remove()
		xml.fromString xml_str
		xml.toString()
		xml.save()
		mc_node = xml.getNode "//ACTIONS/Menu/Calculator"
		mc_node.setAttribute "cmd" "mcShell.openApp calc"
		--(2) all heads without patern (simple data key = val)
		ini = mcINI(Micra.DefaultSettings)
		xml_str = ini.toXMLStringAll "SETTINGS"
		xml = mcXML(Micra.RootDir + "Settings.xml") --set save location
		xml.fromString xml_str
		xml.toString()
		xml.save()
		mc_node = xml.getNode "//SETTINGS/Gallery3D/Current_Dir"
		mc_node.getAttribute "val"
		--(3) using different patterns
		--TODO
	*/
	fn toXMLStringAll root_node_name paterns:#()  = (
	
		local out_xml_str = "<" + root_node_name + ">\n"
		for i = 1 to _data.count do (
		
			local p = if paterns.count == 0 then #() else paterns[i]
			local xml_str = toXMLString _data[i].head pattern:p
			out_xml_str  += xml_str
		)
		out_xml_str +=  "</" + root_node_name + ">\n"
		out_xml_str
	),
	fn save = (
	
		if not loaded or url == undefined do (print "Unable to save. URL is not set or documet is empty. "; return false)
	),
	/**
	*@Example
		 ini = mcINI()
		 ini = mcINI("c:/nonexisting_file.ini")
	*/
	on create do (
	
		if not (exists()) do return OK
		try ( --ini = mcINI("c:/existing_file.ini")
			
			local all_heads = getIniSetting url
			for h in all_heads do (
			
				local keys = #()
				local all_keys = getIniSetting url h
				for k in all_keys do (
				
					keys += #(mcINIKey k (getIniSetting url h k))
				)
				_data += #(mcINIHead h keys)
			)
			loaded = true
			
		) catch ( --unable to load XML file
			
			format "Error : mcINI > create > Unable to load INI File:[ % ] Error:\n%\n" url (getCurrentException())
		)
	)
	/*<end>*/
)	
