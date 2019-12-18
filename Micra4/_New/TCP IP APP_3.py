import ctypes
import win32gui

'''
https://www.lfd.uci.edu/~gohlke/pythonlibs/#pywin32
Step 1: Download the pywin32....whl
Step 2: pip install pywin32....whl
Step 3: C:\python32\python.exe Scripts\pywin32_postinstall.py -install
Step 4: python
>>> import win32gui
'''


#~ Variables

enumWindows = ctypes.windll.user32.EnumWindows
enumWindowsProc = ctypes.WINFUNCTYPE(ctypes.c_bool, ctypes.POINTER(ctypes.c_int), ctypes.POINTER(ctypes.c_int))
getWindowText = ctypes.windll.user32.GetWindowTextW
getWindowTextLength = ctypes.windll.user32.GetWindowTextLengthW
isWindowVisible = ctypes.windll.user32.IsWindowVisible


#~ Functions

def getWindowTitle(hWnd):
	#~ Returns the window title as a string.
	textLenInCharacters = getWindowTextLength(hWnd)
	stringBuffer = ctypes.create_unicode_buffer(textLenInCharacters + 1) # +1 for the \0 at the end of the null-terminated string.
	getWindowText(hWnd, stringBuffer, textLenInCharacters + 1)
	return stringBuffer.value
		
def getWindowsHandlesByTitle(title):
	#~ Returns a list of Window objects that substring match ``title`` in their title text.
	windowObjs = []
	def foreach_window(hWnd, lParam):
		if isWindowVisible(hWnd) and getWindowTitle(hWnd).lower() == title.lower():
			windowObjs.append(hWnd)
		return True
	enumWindows(enumWindowsProc(foreach_window), 0)
	return windowObjs
  
blender_windows = getWindowsHandlesByTitle("blender")
print("blender_windows:", blender_windows[0])
if blender_windows.count > 0:
	win32gui.ShowWindow(blender_windows[0],5)
	win32gui.SetForegroundWindow(blender_windows[0])
#~ titles =  getAllTitles()
#~ print(titles)


#~ win32gui.GetWindowText(hwnd)