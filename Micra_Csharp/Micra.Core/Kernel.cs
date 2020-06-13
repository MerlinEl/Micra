// Thank you MaxSharp
// Copyright 2012 Autodesk, Inc.  All rights reserved.
// Mod by MerlinEl 2020
//
// Use of this software is subject to the terms of the Autodesk license
// agreement provided at the time of installation or download, or which
// otherwise accompanies this software in either electronic or hard copy form.  
//
/*
 * Autodesk.Max.dll
 * 
The 3ds Max .NET SDK consists of the following .NET assemblies (DLLs). They can be found in the root folder 3ds Max application installation.

Autodesk.Max.dll - Contains wrappers that expose most of the API elements from the 3ds Max C++ SDK to .NET constructs. Currently it is not recommended to derive from the Autodesk.Max.Plugins classes.
AssemblyLoader.dll - Contains the Loader class.
CSharpUtilities.dll - Various utility classes for .NET programming.
ExplorerFramework.dll - Abstract explorer framework classes upon which the Scene Explorer is built. It can be used for creating a new node traversal for arbitrary scene explorers.
ManagedServices.dll - Exposes some convenient 3ds Max SDK functionality to .NET.
MaxCustomControls.dll - Various .NET utilities and UI components.
SceneExplorer.dll - Specification of the ExplorerFramework components for the SceneExplorer with bindings to 3ds Max data.
UiViewModels.dll - Contains classes for defining user actions and customizing the user interface.

Resources
https://docs.microsoft.com/cs-cz/dotnet/csharp/language-reference/language-specification/documentation-comments
https://documentation.help/3DS-Max/idx_RM_interface_classes.htm
http://discourse.techart.online/t/from-maxscript-to-c-or-c/3111/12
https://area.autodesk.com/profile/SmsxxDGK/blog-posts/?p=2


*/
using Autodesk.Max;
using System;
using System.Collections.Generic;
using System.IO;
using System.Runtime.InteropServices;
using System.Windows.Threading;

namespace Micra.Core {
    /// <summary>
    /// Provides access to global data structures and functionality of the 3ds Max SDK.
    /// </summary>
    public static class Kernel {
        #region fields
        private delegate void TimerProc(IntPtr hWnd, uint nMsg, int nIDEvent, int dwTime);
        public static IGlobal _Global;
        public static IInterface14 _Interface;
        public static IIInstanceMgr _InstanceMgr;
        public static IIFPLayerManager _IIFPLayerManager; //not used not tested
        public static IInterface_ID _NodeLayerProperties; //not used not tested
        public static IInterface_ID _EditablePoly; //not used not tested
        public static IMeshSelection _IMeshSelection; //not used not tested 
        internal static List<ReferenceListener> listeners = new List<ReferenceListener>();
        internal static Scene scene;
        #endregion 

        public static Dispatcher dispatcher;

        static Kernel() {
            // If this is ever NULL, it is probably because 3ds Max has not yet loaded 
            // Autodesk.Max.Wrappers.dll
            _Global = GlobalInterface.Instance;
            _Interface = _Global.COREInterface17;
            _InstanceMgr = _Global.IInstanceMgr.InstanceMgr;
            scene = new Scene(_Interface);
            dispatcher = Dispatcher.CurrentDispatcher;



            //TODO test and move it in right place
            //not used not tested
            IInterface_ID iMeshSelectionID = _Global.Interface_ID.Create( //not used not tested
                (uint)BuiltInClassIDA.MESHSELECT_CLASS_ID, 
                0
            );
            IMeshSelection _IMeshSelection = (IMeshSelection)_Global.GetCOREInterface(iMeshSelectionID); //not used not tested
            //not used not tested
            IInterface_ID iIFPLayerManagerID = _Global.Interface_ID.Create( //not used not tested
                (uint)BuiltInInterfaceIDA.LAYERMANAGER_INTERFACE, 
                (uint)BuiltInInterfaceIDB.LAYERMANAGER_INTERFACE
            );
            _IIFPLayerManager = (IIFPLayerManager)_Global.GetCOREInterface(iIFPLayerManagerID); //not used not tested
            _NodeLayerProperties = _Global.Interface_ID.Create(0x44e025f8, 0x6b071e44); //not used not tested
            _EditablePoly = _Global.Interface_ID.Create(0x092779, 0x634020); //not used not tested
        }

        public static IHold Undo => Kernel._Global.TheHold;

        public static IITimeSlider _TimeSlider {
            get {
                return _Global.GetCOREInterface(_Global.Interface_ID.Create(0x829e89e5, 0x878ef6e5)) as IITimeSlider;
            }
        }

        public static IIStatusPanel _StatusPanel {
            get {
                return _Global.GetCOREInterface(_Global.Interface_ID.Create(0x94357f0, 0x623e71c2)) as IIStatusPanel;
            }
        }

        /// <summary>
        /// Runs a MAXScript file.
        /// </summary>
        /// <param name="filename"></param>
        public static void ExecuteMaxScriptFile(string filename) {
            ExecuteMaxScriptFile(filename, false);
        }

        /// <summary>
        /// Runs a MAXScript file.
        /// </summary>
        /// <param name="filename"></param>
        /// <param name="quieterrors"></param>
        public static void ExecuteMaxScriptFile(string filename, bool quieterrors) {
            string script = File.ReadAllText(filename);
            ExecuteMaxScriptScript(script, quieterrors);
        }

        /// <summary>
        /// Evaluates a MAXScript string
        /// </summary>
        /// <param name="text"></param>
        public static void ExecuteMaxScriptScript(string text) {
            ExecuteMaxScriptScript(text, false);
        }

        /// <summary>
        /// Evaluates a MAXScript string
        /// </summary>
        /// <param name="text"></param>
        /// <param name="quieterrors"></param>
        public static void ExecuteMaxScriptScript(string text, bool quieterrors) {
            Kernel._Global.ExecuteMAXScriptScript(text, quieterrors, null);
        }

        /// <summary>
        /// Returns a scene object. 
        /// </summary>
        public static Scene Scene { get { return scene; } }

        /// <summary>
        /// Returns the current animation time.
        /// </summary>
        public static TimeValue Now { get { return _Interface.Time; } }

        /// <summary>
        /// 
        /// </summary>
        public static IEnumerable<Animatable> Animatables {
            get {
                EnumAnimList eal = new EnumAnimList();
                _Global.Animatable.EnumerateAllAnimatables(eal);
                return eal.animatables;
            }
        }

        /// <summary>
        /// Indicates whether the kernel is initialized. Primarily a debugging tool. 
        /// </summary>
        public static bool Initialized { get { return _Interface != null; } }

        /// <summary>
        /// Forces all views to redraw at time T. 
        /// </summary>
        public static void RedrawViews(TimeValue t) {
            _Interface.RedrawViews(t, RedrawFlags.Normal, null);
        }

        /// <summary>
        /// Forces all views to redraw.
        /// </summary>
        public static void RedrawViews() {
            RedrawViews(Now);
        }

        /// <summary>
        /// Starts a timer that is called on a regular interval.
        /// </summary>
        /// <param name="msecInterval"></param>
        /// <param name="callback"></param>
        /// <returns>An integer ID of the timer.</returns>
        public static int StartTimer(int msecInterval, Action<int> callback) {
            TimerProc proc = (IntPtr hWnd, uint nMsg, int nIDEvent, int dwTime) => callback(dwTime);
            return SetTimer(IntPtr.Zero, 0, msecInterval, proc);
        }

        /// <summary>
        /// Cancels the identified timer.
        /// </summary>
        /// <param name="nTimer"></param>
        public static void CancelTimer(int nTimer) {
            KillTimer(IntPtr.Zero, nTimer);
        }

        /// <summary>
        /// Add a string as a new line to the prompt. This is a convenient way to write messages back to the user. 
        /// </summary>
        /// <param name="s"></param>
        public static void PushPrompt(string s) {
            Kernel._Interface.PushPrompt(s);
        }

        /// <summary>
        /// Outputs a string the MAXScript listener with a newline appended
        /// </summary>
        /// <param name="s"></param>
        public static void WriteLine(string s) {
            Write(s + "\n");
        }

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

        public static void WriteClear(bool macroRec) {
            // clears the listener
            SendMessage(_Global.TheListener.EditBox, 2004, (IntPtr)0, (IntPtr)0);
            if ( !macroRec ) return;
            // clears the macro recorder
            SendMessage(_Global.TheListener.MacrorecBox, 2004, (IntPtr)0, (IntPtr)0);
            //UIAccessor.SetWindowText(_Global.TheListener.MacrorecBox)[2][1]("");
        }

        /// <summary>
        /// Performs a file reset.
        /// </summary>
        public static void Reset() { _Interface.FileReset(true); }

        /// <summary>
        /// Time slider visibility.
        /// </summary>
        public static bool TimeSliderVisibility {
            get {
                return _TimeSlider.IsVisible_;
            }
            set {
                _TimeSlider.SetVisible(value, true);
            }
        }


        /// <summary>
        /// Status panel visibility.
        /// </summary>
        public static bool StatusPanelVisibility {
            get {
                return _StatusPanel.IsVisible_;
            }
            set {
                _StatusPanel.SetVisible(value);
            }
        }

        /// <summary>
        /// Used to synchronously execute an action on the main thread. 
        /// </summary>
        /// <param name="a"></param>
        public static void Invoke(Action a) {
            dispatcher.Invoke(a);
        }

        /// <summary>
        /// Used to asynchronously execute an action on the main thread. 
        /// </summary>
        /// <param name="a"></param>
        public static DispatcherOperation InvokeAsync(Action a) {
            return dispatcher.BeginInvoke(a);
        }

        #region windows DLL imported functions
        [DllImport("user32")]
        private static extern int SetTimer(IntPtr hwnd, int nIDEvent, int uElapse, TimerProc CB);
        [DllImport("user32")]
        private static extern int KillTimer(IntPtr hwnd, int nIDEvent);
        [DllImport("user32.dll")]
        public static extern int SendMessage(IntPtr hWnd, int wMsg, IntPtr wParam, IntPtr lParam);
        [DllImport("user32.dll")]
        public static extern IntPtr FindWindow(string lpClassName, String lpWindowName); //not used not tested
        #endregion
    }
    public static class ListenerExtensions { //test now
        public static void WriteToListener<T>(this IList<T> collection) {

            WriteToListener<T>(collection, "\t");
        }

        public static void WriteToListener<T>(this IList<T> collection, string delimiter) {

            int count = collection.Count;
            for ( int i = 0; i < count; ++i ) {
                Kernel.Write("{0}{1}", collection[i].ToString(), delimiter);
            }
            Kernel.WriteLine("");
        }
    }
}
