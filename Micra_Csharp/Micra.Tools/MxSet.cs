using System;
using System.IO;
using System.Reflection;
//Test Class for load unload Assembly
namespace Micra.Tools {
    public class MxSet {
        public static AppDomain Orien3DsMaxDomain = AppDomain.CreateDomain("Orien3DsMaxDomain");

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
        public static Type[] LoadAssembly(string filePath) {

            if ( !File.Exists(filePath) ) return null;
            //AppDomain dom = AppDomain.CreateDomain(domainName);
            AssemblyName assemblyName = new AssemblyName();
            assemblyName.CodeBase = filePath;
            Assembly assembly = Orien3DsMaxDomain.Load(assemblyName);
            return assembly.GetTypes();

            //Assembly assem = Assembly.Load(File.ReadAllBytes(filePath));
        }
        public static bool UnloadAssembly() {
            try {

                AppDomain.Unload(Orien3DsMaxDomain);

            } catch {

                return false;
            }
            return true;
        }
    }
}
