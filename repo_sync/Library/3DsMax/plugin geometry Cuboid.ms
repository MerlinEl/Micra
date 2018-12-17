plugin geometry Cuboid
name:"Cuboid"
classID:#(0x133067, 0x54374)
category:"Scripted Primitives"
extends:Box
(
fn fmax val1 val2 = if val1 > val2 then val1 else val2
tool create
(
on mousePoint click do
case click of
(
1: nodeTM.translation = gridPoint
2: #stop
)
on mouseMove click do
if click == 2 then delegate.width = delegate.length =delegate.height = 2 * fmax (abs gridDist.x) (abs gridDist.y)
)
)