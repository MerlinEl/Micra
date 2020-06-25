/// <summary>
/// Returns the polycount of an IINode.
/// </summary>
public static Int32 GetPolyCount(IINode node) {
    int time = MaxInterfaces.COREInterface.Time;
    IObjectWrapper objWrapperX = MaxInterfaces.Global.ObjectWrapper.Create();
    objWrapperX.Init(time, node.EvalWorldState(time, true), false, enable, nativeType);

    int xNumFaces = objWrapperX.NumFaces;
    objWrapperX.Release();
    return xNumFaces;
}



BitArray* IMXSExposure::GetMeshMapSeams(const Mesh* mesh, int mapChannel) const {
    if (!mesh || !mesh->mapSupport(mapChannel))
        return nullptr; // translates to 'undefined' in MAXScript
 
    MNMesh poly(*mesh); // dereferencing the pointer
Mesh meshCopy(*mesh);
 
    if (!poly.nume)
        return nullptr; // without edges, there are no seams
 
    poly.ClearEFlags(MN_SEL);
    poly.SetMapSeamFlags(mapChannel);
    poly.PropegateComponentFlags(MNM_SL_EDGE, MN_SEL, MNM_SL_EDGE, MN_EDGE_MAP_SEAM);
    poly.OutToTri(meshCopy);

    if (mesh->numFaces != meshCopy.numFaces)
        return nullptr; // topology changed when converting to poly
    
    return new BitArray(meshCopy.edgeSel);
}

//Deselects the hidden edges in the mesh.This method is not applicable to TriMeshes.
obj = convertToMesh(Sphere()) -- Create a Sphere, turn to EMesh
obj.allEdges = true -- Show all edges
select obj -- Select the mesh
max modify mode -- Switch to Modify panel
subObjectLevel = 2-- Set Sub-Object level to Edge
edgeSelSet=#() -- Init. an Array
for face = 1 to obj.numfaces do -- Go through all faces
for edge = 1 to 3 do -- And for every of the 3 edges
if (getedgevis obj face edge) do -- If the visibility is true,
append edgeSelSet(((face-1)*3)+edge) --collect the edge
setedgeselection obj edgeSelSet -- Select all visible edges



            //_IMesh.EdgeSel
            //_IMesh.AngleBetweenFaces
            //m.EdgeSel
            //IEdge edge
            //Point3.Distance( _mesh.ed ei.V
/*IInterface_ID iMeshSelectionID = Kernel._Global.Interface_ID.Create( //not used not tested
    (uint)BuiltInClassIDA.MESHSELECT_CLASS_ID,
    0
);
IMeshSelection _IMeshSelection = (IMeshSelection)Kernel._Global.GetCOREInterface(iMeshSelectionID); //not used not tested*/
//Autodesk.Max.IAdjEdgeList
// Autodesk.Max.IFaceElementList
// _IMesh.MakeEdgeList
//_IMesh.BuildVisEdgeList()
//IEdge edge = _IMesh.E(edgeIndex);
//return VertPos(edge.V[0]).DistanceTo(VertPos(edge.V[1]));


In .NET: UIntPtr myHandle = global.Animatable.GetHandleByAnim(myMaterial or anything else );
In MXS: myMaterial = GetAnimByHandle myHandle

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



    void MeshObj::CreateVertexList(S3DVertex* outverts, material_info& m) {
    int index = 0;
    int matid_counter = 0;
    FaceEx* f;
    TVFace mapface;

    for ( int i = 0; i < number_of_faces; i++ ) {
        // for all faces of material matid

        f = mesh->GetFace(i);
        if ( f->matID == m.id ) {
            index = 3 * matid_counter;
            mesh->GetMapFaceIndex(MAPCHANNEL_2, i, mapface.t);

            for ( int j = 0; j < 3; j++ ) {
                int tbIndex = mesh->GetFaceVertexTangentBinormal(i, j);
                m.bbox += mesh->GetVertex(f->vert[j], true); // expand the bounding box
                outverts[index].pos = vector3d(mesh->GetVertex(f->vert[j], true));
                outverts[index].normal = vector3d(mesh->GetNormal(f->norm[j], true));
                outverts[index].tangent = vector3d(tm.VectorTransform(mesh->GetTangent(tbIndex)));
                outverts[index].binormal = vector3d(tm.VectorTransform(mesh->GetBinormal(tbIndex)));
                Point3 vcolour;
                if ( mesh->GetColorVertex(f->color[j], vcolour) )
                    outverts[index].color = SColor(vcolour);
                else // set the vertex colour to white
                    outverts[index].color = SColor(255, 255, 255, 255);
                float alpha;
                if ( mesh->GetAlphaVertex(f->alpha[j], alpha) )
                    outverts[index].color.setAlpha(alpha);
                outverts[index].tcoord1 = vector2d(mesh->GetTexVertex(f->texCoord[j]));
                outverts[index].tcoord2 = vector2d(mesh->GetMapVertex(MAPCHANNEL_2, mapface.t[j]));
                outverts[index].vertindex = f->vert[j];
                index++;
            }
            matid_counter++;
        }
    }
}


//Prepare object
IINode node = global.COREInterface.GetINodeByHandle(handle);
IObjectState os = node.EvalWorldState(0, true);
IObjectWrapper ow = global.ObjectWrapper.Create();
ow.Init(0, os, false, 0, 0)



FieldInfo[] fields1 = typeof(Primitives).GetFields(BindingFlags.Static | BindingFlags.Public);
            foreach (FieldInfo f1 in fields1 ) {
                Max.Log("\tparam:{0} val:{1}", f1.Name, f1.GetValue(Primitives.Bend).ToString());
 
            }

//TODO -not tested -not used
// Get All roperties from a class
// Utility.GetPropertiesNameOfClass(typeof(Primitives)).ForEach(n => Max.Log("\t{0}", n));
public static List<string> GetPropertiesNameOfClass(Type type) {
    List<string> propertyList = new List<string>();
    if ( type != null ) {
        foreach ( var prop in type.GetType().GetProperties() ) {
            propertyList.Add(prop.Name);
        }
    }
    return propertyList;
}
//TODO -not tested -not used
//Utility.GetTypePropertyNames(typeof(Primitives), BindingFlags.Public | BindingFlags.Static)
public static List<string> GetTypePropertyNames(Type type, BindingFlags bindingFlags) {
    var propertyInfos = type.GetProperties(bindingFlags);
    return propertyInfos.Select(propertyInfo => propertyInfo.Name).ToList();
}

public static List<string> GetClassPublicNames(Type type) {

    FieldInfo[] fields = type.GetFields(BindingFlags.Static | BindingFlags.Public);
    List<string> propertyList = new List<string>();
    foreach ( FieldInfo fi in fields ) {
        propertyList.Add(fi.Name);
    }
    return propertyList;
}


IObjectState iState = i.EvalWorldState(0, true);
IObject iObj = iState.Obj;
IPolyObject iPoly = (IPolyObject)iObj.ConvertToType(0, global.PolyObjectClassID);
ITriObject iTri = (ITriObject)iObj.ConvertToType(0, global.TriObjectClassID);
IMesh mesh = iTri.Mesh;


// Name it and ensure it is unique...
string newname = "ADN-Sample-Face";
Kernel._Intrerface.MakeNameUnique(ref newname);
node.Name = newname;

void DemoTeapot() {
    IGlobal global = Autodesk.Max.GlobalInterface.Instance;  //note that global will be an instance of an abstract class.
    var intfc = global.COREInterface13;
    IClass_ID cid = global.Class_ID.Create((uint)BuiltInClassIDA.TEAPOT_CLASS_ID, (uint)BuiltInClassIDB.TEAPOT_CLASS_ID);
    object obj = intfc.CreateInstance(SClass_ID.Geomobject, cid as IClass_ID);
    if ( obj == null ) throw new Exception("Failed to create a sphere!");
    IINode n = global.COREInterface.CreateObjectNode((IObject)obj);
    IObject iobj = (IObject)obj;
    IIParamArray ps = iobj.ParamBlock;
    ps.SetValue(0, global.COREInterface.Time, 20.0f);
    n.Move(global.COREInterface.Time, global.Matrix3.Create(), global.Point3.Create(20, 20, 0), true, true, 0, true);
}


public double GtiTrifaceArea(int faceIndex) {

    IMesh imesh = Kernel._Global.Mesh.Create();
    IMNFace face = _IMNMesh.F(faceIndex);
    ITab<int> tris = Kernel._Global.Tab.Create<int>();
    face.GetTriangles(tris);

    Max.Log("face:{0} tris:{1}", faceIndex, tris.Count);
    for ( int i = 0; i < tris.Count; i++ ) Max.Log("\ttris:{0}", i);
    double area = 0.0;
    int numtriangles = face.Deg - 2;
    int j = tris.Count - 1;
    for ( int t = 0; t < numtriangles; ++t ) { //TODO ensure to get right vertex idex
        int i = t * 3;
        //Max.Log("\tv:{0} v2:{1} v3:{2}", face.Vtx[t]+1, face.Vtx[t] + 2, face.Vtx[t] + 3);
        Max.Log("\ti:{0} v:{1} v2:{2} v3:{3}", i, face.Vtx[i] + 1, face.Vtx[i + 1] + 1, face.Vtx[t + 2] + 1);
        //Max.Log("\tv:{0} p:{1}", face.Vtx[t]+1, face.VertIndex(face.Vtx[t], j));
        /*area += Utility.GetTriangleArea(

            new Point3(_IMNMesh.V(tris[i]  ).P),
            new Point3(_IMNMesh.V(tris[i+1]).P),
            new Point3(_IMNMesh.V(tris[i+2]).P)
        );*/
        j = t;
    }
    Max.Log("face{0} tris count:{1} vtx count:{2} area:{3}", faceIndex, face.TriNum, face.Vtx.Count, area);
    //face.

    /* _IMNMesh.OutToTri(imesh);
     Max.Log("imesh\n\tsel faces:{0}", imesh.FaceSel.Size);
     Max.Log("\t all faces:{0}", imesh.NumFaces);
     imesh.FaceSel.ToEnumerable().ForEach((item, index) => {

         Max.Log("\t\tface:{0} selected{1}", index, item);
     });*/
    return area;
}


/*for ( int fID = 0; fID < _IMesh.NumFaces; fID++ ) {

IBitArray eleBits = Kernel._Global.BitArray.Create(_IMesh.NumFaces);
IFace f = _IMesh.Faces[fID];
if ( f.GetFlag(Convert.ToUInt32(allPolys[0])) ) {
getBits.Set(fID);
}
}
_IMesh.FaceSelect(getBits);*/
//mesh.FaceSelect(eleBits);
/*_IMesh.s
_IMesh.FaceSel.IEnumerable().ForEach((item, index) => {

    if ( item == 1 ) fsel.Add(index); //+3DsMax count + 1
});
*/
/*for ( int i = 0; i < ba.Size; i++ ) {

    if ( faceIndexes.IndexOf(i) != -1 ) ba.Set(i); //set bit as selected
}*/


/*for ( int fID = 0; fID < _IMNMesh.Numf; fID++ ) {

    IBitArray getBits = Kernel._Global.BitArray.Create(_IMNMesh.Numf);
    IMNFace f = _IMNMesh.F(fID);
    if ( f.GetFlag(Convert.ToUInt32(allPolys[0])) ) {
        getBits.Set(fID);
    }
    _IMNMesh.FaceSelect(getBits);
}*/
//ba.
//
//faceIndexes.SelectMany<int, byte>(BitConverter.GetBytes).ToArray()

polyOp.getVertSelection $ as array
fn getFacePolyTable obj =
(
    local index = 0
	local polyByFace = #()
	format "obj:%\n" obj.name
	for poly = 1 to polyop.getNumFaces obj do

    (
        local numTris = polyop.getFaceDeg obj poly - 2

        format "\tpoly:% tris:%\n" poly numTris
		for face = index + 1 to index + numTris do (
            polyByFace[face] = poly

            format "\t\tface:%\n" face

         )

        index += numTris
	)
	return polyByFace
)
getFacePolyTable $



private Poly mesh2poly_csg(IMesh dag) {

    Point3[] pts = new Point3[] { };
    MIntArray tris = new MIntArray();
    MFnMesh mesh = new MFnMesh(dag);
    mesh.getPoints(pts, MSpace.kWorld);
    MIntArray tcounts = new MIntArray();
    mesh.getTriangles(tcounts, tris);

    List<Vert> v = new List<Vert>();
    for ( uint i = 0; i < pts.length(); i++ ) {
        v.Add(Vert(carve.geom.VECTOR(pts[i].x, pts[i].y, pts[i].z)));
    }

    List<Face> faces = new List<Face>();
    for ( uint i = 0; i < tris.length() / 3; i++ ) {
        faces.Add(Ngon(v[tris[3 * i]], v[tris[3 * i + 1]], v[tris[3 * i + 2]]));
    }

    return new Poly(faces);
}

private Mesh poly_csg2mesh(IMNMesh poly) {
    List<Point3> pts = new List<Point3>() { };
    List<int> tris = new List<int>() { };
    List<int> polyCounts = new List<int>() { };

    for ( int i = 0; i < poly.Numv; i++ ) {

        IMNVert v = poly.V(i);
        pts.Add(new Point3(v.P[0], v.P[1], v.P[2]));
    }

    for ( int i = 0, l = poly.Numf; i != l; i++ ) {

        IMNFace f = poly.F(i);
        for ( int j = 0; j < f.Vtx.Count; j++ ) {

            tris.Add(f.Vtx[j]);
        }
        polyCounts.Add(f.Vtx.Count);
    }

    //create Triobject Class
    IClass_ID cid = Kernel._Global.Class_ID.Create((uint)BuiltInClassIDA.TRIOBJ_CLASS_ID, 0);
    // Create a new mesh object for each new face.
    object objectNewFace = Kernel._Interface.CreateInstance(SClass_ID.Geomobject, cid);
    // Create a new node to hold it in the scene.
    IObject objNewFace = (IObject)objectNewFace;
    IINode n = Kernel._Interface.CreateObjectNode(objNewFace);
    n.CenterPivot(0, false);
    n.Name = "MeshObj_001";
    // Based on what we created above, we can safely cast it to TriObject
    IMesh mesh = objNewFace as IMesh;
    mesh.SetNumVerts(pts.Count, false, false);
    mesh.SetNumFaces(polyCounts.Count, false, false);
    //IFace f = mesh.Faces[0];
    return new Mesh(mesh);
}


IMesh m = Global.Mesh;
IMNMesh mn = Global.MNMesh;
mn.OutToTri(m);
mn.SetFromTri(m);


IFPValue IFPvar1 = GlobalInterface.Instance.FPValue.Create();
IFPvar1.FpvTab;

(
    local compilerParams = dotNetObject "System.CodeDom.Compiler.CompilerParameters" #(
		"System.dll", "System.Core.dll", getDir #maxRoot + "Autodesk.Max.dll",
		getDir #maxRoot + "\bin\assemblies\Autodesk.Max.Wrappers.dll")
	compilerParams.GenerateInMemory = on

    local compilerResults = (dotNetObject "Microsoft.CSharp.CSharpCodeProvider").CompileAssemblyFromSource compilerParams #(
		"using System;
		using System.Linq;
		using System.Collections.Generic;
		using Autodesk.Max;
		using Autodesk.Max.Wrappers;
 
		internal static class TabExtensions {
    public static IEnumerable<T> ToEnumerable<T>(this ITab<T> tab) {
        for ( int i = 0; i < tab.Count; i++ )
            yield return tab[i];
    }
}

fn AreaOfUVPolyFace pobj mapc face =
(
    mverts = polyop.getmapface pobj mapc face;
uvs = for v in mverts collect  polyop.getmapvert pobj mapc v;

a = 0.0;
	for v = 1 to uvs.count do
	(
        nv = v + 1;
		if v == uvs.count then nv = 1;
			
		a = a + uvs[v].x* uvs[nv].y;
		a = a - uvs[v].y* uvs[nv].x;
	)
	a* 0.5;
)	

fn buildpoly =
(
    verts = #([0.25,0.0,0],[0.75,0.0,0],[0.5,0.5,0],[0.75,1.0,0],[0.25,1.0,0],[0.0,0.5,0]);
	faces = #([1,2,3],[1,3,6],[3,4,5],[3,5,6]);
	edges = #(#(true,true,false),#(false,false,true),#(true,true,false),#(false,true,false));

	msh = trimesh();
msh.numverts = verts.count;
	msh.numfaces = faces.count;
		
	for v = 1 to verts.count do setvert msh v verts[v];
	for f = 1 to faces.count do 
	(
        setface msh f faces[f];
setedgevis msh f 1 edges[f][1];
		setedgevis msh f 2 edges[f][2];
		setedgevis msh f 3 edges[f][3];
	)	

	mobj = mesh mesh:msh;
	meshop.makeMapPlanar mobj 1;
	converttopoly mobj;
)


pobj = buildpoly();
result = (AreaOfUVPolyFace pobj  1 1) - polyop.getFaceArea pobj 1;


def_struct_primitive(polyop_getUVFaceArea, polyop, "getUVFaceArea");

Value* polyop_getUVFaceArea_cf(Value** arg_list, int count) {

    enum args { kpoly, kmapchannel, kface, knum_of_args };

check_arg_count(getUVFaceArea, knum_of_args, count);
MNMesh* pmesh = get_polyForValue(arg_list[kpoly], MESH_READ_ACCESS, NULL, getUVFaceArea);

int mapchannel = arg_list[kmapchannel]->to_int();
checkMapChannel(pmesh, mapchannel);

int face = arg_list[kface]->to_int() - 1;
range_check(face,0, (pmesh->numf - 1), GetString(IDS_FACE_INDEX_OUT_OF_RANGE));

	MNFace& mnface = pmesh->f[face];

	Tab<int> triangles;
mnface.GetTriangles(triangles);  // get the tri (as indices of the face vert array)

	MNMapFace* mapface = pmesh->MF(mapchannel, face);
Point3* mapverts = pmesh->M(mapchannel)->v;

float area = 0.0f;
int numtriangles = mnface.deg - 2;
	for(int t = 0; t<numtriangles; ++t)
	{
		int i = t * 3;
area += AreaOfTriangle(mapverts[mapface->tv[triangles[i]]], mapverts[mapface->tv[triangles[i + 1]]],
    mapverts[mapface->tv[triangles[i + 2]]]);
	}
	return Float::intern(area);
}

class Poly {
    internal static readonly IGlobal Global = GlobalInterface.Instance;

    public static int[] GetSelectedObjMatIDs() {
        var pIgame = Global.IGameInterface;
        pIgame.InitialiseIGame(true);
        pIgame.SetStaticFrame(0);

        using ( var currNode = Global.COREInterface.GetSelNode(0) )
        using ( var gameNode = pIgame.GetIGameNode(currNode) )
        using ( var gameMesh = Global.IGameMesh.Marshal(( gameNode.IGameObject as Autodesk.Max.Wrappers.IGameObject ).INativeObject__NativePointer) ) {
            return gameMesh.InitializeData ? gameMesh.ActiveMatIDs.ToEnumerable().Select(id => id + 1).ToArray() : new int[0];
        }
    }
}"
	)
	::poly = compilerResults.CompiledAssembly.CreateInstance "Poly"
)
 
if selection.count == 1 and isKindOf $ GeometryClass do Poly.GetSelectedObjMatIDs()




local g = ( dotnetclass "Autodesk.Max.GlobalInterface").Instance
local INode        = g.COREInterface14.GetINodeByHandle obj.inode.handle

local IMesh = ( INode.EvalWorldState 0 true ).Obj.Mesh_
local IAdjFaceList = g.AdjFaceList.Create IMesh(g.AdjEdgeList.Create IMesh)
local IBitArray = g.BitArray.Create IMesh.NumFaces_


public static class IBitArrayExtensions {
    public static IBitArray BitwiseOR(this IBitArray A, IBitArray B) {
        int sizeA = A.Size;
        int sizeB = B.Size;

        if ( sizeA > sizeB ) {
            B.SetSize(sizeA, 1);
        } else {
            A.SetSize(sizeB, 1);
        }

        return B.BitwiseXor(A.BitwiseXor(A.BitwiseAnd(B)));
    }
}

public Object ORBits(IBitArray a, IBitArray b) {
    return a.BitwiseNot.BitwiseAnd(b.BitwiseNot).BitwiseNot;
}



static bool applyOffsetToVerticesEPoly(INode* inNode, Point3 inOffset) {
    static bool success = false;
    bool deleteIt = false;
    bool polyDeleteIt = false;
    Interface* coreInterface = GetCOREInterface();
    PolyObject* polyObject = GetPolyObjectFromNode(inNode, coreInterface->GetTime(), deleteIt);
    if ( polyObject ) {
        ObjectState objectState = inNode->EvalWorldState(coreInterface->GetTime(), true);
        Object* nodeObjectBase = objectState.obj->FindBaseObject();
        EPoly* ePolyInterface = ( EPoly* )( nodeObjectBase->GetInterface(EPOLY_INTERFACE) );
        MNMesh & mesh = polyObject->GetMesh();
        Tab<Point3> deltaTab;
        deltaTab.SetCount(mesh.VNum());
        for ( int index = 0; index < mesh.VNum(); index++ ) {
            deltaTab[index] = inOffset;
        }
        ePolyInterface->ApplyDelta(deltaTab, ePolyInterface, coreInterface->GetTime());
        success = true;
    }
    return success;
}
Kernel._Interface.InvalidateObCache(_BaseObject)
if ( selected ) _BaseObject.ClearSelection(Kernel._Interface.SubObjectLevel); //OK
if (selected) Geometry._IGeomObject.ClearSelection(Kernel._Interface.SubObjectLevel); //OK
IINode iinode = node._IINode;
IObjectState ios = iinode.ObjectRef.Eval(Kernel.Now);
IObject io = ios.Obj;
public static ClassID TriObject = new ClassID(0x0009, 0);
} else if ( ClassID.EditableMesh.Equals(_Object.ClassID) ) {
} else if ( _Node.IsClassOf(ClassID.EditableMesh) ) {  //Object reference not set to an instance of an object

IClass_ID triClass = Kernel._Global.Class_ID.Create(( uint )BuiltInClassIDA.TRIOBJ_CLASS_ID, 0);
IClass_ID polyClass = Kernel._Global.Class_ID.Create(( uint )BuiltInClassIDA.POLYOBJ_CLASS_ID, 0);

/*IBitArray selEdges = node.Object.GetSelectedEdges();
    Mesh mesh = node.GetMesh();
    Kernel.WriteLine("SelectEdgesWithSameLength > Node:{0} selEdges:{1} isEmpty:{2}", node.Name, selEdges.Size, selEdges.IsEmpty);
    if ( selEdges.IsEmpty ) return;
    selEdges.IEnumerable().ForEach(ei => Kernel.WriteLine("ei:{0}", ei));*/

/*Kernel.WriteLine("GetSelectedEdges >_IMesh:{0}", _IMesh); //is not valid Imesh, 
Kernel.WriteLine("\t_IMesh.NumVerts:{0}", _IMesh.NumVerts);
Kernel.WriteLine("\tEdgeSel.IsEmpty:{0}", _IMesh.EdgeSel.IsEmpty);
return _IMesh.EdgeSel;*/

//http://docs.autodesk.com/3DSMAX/16/ENU/3ds-Max-SDK-Programmer-Guide/index.html?url=files/GUID-B2693B67-F56D-4EEB-9FB8-19700D7BAB90.htm,topicNumber=d30e23902
IMesh im = GetImesh(Kernel.Now);
List<string> esel = im.EdgeSel.IEnumerable()
    //.Where(item => item == 1)
    .Select((item, index) => String.Format("selected:{0} index:{1}", item == 1, index / 3))
    .ToList();

esel.ForEach(ei => Kernel.WriteLine("selected esge:{0}", ei));

            //return im.EdgeSel;
            throw new NotImplementedException();
        }
        public List<int> GetSelectedVerts() {
    //IBitArray vsel = Kernel._IMeshSelection.GetSelVertices(node.Object.GetImesh(Kernel.Now));
    //IMesh im = GetImesh(Kernel.Now);
    //return im.VertSel;
    throw new NotImplementedException();



    IMesh im = GetImesh(Kernel.Now);
            List<string> esel = im.EdgeSel.IEnumerable()
                //.Where(item => item == 1)
                .Select((item, index) => String.Format("selected:{0} index:{1}", item == 1, index / 3))
                .ToList();

            esel.ForEach(ei => Kernel.WriteLine("selected esge:{0}", ei));


             IMesh im = GetImesh(Kernel.Now);
            //if not faces are selected, return empty list
            if ( !im.FaceSel.AnyBitSet.Equals(true) ) return new List<int>() { };

            List<int> fsel = new List<int>() { };
            for ( int i = 0; i < im.FaceSel.Size; i++ ) {
                Kernel.WriteLine("selected:{0} bit:{1} index:{2}", im.FaceSel[i] == 1, im.FaceSel[i], i);
                if ( im.FaceSel[i] == 1 ) fsel.Add(i);
            }


    
            //IObject io = node.GetObjectRef();
            if (ClassID.EditablePoly.Equals(io.ClassID) ) {

                Kernel.WriteLine("Is Poly!");
                /*Geometry geo = node.Geometry;
                bool can = geo._IGeomObject.CanConvertToType(ClassID.EditableMesh._IClass_ID) != 0;
                Kernel.WriteLine("Can be converted in to Mesh?{0}", can);*/

                bool can = io.CanConvertToType(ClassID.EditableMesh._IClass_ID) != 0;
Kernel.WriteLine("Can be converted in to Mesh?{0}", can);


                //IMeshSelectData

                //Kernel._Global.IMeshSelect;

                //IMesh im = node.Object.GetImesh(Kernel.Now);
                //IMeshSelection
                //GetMeshSelectInterface //AnimatableInterfaceIDs.h //#define GetMeshSelectInterface(anim) ((IMeshSelect*)(anim)->GetInterface(I_MESHSELECT)) //animtbl.h

                //Autodesk.Max.Wrappers

                //io
                //node._Anim
                //IMeshSelectData msd = Kernel._Global.getme
            }
            /*if ( ClassID.EditableMesh.Equals(io.ClassID) ) {

                Kernel.WriteLine("Is Mesh!");
                IBitArray vsel = Kernel._IMeshSelection.GetSelVertices(node.Object.GetImesh(Kernel.Now));


                Kernel.WriteLine("Selected vertices{0}", vsel.Size);
                //IMeshSelectData msd = Kernel._Global.getme
            }

            var fsel = node.Object.GetSelectedFaces();
            Kernel.WriteLine("selected Faces:{0}", fsel.Count);
            fsel.ForEach(fi => Kernel.WriteLine("selected face:{0}", fi + 1)); //max counting from 1 c# from 0*/


            /*
             Autodesk.Max.IAnimatable, it is easy to ask for the interface. 
             GetMeshSelectDataInterface(anim) ((IMeshSelectData*)anim->GetInterface(I_MESHSELECTDATA)) 
             A plug-in developer may use this macro as follows: Autodesk.Max.IIMeshSelectData; 
             This return value will either be NULL or a pointer to a valid Autodesk.Max.IMesh Select Data interface.
             * */


            /*if ( obj->ClassID() == EPOLYOBJ_CLASS_ID ) {
                IMeshSelectData* msd = GetMeshSelectDataInterface(obj);
                if ( msd ) {
                    GenericNamedSelSetList ss = msd->GetNamedFaceSelList();
                    //ss.names
                    //ss.sets
                    //ss.ids
                }
            }*/



            //im.InvalidateGeomCache();
            //im.Init();

            /*List<string> fsel = im.FaceSel.IEnumerable()
                //.Where(item => item == 1)
                .Select((item, index) => String.Format("selected:{0} index:{1}", item == 1, index)) //get IFace
                .ToList();

            */

            // 