using System;
using System.Globalization;
using System.IO;
using System.Reflection;
using System.Security;
using System.Security.Permissions;
using System.Windows.Forms;

namespace Micra.Domain {
    public class MxDomain {
        private AppDomain appDomain;
        public bool Debug = false;
        public string FriendlyName => appDomain.FriendlyName;
        public MxDomain(string domain_name) {

            PermissionSet trustedLoadGrantSet = new PermissionSet(PermissionState.Unrestricted);
            AppDomainSetup trustedLoadSetup = new AppDomainSetup {

                ApplicationBase = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location)
            };
            AppDomain.CurrentDomain.AssemblyResolve += CurrentDomain_AssemblyResolve;
            appDomain = AppDomain.CreateDomain(domain_name, null, trustedLoadSetup, trustedLoadGrantSet);
        }

        public void ShowUi(Form owner) {

            new DomainUi() { Owner = owner }.Show();
        }

        public static MxDomain FromDomain(AppDomain domain) {

            MxDomain d = new MxDomain(domain.FriendlyName) {
                appDomain = domain
            };
            return d;
        }

        /*
         * Unable to cast transparent proxy to type 'Configuration.CompileProxy.Compiler'.
         * 
        Solution found.
         The solution is to subscribe to the AssemblyResolve Event for the first AppDomain 
         (this is if you use the CreateInstanceAndUnWrap() which also requires you to 
         set the AppBase of your new AppDomain to the location of your assemblies).

         (I did notice an infinite loop when subscribing to this event before, 
         maybe it was because I was using CreateInstanceFromAndUnWrap()).

         the Configuration.GalaxyBuildTask.GalaxyBuildTask._presentProjectLocation 
         is set earlier using _presentProjectLocation = BuildEngine.ProjectFileOfTaskNode;
         this sets the location to be that of the current VS project, 
         because this is launched from a build task it is required to locate the current project.
        */
        private static Assembly CurrentDomain_AssemblyResolve(object sender, ResolveEventArgs args) {
            string projectDir = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location);
            string shortAssemblyName = args.Name.Substring(0, args.Name.IndexOf(','));
            string fileName = Path.Combine(projectDir, shortAssemblyName + ".dll");
            if ( File.Exists(fileName) ) {

                byte[] assembly_bytes = File.ReadAllBytes(fileName);
                Assembly result = Assembly.Load(assembly_bytes);

                //Assembly result = Assembly.LoadFrom(fileName);
                return result;
            } else
                return Assembly.GetExecutingAssembly().FullName == args.Name ? Assembly.GetExecutingAssembly() : null;
        }

        //Create a SandBox to load Assemblies with "Full Trust"
        public AssemblySandBoxLoader LoadAssembly(string assemblyFilename) {

            if ( appDomain == null || !File.Exists(assemblyFilename)) return null;

            AssemblySandBoxLoader loader = appDomain.CreateInstanceAndUnwrap(
              typeof(AssemblySandBoxLoader).Assembly.GetName().FullName,
              typeof(AssemblySandBoxLoader).FullName,
              false,
              BindingFlags.Default,
              null,
              new object[] { assemblyFilename },
              CultureInfo.InvariantCulture,
              null) as AssemblySandBoxLoader;

            return loader;
        }

        public void DestroyDomain() => AppDomain.Unload(appDomain);
        //get all assemblies from this domain
        public Assembly[] GetAssemblies() => appDomain.GetAssemblies();
        public void ShowLoadedAssemblies() {

            Assembly[] assemblies = GetAssemblies();
            Listener.WriteLine("PrintAssemblies > Current Domain:" + FriendlyName);
            foreach ( Assembly asm in assemblies ) {

                Listener.WriteLine("\t" + asm.FullName);
            }
        }
        //get latest(version) loaded assembly from this dommain
        public Assembly GetLatestAssembly(string assemblyName) { //TODO search backwards (if same versions are exists to get last loaded)

            if ( Debug ) Listener.WriteLine("GetLatestAssembly > Name:{0}", assemblyName);
            Assembly[] assemblies = GetAssemblies();
            Assembly latest_assembly = null;
            string version1 = "1.0.0.0";
            foreach ( Assembly asm in assemblies ) {
                if ( Debug ) Listener.WriteLine("\t compare A:{0} b:{1}", assemblyName, asm.GetName().Name);
                if ( asm.GetName().Name == assemblyName ) {

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
    }
    public class AssemblySandBoxLoader : MarshalByRefObject {
        public AssemblySandBoxLoader(string assemblyFilename) {

            byte[] assembly_bytes = File.ReadAllBytes(assemblyFilename);
            TrustedAssembly = Assembly.Load(assembly_bytes);
            //TrustedAssembly = Assembly.LoadFile(assemblyFilename);
            //MaxListener.WriteLine("AssemblySandBoxLoader > Load Assembly:" + assemblyFilename);
        }

        public Assembly TrustedAssembly { get; set; } = null;

        /*public object ExecuteStaticMethod(string className, string methodName, params object[] parameters) {

            //MaxListener.WriteLine("AssemblySandBoxLoader > className:{0} methodName:{1} params:{2}", className, methodName, parameters.Length.ToString());
            Listener.WriteLine("AssemblySandBoxLoader > className:{0} methodName:{1} params:{2}", className, methodName, parameters.Length.ToString());
            Type MyType = null;
            object inst = null;
            foreach ( Type type in TrustedAssembly.GetTypes() ) {

                Listener.WriteLine("\tprop name:{0}", type.Name);
                if ( String.Compare(type.Name, className, true) == 0 ) {
                    MyType = type;
                    inst = TrustedAssembly.CreateInstance(type.FullName);
                    break;
                }
            }
            if ( inst == null ) return null;
            MethodInfo MyMethod = MyType.GetMethod(methodName, new Type[] { typeof(int), typeof(string), typeof(string), typeof(string) });
            MyMethod.Invoke(inst, BindingFlags.InvokeMethod, null, parameters, null);
            return null;
        }*/
    }
}










/*public static string ASSEMBLY_FNAME { get; set; } = "Micra.Star.dll";
public static string AssemblyDir {
    get {
        string codeBase = Assembly.GetExecutingAssembly().CodeBase;
        UriBuilder uri = new UriBuilder(codeBase);
        string path = Uri.UnescapeDataString(uri.Path);
        return Path.GetDirectoryName(path);
    }
}
public static string AssemblyPath => AssemblyDir + ASSEMBLY_FNAME;
/// <summary>
/// MxDomain.ShowAsseblies() //show all assemblies from Current Max Domain
/// MxDomain.ShowAsseblies("Micra.Star") //show selected type assemblies from Current Max Domain
/// </summary>
/// <param name="type"></param>
public static void ShowAsseblies(string type = "All") {

    Listener.WriteLine("Main > GetAllAssemblies > Current Domain:" + AppDomain.CurrentDomain.FriendlyName);
    Assembly[] assemblies = AppDomain.CurrentDomain.GetAssemblies();

    foreach ( Assembly asm in assemblies ) {

        if ( type != "All" ) {

            if ( asm.GetName().Name != type ) continue;
        }
        Listener.WriteLine("\t" + asm.FullName);
    }
}
public static Object GetClassInstance(string classPath, bool forceLoad = false, params object[] args) {
    Listener.WriteLine("GetClassInstance > AssemblyPath:{0}", AssemblyPath);
    if ( !File.Exists(AssemblyPath) ) return null;
    Listener.WriteLine("GetClassInstance > classPath:{0} forceLoad:{1} params:{2}", classPath, forceLoad, args);
    if ( forceLoad ) Reload();

    if ( args.Length > 0 ) {

        Listener.WriteLine("\twith args:{0}", args.Length);
    } else {

        Listener.WriteLine("\twithout args");
    }
    return null;
}

private static void Reload() {
    throw new NotImplementedException();
}*/
