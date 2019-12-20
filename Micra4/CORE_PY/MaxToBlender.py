#~ import classes
import mcMax, mcSystem, mcFile

#~ reimport classes while is in progress
from mcFile import reimport
reimport(["mcMax", "mcSystem", "mcFile"])

#~ variables
py_core_dir = mcFile.getPythonCoreDir()
fbx_file = py_core_dir + "\\test_obj_01.fbx"
print ("\tpy_core_dir:{}\n\tfbx_file:{}".format( py_core_dir, fbx_file ))

#~ export selected object as FBX
mcMax.exportSelectionAsFBX (fbx_file)

#~ Bring Blender in to front or open new Instance	
blender_app = mcSystem.getBlenderApp()
if blender_app != None: 
	print ("Bring Blender in to Front")
	blender_app.activate() 
	print ("blender:", blender_app)
else: print ("Blender is not Open")	
	
	
#~ import [ test_obj_01.fbx ] in to Blender	
	#~ blender test.blend -P test.py
	
	
#~ import pymxs
#~ from pymxs import runtime as rt
#~ myfile = 'C:\\Users\\avisd\\Desktop\\Sample+House.skp'
#~ rt.importFile(myfile, using=rt.sketchUp)

#~ https://help.autodesk.com/view/3DSMAX/2017/ENU/?guid=__py_ref_demo_materials_8py_example_html
#~ https://digitalrune.github.io/DigitalRune-Documentation/html/6f749972-9cb2-4274-b283-c327ba45e379.htm