--------------------------------------------------------------------------------
/* gPlantObjectOnSurface by Orien 2019 */
--------------------------------------------------------------------------------
/*
*@Used Structures
	mcSystem
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
Global gPlantObjectOnSurface
struct sPlantObjectOnSurface (

	intersection_ray = undefined,
	private fn drawCross = (

		if intersection_ray == undefined do return OK
		--gw.clearScreen (Box2 800 600 20 30 ) useBkg:false
		local GridTm = matrixFromNormal intersection_ray.dir
		GridTm.row4 = intersection_ray.pos
		gw.setTransform GridTm
		gw.setColor #line yellow
		gw.Polyline #([-10,0,0],[10,0,0]) false		--Line X
		gw.Polyline #([0,-10,0],[0,10,0]) false		--Line Y
		gw.enlargeUpdateRect #whole
		gw.updateScreen()
	),
	private fn mouseTracking msg ir obj faceNum shift ctrl alt = (

		case msg of
		(
			#mouseAbort: (
				format "mouseTracking Finished\n"
				gPlantObjectOnSurface.stopTrace()
			)
			#freeMove: (

				if ir != undefined do (

					intersection_ray = ir
					if not keyboard.controlPressed do intersection_ray.dir = [0,0,1]
					redrawViews()
				)
			)
			#mousePoint: (

				local src_obj = selection[1] 
				local trgt_obj = obj
				if ir != undefined and src_obj != undefined and trgt_obj != undefined do undo "Plant Object" on (

					selection[1].pos = ir.pos
					if keyboard.controlPressed do selection[1].dir = ir.dir
					gPlantObjectOnSurface.stopTrace()
					#abort
				)
			)
			#mouseMove: ()
		)
		if msg == #mouseAbort then #abort else #continue 
	),
	public fn startTrace = (

		unRegisterRedrawViewsCallback drawCross
		local visible_geo_objects = for o in objects where not o.isHidden and superClassOf o == GeometryClass collect o
		registerRedrawViewsCallback drawCross
		mcSystem.setFocusToMaxActiveViewport()
		mouseTrack trackCallback:mouseTracking prompt:"Pick target location..." on:visible_geo_objects
		completeRedraw()
	),
	public fn stopTrace = (

		unRegisterRedrawViewsCallback drawCross
		completeRedraw()
	)
)
gPlantObjectOnSurface = sPlantObjectOnSurface()

/*
gPlantObjectOnSurface.startTrace()
*/


