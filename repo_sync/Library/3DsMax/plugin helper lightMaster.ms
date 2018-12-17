plugin helper lightMaster
name:"Light Master"
classID:#(12345,54321)
extends:Dummy
/*
replaceUI:true
invisible:true
*/
(
parameters main rollout:params
(
key type:#node subAnim:true
fill type:#node subAnim:true
back type:#node subAnim:true
height type:#worldUnits default:0 ui:height
spread type:#worldUnits default:0 ui:spread
angle type:#angle default:90 ui:angle
-- check value of key since lights don't exist at initial creation
on height set val do if key != undefined then coordsys key.target
(
key.pos.z = val
back.pos.z = val * 1.5
fill.pos.z = val * 0.5
)
on spread set val do if key != undefined then coordsys key.target
(
-- compute normal vector pointing at key in the target's XY plane -- (kuv) and reposition everything based on that and the current -- spread and angle values
local kuv = normalize ([key.pos.x, key.pos.y, 0])
key.pos = [kuv.x * spread, kuv.y * spread, height]
back.pos = [kuv.x * -spread, kuv.y * -spread, height * 1.5]
-- position fill by placing it under the key and then rotating in -- about the target
fill.pos = [kuv.x * spread, kuv.y * spread, height * 0.5]
about key.target rotate fill angle z_axis
)
on angle set val do if key != undefined then coordsys key.target
(
fill.pos = [key.pos.x, key.pos.y, height * 0.5]
about key.target rotate fill angle z_axis
)
)
rollout params "Light Parameters"
(
spinner height "Height" type:#worldUnits range:[-1e32, 1e32, 0]
spinner spread "Spread" type:#worldUnits range:[0, 1e32, 0]
spinner angle "Angle" range:[-180, 180, 30]
on params open do flagForeGround #(key, back, fill) true
on params close do
if key != undefined and back != undefined and fill != undefined then
flagForeGround #(key, back, fill) false
)
)