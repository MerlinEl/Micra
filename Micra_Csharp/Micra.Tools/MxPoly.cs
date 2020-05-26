﻿using Autodesk.Max;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Media.Media3D;

namespace Micra.Tools {
    class MxPoly {
        internal static void SelectSimillarElements() {
            throw new NotImplementedException();
        }

        internal static float GetGeometryVolume(IINode obj) {

            IObjectState iState = obj.EvalWorldState(0, true);
            IObject iObj = iState.Obj;
            ITriObject iTri = (ITriObject)iObj.ConvertToType(0, MxGet.Global.TriObjectClassID);
            IMesh mesh = iTri.Mesh; //Autodesk.Max.Wrappers.Mesh
            MxSet.LogLi("\tGetGeometryVolume obj:{0} trimesh:{1} NumFaces:{2}", obj.Name, mesh.ToString(), mesh.NumFaces);

            double objVolume = 0.0;

            foreach ( IFace f in mesh.Faces) {

                IntPtr fverts = f.AllVerts;
                IPoint3 v0 = mesh.GetVert((int)( f.GetVert(0) ));
                IPoint3 v1 = mesh.GetVert((int)( f.GetVert(1) ));
                IPoint3 v2 = mesh.GetVert((int)( f.GetVert(2) ));

                Vector3D v3 = MxMath.VectorFromPoints(v1, v0);
                Vector3D v4 = MxMath.VectorFromPoints(v2, v0);
                Vector3D v5 = MxMath.VectorFromPoint(v0);
                objVolume += Vector3D.DotProduct(Vector3D.CrossProduct(v3, v4), v5);
            }
            return (float)(objVolume / mesh.Faces.Count);
        }

        internal static List<IPoint3> GetVerticesPositions(IINode obj) { //not tested not used

            IObjectState iState = obj.EvalWorldState(0, true);
            IObject iObj = iState.Obj;
            ITriObject iTri = (ITriObject)iObj.ConvertToType(0, MxGet.Global.TriObjectClassID);
            IMesh mesh = iTri.Mesh;

            /// OBJECT TRANSFORM MATRIX
            IInterval iTimeRange = obj.GetTimeRange(0);
            //IMatrix3 worldTm = obj.GetObjTMAfterWSM(0, iTimeRange);
            IMatrix3 tmObj2World = obj.GetObjectTM(0, iTimeRange); // where i is your IINode

            List<IPoint3> points = new List<IPoint3> { };

            for ( int vertID = 0; vertID < mesh.NumVerts; vertID++ ) {
                IPoint3 vertObjectSpace = mesh.GetVert(vertID);
                IPoint3 vertWorldSpace = tmObj2World.PointTransform(vertObjectSpace); //correction
                //IPoint3 vertWorldSpace = worldTm.PointTransform(vertObjectSpace);
                points.Add(vertWorldSpace);

                MxSet.LogLi(vertID.ToString() + ": " + vertWorldSpace.X.ToString() + ", " + vertWorldSpace.Y.ToString() + ", " + vertWorldSpace.Z.ToString());
            }
            return points;
        }
    }
}


/*

        internal static float GetGeometryVolume(IINode obj) {

            IObjectState iState = obj.EvalWorldState(0, true);
            IObject iObj = iState.Obj;
            ITriObject iTri = (ITriObject)iObj.ConvertToType(0, MxGet.Global.TriObjectClassID);
            IMesh mesh = iTri.Mesh; //Autodesk.Max.Wrappers.Mesh
            MxSet.LogLi("\tGetGeometryVolume obj:{0} trimesh:{1} numVerts:{2}", obj.Name, mesh.ToString(), mesh.NumVerts);
            List<IPoint3> points = new List<IPoint3> { };
            for ( int vertID = 0; vertID < mesh.NumVerts; vertID++ ) {

                IPoint3 p = mesh.GetVert(vertID);
                MxSet.LogLi("\tpos [{0}, {1}, {2}]", p.X, p.Y, p.Z);
                points.Add(p);
            }
            return MxMath.GetAreaFromPoints(points);
        }
 * 
                var invertedWorldMatrix = GetInvertWorldTM(meshNode, 0);
                var offsetTM = GetOffsetTM(meshNode, 0);
 * 
 * 
fn CalculateVolumeAndCenterOfMass obj =
(
local Volume= 0.0
local Center= [0.0, 0.0, 0.0]
local theMesh = snapshotasmesh obj
local numFaces = theMesh.numfaces
for i = 1 to numFaces do
(
  local Face= getFace theMesh i
  local vert2 = getVert theMesh Face.z
  local vert1 = getVert theMesh Face.y
  local vert0 = getVert theMesh Face.x
  local dV = Dot (Cross (vert1 - vert0) (vert2 - vert0)) vert0
  Volume+= dV
  Center+= (vert0 + vert1 + vert2) * dV
)
delete theMesh
Volume /= 6
Center /= 24
Center /= Volume
#(Volume,Center)
)
 --Call the function on a geometry object - the result will be a list --containing the Volume and the Center of mass in local space.
theVolAndCom = CalculateVolumeAndCenterOfMass $Sphere01
--To get the world space of the Center of Mass just like in the Utility, --you have to do some extra work:
theComInWorld = theVolAndCom[2] * $Sphere01.objectTransform
 */
