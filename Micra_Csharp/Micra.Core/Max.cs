using Autodesk.Max;

namespace Micra.Core {
    /// <summary> Max Global Methods - Variables </summary>
    public class Max {
        private static int maxVersion;
        public static int Version {
            get {
                if ( maxVersion == 0 )
                    maxVersion = 1998 + typeof(IInterface).Assembly.GetName().Version.Major;
                return maxVersion;
            }
        }
        public static void LogClear(bool macroRec = false) => Kernel.WriteClear(macroRec);
        public static void Log(string str) => Kernel.WriteLine(str);
        public static void Log(string str, params object[] args) => Kernel.WriteLine(str, args);
        public static int SubObjectLevel => Kernel._Interface.SubObjectLevel;
        public static IILayer CreateLayer() => Kernel._Interface.LayerManager.CreateLayer(); //TODO -not tested -not used
        //ILayerWrapper layer = MaxNodeWrapper.Create(CreateLayer()) as ILayerWrapper;
        //   Assert.IsNotNull(layer);

    }
}
