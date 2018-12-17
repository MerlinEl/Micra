heapSize += 8000000 --12680000L old
dotNet.loadAssembly "C:\Program Files (x86)\Reference Assemblies\Microsoft\Framework\v3.0\WindowsFormsIntegration.dll"

rollout WpfMediaTest "WPFMediaElement" width:362 height:254
(
	local WPFme
	dotNetControl Ehost "Integration.ElementHost" pos:[3,2] width:358 height:212
	button btnPlay "Play" pos:[6,221] width:78 height:26 border:false
	button btnStop "Stop" pos:[87,221] width:78 height:26 border:false

	on WpfMediaTest open do 
	(
		Ehost.backcolor = (dotnetclass"System.drawing.color").black
		WpfMe= dotnetobject "System.Windows.Controls.MediaElement"
		local avi_file = (getdir #preview + "\\test_scene.avi")
		if doesFileExist avi_file do
		(
			local uri = dotnetobject "System.Uri" avi_file
			WpfMe.source = uri 
			--Ehost.child = WpfMe
			WpfMe.LoadedBehavior = WpfMe.LoadedBehavior.manual 
		)
	)
	on WPfMediatest close do 
	(
		WpfMe = undefined
		dgc = dotnetclass "system.gc"
		dgc.collect()
		gc() 
	) 
	on btnplay pressed do WpfMe.Play()
	on btnstop pressed do WpfMe.stop()
)
createdialog  WpfMediaTest