
import bpy
import sys

def main():
    try:
        # Do stuff
        argv = sys.argv
        argv = argv[argv.index("--") + 1:] # get all args after "--"

        obj_out = argv[0]

        bpy.ops.export_scene.obj(filepath=obj_out, axis_forward='-Z', axis_up='Y', use_animation=1, keep_vertex_order=1, use_normals=1, use_materials=0)
        O.wm.quit_blender()

    except:
        # you could write your error file here

        # exit blender
        sys.exit(1)
        O.wm.quit_blender()
main()