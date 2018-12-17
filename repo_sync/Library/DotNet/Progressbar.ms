"System.Drawing.Point"

rollout roll_test "test" width:400 height:100 
(
	dotNetControl dno_pb "Windows.Forms.Progressbar" width:300 height:20
	timer tick_tock interval:100 active:true
	
	on roll_test open do 
	(
		dno_pb.style = dno_pb.style.continuous
		dno_pb.backColor = (dotNetClass "System.Drawing.Color").darkgreen
		dno_pb.foreColor = (dotNetClass "System.Drawing.Color").limegreen
	)
	
	on tick_tock tick do 
	(
		dno_pb.value = mod tick_tock.ticks 100.0
	)
)
CreateDialog roll_test




try (NewForm1.close()) catch ()
(
dotNet.loadAssembly (getdir #maxroot +"\\MaxCustomControls.dll")
dotnet.loadAssembly (getdir #maxroot + "\\DevExpress.XtraEditors.v7.1.dll")
--//--
Global NewForm1 = (dotnetobject "maxcustomcontrols.maxform")
local NewPbar = (dotnetobject "DevExpress.XtraEditors.ProgressBar")
--//-- Main Function
fn NewForm1_closed s e =
(
NewForm1 = undefined
(dotnetclass "system.gc").collect()
gc()
)
--//--
--//-- NewPbar --//--
--//--
NewPbar.name = "NewPbar"
NewPbar.BorderStyle = NewPbar.BorderStyle.flat
NewPbar.Dock = NewPbar.Dock.Bottom
NewPbar.properties.showtitle=true
NewPbar.properties.startcolor=NewPbar.properties.startcolor.black
NewPbar.properties.endcolor=NewPbar.properties.startcolor.white
NewPbar.properties.lookandfeel.style=NewPbar.properties.lookandfeel.style.Flat
NewPbar.properties.progressviewstyle=NewPbar.properties.progressviewstyle.Solid --broken
NewPbar.properties.lookandfeel.usedefaultlookandfeel=false
NewPbar.properties.lookandfeel.usewindowsxptheme=false
--//--
--//-- NewForm1 --//--
--//--
NewForm1.name = "NewForm1"
NewForm1.startposition = NewForm1.startposition.centerscreen
NewForm1.formborderstyle = NewForm1.formborderstyle.sizable
NewForm1.backcolor = NewForm1.backcolor.fromargb 255 220 220 220
NewForm1.forecolor = NewForm1.forecolor.fromargb 255 0 0 0
NewForm1.size = dotnetobject "system.drawing.size" 400 280
NewForm1.text = "NewForm1"
NewForm1.ShowIcon = true
NewForm1.showintaskbar = false
NewForm1.topmost = false
dotnet.addeventhandler NewForm1 "closed" NewForm1_closed
--//--
NewForm1.controls.add NewPbar
--//--
for f in 1 to 7 do
(
NewForm1.controls.item[0].PerformStep()
)
--NewForm1.controls.item[0].ResetText()
--//--
NewForm1.ShowModeless()
)