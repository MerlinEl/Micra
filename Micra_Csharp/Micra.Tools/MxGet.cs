using Autodesk.Max;
using System;
using System.Drawing;
using System.IO;
using System.Reflection;
using System.Windows.Forms;
//Category > Max SDK and C#
namespace Micra.Tools {
    public class MxGet {

        #region Enums

        public enum MouseEventFlags { //not used yet
            LEFTDOWN = 0x00000002,
            LEFTUP = 0x00000004,
            MIDDLEDOWN = 0x00000020,
            MIDDLEUP = 0x00000040,
            MOVE = 0x00000001,
            ABSOLUTE = 0x00008000,
            RIGHTDOWN = 0x00000008,
            RIGHTUP = 0x00000010
        }

        #endregion

        #region Interfaces

        public static IGlobal Global => GlobalInterface.Instance;
        public static IInterface13 Interface => Global.COREInterface13;


        #endregion

        #region Variables

        public static string AssemblyVersion = Assembly.GetExecutingAssembly().GetName().Version.ToString();
        public static string AssemblyDir {
            get {
                string codeBase = Assembly.GetExecutingAssembly().CodeBase;
                UriBuilder uri = new UriBuilder(codeBase);
                string path = Uri.UnescapeDataString(uri.Path);
                return Path.GetDirectoryName(path);
            }
        }
        public static string MicraRootDir = Directory.GetParent(AssemblyDir).FullName;
        public static string MicraRootDir2 => Path.Combine(MicraRootDir, @"..\..\Micra4"); //C# test get upper dir 2*
        #endregion


        #region Objects - New Objects

        public static object FontStyles = Enum.ToObject(typeof(FontStyle), 0);
        public static Font NewFont(string family, float size, FontStyle style) => new Font(family, size, style);
        public static Size NewSize(int w, int h) => new Size(w, h);
        public static Color NewColor(int r, int g, int b) => Color.FromArgb(r, g, b);
        public static Color ColorFromName(string clr_str) => Color.FromName(clr_str);

        #endregion

        //asm = McGetCs.GetLatestAssembly "Micra.Star" --pickup latest dll instance from max domain
        public static Assembly GetLatestAssembly(string assembly_name) {

            Assembly[] assemblies = AppDomain.CurrentDomain.GetAssemblies();
            Assembly latest_assembly = null;
            string version1 = "1.0.0.0";
            foreach ( Assembly asm in assemblies ) {

                if ( asm.GetName().Name == assembly_name ) {

                    string version2 = asm.GetName().Version.ToString();
                    var result = version2.CompareTo(version1);
                    if ( result > 0 ) {
                        latest_assembly = asm;
                        version1 = version2;
                    }
                }
            }
            return latest_assembly;
        }

        /*public static Assembly LoadAssembly(string assembly_path) {

            MxSet.LogLi("Rading bytes from Assembly:\n\t" + assembly_path);
            byte[] assembly_bytes = File.ReadAllBytes(assembly_path); //read assembly bytes, leave dll unlocked
            Assembly asm = Assembly.Load(assembly_bytes); //load assembly in to current domain
            MxSet.LogLi("Loaded Assembly:" + asm.FullName); //print ddl name and version
            return asm;
        }*/


        #region Test

        /// <summary>
        /// NativeWindow parentWindow = GetWindowFromHwnd(hwnd);
        /// try {
        ///     myForm.ShowDialog(parentWindow);
        /// }
        /// finally {
        ///     parentWindow.DestroyHandle();
        /// }
        /// </summary>
        /// <param name="hwnd"></param>
        /// <returns></returns>
        public static NativeWindow GetWindowFromHwnd(long hwnd) {
            IntPtr handle = new IntPtr(hwnd);
            NativeWindow window = new NativeWindow();
            window.AssignHandle(handle);
            return window;
        }
        public static IPoint3 Point(double x, double y, double z) {

            return Global.Point3.Create(x, y, z);
        }

        /*public class Point {
            private double _x = 0;
            private double _y = 0;
            private double _z = 0;
          *  private IPoint3 p;
            public Point(double x, double y, double z) {
                _x = x;
                _y = y;
                _z = z;
                p = MxGet.Global.Point3.Create(x, y, z);
            }
        }*/
        #endregion



    }
}
