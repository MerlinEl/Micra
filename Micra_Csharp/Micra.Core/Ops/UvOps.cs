using Autodesk.Max;
using Autodesk.Max.Plugins;

namespace Micra.Core.Ops {
    class UvOps {
        /// <summary>
        /// Return uv coordinate by index
        /// </summary>
        /// <param name="node">node </param>
        /// <param name="coordinateIndex">index of uv array </param>
        /// /// <param name="global">IGlobal object.</param>
        /// <param name="mapNumber">UVW Map Number</param>
        public Uv GetUvCoordinate(IINode node, int coordinateIndex, IGlobal global, int mapNumber = 1) {
            IObjectState objState = node.EvalWorldState(0, true);
            IObject iObj = objState.Obj;
            if ( iObj == null ) {
                return null;
            }
            TriObject triObject = (TriObject)iObj.ConvertToType(0, global.TriObjectClassID);

            if ( triObject == null ) {
                return null;
            }

            IMesh mesh;
            mesh = triObject.Mesh_;

            if ( coordinateIndex >= mesh.Maps[mapNumber].NumVerts ) {
                return null;
            }

            Uv uv = new Uv();
            //Uv Array is arranged in a row
            //Texture verts(Tv) has all uv coordinates
            uv.X = mesh.Maps[mapNumber].Tv[coordinateIndex * 3];
            uv.Y = mesh.Maps[mapNumber].Tv[coordinateIndex * 3 + 1];

            return uv;
        }
    }
    public class Uv {
        public float X { get; set; }
        public float Y { get; set; }
        public float Z { get; set; }
    }
}

