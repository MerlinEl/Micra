using Autodesk.Max;
using System.Collections.Generic;
using System.Linq;

namespace Micra.Core.Extensions {
    public static class ArrayBitArrayExtensions {
        /// <summary> Cast IEnumerable<ints> in to IBitarray (not used - need test)
        ///     <example> 
        ///         <code>
        ///             example: 
        ///             Enumerable.Range(0, 10).Select(i=> 1).ToBitArray() //set all 10 bits to true
        ///         </code>
        ///     </example>
        ///     <para>param: <paramref name=""/></para>
        /// </summary>
        public static IBitArray ToBitArray(this IEnumerable<int> bitList) {

            IBitArray barr = Kernel.NewIBitarray(bitList.Count());
            bitList.ForEach(i => barr.Set(i));
            return barr;
        }
    }
}

///collect only bits field indexes where value is 1
/// <summary> Convert IBitArray to int List</summary>
/*public static List<int> SelectIBitarrayIndexes(IBitArray bits, bool selectTrue) { //TODO -not tested -not used

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
