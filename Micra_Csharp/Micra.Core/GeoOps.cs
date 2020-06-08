using Autodesk.Max;
using System;
using System.Collections.Generic;
using System.Linq;
using static Micra.Core.Mesh;
using static Micra.Core.Poly;
//HIERARCHY
// Node > SceneObject > Mesh or Poly
namespace Micra.Core {
    public class GeoOps {

        public static double GetFaceArea(Mesh m, Face f) => m.Area(f);
        public static double GetFaceArea(Poly m, Ngon f) => m.Area(f);
        private static double GetFaceArea(IMesh imesh, IFace face) {

            Point3 corner = new Point3(imesh.GetVert((int)face.V[0]));
            Vector3 a = Vector3.FromPoints(new Point3(imesh.GetVert((int)face.V[1])), corner);
            Vector3 b = Vector3.FromPoints(new Point3(imesh.GetVert((int)face.V[2])), corner);
            return Vector3.Cross(a, b).Length / 2.0;
        }
        public static double GetObjectArea(IMNMesh m) {

            IMesh imesh = Kernel._Global.Mesh.Create();
            m.OutToTri(imesh);
            return imesh.Faces.Sum(f => GetFaceArea(imesh, f));
        }
        public static double GetObjectArea(Mesh m) => m.faces.Sum(f => GetFaceArea(m, f));
        public static double GetObjectArea(Node node) {

            if ( node.IsClassOf(ClassID.EditableMesh) ) {

                return GetObjectArea(node.GetMesh());

            } else if ( node.IsClassOf(ClassID.EditablePoly) ) {

                return GetObjectArea(node.GetPolyMesh());

            } else {

                return -1;
            }
        }

        public static double GetEdgeLength(IMesh m, int e) { //not used //not tested

            //m.EdgeSel
            //Point3.Distance( _mesh.ed ei.V
            throw new NotImplementedException();
        }

        public static double GetEdgeLength(IMNMesh m, int ei) {

            IMNEdge edge = m.E(ei);
            IMNVert vert1 = m.V(edge.V1);
            IMNVert vert2 = m.V(edge.V2);
            Point3 p1 = new Point3(vert1.P);
            Point3 p2 = new Point3(vert2.P);
            double dist = Point3.Distance(p1, p2);
            Kernel.WriteLine("Edge:{0} Verts:#({1}, {2}) Length:{3}", ei, edge.V1, edge.V2, dist);
            return dist;
        }

        public static List<int> GetSelectedFaces(IMesh m) { //im:Autodesk.Max.Wrappers.Mesh

            List<int> fsel = new List<int>() { };
            m.FaceSel.IEnumerable().ForEach((item, index) => {

                if ( item == 1 ) fsel.Add(index); //+3DsMax count + 1
            });
            return fsel;
        }

        public static List<int> GetSelectedFaces(IMNMesh m) { //pm:Autodesk.Max.Wrappers.MNMesh

            List<int> fsel = new List<int>() { };
            IBitArray ba = Kernel._Global.BitArray.Create();
            m.GetFaceSel(ba);
            ba.IEnumerable().ForEach((item, index) => {

                if ( item == 1 ) fsel.Add(index); //+3DsMax count + 1
            });
            return fsel;
        }

        public static List<int> GetSelectedEdges(Node node) {

            if ( node.IsClassOf(ClassID.EditableMesh) ) {

                return GetSelectedEdges(node.GetImesh());

            } else if ( node.IsClassOf(ClassID.EditablePoly) ) {

                return GetSelectedEdges(node.GetPolyMesh());

            } else { //TODO read Modifiers

                return null;
            }
        }

        public static List<int> GetSelectedEdges(IMesh m) {

            List<int> esel = new List<int>() { };
            m.EdgeSel.IEnumerable().ForEach((item, index) => {

                if ( item == 1 ) esel.Add(index); //+3DsMax count + 1
            });
            return esel;
        }

        public static List<int> GetSelectedEdges(IMNMesh m) {

            List<int> esel = new List<int>() { };
            IBitArray ba = Kernel._Global.BitArray.Create();
            m.GetEdgeSel(ba);
            ba.IEnumerable().ForEach((item, index) => {

                if ( item == 1 ) esel.Add(index); //+3DsMax count + 1
            });
            return esel;
        }

        public static List<int> GetSelectedVerts(IMesh m) {

            List<int> vsel = new List<int>() { };
            m.VertSel.IEnumerable().ForEach((item, index) => {

                if ( item == 1 ) vsel.Add(index); //+3DsMax count + 1
            });
            return vsel;
        }

        public static List<int> GetSelectedVerts(IMNMesh m) {

            List<int> vsel = new List<int>() { };
            IBitArray ba = Kernel._Global.BitArray.Create();
            m.GetVertexSel(ba);
            ba.IEnumerable().ForEach((item, index) => {

                if ( item == 1 ) vsel.Add(index); //+3DsMax count + 1
            });
            return vsel;
        }

        public static void SelectSimillarFaces(Node node) {

            Kernel.WriteLine("SelectSimillarFaces > The obj:{0}", node.Name);
            List<double> source_volumes = new List<double>() { };
            throw new NotImplementedException();
        }

        public static void SelectSimillarEdges(Node node) {

            Kernel.WriteLine("SelectSimillarEdges > The obj:{0}", node.Name);
            List<double> source_volumes = new List<double>() { };
            if ( node.IsClassOf(ClassID.EditableMesh) ) {

                IMesh im = node.GetImesh();
                var esel_m = GetSelectedEdges(im);
                Kernel.WriteLine("\tSel edges:{0}", esel_m.Count);
                //collect selected edges volume
                source_volumes = esel_m
                    .Select(n => GetEdgeLength(im, n)).Distinct()
                    .ToList();


            } else if ( node.IsClassOf(ClassID.EditablePoly) ) {

                IMNMesh imn = node.GetPolyMesh();
                var esel_p = GetSelectedEdges(imn);
                Kernel.WriteLine("\tSel edges:{0}", esel_p.Count);
                //collect selected edges volume
                source_volumes = esel_p
                    .Select(n => GetEdgeLength(imn, n)).Distinct()
                    .ToList();

            } else { //TODO read Modifiers


            }

            Kernel.WriteLine("\t({0}) Volumes:{1}", source_volumes.Count, String.Join("\n\t\t", source_volumes));


            /*IEnumerable<Node> allEdges = GetAllEdges();
            Kernel.WriteLine("\tAll nodes:{0}", allNodes.Count());

            //get geometry objects with similar volume
            List<Node> matchVolumeNodes = allNodes
                .Where(n =>
                    n.IsSuperClassOf(SuperClassID.GeometricObject) && //get all geometry objects
                    !n.IsClassOf(ClassID.TargetObject) && //exclude any light Target
                    volumes.IndexOf(n.Object.GetVolume()) != -1
                 )
                .Select(n => n)
                .ToList();

            Kernel.WriteLine("\tobjects count:{0}", matchVolumeNodes.Count());

            //execute action with undo enabled
            Kernel._TheHold.Begin();
            SelectNodes(matchVolumeNodes, true);
            Kernel._TheHold.Accept("Select Simillar");
            Kernel._TheHold.End();*/
        }
    }
}


/*//https://forums.cgsociety.org/t/get-uv-faces-area/2058271/5
//not good to pick up all data for calculating area of one face
//TODO take area from vertices
public static double GetFaceArea(IMNMesh m, int fi) { //TODO -not tested -not used

    Kernel.WriteLine("\tSelected polygon index:{0} total:{1}", fi + 1, m.FNum); //+1 Max count
    return new Poly(m).Area(fi); //Poly object will be filled with All face indexes and vertices positions

    IMNFace f = m.F(fi);

    Kernel.WriteLine("face verts:{0} count:{1}", f.Vtx, f.Vtx.Count);

    ITab<int> triangles = Kernel._Global.Tab.Create<int>();
    f.GetTriangles(triangles); // get the tri (as indices of the face vert array)
    int numtriangles = f.Deg - 2;
    for ( int t = 0; t < numtriangles; ++t ) {

        int i = t * 3;
        int v1 = triangles[i];
        int v2 = triangles[i + 1];
        int v3 = triangles[i + 2];
        Kernel.WriteLine("\t\tFace:{0} v1:{1} v1:{2} v1:{3}", i, v1,  v2, v3);
        //AreaOfTriangle
    }*/


/*Kernel.WriteLine("first vert:{0}", triangles[0]);

Kernel.WriteLine("\tPolygon vers:{0} total triangles:{1}", triangles.Count, m.TriNum);

IMesh imesh = Kernel._Global.Mesh.Create();
m.OutToTri(imesh);
for (int i = 0; i < triangles.Count; i++ ) {

    //imesh.Faces[i]
    // v2:{2} v3:{3}
    //ITab tab = tris[i];
    Kernel.WriteLine("\t\ti:{0} tris:{1}", i+1, triangles[i]);
}
//return 0.0;
}*/


/*double sum = 0.0;
m.faces.ForEach(f => sum += GetFaceArea(m, f));
return sum;*/
/*
We can grab the faces as a List and iterate them in .NET API.
IMesh mesh = triOriginal.Mesh;
IList<IFace> faces = triOriginal.Mesh.Faces;
Get the vertex from the original object's face we are processing
IPoint3 point = triOriginal.Mesh.GetVert(( int )face.GetVert(i));
IMNFace f = polyObj.Mesh.F(i);
IMNVert vert = polyObj.Mesh.V(nvindex);
IMNEdge edge = polyNewFace.Mesh.E(nedge);


 * 
 * public static List<int> convertMeshFaceToPolyFace(Mesh m, Poly p, int f) {

    List<int> verts = ( meshop.getVertsUsingFace m f) as array;
    List<int> facesPerVert = new List<int>() { };
    foreach ( int v in verts ) {
        local faces = polyop.getFacesUsingVert p v;
         facesPerVert.Add(faces);
     }
    local deltaFaces = facesPerVert[1];
    for i = 2 to facesPerVert.count do deltaFaces = deltaFaces * facesPerVert[i];
    return ( deltaFaces as array )[1];
}*/
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
