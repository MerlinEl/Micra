--------------------------------------------------------------------------------
/* mcXML by Orien 2019 */   --Not used yet
--------------------------------------------------------------------------------
Global mcXML
Global mcXMLNode
/*
*@Used Structures
	Micra
*
*@Used Objects
	undefined
*
*@Usage
	undefined
*
*@Example
	-----
	LOAD
	-----
	xml = mcXML (Micra.TempDir + "xml_test_01.xml")
	xml.exists() --true
	ch = xml.getChildren() --root children
	------
	CREATE
	------
	xml = mcXML (Micra.TempDir + "xml_test_24.xml")
	xml.exists() --false
	xml.addRootNode "GALLERY"	
*
*/

DotNet.LoadAssembly "System.Xml"

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
		try(_node.Name = newTag)catch(False)
	),
	fn getText = (
		_node.InnerText
	), 
	fn setText txt = (
		_node.InnerText = txt
	),
	fn addAttribute attribute value = (
		_node.SetAttribute attribute value
	),
	fn getAttribute attribute = (
		_node.GetAttribute attribute
	),
	fn setAttributeValue attribute value = (
		_node.SetAttribute attribute value
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
			return True
		)else(False)
	),
	fn getChild index = (
		dNode = _node.ChildNodes.ItemOf index
		if dNode.Name != "#text" then(
			newNode = mcXMLNode()
			newNode.init dnode
			newNode
		)else(return False)
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
			return True
		)else(False)
	),
	fn toString = (
	
		format "mcXMLNode > toString > children:%\n" ( getChildren() )
	)
)

struct mcXML (
public	
	url = undefined,
--private
	loaded		= false,
	rootNode	= undefined,
public
	fn getSource = getSourceFileName(), --get path of this script
	doc = dotNetObject "System.Xml.XmlDocument",
	fn exists = (url != undefined and doesFileExist url),
	/**
	*@Example
		xml = mcXML (Micra.TempDir + "xml_test_24.xml")
		xml.exists() --false
		xml.addRootNode "GALLERY" attr:#("painting", "1") txt:"New Age"
		xml.toString()
	*/
	fn addRootNode node_name attr:#() txt:undefined= ( --create new xml
		
		if loaded do (
		
			print "This document already has a 'DocumentElement' node."
			return false 
		)
		local root_node = doc.createElement node_name
		if attr.count == 2 do root_node.setattribute attr[1] attr[2]
		if txt != undefined do root_node.InnerText = txt
		doc.appendChild root_node
		rootNode = mcXMLNode()
		rootNode.init doc.DocumentElement
		loaded = true
	),
	/**
	*@Usage
		return list(dotNetObject:System.Xml.XPathNodeList) of nodes(mcXMLNode)
	*/
	fn getChildren = (rootNode.getChildren()),
	/**
	TODO finish it -Not Used
	*@Example
		mcXML.getChildrenAt "/bookstore/*"
		mcXML.getChildrenAt "//book"
		mcXML.getChildrenAt "//book/author" 
		return list(dotNetObject:System.Xml.XPathNodeList) of nodes(mcXMLNode)
	*/
	fn getChildrenAt item_path = (
	
		--doc.selectNodes item_path
		
		local itemIter = (doc.selectnodes item_path).GetEnumerator()
		while itemIter.MoveNext() do (
		
			local attrIter = itemIter.Current.Attributes.GetEnumerator()
			--format "\nEntry:%\n" 
			while attrIter.MoveNext() do (
			
				format "  % = %\n" attrIter.current.Name attrIter.current.value
			)
		)
	),
	/**
	*Example
		xml.addChild "urn:samples"
	*/
	fn addChild child_str path:"root" txt:"" = (
	
		--local elem = doc.CreateElement("bk", "genre", "urn:samples")
		local elem = doc.CreateElement child_str
		elem.InnerText = txt
		doc.DocumentElement.AppendChild(elem)
		elem
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
			wSettings.indent = True
			local w = writer.create url wSettings
			doc.writeContentTo w
			w.close()
			true
		) else false
	),
	/**
	*@Usage
		override document content
	*@Example
		xml = mcXML(Micra.TempDir + "xml_test_08.xml")
		xml.fromString (

			"<?xml version='1.0' ?>" +
			"<book genre='novel' ISBN='1-861001-57-5'>" +
			"<title>Pride And Prejudice</title>" +
			"</book>"
		)
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
		xml.fromString (

			"<?xml version='1.0' ?>" +
			"<book genre='novel' ISBN='1-861001-57-5'>" +
			"<title>Pride And Prejudice</title>" +
			"</book>"
		)
		xml.toString()
	*/
	fn toString = (
	
		format "XML:\n%\n" doc.DocumentElement.OuterXml
		/*local children = getChildren()
		format "mcXML > toString > children:%\n" children
		for ch in children do(

			print ch --xml.getItems
		)*/
		--format "mcXML > toString > first child:%\n" (doc.FirstChild.toString()) 	
		--format "mcXML > toString > xml:%\n" (doc.toString())
		--format "mcXML > toString > root node:%\n" (rootNode.toString())
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


	/**
	*@Example
		mcXML.printTree "//bookstore"
		mcXML.printTree "//Skeleton/Bone/Item"
	*/
	/*fn printTree item_path = (
	
		local itemIter = (doc.selectnodes item_path).GetEnumerator()
		while itemIter.MoveNext() do (
		
			format "\nEntry:\n" 
			local attrIter = itemIter.Current.Attributes.GetEnumerator()
			while attrIter.MoveNext() do (
			
				format "  % = %\n" attrIter.current.Name attrIter.current.value
			)
		)
	),*/

/*
 header =  xmlDoc.item["Autodesk_Cache_File"] --this is how you pull an element section by name  
--elments can have children elements.. in this case we are quarying the value of the attribute "Type" inside the "cacheType" element which is of the "Autodesk_Cache_File"..  
cacheType = (header.item["cacheType"].GetAttribute("Type"))  
timePerFrame = (header.item["cacheTimePerFrame"].GetAttribute("TimePerFrame")) 

		xmlDoc.load 
		myNodes = xmlDoc.selectNodes "//Part"
		myPartname=(for i = 0 to myNodes.count-1 collect (myNodes.itemOf[i].getElementsByTagName "PartName").itemOf[0].attributes.itemOf["name"].value)
 		myDescrips = (for i = 0 to myNodes.count-1 collect (myNodes.itemOf[i].getElementsByTagName "PartName").itemOf[0].attributes.itemOf["Description"].value)
 		myProject = (for i = 0 to myNodes.count-1 collect (myNodes.itemOf[i].getElementsByTagName "PartName").itemOf[0].attributes.itemOf["Project"].value)
 		myDiffuse = (for i = 0 to myNodes.count-1 collect (myNodes.itemOf[i].getElementsByTagName "PartName").itemOf[0].attributes.itemOf[ "Diffuse"].value)
		mySpec= (for i = 0 to myNodes.count-1 collect (myNodes.itemOf[i].getElementsByTagName "PartName").itemOf[0].attributes.itemOf["Spec"].value)
		myNormal = (for i = 0 to myNodes.count-1 collect (myNodes.itemOf[i].getElementsByTagName "PartName").itemOf[0].attributes.itemOf["Normal"].value)
 		myReflection = (for i = 0 to myNodes.count-1 collect (myNodes.itemOf[i].getElementsByTagName "PartName").itemOf[0].attributes.itemOf["Reflection"].value)
		
		--FindCorrectItem (Gen_List.items[Gen_List.selection]) --Runs function to match xml to selected part
		
		DescripArea.text = "--" + myDescrips[(FindCorrectItem myPartname (Gen_List.items[Gen_List.selection]))]
		ProjectArea.text = "Project-- " + myProject[(FindCorrectItem myPartname (Gen_List.items[Gen_List.selection]))]
		DiffuseArea.text = myDiffuse[(FindCorrectItem myPartname (Gen_List.items[Gen_List.selection]))]
		SpecArea.text = mySpec[FindCorrectItem myPartname (Gen_List.items[Gen_List.selection])]		
		NormalArea.text = myNormal[(FindCorrectItem myPartname (Gen_List.items[Gen_List.selection]))]	
		ReflectionArea.text = myReflection[(FindCorrectItem myPartname (Gen_List.items[Gen_List.selection]))]

doc = dotNetObject "System.Xml.XmlDocument"
doc.LoadXml("<book genre='novel' ISBN='1-861001-57-5'>" +
             "<title>Pride And Prejudice</title>" +
			"</book>")

--Create a new node and add it to the document.
--The text node is the content of the price element.
elem = doc.CreateElement("price")
txt = doc.CreateTextNode("19.95")
doc.DocumentElement.AppendChild(elem)
doc.DocumentElement.LastChild.AppendChild(txt)

XmlWriter = dotNetClass "System.Xml.XmlWriter"
stringWriter = dotNetObject "System.IO.StringWriter"
mlTextWriter = XmlWriter.Create stringWriter

doc.WriteTo xmlTextWriter
xmlTextWriter.Flush()
(stringWriter.GetStringBuilder()).ToString()




--Create the XmlDocument.
XmlDocument doc = new XmlDocument();
doc.LoadXml("<item><name>wrench</name></item>");

--Add a price element.
XmlElement newElem = doc.CreateElement("price");
newElem.InnerText = "10.95";
doc.DocumentElement.AppendChild(newElem);


XmlElement elem = doc.CreateElement("bk", "genre", "urn:samples");
elem.InnerText = "fantasy";
doc.DocumentElement.AppendChild(elem);


And also to read an XML:

fn recurseXML docElement =
(
	tempPTree = #(docElement.name)
	tempLayerTree = #(docElement.getAttribute "layer")
	
	for i = 0 to (docElement.childNodes.count - 1) do
	(
		tmp = (recurseXML docElement.childNodes.itemOf[i])
		append tempPTree tmp[1]
		append tempLayerTree tmp[2]
	)
	return #(tempPTree, tempLayerTree)
)

global parentTreeXML = #()
global layerTreeXML = #()
fn readXML =
(
	xmlDoc = dotNetObject "System.Xml.XmlDocument"
	xmlDoc.load ("C:\\temp\\test.xml") 
	
	docElement = XmlDoc.documentElement
	
	-- if we don't do this here we end up with the root node on parentTreeXML
	-- which can be worked out in anoter way also, of course.
	for i = 0 to (docElement.childNodes.count - 1) do
	(
		tmp = (recurseXML docElement.childNodes.itemOf[i])
		append parentTreeXML tmp[1]
		append layerTreeXML tmp[2]
	)
)
*/



/*
<bookstore>
<book category="COOKING">
<title lang="en">Everyday Italian</title>
<author>Giada De Laurentiis</author>
<year>2005</year>
<price>30.00</price>
</book>
<book category="CHILDREN">
<title lang="en">Harry Potter</title>
<author>J K. Rowling</author>
<year>2005</year>
<price>29.99</price>
</book>
<book category="WEB">
<title lang="en">XQuery Kick Start</title>
<author>James McGovern</author>
<author>Per Bothner</author>
<author>Kurt Cagle</author>
<author>James Linn</author>
<author>Vaidyanathan Nagarajan</author>
<year>2003</year>
<price>49.99</price>
</book>
<book category="WEB">
<title lang="en">Learning XML</title>
<author>Erik T. Ray</author>
<year>2003</year>
<price>39.95</price>
</book>
</bookstore>


xmlDoc = dotNetObject "system.xml.xmlDocument"
xmlDoc.load @"somepathBookstore.xml"
--1 Get all books
myNodes = xmlDoc.selectNodes "//book"
--2 Get all childnodes of the bookstore element
myNodes = xmlDoc.selectNodes "/bookstore/*"
--3 Get all authors of all books
myNodes = xmlDoc.selectNodes "//book/author"
--4 Get all authors of books from 2005
myNodes = xmlDoc.selectNodes "//book[year='2005']/author"
--4a do the same but the year is a variable 
yearVariable = 2005
myNodes = xmlDoc.selectNodes ("//book[year='" + (yearVariable as string) + "']/author")
--5 Get all books from 2005
myNodes = xmlDoc.selectNodes "//book[year='2005']"
--6 Get all books from 2003 cheaper than 45.00
myNodes = xmlDoc.selectNodes "//book[year='2003' and price<'45']"
 --In examples 3 and 4 you do something like this to get the actual text of the xml-element in an array
myAuthors = (for i = 0 to myNodes .count-1 collect myNodes .itemOf[i].innertext)
--In examples 1, 2, 5 and 6 you get an xml-element with child-elements. Do something like this to get a specific child-element
myPrices = (for i = 0 to myNodes.count-1 collect (myNodes.itemOf[i].getElementsByTagName "price").itemOf[0].innertext)
*/






/*
StringWriter = dotNetObject "System.IO.StringWriter"
penDotNet.show StringWriter

-- Create XmlWriterSettings and fill info
XmlWriterSettings = dotNetObject "System.Xml.XmlWriterSettings"
XmlWriterSettings.Indent = true
XmlWriterSettings.indentChars="	"
XmlWriterSettings.OmitXmlDeclaration = false
XmlWriterSettings.NewLineOnAttributes = false

-- Create new XmlWriter in the StringWriter with the specified settings
XmlWriter=dotNetClass "system.xml.xmlWriter"
Writer = XmlWriter.Create StringWriter XmlWriterSettings

-- Write the document
Writer.WriteStartElement "XMLUI"
 	Writer.WriteValue "This is a test" --COMMENT and re run
	Writer.WriteStartElement "TAB"
	Writer.WriteAttributeString "Name" "Temp"
	Writer.WriteAttributeString "BackGround" ""
		Writer.WriteStartElement "UI" ""
		Writer.WriteAttributeString "Test" "12345"
-- 	Writer.WriteEndElement() --Don't realy need to set the end element as it does it for you. 
-- Writer.WriteEndElement()

-- Release Xml resources
Writer.Flush()
Writer.Close()
xmlString=StringWriter.ToString()


fn reformatXml xml Writer: =
(
	doFlush=false
	if Writer==unsupplied do 
	(
		StringWriter=dotNetObject "System.IO.StringWriter"
		XmlWriterSettings = dotNetObject "System.Xml.XmlWriterSettings"
		XmlWriterSettings.Indent = true
		XmlWriterSettings.indentChars="	"
		XmlWriterSettings.OmitXmlDeclaration = false
		XmlWriterSettings.NewLineOnAttributes = false
		XmlWriter=dotNetClass "system.xml.xmlWriter"
		Writer = XmlWriter.Create StringWriter XmlWriterSettings
		doFlush=true
	)
	
	case xml.name of
	(
		"#document": () --Do nothing
		"xml": () --Do nothing
		"#comment":
		(
			Writer.WriteComment xml.value
		)
		"#text":
		(
			Writer.writeValue xml.value
		)
		default:
		(
			Writer.WriteStartElement xml.name
			for i = 0 to xml.Attributes.count-1 do
			(
				val=xml.getAttribute xml.Attributes.item[i].name
				Writer.WriteAttributeString xml.Attributes.item[i].name val
			)
		)
	)
	
	for i = 0 to xml.childNodes.count-1 do 
	(
		reformatXml xml.childNodes.item[i] Writer:writer StringWriter:StringWriter
	)
	
	if doFlush do
	(
		Writer.Flush()
		Writer.Close()
	)
	
	StringWriter
)

--Test
xmlDoc=dotNetObject "system.xml.xmlDocument"
xmlStr="<?xml version=\"1.0\" encoding=\"UTF-8\"?>           <!--This is a comment--><XMLUI Name=\"Fred\">
<TAB Name=\"Face\"><UI /><!--This is a Button below-->
					<BUTTON Name=\"Reset\" /><INNERTEXT>This is Inner Text</INNERTEXT></TAB></XMLUI>
"
xmlDoc.loadXml xmlStr
clearListener()
xmlStr=reformatXml xmlDoc
xmlStr.toString()



xdoc = (dotNetclass "System.Xml.Linq.XDocument").Parse xmlStr
xdoc.ToString()
(dotnetobject "system.xml.linq.XDeclaration" "1.0" "utf-8" "").tostring() + "" + xdoc.ToString()
*/