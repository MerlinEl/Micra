// Thank you MaxSharp
// Copyright 2012 Autodesk, Inc.  All rights reserved.
//
// Use of this software is subject to the terms of the Autodesk license
// agreement provided at the time of installation or download, or which
// otherwise accompanies this software in either electronic or hard copy form.  
//
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
        public static IInterface14 _Interface;
        public static IGlobal _Global;
        internal static List<ReferenceListener> listeners = new List<ReferenceListener>();
        internal static Scene scene;
        #endregion 

        public static Dispatcher dispatcher;

        static Kernel() {
            // If this is ever NULL, it is probably because 3ds Max has not yet loaded 
            // Autodesk.Max.Wrappers.dll
            _Global = Autodesk.Max.GlobalInterface.Instance;
            _Interface = _Global.COREInterface14;
            scene = new Scene(_Interface);
            dispatcher = Dispatcher.CurrentDispatcher;
        }

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
        public static void RunMAXScriptFile(string filename) {
            RunMAXScriptFile(filename, false);
        }

        /// <summary>
        /// Runs a MAXScript file.
        /// </summary>
        /// <param name="filename"></param>
        /// <param name="quieterrors"></param>
        public static void RunMAXScriptFile(string filename, bool quieterrors) {
            string script = File.ReadAllText(filename);
            RunMAXScriptString(script, quieterrors);
        }

        /// <summary>
        /// Evaluates a MAXScript string
        /// </summary>
        /// <param name="text"></param>
        public static void RunMAXScriptString(string text) {
            RunMAXScriptString(text, false);
        }

        /// <summary>
        /// Evaluates a MAXScript string
        /// </summary>
        /// <param name="text"></param>
        /// <param name="quieterrors"></param>
        public static void RunMAXScriptString(string text, bool quieterrors) {
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

        /// <summary>
        /// Outputs a string the MAXScript listener
        /// </summary>
        /// <param name="s"></param>
        public static void Write(string s) {
            Kernel._Global.TheListener.EditStream.Wputs(s);
            Kernel._Global.TheListener.EditStream.Flush();
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
        #endregion
    }
}
