using mscoree;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Windows.Forms;

namespace Micra.Domain {
    public partial class DomainUi : Form {
        private MxDomain appDomain;
        public DomainUi() {

            InitializeComponent();
        }

        public AppDomain GetAppDomain(string domainName) {

            Listener.WriteLine("GetAppDomain > search for Domain:{0}", domainName);
            AppDomain foundDomain = null;
            IntPtr handle = IntPtr.Zero;
            CorRuntimeHost host = new CorRuntimeHost();
            try {
                host.EnumDomains(out handle);
                while ( true ) {
                    host.NextDomain(handle, out object domain);
                    if ( !( domain is AppDomain myAppDomain ) )
                        break;
                    if ( myAppDomain.FriendlyName.Equals(domainName) ) {
                        Listener.WriteLine("\tfound AppDomain Name - {0}", myAppDomain.FriendlyName);
                        foundDomain = (AppDomain)domain;
                        break;
                    }
                }
            } finally {
                host.CloseEnum(handle);
            }
            return foundDomain;
        }

        private void DestroyCurrentDomain() {

            LbxAssemblies.Items.Clear();
            appDomain.DestroyDomain();
            appDomain = null;
        }

        private void ReloadAssembliesList() {

            Assembly[] assemblies = appDomain.GetAssemblies();
            LbxAssemblies.Items.Clear();
            List<ListItem> list = assemblies
                .Select(asm => new ListItem(( asm as Assembly ).FullName, asm))
                .ToList();
            Listener.WriteLine("ReloadAssembliesList > list:{0}", String.Join("\n", list));
            LbxAssemblies.Items.AddRange(list.ToArray());
        }

        private void RebuildCurrentDomain() {

            Assembly[] assemblies = appDomain.GetAssemblies();
            string[] loaded_assembly_paths = assemblies
                .Select(asm => ( asm as Assembly ).Location)
                .ToArray();
            DestroyCurrentDomain();
            appDomain = new MxDomain(TbxDomainName.Text);
            foreach ( string path in loaded_assembly_paths ) {

                appDomain.LoadAssembly(path);
            }
            ReloadAssembliesList();
        }

        private void BtnLoadAssembly_Click(object sender, EventArgs e) {

            if ( appDomain != null ) {

                appDomain.LoadAssembly(TbxAssemblyPath.Text);
                ReloadAssembliesList();
            }
        }

        private void BtnRebuildDomain_Click(object sender, EventArgs e) {

            if ( appDomain != null ) RebuildCurrentDomain();
        }

        private void DestroyDomain_Click(object sender, EventArgs e) {

            if ( appDomain != null ) DestroyCurrentDomain();
        }

        private void BtnCreateDomain_Click(object sender, EventArgs e) {

            if ( appDomain == null ) {

                appDomain = new MxDomain(TbxDomainName.Text);
                ReloadAssembliesList();
            }
        }

        private void BtnGetDomain_Click(object sender, EventArgs e) {

            AppDomain domain = GetAppDomain(TbxDomainName.Text);
            if ( domain != null ) {

                appDomain = MxDomain.FromDomain(domain);
                ReloadAssembliesList(); 
            }
        }

        private string GetParameters(ConstructorInfo co) {
            string p = "";
            ParameterInfo[] Params = co.GetParameters();
            foreach ( ParameterInfo itm in Params ) {
                p += "\n\t\t\t" + itm.ParameterType + " " + itm.Name;
            }
            return p;
        }

        private void OnIListBoxIemDoubleClick(object sender, MouseEventArgs e) {

            ListItem itm = LbxAssemblies.SelectedItem as ListItem;
            Type[] types = itm.Asm.GetTypes();
            string s = "------------------------------------------------------------------\n";
            s += itm.Text + "\n";
            foreach ( Type type in types ) {
           
                //s += "------------------------------------------------------------------\n";
                string[] c = type.GetConstructors()
                    .Select(co => GetParameters( co as ConstructorInfo ))
                    .ToArray();
                string[] m = type.GetMethods()
                    .Select(me => ( me as MethodInfo ).ToString())
                    .ToArray();
                s += "\t" + type.FullName + " Namespace:" + type.Namespace + "\n\t\tMethods:" + String.Join("\n\t\t\t", m) + "\n";
                /*s += String.Format("\tIs > Class:{0} Interface:{1} GenericType:{2} Public:{3} Sealed:{4}\n", 
                        type.IsClass.ToString(), 
                        type.IsInterface.ToString(),
                        type.IsGenericType.ToString(),
                        type.IsPublic.ToString(),
                        type.IsSealed.ToString()
                    );*/
            }
            Listener.WriteLine(s);
        }
    }
    public class ListItem {
        public ListItem(string text, Assembly asm) {
            Text = text;
            Asm = asm;
        }
        public string Text { get; set; }
        public Assembly Asm { get; set; }
        override public string ToString() => Text;
    }
}

/*public static IList<AppDomain> GetAppDomains() {
    IList<AppDomain> _IList = new List<AppDomain>();
    IntPtr enumHandle = IntPtr.Zero
    CorRuntimeHostClass host = new CorRuntimeHostClass();
    try {
        host.EnumDomains(out enumHandle);
        object domain = null;
        while ( true ) {
            host.NextDomain(enumHandle, out domain);
            if ( domain == null ) break;
            AppDomain appDomain = (AppDomain)domain;
            _IList.Add(appDomain);
        }
        return _IList;
    } catch ( Exception e ) {
        Console.WriteLine(e.ToString());
        return null;
    } finally {
        host.CloseEnum(enumHandle);
        Marshal.ReleaseComObject(host);
    }
}*/
