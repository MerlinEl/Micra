--check if modify mode is true
if getCommandPanelTaskMode() == #modify then 20 else 40

--get mode state
getCommandPanelTaskMode()
--Result:
#create
#modify
#hierarchy
#motion
#display
#utility