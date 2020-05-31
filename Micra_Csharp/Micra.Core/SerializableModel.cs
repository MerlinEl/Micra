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
    /// Represents a simplfified representation of a model that can be easily serialzied.
    /// A model is created from a node and all of its children. 
    /// </summary>
    [Serializable]
    public class SerializableModel 
    {
        public Mesh mesh;
        public string name;
        public Matrix3 transform;
        public List<SerializableModel> models = new List<SerializableModel>();
        public List<Mesh> submeshes = new List<Mesh>();
        public bool bone;
        public Color color;

        public SerializableModel()
        {
        }

        public SerializableModel(Node node)
            : this(node, Kernel.Now)
        {
        }

        public SerializableModel(Node node, TimeValue t)
            : this(node, t, true)
        {
        }

        public SerializableModel(Node node, TimeValue t, bool bMeshData)
            : this(node, t, bMeshData, false)
        { }

        public SerializableModel(Node node, TimeValue t, bool bMeshData, bool bReferencedData)
        {
            color = node.Wirecolor;
            bone = node.IsBone;
            if (bMeshData) // && node.Visibility.Render)
                mesh = node.GetMesh(t);            
            transform = node.GetNodeTransform(t);
            name = node.Name;
            foreach (Node child in node.Nodes)
                models.Add(new SerializableModel(child, t, bMeshData));

            if (bReferencedData)
                foreach (SceneObject obj in node.TargetTree.FilterType<SceneObject>())
                    submeshes.Add(obj.GetMesh(t));
        }
    }
}
