-- Create buttons at routime
(
	try form.close() catch()
	form = dotnetObject "Form"
	components = (dotnetObject "System.ComponentModel.Container").Components
	
	--Clean up any resources being used
	if components.count != 0 do components.Dispose()
	--region Windows Form Designer generated code
	fn button1Click s a =
	(
		--This is the generate button routine
		al = dotnetObject "System.Collections.ArrayList"

		--get all buttons except first one
		for i = 0 to form.controls.count-1 do 
		(
			itm = form.controls.item[i]
			if (itm.GetType()).ToString() == "System.Windows.Forms.Button" and itm.name != "button1" do 
			(
				al.add( itm )
			)
		)
		
		--remove all buttons except first one
		for i = 0 to al.count-1 do form.controls.Remove al.Item[ i ]
		
		--Resize to start size
		form.Size = dotNetObject "System.Drawing.Size" 248 80
		
		--First one is columns
		columns = if textBox1.Text as integer != undefined then textBox1.Text as integer else 0
		rows    = if textBox2.Text as integer != undefined then textBox1.Text as integer else 0
		locX = 16
		locY = 56
		--We assume space between is 20
		for i = 0 to columns * rows do
		(
			b = dotNetObject "Button"
			b.Name = "b" + i as String
			b.Size = dotNetObject "System.Drawing.Size" 10 10
			b.Location = dotnetObject "System.Drawing.Point" locX locY
			
			if mod (i+1) columns == 0 
			then
			(
				locX = 16
				locY += b.Height + 20
			)
			else
			(
				locX += b.Width + 20
			)
			dotNet.addEventHandler b "Click" button1Click
			form.Controls.Add(b)
			
			if ((b.Location.X + b.Width) > form.Width) do
			(
				form.Width += ((b.Location.X + b.Width) - form.Width) + 10
			)
			if ((b.Location.Y + b.Height) > form.Height) do
			(
				form.Height += ((b.Location.Y + b.Height) - form.Height) + 10
			)
		)
	)
	
	fn InitializeComponent =
	(
		textBox1 = dotnetObject "TextBox"
		textBox2 = dotnetObject "TextBox"
		button1 = dotnetObject "Button"
		form.SuspendLayout()
		
		-- textBox1
		textBox1.Location = dotnetObject "System.Drawing.Point" 16 16
		textBox1.Name = "textBox1"
		textBox1.Size = dotnetObject "System.Drawing.Size" 48  20 
		textBox1.TabIndex = 0
		textBox1.Text = "4"
		
		-- textBox2
		textBox2.Location = dotnetObject "System.Drawing.Point" 72 16
		textBox2.Name = "textBox2"
		textBox2.Size = dotnetObject "System.Drawing.Size" 56 20
		textBox2.TabIndex = 1
		textBox2.Text = "8"
		
		-- button1
		button1.Location = dotnetObject "System.Drawing.Point" 152 16
		button1.Name = "button1"
		button1.TabIndex = 2
		button1.Text = "button1"
		dotNet.addEventHandler button1 "Click" button1Click
		
		-- Form1
		form.AutoScaleBaseSize = dotnetObject "System.Drawing.Size" 5 13
		form.ClientSize = dotnetObject "System.Drawing.Size" 240  46
		
		form.Controls.Add(button1)
		form.Controls.Add(textBox2)
		form.Controls.Add(textBox1)

		form.Name = "Form1"
		form.Text = "Form1"
		form.ResumeLayout(false)

	) 
	InitializeComponent()
	form.show()
)

/*
C# Syntax (Toggle Plain Text)  //r0ckbaer
using System;
using SystemDrawing;
using SystemCollections;
	using SystemComponentModel;
	using SystemWindowsForms;
	using SystemData;
	using SystemTextRegularExpressions;
	 
	namespace WindowsApplication1
	{
		/// <summary>
		/// Summary description for Form1
		/// </summary>
		public class Form1 : SystemWindowsFormsForm
		{
			private SystemWindowsFormsTextBox textBox1;
			private SystemWindowsFormsTextBox textBox2;
			private SystemWindowsFormsButton button1;
			/// <summary>
			/// Required designer variable
			/// </summary>
			private SystemComponentModelContainer components = null;
	 
			public Form1()
			{
				//
				// Required for Windows Form Designer support
				//
				InitializeComponent();
	 
				//
				// TODO: Add any constructor code after InitializeComponent call
				//
			}
	 
			/// <summary>
			/// Clean up any resources being used
			/// </summary>
			protected override void Dispose( bool disposing )
			{
				if( disposing )
				{
					if (components != null) 
					{
						componentsDispose();
					}
				}
				baseDispose( disposing );
			}
	 
			#region Windows Form Designer generated code
			/// <summary>
			/// Required method for Designer support - do not modify
			/// the contents of this method with the code editor
			/// </summary>
			private void InitializeComponent()
			{
				thistextBox1 = new SystemWindowsFormsTextBox();
				thistextBox2 = new SystemWindowsFormsTextBox();
				thisbutton1 = new SystemWindowsFormsButton();
				thisSuspendLayout();
				// 
				// textBox1
				// 
				thistextBox1Location = new SystemDrawingPoint(16, 16);
				thistextBox1Name = "textBox1";
				thistextBox1Size = new SystemDrawingSize(48, 20);
				thistextBox1TabIndex = 0;
				thistextBox1Text = "textBox1";
				// 
				// textBox2
				// 
				thistextBox2Location = new SystemDrawingPoint(72, 16);
				thistextBox2Name = "textBox2";
				thistextBox2Size = new SystemDrawingSize(56, 20);
				thistextBox2TabIndex = 1;
				thistextBox2Text = "textBox2";
				// 
				// button1
				// 
				thisbutton1Location = new SystemDrawingPoint(152, 16);
				thisbutton1Name = "button1";
				thisbutton1TabIndex = 2;
				thisbutton1Text = "button1";
				thisbutton1Click += new SystemEventHandler(thisbutton1_Click);
				// 
				// Form1
				// 
				thisAutoScaleBaseSize = new SystemDrawingSize(5, 13);
				thisClientSize = new SystemDrawingSize(240, 46);
				thisControlsAdd(thisbutton1);
				thisControlsAdd(thistextBox2);
				thisControlsAdd(thistextBox1);
				thisName = "Form1";
				thisText = "Form1";
				thisResumeLayout(false);
	 
			}
			#endregion
	 
			/// <summary>
			/// The main entry point for the application
			/// </summary>
			[STAThread]
			static void Main() 
			{
				ApplicationRun(new Form1());
			}
	 
			private void button1_Click(object sender, SystemEventArgs e)
			{
				// This is the generate button routine
				int count = 0;
				SystemCollectionsArrayList al = new ArrayList();
				foreach (Control c in thisControls)
				{
					if (cGetType() == typeof(Button) && cName != "button1")
					{
						alAdd(c);
					}
				}
	 
				for (int i = 0; i < alCount; i++)
					thisControlsRemove((Control)al[i]);
	 
				// Resize to start size
				thisSize = new Size(248, 80);
	 
				// First one is columns
				int columns = ConvertToInt32(textBox1Text);
				int rows = ConvertToInt32(textBox2Text);
				int locX = 16, locY = 56;
				// We assume space between is 20
				for (int i = 0; i < columns * rows; i++)
				{
					Button b = new Button();
					bName = "b" + iToString();
					bSize = new Size(10, 10);
					bLocation = new Point(locX, locY);
					if (((i + 1) % columns) == 0)
					{
						locX = 16;
						locY += bSizeHeight + 20;
					}
					else
					{
						locX += bSizeWidth + 20;
					}
	 
					thisControlsAdd(b);
					bClick +=new EventHandler(b_Click);
	 
					if ((bLocationX + bWidth) > thisClientSizeWidth)
					{
						thisWidth += ((bLocationX + bWidth) - thisClientSizeWidth) + 10;
					}
					if ((bLocationY + bHeight) > thisClientSizeHeight)
					{
						thisHeight += ((bLocationY + bHeight) - thisClientSizeHeight) + 10;
					}
				}
			}
	 
			private void b_Click(object sender, EventArgs e)
			{
				string s =  ((Control)sender)Name;
				s = new Regex("\\d+")Match(s)Value;
				int num = ConvertToInt32(s);
				int columns = ConvertToInt32(textBox1Text);
				int rows = ConvertToInt32(textBox2Text);
				s = stringFormat("Column: {0}, Row: {1}", (num % columns) + 1, (num / columns) + 1);
				MessageBoxShow(this, s);
			}
		}
	}
*/