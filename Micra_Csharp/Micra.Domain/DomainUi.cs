using mscoree;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Windows.Forms;

namespace Micra.Domain {
    public partial class DomainUi:Form {
        private MxDomain customAppDomain;
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
                        foundDomain = ( AppDomain )domain;
                        break;
                    }
                }
            } finally {
                host.CloseEnum(handle);
            }
            return foundDomain;
        }

        private void DestroyCurrentDomain() {

            ClearAll();
            customAppDomain.DestroyDomain();
            customAppDomain = null;
        }

        private void ClearAll() {
            LbxAssemblies.Items.Clear();
            LbxAssemblyTypes.Items.Clear();
            TbxTypeData.Text = "";
        }

        private void ReloadAssembliesList() {

            ClearAll();
            Assembly[] assemblies = null;
            if ( ChkCurrentDomain.Checked ) {

                assemblies = AppDomain.CurrentDomain.GetAssemblies();
            } else {

                if ( customAppDomain == null ) return;
                assemblies = customAppDomain.GetAssemblies();
            }
            List<ListItem> list = assemblies
                .Select(a => new ListItem(( a as Assembly ).FullName, a))
                .ToList();
            Listener.WriteLine("ReloadAssembliesList > list:{0}", String.Join("\n", list));
            if ( list.Count == 0 ) return;
            LbxAssemblies.Items.AddRange(list.ToArray());
            LbxAssemblies.SelectedIndex = 0;
        }

        private void LoadAssemblyTypes(Assembly asm) {

            LbxAssemblyTypes.Items.Clear();
            Type[] types = asm.GetTypes();
            List<ListItem> list = types
                .Select(t => new ListItem(( t as Type ).FullName, t))
                .ToList();
            if ( list.Count == 0 ) return;
            LbxAssemblyTypes.Items.AddRange(list.ToArray());
            LbxAssemblyTypes.SelectedIndex = 0;
        }

        private void LoadTypeData(Type type) {

            string str = ReadTypeInfo(type);
            TbxTypeData.Text = str.Replace("\n", Environment.NewLine);
        }
        //TODO move it to static class manager?
        private void RebuildCurrentDomain() {

            Assembly[] assemblies = customAppDomain.GetAssemblies();
            string[] loaded_assembly_paths = assemblies
                .Select(asm => ( asm as Assembly ).Location)
                .ToArray();
            DestroyCurrentDomain();
            customAppDomain = new MxDomain(TbxDomainName.Text);
            foreach ( string path in loaded_assembly_paths ) {

                customAppDomain.LoadAssembly(path);
            }
            ReloadAssembliesList();
        }

        private void BtnLoadAssembly_Click(object sender, EventArgs e) {

            if ( customAppDomain != null ) {

               bool success = customAppDomain.LoadAssembly(TbxAssemblyPath.Text);
                if ( success ) {
                    ReloadAssembliesList();
                } else {
                    MessageBox.Show("Assembly not found or is already loaded!\nTry to load new version or Rebuild Domain");
                }
            }
        }

        private void BtnRebuildDomain_Click(object sender, EventArgs e) {

            if ( customAppDomain != null ) {

                RebuildCurrentDomain();

            }else {

                MessageBox.Show("Domain {0} not Exists", TbxDomainName.Text);
            }
        }

        private void DestroyDomain_Click(object sender, EventArgs e) {

            if ( customAppDomain != null ) {

                DestroyCurrentDomain();

            } else {

                MessageBox.Show("Domain {0} not Exists", TbxDomainName.Text);
            }
        }

        private void BtnCreateDomain_Click(object sender, EventArgs e) {

            if ( customAppDomain == null ) {

                customAppDomain = new MxDomain(TbxDomainName.Text);
                ReloadAssembliesList();
            }
        }

        private void BtnGetDomain_Click(object sender, EventArgs e) {

            AppDomain domain = GetAppDomain(TbxDomainName.Text);
            if ( domain != null ) {

                customAppDomain = MxDomain.FromDomain(domain);
                ReloadAssembliesList();
            }
        }


        private string ReadMembersInfo(MemberInfo[] ms) {

            string out_data = "";
            foreach ( MemberInfo m in ms ) {
                out_data += String.Format("\t\t{0}{1}\n", "     ", m);
            }
            return out_data;
        }

        private string ReadTypeInfo(Type t) {

            // Specifies the class.
            string out_data = String.Format("Listing all the members (public and non public) of the {0}\n", t);

            // Lists static fields first.
            FieldInfo[] fi = t.GetFields(BindingFlags.Static |
                BindingFlags.NonPublic | BindingFlags.Public);
            out_data += "\t> Static Fields:\n";
            out_data += ReadMembersInfo(fi);

            // Static properties.
            PropertyInfo[] pi = t.GetProperties(BindingFlags.Static |
                BindingFlags.NonPublic | BindingFlags.Public);
            out_data += "\t> Static Properties:\n";
            out_data += ReadMembersInfo(pi);

            // Static events.
            EventInfo[] ei = t.GetEvents(BindingFlags.Static |
                BindingFlags.NonPublic | BindingFlags.Public);
            out_data += "\t> Static Events:\n";
            out_data += ReadMembersInfo(ei);

            // Static methods.
            MethodInfo[] mi = t.GetMethods(BindingFlags.Static |
                BindingFlags.NonPublic | BindingFlags.Public);
            out_data += "\t> Static Methods:\n";
            out_data += ReadMembersInfo(mi);

            // Constructors.
            ConstructorInfo[] ci = t.GetConstructors(BindingFlags.Instance |
                BindingFlags.NonPublic | BindingFlags.Public);
            out_data += "\t> Constructors:\n";
            out_data += ReadMembersInfo(ci);

            // Instance fields.
            fi = t.GetFields(BindingFlags.Instance | BindingFlags.NonPublic |
                BindingFlags.Public);
            out_data += "\t> Instance Fields:\n";
            out_data += ReadMembersInfo(fi);

            // Instance properites.
            pi = t.GetProperties(BindingFlags.Instance | BindingFlags.NonPublic |
                BindingFlags.Public);
            out_data += "\t> Instance Properties:\n";
            out_data += ReadMembersInfo(pi);

            // Instance events.
            ei = t.GetEvents(BindingFlags.Instance | BindingFlags.NonPublic |
                BindingFlags.Public);
            out_data += "\t> Instance Events:\n";
            out_data += ReadMembersInfo(ei);

            // Instance methods.
            mi = t.GetMethods(BindingFlags.Instance | BindingFlags.NonPublic
                | BindingFlags.Public);
            out_data += "\t> Instance Methods:\n";
            out_data += ReadMembersInfo(mi);

            return out_data;
        }

        private void OnAssemblyItemSelectionChanged(object sender, EventArgs e) {

            if ( LbxAssemblies.SelectedItem is ListItem itm )
                LoadAssemblyTypes(itm.Tag as Assembly);
        }

        private void OnAssemblyTypeItemSelectionChanged(object sender, EventArgs e) {
            if ( LbxAssemblyTypes.SelectedItem is ListItem itm )
                LoadTypeData(itm.Tag as Type);
        }

        private void ChkCurrentDomain_CheckedChanged(object sender, EventArgs e) {
            if ( ChkCurrentDomain.Checked ) {

                TbxDomainName.Text = "Current";
                TbxDomainName.Enabled = false;
                BtnGetDomain.Enabled = false;
                BtnCreateDomain.Enabled = false;
                TbxAssemblyPath.Enabled = false;
                BtnLoadAssembly.Enabled = false;
                BtnRebuildDomain.Enabled = false;
                DestroyDomain.Enabled = false;

            } else {

                TbxDomainName.Text = "Micra_Domain";
                TbxDomainName.Enabled = true;
                BtnGetDomain.Enabled = true;
                BtnCreateDomain.Enabled = true;
                TbxAssemblyPath.Enabled = true;
                BtnLoadAssembly.Enabled = true;
                BtnRebuildDomain.Enabled = true;
                DestroyDomain.Enabled = true;
            }
            ReloadAssembliesList();
        }
    }
    public class ListItem {
        public ListItem(string text, Object tag) {
            Text = text;
            Tag = tag;
        }
        public string Text { get; set; }
        public Object Tag { get; set; }
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

/*private string GetParameters(ConstructorInfo co) {
string p = "";
ParameterInfo[] Params = co.GetParameters();
foreach ( ParameterInfo itm in Params ) {
    p += "\n\t\t\t" + itm.ParameterType + " " + itm.Name;
}
return p;
}*/

/*

            ListItem itm = LbxAssemblies.SelectedItem as ListItem;
            Type[] types = itm.Asm.GetTypes();
            string s = "------------------------------------------------------------------\n";
            s += itm.Text + "\n";
            foreach ( Type type in types ) {

                s += ReadTypeInfo(type);
                //s += "------------------------------------------------------------------\n";
                string[] c = type.GetConstructors()
                    .Select(co => GetParameters( co as ConstructorInfo ))
                    .ToArray();
                string[] m = type.GetMethods()
                    .Select(me => ( me as MethodInfo ).ToString())
                    .ToArray();
                s += "\t" + type.FullName + " Namespace:" + type.Namespace + "\n\t\tMethods:" + String.Join("\n\t\t\t", m) + "\n";*/
/*s += String.Format("\tIs > Class:{0} Interface:{1} GenericType:{2} Public:{3} Sealed:{4}\n", 
        type.IsClass.ToString(), 
        type.IsInterface.ToString(),
        type.IsGenericType.ToString(),
        type.IsPublic.ToString(),
        type.IsSealed.ToString()
    );
}
Listener.WriteLine(s);
     */
