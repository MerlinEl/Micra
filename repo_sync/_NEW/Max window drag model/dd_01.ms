--catch file or item dropped on max window
--print file path

 global WindowHooker
 fn CreateDropFileHooker forceRecompile:on = if forceRecompile do
 (
 
 source = ""
 source += "using System;
"
 source += "using System.Runtime.InteropServices;
"
 source += "using System.Text;
"
 source += "using System.Windows.Forms;
"
 source += "public class DropFileHooker : NativeWindow
"
 source += "{
"
 source += "	private const int WM_DROPFILES = 0x0233;
"
 source += "	private const int MAX_PATH = 260;
"
 source += "	public DropFileHooker() { }
"
 source += "	public class MessageEventArgs : EventArgs
"
 source += "	{
"
 source += "		public MessageEventArgs(Message message, string [] files)
"
 source += "		{
"
 source += "			Message = message;
"
 source += "			Files = files;
"
 source += "			Handled = false;
"
 source += "		}
"
 source += "		public readonly Message Message;
"
 source += "		public readonly string[] Files;
"
 source += "		public bool Handled = false;
"
 source += "	}
"
 source += "	public event EventHandler MessageReceived;
"
 source += "	protected override void WndProc(ref Message message)
"
 source += "	{
"
 source += "		switch (message.Msg)
"
 source += "		{
"
 source += "			case WM_DROPFILES:
"
 source += "				IntPtr hDrop = message.WParam;
"
 source += "				//string FileName = null;
"
 source += "				uint FilesDropped = DragQueryFile(hDrop, -1, null, 0);
"
 source += "				string[] Files = new string[FilesDropped];
"
 source += "				if (FilesDropped != 0)
"
 source += "				{
"
 source += "					StringBuilder sFileName = new StringBuilder(MAX_PATH);
"
 source += "					for (int i = 0; i < FilesDropped; i++)
"
 source += "					{
"
 source += "						DragQueryFile(hDrop, i, sFileName, MAX_PATH);
"
 source += "						Files[i] = sFileName.ToString().ToLower();
"
 source += "					}
"
 source += "				}
"
 source += "				MessageEventArgs arg = new MessageEventArgs(message, Files);
"
 source += "				MessageReceived(this, arg);
"
 source += "				if (arg.Handled)
"
 source += "				{
"
 source += "					DragFinish(hDrop);
"
 source += "				}
"
 source += "				break;
"
 source += "			default:
"
 source += "				break;
"
 source += "		}
"
 source += "		base.WndProc(ref message);
"
 source += "	}
"
 source += "	[DllImport(\"shell32.dll\")]
"
 source += "	static extern uint DragQueryFile(IntPtr hDrop, int iFile, [Out] StringBuilder lpszFile, uint cch);
"
 source += "	[DllImport(\"shell32.dll\")]
"
 source += "	static extern uint DragFinish(IntPtr hDrop);
"
 source += "}
"
 
 	csharpProvider = dotnetobject "Microsoft.CSharp.CSharpCodeProvider"
 	compilerParams = dotnetobject "System.CodeDom.Compiler.CompilerParameters"
 
 	compilerParams.ReferencedAssemblies.AddRange #("System.dll", "System.Windows.Forms.dll")
 
 	compilerParams.GenerateInMemory = true
 	compilerResults = csharpProvider.CompileAssemblyFromSource compilerParams #(source)
 		
 	WindowHooker = compilerResults.CompiledAssembly
 )
 CreateDropFileHooker()
 
 (
 	global hooker = WindowHooker.createInstance "DropFileHooker"
 	fn onMessageReceived s e =
 	(
 		format "here: %\n" e.files 
 		if e.files.count > 1 do e.Handled = on
 	)
 	dotnet.removeAllEventHandlers hooker
 	dotnet.addEventHandler hooker "MessageReceived" onMessageReceived
 	
/*
	hooker.ReleaseHandle() -- DON'T FORGET TO RELEASE
*/
 	hooker.AssignHandle (dotnetobject "IntPtr" (windows.getMAXHWND()))
 )
 
 
 
 /*
 blueprints
 here: #("d:\!2k_games\scotch_dev\edit\blueprints\env_generic\backyards\bc_tricycle_bv01.ires")
 model
here: #("d:\!2k_games\scotch_dev\edit\models\templates\staticentity\template_staticentity_bc_shelter_d_0.ires")
 */