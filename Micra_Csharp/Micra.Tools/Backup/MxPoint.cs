using Orien.Tools;
using System;

namespace Micra.Tools.Objects {
    /// <summary>
    /// MxPoint - 3D point representation. 
    /// Defaults to (0,0,0).
    /// </summary>
    public partial struct MxPoint : IFormattable {

        //------------------------------------------------------
        //
        //  Private Fields
        //
        //------------------------------------------------------

        #region Private Fields

        private double _x;
        private double _y;
        private double _z;

        #endregion Private Fields
        //------------------------------------------------------
        //
        //  Constructors
        //
        //------------------------------------------------------

        #region Constructors

        /// <summary>
        /// Constructor that sets point's initial values.
        /// </summary>
        /// <param name="x">Value of the X coordinate of the new point.</param>
        /// <param name="y">Value of the Y coordinate of the new point.</param>
        /// <param name="z">Value of the Z coordinate of the new point.</param>
        public MxPoint(double x, double y, double z) {
            _x = x;
            _y = y;
            _z = z;
        }

        #endregion Constructors


        //------------------------------------------------------
        //
        //  Public Methods
        //
        //------------------------------------------------------

        #region Public Methods

        internal double X { get => _x; set => _x = value; }
        internal double Y { get => _y; set => _y = value; }
        internal double Z { get => _z; set => _z = value; }

        /// <summary>
        /// Offset - update point position by adding offsetX to X, offsetY to Y, and offsetZ to Z.
        /// </summary>
        /// <param name="offsetX">Offset in the X direction.</param>
        /// <param name="offsetY">Offset in the Y direction.</param>
        /// <param name="offsetZ">Offset in the Z direction.</param>
        public void Offset(double offsetX, double offsetY, double offsetZ) {
            _x += offsetX;
            _y += offsetY;
            _z += offsetZ;
        }

        /// <summary>
        /// MxPoint + MxVector addition.
        /// </summary>
        /// <param name="point">Point being added.</param>
        /// <param name="vector">Vector being added.</param>
        /// <returns>Result of addition.</returns>
        public static MxPoint operator +(MxPoint point, MxVector vector) {
            return new MxPoint(point._x + vector.X,
                               point._y + vector.Y,
                               point._z + vector.Z);
        }

        /// <summary>
        /// MxPoint + MxVector addition.
        /// </summary>
        /// <param name="point">Point being added.</param>
        /// <param name="vector">Vector being added.</param>
        /// <returns>Result of addition.</returns>
        public static MxPoint Add(MxPoint point, MxVector vector) {
            return new MxPoint(point._x + vector.X,
                               point._y + vector.Y,
                               point._z + vector.Z);
        }

        /// <summary>
        /// MxPoint - MxVector subtraction.
        /// </summary>
        /// <param name="point">Point from which vector is being subtracted.</param>
        /// <param name="vector">Vector being subtracted from the point.</param>
        /// <returns>Result of subtraction.</returns>
        public static MxPoint operator -(MxPoint point, MxVector vector) {
            return new MxPoint(point._x - vector.X,
                               point._y - vector.Y,
                               point._z - vector.Z);
        }

        /// <summary>
        /// MxPoint - MxVector subtraction.
        /// </summary>
        /// <param name="point">Point from which vector is being subtracted.</param>
        /// <param name="vector">Vector being subtracted from the point.</param>
        /// <returns>Result of subtraction.</returns>
        public static MxPoint Subtract(MxPoint point, MxVector vector) {
            return new MxPoint(point._x - vector.X,
                               point._y - vector.Y,
                               point._z - vector.Z);
        }

        /// <summary>
        /// Subtraction.
        /// </summary>
        /// <param name="point1">Point from which we are subtracting the second point.</param>
        /// <param name="point2">Point being subtracted.</param>
        /// <returns>Vector between the two points.</returns>
        public static MxVector operator -(MxPoint point1, MxPoint point2) {
            return new MxVector(point1._x - point2._x,
                                point1._y - point2._y,
                                point1._z - point2._z);
        }

        /// <summary>
        /// Subtraction.
        /// </summary>
        /// <param name="point1">Point from which we are subtracting the second point.</param>
        /// <param name="point2">Point being subtracted.</param>
        /// <returns>Vector between the two points.</returns>
        public static MxVector Subtract(MxPoint point1, MxPoint point2) {
            MxVector v = new MxVector();
            Subtract(ref point1, ref point2, out v);
            return v;
        }

        /// <summary>
        /// Faster internal version of Subtract that avoids copies
        ///
        /// p1 and p2 to a passed by ref for perf and ARE NOT MODIFIED
        /// </summary>
        internal static void Subtract(ref MxPoint p1, ref MxPoint p2, out MxVector result) {

            result = new MxVector {
                X = p1.X - p2.X,
                Y = p1.Y - p2.Y,
                Z = p1.Z - p2.Z
            };
        }

        /// <summary>
        /// MxPoint * Matrix3D multiplication.
        /// </summary>
        /// <param name="point">Point being transformed.</param>
        /// <param name="matrix">Transformation matrix applied to the point.</param>
        /// <returns>Result of the transformation matrix applied to the point.</returns>
        /*public static MxPoint operator *(MxPoint point, Matrix3D matrix) {
            return matrix.Transform(point);
        }*/

        /// <summary>
        /// MxPoint * Matrix3D multiplication.
        /// </summary>
        /// <param name="point">Point being transformed.</param>
        /// <param name="matrix">Transformation matrix applied to the point.</param>
        /// <returns>Result of the transformation matrix applied to the point.</returns>
        /*public static MxPoint Multiply(MxPoint point, Matrix3D matrix) {
            return matrix.Transform(point);
        }*/

        /// <summary>
        /// Explicit conversion to MxVector.
        /// </summary>
        /// <param name="point">Given point.</param>
        /// <returns>Vector representing the point.</returns>
        public static explicit operator MxVector(MxPoint point) {
            return new MxVector(point._x, point._y, point._z);
        }

        /// <summary>
        /// Explicit conversion to Point4D.
        /// </summary>
        /// <param name="point">Given point.</param>
        /// <returns>4D point representing the 3D point.</returns>
        /*public static explicit operator Point4D(MxPoint point) {
            return new Point4D(point._x, point._y, point._z, 1.0);
        }*/

        /// <summary>
        /// Parse - returns an instance converted from the provided string "[0, 0, 0]" or "(0,0,0)"
        /// <param name="source"> string with MxPoint data </param>
        /// </summary>
        public static MxPoint Parse(string source) {

            source = McString.RemoveChars(source, new string[] { "[", "]", "(", ")", " " }); //remove brackets and empty spaces
            string[] three_fields = source.Split(','); //split string in to three values
            if ( three_fields.Length != 3 ) throw new ArgumentException("MxPoint > Can't Parse String to MxPoint. Incorrect String Format");
            double x, y, z;
            try {
                x = Double.Parse(three_fields[0]);
                y = Double.Parse(three_fields[1]);
                z = Double.Parse(three_fields[2]);
            } catch {

                throw new ArgumentException("MxPoint > Can't Parse String to MxPoint. Incorrect String Format");
            }
            return new MxPoint(x, y, z);
        }

        #endregion Public Methods

        #region Internal Properties


        /// <summary>
        /// Creates a string representation of this object based on the current culture.
        /// </summary>
        /// <returns>
        /// A string representation of this object.
        /// </returns>
        public override string ToString() {

            // Delegate to the internal method which implements all ToString calls.
            return ConvertToString(null /* format string */, null /* format provider */);
        }

        /// <summary>
        /// Creates a string representation of this object based on the IFormatProvider
        /// passed in.  If the provider is null, the CurrentCulture is used.
        /// </summary>
        /// <returns>
        /// A string representation of this object.
        /// </returns>
        public string ToString(IFormatProvider provider) {

            // Delegate to the internal method which implements all ToString calls.
            return ConvertToString(null /* format string */, provider);
        }

        /// <summary>
        /// Creates a string representation of this object based on the format string
        /// and IFormatProvider passed in.
        /// If the provider is null, the CurrentCulture is used.
        /// See the documentation for IFormattable for more information.
        /// </summary>
        /// <returns>
        /// A string representation of this object.
        /// </returns>
        string IFormattable.ToString(string format, IFormatProvider provider) {

            // Delegate to the internal method which implements all ToString calls.
            return ConvertToString(format, provider);
        }

        /// <summary>
        /// Creates a string representation of this object based on the format string
        /// and IFormatProvider passed in.
        /// If the provider is null, the CurrentCulture is used.
        /// See the documentation for IFormattable for more information.
        /// </summary>
        /// <returns>
        /// A string representation of this object.
        /// </returns>
        internal string ConvertToString(string format, IFormatProvider provider) {
            // Helper to get the numeric list separator for a given culture.
            char separator = ',';
            return String.Format(provider,
                "{1:" + format + "}{0}{2:" + format + "}{0}{3:" + format + "}",
                separator,
                _x,
                _y,
                _z);
        }

        #endregion Internal Properties
    }
}
