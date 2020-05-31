﻿using Autodesk.Max;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.InteropServices;

namespace Micra.Core {
    public class Collections {

        public static void DeselectAll(bool redraw = false) {

            var nodes = Kernel.Scene.SelectedNodes();
            nodes.ForEach(n => n.Selected = false);
            if ( redraw ) Kernel.RedrawViews();
        }

        public static void SelectAll(bool hidden = false, bool redraw = false) {

            DeselectAll(false); //deselect frist is some hidden are selected
            foreach ( Node n in Kernel.Scene.RootNode.Children ) {
                if ( !hidden && !n.Visible ) continue;
                n.Selected = true;
            }
            if ( redraw ) Kernel.RedrawViews();
            Kernel.WriteLine("Selected nodes:{0}/{1}", Kernel.Scene.SelectedNodes().Count(), Kernel.Scene.RootNode.Children.Count());
        }
        public static void SelectAllOfType(ClassID classId, bool hidden = false, bool clearSel = true, bool redraw = false) {
            Kernel.WriteLine("Selected by Class");
            if ( clearSel ) DeselectAll(false);
            foreach ( Node n in Kernel.Scene.RootNode.Children ) {
                if ( !hidden && !n.Visible ) continue;
                if ( n.Object.ClassID != classId ) continue;
                n.Selected = true;
            }
            if ( redraw ) Kernel.RedrawViews();
            Kernel.WriteLine("\tnodes:{0}/{1}", Kernel.Scene.SelectedNodes().Count(), Kernel.Scene.RootNode.Children.Count());
        }
        public static void SelectAllOfType(SuperClassID sClassId, bool hidden = false, bool clearSel = true, bool redraw = false) {
            Kernel.WriteLine("Selected by Superclass");
            if ( clearSel ) DeselectAll(false);
            foreach ( Node n in Kernel.Scene.RootNode.Children ) {
                if ( !hidden && !n.Visible ) continue;
                if ( n.Object.SuperClassID != sClassId ) continue;
                n.Selected = true;
            }
            if ( redraw ) Kernel.RedrawViews();
            Kernel.WriteLine("\tnodes:{0}/{1}", Kernel.Scene.SelectedNodes().Count(), Kernel.Scene.RootNode.Children.Count());
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
            Kernel._InstanceMgr.GetInstances(node._Node, instanceAndRef);
            return instanceAndRef.ToIEnumerable<IINode>()
                .Select(n => new Node(n))
                .ToList();
        }
        public static void SelectNodes(List<Node> nodes, bool redraw = false) {

            DeselectAll(false);
            foreach ( Node n in nodes ) {
                if ( !n.Visible ) continue;
                n.Selected = true;
            }
            if ( redraw ) Kernel.RedrawViews();
            Kernel.WriteLine("Selected Instance nodes:{0}/{1}", Kernel.Scene.SelectedNodes().Count(), Kernel.Scene.RootNode.Children.Count());
        }
    }
    internal static class CollectionExtensions {

        public static IEnumerable<T> ToIEnumerable<T>(this ITab<T> itab) {

            if ( itab == null ) yield break;
            for ( int i = 0; i < itab.Count; i++ ) {
                yield return itab[i];
            }
        }
        //items.ToList().ForEach(i => i.DoStuff());
        public static void ForEach<T>(this IEnumerable<T> collection, Action<T> action) {
            foreach ( T item in collection )
                action(item);
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
    }
}


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