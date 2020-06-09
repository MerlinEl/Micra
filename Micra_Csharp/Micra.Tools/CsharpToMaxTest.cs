using Autodesk.Max;
using Micra.Core;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
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
            CbxClassOf.Items.AddRange(ClassID.GetNames());
            CbxClassOf.SelectedIndex = 0;
            CbxSuperClassOf.Items.AddRange(SuperClassID.GetNames());
            CbxSuperClassOf.SelectedIndex = 0;
            CbxSceneNodeTypes.SelectedIndex = 0;
            CbxPrimitiveTypes.SelectedIndex = 0;
            CbxMaxFilePath.SelectedIndex = 0;

            CbxScriptList.Items.AddRange(new object[]{
                "SelFaces",
                "SelEdges",
                "SelVerts",
                "3Boxes",
                "Render",
                "GetFaceArea",
                "GetObjectArea"
            });
            CbxScriptList.SelectedIndex = 0;
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

        private void Button5_Click(object sender, EventArgs e) {
            Kernel.WriteLine(( sender as Button ).Text);
            string cmd = "Render()";
            textBox1.Text = cmd;
            IFPValue mxsRetVal = MxSet.ExecuteMAXScriptScript(cmd);
            if ( mxsRetVal != null ) MxSet.LogLi("Render Click gor:" + mxsRetVal.S);
        }

        private void BtnSelSimElements_Click(object sender, EventArgs e) {

            Kernel.WriteLine(( sender as Button ).Text);
            List<Node> selNodes = Kernel.Scene.SelectedNodes().ToList();
            Kernel.WriteLine("\tSelected nodes:{0}", selNodes.Count());
            int slev = GlobalMethods.SubObjectLevel;
            if ( selNodes.Count() == 1 && slev != 0 ) { //if single object is selected

                Node node = selNodes.First();
                if ( !node.IsEditable() ) return;
                Kernel.WriteLine("selected Node:{0} subObjectLevel:{1}", node.Name, Kernel._Interface.SubObjectLevel);
                switch ( slev ) { //next operation is depend on subobject level

                    case 2: GeoOps.SelectSimillarEdges(node); break;
                    case 3: GeoOps.SelectSimillarEdges(node); break;
                    case 4: GeoOps.SelectSimillarFaces(node); break;
                    case 5: GeoOps.SelectSimillarFaces(node); break;
                }

            } else if ( selNodes.Count() >= 1 ) { //when multi object selection

                ObjOps.SelectSimillarNodes(selNodes);
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
            teapot._Node.Move(new Point3(20, 10, 5));
            //teapot._Object.Move
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
        private void Button14_Click(object sender, EventArgs e) {
            Kernel.WriteLine(( sender as Button ).Text);
            var nodes = Kernel.Scene.SelectedNodes();
            ObjOps.ShowClass(nodes);
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
            ObjOps.ShowParameters(nodes);
        }

        private void Button4_Click_1(object sender, EventArgs e) {
            Kernel.WriteLine(( sender as Button ).Text);
            Node node = Kernel.Scene.SelectedNodes().FirstOrDefault();
            ObjOps.SelectInstances(node, true);
        }

        private void BtnOpenMaxFile_Click(object sender, EventArgs e) {

            Kernel.WriteLine(( sender as Button ).Text);
            string maxFilePpath = CbxMaxFilePath.Text;
            Kernel.WriteLine("Open Max file:{0} exists:{1}", maxFilePpath, File.Exists(maxFilePpath));
            Kernel._Interface.LoadFromFile(maxFilePpath, true);
        }

        private void BtnGetSelFaces_Click(object sender, EventArgs e) {
            Kernel.WriteLine(( sender as Button ).Text);
            Node node = Kernel.Scene.SelectedNodes().FirstOrDefault();
            Kernel.WriteLine("selected Node:{0} subObjectLevel:{1}", node.Name, Kernel._Interface.SubObjectLevel);
            List<int> fsel = node.Object.GetSelectedFaces();
            Kernel.WriteLine("selected Faces:{0} #({1})", fsel.Count, String.Join(",", fsel));
        }

        private void BtnGetSelEdges_Click(object sender, EventArgs e) {
            Kernel.WriteLine(( sender as Button ).Text);
            Node node = Kernel.Scene.SelectedNodes().FirstOrDefault();
            Kernel.WriteLine("selected Node:{0} subObjectLevel:{1}", node.Name, Kernel._Interface.SubObjectLevel);
            var esel = node.Object.GetSelectedEdges();
            Kernel.WriteLine("selected Edges:{0} #({1})", esel.Count, String.Join(",", esel));
        }

        private void BtnGetSelVetts_Click(object sender, EventArgs e) {
            Kernel.WriteLine(( sender as Button ).Text);
            Node node = Kernel.Scene.SelectedNodes().FirstOrDefault();
            Kernel.WriteLine("selected Node:{0} subObjectLevel:{1}", node.Name, Kernel._Interface.SubObjectLevel);
            var vsel = node.Object.GetSelectedVerts();
            Kernel.WriteLine("selected Verts:{0} #({1})", vsel.Count, String.Join(",", vsel));
        }

        private void BtnHideUnselFaces_Click(object sender, EventArgs e) {
            Kernel.WriteLine(( sender as Button ).Text);
            Node node = Kernel.Scene.SelectedNodes().FirstOrDefault();
            if ( node != null ) {
                node.Object.HideGeometry(ChkSelected.Checked);
                Kernel._Interface.InvalidateObCache(node._IINode);
                Kernel.RedrawViews();
            }
        }

        private void BtnUnhideGeometry_Click(object sender, EventArgs e) {
            Kernel.WriteLine(( sender as Button ).Text);
            Node node = Kernel.Scene.SelectedNodes().FirstOrDefault();
            if ( node != null ) {
                node.Object.UnhideGeometry();
                Kernel._Interface.InvalidateObCache(node._IINode);
                Kernel.RedrawViews();
            }
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
                SuperClassID.GetName(n.Object.SuperClassID)
                ));
        }

        private void button18_Click(object sender, EventArgs e) {

            Kernel.WriteLine(( sender as Button ).Text);

            //MaxSharp Mod by MerlinEl 2020
            Node node = Kernel.Scene.SelectedNodes().FirstOrDefault();
            SceneObject sceneObject = node.Object;
            Geometry geometry = node.Object.Geometry;

            IINode iiNode = node._IINode;
            IReferenceTarget tRefTarget = node._Target;
            IReferenceMaker iRefMarker = node._Maker;
            IGeomObject iGeomObject = node.Object._IGeomObject;
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
                iGeomObject,
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
            Node node = Kernel.Scene.SelectedNodes().FirstOrDefault();
            double area = GeoOps.GetObjectArea(node);
            Kernel.WriteLine("Object:{0} Class:{1} Area:{2}", node.Name, node.ClassOf(), area);
        }

        private void BtnGetFaceArea_Click(object sender, EventArgs e) {
            Kernel.WriteLine(( sender as Button ).Text);
            Node node = Kernel.Scene.SelectedNodes().FirstOrDefault();
            if ( node.IsClassOf(ClassID.EditablePoly) ) {

                Poly poly = node.GetPoly();
                var fsel = node.Object.GetSelectedFaces();
                fsel.ForEach(f => {

                    double area = GeoOps.GetFaceArea(poly, poly.ngons[f]);
                    Kernel.WriteLine("Face:{0} Area:{1}", f, area);
                });
            } else if ( node.IsClassOf(ClassID.EditableMesh) ) {

                Mesh mesh = node.GetMesh();
                var fsel = node.Object.GetSelectedFaces();
                fsel.ForEach(f => {

                    double area = GeoOps.GetFaceArea(mesh, mesh.faces[f]);
                    Kernel.WriteLine("Face:{0} Area:{1}", f, area);
                });
            }
        }

        private void BtnExecute_Click(object sender, EventArgs e) {
            Kernel.WriteLine(( sender as Button ).Text);
            Kernel.ExecuteMaxScriptScript(textBox1.Text);
        }
        private void BtnClearExecute_Click(object sender, EventArgs e) {
            textBox1.Text = "";
        }

        private void OnCbxScriptListSelChanges(object sender, EventArgs e) {
            string cmd = Switch.On(CbxScriptList.Text)
                .Case("SelFaces").Then("print $.selectedFaces")
                .Case("SelEdges").Then("print $.selectedEdges")
                .Case("SelVerts").Then("print $.selectedVerts")
                .Case("3Boxes").Then("" +
"Box pos:[-100,0,0] name:(UniqueName \"ojobox\") wirecolor:red\n" +
"Box pos:[0,0,0] name:(UniqueName \"ojobox\") wirecolor:blue\n" +
"Box pos:[100,0,0] name:(UniqueName \"ojobox\") wirecolor:green\n")
                .Case("Render").Then("Render()")
                .Case("GetFaceArea").Then("" +
"fn GetFacesArea obj &fsel = (\n" +
"   local face_areas = #()\n" +
"   if classOf obj == Editable_Mesh then (\n" +
"      fsel = getFaceSelection obj\n" +
"      for fi in fsel do append face_areas (meshOp.getFaceArea obj fi)\n" +
"   ) else if classOf obj == Editable_Poly do (\n" +
"      fsel = polyOp.getFaceSelection obj\n" +
"      for fi in fsel do append face_areas (polyOp.getFaceArea obj fi)\n" +
"   )\n" +
"   face_areas\n" +
")\n" +
"fsel = 0\n" +
"format \"Object:% Area:% Face:%\n\" selection[1].Name (GetFacesArea selection[1] &fsel) fsel")
                .Case("GetObjectArea").Then("" +
"fn GetObjectArea obj = (\n" +
"   faces_area = 0\n" +
"   if classOf obj == Editable_Mesh then (\n" +
"      for f in obj.faces do faces_area += meshOp.getFaceArea obj f.index\n" +
"   ) else if classOf obj == Editable_Poly do (\n" +
"      for f in obj.faces do faces_area += polyOp.getFaceArea obj f.index\n" +
"   )\n" +
"   faces_area\n" +
")\n" +
"format \"Object:% Area:%\n\" selection[1].Name (GetObjectArea selection[1])")
                .Default("");
            textBox1.Text = cmd.Replace("\n", Environment.NewLine);
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
