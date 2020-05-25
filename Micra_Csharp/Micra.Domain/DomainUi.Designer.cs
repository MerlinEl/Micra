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
            this.ChkCurrentDomain = new System.Windows.Forms.CheckBox();
            this.TbxDomainName = new System.Windows.Forms.TextBox();
            this.BtnGetDomain = new System.Windows.Forms.Button();
            this.LbxAssemblies = new System.Windows.Forms.ListBox();
            this.groupBox2 = new System.Windows.Forms.GroupBox();
            this.groupBox3 = new System.Windows.Forms.GroupBox();
            this.LbxAssemblyTypes = new System.Windows.Forms.ListBox();
            this.groupBox4 = new System.Windows.Forms.GroupBox();
            this.TbxTypeData = new System.Windows.Forms.TextBox();
            this.splitContainer1 = new System.Windows.Forms.SplitContainer();
            this.groupBox1.SuspendLayout();
            this.groupBox2.SuspendLayout();
            this.groupBox3.SuspendLayout();
            this.groupBox4.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer1)).BeginInit();
            this.splitContainer1.Panel1.SuspendLayout();
            this.splitContainer1.Panel2.SuspendLayout();
            this.splitContainer1.SuspendLayout();
            this.SuspendLayout();
            // 
            // BtnRebuildDomain
            // 
            this.BtnRebuildDomain.Location = new System.Drawing.Point(772, 17);
            this.BtnRebuildDomain.Name = "BtnRebuildDomain";
            this.BtnRebuildDomain.Size = new System.Drawing.Size(100, 22);
            this.BtnRebuildDomain.TabIndex = 25;
            this.BtnRebuildDomain.Text = "Rebuild Domain";
            this.BtnRebuildDomain.UseVisualStyleBackColor = true;
            this.BtnRebuildDomain.Click += new System.EventHandler(this.BtnRebuildDomain_Click);
            // 
            // DestroyDomain
            // 
            this.DestroyDomain.Location = new System.Drawing.Point(875, 17);
            this.DestroyDomain.Name = "DestroyDomain";
            this.DestroyDomain.Size = new System.Drawing.Size(100, 22);
            this.DestroyDomain.TabIndex = 23;
            this.DestroyDomain.Text = "Destroy Domain";
            this.DestroyDomain.UseVisualStyleBackColor = true;
            this.DestroyDomain.Click += new System.EventHandler(this.DestroyDomain_Click);
            // 
            // BtnLoadAssembly
            // 
            this.BtnLoadAssembly.Location = new System.Drawing.Point(672, 17);
            this.BtnLoadAssembly.Name = "BtnLoadAssembly";
            this.BtnLoadAssembly.Size = new System.Drawing.Size(97, 22);
            this.BtnLoadAssembly.TabIndex = 22;
            this.BtnLoadAssembly.Text = "Load Assembly";
            this.BtnLoadAssembly.UseVisualStyleBackColor = true;
            this.BtnLoadAssembly.Click += new System.EventHandler(this.BtnLoadAssembly_Click);
            // 
            // TbxAssemblyPath
            // 
            this.TbxAssemblyPath.Location = new System.Drawing.Point(372, 19);
            this.TbxAssemblyPath.Name = "TbxAssemblyPath";
            this.TbxAssemblyPath.Size = new System.Drawing.Size(294, 20);
            this.TbxAssemblyPath.TabIndex = 21;
            this.TbxAssemblyPath.Text = "D:\\ReneBaca\\Aprog\\Micra\\Micra4\\Assembly\\Micra.Star.dll";
            this.TbxAssemblyPath.WordWrap = false;
            this.TbxAssemblyPath.Enter += new System.EventHandler(this.OnTextAreaGotFocus);
            this.TbxAssemblyPath.Leave += new System.EventHandler(this.OnTextAreaLostFocus);
            // 
            // BtnCreateDomain
            // 
            this.BtnCreateDomain.Location = new System.Drawing.Point(6, 17);
            this.BtnCreateDomain.Name = "BtnCreateDomain";
            this.BtnCreateDomain.Size = new System.Drawing.Size(100, 22);
            this.BtnCreateDomain.TabIndex = 20;
            this.BtnCreateDomain.Text = "Create Domain";
            this.BtnCreateDomain.UseVisualStyleBackColor = true;
            this.BtnCreateDomain.Click += new System.EventHandler(this.BtnCreateDomain_Click);
            // 
            // groupBox1
            // 
            this.groupBox1.Controls.Add(this.ChkCurrentDomain);
            this.groupBox1.Controls.Add(this.TbxDomainName);
            this.groupBox1.Controls.Add(this.BtnLoadAssembly);
            this.groupBox1.Controls.Add(this.TbxAssemblyPath);
            this.groupBox1.Controls.Add(this.BtnGetDomain);
            this.groupBox1.Controls.Add(this.DestroyDomain);
            this.groupBox1.Controls.Add(this.BtnRebuildDomain);
            this.groupBox1.Controls.Add(this.BtnCreateDomain);
            this.groupBox1.Dock = System.Windows.Forms.DockStyle.Top;
            this.groupBox1.Location = new System.Drawing.Point(0, 0);
            this.groupBox1.Name = "groupBox1";
            this.groupBox1.Size = new System.Drawing.Size(983, 50);
            this.groupBox1.TabIndex = 26;
            this.groupBox1.TabStop = false;
            this.groupBox1.Text = "Domain:";
            // 
            // ChkCurrentDomain
            // 
            this.ChkCurrentDomain.AutoSize = true;
            this.ChkCurrentDomain.Location = new System.Drawing.Point(216, 19);
            this.ChkCurrentDomain.Name = "ChkCurrentDomain";
            this.ChkCurrentDomain.Size = new System.Drawing.Size(41, 17);
            this.ChkCurrentDomain.TabIndex = 30;
            this.ChkCurrentDomain.Text = "cur";
            this.ChkCurrentDomain.UseVisualStyleBackColor = true;
            this.ChkCurrentDomain.CheckedChanged += new System.EventHandler(this.ChkCurrentDomain_CheckedChanged);
            // 
            // TbxDomainName
            // 
            this.TbxDomainName.Location = new System.Drawing.Point(113, 17);
            this.TbxDomainName.Name = "TbxDomainName";
            this.TbxDomainName.Size = new System.Drawing.Size(97, 20);
            this.TbxDomainName.TabIndex = 29;
            this.TbxDomainName.Text = "Micra_Domain";
            this.TbxDomainName.Enter += new System.EventHandler(this.OnTextAreaGotFocus);
            this.TbxDomainName.Leave += new System.EventHandler(this.OnTextAreaLostFocus);
            // 
            // BtnGetDomain
            // 
            this.BtnGetDomain.Location = new System.Drawing.Point(263, 17);
            this.BtnGetDomain.Name = "BtnGetDomain";
            this.BtnGetDomain.Size = new System.Drawing.Size(100, 22);
            this.BtnGetDomain.TabIndex = 28;
            this.BtnGetDomain.Text = "Get Domain";
            this.BtnGetDomain.UseVisualStyleBackColor = true;
            this.BtnGetDomain.Click += new System.EventHandler(this.BtnGetDomain_Click);
            // 
            // LbxAssemblies
            // 
            this.LbxAssemblies.Dock = System.Windows.Forms.DockStyle.Fill;
            this.LbxAssemblies.FormattingEnabled = true;
            this.LbxAssemblies.Location = new System.Drawing.Point(3, 16);
            this.LbxAssemblies.Name = "LbxAssemblies";
            this.LbxAssemblies.Size = new System.Drawing.Size(486, 228);
            this.LbxAssemblies.TabIndex = 27;
            this.LbxAssemblies.SelectedValueChanged += new System.EventHandler(this.OnAssemblyItemSelectionChanged);
            // 
            // groupBox2
            // 
            this.groupBox2.Controls.Add(this.LbxAssemblies);
            this.groupBox2.Dock = System.Windows.Forms.DockStyle.Fill;
            this.groupBox2.Location = new System.Drawing.Point(0, 0);
            this.groupBox2.Name = "groupBox2";
            this.groupBox2.Size = new System.Drawing.Size(492, 247);
            this.groupBox2.TabIndex = 28;
            this.groupBox2.TabStop = false;
            this.groupBox2.Text = "Assemblies:";
            // 
            // groupBox3
            // 
            this.groupBox3.Controls.Add(this.LbxAssemblyTypes);
            this.groupBox3.Dock = System.Windows.Forms.DockStyle.Fill;
            this.groupBox3.Location = new System.Drawing.Point(0, 0);
            this.groupBox3.Name = "groupBox3";
            this.groupBox3.Size = new System.Drawing.Size(487, 247);
            this.groupBox3.TabIndex = 29;
            this.groupBox3.TabStop = false;
            this.groupBox3.Text = "Types:";
            // 
            // LbxAssemblyTypes
            // 
            this.LbxAssemblyTypes.Dock = System.Windows.Forms.DockStyle.Fill;
            this.LbxAssemblyTypes.FormattingEnabled = true;
            this.LbxAssemblyTypes.Location = new System.Drawing.Point(3, 16);
            this.LbxAssemblyTypes.Name = "LbxAssemblyTypes";
            this.LbxAssemblyTypes.Size = new System.Drawing.Size(481, 228);
            this.LbxAssemblyTypes.TabIndex = 0;
            this.LbxAssemblyTypes.SelectedValueChanged += new System.EventHandler(this.OnAssemblyTypeItemSelectionChanged);
            // 
            // groupBox4
            // 
            this.groupBox4.Controls.Add(this.TbxTypeData);
            this.groupBox4.Dock = System.Windows.Forms.DockStyle.Bottom;
            this.groupBox4.Location = new System.Drawing.Point(0, 297);
            this.groupBox4.Name = "groupBox4";
            this.groupBox4.Size = new System.Drawing.Size(983, 384);
            this.groupBox4.TabIndex = 30;
            this.groupBox4.TabStop = false;
            this.groupBox4.Text = "Members:";
            // 
            // TbxTypeData
            // 
            this.TbxTypeData.Dock = System.Windows.Forms.DockStyle.Fill;
            this.TbxTypeData.Location = new System.Drawing.Point(3, 16);
            this.TbxTypeData.Multiline = true;
            this.TbxTypeData.Name = "TbxTypeData";
            this.TbxTypeData.ScrollBars = System.Windows.Forms.ScrollBars.Vertical;
            this.TbxTypeData.Size = new System.Drawing.Size(977, 365);
            this.TbxTypeData.TabIndex = 0;
            // 
            // splitContainer1
            // 
            this.splitContainer1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.splitContainer1.IsSplitterFixed = true;
            this.splitContainer1.Location = new System.Drawing.Point(0, 50);
            this.splitContainer1.Name = "splitContainer1";
            // 
            // splitContainer1.Panel1
            // 
            this.splitContainer1.Panel1.Controls.Add(this.groupBox2);
            // 
            // splitContainer1.Panel2
            // 
            this.splitContainer1.Panel2.Controls.Add(this.groupBox3);
            this.splitContainer1.Size = new System.Drawing.Size(983, 247);
            this.splitContainer1.SplitterDistance = 492;
            this.splitContainer1.TabIndex = 31;
            // 
            // DomainUi
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(983, 681);
            this.Controls.Add(this.splitContainer1);
            this.Controls.Add(this.groupBox4);
            this.Controls.Add(this.groupBox1);
            this.Name = "DomainUi";
            this.Text = "DomainUi";
            this.groupBox1.ResumeLayout(false);
            this.groupBox1.PerformLayout();
            this.groupBox2.ResumeLayout(false);
            this.groupBox3.ResumeLayout(false);
            this.groupBox4.ResumeLayout(false);
            this.groupBox4.PerformLayout();
            this.splitContainer1.Panel1.ResumeLayout(false);
            this.splitContainer1.Panel2.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer1)).EndInit();
            this.splitContainer1.ResumeLayout(false);
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.Button BtnRebuildDomain;
        private System.Windows.Forms.Button DestroyDomain;
        private System.Windows.Forms.Button BtnLoadAssembly;
        private System.Windows.Forms.TextBox TbxAssemblyPath;
        private System.Windows.Forms.Button BtnCreateDomain;
        private System.Windows.Forms.GroupBox groupBox1;
        private System.Windows.Forms.ListBox LbxAssemblies;
        private System.Windows.Forms.Button BtnGetDomain;
        private System.Windows.Forms.GroupBox groupBox2;
        private System.Windows.Forms.GroupBox groupBox3;
        private System.Windows.Forms.ListBox LbxAssemblyTypes;
        private System.Windows.Forms.GroupBox groupBox4;
        private System.Windows.Forms.TextBox TbxTypeData;
        private System.Windows.Forms.TextBox TbxDomainName;
        private System.Windows.Forms.CheckBox ChkCurrentDomain;
        private System.Windows.Forms.SplitContainer splitContainer1;
    }
}