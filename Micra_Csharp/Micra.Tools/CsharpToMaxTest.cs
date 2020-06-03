using Autodesk.Max;
using Micra.Core;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Windows.Forms;

namespace Micra.Tools {
    public partial class CsharpToMaxTest : Form {

        public CsharpToMaxTest() {
            InitializeComponent();
            Init();
        }

        private void Init() {
            Text = Text + "     " + MxGet.AssemblyVersion;
            CbxClassOf.Items.AddRange(ClassID.GetNames());
            CbxClassOf.SelectedIndex = 0;
            CbxSuperClassOf.Items.AddRange(SuperClassID.GetNames());
            CbxSuperClassOf.SelectedIndex = 0;
            CbxSceneNodeTypes.SelectedIndex = 0;
        }

        private void OnTextAreaLostFocus(object sender, EventArgs e) {
            MxSet.SetAccelerators(true);
        }

        private void OnTextAreaGotFocus(object sender, EventArgs e) {
            MxSet.SetAccelerators(false);
        }

        private void Button1_Click(object sender, EventArgs e) {

            Kernel.WriteLine(( sender as Button ).Text);
            Node node = Kernel.Scene.SelectedNodes().FirstOrDefault();
            Kernel.WriteLine("first node:{0}", node);
            if ( node != null ) node.SelectOnly();
        }

        private void Button2_Click(object sender, EventArgs e) {
            Kernel.WriteLine(( sender as Button ).Text);
            string cmd = "Render()";
            textBox1.Text = cmd;
            MxSet.ExecuteMAXScriptScript(cmd);
        }

        private void Button3_Click(object sender, EventArgs e) {
            Kernel.WriteLine(( sender as Button ).Text);
            string cmd = "Box pos:[-100,0,0] name:(UniqueName \"ojobox\") wirecolor:red\n" +
                "Box pos:[0,0,0] name:(UniqueName \"ojobox\") wirecolor:blue\n" +
                "Box pos:[100,0,0] name:(UniqueName \"ojobox\") wirecolor:green\n";
            textBox1.Text = cmd;
            MxSet.ExecuteMAXScriptScript(cmd);
        }

        private void Button5_Click(object sender, EventArgs e) {
            Kernel.WriteLine(( sender as Button ).Text);
            string cmd = "Render()";
            textBox1.Text = cmd;
            IFPValue mxsRetVal = MxSet.ExecuteMAXScriptScript(cmd);
            if ( mxsRetVal != null ) MxSet.LogLi("Render Click gor:" + mxsRetVal.S);
        }

        private void BtnSelSimElements_Click(object sender, EventArgs e) {

            Kernel.WriteLine(( sender as Button ).Text);
            IEnumerable<Node> selNodes = Kernel.Scene.SelectedNodes();
            Kernel.WriteLine("\tSelected nodes:{0}", selNodes.Count());
            int slev = GlobalMethods.SubObjectLevel;
            if ( selNodes.Count() == 1 && slev != 0 ) { //if single object is selected

                Node node = selNodes.First();
                if ( !node.IsEditable() ) return;
                Kernel.WriteLine("selected Node:{0} subObjectLevel:{1}", node.Name, Kernel._Interface.SubObjectLevel);
                switch ( slev ) { //next operation is depend on subobject level

                    case 2: Collections.SelectEdgesWithSameLength(node); break;
                    case 3: break;
                    case 4: break;
                    case 5: break;
                }


            } else if ( selNodes.Count() >= 1 ) { //when multi object selection

                Collections.SelectNodesWithSimillarVolume(selNodes.ToList());
            }

            /*IINode obj = MxCollection.GetFirstSelectedNode(); //Autodesk.Max.Wrappers.INode
            ISubClassList clist = GlobalInterface.Instance.ClassDirectory.Instance.GetClassList(obj.ObjectRef.Eval(0).Obj.SuperClassID);
            */
        }

        private void Button9_Click(object sender, EventArgs e) {

            Kernel.WriteLine(( sender as Button ).Text);
            PrintNode(Kernel.Scene.RootNode);
        }

        private void PrintNode(Node n, string indent = "") {
            Kernel.WriteLine(indent + n.Name);
            foreach ( var c in n.Children )
                PrintNode(c, indent + "  ");
        }

        private void Button8_Click(object sender, EventArgs e) {
            Kernel.WriteLine(( sender as Button ).Text);
            var teapot = Primitives.Teapot.Create();
            teapot["radius"] = 20.0;
            teapot.Node.Move(new Point3(20, 10, 5));
        }

        private void Button7_Click(object sender, EventArgs e) {
            Kernel.WriteLine(( sender as Button ).Text);
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

        private void Button6_Click(object sender, EventArgs e) {

            Kernel.WriteLine(( sender as Button ).Text);
            foreach ( var p in PluginMgr.Plugins ) MxSet.LogLi(p.ClassName);
        }

        private void Button10_Click(object sender, EventArgs e) {

            Kernel.PushPrompt("Look at the MAXScript listener window");
            Kernel.WriteLine("I'm some text appearing in the MAXScript listener window!");
        }

        private void Button11_Click(object sender, EventArgs e) {
            Kernel.WriteLine(( sender as Button ).Text);
            Collections.SelectAll(ChkSelHidden.Checked, true);
        }

        private void Button12_Click(object sender, EventArgs e) {
            Kernel.WriteLine(( sender as Button ).Text);
            Collections.DeselectAll(true);
        }

        private void Button13_Click(object sender, EventArgs e) {
            Kernel.WriteLine(( sender as Button ).Text);
            if ( RbtClassOf.Checked ) {

                ClassID classId = ClassID.FromName(CbxClassOf.SelectedItem.ToString());
                Kernel.WriteLine("classId:{0}", classId);
                Collections.SelectAllOfType(classId, ChkClearSel.Checked, true);

            } else {

                SuperClassID superClassId = SuperClassID.FromName(CbxSuperClassOf.SelectedItem.ToString());
                Kernel.WriteLine("superClassId:{0}", superClassId);
                Collections.SelectAllOfType(superClassId, ChkClearSel.Checked, true);

            }
        }

        private void Button14_Click(object sender, EventArgs e) {
            Kernel.WriteLine(( sender as Button ).Text);
            var nodes = Kernel.Scene.SelectedNodes();
            Collections.ShowClass(nodes);
        }

        private void OnFormShown(object sender, EventArgs e) {
            Kernel.WriteClear(false);
        }

        private void Button15_Click(object sender, EventArgs e) {
            Kernel.WriteLine(( sender as Button ).Text);
            Kernel.WriteClear(ChkMacroRec.Checked);
        }

        private void Button16_Click(object sender, EventArgs e) {
            Kernel.WriteLine(( sender as Button ).Text);
            var nodes = Kernel.Scene.SelectedNodes();
            Collections.ShowParameters(nodes);
        }

        private void Button4_Click_1(object sender, EventArgs e) {
            Kernel.WriteLine(( sender as Button ).Text);
            Node node = Kernel.Scene.SelectedNodes().FirstOrDefault();
            Collections.SelectInstances(node, true);
        }

        private void BtnOpenMaxFile_Click(object sender, EventArgs e) {

            Kernel.WriteLine(( sender as Button ).Text);
            string maxFilePpath = TbxMaxFilePath.Text;
            Kernel.WriteLine("Open Max file:{0} exists:{1}", maxFilePpath, File.Exists(maxFilePpath));
            Kernel._Interface.LoadFromFile(maxFilePpath, true);
        }

        private void BtnGetSelFaces_Click(object sender, EventArgs e) {
            Kernel.WriteLine(( sender as Button ).Text);
            Node node = Kernel.Scene.SelectedNodes().FirstOrDefault();
            Kernel.WriteLine("selected Node:{0} subObjectLevel:{1}", node.Name, Kernel._Interface.SubObjectLevel);
            var fsel = node.Object.GetSelectedFaces();
            Kernel.WriteLine("selected Faces:{0}", fsel.Count);
        }

        private void BtnGetSelEdges_Click(object sender, EventArgs e) {
            Kernel.WriteLine(( sender as Button ).Text);
            Node node = Kernel.Scene.SelectedNodes().FirstOrDefault();
            Kernel.WriteLine("selected Node:{0} subObjectLevel:{1}", node.Name, Kernel._Interface.SubObjectLevel);
            var esel = node.Object.GetSelectedEdges();
            Kernel.WriteLine("selected Edges:{0}", esel.Count);
        }

        private void BtnGetSelVetts_Click(object sender, EventArgs e) {
            Kernel.WriteLine(( sender as Button ).Text);
            Node node = Kernel.Scene.SelectedNodes().FirstOrDefault();
            Kernel.WriteLine("selected Node:{0} subObjectLevel:{1}", node.Name, Kernel._Interface.SubObjectLevel);
            var vsel = node.Object.GetSelectedVerts();
            Kernel.WriteLine("selected Verts:{0}", vsel.Count);
        }

        private void BtnHideUnselFaces_Click(object sender, EventArgs e) {
            Kernel.WriteLine(( sender as Button ).Text);
            Node node = Kernel.Scene.SelectedNodes().FirstOrDefault();
            if ( node != null ) {
                node.Object.HideGeometry(ChkSelected.Checked);
                Kernel._Interface.InvalidateObCache(node._Node);
                Kernel.RedrawViews();
            }
        }

        private void BtnUnhideGeometry_Click(object sender, EventArgs e) {
            Kernel.WriteLine(( sender as Button ).Text);
            Node node = Kernel.Scene.SelectedNodes().FirstOrDefault();
            if ( node != null ) {
                node.Object.UnhideGeometry();
                Kernel._Interface.InvalidateObCache(node._Node);
                Kernel.RedrawViews();
            }
        }

        private void BtnGetSceneObjects_Click(object sender, EventArgs e) {
            Kernel.WriteLine(( sender as Button ).Text);
            IEnumerable<Node> nodes = Enumerable.Empty<Node>(); //new List<Node>(); 
            switch ( CbxSceneNodeTypes.SelectedItem ) {

                case "All"              : nodes = Kernel.Scene.AllNodes(); break;
                case "GeometryNodes"    : nodes = Kernel.Scene.GeometryNodes; break;
                case "LightNodes"       : nodes = Kernel.Scene.LightNodes; break;
                case "CameraNodes"      : nodes = Kernel.Scene.CameraNodes; break;
                case "HelperNodes"      : nodes = Kernel.Scene.HelperNodes; break;
                case "ShapeNodes"       : nodes = Kernel.Scene.ShapeNodes; break;
            }
            Kernel.WriteLine("Get Scene objects by type:{0} ( {1} ) >", CbxSceneNodeTypes.SelectedItem, nodes.Count());
            nodes.ToList()
                .ForEach(n => Kernel.WriteLine("\tNode:{0}\t\tSuperClass:{1}", 
                n.Name,
                SuperClassID.GetName(n.Object.SuperClassID)
                ));
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



/*
 System.Windows.Window dialog = new System.Windows.Window();
            dialog.Title = "Explode It!";
            dialog.SizeToContent = System.Windows.SizeToContent.WidthAndHeight;
            ExplodeGeomUserControl1 ctlExplode = new ExplodeGeomUserControl1(dialog);
            dialog.Content = ctlExplode;
            dialog.WindowStartupLocation = System.Windows.WindowStartupLocation.CenterOwner;
            dialog.ShowInTaskbar = false;
            dialog.ResizeMode = System.Windows.ResizeMode.NoResize;

            System.Windows.Interop.WindowInteropHelper windowHandle =
                new System.Windows.Interop.WindowInteropHelper(dialog);
            windowHandle.Owner = ManagedServices.AppSDK.GetMaxHWND();
            ManagedServices.AppSDK.ConfigureWindowForMax(dialog);

            dialog.ShowDialog(); //modal version; this prevents changes being made to model while our dialog is running, etc.
 */
