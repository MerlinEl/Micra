rollout DragDropOps "LoneRobot Drag Drop" width:136 height:150
 	(	
 
 		dotNetControl btndragdrop "label" pos:[5,5] width:125 height:139 
 				
 		on DragDropOps open do
 		(
 			btndragdrop.text = "Hooray! A Drag/Drop Enabled Label!!! \n\nTo drop a Texturemap, just pass the map path string in the dataobject instead of a max file path. This will also work if draging a map to the material editor"
 			btndragdrop.borderstyle = (dotNetClass "System.Windows.Forms.BorderStyle").fixedsingle	
 			btndragdrop.backcolor = (dotnetclass "System.Drawing.Color").orangered	
 			btndragdrop.forecolor = (dotnetclass "System.Drawing.Color").yellow
 		)
 		on btndragdrop mouseDown sender args do
 		(
 			theIniFile = getdir #maxData  + "3dsmax.ini" 
 			theKeys = getIniSetting theIniFile "FileList" 
 			maxfilearray = for o in theKeys where o != "MaxFiles" collect getIniSetting theIniFIle "FileList" o 
 			intnum = dotnetobject "System.Int32" 0
 			filenamestring= dotnetobject "System.string" maxfilearray[1]
 			dropfile = dotnetobject "System.String[]" 1
 			dropfile.setvalue filenamestring intnum
 			DataObj = dotnetobject "DataObject" ((dotnetclass "DataFormats").filedrop) dropfile
 			sender.dodragdrop Dataobj ((dotnetclass "DragDropEffects").Copy)
 		)
 	)
 	createdialog DragDropOps style:#(#style_toolwindow, #style_sysmenu)

/*
on btndragdrop mouseup sender args do
(

	if (sender.clientrectangle.contains args.x args.y) then (	)
	else
	(			
		theIniFile = getdir #maxData  + "3dsmax.ini" 
		theKeys = getIniSetting theIniFile "FileList" 
		maxfilearray = for o in theKeys where o != "MaxFiles" collect getIniSetting theIniFIle "FileList" o 
		filenameString =  maxfilearray[1]
		dropfile = dotnetobject "System.String[]" 1
		dropfile.setvalue @"\\manager\3D STUFF\IAM\TEST\window001.JPG" 0			
		DataObj = dotnetobject "DataObject" ((dotnetclass "DataFormats").filedrop) dropfile
		sender.dodragdrop Dataobj ((dotnetclass "DragDropEffects").Copy)
		)

)
*/