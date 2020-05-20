using Autodesk.Max;
using System;
using System.IO;
using System.Reflection;
//Test Class for load unload Assembly
namespace Micra.Tools {
    public class MxSet {

        public static bool Gc() {
            try {
                GC.Collect(); // collects all unused memory
                GC.WaitForPendingFinalizers(); // wait until GC has finished its work
                GC.Collect();
            } catch {

                return false;
            }
            return true;
        }
        /// <summary>
        /// Print Message in to Listener
        /// </summary>
        /// <param name="strMsg"></param>
        public static void LogLi(string strMsg, params object[] args) {
            if ( args.Length > 0 ) strMsg = String.Format(strMsg, args);
            MxListener.WriteLine(strMsg);
        }

        public static IFPValue ExecuteMAXScriptScript(string action, bool quietErrors = false) {
            IFPValue fpv = null;
            MxGet.Global.ExecuteMAXScriptScript(action, quietErrors, fpv);
            //ManagedServices.MaxscriptSDK.ExecuteMaxscriptCommand(cmd);
            return fpv;
        }

        public static void SetAccelerators(bool state) {
            if ( state )
                ManagedServices.AppSDK.EnableAccelerators(); // for lostfocus
            else
                ManagedServices.AppSDK.DisableAccelerators(); // for gotfocus
        }

        public static string FbxExport(string filePath) {

            string fullPath = Path.Combine(filePath);
            IClass_ID exporterID = MxGet.Global.Class_ID.Create(0x27227747, 0xDD6978);
            MxGet.Interface.ExportToFile(fullPath, true, 1, exporterID);
            return fullPath;
        }

        //TODO TEST load - unload DLL
        public static AppDomain Orien3DsMaxDomain = AppDomain.CreateDomain("Orien3DsMaxDomain"); //not used
        public static Type[] LoadAssembly(string filePath) { //not used

            if ( !File.Exists(filePath) ) return null;
            //AppDomain dom = AppDomain.CreateDomain(domainName);
            AssemblyName assemblyName = new AssemblyName();
            assemblyName.CodeBase = filePath;
            Assembly assembly = Orien3DsMaxDomain.Load(assemblyName);
            return assembly.GetTypes();

            //Assembly assem = Assembly.Load(File.ReadAllBytes(filePath));
        }
        public static bool UnloadAssembly() { //not used
            try {

                AppDomain.Unload(Orien3DsMaxDomain);

            } catch {

                return false;
            }
            return true;
        }
    }
}
