using Autodesk.Max;
using Orien.NetUi;
using System;
using System.Collections.Generic;
using System.Windows.Forms;

namespace Micra.Tools {
    public partial class MxGeometryOptimizer : Form {
        public MxGeometryOptimizer() {
            InitializeComponent();
        }

        private void OnToolbarDrag(object sender, MouseEventArgs e) {
            if ( e.Button == MouseButtons.Left ) {
                // Release the mouse capture started by the mouse down.
                ( sender as Panel ).Capture = false;
                // Create and send a WM_NCLBUTTONDOWN message.
                Message msg =
                    Message.Create(this.Handle, (int)McUIMsg.WM.NCLBUTTONDOWN,
                        new IntPtr((int)McUIMsg.HT.CAPTION), IntPtr.Zero);
                this.DefWndProc(ref msg);
            }
        }

        private void BtnClose_Click(object sender, EventArgs e) {
            this.Close();
        }

        private void BtnSelSimElements_Click(object sender, EventArgs e) {


        }

        private void BtnCreateConvexHull_Click(object sender, EventArgs e) {

        }
    }
}
