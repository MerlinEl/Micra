/*
	Classes to simplify working with XML. XMLNode and XMLDocument wrap the dotNet XML classes. The interface replicates my python interface.
	
	This file should be installed to maxroot/Scripts/Startup/XMLStructs.ms
	
	Created By David Mackenzie
	dave@daveandgoliath.com

	File Version 1.2
	
	
	Test Code is located at EOF
*/

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



testNewFile = False
testLoadFile = False

if testNewFile == True do(
	clearListener()
	
	--Create a new XML file
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
if testLoadFile == True do(
	xDoc = XMLDocument()										--Create an XMLDcoument
	xDoc.LoadXML "C:\\Temp.xml"								--Load XML from file
	rNode = xDoc.GetRootNode()									--Get the Root Node THIS MUST BE CALLED!
	
	rNode.SetAttributeValue "Attr" "Now I have been loaded"
	xDoc.SaveXML()
	
)--End If