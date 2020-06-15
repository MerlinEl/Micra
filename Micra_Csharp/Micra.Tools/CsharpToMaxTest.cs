using Autodesk.Max;
using Micra.Core;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Windows.Forms;
using System.Xml;
using System.Xml.Linq;

namespace Micra.Tools {
    public partial class CsharpToMaxTest : Form {
        XDocument MaxActionsXML = MxFile.GetXMLFromResources("MaxScriptActions.xml");//load XML from Resources
        public CsharpToMaxTest() {
            InitializeComponent();
            Init();
        }
        private void Init() {

            //get assembly version
            Text = Text + "     " + MxGet.AssemblyVersion;
            //fill list boxes
            CbxClassOf.Items.AddRange(ClassID.GetClassNames());
            CbxClassOf.SelectedIndex = 0;
            CbxSuperClassOf.Items.AddRange(SuperClassID.GetClassNames());
            CbxSuperClassOf.SelectedIndex = 0;
            CbxSceneNodeTypes.SelectedIndex = 0;
            CbxPrimitiveTypes.SelectedIndex = 0;
            CbxMaxFilePath.SelectedIndex = 0;
            CbxSimillarObjBy.SelectedIndex = 0;

            CbxScriptList.Items.AddRange(new object[]{
                "SelFaces",
                "SelEdges",
                "SelVerts",
                "3Boxes",
                "Render",
                "GetFaceArea",
                "GetObjectArea",
                "GetSelectedVertices"
            });
            CbxScriptList.SelectedIndex = 0;
        }

        #region Execute Max Script

        private void BtnExecute_Click(object sender, EventArgs e) {
            Kernel.WriteLine(( sender as Button ).Text);
            Kernel.ExecuteMaxScriptScript(textBox1.Text);
        }
        private void BtnClearExecute_Click(object sender, EventArgs e) {
            textBox1.Text = "";
        }

        /// <summary> Load Max String Commands in to TextBox</summary>
        private void OnCbxScriptListSelChanges(object sender, EventArgs e) {

            string cmd = MxFile.GetMaxScriptFromXML(MaxActionsXML, CbxScriptList.Text);
            textBox1.Text = cmd.Replace("\n", Environment.NewLine);
        }

        #endregion

        #region UI Events


        private void OnTextAreaLostFocus(object sender, EventArgs e) {
            MxSet.SetAccelerators(true);
        }

        private void OnTextAreaGotFocus(object sender, EventArgs e) {
            MxSet.SetAccelerators(false);
        }

        #endregion

        private void Button1_Click(object sender, EventArgs e) {

            Kernel.WriteLine(( sender as Button ).Text);
            Node node = ObjOps.GetFirstSlectedNode();
            Kernel.WriteLine("first node:{0}", node);
            if ( node != null ) node.SelectOnly();
        }

        private void Button5_Click(object sender, EventArgs e) {
            Kernel.WriteLine(( sender as Button ).Text);
            string cmd = "Render()";
            textBox1.Text = cmd;
            IFPValue mxsRetVal = MxSet.ExecuteMAXScriptScript(cmd);
            if ( mxsRetVal != null ) Kernel.WriteLine("Render Click gor:" + mxsRetVal.S);
        }

        private void BtnSelSimElements_Click(object sender, EventArgs e) {

            Kernel.WriteLine(( sender as Button ).Text);
            bool byArea = CbxSimillarObjBy.SelectedIndex == 0 || CbxSimillarObjBy.SelectedIndex == 1;
            bool byVcount = CbxSimillarObjBy.SelectedIndex == 2;
            List<Node> selNodes = ObjOps.GetSlectedNodes();
            Kernel.WriteLine("\tSelected nodes:{0}", selNodes.Count());
            int slev = GlobalMethods.SubObjectLevel;
            if ( selNodes.Count() == 1 && slev != 0 ) { //if single object is selected

                Node node = selNodes.First();
                if ( !node.IsEditable() ) return;
                Kernel.WriteLine("selected Node:{0} subObjectLevel:{1}", node.Name, Kernel._Interface.SubObjectLevel);
                switch ( slev ) { //next operation is depend on subobject level

                    case 2: GeoOps.SelectSimillarEdges(node, byArea, byVcount); break;
                    case 3: GeoOps.SelectSimillarEdges(node, byArea, byVcount); break;
                    case 4: GeoOps.SelectSimillarFaces(node, byArea, byVcount); break;
                    case 5: GeoOps.SelectSimillarElements(node, byArea, byVcount); break;
                }

            } else if ( selNodes.Count() >= 1 ) { //when multi object selection

                ObjOps.SelectSimillarNodes(selNodes, byArea, byVcount);
            }
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
            teapot.Move(new Point3(20, 10, 5));
            //teapot._Object.Move
        }

        private void Button7_Click(object sender, EventArgs e) {
            Kernel.WriteLine(( sender as Button ).Text);
            var cylinder = Primitives.Cylinder.Create();
            Kernel.WriteLine("Create Cylinder params:{0}", cylinder.Params.ToString());
            cylinder["radius"] = 20.0f;
            cylinder["height"] = 40.0f;
            cylinder["heightsegs"] = 10;
            Kernel.WriteLine("Create Bend");
            var bend = Primitives.Bend.Create();
            cylinder.AddModifier(bend);
            bend["bendangle"] = 30.0f;
        }

        private void Button6_Click(object sender, EventArgs e) {

            Kernel.WriteLine(( sender as Button ).Text);
            foreach ( var p in PluginMgr.Plugins ) Kernel.WriteLine(p.ClassName);
        }

        private void Button10_Click(object sender, EventArgs e) {

            Kernel.PushPrompt("Look at the MAXScript listener window");
            Kernel.WriteLine("I'm some text appearing in the MAXScript listener window!");
        }

        private void Button11_Click(object sender, EventArgs e) {
            Kernel.WriteLine(( sender as Button ).Text);
            ObjOps.SelectAll(ChkSelHidden.Checked, true);
        }

        private void Button12_Click(object sender, EventArgs e) {
            Kernel.WriteLine(( sender as Button ).Text);
            ObjOps.DeselectAll(true);
        }

        private void Button13_Click(object sender, EventArgs e) {
            Kernel.WriteLine(( sender as Button ).Text);
            if ( RbtClassOf.Checked ) {

                ClassID classId = ClassID.FromName(CbxClassOf.SelectedItem.ToString());
                Kernel.WriteLine("classId:{0} Name:{1}", classId, classId.GetClassName(classId));
                ObjOps.SelectAllOfType(classId, ChkSelHidden2.Checked, ChkClearSel.Checked, true);

            } else {

                SuperClassID superClassId = SuperClassID.FromName(CbxSuperClassOf.SelectedItem.ToString());
                Kernel.WriteLine("superClassId:{0}", superClassId);
                ObjOps.SelectAllOfType(superClassId, ChkSelHidden2.Checked, ChkClearSel.Checked, true);
            }
        }
        private void Button_ShowSelClass(object sender, EventArgs e) {
            Kernel.WriteLine(( sender as Button ).Text);
            ObjOps.ShowClass(ObjOps.GetSlectedNodes());
        }

        private void OnFormShown(object sender, EventArgs e) {
            Kernel.WriteClear(false);
        }

        private void Button15_Click(object sender, EventArgs e) {
            Kernel.WriteLine(( sender as Button ).Text);
            Kernel.WriteClear(ChkMacroRec.Checked);
        }

        private void Button_ShowSelParams(object sender, EventArgs e) {
            Kernel.WriteLine(( sender as Button ).Text);
            ObjOps.ShowParameters(ObjOps.GetSlectedNodes());
        }

        private void Button_SelInstances(object sender, EventArgs e) {
            Kernel.WriteLine(( sender as Button ).Text);
            ObjOps.SelectInstances(ObjOps.GetFirstSlectedNode(), true);
        }

        private void BtnOpenMaxFile_Click(object sender, EventArgs e) {
            Kernel.WriteLine(( sender as Button ).Text);
            string maxFilePpath = CbxMaxFilePath.Text;
            Kernel.WriteLine("Open Max file:{0} exists:{1}", maxFilePpath, File.Exists(maxFilePpath));
            Kernel._Interface.LoadFromFile(maxFilePpath, true);
        }

        private void BtnGetSelFaces_Click(object sender, EventArgs e) {
            Kernel.WriteLine(( sender as Button ).Text);
            Node node = ObjOps.GetFirstSlectedNode();
            Kernel.WriteLine("selected Node:{0} subObjectLevel:{1}", node.Name, Kernel._Interface.SubObjectLevel);
            List<int> fsel = node.Object.GetSelectedFaces();
            Kernel.WriteLine("selected Faces:{0} #({1}) -- +1 in Max", fsel.Count, String.Join(",", fsel));
        }

        private void BtnGetSelEdges_Click(object sender, EventArgs e) {
            Kernel.WriteLine(( sender as Button ).Text);
            Node node = ObjOps.GetFirstSlectedNode();
            Kernel.WriteLine("selected Node:{0} subObjectLevel:{1}", node.Name, Kernel._Interface.SubObjectLevel);
            var esel = node.Object.GetSelectedEdges();
            Kernel.WriteLine("selected Edges:{0} #({1}) -- +1 in Max", esel.Count, String.Join(",", esel));
        }

        private void BtnGetSelVetts_Click(object sender, EventArgs e) {
            Kernel.WriteLine(( sender as Button ).Text);
            Node node = ObjOps.GetFirstSlectedNode();
            Kernel.WriteLine("selected Node:{0} subObjectLevel:{1}", node.Name, Kernel._Interface.SubObjectLevel);
            var vsel = node.Object.GetSelectedVerts();
            Kernel.WriteLine("selected Verts:{0} #({1}) -- +1 in Max", vsel.Count, String.Join(",", vsel));
        }

        private void BtnHideUnselFaces_Click(object sender, EventArgs e) {
            Kernel.WriteLine(( sender as Button ).Text);
            Node node = ObjOps.GetFirstSlectedNode();
            if ( node != null ) { node.Object.HideGeometry(ChkSelected.Checked); }
        }

        private void BtnUnhideGeometry_Click(object sender, EventArgs e) {
            Kernel.WriteLine(( sender as Button ).Text);
            Node node = ObjOps.GetFirstSlectedNode();
            if ( node != null ) { node.Object.UnhideGeometry(); }
        }

        private void BtnGetSceneObjects_Click(object sender, EventArgs e) {
            Kernel.WriteLine(( sender as Button ).Text);
            IEnumerable<Node> nodes = Enumerable.Empty<Node>(); //new List<Node>(); 
            switch ( CbxSceneNodeTypes.SelectedItem ) {

                case "All": nodes = Kernel.Scene.AllNodes(); break;
                case "GeometryNodes": nodes = Kernel.Scene.GeometryNodes; break;
                case "LightNodes": nodes = Kernel.Scene.LightNodes; break;
                case "CameraNodes": nodes = Kernel.Scene.CameraNodes; break;
                case "HelperNodes": nodes = Kernel.Scene.HelperNodes; break;
                case "ShapeNodes": nodes = Kernel.Scene.ShapeNodes; break;
            }
            Kernel.WriteLine("Get Scene objects by type:{0} ( {1} ) >", CbxSceneNodeTypes.SelectedItem, nodes.Count());
            nodes.ToList()
                .ForEach(n => Kernel.WriteLine("\tNode:{0}\t\tSuperClass:{1}",
                n.Name,
                n.Object.SuperClassID.GetClassName(n.Object.SuperClassID)
                ));
        }

        private void Button18_Click(object sender, EventArgs e) {

            Kernel.WriteLine(( sender as Button ).Text);

            //MaxSharp Mod by MerlinEl 2020
            Node node = ObjOps.GetFirstSlectedNode();
            SceneObject sceneObject = node.Object;
            Geometry geometry = node.Object.Geometry;

            IINode iiNode = node._IINode;
            IReferenceTarget tRefTarget = node._Target;
            IReferenceMaker iRefMarker = node._Maker;
            //IGeomObject iGeomObject = node.Object._IGeomObject;
            IBaseObject iBaseObject = node.Object._BaseObject;
            IObject iObject = node.GetObjectRef(); //same as > //node.Object._Object; //_IINode.ObjectRef
            IAnimatable iAnimatable = node.Object._Anim;
            IParameterBlock iParamBlock = node.Object.ParameterBlock;

            ITriObject triObject = sceneObject.GetITriobject(); //triObject.ClearSelection();
            IMesh iMesh = sceneObject.GetImesh(Kernel.Now);

            //IMNMesh mn = //Global.MNMesh;
            //mn.OutToTri(iMesh);
            //mn.SetFromTri(iMesh);



            Kernel.WriteLine("Selected Node:{0} subObjectLevel:{1}", node.Name, Kernel._Interface.SubObjectLevel);
            List<object> objs = new List<object> {

                node,
                sceneObject,
                geometry,
                iiNode,
                tRefTarget,
                iRefMarker,
               // iGeomObject,
                iBaseObject,
                iObject,
                iAnimatable,
                iParamBlock,
                triObject,
                iMesh
            };
            Kernel.WriteLine("\tObject Types( {0} ) > ", objs.Count());
            objs.ForEach(o => {
                Kernel.WriteLine("\n\t\t{0}", o);
                try {
                    Type t = o.GetType(); // Where obj is object whose properties you need.
                    PropertyInfo[] pi = t.GetProperties();
                    foreach ( PropertyInfo p in pi ) {
                        Kernel.WriteLine("\t\t\t" + p.Name + " : " + p.GetType());
                    }

                } catch { }
            });

            /*objs.ForEach(o => {
                try {
                    var dump = ObjectDumper.Dump(o);
                    Console.WriteLine("\t", dump);
                    //foreach ( PropertyDescriptor descriptor in TypeDescriptor.GetProperties(o) ) {
                    //    string name = descriptor.Name;
                    //    object value = descriptor.GetValue(o);
                    //    Kernel.WriteLine("\t\tName:{0} Value:{1}", name, value);
                    //}
                } catch { }
            });*/


            /*objs.ForEach(n => {
                Kernel.WriteLine("\tObject:{0} type:{1} params:{2}", n.Name, n.GetType().Name, n.Object.Params.Count());
                foreach ( IParameter p in n.Object.Params ) Kernel.WriteLine("\t\tparam:{0}", p.Name);
            });*/

            //animArray = getSubAnimNames $[#Object__Editable_Patch][#Master]
            //node.Object.GetImesh.getsu
            //IMasterPointControl masterPointController = IMasterPointControl.GetSubController(1);
        }

        private void BtnListPrimitives_Click(object sender, EventArgs e) {
            //not works
            Kernel.WriteLine(( sender as Button ).Text);

            ISubClassList iSubClassList = Kernel._Global.ClassDirectory.Instance.GetClassList(SClass_ID.Geomobject);
            //SClass_ID
            //BuiltInClassIDB
            //Iterate through IGlobal.IGlobalClassDirectory
            //Get all classes where Category == "Standard Primitives" || Category == "Extended Primitives"
            Type type = typeof(IGlobal.IGlobalClassDirectory);
            BindingFlags flags = BindingFlags.Static | BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Default; //default == "All"
            switch ( CbxPrimitiveTypes.SelectedItem ) {

                case "Standard": break;
                case "Extended": break;
            }

            Kernel.WriteLine("fields:{0}", type.GetFields(flags).Length);
            type.GetFields(flags).WriteToListener("~");
            //.Where(f => f.FieldType == type)
            //.Apply(f => f.Name)
        }


        private void BtnGetObjArea_Click(object sender, EventArgs e) {
            Kernel.WriteLine(( sender as Button ).Text);
            Node node = ObjOps.GetFirstSlectedNode();
            double area = node.Object.GetArea();
            Kernel.WriteLine("Object:{0} Class:{1} Area:{2}", node.Name, node.ClassOf(), area);
        }

        private void BtnGetFaceArea_Click(object sender, EventArgs e) {
            Kernel.WriteLine(( sender as Button ).Text);
            Node node = ObjOps.GetFirstSlectedNode();
            var fsel = node.Object.GetSelectedFaces();
            fsel.ForEach(f => {

                double area = node.Object.GetFaceArea(f);
                Kernel.WriteLine("Face:{0} Area:{1}", f, area);
            });
        }

        private void ChkSelected_CheckedChanged(object sender, EventArgs e) {

        }

        private void BtnFacesCount_Click(object sender, EventArgs e) {
            Kernel.WriteLine(( sender as Button ).Text);
            Node node = ObjOps.GetFirstSlectedNode();
            Max.Log("Faces count:{0}", node.Object.NumFaces);
        }

        private void BtnEdgesCount_Click(object sender, EventArgs e) {
            Kernel.WriteLine(( sender as Button ).Text);
            Node node = ObjOps.GetFirstSlectedNode();
            Max.Log("Edges count:{0}", node.Object.NumEdges);
        }

        private void BtnVertsCount_Click(object sender, EventArgs e) {
            Kernel.WriteLine(( sender as Button ).Text);
            Node node = ObjOps.GetFirstSlectedNode();
            Max.Log("Verts count:{0}", node.Object.NumVerts);
        }

        private void BtnSelectFaces_Click(object sender, EventArgs e) {
            Kernel.WriteLine(( sender as Button ).Text);
            List<int> faceIndexes = TbxElementsIndexes.Text.Split(',').Select(Int32.Parse).ToList();
            Max.Log("SetSelectedFaces > faces:({0})", string.Join(",", faceIndexes));
            Node node = ObjOps.GetFirstSlectedNode();
            node.Object.SetSelectedFaces(faceIndexes, true);
        }

        private void BtnSelectEdges_Click(object sender, EventArgs e) {
            Kernel.WriteLine(( sender as Button ).Text);
            List<int> edgeIndexes = TbxElementsIndexes.Text.Split(',').Select(Int32.Parse).ToList();
            Max.Log("SetSelectedEdges > edges:({0})", string.Join(",", edgeIndexes));
            Node node = ObjOps.GetFirstSlectedNode();
            node.Object.SetSelectedEdges(edgeIndexes, true);
        }

        private void BtnSelectVerts_Click(object sender, EventArgs e) {
            Kernel.WriteLine(( sender as Button ).Text);
            List<int> vertIndexes = TbxElementsIndexes.Text.Split(',').Select(Int32.Parse).ToList();
            Max.Log("SetSelectedVerts > verts:({0})", string.Join(",", vertIndexes));
            Node node = ObjOps.GetFirstSlectedNode();
            node.Object.SetSelectedVerts(vertIndexes, true);
        }
    }
}


//https://help.autodesk.com/view/3DSMAX/2017/ENU/?guid=__files_GUID_5F19208A_B95E_41A8_A788_3108F747AF0E_htm
//Autodesk.Max.IInterface13.COREInterface13 collecting the IINodes
// get a list of all selected nodes.
/*List<IINode> selectedNodes = MxObj.GetSelectedNodes();
if ( selectedNodes.Count == 0 ) return;
Kernel.WriteLine("Selected Nodes:" + selectedNodes.Count.ToString());
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
