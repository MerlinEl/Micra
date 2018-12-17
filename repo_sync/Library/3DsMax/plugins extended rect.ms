plugin shape ExtendedRect
name:"Rectangle2"
classID:#(0x133067, 0x54375)
extends:rectangle version:1
category:"Splines"
(
  tool create
  (
    local startPoint
    on mousePoint click do
      case click of
      (
        1: startPoint = nodeTM.translation = gridPoint
        3: #stop
      )
    on mouseMove click do
      case click of
      (
        2: (delegate.width= abs gridDist.x
        delegate.length= abs gridDist.y
        nodeTM.translation = startpoint + gridDist/2.
        )
        3: delegate.corner_radius = amax 0 -gridDist.x
      )
  )
)