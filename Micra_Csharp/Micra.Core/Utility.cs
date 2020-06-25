//
// Copyright 2012 Autodesk, Inc.  All rights reserved.
//
// Use of this software is subject to the terms of the Autodesk license
// agreement provided at the time of installation or download, or which
// otherwise accompanies this software in either electronic or hard copy form.  
//
using Autodesk.Max;
using System;
using System.Collections;
using System.Collections.Generic;

namespace Micra.Core {
    /// <summary>
    /// Contains various utility functions.
    /// </summary>
    public static class Utility {

        /// <summary>
        /// Extends IEnumerable&lt;T> with a new function for selecing only those 
        /// instances which match a specific type.
        /// </summary>
        /// <typeparam name="T"></typeparam>
        /// <param name="xs"></param>
        /// <returns></returns>
        public static IEnumerable<T> FilterType<T>(this IEnumerable xs) where T : class {
            foreach ( var x in xs )
                if ( x is T )
                    yield return x as T;
        }

        /// <summary> //not used not tested
        /// So to find the distinct values using just the Id property, you could use:
        /// var query = people.DistinctBy(p => p.Id);
        /// And to use multiple properties, you can use anonymous types, which implement equality appropriately:
        /// var query = people.DistinctBy(p => new { p.Id, p.Name });
        /// </summary>
        /// <typeparam name="TSource"></typeparam>
        /// <typeparam name="TKey"></typeparam>
        /// <param name="source"></param>
        /// <param name="keySelector"></param>
        /// <returns></returns>
        public static IEnumerable<TSource> DistinctBy<TSource, TKey>
            (this IEnumerable<TSource> source, Func<TSource, TKey> keySelector) {
            HashSet<TKey> seenKeys = new HashSet<TKey>();
            foreach ( TSource element in source ) {
                if ( seenKeys.Add(keySelector(element)) ) {
                    yield return element;
                }
            }
        }
    }

    /// <summary>
    /// Simplifies the declaration of named index properties on a class, 
    /// by allowing the getter and setter functions to be mapped to 
    /// anonymous functions. This is important because in C#, a named property 
    /// can't be accessed using the '[x]' property.
    /// </summary>
    /// <typeparam name="IndexT"></typeparam>
    /// <typeparam name="ValueT"></typeparam>
    public class IndexedProperty<IndexT, ValueT> {
        readonly Action<IndexT, ValueT> setAction;
        readonly Func<IndexT, ValueT> getFunc;

        public IndexedProperty(Func<IndexT, ValueT> getFunc, Action<IndexT, ValueT> setAction) {
            this.getFunc = getFunc;
            this.setAction = setAction;
        }

        public ValueT this[IndexT i] {
            get {
                return getFunc(i);
            }
            set {
                setAction(i, value);
            }
        }
    }
}