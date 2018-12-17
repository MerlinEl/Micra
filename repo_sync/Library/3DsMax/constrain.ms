$.pos.controller = Path_Constraint ()
$.pos.controller.appendTarget $Circle001 30


deleteTarget

$.pos.controller.getNumTargets()


  Path_Constraint.percent : percent
  Path_Constraint.follow : boolean
  
  
mapped fn freezePosRot obj position:true rotation:true = (
 -- feeze position
 if position then (
 obj.position.controller = Bezier_Position()
 obj.position.controller = position_list()
 obj.position.controller.available.controller = Position_XYZ()
 obj.position.controller.setname 1 "dontUse"
 obj.position.controller.setname 2 "animate"
 obj.position.controller.SetActive 2
 )

 -- freeze rotation
 if rotation then (
 obj.rotation.controller = Euler_Xyz()
 obj.rotation.controller = Rotation_list()
 obj.rotation.controller.available.controller = Euler_xyz()
 obj.rotation.controller.setname 1 "dontUse"
 obj.rotation.controller.setname 2 "animate"
 obj.rotation.controller.SetActive 2
 -- set the axis order so that the Z axis (bend) will always rotate as expected in Gimbal mode
 obj.rotation.controller[2].axisOrder = 6
 )
 )
 
 
 path1 = Circle()--create a circular path
--$Circle:Circle01 @ [0.000000,0.000000,0.000000]
path2 = Ellipse length:20 width:200--create another path
--$Ellipse:Ellipse01 @ [0.000000,0.000000,0.000000]
s = sphere radius:5--create a sphere
--$Sphere:Sphere01 @ [0.000000,0.000000,0.000000]
pc = path_constraint()--create a path constraint
--Controller:Path_Constraint
s.position.controller = pc--assign it to the sphere's position
--Controller:Path_Constraint
pc.path = path1--assign the first path to the path property
--$Circle:Circle01 @ [0.000000,0.000000,0.000000]
pc.path = path2--assign the second path - it replaces the first
--$Ellipse:Ellipse01 @ [0.000000,0.000000,0.000000]
pc.appendTarget path2 50--try to append the second path
--false--you cannot because it is already assigned!
pc.appendTarget path1 50--try to append the first path
--true--you can because it was not assigned to the list yet
pc.getNumTargets()--see how many paths there are on the list
--2
pc.getWeight 1--get the weight of the first path
--50.0
pc.getWeight 2--get the weight of the first path
--50.0
pc.getWeight 3--get the weight of thethirdpath
--0.0--returns zero because there is no such path!
pc.setWeight 1 100--set the weight of the first path to 100
--true--success, the sphere moves closer to the ellipse
pc.setWeight 2 0--set the weight of the second path to 0
--true--success, the sphere moves to the ellipse
pc.path = path1--try to assign the circle to the path
--At this point, the Circle replaces the Ellispe on the list,
--and the second entry which used to be the Curcle is removed
--because "There can be only one"!
--$Circle:Circle01 @ [0.000000,0.000000,0.000000]
pc.deleteTarget 2--try to delete the second path
--false--you cannot, there is no second path anymore
pc.deleteTarget 1--try to delete the first path (the Circle)
--true