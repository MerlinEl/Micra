using Autodesk.Max;
using Micra.Tools.Properties;
using System.Data;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Xml;
using System.Xml.Linq;

namespace Micra.Tools {
    class MxFile {

        public static string ResolveRelativePath(string path) { //not tested not used

            if ( string.IsNullOrEmpty(MxGet.Interface.CurFilePath) ) {
                return path;
            }
            string dirName = MxGet.MaxPath();
            if ( !path.StartsWith("\\") ) {
                return path;
            }
            return string.Format(@"{0}{1}", dirName, path);
        }

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
            //Kernel.WriteLine("Height of image:" + bitmap.Height.ToString());
        }

        public static string GetSolutionDirectory(string currentPath = null) { //not used
            var directory = new DirectoryInfo(
                currentPath ?? Directory.GetCurrentDirectory());
            while ( directory != null && !directory.GetFiles("*.sln").Any() ) {
                directory = directory.Parent;
            }
            return directory.FullName;
        }

        #region Untested

        public static string FbxExport(string filePath) {

            string fullPath = Path.Combine(filePath);
            IClass_ID exporterID = MxGet.Global.Class_ID.Create(0x27227747, 0xDD6978);
            MxGet.Interface.ExportToFile(fullPath, true, 1, exporterID);
            return fullPath;
        }

        #endregion

        /// <summary> Read XML File from Resources
        ///     <example> 
        ///         <code>
        ///             example: XDocument MaxActionsXML = MxFile.GetXMLFromResources("MaxScriptActions.xml");
        ///         </code>
        ///     </example> 
        ///     <para>param: <paramref name="xmlFname"/> is XML file name</para>
        /// </summary>
        internal static XDocument GetXMLFromResources(string xmlFname) {

            DataSet ds = new DataSet();
            XDocument doc = XDocument.Parse(Resources.MaxScriptActions);
            ds.ReadXml(doc.CreateReader());
            return doc;
        }

        /// <summary> Get MaxScript Command From XML by Name
        ///     <example> 
        ///         <code>
        ///             example: MxFile.GetMaxScriptFromXML(MaxActionsXML, "SelFaces")
        ///         </code>
        ///     </example>
        ///     <para>param: <paramref name="xmlKey"/> is Command Name String</para>
        /// </summary>
        internal static string GetMaxScriptFromXML(XDocument xml, string xmlKey) {

            var list = xml.Root.Elements("item");
            var node = list.Cast<XElement>()
               .Where(n => n.FirstAttribute.Value == xmlKey)
               .Select(n => n)
               .FirstOrDefault();
            return node != null ? node.Value.ToString().TrimStart('\r', '\n') : "undefined";
        }
    }
}


/*
 *
// Getting path to the parent folder of the solution file using C#
string startupPath = Path.Combine(Directory.GetParent(System.IO.Directory.GetCurrentDirectory()).Parent.Parent.Parent.FullName,"abc.txt");
// Read the file as one string. 
string text = System.IO.File.ReadAllText(startupPath);
 * 
// resolve file path
var filePath = Path.Combine(
    VisualStudioProvider.TryGetSolutionDirectoryInfo()
    .Parent.FullName, 
    "filename.ext");
// usage file
StreamReader reader = new StreamReader(filePath);
 * 

 * 
 * */
