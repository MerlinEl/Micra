if menuMan.findMenu "Blank" != undefined then
(menuMan.createMenu "Blank") --Create Blank Menu
if mMenu == undefined then
Local mMenu = menuMan.GetMainMenuBar() --Store current Main Menu Bar
Local mBlank = menuMan.findMenu "Blank" --Definition Blank menu
menuMan.setMainMenuBar mBlank --Set Blank menu to active


menuMan.setMainMenuBar mMenu





menuMan.loadMenuFile "MicraMenuHolder.mnu"

if menuMan.findMenu "Blank" == undefined then
	(
	menuMan.saveMenuFile "MicraMenuHolder.mnu"
	menuMan.createMenu "Blank"
	)

mBlank = menuMan.findMenu "Blank" --Definition Blank menu
menuMan.setMainMenuBar mBlank  --Hide Main Menu Bar




MyMenuBar = menuMan.getMenuFile()
menuMan.loadMenuFile MyMenuBar
menuMan.setMainMenuBar MyMenuBar

menuMan.findMenu MyMenuBar


x=menuMan.getMainMenuBar()
menuMan.setMainMenuBar x
menuMan.unRegisterMenu x
menuMan.registerMenuContext x
menuMan.updateMenuBar()

