using Autodesk.Max;
using System;

namespace Micra.Core {
    class SDKNETUtilities {

        /// <summary>
        /// Getting local MXC variables: generic bidimensional array
        /// [Ex.: myVar = #(#("hello", 1, true),#("goodbye", 2, false), #("regards", 5, true)) ]
        /// </summary>
        /// <typeparam name="T"></typeparam>    type of the value to retrieve (string, int, float, bool...)
        /// <param name="localVarName"></param> the name of the local variable in MXS
        /// <param name="elementIndex"></param> first index of the bidimensional array (zero-based) [element]
        /// <param name="valueIndex"></param>   second index of the bidimensional array (zero-based) [value]
        /// <returns></returns>                 returned value will be type found (string, int, float, bool...)
        ///                                     converted to type 'T' if possible. ERROR IF CONVERSION IS NOT POSSIBLE
        ///                                     OR defaullt 'T' VALUE if index out of range.
        /// By Andrés Fernández - Proin3D - April 2016     
        ///                                
        static public T GetMxsBiDimensionalLocalVariable<T>(string localVarName, int elementIndex, int valueIndex) {
            IFPValue IFPvar1 = GlobalInterface.Instance.FPValue.Create();
            GlobalInterface.Instance.ExecuteMAXScriptScript(localVarName, false, IFPvar1);

            if ( IFPvar1.Type != ParamType2.FpvalueTabBv ) return default(T);

            ITab<IFPValue> IFPvarMain = IFPvar1.FpvTab;
            if ( elementIndex > IFPvarMain.Count - 1 || elementIndex < 0 ) return default(T);

            IFPValue IFPvar2 = IFPvarMain[( IntPtr )elementIndex];
            if ( IFPvar2.Type != ParamType2.FpvalueTabBv ) return default(T);

            ITab<IFPValue> IFPvarElement = IFPvar2.FpvTab;
            if ( valueIndex > IFPvarElement.Count - 1 || valueIndex < 0 ) return default(T);

            IFPValue IFPvar3 = IFPvarElement[( IntPtr )valueIndex];
            ParamType2 ptype = IFPvar3.Type;

            switch ( ptype ) {
                case ParamType2.Bool:
                case ParamType2.Bool2:
                    return ( T )System.Convert.ChangeType(IFPvar3.B, Type.GetTypeCode(typeof(T)));

                case ParamType2.PcntFrac:
                case ParamType2.Float:
                    return ( T )System.Convert.ChangeType(IFPvar3.F, Type.GetTypeCode(typeof(T)));

                case ParamType2.Double:
                    return ( T )System.Convert.ChangeType(IFPvar3.Dbl, Type.GetTypeCode(typeof(T)));

                case ParamType2.Int:
                    return ( T )System.Convert.ChangeType(IFPvar3.I, Type.GetTypeCode(typeof(T)));

                case ParamType2.Int64:
                case ParamType2.Intptr:
                    return ( T )System.Convert.ChangeType(IFPvar3.Intptr, Type.GetTypeCode(typeof(T)));

                case ParamType2.String:
                    return ( T )System.Convert.ChangeType(IFPvar3.S, Type.GetTypeCode(typeof(T)));

                default:
                    return default(T);
            }
        }
    }
}
