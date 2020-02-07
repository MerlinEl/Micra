/*
// Declare a label.
internal System.Windows.Forms.Label Label1;

// Initialize the label.
private void InitializeLabel()
{
    this.Label1 = new Label();
    this.Label1.Location = new System.Drawing.Point(10, 10);
    this.Label1.Name = "Label1";
    this.Label1.TabIndex = 0;

    // Set the label to a small size, but set the AutoSize property 
    // to true. The label will adjust its length so all the text
    // is visible, however if the label is wider than the form,
    // the entire label will not be visible.
    this.Label1.Size = new System.Drawing.Size(10, 10);
    this.Controls.Add(this.Label1);
    this.Label1.AutoSize = true;
    this.Label1.Text = "The text in this label is longer" +  
        " than the set size.";
}
*/


/*
// Copy this text into the Label using
// the biggest font that will fit.
private void SizeLabelFont(Label lbl)
{
    // Only bother if there's text.
    string txt = lbl.Text;
    if (txt.Length > 0)
    {
        int best_size = 100;

        // See how much room we have, allowing a bit
        // for the Label's internal margin.
        int wid = lbl.DisplayRectangle.Width - 3;
        int hgt = lbl.DisplayRectangle.Height - 3;

        // Make a Graphics object to measure the text.
        using (Graphics gr = lbl.CreateGraphics())
        {
            for (int i = 1; i <= 100; i++)
            {
                using (Font test_font =
                    new Font(lbl.Font.FontFamily, i))
                {
                    // See how much space the text would
                    // need, specifying a maximum width.
                    SizeF text_size =
                        gr.MeasureString(txt, test_font);
                    if ((text_size.Width > wid) ||
                        (text_size.Height > hgt))
                    {
                        best_size = i - 1;
                        break;
                    }
                }
            }
        }

        // Use that font size.
        lbl.Font = new Font(lbl.Font.FontFamily, best_size);
    }
}
*/


/* Use this to adapt for multi lines:

SizeChanged += (sender, args) =>
    {
        if (textBox1.Text.Length > 0)
        {
            int maxSize = 100;

            // Make a Graphics object to measure the text.
            using (Graphics gr = textBox1.CreateGraphics())
            {
                for (int i = 1; i < textBox1.Height)
                {
                    maxSize = i - 1;
                    break;
                }
            }
            catch (System.ComponentModel.Win32Exception)
            {
                // this sometimes throws a "failure to create window handle" error.
                // This might happen if the TextBox is invisible and/or
                // too small to display a toolbar.
                // do whatever here, add/delete, whatever, maybe set to default font size?
                maxSize = (int)textBox1.Font.Size;
            }
        }
    }

// Use that font size.
textBox1.Font = new Font(textBox1.Font.FontFamily, maxSize);
*/


using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Windows.Forms;

// This form demonstrates how to build a form layout that adjusts well
// when the user resizes the form. It also demonstrates a layout that 
// responds well to localization.
class BasicDataEntryForm : System.Windows.Forms.Form
{
    public BasicDataEntryForm()
    {
        InitializeComponent();
    }

    private System.ComponentModel.IContainer components = null;

    protected override void Dispose(bool disposing)
    {
        if (disposing && (components != null))
        {
            components.Dispose();
        }
        base.Dispose(disposing);
    }


    public override string ToString()
    {
        return "Basic Data Entry Form";
    }

    private void okBtn_Click(object sender, EventArgs e)
    {
        this.Close();
    }

    private void cancelBtn_Click(object sender, EventArgs e)
    {
        this.Close();
    }

    private void InitializeComponent()
    {
        this.tableLayoutPanel1 = new System.Windows.Forms.TableLayoutPanel();
        this.label1 = new System.Windows.Forms.Label();
        this.textBox1 = new System.Windows.Forms.TextBox();
        this.cancelBtn = new System.Windows.Forms.Button();
        this.okBtn = new System.Windows.Forms.Button();
        this.tableLayoutPanel1.SuspendLayout();
        this.SuspendLayout();
// 
// tableLayoutPanel1
// 
        this.tableLayoutPanel1.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom)
                    | System.Windows.Forms.AnchorStyles.Left)
                    | System.Windows.Forms.AnchorStyles.Right)));
        this.tableLayoutPanel1.ColumnCount = 4;
        this.tableLayoutPanel1.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle());
        this.tableLayoutPanel1.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 50F));
        this.tableLayoutPanel1.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle());
        this.tableLayoutPanel1.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 50F));
        this.tableLayoutPanel1.Controls.Add(this.label1, 0, 0);
        this.tableLayoutPanel1.Controls.Add(this.textBox1, 1, 0);
        this.tableLayoutPanel1.Location = new System.Drawing.Point(13, 13);
        this.tableLayoutPanel1.Name = "tableLayoutPanel1";
        this.tableLayoutPanel1.RowCount = 2;
        this.tableLayoutPanel1.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Absolute, 28F));
        this.tableLayoutPanel1.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Absolute, 28F));
        this.tableLayoutPanel1.Size = new System.Drawing.Size(623, 286);
        this.tableLayoutPanel1.TabIndex = 0;
// 
// label1
// 
        this.label1.Anchor = System.Windows.Forms.AnchorStyles.Right;
        this.label1.AutoSize = true;
        this.label1.Location = new System.Drawing.Point(3, 7);
        this.label1.Name = "label1";
        this.label1.Size = new System.Drawing.Size(59, 14);
        this.label1.TabIndex = 20;
        this.label1.Text = "First Name";
// 
// textBox1
// 
        this.textBox1.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Left | System.Windows.Forms.AnchorStyles.Right)));
        this.textBox1.Location = new System.Drawing.Point(68, 4);
        this.textBox1.Name = "textBox1";
        this.textBox1.Size = new System.Drawing.Size(249, 20);
        this.textBox1.TabIndex = 0;
// 
// cancelBtn
// 
        this.cancelBtn.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
        this.cancelBtn.DialogResult = System.Windows.Forms.DialogResult.Cancel;
        this.cancelBtn.Location = new System.Drawing.Point(558, 306);
        this.cancelBtn.Name = "cancelBtn";
        this.cancelBtn.TabIndex = 1;
        this.cancelBtn.Text = "Cancel";
        this.cancelBtn.Click += new System.EventHandler(this.cancelBtn_Click);
// 
// okBtn
// 
        this.okBtn.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
        this.okBtn.DialogResult = System.Windows.Forms.DialogResult.OK;
        this.okBtn.Location = new System.Drawing.Point(476, 306);
        this.okBtn.Name = "okBtn";
        this.okBtn.TabIndex = 0;
        this.okBtn.Text = "OK";
        this.okBtn.Click += new System.EventHandler(this.okBtn_Click);
// 
// BasicDataEntryForm
// 
        this.ClientSize = new System.Drawing.Size(642, 338);
        this.Controls.Add(this.okBtn);
        this.Controls.Add(this.cancelBtn);
        this.Controls.Add(this.tableLayoutPanel1);
        this.Name = "BasicDataEntryForm";
        this.Padding = new System.Windows.Forms.Padding(9);
        this.StartPosition = System.Windows.Forms.FormStartPosition.Manual;
        this.Text = "Basic Data Entry";
        this.tableLayoutPanel1.ResumeLayout(false);
        this.tableLayoutPanel1.PerformLayout();
        this.ResumeLayout(false);

    }

    private System.Windows.Forms.TableLayoutPanel tableLayoutPanel1;
    private System.Windows.Forms.Label label1;
    private System.Windows.Forms.Button cancelBtn;
    private System.Windows.Forms.Button okBtn;
    private System.Windows.Forms.TextBox textBox1;

    [STAThread]
    static void Main()
    {
        Application.EnableVisualStyles();
        Application.Run(new BasicDataEntryForm());
    }
}