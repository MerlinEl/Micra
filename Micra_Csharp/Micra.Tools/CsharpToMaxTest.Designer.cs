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
            this.groupBox1.SuspendLayout();
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
            this.button4.Location = new System.Drawing.Point(190, 12);
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
            this.BtnSelectAll.Location = new System.Drawing.Point(430, 261);
            this.BtnSelectAll.Name = "BtnSelectAll";
            this.BtnSelectAll.Size = new System.Drawing.Size(172, 23);
            this.BtnSelectAll.TabIndex = 9;
            this.BtnSelectAll.Text = "Select All";
            this.BtnSelectAll.UseVisualStyleBackColor = true;
            this.BtnSelectAll.Click += new System.EventHandler(this.BtnSelectAll_Click);
            // 
            // BtnSelectNone
            // 
            this.BtnSelectNone.Location = new System.Drawing.Point(430, 290);
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
            // CsharpToMaxTest
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(610, 492);
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
    }
}