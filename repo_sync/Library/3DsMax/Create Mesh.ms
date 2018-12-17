
(
	local vert_array =#([0,0,0],[10,0,0],[0,10,0],[10,10,0])
	local face_array =#([1,2,3],[2,4,3])  
	local face_ids   =#(1,2)
	
	mesh vertices:vert_array faces:face_array materialIDS:face_ids
)