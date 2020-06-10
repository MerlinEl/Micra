//
// Copyright 2012 Autodesk, Inc.  All rights reserved.
//
// Use of this software is subject to the terms of the Autodesk license
// agreement provided at the time of installation or download, or which
// otherwise accompanies this software in either electronic or hard copy form.  
//
using Autodesk.Max;
using System;

namespace Micra.Core {
    /// <summary>
    /// Represents 3-dimensional control points with floating point values. 
    /// </summary>
    [Serializable]
    public class Point3 {
        public float X;
        public float Y;
        public float Z;

        public Point3() : this(0, 0, 0) { }
        public Point3(IPoint3 pt) : this(pt.X, pt.Y, pt.Z) { }
        public Point3(float x, float y, float z) { X = x; Y = y; Z = z; }

        public static Point3 Origin { get { return new Point3(0, 0, 0); } }
        public static Point3 XAxis { get { return new Point3(1, 0, 0); } }
        public static Point3 YAxis { get { return new Point3(0, 1, 0); } }
        public static Point3 ZAxis { get { return new Point3(0, 0, 1); } }

        public static Point3 operator -(Point3 a) { return new Point3(-a.X, -a.Y, -a.Z); }

        /// <summary>usage: Vector Addition</summary>
        public static Point3 operator +(Point3 a, Point3 b) { return new Point3(a.X + b.X, a.Y + b.Y, a.Z + b.Z); }
        /// <summary>usage: Vector Subtraction</summary>
        public static Point3 operator -(Point3 a, Point3 b) { return new Point3(a.X - b.X, a.Y - b.Y, a.Z - b.Z); }
        /// <summary>usage: Cross Product</summary>
        public static Point3 operator ^(Point3 a, Point3 b) { return new Point3(a.Y * b.Z - b.Y * a.Z, a.Z * b.X - b.Z * a.X, a.X * b.Y - b.X * a.Y); }
        /// <summary>usage: Dot Product</summary>
        public static float operator *(Point3 a, Point3 b) { return ( a.X * b.X + a.Y * b.Y + a.Z * b.Z ); }
        /// <summary>usage:Scale Up</summary>
        public static Point3 operator *(Point3 a, float scale) { return new Point3(a.X * scale, a.Y * scale, a.Z * scale); }
        /// <summary>usage: Scale Down</summary>
        public static Point3 operator /(Point3 a, float scale) { return new Point3(a.X / scale, a.Y / scale, a.Z / scale); }
        /// <summary>usage: Get IPoint3 from Point3</summary>
        public IPoint3 _IPoint3 { get { return Kernel._Global.Point3.Create(X, Y, Z); } }

        public float Length { get { return (float)Math.Sqrt(LengthSquared); } }
        public float LengthSquared { get { return (float)( X * X + Y * Y + Z * Z ); } }
        public Point3 Normalized { get { float len = Length; return new Point3(X / len, Y / len, Z / len); } }

        public void Normalize() { float len = Length; X /= len; Y /= len; Z /= len; }
        /// <summary>usage: Distance from current Point3 to another Point3</summary>
        internal double DistanceTo(Point3 p2) => Distance(this, p2); //TODO -not tested -not used
        /// <summary>usage: Distance between two Points3</summary>
        internal static double Distance(Point3 p1, Point3 p2) {

            /*return Math.Sqrt(
                ( Math.Pow( p2.X - p1.X, 2 ) ) +
                ( Math.Pow( p2.Y - p1.Y, 2 ) ) +
                ( Math.Pow( p2.Z - p1.Z, 2 ) )
            );*/
            return ( p2 - p1 ).Length;
        }

        // Allow array-like access to this class
        public float this[int i] {
            get {
                switch ( i ) {
                    case 0: return X;
                    case 1: return Y;
                    case 2: return Z;
                    default:
                    throw new IndexOutOfRangeException();
                }
            }
            set {
                switch ( i ) {
                    case 0: X = value; break;
                    case 1: Y = value; break;
                    case 2: Z = value; break;
                    default:
                    throw new IndexOutOfRangeException();
                }
            }
        }
    }
}
