


def isGeometryClass(obj):
	# class_name = obj.GetObject().GetClassName()
	class_name = obj.GetBaseObject().GetClassName()
	return (class_name == "Editable Mesh" or class_name == "Editable Poly")


#~ ids = MaxPlus.ClassIds
#~ help(MaxPlus.ClassIds)
#~ class_id = o.GetBaseObject().GetClassID()
#~ if class_id == ids.Edit_Poly or class_id == ids.Editable_Poly or class_id == ids.Edit_Mesh: