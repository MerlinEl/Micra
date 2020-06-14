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
    static class Utility {
        /// <summary>
        /// Converts an float or double object to a float.
        /// </summary>
        /// <param name="o"></param>
        /// <returns></returns>
        public static float OToF(object o) {
            if ( o is float )
                return ( float )o;
            if ( o is double )
                return ( float )( double )o;
            throw new Exception("Unrecognized floating point type " + o);
        }

        public static double ToDouble(float f) {
            //f = 5.2F;
            decimal dec = new decimal(f); //5.2
            return ( double )dec; //5.2
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

    /// <summary>
    /// Provides a number of predefined colors for convenience.
    /// </summary>
    public static class Colors {
        public static Color AliceBlue { get { return new Color(System.Drawing.Color.AliceBlue); } }
        public static Color AntiqueWhite { get { return new Color(System.Drawing.Color.AntiqueWhite); } }
        public static Color Aqua { get { return new Color(System.Drawing.Color.Aqua); } }
        public static Color Aquamarine { get { return new Color(System.Drawing.Color.Aquamarine); } }
        public static Color Azure { get { return new Color(System.Drawing.Color.Azure); } }
        public static Color Beige { get { return new Color(System.Drawing.Color.Beige); } }
        public static Color Bisque { get { return new Color(System.Drawing.Color.Bisque); } }
        public static Color Black { get { return new Color(System.Drawing.Color.Black); } }
        public static Color BlanchedAlmond { get { return new Color(System.Drawing.Color.BlanchedAlmond); } }
        public static Color Blue { get { return new Color(System.Drawing.Color.Blue); } }
        public static Color BlueViolet { get { return new Color(System.Drawing.Color.BlueViolet); } }
        public static Color Brown { get { return new Color(System.Drawing.Color.Brown); } }
        public static Color BurlyWood { get { return new Color(System.Drawing.Color.BurlyWood); } }
        public static Color CadetBlue { get { return new Color(System.Drawing.Color.CadetBlue); } }
        public static Color Chartreuse { get { return new Color(System.Drawing.Color.Chartreuse); } }
        public static Color Chocolate { get { return new Color(System.Drawing.Color.Chocolate); } }
        public static Color Coral { get { return new Color(System.Drawing.Color.Coral); } }
        public static Color CornflowerBlue { get { return new Color(System.Drawing.Color.CornflowerBlue); } }
        public static Color Cornsilk { get { return new Color(System.Drawing.Color.Cornsilk); } }
        public static Color Crimson { get { return new Color(System.Drawing.Color.Crimson); } }
        public static Color Cyan { get { return new Color(System.Drawing.Color.Cyan); } }
        public static Color DarkBlue { get { return new Color(System.Drawing.Color.DarkBlue); } }
        public static Color DarkCyan { get { return new Color(System.Drawing.Color.DarkCyan); } }
        public static Color DarkGoldenrod { get { return new Color(System.Drawing.Color.DarkGoldenrod); } }
        public static Color DarkGray { get { return new Color(System.Drawing.Color.DarkGray); } }
        public static Color DarkGreen { get { return new Color(System.Drawing.Color.DarkGreen); } }
        public static Color DarkKhaki { get { return new Color(System.Drawing.Color.DarkKhaki); } }
        public static Color DarkMagenta { get { return new Color(System.Drawing.Color.DarkMagenta); } }
        public static Color DarkOliveGreen { get { return new Color(System.Drawing.Color.DarkOliveGreen); } }
        public static Color DarkOrange { get { return new Color(System.Drawing.Color.DarkOrange); } }
        public static Color DarkOrchid { get { return new Color(System.Drawing.Color.DarkOrchid); } }
        public static Color DarkRed { get { return new Color(System.Drawing.Color.DarkRed); } }
        public static Color DarkSalmon { get { return new Color(System.Drawing.Color.DarkSalmon); } }
        public static Color DarkSeaGreen { get { return new Color(System.Drawing.Color.DarkSeaGreen); } }
        public static Color DarkSlateBlue { get { return new Color(System.Drawing.Color.DarkSlateBlue); } }
        public static Color DarkSlateGray { get { return new Color(System.Drawing.Color.DarkSlateGray); } }
        public static Color DarkTurquoise { get { return new Color(System.Drawing.Color.DarkTurquoise); } }
        public static Color DarkViolet { get { return new Color(System.Drawing.Color.DarkViolet); } }
        public static Color DeepPink { get { return new Color(System.Drawing.Color.DeepPink); } }
        public static Color DeepSkyBlue { get { return new Color(System.Drawing.Color.DeepSkyBlue); } }
        public static Color DimGray { get { return new Color(System.Drawing.Color.DimGray); } }
        public static Color DodgerBlue { get { return new Color(System.Drawing.Color.DodgerBlue); } }
        public static Color Firebrick { get { return new Color(System.Drawing.Color.Firebrick); } }
        public static Color FloralWhite { get { return new Color(System.Drawing.Color.FloralWhite); } }
        public static Color ForestGreen { get { return new Color(System.Drawing.Color.ForestGreen); } }
        public static Color Fuchsia { get { return new Color(System.Drawing.Color.Fuchsia); } }
        public static Color Gainsboro { get { return new Color(System.Drawing.Color.Gainsboro); } }
        public static Color GhostWhite { get { return new Color(System.Drawing.Color.GhostWhite); } }
        public static Color Gold { get { return new Color(System.Drawing.Color.Gold); } }
        public static Color Goldenrod { get { return new Color(System.Drawing.Color.Goldenrod); } }
        public static Color Gray { get { return new Color(System.Drawing.Color.Gray); } }
        public static Color Green { get { return new Color(System.Drawing.Color.Green); } }
        public static Color GreenYellow { get { return new Color(System.Drawing.Color.GreenYellow); } }
        public static Color Honeydew { get { return new Color(System.Drawing.Color.Honeydew); } }
        public static Color HotPink { get { return new Color(System.Drawing.Color.HotPink); } }
        public static Color IndianRed { get { return new Color(System.Drawing.Color.IndianRed); } }
        public static Color Indigo { get { return new Color(System.Drawing.Color.Indigo); } }
        public static Color Khaki { get { return new Color(System.Drawing.Color.Khaki); } }
        public static Color Lavender { get { return new Color(System.Drawing.Color.Lavender); } }
        public static Color LavenderBlush { get { return new Color(System.Drawing.Color.LavenderBlush); } }
        public static Color LawnGreen { get { return new Color(System.Drawing.Color.LawnGreen); } }
        public static Color LemonChiffon { get { return new Color(System.Drawing.Color.LemonChiffon); } }
        public static Color LightBlue { get { return new Color(System.Drawing.Color.LightBlue); } }
        public static Color LightCoral { get { return new Color(System.Drawing.Color.LightCoral); } }
        public static Color LightCyan { get { return new Color(System.Drawing.Color.LightCyan); } }
        public static Color LightGoldenrodYellow { get { return new Color(System.Drawing.Color.LightGoldenrodYellow); } }
        public static Color LightGray { get { return new Color(System.Drawing.Color.LightGray); } }
        public static Color LightGreen { get { return new Color(System.Drawing.Color.LightGreen); } }
        public static Color LightPink { get { return new Color(System.Drawing.Color.LightPink); } }
        public static Color LightSalmon { get { return new Color(System.Drawing.Color.LightSalmon); } }
        public static Color LightSeaGreen { get { return new Color(System.Drawing.Color.LightSeaGreen); } }
        public static Color LightSkyBlue { get { return new Color(System.Drawing.Color.LightSkyBlue); } }
        public static Color LightSlateGray { get { return new Color(System.Drawing.Color.LightSlateGray); } }
        public static Color LightSteelBlue { get { return new Color(System.Drawing.Color.LightSteelBlue); } }
        public static Color LightYellow { get { return new Color(System.Drawing.Color.LightYellow); } }
        public static Color Lime { get { return new Color(System.Drawing.Color.Lime); } }
        public static Color LimeGreen { get { return new Color(System.Drawing.Color.LimeGreen); } }
        public static Color Linen { get { return new Color(System.Drawing.Color.Linen); } }
        public static Color Magenta { get { return new Color(System.Drawing.Color.Magenta); } }
        public static Color Maroon { get { return new Color(System.Drawing.Color.Maroon); } }
        public static Color MediumAquamarine { get { return new Color(System.Drawing.Color.MediumAquamarine); } }
        public static Color MediumBlue { get { return new Color(System.Drawing.Color.MediumBlue); } }
        public static Color MediumOrchid { get { return new Color(System.Drawing.Color.MediumOrchid); } }
        public static Color MediumPurple { get { return new Color(System.Drawing.Color.MediumPurple); } }
        public static Color MediumSeaGreen { get { return new Color(System.Drawing.Color.MediumSeaGreen); } }
        public static Color MediumSlateBlue { get { return new Color(System.Drawing.Color.MediumSlateBlue); } }
        public static Color MediumSpringGreen { get { return new Color(System.Drawing.Color.MediumSpringGreen); } }
        public static Color MediumTurquoise { get { return new Color(System.Drawing.Color.MediumTurquoise); } }
        public static Color MediumVioletRed { get { return new Color(System.Drawing.Color.MediumVioletRed); } }
        public static Color MidnightBlue { get { return new Color(System.Drawing.Color.MidnightBlue); } }
        public static Color MintCream { get { return new Color(System.Drawing.Color.MintCream); } }
        public static Color MistyRose { get { return new Color(System.Drawing.Color.MistyRose); } }
        public static Color Moccasin { get { return new Color(System.Drawing.Color.Moccasin); } }
        public static Color NavajoWhite { get { return new Color(System.Drawing.Color.NavajoWhite); } }
        public static Color Navy { get { return new Color(System.Drawing.Color.Navy); } }
        public static Color OldLace { get { return new Color(System.Drawing.Color.OldLace); } }
        public static Color Olive { get { return new Color(System.Drawing.Color.Olive); } }
        public static Color OliveDrab { get { return new Color(System.Drawing.Color.OliveDrab); } }
        public static Color Orange { get { return new Color(System.Drawing.Color.Orange); } }
        public static Color OrangeRed { get { return new Color(System.Drawing.Color.OrangeRed); } }
        public static Color Orchid { get { return new Color(System.Drawing.Color.Orchid); } }
        public static Color PaleGoldenrod { get { return new Color(System.Drawing.Color.PaleGoldenrod); } }
        public static Color PaleGreen { get { return new Color(System.Drawing.Color.PaleGreen); } }
        public static Color PaleTurquoise { get { return new Color(System.Drawing.Color.PaleTurquoise); } }
        public static Color PaleVioletRed { get { return new Color(System.Drawing.Color.PaleVioletRed); } }
        public static Color PapayaWhip { get { return new Color(System.Drawing.Color.PapayaWhip); } }
        public static Color PeachPuff { get { return new Color(System.Drawing.Color.PeachPuff); } }
        public static Color Peru { get { return new Color(System.Drawing.Color.Peru); } }
        public static Color Pink { get { return new Color(System.Drawing.Color.Pink); } }
        public static Color Plum { get { return new Color(System.Drawing.Color.Plum); } }
        public static Color PowderBlue { get { return new Color(System.Drawing.Color.PowderBlue); } }
        public static Color Purple { get { return new Color(System.Drawing.Color.Purple); } }
        public static Color Red { get { return new Color(System.Drawing.Color.Red); } }
        public static Color RosyBrown { get { return new Color(System.Drawing.Color.RosyBrown); } }
        public static Color RoyalBlue { get { return new Color(System.Drawing.Color.RoyalBlue); } }
        public static Color SaddleBrown { get { return new Color(System.Drawing.Color.SaddleBrown); } }
        public static Color Salmon { get { return new Color(System.Drawing.Color.Salmon); } }
        public static Color SandyBrown { get { return new Color(System.Drawing.Color.SandyBrown); } }
        public static Color SeaGreen { get { return new Color(System.Drawing.Color.SeaGreen); } }
        public static Color SeaShell { get { return new Color(System.Drawing.Color.SeaShell); } }
        public static Color Sienna { get { return new Color(System.Drawing.Color.Sienna); } }
        public static Color Silver { get { return new Color(System.Drawing.Color.Silver); } }
        public static Color SkyBlue { get { return new Color(System.Drawing.Color.SkyBlue); } }
        public static Color SlateBlue { get { return new Color(System.Drawing.Color.SlateBlue); } }
        public static Color SlateGray { get { return new Color(System.Drawing.Color.SlateGray); } }
        public static Color Snow { get { return new Color(System.Drawing.Color.Snow); } }
        public static Color SpringGreen { get { return new Color(System.Drawing.Color.SpringGreen); } }
        public static Color SteelBlue { get { return new Color(System.Drawing.Color.SteelBlue); } }
        public static Color Tan { get { return new Color(System.Drawing.Color.Tan); } }
        public static Color Teal { get { return new Color(System.Drawing.Color.Teal); } }
        public static Color Thistle { get { return new Color(System.Drawing.Color.Thistle); } }
        public static Color Tomato { get { return new Color(System.Drawing.Color.Tomato); } }
        public static Color Transparent { get { return new Color(System.Drawing.Color.Transparent); } }
        public static Color Turquoise { get { return new Color(System.Drawing.Color.Turquoise); } }
        public static Color Violet { get { return new Color(System.Drawing.Color.Violet); } }
        public static Color Wheat { get { return new Color(System.Drawing.Color.Wheat); } }
        public static Color White { get { return new Color(System.Drawing.Color.White); } }
        public static Color WhiteSmoke { get { return new Color(System.Drawing.Color.WhiteSmoke); } }
        public static Color Yellow { get { return new Color(System.Drawing.Color.Yellow); } }
        public static Color YellowGreen { get { return new Color(System.Drawing.Color.YellowGreen); } }
    };
}