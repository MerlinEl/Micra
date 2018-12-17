cd_1 = dotNetObject "System.Windows.Forms.ColorDialog"
cd_1.FullOpen = true
cd_1.AnyColor = true
cd_1.AllowFullOpen = true
cd_1.SolidColorOnly = true
cd_1.ShowDialog()    
cd_1.color
         -----------------
------------------------          
          (
          	local MAX_color = black
          	local DotNET_Color = (dotNetClass "System.Drawing.Color").fromARGB 0 0 0
          	
          	dN_UI = dotNetObject "System.Windows.Forms.Form"
          		dN_UI.text = "Color testing"
          		dN_UI.width = 200
          		dN_UI.height = 300
          		dN_UI.topMost = true
          		dN_UI.showIcon = false
          
          		btn_1 = dotNetObject "System.Windows.Forms.Button"
          			btn_1.size = dotNetObject "System.Drawing.Size" 120 50
          			btn_1.name = "btn_1"
          			btn_1.location = dotNetObject "System.Drawing.Point" 20 150
          			btn_1.backColor = (dotNetClass "System.Drawing.Color").Green
          
          		cd_1 = dotNetObject "System.Windows.Forms.ColorDialog"
          			cd_1.Color = (dotNetClass "System.Drawing.Color").AliceBlue
       			cd_1.FullOpen = true
       			cd_1.AnyColor = true
       			cd_1.AllowFullOpen = true
       
          	dN_UI.controls.add(btn_1)
          	
          	fn btn_mouseUp senderArg eventArg =
          	(
          		
          		senderArg.Focus()
          			case (senderArg.Name) of
          			(
          				"btn_1":
          				(
          					if (eventArg.button == eventArg.button.left) do
          					(
          						cd_1.ShowDialog()
          						DotNET_Color = (dotNetClass "System.Drawing.Color").fromARGB cd_1.Color.r cd_1.Color.g cd_1.Color.b
          						btn_1.backColor = DotNET_Color
          						dN_Color = btn_1.backColor
          						MAX_color = color (dn_Color.r) (dn_Color.g) (dn_Color.b)
          						selection.wirecolor = MAX_Color
          					) -- end if
          
          					if (eventArg.button == eventArg.button.right) do
          					(
          						selection.wirecolor = MAX_Color
          					) -- end if
          					
          				) -- 1
          				
          			) -- end case
          			
          	) --
          	
          	dotNet.addEventHandler btn_1 "mouseUp" btn_mouseUp
        
          dN_UI.Show()
          )





------------------

------------------------






This i implemented in vb .net 2005 and the codes are below
But here the colors are displayed in the form itself , i need to select
anywhere from the desktop

Imports System
Imports System.Runtime.InteropServices
Imports System.Drawing
Imports System.Collections
Imports System.ComponentModel
Imports System.Windows.Forms
Imports System.Data
Public Class Form1
Inherits System.Windows.Forms.Form
<DllImport("Gdi32.dll")> Public Shared Function GetPixel(ByVal hdc
As System.IntPtr, ByVal nXPos As Integer, ByVal nYPos As Integer) As
Integer
End Function
<DllImport("User32.dll")> Public Shared Function GetDC(ByVal wnd As
IntPtr) As IntPtr
End Function
<DllImport("User32.dll")> Public Shared Sub ReleaseDC(ByVal dc As
IntPtr)
End Sub
Private panel1 As System.Windows.Forms.Panel
Private WithEvents timer1 As System.Timers.Timer
Private Sub Form1_Load(ByVal sender As System.Object, ByVal e As
System.EventArgs) Handles MyBase.Load
Me.panel1 = New System.Windows.Forms.Panel
Me.timer1 = New System.Timers.Timer
CType(Me.timer1,
System.ComponentModel.ISupportInitialize).BeginInit()
Me.SuspendLayout()
'
'panel1
'
Me.panel1.BorderStyle =
System.Windows.Forms.BorderStyle.Fixed3D
Me.panel1.Location = New System.Drawing.Point(216, 8)
Me.panel1.Name = "panel1"
Me.panel1.Size = New System.Drawing.Size(64, 56)
Me.panel1.TabIndex = 0
'
'timer1
'
Me.timer1.Enabled = True
Me.timer1.SynchronizingObject = Me
'
'Form1
'
Me.AutoScaleBaseSize = New System.Drawing.Size(5, 13)
Me.BackColor = System.Drawing.Color.White
Me.ClientSize = New System.Drawing.Size(292, 273)
Me.Controls.Add(Me.panel1)
Me.Name = "Form1"
Me.Text = "Form1"
CType(Me.timer1,
System.ComponentModel.ISupportInitialize).EndInit()
Me.ResumeLayout(False)
End Sub
Private Sub Form1_Paint(ByVal sender As Object, ByVal e As
System.Windows.Forms.PaintEventArgs) Handles MyBase.Paint
Dim r As New Random(1)
Dim x As Integer
For x = 0 To 99
Dim b As New SolidBrush(Color.FromArgb(r.Next(255),
r.Next(255), r.Next(255)))
e.Graphics.FillRectangle(b, r.Next(Me.ClientSize.Width),
r.Next(Me.ClientSize.Height), r.Next(100), r.Next(100))
Next x
End Sub
Protected Overrides Sub OnMouseMove(ByVal e As MouseEventArgs)
Dim g As Graphics = Me.CreateGraphics()
Dim myDC As IntPtr = g.GetHdc()
Dim c As Color = ColorTranslator.FromWin32(GetPixel(myDC, e.X,
e.Y))
g.ReleaseHdc(myDC)
Me.panel1.BackColor = c
End Sub 'OnMouseMove
End Class



Help me , for that what i should do

Thanks
Sajin