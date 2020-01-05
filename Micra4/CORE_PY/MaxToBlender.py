#~ import classes
import mcMax, mcSystem, mcFile, MaxPlus, mcBridge
from mcLoader import BLENDER_PORT

#~ reimport classes while is in progress
from mcFile import reimport
reimport(["mcMax", "mcSystem", "mcFile"])

def sendSelectionToBlender(objs):
	#~ selection check
	if objs.GetCount() == 0:
		print ("Nothing is selected for Export.")
		return False
	print ("Process ({})Objects:".format(objs.GetCount()))	
	#~ variables
	py_core_dir = mcFile.getPythonCoreDir()
	xml_file = py_core_dir + "\\blender\\blender_max_transfer_info.xml"
	fbx_file = py_core_dir + "\\blender\\blender_max_transfer_scene.fbx"
	
	#~ Save selected objects data in to XML (obj_name, mat_name, parent_name
	mcFile.saveObjectsDataToXML(objs, xml_file)
	print ("\tSave XML Data:\n\t\t{}".format(xml_file))

	#~ Export selected object as FBX
	print ("\tExport FBX File:\n\t\t{}".format(fbx_file))
	mcMax.exportSelectionAsFBX (fbx_file)
	
	#~ Bring Blender in to front or open new Instance	
	blender_app = mcSystem.getBlenderApp()
	if blender_app != None: 
		print ("Bring {} in to Front".format(blender_app.title))
		blender_app.activate()
	else: 
		print ("Blender is not Open.")
		import os
		blender_app_path = mcFile.getBlenderAppPath()
		if os.path.isfile (blender_app_path): 
			print ("Try To start Blender App:\n\t", blender_app_path)
			os.startfile(blender_app_path)
	
	#~ Wait for Blender app is open(if not)
	if blender_app == None:
		import time
		time.sleep(3)
		
	#~ Send event to Blender
	mcBridge.sendMessageToPort({'type':'Export', 'xml':xml_file, 'fbx':fbx_file}, BLENDER_PORT)

#~ EXECUTE
sendSelectionToBlender(MaxPlus.SelectionManager.GetNodes())
	
	
	
#~ sendMessageToPort({'type':'quit'}, BLENDER_PORT) 
#~ print ("\tparent:{}".format( o.GetNumChildren()))