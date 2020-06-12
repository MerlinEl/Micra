using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Micra.Core {
    class EnumFlags {
        //http://docs.autodesk.com/3DSMAX/16/ENU/3ds-Max-SDK-Programmer-Guide/index.html?url=cpp_ref/group___m_n_mesh___component___flags.html,topicNumber=cpp_ref_group___m_n_mesh___component___flags_htmleba9ab06-cf2e-4b8f-9af5-efd4566217c2,hash=gac2a9b609a4dcf10ff24ec73c9ec62df7
        //for MNVerts, MNEdges, and MNFaces
        internal enum MNMeshComponent : uint {
            //Geometry Flags
            MN_SEL = 1 << 0, //Indicates that a component is selected.
            MN_DEAD = 1 << 1, //Indicates that a component is not used and should be ignored.
            MN_TARG = 1 << 2, //Indicates that a component is targeted.
            MN_BACKFACING = 1 << 3, //Indicates that the vertex faces "backwards" in the current viewport.
            MN_HIDDEN = 1 << 4,
            MN_CACHEINVALID = 1 << 5,
            MN_INFOREGROUND = 1 << 7, //Tags a face as not renderable but can be hit-test.
            MN_WHATEVER = 1 << 16,
            MN_LOCAL_SEL = 1 << 17, //Alternate selections (not passed up the pipe).
            MN_HITTEST_CULLED = 1 << 18, //Used to indicate culled components (neither selected nor not selected) in window-region hit testing.
            MN_USER = 1 << 24, //Any value above this can be used by applications.
            //Vertex Flags
            MN_VERT_DONE = 1 << 8, //Set in algorithms that may accidentally revisit the same vertex (MNVertext twice, to keep them from processing it the second time.
            MN_VERT_WELDED = 1 << 9, //Used by MNMesh::WeldBorderVerts()
            MN_VERT_SUBDIVISION_CORNER = 1 << 10, //Track which vertices are direct "descendants" of the original cage vertices in subdivision.
            //Edge flags
            MN_EDGE_INVIS = 1 << 8, //Both faces using this edge consider it invisible.
            MN_EDGE_NOCROSS = 1 << 9, //This edge should not be crossed in algorithms like MNMesh::SabinDoo that can mix faces across edges.
            MN_EDGE_MAP_SEAM = 1 << 10, //Track which edges are direct descendants of the original cage edges in subdivision.
            MN_EDGE_SUBDIVISION_BOUNDARY = 1 << 11, //Track unwanted edges created by Cut, so they might be removed later.
            MN_EDGE_CUT_EXTRA = 1 << 12
        }
    }
}
