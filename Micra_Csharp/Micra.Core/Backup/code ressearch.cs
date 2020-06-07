

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