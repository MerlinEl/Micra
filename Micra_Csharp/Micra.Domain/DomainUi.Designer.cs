namespace Micra.Domain {
    partial class DomainUi {
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
            this.BtnRebuildDomain = new System.Windows.Forms.Button();
            this.DestroyDomain = new System.Windows.Forms.Button();
            this.BtnLoadAssembly = new System.Windows.Forms.Button();
            this.TbxAssemblyPath = new System.Windows.Forms.TextBox();
            this.BtnCreateDomain = new System.Windows.Forms.Button();
            this.groupBox1 = new System.Windows.Forms.GroupBox();
            this.TbxDomainName = new System.Windows.Forms.TextBox();
            this.LbxAssemblies = new System.Windows.Forms.ListBox();
            this.BtnGetDomain = new System.Windows.Forms.Button();
            this.groupBox1.SuspendLayout();
            this.SuspendLayout();
            // 
            // BtnRebuildDomain
            // 
            this.BtnRebuildDomain.Location = new System.Drawing.Point(328, 18);
            this.BtnRebuildDomain.Name = "BtnRebuildDomain";
            this.BtnRebuildDomain.Size = new System.Drawing.Size(100, 24);
            this.BtnRebuildDomain.TabIndex = 25;
            this.BtnRebuildDomain.Text = "Rebuild Domain";
            this.BtnRebuildDomain.UseVisualStyleBackColor = true;
            this.BtnRebuildDomain.Click += new System.EventHandler(this.BtnRebuildDomain_Click);
            // 
            // DestroyDomain
            // 
            this.DestroyDomain.Location = new System.Drawing.Point(434, 18);
            this.DestroyDomain.Name = "DestroyDomain";
            this.DestroyDomain.Size = new System.Drawing.Size(100, 24);
            this.DestroyDomain.TabIndex = 23;
            this.DestroyDomain.Text = "Destroy Domain";
            this.DestroyDomain.UseVisualStyleBackColor = true;
            this.DestroyDomain.Click += new System.EventHandler(this.DestroyDomain_Click);
            // 
            // BtnLoadAssembly
            // 
            this.BtnLoadAssembly.Location = new System.Drawing.Point(435, 46);
            this.BtnLoadAssembly.Name = "BtnLoadAssembly";
            this.BtnLoadAssembly.Size = new System.Drawing.Size(100, 22);
            this.BtnLoadAssembly.TabIndex = 22;
            this.BtnLoadAssembly.Text = "Load Assembly";
            this.BtnLoadAssembly.UseVisualStyleBackColor = true;
            this.BtnLoadAssembly.Click += new System.EventHandler(this.BtnLoadAssembly_Click);
            // 
            // TbxAssemblyPath
            // 
            this.TbxAssemblyPath.Location = new System.Drawing.Point(6, 48);
            this.TbxAssemblyPath.Name = "TbxAssemblyPath";
            this.TbxAssemblyPath.Size = new System.Drawing.Size(416, 20);
            this.TbxAssemblyPath.TabIndex = 21;
            this.TbxAssemblyPath.Text = "D:\\ReneBaca\\Aprog\\Micra\\Micra4\\Assembly\\Micra.Star.dll";
            this.TbxAssemblyPath.WordWrap = false;
            // 
            // BtnCreateDomain
            // 
            this.BtnCreateDomain.Location = new System.Drawing.Point(6, 18);
            this.BtnCreateDomain.Name = "BtnCreateDomain";
            this.BtnCreateDomain.Size = new System.Drawing.Size(100, 24);
            this.BtnCreateDomain.TabIndex = 20;
            this.BtnCreateDomain.Text = "Create Domain";
            this.BtnCreateDomain.UseVisualStyleBackColor = true;
            this.BtnCreateDomain.Click += new System.EventHandler(this.BtnCreateDomain_Click);
            // 
            // groupBox1
            // 
            this.groupBox1.Controls.Add(this.BtnGetDomain);
            this.groupBox1.Controls.Add(this.LbxAssemblies);
            this.groupBox1.Controls.Add(this.TbxDomainName);
            this.groupBox1.Controls.Add(this.DestroyDomain);
            this.groupBox1.Controls.Add(this.BtnRebuildDomain);
            this.groupBox1.Controls.Add(this.BtnCreateDomain);
            this.groupBox1.Controls.Add(this.TbxAssemblyPath);
            this.groupBox1.Controls.Add(this.BtnLoadAssembly);
            this.groupBox1.Location = new System.Drawing.Point(12, 12);
            this.groupBox1.Name = "groupBox1";
            this.groupBox1.Size = new System.Drawing.Size(535, 368);
            this.groupBox1.TabIndex = 26;
            this.groupBox1.TabStop = false;
            this.groupBox1.Text = "Manage:";
            // 
            // TbxDomainName
            // 
            this.TbxDomainName.Location = new System.Drawing.Point(112, 20);
            this.TbxDomainName.Name = "TbxDomainName";
            this.TbxDomainName.Size = new System.Drawing.Size(104, 20);
            this.TbxDomainName.TabIndex = 26;
            this.TbxDomainName.Text = "Micra_Domain";
            this.TbxDomainName.WordWrap = false;
            // 
            // LbxAssemblies
            // 
            this.LbxAssemblies.FormattingEnabled = true;
            this.LbxAssemblies.Location = new System.Drawing.Point(6, 74);
            this.LbxAssemblies.Name = "LbxAssemblies";
            this.LbxAssemblies.Size = new System.Drawing.Size(523, 290);
            this.LbxAssemblies.TabIndex = 27;
            this.LbxAssemblies.MouseDoubleClick += new System.Windows.Forms.MouseEventHandler(this.OnIListBoxIemDoubleClick);
            // 
            // BtnGetDomain
            // 
            this.BtnGetDomain.Location = new System.Drawing.Point(222, 18);
            this.BtnGetDomain.Name = "BtnGetDomain";
            this.BtnGetDomain.Size = new System.Drawing.Size(100, 24);
            this.BtnGetDomain.TabIndex = 28;
            this.BtnGetDomain.Text = "Get Domain";
            this.BtnGetDomain.UseVisualStyleBackColor = true;
            this.BtnGetDomain.Click += new System.EventHandler(this.BtnGetDomain_Click);
            // 
            // DomainUi
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(552, 384);
            this.Controls.Add(this.groupBox1);
            this.Name = "DomainUi";
            this.Text = "DomainUi";
            this.groupBox1.ResumeLayout(false);
            this.groupBox1.PerformLayout();
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.Button BtnRebuildDomain;
        private System.Windows.Forms.Button DestroyDomain;
        private System.Windows.Forms.Button BtnLoadAssembly;
        private System.Windows.Forms.TextBox TbxAssemblyPath;
        private System.Windows.Forms.Button BtnCreateDomain;
        private System.Windows.Forms.GroupBox groupBox1;
        private System.Windows.Forms.TextBox TbxDomainName;
        private System.Windows.Forms.ListBox LbxAssemblies;
        private System.Windows.Forms.Button BtnGetDomain;
    }
}