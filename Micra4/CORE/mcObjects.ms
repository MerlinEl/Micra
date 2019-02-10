--------------------------------------------------------------------------------
/* mcObjects by Orien 2019 */
--------------------------------------------------------------------------------
Global mcItem
Global mcObject
Global mcSize
Global mcRect
Global mcCube

/*
*@Used Structures
	none - this is base
*
*@Used Objects
	none - this is base
*
*/

/**
*@example
	mcItem "a" 23
*/
struct mcItem ( key, val, tag, index )

/**
*@example
	mco = mcObject()	
	mco.add "first" 100 --> OK
	mco.add "second" 200 --> OK
	mco.addMore #(

		mcItem "a" 1,
		mcItem "b" 2,
		mcItem "c" 3
	)
	mco.get "first" --> 100
	mco.keys() --> #("first", "second", "a", "b", "c")
	mco.values() --> #(100, 200, 1, 2, 3)
	or
	(
		local data = mcObject()
		data.addMore #(
			
			mcItem "struc" "mcFile", 
			mcItem "func" "read", 
			mcItem "param" "c:\\temp\\test.txt"
		)
		format "keys:%\n" (data.keys())
	)
*/
struct mcObject ( --always create an instance
private	
	_keys = #(), _values = #(),
public
	fn getSource = getSourceFileName(), --get path of this script
	fn keyIndex key = (finditem _keys key),		
	fn hasKey key = (keyIndex key > 0),
	fn keys = (_keys),
	fn values = (_values),
	fn add key val = (
	
		local key_index = keyIndex key
		--format "mcObject > add >  key:% val:% replace:%\n" key val (key_index>0)
		if key_index == 0 then ( --add
			
			_keys = append _keys key
			_values =  append _values val
		) else ( --replace
		
			_values[key_index] = val	
		)
	),	
	fn get key = (
		
		local key_index = keyIndex key
		--format "mcObject > get >  key:% index:%\n" key key_index
		return if key_index > 0 then _values[key_index] else undefined
	),
	fn addMore itm_arr = (
	
		for itm in itm_arr do add itm.key itm.val	
		this
	),
	fn removeKey key = (
	
		local key_index = keyIndex key
		if key_index > 0 do (
		
			deleteitem _keys key_index
			deleteitem _values key_index
		)
	),
	fn toString = (
	
		local str = ""
		for i = 1 to _keys.count do (str += _keys[i] + ":" + _values[i] as string + " ")
		trimRight str --remove last space
	),
	fn print = (
	
		local str = "mcObject ("
		for i = 1 to _keys.count do (str +=  "\n\tkey:" + _keys[i] + " val:" + _values[i] as string)
		str += "\n)\n"
		::print str
	)
)

/*
	si = mcSize 20 45
	si.w -- 20
*/
Struct mcSize (w, h)

/*
	bo = mcBounds [0, 0] [200, 400]
	bo.pos -- [0, 0]
*/
Struct mcBounds (pos, size)

/*
	re = rect()
	rct = re mi:[0,10] ma:[40,60]
	rct.wi()
	rct.he()
	rct.si()
*/
Struct mcRect 
(
	mi, ma,                  --min, max 
	fn wi =(abs(ma.x-mi.x)), --width 
	fn he =(abs(mi.y-ma.y)), --height  
	fn si =(ma - mi       )  --size
)
/*
	cu = cube2()
	cub = cu mi:$.min ma:$.max
	cub.mi
	cub.he()
	cub.si()
*/

Struct mcCube
(
	mi, ma,                  --min, max
	fn wi =(abs(ma.x-mi.x)), --width
	fn he =(abs(mi.y-ma.y)), --height 
	fn le =(abs(mi.z-ma.z)), --lenhth
	fn si =(ma - mi       )  --size
)


/* --3d bounding box
		for v = 1 to verts.count do
		(
			local p = polyOp.getVert obj v --vert pos
			if type == #local do p *= inverse obj.transform
			if maxX != undefined then
			(
				if p.x < minX then minX = p.x
				if p.y < minY then minY = p.y
				if p.z < minZ then minZ = p.z
				
				if p.x > maxX then maxX = p.x
				if p.y > maxY then maxY = p.y
				if p.z > maxZ then maxZ = p.z
			)
			else
			(
				maxX = minX = p.x
				maxY = minY = p.y
				maxZ = minZ = p.z
			)
		)
*/



/**
*@Usage
	Classes to simplify working with XML. XMLNode and XMLDocument wrap the dotNet XML classes. The interface replicates my python interface.
	This file should be installed to maxroot/Scripts/Startup/XMLStructs.ms
	Created By David Mackenzie
	dave@daveandgoliath.com
	File Version 1.2
*/
/*
DotNet.LoadAssembly "System.Xml"

struct XMLNode(

	Tag,
	Parent,
	DotNetNode,
	
	fn init dnNode = (
		DotNetNode = dnNode
		Tag = dnNode.LocalName
		Parent = dnNode.ParentNode
	),
	fn GetTag = (
		DotNetNode.Name
	),
	fn SetTag newTag =(
		try(DotNetNode.Name = newTag)catch(False)
	),
	fn GetText = (
		DotNetNode.InnerText
	), 
	fn SetText txt = (
		DotNetNode.InnerText = txt
	),
	fn AddAttribute attribute value = (
		DotNetNode.SetAttribute attribute value
	),
	fn GetAttribute attribute = (
		DotNetNode.GetAttribute attribute
	),
	fn SetAttributeValue attribute value = (
		DotNetNode.SetAttribute attribute value
	),
	fn DeleteAttribute attribute = (
		DotNetNode.RemoveAttribute attribute
	),
	fn GetAllAttributes = (
		ret = #()
		attribs = DotNetNode.Attributes
		for i = 0 to (attribs.Count - 1) do(
			t = #()
			item = (attribs.ItemOf i)
			append t item.Name
			append t item.Value
			append ret t
		)
		return ret
	),
	fn HasAttribute attribute =(
		DotNetNode.HasAttribute attribute
	),
	fn AppendNode newNode = (
		if classof newNode == XMLNode then(
			DotNetNode.AppendChild newNode.DotNetNode
			return True
		)else(False)
	),
	fn GetChild index = (
		dNode = DotNetNode.ChildNodes.ItemOf index
		if dNode.Name != "#text" then(
			newNode = XMLNode()
			newNode.init dnode
			newNode
		)else(return False)
	),
	fn GetChildren = (
		nodes = #()
		for i = 0 to (DotNetNode.ChildNodes.Count - 1) do(
			dNode = DotNetNode.ChildNodes.ItemOf i
			newNode = XMLNode()
			newNode.init dNode
			append nodes newNode
		)
		nodes
	),
	fn DeleteChild childNode = (
		if classof childNode == XMLNode then (
			DotNetNode.RemoveChild childNode.DotNetNode
			return True
		)else(False)
	)
)

struct XMLDocument ( 

	file = undefined,
	rootNode = undefined,
	dom = dotNetObject "System.Xml.XmlDocument",
	loaded = undefined,
	
	fn LoadXML pathToXml = (
		
		if not (doesFileExist pathToXml) or pathToXml == "..." do return false
		file = pathToXml
		doc = dom.Load file
		loaded = True
		True
	),
	fn SaveXML = (
		if loaded == True then(
			dom.Save file
			return True
		)else(False)
	),
	fn GetRootNode = (
		rootNode = XMLNode()
		rootNode.init dom.DocumentElement
		rootNode
	),
	fn getNewNode tag = (
		dNode=dom.CreateElement tag
		newNode=XMLNode()
		newNode.init dNode
		newNode
	),
	fn AppendNode newNode = (
		if classof newNode == XMLNode then(
			dom.AppendChild newNode.DotNetNode
			return True
		)else(False)
	),
	fn PrettySaveXML = (
		if loaded == True then(
			writer = dotNetClass "System.Xml.XmlTextWriter"
			wSettings = dotNetObject "System.Xml.XmlWriterSettings"
			wSettings.indent = True
			w = writer.create file wSettings
			--dom.writeTo w
			dom.writeContentTo w
			w.close()
			True
		)
	)
)
*/
/*
--Create a new XML file
(
	clearListener()
	xDoc = XMLDocument()							--Create a new XMLDocument
	xDoc.file = "C:\\Temp.xml"							--Set the file for the document, this would be set if we were using LoadXML() SEE BELOW
	xDoc.loaded = True									--Set loaded to True, this would be set if we were using LoadXML() SEE BELOW
	rNode = xDoc.getNewNode "RootNode"			--Create a new XMLNode THIS MUST BE CALLED!
	xDoc.AppendNode rNode							--Append the new node the XMLDocument
	rNode = xDoc.getRootNode()						--Get the Root Node of the document
	xDoc.SaveXML()										--Save the XML
	
	rNode.SetText "This is the Text"								--Set the node text
	rNode.AddAttribute "Attr" "Some Value"					--Add Attribute
	rNode.AddAttribute "Interesting" "Data"					--Add Attribute
	print (rNode.GetAttribute "Attr")								--Get Attribute Value
	print (rNode.GetAllAttributes())								--Get all of the attribute and there values as an array
	rNode.SetAttributeValue "Attr" "A new Value"			--Set an attribute Value
	rNode.AddAttribute "Del" "I am going to be deleted"	--Add Attribute
	rNode.DeleteAttribute "Del"									--Delete Attribute
	rNode.HasAttribute "Del"										--Test if the node Has the parsed attribute
	rNode.HasAttribute "Attr"										--Test if the node Has the parsed attribute
	
	newNode = xDoc.getNewNode "NewNode"					--Get a new Node
	rNode.AppendNode newNode									--Append a new Node
	newNode.SetText "I am a new Node"						--Set the New Node text
	
	
	newNode = xDoc.getNewNode "SpecialNode" 			--Create a new Node
	rNode.AppendNode newNode									--Append a new Node
	
	childs = rNode.GetChildren() 									--Get All of the Nodes Children
	print childs	
	
	rNode.DeleteChild newNode									--Delete Child
	xDoc.SaveXML()													--Save XML
	xDoc.PrettySaveXML()											--Saves well formed XML
	
)--End If


--Load XML from File
(
	xDoc = XMLDocument()										--Create an XMLDcoument
	xDoc.LoadXML "C:\\Temp.xml"								--Load XML from file
	rNode = xDoc.GetRootNode()									--Get the Root Node THIS MUST BE CALLED!
	
	rNode.SetAttributeValue "Attr" "Now I have been loaded"
	xDoc.SaveXML()
	
)--End If
*/
