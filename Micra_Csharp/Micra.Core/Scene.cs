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
    /// Represent the 3ds Max scene graph, and provides access to other elements of the scene not 
    /// directly accessible from the scene graph. Provides access to scene related functionality 
    /// in the 3ds Max SDK but doesn't correspond to any single class. 
    /// </summary>
    public class Scene {
        internal ReferenceTarget sceneRefTarget;
        internal IIScene scene;
        internal Node sceneRootNode;

        internal Scene(IInterface14 x) {
            scene = x.Scene;
            sceneRootNode = Animatable.CreateWrapper<Node>(x.RootNode);
            sceneRefTarget = Animatable.CreateWrapper<ReferenceTarget>(x.ScenePointer);
        }

        public void FlagForegroundSelectedNodes(TimeValue t) { scene.FlagFGSelected(t.time); }
        public void FlagForegroundSelectedNodes() { FlagForegroundSelectedNodes(Kernel.Now); }
        public void FlagForegroundAnimatedNodes(TimeValue t) { scene.FlagFGAnimated(t.time); }
        public void FlagForegroundAnimatedNodes() { FlagForegroundAnimatedNodes(Kernel.Now); }

        public Node RootNode {
            get { return sceneRootNode; }
        }

        public IEnumerable<Node> NodeTree {
            get { return RootNode.NodeTree; }
        }

        public IEnumerable<Node> NodesBySuperClass(SuperClassID sid) {
            return from n in NodeTree where n.Object != null & n.SuperClassID == sid select n;
        }

        public IEnumerable<Node> AllNodes() {

            return from n in NodeTree where n.Object != null select n;
        }

        public IEnumerable<Node> SelectedNodes() { // OK

            return from n in NodeTree where n.Object != null & n._Node.Selected select n;
        }

        public IEnumerable<Node> GeometryNodes { get { return NodesBySuperClass(SuperClassID.GeometricObject); } }
        public IEnumerable<Node> LightNodes { get { return NodesBySuperClass(SuperClassID.Light); } }
        public IEnumerable<Node> CameraNodes { get { return NodesBySuperClass(SuperClassID.Camera); } }
        public IEnumerable<Node> HelperNodes { get { return NodesBySuperClass(SuperClassID.Helper); } }
        public IEnumerable<Node> ShapeNodes { get { return NodesBySuperClass(SuperClassID.Shape); } }
        public IEnumerable<Node> SystemNodes { get { return NodesBySuperClass(SuperClassID.GeometricObject); } }
        public IEnumerable<Node> SpaceWarpNodes { get { return NodesBySuperClass(SuperClassID.GeometricObject); } }

        public IEnumerable<SceneObject> Objects {
            get { return from n in NodeTree where n.Object != null select n.Object; }
        }

        public ReferenceTarget RootTarget {
            get { return sceneRefTarget; }
        }

        public IEnumerable<T> GetObjects<T>() where T : SceneObject {
            return from o in Objects where o is T select o as T;
        }

        /// <summary>
        /// Because of the nature of the reference hierarchy, it is very likely to receive duplicate
        /// </summary>
        private IEnumerable<ReferenceTarget> AllTargets {
            get {
                foreach ( var rt in RootTarget.TargetTree )
                    yield return rt;

                foreach ( var n in NodeTree ) {
                    yield return n;
                    foreach ( var rt in n.TargetTree )
                        yield return rt;
                }
            }
        }

        public void OnChanged(Action callback) {
            sceneRefTarget.AddListener(callback);
        }

        //! \name Scene Serialization Functions
        //@{
        /// <summary>
        /// Creates a scene from a SceneData instance.
        /// </summary>
        /// <param name="s"></param>
        public void CreateScene(SerializableScene s) {
            Kernel.Reset();
            var sc = new SceneConstructor(this);
            sc.ConstructScene(s);
        }

        /// <summary>
        /// Creates an object that represents scene data that can be serialized.
        /// </summary>
        public SerializableScene GetSerializableScene() {
            return sceneRootNode.GetSerializableScene();
        }
        //@}
    }
}
