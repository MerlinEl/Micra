using Autodesk.Max;
using Autodesk.Max.EditorStyleDef;
using Autodesk.Max.IIRenderMgr;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Runtime.InteropServices;

namespace Micra.Core {
    public class Collections {
        /// <summary>
        /// Smart selection depends on SubobjectLevel
        /// Works with Editable_Poly and Editable_Mesh
        /// </summary>
        /// <param name="redraw"></param>
        public static void DeselectAll(bool redraw = false) {

            /* Too slow
            var nodes = Kernel.Scene.SelectedNodes();
            nodes.ForEach(n => n.Selected = false);
            if ( redraw ) Kernel.RedrawViews();*/

            if ( GlobalMethods.SubObjectLevel == 0 ) {
                Kernel._Interface.ClearNodeSelection(redraw);
            } else {
                Node node = Kernel.Scene.SelectedNodes().FirstOrDefault();
                if ( node != null ) node.Object.DeselectAll(redraw);
            }
        }


        /// <summary>
        /// Smart selection depends on SubobjectLevel
        /// Works with Editable_Poly and Editable_Mesh
        /// </summary>
        /// <param name="hidden"></param>
        /// <param name="redraw"></param>
        public static void SelectAll(bool hidden = false, bool redraw = false) {

            /* Too slow
            Kernel._Interface.DisableSceneRedraw();
            Kernel._Interface.SuspendEditing((uint)TaskModes.TASK_MODE_MODIFY, true); //for now seems not works ... see it later
            try {
                DeselectAll(false); //first deselect all, some hidden may be selected                
                foreach ( Node n in Kernel.Scene.RootNode.Children ) {
                    if ( !hidden && !n.Visible ) continue;
                    n.Selected = true;
                }
            } catch ( Exception ex ) {
                throw new Exception(ex.Message);
            } finally {
                Kernel._Interface.ResumeEditing((uint)TaskModes.TASK_MODE_MODIFY, true); //for now seem not works ... see it later
                Kernel._Interface.EnableSceneRedraw();
            }
            if ( redraw ) Kernel.RedrawViews();*/

            if ( GlobalMethods.SubObjectLevel == 0 ) {

                DeselectAll(false); //first deselect all, some hidden objects may be selected            
                List<Node> nodes = Kernel.Scene.RootNode.Children
                    .Where(n => !hidden ? n.Visible : true)
                    .ToList();
                Kernel._Interface.SelectNodeTab(nodes.ToIINodeTab(), true, redraw);
            } else {

                Node node = Kernel.Scene.SelectedNodes().FirstOrDefault();
                if ( node != null ) node.Object.SelectAll(redraw);
            }
        }
        public static void SelectAllOfType(ClassID classId, bool hidden = false, bool clearSel = true, bool redraw = false) {

            if ( clearSel ) DeselectAll(true);
            List<Node> nodes = Kernel.Scene.RootNode.Children
                .Where(n => !hidden ? n.Visible : true)
                .Where(n=> n.Object.ClassID == classId)
                .ToList();
            Kernel._Interface.SelectNodeTab(nodes.ToIINodeTab(), true, redraw);

        }
        public static void SelectAllOfType(SuperClassID sClassId, bool hidden = false, bool clearSel = true, bool redraw = false) {

            if ( clearSel ) DeselectAll(true);
            List<Node> nodes = Kernel.Scene.RootNode.Children
                .Where(n => !hidden ? n.Visible : true)
                .Where(n => n.Object.SuperClassID == sClassId)
                .ToList();
            Kernel._Interface.SelectNodeTab(nodes.ToIINodeTab(), true, redraw);
        }
        public static void ShowClass(IEnumerable<Node> nodes) {

            nodes.ForEach(n => {
                Kernel.WriteLine("obj:{0}", n.Name);
                Kernel.WriteLine("\tclassOf:{0}\n\tsuperClassOf:{1}",
                    n.ClassOf(), n.SuperClassOf());
            });
        }
        public static void ShowParameters(IEnumerable<Node> nodes) {

            Kernel.WriteLine("Selected Nodes( {0} ) Parameters > ", nodes.Count());
            nodes.ForEach<Node>(n => {
                Kernel.WriteLine("\tObject:{0} type:{1} params:{2}", n.Name, n.GetType().Name, n.Object.Params.Count());
                foreach ( IParameter p in n.Object.Params ) Kernel.WriteLine("\t\tparam:{0}", p.Name);
            });
        }

        public static List<Node> GetNodeInsatances(Node node) {

            IINodeTab instanceAndRef = Kernel._Global.NodeTab.Create();
            Kernel._InstanceMgr.GetInstances(node._IINode, instanceAndRef);
            return instanceAndRef.ToIEnumerable<IINode>()
                .Select(n => new Node(n))
                .ToList();
        }
        public static void SelectNodes(List<Node> nodes, bool redraw = false) {

            //Kernel._Interface.RedrawViews(Kernel.Now, RedrawFlags.Begin, null);
            Kernel._Interface.DisableSceneRedraw();
            Kernel._Interface.SuspendEditing((uint)TaskModes.TASK_MODE_MODIFY, true); //for now seems not works ... see it later
            DeselectAll(false);
            try {
                foreach ( Node n in nodes ) {
                    if ( !n.Visible ) continue;
                    n.Selected = true;
                }
            } catch ( Exception ex ) {

                throw new Exception(ex.Message);

            } finally {
                Kernel._Interface.ResumeEditing((uint)TaskModes.TASK_MODE_MODIFY, true); //for now seem not works ... see it later
                Kernel._Interface.EnableSceneRedraw();
            }
            Kernel.WriteLine("Selected Instance nodes:{0}/{1}", Kernel.Scene.SelectedNodes().Count(), Kernel.Scene.RootNode.Children.Count());
            //Kernel._Interface.RedrawViews(Kernel.Now, RedrawFlags.End, null);
            if ( redraw ) Kernel.RedrawViews();
        }

        public static void SelectSimillarNodes(List<Node> srcNodes) {

            Kernel.WriteLine("SelectNodesWithSimillarVolume > Sel nodes:{0}", srcNodes.Count());
            //collect selected geometry objects volumes
            List<double> volumes = srcNodes
                .Where(n =>
                    n.IsSuperClassOf(SuperClassID.GeometricObject) && //get all geometry objects
                    !n.IsClassOf(ClassID.TargetObject) //exclude any light Target
                )
                .Select(n => n.Object.GetVolume()).Distinct()
                .ToList();

            Kernel.WriteLine("\tVolumes types:{0}", volumes.Count());
            IEnumerable<Node> allNodes = Kernel.Scene.AllNodes();
            Kernel.WriteLine("\tAll nodes:{0}", allNodes.Count());

            //get geometry objects with similar volume
            List<Node> matchVolumeNodes = allNodes
                .Where(n =>
                    n.IsSuperClassOf(SuperClassID.GeometricObject) && //get all geometry objects
                    !n.IsClassOf(ClassID.TargetObject) && //exclude any light Target
                    volumes.IndexOf(n.Object.GetVolume()) != -1
                 )
                .Select(n => n)
                .ToList();

            Kernel.WriteLine("\tobjects count:{0}", matchVolumeNodes.Count());

            //execute action with undo enabled
            Kernel._TheHold.Begin();
            SelectNodes(matchVolumeNodes, true);
            Kernel._TheHold.Accept("Select Simillar");
            Kernel._TheHold.End();
        }

        /*private bool IsMatchVolume(double val, List<double> valList) {

            return valList.IndexOf(val) != -1;
        }*/

        public static void SelectInstances(Node node, bool redraw = false) {
            var nodeInstances = GetNodeInsatances(node);
            if ( nodeInstances.Count == 0 ) return;
            SelectNodes(nodeInstances);
            if ( redraw ) Kernel.RedrawViews();
        }
    }
    internal static class CollectionExtensions {

        public static IEnumerable<T> ToIEnumerable<T>(this ITab<T> itab) {

            if ( itab == null ) yield break;
            for ( int i = 0; i < itab.Count; i++ ) {
                yield return itab[i];
            }
        }

        public static IEnumerable<T> ToEnumerable<T>(this T input) { //test
            yield return input;
        }

        public static void ForEach<T>(this IEnumerable<T> collection) {//test possibly call this "Realize"
            foreach ( T item in collection ) { } // do nothing
        }
        //items.ToList().ForEach(i => i.DoStuff());
        public static void ForEach<T>(this IEnumerable<T> collection, Action<T> action) {
            foreach ( T item in collection ) action(item);
        }
        //int[] data = {1,2,3,4,5};
        //var odd = data.Where(i => i % 2 != 0);
        //or
        //var odd = data.Where<int>(i=>i%2 != 0);
        public static IEnumerable<T> Where<T>(this IEnumerable<T> data, Func<T, bool> predicate) {
            foreach ( T value in data ) {
                if ( predicate(value) ) yield return value;
            }
        }
        //test test test
        public static IEnumerable<int> IEnumerable(this IBitArray ba) { //testing
            if ( ba.IsEmpty ) yield break;
            for ( int i = 0; i < ba.Size; i++ ) {
                yield return ba[i];
            }
        }

        public static IINodeTab ToIINodeTab(this List<Node> nodesList) {

            IINodeTab nodes = Kernel._Global.NodeTab.Create();
            nodesList.ForEach(n => nodes.AppendNode(n._IINode, true, 1));
            return nodes;
        }
    }
}

/*IINode obj = MxCollection.GetFirstSelectedNode(); //Autodesk.Max.Wrappers.INode
ISubClassList clist = GlobalInterface.Instance.ClassDirectory.Instance.GetClassList(obj.ObjectRef.Eval(0).Obj.SuperClassID);
*/
//ITriObject triObj = node.ObjectRef.FindBaseObject() as ITriObject;
//IMesh mesh = triObj.Mesh;
//IntPtr meshPtr = mesh.NativePointer; //same as my C++ pointer - so it's correct

//n._Node.IsHidden(NodeHideFlags.All, false)
/*IINodeTab nodes = Kernel._Global.NodeTab.Create();
foreach ( Node n in Kernel.Scene.RootNode.Children ) {

    if ( !hidden && n._Node.IsHidden(NodeHideFlags.All, false) ) continue;
    nodes.AppendNode(( n._Node ), true, 1);
}
Kernel._Interface.SelectNodeTab(nodes, true, redraw);
Kernel._Interface.ClearNodeSelection(redraw);

public static IINodeTab ToIINodeTab<T>(List<T> nodesList) {

    IINodeTab nodes = Kernel._Global.NodeTab.Create();
    nodesList.ForEach(n => nodes.AppendNode(( n as IINode ), true, 1));
    return nodes;
}

List<IINode> nodes = new List<IINode>() { };
foreach ( Node n in Kernel.Scene.RootNode.Children ) {

    Kernel.WriteLine("Object class:{0} Compare class:{1} match:{2}", n.Object.SuperClassID, classId, ( n.Object.SuperClassID == classId ));

    if ( n.Object.SuperClassID == classId ) nodes.Add(n._Node);
}
if ( clearSel ) DeselectAll(false);
Kernel._Interface.SelectNodeTab(Collections.ToIINodeTab(nodes), true, redraw);

public static List<IINode> GetSelection() {

    IINodeTab selNodes = Kernel._Global.NodeTab.Create();
    Kernel._Interface.GetSelNodeTab(selNodes);
    return selNodes.ToIEnumerable().ToList();
}

//got crash when operate with Objects
IINodeTab nodes = Kernel._Global.NodeTab.Create();
Objects.ForEach<SceneObject>(o => {
    Kernel.WriteLine("Object:{0} type:{1}", o.Name, o.GetType().Name);
    o.Params.ForEach<IParameter>(p => Kernel.WriteLine("\tparam:{0}", p.Name));
    try {
        nodes.AppendNode(o.Node._Node as IINode, true, 1); //o.Node._Node

    } catch ( Exception ex ) {

        throw new Exception("Exception:" + ex.Message + "\nobj:" + o.Name + " type:" + o.GetType().FullName);
    }
    //nodes.AppendNode( o.Node._Node.ObjectRef.Eval(0).Obj as IINode, true, 1); //o.Node._Node
});
Kernel._Interface.SelectNodeTab(nodes, true, redraw);*/
