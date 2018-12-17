toolMode.coordsys
(
	#view
	#screen
	#world
	#parent
	#local
	#grid
)


tbs = case getToolbtnState of
(
	#move:    "Move"
	#rotate:  "Rotate"
	#nuscale: "Scale"
	#uscale:  "Scale"
	#squash:  "Scale"
	#select:  "Select"
)

setToolBtnState tbs on

