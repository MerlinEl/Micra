using Autodesk.Max;
using System;

namespace MyAssembly {
    class MaxListener {

        public static IGlobal Global {
            get { return GlobalInterface.Instance; }
        }

        public static void Write(string s, params string[] args) {
            Write(String.Format(s, args));
        }

        public static void Write(string s) {
            Global.TheListener.EditStream.Wputs(s);
            Global.TheListener.EditStream.Flush();
        }

        public static void WriteLine(string s) {
            Write(s);
            Write("\n");
        }

        public static void WriteLine(string s, params string[] args) {
            WriteLine(String.Format(s, args));
        }

        internal static void WriteLine(object p) {
            throw new NotImplementedException();
        }
    }
}
