	roGen_Joint_CA = attributes roGen_Joint_CA attribID:#(0x753a97d6, 0x50f2e011) --genClassID()
	(
		local lastSize, thisNode
		fn getNode = (
			
			local owner = custattributes.getowner this
			refs.dependentnodes owner firstonly:on
		)
		parameters main rollout:params_rt (
			
			type type:#integer
			rails type:#boolean animateable:false default:false ui:chk_rails
			parkingL type:#boolean animateable:false default:false ui:chk_parking_l
			parkingR type:#boolean animateable:false default:false ui:chk_parking_r
			sidewalkL type:#boolean animateable:false default:false ui:chk_sidewalk_l
			sidewalkR type:#boolean animateable:false default:false ui:chk_sidewalk_r
			is_linked type:#boolean animateable:false default:false
			is_deleted type:#boolean animateable:false default:false
			node_name  type:#string animateable:false default:""
			tangent_pos type:#point3 animateable:false default:[0,0,0]
			parent_node type:#maxObject
			
			on sidewalkL set val do (
				
				format "set sidewalkL to:%\n" val
			)
		)
		rollout params_rt "Road Tool Parameters" rolledUp:true (
			
			group "Settings:" (
				
				label lbl_type "Joint Type:" align:#left
				dropDownList 'ddl_type' "" width:150 height:21 items:#("1-6", "2-2", "2-4", "2-4", "2-5", "4-4", "4-5") align:#left
				checkbox 'chk_rails' "Rails" width:85 height:14 align:#left
				label lbl_parking "Parking Lane:" height:14 align:#left across:3
				checkbox 'chk_parking_l' "Left" width:40 height:14 align:#right
				checkbox 'chk_parking_r' "Right" width:40 height:14 align:#right
				label lbl_sidewalk "Sidewalk:" height:14 align:#left across:3
				checkbox 'chk_sidewalk_l' "Left" width:40 height:14 align:#right
				checkbox 'chk_sidewalk_r' "Right" width:40 height:14 align:#right
			)
			group "About:"
			(
				label lbl1 "Road Joint Helper" align:#left
			)
			
			on params_rt open do ( 
				
				format "params_rt open thisNode:%\n" thisNode
				try (removerollout thisNode.params) catch (format "Unable to remove rollout params:" getCurentException())
-- 				if isValidNode thisNode and hasProperty thisNode "prams" do (
-- 					
-- 					format "closed params rollout\n"
-- 					thisNode.params.open = false
-- 				)
			)
		)
		on getDisplayMesh do (
			
			format "on display:%\n" this
-- 			if (meshObj == undefined) do (
-- 				
-- 				meshObj = createInstance Sphere radius:size segments:8 mapCoords:false
-- 				lastSize = size
-- 				format "roGen_Joint > getDisplayMesh >  mesh:%\n" meshObj
-- 			)
-- 			if size != lastSize do (
-- 				 
-- 				lastSize = meshObj.radius = size
-- 			)
-- 			meshObj.mesh
		)
		fn init = (
			
			thisNode = getNode()
			thisNode.name = uniqueName "roGen_Joint_"
			thisNode.size = 10
-- 			thisNode.params.open = false
		)
		--on create do (format "Dummy was created:% \n" this) --call before getDisplayMesh
		on attachedToNode obj do ( --when node is created
			
			format "roGen_Joint > attachedToNode > node:%\n" obj
		)
		on detachedFromNode obj do ( --when node is deleted
			
			format  "roGen_Joint > detachedFromNode > node_name:%\n"  node_name
-- 			if is_deleted do return false --prevent depency loop crash
-- 			format  "roGen_Joint > detachedFromNode > parent:% is_deleted:%\n"  parent_node is_deleted
-- 			is_deleted = true
-- 			if classOf parent_node == NodeTransformMonitor do ( --when spline is dleted delete also master obj
-- 				local obj = parent_node.node
-- 				if isValidNode obj and not (isDeleted obj) and not (obj.is_deleted) do (
-- 					
-- 					format "roGen_Joint > detachedFromNode > Deleting parent node:%\n" obj.name
-- 					try (delete parent_node.node) catch (format "roGen_Joint > detachedFromNode > Error:%\n" (getCurrentException()))
-- 				)
-- 			)
		)
		on load do (
			
			format "roGen_Joint > load\n"
		)
		on create do (

			format "roGen_Joint > created this:%\n"  this
		)
		on update do (
			
-- 			format "roGen_Joint > update this:%\n"  this	
		)
		on deleted do (
			
			is_deleted = true
			format "roGen_Joint > deleted node:%\n"  node_name
		)
)


du = Sphere pos:[0,0,0] radius:10 wirecolor:green
custAttributes.add du roGen_Joint_CA baseObject:true #unique
du.init()
select du

	
	
	/*
getDialogPos rlt_master
clearUndoBuffer()
theHold.getCurrentUndoLevels()
$.params.hwnd
	removerollout $.params
	$.params.open = false
	flashFloater.rollouts[i].open=false
	Rolloutfloaters 
	replaceUI=true
$.params.rolledUp
	$.params.placement = #minimized --{#minimized|#maximized|#normal}
	closerolloutfloater $.params 
	*/