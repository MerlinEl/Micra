using Autodesk.Max;
using System;

namespace Micra.Domain {
    public class Listener {

        public static IGlobal Global => GlobalInterface.Instance;

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

        public static void WriteLine(string s, params object[] args) {
            WriteLine(String.Format(s, args));
        }
    }
}
