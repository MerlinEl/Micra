using Orien.NetUi;
using System;
using System.Windows.Forms;

namespace Micra.Tools {
    public partial class MxGeometryOptimizer:Form {
        public MxGeometryOptimizer() {
            InitializeComponent();
            InitTooltips();
        }

        private void InitTooltips() {

            MxUi.SetButonTooltip(BtnFlatenTop, "Delete other faces than in top.", "tltp_flatten_01");
            MxUi.SetButonTooltip(BtnOptimizeEring, "Remove all rings which have smal length.", "tltp_unchamfer_03");
            MxUi.SetButonTooltip(BtnUnchamferEring, "Remove Chamfer and restore object volume", "tltp_unchamfer_01");
            MxUi.SetButonTooltip(BtnFuseEdges, "Connect edges and remove seam(optional)", "tltp_fuse_edges_01");
            MxUi.SetButonTooltip(BtnSelectFacesByNormal, "Select faces with same normal", "tltp_fsel_by_normal_01");
            MxUi.SetButonTooltip(BtnSelectFacesByThickness, "Select faces with same edge thickness", "tltp_fsel_by_tickness_01");
            MxUi.SetButonTooltip(BtnSelSimElements, "Select elements with simmilar volume", "tltp_fsel_by_size_01");
            MxUi.SetButonTooltip(BtnCreateBoundingBox, "Create Bounding Box from selected faces.", "tltp_bb_box_01");
            MxUi.SetButonTooltip(BtnCreateBoundingPlane, "Create Bounding Plane from selected faces.", "tltp_bb_plane_01");
            MxUi.SetButonTooltip(BtnCreateConvexHull, "Create Convex Hull from selected Objects", "tltp_convex_hull_01");
        }

        private void OnToolbarDrag(object sender, MouseEventArgs e) {
            if ( e.Button == MouseButtons.Left ) {
                // Release the mouse capture started by the mouse down.
                ( sender as Panel ).Capture = false;
                // Create and send a WM_NCLBUTTONDOWN message.
                Message msg =
                    Message.Create(this.Handle, ( int )McUIMsg.WM.NCLBUTTONDOWN,
                        new IntPtr(( int )McUIMsg.HT.CAPTION), IntPtr.Zero);
                this.DefWndProc(ref msg);
            }
        }

        private void BtnClose_Click(object sender, EventArgs e) {
            this.Close();
        }

        private void BtnSelSimElements_Click(object sender, EventArgs e) {

            /*IINode obj = MxCollection.GetFirstSelectedNode();
            if (!(obj is IEditableObject)) return;
            int slev = MxGet.Interface.SubObjectLevel;

            Kernel.WriteLine("selectedObject:{0} subobjectLevel:{1}", obj.Name, slev);
 
            if (slev == 4 || slev == 5 ) { //select geometry with simillar volume

                Kernel.WriteLine("select geometry with simillar volume"); 

            } else { //select objects with simillar volume

                Kernel.WriteLine("select objects with simillar volume");
            }*/

            /*MxSet.ExecuteMAXScriptScript("" +
                "mcPoly.selectSimilarElements selection[1] " +
                "offset:" + SpnAreaOffset.Value.ToString()
            );*/
        }

        private void BtnCreateConvexHull_Click(object sender, EventArgs e) {

        }
    }
}
