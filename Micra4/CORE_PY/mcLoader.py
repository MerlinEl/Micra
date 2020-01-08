import sys, MaxPlus

HOST = '127.0.0.1'	# Standard loopback interface address (localhost)
MAX_PORT = 4501		# Port to listen on (non-privileged ports are > 1023)
BLENDER_PORT = 4601	# Port to listen on (non-privileged ports are > 1023)

# get Micra python core directory
def getPythonCoreDir():
	result = MaxPlus.FPValue()
	evaluation_success = MaxPlus.Core.EvalMAXScript('micra.CorePyDir', result)
	dir =  result.Get().rstrip('\\') #remove last slash
	return dir

#~ Get Core Python Dir from Micra
core_py_dir = getPythonCoreDir()
print ("Is Python CORE Dir in System Paths:", core_py_dir in sys.path)

#~ Print all system paths
# print ("System Directories:")
# for p in  sys.path:print ("\t"+p)
	
if core_py_dir not in sys.path: 
	#~ add Core Python Dir in to system paths( if need )
	print ("Register Python CORE Dir.")
	sys.path.append(core_py_dir) 
	# from mcFile import createLoaderForBlender
	# createLoaderForBlender(core_py_dir+"\\blender", str(MAX_PORT), str(BLENDER_PORT))
	# start Max Server at Thread
	# print ('Init Bridge at:', MAX_PORT)
	# from mcBridge import ServerThread
	# thread = ServerThread(MAX_PORT)
	# thread.start()
else:
	print ("Core Python Dir was already Registred.")
