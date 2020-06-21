using Autodesk.Max.Wrappers;
using System;
using System.Globalization;
using System.Linq;

namespace Micra.Core.Utils {
    public class Calc {

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
            int proportion = ( int )Math.Round(area / multi);
            return ( int )( proportion * multi );
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
