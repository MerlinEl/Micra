using System;

namespace Micra.Tools.Objects {
    /// <summary>
    /// Size3D - A value type which defined a size in terms of non-negative width, 
    /// length, and height.
    /// </summary>
    public partial struct MxSize {
        #region Constructors

        /// <summary>
        /// Constructor which sets the size's initial values.  Values must be non-negative.
        /// </summary>
        /// <param name="x">X dimension of the new size.</param>
        /// <param name="y">Y dimension of the new size.</param>
        /// <param name="z">Z dimension of the new size.</param>
        public MxSize(double x, double y, double z) {
            if ( x < 0 || y < 0 || z < 0 ) {
                throw new ArgumentException("Size3D > DimensionCannotBeNegative");
            }
            _x = x;
            _y = y;
            _z = z;
        }

        #endregion Constructors

        #region Statics

        /// <summary>
        /// Empty - a static property which provides an Empty size.  X, Y, and Z are 
        /// negative-infinity.  This is the only situation
        /// where size can be negative.
        /// </summary>
        public static MxSize Empty {
            get {
                return s_empty;
            }
        }

        #endregion Statics

        #region Public Methods and Properties

        /// <summary>
        /// IsEmpty - this returns true if this size is the Empty size.
        /// Note: If size is 0 this Size3D still contains a 0, 1, or 2 dimensional set
        /// of points, so this method should not be used to check for 0 volume.
        /// </summary>
        public bool IsEmpty {
            get {
                return _x < 0;
            }
        }

        /// <summary>
        /// Size in X dimension. Default is 0, must be non-negative.
        /// </summary>
        public double X {
            get {
                return _x;
            }
            set {
                if ( IsEmpty ) {
                    throw new InvalidOperationException("Size3D > CannotModifyEmptySize");
                }

                if ( value < 0 ) {
                    throw new ArgumentException("Size3D > DimensionCannotBeNegative");
                }

                _x = value;
            }
        }

        /// <summary>
        /// Size in Y dimension. Default is 0, must be non-negative.
        /// </summary>
        public double Y {
            get {
                return _y;
            }
            set {
                if ( IsEmpty ) {
                    throw new InvalidOperationException("Size3D > CannotModifyEmptySize");
                }

                if ( value < 0 ) {
                    throw new ArgumentException("Size3D > DimensionCannotBeNegative");
                }

                _y = value;
            }
        }


        /// <summary>
        /// Size in Z dimension. Default is 0, must be non-negative.
        /// </summary>
        public double Z {
            get {
                return _z;
            }
            set {
                if ( IsEmpty ) {
                    throw new InvalidOperationException("Size3D > CannotModifyEmptySize");
                }

                if ( value < 0 ) {
                    throw new ArgumentException("Size3D > DimensionCannotBeNegative");
                }

                _z = value;
            }
        }

        #endregion Public Methods

        #region Public Operators

        internal double Width { get => _x; set => _x = value; }
        internal double Height { get => _y; set => _y = value; }
        internal double Depth { get => _z; set => _z = value; }

        /// <summary>
        /// Explicit conversion to Vector.
        /// </summary>
        /// <param name="size">The size to convert to a vector.</param>
        /// <returns>A vector equal to this size.</returns>
        public static explicit operator MxVector(MxSize size) => new MxVector(size._x, size._y, size._z);

        /// <summary>
        /// Explicit conversion to point.
        /// </summary>
        /// <param name="size">The size to convert to a point.</param>
        /// <returns>A point equal to this size.</returns>
        public static explicit operator MxPoint(MxSize size) => new MxPoint(size._x, size._y, size._z);

        #endregion Public Operators

        #region Private Methods

        private static MxSize CreateEmptySize3D() {
            MxSize empty = new MxSize();
            // Can't use setters because they throw on negative values
            empty._x = Double.NegativeInfinity;
            empty._y = Double.NegativeInfinity;
            empty._z = Double.NegativeInfinity;
            return empty;
        }

        #endregion Private Methods

        #region Private Fields

        private readonly static MxSize s_empty = CreateEmptySize3D();
        private double _x;
        private double _y;
        private double _z;

        #endregion Private Fields
    }
}
