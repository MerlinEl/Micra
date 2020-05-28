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
using System.Runtime.Serialization;

namespace Micra.Core {
    /// <summary>
    /// This presents a snapshot representation of a scene that can be 
    /// easily serialized, or passed across process boundaries using 
    /// the Remoting interface. 
    /// </summary>
    [Serializable]
    public class SerializableScene
    {       
        /// <summary>
        /// Serializable representation of a reference to a target.
        /// </summary>
        [Serializable]
        public class Reference
        {
            public ulong id;

            public Reference()
            {
            }

            public Reference(ReferenceTarget rt)
            {
                if (rt == null || !rt.Valid)
                {
                    id = 0;
                }
                else
                {
                    this.id = (ulong)rt.AnimHandle;
                }
            }
        }

        /// <summary>
        /// Serializable representation of an animatable. In other words
        /// something that can be targeted.
        /// </summary>
        public class Target
        {
            public ulong id;

            public Target()
            {
                id = 0;
            }

            public Target(Animatable a)
            {
                id = (ulong)a.AnimHandle;
            }
        }

        /// <summary>
        /// Serializalbe represdentation of a plug-in.
        /// </summary>
        [Serializable]
        public class Plugin : Target
        {
            public string className;
            public ClassID cid;
            public SuperClassID scid;
            public Reference[] targets;
            public ParameterBlock[] paramblocks;

            public Plugin() 
            {
            }

            public Plugin(Animatable a)
                 : base(a)
            {
                className = a.ClassName;
                cid = a.ClassID;
                scid = a.SuperClassID;                
                ReferenceTarget rt = a as ReferenceTarget;
                var pbs = new List<ParameterBlock>();
                if (rt == null)
                {
                    targets = new Reference[0];
                }
                else
                {
                    targets = new Reference[rt.NumTargets];
                    for (int i = 0; i < rt.NumTargets; ++i)
                    {
                        var target = rt.GetTarget(i);
                        targets[i] = new Reference(target);

                        if (target is ParameterBlock1)
                        {
                            pbs.Add(new ParameterBlock(target as ParameterBlock1));
                        }
                        else if (target is ParameterBlock2)
                        {
                            pbs.Add(new ParameterBlock(target as ParameterBlock2));
                        }
                    }
                }
                paramblocks = pbs.ToArray();
            }
        }

        /// <summary>
        /// Serializable representation of a node.
        /// </summary>
        [Serializable]
        public class Node : Target
        {
            public string name;
            public Node[] nodes;
            public Reference sceneobject;
            public Reference[] modifiers;
            public Matrix3 transform;

            public Node() 
            {
            }

            public Node(Core.Node n) 
                : base(n)
            {
                name = n.Name;
                if (n.Object != null)
                    sceneobject = new Reference(n.Object.Base);
                else
                    sceneobject = new Reference();
                transform = n.NodeTransform;
                nodes = (from x in n.Nodes select new Node(x)).ToArray();
                modifiers = (from x in n.Modifiers select new Reference(x)).ToArray();
            }                

            public IEnumerable<Node> NodeTree
            {
                get
                {
                    if (nodes != null)
                        foreach (Node n in nodes)                            
                            foreach (Node m in n.NodeTree)
                                yield return n;
                    yield return this;
                }
            }
        }

        /// <summary>
        /// Serializable representation of a parameter.
        /// </summary>
        [Serializable]
        public class Parameter 
        {
            public string name;
            public System.Object value;
            public string type;
            public int id;

            public Parameter()
            {
            }

            public Parameter(IParameter p)
            {
                name = p.Name;
                value = p.Value;
                type = p.Type;
                id = p.Id;
            }
        }

        /// <summary>
        /// Serializable representation of a parameter block.
        /// </summary>
        [Serializable]
        public class ParameterBlock : Target
        {
            public Parameter[] parameters;

            public ParameterBlock()
            {
            }

            public ParameterBlock(ParameterBlock1 pb) : base(pb)
            {
                parameters = (from p in pb.Params select new Parameter(p)).ToArray();
            }

            public ParameterBlock(ParameterBlock2 pb) : base(pb)
            {
                parameters = (from p in pb.Params select new Parameter(p)).ToArray();
            }
        }

        #region fields 
        public Node root;
        public Plugin[] plugins;
        #endregion

        #region constructors 
        public SerializableScene()
        {
        }

        public SerializableScene(Core.Node x)
        {
            root = new Node(x);

            Dictionary<UIntPtr, Core.Animatable> lookup = new Dictionary<UIntPtr, Animatable>();

            var pluginList = new List<Plugin>();

            foreach (var rt in x.NodeReferenceTree)
            {
                // Make sure we don't repeat anything.
                if (!lookup.ContainsKey(rt.AnimHandle))
                {
                    if (rt is Core.Node || rt is ParameterBlock1 || rt is ParameterBlock2)
                    {
                        // do nothing these 
                    }
                    else
                    {
                        pluginList.Add(new Plugin(rt));
                    }

                   lookup.Add(rt.AnimHandle, rt);
                }
            }

            this.plugins = pluginList.ToArray();
        }
        #endregion
    }
}
