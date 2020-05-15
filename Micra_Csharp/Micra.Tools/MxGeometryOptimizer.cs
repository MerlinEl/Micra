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

            MxSet.LogLi("Create Some Test Objects:");
            string cmd = "Box pos:[-100,0,0] name:(UniqueName \"ojobox\") wirecolor:red\n" +
                "Box pos:[0,0,0] name:(UniqueName \"ojobox\") wirecolor:blue\n" +
                "Box pos:[100,0,0] name:(UniqueName \"ojobox\") wirecolor:green\n";
            ManagedServices.MaxscriptSDK.ExecuteMaxscriptCommand(cmd);

            MxSet.LogLi("Get All Scene Objects >");
            List<IINode> objects = MxObj.Objects();
            MxGet.Interface.ForceCompleteRedraw(false);
            MxSet.LogLi("Print All Scene Objects >");
            foreach (IINode n in objects) MxSet.LogLi("\t" + n.Name);

            //https://help.autodesk.com/view/3DSMAX/2017/ENU/?guid=__files_GUID_5F19208A_B95E_41A8_A788_3108F747AF0E_htm
            //Autodesk.Max.IInterface13.COREInterface13 collecting the IINodes
            // get a list of all selected nodes.
            /*List<IINode> selectedNodes = MxObj.GetSelectedNodes();
            if ( selectedNodes.Count == 0 ) return;
            MxSet.LogLi("Selected Nodes:" + selectedNodes.Count.ToString());
            //MxPoly.SelectSimillarElements(selectedNodes[0]);*/
        }

        private void BtnCreateConvexHull_Click(object sender, EventArgs e) {
            MxSet.LogLi("Render Click:");
            IFPValue mxsRetVal = null;
            MxGet.Global.ExecuteMAXScriptScript("Render()", false, null);
            MxSet.LogLi("Render Click gor:" + mxsRetVal.S);
            //ManagedServices.MaxscriptSDK.ExecuteMaxscriptCommand("Render()");
        }
    }
}
