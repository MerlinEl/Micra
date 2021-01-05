--------------------------------------------------------------------------------
/* mcAnimation by Orien 2019 */
--------------------------------------------------------------------------------
Global mcAnimation
Global mcTempControllerData
/*
*@Used Structures
	Micra
*
*@Used Objects
	undefined
*
*@Usage
	undefined
*
*@Example	
	undefined
*
*/
struct MICRA_ANIMATION_STRUCT
(
	fn getSource = getSourceFileName(), --get path of this script
	fn openTrackView tName:"Orien" tHeight:300 = (
			if trackviews.numTrackViews() == 0 then (
				--<boolean>trackviews.open <fpvalue>name or index [layoutName:<string>] [pos:<point2>] [width:<integer>] [height:<integer>] [dock:<enum>] 
				--trackviews.open "Dope Sheet Editor" layoutName:"Orien" pos:[300,100] width:800 height:400 dock:#bottom --enums: {#float|#top|#bottom|#canDockOnTop} 
				trackviews.open "Dope Sheet Editor" layoutName:tName height:tHeight dock:#right
			) else (
				if trackviews.isOpen "Dope Sheet Editor"
				then trackviews.close "Dope Sheet Editor"
				else trackviews.open "Dope Sheet Editor" layoutName:tName height:tHeight dock:#right
			)
	),
	fn reverse begin end =
	(
		sel = selection as array
		if sel.count != 4 do return false
		undo "Reverse Animation" on for i in sel do 
		(
			reverseTime i.rotation.controller begin end #incLeft #incRight
		)
	),
	fn store = 
	(
		local obj = selection[1]
		if obj == undefined do return false
		mcTempControllerData = #(copy obj.position.controller, copy obj.rotation.controller, copy obj.scale.controller)
	),
	fn paste = 
	(
		local obj = selection[1]
		if obj == undefined do return false
		local old_obj_pos = obj.pos
		if mcTempControllerData != undefined and mcTempControllerData.count == 3 do undo "Paste Animation" on
		(
			obj.position.controller = mcTempControllerData[1]
			obj.rotation.controller = mcTempControllerData[2]
			obj.scale.controller    = mcTempControllerData[3]
			obj.pos = old_obj_pos
		)
	),
	fn addVisibilityTrack = (
		
		--currentTime
		for o in selection do animate on (
			
			at time 0 (o.visibility = 0 ) --brgin
			at time (animationRange.end /2 ) (o.visibility = 1) --half time
			at time animationRange.end  (o.visibility = 0) --end
		)
		--openTrackView()
	),
	fn deleteAnimationKeys = (
		if removeAnimationKeysDialog != undefined do destroyDialog removeAnimationKeysDialog
		rollout removeAnimationKeysDialog "Delete Animation Keys:" width:204 height:108
		(
			checkbox 'chk_pos' " pos" pos:[8,20] width:60 height:24 align:#left
			checkbox 'chk_scale' " scale" pos:[64,20] width:60 height:24 align:#left
			checkbox 'chk_rotation' " rotation" pos:[128,20] width:60 height:24 align:#left
			GroupBox 'grp1' "Set-Up" pos:[4,4] width:192 height:100 align:#left
			button 'btn_remove' "Remove" pos:[8,72] width:180 height:24 align:#left
			spinner 'spn_start' "start" pos:[12,48] width:64 height:16 range:[0, 1000000, 0] type:#integer align:#left
			spinner 'spn_end' "end" pos:[104,48] width:66 height:16 range:[0, 1000000, 0] type:#integer align:#left
			fn deleteAnimationKeys start end = (
			for o in selection do (
					
					if chk_pos.checked then (-- Position keys
						for i=start to end do (
							selectKeys o.pos.controller i
							deleteKeys o.pos.controller #selection 
						)
					)
					if chk_rotation.checked then (-- Rotation keys
						for i=start to end do (
							selectKeys o.rotation.controller i
							deleteKeys o.rotation.controller #selection 
						)
					)
					if chk_scale.checked then (-- Scale keys
						for i=start to end do (
							selectKeys o.scale.controller i
							deleteKeys o.scale.controller #selection 
						)
					)
				)
			)
			on removeAnimationKeysDialog open do (
				spn_start.value = animationRange.start 
				spn_end.value = animationRange.end
			)
			on btn_remove pressed do undo on "Delete Animation Keys" deleteAnimationKeys spn_start.value spn_end.value
		)
		createDialog removeAnimationKeysDialog
	)
	/*<end>*/
)

mcAnimation = MICRA_ANIMATION_STRUCT()

/*
if trackviews.isOpen “Curve Editor”
then trackviews.close “Curve Editor”
else trackviews.open “Curve Editor” layoutName:“Orien” height:300 dock:#bottom
		--C:\Program Files\Autodesk\3ds Max 2018\en-US\MacroScripts\Macro_TrackView.mcr.res
		local TRACK_VIEW_DOPE_SHEET_CAPTION  =  "Track View - Dope Sheet" 
		trackviews.open TRACK_VIEW_DOPE_SHEET_CAPTION
*/