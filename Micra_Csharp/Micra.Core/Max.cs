using Autodesk.Max;
using System;
using System.Collections.Generic;

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
        public static void LogClear(bool macroRec = false) => Listener.Clear(macroRec);
        public static void Log(string str) => Listener.WriteLine(str);
        public static void Log(string str, params object[] args) => Listener.WriteLine(str, args);

        /// <summary>
        /// Add a string as a new line to the prompt. This is a convenient way to write messages back to the user. 
        /// </summary>
        /// <param name="s"></param>
        public static void PushPrompt(string s) => Kernel._Interface.PushPrompt(s);
        public static int SubObjectLevel => Kernel._Interface.SubObjectLevel;
        public static IILayer CreateLayer() => Kernel._Interface.LayerManager.CreateLayer(); //TODO -not tested -not used

        public static void DeleteObject(SceneObject so) {
            so._Node?.Delete();
            Kernel.RedrawViews();
        }
        //ILayerWrapper layer = MaxNodeWrapper.Create(CreateLayer()) as ILayerWrapper;
        //   Assert.IsNotNull(layer);
    }
}
