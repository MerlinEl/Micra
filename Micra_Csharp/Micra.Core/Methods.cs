using Autodesk.Max;
//using Autodesk.Max.Wrappers;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
/**
 * IInterface ip = this.global.COREInterface;
 IINode selNode = ip.GetSelNode( 0 ); //get first object
 IObjectState os = selNode.EvalWorldState(0,false);
IObject selobj = os.Obj;
 ITriObject tobj = selobj as ITriObject;
 IMesh mesh = tobj.Mesh;
 IBitArray selverts =  mesh.VertSel;  //get selected vertex

 */
namespace Micra.Core {
    class Methods {
        public static bool DEBUG { get; private set; }

        public void GradeMesh(IINode node, int Channel, int HeightThreshold, int FadeInValue) {

            IObject obj = node.EvalWorldState(Kernel.Now, true).Obj;
            IClass_ID cid = Kernel._Global.Class_ID.Create((uint)BuiltInClassIDA.TRIOBJ_CLASS_ID, 0);
            if ( obj.CanConvertToType(cid) != 0 ) {
                ITriObject triMesh = obj.ConvertToType(Kernel.Now, cid) as ITriObject;
                IMesh mesh = triMesh.Mesh;
                IList<IPoint3> mapVerts = mesh.MapVerts(Channel);
                int numMapVerts = mesh.GetNumMapVerts(Channel);

                IPoint3 Pt1 = Kernel._Global.Point3.Create(1, 1, 1);

                for ( int i = 0; i < numMapVerts; i++ ) {
                    IPoint3 vertex = mesh.GetVert(i);

                    mapVerts[i].X = 1; // if you need to double-check it

                    if ( vertex.Z > HeightThreshold ) {
                        mapVerts[i].Y = Math.Max(0, mapVerts[i].Y - FadeInValue);
                        //mapVerts[i].Z = Math.Max(0, mapVerts[i].Z - FadeInValue);  // if it's not a grey scale
                    } else {
                        mapVerts[i].Y = Math.Min(1, mapVerts[i].Y + FadeInValue);
                        //mapVerts[i].Z = Math.Min(1, mapVerts[i].Z + FadeInValue);  // if it's not a grey scale
                    }
                    mapVerts[i].Z = mapVerts[i].Y; // if it's a grey scale
                }
            }
        }

        void DemoTeapot(IGlobal global) {
            IGlobal global = Autodesk.Max.GlobalInterface.Instance;  //note that global will be an instance of an abstract class.
            var intfc = global.COREInterface13;
            IClass_ID cid = global.Class_ID.Create((uint)BuiltInClassIDA.TEAPOT_CLASS_ID, (uint)BuiltInClassIDB.TEAPOT_CLASS_ID);
            object obj = intfc.CreateInstance(SClass_ID.Geomobject, cid as IClass_ID);
            if ( obj == null ) throw new Exception("Failed to create a teapot!");
            IINode n = global.COREInterface.CreateObjectNode((IObject)obj);
            IObject iobj = (IObject)obj;
            IParamArray ps = iobj.ParamBlock;
            ps.SetValue(0, global.COREInterface.Time, 20.0f);
            n.Move(global.COREInterface.Time, global.Matrix3.Create(), global.Point3.Create(20, 20, 0), true, true, 0, true);
        }


        /*
         * 
		* Create a plane on all four-sided (selected) faces in the node referenced by  handleid
		@return bool
		*/
        public bool convertFacesToPlanes(uint handleid) {
            IGlobal global = Autodesk.Max.GlobalInterface.Instance;
            IInterface14 ip = global.COREInterface14;
            IINode obj = ip.GetINodeByHandle(handleid).ActualINode;
            IObjectState os = obj.ObjectRef.Eval(ip.Time);
            // Now grab the object itself.
            IObject objOriginal = os.Obj;
            // Let's make sure it is a TriObject, which is the typical kind of object with a mesh
            if ( !objOriginal.IsSubClassOf(global.TriObjectClassID) ) {
                // If it is NOT, see if we can convert it...
                if ( objOriginal.CanConvertToType(global.TriObjectClassID) == 1 ) {
                    objOriginal = objOriginal.ConvertToType(ip.Time, global.TriObjectClassID);
                } else {
                    return false;
                }

            }
            // Now we should be safe to know it is a TriObject and we can cast it as such.
            // An exception will be thrown...
            ITriObject triObj = objOriginal as ITriObject;
            //IPolyObject triObj = objOriginal as IPolyObject;
            IMesh mesh = triObj.Mesh as IMesh;
            IBitArray facearray = mesh.FaceSel; //Should be a bitarray of selected faces
                                                //!TODO... if count == 0 then use all polygons
            /*See if any faces are selected*/
            if ( facearray.AnyBitSet.Equals(true) ) {

                int faceCount = facearray.Size;
                /*
				int time = (int)1;
				int numFaces ;
				int numVerts ;
				
				global.GetPolygonCount(time, objOriginal, &numFaces, &numVerts);
				*/
                /*iterate over selected faces
				 
				 Uh oh... this is a trimesh... what we really need is the selected Polygon... how to get this in C#?
				 
				 */
                for ( int i = 0; i <= ( faceCount - 1 ); i++ ) {
                    IFace face = mesh.Faces[i];
                    if ( face.V.Count() == 4 ) {
                        /*But this will never happen in a triMesh*/
                        IPoint3 v1 = mesh.GetVert((int)( face.GetVert(0) ));
                        IPoint3 v2 = mesh.GetVert((int)( face.GetVert(1) ));
                        IPoint3 v3 = mesh.GetVert((int)( face.GetVert(2) ));
                        IPoint3 v4 = mesh.GetVert((int)( face.GetVert(3) ));
                        IPoint3 front = v1.Subtract(v2).Normalize;
                        IPoint3 side = v2.Subtract(v3).Normalize;
                        IPoint3 up = mesh.GetFaceNormal(i);
                        float divNum = ( 4 );
                        IPoint3 center = v1.Add(v2).Add(v3).Add(v4).DivideBy(divNum);

                        //IMatrix3 tm =  new IMatrix3(front side up center);
                        //tm = pretranslate tm [0.5, 0.5, 0]
                        //face.GetVertIndex()
                    }
                }
            } else {
                return false;
            }
            return true;
        }

        public static IList<IPoint3> getObjectPoints(IObject obj, IINode node, bool bbox, float bias) {
            if ( bbox ) {
                List<IPoint3> bb_points = new List<IPoint3>();
                //IINode node = obj.WorldSpaceObjectNode;
                IBox3 bb_box = obj.GetLocalBoundBox(max_interface.Time, node, null);

                IPoint3 bb_min = bb_box.Min;
                IPoint3 bb_max = bb_box.Max;

                if ( bias > 0 ) {
                    float bias_coeff = bias / 200;

                    IPoint3 margins = ( bb_box.Max.Subtract(bb_box.Min) ).MultiplyBy(bias_coeff);
                    if ( DEBUG )
                        global.TheListener.EditStream.Printf($"new: x: {margins.X},x: {margins.Y},x: {margins.Z}\n");

                    bb_min = bb_min.Add(margins);
                    bb_max = bb_max.DecreaseBy(margins);
                }
                //Corners Instantiate
                IPoint3 top_right_front = global.Point3.Create(bb_max.X, bb_max.Y, bb_max.Z);
                IPoint3 top_right_back = global.Point3.Create(bb_max.X, bb_min.Y, bb_max.Z);
                IPoint3 top_left_back = global.Point3.Create(bb_min.X, bb_min.Y, bb_max.Z);
                IPoint3 top_left_front = global.Point3.Create(bb_min.X, bb_max.Y, bb_max.Z);
                IPoint3 bottom_right_front = global.Point3.Create(bb_max.X, bb_max.Y, bb_min.Z);
                IPoint3 bottom_right_back = global.Point3.Create(bb_max.X, bb_min.Y, bb_min.Z);
                IPoint3 bottom_left_back = global.Point3.Create(bb_min.X, bb_min.Y, bb_min.Z);
                IPoint3 bottom_left_front = global.Point3.Create(bb_min.X, bb_max.Y, bb_min.Z);
                //End Corners Instantiate

                //Start Add in List
                bb_points.Add(top_right_front);
                bb_points.Add(top_right_back);
                bb_points.Add(top_left_back);
                bb_points.Add(top_left_front);
                bb_points.Add(bottom_right_front);
                bb_points.Add(bottom_right_back);
                bb_points.Add(bottom_left_back);
                bb_points.Add(bottom_left_front);
                //Greate :)
                return bb_points;
            } else {
                List<IPoint3> verts = new List<IPoint3>();
                ITriObject tri_obj = (ITriObject)obj.ConvertToType(max_interface.Time, global.TriObjectClassID);
                IMesh mesh = tri_obj.Mesh;
                int count_verts = mesh.NumVerts;

                for ( int i = 0; i < count_verts; i++ ) {
                    IPoint3 vertObjectSpace = mesh.GetVert(i);

                    //IPoint3 vert = mesh.GetVert(i);
                    IMatrix3 tmObj2World = node.GetObjectTM(max_interface.Time, null);
                    IPoint3 vertWorldSpace = tmObj2World.PointTransform(vertObjectSpace);
                    verts.Add(vertWorldSpace);
                }
                bool debug = false;
                if ( debug )
                    return mesh.Verts;
                else
                    return verts;
            }

        }


        public static int getVertsInViewport(IList<IPoint3> points, IINode cam, IINode node) {
            List<IPoint3> insideVerts = new List<IPoint3>();
            List<IPoint3> outsideVerts = new List<IPoint3>();

            IMatrix3 testTM = max_interface.ActiveViewExp.AffineTM;

            IPoint3 point31 = testTM.PointTransform(cam.ObjOffsetPos);
            if ( DEBUG )
                global.TheListener.EditStream.Printf("-___- - AffineTM - Lazy Debug - NAME: " + cam.Name + " X : " + point31.X + " Y : " + point31.Y + " Z : " + point31.Z + "\n");

            int width = max_interface2.RendWidth;
            int height = max_interface2.RendHeight;
            foreach ( IPoint3 pnt in points ) {
                IMatrix3 tmObj2World = node.GetObjectTM(max_interface.Time, null);
                IPoint3 pnt2 = tmObj2World.PointTransform(pnt);
                if ( DEBUG )
                    global.TheListener.EditStream.Printf("._. Work Please -  pnt - X : " + pnt2.X + " Y : " + pnt2.Y + " Z : " + pnt2.Z + "\n");

                //Win!!! Eeeee  --- thePos = pnt * theTM ---
                IPoint3 thePos = testTM.PointTransform(pnt2);
                //End Win!!! Eeeee

                if ( DEBUG )
                    global.TheListener.EditStream.Printf("._. Work Please -  thePos - X : " + thePos.X + " Y : " + thePos.Y + " Z : " + thePos.Z + "\n");

                IIPoint2 point2 = global.IPoint2NS.Create(0, 0);
                IIPoint2 point23 = global.IPoint2NS.Create(width, height);
                if ( DEBUG )
                    global.TheListener.EditStream.Printf($"Start point 0,0 X : {point2.X} , Y : {point2.Y}\n");
                if ( DEBUG )
                    global.TheListener.EditStream.Printf($"End point X : {point23.X} , Y : {point23.Y}\n");

                IPoint3 points3 = max_interface2.ActiveViewExp.MapScreenToView(point2, thePos.Z);
                IPoint3 point32 = max_interface2.ActiveViewExp.MapScreenToView(point23, thePos.Z);

                if ( DEBUG )
                    global.TheListener.EditStream.Printf("._. Work Please -  points3 - X : " + points3.X + " Y : " + points3.Y + " Z : " + points3.Z + "\n");
                if ( DEBUG )
                    global.TheListener.EditStream.Printf("._. Work Please -  point32 - X : " + point32.X + " Y : " + point32.Y + " Z : " + point32.Z + "\n");

                IPoint3 world_size = points3.Subtract(point32);

                if ( DEBUG )
                    global.TheListener.EditStream.Printf("0.0 Work Please -  world_size - X : " + world_size.X + " Y : " + world_size.Y + " Z : " + world_size.Z + "\n");


                float x_aspect = width / ( Math.Abs(world_size.X) );
                float y_aspect = height / ( Math.Abs(world_size.Y) );

                if ( DEBUG )
                    global.TheListener.EditStream.Printf("Aspects - Work Please - X : " + x_aspect + " Y : " + y_aspect + "\n");

                IPoint2 screen_coords = global.Point2.Create(( x_aspect / ( thePos.X - points3.X ) ), ( -( y_aspect * ( thePos.Y - points3.Y ) ) ));

                if ( DEBUG )
                    global.TheListener.EditStream.Printf("?.? Work Please - screene_coords - X : " + screen_coords.X + " Y : " + screen_coords.Y + "\n");

                if ( ( screen_coords.X <= 0 ) || ( screen_coords.Y <= 0 ) || ( screen_coords.X > width ) || ( screen_coords.Y > height ) ) {
                    outsideVerts.Add(thePos);
                    if ( DEBUG )
                        global.TheListener.EditStream.Printf("!.! Please - out - X : " + thePos.X + " Y : " + thePos.Y + " Z : " + thePos.Z + "\n");
                } else {
                    insideVerts.Add(thePos);
                    if ( DEBUG )
                        global.TheListener.EditStream.Printf("#.# Please - in - X : " + thePos.X + " Y : " + thePos.Y + " Z : " + thePos.Z + "\n");
                }
            }
            return insideVerts.Count;
        }

        public static List<List<uint>> Vertex_in_sight(UIntPtr camera_handle) {

            List<List<uint>> response = new List<List<uint>>();
            //List<IINode> all_nodes = SceneNodes.GetAllNodes(max_interface.RootNode);

            IAnimatable camera = global.Animatable.GetAnimByHandle(camera_handle);
            IINode camera_node = camera as IINode;

            if ( DEBUG )
                global.TheListener.EditStream.Printf("Debug - NAME: " + camera_handle + " Camera :" + camera.NodeName + " Node : " + camera_node.Name + "\n");
            foreach ( IINode node in applicable_nodes ) {
                IObject obj = node.EvalWorldState(max_interface.Time, false).Obj;
                IBox3 bbox = obj.GetLocalBoundBox(max_interface.Time, node, null);


                IList<IPoint3> obj_bbox_points = getObjectPoints(obj, node, true, 40);
                IList<IPoint3> obj_mesh_points = getObjectPoints(obj, node, false, 0);
                int pre_check = getVertsInViewport(obj_bbox_points, camera_node, node);

                if ( DEBUG ) {
                    foreach ( IPoint3 point in obj_mesh_points )
                        global.TheListener.EditStream.Printf($"Node: {node.Name} x : {point.X} , y: {point.Y} , z: {point.Z}\n");
                }
                List<uint> pair = new List<uint>();
                if ( pre_check == 0 ) {
                    pair.Add(node.Handle);
                    pair.Add(0);
                    response.Add(pair);
                }
            }
            return response;
        }

        // Method to obtain the ParamBlock2 of the Custom Attribute 'CA_MxsNETConnect attribID:#(0x11aa99ff, 0x1234abcd)'
        // applied to scene RootNode
        static public IIParamBlock2 GetCA_MxsNETConnect() {
            IGlobal global = GlobalInterface.Instance;
            IInterface14 ip = global.COREInterface14;

            IINode rootNode = ip.RootNode;
            IClass_ID CA_Class = global.Class_ID.Create(0x11aa99ff, 0x1234abcd);

            IICustAttribContainer CAC = rootNode.CustAttribContainer;
            int numCA = CAC.NumCustAttribs;
            int CA_Id = -1;
            ICustAttrib CA;

            for ( int ca = 0; ca < numCA; ca++ ) {
                CA = CAC.GetCustAttrib(ca);

                if ( CA.ClassID.PartA == CA_Class.PartA && CA.ClassID.PartB == CA_Class.PartB ) {
                    CA_Id = ca;
                    break;
                }
            }

            if ( CA_Id == -1 ) {
                return null;
            }

            CA = CAC.GetCustAttrib(CA_Id);
            IIParamBlock2 param = CA.GetParamBlock(0);
            return param;
        }


        static public void CA_MxsNETConnect() {
            IIParamBlock2 param = GetCA_MxsNETConnect();
            if ( param == null ) {
                return;
            }

            ////////////////////////////////////////////////////////////
            // Example1 to retrieve a #MaxObject that is an Edtable_Mesh (it's the first parameter => id=0)
            IReferenceTarget rf = param.GetReferenceTarget(0, 0, 0);    // First 0 is because #MaxObject are the first parameter
                                                                        // Second 0 is time at 0
                                                                        // Third 0 is first MaxObject in the #MaxObjectTab array
            ITriObject tri = (ITriObject)rf;
            IMesh mm = tri.Mesh_;   //  Retrieve the mesh of the Editable_Mesh
            int numverts = mm.NumVerts_;
            //WriteLine("numVerts= " + numverts);

            // Example2 to retrieve all nodes held in the #nodeTab parameter (it's the second parameter => id=1)
            int numNodes = param.Count(1);
            List<IINode> theNodes = new List<IINode>(numNodes);
            for ( int i = 0; i < numNodes; i++ ) {
                theNodes.Add(param.GetINode(1, 0, i));
                //WriteLine("Node " + i + ": " + theNodes[i].Name);
            }

            // Example3 to return a node to the #nodeTab parameter (in this case, the last node to the first place)
            bool done = param.SetValue(1, 0, theNodes[numNodes - 1], 0);
            ////////////////////////////////////////////////////////////
        }

        public void IntersectRay(uint handleid) {

            IGlobal global = Autodesk.Max.GlobalInterface.Instance;
            IInterface14 ip = global.COREInterface14;
            IINode obj = ip.GetINodeByHandle(handleid).ActualINode;
            IObjectState os = obj.ObjectRef.Eval(ip.Time);
            // Now grab the object itself.
            IObject objOriginal = os.Obj;
            // cast as tri-object, as we know it will work by this point
            var triOriginal = objOriginal as ITriObject;

            // get various cooridnate spaces
            var TTM = Target.GetObjectTM(Ip.Time, intv);
            var InvTTM = Target.GetObjectTM(Ip.Time, intv);
            var STM = Source.GetNodeTM(Ip.Time, intv);
            var InvSTM = Source.GetNodeTM(Ip.Time, intv);
            InvTTM.Invert();
            InvSTM.Invert();

            // ray in world space (Source is always in world space, rayDir = (0,0,-1, or 0,0,1))
            Rhey = Global.Ray.Create(STM.Trans, RayDir);

            // put ray in target object space
            Rhey.P = STM.Multiply(InvTTM).Trans;
            Rhey.Dir = Global.VectorTransform(Rhey.Dir, InvTTM);
            Global.Normalize(Rhey.Dir);

            var res = triOriginal.Mesh.IntersectRay(Rhey, ref dist, nor, ref fi, bary);

            // Hit position in Object space
            HitPos = Rhey.P.Add(Rhey.Dir.MultiplyBy(dist));

            // Back into World Space
            var resMat = Global.Matrix3.Create(true);
            resMat.Trans = HitPos;
            resMat = resMat.Multiply(TTM);
            HitPos = resMat.Trans;

            // Debug to 3ds Max Listener
            GlobalInterface.Instance.TheListener.EditStream.Printf($"Source: {Source.Name} | ");
            GlobalInterface.Instance.TheListener.EditStream.Printf($"HitPos X: {HitPos.X} Y: {HitPos.Y} Z: {HitPos.Z}");

        }


        //Im trying to animate vertices using the Max SDK(.net version). I have it working with 1 line of MaxScript(“animateVertex $ #all”) in 
        //between and I would like to know if it would be possible to remove it. This is what I have right now:
        public void AnimateVertices() {

            IInterval interval = Kernel._Global.Interval.Create();
            interval.SetInfinite();
            IINode node = Kernel._Interface.GetSelNode(0);
            IObject baseObjectRef = node.ObjectRef.FindBaseObject();
            ITriObject triObject = baseObjectRef as ITriObject;

            //try Autodesk.Max.IMasterPointControl //IMasterPointControl.GetSubController(int)
            //IMasterPointControl masterPointController = IMasterPointControl.GetSubController(1);
            IMasterPointControl masterPointController = GetmasterPointController(triObject);
            if ( masterPointController == null )
                return;

            MaxScriptExecute("animateVertex $ #all");  //This is the one!

            subControlList = EnumControl(masterPointController);

            int begin = 0 * Kernel._Global.TicksPerFrame; //0 :)
            int end = 1 * Kernel._Global.TicksPerFrame;

            Kernel._Global.SuspendAnimate();
            Kernel._Global.AnimateOn();

            //Ive tried multiple things to replace it, but none of them work.
            //Id like to know what it does in the background, but I couldnt find any samples.
            masterPointController.SetNumSubControllers(8, true);
            for ( int i = 0; i < masterPointController.NumSubControllers; i++ ) {
                //I want a ctrlPoint3
                //var controller = m_Global.Point3Controller.ToController; //crash!
                IControl positionController = Kernel._Global.NewDefaultPositionController; //I dont think this one is correct either, but doesn't crash at least

                masterPointController.SetSubController(i, positionController);  //set the controller at the current index              
                IPoint3 val = trimesh.Mesh.GetVert(i);  //get the position of the vertex
                object valObj = val;

                positionController.SetValue(begin, valObj, true, GetSetMethod.Absolute);   //set a key at 0

                val.X += 30; val.Y += 30; val.Z += 30;
                object testValObj = val;

                positionController.SetValue(end, testValObj, true, GetSetMethod.Absolute);  //set another key at 1
            }


        }
    }
}
