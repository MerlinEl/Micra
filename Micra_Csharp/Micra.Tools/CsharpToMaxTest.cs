using Autodesk.Max;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Reflection;
using System.Windows.Forms;

namespace Micra.Tools {
    public partial class CsharpToMaxTest : Form {

        public CsharpToMaxTest() {
            InitializeComponent();
            Init();
        }

        private void Init() {
            Text = Text + "     " + MxGet.AssemblyVersion;
            CboxAsemblyGetType.SelectedIndex = CboxAsemblyGetType.Items.Count - 1;
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
            MxSet.ExecuteMAXScriptScript(cmd);
        }

        private void button3_Click(object sender, EventArgs e) {
            MxSet.LogLi(( sender as Button ).Text);
            string cmd = "Box pos:[-100,0,0] name:(UniqueName \"ojobox\") wirecolor:red\n" +
                "Box pos:[0,0,0] name:(UniqueName \"ojobox\") wirecolor:blue\n" +
                "Box pos:[100,0,0] name:(UniqueName \"ojobox\") wirecolor:green\n";
            textBox1.Text = cmd;
            MxSet.ExecuteMAXScriptScript(cmd);
        }

        private void button4_Click(object sender, EventArgs e) {

            List<IINode> objects = MxCollection.Objects();
            MxSet.LogLi(( sender as Button ).Text + " objs:" + objects.Count);
            //MxGet.Interface.ForceCompleteRedraw(false);
            foreach ( IINode n in objects ) MxSet.LogLi("\t" + n.Name);
        }

        private void button5_Click(object sender, EventArgs e) {
            MxSet.LogLi(( sender as Button ).Text);
            string cmd = "Render()";
            textBox1.Text = cmd;
            IFPValue mxsRetVal = MxSet.ExecuteMAXScriptScript(cmd);
            if ( mxsRetVal != null ) MxSet.LogLi("Render Click gor:" + mxsRetVal.S);
        }

        private void button11_Click(object sender, EventArgs e) {

            MxSet.LogLi("Search for latest Assembly in Current Domain:" + AppDomain.CurrentDomain.FriendlyName);
            Assembly asm = MxGet.GetLatestAssembly(TbxAssemblyName.Text);
            if ( asm != null ) {

                MxSet.LogLi("Got Latest(Micra.Star) Assembly:" + asm.FullName);
            } else {

                MxSet.LogLi("Latest(Micra.Star) Assembly not Found");
            }

        }
        private void button12_Click(object sender, EventArgs e) {

            MxGet.ReloadAssembly(TbxAssemblyPath.Text);
        }
        private void button13_Click(object sender, EventArgs e) {

            MxSet.LogLi("Main > GetAllAssemblies > Current Domain:" + AppDomain.CurrentDomain.FriendlyName);
            Assembly[] assemblies = AppDomain.CurrentDomain.GetAssemblies();
            
            foreach ( Assembly asm in assemblies ) {

                switch (CboxAsemblyGetType.SelectedItem.ToString()) {

                    case "All": break;
                    case "Micra.Star":
                        if ( asm.GetName().Name != "Micra.Star" ) continue;
                    break;
                }
                MxSet.LogLi("\t" + asm.FullName);
            }
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
