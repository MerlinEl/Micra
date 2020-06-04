//
// Copyright 2012 Autodesk, Inc.  All rights reserved.
//
// Use of this software is subject to the terms of the Autodesk license
// agreement provided at the time of installation or download, or which
// otherwise accompanies this software in either electronic or hard copy form.  
//
using Autodesk.Max;

namespace Micra.Core {
    /// <summary>
    /// Represents a geometric object in the scene.
    /// Wraps a GeomObject from the Max SDK.
    /// </summary>
    public class Geometry : SceneObject {
        internal Geometry(IGeomObject x) : base(x) { }

        /// <summary>
        /// Returns the corresponding wrapped object from the Autodesk.Max layer. 
        /// This is only used if the APIs of Autodesk.Max layer are required.
        /// </summary>
        public IGeomObject _IGeomObject { get { return _Anim as IGeomObject; } }
    }
}
