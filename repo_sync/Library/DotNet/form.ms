fo=dotNetObject "Form"
bu = dotnetobject "button"
mcsystem.show fo.dock
mcsystem.show fo.FormBorderStyle


mcTextBoxDialog.showModal()

(fo.GetType()).name == "Form"
(bu.getType()).name == "Button"
	
	
	fn onClosing s a = --onClosed
	(
		print "form exited"
	)
	fn onVisibleChanged s a = 
	(
		if s.Visible 
		then print "form opened"
		else print "form closed"
	)


mc_Dialog_D.show()
mc_Dialog_D.hide()
mc_Dialog_D.Visible

mc_Dialog_D.close()
mc_Dialog_D.dispose()
mc_Dialog_D.IsDisposed

mcSelectionHolderDialog3.Visible
mcSelectionHolderDialog1.location = dotNetobject "System.drawing.point" 200 200
mcSelectionHolderDialog1.location.tostring()


global dotNetForm
  
  struct dotNetFormStruct
   (
  	 -- Properties
  	testfrm= dotNetObject "Form",
  	btnTest = dotNetObject "Button",
  
  	 -- Event Handlers
  	 fn testButton control arg =
  	 (
  		 print control.text
  		 print dotNetForm.btnTest.text
  	 ),
   
  	 -- Normal functions
  	 fn print_btnStored =
  	 (
  		 print btnStored.text
  	 ),
  	  
  	 -- Interface
  	 fn init =
  	 (   
  		 
  		 testfrm.Size = dotNetObject "System.Drawing.Size" 100 100	  
  		 
  		 -- Init Button
  		 btnTest.text = "test button"
  		btnTest.location = dotNetobject "System.drawing.point" 2 2
  		 
  		 testfrm.controls.addRange(#(btnTest))
  		 
  		 -- Init Events
  		 dotNet.addEventHandler btnTest "click" testButton
  		 
  		 -- Show Form
  		 testfrm.show()
  	 ),
  	
  	initIt = init()
   )
   dotNetForm = dotNetFormStruct() 


(
	form = dotNetObject "form"
	mcsystem.show form
	form.Name = "Form1"
	form.Text = "Form1"
	form.backcolor = netDrColor blue
	--functions
	fn onOpenForm = ()
	fn onCloseForm = ()
	--handlers
	dotNet.addEventHandler form "Shown" onOpenForm
	dotNet.addEventHandler form "Closed" onCloseForm
	
	form.show()
	form.BringToFront()
	form.focus()
)

form.modal 
form.IsRestrictedWindow


mc2_Dialog_F.GetLifetimeService()
mc2_Dialog_F.Created 
(mc2_Dialog_F.DataBindings).count --items[0]
mc2_Dialog_F.HasChildren
mc2_Dialog_F.Owner
mc2_Dialog_F.Parent
mc2_Dialog_F.ParentForm

db = mc2_Dialog_F.CreateObjRef (dotnetClass "System.Type").FilterName.Clone() --<System.Type>requestedType
mc2_Dialog_F.CreateObjRef
mc2system.show (dotnetClass "System.Type").FilterName.Method.IsStatic 
(dotnetClass "System.Type").Assembly 

 --.<System.Runtime.Remoting.ObjRef>CreateObjRef <System.Type>requestedType

mc2_Dialog_F.GetType()

diag = dotnetclass "System.Diagnostics.Process"
wp = diag.GetProcessesByName "3Dsmax"

dotnetObject "IWin32Window" mc2_Dialog_F --this is sys 32 window

mc2_Dialog_F.Show --<System.Windows.Forms.IWin32Window>owner

mc2_Dialog_F.ValidateChildren()
mc2_Dialog_F.Update()
mc2_Dialog_F.Validate()




fooo = dotnetObject "form"
WindowWrapper = (dotnetobject "WindowWrapper" (windows.getMAXHWND()))
fooo.show(WindowWrapper)

