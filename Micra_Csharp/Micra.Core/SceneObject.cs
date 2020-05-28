//
// Copyright 2012 Autodesk, Inc.  All rights reserved.
//
// Use of this software is subject to the terms of the Autodesk license
// agreement provided at the time of installation or download, or which
// otherwise accompanies this software in either electronic or hard copy form.  
//
using Autodesk.Max;
using System;
using System.Collections.Generic;
using System.Linq;

namespace Micra.Core {
    /// <summary>
    /// Represents an element of a scene. Wraps the BaseObject type in the 3ds Max SDK. 
    /// </summary>
    public class SceneElement : ReferenceTarget {
        public IBaseObject _BaseObject { get { return _Anim as IBaseObject; } }

        internal SceneElement(IBaseObject x) : base(x) {
            if ( parameterBlock == null ) {
                IIParamArray pa = _BaseObject.ParamBlock;
                if ( pa != null )
                    parameterBlock = CreateWrapper<ParameterBlock1>(pa.ParamBlock);
            }
        }

        public IEnumerable<Node> Nodes {
            get {
                return from x in Observers where x is Node select x as Node;
            }
        }

        public bool Instanced {
            get {
                return Nodes.Count() > 1;
            }
        }

        public string Name {
            get {
                return _BaseObject.ObjectName;
            }
        }
    }

    /// <summary>
    /// Represents an object that can flow through the geometry pipeline. Wraps the Object type 
    /// in the Max SDK. Associated with a Node. 
    /// </summary>
    public class SceneObject : SceneElement {
        internal SceneObject(IObject x) : base(x) { }

        /// <summary>
        /// Returns the corresponding wrapped object from the Autodesk.Max layer. 
        /// This is only used if the APIs of Autodesk.Max layer are required.
        /// </summary>
        public IObject _Object { get { return _Anim as IObject; } }

        Node node;

        /// <summary>
        /// When an object is created, it should be manually associated with a single node.
        /// This is only for convenience. An object is not guaranteed to have a node.
        /// </summary>
        public Node Node {
            get {
                return node;
            }
            set {
                node = value;
            }
        }

        public void AddModifier(Modifier m) {
            if ( Node != null )
                Node.AddModifier(m);
        }

        public SceneObject Base {
            get {
                SceneObject r = this;
                while ( r._Object is IIDerivedObject ) {
                    IIDerivedObject ido = r._Object as IIDerivedObject;
                    // Should never happen, but we have good reason to be paranoid. 
                    if ( ido.ObjRef == null )
                        return r;
                    r = Animatable.CreateWrapper<SceneObject>(ido.ObjRef);
                }
                return r;
            }
        }

        public Mesh Mesh {
            get { return GetMesh(Kernel.Now); }
        }

        public Mesh GetMesh(TimeValue t) {
            IClass_ID triClass = Kernel._Global.Class_ID.Create((uint)BuiltInClassIDA.TRIOBJ_CLASS_ID, 0);
            if ( _Object.CanConvertToType(ClassID.TriObject._IClass_ID) == 0 )
                return null;

            ITriObject tri = _Object.ConvertToType(t, triClass) as ITriObject;
            if ( tri == null )
                return null;

            Mesh r = new Mesh(tri.Mesh);

            //if (tri.Handle != _Object.Handle)
            if ( tri != _Object ) {
                RefResult rr = tri.MaybeAutoDelete();
                if ( rr == RefResult.Fail )
                    throw new Exception("Failed to autodelete the tri-object");
            }

            return r;
        }
    }
}