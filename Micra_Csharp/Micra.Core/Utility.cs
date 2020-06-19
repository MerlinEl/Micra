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
using System.Linq;
using System.Reflection;

namespace Micra.Core {
    /// <summary>
    /// Contains various utility functions.
    /// </summary>
    public static class Utility {
        /// <summary>Give ramdom values from 0.0 to 1.0. Default with three decimals.</summary>
        public static float RandomFloat(Random random) => (float)( Math.Round(random.NextDouble(), 3) );
        public static float RandomFloat(Random random, int decimals) => (float)( Math.Round(random.NextDouble(), decimals) );
        /// <summary>
        /// Converts an float or double object to a float.
        /// </summary>
        /// <param name="o"></param>
        /// <returns></returns>
        public static float OToF(object o) {
            if ( o is float )
                return (float)o;
            if ( o is double )
                return (float)(double)o;
            throw new Exception("Unrecognized floating point type " + o);
        }

        public static double ToDouble(float f) {
            //f = 5.2F;
            decimal dec = new decimal(f); //5.2
            return (double)dec; //5.2
        }

        public static double RadToDeg(double radians) {
            return radians * ( 180.0 / Math.PI );
        }

        public static double DegToRad(double degrees) {
            return degrees * ( Math.PI / 180.0 );
        }

        /// <summary> Heron’s Formula to calculate face area
        ///     <example> 
        ///         <code>
        ///             example: GetTriangleArea(p1, p2, p3);
        ///         </code>
        ///     </example>
        /// </summary>
        public static double GetTriangleArea(Point3 p1, Point3 p2, Point3 p3) {

            double a = p1.DistanceTo(p2);
            double b = p2.DistanceTo(p3);
            double c = p3.DistanceTo(p1);
            double p = 0.5 * ( a + b + c );
            return Math.Sqrt(p * ( p - a ) * ( p - b ) * ( p - c ));
        }

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
        /// <summary> Convert IBitArray to int List</summary>
        public static List<int> IBitarrayToList(IBitArray bits) { //TODO -not tested -not used

            List<int> _bits = new List<int>();
            for ( int index = 0; index < bits.Size; index++ ) {

                if ( bits[index] == 1 ) _bits.Add(index); //collect only bits with True state
            }
            return _bits;
        }
        /// <summary> Convert IBitArray to int Bitarray</summary>
        ///     <example> 
        ///         <code>
		///             example: 
        ///             IBitArray iba = Kernel.NewIBitarray(10);
        ///             for (b in ba do) iba.Set(b)  
        ///             BitArray ba = IBitArrayToBitArray(iba)
		///         </code>
		///     </example>
        ///     <para>param: <paramref name=""/></para>
        /// </summary>
        public static BitArray IBitarrayToBitarray(IBitArray iBitArray) { //TODO -not tested -not used

            if ( iBitArray.IsEmpty ) return new BitArray(0) { };
            BitArray bitArray = new BitArray(iBitArray.Size) { };
            IBitArray tmp = Kernel.NewIBitarray(iBitArray.Size);
            for ( int j = 0; j < iBitArray.Size; j++ ) {

                tmp.ClearAll();
                tmp.Set(j);
                if ( tmp.BitwiseAndWith(iBitArray).AnyBitSet ) bitArray[j] = true;
            }
            return bitArray;
        }


        /*
         fn IBitarrayToBitarray IBitArray =
    (
        result = #{}
        
        if not IBitArray.isEmpty do
        (
            gi = (dotNetClass "Autodesk.Max.GlobalInterface").instance
            
            tmp = gi.BitArray.Create IBitArray.Size
            BitAnd = tmp.BitwiseAndWith
            
            _clear = tmp.ClearAll
            _set   = tmp.Set

            for j = 0 to IBitArray.Size-1 do
            (
                _clear()
                _set j
                if (BitAnd IBitArray).AnyBitSet do result[j+1] = true
            )
        )
        return result
    )
         */

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