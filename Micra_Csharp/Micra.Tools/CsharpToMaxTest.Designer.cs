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
            this.button4 = new System.Windows.Forms.Button();
            this.button5 = new System.Windows.Forms.Button();
            this.groupBox1 = new System.Windows.Forms.GroupBox();
            this.BtnSelSimElements = new System.Windows.Forms.Button();
            this.BtnSelectAll = new System.Windows.Forms.Button();
            this.BtnSelectNone = new System.Windows.Forms.Button();
            this.BtnPrintNodeInstances = new System.Windows.Forms.Button();
            this.groupBox2 = new System.Windows.Forms.GroupBox();
            this.button6 = new System.Windows.Forms.Button();
            this.button7 = new System.Windows.Forms.Button();
            this.button8 = new System.Windows.Forms.Button();
            this.button9 = new System.Windows.Forms.Button();
            this.button10 = new System.Windows.Forms.Button();
            this.button11 = new System.Windows.Forms.Button();
            this.button12 = new System.Windows.Forms.Button();
            this.button13 = new System.Windows.Forms.Button();
            this.CbxObjType = new System.Windows.Forms.ComboBox();
            this.ChkPrintProps = new System.Windows.Forms.CheckBox();
            this.ChkClearSel = new System.Windows.Forms.CheckBox();
            this.ChkSelHidden = new System.Windows.Forms.CheckBox();
            this.groupBox1.SuspendLayout();
            this.groupBox2.SuspendLayout();
            this.SuspendLayout();
            // 
            // button1
            // 
            this.button1.Location = new System.Drawing.Point(12, 12);
            this.button1.Name = "button1";
            this.button1.Size = new System.Drawing.Size(172, 23);
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
            this.textBox1.Size = new System.Drawing.Size(568, 115);
            this.textBox1.TabIndex = 3;
            this.textBox1.Text = "...";
            // 
            // button4
            // 
            this.button4.Location = new System.Drawing.Point(12, 67);
            this.button4.Name = "button4";
            this.button4.Size = new System.Drawing.Size(171, 23);
            this.button4.TabIndex = 4;
            this.button4.Text = "Get All Scene Objects";
            this.button4.UseVisualStyleBackColor = true;
            this.button4.Click += new System.EventHandler(this.button4_Click);
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
            this.groupBox1.Location = new System.Drawing.Point(12, 312);
            this.groupBox1.Name = "groupBox1";
            this.groupBox1.Size = new System.Drawing.Size(590, 169);
            this.groupBox1.TabIndex = 7;
            this.groupBox1.TabStop = false;
            this.groupBox1.Text = "Execute Max Script";
            // 
            // BtnSelSimElements
            // 
            this.BtnSelSimElements.Location = new System.Drawing.Point(12, 41);
            this.BtnSelSimElements.Name = "BtnSelSimElements";
            this.BtnSelSimElements.Size = new System.Drawing.Size(172, 23);
            this.BtnSelSimElements.TabIndex = 8;
            this.BtnSelSimElements.Text = "Select Simillar Elements";
            this.BtnSelSimElements.UseVisualStyleBackColor = true;
            this.BtnSelSimElements.Click += new System.EventHandler(this.BtnSelSimElements_Click);
            // 
            // BtnSelectAll
            // 
            this.BtnSelectAll.Location = new System.Drawing.Point(12, 125);
            this.BtnSelectAll.Name = "BtnSelectAll";
            this.BtnSelectAll.Size = new System.Drawing.Size(172, 23);
            this.BtnSelectAll.TabIndex = 9;
            this.BtnSelectAll.Text = "Select All";
            this.BtnSelectAll.UseVisualStyleBackColor = true;
            this.BtnSelectAll.Click += new System.EventHandler(this.BtnSelectAll_Click);
            // 
            // BtnSelectNone
            // 
            this.BtnSelectNone.Location = new System.Drawing.Point(12, 154);
            this.BtnSelectNone.Name = "BtnSelectNone";
            this.BtnSelectNone.Size = new System.Drawing.Size(172, 23);
            this.BtnSelectNone.TabIndex = 10;
            this.BtnSelectNone.Text = "Select None";
            this.BtnSelectNone.UseVisualStyleBackColor = true;
            this.BtnSelectNone.Click += new System.EventHandler(this.BtnSelectNone_Click);
            // 
            // BtnPrintNodeInstances
            // 
            this.BtnPrintNodeInstances.Location = new System.Drawing.Point(12, 96);
            this.BtnPrintNodeInstances.Name = "BtnPrintNodeInstances";
            this.BtnPrintNodeInstances.Size = new System.Drawing.Size(172, 23);
            this.BtnPrintNodeInstances.TabIndex = 11;
            this.BtnPrintNodeInstances.Text = "Select Node Instances";
            this.BtnPrintNodeInstances.UseVisualStyleBackColor = true;
            this.BtnPrintNodeInstances.Click += new System.EventHandler(this.BtnPrintNodeInstances_Click);
            // 
            // groupBox2
            // 
            this.groupBox2.Controls.Add(this.ChkSelHidden);
            this.groupBox2.Controls.Add(this.ChkClearSel);
            this.groupBox2.Controls.Add(this.ChkPrintProps);
            this.groupBox2.Controls.Add(this.CbxObjType);
            this.groupBox2.Controls.Add(this.button13);
            this.groupBox2.Controls.Add(this.button12);
            this.groupBox2.Controls.Add(this.button11);
            this.groupBox2.Controls.Add(this.button10);
            this.groupBox2.Controls.Add(this.button6);
            this.groupBox2.Controls.Add(this.button7);
            this.groupBox2.Controls.Add(this.button8);
            this.groupBox2.Controls.Add(this.button9);
            this.groupBox2.Location = new System.Drawing.Point(293, 12);
            this.groupBox2.Name = "groupBox2";
            this.groupBox2.Size = new System.Drawing.Size(305, 294);
            this.groupBox2.TabIndex = 12;
            this.groupBox2.TabStop = false;
            this.groupBox2.Text = "MaxSharp";
            // 
            // button6
            // 
            this.button6.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.button6.Location = new System.Drawing.Point(13, 107);
            this.button6.Name = "button6";
            this.button6.Size = new System.Drawing.Size(105, 23);
            this.button6.TabIndex = 8;
            this.button6.Text = "Plugin List";
            this.button6.UseVisualStyleBackColor = true;
            this.button6.Click += new System.EventHandler(this.button6_Click);
            // 
            // button7
            // 
            this.button7.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.button7.Location = new System.Drawing.Point(13, 77);
            this.button7.Name = "button7";
            this.button7.Size = new System.Drawing.Size(105, 23);
            this.button7.TabIndex = 7;
            this.button7.Text = "Bent Cylinder";
            this.button7.UseVisualStyleBackColor = true;
            this.button7.Click += new System.EventHandler(this.button7_Click);
            // 
            // button8
            // 
            this.button8.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.button8.Location = new System.Drawing.Point(13, 48);
            this.button8.Name = "button8";
            this.button8.Size = new System.Drawing.Size(105, 23);
            this.button8.TabIndex = 6;
            this.button8.Text = "Create Teapot";
            this.button8.UseVisualStyleBackColor = true;
            this.button8.Click += new System.EventHandler(this.button8_Click);
            // 
            // button9
            // 
            this.button9.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.button9.Location = new System.Drawing.Point(13, 19);
            this.button9.Name = "button9";
            this.button9.Size = new System.Drawing.Size(105, 23);
            this.button9.TabIndex = 5;
            this.button9.Text = "Nodes";
            this.button9.UseVisualStyleBackColor = true;
            this.button9.Click += new System.EventHandler(this.button9_Click);
            // 
            // button10
            // 
            this.button10.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.button10.Location = new System.Drawing.Point(124, 19);
            this.button10.Name = "button10";
            this.button10.Size = new System.Drawing.Size(105, 23);
            this.button10.TabIndex = 9;
            this.button10.Text = "Kernel Print Test";
            this.button10.UseVisualStyleBackColor = true;
            this.button10.Click += new System.EventHandler(this.button10_Click);
            // 
            // button11
            // 
            this.button11.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.button11.Location = new System.Drawing.Point(13, 194);
            this.button11.Name = "button11";
            this.button11.Size = new System.Drawing.Size(105, 23);
            this.button11.TabIndex = 10;
            this.button11.Text = "Select All";
            this.button11.UseVisualStyleBackColor = true;
            this.button11.Click += new System.EventHandler(this.button11_Click);
            // 
            // button12
            // 
            this.button12.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.button12.Location = new System.Drawing.Point(13, 165);
            this.button12.Name = "button12";
            this.button12.Size = new System.Drawing.Size(105, 23);
            this.button12.TabIndex = 11;
            this.button12.Text = "Deselect All";
            this.button12.UseVisualStyleBackColor = true;
            this.button12.Click += new System.EventHandler(this.button12_Click);
            // 
            // button13
            // 
            this.button13.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.button13.Location = new System.Drawing.Point(13, 223);
            this.button13.Name = "button13";
            this.button13.Size = new System.Drawing.Size(105, 23);
            this.button13.TabIndex = 12;
            this.button13.Text = "Select All Of Type";
            this.button13.UseVisualStyleBackColor = true;
            this.button13.Click += new System.EventHandler(this.button13_Click);
            // 
            // CbxObjType
            // 
            this.CbxObjType.FormattingEnabled = true;
            this.CbxObjType.Items.AddRange(new object[] {
            "Light",
            "Geometry",
            "Mesh",
            "Poly",
            "Bone",
            "Helper",
            "Spline"});
            this.CbxObjType.Location = new System.Drawing.Point(124, 223);
            this.CbxObjType.Name = "CbxObjType";
            this.CbxObjType.Size = new System.Drawing.Size(100, 21);
            this.CbxObjType.TabIndex = 13;
            // 
            // ChkPrintProps
            // 
            this.ChkPrintProps.AutoSize = true;
            this.ChkPrintProps.Location = new System.Drawing.Point(124, 198);
            this.ChkPrintProps.Name = "ChkPrintProps";
            this.ChkPrintProps.Size = new System.Drawing.Size(75, 17);
            this.ChkPrintProps.TabIndex = 14;
            this.ChkPrintProps.Text = "print props";
            this.ChkPrintProps.UseVisualStyleBackColor = true;
            // 
            // ChkClearSel
            // 
            this.ChkClearSel.AutoSize = true;
            this.ChkClearSel.Checked = true;
            this.ChkClearSel.CheckState = System.Windows.Forms.CheckState.Checked;
            this.ChkClearSel.Location = new System.Drawing.Point(230, 225);
            this.ChkClearSel.Name = "ChkClearSel";
            this.ChkClearSel.Size = new System.Drawing.Size(65, 17);
            this.ChkClearSel.TabIndex = 15;
            this.ChkClearSel.Text = "clear sel";
            this.ChkClearSel.UseVisualStyleBackColor = true;
            // 
            // ChkSelHidden
            // 
            this.ChkSelHidden.AutoSize = true;
            this.ChkSelHidden.Location = new System.Drawing.Point(218, 198);
            this.ChkSelHidden.Name = "ChkSelHidden";
            this.ChkSelHidden.Size = new System.Drawing.Size(74, 17);
            this.ChkSelHidden.TabIndex = 16;
            this.ChkSelHidden.Text = "sel hidden";
            this.ChkSelHidden.UseVisualStyleBackColor = true;
            // 
            // CsharpToMaxTest
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(610, 492);
            this.Controls.Add(this.groupBox2);
            this.Controls.Add(this.BtnPrintNodeInstances);
            this.Controls.Add(this.BtnSelectNone);
            this.Controls.Add(this.BtnSelectAll);
            this.Controls.Add(this.BtnSelSimElements);
            this.Controls.Add(this.groupBox1);
            this.Controls.Add(this.button4);
            this.Controls.Add(this.button1);
            this.Name = "CsharpToMaxTest";
            this.Text = "Csharp To Max Test:";
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
        private System.Windows.Forms.Button button4;
        private System.Windows.Forms.Button button5;
        private System.Windows.Forms.GroupBox groupBox1;
        private System.Windows.Forms.Button BtnSelSimElements;
        private System.Windows.Forms.Button BtnSelectAll;
        private System.Windows.Forms.Button BtnSelectNone;
        private System.Windows.Forms.Button BtnPrintNodeInstances;
        private System.Windows.Forms.GroupBox groupBox2;
        private System.Windows.Forms.Button button6;
        private System.Windows.Forms.Button button7;
        private System.Windows.Forms.Button button8;
        private System.Windows.Forms.Button button9;
        private System.Windows.Forms.Button button10;
        private System.Windows.Forms.Button button11;
        private System.Windows.Forms.Button button12;
        private System.Windows.Forms.Button button13;
        private System.Windows.Forms.ComboBox CbxObjType;
        private System.Windows.Forms.CheckBox ChkPrintProps;
        private System.Windows.Forms.CheckBox ChkClearSel;
        private System.Windows.Forms.CheckBox ChkSelHidden;
    }
}