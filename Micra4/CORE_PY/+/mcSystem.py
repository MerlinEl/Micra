import mcGetWindow as gw

def getBlenderApp():
	app_process_list = gw.getWindowsWithTitle('Blender')
	if len(app_process_list) == 0: 
		print ("Got (0)Windows with Blender Name.")
		return None
	blender_window = None
	# collect windows names if attribute title is exist
	window_names = [w.title for w in app_process_list]
	print ("Got ({})Windows with Blender Name.\nTitles:\n\t{}".format(len(app_process_list), "\n\t".join(window_names)))
	for n in window_names:
		is_blender = n.startswith ("Blender")	
		print ("window name:{} is Blender:{}".format(n, is_blender))
		if is_blender: 
			blender_window = w
			break
	return blender_window