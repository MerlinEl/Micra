ctrl.SetChildIndex itm80 80
ctrl.getChildIndex itm0
itm80.text

--=================================================
--find place to be pushed
--=================================================	
ctrl = mcDgalleryDialog.tag.value.flp_cat.controls	
itm_80 =ctrl.item 80
items = for i=0 to ctrl.count-1 collect (ctrl.item i)
texts = for t in items collect t.text
print texts	

fn textArrayCompare a b = 
(
	local lvl = for i=1 to a.count do if a[i] != b[i] do exit with i  --search lethers one by one and exit if is different or "B" is undefined
	if classOf lvl != integer do return 0 -- if both is same (they not moving anywhere)
	if b[lvl] == undefined do return 1 --( "A" is moving forward )
	
	if a[lvl] > b[lvl] then 1
	else if a[lvl] < b[lvl] do -1
)
qsort texts textArrayCompare

new_pos = findItem texts "novy"
ctrl.SetChildIndex (itm_80) (new_pos-2)
ctrl.SetChildIndex (itm_80) 80

--=================================================
--get items, resort and push them back
--=================================================
fn itemTextArrayCompare a b = 
(
	local t1 = toLower a.text, t2 = toLower b.text
	local lvl = for i=1 to t1.count do if t1[i] != t2[i] do exit with i  --search lethers from begin and exit if is diferent
	if classOf lvl != integer do return 0 -- if both is same (they not moving anywhere)
		
	if t2[lvl] == undefined do return 1 --( T1 is moving forward )
	
	if t1[lvl] < t2[lvl] then return -1 --( T1 is moving backward )
	else if t1[lvl] > t2[lvl] then return 1	 --( T1 is moving forward )
)
qsort items itemTextArrayCompare

for i=0 to ctrl.count-1 do print (ctrl.item i).text
mcDgalleryDialog.tag.value.flp_cat.controls.clear()
mcDgalleryDialog.tag.value.flp_cat.controls.addRange items
--=================================================

--=================================================

try(destroydialog materialib_rollout) catch()
rollout materialib_rollout "test-25" width:650 height:412
(
	dotNetControl FLP "System.Windows.Forms.FlowLayoutPanel" pos:[185,16] width:430 height:359
	fn onClick sender arg = 
	(
		sender.BackColor =(DotNetClass "System.Drawing.Color").fromARGB 180 180 180
		format "% \"%\"\n" sender.tag sender.text
	)
	 
	on materialib_rollout open do
	( 
		FLP.controls.clear()
		for k=1 to 10 do 
		(
			bt = dotNetobject "System.Windows.Forms.Button"
			bt.text = ("N " + k as string)
			bt.tag = k 
			dotnet.addeventhandler bt "Click" onClick
			FLP.Controls.Add bt 
		)
	)
)
createdialog materialib_rollout




"---------------------------------------------------------------------------"
Info:dotNetObject:System.Windows.Forms.FlowLayoutPanel
"---------------------------------------------------------------------------"
ClassOf: dotNetObject
SuperClassOf: Value
No ShowClass for dotNetObject:System.Windows.Forms.FlowLayoutPanel
No Show for dotNetObject:System.Windows.Forms.FlowLayoutPanel
  .AccessibilityObject : <System.Windows.Forms.AccessibleObject>, read-only
  .AccessibleDefaultActionDescription : <System.String>
  .AccessibleDescription : <System.String>
  .AccessibleName : <System.String>
  .AccessibleRole : <System.Windows.Forms.AccessibleRole>
  .AllowDrop : <System.Boolean>
  .Anchor : <System.Windows.Forms.AnchorStyles>
  .AutoScroll : <System.Boolean>
  .AutoScrollMargin : <System.Drawing.Size>
  .AutoScrollMinSize : <System.Drawing.Size>
  .AutoScrollOffset : <System.Drawing.Point>
  .AutoScrollPosition : <System.Drawing.Point>
  .AutoSize : <System.Boolean>
  .AutoSizeMode : <System.Windows.Forms.AutoSizeMode>
  .BackColor : <System.Drawing.Color>
  .BackgroundImage : <System.Drawing.Image>
  .BackgroundImageLayout : <System.Windows.Forms.ImageLayout>
  .BindingContext : <System.Windows.Forms.BindingContext>
  .BorderStyle : <System.Windows.Forms.BorderStyle>
  .Bottom : <System.Int32>, read-only
  .Bounds : <System.Drawing.Rectangle>
  .CanFocus : <System.Boolean>, read-only
  .CanSelect : <System.Boolean>, read-only
  .Capture : <System.Boolean>
  .CausesValidation : <System.Boolean>
  .CheckForIllegalCrossThreadCalls : <System.Boolean>, static
  .ClientRectangle : <System.Drawing.Rectangle>, read-only
  .ClientSize : <System.Drawing.Size>
  .CompanyName : <System.String>, read-only
  .Container : <System.ComponentModel.IContainer>, read-only
  .ContainsFocus : <System.Boolean>, read-only
  .ContextMenu : <System.Windows.Forms.ContextMenu>
  .ContextMenuStrip : <System.Windows.Forms.ContextMenuStrip>
  .Controls : <System.Windows.Forms.Control+ControlCollection>, read-only
  .Created : <System.Boolean>, read-only
  .Cursor : <System.Windows.Forms.Cursor>
  .DataBindings : <System.Windows.Forms.ControlBindingsCollection>, read-only
  .DefaultBackColor : <System.Drawing.Color>, read-only, static
  .DefaultFont : <System.Drawing.Font>, read-only, static
  .DefaultForeColor : <System.Drawing.Color>, read-only, static
  .DisplayRectangle : <System.Drawing.Rectangle>, read-only
  .Disposing : <System.Boolean>, read-only
  .Dock : <System.Windows.Forms.DockStyle>
  .DockPadding : <System.Windows.Forms.ScrollableControl+DockPaddingEdges>, read-only
  .Enabled : <System.Boolean>
  .FlowDirection : <System.Windows.Forms.FlowDirection>
  .Focused : <System.Boolean>, read-only
  .Font : <System.Drawing.Font>
  .ForeColor : <System.Drawing.Color>
  .Handle : <System.IntPtr>, read-only
  .HasChildren : <System.Boolean>, read-only
  .Height : <System.Int32>
  .HorizontalScroll : <System.Windows.Forms.HScrollProperties>, read-only
  .ImeMode : <System.Windows.Forms.ImeMode>
  .InvokeRequired : <System.Boolean>, read-only
  .IsAccessible : <System.Boolean>
  .IsDisposed : <System.Boolean>, read-only
  .IsHandleCreated : <System.Boolean>, read-only
  .IsMirrored : <System.Boolean>, read-only
  .LayoutEngine : <System.Windows.Forms.Layout.LayoutEngine>, read-only
  .Left : <System.Int32>
  .Location : <System.Drawing.Point>
  .Margin : <System.Windows.Forms.Padding>
  .MaximumSize : <System.Drawing.Size>
  .MinimumSize : <System.Drawing.Size>
  .ModifierKeys : <System.Windows.Forms.Keys>, read-only, static
  .MouseButtons : <System.Windows.Forms.MouseButtons>, read-only, static
  .MousePosition : <System.Drawing.Point>, read-only, static
  .Name : <System.String>
  .Padding : <System.Windows.Forms.Padding>
  .Parent : <System.Windows.Forms.Control>
  .PreferredSize : <System.Drawing.Size>, read-only
  .ProductName : <System.String>, read-only
  .ProductVersion : <System.String>, read-only
  .RecreatingHandle : <System.Boolean>, read-only
  .Region : <System.Drawing.Region>
  .Right : <System.Int32>, read-only
  .RightToLeft : <System.Windows.Forms.RightToLeft>
  .Site : <System.ComponentModel.ISite>
  .Size : <System.Drawing.Size>
  .TabIndex : <System.Int32>
  .TabStop : <System.Boolean>
  .Tag : <System.Object>
  .Text : <System.String>
  .Top : <System.Int32>
  .TopLevelControl : <System.Windows.Forms.Control>, read-only
  .UseWaitCursor : <System.Boolean>
  .VerticalScroll : <System.Windows.Forms.VScrollProperties>, read-only
  .Visible : <System.Boolean>
  .Width : <System.Int32>
  .WindowTarget : <System.Windows.Forms.IWindowTarget>
  .WrapContents : <System.Boolean>
PROPERTIES:
  .<System.IAsyncResult>BeginInvoke <System.Delegate>method
  .<System.IAsyncResult>BeginInvoke <System.Delegate>method <System.Object[]>args
  .BringToFront()
  .<System.Boolean>Contains <System.Windows.Forms.Control>ctl
  .CreateControl()
  .<System.Drawing.Graphics>CreateGraphics()
  .<System.Runtime.Remoting.ObjRef>CreateObjRef <System.Type>requestedType
  .Dispose()
  .<System.Windows.Forms.DragDropEffects>DoDragDrop <System.Object>data <System.Windows.Forms.DragDropEffects>allowedEffects
  .DrawToBitmap <System.Drawing.Bitmap>bitmap <System.Drawing.Rectangle>targetBounds
  .<System.Object>EndInvoke <System.IAsyncResult>asyncResult
  .<System.Boolean>Equals <System.Object>obj
  .[static]<System.Boolean>Equals <System.Object>objA <System.Object>objB
  .<System.Windows.Forms.Form>FindForm()
  .<System.Boolean>Focus()
  .[static]<System.Windows.Forms.Control>FromChildHandle <System.IntPtr>handle
  .[static]<System.Windows.Forms.Control>FromHandle <System.IntPtr>handle
  .<System.Windows.Forms.Control>GetChildAtPoint <System.Drawing.Point>pt
  .<System.Windows.Forms.Control>GetChildAtPoint <System.Drawing.Point>pt <System.Windows.Forms.GetChildAtPointSkip>skipValue
  .<System.Windows.Forms.IContainerControl>GetContainerControl()
  .<System.Boolean>GetFlowBreak <System.Windows.Forms.Control>control
  .<System.Int32>GetHashCode()
  .<System.Object>GetLifetimeService()
  .<System.Windows.Forms.Control>GetNextControl <System.Windows.Forms.Control>ctl <System.Boolean>forward
  .<System.Drawing.Size>GetPreferredSize <System.Drawing.Size>proposedSize
  .<System.Type>GetType()
  .Hide()
  .<System.Object>InitializeLifetimeService()
  .Invalidate()
  .Invalidate <System.Drawing.Region>region
  .Invalidate <System.Drawing.Rectangle>rc
  .Invalidate <System.Boolean>invalidateChildren
  .Invalidate <System.Drawing.Rectangle>rc <System.Boolean>invalidateChildren
  .Invalidate <System.Drawing.Region>region <System.Boolean>invalidateChildren
  .<System.Object>Invoke <System.Delegate>method
  .<System.Object>Invoke <System.Delegate>method <System.Object[]>args
  .[static]<System.Boolean>IsKeyLocked <System.Windows.Forms.Keys>keyVal
  .[static]<System.Boolean>IsMnemonic <System.Char>charCode <System.String>text
  .PerformLayout()
  .PerformLayout <System.Windows.Forms.Control>affectedControl <System.String>affectedProperty
  .<System.Drawing.Point>PointToClient <System.Drawing.Point>p
  .<System.Drawing.Point>PointToScreen <System.Drawing.Point>p
  .<System.Windows.Forms.PreProcessControlState>PreProcessControlMessage <System.Windows.Forms.Message&>msg
  .<System.Boolean>PreProcessMessage <System.Windows.Forms.Message&>msg
  .<System.Drawing.Rectangle>RectangleToClient <System.Drawing.Rectangle>r
  .<System.Drawing.Rectangle>RectangleToScreen <System.Drawing.Rectangle>r
  .[static]<System.Boolean>ReferenceEquals <System.Object>objA <System.Object>objB
  .Refresh()
  .ResetBackColor()
  .ResetBindings()
  .ResetCursor()
  .ResetFont()
  .ResetForeColor()
  .ResetImeMode()
  .ResetRightToLeft()
  .ResetText()
  .ResumeLayout()
  .ResumeLayout <System.Boolean>performLayout
  .Scale <System.Drawing.SizeF>factor
  .Scale <System.Single>ratio
  .Scale <System.Single>dx <System.Single>dy
  .ScrollControlIntoView <System.Windows.Forms.Control>activeControl
  .Select()
  .<System.Boolean>SelectNextControl <System.Windows.Forms.Control>ctl <System.Boolean>forward <System.Boolean>tabStopOnly <System.Boolean>nested <System.Boolean>wrap
  .SendToBack()
  .SetAutoScrollMargin <System.Int32>x <System.Int32>y
  .SetBounds <System.Int32>x <System.Int32>y <System.Int32>width <System.Int32>height
  .SetBounds <System.Int32>x <System.Int32>y <System.Int32>width <System.Int32>height <System.Windows.Forms.BoundsSpecified>specified
  .SetFlowBreak <System.Windows.Forms.Control>control <System.Boolean>value
  .Show()
  .SuspendLayout()
  .<System.String>ToString()
  .Update()
METHODS:
   on <control_name> AutoSizeChanged <System.EventArgs>e do ( ... )
   on <control_name> BackColorChanged <System.EventArgs>e do ( ... )
   on <control_name> BackgroundImageChanged <System.EventArgs>e do ( ... )
   on <control_name> BackgroundImageLayoutChanged <System.EventArgs>e do ( ... )
   on <control_name> BindingContextChanged <System.EventArgs>e do ( ... )
   on <control_name> CausesValidationChanged <System.EventArgs>e do ( ... )
   on <control_name> ChangeUICues <System.Windows.Forms.UICuesEventArgs>e do ( ... )
   on <control_name> Click <System.EventArgs>e do ( ... )
   on <control_name> ClientSizeChanged <System.EventArgs>e do ( ... )
   on <control_name> ContextMenuChanged <System.EventArgs>e do ( ... )
   on <control_name> ContextMenuStripChanged <System.EventArgs>e do ( ... )
   on <control_name> ControlAdded <System.Windows.Forms.ControlEventArgs>e do ( ... )
   on <control_name> ControlRemoved <System.Windows.Forms.ControlEventArgs>e do ( ... )
   on <control_name> CursorChanged <System.EventArgs>e do ( ... )
   on <control_name> Disposed <System.EventArgs>e do ( ... )
   on <control_name> DockChanged <System.EventArgs>e do ( ... )
   on <control_name> DoubleClick <System.EventArgs>e do ( ... )
   on <control_name> DragDrop <System.Windows.Forms.DragEventArgs>e do ( ... )
   on <control_name> DragEnter <System.Windows.Forms.DragEventArgs>e do ( ... )
   on <control_name> DragLeave <System.EventArgs>e do ( ... )
   on <control_name> DragOver <System.Windows.Forms.DragEventArgs>e do ( ... )
   on <control_name> EnabledChanged <System.EventArgs>e do ( ... )
   on <control_name> Enter <System.EventArgs>e do ( ... )
   on <control_name> FontChanged <System.EventArgs>e do ( ... )
   on <control_name> ForeColorChanged <System.EventArgs>e do ( ... )
   on <control_name> GiveFeedback <System.Windows.Forms.GiveFeedbackEventArgs>e do ( ... )
   on <control_name> GotFocus <System.EventArgs>e do ( ... )
   on <control_name> HandleCreated <System.EventArgs>e do ( ... )
   on <control_name> HandleDestroyed <System.EventArgs>e do ( ... )
   on <control_name> HelpRequested <System.Windows.Forms.HelpEventArgs>hlpevent do ( ... )
   on <control_name> ImeModeChanged <System.EventArgs>e do ( ... )
   on <control_name> Invalidated <System.Windows.Forms.InvalidateEventArgs>e do ( ... )
   on <control_name> KeyDown <System.Windows.Forms.KeyEventArgs>e do ( ... )
   on <control_name> KeyPress <System.Windows.Forms.KeyPressEventArgs>e do ( ... )
   on <control_name> KeyUp <System.Windows.Forms.KeyEventArgs>e do ( ... )
   on <control_name> Layout <System.Windows.Forms.LayoutEventArgs>e do ( ... )
   on <control_name> Leave <System.EventArgs>e do ( ... )
   on <control_name> LocationChanged <System.EventArgs>e do ( ... )
   on <control_name> LostFocus <System.EventArgs>e do ( ... )
   on <control_name> MarginChanged <System.EventArgs>e do ( ... )
   on <control_name> MouseCaptureChanged <System.EventArgs>e do ( ... )
   on <control_name> MouseClick <System.Windows.Forms.MouseEventArgs>e do ( ... )
   on <control_name> MouseDoubleClick <System.Windows.Forms.MouseEventArgs>e do ( ... )
   on <control_name> MouseDown <System.Windows.Forms.MouseEventArgs>e do ( ... )
   on <control_name> MouseEnter <System.EventArgs>e do ( ... )
   on <control_name> MouseHover <System.EventArgs>e do ( ... )
   on <control_name> MouseLeave <System.EventArgs>e do ( ... )
   on <control_name> MouseMove <System.Windows.Forms.MouseEventArgs>e do ( ... )
   on <control_name> MouseUp <System.Windows.Forms.MouseEventArgs>e do ( ... )
   on <control_name> MouseWheel <System.Windows.Forms.MouseEventArgs>e do ( ... )
   on <control_name> Move <System.EventArgs>e do ( ... )
   on <control_name> PaddingChanged <System.EventArgs>e do ( ... )
   on <control_name> Paint <System.Windows.Forms.PaintEventArgs>e do ( ... )
   on <control_name> ParentChanged <System.EventArgs>e do ( ... )
   on <control_name> PreviewKeyDown <System.Windows.Forms.PreviewKeyDownEventArgs>e do ( ... )
   on <control_name> QueryAccessibilityHelp <System.Windows.Forms.QueryAccessibilityHelpEventArgs>e do ( ... )
   on <control_name> QueryContinueDrag <System.Windows.Forms.QueryContinueDragEventArgs>e do ( ... )
   on <control_name> RegionChanged <System.EventArgs>e do ( ... )
   on <control_name> Resize <System.EventArgs>e do ( ... )
   on <control_name> RightToLeftChanged <System.EventArgs>e do ( ... )
   on <control_name> Scroll <System.Windows.Forms.ScrollEventArgs>e do ( ... )
   on <control_name> SizeChanged <System.EventArgs>e do ( ... )
   on <control_name> StyleChanged <System.EventArgs>e do ( ... )
   on <control_name> SystemColorsChanged <System.EventArgs>e do ( ... )
   on <control_name> TabIndexChanged <System.EventArgs>e do ( ... )
   on <control_name> TabStopChanged <System.EventArgs>e do ( ... )
   on <control_name> TextChanged <System.EventArgs>e do ( ... )
   on <control_name> Validated <System.EventArgs>e do ( ... )
   on <control_name> Validating <System.ComponentModel.CancelEventArgs>e do ( ... )
   on <control_name> VisibleChanged <System.EventArgs>e do ( ... )
   
   
   
   
   
   --Troubleshoting
   
   
   --Flickering 
   Public Class CustomFlowLayoutPanel
    Inherits FlowLayoutPanel

    Public Sub New()
        MyBase.New()

        SetStyle(ControlStyles.UserPaint, True)
        SetStyle(ControlStyles.AllPaintingInWmPaint, True)
        SetStyle(ControlStyles.DoubleBuffer, True)

    End Sub
	
	--answer
	See calling SuspendLayout() for the panel before adding controls to it and then call ResumeLayout() on the Panel . You may loose that flicker a bit
	
	
	
	
	
--Zpocátku jsme se všechny ovládací prvky RadioButton typu, které existují v rámci FlowLayoutPanel.
--Potom použijte rozšírení LINQ metoda, aby se ujistete se, že položky na základe hodnoty majetku text.
--A v závislosti na zpusobu (OrderBy nebo OrderByDescending) dostaneme ovládací prvky v poradí urceném delegát (x => x.Text).
	
	public partial class Form1 : Form
{
    public Form1()
    {
        InitializeComponent();
        this.Load += new EventHandler(Form1_Load);
    }

    void Form1_Load(object sender, EventArgs e)
    {
        var radioBtns = flowLayoutPanel1.Controls.OfType<RadioButton>().OrderBy(x => x.Text).ToArray();
        flowLayoutPanel1.Controls.Clear();
        flowLayoutPanel1.Controls.AddRange(radioBtns);
    }
    bool _IsAsc = false;
    private void button1_Click(object sender, EventArgs e)
    {
        RadioButton[ ] radioBtns;

        if (_IsAsc)
        {
            radioBtns = flowLayoutPanel1.Controls.OfType<RadioButton>().OrderBy(x => x.Text).ToArray();
        }
        else
        {
            radioBtns = flowLayoutPanel1.Controls.OfType<RadioButton>().OrderByDescending(x => x.Text).ToArray();
        }
        _IsAsc = !_IsAsc;
        flowLayoutPanel1.Controls.Clear();
        flowLayoutPanel1.Controls.AddRange(radioBtns);
    }
}
 