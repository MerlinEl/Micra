using Autodesk.Max;
using System;
using System.Collections.Generic;
using System.Linq;

namespace Micra.Core {
    public class Collections {

        public static void DeselectAll(bool redraw = true) {

            Kernel._Interface.ClearNodeSelection(redraw);
        }

        public static void SelectAll(bool hidden, bool redraw = true, bool showProperties = false) {

            if ( showProperties ) {
                foreach ( Node n in Kernel.Scene.RootNode.Children ) {
                    Kernel.WriteLine("Object:{0} type:{1} params:{2}", n.Object.Name, n.GetType().Name, n.Object.Params.ToList().Count);
                    foreach ( IParameter p in n.Object.Params ) Kernel.WriteLine("\tparam:{0}", p.Name);
                };
            }
            List<IINode> nodes = Kernel.Scene.RootNode.Children
                //.Where(n=> n._Node.IsHidden == hidden)
                .Select(n => (IINode)n._Node)
                .ToList();
            Kernel._Interface.SelectNodeTab(ToIINodeTab(nodes), true, redraw);
        }

        public static void SelectAllOfType(SuperClassID classId, bool clearSel, bool redraw) {

            List<IINode> nodes = new List<IINode>() { };
            foreach ( Node n in Kernel.Scene.RootNode.Children ) {

                Kernel.WriteLine("Object class:{0} Compare class:{1} match:{2}", n.Object.SuperClassID, classId, ( n.Object.SuperClassID == classId ));

                if ( n.Object.SuperClassID == classId ) nodes.Add(n._Node);
            }
            if ( clearSel ) DeselectAll(false);
            Kernel._Interface.SelectNodeTab(Collections.ToIINodeTab(nodes), true, redraw);
        }

        public static IINodeTab ToIINodeTab<T>(List<T> nodesList) {

            IINodeTab nodes = Kernel._Global.NodeTab.Create();
            nodesList.ForEach(n => nodes.AppendNode(( n as IINode ), true, 1));
            return nodes;
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
