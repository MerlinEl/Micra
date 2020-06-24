using System;
using System.Collections.Generic;
using System.Linq;
//Assembly PJanssen
namespace Micra.Core {
    public static class Throw { //under testing

        //
        // Summary:
        //     A dummy attribute that tells Code Analysis that a parameter has been validated
        //     as not being null.
        [AttributeUsage(AttributeTargets.Parameter)]
        internal sealed class ValidatedNotNullAttribute : Attribute {
        }
        //
        // Summary:
        //     Throws an ArgumentNullException is the supplied argument is null.
        //
        // Example: 
        //      Throw.IfNull(assembly, "assembly");
        //      Throw.IfNull(res, "res");
        // Parameters:
        //   argValue:
        //     The argument value.
        //
        //   argName:
        //     The name of the argument.
        //
        // Exceptions:
        //   T:System.ArgumentNullException:
        public static void IfNull([ValidatedNotNull] object argValue, string argName) {
            if ( argValue == null ) {
                throw new ArgumentNullException(argName);
            }
        }

        //
        // Summary:
        //     Throws an ArgumentNullException is the supplied argument is null and an ArgumentException
        //     if the supplied argument is empty.
        //
        // Parameters:
        //   argValue:
        //     The argument value.
        //
        //   argName:
        //     The name of the argument.
        //
        // Exceptions:
        //   T:System.ArgumentException:
        //
        //   T:System.ArgumentNullException:
        public static void IfNullOrEmpty<T>([ValidatedNotNull] IEnumerable<T> argValue, string argName) {
            IfNull(argValue, argName);
            if ( argValue.Count() == 0 ) {
                throw new ArgumentException("Value cannot be empty.", argName);
            }
        }

        //
        // Summary:
        //     Throws an exception if the supplied value is larger than the supplied maximum
        //     value.
        //
        // Parameters:
        //   argValue:
        //     The value to compare to the mimimum value.
        //
        //   maximumValue:
        //     The largest valid value of pValue.
        //
        //   argName:
        //     The name of the argument.
        //
        // Type parameters:
        //   T:
        //     The type of object to compare. The type must implement IComparable.
        //
        // Exceptions:
        //   T:System.ArgumentOutOfRangeException:
        public static void IfLargerThan<T>(T argValue, T maximumValue, string argName) where T : IComparable<T> {
            if ( argValue.CompareTo(maximumValue) > 0 ) {
                throw new ArgumentOutOfRangeException(argName, argValue, "Maximum value:" + maximumValue.ToString());
            }
        }

        //
        // Summary:
        //     Throws an exception if the supplied value is smaller than the supplied minimum
        //     value.
        //
        // Parameters:
        //   argValue:
        //     The value to compare to the mimimum value.
        //
        //   minimumValue:
        //     The smallest valid value of pValue.
        //
        //   argName:
        //     The name of the argument.
        //
        // Type parameters:
        //   T:
        //     The type of object to compare. The type must implement IComparable.
        //
        // Exceptions:
        //   T:System.ArgumentOutOfRangeException:
        public static void IfSmallerThan<T>(T argValue, T minimumValue, string argName) where T : IComparable<T> {
            if ( argValue.CompareTo(minimumValue) < 0 ) {
                throw new ArgumentOutOfRangeException(argName, argValue, "Minimum value: " + minimumValue.ToString());
            }
        }

        /// <summary> Throws an exception if the supplied value is not in given range
        ///     <example> 
        ///         <code>
		///             example: 
        ///             Throw.IfNotInRange(edgeIndex, 1, Numf*3, "Edge")
		///         </code>
		///     </example>
        ///     <para>param: <paramref name="minimumValue"/> Minimum Value Range</para>
        ///     <para>param: <paramref name="maximumValue"/> Maximum Value Range</para>
        /// </summary>
        public static void IfNotInRange<T>(T argValue, T minimumValue, T maximumValue, string argName) where T : IComparable<T> {
            if ( argValue.CompareTo(minimumValue) < 0 || argValue.CompareTo(maximumValue) > 0 ) {
                throw new ArgumentOutOfRangeException(argName, argValue, 
                    "Allowed range: [ " + minimumValue.ToString() + ", " + maximumValue.ToString() + " ]"
                );
            }
        }
    }
}
