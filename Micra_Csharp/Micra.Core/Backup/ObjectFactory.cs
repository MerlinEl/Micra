using Autodesk.Max;

namespace Micra.Core {
    public static class ObjectFactory {
        private static object Global = GlobalInterface.Instance.COREInterface17;

        public static IClass_ID CreateClassID(uint firstId, uint secondId) {
            return Global.Class_ID.Create(firstId, secondId);
        }

        public static IFPValue CreateFPValue() {
            return Global.FPValue.Create();
        }

        public static IPath CreatePath(IPath existingPath) {
            return Global.MaxSDK.Util.Path.Create(existingPath);
        }

        public static IPath CreatePath(string path) {
            return Global.MaxSDK.Util.Path.Create(path);
        }

        public static IBitmapInfo CreateBitmapInfo() {
            return Global.BitmapInfo.Create();
        }

        public static IBitmap CreateBitmap(IBitmapInfo info) {
            return Global.CreateBitmapFromBitmapInfo(info);
        }

        public static IBox3 CreateBox3() {
            return Global.Box3.Create();
        }

        public static IPoint3 CreatePoint3() {
            return Global.Point3.Create();
        }

        public static IMatrix3 CreateMatrix3() {
            return Global.Matrix3.Create(true);
        }

        public static IMesh CreateMesh() {
            return Global.Mesh.Create();
        }

        public static ITab<T> CreateITab<T>() {
            return Global.Tab.Create<T>();
        }

        public static IMatrix3 CreateMatrix3(IMatrix3 matrix3) {
            return Global.Matrix3.Create(true).MultiplyBy(matrix3);
        }

        public static IInterval CreateInterval() {
            return Global.Interval.Create();
        }
    }
}
