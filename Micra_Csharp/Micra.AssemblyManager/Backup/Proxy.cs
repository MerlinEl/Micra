using System;
using System.Reflection;
using System.Windows.Forms;

namespace Orien.AssemblyManager {
    //this attribute is required for creation of instance in seperate appdomain.
    [Serializable]
    /*to enable the class to cross the appdomain limits we have 
        to inherit the class from Marshelby refe object.*/
    class Proxy : MarshalByRefObject {


        public Proxy() {

            AppDomain.CurrentDomain.AssemblyResolve += new ResolveEventHandler(CurrentDomain_AssemblyResolve);

        }

        Assembly CurrentDomain_AssemblyResolve(object sender, ResolveEventArgs args) {

            return typeof(Proxy).Assembly;

        }

        public void PrintDomain() {

            MessageBox.Show(AppDomain.CurrentDomain.FriendlyName);

        }

        public Assembly LoadAssembly(string assemblyPath) {
            try {
                return Assembly.LoadFrom(assemblyPath);
            } catch ( Exception ex ) {
                throw new InvalidOperationException(ex.Message);
            }
        }
    }
}