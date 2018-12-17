ScrollBars = dotNetClass "System.Windows.Forms.ScrollBars"



f=dotnetObject "form"
f.backcolor = netDrColor yellow
vs=dotnetObject "vScrollBar"
hs=dotnetObject "hScrollBar"
vs.location = netDrPoint [0,40]
vs.AutoSize = true
hs.location = netDrPoint [0,0]
hs.AutoSize = true
f.controls.add(vs)
f.controls.add(hs)
f.show(WindowWrapper)

mc2system.show vs
