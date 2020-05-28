using Autodesk.Max;
using System;
using System.Collections.Generic;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Windows.Forms;
//http://help.autodesk.com/view/3DSMAX/2020/ENU/?guid=__cpp_ref_class_interface_html
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
        //http://help.autodesk.com/view/3DSMAX/2020/ENU/?guid=__cpp_ref_class_interface14_html
        public static IInterface13 Interface => Global.COREInterface14;
        public static IIInstanceMgr InstanceMgr => Global.IInstanceMgr.InstanceMgr;
        public static IIGameScene GameScene(bool onlySelected = true) {

            IIGameScene gameScene = Global.IGameInterface;
            gameScene.InitialiseIGame(onlySelected);
            gameScene.SetStaticFrame(0);
            return gameScene;
        }
        public static IINode MaxScene => Interface.RootNode;

        public static string MaxSceneFileName => GameScene().SceneFileName;
        public static IClass_ID Class_ID;

        /*static void Initialize() {
            if ( Class_ID == null ) {
                Class_ID = Global.Class_ID.Create(0x8217f123, 0xef980456);
                Interface.AddClass(new MxDescriptor());
            }
        }*/
        #endregion

        #region Variables
        public static string MaxPath() => Interface.GetDir((int)MaxDirectory.ProjectFolder);
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
        public static IPoint3 NewPoint3() => Global.Point3.Create();
        public static IPoint3 NewIPoint3(float X, float Y, float Z) => Global.Point3.Create(X,Y,Z);

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

        /*public static ScaleUnitType GetSceneUnits() {

            unsafe {

                int unitType = 0;
                double ptrScale = 0.0f;
                IntPtr pType = new IntPtr(&unitType);
                IntPtr pScale = new IntPtr(&ptrScale);

                Global.GetMasterUnitInfo(pType, pScale);
            }
            float masterScale = (float)Global.GetMasterScale(unitType);
            return (ScaleUnitType)unitType;
        }*/
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

        #endregion

    }
    //https://github.com/sinushawa/TagManager
    //Interface.AddClass(new testSub.Descriptor(Global));
    public class testSub : Autodesk.Max.Plugins.UtilityObj { //test only
        public class Descriptor : Autodesk.Max.Plugins.ClassDesc2 {
            protected IGlobal _global;
            internal static IClass_ID _classID;

            public IGlobal Global {
                get { return this._global; }
            }

            public Descriptor(IGlobal global) {
                this._global = global;
                _classID = _global.Class_ID.Create(0x8962d7, 0x285b3ff9);
            }

            public override string Category {
                get { return "NetPluginTests"; }
            }

            public override IClass_ID ClassID {
                get { return _classID; }
            }

            public override string ClassName {
                get { return "TestPlugin01"; }
            }

            public override object Create(bool loading) {
                return new testSub(this);
            }

            public override bool IsPublic {
                get { return true; }
            }

            public override SClass_ID SuperClassID {
                get { return SClass_ID.Utility; }
            }
        }
        Descriptor _descriptor;

        public testSub(Descriptor descriptor) {
            this._descriptor = descriptor;
        }

        public override void BeginEditParams(IInterface ip, IIUtil iu) {
            ip.PushPrompt("This is a prompt msg :D");
        }

        public override void EndEditParams(IInterface ip, IIUtil iu) {
            ip.PopPrompt();
        }
    }
}


/*
     public static IntPtr GetNativeHandle(this INativeObject obj) => obj.NativePointer;
      public static IMatrix3 Identity { get { return Loader.Global.Matrix3.Create(XAxis, YAxis, ZAxis, Origin); } }
      public static IInterval Forever {
          get { return Loader.Global.Interval.Create(int.MinValue, int.MaxValue); }
      }
      //var type = GetWrappersAssembly().GetType("Autodesk.Max.Wrappers.IGameCamera");
      //var constructor = type.GetConstructors()[0];
      static Assembly GetWrappersAssembly() {
          return Assembly.Load("Autodesk.Max.Wrappers, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null");
      }
       public static IEnumerable<Type> GetAllLoadableTypes() {
          Assembly[] assemblies = AppDomain.CurrentDomain.GetAssemblies();
          foreach ( Assembly assembly in assemblies ) {
              foreach ( Type type in assembly.GetLoadableTypes() ) {
                  yield return type;
              }
          }
      }
      public static IEnumerable<Type> GetLoadableTypes(this Assembly assembly) {
          if ( assembly == null ) throw new ArgumentNullException("assembly");
          try {
              return assembly.GetTypes();
          } catch ( ReflectionTypeLoadException e ) {
              return e.Types.Where(t => t != null);
          }
      }
      public struct VersionNumber {
          public int Major;
          public int Minor;
          public int Revision;
          public int BuildNumber;
      }
      public static VersionNumber GetMaxVersion() {

          // https://getcoreinterface.typepad.com/blog/2017/02/querying-the-3ds-max-version.html
          var versionString = ManagedServices.MaxscriptSDK.ExecuteStringMaxscriptQuery("getFileVersion \"$max/3dsmax.exe\"");
          var versionSplit = versionString.Split(',');
          int major, minor, revision, buildNumber = 0;
          int.TryParse(versionSplit[0], out major);
          int.TryParse(versionSplit[1], out minor);
          int.TryParse(versionSplit[2], out revision);
          int.TryParse(versionSplit[3], out buildNumber);
          return new VersionNumber { Major = major, Minor = minor, Revision = revision, BuildNumber = buildNumber };
      }
      */
