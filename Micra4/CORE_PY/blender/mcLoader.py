import sys
Micra_Blender_Dir = 'D:\\ReneBaca\\3DsMax\\Micra\\Micra4\\CORE_PY\\blender'
MAX_PORT = 5688
BLENDER_PORT = 2489
#~ add Micra Core Python Dir in to system paths( if need )
def register():
	if Micra_Blender_Dir not in sys.path:
		print ('Register Micra Python CORE Dir:', Micra_Blender_Dir)
		sys.path.append(Micra_Blender_Dir)
		# start Blender Server at Thread
		print ('Init Bridge at:', BLENDER_PORT)
		from mcBridge import ServerThread
		thread = ServerThread(BLENDER_PORT)
		thread.start()
		# wait 2 sec and register Script Command
		from mcThread import RegisterScript
		thread = RegisterScript(Micra_Blender_Dir, 'BlenderToMax.py', 2)
		thread.start()
	else:
		print ('Micra Core Python Dir was already Registred.')

if __name__ == '__main__':
	register()