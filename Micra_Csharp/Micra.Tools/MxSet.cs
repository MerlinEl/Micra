using Autodesk.Max;
using System;
using System.IO;
using System.Reflection;
using System.Runtime.InteropServices;
//Test Class for load unload Assembly
namespace Micra.Tools {
    public class MxSet {

        public static bool Gc() {
            try {
                GC.Collect(); // collects all unused memory
                GC.WaitForPendingFinalizers(); // wait until GC has finished its work
                GC.Collect();
            } catch {

                return false;
            }
            return true;
        }

        public static IFPValue ExecuteMAXScriptScript(string action, bool quietErrors = false) {
            IFPValue fpv = null;
            MxGet.Global.ExecuteMAXScriptScript(action, quietErrors, fpv);
            //ManagedServices.MaxscriptSDK.ExecuteMaxscriptCommand(cmd);
            return fpv;
        }

        public static void SetAccelerators(bool state) {
            if ( state )
                ManagedServices.AppSDK.EnableAccelerators(); // for lostfocus
            else
                ManagedServices.AppSDK.DisableAccelerators(); // for gotfocus
        }
        public uint ProgressBarFunc(ref IntPtr ppContext) {
            return 0;
        }
        delegate uint ProgressBarDelegate(ref IntPtr ppContext);



        #region Untested

        //MxGet.Interface.AddPrompt("Yeeehaaaaaaaaaa!");

        public void ShowProgressBar() {

            //yourInterface is IInterface of Max SDK ,You can take pointer on BeginEditParams from UtilityObj
            ProgressBarDelegate progressBarDelegate = new ProgressBarDelegate(ProgressBarFunc);
            IntPtr progressBarFunc = Marshal.GetFunctionPointerForDelegate(progressBarDelegate);
            MxGet.Interface.ProgressStart("Progress Started", false, progressBarFunc, IntPtr.Zero);
            //If false parametre is true ,cancel btn of progress bar will be show.
            MxGet.Interface.ProgressUpdate(0, false, "Progress Update");
            MxGet.Interface.ProgressEnd();
        }

        #endregion
        


    }
}
