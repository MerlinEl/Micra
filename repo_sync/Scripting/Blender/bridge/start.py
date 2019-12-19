#Ported to blender from "MT Framework tools" https://www.dropbox.com/s/4ufvrgkdsioe3a6/MT%20Framework.mzp?dl=0 
#(https://lukascone.wordpress.com/2017/06/18/mt-framework-tools/)

"""
Created on 13.12.2019
@author: MerlinEl
@Call From 3DsMax Python
"D:\ReneBaca\Blender\v2.81a-win64\bridge\blender_client.py" "D:\ReneBaca\Blender\v2.81a-win64\bridge\start.py"
"""

import sys 
import os 
import bpy 

bridge_path = os.path.dirname(os.path.realpath(__file__))
if bridge_path not in sys.path: sys.path.append(bridge_path) 
print('Bridge dir: ', bridge_path)

# Import FBX 
status = bpy.ops.import_scene.fbx( filepath="Test_Object.FBX" ) 
obj_object = bpy.context.selected_objects[0]
print('Imported Success: [', status == {'FINISHED'}, '] Object Name: [', obj_object.name + " ]")
		
# Save blend file bpy.ops.wm.save_mainfile( "D:\test.html" )



"""
print("Registred system paths")
print('C Importing File: ', sys.path)

print("Path at terminal when executing this file")
print(os.getcwd() + "\n")

print("This file path, relative to os.getcwd()")
print(__file__ + "\n")

print("This file full path (following symlinks)")
full_path = os.path.realpath(__file__)
print(full_path + "\n")

print("This file directory and name")
path, filename = os.path.split(full_path)
print(path + ' --> ' + filename + "\n")

print("This file directory only")
print(os.path.dirname(full_path))
"""
