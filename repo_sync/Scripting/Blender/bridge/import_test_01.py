import bpy
file_loc = "D:\\!2k_games\\scotch_dev\\exported\\a.fbx"
imported_object = bpy.ops.import_scene.fbx(filepath=file_loc)
print('Importing File: ', imported_object)