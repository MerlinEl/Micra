fn compileAssembly src = (
	
	try (
		
		csharpProvider = dotnetobject "Microsoft.CSharp.CSharpCodeProvider"
		compilerParams = dotnetobject "System.CodeDom.Compiler.CompilerParameters"
		CompilerParams.ReferencedAssemblies.Add("System.dll")
		compilerParams.ReferencedAssemblies.Add("System.Windows.Forms.dll")
		CompilerParams.GenerateExecutable = true
		CompilerParams.GenerateInMemory = true
		compilerResults = csharpProvider.CompileAssemblyFromSource compilerParams #(src)
		compilerResults.CompiledAssembly
		
	) catch (
		
		format "Unable to compile Assembly:\n\t%\n"  (getCurrentException())
		undefined
	)
)

source = "using System.Windows.Forms;
class TransparentLabel : Label {
	static void Main() {
		
	}
	protected override CreateParams CreateParams {
		get {
			
			this.SetStyle(ControlStyles.OptimizedDoubleBuffer, false);
			const int WS_EX_TRANSPARENT = 0x20;
			CreateParams result = base.CreateParams;
			result.ExStyle = result.ExStyle | WS_EX_TRANSPARENT;
			return result;
		}
	}
	protected override void OnPaintBackground(PaintEventArgs pevent) {
	
	}
}"


fn TransparentLabelfn = (

    rollout test "test" width:400 (

		dotnetcontrol test "label" width:100 height:100 pos:[0,0]
		dotnetcontrol test2 "label" width:100 height:100 pos:[120,0]
		fn onButtonClick s e = (
			format "button click:%\n" s.name
			case s.name of (
				
				"btn_config": messagebox("button 1")
				"btn_config2": messagebox("button 2")
				default: print "error"
			)
		)
		on test open do (
			
			if dotnetClass  "TransparentLabel" == undefined do compileAssembly source
			local colors = DotNetClass "System.Drawing.Color"
			local img = (dotNetClass "System.Drawing.Image")
			local pathImg_Config = img.fromFile(micra.ImagesPath + "DirFile.bmp")
			local pathImg_Config2 = img.fromFile(micra.ImagesPath + "DirRoot.bmp")
			button_Config= dotnetobject "TransparentLabel"
			button_Config.name="btn_config"
			button_Config.dock=button_Config.dock.fill
			button_Config.image = pathImg_Config
			test.controls.add button_Config
			dotNet.addEventHandler button_Config "click" onButtonClick
			test.backColor = colors.fromArgb 0 255 255

			button_Config2=dotnetobject  "TransparentLabel"
			button_Config2.name="btn_config2"
			button_Config2.dock=button_Config2.dock.fill
			button_Config2.image = pathImg_Config2
			test2.controls.add button_Config2
			dotNet.addEventHandler button_Config2 "click" onButtonClick
			test2.backColor = colors.fromArgb 255 0 0
			
			dnToolTip = dotnetobject "tooltip"
			dnToolTip.AutoPopDelay = 5000
			dnToolTip.InitialDelay = 300
			dnToolTip.ReshowDelay = 300
			dnToolTip.ShowAlways = true
			dnToolTip.settooltip button_Config "test"
			dnToolTip.settooltip button_Config2 "test2"
		)
	)
	createdialog test
)
TransparentLabelfn()
