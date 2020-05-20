using System;
using System.Globalization;
using System.IO;
using System.Reflection;
using System.Security;
using System.Security.Permissions;

namespace MyAssembly {

    public class MxDomain {

        public readonly AppDomain appDomain;
        public string FriendlyName => appDomain.FriendlyName;

        public MxDomain(string domain_name) {

            PermissionSet trustedLoadGrantSet = new PermissionSet(PermissionState.Unrestricted);
            AppDomainSetup trustedLoadSetup = new AppDomainSetup {

                ApplicationBase = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location)
            };
            AppDomain.CurrentDomain.AssemblyResolve += CurrentDomain_AssemblyResolve;
            appDomain = AppDomain.CreateDomain(domain_name, null, trustedLoadSetup, trustedLoadGrantSet);
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
        public AssemblySandBoxLoader Sandbox(string assemblyFilename) {

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

        public Assembly[] GetAssemblies() => appDomain.GetAssemblies();

        public Assembly GetAssembly(string assemblyName) {

            Assembly[] assemblies = GetAssemblies();
            foreach ( Assembly asm in assemblies ) {

                if ( asm.GetName().Name == assemblyName ) return asm;
            }
            return null;
        }
    }
}


/*public Assembly CurrentDomain_AssemblyResolve(object sender, ResolveEventArgs args) {
    return typeof(AssemblySandBoxLoader).Assembly;
}*/

/*
appDomain = AppDomain.CreateDomain(
    "FriendlyName", 
    AppDomain.CurrentDomain.Evidence, 
    AppDomain.CurrentDomain.BaseDirectory, 
    AppDomain.CurrentDomain.RelativeSearchPath, 
    AppDomain.CurrentDomain.ShadowCopyFiles
);
This will use the BaseDirectory and the RelativeSearchPath of the current appDomain.
 */
