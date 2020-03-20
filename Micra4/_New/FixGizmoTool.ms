rollout fT "fixGizmo" width:117 height:35
(
	button btn1 "Fix Gizmo Now!!" pos:[8,5] width:99 height:25

on btn1 pressed do
	(
		thisNodeParent = $.parent
		thisNodeChild = #()
		for i in $.children do (	append thisNodeChild i	)

	--unlink code

		$.parent = undefine
		for i in thisNodeChild do (	i.parent = undefine	)
		
	--fixgizmo2 code
		
		with redraw off 
		(
			temppivot = point transform:(getTransformAxis $ 1) text:tempPivot size:0
			ResetXForm $ ; CollapseStack  $ 
			$.pivot = temppivot.pos
			pivot_rotate_angle= temppivot.rotation
			$.rotation *= pivot_rotate_angle
			$.objectoffsetrot *= pivot_rotate_angle
			$.objectoffsetpos *= pivot_rotate_angle
			$.pos=temppivot.pos
			$.pivot = temppivot.pos
			$.rotation = (quat 0 0 0 0)
			ResetXForm $ ; CollapseStack  $ 
			$.transform = temppivot.transform
			delete temppivot
		)

	--relink code

		$.parent = thisNodeParent
		for i in thisNodeChild do (	i.parent = $	)
	)
	
)
createdialog ft