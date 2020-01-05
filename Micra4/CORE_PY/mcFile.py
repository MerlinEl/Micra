import sys, MaxPlus	

# if 'mcFile' in sys.modules:  del sys.modules["mcFile"]
# from mcFile import reimport
# reimport (["mcMax"])
def reimport(cls_arr):
	for str in cls_arr:
		# print ("Is class {} loaded:{}".format (str, str in sys.modules))
		if str in sys.modules:
			#~ print ("is changed:", is_changed(mcMax))
			#~ print ("references count:", sys.getrefcount(str))
			del sys.modules[str]
			print ("Reimport class:", str)
		else: print ("Import class:", str)
		exec  ("import " + str)
		#~ importlib.import_module(str)

def getPythonCoreDir():
	result = MaxPlus.FPValue()
	evaluation_success = MaxPlus.Core.EvalMAXScript('micra.CorePyDir', result)
	dir = result.Get().rstrip('\\') #remove last slash
	return dir

def getBlenderAppPath():
	result = MaxPlus.FPValue()
	evaluation_success = MaxPlus.Core.EvalMAXScript('mcFile.readSettings Micra.UserSettings "Settings/BlenderAppPath"', result)
	dir = result.Get().rstrip('\\') #remove last slash
	return dir
	
def getFileName(fpath):
	return os.path.basename(fpath)
			
# fpath = getPythonCoreDir() + '\\blender\\blender_max_transfer_info.xml'
# print("XML DATA:\n\t{}".format( getDataFromXml(fpath, "name") ))
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
	from mcPoly import isGeometryClass
	root = Element("root")
	children = []
	for o in objs:
		if isGeometryClass(o):
			# print ("obj:{}\n\tmat:{}\n\tparent:{}".format(o.Name, o.Material, o.Parent.Name))
			children.append(
				Element('item', 
					name=o.Name,
					parent=o.Parent.Name if o.Parent.Name != "Scene Root" else "None",
					material=o.Material.GetName() if o.Material else "None"
				)
			)
	root.extend(children) #~ add children in to root node
	root = fromstring(prettify(root)) #~format xml
	ElementTree(root).write(fpath, encoding="UTF-8", method="xml")
	
# create loader file for Blender	
def createLoaderForBlender(dir, max_port, blender_post):
	str = "import sys\n"
	str += "Micra_Blender_Dir = '"+dir.replace("\\", "\\\\")+"'\n"
	str += "MAX_PORT = "+max_port+"\n"
	str += "BLENDER_PORT = "+blender_post+"\n"
	str += "#~ add Micra Core Python Dir in to system paths( if need )\n"
	str += "def register():\n"
	str += "\tif Micra_Blender_Dir not in sys.path:\n"
	str += "\t\tprint ('Register Micra Python CORE Dir:', Micra_Blender_Dir)\n"
	str += "\t\tsys.path.append(Micra_Blender_Dir)\n"
	str += "\t\t# start Blender Server at Thread\n"
	str += "\t\tprint ('Init Bridge at:', BLENDER_PORT)\n"
	str += "\t\tfrom mcBridge import ServerThread\n"
	str += "\t\tthread = ServerThread(BLENDER_PORT)\n"
	str += "\t\tthread.start()\n"
	str += "\t\t# wait 2 sec and register Script Command\n"
	str += "\t\tfrom mcThread import RegisterScript\n"
	str += "\t\tthread = RegisterScript(Micra_Blender_Dir, 'BlenderToMax.py', 2)\n"
	str += "\t\tthread.start()\n"
	str += "\telse:\n"
	str += "\t\tprint ('Micra Core Python Dir was already Registred.')\n\n"	
	str += "if __name__ == '__main__':\n"
	str += "\tregister()"
	fpath = dir + "\\mcLoader.py"
	f = open(fpath, "w")
	f.write(str)
	f.close()
	
def importFileFBX(fpath): 
	# imported_object = bpy.ops.import_scene.fbx(filepath=fpath)
	print('Importing File: ', imported_object)

def deleteObjects(obj_names):
	print ("deleteObjects > objs:", obj_names)
	#unselect everything
	# bpy.ops.object.select_all(action='DESELECT')
	# select only object from list.
	# for o in bpy.data.objects:
		# if o.type == 'MESH' and o.name in obj_names:
			# print ("delete object:{} obj:{}", o.name, o)
			# bpy.data.objects.unlink(o)
			# bpy.data.objects.remove(o)

def importFileFBXReplace(fbx_path, xml_path): 
	print ("Read XML File:\n\t", xml_path)
	obj_names = getDataFromXml(xml_path, "name")
	print("Delete old Objects:\n\t{}".format(obj_names))
	deleteObjects(obj_names)
	print ("Import FBX File:\n\t", fbx_path)
	importFileFBX(fbx_path)
	
"""
from imp import reload
def reimport(cls_str):
	if cls_str in sys.modules:
		print ("reload " + cls_str)
		del sys.modules[cls_str]
	else:
		print ("import " + cls_str)
	exec  ("import " + cls_str)
		
from imp import reload
from importlib import reload
if is_changed(foo):
reload(mcMax)		
		
from imp import reload
reload(mcMax)
mcMax.exportSelectionAsFBX ("c:\\temp\\test_export.fbx")		
"""