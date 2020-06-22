//
// Copyright 2012 Autodesk, Inc.  All rights reserved.
//
// Use of this software is subject to the terms of the Autodesk license
// agreement provided at the time of installation or download, or which
// otherwise accompanies this software in either electronic or hard copy form.  
//
using Autodesk.Max;
using Humanizer;
using Micra.Core.Extensions;
using System;
using System.Collections.Generic;
using System.Linq;

namespace Micra.Core {
    /// <summary>
    /// This is mesh data stored in a format that can be automatically serialized to file 
    /// as XML and across a network via TCP. It computes both vertex normals and face normals
    /// ignoring smoothing group data. 
    /// </summary>
    [Serializable]
    public class Mesh {

        public static uint MESH_VERT = 1;
        public static uint MESH_EDGE = 2;
        public static uint MESH_FACE = 4;
        /// <summary>
        /// Represents a mesh face. 
        /// </summary>
        [Serializable]
        public struct Face {
            public uint a;
            public uint b;
            public uint c;

            public Face(IFace f) {
                a = f.V[0];
                b = f.V[1];
                c = f.V[2];
            }
        }

        private IMesh _IMesh { get; }
        public Face[] faces;
        public Point3[] verts;
        public Face[] tfaces;
        public Point3[] tverts;
        public Point3[] fnormals;
        public Point3[] vnormals;

        internal Mesh(IMesh m, bool serialize = false) {
            _IMesh = m;
            if ( serialize ) {

                faces = new Face[m.NumFaces];
                for ( int i = 0; i < m.NumFaces; ++i ) faces[i] = new Face(m.Faces[i]); //from IFace

                verts = new Point3[m.NumVerts];
                for ( int i = 0; i < m.NumVerts; ++i ) verts[i] = new Point3(m.Verts[i]); //from IPoint3

                tfaces = new Face[m.NumFaces];
                for ( int i = 0; i < m.NumFaces; ++i ) tfaces[i] = new Face(m.Faces[i]);

                tverts = new Point3[m.NumTVerts];
                for ( int i = 0; i < m.NumTVerts; ++i ) tverts[i] = new Point3(m.TVerts[i]);

                fnormals = new Point3[m.NumFaces];
                vnormals = new Point3[m.NumVerts];

                for ( int i = 0; i < m.NumVerts; ++i ) vnormals[i] = Point3.Origin;

                // Compute vertex normals ignoring smoothing groups
                // Each vertex normal is the average of the face normals.
                for ( int i = 0; i < m.NumFaces; ++i ) {
                    uint a = faces[i].a;
                    uint b = faces[i].b;
                    uint c = faces[i].c;
                    Point3 va = verts[a];
                    Point3 vb = verts[b];
                    Point3 vc = verts[c];
                    Point3 fnorm = ( vb - va ) ^ ( vc - vb );
                    vnormals[a] += fnorm;
                    vnormals[b] += fnorm;
                    vnormals[c] += fnorm;
                    fnormals[i] = fnorm.Normalized;
                }

                // Last step is to normalize the vector normals.
                for ( int i = 0; i < m.NumVerts; ++i ) vnormals[i].Normalize();
            }
        }

        public double GetArea() => _IMesh.Faces.Sum(f => GetFaceArea(f));
        public double GetFaceArea(int faceIndex) => faceIndex >= _IMesh.Faces.Count - 1 ? -1 : GetFaceArea(_IMesh.Faces[faceIndex]);
        public double GetFaceArea(IFace f) {
            
            Point3 corner = new Point3 (_IMesh.Verts[(int)f.V[0]]);
            Vector3 a = Vector3.FromPoints(new Point3(_IMesh.Verts[( int )f.V[1]]), corner);
            Vector3 b = Vector3.FromPoints(new Point3(_IMesh.Verts[( int )f.V[2]]), corner);
            return Vector3.Cross(a, b).Length / 2.0;
        }

        /*internal double GetArea() => faces.Sum(f => GetFaceArea(f));
        public double GetFaceArea(int faceIndex) => faceIndex >= faces.Length - 1 ? -1 : GetFaceArea(faces[faceIndex]);

        // The area of a face is very easy to compute, its just half the length of the normal cross product
        public double GetFaceArea(Face f) {

            Point3 corner = verts[f.a];
            Vector3 a = Vector3.FromPoints(verts[f.b], corner);
            Vector3 b = Vector3.FromPoints(verts[f.c], corner);
            return Vector3.Cross(a, b).Length / 2.0;
        }*/

        internal List<IFace> GetSelectedIFaces() { //TODO -not tested -not used

            List<IFace> fsel = new List<IFace>() { };
            _IMesh.FaceSel.IEnumerable().ForEach((item, index) => {

                if ( item == 1 ) fsel.Add(_IMesh.Faces[index]); //+3DsMax count + 1
            });
            return fsel;
        }

        internal List<int> GetSelectedFaces() { //im:Autodesk.Max.Wrappers.Mesh

            List<int> fsel = new List<int>() { };
            _IMesh.FaceSel.IEnumerable().ForEach((item, index) => {

                if ( item == 1 ) fsel.Add(index); //+3DsMax count + 1
            });
            return fsel;
        }

        public List<int> GetSelectedEdges() {

            List<int> esel = new List<int>() { };
            _IMesh.EdgeSel.IEnumerable().ForEach((item, index) => {

                if ( item == 1 ) esel.Add(index); //+3DsMax count + 1
            });
            return esel;
        }

        public List<int> GetSelectedVerts() {

            List<int> vsel = new List<int>() { };
            _IMesh.VertSel.IEnumerable().ForEach((item, index) => {

                if ( item == 1 ) vsel.Add(index); //+3DsMax count + 1
            });
            return vsel;
        }

        /// <summary> Set Face selection
        ///     <example> 
        ///         <code>
        ///             example: Node.Object
        ///             <br>switch ( ClassOf() ) {</br>
        ///                 <br>case nameof(ClassID.EditableMesh) : GetMesh().SetSelectedFaces(faceIndexes); break;</br>
        ///                 <br>case nameof(ClassID.EditablePoly) : GetPoly().SetSelectedFaces(faceIndexes); break;</br>
        ///             <br>}</br>
        ///         </code>
        ///     </example>
        ///     <para>param: <paramref name="faceIndexes"/>List(int) of face indexes</para>
        /// </summary>
        public void SetSelectedFaces(List<int> faceIndexes) {

            var bytes = faceIndexes.Select(i => BitConverter.GetBytes(i)).ToArray();
            IBitArray ba = Kernel.NewIBitarray(Numf);
            //for each face index which is in range(all faces), set bit to 1(selected) 
            faceIndexes.Where(i => i < ba.Size).ForEach(i => ba.Set(i));
            _IMesh.FaceSel_ = ba;
            _IMesh.InvalidateTopologyCache();
            _IMesh.InvalidateGeomCache();
        }

        public void SetSelectedEdges(List<int> edgetIndexes) {

            var bytes = edgetIndexes.Select(i => BitConverter.GetBytes(i)).ToArray();
            IBitArray ba = Kernel.NewIBitarray(Nume);
            //for each edge index which is in range(all edges), set bit to 1(selected) 
            edgetIndexes.Where(i => i < ba.Size).ForEach(i => ba.Set(i));
            _IMesh.EdgeSel = ba;
            _IMesh.InvalidateTopologyCache();
            _IMesh.InvalidateGeomCache();
        }

        public void SetSelectedVerts(List<int> vertIndexes) {

            var bytes = vertIndexes.Select(i => BitConverter.GetBytes(i)).ToArray();
            IBitArray ba = Kernel.NewIBitarray(Numv);
            //for each vert index which is in range(all verts), set bit to 1(selected) 
            vertIndexes.Where(i => i < ba.Size).ForEach(i => ba.Set(i));
            _IMesh.VertSel_ = ba;
            _IMesh.InvalidateTopologyCache();
            _IMesh.InvalidateGeomCache();
        }

        public int Numf => _IMesh.NumFaces;
        //no better method for now (missing NumEdges in _IMesh)
        public int Nume => _IMesh.EdgeSel.Size;
        public int Numv => _IMesh.NumVerts;

        internal void HideFaces(List<int> lists) => lists.ForEach(i => _IMesh.Faces[i].Hide()); //TODO validate list indexes
        /// <summary> Hide Selected or Unselected Faces
        ///     <example> 
        ///         <code>
		///             example: GetMesh().HideFaces(true);
		///         </code>
		///     </example>
        ///     <para>param: <paramref name="selected"/> > True(Hide Selected), False(Hide Unselected)</para>
        /// </summary>
        internal void HideFaces(bool selected) {
            Max.Log("HideFaces > on Mesh!");
            for ( int i = 0; i < _IMesh.FaceSel.Size; i++ ) {

                bool isSelected = _IMesh.FaceSel[i] == 1;
                //Max.Log("face:{0} selected:{1} ", i, isSelected);
                if ( selected && isSelected ) {
                    Max.Log("hide face:{0}", i);
                    _IMesh.Faces[i].Hide();

                } else if ( !selected && !isSelected ) _IMesh.Faces[i].Hide();
            }
            _IMesh.InvalidateTopologyCache();
        }
        internal void UnhideFaces() {
            _IMesh.Faces.ForEach<IFace>(f => f.Show());
            _IMesh.InvalidateTopologyCache();
        }

        internal double GetEdgeLength(int edgeIndex) {

            Throw.IfLargerThan(edgeIndex, Nume, "Edge");

            //IMeshTempData meshTempData = Kernel._Global.MeshTempData.Create(_IMesh);
            //meshTempData.FreeAll();
            //IAdjEdgeList elist = meshTempData.AdjEList;
            //ITab<IPoint3> = meshTempData.ClusterCenters(MESH_FACE); //selection level FACE


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
            throw new NotImplementedException();
        }

        /*internal void GetElements() {

            IAdjEdgeList elist = Kernel._Global.AdjEdgeList.Create(_IMesh);
            IAdjFaceList flist = Kernel._Global.AdjFaceList.Create(_IMesh, elist);
            var iBitArray = Kernel._Global.BitArray.Create(_IMesh.NumFaces);
            var faces = new List<int>(_IMesh.NumFaces) { };
            var elements = new List<int>() { };
            while ( faces.Count > 0 ) do (

                iBitArray.ClearAll();
                _IMesh.ElementFromFace(( firstBit(faces)) - 1 ) iBitArray(IAdjFaceList)

                IMesh.FaceSel = IBitArray
                elementFaces = getFaceSelection obj
               faces -= elementFaces


                append elements elementFaces
        
            )
        }*/

        /*private uint firstBit(List<int> bits) {

            int b;
            foreach ( int n in bits ) {
                while !( b = n ); bits[n])) do b;
           }
        }*/

        internal List<int> GetFaceVerts(int faceIndex) {
            if ( faceIndex > _IMesh.Faces.Count - 1 ) throw new Exception("Face index is out of range.");
            return new List<int>() { 
                ( int )_IMesh.Faces[faceIndex].V[0], 
                ( int )_IMesh.Faces[faceIndex].V[1], 
                ( int )_IMesh.Faces[faceIndex].V[2]
            };
        }

        /*internal List<int> GetFaceVerts(int faceIndex) {
            if ( faceIndex > faces.Length - 1 ) throw new Exception("Face index is out of range.");
            return new List<int>() { ( int )faces[faceIndex].a, ( int )faces[faceIndex].b, ( int )faces[faceIndex].c };
        }*/
    }
}


/*
        public List<int> getEditableMeshElementsSDK (Node node) {

            fn firstBit bits = (

                local b
                for n in bits while not(b = n; bits[n]) do ()
               b
            )

INode iNode = Kernel._Interface.GetINodeByHandle(obj.inode.handle);
IMesh iMesh = iNode.EvalWorldState(Kernel.Now, true).Obj.Mesh_
            IAdjFaceList adjFaceList = Kernel._Global.AdjFaceList.Create IMesh(Kernel._Global.AdjEdgeList.Create IMesh)
            IBitArray bitArray = Kernel._Global.BitArray.Create IMesh.NumFaces_
            local faces = #{1..obj.numfaces}
            local elements = #()
           //CACHED FUNCTIONS
           local IMeshElementFromFace = IMesh.ElementFromFace
           local IBitArrayClearAll = IBitArray.ClearAll    
            while not faces.isEmpty do (

                IBitArrayClearAll()
                IMesh.ElementFromFace((firstBit faces)-1, IBitArray, bitArray);
IMesh.FaceSel = IBitArray
elementFaces = getFaceSelection obj
faces -= elementFaces
append elements elementFaces
        
            )
           return elements

    }
*/
