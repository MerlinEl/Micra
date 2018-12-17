try(destroydialog drawRol) catch()
rollout drawRol "Draw in Label"
(
 dotNetControl lb "System.Windows.Forms.Label" width:180 height:30 pos:[10, 10]
 
 local pen = dotNetObject "system.drawing.pen" (dotNetClass "system.drawing.color").red 2  
 on lb mouseDown s e do
 (
  g = s.createGraphics() 
  g.DrawLine pen 0 e.y s.bounds.width e.y
 )
)
createdialog drawRol width:200 height:50