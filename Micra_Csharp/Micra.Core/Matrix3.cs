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
