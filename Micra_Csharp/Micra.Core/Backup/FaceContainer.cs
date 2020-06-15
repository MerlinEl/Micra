using System;
using System.Collections.Generic;
using System.Linq;
using _2KGames.Fusion.Bridge;

namespace _2KGames.Fusion.Core.Controls.Volume
{
	///Holds faces, faces are sorted all the time
	public class FaceContainer
	{
		//Invariant: Face list is sorted
		private readonly List<Face> m_Faces = new List<Face>();

		public IList<Face> Faces
		{
			get { return m_Faces; }
		}

		public int Count
		{
			get { return m_Faces.Count; }
		}

		public void AddFaces(IEnumerable<Face> faces)
		{
			foreach (Face face in faces)
			{
				AddFace(face);
			}
		}

		public bool AddFace(Face face)
		{
			var index = m_Faces.BinarySearch(face);
			if (index < 0)
			{
				index = ~index;
				m_Faces.Insert(index, face);
				return true;
			}

			return false;
		}

		public bool RemoveFace(Face face)
		{
			var index = m_Faces.BinarySearch(face);
			if (index >= 0)
			{
				m_Faces.RemoveAt(index);
			}
			return index >= 0;
		}

		//Search for Face in Container, Logarithmic complexity
		public bool Contain(Face face)
		{
			var index = m_Faces.BinarySearch(face);
			return index >= 0;
		}

		public int RemoveAll(Predicate<Face> predicate)
		{
			return m_Faces.RemoveAll(predicate);
		}

		public FaceContainer Intersection(FaceContainer container)
		{
			FaceContainer intersectionFaces = new FaceContainer();
			var intersection = m_Faces.Intersect(container.m_Faces);

			foreach (var face in intersection)
			{
				intersectionFaces.AddFace(face);
			}

			return intersectionFaces;
		}

		public List<Face> GetSortedAccordingDistanceFrom(Vector point)
		{
			List<Face> sortedFaces = new List<Face>(m_Faces);
			sortedFaces.Sort((x, y) =>
			{
				if (x.GetPos().Distance2(point) > y.GetPos().Distance2(point))
				{
					return -1;
				}
				else
				{
					return 1;
				}
			});

			return sortedFaces;
		}
	}
}
