using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Micra.Core {
    public class Max {
        public static void MaxLogClear(bool macroRec = false) => Kernel.WriteClear(macroRec);
        public static void MaxLog(string str) => Kernel.WriteLine(str);
        public static void MaxLog(string str, params object[] args) => Kernel.WriteLine(str, args);
        public static int SubObjectLevel => Kernel._Interface.SubObjectLevel;
    }
}
