using Autodesk.Max;
using System;

namespace Micra.Tools {
    public class McMax {
        [Flags]
        enum ChannelPartID : uint {
            // The topology channel - the face or polygon structures. 
            TOPO_CHANNEL = 1 << 0,
            // The vertices of the object. 
            GEOM_CHANNEL = 1 << 1,
            // The texture vertices and procedural mappings. 
            TEXMAP_CHANNEL = 1 << 2,
            // This is no longer used. 
            MTL_CHANNEL = 1 << 3,
            // The sub-object selection channel. 
            SELECT_CHANNEL = 1 << 4,
            // The current level of selection. 
            SUBSEL_TYPE_CHANNEL = 1 << 5,
            // The miscellaneous bits controlling the item's display. 
            DISP_ATTRIB_CHANNEL = 1 << 6,
            // The color per vertex channel. 
            VERTCOLOR_CHANNEL = 1 << 7,
            // The used internally by 3ds Max for stripping. 
            GFX_DATA_CHANNEL = 1 << 8,
            // Displacement approximation. 
            DISP_APPROX_CHANNEL = 1 << 9,
            // The channel used by extension channel objects. 
            EXTENSION_CHANNEL = 1 << 13,
            // The ObjectState Transform that flows down the pipeline. 
            TM_CHANNEL = 1 << 10,
            // For internal use. 
            EDGEVISIBILITY_CHANNEL = 1 << 11,
            // For internal use. 
            DONT_RECREATE_TRISTRIP_CHANNEL = 1 << 12,
            // This is no longer used. 
            //GLOBMTL_CHANNEL = 1 << 31,
            OBJ_CHANNELS = TOPO_CHANNEL | GEOM_CHANNEL | SELECT_CHANNEL | TEXMAP_CHANNEL | MTL_CHANNEL | SUBSEL_TYPE_CHANNEL | DISP_ATTRIB_CHANNEL | VERTCOLOR_CHANNEL | GFX_DATA_CHANNEL | DISP_APPROX_CHANNEL | EXTENSION_CHANNEL,
            ALL_CHANNELS = OBJ_CHANNELS | TM_CHANNEL, //| GLOBMTL_CHANNEL
            PART_GEOM = 10240 //test
        }
        //http://www.ersindemir.net/execute-max-script-with-c/
        public static void ExecuteScript() {

            ManagedServices.MaxscriptSDK.ExecuteMaxscriptCommand("format \"test\n\"");
        }

        public uint ChannelsChanged {
            get { return (uint)( ChannelPartID.PART_GEOM | ChannelPartID.TEXMAP_CHANNEL | ChannelPartID.VERTCOLOR_CHANNEL ); }
        }

        public static void CtmTest1() {

            var g = GlobalInterface.Instance;
            /*var mesh = g.CreateNewMesh();
            mesh.setNumVerts(4);
            mesh.setNumFaces(3);
            mesh.setVert(0, objSize * Point3(0.0, 0.0, 0.0));
            mesh.setVert(1, objSize * Point3(10.0, 0.0, 0.0));
            mesh.setVert(2, objSize * Point3(0.0, 10.0, 0.0));
            mesh.setVert(3, objSize * Point3(0.0, 0.0, 10.0));

            mesh.faces[0].setVerts(0, 1, 2);
            mesh.faces[0].setEdgeVisFlags(1, 1, 0);
            mesh.faces[0].setSmGroup(2);
            mesh.faces[1].setVerts(3, 1, 0);
            mesh.faces[1].setEdgeVisFlags(1, 1, 0);
            mesh.faces[1].setSmGroup(2);
            mesh.faces[2].setVerts(0, 2, 3);
            mesh.faces[2].setEdgeVisFlags(1, 1, 0);
            mesh.faces[2].setSmGroup(4);
            mesh.InvalidateGeomCache();*/

            //g.AcceleratorsEnabled

        }


    }
}


/*
//Returns the vertex position in object space
List<IINode> nodes = nodesFromHandles(objHandles);
foreach (IINode i in nodes)
{
    log(i.Name);
    IObjectState iState = i.EvalWorldState(0, true);
    IObject iObj = iState.Obj;
    ITriObject iTri = (ITriObject)iObj.ConvertToType(0, global.TriObjectClassID);
    IMesh mesh = iTri.Mesh;

    /// OBJECT TRANSFORM MATRIX
    IInterval iTimeRange = i.GetTimeRange(0);
    IMatrix3 worldTm = i.GetObjTMAfterWSM(0, iTimeRange);

    for (int vertID = 0; vertID < mesh.NumVerts; vertID++)
    {
        IPoint3 x = mesh.GetVert(vertID); /// RETURNS A BAD POSITION? RELATIVE TO WHAT MATRIX?
        IPoint3 v = worldTm.PointTransform(x);
        log(vertID.ToString() + ": " + v.X.ToString() + ", " + v.Y.ToString() + ", " + v.Z.ToString());
    }
}
//Returns the vertex position in object space, which is unfortunately not mentioned in the docs. 
//As you are interested in the positions in world space, you have to transform them using the following:
 * 
IMatrix3 tmObj2World= i.GetObjectTM(0, iTimeRange); // where i is your IINode
IPoint3 vertWorldSpace = tmObj2World.PointTransform(vertObjectSpace);
*/
