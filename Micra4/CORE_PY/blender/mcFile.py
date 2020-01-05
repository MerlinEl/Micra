import bpy, os

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

def getFileName(fpath):
	return os.path.basename(fpath)

def deleteObjects(obj_names):
	#unselect everything
	bpy.ops.object.select_all(action='DESELECT')
	# select only object from list.
	for o in bpy.data.objects:
		if o.type == 'MESH' and o.name in obj_names:
			# print ("delete object:{} obj:{}", o.name, o)
			# bpy.data.objects.unlink(o)
			bpy.data.objects.remove(o)

def getDataFromXml(xml_path, type):
	from xml.dom import minidom
	mydoc = minidom.parse(xml_path)
	items = mydoc.getElementsByTagName('item')
	data = []
	for elem in items:
		data.append(elem.attributes[type].value)
	return data
	
def saveObjectsDataToXML(objs, fpath):
    from xml.etree.ElementTree import Element, ElementTree, fromstring
    from ElementTree_pretty import prettify
    from mcColl import getObjectValue
    root = Element("root")
    children = []
    for o in objs:
        # print ("obj:{}\n\tmat:{}\n\tparent:{}".format(o.Name, o.Material, o.Parent.Name))
        children.append(
            Element('item', 
                name=str(getObjectValue (o, "name")),
                parent=str(getObjectValue (o, "parent.name")),
                material=str(getObjectValue (o, "active_material.name"))
            )
        )
    root.extend(children) #~ add children in to root node
    root = fromstring(prettify(root)) #~format xml
    print ("saveObjectsDataToXML > Root:\n\t", root)
    ElementTree(root).write(fpath, encoding="UTF-8", method="xml")	
	
def importFileFBX(fpath): 
	imported_object = bpy.ops.import_scene.fbx(filepath=fpath)
	print('Importing File: ', imported_object)

def importFileFBXReplace(fbx_path, xml_path): 
	print ("Read XML File:\n\t", xml_path)
	obj_names = getDataFromXml(xml_path, "name")
	print("Delete old Objects:\n\t{}".format(obj_names))
	deleteObjects(obj_names)
	print ("Import FBX File:\n\t", fbx_path)
	importFileFBX(fbx_path)


"""

importFileFBX ("D:\\!2k_games\\scotch_dev\\exported\\a.fbx")

script_path = scriptFilePath()
print ("SCRIPT:  mame:{}\n\tpath:{}".format( script_path[0], script_path[1] ))

scene_path = sceneFilePath()
print ("SCENE:  mame:{}\n\tpath:{}".format( scene_path[0], scene_path[1] ))
"""