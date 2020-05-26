using Autodesk.Max;
using Autodesk.Max.Plugins;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Windows.Forms;

namespace Micra.Tools {
    public partial class CsharpToMaxTest : Form {

        public CsharpToMaxTest() {
            InitializeComponent();
            Init();
        }

        private void Init() {
            Text = Text + "     " + MxGet.AssemblyVersion;
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

        private void BtnSelSimElements_Click(object sender, EventArgs e) {

            MxSet.LogLi("SelSimElements");
            List<IINode> sel_objs = MxCollection.GetSelectedNodes();
            MxSet.LogLi("\tSelected objects:{0}", sel_objs.Count);
            if ( sel_objs.Count == 0 ) return;
            List<IINode> all_objs = MxCollection.Objects();
            MxSet.LogLi("\tAll objects:{0}", all_objs.Count);
            if ( all_objs.Count == 1 ) return;
            List<double> volumes = new List<double> { };
            foreach (IINode o in sel_objs ) {

                float v = MxPoly.GetGeometryVolume(o);
                MxSet.LogLi("\t\tget obj:{0} area:{1}", o.Name, v);
            }

            return;

            IINode obj = MxCollection.GetFirstSelectedNode(); //Autodesk.Max.Wrappers.INode
            ISubClassList clist = GlobalInterface.Instance.ClassDirectory.Instance.GetClassList(obj.ObjectRef.Eval(0).Obj.SuperClassID);
            //IClassEntry.ClassName: "GeoSphere"
            //IClassEntry.Category: "Standard Primitives"
            //IClassEntry.DllNumber: 74
            //TODO is good to do it with multiselection (obj or element or face)
            //polyObjectClassID
            //firstNode.ObjectRef != null && firstNode.ObjectRef.Eval(0).Obj.SuperClassID == SClass_ID.Light
            //obj.SuperClassID == Basenode
            if ( obj == null || obj.ObjectRef.Eval(0).Obj.SuperClassID != SClass_ID.Geomobject ) return;

            Type obj_type = obj.GetType();

            MxSet.LogLi("SelSimElements > sel obj:{0} is SuperClassID:{1} type:{2}", obj.Name, obj.ObjectRef.Eval(0).Obj.SuperClassID, obj_type.Name);
            MxSet.LogLi("SelSimElements > class list:{0}", clist.ToString());
            return;


            int slev = MxGet.Interface.SubObjectLevel;

            MxSet.LogLi("selectedObject:{0} subobjectLevel:{1}", obj.Name, slev);

            if ( slev == 4 || slev == 5 ) { //select geometry with simillar volume

                MxSet.LogLi("select geometry with simillar volume");

            } else { //select objects with simillar volume

                MxSet.LogLi("select objects with simillar volume");
            }

            /*MxSet.ExecuteMAXScriptScript("" +
                "mcPoly.selectSimilarElements selection[1] " +
                "offset:" + SpnAreaOffset.Value.ToString()
            );*/
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
