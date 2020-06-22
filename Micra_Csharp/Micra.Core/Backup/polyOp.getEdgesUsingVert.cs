IPolyObject polyObj = (IPolyObject)m_Node.EvalWorldState(0, true).Obj.ConvertToType(0, m_Global.PolyObjectClassID);
IMNMesh mm = polyObj.Mm;

mm.FillInVertEdgesFaces();

for (int j = 0; j < mesh.NumVerts; j++)
{
         int edgeIndex = mm.FindEdgeFromVertToVert(m_SelectedVertexIndex, j);
         if (edgeIndex != -1)
         {
                edgeList.Add(edgeIndex);
                vertexIndexList.Add(j);
         }
}