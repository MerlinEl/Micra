﻿using Autodesk.Max;
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

        private void button2_Click(object sender, EventArgs e) {
            Kernel.WriteLine(( sender as Button ).Text);
            string cmd = "Render()";
            textBox1.Text = cmd;
            MxSet.ExecuteMAXScriptScript(cmd);
        }

        private void button3_Click(object sender, EventArgs e) {
            Kernel.WriteLine(( sender as Button ).Text);
            string cmd = "Box pos:[-100,0,0] name:(UniqueName \"ojobox\") wirecolor:red\n" +
                "Box pos:[0,0,0] name:(UniqueName \"ojobox\") wirecolor:blue\n" +
                "Box pos:[100,0,0] name:(UniqueName \"ojobox\") wirecolor:green\n";
            textBox1.Text = cmd;
            MxSet.ExecuteMAXScriptScript(cmd);
        }

        private void button5_Click(object sender, EventArgs e) {
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
            if ( selNodes.Count() == 1 && slev != 0) { //if single object is selected

                Node node = selNodes.First();
                if ( !node.IsEditable() ) return;
                Kernel.WriteLine("selected Node:{0} subObjectLevel:{1}", node.Name, Kernel._Interface.SubObjectLevel);
                switch ( slev ) { //next operation is depend on subobject level

                    case 1: break;
                    case 2: break;
                    case 3: break;
                    case 4: break;
                    case 5: break;
                }


            } else if (selNodes.Count() >= 1) { //when multi object selection

                Collections.SelectNodesWithSimillarVolume(selNodes.ToList());
            }

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

        private bool IsMatchVolume(double val, List<double> valList) {

            return valList.IndexOf(val) != -1;
        }

        private void button9_Click(object sender, EventArgs e) {

            Kernel.WriteLine(( sender as Button ).Text);
            PrintNode(Kernel.Scene.RootNode);
        }

        private void PrintNode(Node n, string indent = "") {
            Kernel.WriteLine(indent + n.Name);
            foreach ( var c in n.Children )
                PrintNode(c, indent + "  ");
        }

        private void button8_Click(object sender, EventArgs e) {
            Kernel.WriteLine(( sender as Button ).Text);
            var teapot = Primitives.Teapot.Create();
            teapot["radius"] = 20.0;
            teapot.Node.Move(new Point3(20, 10, 5));
        }

        private void button7_Click(object sender, EventArgs e) {
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

        private void button6_Click(object sender, EventArgs e) {

            Kernel.WriteLine(( sender as Button ).Text);
            foreach ( var p in PluginMgr.Plugins ) MxSet.LogLi(p.ClassName);
        }

        private void button10_Click(object sender, EventArgs e) {

            Kernel.PushPrompt("Look at the MAXScript listener window");
            Kernel.WriteLine("I'm some text appearing in the MAXScript listener window!");
        }

        private void button11_Click(object sender, EventArgs e) {
            Kernel.WriteLine(( sender as Button ).Text);
            Collections.SelectAll(ChkSelHidden.Checked, true);
        }

        private void button12_Click(object sender, EventArgs e) {
            Kernel.WriteLine(( sender as Button ).Text);
            Collections.DeselectAll(true);
        }

        private void button13_Click(object sender, EventArgs e) {
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

        private void button14_Click(object sender, EventArgs e) {
            Kernel.WriteLine(( sender as Button ).Text);
            var nodes = Kernel.Scene.SelectedNodes();
            Collections.ShowClass(nodes);
        }

        private void OnFormShown(object sender, EventArgs e) {
            Kernel.WriteClear(false);
        }

        private void button15_Click(object sender, EventArgs e) {
            Kernel.WriteLine(( sender as Button ).Text);
            Kernel.WriteClear(ChkMacroRec.Checked);
        }

        private void button16_Click(object sender, EventArgs e) {
            Kernel.WriteLine(( sender as Button ).Text);
            var nodes = Kernel.Scene.SelectedNodes();
            Collections.ShowParameters(nodes);
        }

        private void button4_Click_1(object sender, EventArgs e) {
            Kernel.WriteLine(( sender as Button ).Text);
            Node node = Kernel.Scene.SelectedNodes().FirstOrDefault();
            var nodeInstances = Collections.GetNodeInsatances(node);
            if ( nodeInstances.Count > 0 ) Collections.SelectNodes(nodeInstances);
        }

        private void BtnOpenMaxFile_Click(object sender, EventArgs e) {

            string maxFilePpath = TbxMaxFilePath.Text;
            Kernel.WriteLine("Open Max file:{0} exists:{1}", maxFilePpath, File.Exists(maxFilePpath));
            Kernel._Interface.LoadFromFile(maxFilePpath, true);
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
