#~ from ("D:\\ReneBaca\\Blender\\v2.81a-win64\\bridge")._app_win.py import pygetwindow 

#~ from "D:\\ReneBaca\\Blender\\v2.81a-win64\\bridge" import "_app_win.py"
#~ from "D:\\ReneBaca\\Blender\\v2.81a-win64\\bridge\\pygetwindow" import import pygetwindow 


import ctypes



#~ Variables

enumWindows = ctypes.windll.user32.EnumWindows
enumWindowsProc = ctypes.WINFUNCTYPE(ctypes.c_bool, ctypes.POINTER(ctypes.c_int), ctypes.POINTER(ctypes.c_int))
getWindowText = ctypes.windll.user32.GetWindowTextW
getWindowTextLength = ctypes.windll.user32.GetWindowTextLengthW
isWindowVisible = ctypes.windll.user32.IsWindowVisible



#~ Classes

class BaseWindow:
    def __init__(self):
        pass
		
    def __str__(self):
        return '<%s title="%s">' % (
            self.__class__.__qualname__,
            self.title,
        )

    @property
    def title(self):
        #~ Returns the window title as a string.
        raise NotImplementedError
		
		
class Win32Window(BaseWindow):
    def __init__(self, hWnd):
        self._hWnd = hWnd # TODO fix this, this is a LP_c_long insead of an int.

    def __repr__(self):
        return '%s(hWnd=%s)' % (self.__class__.__name__, self._hWnd)

    @property
    def title(self):
       #~ Returns the window title as a string.
        textLenInCharacters = ctypes.windll.user32.GetWindowTextLengthW(self._hWnd)
        stringBuffer = ctypes.create_unicode_buffer(textLenInCharacters + 1) # +1 for the \0 at the end of the null-terminated string.
        ctypes.windll.user32.GetWindowTextW(self._hWnd, stringBuffer, textLenInCharacters + 1)

        # TODO it's ambiguous if an error happened or the title text is just empty. Look into this later.
        return stringBuffer.value


#~ Functions

def getAllWindows():
   #~ Returns a list of Window objects for all visible windows.
    windowObjs = []
    def foreach_window(hWnd, lParam):
        if isWindowVisible(hWnd):
            windowObjs.append(Win32Window(hWnd))
        return True
    enumWindows(enumWindowsProc(foreach_window), 0)

    return windowObjs

def getAllTitles():
   #~ Returns a list of strings of window titles for all visible windows.
    return [window.title for window in getAllWindows()]


def getWindowTitle(hWnd):
       #~ Returns the window title as a string.
        textLenInCharacters = ctypes.windll.user32.GetWindowTextLengthW(hWnd)
        stringBuffer = ctypes.create_unicode_buffer(textLenInCharacters + 1) # +1 for the \0 at the end of the null-terminated string.
        ctypes.windll.user32.GetWindowTextW(hWnd, stringBuffer, textLenInCharacters + 1)
		return stringBuffer.value


def getWindowsHandlesByTitle(title):
	   #~ Returns a list of Window objects that substring match ``title`` in their title text.
	windowObjs = []
    def foreach_window(hWnd, lParam):
        if isWindowVisible(hWnd) and getWindowTitle(hWnd) == title:
            windowObjs.append(Win32Window(hWnd))
        return True
    enumWindows(enumWindowsProc(foreach_window), 0)
    return windowObjs
  
blender_windows = getWindowsHandlesByTitle("blender")
print("blender_windows:", blender_windows)
#~ titles =  getAllTitles()
#~ print(titles)

