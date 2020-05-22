--> Test
--Final Method
dotNet.loadAssembly (micra.AssemblyDir + "Micra.Domain.dll")
cls = dotNet.getType "Micra.Domain.MxDomain"

--Micra.Domain.MxDomain <System.String>domain_name
dnArgs=dotNet.ValueToDotNetObject #("Micra_Domain") (dotNetClass "System.Object")
Global MxDomain = (dotNetClass "System.Activator").CreateInstance cls dnArgs --create custom domain
--Global MxDomain = (dotNetClass "System.Activator").CreateInstance cls "Micra_Domain" --create custom domain (not works)
MxDomain.ShowUi(mcMicraDialog) --show form with owner MicraForm

MxDomain.LoadAssembly(micra.AssemblyDir + "Micra.Star.dll") --load assembly in this domain --TODO return null , should be Loader
MxDomain.ShowLoadedAssemblies() --print all loaded assemblies from this domain

asm = MxDomain.GetLatestAssembly "Micra.Star" --get latest version assembly reference from this domain

if (asm != undefined) do format "Assembly % loaded." asm.FullName
	
	asm.Location
	asm.FullName
	asm.IsFullyTrusted
	asm.GetReferencedAssemblies()
	asm.GetExportedTypes()
	asm.GetLoadedModules()
	asm.GetModules()
s = (dotnetClass "System.String").Join "\n" (asm.GetTypes())

	
--Get Class Instance 1
cls = asm.getType "Micra.Tools.MxGet"
_mcGet = (dotNetClass "System.Activator").CreateInstance cls --create class instance 
_mcGet.MicraRootDir
	
cls = asm.getType "Orien.Tools.McArray" --get latest version assembly reference from this domain
cls = asm.getType "Micra.Tools.Listener"	
_mcListener = (dotNetClass "System.Activator").CreateInstance cls --create class instance 
_mcListener.Write ("This message was sended from C#\n")
	
	
--Get Class Instance 2 (not accesible for now)
cls = asm.getType "Orien.Tools.McMath"
_mcMath = (dotNetClass "System.Activator").CreateInstance cls --create class instance 
--Math operations
_mcMath.minMax 100	1	50	--> 50
_mcMath.minMax -1	1	50	--> 1
_mcMath.minMax 100	1	200	--> 100
	

fn ReloadAllAssemblies = (
	MxDomain.DestroyDomain() --destroy custom domain
	MxDomain = (dotNetClass "System.Activator").CreateInstance cls "Micra_Domain" --create custom domain
	MxDomain.LoadAssembly(micra.AssemblyDir + "Micra.Star.dll") --load assembly in this domain
	MxDomain.LoadAssembly(micra.AssemblyDir + "?.dll") --load assembly in this domain
	MxDomain.LoadAssembly(micra.AssemblyDir + "?.dll") --load assembly in this domain
)
	
	
McGetCs
McSetCs

show MxDomain
showMethods MxDomain

--method 8
Global McGetCs = mcCSharp.getClassInstance "Micra.Tools.MxGet" forceLoad:true --one force is enough for reload
Global McSetCs = mcCSharp.getClassInstance "Micra.Tools.MxSet" forceLoad:true --one force is enough for reload

--TODO This will load latest DLL , but without force, Max wil  next time take OLD one
_mcCsharpToMaxTest = mcCSharp.getClassInstance "Micra.Tools.CtoMaxTest" forceLoad:true --one force is enough for reload
_mcCsharpToMaxTest.owner = mcMicraDialog --bind form in to max window
_mcCsharpToMaxTest.Show()






--method 7
dotNet.loadAssembly (micra.AssemblyDir + "MyAssembly.dll")
cls = dotNet.getType "MyAssembly.AssemblyUI"
_mcAman = (dotNetClass "System.Activator").CreateInstance cls --create class instance 
_mcAman.owner = mcMicraDialog --bind form in to max window
_mcAman.show()

_mcAman.loader
_mcAman.newDomain.FriendlyName
_mcAman.newDomain.GetAssemblies()

--incerase assembly version
ms = _mcAman.newDomain.GetAssembly "Micra.Star"
cls = ms.GetTYpe "Micra.Tools.CtoMaxTest"
_mcGeoOpt = (dotNetClass "System.Activator").CreateInstance cls --create class instance 
_mcGeoOpt.owner = mcMicraDialog --bind form in to max window
_mcGeoOpt.Show()


_mcGeoOpt.GetLatestAssembly "Micra.Star"


---------------------------------------
---------------------------------------
McGetCs.GetAllAssemblies()
assembly_path = micra.AssemblyDir + "Micra.Star.dll" ---Wictory :D tadaaaaaaaaa
McGetCs.ReloadAssembly assembly_path
asm = McGetCs.GetLatestAssembly "Micra.Star"
asm.FullName
cls = asm.GetType "Micra.Tools.MxGet" 
McGetCs = (dotNetClass "System.Activator").CreateInstance cls --create class instance 
McGetCs
---------------------------------------
---------------------------------------




assembly_path = micra.AssemblyDir + "Micra.Star.dll"
AssemblyName = dotNetClass "System.Reflection.AssemblyName"
assem_name = AssemblyName.GetAssemblyName(assembly_path)
format "Assembly.FullName:%\n" assem_name.FullName --print ddl name and version
assembly_bytes = (dotnetClass "System.IO.File").ReadAllBytes assembly_path
assembly = (dotnetClass "System.Reflection.Assembly").Load assembly_bytes

cls = dotNet.getType "Micra.Tools.CtoMaxTest"
_mcGeoOpt = (dotNetClass "System.Activator").CreateInstance cls
_mcGeoOpt.owner = mcMicraDialog --bind form in to max window
_mcGeoOpt.Show()


gc()
_mcAman.GC()



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



--method 3
cls = dotNet.getType "Orien.Tools.mcMath"
_mcMath = (dotNetClass "System.Activator").CreateInstance cls --create class instance 
--Math operations
_mcMath.minMax 100	1	50	--> 50
_mcMath.minMax -1	1	50	--> 1
_mcMath.minMax 100	1	200	--> 100





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


--Manager.Unload not works check it in > max 2010
_mcGeoOpt = mcCSharp.getClassInstance "Micra.Tools.CtoMaxTest" forceLoad:true
_mcGeoOpt.owner = mcMicraDialog --bind form in to max window
_mcGeoOpt.Show()

--cls = dotNet.getType "Micra.Tools.MxGeometryOptimizer"
--_mcGeoOpt = (dotNetClass "System.Activator").CreateInstance cls --create class instance 


_mcGeoOpt = mcCSharp.getClassInstance "Micra.Tools.MxGeometryOptimizer" forceLoad:true
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



--C:\Program Files\Autodesk\3ds Max 2018\Autodesk.Max.dll
--D:\ReneBaca\Aprog\Micra\Micra4\Assembly\Micra.Star.dll
_mcAman.newDomain.FriendlyName
ta = _mcAman.loader.TrustedAssembly
ta.FullName
ta.Location
ta.CodeBase

  .<System.Object>CreateInstance <System.String>typeName


--public object ExecuteStaticMethod(string className, string methodName, params object[] parameters) {
args = dotNet.ValueToDotNetObject #(100, 1 ,50) (dotNetObject "System.Object")
_mcAman.loader.ExecuteStaticMethod "Orien.Tools.mcMath" "minMax" args
_mcAman.appDomain.getType "Orien.Tools.McString"



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

