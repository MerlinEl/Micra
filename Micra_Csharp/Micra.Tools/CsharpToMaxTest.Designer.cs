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
            this.button2 = new System.Windows.Forms.Button();
            this.button3 = new System.Windows.Forms.Button();
            this.textBox1 = new System.Windows.Forms.TextBox();
            this.button5 = new System.Windows.Forms.Button();
            this.groupBox1 = new System.Windows.Forms.GroupBox();
            this.BtnSelSimElements = new System.Windows.Forms.Button();
            this.groupBox2 = new System.Windows.Forms.GroupBox();
            this.button16 = new System.Windows.Forms.Button();
            this.ChkMacroRec = new System.Windows.Forms.CheckBox();
            this.button15 = new System.Windows.Forms.Button();
            this.button14 = new System.Windows.Forms.Button();
            this.ChkSelHidden = new System.Windows.Forms.CheckBox();
            this.ChkClearSel = new System.Windows.Forms.CheckBox();
            this.CbxClassOf = new System.Windows.Forms.ComboBox();
            this.button13 = new System.Windows.Forms.Button();
            this.button12 = new System.Windows.Forms.Button();
            this.button11 = new System.Windows.Forms.Button();
            this.button10 = new System.Windows.Forms.Button();
            this.button6 = new System.Windows.Forms.Button();
            this.button7 = new System.Windows.Forms.Button();
            this.button8 = new System.Windows.Forms.Button();
            this.button9 = new System.Windows.Forms.Button();
            this.CbxSuperClassOf = new System.Windows.Forms.ComboBox();
            this.RbtClassOf = new System.Windows.Forms.RadioButton();
            this.RbtSuperClassOf = new System.Windows.Forms.RadioButton();
            this.button4 = new System.Windows.Forms.Button();
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
            // button2
            // 
            this.button2.Location = new System.Drawing.Point(130, 19);
            this.button2.Name = "button2";
            this.button2.Size = new System.Drawing.Size(118, 23);
            this.button2.TabIndex = 1;
            this.button2.Text = "Render Scene";
            this.button2.UseVisualStyleBackColor = true;
            this.button2.Click += new System.EventHandler(this.button2_Click);
            // 
            // button3
            // 
            this.button3.Location = new System.Drawing.Point(6, 19);
            this.button3.Name = "button3";
            this.button3.Size = new System.Drawing.Size(118, 23);
            this.button3.TabIndex = 2;
            this.button3.Text = "Create 3 Boxes";
            this.button3.UseVisualStyleBackColor = true;
            this.button3.Click += new System.EventHandler(this.button3_Click);
            // 
            // textBox1
            // 
            this.textBox1.Location = new System.Drawing.Point(6, 48);
            this.textBox1.Multiline = true;
            this.textBox1.Name = "textBox1";
            this.textBox1.Size = new System.Drawing.Size(650, 112);
            this.textBox1.TabIndex = 3;
            this.textBox1.Text = "...";
            // 
            // button5
            // 
            this.button5.Location = new System.Drawing.Point(254, 19);
            this.button5.Name = "button5";
            this.button5.Size = new System.Drawing.Size(145, 23);
            this.button5.TabIndex = 5;
            this.button5.Text = "Render With Rerurn Result";
            this.button5.UseVisualStyleBackColor = true;
            this.button5.Click += new System.EventHandler(this.button5_Click);
            // 
            // groupBox1
            // 
            this.groupBox1.Controls.Add(this.button3);
            this.groupBox1.Controls.Add(this.button5);
            this.groupBox1.Controls.Add(this.button2);
            this.groupBox1.Controls.Add(this.textBox1);
            this.groupBox1.Location = new System.Drawing.Point(12, 322);
            this.groupBox1.Name = "groupBox1";
            this.groupBox1.Size = new System.Drawing.Size(662, 166);
            this.groupBox1.TabIndex = 7;
            this.groupBox1.TabStop = false;
            this.groupBox1.Text = "Execute Max Script";
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
            this.groupBox2.Size = new System.Drawing.Size(650, 304);
            this.groupBox2.TabIndex = 12;
            this.groupBox2.TabStop = false;
            this.groupBox2.Text = "MaxSharp";
            // 
            // button16
            // 
            this.button16.Location = new System.Drawing.Point(6, 162);
            this.button16.Name = "button16";
            this.button16.Size = new System.Drawing.Size(194, 23);
            this.button16.TabIndex = 20;
            this.button16.Text = "Show Selection Parameters";
            this.button16.UseVisualStyleBackColor = true;
            this.button16.Click += new System.EventHandler(this.button16_Click);
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
            this.button15.Click += new System.EventHandler(this.button15_Click);
            // 
            // button14
            // 
            this.button14.Location = new System.Drawing.Point(6, 133);
            this.button14.Name = "button14";
            this.button14.Size = new System.Drawing.Size(194, 23);
            this.button14.TabIndex = 17;
            this.button14.Text = "Show Slection Class";
            this.button14.UseVisualStyleBackColor = true;
            this.button14.Click += new System.EventHandler(this.button14_Click);
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
            // ChkClearSel
            // 
            this.ChkClearSel.AutoSize = true;
            this.ChkClearSel.Checked = true;
            this.ChkClearSel.CheckState = System.Windows.Forms.CheckState.Checked;
            this.ChkClearSel.Location = new System.Drawing.Point(140, 224);
            this.ChkClearSel.Name = "ChkClearSel";
            this.ChkClearSel.Size = new System.Drawing.Size(65, 17);
            this.ChkClearSel.TabIndex = 15;
            this.ChkClearSel.Text = "clear sel";
            this.ChkClearSel.UseVisualStyleBackColor = true;
            // 
            // CbxClassOf
            // 
            this.CbxClassOf.FormattingEnabled = true;
            this.CbxClassOf.Location = new System.Drawing.Point(6, 249);
            this.CbxClassOf.Name = "CbxClassOf";
            this.CbxClassOf.Size = new System.Drawing.Size(122, 21);
            this.CbxClassOf.TabIndex = 13;
            // 
            // button13
            // 
            this.button13.Location = new System.Drawing.Point(6, 220);
            this.button13.Name = "button13";
            this.button13.Size = new System.Drawing.Size(122, 23);
            this.button13.TabIndex = 12;
            this.button13.Text = "Select All Of Type";
            this.button13.UseVisualStyleBackColor = true;
            this.button13.Click += new System.EventHandler(this.button13_Click);
            // 
            // button12
            // 
            this.button12.Location = new System.Drawing.Point(6, 46);
            this.button12.Name = "button12";
            this.button12.Size = new System.Drawing.Size(194, 23);
            this.button12.TabIndex = 11;
            this.button12.Text = "Deselect All";
            this.button12.UseVisualStyleBackColor = true;
            this.button12.Click += new System.EventHandler(this.button12_Click);
            // 
            // button11
            // 
            this.button11.Location = new System.Drawing.Point(208, 46);
            this.button11.Name = "button11";
            this.button11.Size = new System.Drawing.Size(122, 23);
            this.button11.TabIndex = 10;
            this.button11.Text = "Select All";
            this.button11.UseVisualStyleBackColor = true;
            this.button11.Click += new System.EventHandler(this.button11_Click);
            // 
            // button10
            // 
            this.button10.Location = new System.Drawing.Point(6, 19);
            this.button10.Name = "button10";
            this.button10.Size = new System.Drawing.Size(194, 23);
            this.button10.TabIndex = 9;
            this.button10.Text = "Kernel Print Test";
            this.button10.UseVisualStyleBackColor = true;
            this.button10.Click += new System.EventHandler(this.button10_Click);
            // 
            // button6
            // 
            this.button6.Location = new System.Drawing.Point(412, 104);
            this.button6.Name = "button6";
            this.button6.Size = new System.Drawing.Size(122, 23);
            this.button6.TabIndex = 8;
            this.button6.Text = "Plugin List";
            this.button6.UseVisualStyleBackColor = true;
            this.button6.Click += new System.EventHandler(this.button6_Click);
            // 
            // button7
            // 
            this.button7.Location = new System.Drawing.Point(412, 75);
            this.button7.Name = "button7";
            this.button7.Size = new System.Drawing.Size(122, 23);
            this.button7.TabIndex = 7;
            this.button7.Text = "Bent Cylinder";
            this.button7.UseVisualStyleBackColor = true;
            this.button7.Click += new System.EventHandler(this.button7_Click);
            // 
            // button8
            // 
            this.button8.Location = new System.Drawing.Point(412, 46);
            this.button8.Name = "button8";
            this.button8.Size = new System.Drawing.Size(122, 23);
            this.button8.TabIndex = 6;
            this.button8.Text = "Create Teapot";
            this.button8.UseVisualStyleBackColor = true;
            this.button8.Click += new System.EventHandler(this.button8_Click);
            // 
            // button9
            // 
            this.button9.Location = new System.Drawing.Point(412, 17);
            this.button9.Name = "button9";
            this.button9.Size = new System.Drawing.Size(122, 23);
            this.button9.TabIndex = 5;
            this.button9.Text = "Nodes";
            this.button9.UseVisualStyleBackColor = true;
            this.button9.Click += new System.EventHandler(this.button9_Click);
            // 
            // CbxSuperClassOf
            // 
            this.CbxSuperClassOf.FormattingEnabled = true;
            this.CbxSuperClassOf.Location = new System.Drawing.Point(6, 275);
            this.CbxSuperClassOf.Name = "CbxSuperClassOf";
            this.CbxSuperClassOf.Size = new System.Drawing.Size(122, 21);
            this.CbxSuperClassOf.TabIndex = 22;
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
            // button4
            // 
            this.button4.Location = new System.Drawing.Point(6, 75);
            this.button4.Name = "button4";
            this.button4.Size = new System.Drawing.Size(194, 23);
            this.button4.TabIndex = 26;
            this.button4.Text = "Seselect Instances";
            this.button4.UseVisualStyleBackColor = true;
            this.button4.Click += new System.EventHandler(this.button4_Click_1);
            // 
            // CsharpToMaxTest
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(682, 492);
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
        private System.Windows.Forms.Button button2;
        private System.Windows.Forms.Button button3;
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
    }
}