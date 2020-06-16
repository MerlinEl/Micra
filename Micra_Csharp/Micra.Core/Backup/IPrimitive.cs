using Autodesk.Max;
using Autodesk.Max.MaxSDK.Util;
using System;

namespace Micra.Core {
    //
    // Summary:
    //     This is the base class for the creation of Geometric Autodesk.Max.IObject plug-ins.
    //     This class represents an object that has geometry and is renderable.
    public interface IPrimitive : IObject, IBaseObject, IReferenceTarget, IReferenceMaker, IAnimatable, IInterfaceServer, IEquatable<IInterfaceServer>, IDisposable, INativeObject, INoncopyable, IEquatable<INoncopyable> {
        //
        // Summary:
        //     If an object creates different meshes depending on the particular instance (view-dependent)
        //     it should return nonzero; otherwise 0.
        bool IsInstanceDependent {
            get;
        }

        //
        // Summary:
        //     Objects may supply multiple render meshes ( e.g. particle systems). If this method
        //     returns a positive number, then GetMultipleRenderMesh and GetMultipleRenderMeshTM
        //     will be called for each mesh, instead of calling GetRenderMesh. The number of
        //     render meshes, or 0 to indicate that multiple meshes aren't supported.
        int NumberOfRenderMeshes {
            get;
        }

        //
        // Summary:
        //     Returns TRUE if this object can do displacement mapping; otherwise FALSE.
        bool CanDoDisplacementMapping {
            get;
        }

        //
        // Summary:
        //     This method should be implemented by all renderable GeomObjects. It provides
        //     a mesh representation of the object for use by the renderer. Primitives that
        //     already have a mesh cached can just return a pointer to it (and set needDelete
        //     to FALSE). Implementations of this method which take a long time should periodically
        //     call View::CheckForRenderAbort() to see if the user has canceled the render.
        //     If canceled, the function can either return NULL, or return a non null pointer
        //     with the appropriate value for needDelete. (If needDelete is TRUE a non-null
        //     mesh will be deleted.) A pointer to the mesh object.
        //
        // Parameters:
        //   t:
        //     The time to get the mesh.
        //
        //   inode:
        //     The node in the scene.
        //
        //   view:
        //     If the renderer calls this method it will pass the view information here. See
        //     Class .
        //
        //   needDelete:
        //     Set to TRUE if the renderer should delete the mesh, FALSE otherwise.
        IMesh GetRenderMesh(int t, IINode inode, IView view, ref int needDelete);

        //
        // Summary:
        //     For multiple render meshes, this method must be implemented. set needDelete to
        //     TRUE if the render should delete the mesh, FALSE otherwise.
        //
        // Parameters:
        //   t:
        //     The time at which to obtain the mesh.
        //
        //   inode:
        //     The pointer to the node.
        //
        //   view:
        //     A reference to the view.
        //
        //   needDelete:
        //     TRUE if the mesh needs to be deleted, otherwise FALSE.
        //
        //   meshNumber:
        //     Specifies which of the multiplie meshes is being asked for.
        IMesh GetMultipleRenderMesh(int t, IINode inode, IView view, ref int needDelete, int meshNumber);

        //
        // Summary:
        //     For multiple render meshes, this method must be implemented.
        //
        // Parameters:
        //   t:
        //     The time at which to obtain the mesh.
        //
        //   inode:
        //     The pointer to the node.
        //
        //   view:
        //     A reference to the view.
        //
        //   meshNumber:
        //     Specifies which of the multiplie meshes is being asked for.
        //
        //   meshTM:
        //     Should be returned with the transform defining the offset of the particular mesh
        //     in object space.
        //
        //   meshTMValid:
        //     Should contain the validity interval of meshTM.
        void GetMultipleRenderMeshTM(int t, IINode inode, IView view, int meshNumber, IMatrix3 meshTM, IInterval meshTMValid);

        //
        // Summary:
        //     This method provides a patch mesh representation of the object for use by the
        //     renderer. If this method returns NULL, then GetRenderMesh() will be called. A
        //     pointer to the patch mesh. See Class Autodesk.Max.IPatchMesh.
        //
        // Parameters:
        //   t:
        //     The time to get the patch mesh.
        //
        //   inode:
        //     The node in the scene.
        //
        //   view:
        //     If the renderer calls this method it will pass the view information here. See
        //     Class .
        //
        //   needDelete:
        //     Set to TRUE if the renderer should delete the patch mesh, FALSE otherwise.
        IPatchMesh GetRenderPatchMesh(int t, IINode inode, IView view, ref int needDelete);
    }
}
