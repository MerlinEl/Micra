//
// Copyright 2012 Autodesk, Inc.  All rights reserved.
//
// Use of this software is subject to the terms of the Autodesk license
// agreement provided at the time of installation or download, or which
// otherwise accompanies this software in either electronic or hard copy form.  
//
using Autodesk.Max;
using System;
using System.Linq;
using System.Reflection;

namespace Micra.Core {

    public enum TaskModes : uint {

        TASK_MODE_CREATE=1,
        TASK_MODE_MODIFY=2,
        TASK_MODE_HIERARCHY=3,
        TASK_MODE_MOTION=4,
        TASK_MODE_DISPLAY=5,
        TASK_MODE_UTILITY=6,
    }


    /// <summary>
    /// Represents a time value during an animation. 
    /// Wraps the TimeValue typedef in 3ds Max SDK.
    /// <seealso cref="Interval"/>
    /// </summary>
    [Serializable]
    public struct TimeValue {
        public int time;
        public TimeValue(int time) { this.time = time; }
        public static implicit operator TimeValue(int time) { return new TimeValue(time); }
        public static implicit operator int(TimeValue time) { return time.time; }

        public static readonly TimeValue PositiveInfinity = int.MaxValue;
        public static readonly TimeValue NegativeInfinity = int.MinValue;
    }

    /// <summary>
    /// Represents a range of time values during an animation.
    /// Wraps the Interval struct in the 3ds Max SDK.
    /// <seealso cref="TimeValue"/>
    /// </summary>
    [Serializable]
    public struct Interval {
        public TimeValue start;
        public TimeValue end;
        public Interval(IInterval i) { this.start = i.Start; this.end = i.End; }
        public Interval(int start, int end) { this.start = start; this.end = end; }

        public IInterval _IInterval { get { return Kernel._Global.Interval.Create(start, end); } }

        public static readonly Interval Forever = new Interval(TimeValue.NegativeInfinity, TimeValue.PositiveInfinity);
        public static readonly Interval Never = new Interval(TimeValue.NegativeInfinity, TimeValue.NegativeInfinity);
    }

    /// <summary>
    /// Identifies a category of plug-in type. Wraps the SClass_ID class in the 3ds Max SDK. 
    /// </summary>
    [Serializable]
    public struct SuperClassID {
        public ulong id;
        public SuperClassID(SClass_ID id) { this.id = ( ulong )id; }
        public static implicit operator SuperClassID(SClass_ID id) { return new SuperClassID(id); }
        public static implicit operator SClass_ID(SuperClassID id) { return ( SClass_ID )id.id; }

        public static SuperClassID GeometricObject = SClass_ID.Geomobject;
        public static SuperClassID ObjectModifier = SClass_ID.Osm;
        public static SuperClassID Material = SClass_ID.Material;
        public static SuperClassID Texture = SClass_ID.Texmap;
        public static SuperClassID ReferenceTarget = SClass_ID.RefTarget;
        public static SuperClassID ReferenceMaker = SClass_ID.RefMaker;
        public static SuperClassID Light = SClass_ID.Light;
        public static SuperClassID Shape = SClass_ID.Shape;
        public static SuperClassID Camera = SClass_ID.Camera;
        public static SuperClassID Helper = SClass_ID.Helper;
        public static SuperClassID Atmospheric = SClass_ID.Atmospheric;
        public static SuperClassID PositionController = SClass_ID.CtrlPosition;
        public static SuperClassID NotifyAll = new SuperClassID(( SClass_ID )0xfffffff0);
        public static SuperClassID BaseNode = SClass_ID.Basenode;
        public static SuperClassID GenericDerivedObject = SClass_ID.GenDerivob;
        public static SuperClassID DerivedObject = SClass_ID.Derivob;
        public static SuperClassID ParameterBlock2 = SClass_ID.ParameterBlock2;

        public override string ToString() {
            return id.ToString();
        }

        public override bool Equals(object obj) {
            if ( !( obj is SuperClassID ) )
                return false;
            return ( ( SuperClassID )obj ).id == id;
        }

        public override int GetHashCode() {
            return id.GetHashCode();
        }

        public static bool operator ==(SuperClassID x, SuperClassID y) { return x.id == y.id; }
        public static bool operator !=(SuperClassID x, SuperClassID y) { return x.id != y.id; }

        internal string GetSuperClassName(SuperClassID superClassID) {
            //get clas name from Max Enums
            string clsStr = Enum.GetName(typeof(SClass_ID), superClassID.id);
            //get Clas name From Kernel Struct
            /*Type type = typeof(SuperClassID);
            foreach ( var p in type.GetFields(BindingFlags.Static | BindingFlags.Public) ) {
                var v = p.GetValue(null); // static classes cannot be instanced, so use null...
                if ( v.ToString() == superClassID.ToString() ) {
                    clsStr = p.Name;
                    break;
                }
            }*/
            return clsStr;
        }

        public static SuperClassID FromName(string sclassName) {

            Type type = typeof(SuperClassID);
            FieldInfo fi = type
                .GetFields(BindingFlags.Static | BindingFlags.Public)
                .Where(f => f.FieldType == type && f.Name == sclassName).FirstOrDefault();
            return fi != null ? ( SuperClassID )fi.GetValue(fi) : new SuperClassID();
        }

        public static string[] GetNames() {

            Type type = typeof(SuperClassID);
            return type.GetFields(BindingFlags.Static | BindingFlags.Public)
                .Where(f => f.FieldType == type)
                .Select(f => f.Name)
                .ToArray();
        }
    }

    /// <summary>
    /// Identifies a particular plug-in. Wraps the Class_ID class in the 3sd Max SDK.
    /// </summary>
    [Serializable]
    public struct ClassID {
        public uint a;
        public uint b;
        public ClassID(Autodesk.Max.IClass_ID id) : this(id.PartA, id.PartB) { }
        public ClassID(uint a, uint b) { this.a = a; this.b = b; }
        public ClassID(BuiltInClassIDA a, BuiltInClassIDB b) { this.a = ( uint )a; this.b = ( uint )b; }

        public IClass_ID _IClass_ID => Kernel._Global.Class_ID.Create(a, b);

        public static ClassID EditableMesh = new ClassID(BuiltInClassIDA.EDITTRIOBJ_CLASS_ID, 0);
        public static ClassID EditablePoly = new ClassID(BuiltInClassIDA.EPOLYOBJ_CLASS_ID, BuiltInClassIDB.EPOLYOBJ_CLASS_ID);
        public static ClassID BoneGeometry = new ClassID(BuiltInClassIDA.BONE_CLASS_ID, BuiltInClassIDB.BONE_OBJ_CLASSID);
        public static ClassID TargetObject = new ClassID(BuiltInClassIDA.TARGET_CLASS_ID, 0);
        public static ClassID TriObject = new ClassID(BuiltInClassIDA.TRIOBJ_CLASS_ID, 0); //not tested

        //replaced --see if is ok and remove it
        //public static ClassID TriObject = new ClassID(0x0009, 0);

        public string GetClassName(ClassID clsID) {
            //get clas name from Max Enums
            string clsStr = Enum.GetName(typeof(BuiltInClassIDA), clsID.a);
            //get Clas name From Kernel Struct
            /*Type type = typeof(ClassID);
            foreach ( var p in type.GetFields(BindingFlags.Static | BindingFlags.Public) ) {
                var v = p.GetValue(null); // static classes cannot be instanced, so use null...
                if (v.ToString() == clsID.ToString()) {
                    clsStr = p.Name;
                    break;
                }
            }*/
            return clsStr;
        }

        public override string ToString() {
            return "ClassID(" + a.ToString() + ", " + b.ToString() + ")";
        }

        public override bool Equals(object obj) {
            if ( !( obj is ClassID ) )
                return false;
            ClassID that = ( ClassID )obj;
            return a == that.a && b == that.b;
        }

        public override int GetHashCode() {
            return a.GetHashCode() ^ b.GetHashCode();
        }

        public static ClassID FromName(string sclassName) {

            Type type = typeof(ClassID);
            FieldInfo fi = type
                .GetFields(BindingFlags.Static | BindingFlags.Public)
                .Where(f => f.FieldType == type && f.Name == sclassName).FirstOrDefault();
            return fi != null ? ( ClassID )fi.GetValue(fi) : new ClassID();
        }

        public static string[] GetNames() {

            Type type = typeof(ClassID);
            return type.GetFields(BindingFlags.Static | BindingFlags.Public)
                .Where(f => f.FieldType == type)
                .Select(f => f.Name)
                .ToArray();
        }

        public static bool operator ==(ClassID x, ClassID y) { return ( x.a == y.a ) && ( x.b == y.b ); }
        public static bool operator !=(ClassID x, ClassID y) { return ( x.a != y.a ) || ( x.b != y.b ); }
    }

    /// <summary>
    /// Represents a color with each color component represented as a float, including the 
    /// transparency. 
    /// </summary>
    [Serializable]
    public struct Color {
        public float r;
        public float g;
        public float b;
        public float a;

        public Color(System.Drawing.Color c) : this(c.R, c.G, c.B, 255) { }
        public Color(IColor c) : this(c.R, c.G, c.B) { }
        public Color(IAColor c) : this(c.R, c.G, c.B, c.A) { }
        public Color(float r, float g, float b, float a) { this.r = r; this.g = g; this.b = b; this.a = a; }
        public Color(float r, float g, float b) : this(r, g, b, 1.0f) { }
        public Color(byte r, byte g, byte b, byte a) : this(( float )r / 255.0f, ( float )g / 255.0f, ( float )b / 255.0f, ( float )a / 255.0f) { }
        public Color(byte r, byte g, byte b) : this(r, g, b, 255) { }

        int IntR { get { return ( int )( r * 255.0f ); } }
        int IntG { get { return ( int )( g * 255.0f ); } }
        int IntB { get { return ( int )( b * 255.0f ); } }
        int IntA { get { return ( int )( a * 255.0f ); } }

        public IAColor _IAColor { get { return Kernel._Global.AColor.Create(r, g, b, a); } }
        public IColor _IColor { get { return Kernel._Global.Color.Create(r, g, b); } }
        public System.Drawing.Color SystemColor { get { return System.Drawing.Color.FromArgb(IntA, IntR, IntG, IntB); } }

        public static readonly Color MinColor = new Color(0, 0, 0, 0);
        public static readonly Color MaxColor = new Color(( byte )255, ( byte )255, ( byte )255, ( byte )255);
    }

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

        // Vector Addition
        public static Point3 operator +(Point3 a, Point3 b) { return new Point3(a.X + b.X, a.Y + b.Y, a.Z + b.Z); }
        // Vector Subtraction
        public static Point3 operator -(Point3 a, Point3 b) { return new Point3(a.X - b.X, a.Y - b.Y, a.Z - b.Z); }
        // Cross Product
        public static Point3 operator ^(Point3 a, Point3 b) { return new Point3(a.Y * b.Z - b.Y * a.Z, a.Z * b.X - b.Z * a.X, a.X * b.Y - b.X * a.Y); }
        // Dot Product
        public static float operator *(Point3 a, Point3 b) { return ( a.X * b.X + a.Y * b.Y + a.Z * b.Z ); }
        // Scale
        public static Point3 operator *(Point3 a, float scale) { return new Point3(a.X * scale, a.Y * scale, a.Z * scale); }

        public IPoint3 _IPoint3 { get { return Kernel._Global.Point3.Create(X, Y, Z); } }

        public float Length { get { return ( float )Math.Sqrt(LengthSquared); } }
        public float LengthSquared { get { return ( float )( X * X + Y * Y + Z * Z ); } }
        public Point3 Normalized { get { float len = Length; return new Point3(X / len, Y / len, Z / len); } }

        public void Normalize() { float len = Length; X /= len; Y /= len; Z /= len; }

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

    /// <summary>
    /// Represents a transform matrix as four rows of Point3. 
    /// </summary>
    [Serializable]
    public class Matrix3 {
        public Point3[] rows;

        public Matrix3() {
            rows = new Point3[4];
            rows[0] = Point3.Origin;
            rows[1] = Point3.Origin;
            rows[2] = Point3.Origin;
            rows[3] = Point3.Origin;
        }

        public Matrix3(IMatrix3 x)
            : this(new Point3(x.GetRow(0)), new Point3(x.GetRow(1)), new Point3(x.GetRow(2)), new Point3(x.GetRow(3))) { }

        public Matrix3(Point3 r0, Point3 r1, Point3 r2, Point3 r3) {
            rows = new Point3[4];
            rows[0] = r0;
            rows[1] = r1;
            rows[2] = r2;
            rows[3] = r3;
        }

        public Matrix3(Point3 r0, Point3 r1, Point3 r2)
            : this(r0, r1, r2, Point3.Origin) {
        }

        public static Matrix3 Identity { get { return new Matrix3(Point3.XAxis, Point3.YAxis, Point3.ZAxis); } }
        public static Matrix3 Origin { get { return new Matrix3(); } }

        public static Matrix3 Translation(Point3 p) {
            return new Matrix3(Point3.XAxis, Point3.YAxis, Point3.ZAxis, p);
        }

        // Allow access to internals.
        public Point3 this[int i] {
            get { return this.rows[i]; }
            set {
                // Do not assign directly, or we just recieve a reference.
                this.rows[i].X = value.X;
                this.rows[i].Y = value.Y;
                this.rows[i].Z = value.Z;
            }
        }

        public static Point3 operator *(Point3 lhs, Matrix3 rhs) {
            Point3 res = new Point3();
            res[0] = lhs[0] * rhs[0][0] + lhs[1] * rhs[1][0] + lhs[2] * rhs[2][0] + rhs[3][0];
            res[1] = lhs[0] * rhs[0][1] + lhs[1] * rhs[1][1] + lhs[2] * rhs[2][1] + rhs[3][1];
            res[2] = lhs[0] * rhs[0][2] + lhs[1] * rhs[1][2] + lhs[2] * rhs[2][2] + rhs[3][2];

            return res;
        }
        //matrix explanation here 
        // Operator overload - Matrix Mult
        public static Matrix3 operator *(Matrix3 lhs, Matrix3 rhs) {
            Matrix3 res = new Matrix3();
            res[0][0] = lhs[0][0] * rhs[0][0] + lhs[0][1] * rhs[1][0] + lhs[0][2] * rhs[2][0];
            res[0][1] = lhs[0][0] * rhs[0][1] + lhs[0][1] * rhs[1][1] + lhs[0][2] * rhs[2][1];
            res[0][2] = lhs[0][0] * rhs[0][2] + lhs[0][1] * rhs[1][2] + lhs[0][2] * rhs[2][2];

            res[1][0] = lhs[1][0] * rhs[0][0] + lhs[1][1] * rhs[1][0] + lhs[1][2] * rhs[2][0];
            res[1][1] = lhs[1][0] * rhs[0][1] + lhs[1][1] * rhs[1][1] + lhs[1][2] * rhs[2][1];
            res[1][2] = lhs[1][0] * rhs[0][2] + lhs[1][1] * rhs[1][2] + lhs[1][2] * rhs[2][2];

            res[2][0] = lhs[2][0] * rhs[0][0] + lhs[2][1] * rhs[1][0] + lhs[2][2] * rhs[2][0];
            res[2][1] = lhs[2][0] * rhs[0][1] + lhs[2][1] * rhs[1][1] + lhs[2][2] * rhs[2][1];
            res[2][2] = lhs[2][0] * rhs[0][2] + lhs[2][1] * rhs[1][2] + lhs[2][2] * rhs[2][2];

            res[3][0] = lhs[3][0] * rhs[0][0] + lhs[3][1] * rhs[1][0] + lhs[3][2] * rhs[2][0] + rhs[3][0];
            res[3][1] = lhs[3][0] * rhs[0][1] + lhs[3][1] * rhs[1][1] + lhs[3][2] * rhs[2][1] + rhs[3][1];
            res[3][2] = lhs[3][0] * rhs[0][2] + lhs[3][1] * rhs[1][2] + lhs[3][2] * rhs[2][2] + rhs[3][2];

            return res;
        }

        public Matrix3 Invert() {
            // Lazy, terribly inefficent way to do this.
            // do this properly (without thunking to unmanaged code) another time.
            IMatrix3 cppversion = _IMatrix3;
            cppversion.Invert();
            return new Matrix3(cppversion);
        }

        public Matrix3 Translate(Point3 p) {
            rows[3] += p;
            return this;
        }

        public IMatrix3 _IMatrix3 {
            get {
                return Kernel._Global.Matrix3.Create(rows[0]._IPoint3, rows[1]._IPoint3, rows[2]._IPoint3, rows[3]._IPoint3);
            }
        }
    }
}
