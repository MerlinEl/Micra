private void label1_Paint(object sender, PaintEventArgs e)
        {

                Control lblControl = (Control)sender;
                SolidBrush drawBrush = new SolidBrush(lblControl.ForeColor);
                StringFormat strformat = new StringFormat();
            
                System.Drawing.Rectangle rect = new System.Drawing.Rectangle(0, 0, e.ClipRectangle.Width, e.ClipRectangle.Height);
                System.Drawing.Graphics lblGraphics = e.Graphics;
                lblGraphics.FillRectangle(new System.Drawing.Drawing2D.LinearGradientBrush(rect, Color.Blue, Color.White, System.Drawing.Drawing2D.LinearGradientMode.BackwardDiagonal), rect);
                
                strformat.Alignment = StringAlignment.Center;
                RectangleF rectF = new RectangleF(0, lblControl.Height / 2 - Font.Height / 2, lblControl.Width, lblControl.Height);
                lblGraphics.DrawString(lblControl.Text, lblControl.Font, drawBrush, rectF, strformat);
                e.Dispose();
           
        }