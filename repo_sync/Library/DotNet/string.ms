stringBuilder=dotNetClass "System.Text.StringBuilder"
StringWriter = dotNetObject "System.IO.StringWriter"


-- Do not forget to load the assembly
dotnet.LoadAssembly "System.Xml.dll"

-- Create the XmlWriter class
XmlWriter = dotNetClass "System.Xml.XmlWriter"

-- Create StringWriter
StringWriter = dotNetObject "System.IO.StringWriter"

-- Create XmlWriterSettings and fill info
XmlWriterSettings = dotNetObject "System.Xml.XmlWriterSettings"
XmlWriterSettings.Indent = true
XmlWriterSettings.OmitXmlDeclaration = false
XmlWriterSettings.NewLineOnAttributes = true

-- Create new XmlWriter in the StringWriter with the specified settings
Writer = XmlWriter.Create StringWriter XmlWriterSettings

-- Write the name of each geometry in the current scene

Writer.WriteStartElement "geometries"
for object in geometry do
(
	Writer.WriteElementString "geometry" object.name
)
Writer.WriteEndElement()

-- Release Xml resources
Writer.Flush()
Writer.Close()

StringWriter.ToString()
