namespace Micra.Tools {
    partial class CsharpToMaxTest {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing) {
            if ( disposing && ( components != null ) ) {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent() {
            this.button1 = new System.Windows.Forms.Button();
            this.textBox1 = new System.Windows.Forms.TextBox();
            this.button5 = new System.Windows.Forms.Button();
            this.groupBox1 = new System.Windows.Forms.GroupBox();
            this.CbxScriptList = new System.Windows.Forms.ComboBox();
            this.BtnExecute = new System.Windows.Forms.Button();
            this.BtnSelSimElements = new System.Windows.Forms.Button();
            this.groupBox2 = new System.Windows.Forms.GroupBox();
            this.CbxMaxFilePath = new System.Windows.Forms.ComboBox();
            this.ChkSelHidden2 = new System.Windows.Forms.CheckBox();
            this.CbxPrimitiveTypes = new System.Windows.Forms.ComboBox();
            this.BtnListPrimitives = new System.Windows.Forms.Button();
            this.button18 = new System.Windows.Forms.Button();
            this.BtnGetSceneObjects = new System.Windows.Forms.Button();
            this.CbxSceneNodeTypes = new System.Windows.Forms.ComboBox();
            this.ChkSelected = new System.Windows.Forms.CheckBox();
            this.BtnUnhideGeometry = new System.Windows.Forms.Button();
            this.BtnHideGeometry = new System.Windows.Forms.Button();
            this.BtnGetSelVetts = new System.Windows.Forms.Button();
            this.BtnGetSelEdges = new System.Windows.Forms.Button();
            this.BtnGetSelFaces = new System.Windows.Forms.Button();
            this.BtnOpenMaxFile = new System.Windows.Forms.Button();
            this.button4 = new System.Windows.Forms.Button();
            this.RbtSuperClassOf = new System.Windows.Forms.RadioButton();
            this.RbtClassOf = new System.Windows.Forms.RadioButton();
            this.button16 = new System.Windows.Forms.Button();
            this.ChkClearSel = new System.Windows.Forms.CheckBox();
            this.CbxSuperClassOf = new System.Windows.Forms.ComboBox();
            this.ChkMacroRec = new System.Windows.Forms.CheckBox();
            this.button15 = new System.Windows.Forms.Button();
            this.button14 = new System.Windows.Forms.Button();
            this.ChkSelHidden = new System.Windows.Forms.CheckBox();
            this.button12 = new System.Windows.Forms.Button();
            this.button11 = new System.Windows.Forms.Button();
            this.button10 = new System.Windows.Forms.Button();
            this.button6 = new System.Windows.Forms.Button();
            this.CbxClassOf = new System.Windows.Forms.ComboBox();
            this.button7 = new System.Windows.Forms.Button();
            this.button13 = new System.Windows.Forms.Button();
            this.button8 = new System.Windows.Forms.Button();
            this.button9 = new System.Windows.Forms.Button();
            this.BtnGetObjArea1 = new System.Windows.Forms.Button();
            this.BtnGetObjArea2 = new System.Windows.Forms.Button();
            this.groupBox1.SuspendLayout();
            this.groupBox2.SuspendLayout();
            this.SuspendLayout();
            // 
            // button1
            // 
            this.button1.Location = new System.Drawing.Point(6, 104);
            this.button1.Name = "button1";
            this.button1.Size = new System.Drawing.Size(194, 23);
            this.button1.TabIndex = 0;
            this.button1.Text = "Select First Node From Selection";
            this.button1.UseVisualStyleBackColor = true;
            this.button1.Click += new System.EventHandler(this.Button1_Click);
            // 
            // textBox1
            // 
            this.textBox1.Location = new System.Drawing.Point(6, 48);
            this.textBox1.Multiline = true;
            this.textBox1.Name = "textBox1";
            this.textBox1.Size = new System.Drawing.Size(592, 172);
            this.textBox1.TabIndex = 3;
            this.textBox1.Text = "...";
            // 
            // button5
            // 
            this.button5.Location = new System.Drawing.Point(453, 17);
            this.button5.Name = "button5";
            this.button5.Size = new System.Drawing.Size(145, 23);
            this.button5.TabIndex = 5;
            this.button5.Text = "Render With Rerurn Result";
            this.button5.UseVisualStyleBackColor = true;
            this.button5.Click += new System.EventHandler(this.Button5_Click);
            // 
            // groupBox1
            // 
            this.groupBox1.Controls.Add(this.CbxScriptList);
            this.groupBox1.Controls.Add(this.BtnExecute);
            this.groupBox1.Controls.Add(this.button5);
            this.groupBox1.Controls.Add(this.textBox1);
            this.groupBox1.Location = new System.Drawing.Point(12, 357);
            this.groupBox1.Name = "groupBox1";
            this.groupBox1.Size = new System.Drawing.Size(614, 228);
            this.groupBox1.TabIndex = 7;
            this.groupBox1.TabStop = false;
            this.groupBox1.Text = "Execute Max Script";
            // 
            // CbxScriptList
            // 
            this.CbxScriptList.FormattingEnabled = true;
            this.CbxScriptList.Location = new System.Drawing.Point(130, 19);
            this.CbxScriptList.Name = "CbxScriptList";
            this.CbxScriptList.Size = new System.Drawing.Size(215, 21);
            this.CbxScriptList.TabIndex = 44;
            this.CbxScriptList.SelectedIndexChanged += new System.EventHandler(this.OnCbxScriptListSelChanges);
            // 
            // BtnExecute
            // 
            this.BtnExecute.Location = new System.Drawing.Point(6, 19);
            this.BtnExecute.Name = "BtnExecute";
            this.BtnExecute.Size = new System.Drawing.Size(118, 23);
            this.BtnExecute.TabIndex = 6;
            this.BtnExecute.Text = "EXECUTE";
            this.BtnExecute.UseVisualStyleBackColor = true;
            this.BtnExecute.Click += new System.EventHandler(this.BtnExecute_Click);
            // 
            // BtnSelSimElements
            // 
            this.BtnSelSimElements.Location = new System.Drawing.Point(6, 191);
            this.BtnSelSimElements.Name = "BtnSelSimElements";
            this.BtnSelSimElements.Size = new System.Drawing.Size(194, 23);
            this.BtnSelSimElements.TabIndex = 8;
            this.BtnSelSimElements.Text = "Select Simillar Elements";
            this.BtnSelSimElements.UseVisualStyleBackColor = true;
            this.BtnSelSimElements.Click += new System.EventHandler(this.BtnSelSimElements_Click);
            // 
            // groupBox2
            // 
            this.groupBox2.Controls.Add(this.BtnGetObjArea2);
            this.groupBox2.Controls.Add(this.BtnGetObjArea1);
            this.groupBox2.Controls.Add(this.CbxMaxFilePath);
            this.groupBox2.Controls.Add(this.ChkSelHidden2);
            this.groupBox2.Controls.Add(this.CbxPrimitiveTypes);
            this.groupBox2.Controls.Add(this.BtnListPrimitives);
            this.groupBox2.Controls.Add(this.button18);
            this.groupBox2.Controls.Add(this.BtnGetSceneObjects);
            this.groupBox2.Controls.Add(this.CbxSceneNodeTypes);
            this.groupBox2.Controls.Add(this.ChkSelected);
            this.groupBox2.Controls.Add(this.BtnUnhideGeometry);
            this.groupBox2.Controls.Add(this.BtnHideGeometry);
            this.groupBox2.Controls.Add(this.BtnGetSelVetts);
            this.groupBox2.Controls.Add(this.BtnGetSelEdges);
            this.groupBox2.Controls.Add(this.BtnGetSelFaces);
            this.groupBox2.Controls.Add(this.BtnOpenMaxFile);
            this.groupBox2.Controls.Add(this.button4);
            this.groupBox2.Controls.Add(this.BtnSelSimElements);
            this.groupBox2.Controls.Add(this.RbtSuperClassOf);
            this.groupBox2.Controls.Add(this.RbtClassOf);
            this.groupBox2.Controls.Add(this.button1);
            this.groupBox2.Controls.Add(this.button16);
            this.groupBox2.Controls.Add(this.ChkClearSel);
            this.groupBox2.Controls.Add(this.CbxSuperClassOf);
            this.groupBox2.Controls.Add(this.ChkMacroRec);
            this.groupBox2.Controls.Add(this.button15);
            this.groupBox2.Controls.Add(this.button14);
            this.groupBox2.Controls.Add(this.ChkSelHidden);
            this.groupBox2.Controls.Add(this.button12);
            this.groupBox2.Controls.Add(this.button11);
            this.groupBox2.Controls.Add(this.button10);
            this.groupBox2.Controls.Add(this.button6);
            this.groupBox2.Controls.Add(this.CbxClassOf);
            this.groupBox2.Controls.Add(this.button7);
            this.groupBox2.Controls.Add(this.button13);
            this.groupBox2.Controls.Add(this.button8);
            this.groupBox2.Controls.Add(this.button9);
            this.groupBox2.Location = new System.Drawing.Point(18, 12);
            this.groupBox2.Name = "groupBox2";
            this.groupBox2.Size = new System.Drawing.Size(979, 339);
            this.groupBox2.TabIndex = 12;
            this.groupBox2.TabStop = false;
            this.groupBox2.Text = "MaxSharp";
            // 
            // CbxMaxFilePath
            // 
            this.CbxMaxFilePath.FormattingEnabled = true;
            this.CbxMaxFilePath.Items.AddRange(new object[] {
            "D:\\ReneBaca\\Aprog\\Micra\\Micra_Csharp\\Resources\\test_scene_01.max",
            "E:\\Aprog\\Orien\\Micra\\Micra_Csharp\\Resources\\test_scene_01.max"});
            this.CbxMaxFilePath.Location = new System.Drawing.Point(208, 302);
            this.CbxMaxFilePath.Name = "CbxMaxFilePath";
            this.CbxMaxFilePath.Size = new System.Drawing.Size(400, 21);
            this.CbxMaxFilePath.TabIndex = 43;
            // 
            // ChkSelHidden2
            // 
            this.ChkSelHidden2.AutoSize = true;
            this.ChkSelHidden2.Location = new System.Drawing.Point(134, 224);
            this.ChkSelHidden2.Name = "ChkSelHidden2";
            this.ChkSelHidden2.Size = new System.Drawing.Size(74, 17);
            this.ChkSelHidden2.TabIndex = 42;
            this.ChkSelHidden2.Text = "sel hidden";
            this.ChkSelHidden2.UseVisualStyleBackColor = true;
            // 
            // CbxPrimitiveTypes
            // 
            this.CbxPrimitiveTypes.FormattingEnabled = true;
            this.CbxPrimitiveTypes.Items.AddRange(new object[] {
            "All",
            "Standard",
            "Extended"});
            this.CbxPrimitiveTypes.Location = new System.Drawing.Point(828, 52);
            this.CbxPrimitiveTypes.Name = "CbxPrimitiveTypes";
            this.CbxPrimitiveTypes.Size = new System.Drawing.Size(145, 21);
            this.CbxPrimitiveTypes.TabIndex = 41;
            // 
            // BtnListPrimitives
            // 
            this.BtnListPrimitives.Location = new System.Drawing.Point(700, 52);
            this.BtnListPrimitives.Name = "BtnListPrimitives";
            this.BtnListPrimitives.Size = new System.Drawing.Size(122, 23);
            this.BtnListPrimitives.TabIndex = 39;
            this.BtnListPrimitives.Text = "List Primitives";
            this.BtnListPrimitives.UseVisualStyleBackColor = true;
            this.BtnListPrimitives.Click += new System.EventHandler(this.BtnListPrimitives_Click);
            // 
            // button18
            // 
            this.button18.Location = new System.Drawing.Point(861, 289);
            this.button18.Name = "button18";
            this.button18.Size = new System.Drawing.Size(112, 34);
            this.button18.TabIndex = 38;
            this.button18.Text = "Poy - Mesh - All";
            this.button18.UseVisualStyleBackColor = true;
            this.button18.Click += new System.EventHandler(this.button18_Click);
            // 
            // BtnGetSceneObjects
            // 
            this.BtnGetSceneObjects.Location = new System.Drawing.Point(700, 17);
            this.BtnGetSceneObjects.Name = "BtnGetSceneObjects";
            this.BtnGetSceneObjects.Size = new System.Drawing.Size(122, 23);
            this.BtnGetSceneObjects.TabIndex = 36;
            this.BtnGetSceneObjects.Text = "Get Scene Objects";
            this.BtnGetSceneObjects.UseVisualStyleBackColor = true;
            this.BtnGetSceneObjects.Click += new System.EventHandler(this.BtnGetSceneObjects_Click);
            // 
            // CbxSceneNodeTypes
            // 
            this.CbxSceneNodeTypes.FormattingEnabled = true;
            this.CbxSceneNodeTypes.Items.AddRange(new object[] {
            "All",
            "GeometryNodes",
            "LightNodes",
            "CameraNodes",
            "HelperNodes",
            "ShapeNodes"});
            this.CbxSceneNodeTypes.Location = new System.Drawing.Point(828, 17);
            this.CbxSceneNodeTypes.Name = "CbxSceneNodeTypes";
            this.CbxSceneNodeTypes.Size = new System.Drawing.Size(145, 21);
            this.CbxSceneNodeTypes.TabIndex = 35;
            // 
            // ChkSelected
            // 
            this.ChkSelected.AutoSize = true;
            this.ChkSelected.Checked = true;
            this.ChkSelected.CheckState = System.Windows.Forms.CheckState.Checked;
            this.ChkSelected.Location = new System.Drawing.Point(542, 195);
            this.ChkSelected.Name = "ChkSelected";
            this.ChkSelected.Size = new System.Drawing.Size(66, 17);
            this.ChkSelected.TabIndex = 34;
            this.ChkSelected.Text = "selected";
            this.ChkSelected.UseVisualStyleBackColor = true;
            // 
            // BtnUnhideGeometry
            // 
            this.BtnUnhideGeometry.Location = new System.Drawing.Point(423, 162);
            this.BtnUnhideGeometry.Name = "BtnUnhideGeometry";
            this.BtnUnhideGeometry.Size = new System.Drawing.Size(111, 23);
            this.BtnUnhideGeometry.TabIndex = 33;
            this.BtnUnhideGeometry.Text = "Unhide Geometry";
            this.BtnUnhideGeometry.UseVisualStyleBackColor = true;
            this.BtnUnhideGeometry.Click += new System.EventHandler(this.BtnUnhideGeometry_Click);
            // 
            // BtnHideGeometry
            // 
            this.BtnHideGeometry.Location = new System.Drawing.Point(423, 191);
            this.BtnHideGeometry.Name = "BtnHideGeometry";
            this.BtnHideGeometry.Size = new System.Drawing.Size(111, 23);
            this.BtnHideGeometry.TabIndex = 32;
            this.BtnHideGeometry.Text = "Hide Geometry";
            this.BtnHideGeometry.UseVisualStyleBackColor = true;
            this.BtnHideGeometry.Click += new System.EventHandler(this.BtnHideUnselFaces_Click);
            // 
            // BtnGetSelVetts
            // 
            this.BtnGetSelVetts.Location = new System.Drawing.Point(208, 191);
            this.BtnGetSelVetts.Name = "BtnGetSelVetts";
            this.BtnGetSelVetts.Size = new System.Drawing.Size(122, 23);
            this.BtnGetSelVetts.TabIndex = 31;
            this.BtnGetSelVetts.Text = "Get Selected Verts";
            this.BtnGetSelVetts.UseVisualStyleBackColor = true;
            this.BtnGetSelVetts.Click += new System.EventHandler(this.BtnGetSelVetts_Click);
            // 
            // BtnGetSelEdges
            // 
            this.BtnGetSelEdges.Location = new System.Drawing.Point(208, 162);
            this.BtnGetSelEdges.Name = "BtnGetSelEdges";
            this.BtnGetSelEdges.Size = new System.Drawing.Size(122, 23);
            this.BtnGetSelEdges.TabIndex = 30;
            this.BtnGetSelEdges.Text = "Get Selected Edges";
            this.BtnGetSelEdges.UseVisualStyleBackColor = true;
            this.BtnGetSelEdges.Click += new System.EventHandler(this.BtnGetSelEdges_Click);
            // 
            // BtnGetSelFaces
            // 
            this.BtnGetSelFaces.Location = new System.Drawing.Point(208, 133);
            this.BtnGetSelFaces.Name = "BtnGetSelFaces";
            this.BtnGetSelFaces.Size = new System.Drawing.Size(122, 23);
            this.BtnGetSelFaces.TabIndex = 29;
            this.BtnGetSelFaces.Text = "Get Selected Faces";
            this.BtnGetSelFaces.UseVisualStyleBackColor = true;
            this.BtnGetSelFaces.Click += new System.EventHandler(this.BtnGetSelFaces_Click);
            // 
            // BtnOpenMaxFile
            // 
            this.BtnOpenMaxFile.Location = new System.Drawing.Point(6, 302);
            this.BtnOpenMaxFile.Name = "BtnOpenMaxFile";
            this.BtnOpenMaxFile.Size = new System.Drawing.Size(194, 23);
            this.BtnOpenMaxFile.TabIndex = 27;
            this.BtnOpenMaxFile.Text = "Open File";
            this.BtnOpenMaxFile.UseVisualStyleBackColor = true;
            this.BtnOpenMaxFile.Click += new System.EventHandler(this.BtnOpenMaxFile_Click);
            // 
            // button4
            // 
            this.button4.Location = new System.Drawing.Point(6, 75);
            this.button4.Name = "button4";
            this.button4.Size = new System.Drawing.Size(194, 23);
            this.button4.TabIndex = 26;
            this.button4.Text = "Seselect Instances";
            this.button4.UseVisualStyleBackColor = true;
            this.button4.Click += new System.EventHandler(this.Button4_Click_1);
            // 
            // RbtSuperClassOf
            // 
            this.RbtSuperClassOf.AutoSize = true;
            this.RbtSuperClassOf.Location = new System.Drawing.Point(140, 277);
            this.RbtSuperClassOf.Name = "RbtSuperClassOf";
            this.RbtSuperClassOf.Size = new System.Drawing.Size(87, 17);
            this.RbtSuperClassOf.TabIndex = 25;
            this.RbtSuperClassOf.Text = "superClassOf";
            this.RbtSuperClassOf.UseVisualStyleBackColor = true;
            // 
            // RbtClassOf
            // 
            this.RbtClassOf.AutoSize = true;
            this.RbtClassOf.Checked = true;
            this.RbtClassOf.Location = new System.Drawing.Point(140, 251);
            this.RbtClassOf.Name = "RbtClassOf";
            this.RbtClassOf.Size = new System.Drawing.Size(60, 17);
            this.RbtClassOf.TabIndex = 24;
            this.RbtClassOf.TabStop = true;
            this.RbtClassOf.Text = "classOf";
            this.RbtClassOf.UseVisualStyleBackColor = true;
            // 
            // button16
            // 
            this.button16.Location = new System.Drawing.Point(6, 162);
            this.button16.Name = "button16";
            this.button16.Size = new System.Drawing.Size(194, 23);
            this.button16.TabIndex = 20;
            this.button16.Text = "Show Selection Parameters";
            this.button16.UseVisualStyleBackColor = true;
            this.button16.Click += new System.EventHandler(this.Button16_Click);
            // 
            // ChkClearSel
            // 
            this.ChkClearSel.AutoSize = true;
            this.ChkClearSel.Checked = true;
            this.ChkClearSel.CheckState = System.Windows.Forms.CheckState.Checked;
            this.ChkClearSel.Location = new System.Drawing.Point(214, 224);
            this.ChkClearSel.Name = "ChkClearSel";
            this.ChkClearSel.Size = new System.Drawing.Size(65, 17);
            this.ChkClearSel.TabIndex = 15;
            this.ChkClearSel.Text = "clear sel";
            this.ChkClearSel.UseVisualStyleBackColor = true;
            // 
            // CbxSuperClassOf
            // 
            this.CbxSuperClassOf.FormattingEnabled = true;
            this.CbxSuperClassOf.Location = new System.Drawing.Point(6, 275);
            this.CbxSuperClassOf.Name = "CbxSuperClassOf";
            this.CbxSuperClassOf.Size = new System.Drawing.Size(122, 21);
            this.CbxSuperClassOf.TabIndex = 22;
            // 
            // ChkMacroRec
            // 
            this.ChkMacroRec.AutoSize = true;
            this.ChkMacroRec.Location = new System.Drawing.Point(334, 21);
            this.ChkMacroRec.Name = "ChkMacroRec";
            this.ChkMacroRec.Size = new System.Drawing.Size(73, 17);
            this.ChkMacroRec.TabIndex = 19;
            this.ChkMacroRec.Text = "macro rec";
            this.ChkMacroRec.UseVisualStyleBackColor = true;
            // 
            // button15
            // 
            this.button15.Location = new System.Drawing.Point(208, 17);
            this.button15.Name = "button15";
            this.button15.Size = new System.Drawing.Size(120, 23);
            this.button15.TabIndex = 18;
            this.button15.Text = "Clear Listener";
            this.button15.UseVisualStyleBackColor = true;
            this.button15.Click += new System.EventHandler(this.Button15_Click);
            // 
            // button14
            // 
            this.button14.Location = new System.Drawing.Point(6, 133);
            this.button14.Name = "button14";
            this.button14.Size = new System.Drawing.Size(194, 23);
            this.button14.TabIndex = 17;
            this.button14.Text = "Show Slection Class";
            this.button14.UseVisualStyleBackColor = true;
            this.button14.Click += new System.EventHandler(this.Button14_Click);
            // 
            // ChkSelHidden
            // 
            this.ChkSelHidden.AutoSize = true;
            this.ChkSelHidden.Location = new System.Drawing.Point(334, 50);
            this.ChkSelHidden.Name = "ChkSelHidden";
            this.ChkSelHidden.Size = new System.Drawing.Size(74, 17);
            this.ChkSelHidden.TabIndex = 16;
            this.ChkSelHidden.Text = "sel hidden";
            this.ChkSelHidden.UseVisualStyleBackColor = true;
            // 
            // button12
            // 
            this.button12.Location = new System.Drawing.Point(6, 46);
            this.button12.Name = "button12";
            this.button12.Size = new System.Drawing.Size(194, 23);
            this.button12.TabIndex = 11;
            this.button12.Text = "Deselect All";
            this.button12.UseVisualStyleBackColor = true;
            this.button12.Click += new System.EventHandler(this.Button12_Click);
            // 
            // button11
            // 
            this.button11.Location = new System.Drawing.Point(208, 46);
            this.button11.Name = "button11";
            this.button11.Size = new System.Drawing.Size(122, 23);
            this.button11.TabIndex = 10;
            this.button11.Text = "Select All";
            this.button11.UseVisualStyleBackColor = true;
            this.button11.Click += new System.EventHandler(this.Button11_Click);
            // 
            // button10
            // 
            this.button10.Location = new System.Drawing.Point(6, 19);
            this.button10.Name = "button10";
            this.button10.Size = new System.Drawing.Size(194, 23);
            this.button10.TabIndex = 9;
            this.button10.Text = "Kernel Print Test";
            this.button10.UseVisualStyleBackColor = true;
            this.button10.Click += new System.EventHandler(this.Button10_Click);
            // 
            // button6
            // 
            this.button6.Location = new System.Drawing.Point(412, 104);
            this.button6.Name = "button6";
            this.button6.Size = new System.Drawing.Size(122, 23);
            this.button6.TabIndex = 8;
            this.button6.Text = "Plugin List";
            this.button6.UseVisualStyleBackColor = true;
            this.button6.Click += new System.EventHandler(this.Button6_Click);
            // 
            // CbxClassOf
            // 
            this.CbxClassOf.FormattingEnabled = true;
            this.CbxClassOf.Location = new System.Drawing.Point(6, 249);
            this.CbxClassOf.Name = "CbxClassOf";
            this.CbxClassOf.Size = new System.Drawing.Size(122, 21);
            this.CbxClassOf.TabIndex = 13;
            // 
            // button7
            // 
            this.button7.Location = new System.Drawing.Point(412, 75);
            this.button7.Name = "button7";
            this.button7.Size = new System.Drawing.Size(122, 23);
            this.button7.TabIndex = 7;
            this.button7.Text = "Bent Cylinder";
            this.button7.UseVisualStyleBackColor = true;
            this.button7.Click += new System.EventHandler(this.Button7_Click);
            // 
            // button13
            // 
            this.button13.Location = new System.Drawing.Point(6, 220);
            this.button13.Name = "button13";
            this.button13.Size = new System.Drawing.Size(122, 23);
            this.button13.TabIndex = 12;
            this.button13.Text = "Select All Of Type";
            this.button13.UseVisualStyleBackColor = true;
            this.button13.Click += new System.EventHandler(this.Button13_Click);
            // 
            // button8
            // 
            this.button8.Location = new System.Drawing.Point(412, 46);
            this.button8.Name = "button8";
            this.button8.Size = new System.Drawing.Size(122, 23);
            this.button8.TabIndex = 6;
            this.button8.Text = "Create Teapot";
            this.button8.UseVisualStyleBackColor = true;
            this.button8.Click += new System.EventHandler(this.Button8_Click);
            // 
            // button9
            // 
            this.button9.Location = new System.Drawing.Point(412, 17);
            this.button9.Name = "button9";
            this.button9.Size = new System.Drawing.Size(122, 23);
            this.button9.TabIndex = 5;
            this.button9.Text = "All Scene Nodes";
            this.button9.UseVisualStyleBackColor = true;
            this.button9.Click += new System.EventHandler(this.Button9_Click);
            // 
            // BtnGetObjArea1
            // 
            this.BtnGetObjArea1.Location = new System.Drawing.Point(723, 133);
            this.BtnGetObjArea1.Name = "BtnGetObjArea1";
            this.BtnGetObjArea1.Size = new System.Drawing.Size(122, 23);
            this.BtnGetObjArea1.TabIndex = 44;
            this.BtnGetObjArea1.Text = "Get Object Area";
            this.BtnGetObjArea1.UseVisualStyleBackColor = true;
            this.BtnGetObjArea1.Click += new System.EventHandler(this.BtnGetObjArea_Click);
            // 
            // BtnGetObjArea2
            // 
            this.BtnGetObjArea2.Location = new System.Drawing.Point(851, 133);
            this.BtnGetObjArea2.Name = "BtnGetObjArea2";
            this.BtnGetObjArea2.Size = new System.Drawing.Size(122, 23);
            this.BtnGetObjArea2.TabIndex = 45;
            this.BtnGetObjArea2.Text = "Get Face Area";
            this.BtnGetObjArea2.UseVisualStyleBackColor = true;
            this.BtnGetObjArea2.Click += new System.EventHandler(this.BtnGetFaceArea_Click);
            // 
            // CsharpToMaxTest
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(1009, 589);
            this.Controls.Add(this.groupBox2);
            this.Controls.Add(this.groupBox1);
            this.Name = "CsharpToMaxTest";
            this.Text = "Csharp To Max Test:";
            this.Shown += new System.EventHandler(this.OnFormShown);
            this.groupBox1.ResumeLayout(false);
            this.groupBox1.PerformLayout();
            this.groupBox2.ResumeLayout(false);
            this.groupBox2.PerformLayout();
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.Button button1;
        private System.Windows.Forms.TextBox textBox1;
        private System.Windows.Forms.Button button5;
        private System.Windows.Forms.GroupBox groupBox1;
        private System.Windows.Forms.Button BtnSelSimElements;
        private System.Windows.Forms.GroupBox groupBox2;
        private System.Windows.Forms.Button button6;
        private System.Windows.Forms.Button button7;
        private System.Windows.Forms.Button button8;
        private System.Windows.Forms.Button button9;
        private System.Windows.Forms.Button button10;
        private System.Windows.Forms.Button button11;
        private System.Windows.Forms.Button button12;
        private System.Windows.Forms.Button button13;
        private System.Windows.Forms.ComboBox CbxClassOf;
        private System.Windows.Forms.CheckBox ChkClearSel;
        private System.Windows.Forms.CheckBox ChkSelHidden;
        private System.Windows.Forms.Button button14;
        private System.Windows.Forms.Button button15;
        private System.Windows.Forms.CheckBox ChkMacroRec;
        private System.Windows.Forms.Button button16;
        private System.Windows.Forms.ComboBox CbxSuperClassOf;
        private System.Windows.Forms.RadioButton RbtSuperClassOf;
        private System.Windows.Forms.RadioButton RbtClassOf;
        private System.Windows.Forms.Button button4;
        private System.Windows.Forms.Button BtnOpenMaxFile;
        private System.Windows.Forms.Button BtnGetSelVetts;
        private System.Windows.Forms.Button BtnGetSelEdges;
        private System.Windows.Forms.Button BtnGetSelFaces;
        private System.Windows.Forms.Button BtnHideGeometry;
        private System.Windows.Forms.Button BtnUnhideGeometry;
        private System.Windows.Forms.CheckBox ChkSelected;
        private System.Windows.Forms.ComboBox CbxSceneNodeTypes;
        private System.Windows.Forms.Button BtnGetSceneObjects;
        private System.Windows.Forms.Button button18;
        private System.Windows.Forms.ComboBox CbxPrimitiveTypes;
        private System.Windows.Forms.Button BtnListPrimitives;
        private System.Windows.Forms.CheckBox ChkSelHidden2;
        private System.Windows.Forms.ComboBox CbxMaxFilePath;
        private System.Windows.Forms.Button BtnExecute;
        private System.Windows.Forms.ComboBox CbxScriptList;
        private System.Windows.Forms.Button BtnGetObjArea2;
        private System.Windows.Forms.Button BtnGetObjArea1;
    }
}