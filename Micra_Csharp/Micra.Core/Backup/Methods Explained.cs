using Autodesk.Max;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Micra.Core {
    class MethodsExplained {
        /// <summary>
        /// Sample shows how get an objects state and iterate it's mesh
        /// to create new individual face objects
        /// </summary>
        public void InterateMeshObj() {
            try {

                IGlobal global = Autodesk.Max.GlobalInterface.Instance;
                IInterface14 ip = global.COREInterface14;

                // Get the first selected node...
                IINode node = ip.GetSelNode(0);

                if ( node == null ) {
                    ip.PushPrompt("Nothing Selected! Select something first to explode it into faces.");
                    return;
                }


                // Get it's current object state. If a modifier has been applied, for example,
                // it is going to return the OS of the mesh in it's current form in the timeline.
                IObjectState os = node.ObjectRef.Eval(ip.Time);

                // Now grab the object itself.
                IObject objOriginal = os.Obj;

                // Let's make sure it is a TriObject, which is the typical kind of object with a mesh
                if ( !objOriginal.IsSubClassOf(global.TriObjectClassID) ) {
                    // If it is NOT, see if we can convert it...
                    if ( objOriginal.CanConvertToType(global.TriObjectClassID) == 1 )
                        objOriginal = objOriginal.ConvertToType(ip.Time, global.TriObjectClassID);
                    else
                        return;
                }

                // Store the orginal transform positioning data
                IMatrix3 mat = node.GetNodeTM(0, null);
                IPoint3 ptOffsetPos = node.ObjOffsetPos;
                IQuat quatOffsetRot = node.ObjOffsetRot;
                IScaleValue scaleOffsetScale = node.ObjOffsetScale;

                // Now we should be safe to know it is a TriObject and we can cast it as such.
                // An exception will be thrown...
                ITriObject triOriginal = objOriginal as ITriObject;


                // Let's first setup a class ID for the type of objects are are creating.
                // New TriObject in this case to hold each face.
                IClass_ID cid = global.Class_ID.Create((uint)BuiltInClassIDA.TRIOBJ_CLASS_ID, 0);

                // We can grab the faces as a List and iterate them in .NET API.
                IList<IFace> faces = triOriginal.Mesh.Faces;
                foreach ( IFace face in faces ) {
                    // Create a new TriObject for each new face.
                    object objectNewFace = ip.CreateInstance(SClass_ID.Geomobject, cid as IClass_ID);

                    // Create a new node to hold it in the scene.
                    IObject objNewFace = (IObject)objectNewFace;
                    IINode n = global.COREInterface.CreateObjectNode(objNewFace);

                    // Name it and ensure it is unique...
                    string newname = "ADN-Sample-Face";
                    ip.MakeNameUnique(ref newname);
                    n.Name = newname;

                    // Based on what we created above, we can safely cast it to TriObject
                    ITriObject triNewFace = objNewFace as ITriObject;

                    // Setup the new TriObject with 1 face, and the vertex count from the original object's face we are processing
                    triNewFace.Mesh.SetNumFaces(1, false, false);
                    triNewFace.Mesh.SetNumVerts(face.V.Count(), false, false);

                    // Finish setting up the face (always face '0' because there will only be one per object).
                    triNewFace.Mesh.Faces[0].SetVerts(0, 1, 2);
                    triNewFace.Mesh.Faces[0].SetEdgeVisFlags(EdgeVisibility.Vis, EdgeVisibility.Vis, EdgeVisibility.Vis);
                    triNewFace.Mesh.Faces[0].SmGroup = 2;

                    // Now, for each vertex, get the old face's points and store into new.
                    for ( int i = 0; i < face.V.Count(); i++ ) {
                        //Get the vertex from the original object's face we are processing
                        IPoint3 point = triOriginal.Mesh.GetVert((int)face.GetVert(i));
                        // Set the vertex point in the new face vertex
                        triNewFace.Mesh.SetVert(i, point);
                    }

                    // update transform to match object being exploded.
                    n.SetNodeTM(0, mat);
                    n.ObjOffsetPos = ptOffsetPos;
                    n.ObjOffsetRot = quatOffsetRot;
                    n.ObjOffsetScale = scaleOffsetScale;
                    n.ObjOffsetPos = ptOffsetPos;
                    n.CenterPivot(0, false);

                    // make it draw.
                    triNewFace.Mesh.InvalidateGeomCache();
                }


            } catch ( System.Exception ex ) {
                Kernel.WriteLine("Exception occurred: " + ex.Message);
            }
        }
        public void GetObjectsByLayer() {
            //Access scene layers
            //GlobalInterface.Instance.COREInterface13.LayerManager.GetLayer(i);
            int layersCount = Autodesk.Max.MaxPlus.LayerManager.GetNumLayers();
            for ( int i = 0; i < layersCount; i++ ) {
                var layer = Autodesk.Max.MaxPlus.LayerManager.GetLayer(i);
                Autodesk.Max.MaxPlus.INodeList nodes = layer.GetNodes();

                //Each node is Autodesk.Max.MaxPlus.INode 
                foreach ( var node in nodes.ToIEnumerable() ) {
                    node.Object.DoStuff();
                }
            }
        }
        public void GetSceneMaterials() {

            ITab<IMtlBase> materialsLib = GlobalInterface.Instance.COREInterface15.SceneMtls;

            foreach ( var materialBase in materialsLib.ToIEnumerable() ) {


            }
        }
        public class Extensions {
            //Access scene layers
            public static IEnumerable<Autodesk.Max.MaxPlus.INode> ToIEnumerable(this INodeList nodeList) {
                if ( nodeList == null ) {
                    yield break;
                }

                int count = nodeList.GetCount();
                for ( int i = 0; i < count; i++ ) {
                    yield return nodeList.GetItem(i);
                }
            }
            //materials
            public static IEnumerable<T> ToIEnumerable<T>(this ITab<T> itab) {
                if ( itab == null ) {
                    yield break;
                }

                for ( int i = 0; i < itab.Count; i++ ) {
                    yield return itab[i];
                }
            }
        }
    }
}
