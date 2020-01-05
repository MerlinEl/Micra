

"""
obj = bpy.context.selected_objects[0]
val = getObjectValue(obj, "active_material.name")           
print ("obj:{}: val:{}".format(obj.name, val))
"""
def getObjectValue(obj, chain_str):
    chain = chain_str.split(".")
    o = obj
    for key in chain:
        if hasattr(o, key):
            o = getattr(o, key)
#            print ("next key:{} val:{}".format(key, o))
        else:
            o = None
            break
#    print ("RETURN key:{} val:{}".format(chain_str, o))
    return o  