//
// Copyright 2012 Autodesk, Inc.  All rights reserved.
//
// Use of this software is subject to the terms of the Autodesk license
// agreement provided at the time of installation or download, or which
// otherwise accompanies this software in either electronic or hard copy form.  
//
using Autodesk.Max;
using System.Collections.Generic;
using System.Linq;

namespace Micra.Core {
    /// <summary>
    /// Provides global functionality related to plug-ins. 
    /// Wraps a DllDir class in the 3ds Max SDK. 
    /// </summary>
    public static class PluginMgr {
        public static IDllDir _dir { get { return Kernel._Interface.DllDir; } }

        public static IEnumerable<Dll> Dlls {
            get {
                for ( int i = 0; i < _dir.Count; ++i )
                    yield return new Dll(_dir[i]);
            }
        }

        public static IEnumerable<Plugin> Plugins {
            get {
                foreach ( var d in Dlls )
                    foreach ( var p in d.Plugins )
                        yield return p;
            }
        }

        public static Plugin GetPlugin(string name) {
            return Plugins.FirstOrDefault((Plugin p) => p.InternalName == name);
        }

        public static Animatable Create(string internalName) {
            var p = GetPlugin(internalName);
            return p != null ? p.Create() : null;
        }

        public static Animatable Create(SuperClassID scid, ClassID cid) {
            return Animatable.CreatePluginInstance<Animatable>(scid, cid);
        }
    }

    /// <summary>
    /// Contains information about a plug-in dll. 
    /// Wraps a DllDesc object in the 3ds Max SDK.
    /// </summary>
    public class Dll {
        public IDllDesc _dll;
        internal Dll(IDllDesc dll) { this._dll = dll; }

        public string Description { get { return _dll.Description; } }
        public IEnumerable<Plugin> Plugins {
            get {
                for ( int i = 0; i < _dll.NumberOfClasses; ++i )
                    if ( _dll[i] != null )
                        yield return new Plugin(_dll[i]);
            }
        }

#if MAX_2012
        public string Directory { get { return _dll.Directory; } }
        public string FileName { get { return _dll.Fname; } }
        public bool Loaded { get { return _dll.Loaded; } }
#else
        public string Directory { get { return _dll.DirectoryName; } }
        public string FileName { get { return _dll.FileName; } }
        public bool Loaded { get { return _dll.IsLoaded; } }
#endif
    }

    /// <summary>
    /// Contains information about a plug-in and provides 
    /// access to its constructor. Only supports "Animatable" 
    /// derived plug-ins. Wraps a ClassDesc instance in the 3ds Max SDK.
    /// </summary>
    public class Plugin {
        public IClassDesc _cd;
        internal Plugin(IClassDesc cd) { this._cd = cd; }
        public string ClassName { get { return _cd.ClassName; } }
        public string Category { get { return _cd.Category; } }
        public Animatable Create() { return Animatable.CreateWrapper<Animatable>(_cd.Create(false) as IAnimatable); }
        public string InternalName { get { return _cd.InternalName; } }
        public SuperClassID SuperClassID { get { return _cd.SuperClassID; } }
        public ClassID ClassID { get { return new ClassID(_cd.ClassID); } }
    }
}
