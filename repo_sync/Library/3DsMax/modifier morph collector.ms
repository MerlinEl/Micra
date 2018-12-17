--Scripted Modifier Plug-ins
--GenclassID() 

plugin modifier MorphCollector
name:"Morph Collector"
classID:#(0x6b0f2189, 0x17b2df79)
(
	parameters param_tagrings rollout:tagrings
	(
		ring_names type:#filenameTab tabSize:0 tabSizeVariable:true
		--tag_names type:#filenameTab tabSize:0 tabSizeVariable:true
		last_sel type:#integer default:1
	)
	/*
	parameters param_tags rollout:tags
	(
		tag_names type:#filenameTab tabSize:0 tabSizeVariable:true
	)
	*/
	rollout tags "Tags:"
	(
		listBox tag_list "" pos:[2,2] width:158 height:8 items:#()
	)
	rollout tagrings "Tag Rings:"
	(
		fn isMorphTagger obj = (classOf obj == MorphTagger and findItem tagrings.ring_list.items obj.name == 0)
		listBox ring_list "" pos:[2,2] width:158 height:8  items:#()
		pickButton btn_add "Add" pos:[4,118] width:76 height:24 filter:isMorphTagger
		button btn_rem "Remove" pos:[84,118] width:76 height:24
		fn loadTags = 
		(
			local ring_node = getNodeByName ring_names[last_sel]
			if ring_node == undefined do return false
			tags.tag_list.items =  ring_node.tag_names as array
		)
		fn updateNodeList = 
		(
			ring_list.items = for n in ring_names where (getNodeByName n) != undefined collect n
			if ring_list.items.count != 0 do 
			(
				ring_list.selection = last_sel
				loadTags()
			)			
		)
		fn addRing obj =
		(
			append ring_names obj.name 
			last_sel = ring_list.items.count
			updateNodeList()
		)
		fn remRing num =
		(
			if num == 0 do return false
			deleteItem ring_names num
			ring_list.items = deleteItem ring_list.items num
			last_sel = ring_list.items.count
			updateNodeList()	
		)
		on tagrings open do (updateNodeList())
		on btn_add picked obj do (addRing obj)
		on btn_rem pressed do (remRing ring_list.selection)	
		on ring_list selected sel do (last_sel = sel ; loadTags())
    )

)

/*

			if ring_list.items.count != 0 do
			(
				if ring_list.selection == 0 then ring_list.selection = ring_list.items.count
			)

	if lbx_tags.selection == 0 then last_sel = lbx_tags.items.count else last_sel = lbx_tags.selection
parameters main rollout:tagrings
(
	tagger_node_list type:#nodeTab tabSize:0 tabSizeVariable:true
	on node_list tabChanged change tabIndex tabCount do this.theRollout.updateNodeList()
)
parameters main rollout:tags 
(
	tag_list type:#nodeTab tabSize:0 tabSizeVariable:true
)
*/