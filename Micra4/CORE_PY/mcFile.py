import sys, MaxPlus	

def getPythonCoreDir():
	result = MaxPlus.FPValue()
	evaluation_success = MaxPlus.Core.EvalMAXScript('micra.CorePyDir', result)
	dir =  result.Get().rstrip('\\') #remove last slash
	return dir

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