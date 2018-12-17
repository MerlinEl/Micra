resetMaxFile #noPrompt 
-- USER INTERFACE ITEMS 
CaseTest = newRolloutFloater "Best Case Scenario" 300 150 
rollout rgender_issue "Describe yourself" 
	(
 	radioButtons btn_gender "Are you a: " labels:#("man", "woman", "child", "other") 
	on btn_gender changed state do 
		( 
		case state of 
			( 
			1: (c = cone () ) 
			2: (s = sphere () ) 
			3: (b = box () ) 
			4: (t = spindle radius:20 height:42 cap_height:15) 
			) 
--btn_gender.enabled = false 
		)
 	)
addrollout rgender_issue CaseTest




a=2
b=6
 of
(
(a > b): print "a is big"

(b > a): print "b is big"
)


new_obj = case copy_type.state of
(
2: copy $foo
3: instance $foo
default: reference $foo
)

(
	local pos = #top
	
	local new_pos = case pos of
	(
		#top: [10,20]--[50,20]
		#left: [10,30]--[345,5]
		#right: [10,40]--[12,78]
	)
	
	print (new_pos)
)



/*
--A)
if getSelectionLevel $ == #vertex then print "viewText=1" else print "viewText=2"
if getSelectionLevel $ == #edge then print "viewText=1" else print "viewText=2"
if getSelectionLevel $ == #face then print "viewText=1" else print "viewText=2"

--B)
case getSelectionLevel $ of 
(
	#vertex: viewText = "Sel. Vert.: " + ((getVertSelection $) as array).count as string
	#edge:   viewText = "Sel. Edges: " + ((getEdgeSelection $) as array).count as string
	#face:   viewText = "Sel. Faces: " + ((getFaceSelection $) as array).count as string
)
print viewText
*/