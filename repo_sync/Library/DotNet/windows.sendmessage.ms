commandHWND= windows.getChildHWND #max "Command Panel"
BM_CLICK = 0x00F5
wParam = 0
lParam = 0
result = windows.sendMessage commandHWND[6] BM_CLICK wParam lParam



 -- open the Dynamics utility in the Utilities panel
 utilityPanel.openUtility Dynamics

 WM_COMMAND = 0x111 -- Windows Message: Command
 CB_GETCOUNT = 0x0146 -- ComboBox message: Get number of items
 CB_SETCURSEL = 0x014E -- ComboBox message: Set current selection
 CBN_SELENDOK = 9 -- ComboBox notification: Selection ended, OK

 maxHWND = windows.getMaxHWND() -- handle to 3ds Max
 maxChildren = windows.getChildrenHWND maxHWND -- all of 3ds Max's children elements

 -- a function to get the Simulations dropdown from the Dynamics rollout
 fn getDynamicsDropdown = (
 foundPanel = false
 -- loop over all the children
 for child in maxChildren do (
 -- if we find the Dynamics rollout
 if ((child[4] == "RollupPanelTitle") AND (child[5] == "Dynamics")) then ( foundPanel = true )
 if (foundPanel) then (
 -- then we can return the very first 'ComboBox' (the dropdownlist) we find
 if (child[4] == "ComboBox") then ( return child )
 )
 )
 undefined
 )

 -- get the Simulations dropdown
 dynamicsDropdown = getDynamicsDropdown()

 -- get its handle
 dynamicsDropdown_handle = dynamicsDropdown[1]

 -- get its UI resource ID
 dynamicsDropdown_id = UIAccessor.getWindowResourceID dynamicsDropdown_handle

 -- get the dialog it resides in (the 'body' of the Dynamics rollout)
 dynamicsDialog_handle = dynamicsDropdown[2]

 -- Now we've got everything we need...

 -- This is where you would put your code to, for example, determine which simulations should be run.
 -- In the following, it will simply loop over all of the simulations.
 numSolutions = windows.sendmessage dynamicsDropdown_handle CB_GETCOUNT 0 0
 for i = 1 to numSolutions do (
 -- try to change the dropdown selection to the 'i'th simulation
 -- if that fails (its result is -1), then exit the loop.
 if ((windows.sendMessage dynamicsDropdown_handle CB_SETCURSEL (i-1) 0) == -1) then ( exit )

 -- note that we only changed the selection internally. Max doesn't know this until we send a notification as well.
 windows.sendMessage dynamicsDialog_handle WM_COMMAND ((bit.shift CBN_SELENDOK 16) + dynamicsDropdown_id) dynamicsDropdown_handle

 -- The 'i'th simulation should now be properly selected, so let's hit the button labeled "Solve"
 UIAccessor.pressButtonByName dynamicsDialog_handle "Solve"
 )
 -- The End.



 Edit 1: numSolutions
 Edit 2: this forum's [code] handling with respect to indentation is nnnngh-worthy. Re-pasted to clear that up.