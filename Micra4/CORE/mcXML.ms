--------------------------------------------------------------------------------
/* mcXML by Orien 2019 */
--------------------------------------------------------------------------------
Global mcXML
Global mcXMLAttrib
Global mcXMLNode
/*
*@Used Structures
	Micra
*
*@Used Objects
	mcXMLAttrib
	mcXMLNode
*
*@Usage
	Read-Write XML files with intuitive interface
	-----------------------
	LOAD FROM FILE or BUILD
	-----------------------
	xml = mcXML (Micra.TempDir + "xml_test_45.xml")
	-----------------------
	LOAD FROM STRING
	-----------------------
	xml.exists() --false or true
	xml.fromString mcXMLTemp._template_1
	-----------------------
	READ DATA
	-----------------------
	xml.exists() --true
	mc_node = xml.getNode "//GALLERY/image_1"
	mc_node.getAttribute "author"
	-----------------------
	CREATE ROOT NODE
	-----------------------
	xml.exists() --false
	xml.addRootNode "GALLERY"	
	-----------------------
	ADD or REPLACE NODES
	-----------------------
	xml.exists() --true
	node_attribs = #(
	
		mcXMLAttrib "year" "2018", 
		mcXMLAttrib "author" "J K. Rowling",
		mcXMLAttrib "price" "39.95"
	)
	xml.addNode "//GALLERY" "image_1" attr:node_attribs
	xml.addNode "//GALLERY/Nova/Day" "d_001" attr:#(mcXMLAttrib "sell" "1000")
	xml.addNode "//GALLERY" "image_1" attr:#(mcXMLAttrib "author" "Giada De Laurentiis") override:true
	
	mc_node = xml.getNode "//GALLERY/image_1"
	mc_node.toString()
	mc_node.setAttribute "author" "J M. Novalis"
	mc_node.setAttributes #(mcXMLAttrib "author" "J M. Novalis", mcXMLAttrib "sell" "1000")
	mc_node.toString()
	-----------------
	DEBUG and SAVE
	-----------------
	xml.toString()
	xml.save()
*
*@Example
	xml = mcXML (Micra.TempDir + "Actions.xml")
	xml.toString()

	xml = mcXML (Micra.TempDir + "Actions_01.xml")
	xml.addRootNode "ACTIONS"	
	xml.fromString mcXMLTemp._template_1
	new_node = xml.addNode "//SETTINGS/Nova/Day" "d_001" attr:#(mcXMLAttrib "sell" "1000")
	xml.addNode "//SETTINGS/Nova/Day" "d_001" attr:#(mcXMLAttrib "sell" "2000") override:true
	xml.toString()
	xml.save()
*
*/
	
DotNet.LoadAssembly "System.Xml"

struct MICRA_XML_TEMPLATES (

	_template_1 = (
		"<?xml version='1.0' encoding='UTF-8'?>" +
		"<SETTINGS>" +
			"<Buttons>" +
				"<btn_B2 action='Move_To_X' icon='28' />" +
				"<btn_B3 action='Create_3PGrid' icon='81' />" +
				"<btn_B4 action='Mirror_2' icon='64' />" +
				"<btn_B5 action='Reset_Transform' icon='33' />" +
				"<btn_B7 action='Move_To_Ground' icon='54' />" +
			"</Buttons>" +
			"<Properties_1>" +
				"<mc_Dialog_A active='true' pos='[2172,872]' size='[148,66]' title='Menu:' btnCount='[6,2]' />" +
				"<mc_Dialog_B active='true' pos='[2172,288]' size='[148,162]' title='Object:' btnCount='[6,6]' />" +
				"<mc_Dialog_C active='true' pos='[2172,450]' size='[148,66]' title='Pivot:' btnCount='[6,2]' />" +
			"</Properties_1>" +
				"<Properties_2>" +
				"<mcMicraDialog val='#(true, [2172,222], [148,66])' />" +
				"<mcCustomizeDialog val='#(false, [1380,500], [600,404])' />" +
				"<mcProgramDialog val='#(undefined, [2298,0], [256,232])' />"  +
			"</Properties_2>" +
		"</SETTINGS>" 
	),
	_template_2 = ( --personaly I newer use this type of xml
	
		"<?xml version='1.0' encoding='UTF-8'?>" +
		"<BOOKSTORE>" +
			"<book category='COOKING'>" +
				"<title lang='en'>Everyday Italian</title>" +
				"<author>Giada De Laurentiis</author>" +
				"<year>2005</year>" +
				"<price>30.00</price>" +
			"</book>" +
			"<book category='CHILDREN'>" +
				"<title lang='en'>Harry Potter</title>" +
				"<author>J K. Rowling</author>" +
				"<year>2005</year>" +
				"<price>29.99</price>" +
			"</book>" +
			"<book genre='novel' ISBN='1-861001-57-5'>" +
			"<title>Pride And Prejudice</title>" +
			"</book>" +
		"</BOOKSTORE>"
	)
)
Global mcXMLTemp = MICRA_XML_TEMPLATES()

struct mcXMLAttrib ( key="", val="" ) --both must be strings

struct mcXMLNode(

	tag,
	parent,
	_node,
	fn init dnNode = (
	
		_node = dnNode
		tag = dnNode.LocalName
		parent = dnNode.ParentNode
	),
	fn getTag = (
	
		_node.Name
	),
	fn setTag newTag =(
	
		try(_node.Name = newTag)catch(false)
	),
	fn getAttribute attribute = (
	
		_node.GetAttribute attribute
	),
	fn setAttribute attribute value = (
	
		_node.SetAttribute attribute value
	),
	fn setAttributes attr = ( --arr = Array of [ mcXMLAttrib key val ]
	
		if attr.count > 0 do for itm in attr do (
		
			if itm.key == undefined or itm.val == undefined do (format "Attribute [ % ] is invalid.\n" itm; continue)
			setAttribute (itm.key as String) (itm.val as String)
		)
	),
	fn deleteAttribute attribute = (
	
		_node.RemoveAttribute attribute
	),
	fn getAllAttributes = (
	
		local ret = #()
		attribs = _node.Attributes
		for i = 0 to (attribs.Count - 1) do(

			local item = (attribs.ItemOf i)
			append ret (mcXMLAttrib item.Name item.Value)
		)
		return ret
	),
	fn delAllAttributes = (
	
		_node.Attributes.RemoveAll()
	),
	fn hasAttribute attribute =(
	
		_node.HasAttribute attribute
	),
	fn appendNode newNode = (
	
		if classof newNode == mcXMLNode then(
			_node.AppendChild newNode._node
			return true
		)else(false)
	),
	fn getChild index = (
		local dNode = _node.ChildNodes.ItemOf index
		if dNode.Name != "#text" then(
			newNode = mcXMLNode()
			newNode.init dnode
			newNode
		)else(false)
	),
	fn getChildren = (
	
		local nodes = #()
		for i = 0 to (_node.ChildNodes.Count - 1) do(
		
			local dNode = _node.ChildNodes.ItemOf i
			newNode = mcXMLNode()
			newNode.init dNode
			append nodes newNode
		)
		nodes
	),
	fn getChildrenNames = (
	
		local nodes = getChildren()
		local node_names = #()
		for n in nodes do(
		
			if n.tag == "#comment" do continue --skip comments nodes
			append node_names n.tag
		)
		node_names
	),
	fn deleteChild childNode = (
		if classof childNode == mcXMLNode then (
			_node.RemoveChild childNode._node
			return true
		)else(false)
	),
	fn deleteAllChildren = (_node.RemoveAll()),
	/**
	*@Usage
		return first node at given patn or undefined
	*@Example
		xml = mcXML (Micra.TempDir + "xml_test_91.xml")
		xml.fromString mcXMLTemp._template_1
		mc_node = xml.getNode "//bookstore/book/author"
		mc_node = xml.getNode "//book/author"
		mc_node = xml.getNode "//author"
		mc_node.toString()
		all three ways give the same result > "Giada De Laurentiis"
	*/
	fn getNode node_path = (
	
		local target_node = _node.SelectSingleNode node_path
		if target_node != undefined then (
		
			local newNode = mcXMLNode()
			newNode.init target_node
			newNode
		) else (
		
			undefined
		)
	),
	fn toString = (_node.OuterXml)
)

struct mcXML (
public	
	url = undefined,
--private
	loaded		= false,
	rootNode	= undefined, --mcXMLNode
	doc = dotNetObject "System.Xml.XmlDocument",
public
	fn getSource = getSourceFileName(), --get path of this script
	fn exists = (url != undefined and doesFileExist url),
	fn reformat = ( --add new lines and tabs
	
		local sw = dotNetObject "System.IO.StringWriter"
		doc.Save sw
		sw
	),
	/**
	*@Usage
		override all document content
	*@Example
		xml = mcXML(Micra.TempDir + "xml_test_08.xml")
		xml.fromString mcXMLTemp._template_1
		xml.toString()
		xml.save()
	*/
	fn fromString xml_str = (
		
		try (
		
			doc.LoadXml xml_str
			rootNode = mcXMLNode()
			rootNode.init doc.DocumentElement
			loaded = true
		) catch ( --unable to parse XML string
			
			format "Error : mcXMLNode > fromString : %\n" (getCurrentException())	
		)
	),
	/**
	*@Example
		xml = mcXML()
		xml.fromString mcXMLTemp._template_1
		xml.toString()
	*/
	fn toString = (
	
		if doc.DocumentElement == undefined or doc.DocumentElement.IsEmpty do return ""
		(reformat()).ToString() --Format XML String to Print Friendly XML String
	),
	--fn getNode node_path = (if doc.DocumentElement != undefined then doc.SelectSingleNode node_path else undefined),
	/**
	*@Usage
		return array of nodes(mcXMLNode)
	*/
	fn getChildren = (rootNode.getChildren()),
	/**
	*@Example
		xml = mcXML (Micra.TempDir + "xml_test_96.xml")
		xml.exists() --false
		xml.addRootNode "GALLERY"
		xml.tostring()
		xml.save()
	*@Warning
		do not insert InnerText at rootNode (cause bad formating)
	*/
	fn addRootNode root_node_name = ( --create new xml
		
		if loaded do (
		
			print "This document already has a 'DocumentElement' node."
			return false 
		)
		local root_node = doc.createElement root_node_name
		doc.appendChild root_node
		rootNode = mcXMLNode()
		rootNode.init doc.DocumentElement
		loaded = true
	),
	/**
	*@Example
		xml = mcXML (Micra.TempDir + "xml_test_94.xml")
		xml.loaded --true
		node = xml.getNode "//image_1" --or "//Object/Move_To_X"
		node.toString()
		node.setAttribute "author" "J M. Novalis"
		xml.toString()
	*@Warning
		root node name > bad: "//GALLERY/image_1" correct: "//image_1"
		last slash > bad: "//image_1/" correct: "//image_1" 
	*/
	fn getNode target_path = (
	
		if not loaded do (print "You must create root node first"; return undefined)
		rootNode.getNode target_path
	),
	/**
	*@Usage
		insert new node , override current or create new at path
	*@Example 
	
		xml = mcXML (Micra.TempDir + "xml_test_94.xml")
		xml.loaded --true
		
		--Add:
		node_attribs = #(mcXMLAttrib "year" "2018", mcXMLAttrib "author" "J K. Rowling")
		xml.addNode "//GALLERY" "image_1" attr:node_attribs
		node_attribs = #(mcXMLAttrib "year" "2019", mcXMLAttrib "author" "Erik T. Ray")
		xml.addNode "//GALLERY" "image_2" attr:node_attribs
		
		--Replace:
		node_attribs = #(mcXMLAttrib "year" "2019", mcXMLAttrib "author" "Giada De Laurentiis")
		xml.addNode "//GALLERY" "image_1" attr:node_attribs override:true
		
		--New Path:
		node_attribs = #(mcXMLAttrib "year" "2020", mcXMLAttrib "author" "D A. Makarov")
		xml.addNode "//GALLERY/Nova/Dot" "image_1" attr:node_attribs
		or
		xml.addNode "//GALLERY/Nova/Dot/image_1" "" attr:node_attribs
		xml.toString()
	*/
	fn addNode target_path node_name attr:#() override:false = (
	
		if not loaded do (print "You must create root node first"; return false)
		if node_name.count == 0 do ( --split path("//GALLERY/Nova/Dot/image_1") to target_path("//GALLERY/Nova/Dot/") and node_name("image_1")
		
			local path_arr = filterString target_path "/"
			if path_arr.count < 2 do (print "Invalid path"; return undefined)
			node_name = path_arr[path_arr.count] --get last path name
			target_path = trimright target_path node_name --remove last path name
			target_path = trimright target_path "/" --remove last slash
			--format "mcXML > addNode > create new node at target_path:% arr:%  node name:%\n" target_path path_arr node_name
		)
		local new_node = mcXMLNode()
		new_node.init (doc.createElement node_name)
		new_node.setAttributes attr
		local target_node = getNode target_path
		if target_node == undefined do ( --insert new node with full path
			
			--format "Path not found! Create new path [ % ].\n" target_path
			local path_array = filterString target_path "/" --#("GALLERY", "Nova")
			--format "path_array:%\n" path_array
			--found which parts of path not exist and create them!!!!!!!
			local progresive_path = "//" + path_array[1] 
			local progresive_node = rootNode.getNode progresive_path
			 --if first node not found create one at base --test it to be finished
			if progresive_node == undefined do (
				
					local next_node = mcXMLNode()
					next_node.init (doc.createElement path_array[1])
					rootNode.appendNode next_node
					progresive_node = rootNode.getNode progresive_path
			)
			--< test this one with LS3D Model Manager --paths without SETTINGS/ --or always put in write full node path like "SETTINGS/ROOT/edit"
			
			for i = 2 to path_array.count do (
			
				progresive_path = progresive_path + "/" + path_array[i]
				if rootNode.getNode progresive_path == undefined then (
				
					format "creating node at path: [ % ]\n" progresive_path
					local next_node = mcXMLNode()
					next_node.init (doc.createElement path_array[i])
					progresive_node.appendNode next_node
					
				) else (
				
					--format "node exists at path [  % ]\n" progresive_path
				)
				progresive_node = rootNode.getNode progresive_path
			)
			progresive_node.appendNode new_node
			return new_node
		)
		local node_path = target_path + "/" + node_name
		local found_node = rootNode.getNode node_path
		if override and found_node != undefined then ( --replace current node

			found_node.parent.ReplaceChild new_node._node found_node._node
			--doc.DocumentElement.ReplaceChild new_node._node found_node._node
			new_node = found_node
			--format "replace node:%  at:%\n" found_node.tag target_path
		
		) else ( --append new node
		
			new_node.parent = target_node
			target_node.appendNode new_node
			--format "add node:% at:%\n" node_name target_path
		)
		new_node
	),
	/**
	*@Example 
	
		xml = mcXML Micra.ActionsXML
		xml.addNode "//ACTIONS/TestCat"
		xml.delNode "//ACTIONS/TestCat"
		xml.toString()
		xml.save()
	*/
	fn delNode target_path = (
	
		if not loaded do (print "You must create root node first"; return false)
		local xml_node = getNode target_path
		if xml_node == undefined do return false
		xml_node.parent.RemoveChild xml_node._node
	),
	fn delAllNodes target_path = (
	
		if not loaded do (print "You must create root node first"; return false)
		local xml_node = getNode target_path
		if xml_node == undefined do return false
		xml_node.deleteAllChildren()
	),
	fn hasAttribute attr_name = (
		
		rootNode.hasAttribute attr_name
	),
	fn getAllAttributes target_path = (
	
		if not loaded do (print "You must create root node first"; return false)
		local xml_node = getNode target_path
		if xml_node == undefined do return false
		xml_node.getAllAttributes()
	),
	fn delAllAttributes target_path = (
	
		if not loaded do (print "You must create root node first"; return false)
		local xml_node = getNode target_path
		if xml_node == undefined do return false
		xml_node.delAllAttributes()
	),
	fn swapAttributes path_a path_b = (
	
		local node_a = getNode ("//"+path_a)
		local node_b = getNode ("//"+path_b)
		if node_a == undefined or node_b == undefined do return false
		local cotent_a = node_a.getAllAttributes() 
		local cotent_b = node_b.getAllAttributes() 
		--format "BEFORE nodes:\na:%\nb:%\n" (node_a.toString()) (node_b.toString())
		node_a.delAllAttributes()
		node_b.delAllAttributes()
		node_a.setAttributes cotent_b
		node_b.setAttributes cotent_a
		--format "AFTER nodes:\na:%\nb:%\n" (node_a.toString()) (node_b.toString())
	),
	fn saveSimple = (if loaded then (doc.save url; true) else false), --save with intact formatting
	fn save = ( --save nice formated
	
		if not loaded or url == undefined do (print "Unable to save XML. Documet is empty or URL is not set. "; return false)
		local writer = dotNetClass "System.Xml.XmlTextWriter"
		local wSettings = dotNetObject "System.Xml.XmlWriterSettings"
		wSettings.indent = true
		local w = writer.create url wSettings
		doc.writeContentTo w
		w.close()
		true
	),
	fn remove = (if exists() do deleteFile url),
	on create do (
	
		--doc.PreserveWhitespace = false
		if not (exists()) do ( --xml = mcXML() || xml = mcXML("c:/nonexisting_file.xml")
		
			local header = doc.CreateXmlDeclaration "1.0" "utf-8" ""
			doc.AppendChild header
			return OK
		)
		try ( --xml = mcXML("c:/existing_file.xml")
			
			doc.load url
			rootNode = mcXMLNode()
			rootNode.init doc.DocumentElement
			loaded = true
		) catch ( --unable to load XML file
			
			format "Error : mcXML > create > Unable to load XML File:[ % ] Error:\n%\n" url (getCurrentException())	
		)
	)
	/*<end>*/
)	

/*
https://docs.microsoft.com/en-us/dotnet/api/system.xml.xmldocument?view=netframework-4.7.2

 XmlElement bookElement = doc.CreateElement("book", "http://www.contoso.com/books");
 XmlElement titleElement = doc.CreateElement("title");
 titleElement.InnerText = title;
  bookElement.AppendChild(titleElement);
bookElement.InnerXml = bookElement.InnerXml.Replace(titleElement.OuterXml, "\n    " + titleElement.OuterXml + " \n    ");
*/


--Removed > 
	/**
	*@Usage
		insert - replace node with xml string
	
	fn fromStringAt xml_str node_path override:false = (
	
		if override do (
		
			--remove node if exists
		)
	),*/