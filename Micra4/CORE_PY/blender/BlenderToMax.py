# Fix __name__ after Thread
__name__ = "__main__"

bl_info = {
    "name": "Send To 3DsMax",
    "author": "MerlinEl",
    "version": (1, 2, 0),
    "blender": (2, 80, 0),
    "description": "Send selected objects in to 3Ds Max Application",
    "warning": "",
    "category" : "Object"
}

import bpy, mcBridge
from mcLoader import Micra_Blender_Dir, MAX_PORT
from mcFile import saveObjectsDataToXML

class SendTo3DsMax(bpy.types.Operator):
    """My Object Moving Script"""       # Use this as a tooltip for menu items and buttons.
    bl_idname = "scene.send_to_3dsmax"  # Unique identifier for buttons and menu items to reference.
    bl_label = "Send To 3DsMax"         # Display name in the interface.

    def execute(self, context):         # execute() is called when running the operator.
        
        xml_file = Micra_Blender_Dir + "\\blender_max_transfer_info.xml"
        fbx_file = Micra_Blender_Dir + "\\blender_max_transfer_scene.fbx"
        
        
#        Save selected objects data in to XML (obj_name, mat_name, parent_name)
        print ("\tSave XML File:\n\t\t{}".format(xml_file))
        objs = bpy.context.selected_objects
        saveObjectsDataToXML(objs, xml_file)

#        Export selected object as FBX
        print ("\tExport FBX File:\n\t\t{}".format(fbx_file))
        bpy.ops.export_scene.fbx(filepath=fbx_file, use_selection=True)
        
#       Send event to Max
        mcBridge.sendMessageToPort({'type':'Export', 'xml':xml_file, 'fbx':fbx_file}, MAX_PORT)
        
        return {'FINISHED'} # Lets Blender know the operator finished successfully.

def register():
    bpy.utils.register_class(SendTo3DsMax)


def unregister():
    bpy.utils.unregister_class(SendTo3DsMax)


# This allows you to run the script directly from Blender's Text editor
# to test the add-on without having to install it.
if __name__ == "__main__":
    register()
    
"""
# The original script
scene = context.scene
for obj in scene.objects:
    obj.location.x += 1.0
    
# The New Script

            for obj in objs:
             print ("\tobj:", obj)
             print ("\tname:", obj.name)
             print ("\tparent:", obj.parent)
             print ("\tmaterial:", obj.active_material)


"""