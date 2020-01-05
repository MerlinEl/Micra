import mcGetWindow as gw

def getBlenderApp():
	app_process_list = gw.getWindowsWithTitle('Blender')
	blender_window = None
	print ("Got ({})Windows with Blender Name.".format(len(app_process_list)))
	if len(app_process_list) > 0: 
		for w in app_process_list:
			app_title = w.title.encode('utf-8').strip() #UnicodeEncodeError Hot Fix
			is_blender = app_title.startswith("Blender")
			print ("\tName:{} is Blender:{}".format(app_title, is_blender))
			if is_blender: 
				blender_window = w
				# break # speed up if enabled, but we did not get list of all windows (keep disabled for debug now)
	return blender_window