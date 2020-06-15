using System.Collections.Generic;

namespace _2KGames.Fusion.Core.Controls.Volume
{
	///Holds vertices, vertices are sorted all the time
	public class VertexContainer
	{
		//Invariant: vertices list is sorted
		private readonly List<Vertex> m_Vertices = new List<Vertex>();

		public IList<Vertex> Vertices
		{
			get { return m_Vertices; }
		}

		public bool AddVertex(Vertex vertex)
		{
			var index = m_Vertices.BinarySearch(vertex);
			if (index < 0)
			{
				index = ~index;
				m_Vertices.Insert(index, vertex);
				return true;
			}

			return false;
		}

		//Search for Vertex in Container, Logarithmic complexity
		public bool Contain(Vertex vertex)
		{
			var index = m_Vertices.BinarySearch(vertex);
			return index >= 0;
		}
	}
}
