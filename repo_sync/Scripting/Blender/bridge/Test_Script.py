import bpy
import sys

def main():
    try:
	
		print('INIT 3DsMAX Bridge:')
        # Do stuff
        argv = sys.argv
        argv = argv[argv.index("--") + 1:] # get all args after "--"

		file_loc = argv[0]
		print('Importing File: ', file_loc)
		# imported_object = bpy.ops.import_scene.fbx(filepath=file_loc)
		# obj_object = bpy.context.selected_objects[0] ####<--Fix
		# print('Imported Object: ', obj_object.name)

    except:
        # you could write your error file here
		print('Unable to Import Object: ', file_loc)
main()