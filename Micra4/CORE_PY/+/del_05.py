#~ import pymxs as mxs


#~ def exportSelectionAsFBX():
	#~ mxs.runtime.exportFile (
		#~ r'c:\temp\msx.fbx', 
		#~ pymxs.runtime.Name("noPrompt"), 
		#~ selectedOnly=True, using='FBXEXP'
	#~ )
#~ exportSelectionAsFBX()


#~ import pymxs as mxs
#~ mxs.runtime.exportFile (
	#~ r'c:\temp\msx.fbx', 
	#~ pymxs.runtime.Name("noPrompt"), 
	#~ selectedOnly=True, using='FBXEXP'
#~ )



#~ import sys
#~ print sys.getrefcount("mcMax")
#~ if 'mcMax' in sys.modules:  
    #~ del sys.modules["mcMax"]
#~ import mcMax

if 'mcFile' in sys.modules:  del sys.modules["mcFile"]

from mcFile import reimport
reimport(["mcMax"])

mcMax.exportSelectionAsFBX ("c:\\temp\\test_export.fbx")