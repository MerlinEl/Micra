--------------------------------------------------------------------------------
/* mcXML by Orien 2019 */
--------------------------------------------------------------------------------
Global mcXML
Global mcAttrib
Global mcXMLNode

/*
*@Used Structures
	Micra --only for debug paths
*
*@Used Objects
	mcAttrib
	mcXMLNode
*
*@Usage
	Read-Write XML files with intuitive interface
*
*@Example
	-----------------
	LOAD-BUILD
	-----------------
	xml = mcXML (Micra.TempDir + "xml_test_45.xml")
	-----------------
	GET DATA
	-----------------
	xml.exists() --true
	node = xml.getNode "//GALLERY/image_1"
	node.getAttribute "author"
	-----------------
	LOAD FROM STRING
	-----------------
	xml.exists() --false or true
	xml.fromString xml._template_1
	-----------------
	CREATE ROOT NODE
	-----------------
	xml.exists() --false
	xml.addRootNode "GALLERY"	
	-----------------
	ADD-REPLACE NODES
	-----------------
	xml.exists() --true
	node_attribs = #(
	
		mcAttrib "year" "2018", 
		mcAttrib "author" "J K. Rowling",
		mcAttrib "price" "39.95"
	)
	xml.addNode "//GALLERY" "image_1" attr:node_attribs
	xml.addNode "//GALLERY/Nova/Day" "d_001" attr:#(mcAttrib "sell" "1000")
	xml.addNode "//GALLERY" "image_1" attr:#(mcAttrib "author" "Giada De Laurentiis") override:true
	
	mc_node = xml.getNode "//GALLERY/image_1"
	mc_node.toString()
	mc_node.setAttribute "author" "J M. Novalis"
	mc_node.setAttributes #(mcAttrib "author" "J M. Novalis", mcAttrib "sell" "1000")
	mc_node.toString()
	-----------------
	DEBUG-SAVE
	-----------------
	xml.toString()
	xml.save()
*
*/
	
DotNet.LoadAssembly "System.Xml"

struct mcAttrib ( key="", val="" ) --both must be strings

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
	fn setAttributes attr = ( --arr = Array of [ mcAttrib key val ]
	
		if attr.count > 0 do for itm in attr do (
		
			if itm.key == undefined or itm.val == undefined do (format "Attribute [ % ] is invalid.\n" itm; continue)
			setAttribute (itm.key as String) (itm.val as String)
		)
	),
	fn deleteAttribute attribute = (
	
		_node.RemoveAttribute attribute
	),
	fn getAllAttributes = (
	
		ret = #()
		attribs = _node.Attributes
		for i = 0 to (attribs.Count - 1) do(
			t = #()
			item = (attribs.ItemOf i)
			append t item.Name
			append t item.Value
			append ret t
		)
		return ret
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
		dNode = _node.ChildNodes.ItemOf index
		if dNode.Name != "#text" then(
			newNode = mcXMLNode()
			newNode.init dnode
			newNode
		)else(false)
	),
	fn getChildren = (
		nodes = #()
		for i = 0 to (_node.ChildNodes.Count - 1) do(
			dNode = _node.ChildNodes.ItemOf i
			newNode = mcXMLNode()
			newNode.init dNode
			append nodes newNode
		)
		nodes
	),
	fn deleteChild childNode = (
		if classof childNode == mcXMLNode then (
			_node.RemoveChild childNode._node
			return true
		)else(false)
	),
	/**
	*@Usage
		return first node at given patn or undefined
	*@Example
		xml = mcXML (Micra.TempDir + "xml_test_91.xml")
		xml.fromString xml._template_1
		the_node = xml.getNode "//bookstore/book/author"
		the_node = xml.getNode "//book/author"
		the_node = xml.getNode "//author"
		the_node.InnerText
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
	_template_1 = ( --personaly newer use this type of struct, _template_2 is better
		"<?xml version='1.0' encoding='UTF-8'?>" +
		"<bookstore>" +
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
		"</bookstore>"
	),
	_template_2 = (
	
		"<?xml version='1.0' encoding='UTF-8'?>" +
		"<SETTINGS>" +
			"<Buttons>" +
				"<btn_B2 action='Move_To_X' icon='28' />" +
				"<btn_B3 action='Create_3PGrid' icon='81' />" +
				"<btn_B4 action='Mirror_2' icon='64' />" +
				"<btn_B5 action='Reset_Transform' icon='33' />" +
				"<btn_B7 action='Move_To_Ground' icon='54' />" +
			"</Buttons>" +
		"</SETTINGS>" 
	),
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
		override document content
	*@Example
		xml = mcXML(Micra.TempDir + "xml_test_08.xml")
		xml.fromString xml._template_1
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
		xml.fromString xml._template_1
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
	fn addRootNode node_name = ( --create new xml
		
		if loaded do (
		
			print "This document already has a 'DocumentElement' node."
			return false 
		)
		local root_node = doc.createElement node_name
		doc.appendChild root_node
		rootNode = mcXMLNode()
		rootNode.init doc.DocumentElement
		loaded = true
	),
	/**
	*@Example
		xml = mcXML (Micra.TempDir + "xml_test_94.xml")
		xml.loaded --true
		node = xml.getNode "//GALLERY/image_1"
		node.toString()
		node.setAttribute "author" "J M. Novalis"
		xml.toString()
	*/
	fn getNode target_path = (rootNode.getNode target_path),
	/**
	*@Usage
		insert new node , override current or create new at path
	*@Example 
	
		xml = mcXML (Micra.TempDir + "xml_test_94.xml")
		xml.loaded --true
		
		--Add:
		node_attribs = #(mcAttrib "year" "2018", mcAttrib "author" "J K. Rowling")
		xml.addNode "//GALLERY" "image_1" attr:node_attribs
		node_attribs = #(mcAttrib "year" "2019", mcAttrib "author" "Erik T. Ray")
		xml.addNode "//GALLERY" "image_2" attr:node_attribs
		
		--Replace:
		node_attribs = #(mcAttrib "year" "2019", mcAttrib "author" "Giada De Laurentiis")
		xml.addNode "//GALLERY" "image_1" attr:node_attribs override:true
		
		--New Path:
		node_attribs = #(mcAttrib "year" "2020", mcAttrib "author" "D A. Makarov")
		xml.addNode "//GALLERY/Nova/Dot" "image_1" attr:node_attribs
		
		xml.toString()
	*/
	fn addNode target_path node_name attr:#() override:false = (
	
		if not loaded do (print "You must create root node first"; return false)
		local new_node = mcXMLNode()
		new_node.init (doc.createElement node_name)
		new_node.setAttributes attr
		local target_node = rootNode.getNode target_path
		if target_node == undefined do ( --insert new node with full path
			
			--format "Path not found! Create new path [ % ].\n" target_path
			local path_array = filterString target_path "/" --#("GALLERY", "Nova")
			--format "path_array:%\n" path_array
			--found which parts of path not exist and create them
			local progresive_path = "//" + path_array[1] 
			local progresive_node = rootNode.getNode progresive_path
			for i = 2 to path_array.count do (
			
				progresive_path = progresive_path + "/" + path_array[i]
				if rootNode.getNode progresive_path == undefined then (
				
					--format "creating node at path: [ % ]\n" progresive_path
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
			
			local root = doc.DocumentElement
			root.ReplaceChild new_node._node found_node._node
			new_node = found_node
			--format "replace node:%  at:%\n" found_node.tag target_path
		
		) else ( --append new node
		
			new_node.parent = target_node
			target_node.appendNode new_node
			--format "add node:% at:%\n" node_name target_path
		)
		new_node
	),
	fn hasAttribute attr_name = (
		
		rootNode.hasAttribute attr_name
	),
	fn save = (
	
		if not loaded or url == undefined do (
		
			print "Unable to save. URL is not set or documet is empty. "
			return false
		)
		--if loaded then (doc.save url; true) else false
		if loaded == true then(
			local writer = dotNetClass "System.Xml.XmlTextWriter"
			local wSettings = dotNetObject "System.Xml.XmlWriterSettings"
			wSettings.indent = true
			local w = writer.create url wSettings
			doc.writeContentTo w
			w.close()
			true
		) else false
	),
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
			
			format "Error : mcXMLNode > create: %\n" (getCurrentException())	
		)
	)
	/*<end>*/
)	