using System;
using System.Collections.Generic;

namespace Micra.Core {
    public class Geo {

        private Node _Node;

        public Geo(Node node) => _Node = node;
        public dynamic geo { 
            
            get {
                if ( _Node.IsClassOf(ClassID.EditableMesh) ) return _Node.GetMesh();
                if ( _Node.IsClassOf(ClassID.EditablePoly) ) return _Node.GetPoly();
                throw new NotImplementedException("Invalid object type: " + geo.GetTYpe());
            } 
        }

        public int NumFaces => _Node.Object.NumFaces;

        public double GetFaceArea(int faceIndex) => geo.GetFaceArea(faceIndex);
        public List<int> GetFaceVerts(int faceIndex) => geo.GetFaceVerts(faceIndex);
        internal List<int> GetSelectedFaces() => _Node.Object.GetSelectedFaces();
    }
}