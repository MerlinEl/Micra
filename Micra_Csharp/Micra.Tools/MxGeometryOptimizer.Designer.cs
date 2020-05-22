namespace Micra.Tools {
    partial class MxGeometryOptimizer {
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
            this.BtnSelSimElements = new System.Windows.Forms.Button();
            this.groupBox1 = new System.Windows.Forms.GroupBox();
            this.label10 = new System.Windows.Forms.Label();
            this.numericUpDown6 = new System.Windows.Forms.NumericUpDown();
            this.button12 = new System.Windows.Forms.Button();
            this.label6 = new System.Windows.Forms.Label();
            this.label4 = new System.Windows.Forms.Label();
            this.label5 = new System.Windows.Forms.Label();
            this.numericUpDown2 = new System.Windows.Forms.NumericUpDown();
            this.BtnSelectFacesByThickness = new System.Windows.Forms.Button();
            this.comboBox1 = new System.Windows.Forms.ComboBox();
            this.label3 = new System.Windows.Forms.Label();
            this.BtnSelectFacesByNormal = new System.Windows.Forms.Button();
            this.label2 = new System.Windows.Forms.Label();
            this.label1 = new System.Windows.Forms.Label();
            this.SpnAreaOffset = new System.Windows.Forms.NumericUpDown();
            this.groupBox2 = new System.Windows.Forms.GroupBox();
            this.checkBox1 = new System.Windows.Forms.CheckBox();
            this.BtnFlatenByNormal = new System.Windows.Forms.Button();
            this.BtnFlatenTop = new System.Windows.Forms.Button();
            this.BtnFuseEdges = new System.Windows.Forms.Button();
            this.BtnUnchamferEring = new System.Windows.Forms.Button();
            this.label11 = new System.Windows.Forms.Label();
            this.label12 = new System.Windows.Forms.Label();
            this.numericUpDown4 = new System.Windows.Forms.NumericUpDown();
            this.BtnOptimizeEring = new System.Windows.Forms.Button();
            this.groupBox3 = new System.Windows.Forms.GroupBox();
            this.BtnCreateConcaveHull = new System.Windows.Forms.Button();
            this.BtnCreateBoundingBox = new System.Windows.Forms.Button();
            this.BtnCreateBoundingPlane = new System.Windows.Forms.Button();
            this.label9 = new System.Windows.Forms.Label();
            this.numericUpDown5 = new System.Windows.Forms.NumericUpDown();
            this.label7 = new System.Windows.Forms.Label();
            this.label8 = new System.Windows.Forms.Label();
            this.numericUpDown3 = new System.Windows.Forms.NumericUpDown();
            this.BtnCreateConvexHull = new System.Windows.Forms.Button();
            this.TitleBar = new System.Windows.Forms.Panel();
            this.BtnClose = new System.Windows.Forms.Button();
            this.TitleLabel = new System.Windows.Forms.Label();
            this.groupBox1.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.numericUpDown6)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.numericUpDown2)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.SpnAreaOffset)).BeginInit();
            this.groupBox2.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.numericUpDown4)).BeginInit();
            this.groupBox3.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.numericUpDown5)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.numericUpDown3)).BeginInit();
            this.TitleBar.SuspendLayout();
            this.SuspendLayout();
            // 
            // BtnSelSimElements
            // 
            this.BtnSelSimElements.Location = new System.Drawing.Point(4, 19);
            this.BtnSelSimElements.Name = "BtnSelSimElements";
            this.BtnSelSimElements.Size = new System.Drawing.Size(144, 23);
            this.BtnSelSimElements.TabIndex = 0;
            this.BtnSelSimElements.Text = "Select Simillar Elements";
            this.BtnSelSimElements.UseVisualStyleBackColor = true;
            this.BtnSelSimElements.Click += new System.EventHandler(this.BtnSelSimElements_Click);
            // 
            // groupBox1
            // 
            this.groupBox1.Controls.Add(this.label10);
            this.groupBox1.Controls.Add(this.numericUpDown6);
            this.groupBox1.Controls.Add(this.button12);
            this.groupBox1.Controls.Add(this.label6);
            this.groupBox1.Controls.Add(this.label4);
            this.groupBox1.Controls.Add(this.label5);
            this.groupBox1.Controls.Add(this.numericUpDown2);
            this.groupBox1.Controls.Add(this.BtnSelectFacesByThickness);
            this.groupBox1.Controls.Add(this.comboBox1);
            this.groupBox1.Controls.Add(this.label3);
            this.groupBox1.Controls.Add(this.BtnSelectFacesByNormal);
            this.groupBox1.Controls.Add(this.label2);
            this.groupBox1.Controls.Add(this.label1);
            this.groupBox1.Controls.Add(this.SpnAreaOffset);
            this.groupBox1.Controls.Add(this.BtnSelSimElements);
            this.groupBox1.Location = new System.Drawing.Point(4, 29);
            this.groupBox1.Name = "groupBox1";
            this.groupBox1.Size = new System.Drawing.Size(154, 246);
            this.groupBox1.TabIndex = 1;
            this.groupBox1.TabStop = false;
            this.groupBox1.Text = "Select:";
            // 
            // label10
            // 
            this.label10.AutoSize = true;
            this.label10.Location = new System.Drawing.Point(9, 225);
            this.label10.Name = "label10";
            this.label10.Size = new System.Drawing.Size(35, 13);
            this.label10.TabIndex = 8;
            this.label10.Text = "Each:";
            // 
            // numericUpDown6
            // 
            this.numericUpDown6.Location = new System.Drawing.Point(72, 220);
            this.numericUpDown6.Name = "numericUpDown6";
            this.numericUpDown6.Size = new System.Drawing.Size(76, 20);
            this.numericUpDown6.TabIndex = 7;
            this.numericUpDown6.Value = new decimal(new int[] {
            1,
            0,
            0,
            0});
            // 
            // button12
            // 
            this.button12.Location = new System.Drawing.Point(4, 192);
            this.button12.Name = "button12";
            this.button12.Size = new System.Drawing.Size(144, 23);
            this.button12.TabIndex = 12;
            this.button12.Text = "Slect Limited Loop";
            this.button12.UseVisualStyleBackColor = true;
            // 
            // label6
            // 
            this.label6.BorderStyle = System.Windows.Forms.BorderStyle.Fixed3D;
            this.label6.Location = new System.Drawing.Point(4, 130);
            this.label6.Name = "label6";
            this.label6.Size = new System.Drawing.Size(148, 2);
            this.label6.TabIndex = 11;
            // 
            // label4
            // 
            this.label4.BorderStyle = System.Windows.Forms.BorderStyle.Fixed3D;
            this.label4.Location = new System.Drawing.Point(4, 187);
            this.label4.Name = "label4";
            this.label4.Size = new System.Drawing.Size(146, 2);
            this.label4.TabIndex = 9;
            // 
            // label5
            // 
            this.label5.AutoSize = true;
            this.label5.Location = new System.Drawing.Point(6, 166);
            this.label5.Name = "label5";
            this.label5.Size = new System.Drawing.Size(58, 13);
            this.label5.TabIndex = 10;
            this.label5.Text = "Tolerance:";
            // 
            // numericUpDown2
            // 
            this.numericUpDown2.Increment = new decimal(new int[] {
            1,
            0,
            0,
            65536});
            this.numericUpDown2.Location = new System.Drawing.Point(72, 164);
            this.numericUpDown2.Name = "numericUpDown2";
            this.numericUpDown2.Size = new System.Drawing.Size(76, 20);
            this.numericUpDown2.TabIndex = 8;
            this.numericUpDown2.Value = new decimal(new int[] {
            5,
            0,
            0,
            65536});
            // 
            // BtnSelectFacesByThickness
            // 
            this.BtnSelectFacesByThickness.Location = new System.Drawing.Point(4, 135);
            this.BtnSelectFacesByThickness.Name = "BtnSelectFacesByThickness";
            this.BtnSelectFacesByThickness.Size = new System.Drawing.Size(144, 23);
            this.BtnSelectFacesByThickness.TabIndex = 7;
            this.BtnSelectFacesByThickness.Text = "Select Faces By Thickness";
            this.BtnSelectFacesByThickness.UseVisualStyleBackColor = true;
            // 
            // comboBox1
            // 
            this.comboBox1.AutoCompleteCustomSource.AddRange(new string[] {
            "fromface",
            "left",
            "tight",
            "front",
            "back",
            "top",
            "bottom"});
            this.comboBox1.FormattingEnabled = true;
            this.comboBox1.Location = new System.Drawing.Point(51, 103);
            this.comboBox1.Name = "comboBox1";
            this.comboBox1.Size = new System.Drawing.Size(97, 21);
            this.comboBox1.TabIndex = 6;
            // 
            // label3
            // 
            this.label3.AutoSize = true;
            this.label3.Location = new System.Drawing.Point(8, 107);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(46, 13);
            this.label3.TabIndex = 5;
            this.label3.Text = "Method:";
            // 
            // BtnSelectFacesByNormal
            // 
            this.BtnSelectFacesByNormal.Location = new System.Drawing.Point(6, 76);
            this.BtnSelectFacesByNormal.Name = "BtnSelectFacesByNormal";
            this.BtnSelectFacesByNormal.Size = new System.Drawing.Size(144, 23);
            this.BtnSelectFacesByNormal.TabIndex = 3;
            this.BtnSelectFacesByNormal.Text = "Select Faces By Normal";
            this.BtnSelectFacesByNormal.UseVisualStyleBackColor = true;
            // 
            // label2
            // 
            this.label2.BorderStyle = System.Windows.Forms.BorderStyle.Fixed3D;
            this.label2.Location = new System.Drawing.Point(4, 71);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(146, 2);
            this.label2.TabIndex = 2;
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(6, 50);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(58, 13);
            this.label1.TabIndex = 2;
            this.label1.Text = "Tolerance:";
            // 
            // SpnAreaOffset
            // 
            this.SpnAreaOffset.Increment = new decimal(new int[] {
            1,
            0,
            0,
            65536});
            this.SpnAreaOffset.Location = new System.Drawing.Point(72, 48);
            this.SpnAreaOffset.Name = "SpnAreaOffset";
            this.SpnAreaOffset.Size = new System.Drawing.Size(76, 20);
            this.SpnAreaOffset.TabIndex = 1;
            this.SpnAreaOffset.Value = new decimal(new int[] {
            10,
            0,
            0,
            0});
            // 
            // groupBox2
            // 
            this.groupBox2.Controls.Add(this.checkBox1);
            this.groupBox2.Controls.Add(this.BtnFlatenByNormal);
            this.groupBox2.Controls.Add(this.BtnFlatenTop);
            this.groupBox2.Controls.Add(this.BtnFuseEdges);
            this.groupBox2.Controls.Add(this.BtnUnchamferEring);
            this.groupBox2.Controls.Add(this.label11);
            this.groupBox2.Controls.Add(this.label12);
            this.groupBox2.Controls.Add(this.numericUpDown4);
            this.groupBox2.Controls.Add(this.BtnOptimizeEring);
            this.groupBox2.Location = new System.Drawing.Point(164, 29);
            this.groupBox2.Name = "groupBox2";
            this.groupBox2.Size = new System.Drawing.Size(154, 246);
            this.groupBox2.TabIndex = 12;
            this.groupBox2.TabStop = false;
            this.groupBox2.Text = "Optimize:";
            // 
            // checkBox1
            // 
            this.checkBox1.AutoSize = true;
            this.checkBox1.Location = new System.Drawing.Point(100, 105);
            this.checkBox1.Name = "checkBox1";
            this.checkBox1.RightToLeft = System.Windows.Forms.RightToLeft.Yes;
            this.checkBox1.Size = new System.Drawing.Size(48, 17);
            this.checkBox1.TabIndex = 7;
            this.checkBox1.Text = "wipe";
            this.checkBox1.UseVisualStyleBackColor = true;
            // 
            // BtnFlatenByNormal
            // 
            this.BtnFlatenByNormal.Location = new System.Drawing.Point(4, 156);
            this.BtnFlatenByNormal.Name = "BtnFlatenByNormal";
            this.BtnFlatenByNormal.Size = new System.Drawing.Size(144, 23);
            this.BtnFlatenByNormal.TabIndex = 6;
            this.BtnFlatenByNormal.Text = "Flatten By Face N";
            this.BtnFlatenByNormal.UseVisualStyleBackColor = true;
            // 
            // BtnFlatenTop
            // 
            this.BtnFlatenTop.Location = new System.Drawing.Point(4, 130);
            this.BtnFlatenTop.Name = "BtnFlatenTop";
            this.BtnFlatenTop.Size = new System.Drawing.Size(144, 23);
            this.BtnFlatenTop.TabIndex = 5;
            this.BtnFlatenTop.Text = "Flatten Top";
            this.BtnFlatenTop.UseVisualStyleBackColor = true;
            // 
            // BtnFuseEdges
            // 
            this.BtnFuseEdges.Location = new System.Drawing.Point(4, 102);
            this.BtnFuseEdges.Name = "BtnFuseEdges";
            this.BtnFuseEdges.Size = new System.Drawing.Size(92, 23);
            this.BtnFuseEdges.TabIndex = 4;
            this.BtnFuseEdges.Text = "Fuse Edges";
            this.BtnFuseEdges.UseVisualStyleBackColor = true;
            // 
            // BtnUnchamferEring
            // 
            this.BtnUnchamferEring.Location = new System.Drawing.Point(4, 76);
            this.BtnUnchamferEring.Name = "BtnUnchamferEring";
            this.BtnUnchamferEring.Size = new System.Drawing.Size(144, 23);
            this.BtnUnchamferEring.TabIndex = 3;
            this.BtnUnchamferEring.Text = "Unchamfer eRing";
            this.BtnUnchamferEring.UseVisualStyleBackColor = true;
            // 
            // label11
            // 
            this.label11.BorderStyle = System.Windows.Forms.BorderStyle.Fixed3D;
            this.label11.Location = new System.Drawing.Point(4, 71);
            this.label11.Name = "label11";
            this.label11.Size = new System.Drawing.Size(148, 2);
            this.label11.TabIndex = 2;
            // 
            // label12
            // 
            this.label12.AutoSize = true;
            this.label12.Location = new System.Drawing.Point(6, 50);
            this.label12.Name = "label12";
            this.label12.Size = new System.Drawing.Size(62, 13);
            this.label12.TabIndex = 2;
            this.label12.Text = "Max length:";
            // 
            // numericUpDown4
            // 
            this.numericUpDown4.Increment = new decimal(new int[] {
            1,
            0,
            0,
            65536});
            this.numericUpDown4.Location = new System.Drawing.Point(72, 48);
            this.numericUpDown4.Name = "numericUpDown4";
            this.numericUpDown4.Size = new System.Drawing.Size(76, 20);
            this.numericUpDown4.TabIndex = 1;
            this.numericUpDown4.Value = new decimal(new int[] {
            3,
            0,
            0,
            0});
            // 
            // BtnOptimizeEring
            // 
            this.BtnOptimizeEring.Location = new System.Drawing.Point(4, 19);
            this.BtnOptimizeEring.Name = "BtnOptimizeEring";
            this.BtnOptimizeEring.Size = new System.Drawing.Size(144, 23);
            this.BtnOptimizeEring.TabIndex = 0;
            this.BtnOptimizeEring.Text = "Optimize By eRing";
            this.BtnOptimizeEring.UseVisualStyleBackColor = true;
            // 
            // groupBox3
            // 
            this.groupBox3.Controls.Add(this.BtnCreateConcaveHull);
            this.groupBox3.Controls.Add(this.BtnCreateBoundingBox);
            this.groupBox3.Controls.Add(this.BtnCreateBoundingPlane);
            this.groupBox3.Controls.Add(this.label9);
            this.groupBox3.Controls.Add(this.numericUpDown5);
            this.groupBox3.Controls.Add(this.label7);
            this.groupBox3.Controls.Add(this.label8);
            this.groupBox3.Controls.Add(this.numericUpDown3);
            this.groupBox3.Controls.Add(this.BtnCreateConvexHull);
            this.groupBox3.Location = new System.Drawing.Point(324, 29);
            this.groupBox3.Name = "groupBox3";
            this.groupBox3.Size = new System.Drawing.Size(154, 246);
            this.groupBox3.TabIndex = 13;
            this.groupBox3.TabStop = false;
            this.groupBox3.Text = "Create:";
            // 
            // BtnCreateConcaveHull
            // 
            this.BtnCreateConcaveHull.Location = new System.Drawing.Point(6, 99);
            this.BtnCreateConcaveHull.Name = "BtnCreateConcaveHull";
            this.BtnCreateConcaveHull.Size = new System.Drawing.Size(144, 23);
            this.BtnCreateConcaveHull.TabIndex = 7;
            this.BtnCreateConcaveHull.Text = "Create Concave Hull";
            this.BtnCreateConcaveHull.UseVisualStyleBackColor = true;
            // 
            // BtnCreateBoundingBox
            // 
            this.BtnCreateBoundingBox.Location = new System.Drawing.Point(6, 188);
            this.BtnCreateBoundingBox.Name = "BtnCreateBoundingBox";
            this.BtnCreateBoundingBox.Size = new System.Drawing.Size(144, 23);
            this.BtnCreateBoundingBox.TabIndex = 6;
            this.BtnCreateBoundingBox.Text = "Create Bounding Box";
            this.BtnCreateBoundingBox.UseVisualStyleBackColor = true;
            // 
            // BtnCreateBoundingPlane
            // 
            this.BtnCreateBoundingPlane.Location = new System.Drawing.Point(6, 215);
            this.BtnCreateBoundingPlane.Name = "BtnCreateBoundingPlane";
            this.BtnCreateBoundingPlane.Size = new System.Drawing.Size(144, 23);
            this.BtnCreateBoundingPlane.TabIndex = 5;
            this.BtnCreateBoundingPlane.Text = "Create Bounding Plane";
            this.BtnCreateBoundingPlane.UseVisualStyleBackColor = true;
            // 
            // label9
            // 
            this.label9.AutoSize = true;
            this.label9.Location = new System.Drawing.Point(6, 73);
            this.label9.Name = "label9";
            this.label9.Size = new System.Drawing.Size(47, 13);
            this.label9.TabIndex = 4;
            this.label9.Text = "Inflation:";
            // 
            // numericUpDown5
            // 
            this.numericUpDown5.Increment = new decimal(new int[] {
            1,
            0,
            0,
            65536});
            this.numericUpDown5.Location = new System.Drawing.Point(72, 71);
            this.numericUpDown5.Name = "numericUpDown5";
            this.numericUpDown5.Size = new System.Drawing.Size(76, 20);
            this.numericUpDown5.TabIndex = 3;
            this.numericUpDown5.Value = new decimal(new int[] {
            5,
            0,
            0,
            65536});
            // 
            // label7
            // 
            this.label7.BorderStyle = System.Windows.Forms.BorderStyle.Fixed3D;
            this.label7.Location = new System.Drawing.Point(4, 94);
            this.label7.Name = "label7";
            this.label7.Size = new System.Drawing.Size(148, 2);
            this.label7.TabIndex = 2;
            // 
            // label8
            // 
            this.label8.AutoSize = true;
            this.label8.Location = new System.Drawing.Point(6, 50);
            this.label8.Name = "label8";
            this.label8.Size = new System.Drawing.Size(49, 13);
            this.label8.TabIndex = 2;
            this.label8.Text = "Vert limit:";
            // 
            // numericUpDown3
            // 
            this.numericUpDown3.Increment = new decimal(new int[] {
            1,
            0,
            0,
            65536});
            this.numericUpDown3.Location = new System.Drawing.Point(72, 48);
            this.numericUpDown3.Name = "numericUpDown3";
            this.numericUpDown3.Size = new System.Drawing.Size(76, 20);
            this.numericUpDown3.TabIndex = 1;
            this.numericUpDown3.Value = new decimal(new int[] {
            20,
            0,
            0,
            0});
            // 
            // BtnCreateConvexHull
            // 
            this.BtnCreateConvexHull.Location = new System.Drawing.Point(4, 19);
            this.BtnCreateConvexHull.Name = "BtnCreateConvexHull";
            this.BtnCreateConvexHull.Size = new System.Drawing.Size(144, 23);
            this.BtnCreateConvexHull.TabIndex = 0;
            this.BtnCreateConvexHull.Text = "Create Convex Hull";
            this.BtnCreateConvexHull.UseVisualStyleBackColor = true;
            this.BtnCreateConvexHull.Click += new System.EventHandler(this.BtnCreateConvexHull_Click);
            // 
            // TitleBar
            // 
            this.TitleBar.BackColor = System.Drawing.SystemColors.MenuHighlight;
            this.TitleBar.Controls.Add(this.BtnClose);
            this.TitleBar.Controls.Add(this.TitleLabel);
            this.TitleBar.Dock = System.Windows.Forms.DockStyle.Top;
            this.TitleBar.Location = new System.Drawing.Point(0, 0);
            this.TitleBar.Name = "TitleBar";
            this.TitleBar.Size = new System.Drawing.Size(482, 23);
            this.TitleBar.TabIndex = 14;
            this.TitleBar.MouseDown += new System.Windows.Forms.MouseEventHandler(this.OnToolbarDrag);
            // 
            // BtnClose
            // 
            this.BtnClose.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.BtnClose.FlatAppearance.BorderSize = 0;
            this.BtnClose.FlatAppearance.MouseOverBackColor = System.Drawing.Color.LightSkyBlue;
            this.BtnClose.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.BtnClose.Font = new System.Drawing.Font("Verdana", 9.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.BtnClose.ForeColor = System.Drawing.Color.Cyan;
            this.BtnClose.Location = new System.Drawing.Point(455, 0);
            this.BtnClose.Name = "BtnClose";
            this.BtnClose.Size = new System.Drawing.Size(27, 25);
            this.BtnClose.TabIndex = 16;
            this.BtnClose.Text = "X";
            this.BtnClose.UseVisualStyleBackColor = true;
            this.BtnClose.Click += new System.EventHandler(this.BtnClose_Click);
            // 
            // TitleLabel
            // 
            this.TitleLabel.AutoSize = true;
            this.TitleLabel.Dock = System.Windows.Forms.DockStyle.Top;
            this.TitleLabel.Font = new System.Drawing.Font("Century Gothic", 12F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.TitleLabel.ForeColor = System.Drawing.Color.Cyan;
            this.TitleLabel.Location = new System.Drawing.Point(0, 0);
            this.TitleLabel.Name = "TitleLabel";
            this.TitleLabel.Size = new System.Drawing.Size(168, 19);
            this.TitleLabel.TabIndex = 15;
            this.TitleLabel.Text = "Geometry Optimizer:";
            // 
            // MxGeometryOptimizer
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackgroundImageLayout = System.Windows.Forms.ImageLayout.None;
            this.ClientSize = new System.Drawing.Size(482, 279);
            this.Controls.Add(this.TitleBar);
            this.Controls.Add(this.groupBox3);
            this.Controls.Add(this.groupBox2);
            this.Controls.Add(this.groupBox1);
            this.DoubleBuffered = true;
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.None;
            this.Name = "MxGeometryOptimizer";
            this.Text = " Geometry Optimizer";
            this.groupBox1.ResumeLayout(false);
            this.groupBox1.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.numericUpDown6)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.numericUpDown2)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.SpnAreaOffset)).EndInit();
            this.groupBox2.ResumeLayout(false);
            this.groupBox2.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.numericUpDown4)).EndInit();
            this.groupBox3.ResumeLayout(false);
            this.groupBox3.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.numericUpDown5)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.numericUpDown3)).EndInit();
            this.TitleBar.ResumeLayout(false);
            this.TitleBar.PerformLayout();
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.Button BtnSelSimElements;
        private System.Windows.Forms.GroupBox groupBox1;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.NumericUpDown SpnAreaOffset;
        private System.Windows.Forms.Label label6;
        private System.Windows.Forms.Label label4;
        private System.Windows.Forms.Label label5;
        private System.Windows.Forms.NumericUpDown numericUpDown2;
        private System.Windows.Forms.Button BtnSelectFacesByThickness;
        private System.Windows.Forms.ComboBox comboBox1;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.Button BtnSelectFacesByNormal;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.GroupBox groupBox2;
        private System.Windows.Forms.Label label11;
        private System.Windows.Forms.Label label12;
        private System.Windows.Forms.NumericUpDown numericUpDown4;
        private System.Windows.Forms.Button BtnOptimizeEring;
        private System.Windows.Forms.GroupBox groupBox3;
        private System.Windows.Forms.Label label9;
        private System.Windows.Forms.NumericUpDown numericUpDown5;
        private System.Windows.Forms.Label label7;
        private System.Windows.Forms.Label label8;
        private System.Windows.Forms.NumericUpDown numericUpDown3;
        private System.Windows.Forms.Button BtnCreateConvexHull;
        private System.Windows.Forms.Button BtnFlatenByNormal;
        private System.Windows.Forms.Button BtnFlatenTop;
        private System.Windows.Forms.Button BtnFuseEdges;
        private System.Windows.Forms.Button BtnUnchamferEring;
        private System.Windows.Forms.Button BtnCreateBoundingBox;
        private System.Windows.Forms.Button BtnCreateBoundingPlane;
        private System.Windows.Forms.CheckBox checkBox1;
        private System.Windows.Forms.Label label10;
        private System.Windows.Forms.NumericUpDown numericUpDown6;
        private System.Windows.Forms.Button button12;
        private System.Windows.Forms.Panel TitleBar;
        private System.Windows.Forms.Label TitleLabel;
        private System.Windows.Forms.Button BtnClose;
        private System.Windows.Forms.Button BtnCreateConcaveHull;
    }
}