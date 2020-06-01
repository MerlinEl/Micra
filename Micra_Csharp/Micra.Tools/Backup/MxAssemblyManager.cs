using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;

namespace Micra.Tools {
    internal class MxAssemblyManager {
        private static AppDomain newDomain;
        private static Proxy loader;
        private static readonly string Domain_Name = "Csharp3DsMax";
        public static void ShowloadedAssemblies() {

            Assembly[] assemblies = AppDomain.CurrentDomain.GetAssemblies();
            MxSet.LogLi("ShowloadedAssemblies > Current Domain:" + AppDomain.CurrentDomain.FriendlyName);
            foreach ( Assembly asm in assemblies ) {

                MxSet.LogLi("\t{0}", asm.FullName);
                /*FileVersionInfo fvi = FileVersionInfo.GetVersionInfo(asm.Location);
                AssemblyName asmName = asm.GetName();
                string name = asmName.Name;
                Version asmV = asmName.Version;
                string fileV = fvi.FileVersion;
                string prodV = fvi.ProductVersion;
                MxSet.LogLi("\t{0} VERSIONS: (base:){1}  (file:){2}  (product:){3}", name, asmV, fileV, prodV);*/
            }
        }

        internal static void CreateDomain() {

            AppDomain currDomain = AppDomain.CurrentDomain;
            MxSet.LogLi("Current Domain:" + currDomain.FriendlyName);
            MxSet.LogLi("Current Domain Evidence:" + currDomain.Evidence.ToString());
            //Creating a new appdomain
            AppDomainSetup setup = currDomain.SetupInformation;
            MxSet.LogLi("Current Domain Info:" + setup.ToString());
            //Create an instance of loader class in new appdomain
            newDomain = AppDomain.CreateDomain(Domain_Name, AppDomain.CurrentDomain.Evidence, setup);
            MxSet.LogLi("Created New Domain:" + newDomain.FriendlyName);

            System.Runtime.Remoting.ObjectHandle obj = newDomain.CreateInstance(typeof(Proxy).Assembly.FullName, typeof(Proxy).FullName);
            MxSet.LogLi("New Domain obj:" + obj.ToString());
            //As the object we are creating is from another appdomain hence we will get that object in wrapped format and hence in next step we have unwrappped it
            loader = (Proxy)obj.Unwrap();
        }

        internal static void ExecuteStaticMethod(string className, string methodName, params object[] parameters) {

            //Call exceuteMethod and pass the name of the method from assembly and the parameters.
            loader.ExecuteStaticMethod(className, methodName, parameters);
        }

        internal static void UnloadDomain() {

            //After the method has been executed call unload method of the appdomain.
            AppDomain.Unload(newDomain);
            //Wow you have unloaded the new appdomain and also unloaded the loaded assembly from memory.
        }
        //d:\\ReneBaca\\Aprog\\Micra\\Micra4\\Assembly\\Micra.Star.dll
        internal static void LoadAssembly(string dllFilePath) {
            //Call loadassembly method so that the assembly will be loaded into the new appdomain amd the object will also remain in new appdomain only.
            loader.LoadAssembly(dllFilePath);
            /*try {
                byte[] buffer = File.ReadAllBytes(dllFilePath);
                Assembly assm = newDomain.Load(buffer);
                Type[] types = assm.GetTypes();
                foreach ( Type type in types ) {
                    MxSet.LogLi("\ttype:" + type.FullName);
                }
            } catch ( Exception ex ) {
                MxSet.LogLi(ex.Message);
            }*/

            /*string assemblyName = AssemblyName.GetAssemblyName(dllFilePath).FullName;
            string typeName = Type.GetType("Micra.Tools").FullName;
            System.Runtime.Remoting.ObjectHandle obj = newDomain.CreateInstance(assemblyName, typeName);*/

            /*AppDomainSetup domainSetup = new AppDomainSetup { PrivateBinPath = dllFilePath };
            newDomain = AppDomain.CreateDomain(Domain_Name, null, domainSetup);
            loader = (MxAssembly)newDomain.CreateInstanceFromAndUnwrap(
                          dllFilePath,
                          typeof(MxAssembly).FullName
            );
            loader.LoadAssembly(dllFilePath);*/

        }
    }
}
