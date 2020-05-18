using Autodesk.Max;
using System;
using System.Collections.Generic;
using System.Windows.Forms;

namespace Micra.Tools {
    public partial class CtoMaxTest : Form {

        public CtoMaxTest() {
            InitializeComponent();
        }
        private void OnTextAreaLostFocus(object sender, EventArgs e) {
            MxSet.SetAccelerators(true);
        }

        private void OnTextAreaGotFocus(object sender, EventArgs e) {
            MxSet.SetAccelerators(false);
        }

        private void Button1_Click(object sender, EventArgs e) {

            MxSet.LogLi(( sender as Button ).Text);
            var node = MxGet.Interface.GetSelNode(0);
            MxGet.Interface.SelectNode(node, true);
            //ITriObject triObj = node.ObjectRef.FindBaseObject() as ITriObject;
            //IMesh mesh = triObj.Mesh;
            //IntPtr meshPtr = mesh.NativePointer; //same as my C++ pointer - so it's correct
        }

        private void button2_Click(object sender, EventArgs e) {
            MxSet.LogLi(( sender as Button ).Text);
            string cmd = "Render()";
            textBox1.Text = cmd;
            MxGet.Global.ExecuteMAXScriptScript(cmd, false, null);
        }

        private void button3_Click(object sender, EventArgs e) {
            MxSet.LogLi(( sender as Button ).Text);
            string cmd = "Box pos:[-100,0,0] name:(UniqueName \"ojobox\") wirecolor:red\n" +
                "Box pos:[0,0,0] name:(UniqueName \"ojobox\") wirecolor:blue\n" +
                "Box pos:[100,0,0] name:(UniqueName \"ojobox\") wirecolor:green\n";
            textBox1.Text = cmd;
            ManagedServices.MaxscriptSDK.ExecuteMaxscriptCommand(cmd);
        }

        private void button4_Click(object sender, EventArgs e) {

            List<IINode> objects = MxObj.Objects();
            MxSet.LogLi(( sender as Button ).Text + " objs:" + objects.Count);
            //MxGet.Interface.ForceCompleteRedraw(false);
            foreach ( IINode n in objects ) MxSet.LogLi("\t" + n.Name);
        }

        private void button5_Click(object sender, EventArgs e) {
            MxSet.LogLi(( sender as Button ).Text);
            string cmd = "Render()";
            textBox1.Text = cmd;
            IFPValue mxsRetVal = null;
            MxGet.Global.ExecuteMAXScriptScript(cmd, false, mxsRetVal);
            MxSet.LogLi("Render Click gor:" + mxsRetVal.S);
        }

        private void button6_Click(object sender, EventArgs e) {

            MxSet.LogLi(( sender as Button ).Text);
            MxAssemblyManager.CreateDomain();
        }
        private void button8_Click(object sender, EventArgs e) {

            MxSet.LogLi(( sender as Button ).Text);
            MxAssemblyManager.ExecuteStaticMethod("MxSet", "LogLi", new object[] { "Execute Static Method", "MxSet", "LogLi" });
        }
        private void button7_Click(object sender, EventArgs e) {

            MxSet.LogLi(( sender as Button ).Text);
            MxAssemblyManager.UnloadDomain();
        }

        private void button9_Click(object sender, EventArgs e) {
            MxSet.LogLi(( sender as Button ).Text);
            MxAssemblyManager.ShowloadedAssemblies();
        }

        private void button10_Click(object sender, EventArgs e) {
            MxSet.LogLi(( sender as Button ).Text);
            MxAssemblyManager.LoadAssembly(TbxAssemblyPath.Text);
        }
    }
}


//https://help.autodesk.com/view/3DSMAX/2017/ENU/?guid=__files_GUID_5F19208A_B95E_41A8_A788_3108F747AF0E_htm
//Autodesk.Max.IInterface13.COREInterface13 collecting the IINodes
// get a list of all selected nodes.
/*List<IINode> selectedNodes = MxObj.GetSelectedNodes();
if ( selectedNodes.Count == 0 ) return;
MxSet.LogLi("Selected Nodes:" + selectedNodes.Count.ToString());
//MxPoly.SelectSimillarElements(selectedNodes[0]);*/
