using Autodesk.Max;
using Micra.Core.Extensions;
using Micra.Core.Utils;
using System;
using System.Collections.Generic;
using System.Linq;

namespace Micra.Core.Ops {
    public class GeoOps {

        public static double GetEdgeLength(IMNMesh m, int ei) {

            IMNEdge edge = m.E(ei);
            IMNVert vert1 = m.V(edge.V1);
            IMNVert vert2 = m.V(edge.V2);
            Point3 p1 = new Point3(vert1.P);
            Point3 p2 = new Point3(vert2.P);
            double dist = Point3.Distance(p1, p2);
            Max.Log("Edge:{0} Verts:#({1}, {2}) Length:{3}", ei, edge.V1, edge.V2, dist);
            return dist;
        }

        public static void SelectSimillarFaces(Node n, bool byArea, bool byVcount, float areaSizeTolerance = 0, int vertsCountTolerance = 0) {

            Max.Log("\tareaSizeTolerance:{0} vertsCountTolerance:{1}", areaSizeTolerance, vertsCountTolerance);
            Geo geo = new Geo(n);
            // collect selected faces (area, vertnum)
            var fsel = geo.GetSelectedFaces();

            Max.Log("SelectSimillarFaces > The obj:{0} fse:{1}", n.Name, fsel.Count);
            List<GeomCompareData> objData = fsel
                .Select(f => new GeomCompareData(f, Calc.RoundArea(geo.GetFaceArea(f), areaSizeTolerance), geo.GetFaceVerts(f).Count))
                .ToList();
            // get only unique types
            List<GeomCompareData> distinctObjData = objData
                .GroupBy(o => new { o.AREA, o.VNUM })
                .Select(g => g.First())
                .ToList();
            // print data
            Max.Log("\t\tSource unique faces:{0} data:\n\t\t\t{1}", distinctObjData.Count(), String.Join("\n\t\t\t", distinctObjData));
            //compare objData with all faces
            Max.Log("\t\tAll nodes faces:{0}", geo.NumFaces);
            List<int> matchFaces = new List<int>() { };
            for ( int f = 0; f < geo.NumFaces; f++ ) {

                if ( objData.FindIndex(o => o.MatchBy(
                         new GeomCompareData(f, Calc.RoundArea(geo.GetFaceArea(f), areaSizeTolerance), geo.GetFaceVerts(f).Count),
                         byArea, byVcount
                     )) == -1
                 ) continue; //skip faces with different area or verts count or both
                if ( matchFaces.IndexOf(f) == -1 ) matchFaces.Add(f); // add only unique face indexes
            }

            Max.Log("\tSimillar faces count:{0}", matchFaces.Count());
            //matchNodes.ForEach(o => Max.Log("\t\tIndex:{0}\n\t\t\tArea:{1}\n\t\t\tVcount:{2}", o.ID, o.Object.GetArea(), o.Object.NumVerts));

            //execute action with undo enabled
            Kernel.Undo.Begin();
            geo.SetSelectedFaces(matchFaces);
            Kernel.Undo.Accept("Select Simillar Faces");
            Kernel.Undo.End();
        }

        public static void SelectSimillarElements(Node n, bool byArea, bool byVcount, float areaSizeTolerance = 0, int vertsCountTolerance = 0) {
            Max.Log("SelectSimillarElements > The obj:{0}", n.Name);
            throw new NotImplementedException();
        }

        public static void SelectSimillarEdges(Node n, float areaSizeTolerance = 0) {

            Max.Log("SelectSimillarEdges > The obj:{0}", n.Name);
            Geo geo = new Geo(n);

            //get unique length edges
            var esel = geo.GetSelectedEdges();
            List<double> srcLengths = esel
                    .Select(i => Calc.RoundArea(geo.GetEdgeLength(i), areaSizeTolerance)).Distinct()
                    .ToList();
            Max.Log("\t({0}) Lengths:{1}\n", srcLengths.Count, string.Join("\n\t\t", srcLengths));

            //get edges with similar volume
            var allEdges = geo.AllEdges;
            Max.Log("\tAll edges:{0}", allEdges.Count());
            List<int> matchEdges = allEdges
                .Where(ei => srcLengths.IndexOf(

                    Calc.RoundArea(geo.GetEdgeLength(ei), areaSizeTolerance)
                 ) != -1 )
                .Select(ei => ei)
                .ToList();

            Max.Log("\tedges count:{0}", matchEdges.Count());

            //execute action with undo enabled
            Kernel.Undo.Begin();
            geo.SetSelectedEdges(matchEdges, true);
            Kernel.Undo.Accept("Select Simillar Edges");
            Kernel.Undo.End();
        }
        public static void SelectSimillarEdgeLoops(Node node, float areaSizeTolerance = 0) { }

        public static void UnhideGeometry(Node node) {

            Geo geo = new Geo(node);
            //TODO add master switch for Modifiers like:(Unwrap, UvMap, ...)
            switch ( Max.SubObjectLevel ) {

                case 1: geo.UnhideVerts(); break;
                case 2: geo.UnhideEdges(); break;
                case 3:
                if ( node.IsClassOf(ClassID.EditableMesh) ) {

                    geo.UnhideFaces();

                } else if ( node.IsClassOf(ClassID.EditablePoly) ) {

                    geo.UnhideEdges();
                }
                break;
                case 4: geo.UnhideFaces(); break;
                case 5: geo.UnhideFaces(); break;
            }
        }

        public static void HideGeometry(Node node, bool selected) {

            Geo geo = new Geo(node);
            //TODO replace with switch for Modifiers like:(Unwrap, UvMap, ...)
            switch ( Max.SubObjectLevel ) {

                case 1: geo.HideVerts(selected); break;
                case 2: geo.HideEdges(selected); break;
                case 3:
                if ( node.IsClassOf(ClassID.EditableMesh) ) {

                    geo.HideFaces(selected);

                } else if ( node.IsClassOf(ClassID.EditablePoly) ) {

                    geo.HideEdges(selected);
                }
                break;
                case 4: geo.HideFaces(selected); break;
                case 5: geo.HideFaces(selected); break;
            }
        }
    }
    internal class GeomCompareData {

        public int ID { get; } = 0;
        public double AREA { get; } = 0.0;
        public int VNUM { get; } = 0;
        public GeomCompareData(int elementIndex, double area = 0, int vnum = 0) {

            ID = elementIndex;
            AREA = area;
            VNUM = vnum;
        }
        public bool MatchBy(GeomCompareData cd, bool byArea, bool byVcount) {

            if ( byArea == true && byVcount == true ) return cd.AREA != -1 && cd.VNUM != -1 && cd.AREA == AREA && cd.VNUM == VNUM;
            if ( byArea ) return cd.AREA != -1 && cd.AREA == AREA;
            if ( byVcount ) return cd.VNUM != -1 && cd.VNUM == VNUM;
            return false;
        }
        public override string ToString() {
            return String.Format("area:{0} vnum:{1}", AREA, VNUM);
        }
    }
}


/*Max.Log("first vert:{0}", triangles[0]);

Max.Log("\tPolygon vers:{0} total triangles:{1}", triangles.Count, m.TriNum);

IMesh imesh = Kernel._Global.Mesh.Create();
m.OutToTri(imesh);
for (int i = 0; i < triangles.Count; i++ ) {

    //imesh.Faces[i]
    // v2:{2} v3:{3}
    //ITab tab = tris[i];
    Max.Log("\t\ti:{0} tris:{1}", i+1, triangles[i]);
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
