macroscript MultiWire category:"Bobo_s Tools"
(

----------------------------------------------------------------------------------------
--   Script Name:	MultiWire
--	 Version:		v0.32
--	 Started:       09/28/00
--	 Last Modified: 11/16/00
--   Description:	Enhanced Wiring of Multiple Objects, List Controller support and more
--	 Documentation: Visit http://www.gfxcentral.com/bobo/mxs4/multiwire
--	 Code by:		Borislav Petrov [Boboland]		bobo@email.archlab.tuwien.ac.at
----------------------------------------------------------------------------------------

global multiwire_float
global multiwire_roll
global multiwire_slave_list = #()
global multiwire_names_array = #()
global multiwire_master_source = undefined


fn collect_base_CATs node =
(
values_array =#()
try(base_cats = (node.baseobject.Custom_Attributes))catch(base_cats = undefined)
if base_cats != undefined then
(
for i = 1 to base_cats.numsubs do
(
cat_name = substring (base_cats[i] as string) 9 100
append values_array ("*"+cat_name+"_OBJCAT")
)--end i loop
)
values_array 
)--end fn

fn collect_mat_CATs node =
(
values_array =#()
if node.material != undefined then
(
try(mat_cats = (node.material.custom_attributes))catch(mat_cats = undefined)
if mat_cats != undefined then
(
for i = 1 to mat_cats.numsubs do
(
cat_name = substring (mat_cats[i] as string) 9 100
append values_array ("*"+(cat_name)+"_MATCAT")
)--end i
)
)
values_array 
)--end fn

fn collect_mod_CATs node =
(
values_array =#()
for m = 1 to node.modifiers.count do
(
	try(mod_cats = (node.modifiers[m].custom_attributes))catch(mod_cats = undefined)
	if 	mod_cats != undefined then 
	(
	for i = 1 to mod_cats.numsubs do
	(
	cat_name = substring (node.modifiers[m].custom_attributes[i] as string) 9 100
	append values_array ("*"+cat_name+"_MODCAT")
	)--end i
    )--end m loop
)--end m loop	
values_array 
)--end fn

fn collect_subs_name my_node =
(
subanims_array = #(my_node)
subnames_array = #()
i = 0
while i < subanims_array.count do
	(
	i+=1
	for j = 1 to subanims_array[i].numsubs do
		(
		append subanims_array subanims_array[i][j]
		sub_name = (getSubAnimName subanims_array[i] j)
		go_on = true
		if findstring (sub_name as string) "_Wire" != undefined then go_on = false
		try(if findstring (subanims_array[i].controller as string) "_list" != undefined then go_on = false)catch()		
		
		check_class = classof subanims_array[i][j].value
		if check_class != Float and check_class != Color and check_class != Quat and check_class != Point3 and check_class != BooleanClass and check_class != Integer then go_on = false 
		if go_on then append subnames_array sub_name
		)--end j loop
	)--end while
deleteItem subanims_array 1
subnames_array
)--end fn


fn find_subanim my_node nam =
(
subanims_array = #(my_node)
i = 0
while i < subanims_array.count do
	(
	i+=1
	for j = 1 to subanims_array[i].numsubs do
		(
		append subanims_array subanims_array[i][j]
		sub_name = (getSubAnimName subanims_array[i] j)
		if sub_name == nam then 
		(
		return subanims_array[i]
		)
		)--end j loop
	)--end while
deleteItem subanims_array 1
undefined
)	



fn find_MODCAT_subanim my_node nam =
(
for m = 1 to my_node.modifiers.count do
(
for i = 1 to my_node.modifiers[m].custom_attributes.numsubs do
(
sub_name = getSubAnimName my_node.modifiers[m].custom_attributes i
		if sub_name == nam then 
		(
		return (my_node.modifiers[m].custom_attributes)
		)
)--end i loop
)--end m loop
undefined
)	



fn build_common_list obj_array =
(
base_list = collect_subs_name obj_array[1]
base_cats = collect_base_CATs obj_array[1]
mod_cats = collect_mod_CATs obj_array[1]
mat_cats = collect_mat_CATs obj_array[1]

join base_list base_cats
join base_list mod_cats
join base_list mat_cats

for o = 2 to obj_array.count do
(
compare_list = collect_subs_name obj_array[o]
base_cats = collect_base_CATs obj_array[o]
mod_cats = collect_mod_CATs obj_array[o]
join compare_list base_cats
join compare_list mod_cats

for i = base_list.count to 1 by -1 do
	(
	if findItem compare_list base_list[i] == 0 then deleteItem base_list i
	)--end i loop
)--end o loop
base_list
)




rollout multiwire_roll "Wire Multiple Properties"
(
group "Wire to Master Object:"
(
pickbutton pick_master ">Pick Master" width:75 across:2 align:#left
button master_name "None" align:#right width:170 tooltip:"Press to SELECT the Master Object in the Scene."
listbox source_master_track items:#() height:8 align:#center
checkbox alpha_sort1 "A...Z" checked:true  align:#left
)

group "Wire Slave Objects:"
(
button update_selection "Load Selection as Slave List" width:145 across:2 align:#left \
tooltip:"Gets the current scene selection into the Slave List."
button reselect_selection "ReSelect in Scene" width:100 align:#right \
tooltip:"Selects the current Slave List objects in the scene."
label slave_stats "No Slave Objects Selected." align:#center 

listbox subs_list items:#() height:8 align:#center
checkbox alpha_sort2 "A...Z" checked:true align:#left across:3
checkbox invert_value "Invert" align:#center
dropdownlist axis_pref items:#("X axis","Y axis","Z axis","XY axes","XZ axes","YZ axes","XYZ axes") align:#right width:80

edittext expression_string text:"" width:250 align:#center height:32 offset:[-3,0]

)
group "Connect"
(
checkbox keep_controllers "KEEP Existing Controllers" checked:true align:#left 
checkbox instance_controller "INSTANCE Controllers" checked:false align:#left 
button wire_params "CONNECT..." height:40 width:100 offset:[75,-45] enabled:false 
)

group "Disconnect"
(
checkbox keep_values "KEEP Current Values" checked:true align:#left
checkbox all_controllers "Disconnect ALL Props" checked:false align:#left 

button unwire_params "DISCONNECT..." height:40 width:100 offset:[75,-45] enabled:false
)




fn update_list_display =
(
if selection.count > 0 then
(
old_name = subs_list.selected
global multiwire_slave_list = selection as array
global multiwire_common_names_array = build_common_list (selection as array)
if alpha_sort2.checked then multiwire_common_names_array = sort multiwire_common_names_array 

multiwire_common_names_string_array = #()
for i = 1 to multiwire_common_names_array.count do 
	(
	append multiwire_common_names_string_array (multiwire_common_names_array[i] as string)
	if (multiwire_common_names_array[i] as string) == old_name then subs_list.selection = i
	)
subs_list.items = multiwire_common_names_string_array
if multiwire_slave_list.count  == 1 then 
(
txt = "1 Slave Object with "
txt += multiwire_common_names_array.count as string +" Parameters:"
)
else
(
txt = multiwire_slave_list.count as string 
txt += " Slave Objects with " 
txt += multiwire_common_names_array.count as string +" Common Parameters:"
)
slave_stats.text = txt
unwire_params.enabled = true
if source_master_track.items.count > 0 then wire_params.enabled = true
)
)

on update_selection pressed do
	(
	update_list_display ()
	)
	
on alpha_sort2 changed state do
	(
	update_list_display ()
	)	
	
	
on reselect_selection pressed do
(
for i = multiwire_slave_list.count to 1 by -1 do
(
if not isValidNode multiwire_slave_list[i] then deleteItem multiwire_slave_list i
)
select multiwire_slave_list
update_list_display ()
)


fn update_expression =
(
if multiwire_master_source != undefined then
(
source_name = multiwire_names_array[source_master_track.selection]

if findstring (source_name as string) "*" == undefined then 
(
source_subanim = find_subanim multiwire_master_source source_name
s_m_t = source_master_track.selected
)

if findstring (source_name as string) "_OBJCAT" != undefined then
(
source_name = (substring source_name 2 ((findstring source_name "_")-2)) as name
source_subanim = multiwire_master_source.baseobject.custom_attributes
s_m_t = source_name as string
)

if findstring (source_name as string) "_MODCAT" != undefined then 
(
source_name = (substring source_name 2 ((findstring source_name "_")-2)) as name
source_subanim = find_MODCAT_subanim multiwire_master_source source_name
s_m_t = source_name as string
)

if findstring (source_name as string) "_MATCAT" != undefined then 
(
source_name = (substring source_name 2 ((findstring source_name "_")-2)) as name
source_subanim = multiwire_master_source.material.custom_attributes
s_m_t = source_name as string
)


)--end if 


if multiwire_slave_list.count > 0 then
(
target_name = multiwire_common_names_array[subs_list.selection]

if findstring (target_name as string) "*" == undefined then 
(
target_subanim = find_subanim multiwire_slave_list[1] target_name
)

if findstring (target_name as string) "_OBJCAT" != undefined then 
(
target_name = (substring target_name 2 ((findstring target_name "_")-2)) as name
target_subanim = multiwire_slave_list[1].baseobject.custom_attributes
)


if findstring (target_name as string) "_MODCAT" != undefined then 
(
target_name = (substring target_name 2 ((findstring target_name "_")-2)) as name
target_subanim = find_MODCAT_subanim multiwire_slave_list[1] target_name
)

if findstring (target_name as string) "_MATCAT" != undefined then 
(
target_name = (substring target_name 2 ((findstring target_name "_")-2)) as name
target_subanim = multiwire_slave_list[1].material.custom_attributes
)


)--end if

if multiwire_slave_list.count > 0 and multiwire_master_source != undefined then
(

source_type = classof source_subanim[source_name].value
target_type = classof target_subanim[target_name].value

if invert_value.checked then sign_string = "-" else sign_string = ""

--txt = source_master_track.selected 
txt = s_m_t

if source_type == UndefinedClass then source_type = Float
if target_type == UndefinedClass then target_type = Float
if source_type == BooleanClass then source_type = Float
if target_type == BooleanClass then target_type = Float
if source_type == Integer then source_type = Float
if target_type == Integer then target_type = Float


if source_type == target_type then
	(
	txt =sign_string+ s_m_t
	)
else
	(
	if source_type == Float then
		(
		if target_type == Quat then 
			(
			case axis_pref.selection of
				(
				1: txt = "Eulerangles "+sign_string+s_m_t +" 0 0"
				2: txt = "Eulerangles 0 "+sign_string+s_m_t+" 0"
				3: txt = "Eulerangles 0 0 "+sign_string+s_m_t
				4: txt = "Eulerangles "+sign_string+s_m_t + " " + sign_string+s_m_t + " 0"
				5: txt = "Eulerangles "+sign_string+s_m_t + " 0 "+sign_string+s_m_t
				6: txt = "Eulerangles 0 "+sign_string+s_m_t +" "+sign_string+s_m_t
				7: txt = "Eulerangles "+sign_string+s_m_t +" "+sign_string+s_m_t +" "+sign_string+s_m_t
				)
			)
			
		if target_type == Color then 
			(
			case axis_pref.selection of
				(
				1: txt = "Color "+s_m_t +" 0 0"
				2: txt = "Color  0 "+s_m_t+" 0"
				3: txt = "Color 0 0 "+s_m_t
				4: txt = "Color  "+s_m_t + " " + s_m_t + " 0"
				5: txt = "Color  "+s_m_t + " 0 "+s_m_t
				6: txt = "Color  0 "+s_m_t +" "+s_m_t
				7: txt = "Color  "+s_m_t +" "+s_m_t +" "+s_m_t
				)
			)
			
		if target_type == Point3 then 
			(
			case axis_pref.selection of
				(
				1: txt = "Point3 "+sign_string+s_m_t +" 0 0"
				2: txt = "Point3 0 "+sign_string+s_m_t+" 0"
				3: txt = "Point3 0 0 "+sign_string+s_m_t
				4: txt = "Point3  "+sign_string+s_m_t + " " + sign_string+s_m_t + " 0"
				5: txt = "Point3 "+sign_string+s_m_t + " 0 "+s_m_t
				6: txt = "Point3 0 "+sign_string+s_m_t +" "+sign_string+s_m_t
				7: txt = "Point3 "+sign_string+s_m_t +" "+sign_string+s_m_t +" "+sign_string+s_m_t
				)			
			
			)
		)--end float source 
		
	if source_type == Point3 then
		(
		if target_type == Quat then 
			(
			txt = "Eulerangles "+sign_string+s_m_t +".x " +sign_string+ s_m_t +".y " + sign_string+s_m_t +".z"
			)
			
		if target_type == Float then 
			(
			case axis_pref.selection of
				(
				1: txt = sign_string+s_m_t +".x"
				2: txt = sign_string+s_m_t +".y"
				3: txt = sign_string+s_m_t +".z"
				4: txt = sign_string+"("+s_m_t +".x + " + s_m_t +".y)/2.0"
				5: txt = sign_string+"("+s_m_t +".x + " + s_m_t +".z)/2.0"
				6: txt = sign_string+"("+s_m_t +".y + " + s_m_t +".z)/2.0"
				7: txt = sign_string+"("+s_m_t +".x + " + s_m_t +".y + "+s_m_t +".z)/3.0"
				)--end case
			)--end float 
		)--end point3 source

	if source_type == Color then
		(
		if target_type == Quat then 
			(
			txt = "Eulerangles ("+sign_string+s_m_t +".x*360) (" + sign_string+s_m_t +".y*360) (" +sign_string+ s_m_t +".z*360)"
			)
			
		if target_type == Float then 
			(
			case axis_pref.selection of
				(
				1: txt = sign_string+s_m_t +".x*255"
				2: txt = sign_string+s_m_t +".y*255"
				3: txt = sign_string+s_m_t +".z*255"
				4: txt = sign_string+"(("+sign_string+s_m_t +".x*255) + (" +sign_string+ s_m_t +".y*255))/2.0"
				5: txt = sign_string+"(("+sign_string+s_m_t +".x*255) + (" +sign_string+ s_m_t +".z*255))/2.0"
				6: txt = sign_string+"(("+sign_string+s_m_t +".y*255) + (" +sign_string+ s_m_t +".z*255))/2.0"
				7: txt = sign_string+"(("+sign_string+s_m_t +".x*255) + (" +sign_string+ s_m_t +".y*255) + ("+sign_string+s_m_t +".z*255))/3.0"
				)--end case
			)--end float 
		)--end point3 source

		

	if source_type == Quat then
		(
		if target_type == Point3 then 
			(
			txt = "Point3 ("+s_m_t +" as Eulerangles).x (" + s_m_t +" as Eulerangles).y (" + s_m_t +" as Eulerangles).z"
			)

		if target_type == Color then 
			(
			txt = "Color ("+s_m_t +" as Eulerangles).x (" + s_m_t +" as Eulerangles).y (" + s_m_t +" as Eulerangles).z"
			)
			
		if target_type == Float then 
			(
			case axis_pref.selection of 
				(
				1: txt = sign_string+"("+s_m_t +" as Eulerangles).x"
				2: txt = sign_string+"("+s_m_t +" as Eulerangles).y"
				3: txt = sign_string+"("+s_m_t +" as Eulerangles).z"
				4: txt = sign_string+"(("+s_m_t +" as Eulerangles).x + ("+s_m_t +" as Eulerangles).y)/2.0" 
				5: txt = sign_string+"(("+s_m_t +" as Eulerangles).x + ("+s_m_t +" as Eulerangles).z)/2.0" 
				6: txt = sign_string+"(("+s_m_t +" as Eulerangles).y + ("+s_m_t +" as Eulerangles).z)/2.0" 
				7: txt = sign_string+"(("+s_m_t +" as Eulerangles).x + ("+s_m_t +" as Eulerangles).y + (" +s_m_t +" as Eulerangles).z)/3.0" 
				
				)--end case
			)--end float 
		)--end point3 source
		
	)
expression_string.text = txt 
)--end if

#(source_subanim,source_name,target_subanim,target_name)
)--end fn


fn update_master_display obj =
(
old_name = source_master_track.selected
global multiwire_names_array = collect_subs_name obj

base_cats = collect_base_CATs obj
mod_cats = collect_mod_CATs obj
mat_cats = collect_mat_CATs obj

join multiwire_names_array base_cats
join multiwire_names_array mod_cats
join multiwire_names_array mat_cats


if alpha_sort1.checked then multiwire_names_array = sort multiwire_names_array 
multiwire_names_string_array = #()
for i = 1 to multiwire_names_array.count do 
	(
	append multiwire_names_string_array (multiwire_names_array[i] as string)
	if (multiwire_names_array[i] as string) == old_name then source_master_track.selection = i
	)
source_master_track.items = multiwire_names_string_array
)

on pick_master picked obj do
(
global multiwire_master_source = obj
master_name.text = obj.name
if subs_list.items.count > 0 then wire_params.enabled = true
update_master_display obj
global multiwire_connection_parties = update_expression ()
)	

on alpha_sort1 changed state do
	(
	if multiwire_master_source != undefined then update_master_display multiwire_master_source
	)


on master_name pressed do
(
if isValidNode multiwire_master_source then
	(
	select  multiwire_master_source
	)
)
	
on source_master_track selected itm do
(
global multiwire_connection_parties = update_expression ()
)--end on

on subs_list selected itm do
(
global multiwire_connection_parties = update_expression ()
)--end on

on axis_pref selected itm do
(
global multiwire_connection_parties = update_expression ()
)--end on

on invert_value changed state do
(
global multiwire_connection_parties = update_expression ()
)--end on

	



--------------------------------------------------------------------------
--TEMP.FIX FOR DISRUPTED WIRES WHEN MASTER GETS WIRED TO NEWER MASTER
--------------------------------------------------------------------------

local master_array = #()
local numwires_array = #()
local pb_array = #()
local pb_index_array = #()
local expression_array = #()
local direction_array = #()

fn store_existing_wirings my_node =
(
master_array = #()
numwires_array = #()
pb_array = #()
pb_index_array = #()
expression_array = #()
direction_array = #()

subanims_array = #(my_node)

i = 0
while i < subanims_array.count do
	(
	i+=1
	for j = 1 to subanims_array[i].numsubs do
		(
		append subanims_array subanims_array[i][j]
		check_controller = subanims_array[i][j].controller
		check_class = (classof check_controller ) as string
		if findstring check_class "_Wire" != undefined then 
			(
			append master_array subanims_array[i][j]
			num_wires = check_controller.numWires
			append numwires_array num_wires 
				for w = 1 to num_wires do
				(
				pb = check_controller.getWireParent w
				append pb_array pb
				pb_index = check_controller.getWireSubnum w
				append pb_index_array (pb_index+1)
				exp_str = check_controller.getExprText w
				append expression_array exp_str
				dir_str = check_controller.IsTwoWay
				append direction_array dir_str
				)
			)
		)--end j loop
	)--end while
)

fn restore_existing_wirings my_node =
(

for i = 1 to master_array.count do
(
for j = 1 to numwires_array[i] do
	(
	pb = pb_array[i+j-1]
	pb_i = pb_index_array[i+j-1]
	exp_str = expression_array[i+j-1]
	if not direction_array[i+j-1] then 
		(
--		format "Restoring Wiring between from % to % with Expression %\n" pb[pb_i] master_array[i] exp_str
		paramwire.Connect pb[pb_i] master_array[i] exp_str
		)
	)--end j
)--end i
)--end fn


fn fix_disrupted_wires =
(
format "Restoring Disrupted Wirings... \n"
for s in $* do
(
store_existing_wirings s
restore_existing_wirings s
)--end s loop
)--end fn

---------------
--END TEMP.FIX
---------------






on source_master_track DoubleClicked itm do
(
source_name = multiwire_connection_parties[2] 
source_subanim = multiwire_connection_parties[1] 
paramwire.EditParam source_subanim[source_name]
)
	
on subs_list DoubleClicked itm do
(
if multiwire_slave_list.count == 1 then
(
q = true
)
else
(
q = querybox ("Are you sure you want to open multiple\nParameter Wiring Dialogs for all "+multiwire_slave_list.count as string +" Slave Objects?") title:"MultiWire OPEN DIALOGS" beep:no
)
if q then
	(	
	for i in multiwire_slave_list do
		(
		target_name = multiwire_connection_parties[4] 
		target_subanim = multiwire_connection_parties[3] 
		
--		target_name = multiwire_common_names_array[subs_list.selection]
--		target_subanim = find_subanim i target_name
		paramwire.EditParam target_subanim[target_name] 
		)--end i loop
	)--end if q	
)--end on


fn check_master_validity =
(
(isValidNode multiwire_master_source)
)

on wire_params pressed do 
(

still_valid_master = check_master_validity ()
if still_valid_master then
(
source_subanim = multiwire_connection_parties[1] 
source_name = multiwire_connection_parties[2]
target_subanim = multiwire_connection_parties[3] 
target_name = multiwire_connection_parties[4]

txt = "Are you sure you want to CONNECT \n"
txt += "the Property ["+(target_name as string)+"] to ["+multiwire_master_source.name+":"+(source_name as string)+"]\n"
if multiwire_slave_list.count != 1 then
	(
	txt += "for "+multiwire_slave_list.count as string +" Slave Objects"
	)
	else
	(
	txt += "for 1 Slave Object"
	)
txt += " using the Expression\n\""
txt += expression_string.text + "\"?"
	
q = querybox txt title:"MultiWire CONNECT"
	
if q then
	(
	q2 = keep_controllers.state
	
	for i in multiwire_slave_list do
		(
		if not isValidNode i then
		(
		format "Skipping a Slave Object ... - Deleted!\n"
		)
		else
		(
		if i == multiwire_master_source and target_name == source_name then
		(
		format "Skipping %:% - Cannot Wire to Itself!\n" i.name multiwire_common_names_array[subs_list.selection] 
		)
		else
		(
		target_subanim = find_subanim i target_name
		format "Connecting %:% to %:%...\n"  i.name target_name multiwire_master_source.name source_name
		if q2 then 
		(
		old_cont = target_subanim[target_name].controller
		if old_cont == undefined then
			(
			old_value = target_subanim[target_name].value 
			try
				(
				at time 11 with animate on target_subanim[target_name].value = false
				)
			catch
				(
				try(at time 11 with animate on target_subanim[target_name].value = 123)
					catch
						(
						try(at time 11 with animate on target_subanim[target_name].value = color 1 2 3)catch()
						)
				)
			deleteKeys target_subanim[target_name].controller #allkeys
			target_subanim[target_name].value = old_value 
			old_cont = target_subanim[target_name].controller
			)
		)
	
		
		if not instance_controller.checked or i == multiwire_slave_list[1] then
			(
			try
				(
				paramwire.connect source_subanim[source_name] target_subanim[target_name] expression_string.text
				global inst_controller = target_subanim[target_name].controller
				)
			catch
				(
				format "MultiWire ERROR: Wrong Expression \"%\"\n" expression_string.text
				exit
				)
			)
			else
			(
			target_subanim[target_name].controller = inst_controller
			)
		
		if q2 then
			(
			if findstring ((classof old_cont) as string) "_List" == undefined then
				(
				case (classof target_subanim[target_name].value) of
					(
					Point3: (
							if target_name == #position then 
									(
									target_subanim[target_name].controller = position_list()
									)
									else
									(
									if target_name == #scale then
										(
										target_subanim[target_name].controller = scale_list()
										)
										else
										(
										target_subanim[target_name].controller = point3_list()
										)
									)
							)--end Point3
					Color:	(
							target_subanim[target_name].controller = point3_list()
							)	
					Float:	(
							target_subanim[target_name].controller = float_list()
							)	
					Integer:(
							target_subanim[target_name].controller = float_list()
							)	
			BooleanClass:	(
							target_subanim[target_name].controller = float_list()
							)	
			UndefinedClass:	(
							target_subanim[target_name].controller = float_list()
							)	
					Quat:	(
							target_subanim[target_name].controller = rotation_list()
							)		
					)--end case
				
				list_cont = target_subanim[target_name].controller 
				if old_cont != undefined then list_cont.Available.controller = old_cont
				list_cont.SetActive list_cont.count
				)
			else
				(
				wire_cont = target_subanim[target_name].controller 
				target_subanim[target_name].Available.controller = old_cont
				old_cont.controller = wire_cont
				)
			)--end q2
		)--end if same object	
		)--end if deleted	
		)--end i loop
		
		
	fix_disrupted_wires ()
	
	format "Done.\n" 
	format "\n"	
	)--end q
)--end if valid
else
(
messagebox "Master Object has been deleted.\nPlease select an existing Master Object!\n" title:"MultiWire"
)
	
)--on pressed

on unwire_params pressed do 
(

if all_controllers.checked then
(
txt = "Are you sure you want to DISCONNECT ALL\n"
txt += "Properties of "+multiwire_slave_list.count as string 
if multiwire_slave_list.count > 1 then 
	(
	txt += " Slave Objects?\n"
	)
	else
	(
	txt += " Slave Object?\n"
	)
)
else
(
target_name = multiwire_common_names_array[subs_list.selection]
txt = "Are you sure you want to DISCONNECT \n"
txt += "the Property ["+(target_name as string)+ "] "
if multiwire_slave_list.count == 1 then
	(
	txt += "of 1 Slave Object?\n"
	)
	else
	(
	txt += "of "+multiwire_slave_list.count as string +" Slave Objects?\n"
	)
)


q = querybox txt title:"MultiWire DISCONNECT"
if q then
	(	
	q2 = keep_values.state
	if all_controllers.checked then 
		(
		start_value = 1 
		end_value = multiwire_common_names_array.count
		)
		else
		(
		start_value = subs_list.selection
		end_value = subs_list.selection
		)

	format "Looking for Wires to Disconnect...\n" 
	for i in multiwire_slave_list do
		(
		if not isValidNode i then
		(
		format "Skipping a Slave Object ... - Deleted!\n"
		)
		else
		(
		for p = start_value to end_value do
		(
		if all_controllers.checked then target_name = multiwire_common_names_array[p]
		
		if findstring (target_name as string) "_OBJCAT" == undefined and findstring (target_name as string) "_MODCAT" == undefined and findstring (target_name as string) "_MATCAT" == undefined then
		(
		target_subanim = find_subanim i target_name
		)
		
		if findstring (target_name as string) "_OBJCAT" != undefined then
			(
			target_name = (substring target_name 2 ((findstring target_name "_")-2)) as name
			target_subanim = i.baseobject.custom_attributes			
			)
		
		if findstring (target_name as string) "_MODCAT" != undefined then 
			(
			target_name = (substring target_name 2 ((findstring target_name "_")-2)) as name
			target_subanim = find_MODCAT_subanim i target_name
			)
		
		if findstring (target_name as string) "_MATCAT" != undefined then
			(
			target_name = (substring target_name 2 ((findstring target_name "_")-2)) as name
			)
			
			
		old_value = target_subanim[target_name].value
		if findstring ((classof target_subanim[target_name].controller) as string) "_Wire" != undefined then
			(
			paramwire.disconnect target_subanim[target_name] 
			format "Disconnecting %:%...\n" i.name target_name
			)
		if findstring ((classof target_subanim[target_name].controller) as string) "_List" != undefined then
			(
			list_cont = target_subanim[target_name].controller
			for j = list_cont.count to 1 by -1 do
				(
				if findstring ((classof list_cont[j].controller) as string) "_Wire" != undefined then
					(
					list_cont.delete j
					format "Disconnecting %:%...\n" i.name target_name
					)
				)--end j loop
			if list_cont.count == 1 then 
				(
				new_cont = list_cont[1]
				target_subanim[target_name].controller = new_cont
				)	
			)
		if q2 then try(target_subanim[target_name].value = old_value)catch()
		)--end p loop
		)--end if deleted
		)--end i loop
	format "Done.\n" 
	format "\n"	
	)--end q
)--on click


)--end roll

try(closerolloutfloater multiwire_float)catch()
multiwire_float = newrolloutfloater "MultiWire v0.32" 300 630
addrollout multiwire_roll multiwire_float
if selection.count > 0 then 
	(
	multiwire_roll.update_list_display ()
	global multiwire_connection_parties = multiwire_roll.update_expression ()
	)
)