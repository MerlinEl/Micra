using Autodesk.Max;
using System;
using System.IO;
using System.Reflection;

namespace Micra.Domain {
    public class Listener {

        public static void Write(string s, params string[] args) {
            Write(String.Format(s, args));
        }

        public static void Write(string s) {

            GlobalInterface.Instance.TheListener.EditStream.Wputs(s);
            GlobalInterface.Instance.TheListener.EditStream.Flush();
            //Console.WriteLine(s); //switch console for build test
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
