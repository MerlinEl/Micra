macroScript _vertex_alpha_selector_english
	category:"DragAndDrop"
       toolTip:"Vertex_Alpha_selector v1"
    buttontext:"Vertex_Alpha_selector v1"
	Icon:#("Systems",2)

(
global My_alpha_test()
global My_alpha_select_verts()

--==============================================================================
rollout List_win_alpha "alpha_v1" width:120 height:240
(
	multiListBox lbx_1 " " pos:[5,8] width:70 height:10  

	spinner spn_1 "Value: " pos:[5,170]  fieldWidth:50 range:[0.0,100.0,0.0] type:#float scale:1.0

	Checkbox btn2 "A" pos:[5 ,2]    checked:false    tooltip:"display vertex Alpha"
	Checkbox btn3 "C" pos:[35,2]   checked:false     tooltip:"display vertex Color"
	Checkbox btn4 "none"  pos:[65,2]   checked:false tooltip:"display normal" 
	
	button btn1 "Select"  pos:[76,32]  width:42 height:80  toolTip:"Select vertexs"
	button btn5 "integer" pos:[76,120] width:42 height:32 toolTip:"Integer alpha, 12.2563 --> 12.0"
	
	dropdownList dd_1 "object : "  pos:[5,190] width:90 height:15 items:#("")

--##########################################################################################
	on List_win_alpha open do
	(	
		callbacks.removeScripts id:#alpha_test_1
		callbacks.addScript #selectionSetChanged "try( My_alpha_test() )catch()" id:#alpha_test_1
		try (select selection)catch()
	)

	on List_win_alpha close do
	( 	
		callbacks.removeScripts id:#alpha_test_1	
	)
	
	on btn1 pressed  do
	(  setwaitcursor()
	   My_alpha_select_verts lbx_1.selection 
	)

	on btn2 changed checked  do 
	(   
		btn2.checked =btn3.checked =btn4.checked = false
	    btn2.checked = true
		selection.vertexColorType = 2
		selection.showVertexColors=on
		selection.vertexColorsShaded=false
		completeredraw() 	
	)
	on btn3 changed checked do 
	( 
		btn2.checked =btn3.checked =btn4.checked = false
		btn3.checked = true
	    selection.vertexColorType = 0
		selection.showVertexColors=on
		selection.vertexColorsShaded=false
		completeredraw()
	)
	on btn4 changed checked do 
	( 
		btn2.checked =btn3.checked =btn4.checked = false
		btn4.checked = true
	    selection.vertexColorType = 0
		selection.showVertexColors=off
		selection.vertexColorsShaded=false
		completeredraw()
	)
	
	on btn5 pressed  do
	(
		for nn=1 to selection.count do
		(
			for tt=1 to selection[nn].verts.count do
			( alpha_integer=(polyOp.getMapVert selection[nn] -2 tt )[1] 
			  alpha_integer=(alpha_integer * 100.0) as integer
			  alpha_integer=alpha_integer/100.0
			  polyOp.setMapVert selection[nn] -2 tt [alpha_integer,alpha_integer,alpha_integer]
			)  
		)	
		select selection
	--	messagebox "alpha_integer complete!!"
	)
--***************************************************************************************	
    on spn_1 entered  do 
	(
	  setwaitcursor()
	  new_alpha_value = (spn_1.value * 2.55)
	  new_alpha_value = (color new_alpha_value new_alpha_value new_alpha_value)
	  for nn =1 to selection.count	do
	  (	polyOp.setVertColor selection[nn] -2 (selection[nn].selectedVerts) new_alpha_value  )
 	  for ii in selection do update ii
   	  My_alpha_test()
	) -- on
--***************************************************************************************
	on dd_1 selected i do
	(	  try ( select selection[i] ) catch()	)
)
--########################################################################
--#####																######
--#####																######
--########################################################################

fn My_alpha_select_verts item_number =        
(
		try(	
				setwaitcursor()
				if selection.count==0 
				then( 	
						List_win_alpha.lbx_1.items =#()
						List_win_alpha.dd_1.items  =#(" ") 
						List_win_alpha.dd_1.caption=""
					)
				else( 
					  current_alpha_array=#() 
  					  item_content=#()
					   convertToPoly selection
					  for g= 1 to item_number.count do
					  (if item_number[g]==true then ( append item_content (List_win_alpha.lbx_1.items[g] as float) )  )
					  subobjectLevel = 1
					  -------------------------------------------------
					  for nn =1 to selection.count do
					  (
						current_alpha_array=#()  
						polyOp.setMapSupport selection[nn] -2 true
						all_vertexs=0
						all_vertexs=polyop.getNumMapVerts selection[nn] -2
						must_select_verts=#{} 
						must_select_verts[all_vertexs]=false
						xx=#{}
						for h =1 to item_content.count do 
						( vv= ( item_content[h] ) * 2.55
						  xx+=polyop.getVertsByColor selection[nn] (color vv vv vv) 0.01 0.01 0.01 channel:-2 
						)
						select selection[nn].verts[xx]
					 )--for nn 
					modPanel.addModToSelection (Edit_Mesh ()) ui:on
					subobjectLevel = 1
				   )--else 
			) catch( )
)-- fn

--########################################################################################
--#####																				######
--#####																				######
--########################################################################################
fn My_alpha_test=
(
		try(	
				alpha_array=#()

				if selection.count==0 
				then( 	
						List_win_alpha.lbx_1.items	  =#()
						List_win_alpha.dd_1.items  =#(" ") 
						List_win_alpha.dd_1.caption=""
					)
				else( 
					  current_alpha_array=#()
					  diffent_alpha=#()
					  for nn =1 to selection.count do
					  (
							current_alpha_array=#()
							case (classOf selection[nn].baseObject ) of
							(
								Editable_Poly:( polyOp.setMapSupport selection[nn] -2 true
						    					all_vertexs=polyop.getNumMapVerts selection[nn] -2
												for i = 1 to  all_vertexs do ( current_alpha_array[i]=(polyOp.getMapVert selection[nn] -2 i)[1] * 100.0 )  )	
							    Editable_mesh:( meshOp.setMapSupport selection[nn] -2 true
						    					all_vertexs=meshop.getNumMapVerts selection[nn] -2
												for i = 1 to  all_vertexs do ( current_alpha_array[i]=(meshOp.getMapVert selection[nn] -2 i)[1] * 100.0 )  )	
									  default:( all_vertexs=0 ;current_alpha_array=#() )
							)
							 	sss=#()
							 	for k =1 to current_alpha_array.count do 
								( sss[k]=current_alpha_array[k] as string 
								)
								sort sss
								diffent_alpha=#()
								diffent_alpha[1]=sss[1]
								for k =1 to sss.count do 
								( if sss[k] != diffent_alpha[diffent_alpha.count]
								  then ( append diffent_alpha sss[k] )
								)
						sss=#()
						sort alpha_array
						for k =1 to current_alpha_array.count do ( sss[k]=current_alpha_array[k] as string )
						alpha_array += sss
					-----------------------------------------------------------------------------------------	
					)--for	
						diffent_alpha=#()
						sort alpha_array
						diffent_alpha[1]=alpha_array[1]
						for k =1 to alpha_array.count do 
							( if alpha_array[k] != diffent_alpha[diffent_alpha.count]
							  then ( append diffent_alpha alpha_array[k] )
							) -- for

				for k =1 to diffent_alpha.count do ( diffent_alpha[k]=diffent_alpha[k] as float )
				sort diffent_alpha
				for k =1 to diffent_alpha.count do ( diffent_alpha[k]=diffent_alpha[k] as string )
				List_win_alpha.lbx_1.items	  =diffent_alpha
			
				obj_name=#()
				for i =1 to selection.count do ( obj_name[i] = selection[i].name )
				List_win_alpha.dd_1.items = obj_name
				List_win_alpha.dd_1.caption=(selection.count as string)+" obj"
				
				   )--else 
			) catch( )
)-- fn
--########################################################################
--#####		start													######
--########################################################################
try (
	options.printAllElements = true
	if List_win_alpha.open==true  
	then( 
		 callbacks.removeScripts id:#alpha_test_1
		 destroydialog List_win_alpha
	    )
	else(	
		 destroydialog List_win_alpha
		 pos_a=[0,150]
		 createdialog List_win_alpha pos:pos_a  fgcolor:(color 250 250 0) \
		 style:#(#style_titlebar, #style_border, #style_sysmenu,#style_minimizebox) \
		 escapeEnable:true
 		try (select selection)catch()
		) 
    ) catch()
)

