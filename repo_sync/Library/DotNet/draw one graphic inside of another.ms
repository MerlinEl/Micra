
            Bitmap ReqdBmp = new Bitmap(100, 100);
            Graphics Gra = pictureBox1.CreateGraphics();
            Graphics g2 = pictureBox2.CreateGraphics();
            g2.DrawImage(pictureBox1.Image, new Rectangle(0, 0, ReqdBmp.Width, ReqdBmp.Height), new Rectangle(100, 100, ReqdBmp.Width, ReqdBmp.Height), GraphicsUnit.Pixel);