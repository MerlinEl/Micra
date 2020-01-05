import mcFile
from mcFile import reimport, getBlenderAppPath, getPythonCoreDir
reimport(["mcFile"])

dir = getBlenderAppPath()
fpath = getPythonCoreDir() + '\\blender\\blender_max_transfer_info.xml'
print ("Blender App Path:\n\t{}\nXML File Path:\n\t{}".format(dir, fpath))


#~ import xml.etree.ElementTree as ET
#~ tree = ET.parse(fpath)
#~ root = tree.getroot()

#~ for child in root:
	#~ print child.tag, child.attrib
	

#~ obj_names =  {k: v for k, v in vars(namespace).items() if v is not None}
#~ print obj_names


def getDataFromXml(xml_path, type):
	from xml.dom import minidom
	mydoc = minidom.parse(xml_path)
	items = mydoc.getElementsByTagName('item')
	data = []
	for elem in items:
		data.append(elem.attributes[type].value)
	return data

print("XML DATA:\n\t{}".format( getDataFromXml(fpath, "name") ))
print("XML DATA:\n\t{}".format( getDataFromXml(fpath, "parent") ))