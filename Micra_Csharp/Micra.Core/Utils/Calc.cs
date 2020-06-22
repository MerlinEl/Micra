using System;
using System.Globalization;

namespace Micra.Core.Utils {
    public class Calc {
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

        public static int DigitsCount(int n) {

            if ( n == 0 ) return 0;
            return 1 + DigitsCount(n / 10);
        }

        public static int DecimaslCount(float val) => DecimalsCount(val.ToString());
        public static int DecimaslCount(double val) => DecimalsCount(val.ToString());
        public static int DecimalsCount(string str) {

            bool start = false;
            int count = 0;
            foreach ( char s in str ) {
                if ( s == '.' || s == ',' ) {
                    start = true;
                } else if ( start ) {
                    count++;
                }
            }
            return count;
        }

        /// <summary> Round Double by given int
        ///     <example> 
        ///         <code>
		///             example: 
        ///             <br>RoundDouble(9,1654656, 3) => 9,165</br>
        ///             <br>RoundDouble(9,1654656, 2) => 9,17</br>
		///         </code>
		///     </example>
        ///     <para>param: <paramref name=""/></para>
        /// </summary>
        public static double RoundDouble(double d, int decimlaPlaces) => Math.Round(d, decimlaPlaces);

        /// <summary> Round Double by given float
        ///     <example> 
        ///         <code>
        ///             example: 
        ///             <br>RoundDouble(9,1654656, 0.001) => 9,165</br>
        ///             <br>RoundDouble(9,1654656, 0.01) => 9,17</br>
        ///         </code>
        ///     </example>
        ///     <para>param: <paramref name=""/></para>
        /// </summary>
        public static double RoundDouble(double d, float precision) {

            //Max.Log("double str:{0} count:{1} precision:{2}", d.ToString(), d.ToString().Length, precision);
            int decimlaPlaces = DecimaslCount(precision);
            //Max.Log("RoundDouble > double:{0} precision:{1} decimals:{2}", d, precision, decimlaPlaces);
            return Math.Round(d, decimlaPlaces);
        }

        /// <summary> Round integer by given int
        ///     <example> 
        ///         <code>
		///             example: 
        ///             <br>RoundInt(1654656, 100) => 1655000</br>
        ///             <br>RoundInt(1654656, 10) => 1654700</br>
		///         </code>
		///     </example>
        ///     <para>param: <paramref name=""/></para>
        /// </summary>
        public static int RoundInt(int area, int precision) {

            int digitsCount = DigitsCount(precision);
            double multi = Math.Pow(10, digitsCount);
            int proportion = (int)Math.Round(area / multi);
            return (int)( proportion * multi );
        }

        internal static double RoundArea(double area, float precision) {

            if ( precision == 0 ) return area; //nothing changes
            if ( precision >= 1 ) { //roud whole number

                return Calc.RoundInt((int)area, (int)precision);

            } else { //round to decimals

                return Calc.RoundDouble(area, precision);
            }
        }

        public static double StringToDouble(string str) {

            str = str.Replace(',', '.');
            double.TryParse(str, NumberStyles.Any, CultureInfo.InvariantCulture, out double value);
            return value;
        }

        public static float StringToFloat(string str) {

            str = str.Replace(',', '.');
            float.TryParse(str, NumberStyles.Any, CultureInfo.InvariantCulture, out float value);
            return value;
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
    }
}


/*
float.Parse(str, CultureInfo.InvariantCulture.NumberFormat);
CultureInfo.InvariantCulture //CultureInfo.GetCultureInfo("en") 
 * 
  var commaCulture = new CultureInfo("en")
    {
        NumberFormat =
        {
            NumberDecimalSeparator = ","
        }
    };

    var pointCulture = new CultureInfo("en")
    {
        NumberFormat =
        {
            NumberDecimalSeparator = "."
        }
    };
 */
