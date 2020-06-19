//
// Copyright 2012 Autodesk, Inc.  All rights reserved.
//
// Use of this software is subject to the terms of the Autodesk license
// agreement provided at the time of installation or download, or which
// otherwise accompanies this software in either electronic or hard copy form.  
//

using Autodesk.Max;
using System;

namespace Micra.Core.Prim {
    /// <summary>
    /// The base class for predefined plug-in factories.
    /// </summary>
    public class PrimitiveFactory {
        protected SuperClassID scid;
        protected ClassID cid;
        public SuperClassID SuperClassID { get { return scid; } }
        public ClassID ClassID { get { return cid; } }
    }

    /// <summary>
    /// Base class for predefined plug-in factories. Introduces a Create function for creating the primitive in the scene 
    /// with a new node. 
    /// </summary>
    /// <typeparam name="T"></typeparam>
    public abstract class PrimitiveFactory<T> : PrimitiveFactory {
        internal PrimitiveFactory(SClass_ID scid, BuiltInClassIDA cidA, BuiltInClassIDB cidB) { this.scid = scid; cid = new ClassID((uint)cidA, (uint)cidB); }
        internal PrimitiveFactory(SClass_ID scid, BuiltInClassIDA cidA) { this.scid = scid; cid = new ClassID((uint)cidA, 0); }

        /// <summary>
        /// Creates a primitive with a new node.
        /// </summary>
        /// <returns></returns>
        public abstract T Create();
    }

    /// <summary>
    /// Base class for predefined sceene object factories. 
    /// </summary>
    public class PrimObjectFactory : PrimitiveFactory<SceneObject> {
        public PrimObjectFactory(SClass_ID scid, BuiltInClassIDA cidA, BuiltInClassIDB cidB) : base(scid, cidA, cidB) { }
        public PrimObjectFactory(SClass_ID scid, BuiltInClassIDA cidA) : base(scid, cidA) { }

        public override SceneObject Create() {
            SceneObject o = Animatable.CreatePluginInstance<SceneObject>(scid, cid);
            Node n = Node.Create(o); //create new Node from SceneObject
            o._Node = n ?? throw new Exception("Failed to create object node"); //put Node Reference in to SceneObject
            Kernel.RedrawViews();
            return o; //return SceneObject with embeded _Node reference
        }
    }
}
