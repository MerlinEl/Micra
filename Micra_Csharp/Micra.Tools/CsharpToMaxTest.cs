using Autodesk.Max;
using Micra.Core;
using Micra.Core.Extensions;
using Micra.Core.Ops;
using Micra.Core.Prim;
using Micra.Core.Ressearch;
using Micra.Core.Utils;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Windows.Forms;
using System.Xml.Linq;
using static Micra.Core.Prim.PrimitiveTypes;

namespace Micra.Tools {
    public partial class CsharpToMaxTest:Form {
        XDocument MaxActionsXML = MxFile.GetXMLFromResources("MaxScriptActions.xml");//load XML from Resources
        public CsharpToMaxTest() {
            InitializeComponent();
            CloseAllFormInstancesExceptThisOne();
            Init();
        }
        private void Init() {

            //get assembly version
            Text = Text + "     " + MxGet.AssemblyVersion;
            //fill list boxes
            CbxClassOf.Items.AddRange(ClassReader.GetClassNames(typeof(ClassID)).ToArray());
            CbxClassOf.SelectedIndex = 0;
            CbxSuperClassOf.Items.AddRange(ClassReader.GetClassNames(typeof(SuperClassID)).ToArray());
            CbxSuperClassOf.SelectedIndex = 0;
            CbxSceneNodeTypes.SelectedIndex = 0;
            CbxPrimitiveTypes.SelectedIndex = 0;
            CbxMaxFilePath.SelectedIndex = 0;
            CbxSimillarObjBy.SelectedIndex = 0;
            LbxPrimitiveObjectNames.SelectedIndex = 0;
            SpnSimillarAreaTolerance.SelectedIndex = 2;
            CbxDecimalsCount.SelectedIndex = 7;
            CbxDigitsCount.SelectedIndex = 3;

            //Todo read all key names from XML
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

            CbxPrimitiveCategories.Items.AddRange(new object[] {

                "Geometry", //PrimGeomObjectFactory
                "Helpers", //PrimHelperFactory
                "Shapes", //PrimShapeObjectFactory
                "Cameras", //PrimCamObjectFactory
                "Lights" //PrimLightObjectFactory
            });
            CbxPrimitiveCategories.SelectedIndex = 0;
        }

        #region Execute Max Script

        private void BtnExecute_Click(object sender, EventArgs e) {
            Max.Log(( sender as Button ).Text);
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

        private void OnTextAreaGotFocus(object sender, EventArgs e) {
            MxSet.SetAccelerators(false);
        }


        private void OnTextAreaLostFocus(object sender, EventArgs e) {
            MxSet.SetAccelerators(true);
        }

        #endregion

        private void CloseAllFormInstancesExceptThisOne() {

            List<Form> AllButThisForm = Application.OpenForms
                .OfType<Form>()
                .Where(frm => frm.Name.Contains(this.Name) && frm.Handle != this.Handle)
                .ToList<Form>();

            foreach ( Form othrFrm in AllButThisForm ) othrFrm.Close();
        }

        private void OnFormShown(object sender, EventArgs e) {
            Max.LogClear(false);
        }


        private void Button1_Click(object sender, EventArgs e) {

            Max.Log(( sender as Button ).Text);
            Node node = ObjOps.GetFirstSlectedNode();
            Max.Log("first node:{0}", node);
            if ( node != null ) node.SelectOnly();
        }

        private void Button5_Click(object sender, EventArgs e) {
            Max.Log(( sender as Button ).Text);
            string cmd = "Render()";
            textBox1.Text = cmd;
            IFPValue mxsRetVal = MxSet.ExecuteMAXScriptScript(cmd);
            if ( mxsRetVal != null ) Max.Log("Render Click gor:" + mxsRetVal.S);
        }

        private void Button9_Click(object sender, EventArgs e) {

            Max.Log(( sender as Button ).Text);
            PrintNode(Kernel.Scene.RootNode);
        }

        private void PrintNode(Node n, string indent = "") {
            Max.Log(indent + n.Name);
            foreach ( var c in n.Children )
                PrintNode(c, indent + "  ");
        }

        private void Button7_Click(object sender, EventArgs e) {
            Max.Log(( sender as Button ).Text);
            var cylinder = Primitives.Cylinder.Create();
            Max.Log("Create Cylinder params:{0}", cylinder.Params.ToString());
            cylinder["radius"] = 20.0f;
            cylinder["height"] = 40.0f;
            cylinder["heightsegs"] = 10;
            Max.Log("Create Bend");
            var bend = Primitives.Bend.Create();
            cylinder.AddModifier(bend);
            bend["bendangle"] = 30.0f;
        }

        private void BtnPluginList(object sender, EventArgs e) {

            Max.Log(( sender as Button ).Text);
            foreach ( var p in PluginMgr.Plugins ) Max.Log(p.ClassName);
        }

        private void Button10_Click(object sender, EventArgs e) {

            Max.PushPrompt("Look at the MAXScript listener window");
            Max.Log("I'm some text appearing in the MAXScript listener window!");
        }

        private void Button11_Click(object sender, EventArgs e) {
            Max.Log(( sender as Button ).Text);
            ObjOps.SelectAll(ChkSelHidden.Checked, true);
        }

        private void Button12_Click(object sender, EventArgs e) {
            Max.Log(( sender as Button ).Text);
            ObjOps.DeselectAll(true);
        }

        private void Button13_Click(object sender, EventArgs e) {
            Max.Log(( sender as Button ).Text);
            if ( RbtClassOf.Checked ) {

                ClassID classId = ClassID.FromName(CbxClassOf.SelectedItem.ToString());
                Max.Log("classId:{0} Name:{1}", classId, classId.GetClassName(classId));
                ObjOps.SelectAllOfType(classId, ChkSelHidden2.Checked, ChkClearSel.Checked, true);

            } else {

                SuperClassID superClassId = SuperClassID.FromName(CbxSuperClassOf.SelectedItem.ToString());
                Max.Log("superClassId:{0}", superClassId);
                ObjOps.SelectAllOfType(superClassId, ChkSelHidden2.Checked, ChkClearSel.Checked, true);
            }
        }
        private void Button_ShowSelClass(object sender, EventArgs e) {
            Max.Log(( sender as Button ).Text);
            ObjOps.ShowClass(ObjOps.GetSlectedNodes(), ChkShowMaxClass.Checked);
        }

        private void Button15_Click(object sender, EventArgs e) {
            Max.Log(( sender as Button ).Text);
            Max.LogClear(ChkMacroRec.Checked);
        }

        private void Button_ShowSelParams(object sender, EventArgs e) {
            Max.Log(( sender as Button ).Text);
            ClassReader.ShowParameters(ObjOps.GetSlectedNodes());

            //https://help.autodesk.com/view/3DSMAX/2017/ENU/?guid=__cpp_ref_class_param_block_desc2_html
            /*for ( int i = 0; i < Kernel._Interface.RootNode.NumChildren; i++ ) {
                IINode node = Kernel._Interface.RootNode.GetChildNode(i);
                if ( !node.Selected ) continue;
                Max.Log("obj:{0} ", node.Name);
                IObject io = node.ObjectRef;
                if ( io == null ) continue;
                //IObjectState ist = io.Eval(Kernel.Now);
                //ist.Obj
                //return GetDescByID(PARTICLECHANNELBOOLR_INTERFACE); }
                node.GetDescByID(Kernel._Interface.Id);
                Max.Log("\tNumParamBlocks:{0}", io.NumParamBlocks);
                for (int j = 0; j < io.NumParamBlocks; j++ ) {

                    IIParamBlock2 ip2 = io.GetParamBlock(i);
                    Max.Log("\t\tNumParams:{0}", ip2.NumParams);
                    for (int k = 0; k < ip2.NumParams; k++ ) {

                        Max.Log("\t\t\tparam:{0}", ip2.GetParamDefByIndex((uint)k).IntName);
                    }
                }
            }*/
        }

        private void Button_SelInstances(object sender, EventArgs e) {
            Max.Log(( sender as Button ).Text);
            ObjOps.SelectInstances(ObjOps.GetFirstSlectedNode(), true);
        }

        private void BtnOpenMaxFile_Click(object sender, EventArgs e) {
            Max.Log(( sender as Button ).Text);
            string maxFilePpath = CbxMaxFilePath.Text;
            Max.Log("Open Max file:{0} exists:{1}", maxFilePpath, File.Exists(maxFilePpath));
            Kernel._Interface.LoadFromFile(maxFilePpath, true);
        }

        private void BtnGetSelFaces_Click(object sender, EventArgs e) {
            Max.Log(( sender as Button ).Text);
            Node node = ObjOps.GetFirstSlectedNode();
            Max.Log("selected Node:{0} subObjectLevel:{1}", node.Name, Kernel._Interface.SubObjectLevel);
            List<int> fsel = node.Object.GetSelectedFaces();
            Max.Log("selected Faces:{0} #({1}) -- +1 in Max", fsel.Count, String.Join(",", fsel));
        }

        private void BtnGetSelEdges_Click(object sender, EventArgs e) {
            Max.Log(( sender as Button ).Text);
            Node node = ObjOps.GetFirstSlectedNode();
            Max.Log("selected Node:{0} subObjectLevel:{1}", node.Name, Kernel._Interface.SubObjectLevel);
            var esel = node.Object.GetSelectedEdges();
            Max.Log("selected Edges:{0} #({1}) -- +1 in Max", esel.Count, String.Join(",", esel));
        }

        private void BtnGetSelVetts_Click(object sender, EventArgs e) {
            Max.Log(( sender as Button ).Text);
            Node node = ObjOps.GetFirstSlectedNode();
            Max.Log("selected Node:{0} subObjectLevel:{1}", node.Name, Kernel._Interface.SubObjectLevel);
            var vsel = node.Object.GetSelectedVerts();
            Max.Log("selected Verts:{0} #({1}) -- +1 in Max", vsel.Count, String.Join(",", vsel));
        }

        private void BtnHideUnselFaces_Click(object sender, EventArgs e) {
            Max.Log(( sender as Button ).Text);
            Node node = ObjOps.GetFirstSlectedNode();
            if ( node != null ) { node.Object.HideGeometry(ChkSelected.Checked); }
        }

        private void BtnUnhideGeometry_Click(object sender, EventArgs e) {
            Max.Log(( sender as Button ).Text);
            Node node = ObjOps.GetFirstSlectedNode();
            if ( node != null ) { node.Object.UnhideGeometry(); }
        }

        private void BtnGetSceneObjects_Click(object sender, EventArgs e) {
            Max.Log(( sender as Button ).Text);
            IEnumerable<Node> nodes = Enumerable.Empty<Node>(); //new List<Node>(); 
            switch ( CbxSceneNodeTypes.SelectedItem ) {

                case "All": nodes = Kernel.Scene.AllNodes(); break;
                case "GeometryNodes": nodes = Kernel.Scene.GeometryNodes; break;
                case "LightNodes": nodes = Kernel.Scene.LightNodes; break;
                case "CameraNodes": nodes = Kernel.Scene.CameraNodes; break;
                case "HelperNodes": nodes = Kernel.Scene.HelperNodes; break;
                case "ShapeNodes": nodes = Kernel.Scene.ShapeNodes; break;
            }
            Max.Log("Get Scene objects by type:{0} ( {1} ) >", CbxSceneNodeTypes.SelectedItem, nodes.Count());
            nodes.ToList()
                .ForEach(n => Max.Log("\tNode:{0}\t\tSuperClass:{1}",
                n.Name,
                n.Object.SuperClassID.GetClassName(n.Object.SuperClassID)
                ));
        }

        private void Button18_Click(object sender, EventArgs e) {

            Max.Log(( sender as Button ).Text);

            //MaxSharp Mod by MerlinEl 2020
            Node node = ObjOps.GetFirstSlectedNode();
            SceneObject sceneObject = node.Object;
            //Geometry geometry = node.Object.Geometry;

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

            Max.Log("Selected Node:{0} subObjectLevel:{1}", node.Name, Kernel._Interface.SubObjectLevel);
            List<object> objs = new List<object> {

                node,
                sceneObject,
                //geometry,
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
            Max.Log("\tObject Types( {0} ) > ", objs.Count());
            objs.ForEach(o => {
                Max.Log("\n\t\t{0}", o);
                try {
                    Type t = o.GetType(); // Where obj is object whose properties you need.
                    PropertyInfo[] pi = t.GetProperties();
                    foreach ( PropertyInfo p in pi ) {
                        Max.Log("\t\t\t" + p.Name + " : " + p.GetType());
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
                    //    Max.Log("\t\tName:{0} Value:{1}", name, value);
                    //}
                } catch { }
            });*/


            /*objs.ForEach(n => {
                Max.Log("\tObject:{0} type:{1} params:{2}", n.Name, n.GetType().Name, n.Object.Params.Count());
                foreach ( IParameter p in n.Object.Params ) Max.Log("\t\tparam:{0}", p.Name);
            });*/

            //animArray = getSubAnimNames $[#Object__Editable_Patch][#Master]
            //node.Object.GetImesh.getsu
            //IMasterPointControl masterPointController = IMasterPointControl.GetSubController(1);
        }

        private void BtnGetObjArea_Click(object sender, EventArgs e) {
            Max.Log(( sender as Button ).Text);
            Node node = ObjOps.GetFirstSlectedNode();
            double area = node.Object.GetArea();
            Max.Log("Object:{0} Class:{1} Area:{2}", node.Name, node.ClassOf(), area);
        }

        private void BtnGetFaceArea_Click(object sender, EventArgs e) {
            Max.Log(( sender as Button ).Text);
            Node node = ObjOps.GetFirstSlectedNode();
            Geo geo = new Geo(node); //poly or mesh or later modpoly modmesh
            var fsel = node.Object.GetSelectedFaces();
            fsel.ForEach(f => {

                double area = geo.GetFaceArea(f);
                Max.Log("Face:{0} Area:{1}", f, area);
            });
        }

        private void ChkSelected_CheckedChanged(object sender, EventArgs e) {

        }

        private void BtnFacesCount_Click(object sender, EventArgs e) {
            Max.Log(( sender as Button ).Text);
            Node node = ObjOps.GetFirstSlectedNode();
            Max.Log("Faces count:{0}", node.Object.NumFaces);
        }

        private void BtnEdgesCount_Click(object sender, EventArgs e) {
            Max.Log(( sender as Button ).Text);
            Node node = ObjOps.GetFirstSlectedNode();
            Max.Log("Edges count:{0}", node.Object.NumEdges);
        }

        private void BtnVertsCount_Click(object sender, EventArgs e) {
            Max.Log(( sender as Button ).Text);
            Node node = ObjOps.GetFirstSlectedNode();
            Max.Log("Verts count:{0}", node.Object.NumVerts);
        }

        private void BtnSelectFaces_Click(object sender, EventArgs e) {
            Max.Log(( sender as Button ).Text);
            List<int> faceIndexes = TbxElementsIndexes.Text.Split(',').Select(Int32.Parse).ToList();
            Max.Log("SetSelectedFaces > faces:({0})", string.Join(",", faceIndexes));
            Node node = ObjOps.GetFirstSlectedNode();
            node.Object.SetSelectedFaces(faceIndexes, true);
        }

        private void BtnSelectEdges_Click(object sender, EventArgs e) {
            Max.Log(( sender as Button ).Text);
            List<int> edgeIndexes = TbxElementsIndexes.Text.Split(',').Select(Int32.Parse).ToList();
            Max.Log("SetSelectedEdges > edges:({0})", string.Join(",", edgeIndexes));
            Node node = ObjOps.GetFirstSlectedNode();
            node.Object.SetSelectedEdges(edgeIndexes, true);
        }

        private void BtnSelectVerts_Click(object sender, EventArgs e) {
            Max.Log(( sender as Button ).Text);
            List<int> vertIndexes = TbxElementsIndexes.Text.Split(',').Select(Int32.Parse).ToList();
            Max.Log("SetSelectedVerts > verts:({0})", string.Join(",", vertIndexes));
            Node node = ObjOps.GetFirstSlectedNode();
            node.Object.SetSelectedVerts(vertIndexes, true);
        }

        private void BtnSelSimElements_Click_1(object sender, EventArgs e) {

            Max.Log(( sender as Button ).Text);
            bool byArea = CbxSimillarObjBy.SelectedIndex == 0 || CbxSimillarObjBy.SelectedIndex == 1;
            bool byVcount = CbxSimillarObjBy.SelectedIndex == 2;
            List<Node> selNodes = ObjOps.GetSlectedNodes();
            Max.Log("\tSelected nodes:{0}", selNodes.Count());
            int slev = Max.SubObjectLevel;
            float areaToloerance = Calc.StringToFloat(SpnSimillarAreaTolerance.SelectedItem.ToString());
            Max.Log("areaToloerance:{0}", areaToloerance);
            if ( selNodes.Count() == 1 && slev != 0 ) { //if single object is selected

                Node node = selNodes.First();
                if ( !node.IsEditable() ) return;
                Max.Log("selected Node:{0} subObjectLevel:{1}", node.Name, Kernel._Interface.SubObjectLevel);
                switch ( slev ) { //next operation is depend on subobject level

                    case 2: GeoOps.SelectSimillarEdges(node, areaToloerance); break;
                    case 3:
                        if (node.IsClassOf(ClassID.EditableMesh)) {
 
                            GeoOps.SelectSimillarFaces(node, byArea, byVcount,
                                areaToloerance, ( int )SpnSimillarVertsTolerance.Value);

                        } else if (node.IsClassOf(ClassID.EditablePoly)) {

                            GeoOps.SelectSimillarEdgeLoops(node, areaToloerance); 
                        }
                    break;
                    case 4:
                        GeoOps.SelectSimillarFaces(node, byArea, byVcount,
                            areaToloerance, ( int )SpnSimillarVertsTolerance.Value); break;
                    case 5:
                        GeoOps.SelectSimillarElements(node, byArea, byVcount,
                            areaToloerance, ( int )SpnSimillarVertsTolerance.Value); break;
                }

            } else if ( selNodes.Count() >= 1 ) { //when multi object selection

                ObjOps.SelectSimillarNodes(selNodes, byArea, byVcount, areaToloerance, (int)SpnSimillarVertsTolerance.Value);
            }
        }

        private void BtnListAllPrimitives_Click(object sender, EventArgs e) {
            Max.Log(( sender as Button ).Text);
            ClassReader.GetClassNames(typeof(Primitives)).ForEach(
                s => {
                    Max.Log("\tPrimitives:{0}", s);
                }
            );
        }

        private void BtnListGeomPrim_Click(object sender, EventArgs e) {

            Max.Log(( sender as Button ).Text);
            ClassReader.GetClassNames(typeof(Primitives), typeof(PrimGeomObjectFactory)).ForEach(
                s => {
                    Max.Log("\tPrimitives > PrimGeomObjectFactory:{0}", s);
                }
            );
        }

        private void BtnShowBuiltInClassIDAB_Click(object sender, EventArgs e) {
            Max.Log(( sender as Button ).Text);
            Max.Log("\nBuiltInClassIDA:");
            ClassReader.GetClassNames(typeof(BuiltInClassIDA)).ForEach(
                s => { Max.Log("\t{0}", s); }
            );
            Max.Log("\nBuiltInClassIDB:");
            ClassReader.GetClassNames(typeof(BuiltInClassIDB)).ForEach(
                s => { Max.Log("\t{0}", s); }
            );
        }

        private void BtnCreatePrimitivesGenerator_Click(object sender, EventArgs e) {
            Max.Log(( sender as Button ).Text);
            TbxCoding.Text = PrimitivesClassGenerator.CreatePrimitiveCommandsList().Replace("\n", Environment.NewLine);
        }

        private void BtnGeneratePrimitivesParamClasses_Click(object sender, EventArgs e) {
            Max.Log(( sender as Button ).Text);
            TbxCoding.Text = PrimitivesClassGenerator.GenerateClasses().Replace("\n", Environment.NewLine);
        }

        private void BtnCodingClear_Click(object sender, EventArgs e) {
            TbxCoding.Text = "";
        }

        private void BtnCodingCopy_Click(object sender, EventArgs e) {
            Clipboard.SetText(TbxCoding.Text);
        }

        private void button2_Click(object sender, EventArgs e) {
            Max.Log(( sender as Button ).Text);

            float offsetX = ( float )SpnPrimOffsetX.Value;
            float offsetY = ( float )SpnPrimOffsetY.Value;
            for ( int i = 0; i < SpnPrimCnt.Value; i++ ) {
                CreatePrimitiveByName(LbxPrimitiveObjectNames.SelectedItem.ToString(), offsetX, offsetY, i);
            }
        }
        private void CreatePrimitiveByName(string primName, float offsetX, float offsetY, int i) {

            switch ( primName ) {

                case "Box":
                    new PBox(Primitives.Box.Create()) {
                        Length = ( float )SpnPrimLen.Value,
                        Width = ( float )SpnPrimWid.Value,
                        Height = ( float )SpnPrimHei.Value,
                        Wirecolor = Color.RainbowColor(( int )SpnPrimCnt.Value, i),
                        Pos = new Point3(( ( float )SpnPrimWid.Value + offsetX ) * i, 0, 0)
                        //realWorldMapSize = false //not works
                    }; break;

                case "Sphere":
                    new PSphere(Primitives.Sphere.Create()) {
                        Radius = ( float )SpnPrimRadius1.Value,
                        Wirecolor = Color.RainbowColor(( int )SpnPrimCnt.Value, i),
                        Pos = new Point3(( ( float )SpnPrimWid.Value * 4 + offsetX ) * i, ( ( float )SpnPrimRadius1.Value + offsetY ) * 2, 0)
                    }; break;

                case "Teapot":
                    new PTeapot(Primitives.Teapot.Create()) {
                        Radius = ( float )SpnPrimRadius1.Value,
                        Wirecolor = Color.RainbowColor(( int )SpnPrimCnt.Value, i),
                        Pos = new Point3(( ( float )SpnPrimWid.Value * 4 + offsetX ) * i, ( ( float )SpnPrimRadius1.Value + offsetY ) * 3, 0)
                    }; break;

                case "Cylinder":
                    new PCylinder(Primitives.Cylinder.Create()) {
                        Radius = ( float )SpnPrimRadius1.Value,
                        Height = ( float )SpnPrimHei.Value,
                        Wirecolor = Color.RainbowColor(( int )SpnPrimCnt.Value, i),
                        Pos = new Point3(( ( float )SpnPrimWid.Value * 4 + offsetX ) * i, ( ( float )SpnPrimRadius1.Value + offsetY ) * 4, 0)
                    }; break;

                case "Torus":
                    new PTorus(Primitives.Torus.Create()) {
                        Radius1 = ( float )SpnPrimRadius1.Value,
                        Radius2 = ( float )SpnPrimRadius2.Value,
                        Wirecolor = Color.RainbowColor(( int )SpnPrimCnt.Value, i),
                        Pos = new Point3(( ( float )SpnPrimWid.Value * 4 + offsetX ) * i, ( ( float )SpnPrimRadius1.Value + offsetY ) * 5, 0)
                    }; break;

                case "Tube":
                    new PTube(Primitives.Tube.Create()) {
                        Radius1 = ( float )SpnPrimRadius1.Value,
                        Radius2 = ( float )SpnPrimRadius2.Value,
                        Height = ( float )SpnPrimHei.Value,
                        Wirecolor = Color.RainbowColor(( int )SpnPrimCnt.Value, i),
                        Pos = new Point3(( ( float )SpnPrimWid.Value * 4 + offsetX ) * i, ( ( float )SpnPrimRadius1.Value + offsetY ) * 6, 0)
                    }; break;

                case "Plane":
                    new PPlane(Primitives.Plane.Create()) {
                        Length = ( float )SpnPrimLen.Value,
                        Width = ( float )SpnPrimWid.Value,
                        Wirecolor = Color.RainbowColor(( int )SpnPrimCnt.Value, i),
                        Pos = new Point3(( ( float )SpnPrimWid.Value + offsetX ) * i, 0, 0)
                    }; break;
            }
        }

        private void BtnGetSelectedPrimitiveClass_Click(object sender, EventArgs e) {

            Max.Log(( sender as Button ).Text);
            Node n = ObjOps.GetFirstSlectedNode();
            if ( n == null ) return;
            TbxObjType.Text = PrimitivesClassGenerator.GetObjectClass(n);
        }

        private void BtnGenerateClassParams_Click(object sender, EventArgs e) {

            Max.Log("Create:{0}", TbxObjType.Text);
            if ( TbxObjType.Text.Length == 0 ) return;
            PrimGeomObjectFactory o = ( PrimGeomObjectFactory )ClassReader.GetFieldValueByName(typeof(Primitives), TbxObjType.Text);
            if ( o == null ) return;
            Max.Log("\tClass:{0}", o.ClassID.PartA);
            SceneObject so = o.Create();
            TbxCoding.Text = PrimitivesClassGenerator.GenerateClass(so).Replace("\n", Environment.NewLine);
            Max.DeleteObject(so);
        }

        private void BtnCreatePlaneComplex_Click(object sender, EventArgs e) {
            Max.Log(( sender as Button ).Text);
            //not works
            //_CPP_TO_CSHARP_01.CreateBox();
            //_CPP_TO_CSHARP_01.CreateTeapot();
            CPP_TO_CSHARP_01.CreatePlane(100, 200, 10, 20);
        }

        private void BtnCreateBoxComplex_Click(object sender, EventArgs e) {
            Max.Log(( sender as Button ).Text);
            CPP_TO_CSHARP_01.CreateBox();
        }

        private void BtnCreateTeapotComplex_Click(object sender, EventArgs e) {
            Max.Log(( sender as Button ).Text);
            CPP_TO_CSHARP_01.CreateTeapot();
        }

        private void OnPrimitiveCategoryChanged(object sender, EventArgs e) {

            string categoryType = CbxPrimitiveCategories.SelectedItem.ToString();
            Type primType = GetPrimitiveTypeByName(categoryType);
            var items = ClassReader.GetClassNames(typeof(Primitives), primType).ToArray();
            LbxPrimitiveObjectNames.Items.Clear();
            LbxPrimitiveObjectNames.Items.AddRange(items);
            LbxPrimitiveObjectNames.SelectedIndex = 0;
        }

        private void OnPrimitiveItemChanged(object sender, EventArgs e) {

            LbxParamList.Items.Clear();
            string primitiveObjectName = LbxPrimitiveObjectNames.SelectedItem.ToString();
            var so = Primitives.CreateSceneObjectByPrimitiveName(primitiveObjectName);
            if ( so == null ) {

                LbxParamList.Items.Add("Unable to get Parameters.");
                return;
            }
            so.Params.ForEach(p => Max.Log("obj:{0} param:{1}", primitiveObjectName, p));
            LbxParamList.Items.AddRange(so.Params.Where(p => !String.IsNullOrEmpty(p.Name)).Select(p => p.Name).ToArray());
            LbxParamList.SelectedIndex = 0;
            so = null;
        }

        private void BtnDecimalsCount_Click(object sender, EventArgs e) {
            Max.Log("decimals:{0}", Calc.DecimaslCount(
                Calc.StringToDouble(CbxDecimalsCount.SelectedItem.ToString()))
            );
        }

        private void BtnDigitsCount_Click(object sender, EventArgs e) {
            Max.Log("digits:{0}", Calc.DigitsCount(
                Int32.Parse(CbxDigitsCount.SelectedItem.ToString()))
            );
        }

        private void BtnRoundDecimal_Click(object sender, EventArgs e) {
            Max.Log("double:{0}", Calc.RoundDouble(
                Calc.StringToDouble(CbxDecimalsCount.SelectedItem.ToString()),
                ( int )SpnRoundDouble.Value)
            );
        }

        private void BtnRoundInt_Click(object sender, EventArgs e) {
            Max.Log("int:{0}", Calc.RoundInt(
                Int32.Parse(CbxDigitsCount.SelectedItem.ToString()),
                ( int )SpnRoundInt.Value)
            );
        }
    }
}


/*
         Utility.GetStructPublicNames(typeof(BuiltInClassIDA)).ForEach(
             s => {
                 Max.Log("\tBuiltInClassIDA:{0}", s);
                 //var o = Primitives.Box.Create();

             }
         );*/

/*ISubClassList iSubClassList = Kernel._Global.ClassDirectory.Instance.GetClassList(IGlobal.IGlobalClassDirectory);
Max.Log("iSubClassList:{0}", iSubClassList.Count((int)EnumPlugins.AccesType.ACC_ALL));

Utility.GetStructPublicNames(typeof(IGlobal.IGlobalClassDirectory)).ForEach(
        s => {
            Max.Log("\tIGlobalClassDirectory:{0}", s);

        }
   );*/

//ISubClassList iSubClassList = Kernel._Global.ClassDirectory.Instance.GetClassList(SClass_ID.Geomobject);
//SClass_ID
//BuiltInClassIDB
//Iterate through IGlobal.IGlobalClassDirectory
//Get all classes where Category == "Standard Primitives" || Category == "Extended Primitives"
/*Type type = typeof(IGlobal.IGlobalClassDirectory);
BindingFlags flags = BindingFlags.Static | BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Default; //default == "All"
switch ( CbxPrimitiveTypes.SelectedItem ) {

    case "Standard": break;
    case "Extended": break;
}

Max.Log("fields:{0}", type.GetFields(flags).Length);
type.GetFields(flags).WriteToListener("~");*/
//type.GetFields(flags).WriteToListener("~");
//.Where(f => f.FieldType == type)
//.Apply(f => f.Name)

//var box = PBox.Create(); //PBox is derived from SceneObject
/*box["Length"] = (float)SpnBoxLen.Value; //old way
box["Width"] = (float)SpnBoxWid.Value; //old way
box["Height"] = (float)SpnBoxHei.Value; //old way*/
//box[PBox.Length] = (float)SpnBoxLen.Value; //old way


//https://help.autodesk.com/view/3DSMAX/2017/ENU/?guid=__files_GUID_5F19208A_B95E_41A8_A788_3108F747AF0E_htm
//Autodesk.Max.IInterface13.COREInterface13 collecting the IINodes
// get a list of all selected nodes.
/*List<IINode> selectedNodes = MxObj.GetSelectedNodes();
if ( selectedNodes.Count == 0 ) return;
Max.Log("Selected Nodes:" + selectedNodes.Count.ToString());
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
