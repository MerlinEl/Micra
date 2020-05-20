namespace MyAssembly {
    partial class AssemblyUI {
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
            this.button10 = new System.Windows.Forms.Button();
            this.TbxAssemblyPath = new System.Windows.Forms.TextBox();
            this.button2 = new System.Windows.Forms.Button();
            this.button3 = new System.Windows.Forms.Button();
            this.button4 = new System.Windows.Forms.Button();
            this.button5 = new System.Windows.Forms.Button();
            this.SuspendLayout();
            // 
            // button1
            // 
            this.button1.Location = new System.Drawing.Point(22, 12);
            this.button1.Name = "button1";
            this.button1.Size = new System.Drawing.Size(103, 31);
            this.button1.TabIndex = 0;
            this.button1.Text = "Create Domain";
            this.button1.UseVisualStyleBackColor = true;
            this.button1.Click += new System.EventHandler(this.button1_Click);
            // 
            // button10
            // 
            this.button10.Location = new System.Drawing.Point(477, 46);
            this.button10.Name = "button10";
            this.button10.Size = new System.Drawing.Size(68, 23);
            this.button10.TabIndex = 15;
            this.button10.Text = "Load Assembly";
            this.button10.UseVisualStyleBackColor = true;
            this.button10.Click += new System.EventHandler(this.button10_Click);
            // 
            // TbxAssemblyPath
            // 
            this.TbxAssemblyPath.Location = new System.Drawing.Point(22, 49);
            this.TbxAssemblyPath.Name = "TbxAssemblyPath";
            this.TbxAssemblyPath.Size = new System.Drawing.Size(449, 20);
            this.TbxAssemblyPath.TabIndex = 14;
            this.TbxAssemblyPath.Text = "D:\\ReneBaca\\Aprog\\Micra\\Micra4\\Assembly\\Micra.Star.dll";
            this.TbxAssemblyPath.WordWrap = false;
            // 
            // button2
            // 
            this.button2.Location = new System.Drawing.Point(282, 12);
            this.button2.Name = "button2";
            this.button2.Size = new System.Drawing.Size(120, 31);
            this.button2.TabIndex = 16;
            this.button2.Text = "Destroy Domain";
            this.button2.UseVisualStyleBackColor = true;
            this.button2.Click += new System.EventHandler(this.button2_Click);
            // 
            // button3
            // 
            this.button3.Location = new System.Drawing.Point(131, 12);
            this.button3.Name = "button3";
            this.button3.Size = new System.Drawing.Size(145, 31);
            this.button3.TabIndex = 17;
            this.button3.Text = "Show Domain Assemblies";
            this.button3.UseVisualStyleBackColor = true;
            this.button3.Click += new System.EventHandler(this.button3_Click);
            // 
            // button4
            // 
            this.button4.Location = new System.Drawing.Point(189, 75);
            this.button4.Name = "button4";
            this.button4.Size = new System.Drawing.Size(194, 31);
            this.button4.TabIndex = 18;
            this.button4.Text = "Show Max Domain Assemblies";
            this.button4.UseVisualStyleBackColor = true;
            this.button4.Click += new System.EventHandler(this.button4_Click);
            // 
            // button5
            // 
            this.button5.Location = new System.Drawing.Point(413, 12);
            this.button5.Name = "button5";
            this.button5.Size = new System.Drawing.Size(132, 31);
            this.button5.TabIndex = 19;
            this.button5.Text = "Rebuild Domain";
            this.button5.UseVisualStyleBackColor = true;
            this.button5.Click += new System.EventHandler(this.button5_Click);
            // 
            // AssemblyUI
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(552, 107);
            this.Controls.Add(this.button5);
            this.Controls.Add(this.button4);
            this.Controls.Add(this.button3);
            this.Controls.Add(this.button2);
            this.Controls.Add(this.button10);
            this.Controls.Add(this.TbxAssemblyPath);
            this.Controls.Add(this.button1);
            this.Name = "AssemblyUI";
            this.Text = "AssemblyUI";
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Button button1;
        private System.Windows.Forms.Button button10;
        private System.Windows.Forms.TextBox TbxAssemblyPath;
        private System.Windows.Forms.Button button2;
        private System.Windows.Forms.Button button3;
        private System.Windows.Forms.Button button4;
        private System.Windows.Forms.Button button5;
    }
}