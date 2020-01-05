
import bpy

sel_objs = bpy.context.selected_objects
print ("sel_objs:", sel_objs)

sel_names = [obj.name for obj in sel_objs]
print ("sel_names:", sel_names)

obj = sel_objs[0]
print ("obj:", obj.name)
obj_parent = obj.parent
print ("parent:", obj_parent)
obj_mat = obj.active_material
#print ("material:", obj_mat.name)

print ("\n\n")



from mcColl import getObjectValue
    
obj_1 = bpy.context.selected_objects[0]        
val = getObjectValue(obj_1, "active_material.name")           
print ("obj:{}: val:{}".format(obj_1.name, val))


obj_2 = bpy.context.selected_objects[1] 
obj_2.parent = obj_1
val = getObjectValue(obj_2, "parent.name")           
print ("obj:{}: val:{}".format(obj_2.name, val))