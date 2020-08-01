(
fileIn (getDir #userStartupScripts + "\LBTools_Biped_Helper.ms")
local str = "Biped Helper 2.4 has been installed.\n\nFind it in the Category > LB Tools.\n"
format str
messageBox str
colorman.reInitIcons()
)