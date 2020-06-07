using Autodesk.Max;
using Autodesk.Max.Wrappers;
using System;

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

        public struct Edge {
            public uint a;
            public uint b;

            public Edge(IEdge e) {

                a = e.V[0];
                b = e.V[1];
            }
        }

        public Face[] faces;
        public Point3[] verts;
        public Face[] tfaces;
        public Point3[] tverts;
        public Point3[] fnormals;
        public Point3[] vnormals;

        public Poly() {
        }

        internal Poly(IMNMesh p) {

            //PolyObject
            /*faces = new Face[m.NumFaces];
            for ( int i = 0; i < m.NumFaces; ++i )
                faces[i] = new Face(m.Faces[i]);

            verts = new Point3[m.NumVerts];
            for ( int i = 0; i < m.NumVerts; ++i )
                verts[i] = new Point3(m.Verts[i]);

            tfaces = new Face[m.NumFaces];
            for ( int i = 0; i < m.NumFaces; ++i )
                tfaces[i] = new Face(m.Faces[i]);

            tverts = new Point3[m.NumTVerts];
            for ( int i = 0; i < m.NumTVerts; ++i )
                tverts[i] = new Point3(m.TVerts[i]);

            fnormals = new Point3[m.NumFaces];
            vnormals = new Point3[m.NumVerts];

            for ( int i = 0; i < m.NumVerts; ++i )
                vnormals[i] = Point3.Origin;

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
            for ( int i = 0; i < m.NumVerts; ++i )
                vnormals[i].Normalize();*/
        }
    }
}