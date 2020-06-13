using Autodesk.Max;
using Humanizer;
using System;
using System.Collections.Generic;
using System.Linq;

namespace Micra.Core {
    public class ObjOps {

        public static List<Node> GetSlectedNodes() => Kernel.Scene.SelectedNodes().ToList();
        /// <summary> Get First Node From Selected Objects</summary>
        public static Node GetFirstSlectedNode() => GetSlectedNodes().FirstOrDefault();
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
                .Where(n => n.Object.ClassID == classId)
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
            Kernel._Interface.SuspendEditing(( uint )TaskModes.TASK_MODE_MODIFY, true); //for now seems not works ... see it later
            DeselectAll(false);
            try {
                foreach ( Node n in nodes ) {
                    if ( !n.Visible ) continue;
                    n.Selected = true;
                }
            } catch ( Exception ex ) {

                throw new Exception(ex.Message);

            } finally {
                Kernel._Interface.ResumeEditing(( uint )TaskModes.TASK_MODE_MODIFY, true); //for now seem not works ... see it later
                Kernel._Interface.EnableSceneRedraw();
            }
            Kernel.WriteLine("Selected Instance nodes:{0}/{1}", Kernel.Scene.SelectedNodes().Count(), Kernel.Scene.RootNode.Children.Count());
            //Kernel._Interface.RedrawViews(Kernel.Now, RedrawFlags.End, null);
            if ( redraw ) Kernel.RedrawViews();
        }
        /// <summary>
        /// Select simillar nodes based on vertex count and faces area
        /// </summary>
        /// <param name="srcNodes"></param>
        public static void SelectSimillarNodes(List<Node> srcNodes, bool byArea = true, bool byVcount = false) {

            // collect selected objects (handle, area, vertnum)
            List<ObjectData> objData = srcNodes
                .Where(n =>
                    n.IsSuperClassOf(SuperClassID.GeometricObject) && //get all geometry objects
                    !n.IsClassOf(ClassID.TargetObject) //exclude any light Target
                )
                .Select(n => new ObjectData(n.Handle, n.Object.GetArea(), n.Object.NumVerts))
                .ToList();
            // get only unique types
            List<ObjectData> distinctObjData = objData
                .GroupBy(o => new { o.AREA, o.VNUM })
                .Select(g => g.First())
                .ToList();
            // print data
            Max.Log("\t\tSource unique nodes:{0}", distinctObjData.Count());
            //distinctObjData.ForEach(o => Max.Log("\t\tHandle:{0}\n\t\t\tArea:{1}\n\t\t\tVcount:{2}", o.HANDLE, o.AREA, o.VNUM));

            IEnumerable<Node> allNodes = Kernel.Scene.AllNodes();
            Kernel.WriteLine("\t\tAll scene nodes:{0}", allNodes.Count());

            //get geometry objects with similar (area, vertnum)
            List<Node> matchNodes = allNodes
                .Where(n =>
                    n.IsSuperClassOf(SuperClassID.GeometricObject) && //get all geometry objects
                    !n.IsClassOf(ClassID.TargetObject) && //exclude any light Target
                    // Returns:
                    //     The zero-based index of the first occurrence of an element
                    //     that matches the conditions defined by match, if found; 
                    //     otherwise, –1.
                    objData.FindIndex(o=> o.MatchBy(
                        new ObjectData (n.Handle, n.Object.GetArea(), n.Object.NumVerts),
                        byArea, byVcount
                    )) != -1
                 )
                .GroupBy(n => n.Handle) //group by handle id
                .Select(g => g.First()) //get unique nodes by handle
                .ToList();

            Kernel.WriteLine("\tSimillar nodes count:{0}", matchNodes.Count());
            //matchNodes.ForEach(o => Max.Log("\t\tHandle:{0}\n\t\t\tArea:{1}\n\t\t\tVcount:{2}", o.Handle, o.Object.GetArea(), o.Object.NumVerts));

            //execute action with undo enabled
            Kernel.Undo.Begin();
            SelectNodes(matchNodes, true);
            Kernel.Undo.Accept("Select Simillar");
            Kernel.Undo.End();
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
    internal class ObjectData {

        public ulong HANDLE { get; set; }
        public double AREA { get; set; } = 0.0;
        public int VNUM { get; set; } = 0;
        public ObjectData(ulong handle, double area = 0, int vnum = 0) {

            HANDLE = handle;
            AREA = area;
            VNUM = vnum;
        }
        public bool MatchBy(ObjectData obj, bool byArea, bool byVcount) {

            if ( byArea == true && byVcount == true ) return obj.AREA == AREA && obj.VNUM == VNUM;
            if ( byArea ) return obj.AREA == AREA;
            if ( byVcount ) return obj.VNUM == VNUM;
            return false;
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
