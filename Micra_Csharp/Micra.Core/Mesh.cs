//
// Copyright 2012 Autodesk, Inc.  All rights reserved.
//
// Use of this software is subject to the terms of the Autodesk license
// agreement provided at the time of installation or download, or which
// otherwise accompanies this software in either electronic or hard copy form.  
//
using Autodesk.Max;
using System;

namespace Micra.Core {
    /// <summary>
    /// This is mesh data stored in a format that can be automatically serialized to file 
    /// as XML and across a network via TCP. It computes both vertex normals and face normals
    /// ignoring smoothing group data. 
    /// </summary>
    [Serializable]
    public class Mesh {
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
            public double Area(Point3[] verts) { //not used not tested

                Point3 p1 = verts[a];
                Point3 p2 = verts[b];
                Point3 p3 = verts[c];
                Vector3 v1 = Vector3.FromPoints(p2, p1);
                Vector3 v2 = Vector3.FromPoints(p3, p1);
                Vector3 v3 = Vector3.FromPoint(p1);
                return Vector3.DotProduct(Vector3.CrossProduct(v1, v2), v3);

                // The area of a face is very easy to compute, its just half the length of the normal cross product:
                /*Point3 A = new Point3 (verts[b] - verts[a]);
                Point3 B = new Point3 (verts[c] - verts[a]);
                Point3 N = A ^ B;
                area = Length(N) / 2.0f;*/
            }
        }

        public struct Edge {
            public uint a;
            public uint b;

            public Edge(IEdge e) {

                a = e.V[0];
                b = e.V[1];
            }
            public double Length() {

                //return Point3.Distance(p1, p2)
                throw new NotImplementedException();
            }
        }

        //public IMesh _IMesh;

        public Face[] faces;
        //public Edge[] edges;
        public Point3[] verts;
        public Face[] tfaces;
        public Point3[] tverts;
        public Point3[] fnormals;
        public Point3[] vnormals;

        public Mesh() {
        }

        internal Mesh(IMesh m) {

           /* _IMesh = m;
            Kernel.WriteLine("Init Mesh from Imesh > NumVerts:{0} EdgeSel.IsEmpty:{1}", _IMesh.NumVerts, m.EdgeSel.IsEmpty);
            for (int i = 0; i < m.EdgeSel.Size; i++ ) {

                Kernel.WriteLine("\tedge{0}", m.EdgeSel[i]);
            }*/

            faces = new Face[m.NumFaces];
            for ( int i = 0; i < m.NumFaces; ++i )
                faces[i] = new Face(m.Faces[i]);

            /*edges = new Edge[m.NumEdges];
            for ( int i = 0; i < m.NumEdges; ++i )
                edges[i] = new Edge(m.Edges[i]);*/

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
                vnormals[i].Normalize();
        }

        #region Public Methods

        public double GetVolume() {
            
            double objVolume = 0.0;
            faces.ForEach(f => objVolume += f.Area(verts));
            return ( objVolume / faces.Length );
        }

        public double GetEdgeLength(int ei) { //TODO

            //Point3.Distance( _mesh.ed ei.V
            return 0;
        }

        #endregion

        #region Public Static Methods


        #endregion
    }
}