using _2KGames.Fusion.Bridge;
using System.Collections.Generic;

namespace _2KGames.Fusion.Core.Controls.Volume
{

	///Conainer which holds for each Vertex list of Faces which reference this Vertex
	///Is used for fast face searching.
	public class VertexDictionary
	{
		private readonly Dictionary<Vertex, FaceContainer> m_Faces = new Dictionary<Vertex, FaceContainer>();
		private readonly FaceContainer m_FaceContainer;

		public VertexDictionary(FaceContainer faceContainer)
		{
			m_FaceContainer = faceContainer;
		}

		public void Clear()
		{
			m_Faces.Clear();
		}
		///Clears dictionary and create a new one from scratch
		///Time Complexity = O(N*Log(N)*M), where N=number of Vertices, M=number of Faces
		public void Refresh()
		{
			Clear();

			foreach (var face in m_FaceContainer.Faces)
			{
				foreach (Vertex vertex in face.Vertices)
				{
					FaceContainer faces;
					if (m_Faces.TryGetValue(vertex, out faces))
					{
						faces.AddFace(face);
					}
					else
					{
						faces = new FaceContainer();
						faces.AddFace(face);
						m_Faces.Add(vertex, faces);
					}
				}
			}
		}

		///Returns all faces which are using given vertex
		public bool GetFaces(Vertex vertex, out FaceContainer faceContainer)
		{
			return m_Faces.TryGetValue(vertex, out faceContainer);
		}

		public VertexContainer GetVertices()
		{
			VertexContainer vertices = new VertexContainer();
			foreach (var item in m_Faces)
			{
				vertices.AddVertex(item.Key);
			}

			return vertices;
		}

		///Returns all faces which are using given edge
		public bool GetFacesWithVertices(VertexContainer vertices, out FaceContainer faceContainer)
		{
			faceContainer = null;
			//find faces which are used by both vertices (~intersection of both sets)

			if (vertices.Vertices.Count == 0)
			{
				Trace.InfoInternal("Cannot GetFacesWithVertices if input vertices are empty");
				return false;
			}

			if (!GetFaces(vertices.Vertices[0], out faceContainer))
			{
				return false;
			}

			for (int i = 1; i < vertices.Vertices.Count; i++)
			{
				if (faceContainer.Count == 0)
				{
					return false;
				}
				else
				{
					FaceContainer tmpContainer;
					if (GetFaces(vertices.Vertices[i], out tmpContainer))
					{
						faceContainer = faceContainer.Intersection(tmpContainer);
						if (faceContainer == null)
						{
							return false;
						}
					}
					else
					{
						return false;
					}
				}
			}

			return faceContainer.Count != 0;
		}
	}
}
