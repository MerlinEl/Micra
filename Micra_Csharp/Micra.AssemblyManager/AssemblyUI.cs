using System;
using System.Reflection;
using System.Windows.Forms;

namespace MyAssembly {
    public partial class AssemblyUI : Form {

        public MxDomain newDomain;
        public AssemblySandBoxLoader loader;
        private string Domain_Name = "My AddIn SandBox"; // + Guid.NewGuid()
        public AssemblyUI() {
            InitializeComponent();
        }

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

        private void button1_Click(object sender, EventArgs e) {

            MaxListener.WriteLine("Manager > Current Domain:" + AppDomain.CurrentDomain.FriendlyName); //3dsmax.exe
            newDomain = new MxDomain(Domain_Name);
            MaxListener.WriteLine("Manager > New Domain:" + newDomain.FriendlyName);
        }

        private void button2_Click(object sender, EventArgs e) {

            MaxListener.WriteLine("Manager > Unload Domain:" + newDomain.FriendlyName);
            newDomain.DestroyDomain();
        }

        private void button10_Click(object sender, EventArgs e) {

            MaxListener.WriteLine("Manager > Load Assembly Domain:" + TbxAssemblyPath.Text);
            loader = newDomain.Sandbox(TbxAssemblyPath.Text);
        }

        private void button3_Click(object sender, EventArgs e) {
            if ( newDomain == null ) return;
            Assembly[] assemblies = newDomain.GetAssemblies();
            MaxListener.WriteLine("ShowloadedAssemblies > New Domain:" + newDomain.FriendlyName);
            foreach ( Assembly asm in assemblies ) {

                MaxListener.WriteLine("\t" + asm.FullName);
            }
        }

        private void button4_Click(object sender, EventArgs e) {
            Assembly[] assemblies = AppDomain.CurrentDomain.GetAssemblies();
            MaxListener.WriteLine("ShowloadedAssemblies > Current Domain:" + AppDomain.CurrentDomain.FriendlyName);
            foreach ( Assembly asm in assemblies ) {

                MaxListener.WriteLine("\t" + asm.FullName);
            }
        }

        private void button5_Click(object sender, EventArgs e) {
            MaxListener.WriteLine("Manager > Recreating Domain:");
            button10.PerformClick();
            button3.PerformClick();
        }
    }
}

//string dll_path = @"d:\ReneBaca\Aprog\ORIENTOOLS\C#\MyAssembly\bin\Debug\MyAssembly.dll";
//MaxListener.WriteLine("Manager > Load Dll:" + dll_path);
//loader.LoadAssembly(TbxAssemblyPath.Text);