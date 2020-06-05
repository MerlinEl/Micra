namespace Micra.Core {
    using Autodesk.Max;
    using System;
    using System.Collections.Generic;

    /*
    // Maxscript TEST
    delete objects

    gc()

    st=timestamp(); sh=heapfree

    SuperCube.createSuperCube 40
		
	format "time:% heap:%\n" (timestamp()-st) (sh-heapfree)
    */
    namespace PathScripts {

        class SuperCube {
            static public IGlobal global = GlobalInterface.Instance;
            static public IInterface14 ip = global.COREInterface14;

            static public void createSuperCube(int numCubes) {
                int[][] Faces = new int[12][] { new int[3] { 0, 2, 3 }, new int[3] { 3, 1, 0 }, new int[3] { 4, 5, 7 }, new int[3] { 7, 6, 4 },
                                                        new int[3] { 0, 1, 5 }, new int[3] { 5, 4, 0 }, new int[3] { 1, 3, 7 }, new int[3] { 7, 5, 1 },
                                                        new int[3] { 3, 2, 6 }, new int[3] { 6, 7, 3 }, new int[3] { 2, 0, 4 }, new int[3] { 4, 6, 2 }};
                float[][] Verts = new float[8][] { new float[3] { -0.5f, -0.5f, -0.5f }, new float[3] { 0.5f, -0.5f, -0.5f }, new float[3] { -0.5f, 0.5f, -0.5f }, new float[3] { 0.5f, 0.5f, -0.5f },
                                                           new float[3] { -0.5f, -0.5f, 0.5f }, new float[3] { 0.5f, -0.5f, 0.5f }, new float[3] { -0.5f, 0.5f, 0.5f }, new float[3] { 0.5f, 0.5f, 0.5f }};
                uint[] theElementSmooth = new uint[12] { 2, 2, 4, 4, 8, 8, 16, 16, 32, 32, 64, 64 };

                IClass_ID cid = global.Class_ID.Create((uint)BuiltInClassIDA.EDITTRIOBJ_CLASS_ID, 0);

                // Create a new TriObject.
                object objectEditMesh = ip.CreateInstance(SClass_ID.Geomobject, cid as IClass_ID);
                // Create a new node to hold it in the scene.
                IObject objBaseObject = (IObject)objectEditMesh;
                IINode node = global.COREInterface.CreateObjectNode(objBaseObject);
                // Name it unique.
                string newName = "SuperCube";
                //ip.MakeNameUnique(ref newName);
                node.Name = newName;
                // Cast to TriObject
                ITriObject triNew = objBaseObject as ITriObject;

                int nTotal = numCubes * numCubes * numCubes;
                Random r = new Random();
                int countVerts = 0;
                int actualVert = 0;
                int actualFace = 0;
                double range = 1.0 - 0.1;

                IMesh TMESH = triNew.Mesh;

                // Setup the new TriObject with number of faces and verts
                TMESH.SetNumFaces(12 * nTotal, false, false);
                TMESH.SetNumVerts(8 * nTotal, false, false);
                TMESH.SetNumTVerts(8 * nTotal, false);

                IList<IFace> MESH_FACES = TMESH.Faces;

                for ( int z = 0; z < numCubes; z++ ) {
                    for ( int y = 0; y < numCubes; y++ ) {
                        for ( int x = 0; x < numCubes; x++ ) {
                            actualVert = ( 8 * countVerts );
                            actualFace = ( 12 * countVerts );
                            float rng = (float)( r.NextDouble() * range + 0.1 );
                            for ( int v = 0; v < 8; v++ ) {
                                TMESH.SetVert(v + actualVert, Verts[v][0] * rng + x, Verts[v][1] * rng + y, Verts[v][2] * rng + z);
                                TMESH.SetTVert(v + actualVert, rng, rng, 0);
                            }
                            for ( int f = 0; f < 12; f++ ) {
                                IFace FACE = MESH_FACES[f + actualFace];
                                FACE.SetVerts(Faces[f][0] + actualVert, Faces[f][1] + actualVert, Faces[f][2] + actualVert);
                                FACE.SetEdgeVisFlags(EdgeVisibility.Vis, EdgeVisibility.Vis, EdgeVisibility.Invis);
                                FACE.SmGroup = theElementSmooth[f];
                            }
                            countVerts++;
                        }
                    }
                }

                // Assign identity transform, position and center pivot.
                //IMatrix3 tm = global.Matrix3.Create(); tm.IdentityMatrix();
                //IPoint3 pt0 = global.Point3.Create(0, 0, 0);
                //node.SetNodeTM(0, tm);
                //node.ObjOffsetPos = pt0;
                //node.CenterPivot(0, false);
                // make it drawable.
                TMESH.InvalidateGeomCache();
                //ip.RedrawViews(0, RedrawFlags.Normal, null);
            }

        }
    }
}
