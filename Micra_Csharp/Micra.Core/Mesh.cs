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
        }

        public Face[] faces;
        public Point3[] verts;
        public Face[] tfaces;
        public Point3[] tverts;
        public Point3[] fnormals;
        public Point3[] vnormals;

        public Mesh() {
        }

        internal Mesh(IMesh m) {
            faces = new Face[m.NumFaces];
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
                vnormals[i].Normalize();
        }

        public double GetVolume() {
            
            double objVolume = 0.0;
            //Kernel.WriteLine("\tGetVolume > NumFaces:{0}", faces.Length);
            foreach ( Face f in faces ) {

                Point3 p1 = verts[f.a];
                Point3 p2 = verts[f.b];
                Point3 p3 = verts[f.c];
                Vector3 v1 = Vector3.FromPoints(p2, p1);
                Vector3 v2 = Vector3.FromPoints(p3, p1);
                Vector3 v3 = Vector3.FromPoint(p1);
                objVolume += Vector3.DotProduct(Vector3.CrossProduct(v1, v2), v3);
            }
            return ( float )( objVolume / faces.Length );
        }
    }
}
