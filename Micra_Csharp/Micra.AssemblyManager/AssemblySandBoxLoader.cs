using System;
using System.IO;
using System.Reflection;
using System.Windows.Forms;

namespace MyAssembly {
    public class AssemblySandBoxLoader : MarshalByRefObject {
        public AssemblySandBoxLoader(string assemblyFilename) {

            byte[] assembly_bytes = File.ReadAllBytes(assemblyFilename);
            TrustedAssembly = Assembly.Load(assembly_bytes);
            //TrustedAssembly = Assembly.LoadFile(assemblyFilename);
            //MaxListener.WriteLine("AssemblySandBoxLoader > Load Assembly:" + assemblyFilename);
        }

        public Assembly TrustedAssembly { get; set; } = null;

        public object ExecuteStaticMethod(string className, string methodName, params object[] parameters) {

            //MaxListener.WriteLine("AssemblySandBoxLoader > className:{0} methodName:{1} params:{2}", className, methodName, parameters.Length.ToString());
            MessageBox.Show(String.Format("AssemblySandBoxLoader > className:{0} methodName:{1} params:{2}", className, methodName, parameters.Length.ToString()));
            Type MyType = null;
            object inst = null;
            foreach ( Type type in TrustedAssembly.GetTypes() ) {

                //MaxListener.WriteLine("\tprop name:{0}", type.Name);
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
        }
    }
}
