			fn onGotFocus = (enableAccelerators = false)
	fn onLostFocus = (enableAccelerators = true)
		
		dotNet.addEventHandler textBox1 "GotFocus" onGotFocus
		dotNet.addEventHandler textBox1 "LostFocus" onLostFocus
		
		
		
		
		enableAccelerators = true --set focus to viewport
		
		
rollout tbtest “MXS Dotnet texbox” width:227 height:23
 (
 dotnetcontrol textboxctrl “TextBox” pos:[1,1] width:225 height:16


on textboxctrl gotfocus sender arg do enableacellerators = false
 on textboxctrl lostfocus sender arg do enableacellerators = true
 )
 createdialog tbtest
		
		
		
Public Class MaxTextBox
 Inherits System.Windows.Forms.TextBox


Protected Overrides Sub OnGotFocus(ByVal e As System.EventArgs)
 ManagedServices.AppSDK.DisableAccelerators()
 End Sub

Protected Overrides Sub OnLostFocus(ByVal e As System.EventArgs)
 ManagedServices.AppSDK.EnableAccelerators()
 End Sub
 End Cla