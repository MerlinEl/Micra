namespace Micra.Core {
    /// <summary> Max Global Methods - Variables </summary>
    public class Max {
        public static void LogClear(bool macroRec = false) => Kernel.WriteClear(macroRec);
        public static void Log(string str) => Kernel.WriteLine(str);
        public static void Log(string str, params object[] args) => Kernel.WriteLine(str, args);
        public static int SubObjectLevel => Kernel._Interface.SubObjectLevel;
    }
}
