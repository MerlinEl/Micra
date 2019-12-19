import mcGetWindow as gw

def getBlenderApp():
	app_process_list = gw.getWindowsWithTitle('Blender')
	blender_window = None
	print ("Got ({})Windows with Blender Name.".format(len(app_process_list)))
	if len(app_process_list) > 0: 
		for w in app_process_list:
			is_blender = w.title.startswith ("Blender")	
			# print ("window name:{} is Blender:{}".format(w.title, is_blender))
			if is_blender: 
				blender_window = w
				break
	return blender_window