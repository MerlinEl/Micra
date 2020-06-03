//
// Copyright 2012 Autodesk, Inc.  All rights reserved.
//
// Use of this software is subject to the terms of the Autodesk license
// agreement provided at the time of installation or download, or which
// otherwise accompanies this software in either electronic or hard copy form.  
//
using Autodesk.Max;
using System;
using System.Collections.Generic;
using System.Linq;
//http://docs.autodesk.com/3DSMAX/16/ENU/3ds-Max-SDK-Programmer-Guide/index.html?url=files/GUID-B2693B67-F56D-4EEB-9FB8-19700D7BAB90.htm,topicNumber=d30e23902
namespace Micra.Core {
    /// <summary>
    /// Represents an element of a scene. Wraps the BaseObject type in the 3ds Max SDK. 
    /// </summary>
    public class SceneElement : ReferenceTarget {
        public IBaseObject _BaseObject { get { return _Anim as IBaseObject; } }

        internal SceneElement(IBaseObject x) : base(x) {
            if ( parameterBlock == null ) {
                IIParamArray pa = _BaseObject.ParamBlock;
                if ( pa != null )
                    parameterBlock = CreateWrapper<ParameterBlock1>(pa.ParamBlock);
            }
        }

        public IEnumerable<Node> Nodes {
            get {
                return from x in Observers where x is Node select x as Node;
            }
        }

        public bool Instanced {
            get {
                return Nodes.Count() > 1;
            }
        }

        public string Name {
            get {
                return _BaseObject.ObjectName;
            }
        }
    }

    /// <summary>
    /// Represents an object that can flow through the geometry pipeline. Wraps the Object type 
    /// in the Max SDK. Associated with a Node. 
    /// </summary>
    public class SceneObject : SceneElement {
        internal SceneObject(IObject x) : base(x) { }

        /// <summary>
        /// Returns the corresponding wrapped object from the Autodesk.Max layer. 
        /// This is only used if the APIs of Autodesk.Max layer are required.
        /// </summary>
        public IObject _Object { get { return _Anim as IObject; } }

        /// <summary>
        /// When an object is created, it should be manually associated with a single node.
        /// This is only for convenience. An object is not guaranteed to have a node.
        /// </summary>
        public Node Node { get; set; }
        public Mesh Mesh => GetMesh(Kernel.Now);

        public void AddModifier(Modifier m) {
            if ( Node != null )
                Node.AddModifier(m);
        }

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
        public ITriObject GetITriobject() => GetITriobject(Kernel.Now);
        public ITriObject GetITriobject(TimeValue t) {

            IClass_ID triClass = Kernel._Global.Class_ID.Create((uint)BuiltInClassIDA.TRIOBJ_CLASS_ID, 0);
            if ( _Object.CanConvertToType(ClassID.TriObject._IClass_ID) == 0 ) return null;

            ITriObject tri = _Object.ConvertToType(t, triClass) as ITriObject;
            if ( tri == null ) return null;
            return tri;
        }

        public IMesh GetImesh(TimeValue t) => GetITriobject(t).Mesh;

        public Mesh GetMesh(TimeValue t) {

            ITriObject tri = GetITriobject(t);
            Mesh r = new Mesh(tri.Mesh);

            if ( tri.GetType().TypeHandle.Value != _Object.GetType().TypeHandle.Value ) {
                //if (tri.Handle != _Object.Handle) {
                RefResult rr = tri.MaybeAutoDelete();
                if ( rr == RefResult.Fail )
                    throw new Exception("Failed to autodelete the tri-object");
            }
            return r;
        }

        public double GetObjectVolume() {

            Mesh m = Node.GetMesh();
            double objVolume = 0.0;
            m.faces.ForEach(f => objVolume += GeoOP.GetFaceArea(m, f));
            return ( objVolume / m.faces.Length );
        }

        public void HideGeometry(bool selected) {
            //Based on SubobjectLevel
            switch ( Kernel._Interface.SubObjectLevel ) {

                case 1: break;
                case 2: break;
                case 3: break;
                case 4: break;
                case 5: break;
            }

            IMesh im = GetImesh(Kernel.Now);
            Kernel.WriteLine("Mesh Faces:{0}", im.FaceSel.Size);
            for ( int i = 0; i < im.FaceSel.Size; i++ ) {

                bool isSelected = im.FaceSel[i] == 1;
                Kernel.WriteLine("selected:{0} face:{1}", isSelected, i);
                if ( selected && isSelected ) {
                    im.Faces[i].Hide();
                } else if ( !selected && !isSelected ) im.Faces[i].Hide();
            }
            im.InvalidateTopologyCache();
            // Kernel._Interface.InvalidateObCache(_BaseObject)
        }

        public void UnhideGeometry() {

            IMesh im = GetImesh(Kernel.Now);
            //Based on SubobjectLevel
            switch ( Kernel._Interface.SubObjectLevel ) {
                //todo
                /*case 1: im.Verts.ForEach<IVert>(v => v.Show()); break; //this not vertices onlt positions Point3
                case 2: im.Edges.ForEach<IEdge>(e => e.Show()); break;
                case 3: im.Edges.ForEach<IEdge>(e => e.Show()); break;*/
                case 3: im.Faces.ForEach<IFace>(f => f.Show()); break; //if is Mesh (poly have spline here)
                case 4: im.Faces.ForEach<IFace>(f => f.Show()); break;
                case 5: im.Faces.ForEach<IFace>(f => f.Show()); break;
            }
            im.InvalidateTopologyCache();

            /* im.InvalidateGeomCache();
             im.InvalidateTopologyCache();
             ITriObject triObject = GetITriobject();
             //triObject->NotifyDependents(FOREVER, OBJ_CHANNELS, REFMSG_CHANGE);
             triObject.NotifyDependents(new Interval(), EnumChannels.OBJ_CHANNELS, EnumRefMsg.REFMSG_CHANGE);
             Kernel._Interface.RedrawViews();*/
        }

        public List<int> GetSelectedFaces() {

            IMesh im = GetImesh(Kernel.Now);
            //if not faces are selected, return empty list
            if ( !im.FaceSel.AnyBitSet.Equals(true) ) return new List<int>() { };

            int faceCount = im.FaceSel.Size;
            Kernel.WriteLine("FaceSel.Size:{0}", faceCount);
            for ( int i = 0; i < im.FaceSel.Size; i++ ) {

                bool isSelected = im.FaceSel[i] == 1;
                Kernel.WriteLine("selected:{0} face:{1}", isSelected, i);
                if ( !isSelected ) im.Faces[i].Hide();
            }
            im.InvalidateGeomCache();
            //im.Init();

            /*List<string> fsel = im.FaceSel.IEnumerable()
                //.Where(item => item == 1)
                .Select((item, index) => String.Format("selected:{0} index:{1}", item == 1, index)) //get IFace
                .ToList();

            fsel.ForEach(ei => Kernel.WriteLine("selected face:{0}", ei));*/

            // return fsel;
            throw new NotImplementedException();
        }
        public List<int> GetSelectedEdges() {

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

            //IMesh im = GetImesh(Kernel.Now);
            //return im.VertSel;
            throw new NotImplementedException();
        }

    }
}

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
