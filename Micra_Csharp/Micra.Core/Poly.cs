using Autodesk.Max;
using Autodesk.Max.Wrappers;
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
        public struct Ngon {
            /// <summary>Vertex List</summary>
            public IList<int> Vtx;
            /// <summary>Vertex 0</summary>
            public int a;
            /// <summary>Vertex 1</summary>
            public int b;
            /// <summary>Vertex 2</summary>
            public int c;
            /// <summary>Vertex 3</summary>
            public int d;

            public Ngon(IMNFace f) {
                //f.TriNum
                //MNVert
                //f.VertIndex
                Vtx = f.Vtx;
                a = f.Vtx[0];
                b = f.Vtx[1];
                c = f.Vtx[2];
                d = f.Vtx[3];
            }
            public int Count => Vtx.Count;
            public bool IsTriangle => Count == 3;
            public bool IsQuad => Count == 4;
            public bool IsNgon => Vtx.Count > 4;

        }

        /*public struct Edge {
            public int a;
            public int b;

            public Edge(IEdge e) {

                a = e.V[0];
                b = e.V[1];
            }
        }*/

        public Ngon[] ngons;
        public Point3[] verts;
        /*public Ngon[] tfaces;
        public Point3[] tverts;
        public Point3[] fnormals;
        public Point3[] vnormals;*/

        public Point3 FaceCenter(Ngon f) {

            Point3 center = new Point3();
            f.Vtx.ForEach(v => center += verts[v]);
            return center / f.Vtx.Count;
        }

        public Poly() {
        }

        internal Poly(IMNMesh m) {

            ngons = new Ngon[m.FNum];
            for ( int i = 0; i < m.FNum; ++i ) ngons[i] = new Ngon(m.F(i)); //from IMNFace

            verts = new Point3[m.VNum];
            for ( int i = 0; i < m.VNum; ++i ) verts[i] = new Point3(m.V(i).P); //from IMNVert

            /*tfaces = new Ngon[m.FNum];
            for ( int i = 0; i < m.FNum; ++i )
                tfaces[i] = new Ngon(m.Faces[i]);

            tverts = new Point3[m.NumTVerts];
            for ( int i = 0; i < m.NumTVerts; ++i )
                tverts[i] = new Point3(m.TVerts[i]);

            fnormals = new Point3[m.FNum];
            vnormals = new Point3[m.VNum];

            for ( int i = 0; i < m.VNum; ++i )
                vnormals[i] = Point3.Origin;

            // Compute vertex normals ignoring smoothing groups
            // Each vertex normal is the average of the face normals.
            for ( int i = 0; i < m.FNum; ++i ) {
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
            for ( int i = 0; i < m.VNum; ++i )
                vnormals[i].Normalize();*/
        }
        /// <summary> Calculate Face, Polygon, Ngon Area
        ///     <example> 
        ///         <code>
		///             example: 
		///         </code>
		///     </example>
        ///     <para>param: <paramref name=""/></para>
        /// </summary>
        public double Area(int ngonIndex) => Area(ngons[ngonIndex]);
        /**
            This script is based upon Heron’s Formula, which calculates 
            the area of a triangle based upon knowing its three lengths.
            The script also calculates the area for quads.
            It does this by dividing the quad into two triangles.
        */
        public double Area(Ngon face) { //TODO -under testing

            //if there is more than 4 vertices use centralized triangulation method (MerlinEl 2020)
            if ( face.IsNgon ) {

                Point3 center = FaceCenter(face);
                double area = 0.0;
                //create triangle from two verts in order and center (I hope that Vtx indexes are in order)
                for ( int i = 0; i < face.Vtx.Count - 1; i++ ) {
                    //get edge p1 p2 and center for triangle base
                    area += GetTriangleArea(center, verts[face.Vtx[i]], verts[face.Vtx[i + 1]]);
                }
                return area;
            }
            //get points
            Point3 p1 = verts[face.a];
            Point3 p2 = verts[face.b];
            Point3 p3 = verts[face.c];
            //calculate area of triangle
            double area1 = GetTriangleArea(p1, p2, p3);
            //if is quad, calc area of second triangle
            double area2 = face.IsQuad ? GetTriangleArea(p1, p3, verts[face.d]) : 0;
            return area1 + area2;
        }
        /// <summary> Heron’s Formula to calculate face area
        ///     <example> 
        ///         <code>
        ///             example: GetTriangleArea(p1, p2, p3);
        ///         </code>
        ///     </example>
        /// </summary>
        private double GetTriangleArea(Point3 p1, Point3 p2, Point3 p3) {

            double a = p1.DistanceTo(p2);
            double b = p2.DistanceTo(p3);
            double c = p3.DistanceTo(p1);
            double p = 0.5 * ( a + b + c );
            return Math.Sqrt(p * ( p - a ) * ( p - b ) * ( p - c ));
        }
    }
}
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
