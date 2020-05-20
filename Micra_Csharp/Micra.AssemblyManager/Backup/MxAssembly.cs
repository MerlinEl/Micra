using System;
using System.Reflection;

namespace Orien.AssemblyManager {
    public class MxAssembly : MarshalByRefObject {
        private Assembly _assembly;
        Type MyType = null;
        object inst = null;
        public override object InitializeLifetimeService() {
            return null;
        }

        public void LoadAssembly(string path) {
            _assembly = Assembly.Load(AssemblyName.GetAssemblyName(path));
        }

        public object ExecuteStaticMethod(string className, string methodName, params object[] parameters) {
            foreach ( Type type in _assembly.GetTypes() ) {
                if ( String.Compare(type.Name, className, true) == 0 ) {
                    MyType = type;
                    inst = _assembly.CreateInstance(type.FullName);
                    break;
                }
            }
            MethodInfo MyMethod = MyType.GetMethod(methodName, new Type[] { typeof(int), typeof(string), typeof(string), typeof(string) });
            MyMethod.Invoke(inst, BindingFlags.InvokeMethod, null, parameters, null);
            return null;
        }
    }
}
