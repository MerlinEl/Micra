//
// Copyright 2012 Autodesk, Inc.  All rights reserved.
//
// Use of this software is subject to the terms of the Autodesk license
// agreement provided at the time of installation or download, or which
// otherwise accompanies this software in either electronic or hard copy form.  
//
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using Autodesk.Max;

namespace Micra.Core {
    /// <summary>
    /// Represents a camera in the scene.
    /// Wraps a CameraObject from the Max SDK.
    /// </summary>
    public class Camera : SceneObject
    {
        internal Camera(ICameraObject x) : base(x) { }

        /// <summary>
        /// Returns the corresponding wrapped object from the Autodesk.Max layer. 
        /// This is only used if the APIs of Autodesk.Max layer are required.
        /// </summary>
        public ICameraObject _Camera { get { return _Anim as ICameraObject; } }
    }
}
