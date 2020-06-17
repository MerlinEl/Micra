using System;
using System.Collections.Generic;

namespace Micra.Core {
    public class Listener {

        /// <summary>
        /// Outputs a string the MAXScript listener with a newline appended
        /// </summary>
        /// <param name="s"></param>
        public static void WriteLine(string s) => Write(s + "\n");
        public static void WriteLine(string s, params Object[] args) {
            WriteLine(String.Format(s, args));
        }
        public static void Write(string s, params Object[] args) {
            Write(String.Format(s, args));
        }
        /// <summary>
        /// Outputs a string the MAXScript listener
        /// </summary>
        /// <param name="s"></param>
        public static void Write(string s) {
            Kernel._Global.TheListener.EditStream.Wputs(s);
            Kernel._Global.TheListener.EditStream.Flush();
        }

        public static void Clear(bool macroRec) {
            // clears the listener
            User32.SendMessage(Kernel._Global.TheListener.EditBox, 2004, (IntPtr)0, (IntPtr)0);
            if ( !macroRec ) return;
            // clears the macro recorder
            User32.SendMessage(Kernel._Global.TheListener.MacrorecBox, 2004, (IntPtr)0, (IntPtr)0);
            //UIAccessor.SetWindowText(_Global.TheListener.MacrorecBox)[2][1]("");
        }
    }
    public static class ListenerExtensions {
        /// <summary> 
        ///     <example> 
        ///         <code>
        ///             example: 
        ///             <br>Type type = typeof(IGlobal.IGlobalClassDirectory);</br>
        ///             <br>BindingFlags flags = BindingFlags.Static | BindingFlags.Public;</br>
        ///             <br>type.GetFields(flags).WriteToListener("~");</br>
        ///         </code>
        ///     </example>
        ///     <para>param: <paramref name=""/></para>
        /// </summary>
        public static void WriteToListener<T>(this IList<T> collection) {

            WriteToListener<T>(collection, "\t");
        }
        public static void WriteToListener<T>(this IList<T> collection, string delimiter) {

            int count = collection.Count;
            for ( int i = 0; i < count; ++i ) {
                Listener.Write("{0}{1}", collection[i].ToString(), delimiter);
            }
            Listener.WriteLine("");
        }
    }
}
