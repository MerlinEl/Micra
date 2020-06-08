using Autodesk.Max;
using System;
using System.Collections.Generic;

namespace Micra.Core {
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
        //values.ForEachWithIndex((item, idx) => Console.WriteLine("{0}: {1}", idx, item));
        public static void ForEach<T>(this IEnumerable<T> collection, Action<T, int> handler) {
            int idx = 0;
            foreach ( T item in collection )
                handler(item, idx++);
        }

        //TODO -not tested -not used
        //Point3 center = f.Vtx.Select(v => verts[v]).Sum();
        /*public static Point3 Sum(this IEnumerable<Point3> collection) {
            Point3 sum = new Point3();
            foreach ( Point3 p in collection ) sum += p;
            return sum;
        }*/

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
