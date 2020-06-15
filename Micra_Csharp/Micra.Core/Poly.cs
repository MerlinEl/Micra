using Autodesk.Max;
using Autodesk.Max.Wrappers;
using Humanizer;
using System;
using System.Collections.Generic;
using System.Linq;
//resources
//http://www.illusioncatalyst.com/3dsmax_files/snippets/editable_poly_sub_obj.php
namespace Micra.Core {
    /// <summary>
    /// This is poly data stored in a format that can be automatically serialized to file 
    /// as XML and across a network via TCP. It computes both vertex normals and face normals
    /// ignoring smoothing group data. 
    /// </summary>
    [Serializable]
    public class Poly {
        /// <summary>
        /// Represents a poly face. 
        /// </summary>
        [Serializable]
        public struct Ngon { //TODO -not tested -not used
            private IMNFace _IMNFace { get; }
            /// <summary>Vertex List</summary>
            public IList<int> verts => _IMNFace.Vtx;
            public Ngon(IMNFace f) => _IMNFace = f;
            public int Vnum => _IMNFace.Vtx.Count;
            /// <summary> Check if face have exactly 3 vertices.</summary>
            public bool IsTriangle => Vnum == 3;
            /// <summary> Check if face have exactly 4 vertices.</summary>
            public bool IsQuad => Vnum == 4;
            /// <summary> Check if face have more than 4 vertices.</summary>
            public bool IsNgon => Vnum > 4;
        }
        /// <summary> Check if face have more than 4 vertices.</summary>
        //public bool IsNGon(int faceIndex) => _IMNMesh.F(faceIndex).Vtx.Count > 4;

        private IMNMesh _IMNMesh { get; } //Autodesk.Max.Wrappers.MNMesh
        internal Poly(IMNMesh m) => _IMNMesh = m;

        internal bool IsFaceSelected(int faceIndex) => _IMNMesh.F(faceIndex).GetFlag((uint)EnumFlags.MNMeshComponent.MN_SEL);
        internal bool IsEdgeSelected(int edgeIndex) => _IMNMesh.E(edgeIndex).GetFlag((uint)EnumFlags.MNMeshComponent.MN_SEL);
        internal bool IsVertSelected(int edgeIndex) => _IMNMesh.V(edgeIndex).GetFlag((uint)EnumFlags.MNMeshComponent.MN_SEL);

        internal void ShowFace(int faceIncex) => _IMNMesh.F(faceIncex).SetFlag((uint)EnumFlags.MNMeshComponent.MN_HIDDEN, false);
        internal void HideFace(int faceIncex) => _IMNMesh.F(faceIncex).SetFlag((uint)EnumFlags.MNMeshComponent.MN_HIDDEN, true);

        public Point3 VertPos(int vertIndex) => new Point3(_IMNMesh.V(vertIndex).P);
        public Point3 FaceCenter(int faceIndex) {

            IMNFace face = _IMNMesh.F(faceIndex);
            Point3 center = new Point3();
            face.Vtx.ForEach(v => center += VertPos(v));
            return center / face.Vtx.Count;
        }
        public List<int> GetSelectedFaces() {

            var fsel = new List<int>() { };
            for ( int i = 0; i < _IMNMesh.Numf; i++ ) if ( IsFaceSelected(i) ) fsel.Add(i);
            return fsel;
        }
        public List<int> GetSelectedEdges() {

            var esel = new List<int>() { };
            for ( int i = 0; i < _IMNMesh.Nume; i++ ) if ( IsEdgeSelected(i) ) esel.Add(i);
            return esel;
        }
        public List<int> GetSelectedVerts() {

            var vsel = new List<int>() { };
            for ( int i = 0; i < _IMNMesh.Numv; i++ ) if ( IsVertSelected(i) ) vsel.Add(i);
            return vsel;
        }

        public IBitArray GetFaceElement(int faceIndex) { //TODO -not tested -not used

            IBitArray eleBits = Kernel._Global.BitArray.Create(_IMNMesh.Numf);
           //_IMNMesh.FaceSelect(eleBits);
           _IMNMesh.ElementFromFace(faceIndex, eleBits);
            return eleBits;
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
        internal void SetSelectedFaces(List<int> faceIndexes) {

            var bytes = faceIndexes.Select(i => BitConverter.GetBytes(i)).ToArray();
            IBitArray ba = Kernel.NewIBitarray(_IMNMesh.Numf);
            //for each face index which is in range(all faces), set bit to 1(selected) 
            faceIndexes.Where(i=> i < ba.Size).ForEach(i=> ba.Set(i));
            _IMNMesh.FaceSelect(ba);
            _IMNMesh.InvalidateGeomCache();
        }

        internal void SetSelectedEdges(List<int> edgeIndexes) {

            var bytes = edgeIndexes.Select(i => BitConverter.GetBytes(i)).ToArray();
            IBitArray ba = Kernel.NewIBitarray(_IMNMesh.Nume);
            //for each edge index which is in range(all edges), set bit to 1(selected) 
            edgeIndexes.Where(i => i < ba.Size).ForEach(i => ba.Set(i));
            _IMNMesh.EdgeSelect(ba);
            _IMNMesh.InvalidateGeomCache();
        }

        internal void SetSelectedVerts(List<int> vertIndexes) {

            var bytes = vertIndexes.Select(i => BitConverter.GetBytes(i)).ToArray();
            IBitArray ba = Kernel.NewIBitarray(_IMNMesh.Numv);
            //for each vert index which is in range(all verts), set bit to 1(selected) 
            vertIndexes.Where(i => i < ba.Size).ForEach(i => ba.Set(i));
            _IMNMesh.VertexSelect(ba);
            _IMNMesh.InvalidateGeomCache();
        }

        /// <summary> Calculate Face, Polygon, Ngon Area
        ///     <example> 
        ///         <code>
        ///             example: 
        ///         </code>
        ///     </example>
        ///     <para>param: <paramref name=""/></para>
        /// </summary>
        public double GetArea() {

            IMesh imesh = Kernel._Global.Mesh.Create();
            _IMNMesh.OutToTri(imesh);
            return imesh.Faces.Sum(f => GetFaceArea(imesh, f));
        }
        private double GetFaceArea(IMesh imesh, IFace face) {

            Point3 corner = new Point3(imesh.GetVert((int)face.V[0]));
            Vector3 a = Vector3.FromPoints(new Point3(imesh.GetVert((int)face.V[1])), corner);
            Vector3 b = Vector3.FromPoints(new Point3(imesh.GetVert((int)face.V[2])), corner);
            return Vector3.Cross(a, b).Length / 2.0;
        }

        public double GetFaceArea(int faceIndex) {

            IMNFace ngon = _IMNMesh.F(faceIndex);
            List<Point3> polygon = ngon.Vtx.Select(vi => VertPos(vi)).ToList();
            Point3 normal = new Point3();
            double dist = 0.0;
            double area = 0.0;
            int n = polygon.Count; //number of vertices
            if ( n == 3 ) { //is triangle
                Point3 a = polygon[0];
                Point3 b = polygon[1];
                Point3 c = polygon[2];
                Point3 v = b - a;
                normal = v.Cross(c - a);
                dist = normal.Dot(a);
            } else if ( n == 4 ) { //is polygon
                Point3 a = polygon[0];
                Point3 b = polygon[1];
                Point3 c = polygon[2];
                Point3 d = polygon[3];

                normal.X = ( c.Y - a.Y ) * ( d.Z - b.Z )
                  + ( c.Z - a.Z ) * ( b.Y - d.Y );
                normal.Y = ( c.Z - a.Z ) * ( d.X - b.X )
                  + ( c.X - a.X ) * ( b.Z - d.Z );
                normal.Z = ( c.X - a.X ) * ( d.Y - b.Y )
                  + ( c.Y - a.Y ) * ( b.X - d.X );

                dist = 0.25 *
                  ( normal.X * ( a.X + b.X + c.X + d.X )
                  + normal.Y * ( a.Y + b.Y + c.Y + d.Y )
                  + normal.Z * ( a.Z + b.Z + c.Z + d.Z ) );
            } else if ( n > 4 ) { //is ngon
                Point3 a;
                Point3 b = polygon[n - 2];
                Point3 c = polygon[n - 1];
                Point3 s = new Point3();

                for ( int i = 0; i < n; ++i ) {
                    a = b;
                    b = c;
                    c = polygon[i];

                    normal.X += b.Y * ( c.Z - a.Z );
                    normal.Y += b.Z * ( c.X - a.X );
                    normal.Z += b.X * ( c.Y - a.Y );

                    s += c;
                }
                dist = s.Dot(normal) / n;
            }
            float length = normal.Length;
            normal /= length;
            area = 0.5 * length;
            return area;
        }
   
        /// <summary> Hide Selected or Unselected Faces
        ///     <example> 
        ///         <code>
        ///             example: GetPoly().HideFaces(true);
        ///         </code>
        ///     </example>
        ///     <para>param: <paramref name="selected"/> > True(Hide Selected), False(Hide Unselected)</para>
        /// </summary>
        internal void HideFaces(bool selected) {
            Max.Log("HideFaces > on Poly!");
            for ( int i = 0; i < _IMNMesh.Numf; i++ ) {

                bool isSelected = IsFaceSelected(i);
                //Max.Log("face:{0} selected:{1} ", i, isSelected);
                if ( selected && isSelected ) {
                    Max.Log("hide face:{0}", i);
                    HideFace(i);

                } else if ( !selected && !isSelected ) HideFace(i);
            }
            _IMNMesh.InvalidateTopoCache(false);
            _IMNMesh.InvalidateGeomCache();
        }

        internal List<int> GetFaceVerts(int faceIndex) {
            if ( faceIndex > _IMNMesh.Numf - 1 ) throw new Exception("Face index is out of range.");
            return _IMNMesh.F(faceIndex).Vtx.ToList();
        }

        internal void UnhideFaces() {
            //_IMNMesh.F.ForEach<IMNFace>(f => ShowFace(f));
            Max.Log("UnhideFaces > on Poly!");
            for ( int i = 0; i < _IMNMesh.Numf; i++ ) ShowFace(i);
            _IMNMesh.InvalidateTopoCache(false);
            _IMNMesh.InvalidateGeomCache();
        }

        internal double EdgeLength(int edgeIndex) {
            throw new NotImplementedException();
        }
    }
}

//MNTempData mtd = new MNTempData(_IMNMesh, true);
//mtd.Invalidate((uint)EnumChannels.SELECT_CHANNEL | (uint)EnumChannels.TOPO_CHANNEL);
//mtd.FreeAll();

/*Max.Log("GetSelectedFaces > on Poly!");
List<int> fsel = new List<int>() { };
IBitArray ba = Kernel._Global.BitArray.Create();
_IMNMesh.GetFaceSel(ba);
ba.IEnumerable().ForEach((item, index) => {

    if ( item == 1 ) fsel.Add(index); //+3DsMax count + 1
});
return fsel;
public static List<int> GetSelectedVerts(IMNMesh m) {
    List<int> vsel = new List<int>() { };
    IBitArray ba = Kernel._Global.BitArray.Create();
    m.GetVertexSel(ba);
    ba.IEnumerable().ForEach((item, index) => {

        if ( item == 1 ) vsel.Add(index); //+3DsMax count + 1
    });
    return vsel;
}
*/


/*
Data Invalidation Methods:
Prototype:
void Invalidate(DWORD part);
Remarks:
Invalidates all data based on the specified part of the mesh. In the following
chart, the columns represent the channels GEOM_CHANNEL (G),
TOPO_CHANNEL (T), SELECT_CHANNEL (S), and
SUBSEL_TYPE_CHANNEL (U).
X's indicate dependency of the specified data cache on the given channel.

*/



/*
void MakeEdgeVisAndSel(MNMesh & mm, int ee)
{
   assert(mm.GetFlag(MN_MESH_FILLED_IN));
   MNEdge *me = mm.E(ee);
   MNFace *mf1 = mm.F(me->f1);
   MNFace *mf2 =(me->f2>-1) ? mm.F(me->f2) : NULL;
 
   // Change the edge as desired
   me->ClearFlag(MN_EDGE_INVIS | MN_EDGE_HALF_INVIS);
   me->SetFlag(MN_SEL);
 
   // Make the corresponding changes in face 1
   inti;
   i = mf1->EdgeIndex(ee);
   mf1->visedg.Set(i);
   mf1->edgsel.Set(i);
 
   // Make the corresponding changes in face 2
   if(mf2)
   {
     i = mf2->EdgeIndex(ee);
     mf2->visedg.Set(i);
     mf2->edgsel.Set(i);
   }
}
*/


/*
/// <summary>
/// Face center
/// </summary>
public Point3 FaceCenter;

   public double Area(int ngonIndex) { //TODO -not tested -not used

            Ngon face = ngons[ngonIndex];

            //if there is more than 4 vertices use centralized triangulation method
            if ( face.IsNgon ) {

                Point3 center = GetFaceCenter(face);
                double area = 0.0;
                //take two verts in order and make triangle to center
                for (int i = 0; i < face.Vtx.Count-1; i++ ) {


                }
                //face.Vtx.ForEach(v=> verts[v])
                return area;
            }

            //get points into a nice, concise format
            Point3[] pts = new Point3[4];

            pts[0] = verts[face.a];
            pts[1] = verts[face.b];
            pts[2] = verts[face.c];
            if ( face.IsQuad ) pts[3] = verts[face.d];

            //calculate areas of triangles
            double a = pts[0].DistanceTo(pts[1]);
            double b = pts[1].DistanceTo(pts[2]);
            double c = pts[2].DistanceTo(pts[0]);
            double p = 0.5 * ( a + b + c );
            double area1 = Math.Sqrt(p * ( p - a ) * ( p - b ) * ( p - c ));

            //double area1 = GetTriangleArea(pts[0], pts[1], pts[2]);

            //if quad, calc area of second triangle
            double area2 = 0;
            if ( face.IsQuad ) {
                a = pts[0].DistanceTo(pts[2]);
                b = pts[2].DistanceTo(pts[3]);
                c = pts[3].DistanceTo(pts[0]);
                p = 0.5 * ( a + b + c );
                area2 = Math.Sqrt(p * ( p - a ) * ( p - b ) * ( p - c ));
                //double area2 = GetTriangleArea(pts[0], pts[2], pts[3]);
            }
            return area1 + area2;
        }


*/
