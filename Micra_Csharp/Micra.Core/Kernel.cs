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
Draw on window https://getcoreinterface.typepad.com/blog/c/
Good SDK https://documentation.help/3DS-Max/idx_AT_working_with_meshes.htm
https://docs.microsoft.com/cs-cz/dotnet/csharp/language-reference/language-specification/documentation-comments
https://documentation.help/3DS-Max/idx_RM_interface_classes.htm
http://discourse.techart.online/t/from-maxscript-to-c-or-c/3111/12
https://area.autodesk.com/profile/SmsxxDGK/blog-posts/?p=2


*/
using Autodesk.Max;
using Autodesk.Max.Remoting;
using System;
using System.Collections.Generic;
using System.IO;
using System.Windows.Threading;

namespace Micra.Core {
    /// <summary>
    /// Provides access to global data structures and functionality of the 3ds Max SDK.
    /// </summary>
    public static class Kernel {
        #region fields
        //public static IGlobal _Global;
        private static IGlobal global;
        public static IInterface17 _Interface;
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
            //_Global = GlobalInterface.Instance;
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
  
        /// <summary>
        /// Gets the Global interface.
        /// </summary>
        public static IGlobal _Global { //test
            get {
                if ( global == null ) global = GlobalInterface.Instance; //note that global will be an instance of an abstract class.
#if DEBUG
                if ( global == null ) {
                    try {
                        IManager manager = Activator.GetObject(typeof(RManager)
                                                              , "tcp://localhost:9998/Manager") as IManager;
                        if ( manager != null ) global = manager.Global;
                    } catch ( System.Net.Sockets.SocketException ) {
                        //Remoting is disabled or unavailable for some other reason.
                    }
                }
#endif
                return global;
            }
        }

        public static IHold Undo => Kernel._Global.TheHold;

        public static IBitArray NewIBitarray() => Kernel._Global.BitArray.Create();
        public static IBitArray NewIBitarray(int size) => Kernel._Global.BitArray.Create(size);

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
        public static void RedrawViews() => RedrawViews(Now);


        /// <summary>
        /// Forces a complete redraw of all views.
        /// </summary>
        public static void CompleteRedraw() => _Interface.ForceCompleteRedraw(false);

        /// <summary>
        /// Gets the active viewport.
        /// </summary>
        public static IViewExp ActiveView => _Interface.ActiveViewExp;

        /// <summary>
        /// Performs a file reset.
        /// </summary>
        public static void ResetScene(bool noPrompt) { _Interface.FileReset(noPrompt); }

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
    }
}
