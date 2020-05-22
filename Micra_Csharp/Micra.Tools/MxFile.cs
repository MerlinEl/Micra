using Autodesk.Max;
using System.IO;

namespace Micra.Tools {
    class MxFile {
        /// <summary>
        /// This function writing bitmap File
        /// </summary>
        /// <param name="bitmap">Bitmap properties</param>
        /// <param name="global">Your Global</param>
        /// <param name="outputPath">File writing location</param>
        public static void SaveBitmap(IBitmap bitmap, IGlobal global, string outputPath) {

            IBitmapInfo bitmapInfo = global.BitmapInfo.Create();
            bitmapInfo.SetName(outputPath);

            //Image file format can set using this function
            /*bitmapInfo.SetType(17);
            bitmapInfo.SetDevice("DDS Image File"); */

            bitmap.OpenOutput(bitmapInfo);
            bitmap.Write(bitmapInfo, 0);
            bitmap.Close(bitmapInfo, 0);
            global.TheManager.DelBitmap(bitmap);
        }

        /// <summary>
        /// This Function is loading textures.
        /// </summary>
        /// <param name="path">File Location</param>
        /// <param name="global">Your IGlobal param.</param>
        public static void LoadBitmap(IGlobal global, string path) {

            IBitmap bitmap = global.TheManager.NewBitmap;
            IBitmapInfo bitmapInfo = global.BitmapInfo.Create();
            bitmapInfo.SetName(path);
            global.TheManager.LoadInto(bitmapInfo, bitmap, false);
            //MxSet.LogLi("Height of image:" + bitmap.Height.ToString());
        }

        #region Untested

        public static string FbxExport(string filePath) {

            string fullPath = Path.Combine(filePath);
            IClass_ID exporterID = MxGet.Global.Class_ID.Create(0x27227747, 0xDD6978);
            MxGet.Interface.ExportToFile(fullPath, true, 1, exporterID);
            return fullPath;
        }

        #endregion
    }
}
