import bpy

def sceneFilePath():
	fpath = bpy.context.blend_data.filepath #bpy.data.filepath
	if (len(fpath) == 0): return ["", ""]
	fname = bpy.path.basename(fpath)
	return [fname, fpath]


def scriptFilePath():
    fpath = bpy.context.space_data.text.filepath
    if (len(fpath) == 0): return ["", ""]
    fname = bpy.path.basename(fpath)
    return [fname, fpath]


def importFileFBX(fpath): 
	imported_object = bpy.ops.import_scene.fbx(filepath=fpath)
	print('Importing File: ', imported_object)


"""

importFileFBX ("D:\\!2k_games\\scotch_dev\\exported\\a.fbx")

script_path = scriptFilePath()
print ("SCRIPT:  mame:{}\n\tpath:{}".format( script_path[0], script_path[1] ))

scene_path = sceneFilePath()
print ("SCENE:  mame:{}\n\tpath:{}".format( scene_path[0], scene_path[1] ))
"""