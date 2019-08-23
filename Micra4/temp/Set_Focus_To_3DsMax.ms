WM_SETFOCUS = 0x7


-- hwnd = Windows.GetMAXHWND()
-- windows.SendMessage hwnd WM_SETFOCUS 0 0
-- format "max focus...\n"


-- mxse_hwnd = (dotNetClass "Autodesk.Max.GlobalInterface").Instance.TheMxsEditorInterface.EditorGetEditHWND
-- windows.SendMessage mxse_hwnd WM_SETFOCUS 0 0
-- format "Set Focus To Max Script Editor...\n"



windows.SendMessage hForm.handle WM_SETFOCUS 0 0
format "Set Focus To TextboxForm...\n"