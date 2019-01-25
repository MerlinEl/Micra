--------------------------------------------------------------------------------
/* mcXML by Orien 2019 */
--------------------------------------------------------------------------------
Global mcXML
Global XMLNode
/*
For delete , not used , mybe?????

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
	xml = mcXML (Micra.TempDir + "xml_test_01.xml")
	xml.url
	itms = xml.getItems "books"
	ch = xml.getChildren() --root children
	mcXML.printTree "//bookstore"
*
*/

DotNet.LoadAssembly "System.Xml"

struct XMLNode(

	tag,
	parent,
	_node,
	fn init dnNode = (
	
		_node = dnNode
		Tag = dnNode.LocalName
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
		if classof newNode == XMLNode then(
			_node.AppendChild newNode._node
			return True
		)else(False)
	),
	fn getChild index = (
		dNode = _node.ChildNodes.ItemOf index
		if dNode.Name != "#text" then(
			newNode = XMLNode()
			newNode.init dnode
			newNode
		)else(return False)
	),
	fn getChildren = (
		nodes = #()
		for i = 0 to (_node.ChildNodes.Count - 1) do(
			dNode = _node.ChildNodes.ItemOf i
			newNode = XMLNode()
			newNode.init dNode
			append nodes newNode
		)
		nodes
	),
	fn deleteChild childNode = (
		if classof childNode == XMLNode then (
			_node.RemoveChild childNode._node
			return True
		)else(False)
	)
)

struct mcXML (
public	
	url,
private
	loaded		= false,
	rootNode	= undefined,
public
	fn getSource = getSourceFileName(), --get path of this script
	doc = dotNetObject "System.Xml.XmlDocument",
	on create do (
		if not (doesFileExist url) do return false
		doc.load url
		rootNode = XMLNode()
		rootNode.init doc.DocumentElement
		loaded = true
	),
	fn getChildren = (rootNode.getChildren()),
	/**
	*@Example
		"/bookstore/*"
		"//book"
		"//book/author"
	*/
	fn getItems items_path = (
	
		doc.selectNodes items_path
	),
	/**
	*@Example
		mcXML.printTree "//bookstore"
		mcXML.printTree "//Skeleton/Bone/Item"
	*/
	fn printTree item_path = (
	
		local itemIter = (doc.selectnodes item_path).GetEnumerator()
		/*while itemIter.MoveNext() do (
		
			format "\nEntry:\n" 
			local attrIter = itemIter.Current.Attributes.GetEnumerator()
			while attrIter.MoveNext() do (
			
				format "  % = %\n" attrIter.current.Name attrIter.current.value
			)
		)*/
	),
	fn saveXML = (
	
		if loaded then (doc.save url; true) else false
	),
	fn toString = (
	
		
	),
	fn hasAttribute attr_name = (
		
		
	)
	/*<end>*/
)	
 --create instance



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