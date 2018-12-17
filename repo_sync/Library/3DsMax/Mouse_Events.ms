rollout xxl "Untitled" width:336 height:300
(
	ActiveXControl ax "{5754A833-F79C-11D3-A259-0080C8588E1D}" pos:[8,8] width:320 height:196
	on xxl open  do
	(
	
	)
	on xxl close  do
	(
	
	)
	on ax MouseMove x y do format "x: %y: %" x y
)
createDialog xxl

/*
METHODS:
  .LeftClick()
  .RightClick()
  .MiddleClick()
  .MouseMove &x:integer &y:integer
  .MouseCoRollout:xxl
*/