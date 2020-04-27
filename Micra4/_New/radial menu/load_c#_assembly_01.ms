--> Test
--Load Assemblies
dotNet.loadAssembly (micra.AssemblyDir + "Orien.Tools.dll")
dotNet.loadAssembly (micra.AssemblyDir + "Orien.NetUi.dll")
--Pickup Class
--method 1
cls = dotNet.getType "Orien.Tools.mcMath"
_mcMath = (dotNetClass "System.Activator").CreateInstance cls --create class instance 
cls = dotNet.getType "Orien.Tools.mcString"
_mcString = (dotNetClass "System.Activator").CreateInstance cls --create class instance 
--method 2
cls = dotNet.getType "Orien.NetUi.mcPopUp" 
activator = (dotNetClass "System.Activator")
inst = activator.CreateInstance cls


params = #("Processing geometry calculations", true, true, true)
args = dotNet.ValueToDotNetObject params (dotNetObject "System.Object")
inst.ProgBar
dotNet.getType "Orien.NetUi.McPopUp.ProgBar" 
inst.GetType "Orien.NetUi.McPopUp.ProgBar"
.<System.Type>GetType()
cls.getType "Orien.NetUi.ProgBar"
--< Test


--> Start Here 
Global _mcString = mcDotnet.loadAssembly "Orien.Tools" "Orien.Tools.McString"
Global _mcArray = mcDotnet.loadAssembly "Orien.Tools" "Orien.Tools.McArray"
Global _mcMath = mcDotnet.loadAssembly "Orien.Tools" "Orien.Tools.McMath"

--String Operations
str = "abababaertyfddfkofopersdf"
str.count
_mcString.LastIndexOf str "d"

--Math operations
_mcMath.minMax 100	1	50	--> 50
_mcMath.minMax -1	1	50	--> 1
_mcMath.minMax 100	1	200	--> 100


--PopUp operations NOW!
_mcPopUp = mcDotnet.loadAssembly "Orien.NetUi.dll" "Orien.NetUi.McPopUp.ProgBar" 
params:#("Processing geometry calculations", true, true, true)
Orien.NetUi.mcPopUp
_mcPopUp.ProgBar
progb = mcPopUp.ProgBar("Processing geometry calculations", true, true, true);







--XML operations (load save data) TODO
Global xml = mcDotnet.loadAssembly "Orien.Tools" "Orien.Tools.McXml" params:#(micra.RootDir + "Actions.xml")
showMethods _mcString
showMethods _mcMath
showMethods xml

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

