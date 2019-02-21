TODO 
--check if action is deleted before load button icon
--if is deleted remove registry from * Current Profile * and * Temp Profile *

Profile [buttons]
btn_B2=Move_To_X

Actions [Object]
Move_To_X          = 28, mcAction.object_move_to_grid(),Move To X




	


	--save registred dialogs pos and size to current profile
	fn saveCurrentProfile = (
		--get all registred dialogs
		local dia_names_1 = mcFile.readSettings Micra.UserProfile "Properties_1" type:"keys" --get micra dialogs
		local dia_names_2 = mcFile.readSettings Micra.UserProfile "Properties_2" type:"keys" --get all other dialogs
		--save all visible dialogs to /Profile_.ini
		for n in dia_names_1 do mcFile.saveDialogSettings n "Properties_1"
		for n in dia_names_2 do mcFile.saveDialogSettings n "Properties_2"
		--trace info
		local current_profile_index = mcFile.readSettings Micra.UserSettings "Settings/CurrentProfile"
		local current_profile_name = mcFile.readSettings Micra.UserSettings ("Profiles/menu_"+current_profile_index)
		format "% > saveCurrentProfile > Profile:[%] has been Saved!\n" Micra.version current_profile_name
	)

	"Save":saveCurrentProfile()
	
	local command_names = #("Save", "Manage")


xml = mcXML (Micra.TempDir + "xml_test_01.xml")
	xml.url
	xml.exists()
	itms = xml.getItems "books"
	ch = xml.getChildren() --root children
	mcXML.toString()

xml = mcXML(Micra.TempDir + "xml_test_22.xml")
xml.exists()
xml.create "BOOKS"
xml.toString()

writer = dotNetClass "System.Xml.XmlWriter"
writerSettings = dotNetObject "System.Xml.XmlWriterSettings"
writerSettings.Indent = true
writerSettings.NewLineOnAttributes = true	
writer = writer.Create file writerSettings	
doc.Save writer
writer.Close()



xml = mcXML (Micra.TempDir + "xml_test_01.xml")
xml.toString()
xml.declaration
xml.doc.DocumentElement.OuterXml



 XmlSerializer xsSubmit = new XmlSerializer(typeof(MyObject));
 var subReq = new MyObject();
 var xml = "";

 using(var sww = new StringWriter())
 {
     using(XmlWriter writer = XmlWriter.Create(sww))
     {
         xsSubmit.Serialize(writer, subReq);
         xml = sww.ToString(); // Your XML
     }
 }

  .NewLineChars : <System.String>
  .NewLineHandling : <System.Xml.NewLineHandling>
  .NewLineOnAttributes : <System.Boolean>

settings = dotNetObject "System.Xml.XmlWriterSettings"
settings.Indent = true;
--settings.NewLine = (dotnetClass "Environment").NewLine
XmlWriter = dotNetClass "System.Xml.XmlWriter"
writer = XmlWriter.Create (Micra.TempDir + "xml_test_07.xml") settings
XmlWriter.ToString()
writer.close()
writer.flush()
xml.Save(writer)


stringWriter = dotNetObject "System.IO.StringWriter"
mlTextWriter = XmlWriter.Create stringWriter
mlTextWriter.ToString()

xml = mcXML (Micra.TempDir + "xml_test_01.xml")
xml = mcXML (Micra.TempDir + "xml_test_07.xml")
xml.exists()
xml.fromString (

	"<?xml version='1.0' ?>\n" +
	"<book genre='novel' ISBN='1-861001-57-5'>\n" +
	"\t<title>Pride And Prejudice</title>\n" +
	"</book>"
)
xml.doc.PreserveWhitespace = false
xml.toString()
xml.save()
mcAction.getObjectProps()
 LayerManager.getLayerFromName  "lh_02_little_italy_block_g"
$.layer.name





	--------RECORD DEFORM HELPER CUSTOM ATTRIBUTE DATA TO XML
	fn f_recordPoseNodes myNodes xmlFile=
	(
		dotNet.loadAssembly "system.xml"
		xmlDoc=dotNetObject "system.xml.xmlDocument"
		RootElement=xmlDoc.createElement "DeformHelperPoseSetup"
		RootElement.setAttribute "maxfilepath" ((try(maxfilepath)catch("unsaved")) as string)
		RootElement.setAttribute "maxfilename" ((try(maxfilename)catch("untitled")) as string)
		RootElement.setAttribute "username" (sysInfo.username as string)
		RootElement.setAttribute "localTime" (localTime as string)
		Root_Node=xmlDoc.appendChild RootElement
		for nody in myNodes do
		(
			myNodeElement = xmlDoc.createElement "PoseHelperNode"
			--LS3D_RigData.fn_setElementPropsMatrix nody myNodeElement
			myNodeElement.setAttribute "name" ((nody.name) as string)
			myNodeElement.setAttribute "parent" ((nody.parent.name) as string)
			myNodeElement.setAttribute "myTabSize" (nody.baseobject.mytabsize as string)
			myNodeElement.setAttribute "rb_SelectionType" (nody.baseobject.rb_SelectionType as string)
			lerpNodesString=((nody.baseobject.LerpNodes[1]).name as string)+","+((nody.baseobject.LerpNodes[2]).name as string)
			myNodeElement.setAttribute "LerpNodes" lerpNodesString
		
			for i=1 to nody.baseobject.mytabsize do
			(
				myPoseTargetElement=xmlDoc.createElement "PoseTarget"
				myPoseTargetElement.setAttribute "PoseNames" (nody.baseobject.PoseNames[i] as string)
				myPoseTargetElement.setAttribute "ParentSpaceNodes" (nody.baseobject.ParentSpaceNodes[i].name as string)
				myPoseTargetElement.setAttribute "PoseMatrices" (nody.baseobject.PoseMatrices[i] as string)
				myIndex=i-1
				myName=("PoseBlendValues_"+(myIndex as string)) as name
				--myController=execute ("$.LS3D_PoseHelper_attr[#PoseBlendValues_"+(myIndex as string)+"].controller")
				myController=$.LS3D_PoseHelper_attr[myName].controller
				myPoseTargetElement.setAttribute "PoseControllerClass" ((classof myController) as string)
				
				myType=myController.GetType "myTrack"
				if myType==#object then
				(
					myPoseTargetElement.setAttribute "PoseControllerType" (myType as string)
					myString=(exprForMAXObject (myController.getvalue "mytrack"))
					myPoseTargetElement.setAttribute "myTrack" myString
				)
				else
				(
					myPoseTargetElement.setAttribute "PoseControllerType" (myType as string)
					--myString=(myController.getConstant "mytrack")
					--myPoseTargetElement.setAttribute "myTrack" myString
				)
				
				myPoseTargetElement.setAttribute "Script" ((myController.script) as string)
				
				
				myNodeElement.appendChild myPoseTargetElement
			) 
			Root_Node.appendChild myNodeElement
		)
		xmlDoc.Save (xmlFile)
	),
	
	--Set Up Deformation Helper CA from XML
	fn f_setUpPoseHelperCADefFromXML xmlFile single:false=
	(
		xDoc = dotnetobject "system.xml.xmldocument"	
		xDoc.Load xmlFile
		rootelement = xDoc.documentelement
		(
			RootKids=rootelement.ChildNodes
			for i=0 to (RootKids.count-1) do
			(
				JointElement=RootKids.ItemOf[i]
				DeformHelperNodeName=JointElement.attributes.ItemOf["name"].value
				Format "DeformHelperNodeName=%\n" (DeformHelperNodeName as string)
				
				JointKids=JointElement.ChildNodes
				zerobasedcount=JointKids.count-1
				myNode=getnodebyname DeformHelperNodeName
				
				if myNode!=undefined then
				(
					select myNode
					
					--Remove current attributes and create new Pose Helper Custom Attribute
					--SET LERP TYPE
					LS3D_DeformAttribLib.f_addDeformHelperCA myNode numslots:15
					my_rb_SelectionType=(JointElement.attributes.ItemOf["rb_SelectionType"].value) as integer
					myNode.LS3D_PoseHelper_attr.rb_SelectionType=my_rb_SelectionType
					
					--SET LERP NODES
					myLerpNodes=filterstring (JointElement.attributes.ItemOf["LerpNodes"].value) ","
					myNodeA=getnodebyname myLerpNodes[1]
					myNodeB=getnodebyname myLerpNodes[2]
					if my_rb_SelectionType==2 then
					(
						LS3D_DeformAttribLib.f_AssignLerpingTransformBlendingFloatScript myNode LerpNode1:myNodeA LerpNode2:myNodeB
					)
					else
					(
						LS3D_DeformAttribLib.f_AssignSimpleParentTransformBlendingFloatScript myNode
					)
					poseHelperNodeKids=JointElement.ChildNodes
					for j=0 to (poseHelperNodeKids.count-1) do
					(
						poseTargetElement=poseHelperNodeKids.ItemOf[j]
						myPoseName=(poseTargetElement.attributes.ItemOf["PoseNames"].value)
						--format "PoseNames=%\n" (myPoseName as string)
						myNode.LS3D_PoseHelper_attr.PoseNames[j+1] =myPoseName
						if myPoseName!="undefined" then
						(	
							ParentSpaceNode=poseTargetElement.attributes.ItemOf["ParentSpaceNodes"].value
							--format "ParentSpaceNode=%\n" (ParentSpaceNode as string)
							parentNode=getnodebyname ParentSpaceNode
							if isvalidnode parentNode then
							(
								myNode.LS3D_PoseHelper_attr.ParentSpaceNodes[j+1]=parentNode
							)
							
							myPoseMatrices=execute (poseTargetElement.attributes.ItemOf["PoseMatrices"].value)-- as matrix3
							--format "myPoseMatrices=%\n" (myPoseMatrices as string)
							myNode.LS3D_PoseHelper_attr.PoseMatrices[j+1]=myPoseMatrices
							
							myPoseControllerClass=(poseTargetElement.attributes.ItemOf["PoseControllerClass"].value)
							--format "myPoseControllerClass=%\n" (myPoseControllerClass as string)
							
							myPoseControllerType=(poseTargetElement.attributes.ItemOf["PoseControllerType"].value)
							--format "myPoseControllerType=%\n" (myPoseControllerType as string)
							
							if myPoseControllerType=="object" then
							(
								myCon=myNode.PoseBlendValues[j+1].controller
								myTrack=(poseTargetElement.attributes.ItemOf["myTrack"].value)
								--format "myTrack=%\n" (myTrack as string)
								tarCon=execute myTrack
								myCon.addConstant "myTrack" tarCon
								myCon.script="myTrack.value"
								myCon2=myNode.NormalizedBlendValues[j+1].controller
								myCon2.addConstant "driver_input" tarCon
							)
						)
					)
				)
				else
				(
					format "PoseHelperNode %=undefined!\n" DeformHelperNodeName
				)
			)
		) 

	),
