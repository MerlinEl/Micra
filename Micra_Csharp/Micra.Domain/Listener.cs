using Autodesk.Max;
using System;

namespace Micra.Domain {
    public class Listener {

        public static void Write(string s, params string[] args) {
            Write(String.Format(s, args));
        }

        public static void Write(string s) {
            #if DEBUG
                Console.WriteLine(s); //switch console for build test
            # else
                GlobalInterface.Instance.TheListener.EditStream.Wputs(s);
                GlobalInterface.Instance.TheListener.EditStream.Flush();
            #endif
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
