using System;
using static Micra.Core.Mesh;

namespace Micra.Core {
    public class GeoOP {
        public static double GetFaceArea(Mesh m, int faceIndex) { //not used //not tested

            return faceIndex >= m.faces.Length ? -1 : GetFaceArea(m, m.faces[faceIndex]);
        }
        public static double GetFaceArea(Mesh m, Face f) {

            Point3 p1 = m.verts[f.a];
            Point3 p2 = m.verts[f.b];
            Point3 p3 = m.verts[f.c];
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
        public static double GetEdgeLength(Mesh m, Edge e) { //not used //not tested

            //Point3.Distance( _mesh.ed ei.V
            throw new NotImplementedException();
        }
    }
}


/*
mxssetedgevisflags msh fi #{1,3};
 fn mxssetedgevisflags m face flags =
 (	
 	setEdgeVis m  face 1 flags[1];
 	setEdgeVis m  face 2 flags[2];
 	setEdgeVis m  face 3 flags[3];
 ) 
 * 
mesh.faces[fi].setEdgeVisFlags(1,0,1);
 * 
 * 
     public IMesh DeleteVertices(IMesh mesh, IImmutableList<int> indices_to_remove)
    {
        var indices_to_remove_set = new HashSet<int>(indices_to_remove);
        var new_vertices = new List<Vector>();
        var map = new int[mesh.Vertices.Count];

        for (var i = 0; i < mesh.Vertices.Count; i++)
        {
            if (indices_to_remove_set.Contains(i))
            {
                map[i] = -1;
            }
            else
            {
                new_vertices.Add(mesh.Vertices[i]);
                map[i] = new_vertices.Count - 1;
            }
        }

        var new_triangle_list = from triangle in mesh.Triangles
                                where map[triangle.A] != -1 &&
                                      map[triangle.B] != -1 &&
                                      map[triangle.C] != -1
                                select new IndexTriangle(
                                    map[triangle.A],
                                    map[triangle.B],
                                    map[triangle.C]);

        //build new mesh...
    }
     */
