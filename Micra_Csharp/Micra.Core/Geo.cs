using Micra.Core.Enums;
using System;
using System.Collections.Generic;
using static Micra.Core.Mesh;

namespace Micra.Core {
    public class Geo {

        private Node _Node;

        public Geo(Node node) {
            Throw.IfNull(node, "Node");
            _Node = node;
        }
        /// <summary> Created GEO Interfece depends on object type (Mesh, Poly, Epoly, Emesh)</summary>
        private dynamic geo {
            //TODO add editable_poly and editable_mesh modifier interfaces
            get {
                if ( _Node.IsClassOf(ClassID.EditableMesh) ) return _Node.GetMesh();
                if ( _Node.IsClassOf(ClassID.EditablePoly) ) return _Node.GetPoly();
                //if (_Node.IsClassOf(ClassID.ModMesh) ) return .... break;
                //if (_Node.IsClassOf(ClassID.ModPoly) ) return .... break;
                throw new NotImplementedException("Invalid object type: " + geo.GetTYpe());
            }
        }
        public void Update(bool redraw) { //like (update $) in max

            _Node.InvalidateObjCache();
            //force refresh command panel (if not, when deselect all sub elements, one will still selected)
            Kernel._Interface.SetSubObjectLevel(Kernel._Interface.SubObjectLevel, true);
            if ( redraw ) Kernel.RedrawViews();
        }

        #region Get Elements

        public int NumFaces => geo.NumFaces;
        public int NumEdges => geo.NumEdges;
        public int NumVerts => geo.NumVerts;

        public List<int> AllFaces => geo.AllFaces;
        public List<int> AllEdges => geo.AllEdges;
        public List<int> AllVerts => geo.AllVerts;

        #endregion

        #region Math

        public double GetArea() => geo.GetArea();
        public double GetFaceArea(int faceIndex) => geo.GetFaceArea(faceIndex);
        public double GetEdgeLength(int edgeIndex) => geo.GetEdgeLength(edgeIndex);

        #endregion

        public Edge GetEdge(int edgeIndex) => geo.GetEdge(edgeIndex); //TODO remove from here and make it private in Mesh


        #region Conversions

        public List<int> GetFaceVerts(int faceIndex) => geo.GetFaceVerts(faceIndex);

        #endregion

        #region Get Selection

        public List<int> GetSelectedFaces() => geo.GetSelectedFaces();
        public List<int> GetSelectedEdges() => geo.GetSelectedEdges();
        public List<int> GetSelectedVerts() => geo.GetSelectedVerts();

        #endregion

        #region Set Selection
        /// <summary> Clear selected elements in subobject level
        ///     <example> 
        ///         <code>
		///             example: 
        ///             <br>geo.ClearSelection("Faces")</br>
        ///             <br>geo.ClearSelection("Edges")</br>
        ///             <br>geo.ClearSelection("Verts")</br>
		///         </code>
		///     </example>
        ///     <para>param: <paramref name="elementType"/> ["Faces", "Edges", "Verts"]</para>
        /// </summary>
        public void ClearSelection(string elementType) => ClearSelection(elementType, true);
        public void ClearSelection(string elementType, bool redraw) {
            geo.ClearSelection(elementType);
            Update(redraw);
        }

        public void SetSelectedFaces(List<int> faceIndexes) => SetSelectedFaces(faceIndexes, false, true);
        public void SetSelectedFaces(List<int> faceIndexes, bool append) => SetSelectedFaces(faceIndexes, append, true);
        public void SetSelectedFaces(List<int> faceIndexes, bool append, bool redraw) {

            if ( !append ) { ClearSelection("Faces"); } else { faceIndexes.AddRange(GetSelectedFaces()); }
            geo.SetSelectedFaces(faceIndexes);
            Update(redraw);
        }
        public void SetSelectedEdges(List<int> edgeIndexes) => SetSelectedEdges(edgeIndexes, false, true);
        public void SetSelectedEdges(List<int> edgeIndexes, bool append) => SetSelectedEdges(edgeIndexes, append, true);
        public void SetSelectedEdges(List<int> edgeIndexes, bool append, bool redraw) {

            if ( !append ) { ClearSelection("Edges"); } else { edgeIndexes.AddRange(GetSelectedFaces()); }
            geo.SetSelectedEdges(edgeIndexes);
            Update(redraw);
        }
        public void SetSelectedVerts(List<int> vertIndexes) => SetSelectedVerts(vertIndexes, false, true);
        public void SetSelectedVerts(List<int> vertIndexes, bool append) => SetSelectedVerts(vertIndexes, append, true);
        public void SetSelectedVerts(List<int> vertIndexes, bool append, bool redraw) {

            if ( !append ) { ClearSelection("Edges"); } else { vertIndexes.AddRange(GetSelectedFaces()); }
            geo.SetSelectedVerts(vertIndexes);
            Update(redraw);
        }

        #endregion

        public void UnhideFaces() => UnhideFaces(true);
        public void UnhideFaces(bool redraw) {

            geo.UnhideFaces();
            Update(redraw);
            //_IGeomObject.InvalidateChannels((uint)EnumChannels.GEOM_CHANNEL);
            //Kernel.RedrawViews();
        }

        public void UnhideEdges() => UnhideEdges(true);
        public void UnhideEdges(bool redraw) {
            throw new NotImplementedException();
        }

        public void UnhideVerts() => UnhideVerts(true);
        public void UnhideVerts(bool redraw) {
            throw new NotImplementedException();
        }

        public void HideFaces(bool selected) => HideFaces(selected, true);
        public void HideFaces(bool selected, bool redraw) {

            geo.HideFaces(selected);
            Update(redraw);
            if ( selected ) _Node.Object._IGeomObject.ClearSelection(Kernel._Interface.SubObjectLevel);
        }
        public void HideEdges(bool selected) => HideEdges(selected, true);
        public void HideEdges(bool selected, bool redraw) {
            throw new NotImplementedException();
        }
        public void HideVerts(bool selected) => HideVerts(selected, true);
        public void HideVerts(bool selected, bool redraw) {
            throw new NotImplementedException();
        }
    }
}

//_IGeomObject.InvalidateChannels((uint)EnumChannels.GEOM_CHANNEL);
//_Node._IINode.ObjectRef.InvalidateChannels((uint)EnumChannels.SELECT_CHANNEL);
//Kernel._Global.InvalidateNodeRect(_Node._IINode, Kernel.Now);

/*_Node.Object._IGeomObject.InvalidateChannels(
    (uint)EnumChannels.SELECT_CHANNEL //| (uint)EnumChannels.GEOM_CHANNEL
);*/


/*
                switch ( slev ) { //next operation is depend on subobject level

                    case 2: GeoOps.SelectSimillarEdges(node, areaToloerance); break;
                    case 3:
                    if ( node.IsClassOf(ClassID.EditableMesh) ) {

                        GeoOps.SelectSimillarFaces(node, byArea, byVcount,
                            areaToloerance, (int)SpnSimillarVertsTolerance.Value);

                    } else if ( node.IsClassOf(ClassID.EditablePoly) ) {

                        GeoOps.SelectSimillarEdgeLoops(node, areaToloerance);
                    }
                    break;
                    case 4:
                    GeoOps.SelectSimillarFaces(node, byArea, byVcount,
                        areaToloerance, (int)SpnSimillarVertsTolerance.Value); break;
                    case 5:
                    GeoOps.SelectSimillarElements(node, byArea, byVcount,
                        areaToloerance, (int)SpnSimillarVertsTolerance.Value); break;
                }
*/
