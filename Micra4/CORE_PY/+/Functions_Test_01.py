import sys, os, ctypes

file_path	= os.path.abspath("Loader_PY.py")
file_dir	= os.path.dirname(file_path) 
print ("Current Script\n\tdir:{0}\n\tpath:{1}".format(file_dir , file_path))
print ("System Directories:")
for p in sys.path:print ("\t"+p)
print ("is file_path in system paths:", file_path in sys.path)
if file_dir not in sys.path: 
	print ("Register Python CORE Dir.")
	sys.path.append(file_dir) 
else:
	print ("Core Python Dir was already Registred.")
	
	
from mcMath import POINT
from mcGeom import Point

def cursor():
    """Returns the current xy coordinates of the mouse cursor as a two-integer
    tuple by calling the GetCursorPos() win32 function.

    Returns:
      (x, y) tuple of the current xy coordinates of the mouse cursor.
    """
    cursor = POINT()
    ctypes.windll.user32.GetCursorPos(ctypes.byref(cursor))
    return Point(x=cursor.x, y=cursor.y)

print ("Cursor:", cursor())

import mcGetWindow as gw
photoshop_app_list = gw.getWindowsWithTitle('Photoshop')
print ("Got App:", len(photoshop_app_list))
if len(photoshop_app_list) > 0: photoshop_app_list[0].activate() 
else: print ("Photoshop is not Open")


#execute max script and get result as python
result = MaxPlus.FPValue()
evaluation_success = MaxPlus.Core.EvalMAXScript('1+1', result)
handle1 =  result.Get()
print ("result:", result.Get())

#open file with max dialog
try:
    filepath = MaxPlus.Core.EvalMAXScript('getOpenFileName \
    caption:"Select Python File" \
    types:"Object Preset(*.py)|*.py" \
    historyCategory:"PythonObjectPresets";').Get()
except:
    print("No path selected. Export Cancelled.")
print("The filepath is: "+filepath)



>>> entries = os.listdir('my_directory/')
>>> for entry in entries:
...     print(entry)
...
...
sub_dir_c
file1.py
sub_dir_b
file3.txt
file2.csv
sub_dir


import MaxPlus
print 'The Scripts directory is', MaxPlus.PathManager.GetScriptsDir()
print 'The Temp directory is', MaxPlus.PathManager.GetTempDir()



# https://forums.cgsociety.org/t/python-and-pyqt-in-3dsmax/1369437/61
import win32com.client
import sys   
#Create a connection to Max
conn = win32com.client.Dispatch("MAX.Application.2008")     
#Flag as a Method otherwise python or win32com will most likely treat it as attribute.
conn._FlagAsMethod("exec_py")
conn.exec_py(sys.argv[1])