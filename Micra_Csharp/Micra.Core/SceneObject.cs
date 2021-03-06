//
// Copyright 2012 Autodesk, Inc.  All rights reserved.
//
// Use of this software is subject to the terms of the Autodesk license
// agreement provided at the time of installation or download, or which
// otherwise accompanies this software in either electronic or hard copy form.  
//
using Autodesk.Max;
using Micra.Core.Enums;
using Micra.Core.Prim;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection.Metadata;
//http://docs.autodesk.com/3DSMAX/16/ENU/3ds-Max-SDK-Programmer-Guide/index.html?url=files/GUID-B2693B67-F56D-4EEB-9FB8-19700D7BAB90.htm,topicNumber=d30e23902
namespace Micra.Core {
    /// <summary>
    /// Represents an element of a scene. Wraps the BaseObject type in the 3ds Max SDK. 
    /// </summary>
    public class SceneElement:ReferenceTarget {
        public IBaseObject _BaseObject => _Anim as IBaseObject;

        internal SceneElement(IBaseObject x) : base(x) {
            if ( parameterBlock == null ) {
                IIParamArray pa = _BaseObject.ParamBlock;
                if ( pa != null )
                    parameterBlock = CreateWrapper<ParameterBlock1>(pa.ParamBlock);
            }
        }

        public IEnumerable<Node> Nodes => from x in Observers where x is Node select x as Node;

        public bool Instanced => Nodes.Count() > 1;

        public string Name => _BaseObject.ObjectName;
    }

    /// <summary>
    /// Represents an object that can flow through the geometry pipeline. Wraps the Object type 
    /// in the Max SDK. Associated with a Node. 
    /// </summary>
    public class SceneObject:SceneElement {
        internal SceneObject(IObject x) : base(x) { }

        #region INTERNAL TYPES

        /// <summary>
        /// Returns the corresponding wrapped object from the Autodesk.Max layer. 
        /// This is only used if the APIs of Autodesk.Max layer are required.
        /// </summary>
        internal IObject _Object => _Anim as IObject;
        /// <summary> Returns <see cref="Autodesk.Max.IGeomObject"/></summary>
        internal IGeomObject _IGeomObject => _Anim as IGeomObject;  //test
        /// <summary>
        /// <br>When an object is created, it should be manually associated with a single node.</br>
        /// <br>This is only for convenience. An object is not guaranteed to have a node.</br>
        /// <example><code>
        /// Example: <see cref="PrimObjectFactory.Create"/>
        /// </code></example>
        /// </summary>
        internal Node _Node { get; set; } //get parent Node if is assinged

        #endregion


        #region PUBLIC TYPES

        public Node GetNode() => _Node; //for test

        public Mesh Mesh => GetMesh(Kernel.Now);
        //public Geometry Geometry => CreateWrapper<Geometry>(_Anim); //TODO test this if need

        public SceneObject Base {
            get {
                SceneObject r = this;
                while ( r._Object is IIDerivedObject ) {
                    IIDerivedObject ido = r._Object as IIDerivedObject;
                    // Should never happen, but we have good reason to be paranoid. 
                    if ( ido.ObjRef == null )
                        return r;
                    r = Animatable.CreateWrapper<SceneObject>(ido.ObjRef);
                }
                return r;
            }
        }

        #endregion

        #region MESH OBJECT

        public ITriObject GetITriobject() => GetITriobject(Kernel.Now);
        public ITriObject GetITriobject(TimeValue t) { //Autodesk.Max.Wrappers.TriObject

            //Max.Log("GetITriobject > from _Object:{0}", _Object);
            IClass_ID triClass = ClassID.TriObject._IClass_ID;
            if ( _Object.CanConvertToType(triClass) == 0 ) return null;
            return _Object.ConvertToType(t, triClass) as ITriObject;
        }

        public IMesh GetImesh() => GetITriobject(Kernel.Now).Mesh;

        public IMesh GetImesh(TimeValue t) => GetITriobject(t).Mesh;

        public Mesh GetMesh() => GetMesh(Kernel.Now);
        public Mesh GetMesh(TimeValue t) {

            ITriObject tri = GetITriobject(t);
            if ( tri == null ) return null;
            Mesh r = new Mesh(tri.Mesh);
            if ( tri.GetType().TypeHandle.Value != _Object.GetType().TypeHandle.Value ) {
                //if ( tri.Handle != _Object.Handle ) { //replaced with .GetType().TypeHandle 
                RefResult rr = tri.MaybeAutoDelete();
                if ( rr == RefResult.Fail )
                    throw new Exception("Failed to autodelete the tri-object");

            }
            return r;
        }

        #endregion

        #region POLY OBJECT TEST

        public IPolyObject GetIpolyObject(TimeValue t) { //Autodesk.Max.Wrappers.PolyObject

            //Max.Log("GetIpolyObject > from _Object:{0}", _Object);
            IClass_ID polyClass = ClassID.PolyObject._IClass_ID;
            if ( _Object.CanConvertToType(polyClass) == 0 ) return null;
            return _Object.ConvertToType(t, polyClass) as IPolyObject;
        }

        public IMNMesh GetIpoly() => GetIpolyObject(Kernel.Now).Mesh;
        public IMNMesh GetIpoly(TimeValue t) => GetIpolyObject(t).Mesh;
        public Poly GetPoly() => GetPoly(Kernel.Now);
        public Poly GetPoly(TimeValue t) {

            IPolyObject pol = GetIpolyObject(t);
            if ( pol == null ) return null;
            Poly r = new Poly(pol.Mesh);

            if ( pol.GetType().TypeHandle.Value != _Object.GetType().TypeHandle.Value ) {
                //if (pol.Handle != _Object.Handle) { //replaced with .GetType().TypeHandle 
                RefResult rr = pol.MaybeAutoDelete();
                if ( rr == RefResult.Fail )
                    throw new Exception("Failed to autodelete the poly-object");
            }
            return r;
        }

        #endregion

        public string ClassOf() => ClassID.GetClassName(ClassID);
        public string SuperClassOf() => SuperClassID.GetClassName(SuperClassID);
        public bool IsClassOf(ClassID id) => ClassID.PartA == id.PartA && ClassID.PartB == id.PartB;
        public bool IsSuperClassOf(SuperClassID id) => SuperClassID == id;
        public void AddModifier(Modifier m) => _Node?.AddModifier(m);


        public void Move(Point3 p) => _Node?.Move(p); //shortcut > if (_Node!=null) _Node.Move(p)

        //TODO test with modifiers
        public void SelectAll(bool redraw) {

            _IGeomObject.SelectAll(Max.SubObjectLevel);
            if ( redraw ) Kernel.RedrawViews();
        }
        public void DeselectAll(bool redraw) { //deselect all geometry

            _IGeomObject.ClearSelection(Max.SubObjectLevel);
            if ( redraw ) Kernel.RedrawViews();
        }

        //TODO test it with mesh and poly
        /// <summary> Set Wirecolor to Node. Works in Primitives.</summary>
        public Color Wirecolor {
            get { return new Color(_Node._IINode.WireColor); }
            set { _Node._IINode.WireColor = value.SystemColor; }
        }

        public Point3 Pos {
            get { return _Node?.GetNodeTransform(Kernel.Now).rows[0]; }
            set {_Node?.SetNodeTransform(Matrix3.Identity.Translate(value), Kernel.Now);} 
        }
    }
}


/*
parameterBlock.Params.Any("Length")

 ITriObject triObject = GetITriobject();
 //triObject->NotifyDependents(FOREVER, OBJ_CHANNELS, REFMSG_CHANGE);
 triObject.NotifyDependents(new Interval(), EnumChannels.OBJ_CHANNELS, EnumRefMsg.REFMSG_CHANGE);
 Kernel._Interface.RedrawViews();
            //_Node.InvalidateObjCache();
// n.InvalidateObjCache();
*/

// solving Object reference not set to an instance of an object
/*Max.Log("GetIpolyObject > from _Object:{0}", _Object);
Max.Log("_Node:{0}", _Node);
IObjectState istate = _Object.Eval(Kernel.Now);
Max.Log("istate:{0}", istate);
IClass_ID polyClass = Kernel._Global.Class_ID.Create(( uint )BuiltInClassIDA.POLYOBJ_CLASS_ID, 0);
Max.Log("polyClass:{0} epoly:{1}", polyClass, ClassID.EditablePoly._IClass_ID);
IObject iObj = istate.Obj;
Max.Log("iObj:{0}", iObj);
if ( iObj.CanConvertToType(polyClass) == 0 ) return null;
//_Object.GetReference(0)
//if ( _Object.CanConvertToType(ClassID.EditablePoly._IClass_ID) == 0 ) return null;
IPolyObject pobj = istate.Obj.ConvertToType(t, polyClass) as IPolyObject;
if ( pobj == null ) return null;
return pobj;*/


/*switch ( GlobalMethods.SubObjectLevel ) { //next operation is depend on subobject level

    case 1: break;
    case 2: break;
    case 3: break;
    case 4: break;
    case 5: break;
    default: break;
}*/

/*
 			IGlobal global = Autodesk.Max.GlobalInterface.Instance;
			IInterface14 ip = global.COREInterface14;
			IINode obj = ip.GetINodeByHandle(handleid).ActualINode;
			IObjectState os = obj.ObjectRef.Eval(ip.Time);
            // Now grab the object itself.
			IObject objOriginal = os.Obj;
            // Let's make sure it is a TriObject, which is the typical kind of object with a mesh
			if (!objOriginal.IsSubClassOf(global.TriObjectClassID))
			{
				// If it is NOT, see if we can convert it...
				if (objOriginal.CanConvertToType(global.TriObjectClassID) == 1)
				{
					objOriginal = objOriginal.ConvertToType(ip.Time, global.TriObjectClassID);
				}
				else
				{
					return false;
				}
					
			}
            ITriObject triObj = objOriginal as ITriObject;
			//IPolyObject triObj = objOriginal as IPolyObject;
			IMesh mesh = triObj.Mesh as IMesh;
			IBitArray facearray = mesh.FaceSel; //Should be a bitarray of selected faces
				int time = (int)1;
				int numFaces ;
				int numVerts ;
				
				global.GetPolygonCount(time, objOriginal, &numFaces, &numVerts);
*/

/* Test
//gi = MaxSDK.GetGlobal()
//b = gi.BitArray.Create 10
//b.get_Item(0)
//b.Set 0
//b.get_Item(0)
//MaxSDK.GetBit b 0 
public IBitArray MakeBits(int size) {

    return GlobalInterface.Instance.BitArray.Create(size);
}

public int GetBit(IBitArray bits, int index) {

    return bits[index];
}
*/



/*

 * 
 * 
public Object ORBits(IBitArray a, IBitArray b)
{
        return a.BitwiseNot.BitwiseAnd(b.BitwiseNot).BitwiseNot;
}
 * 
 int faceIndex = 0;
IBitArray eleBits = global.BitArray.Create(mesh.Numf);
mesh.FaceSelect(eleBits);
mesh.ElementFromFace(faceIndex, eleBits);
for (int fID = 0; fID < mesh.Numf; fID++)
{
    IBitArray getBits = global.BitArray.Create(mesh.Numf);
    IMNFace f = mesh.F(fID);
    if (f.GetFlag(Convert.ToUInt32(allPolys[0])))
    {
        getBits.Set(fID);
    }
}
mesh.FaceSelect(getBits);



fn getEditableMeshElementsSDK obj = (

    fn firstBit bits = (
    
        local b
        for n in bits while not (b = n; bits[n]) do ()
        b
    )

    local g            = (dotnetclass "Autodesk.Max.GlobalInterface").Instance
    local INode        = g.COREInterface14.GetINodeByHandle obj.inode.handle
    local IMesh        = (INode.EvalWorldState 0 true ).Obj.Mesh_
    local IAdjFaceList = g.AdjFaceList.Create IMesh (g.AdjEdgeList.Create IMesh)
        
    local IBitArray = g.BitArray.Create IMesh.NumFaces_ 

    local faces = #{1..obj.numfaces}
    local elements = #()

    
    -- CACHED FUNCTIONS
    local IMeshElementFromFace = IMesh.ElementFromFace
    local IBitArrayClearAll = IBitArray.ClearAll    
    
    while not faces.isEmpty do (
        
        IBitArrayClearAll()
        IMeshElementFromFace ((firstBit faces)-1) IBitArray IAdjFaceList

        IMesh.FaceSel = IBitArray
        elementFaces  = getFaceSelection obj
        faces -= elementFaces
        
        append elements elementFaces
        
    )
    
   elements

)

IBitArray = g.BitArray.Create IMesh.NumFaces_ 
IBitArray.ClearAll()

IMesh.ElementFromFace ((firstBit faces)-1) IBitArray IAdjFaceList
IMesh.FaceSel = IBitArray
elementFaces  = getFaceSelection obj
faces -= elementFaces  
 * 
 * OR
 * 
IMesh.ElementFromFace ((firstBit faces)-1) IBitArray IAdjFaceList


fn getEditableMeshElements obj = (
    
    fn firstBit bits = 
    (
        local b
        for n in bits while not (b = n; bits[n]) do ()
        b
    )

    local faces = #{1..obj.numfaces}
    local meshopgetElementsUsingFace = meshop.getElementsUsingFace
    local elements = #()
    
    while not faces.isEmpty do (

        element = meshopgetElementsUsingFace obj (firstBit faces)
        append elements element        
        faces -= element
        
    )
    
    elements
    
)

 */
