--> Test
--Load Assemblies
dotNet.loadAssembly (micra.AssemblyDir + "Orien.Tools.dll")
dotNet.loadAssembly (micra.AssemblyDir + "Orien.NetUi.dll")
dotNet.loadAssembly (micra.AssemblyDir + "Micra.Star.dll")

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

cls = dotNet.getType "Micra.Tools.Listener"
_mcListener = (dotNetClass "System.Activator").CreateInstance cls --create class instance 
_mcListener.Write ("This message was sended from C#\n")



--cls = dotNet.getType "Micra.Tools.MxGeometryOptimizer"
--_mcGeoOpt = (dotNetClass "System.Activator").CreateInstance cls --create class instance 


_mcGeoOpt = mcCSharp.getClassInstance "Micra.Tools.MxGeometryOptimizer" forceLoad:true
_mcGeoOpt.owner = mcMicraDialog --bind form in to max window
_mcGeoOpt.Show()

--Manager.Unload not works check it in > max 2010
_mcGeoOpt = mcCSharp.getClassInstance "Micra.Tools.CtoMaxTest" --forceLoad:true
_mcGeoOpt.owner = mcMicraDialog --bind form in to max window
_mcGeoOpt.Show()

--Creating a new appdomain
AppDomain =  dotNetClass"System.AppDomain"
CurrentDomain = AppDomain.CurrentDomain
CurrentDomain.FriendlyName
all_assemblies = for a in CurrentDomain.GetAssemblies() collect a
first_assemblies = all_assemblies[1]
for a in all_assemblies do print a.FullName --< GET ALL LOADED ASSEMBLY NAMES
--WUT? Multiple loaded! -- 
/*
"System.IO.Compression.FileSystem, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089"
"Snippets, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null"
"PresentationFramework-SystemXmlLinq, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089"
"Micra.Star, Version=1.0.0.4, Culture=neutral, PublicKeyToken=null"
"Micra.Star, Version=1.0.0.4, Culture=neutral, PublicKeyToken=null"
"Micra.Star, Version=1.0.0.4, Culture=neutral, PublicKeyToken=null"
"Micra.Star, Version=1.0.0.4, Culture=neutral, PublicKeyToken=null"
"Micra.Star, Version=1.0.0.4, Culture=neutral, PublicKeyToken=null"
"MFCM140U, Version=14.25.28508.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a"
"Micra.Star, Version=1.0.0.4, Culture=neutral, PublicKeyToken=null"
"Micra.Star, Version=1.0.0.4, Culture=neutral, PublicKeyToken=null"
"Micra.Star, Version=1.0.0.4, Culture=neutral, PublicKeyToken=null"
"Micra.Star, Version=1.0.0.4, Culture=neutral, PublicKeyToken=null"
"Micra.Star, Version=1.0.0.4, Culture=neutral, PublicKeyToken=null"
"Micra.Star, Version=1.0.0.4, Culture=neutral, PublicKeyToken=null"
*/

/*

            AppDomainSetup domaininfo = new AppDomainSetup {
                ApplicationBase = Path.GetDirectoryName(TbxAssemblyPath.Text)
            };

            MessageBox.Show("ApplicationBase:" + domaininfo.ApplicationBase);

            Evidence adevidence = AppDomain.CurrentDomain.Evidence;

            MessageBox.Show("CurrentDomain:" + AppDomain.CurrentDomain.FriendlyName);

            newDomain = AppDomain.CreateDomain(Domain_Name, adevidence, domaininfo);

            MessageBox.Show("NewDomain:" + newDomain.FriendlyName);

            Type type = typeof(Proxy);
            loader = (Proxy)newDomain.CreateInstanceAndUnwrap(
                type.Assembly.FullName,
                type.FullName
            );
*/





Activator = dotNetClass "System.Activator"
Assembly = dotNetClass "System.Reflection.Assembly"
AssemblyName = dotNetClass "System.Reflection.AssemblyName"
assemName = AssemblyName.GetAssemblyName(micra.AssemblyDir + "Micra.Star.dll")
format "Assembly.FullName:%"  assemName.FullName
ca1 = Assembly.GetCallingAssembly()
ca1.FullName --"3dsmax, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null"
for t in ca1.GetTypes() do print t   --All Runtime Types ex: MaxApp.ManagedAssemblyLoader, Interface17, Bitmap, Point3, Interface, MaxApp.RecentDocument
recent_doc = (ca1.GetType "MaxApp.RecentDocument").Name
Interface17 = ca1.GetType "Interface17"
Interface17.Attributes




ca2 = Assembly.GetAssembly (dotNet.getType "Micra.Tools.CtoMaxTest")
ca2.FullName --"Micra.Star, Version=1.0.0.4, Culture=neutral, PublicKeyToken=null"

Setup = AppDomain.CurrentDomain.SetupInformation
--Create an instance of loader class in new appdomain
--  .[static]<System.AppDomain>CreateDomain <System.String>friendlyName <System.Security.Policy.Evidence>securityInfo <System.AppDomainSetup>info
newDomain = AppDomain.CreateDomain "newDomain" AppDomain.CurrentDomain.Evidence Setup 


/*
//Creating a new appdomain
AppDomainSetup setup = AppDomain.CurrentDomain.SetupInformation;
AppDomain newDomain = AppDomain.CreateDomain("newDomain", AppDomain.CurrentDomain.Evidence, setup); //Create an instance of loader class in new appdomain
System.Runtime.Remoting.ObjectHandle obj = newDomain.CreateInstance(typeof(LoadMyAssembly).Assembly.FullName, typeof(LoadMyAssembly).FullName);
LoadMyAssembly loader = (LoadMyAssembly)obj.Unwrap();//As the object we are creating is from another appdomain hence we will get that object in wrapped format and hence in next step we have unwrappped it
//Call loadassembly method so that the assembly will be loaded into the new appdomain amd the object will also remain in new appdomain only.
loader.LoadAssembly(StrPath);
//Call exceuteMethod and pass the name of the method from assembly and the parameters.
loader.ExecuteStaticMethod(strModule, "MyMethod", new object[] {"girish", "girish });
AppDomain.Unload(newDomain); //After the method has been executed call unload method of the appdomain.
//Wow you have unloaded the new appdomain and also unloaded the loaded assembly from memory.
*/


--method 7
dotNet.loadAssembly (micra.AssemblyDir + "Orien.AssemblyManager.dll")
cls = dotNet.getType "Orien.AssemblyManager.Manager"
_mcAman = (dotNetClass "System.Activator").CreateInstance cls --create class instance 
_mcAman.show()



Global McSetCs = mcCSharp.getClassInstance "Micra.Tools.MxSet" --forceLoad:true
McSetCs.LogLi


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

