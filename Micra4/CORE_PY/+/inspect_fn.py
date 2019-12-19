import MaxPlus, inspect

#~ source_DF = inspect.getsource(MaxPlus)
#~ print(type(source_DF))
#~ print(len(source_DF))
#~ print(source_DF[:200])
	
	
#~ source_file_DF = inspect.getsourcefile(MaxPlus)
#~ print(source_file_DF)
	

#~ sourcelines_DF = inspect.getsourcelines(MaxPlus.FileManager)
#~ print(type(sourcelines_DF))
#~ print(len(sourcelines_DF))
#~ print(type(sourcelines_DF[0]))	

#~ lines = inspect.getsource(MaxPlus)
#~ print(lines)

#~ lines = inspect.getsource(MaxPlus.FileManager.ExportSelected)
#~ print(lines)
	
help ("MaxPlus.FileManager.Reset")	
help ("MaxPlus.ViewportManager.SetViewportMax")	
help ("MaxPlus.FileManager.ExportSelected")
help ("MaxPlus.FileManager.DoesFileExist")

result = MaxPlus.FileManager.DoesFileExist ( "c:\\temp")
print ("is file exist:", result)

#~ result = MaxPlus.FileManager.ExportSelected ("c:\\temp\\test_export.fbx")
#~ print ("export file:", result)

import imp
lines = inspect.getsource(imp)
print(lines)

#~ reset Max
#~ MaxPlus.FileManager.Reset(False)

# maximize the view
#~ MaxPlus.ViewportManager.SetViewportMax(True)
	

	