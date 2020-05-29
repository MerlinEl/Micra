using Autodesk.Max;
using Autodesk.Max.Plugins;
using Micra.Core;
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
            CbxObjType.SelectedIndex = 0;
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

            List<IINode> objects = MxCollection.GetAllObjects();
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
            List<IINode> sel_objs = MxCollection.GetSelection();
            MxSet.LogLi("\tSelected objects:{0}", sel_objs.Count);
            if ( sel_objs.Count == 0 ) return;
            List<IINode> all_objs = MxCollection.GetAllObjects();
            MxSet.LogLi("\tAll objects:{0}", all_objs.Count);
            if ( all_objs.Count == 1 ) return;
            var volumes = new List<Tuple<IINode, double>> { }; //list of pairs
            foreach ( IINode o in sel_objs ) {
                MxCollection.PrintObjectClass(o);
                double v = MxPoly.GetGeometryVolume(o);
                volumes.Add(Tuple.Create(o, v));
                MxSet.LogLi("\t\tget obj:{0} area:{1}", o.Name, v);
            }

            return;

            /*IINode obj = MxCollection.GetFirstSelectedNode(); //Autodesk.Max.Wrappers.INode
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
            }*/

            /*MxSet.ExecuteMAXScriptScript("" +
                "mcPoly.selectSimilarElements selection[1] " +
                "offset:" + SpnAreaOffset.Value.ToString()
            );*/
        }

        private void BtnSelectAll_Click(object sender, EventArgs e) {

            MxCollection.SelectAll();
        }

        private void BtnSelectNone_Click(object sender, EventArgs e) {
            MxCollection.SelectNone();
        }

        private void BtnPrintNodeInstances_Click(object sender, EventArgs e) {
            IINode obj = MxCollection.GetFirstSelectedNode();
            if ( obj == null ) return;
            MxSet.LogLi("Get Instances from Node:{0}", obj.Name);
            List<IINode> instances = MxCollection.GetInstances(obj);
            if ( instances.Count == 0 ) return;
            foreach ( IINode n in instances ) MxSet.LogLi("\t{0}", n.Name);
            MxCollection.SetSelection(instances);
        }

        private void button9_Click(object sender, EventArgs e) {

            MxSet.LogLi("Scene nodes");
            PrintNode(Kernel.Scene.RootNode);
        }

        private void PrintNode(Node n, string indent = "") {
            MxSet.LogLi(indent + n.Name);
            foreach ( var c in n.Children )
                PrintNode(c, indent + "  ");
        }

        private void button8_Click(object sender, EventArgs e) {

            var teapot = Primitives.Teapot.Create();
            teapot["radius"] = 20.0;
            teapot.Node.Move(new Point3(20, 10, 5));
        }

        private void button7_Click(object sender, EventArgs e) {

            var cylinder = Primitives.Cylinder.Create();
            MxSet.LogLi("Create Cylinder params:{0}", cylinder.Params.ToString());
            cylinder["radius"] = 20.0f;
            cylinder["height"] = 40.0f;
            cylinder["heightsegs"] = 10;
            MxSet.LogLi("Create Bend");
            var bend = Primitives.Bend.Create();
            cylinder.AddModifier(bend);
            bend["bendangle"] = 30.0f;
        }

        private void button6_Click(object sender, EventArgs e) {

            MxSet.LogLi("Plug-ins");
            foreach ( var p in PluginMgr.Plugins ) MxSet.LogLi(p.ClassName);
        }

        private void button10_Click(object sender, EventArgs e) {

            Kernel.PushPrompt("Look at the MAXScript listener window");
            Kernel.WriteLine("I'm some text appearing in the MAXScript listener window!");
        }

        private void button11_Click(object sender, EventArgs e) {

            Collections.SelectAll(ChkSelHidden.Checked, true, ChkPrintProps.Checked);
        }

        private void button12_Click(object sender, EventArgs e) {
            Collections.DeselectAll(true);
        }

        private void button13_Click(object sender, EventArgs e) {

            SuperClassID classId;
            switch ( CbxObjType.SelectedItem ) {

                case "Light": classId = SuperClassID.Light; break;
                case "Geometry": classId = SuperClassID.GeometricObject; break;
                //case "Mesh": classId = ClassID.EditableMesh; break;
                //case "Poly": classId = ClassID.EditablePoly; break;
                //case "Bone": classId = ClassID.BoneGeometry; break;
                case "Helper": classId = SuperClassID.Helper; break;
                case "Spline": classId = SuperClassID.Shape; break;
                default : classId = SuperClassID.GeometricObject; break;
            }
            Kernel.WriteLine("Select All objects with type:{0}", CbxObjType.SelectedItem.ToString());
            Collections.SelectAllOfType(classId, ChkClearSel.Checked, true);
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
