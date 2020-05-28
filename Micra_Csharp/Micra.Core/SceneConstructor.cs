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

namespace Micra.Core {
    /// <summary>
    /// Creates a scene in 3ds Max from serializable scene data. This is not 
    /// exposed as part of the API. Instead you would use Scene.CreateScene().
    /// </summary>
    internal class SceneConstructor
    {
        Scene scene;

        Dictionary<ulong, SerializableScene.Plugin> plugins = new Dictionary<ulong, SerializableScene.Plugin>();
        Dictionary<ulong, Animatable> anims = new Dictionary<ulong, Animatable>();

        public SceneConstructor(Scene s)
        {
            this.scene = s;
        }

        public void ConstructScene(SerializableScene ss)
        {
            foreach (var p in ss.plugins)
                plugins.Add(p.id, p);
            AddNodes(scene.RootNode, ss.root.nodes);
            SetParameters();
            SetReferences();
        }

        T CreatePlugin<T>(ulong id) where T : Animatable
        {
            if (anims.ContainsKey(id))
                return anims[id] as T;

            if (!plugins.ContainsKey(id))
                return null;

            var sp = plugins[id];
            Animatable a = PluginMgr.Create(sp.scid, sp.cid);
            anims.Add(id, a);

            return a as T;
        }

        public void SetParameters()
        {
            foreach (var keyValue in plugins)
            {
                if (keyValue.Value.paramblocks.Length > 0 && anims.ContainsKey(keyValue.Key))
                {
                    var se = anims[keyValue.Key] as SceneElement;
                    if (se != null)
                        // Note: we only support parameters from the first parameter block for now.
                        foreach (var p in keyValue.Value.paramblocks[0].parameters)
                            se[p.id] = p.value;
                }
            }
        }

        public void SetReferences()
        {
            // loop over the created animatables
            foreach (var keyValue in anims)
            {
                var rt = keyValue.Value as ReferenceTarget;
                
                // Find the scene plug-in (expected to happen, unless the code is broken)
                if (!plugins.ContainsKey(keyValue.Key))
                    throw new Exception("Internal error: missing plug-in data from scene");                
                var p = plugins[keyValue.Key];

                // iterate through the reference target list
                // values should be the same, but just in case
                int nTargets = Math.Min(p.targets.Length, rt.NumTargets);    
                for (int i = 0; i < nTargets; ++i)
                {
                    // Get the target ID
                    ulong id = p.targets[i].id;
                    if (id == 0)
                    {
                        // 0 means null
                        rt.SetTarget(i, null);
                    }
                    else
                    {
                        // Find if this refers to an object that we created when loading the scene.
                        // if so, we link to it.
                        if (anims.ContainsKey(id))
                        {
                            var target = anims[id] as ReferenceTarget;
                            rt.SetTarget(i, target);
                        }                            
                    }
                }
            }
        }

        public void AddNodes(Node node, IEnumerable<SerializableScene.Node> nodes)
        {
            foreach (var n in nodes)
            {
                // Create the associated plug-in (or look it up)
                var obj = CreatePlugin<SceneObject>(n.sceneobject.id);
                if (obj == null)
                    throw new Exception("Could not create scene object associated with node " + n.name);

                // Create the node with the object and name
                Node child = node.AddNewNode(obj, n.name);

                // Set the transform
                child.NodeTransform = n.transform;

                // Make sure that the node is listed in the created animss 
                anims.Add(n.id, child);

                // Add modifiers
                foreach (var m in n.modifiers)
                {
                    var mod = CreatePlugin<Modifier>(m.id);
                    if (mod != null)
                        child.AddModifier(mod);
                    else
                        throw new Exception("Could not create modifier");
                }

                // Add sub-nodes 
                AddNodes(child, n.nodes);
            }
        }
    }
}
