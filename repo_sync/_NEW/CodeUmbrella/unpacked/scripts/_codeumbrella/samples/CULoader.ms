/*
//    CodeUmbrella.CULoader 
//    Ultimate sandbox .NET plugin loader
//    version 1.01f / created by UNU
//    http://codeumbrella.weebly.com
//
//    This product is free to use in non-commercial projects.
//    If you plan to distribute this product in a FREE to download project, 
//    author of this product shall be credited in each distribution. 
//
//    If you like this tool, donate so we can make it better
//    If you want to distribute CodeUmbrella.CULoader in commercial projects
//    for all information how to obtain a licence, get more features
//    and support, send an inquiry via 
//    http://codeumbrella.weebly.com/contact
//    
*/

fn startCodeUmbrellaLoader =
(
  local Assembly = dotNetClass "System.Reflection.Assembly"
  local maxroot = pathConfig.GetDir #maxroot
  Assembly.LoadFrom (maxroot + "\\CULoader.dll")
  global CULoader = dotNetObject "CodeUmbrella.CULoader"
  CULoader.enableDispatcher=false
)

if CULoader==undefined do startCodeUmbrellaLoader()

rollout CULoaderUI "CULoader" width:130 height:180
(
	button btn1 "Load .NET plugin" pos:[8,14] width:113 height:33
	button btn2 "Call a function" pos:[8,53] width:113 height:33
	button btn3 "List loaded assemblies" pos:[7,93] width:113 height:33
	button btn4 "Unload all" pos:[8,135] width:113 height:33
	
	on CULoaderUI open do 
	(
		if CULoader==undefined do startCodeUmbrellaLoader()
	)
	on btn1 pressed do
	(
		CULoader.loadNETLib "myVBPlugin.dll"  "myVBPlugin" 
	)
	on btn2 pressed do
	(
	  libraryID=CULoader.getLibByName "myVBPlugin.dll"
	  print libraryID	
	  if libraryID!=-1 do 
	  (
		  
		  netLIB=CULoader.libraryList.item(libraryID)
		  returnValue = CULoader.callFunction netLIB "giveMeRandomStuff" #()
		  print ((returnValue as string) + " : " + (classOf returnValue) as string )
		  try(CULoader.callFunction netLIB "createSimpleBox" #())catch(print (getCurrentException()))
		  returnvalue=undefined
		  gc()
		
		  
	  )
	)
	on btn3 pressed do
	(
		CULoader.listLoadedAssemblies()
	)
	on btn4 pressed do
	(
		CULoader.unloadAllNETLibs()
	)
)
createDialog CULoaderUI

fn loadPlugin scriptName className funcName params:#() =
(
	local retVal = ""
	CULoader.enableDispatcher=false
	CULoader.loadNETLib scriptName className
	local libraryID = CULoader.getLibByName scriptName
	if libraryID != -1 do 
	(
	  netLIB = CULoader.libraryList.item(libraryID)
	  retVal = CULoader.callFunction netLIB funcName params	  
	)
	CULoader.unloadAllNETLibs()
    return retVal
)
loadPlugin "myVBPlugin.dll" "myVBPlugin" "createSimpleBox"