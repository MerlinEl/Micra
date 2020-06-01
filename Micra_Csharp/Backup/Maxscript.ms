

fn loadAssembly dll_name class_name params:#() forceLoad:false = (
	
	local cls = dotNet.getType class_name  --pickup class from memory
	if cls == undefined or forceLoad do (  --if dll is not loaded 
		
		dotNet.loadAssembly (micra.AssemblyDir + dll_name + ".dll") --load dll in to memory
	)
	cls = dotNet.getType class_name  --pickup class from memory
	if cls == undefined do return undefined
	local activator = (dotNetClass "System.Activator")
	try (
		if params.count == 0 then (
			
			activator.CreateInstance cls --create class instance
		) else (
			
			local args = dotNet.ValueToDotNetObject params (dotNetObject "System.Object")
			activator.CreateInstance cls args
		)
	) catch (format "Unable to init Class:%\n\t%\n" class_name (getCurrentException()))
)

--TEST--->
dotNet.loadAssembly (micra.AssemblyDir + "Orien.Tools.dll") --load dll in to memory
cls = dotNet.getType "Orien.Tools.mcMath"
_mcMath = (dotNetClass "System.Activator").CreateInstance cls --create class instance 

cls = dotNet.getType "Orien.Tools.mcString"
_mcString = (dotNetClass "System.Activator").CreateInstance cls --create class instance 
--TEST<---


Global _mcString = loadAssembly "Orien.Tools" "Orien.Tools.mcString"
Global _mcArray = loadAssembly "Orien.Tools" "Orien.Tools.mcArray"
Global _mcMath = loadAssembly "Orien.Tools" "Orien.Tools.mcMath"
Global xml = loadAssembly "Orien.Tools" "Orien.Tools.mcXml" params:#(micra.RootDir + "Actions.xml")

showMethods _mcString
showMethods _mcMath
showMethods xml


str = "abababaertyfddfkofopersdf"
str.count
_mcString.LastIndexOf str "d"


_mcMath.minMax 100	1	50	--> 50
_mcMath.minMax -1	1	50	--> 1
_mcMath.minMax 100	1	200	--> 100

--READ - WRITE XML


--Get Multiple Nodes from path
xml_nodes_list = xml.GetNodes "/ACTIONS/Object"
string_aqn = (dotNet.getType "Orien.Tools.MaxXmlNode").AssemblyQualifiedName
type = dotnetobject ("System.Collections.Generic.List`1[[" + string_aqn + "]]")
xml_nodes = dotnet.ValueToDotNetObject xml_nodes_list type
for i = 0 to xml_nodes.count - 1  do (
	
	local max_xml_node = xml_nodes.item[i]
	format "body:%\n" max_xml_node.Body
-- 	format "name:%\n" max_xml_node.Name
-- 	format "icon:%\n" (max_xml_node.GetAttribute "icon")
-- 	format "url:%\n" (max_xml_node.url)
)

--Get Single Node from path
net_xml_node = xml.GetNode "/ACTIONS/Object/Clone_2"
net_xml_node.url --get current node path
net_xml_node.Text --get node text
net_xml_node.Text ="45654" --add - replace text
net_xml_node.GetAttribute "icon"
net_xml_node.SetAttribute "icon" "89"
net_xml_node.GetAttribute "abcd" --undefined
net_xml_node.SetAttribute "abcd" "123" --add - replace attribute
net_xml_node.Body --"<Clone_2 icon="62" cmd="mcFile.fileInVersion Clone2" tooltip="Clone 2" abcd="123">45654</Clone_2>"
net_xml_node.Parent.Name --Object
xml.Save()

