using Autodesk.Max;
using Micra.Core;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.InteropServices;
//http://help.autodesk.com/view/3DSMAX/2020/ENU/?guid=__cpp_ref_class_interface14_html
namespace Micra.Tools {
    internal class MxCollection {
        //enum to class constants
        public static IClass_ID triClass = MxGet.Global.Class_ID.Create((uint)BuiltInClassIDA.TRIOBJ_CLASS_ID, 0);
        public static IClass_ID polyClass = MxGet.Global.Class_ID.Create((uint)BuiltInClassIDA.POLYOBJ_CLASS_ID, 0);
        public static IClass_ID spsClass = MxGet.Global.Class_ID.Create((uint)BuiltInClassIDA.SPLINESHAPE_CLASS_ID, 0);
        /*public static IInterface_ID EditablePoly { //not tested not used
            get {
                return MxGet.Global.Interface_ID.Create(0x092779, 0x634020);
            }
        }*/

        /* C++ version
        Object* obj = node->GetObjectRef();
        PolyObject* poly = (PolyObject*)obj->ConvertToType(t, Class_ID(polyObjectClassID));
        Object *pObj = poly->CollapseObject();
        if (pObj != poly) delete poly;
        node->SetObjectRef(pObj);
         */
        public static IObject ConvertToMesh(IINode node) {

            //Check if node is not null
            if ( node == null ) {
                //MxGet.Interface.PushPrompt("Nothing Selected! Select something first to explode it into faces.");
                return null;
            }
            // Get it's current object state. If a modifier has been applied, for example,
            // it is going to return the OS of the mesh in it's current form in the timeline.
            IObjectState os = node.ObjectRef.Eval(MxGet.Interface.Time);

            // Now grab the object itself.
            IObject objOriginal = os.Obj;

            // If can be converted then convert it...
            if ( objOriginal.CanConvertToType(MxGet.Global.TriObjectClassID) == 1 )
                return objOriginal.ConvertToType(MxGet.Interface.Time, MxGet.Global.TriObjectClassID);
            else return null;

            //single line
            //obj.ObjectRef.Eval(0).Obj.FindBaseObject().ConvertToType(0, triClass);

            //Python example
            /*node = MaxPlus.Factory.CreateNode(obj)
            node.Convert(MaxPlus.ClassIds.TriMeshGeometry)
            obj = MaxPlus.Factory.CreateGeomObject(MaxPlus.ClassIds.Sphere)
            obj = node.GetBaseObject()*/
        }
        public static IObject ConvertToPoly(IINode node) {

            if ( node == null ) return null;
            IObjectState os = node.ObjectRef.Eval(MxGet.Interface.Time);
            IObject objOriginal = os.Obj;
            if ( objOriginal.CanConvertToType(MxGet.Global.PolyObjectClassID) == 1 )
                return objOriginal.ConvertToType(MxGet.Interface.Time, MxGet.Global.PolyObjectClassID);
            else return null;

            //single line
            //obj.ObjectRef.Eval(0).Obj.FindBaseObject().ConvertToType(0, polyClass);

            //Python example
            /*node = MaxPlus.Factory.CreateNode(obj)
            node.Convert(MaxPlus.ClassIds.PolyMeshObject)
            obj = MaxPlus.Factory.CreateGeomObject(MaxPlus.ClassIds.Sphere)
            obj = node.GetBaseObject()*/
        }

        public void DemoTeapotHardWay(IGlobal global) { //test

            var cid = MxGet.Global.Class_ID.Create(
                (uint)BuiltInClassIDA.TEAPOT_CLASS_ID,
                (uint)BuiltInClassIDB.TEAPOT_CLASS_ID
            );
            var obj = MxGet.Interface.CreateInstance(SClass_ID.Geomobject, cid) as IObject;
            var n = MxGet.Global.COREInterface.CreateObjectNode(obj);
            var ps = obj.ParamBlock;
            ps.SetValue(0, MxGet.Global.COREInterface.Time, 20.0f);
            n.Move(global.COREInterface.Time, global.Matrix3.Create(),
            global.Point3.Create(20, 20, 0), true, true, 0, true);
        }

        public static void PrintObjectClass(IINode obj) { //test only
                                                          //if ( obj == null || obj.ObjectRef.Eval(0).Obj.SuperClassID != SClass_ID.Geomobject ) return;
                                                          //MxGet.Global.Class_ID
                                                          //PolyObject
                                                          //MxGet.Interface.MaxPlus
            IObject io = obj.ObjectRef.Eval(0).Obj;

            IClass_ID classId = io.ClassID; //Autodesk.Max.Wrappers.Class_ID 
            SClass_ID sclassID = io.SuperClassID; //Geomobject
            MxSet.LogLi("PrintObjectClass > obj:{0} is ClassOf:{1} SuperClassOf:{2}", obj.Name, classId, sclassID);
            //io.ConvertToType(0, polyObjectClassID);
        }

        public static void SelectNone(bool redraw = true) {

            MxGet.Interface.ClearNodeSelection(redraw);
        }
        public static void SelectAll() => SetSelection(GetAllObjects());

        public static void SelectAll2() {

            /*IINodeTab nodes = MxGet.Global.NodeTab.Create();
            Kernel.Scene.Objects.ForEach(n => nodes.AppendNode(( n as IINode ), true, 1));
            MxGet.Interface.SelectNodeTab(nodes, true, true);*/
            IINodeTab nodes = ToIINodeTab(Kernel.Scene.Objects.ToList());
            MxGet.Interface.SelectNodeTab(nodes, true, true);
        }
        /// <summary>
        /// Get All Scene Objects
        /// </summary>
        public static List<IINode> GetAllObjects(bool visibleOnly = false) { //OK

            IINode root_node = MxGet.Interface.RootNode;
            MxSet.LogLi("Objects > RootNode:" + root_node.Name);
            List<IINode> node_list = new List<IINode>() { };
            for ( int i = 0; i < root_node.NumChildren; i++ ) {

                IINode child_node = MxGet.Interface.RootNode.GetChildNode(i);
                if ( visibleOnly && child_node.IsHidden(NodeHideFlags.All, false) ) continue;
                node_list.Add(child_node);
            };
            return node_list;
        }

        public static IINode GetFirstSelectedNode() {
            return MxGet.Interface.GetSelNode(0);
        }

        public static List<IINode> GetSelection() {

            IINodeTab selNodes = MxGet.Global.NodeTab.Create();
            MxGet.Interface.GetSelNodeTab(selNodes);
            return selNodes.ToIEnumerable().ToList();

            /*List<IINode> selectedNodes = new List<IINode>();
            for ( int i = 0; i < MxGet.Interface.SelNodeCount; i++ ) {
                selectedNodes.Add(MxGet.Interface.GetSelNode(i));
            }
            return selectedNodes;*/
        }
        /*private static void SetSelection(List<IINode> _nodes) {
            try {
                _nodes = _nodes.Distinct().ToList();
                IINodeTab selectedNodes = MxGet.Global.NodeTab.Create();
                selectedNodes.Resize(_nodes.Count);
                foreach ( IINode _node in _nodes ) {
                    if ( _node != null ) {
                        selectedNodes.AppendNode(_node, false, 1);
                    }
                    MxGet.Interface.SelectNode(_node, false);
                }
                MxGet.Interface.SelectNodeTab(selectedNodes, true, true);
            } catch {
            }
        }
        public static void SetSelection(List<uint> _nodesHandles) {
            if ( !TagGlobals.addToSelection ) {
                Interface.ClearNodeSelection(false);
            }
            Selection = _nodesHandles.GetNodesByHandles();
        }
        private static void SetSelection(SortableObservableCollection<IINode> _nodes) {
            Selection = _nodes.ToList();
        }*/
        public static void SetSelection(List<IINode> nodes) {

            if ( nodes == null || nodes.Count == 0 ) return;
            MxGet.Interface.SelectNodeTab(ToIINodeTab(nodes), true, true);
        }
        /* C++ version
        INodeTab instanceAndRef;
        IInstanceMgr::GetInstanceMgr()->GetInstances(node, instanceAndRef);
        */
        public static List<IINode> GetInstances(IINode node) { //not tested not used

            IINodeTab instances = MxGet.Global.NodeTab.Create();
            MxGet.InstanceMgr.GetInstances(node, instances);
            return instances.ToIEnumerable().ToList();
        }

        public void PrintObjectsInLayers() { //test only

            int layersCount = MxGet.Interface.LayerManager.LayerCount;
            MxSet.LogLi("PrintObjectsInLayers > layers:" + layersCount);
            for ( int i = 0; i < layersCount; i++ ) {

                IILayer layer = MxGet.Interface.LayerManager.GetLayer(i);
                //ITab<IINode> nodes = Kernel.Global.Tab.Create<IINode>();
                IINodeTab nodes = MxGet.Global.NodeTab.Create();
                IInterface_ID id = MxGet.Global.Interface_ID.Create(

                    (uint)BuiltInInterfaceIDA.LAYERPROPERTIES_INTERFACE,
                    (uint)BuiltInInterfaceIDB.LAYERPROPERTIES_INTERFACE
                );
                IILayerProperties lProp = (IILayerProperties)layer.GetInterface(id);
                lProp.Nodes(nodes); //get nodes from layers 
                foreach ( IINode node in nodes.ToIEnumerable() ) {

                    MxSet.LogLi("\tnode:" + node.Name);
                }
            }
        }

        public static void PrintSceneMaterials() { //test only

            ITab<IMtlBase> materialsLib = MxGet.Interface.SceneMtls;
            MxSet.LogLi("PrintSceneMaterials > scene mats:" + materialsLib.Count);
            foreach ( var materialBase in materialsLib.ToIEnumerable() ) {

                MxSet.LogLi("\t" + materialBase.Name);
            }
        }

        internal static void getChildNodesRecurse(IINode node, List<IINode> array) { //not tested not used

            array.Add(node);
            for ( int i = 0; i < node.NumChildren; i++ ) {
                getChildNodesRecurse(node.GetChildNode(i), array);
            }
        }
        public static IINodeTab ToIINodeTab<T>(List<T> nodesList) {

            IINodeTab nodes = MxGet.Global.NodeTab.Create();
            nodesList.ForEach(n => nodes.AppendNode(( n as IINode ), true, 1));
            return nodes;
        }
        /*public static IINodeTab ToIINodeTab(List<IINode> nodesList) {

            if ( nodesList == null ) return null;
            IINodeTab nodes = MxGet.Global.NodeTab.Create();
            foreach ( IINode n in nodesList ) {
                if ( n != null ) nodes.AppendNode(n, true, 1);
                //MxGet.Interface.SelectNode(n, false);
            }
            return nodes;
        }*/
        /*public static ITab<IINode> ToITab(this List<IINode> _nodes) {

            ITab<IINode> _Itab = _nodes.ToNodeTab() as ITab<IINode>;

            return _Itab;
        }
        public static List<IINode> ToListNode(this IINodeTab _nodes) {
            List<IINode> listNodes = new List<IINode>();
            for ( int i = 0; i < _nodes.Count; i++ ) {
                IntPtr pointer = (IntPtr)i;
                listNodes.Add(_nodes[i]);
            }
            return listNodes;
        }
        public static List<uint> ToListHandles(this List<IINode> _nodes) {
            List<uint> listHandles = new List<uint>();
            foreach ( IINode _node in _nodes ) {
                listHandles.Add(_node.Handle);
            }
            return listHandles;
        }*/
    }
    internal static class MxCollectionExtensions {
        //julienCM69Q
        /*public static IEnumerable<IINode> ToIEnumerable(this IINodeTab nodeList) {

            if ( nodeList == null ) {
                yield break;
            }
            int count = nodeList.Count;
            for ( int i = 0; i < count; i++ ) {
                yield return nodeList[i];
            }
        }*/
        public static IEnumerable<T> ToIEnumerable<T>(this ITab<T> itab) {

            if ( itab == null ) yield break;
            for ( int i = 0; i < itab.Count; i++ ) {
                yield return itab[i];
            }
        }
        public static void ForEach<T>(this IEnumerable<T> collection, Action<T> action) {
            foreach ( T item in collection )
                action(item);
        }
    }
}




/*
 public static IEnumerable<Autodesk.Max.MaxPlus.INode> ToIEnumerable(this INodeList nodeList)
        {
            if (nodeList == null)
            {
                yield break;
            }

            int count = nodeList.GetCount();
            for (int i = 0; i < count; i++)
            {
                yield return nodeList.GetItem(i);
            }
        }
     */
/*
foreach (IINode o in sel_objs.ToIEnumerable() ) {
double v = MxPoly.GetGeometryVolume(o);
    }
*/

/*public static IInterface_ID EditablePoly { //not tested not used
    get {
        return MxGet.Global.Interface_ID.Create(0x092779, 0x634020);
    }
}
public static IInterface_ID NodeLayerProperties { //not tested not used
    get {
        return MxGet.Global.Interface_ID.Create(0x44e025f8, 0x6b071e44);

    }
}
public static IIFPLayerManager IIFPLayerManager { //not tested not used
    get {
        IInterface_ID iIFPLayerManagerID = MxGet.Global.Interface_ID.Create((uint)BuiltInInterfaceIDA.LAYERMANAGER_INTERFACE, (uint)BuiltInInterfaceIDB.LAYERMANAGER_INTERFACE);
        return (IIFPLayerManager)MxGet.Global.GetCOREInterface(iIFPLayerManagerID);
    }
}*/

//not tested not used
//http://help.autodesk.com/view/3DSMAX/2016/ENU/?guid=__cpp_ref_class_interface_html
//Returns a pointer to the object (or modifier) that is currently being edited in the modifier panel.
/*internal static IBaseObject CurEditObject() {

    var camerasTab = MxGet.GameScene().GetIGameNodeByType(Autodesk.Max.IGameObject.ObjectTypes.Camera);
    for ( int ix = 0; ix < camerasTab.Count; ++ix ) { }
    var meshes = MxGet.GameScene().GetIGameNodeByType(Autodesk.Max.IGameObject.ObjectTypes.Mesh);
    for ( int ix = 0; ix < meshes.Count; ++ix ) { }
    var lightNodes = MxGet.GameScene().GetIGameNodeByType(Autodesk.Max.IGameObject.ObjectTypes.Light);
    for ( var i = 0; i < lightNodes.Count; ++i ) { }

    var meshes = MxGet.MaxScene.NodesListBySuperClasses(new[] { SuperClassID.GeometricObject, SuperClassID.Helper });
    foreach ( var meshNode in meshes ) { }
    foreach ( var lightNode in MxGet.MaxScene.NodesListBySuperClasses(SuperClassID.Light) )
        firstNode.ObjectRef != null && firstNode.ObjectRef.Eval(0).Obj.SuperClassID == SClass_ID.Camera
        firstNode.ObjectRef != null && firstNode.ObjectRef.Eval(0).Obj.SuperClassID == SClass_ID.Light

    //Autodesk.Max.IPolyObject
    //int c = (int)Autodesk.Max.IGameObject.ObjectTypes.Camera;
    //int m = (int)Autodesk.Max.IGameObject.ObjectTypes.Mesh;
    //var id = _camera.GetGuid().ToString();
    return MxGet.Interface.CurEditObject;
}*/




/*
http://docs.autodesk.com/3DSMAX/16/ENU/3ds-Max-SDK-Programmer-Guide/index.html?url=files/GUID-C59F7DCE-8B96-4A49-A4E0-053EA2424A0D.htm,topicNumber=d30e11958
 GEOMOBJECT_CLASS_ID =  0x000010

     */


//not used not tested
/*private Autodesk.Max.INodeTab GetNodeInstances(IINode node) {

    IObject obj = node.ObjectRef;
    Autodesk.Max.INodeTab instanceAndRef = MxGet.Global.NodeTab.Create();
    Autodesk.Max.INodeTab result = MxGet.Global.NodeTab.Create();

    MxGet.Global.IInstanceMgr.InstanceMgr.GetInstances(node, instanceAndRef);

    IntPtr indexer;

    for ( int i = 0; i < instanceAndRef.Count; i++ ) {
        indexer = new IntPtr(i);

        if ( obj.Handle == instanceAndRef[indexer].ObjectRef.Handle ) {
            result.InsertNode(instanceAndRef[indexer], result.Count, true);
        }

        Marshal.FreeHGlobal(indexer);
    }
    return result;
}*/


/*internal static String GetNodeName(uint handle) {

//MxGet.Interface.SelectNode(node);
IINode theNode = MxGet.Interface.GetINodeByHandle(handle);
return theNode.Name;
}*/


//http://help.autodesk.com/view/3DSMAX/2018/ENU/?guid=__cpp_ref_class_max_s_d_k_1_1_geom_bind_1_1_i_mesh_html
/*internal static bool IsSpline(IINode obj) {
    obj is SplineShape
}*/

/*
 static private ITriObject GetTriObjectFromNode(IINode node)
        {
            IObject obj = node.EvalWorldState(0, true).Obj;
            IClass_ID myClass = global.Class_ID.Create(9, 0);

            if (obj.CanConvertToType(myClass) == 1)
            {
                ITriObject tri = (ITriObject)obj.ConvertToType(0, myClass);
                return tri;
            }
            else
            {
                return null;
            }
        }
             */



/// This method is used to build a mesh with the data contained in the class. 
/// It will ususally will be called when the object is rebuilt during deserialization ///
/// got guidance from here : http://eliang.blogspot.com/2011/10/creating-triangle-mesh-with-3ds-max-sdk.html        
/*private ITriObject BuildMesh(bool build_normals = true, bool build_maps = true) {          // Make a new TriObject class         
    ITriObject triobj = Kernel.Global.TriObject.Create();         // bail if null         
    if ( triobj == null ) return null;          // grab the IMesh instance in the TriObject         
    IMesh mesh = triobj.Mesh;         // bail if null         if (triobj == null)                 
    return null;
    int numVertices = this.Verts.Count;
    int numTriangles = this.Faces.Count;
    int numNormals = this.Normals.Count;
    int numMaps = this.Maps.Count;          // set vertex array size in the mesh         
    mesh.SetNumVerts(numVertices, false, true);         // set triangle array size in the mesh         
    mesh.SetNumFaces(numTriangles, false, true);          // Loop and set vertex positions         
    for ( int i = 0; i < numVertices; i++ )
        mesh.SetVert(i, this.Verts[i].Position.ToIPoint3());          // Loop and set the basic face data         
    for ( int i = 0, j = 0; i < numTriangles; i++, j += 3 ) {
        int v0 = (int)this.Faces[i].Verts[0];
        int v1 = (int)this.Faces[i].Verts[1];
        int v2 = (int)this.Faces[i].Verts[2];                  // vertex positions                 
        IFace face = mesh.Faces[i];
        face.MatID = 1;
        face.SetEdgeVisFlags(this.Faces[i].EdgeVis[0], this.Faces[i].EdgeVis[1], this.Faces[i].EdgeVis[2]);
        face.SetVerts(v0, v1, v2);                  // set the fac smoothing group if there was one set.                
        if ( this.Faces[i].SmoothingGroup != -1 ) {
            face.SmGroup = (uint)this.Faces[i].SmoothingGroup;
        }
    }          // build uv information using the maps of the mesh         
    if ( build_maps == true ) {                 // initialize the map array to the needed size                
        mesh.SetNumMaps(numMaps, false);                  // start at 1 as zero is Vert color.. i think.                 
        for ( int m = 1; m < numMaps; m++ ) {                         // enable map support                         
            mesh.SetMapSupport(m, true);  // enable map channel                          // get the current IMeshMap iteration                         
            IMeshMap map = mesh.Maps[m];                          // set num of verts to the vert count of the map List<>                         
            int numMapVerts = this.Maps[m].TVerts.Count;
            mesh.SetNumMapVerts(m, numMapVerts, false);
            for ( int i = 0; i < numMapVerts; i++ ) {
                mesh.SetMapVert(m, i, ( this.Maps[m].TVerts[i] ).ToIPoint3());
            }                           // set num of verts to the face count of the map List<>                         
            int numMapFaces = this.Maps[m].TFaces.Count;
            mesh.SetNumMapFaces(m, numMapFaces, false, 0);                          // grab the now intitialzed list of faces                         
            IList mapFaces = mesh.MapFaces(m);                          // loop and associate vertecies by the stored indecies.                         
            for ( int i = 0; i < numMapFaces; i++ ) {
                ITVFace tFace = mapFaces[i];
                int v0 = (int)this.Maps[m].TFaces[i].Verts[0];
                int v1 = (int)this.Maps[m].TFaces[i].Verts[1];
                int v2 = (int)this.Maps[m].TFaces[i].Verts[2];
                tFace.SetTVerts(v0, v1, v2);
            }
        }
    }          // build normal information for each vert and face association         
    if ( build_normals == true ) {                 // call this to initialize the normal arrays                 
        mesh.BuildNormals();                  // tell the mesh we will be specifying normals                 
        mesh.SpecifyNormals();                  // class to aid normal updating                 
        IMeshNormalSpec normalSpec = mesh.SpecifiedNormals;                                  // clear any pre calculated normals                 
        normalSpec.ClearNormals();                  // set the normal vertex array size                 
        normalSpec.SetNumNormals(numVertices);                  // loop and set vertex normals                 
        for ( int i = 0; i < numVertices; i++ ) {
            IPoint3 ip3 = ( this.Normals[i].Direction.ToIPoint3() ).Normalize;
            normalSpec.NormalArray.Set(ip3.X, ip3.Y, ip3.Z);
            normalSpec.SetNormalExplicit(i, false);
        }                  // set normal face array size                 
        normalSpec.SetNumFaces(numTriangles);
        for ( int i = 0, j = 0; i < numTriangles; i++, j += 3 ) {
            int v0 = (int)this.Faces[i].Verts[0];
            int v1 = (int)this.Faces[i].Verts[1];
            int v2 = (int)this.Faces[i].Verts[2];                          // vertex positions                         
            IFace face = mesh.Faces[i];                          // vertex normals                         
            IMeshNormalFace normalFace = normalSpec.Face(i);
            normalSpec.SetNormal(i, v0, ( this.Normals[v0].Direction.ToIPoint3() ).Normalize);
            normalSpec.SetNormal(i, v1, ( this.Normals[v1].Direction.ToIPoint3() ).Normalize);
            normalSpec.SetNormal(i, v2, ( this.Normals[v2].Direction.ToIPoint3() ).Normalize);
            normalFace.SpecifyAll(true);
            //normalFace.SetNormalID(0, v0);                         
            //normalFace.SetNormalID(1, v1);                         
            //normalFace.SetNormalID(2, v2);                         
            normalFace.SetSpecified(0, true);
            normalFace.SetSpecified(1, true);
            normalFace.SetSpecified(2, true);
        }
    }          // tell the mesh to rebuild its internal cache's... like a recompute.         
    mesh.InvalidateGeomCache();
    mesh.InvalidateTopologyCache();
    return triobj;
}*/


///Function that populates necassary mesh data to this class, from scene data. Called before serialization. 
///
///The IINode, containing the mesh, to be serialized 
/*public void Populate(IINode node) {         // make sure the node is valid         
    if ( node == null ) return;          // get the object ref as a tri object         
    ITriObject triObj = MxsSharp.MeshOps.GetITriObject(node);         // bail if we failed to retrieve         
    if ( triObj == null ) return;                  // get the mesh/IMesh from the tri object         
    IMesh mesh = triObj.Mesh;         // bail if we failed to retrieve         
    if ( mesh == null ) return;          // initialize the base data variables          
    this.Verts = new List();
    this.Faces = new List();
    this.Normals = new List();
    this.Name = node.Name;          // serialize the transform        
    this.Transform = new Matrix();
    this.Transform.Populate(node);          // create serialized data for mesh vertex         
    int count = 0;
    foreach ( IPoint3 vPos in mesh.Verts ) {                             // Create custom Vertex class that can be serialized                 
        Vertex vrt = new Vertex();                 // Populate the vertex class with data - cannot do this on itilialize due to serialization                 
        vrt.Populate(vPos);                 // Add to this class' Verts list                 
        this.Verts.Add(vrt);
        count++;
    }          // create serialized data for mesh faces         
    foreach ( IFace iface in mesh.Faces ) {                 // Create custom Face class that can be serialized                 
        Face face = new Face();                 // Populate the Face class with data - cannot do this on itilialize due to serialization                 
        face.Populate(iface);                 // Add to this class' Faces list                 
        this.Faces.Add(face);
    }          // Serialize any map channels the mesh may have.. uvs and such         
    if ( mesh.NumMaps > 0 ) {
        this.Maps = new List();
        for ( int mi = 0; mi < mesh.NumMaps; mi++ ) {                         // Create custom MeshMap class that can be serialized                         
            MeshMap map = new MeshMap();                         // Populate the MeshMap class with data - cannot do this on itilialize due to serialization                         
            map.Populate(mesh, mi);                         // Add to this class' Maps list                         
            this.Maps.Add(map);
        }
    }          // build / check normals before we serialize them. otherwise we may not have any normals.         
    mesh.BuildNormals(); mesh.BuildRenderNormals();                  // create serialized data for mesh normals         
    for ( int i = 0; i < mesh.NormalCount; i++ ) {                     // Create custom Normal class that can be serialized                             
        IPoint3 inml = mesh.GetNormal(i);
        Normal normal = new Normal();                 // Populate the Normal class with data - cannot do this on itilialize due to serialization                 
        normal.Populate(inml);                 // Add to this class' Normals list                 
        this.Normals.Add(normal);
    }
    mesh.DisplayNormals(1, 3.0f);
}*/


/*public static String GetTriMeshFromNode(uint handle) {
    int t = 0;
    IGlobal Global = Autodesk.Max.GlobalInterface.Instance;
    IINode node = Global.COREInterface13.GetINodeByHandle(handle);

    IObject obj = node.EvalWorldState(0, true).Obj;

    if ( node.ObjectRef.SuperClassID != SClass_ID.Geomobject ) return ( "SuperClass : " + node.ObjectRef.SuperClassID.ToString() + " not valid" );

    IMesh mesh = obj.ConvertToType(t, IClass_ID ? !? !? !? !?);

    return mesh.GetVert(0).ToString();
}*/

/*internal static List<IINode> getSceneNodesList() {
    // make a list to fill

    List<IINode> nodeList = new List<IINode>();
    // loop from the scene 'Root' node
    for ( int i = 0; i < this._interface.RootNode.NumChildren; i++ ) {
        // call recusrive function and populate list with all nodes
        this.getChildNodesRecurse(this._interface.RootNode.GetChildNode(i), nodeList);
    }

    return nodeList;
}

internal static List<IINode> GetSelectedNodes() {
    // make a list to fill
    List<IINode> selectionList = new List<IINode>();
    // for all the nodes in the scene
    foreach ( IINode node in ( this.getSceneNodesList() ) ) {
        // if it's selected
        if ( node.Selected == true ) {
            // add it to the return list
            selectionList.Add(node);
        }
    }
    return selectionList;
}*/

/*
  public void EnumControl(IControl cntrl)
        {
            
            // print the name of this control
            this.PrintToListener(cntrl.ClassName);

            // make an object type to be passed to the getvalue
            object val = null;

            // make an interval class and set it to forever
            IInterval interval = _global.Interval.Create();
            interval.SetInfinite();

            // A switch/case to test the super class id of the control
            switch (cntrl.SuperClassID)
            {
                case SClass_ID.CtrlInteger:
                    // make a local var of the type this super class requires
                    int _val_Int = 0;

                    // populate var with the type we want as an object.. GetVal rewuires an object.. but initialized to the correct memory type                            
                    val = _val_Int as object;

                    // populates val with the value.                                                             
                    cntrl.GetValue(this._interface.Time, ref val, interval, GetSetMethod.Absolute);

                    // now convert val back to our typed var, so we can use it (var is still an object so wont work as point3 or matrix...ect)
                    _val_Int = (int)val;

                    this.PrintToListener("--> " + _val_Int.ToString());
                    break;
                case SClass_ID.CtrlFloat:
                    // make a local var of the type this super class requires
                    float _val_Flt = 0.0f;

                    // populate var with the type we want as an object.. GetVal rewuires an object.. but initialized to the correct memory type                                                        
                    val = _val_Flt as object;

                    // populates val with the value.                   
                    cntrl.GetValue(this._interface.Time, ref val, interval, GetSetMethod.Absolute);

                    // now convert val back to our typed var, so we can use it (var is still an object so wont work as point3 or matrix...ect)
                    _val_Flt = (float)val;

                    this.PrintToListener("--> " + _val_Flt.ToString());

                    break;
                case SClass_ID.CtrlPoint3:
                    // make a local var of the type this super class requires
                    IPoint3 _val_p3 = this._global.Point3.Create(0.0, 0.0, 0.0);

                    // populate var with the type we want as an object.. GetVal rewuires an object.. but initialized to the correct memory type                                                                                    
                    val = _val_p3 as object;

                    // populates val with the value.                   
                    cntrl.GetValue(this._interface.Time, ref val, interval, GetSetMethod.Absolute);

                    // now convert val back to our typed var, so we can use it (var is still an object so wont work as point3 or matrix...ect)
                    _val_p3 = (IPoint3)val;

                    this.PrintToListener("--> " + _val_p3.ToString());

                    break;
                case SClass_ID.CtrlPosition:

                    // make a local var of the type this super class requires
                    IMatrix3 _val_tm = this._global.Matrix3.Create();

                    // populate var with the type we want as an object.. GetVal rewuires an object.. but initialized to the correct memory type
                    val = _val_tm as object;

                    // populates val with the value.                 
                    cntrl.GetValue(this._interface.Time, ref val, interval, GetSetMethod.Absolute);

                    // now convert val back to our typed var, so we can use it (var is still an object so wont work as point3 or matrix...ect)
                    _val_tm = (IMatrix3)val;

                    // print
                    this.PrintToListener("--> " + _val_tm.Trans.X.ToString() + ", " + _val_tm.Trans.Y.ToString() + ", " + _val_tm.Trans.Z.ToString());

                    break;

                case SClass_ID.CtrlMatrix3:
                    // make a local var of the type this super class requires
                    _val_tm = this._global.Matrix3.Create();

                    // populate var with the type we want as an object.. GetVal rewuires an object.. but initialized to the correct memory type
                    val = _val_tm as object;

                    // populates val with the value.                 
                    cntrl.GetValue(this._interface.Time, ref val, interval, GetSetMethod.Absolute);

                    // now convert val back to our typed var, so we can use it (var is still an object so wont work as point3 or matrix...ect)
                    _val_tm = (IMatrix3)val;

                    // print
                    this.PrintToListener("--> " + _val_tm.Trans.X.ToString() + ", " + _val_tm.Trans.Y.ToString() + ", " + _val_tm.Trans.Z.ToString());

                    break;
                case SClass_ID.CtrlQuat:
                    // make a local var of the type this super class requires
                    IQuat _val_q = this._global.Quat.Create();

                    // populate var with the type we want as an object.. GetVal rewuires an object.. but initialized to the correct memory type
                    val = _val_q as object;

                    // populates val with the value.                 
                    cntrl.GetValue(this._interface.Time, ref val, interval, GetSetMethod.Absolute);

                    // now convert val back to our typed var, so we can use it (var is still an object so wont work as point3 or matrix...ect)
                    _val_q = (IQuat)val;

                    IntPtr x = new IntPtr(), y = new IntPtr(), z = new IntPtr();
                    _val_q.GetEuler(x, y, z);

                    

                    // now convert val back to our typed var, so we can use it (var is still an object so wont work as point3 or matrix...ect)
                    this.PrintToListener("--> [" + _val_q.Vector.X.ToString() + ", " + _val_q.Vector.Y.ToString() + ", " + _val_q.Vector.Z.ToString() + "]");

                    break;
                case SClass_ID.CtrlRotation:
                    // make a local var of the type this super class requires
                    _val_q = this._global.Quat.Create();

                    // populate var with the type we want as an object.. GetVal rewuires an object.. but initialized to the correct memory type
                    val = _val_q as object;

                    // populates val with the value.                 
                    cntrl.GetValue(this._interface.Time, ref val, interval, GetSetMethod.Absolute);

                    // now convert val back to our typed var, so we can use it (var is still an object so wont work as point3 or matrix...ect)
                    _val_q = (IQuat)val;

                    // now convert val back to our typed var, so we can use it (var is still an object so wont work as point3 or matrix...ect)
                    this.PrintToListener("--> [" + _val_q.Vector.X.ToString() + ", " + _val_q.Vector.Y.ToString() + ", " + _val_q.Vector.Z.ToString() + "]");

                    break;
                case SClass_ID.CtrlScale:
                    // make a local var of the type this super class requires
                    IScaleValue _val_sv = this._global.ScaleValue.Create();

                    // populate var with the type we want as an object.. GetVal rewuires an object.. but initialized to the correct memory type
                    val = _val_sv as object;

                    // populates val with the value.                 
                    cntrl.GetValue(this._interface.Time, ref val, interval, GetSetMethod.Absolute);

                    // now convert val back to our typed var, so we can use it (var is still an object so wont work as point3 or matrix...ect)
                    _val_sv = (IScaleValue)val;

                    // now convert val back to our typed var, so we can use it (var is still an object so wont work as point3 or matrix...ect)
                    this.PrintToListener("--> " + _val_sv.S.ToString());

                    break;
                default:
                    //default stuff
                    break;
            }

            // now loop any child sub anims, convert to control and recurse
            int numsubs = cntrl.NumSubs;
            for (int i = 0; i < numsubs; ++i)
            {
                IAnimatable anim = cntrl.SubAnim(i);
                if (anim == null)
                    continue;
                
                IControl subcntrl = (IControl)anim.GetInterface(InterfaceID.Control); // do we have a control (theres no single superclass id for controls)

                if (subcntrl != null)
                {

                    this.EnumControl(subcntrl);
                }
            }
        }
*/
