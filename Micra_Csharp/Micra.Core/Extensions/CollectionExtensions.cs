using Autodesk.Max;
using System;
using System.Collections.Generic;
using System.Linq;

namespace Micra.Core.Extensions {
    public static class CollectionExtensions {

        /// <summary> Extension method to convert ITab<T> to an IEnumerable to easily iterate through the list.
        ///     <example> 
        ///         <code>
		///             example:
        ///             ITab<IMtlBase> materialsLib = GlobalInterface.Instance.COREInterface15.SceneMtls;
        ///             foreach (var materialBase in materialsLib.ToIEnumerable()) {.... }
		///         </code>
		///     </example>
        ///     <para>param: <paramref name="itab"/></para>
        /// </summary>
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
        /// <summary> Do an action during loop
        ///     <br>Used: <see cref="PrimitiveClassGenerator.CreateStringEnums"/></br>
        /// </summary>
        public static IEnumerable<T> Do<T>(this IEnumerable<T> collection, Action<T> action) {
            foreach ( T item in collection ) action(item);
            return collection;
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

        /// <summary> Lop trough custommers and set the parameter for tohse which fullfill condition
        ///     <example> 
        ///         <code>
		///             example: 
        ///             <br>customers.Where(c => c.IsValid).SetValue(c => c.CreditLimit = 1000).ToList();</br>
        ///             <br>or</br>
        ///             <br>var newCustomers = customers.Where(c => c.IsValid).SetValue(c => c.CreditLimit = 1000);</br>
		///         </code>
		///     </example>
        /// </summary>
        public static IEnumerable<T> SetValue<T>(this IEnumerable<T> items, Action<T> updateMethod) {
            foreach ( T item in items ) {
                updateMethod(item);
            }
            return items;
        }
        //TODO -not tested -not used
        /// <summary> LINQ's Distinct() on a particular property
        ///     <example> 
        ///         <code>
		///             example: 
        ///             <br>var query = people.DistinctBy(p => p.Id);</br>
        ///             <br>var query = people.DistinctBy(p => new { p.Id, p.Name });</br>
		///         </code>
		///     </example>
        /// </summary>
        public static IEnumerable<TSource> DistinctBy<TSource, TKey>(this IEnumerable<TSource> source, Func<TSource, TKey> keySelector) {
            HashSet<TKey> seenKeys = new HashSet<TKey>();
            foreach ( TSource element in source ) {
                if ( seenKeys.Add(keySelector(element)) ) {
                    yield return element;
                }
            }
        }

        #region Test
        public static void AddUniqueItem<T>(this List<T> list, T item, bool throwException) {
            if ( !list.Contains(item) ) {
                list.Add(item);
            } else if ( throwException ) {
                throw new InvalidOperationException("Item already exists in the list");
            }
        }
        public static bool IsUnique<T>(this List<T> list, IEqualityComparer<T> comparer) {
            return list.Count == list.Distinct(comparer).Count();
        }
        public static bool IsUnique<T>(this List<T> list) {
            return list.Count == list.Distinct().Count();
        }
        #endregion

    }
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
/*public static IEnumerable<T> Where<T>(this IEnumerable<T> data, Func<T, bool> predicate) {
    foreach ( T value in data ) {
        if ( predicate(value) ) yield return value;
    }
}*/

/*


What if I want to obtain a distinct list based on one or more properties?
Simple! You want to group them and pick a winner out of the group.

List<Person> distinctPeople = allPeople
  .GroupBy(p => p.PersonId)
  .Select(g => g.First())
  .ToList();

If you want to define groups on multiple properties, here's how:

List<Person> distinctPeople = allPeople
  .GroupBy(p => new {p.PersonId, p.FavoriteColor} )
  .Select(g => g.First())
  .ToList();


 */
