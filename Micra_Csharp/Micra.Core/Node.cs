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

namespace Micra.Core {
    /// <summary>
    /// Represents a node in the scene graph. 
    /// Wraps a INode class in the 3ds Max SDK.
    /// Nodes cannot be created unless they are associated with 
    /// an object. 
    /// </summary>
    public class Node : ReferenceTarget {
        /// <summary>
        /// Wraps functionality of a Node for getting and setting user data strings. 
        /// </summary>
        public class NodeUserData {
            internal IINode node;

            internal NodeUserData(IINode node) { this.node = node; }

            public string this[string key] {
                get {
                    if ( node.UserPropExists(key) ) {
                        string ret = "";
                        node.GetUserPropString(key, ref ret);
                        return ret;
                    } else {
                        return "";
                    }
                }
                set {
                    string tmp = value;
                    node.SetUserPropString(key, value);
                }
            }
        }

        /// <summary>
        /// Encapsulates node visibility functionality. 
        /// </summary>
        public class NodeVisibility {
            readonly IINode node;

            public NodeVisibility(IINode node) {
                this.node = node;
            }

            public bool Render {
                get {
                    return node.Renderable;
                }
                set {
                    node.Renderable = value;
                }
            }

            public bool Primary {
                get {
                    return node.PrimaryVisibility;
                }
                set {
                    node.PrimaryVisibility = value;
                }
            }

            public bool Secondary {
                get {
                    return node.SecondaryVisibility;
                }
                set {
                    node.SecondaryVisibility = value;
                }
            }
        }

        internal Node(IINode x) : base(x) { }

        /// <summary>
        /// This is a handle to the low-level node managed by Autodesk.Max
        /// </summary>
        public IINode _IINode { get { return _Anim as IINode; } }

        /// <summary>
        /// Creates a node attached to a particular scene object. 
        /// </summary>
        /// <param name="o"></param>
        /// <returns></returns>
        public static Node Create(SceneObject o) {
            return CreateWrapper<Node>(Kernel._Interface.CreateObjectNode(o._Object));
        }

        /// <summary>
        /// Creates a named node attached to a particular scene object. 
        /// </summary>
        /// <param name="o"></param>
        /// <param name="name"></param>
        /// <returns></returns>
        public static Node Create(SceneObject o, string name) {
            return CreateWrapper<Node>(Kernel._Interface.CreateObjectNode(o._Object, name));
        }

        public void FlagForeground(TimeValue t, bool notify) { _IINode.FlagForeground(t, notify); }
        public void FlagForeground(TimeValue t) { FlagForeground(t, false); }
        public void FlagForeground() { FlagForeground(Kernel.Now); }

        public ulong NodeHandle {
            get { return (ulong)_IINode.NodeLong; }
        }

        public String Name {
            get { return _IINode.Name; }
            set { _IINode.Name = value; }
        }

        public String UserPropertyBuffer {
            get { string tmp = ""; _IINode.GetUserPropBuffer(ref tmp); return tmp; }
            set { string tmp = value; _IINode.SetUserPropBuffer(tmp); }
        }

        public NodeUserData UserData {
            get { return new NodeUserData(_IINode); }
        }

        public bool Selected {
            get { return _IINode.Selected; }
            set { if ( value ) Kernel._Interface.SelectNode(_IINode, false); else Kernel._Interface.DeSelectNode(_IINode); }
        }

        public void SelectOnly() {
            Kernel._Interface.SelectNode(_IINode, true);
        }

        //! \name Parent and Child Node Relationships
        //@{
        #region parent / child node relationships
        public bool IsRoot {
            get { return _IINode.IsRootNode; }
        }

        public bool IsTopParent {
            get { return Parent.IsRoot; }
        }

        public Node TopParent {
            get { Node r = this; while ( r.Parent != null && !IsTopParent ) r = r.Parent; return r; }
        }

        public Node Parent {
            get { return CreateWrapper<Node>(_IINode.ParentNode); }
        }

        public IEnumerable<Node> Children {
            get {
                for ( int i = 0; i < _IINode.NumberOfChildren; ++i )
                    if ( _IINode.GetChildNode(i) != null )
                        yield return new Node(_IINode.GetChildNode(i));
            }
        }

        public Node GetChild(int i) {
            if ( _IINode.GetChildNode(i) != null )
                return new Node(_IINode.GetChildNode(i));
            return null;
        }

        public void Attach(Node n) {
            Attach(n, true);
        }

        public void Attach(Node n, bool keepTM) {
            _IINode.AttachChild(n._IINode, keepTM);
        }

        public void Detach() {
            Detach(Kernel.Now);
        }

        public void Detach(TimeValue t) {
            Detach(t, true);
        }

        public void Detach(TimeValue t, bool keepTM) {
            _IINode.Detach(t, keepTM);
        }

        public Node AddNewNode(SceneObject o, string name) {
            Node n = Create(o, name);
            Attach(n);
            return n;
        }

        public Node AddNewNode(SceneObject o) {
            Node n = new Node(Kernel._Interface.CreateObjectNode(o._Object));
            _IINode.AttachChild(n._IINode, true);
            return n;
        }

        public IEnumerable<Node> NodeTree {
            get {
                foreach ( Node x in Nodes ) {
                    foreach ( Node y in x.NodeTree )
                        yield return y;
                    yield return x;
                }
            }
        }

        public IEnumerable<ReferenceTarget> NodeReferenceTree {
            get {
                foreach ( Node n in NodeTree ) {
                    yield return n;
                    foreach ( ReferenceTarget t in n.TargetTree )
                        yield return t;
                }
            }
        }

        public IEnumerable<Node> Nodes {
            get {
                for ( int i = 0; i < _IINode.NumberOfChildren; ++i )
                    if ( _IINode.GetChildNode(i) != null )
                        yield return new Node(_IINode.GetChildNode(i));
            }
        }
        #endregion 
        //@}

        public void Delete() => Delete(Kernel.Now);

        public void Delete(TimeValue t) => Delete(t, true);

        public void Delete(TimeValue t, bool keepChildrenPositions) {
            _IINode.Delete(t, keepChildrenPositions);
        }

        public bool Visible {
            get { return !_IINode.IsHidden(0, false); }
            set { _IINode.Hide(!value); }
        }

        public bool Frozen {
            get { return _IINode.IsFrozen; }
            set { _IINode.IsFrozen = value; }
        }

        public string ClassOf() => ClassID.GetClassName(Object.ClassID);
        public string SuperClassOf() => SuperClassID.GetSuperClassName(Object.SuperClassID);

        public bool IsClassOf(ClassID id) => Object.ClassID.a == id.a && Object.ClassID.b == id.b;

        public bool IsSuperClassOf(SuperClassID id) => Object.SuperClassID == id;


        //Todo >
        //-baseObject == allow modifiers
        //-modPolyOrMesh == add posibility operate with editable_poy and editable_mesh modifiers
        public bool IsEditable(bool baseObject = false, bool modPolyOrMesh = false) {

            //Kernel.WriteLine("is mesh:{0} is poly{1}", IsClassOf(ClassID.EditableMesh), IsClassOf(ClassID.EditablePoly));
            return IsClassOf(ClassID.EditableMesh) || IsClassOf(ClassID.EditablePoly);
        }

        public void Move(Point3 pt) => Move(pt, Kernel.Now);

        public void Move(Point3 pt, TimeValue t) {
            _IINode.Move(t, Matrix3.Identity.Translate(pt)._IMatrix3, pt._IPoint3, false, true, (int)PivotMode.None, false);
        }

        public SceneObject Object {
            get {
                return CreateWrapper<SceneObject>(_IINode.ObjectRef);
            }
        }

        public IObject GetObjectRef() { //test only

            /*IINode iinode = node._IINode;
            IObjectState ios = iinode.ObjectRef.Eval(Kernel.Now);
            IObject io = ios.Obj;*/
            return _IINode.ObjectRef;
        }

        //! \name Modifier Functions
        //@{
        #region modifier functions
        public void AddModifier(Modifier m) {
            Kernel._Interface.AddModifier(_IINode, m._Modifier, 0);
        }

        public void DeleteModifier(Modifier m) {
            Kernel._Interface.DeleteModifier(_IINode, m._Modifier);
        }

        public IEnumerable<Modifier> Modifiers {
            get {
                IIDerivedObject ido = _IINode.ObjectRef as IIDerivedObject;
                if ( ido == null )
                    yield break;

                for ( int i = 0; i < ido.NumModifiers; ++i )
                    yield return CreateWrapper<Modifier>(ido.GetModifier(i));
            }
        }
        #endregion functions
        //@}

        public bool BoxMode {
            get {
                return _IINode.BoxMode;
            }
            set {
                _IINode.BoxMode = value;
            }
        }

        public bool AllEdges {
            get {
                return _IINode.AllEdges;
            }
            set {
                _IINode.AllEdges = value;
            }
        }

        public NodeVisibility Visibility {
            get {
                return new NodeVisibility(_IINode);
            }
        }
        /*public SceneObject GetSceneObject() => GetSceneObject(Kernel.Now, true);
        public SceneObject GetSceneObject(TimeValue t, bool evalHidden) {

            // Retrieve the TriObject from the node
            IObjectState state = _Node.EvalWorldState(t, evalHidden);
            //Kernel.WriteLine("GetMesh > node:{0} state:{1}", Name, state);
            if ( state == null ) return null;

            IObject obj = state.Obj;
            if ( obj == null ) return null;

            return new SceneObject(obj);
        }*/

        public Mesh GetMesh() {
            return GetMesh(Kernel.Now);
        }

        public Mesh GetMesh(TimeValue t) {
            return GetMesh(t, true);
        }

        public Mesh GetMesh(TimeValue t, bool evalHidden) {

            /*SceneObject o = GetSceneObject(t, evalHidden);
            if ( o == null ) return null;
            return o.GetMesh(t);*/
            return Object.GetMesh(t);
        }

        public bool IsBone {
            get { return _IINode.BoneNodeOnOff; }
        }

        public Color Wirecolor {
            get { return new Color(_IINode.WireColor); }
            set { _IINode.WireColor = value.SystemColor; }
        }

        public Node CreateInstance() {
            return CreateWrapper<Node>(Kernel._Interface.CreateObjectNode(Object._Object));
        }

        //! \name Transform Functions 
        //@{
        #region transform functions
        public Matrix3 NodeTransform {
            get {
                return GetNodeTransform(Kernel.Now);
            }
            set {
                SetNodeTransform(value, Kernel.Now);
            }
        }

        public Matrix3 ObjectTransform {
            get {
                return GetObjectTransform(Kernel.Now);
            }
        }

        public Matrix3 GetNodeTransform(TimeValue t) {
            Interval validity = new Interval();
            return GetNodeTransform(t, out validity);
        }

        public void SetNodeTransform(Matrix3 m, TimeValue t) {
            _IINode.SetNodeTM(t, m._IMatrix3);
        }

        public Matrix3 GetNodeTransform(TimeValue t, out Interval validity) {
            IInterval v = Kernel._Global.Interval.Create();
            Matrix3 r = new Matrix3(_IINode.GetNodeTM(t, v));
            validity = new Interval(v);
            return r;
        }

        public Matrix3 GetObjectTransform(TimeValue t) {
            Interval validity = new Interval();
            return GetObjectTransform(t, out validity);
        }

        public Matrix3 GetObjectTransform(TimeValue t, out Interval validity) {
            IInterval v = Kernel._Global.Interval.Create();
            Matrix3 r = new Matrix3(_IINode.GetObjectTM(t, v));
            validity = new Interval(v);
            return r;
        }
        #endregion
        //@}

        //! \name Material Functions
        //@{
        /* BUG in EPHERE wrapper!
        public IEnumerable<Material> ViewportMaterials {
            get {
                for (int i = 0; i < _Node.NumMtls; ++i)
                    yield return CreateWrapper<Material>(_Node.Mtls[i]);
            }
         */
        public Material Material {
            get { return CreateWrapper<Material>(_IINode.Mtl); }
            set { _IINode.Mtl = value._Mtl; }
        }
        //@}

        //! \name Serialization Functions
        //@{
        public SerializableModel GetSerializableModel() {
            return new SerializableModel(this);
        }

        public SerializableScene GetSerializableScene() {
            return new SerializableScene(this);
        }
        //@}
    }
}
