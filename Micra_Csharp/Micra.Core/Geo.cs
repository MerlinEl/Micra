using System;
using System.Collections.Generic;

namespace Micra.Core {
    public class Geo {

        private Node _Node;

        public Geo(Node node) => _Node = node;
        private dynamic geo { 
            
            get {
                if ( _Node.IsClassOf(ClassID.EditableMesh) ) return _Node.GetMesh();
                if ( _Node.IsClassOf(ClassID.EditablePoly) ) return _Node.GetPoly();
                throw new NotImplementedException("Invalid object type: " + geo.GetTYpe());
            } 
        }

        public int NumFaces => _Node.Object.NumFaces;

        public double GetFaceArea(int faceIndex) => geo.GetFaceArea(faceIndex);
        public double GetEdgeLength(int edgeIndex) => geo.Object.GetEdgeLength(edgeIndex);
        public List<int> GetFaceVerts(int faceIndex) => geo.GetFaceVerts(faceIndex);
        internal List<int> GetSelectedFaces() => _Node.Object.GetSelectedFaces();
        internal List<int> GetSelectedEdges() => _Node.Object.GetSelectedEdges();
        internal List<int> GetSelectedVerts() => _Node.Object.GetSelectedVerts();
    }
}