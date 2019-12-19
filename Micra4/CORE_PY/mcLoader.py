import sys, MaxPlus

def getPythonCoreDir():
	result = MaxPlus.FPValue()
	evaluation_success = MaxPlus.Core.EvalMAXScript('micra.CorePyDir', result)
	dir =  result.Get().rstrip('\\') #remove last slash
	return dir
	
#~ Get Core Python Dir from Micra
core_py_dir = getPythonCoreDir()
#~ Print all system paths
# print ("System Directories:")
# for p in  sys.path:print ("\t"+p)
	
#~ add Core Python Dir in to system paths( if need )
print ("Is Python CORE Dir in System Paths:", core_py_dir in sys.path)
if core_py_dir not in sys.path: 
	print ("Register Python CORE Dir.")
	sys.path.append(core_py_dir) 
else:
	print ("Core Python Dir was already Registred.")
