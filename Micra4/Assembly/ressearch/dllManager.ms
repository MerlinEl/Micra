

(
	try(dllManager.closeMe())catch()
	/*
	
	dllManager.ms
	version : v 0.1
	author: Logan Bender <loganb@blarg.net>
	update: Feb 26 2014
	
	history:
		2.26.2014
			bug fix in dllManager.instantiate
		2.25.2014 
			added ability to instantiate a Class with parmaters.

	puropose:
	
		dllManager is a simple dialog to help iterate on compiled dll C# class libraries & easily reload your DLL in 3DS Max  as you work.
		Now you don't have to restart 3DSMax because you can't 'unload' a compiled dll loaded via dotNet.Loadassembly.
	
	usage: 
	
		paste script into Max Script Editor and evaluate.
		double click on the DLL displayed to load a new one
		click 'reload' Dll after each C# compile
	
	IMPORTANT:  
		to instantiate your class, avoid the dotNetObject Max Script command, instead use:

		dllManager.instantiate "MyClass.MyObject" [args:< mxs array> ]
		args is optional 
		
		to call method class, avoid the dotNetClassMax Script command, instead use:

		dllManager.callMethod "MyNamespace.MyClass.MyMethod()" [args:< mxs array> ]
			
			
	the techniques used here are taken from  this CG Talk thread
		http://forums.cgsociety.org/showthread.php?p=7758871#post7758871
		any issue you have might best be posted there.
	
	*/
	
	struct dllManager(
		dialog,
		ro_dllManager,
		assembly,
		activator = dotNetClass "System.Activator",
		verbose=true,
		dllPath="",
		settingsFile=(getDir #userScripts)+"\dllManager_settings.ini",
		
		/* read settings from 3dsMax.ini and populate dllManager.dllPath
		if no settings file is  found, dllManager.dllPath is a string to prompt the user  */
		fn readSettings =(
			local iniFile=getfilenamePath ( getMaxIniFile())+"dllManager.ini"
			if (hasINISetting  iniFile "dllManager" "dllPath")then
			(
				dllManager.dllPath=(getINISetting iniFile "dllManager" "dllPath")
			)else(
				dllManager.dllPath="double click to load a dll.."
			)
			dllManager.updateUI()
		),
		
		/* 	save dllManager.dllPath value for next session  */
		fn writeSettings=(
			local iniFile=getfilenamePath ( getMaxIniFile())+"dllManager.ini"
			setINISetting iniFile "dllManager" "dllPath" dllManager.dllPath	
		),
	
		--generic browse for a file fn
		fn browseFile fPath:maxfilepath ext:"*.*" =
		(
			local fType = @"(*." + ext +@")|*." + ext
			filePath=(getOpenFileName caption:"choose a file..." filename: fPath types: fType)
			return filePath
		),
		
		
		--fn to convert windows environment variables like %userProfile% in this case
		fn expandFilePath filePath=(
			return (dotnetclass "System.Environment").expandEnvironmentVariables filePath
		),
		
		--bowse for dllManager.dllPath, update settingsFile wiuth new dll
		fn browseDll=(
			dllManager.dllPath=dllManager.browseFile  fPath:(dllManager.expandFilePath "%userProfile%/") ext:"*.*"
			format "dllManager.dllPath: %\n" dllManager.dllPath
			dllManager.writeSettings()
		),
			
		fn updateUI=
		(
			dllManager.ro_dllManager.lb_dll.items=#((getfilenamefile dllManager.dllPath))
		),
		
		/*
			Load the DLL
			this is the trick that makes the DLL reload-able
			instead of dotnet.loadAssembly, which locks the DLL as 'in use' while Max is running and prevents Visual Studio from compiling,
			we recreate the Assembly on the fly by reading the file bytes via System.IO.File, leaving the actuall DLL file 'unused'.
			now Visual Studio can compile unhindered. Win!
		*/
		fn newDll=(
			
			dllManager.assembly = (dotnetClass "System.Reflection.assembly").Load ((dotnetClass "System.IO.File").ReadAllBytes dllManager.dllpath)
			dllManager.updateUI()
		),
		
		
		fn reload=(
			if doesFileExist dllManager.dllPath then
			(
				format"\t( dllManager.reload()...)\n"
				dllManager.newDll()
				dllManager.showDll()
				dllManager.assembly
			)else(
				local str= dllManager.dllPath+" not found."
				messagebox (str) title:"(dllManager.reload())"
			)
		),

		--display DLL Classes in listener
		fn showDll=(
			local theTypes = dllManager.assembly.GetExportedTypes()
			if dllManager.verbose then
			(
				for t in theTypes do
				(
					format "TYPE: \"%\"\n" t.Fullname
					theObj = try(dotNetObject t.FullName)catch(dotNetClass t.fullname)
					format "\tCONSTRUCTORS:\n"
					dotNet.showConstructors theObj
					format "\tPROPERTIES:\n"
					showProperties theObj
					format "\tMETHODS:\n"
					showMethods theObj
					format "\tEVENTS:\n"
					showEvents theObj
					format "\n\n"
				)
			)
		),

		/*
			create an instance of a class , optionally display the members of the class 
			instead of dotNetObject or dotNetClass we must use the C# method Assembly.CreateInstance
		*/

		fn instantiate className args:#() =(
			local dnArgs=dotNet.ValueToDotNetObject args (dotNetClass "System.Object")--convert Args#() to System.Object[]
			local dotNetType=dllManager.assembly.GetType(className) --get Type of className as a dot Net value
 			format "args:%\n" args
 			format "dnArgs.Length : %\n" dnArgs.Length
			inst=dllManager.activator.CreateInstance dotNetType dnArgs
/* 			if dnArgs.Length >0 then(
				format "instantiate Class with args...\n" dnArgs.Length
				inst=dllManager.activator.CreateInstance dotNetType dnArgs
			)else(
				inst=dllManager.activator.CreateInstance dotNetType
			) 
*/
			if dllManager.verbose then (
				format "% Events:\n" className
				dotNet.showConstructors inst
				format "% Properties:\n" className
				showProperties inst
				format "% Methods:\n" className
				showMethods inst
				format "% Events:\n" className
				showEvents inst
			)
			return inst
		),
		
		fn callMethod staticMethodName args:#()=( 
			local dnArgs=dotNet.ValueToDotNetObject args (dotNetClass "System.Object")--convert Args#() to System.Object[]
			if (dnArgs.Length==0) then ( dnArgs=undefined )
			local slices= (filterstring staticMethodName ".")
			local methodName= substitutestring slices[slices.count] "()" ""
			local className=substring staticmethodName 1 ((findstring staticmethodName methodName)-2)
			local type=dllManager.assembly.GetType(className)
			local dnMethod=type.GetMethod(methodName)
			format "%.%"className methodName
			dnMethod.Invoke undefined dnArgs
		),
		--UI
		fn closeMe=try(DestroyDialog ro_dllManager)catch(),
		
		fn show =(
			dllManager.closeMe()
			dllManager.ro_dllManager=rollout ro_dllManager "DLL Manager" width:500
			(
				label l_0 "DLL file ( double click to change)" align:#left across:2
				checkbox cb_verbose "verbose" checked:dllManager.verbose align:#right
				
				listbox lb_dll items:#(dllManager.dllPath) height:1
				button btn_reload "reload DLL"   height:30 width:380 --across:2 align:#left
				--button btn "close"  height:30  align:#right
				group "note"(
					label l_1 "to instantiate objects use the command:" ALIGN:#LEFT
					label l_2 "MyObject=dllManager.instantiate \"MyClass.MyObject\" [args:<mxs array>]"
					label l_3 "to call a static class method, use the command:" ALIGN:#LEFT
					label l_4  "dllManager.callMethod \"MyNameSpace.MyStaticClass.MyFunction()\" [args:<mxs array>]"
				)
				on btn pressed do
				(
					closeMe()
				)
				 
				on cb_verbose changed state do(
					
					dllManager.verbose = state
					format "dllManager.verbose:%\n" dllManager.verbose
					
				)
				
				on lb_dll doubleClicked i do
				(
					dllManager.browseDll()
					dllManager.newDll()
					dllManager.reload()
				)
				
				on btn_reload pressed do
				(
					dllManager.reload()
				)
				
				--load settings on open 
				on ro_dllManager open do dllManager.readSettings()
				
			)
			dllManager.dialog=createdialog ro_dllManager modal:false
		)
	)
	
	dllManager=dllManager()
	dllManager.show()
	dllManager
)