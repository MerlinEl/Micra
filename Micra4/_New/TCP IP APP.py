def getAllWindows():
    """Returns a list of Window objects for all visible windows.
    """
	import ctypes
    windowObjs = []
    def foreach_window(hWnd, lParam):
        if ctypes.windll.user32.IsWindowVisible(hWnd) != 0:
            windowObjs.append(Win32Window(hWnd))
        return True
    enumWindows(enumWindowsProc(foreach_window), 0)

    return windowObjs

def getAllTitles():
    """Returns a list of strings of window titles for all visible windows.
    """
    return [window.title for window in getAllWindows()]
	
	
def getWindowsWithTitle(title):
    """Returns a list of Window objects that substring match ``title`` in their title text."""
    hWndsAndTitles = _getAllTitles()
    windowObjs = []
    for hWnd, winTitle in hWndsAndTitles:
        if title.upper() in winTitle.upper(): # do a case-insensitive match
            windowObjs.append(Win32Window(hWnd))
    return windowObjs
  
  getWindowsWithTitle("blender")



import ctypes
 
EnumWindows = ctypes.windll.user32.EnumWindows
EnumWindowsProc = ctypes.WINFUNCTYPE(ctypes.c_bool, ctypes.POINTER(ctypes.c_int), ctypes.POINTER(ctypes.c_int))
GetWindowText = ctypes.windll.user32.GetWindowTextW
GetWindowTextLength = ctypes.windll.user32.GetWindowTextLengthW
IsWindowVisible = ctypes.windll.user32.IsWindowVisible
 
titles = []
def foreach_window(hwnd, lParam):
    if IsWindowVisible(hwnd):
        length = GetWindowTextLength(hwnd)
        buff = ctypes.create_unicode_buffer(length + 1)
        GetWindowText(hwnd, buff, length + 1)
        titles.append(buff.value)
    return True
EnumWindows(EnumWindowsProc(foreach_window), 0)
 
print(titles)







def getWindowsWithTitle(title):
    """Returns a list of Window objects that substring match ``title`` in their title text."""
    hWndsAndTitles = _getAllTitles()
    windowObjs = []
    for hWnd, winTitle in hWndsAndTitles:
        if title.upper() in winTitle.upper(): # do a case-insensitive match
            windowObjs.append(Win32Window(hWnd))
    return windowObjs
  
  getWindowsWithTitle("blender")
  
  
  
import win32gui
 
def windowEnumerationHandler(hwnd, top_windows):
    top_windows.append((hwnd, win32gui.GetWindowText(hwnd)))
 
if __name__ == "__main__":
    results = []
    top_windows = []
    win32gui.EnumWindows(windowEnumerationHandler, top_windows)
    for i in top_windows:
        if "notepad" in i[1].lower():
            print i
            win32gui.ShowWindow(i[0],5)
            win32gui.SetForegroundWindow(i[0])
            break
  
  
  #~ import subprocess
  #~ import time
  #~ blender = subprocess.Popen ([r"blender.exe"])
  #
  # sleep to give the window time to appear
  #
  #~ time.sleep (2.0)