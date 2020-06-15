using System;
using System.Collections.Generic;
using _2KGames.Fusion.Bridge;

namespace _2KGames.Fusion.Core.Controls.Volume
{
	public class EdgeIntersectionInfo
	{
		public Vertex Vertex1
		{
			get;
			private set;
		}

		public Vertex Vertex2
		{
			get;
			private set;
		}

		public Face Face
		{
			get;
			private set;
		}

		public Vector IntersectPos
		{
			get;
			private set;
		}

		public bool IntersectVertex()
		{
			return Vertex1 == Vertex2;
		}

		public EdgeIntersectionInfo(Vertex vertex1, Vertex vertex2, Vector intersect)
		{
			Vertex1 = vertex1;
			Vertex2 = vertex2;

			IntersectPos = intersect;
		}
	}

	///Represents Volume Face, and must not be planar
	public class Face : VolumeBaseNode
	{
		//Invariant: vertices are oriented counter clock wise, and must not be planar
		private readonly List<Vertex> m_Vertices = new List<Vertex>();

		public Face(List<Vertex> vertices)
		{
			foreach (var item in vertices)
			{
				m_Vertices.Add(item);
			}
			IsVisible = true;
		}

		public List<Vertex> Vertices
		{
			get { return m_Vertices; }
		}

		public int VerticesCount
		{
			get { return m_Vertices.Count; }
		}

		public void GetMeshData(out Vector[] vertices, out ushort[] indices)
		{
			vertices = new Vector[m_Vertices.Count];
			for (int i = 0; i < m_Vertices.Count; i++)
			{
				vertices[i] = m_Vertices[i].GetPos();
			}

			int triangleCnt = m_Vertices.Count - 2;
			indices = new ushort[3 * triangleCnt];

			int index = 0;
			for (ushort i = 0; i < triangleCnt; ++i, index += 3)
			{
				indices[index] = 0;
				indices[index + 1] = (ushort)(i + 1);
				indices[index + 2] = (ushort)(i + 2);
			}
		}

		private void ReverseOrientation()
		{
			m_Vertices.Reverse();
		}

		public override void SetPos(Vector pos)
		{
			Vector currentPos = GetPos();
			Vector diff = pos - currentPos;

			foreach (Vertex vertex in m_Vertices)
			{
				if (vertex.TransformStamp != TransformStamp)
				{
					vertex.TransformStamp = TransformStamp;
					vertex.SetPos(vertex.GetPos() + diff);
				}
			}

			UpdateRequest();
		}

		public override Vector GetPos()
		{
			Vector pos = new Vector(0, 0, 0);
			foreach (Vertex vertex in m_Vertices)
			{
				pos += vertex.GetPos();
			}

			return pos / VerticesCount;
		}

		public override void SetDir(Vector dir)
		{
			Vector pos = GetPos();

			Vector curDir = GetDir();
			float angle = curDir.AngleTo(dir);
			if (angle<0.001f)
			{
				//its close enough
				return;
			}

			Vector axis = dir.Cross(curDir);
			axis.Normalize();

			Quat rot = new Quat();
			rot.MakeFromAxisAngle(axis, angle);

			foreach (Vertex vertex in m_Vertices)
			{
				Manipulators.SceneObjectManipulator.RotateAroundPivot(vertex, pos, rot);
			}

			UpdateRequest();
		}

		public override Vector GetDir()
		{
			return GetFirstNormal();
		}

		public override Vector GetRight()
		{
			return GetMatrixCopy().GetRight();
		}

		public override Vector GetUp()
		{
			return GetDir().Cross(GetRight());
		}

		public override Matrix GetMatrixCopy()
		{
			Matrix matrix = Matrix.Identity;
			matrix.SetDir(GetDir());
			matrix.SetPos(GetPos());
			return matrix;
		}

		public override Matrix GetWorldMatrixCopy()
		{
			return GetMatrixCopy();
		}

		public override Quat GetRot()
		{
			return new Quat();
		}

		public override void SetRot(Quat rot)
		{
		}

		public override float GetScale()
		{
			return 1.0f;
		}

		public override void SetScale(float scale)
		{
		}

		public EdgeEnumerator GetEdgeEnumerator()
		{
			return new EdgeEnumerator(this);
		}

		//Calculates normal of face in case that Face is planar and convex 
		public Vector GetFirstNormal()
		{
			EdgeEnumerator edgeEnumerator = GetEdgeEnumerator();
			edgeEnumerator.MoveNext();

			Edge prevEdge = edgeEnumerator.Current;
			edgeEnumerator.MoveNext();
			Vector firstNormal;

			while (!prevEdge.CalculateNormal(edgeEnumerator.Current, out firstNormal))
			{
				prevEdge = edgeEnumerator.Current;
				bool next = edgeEnumerator.MoveNext();
				System.Diagnostics.Debug.Assert(next, "No valid normal, all vertices from the face are collinear. Invalid face!");
			}

			return firstNormal;
		}

		//Calculates Average normal of face. If face is planar and convex then use GetFirstNormal() which is faster
		public Vector GetAvergeNormal()
		{
			Vector avgNormal = new Vector(0, 0, 0);
			EdgeEnumerator edgeEnumerator = GetEdgeEnumerator();
			edgeEnumerator.MoveNext();
			Edge prevEdge = edgeEnumerator.Current;

			int cnt = 0;
			while (edgeEnumerator.MoveNext())
			{
				Vector edgeNormal;
				if (prevEdge.CalculateNormal(edgeEnumerator.Current, out edgeNormal))
				{
					avgNormal = avgNormal + edgeNormal;
					++cnt;
				}
				prevEdge = edgeEnumerator.Current;
			}

			System.Diagnostics.Debug.Assert(cnt != 0, "No valid normal, all vertices from the face are collinear. Invalid face!");
			avgNormal = avgNormal / cnt;
			avgNormal.Normalize();

			return avgNormal;
		}

		//Determine if face is planar
		public bool IsPlanarAndConvex()
		{
			//Polygon is convex & planar iff cross product of each adjacent edges has the same direction

			EdgeEnumerator edgeEnumerator = GetEdgeEnumerator();
			Edge prevEdge = null;
			Edge firstEdge = null;

			Vector prevNormal = new Vector(0, 0, 0);
			bool validPrevNormal = false;

			while (edgeEnumerator.MoveNext())
			{
				if (prevEdge != null)
				{
					if (prevEdge != firstEdge && prevEdge.GetPos().Distance2(edgeEnumerator.Current.GetPos()) <= Helpers.ValueHelper.Epsilon)
					{
						//if 2 vertices share position, then their normal is not defined, so ignore this case, its still convex & planar
						continue;
					}
					else
					{
						Vector normal;
						if (prevEdge.CalculateNormal(edgeEnumerator.Current, out normal))
						{
							if (prevEdge == firstEdge)
							{
								//we dont have prevNormal in this case, just dont do anything
							}
							else
							{
								if (validPrevNormal && prevNormal.Distance2(normal) > Helpers.ValueHelper.Epsilon)
								{
									return false;
								}
							}

							prevNormal = normal;
							validPrevNormal = true;
						}
					}

				}
				else
				{
					firstEdge = edgeEnumerator.Current;
				}

				prevEdge = edgeEnumerator.Current;
			}

			return true;
		}

		//Search for Vertex, linear complexity
		public bool Contain(Vertex vertex)
		{
			return m_Vertices.Find(item => item == vertex) != null;
		}

		//Find edge which is defined by input vertices.
		public Edge FindEdge(Vertex vertex1, Vertex vertex2, bool orientedOnly)
		{
			var edgeEnumerator = GetEdgeEnumerator();
			while (edgeEnumerator.MoveNext())
			{
				if (edgeEnumerator.Current.Vertex1 == vertex1 && edgeEnumerator.Current.Vertex2 == vertex2)
				{
					return edgeEnumerator.Current;
				}
				else if (!orientedOnly && edgeEnumerator.Current.Vertex1 == vertex2 && edgeEnumerator.Current.Vertex2 == vertex1)
				{
					return edgeEnumerator.Current;
				}
			}

			return null;
		}

		//Returns shared vertices in out params, order of vertices is in order of this face orientation
		public int FindSharedVertices(Face face, out List<Vertex> vertices)
		{
			vertices = new List<Vertex>();

			System.Diagnostics.Debug.Assert(face != this, "Cannot compare same faces!");

			foreach (Vertex vertex in m_Vertices)
			{
				if (face.Contain(vertex))
				{
					vertices.Add(vertex);
					System.Diagnostics.Debug.Assert(Contain(vertex), "Corrupted data detected");
				}
			}


			return vertices.Count;
		}

		//Split face into two subfaces one subface is "this", second is returned. If split cant be done null is returned
		public Face Split(Vertex vertex1, Vertex vertex2)
		{
			List<Vertex> newFaceVertices = new List<Vertex>();
			int matches = 0;

			if (FindEdge(vertex1, vertex2, false) != null)
			{
				//cannot split according face edge
				return null;
			}
			else
			{
				var vertexEnumerator = m_Vertices.GetEnumerator();
				while (matches < 2 && vertexEnumerator.MoveNext())
				{
					if (vertexEnumerator.Current == vertex1 || vertexEnumerator.Current == vertex2)
					{
						//vertices shared between current face and new face 
						newFaceVertices.Add(vertexEnumerator.Current);
						++matches;
					}
					else if (matches == 1)
					{
						//vertices which will be removed from current face and added to new face
						newFaceVertices.Add(vertexEnumerator.Current);
					}
				}
			}

			if (newFaceVertices.Count < 3)
			{
				return null;
			}
			else
			{
				Vector normal = GetFirstNormal();
				for (int idx = 1; idx < newFaceVertices.Count - 1; ++idx)
				{
					//remove this vertices from current face, the will be part of new face
					m_Vertices.Remove(newFaceVertices[idx]);
				}

				Face face = new Face(newFaceVertices);

				//new splitted faces must have same orientation as the original face
				if (face.GetFirstNormal().Dot(normal) < 0)
				{
					face.ReverseOrientation();
				}
				if (GetFirstNormal().Dot(normal) < 0)
				{
					ReverseOrientation();
				}
				return face;
			}
		}

		//Search for edge, Logarithmic complexity
		public bool Contain(Edge edge)
		{
			return FindEdge(edge.Vertex1, edge.Vertex2, true) != null;
		}

		//Add vertex into face, returns true if succeeded, false otherwise
		public bool AddVertex(Edge whereToAdd, Vertex newVertex)
		{
			//Oriented edges only, wont work otherwise because of the insert style
			Edge myEdge = FindEdge(whereToAdd.Vertex1, whereToAdd.Vertex2, true);
			if (myEdge == null)
			{
				Trace.InfoInternal("Cannot add vertex, given edge is not part of the face!");
				return false;
			}

			int idx = m_Vertices.FindIndex(vertex => vertex == whereToAdd.Vertex1);
			System.Diagnostics.Debug.Assert(idx >= 0, "Data are not consistent, edge was found but vertices of the edges werent!");

			m_Vertices.Insert(idx + 1, newVertex);
			return true;
		}

		public Vector CalculateGravityCenter()
		{
			Vector massCenter = new Vector(0, 0, 0);
			foreach (Vertex vertex in m_Vertices)
			{
				massCenter = massCenter + vertex.GetPos();
			}

			massCenter = massCenter / VerticesCount;
			return massCenter;
		}

		//Add vertex into face
		public static void AddVertex(Face whereToAdd, ref List<Face> triangulation)
		{
			Vector massCenter = whereToAdd.CalculateGravityCenter();
			Vertex newVertex = new Vertex(massCenter);

			var edgeEnumerator = whereToAdd.GetEdgeEnumerator();
			edgeEnumerator.MoveNext();
			Edge firstEdge = edgeEnumerator.Current;

			//create new faces
			List<Vertex> vertices = new List<Vertex>();
			while (edgeEnumerator.MoveNext())
			{
				vertices.Clear();
				vertices.Add(edgeEnumerator.Current.Vertex1);
				vertices.Add(edgeEnumerator.Current.Vertex2);
				vertices.Add(newVertex);

				triangulation.Add(new Face(vertices));
			}

			//update the original face
			whereToAdd.m_Vertices.RemoveRange(2, whereToAdd.m_Vertices.Count - 2);
			whereToAdd.m_Vertices.Add(newVertex);
		}

		public bool ReplaceVertex(Vertex vertexToReplace, Vertex replacement)
		{
			for (int idx = 0; idx < m_Vertices.Count; ++idx)
			{
				if (m_Vertices[idx] == vertexToReplace)
				{
					m_Vertices[idx] = replacement;
					return true;
				}
			}

			return false;
		}

		//Returns the farest vertex from given vertex in current face. Distance metric == number of edges
		public Vertex GetFarestVertex(Vertex vertex)
		{
			int idx = m_Vertices.FindIndex(item => item == vertex);
			if (idx < 0)
				return null;

			return m_Vertices[(idx + m_Vertices.Count / 2) % m_Vertices.Count];
		}

		public void GetNeighbourVertices(Vertex vertex, out Vertex prevVertex, out Vertex nextVertex)
		{
			System.Diagnostics.Debug.Assert(vertex != null, "Invalid input vertex");

			prevVertex = null;
			nextVertex = null;

			var vertexEnumerator = m_Vertices.GetEnumerator();
			while (vertexEnumerator.MoveNext())
			{
				if (vertexEnumerator.Current != vertex)
				{
					prevVertex = vertexEnumerator.Current;
				}
				else if (vertexEnumerator.Current == vertex)
				{
					//prev is valid at this moment except the case that this is the first vertex of the polygon
					if (prevVertex == null)
					{
						prevVertex = m_Vertices[m_Vertices.Count - 1];
					}

					if (vertexEnumerator.MoveNext())
					{
						nextVertex = vertexEnumerator.Current;
					}
					else
					{
						nextVertex = m_Vertices[0];
					}

					System.Diagnostics.Debug.Assert(nextVertex != null && prevVertex != null && nextVertex != prevVertex && prevVertex != vertex, "Invalid face found!");
					return;
				}
			}

			System.Diagnostics.Debug.Assert(false, "Vertex is not member of face!");
		}

		public void GetNeighbourEdges(Vertex edgeVertex1, Vertex edgeVertex2, out Vertex connectedWithVertex1, out Vertex connectedWithVertex2)
		{
			connectedWithVertex1 = null;
			connectedWithVertex2 = null;

			Vertex[] neighbours = new Vertex[2];
			GetNeighbourVertices(edgeVertex1, out neighbours[0], out neighbours[1]);
			if (neighbours[0] != edgeVertex2 && neighbours[1] == edgeVertex2)
			{
				connectedWithVertex1 = neighbours[0];
			}
			else if (neighbours[1] != edgeVertex2 && neighbours[0] == edgeVertex2)
			{
				connectedWithVertex1 = neighbours[1];
			}
			else
			{
				System.Diagnostics.Debug.Assert(false, "One of the previous condition has to be met!");
			}

			GetNeighbourVertices(edgeVertex2, out neighbours[0], out neighbours[1]);
			if (neighbours[0] != edgeVertex1 && neighbours[1] == edgeVertex1)
			{
				connectedWithVertex2 = neighbours[0];
			}
			else if (neighbours[1] != edgeVertex1 && neighbours[0] == edgeVertex1)
			{
				connectedWithVertex2 = neighbours[1];
			}
			else
			{
				System.Diagnostics.Debug.Assert(false, "One of the previous condition has to be met!");
			}
		}

		//Remove vertex from face, returns true if succeeded, false otherwise
		public bool Remove(Vertex vertexToRemove)
		{
			return m_Vertices.Remove(vertexToRemove);
		}

		//Calculates Bounding box of the face
		public override AABB GetBBox()
		{
			AABB bbox = new AABB();
			bbox.Invalidate();
			foreach (Vertex vertex in m_Vertices)
			{
				if (!bbox.IsValid())
				{
					bbox = vertex.GetBBox();
				}
				else
				{
					bbox.Absorb(vertex.GetBBox());
				}
			}

			return bbox;
		}

		public override void Accept(ILineCDVisitor visitor)
		{
			System.Diagnostics.Debug.Assert(m_Vertices.Count >= 3, "Face consist of less than 3 vertices. Invalid face!");
			Plane trianglePlane = new Plane(m_Vertices[0].GetPos(), m_Vertices[1].GetPos(), m_Vertices[2].GetPos());

			Vector rayDir = (visitor.GetRayEnd() - visitor.GetRayOrigin());
			float maxDistance = rayDir.Normalize();
			Vector intersectPos = new Vector(0, 0, 0);

			if (trianglePlane.Intersection(visitor.GetRayOrigin(), rayDir, ref intersectPos) && IsPointInside(intersectPos))
			{
				Vector vec = intersectPos - visitor.GetRayOrigin();
				if (vec.Dot(rayDir) < 0) return;

				float dis = vec.Length;
				if (dis >= maxDistance) return;

				TraceResult traceResult = new TraceResult(TraceHitType.Volume, null);
				traceResult.SetSceneNode(this);

				traceResult.LineData = new LineData();
				traceResult.LineData.SetIsecPos(intersectPos);

				traceResult.LineData.SetDistance(dis);
				traceResult.LineData.SetISecNorm(GetFirstNormal());
				visitor.AddTraceRes(traceResult);
			}
		}

		private static Vector ProjectPointToPlane(Vector point, Vector planeNormal, Vector planePoint)
		{
			/*
			The projection of a point q = (x, y, z) onto a plane given by a point p = (a, b, c) and a normal n = (d, e, f) is
			q_proj = q - dot(q - p, n) * n
			*/

			return point - planeNormal * (point - planeNormal).Dot(planeNormal);
		}

		//test if point is inside polygon. Polygon must be planar and convex!
		private bool IsPointInside(Vector testPoint)
		{
			Vector normal = GetFirstNormal();

			Vector testPointNormal = (m_Vertices[0].GetPos() - testPoint).Cross(m_Vertices[1].GetPos() - m_Vertices[0].GetPos());
			testPointNormal.Normalize();

			if (normal.Distance2(testPointNormal) > Helpers.ValueHelper.Epsilon)
			{
				//point is not on the same plane as the face
				return false;
			}


			var edgeEnumerator = GetEdgeEnumerator();
			while (edgeEnumerator.MoveNext())
			{
				Vector insideVec = edgeEnumerator.Current.GetEdgeVector().Cross(normal);
				if (insideVec.Dot(testPoint - edgeEnumerator.Current.GetPos()) > 0)
				{
					return false;
				}
			}

			return true;
		}
		private static bool IsPointInsideTriangle(Vector trianglePoint1, Vector trianglePoint2, Vector trianglePoint3, Vector testPoint)
		{
			Vector v0 = trianglePoint3 - trianglePoint1;
			Vector v1 = trianglePoint2 - trianglePoint1;
			Vector v2 = testPoint - trianglePoint1;

			float dot00 = v0.Dot(v0);
			float dot01 = v0.Dot(v1);
			float dot02 = v0.Dot(v2);
			float dot11 = v1.Dot(v1);
			float dot12 = v1.Dot(v2);

			// Compute barycentric coordinates
			float invDenom = 1.0f / (dot00 * dot11 - dot01 * dot01);
			float u = (dot11 * dot02 - dot01 * dot12) * invDenom;
			float v = (dot00 * dot12 - dot01 * dot02) * invDenom;

			// Check if point is in triangle
			return (u >= 0) && (v >= 0) && (u + v < 1);
		}

		private static bool FindEar(Face inputFace, int earIdx, out Edge edge1, out Edge edge2)
		{
			//TODO: performance of earIdx, do not start from scratch every time!!!

			EdgeEnumerator edgeEnumerator = inputFace.GetEdgeEnumerator();
			Edge prevEdge = null;
			Edge firstEdge = null;

			Vector avgNormal = inputFace.GetAvergeNormal();

			while (edgeEnumerator.MoveNext())
			{
				if (prevEdge != null)
				{
					Vector normal;
					if (prevEdge.CalculateNormal(edgeEnumerator.Current, out normal))
					{
						if (avgNormal.Dot(normal) > 0) //convex angle is good candidate for ear tip
						{
							bool skipCandidate = false;
							foreach (Vertex vertex in inputFace.m_Vertices)
							{
								if (vertex == prevEdge.Vertex1 || vertex == prevEdge.Vertex2 || vertex == edgeEnumerator.Current.Vertex2)
								{
									break;
								}
								else
								{
									if (IsPointInsideTriangle(prevEdge.Vertex1.GetPos(), prevEdge.Vertex2.GetPos(), edgeEnumerator.Current.Vertex2.GetPos(), vertex.GetPos()))
									{
										skipCandidate = true;
										break;
									}
								}
							}

							if (!skipCandidate)
							{
								//we found ear
								if (earIdx-- == 0)
								{
									edge1 = prevEdge;
									edge2 = edgeEnumerator.Current;
									return true;
								}
							}
						}
					}
				}
				else
				{
					firstEdge = edgeEnumerator.Current;
				}

				prevEdge = edgeEnumerator.Current;
			}

			edge1 = null;
			edge2 = null;

			return false;
		}

		//Split face into triangles, newly created triangles are return via output param.
		public static void Triangulate(Face inputFace, ref List<Face> triangulation)
		{
			System.Diagnostics.Debug.Assert(inputFace.VerticesCount >= 3, "Face consist of less than 3 vertices. Invalid face!");
			if (inputFace.VerticesCount == 3)
			{
				return;
			}
			//Vector normal = inputFace.GetAvergeNormal();
			//Vector zero = new Vector(0,0,0);

			/* Projectioin will be solved later if required
			List<Vertex> projectedVertices = new List<Vertex>();

			var vertextEnumerator = inputFace.m_Vertices.GetEnumerator();
			while (vertextEnumerator.MoveNext())
			{
				projectedVertices.Add(new Vertex(ProjectPointToPlane(vertextEnumerator.Current.GetPos(), normal, zero)));
			}

			Face projectedFace = new Face(projectedVertices);
			*/

			List<Vertex> verticesBackup = new List<Vertex>(inputFace.m_Vertices);

			Face projectedFace = inputFace;
			Edge edge1, edge2;

			Vector normal = projectedFace.GetAvergeNormal();
			int findEarIdx = 0;
			while (findEarIdx >= 0 && FindEar(projectedFace, findEarIdx, out edge1, out edge2))
			{
				List<Vertex> triangleVertices = new List<Vertex>();
				triangleVertices.Add(edge1.Vertex1);
				triangleVertices.Add(edge1.Vertex2);

				if (!triangleVertices.Contains(edge2.Vertex1))
				{
					triangleVertices.Add(edge2.Vertex1);
				}
				else
				{
					triangleVertices.Add(edge2.Vertex2);
				}

				Face faceFromEar = new Face(triangleVertices);
				if (faceFromEar.GetAvergeNormal().Dot(normal) < 0.8f)
				{
					//try to find another ear
					++findEarIdx;
					continue;
				}

				Face faceCopy = new Face(verticesBackup);
				faceCopy.Remove(edge1.Vertex2);
				if (faceCopy.GetAvergeNormal().Dot(normal) < 0.8f)
				{
					//try to find another ear
					++findEarIdx;
					continue;
				}
				else
				{
					triangulation.Add(faceFromEar);
					inputFace.Remove(edge1.Vertex2);
				}

				findEarIdx = -1; //while cycle is terminated by this
				Triangulate(inputFace, ref triangulation);
			}

			// System.Diagnostics.Debug.Assert(findEarIdx == -1, "Triangulation failed, no proper triangulation was found!");
			if (findEarIdx != -1)
			{
				throw new Exception("Triangulation failed, no proper triangulation was found!");
			}

		}

		//returns merged face, must be added into faceContainer and face1, face2 removed from faceContainer by user to keep data valid
		public static Face GetMergedFace(Face face1, Face face2)
		{
			Vector normal1 = face1.GetAvergeNormal();
			Vector normal2 = face2.GetAvergeNormal();

			if (normal1.Distance2(normal2) < Helpers.ValueHelper.Epsilon)
			{
				Dictionary<Vertex, Vertex> edges = new Dictionary<Vertex, Vertex>();
				var edgeEnum = face1.GetEdgeEnumerator();
				while (edgeEnum.MoveNext())
				{
					edges.Add(edgeEnum.Current.Vertex1, edgeEnum.Current.Vertex2);
				}

				int sharedVerticesCnt = 0;
				edgeEnum = face2.GetEdgeEnumerator();

				List<Vertex> keysToRemove = new List<Vertex>();
				while (edgeEnum.MoveNext())
				{
					Vertex v;

					//look if the current edge isnt shared with second face
					if (edges.TryGetValue(edgeEnum.Current.Vertex2, out v))
					{
						++sharedVerticesCnt;
						if (v == edgeEnum.Current.Vertex1)
						{
							//its shared, delete
							keysToRemove.Add(edgeEnum.Current.Vertex2);
						}
					}
				}

				foreach (var item in keysToRemove)
				{
					edges.Remove(item);
				}

				edgeEnum = face2.GetEdgeEnumerator();
				while (edgeEnum.MoveNext())
				{
					if (keysToRemove.Contains(edgeEnum.Current.Vertex2))
					{
						continue;
					}

					edges[edgeEnum.Current.Vertex1] = edgeEnum.Current.Vertex2;
				}


				if (sharedVerticesCnt < 2)
				{
					Trace.InfoInternal("Cannot merge faces, they dont share at least two vertices!");
					return null;
				}

				List<Vertex> faceVertices = new List<Vertex>();
				var edgeEnumerator = edges.GetEnumerator();
				edgeEnumerator.MoveNext();

				Vertex firstVertex = edgeEnumerator.Current.Key;
				Vertex prevVertex = firstVertex;
				faceVertices.Add(prevVertex);


				Vertex nextVertex = edgeEnumerator.Current.Value;
				while (nextVertex != firstVertex)
				{
					faceVertices.Add(nextVertex);
					prevVertex = nextVertex;
					nextVertex = edges[prevVertex];
				}

				Face newFace = new Face(faceVertices);
				System.Diagnostics.Debug.Assert(face1.VerticesCount + face2.VerticesCount + 2 - (sharedVerticesCnt * 2) == newFace.VerticesCount, "We lost some vertices during merging faces, data corrupted!");

				return newFace;

			}
			else
			{
				Trace.InfoInternal("Cannot merge faces, they have different normal. Merged face is not planar!");
				return null;
			}
		}

		private const float s_PlaneIntersectionEpsilon = 0.001f;

		public enum FaceOrientation
		{
			//All vertices are above plane
			AbovePlane,

			//All vertices are above plane
			AbovePlaneWithTouch,
			//All vertices are under plane
			UnderPlane,

			UnderPlaneWithTouch,

			//Some vertices are above plane, some are under plane but no vertices is in plane
			CrossPlane,

			InPlane
		}


		public FaceOrientation GetOrientation(Plane plane)
		{
			bool isAbovePlane = false;
			bool isUnderPlane = false;
			bool isInPlane = false;
			foreach (Vertex vertex in m_Vertices)
			{
				float distance = plane.Distance(vertex.GetPos());

				if (distance == 0f)
				{
					isInPlane = true;
				}
				else if (distance > 0.001f)
				{
					//one halfspace
					isAbovePlane = true;
				}
				else if (distance < -0.001f)
				{
					//second halfspace
					isUnderPlane = true;
				}
				else
				{
					isInPlane = true;
				}

			}

			if (isAbovePlane && isUnderPlane)
			{
				return FaceOrientation.CrossPlane;
			}
			else if (isAbovePlane && isInPlane)
			{
				return FaceOrientation.AbovePlaneWithTouch;
			}
			else if (isAbovePlane && !isInPlane)
			{
				return FaceOrientation.AbovePlane;
			}
			else if (isUnderPlane && isInPlane)
			{
				return FaceOrientation.UnderPlaneWithTouch;
			}
			else if (isUnderPlane && !isInPlane)
			{
				return FaceOrientation.UnderPlane;
			}
			else if (isInPlane)
			{
				return FaceOrientation.InPlane;
			}

			System.Diagnostics.Debug.Assert(false, "One of the previous condition has to be met!");
			return FaceOrientation.CrossPlane;
		}

		public bool FindIntersection(Plane plane, out IEnumerable<EdgeIntersectionInfo> intersections)
		{
			List<EdgeIntersectionInfo> intersectionContainer = new List<EdgeIntersectionInfo>();
			intersections = intersectionContainer;

			EdgeEnumerator edgeIt = GetEdgeEnumerator();

			while (edgeIt.MoveNext())
			{
				Vector intersectPos = new Vector();
				Vector edgeVector = edgeIt.Current.GetEdgeVector();
				Vector edgeStart = edgeIt.Current.Vertex1.GetPos();
				Vector edgeEnd = edgeIt.Current.Vertex2.GetPos();

				if (plane.Intersection(edgeStart, edgeVector, ref intersectPos))
				{
					float edgeLen = edgeVector.Length;
					float startToIntersect = edgeStart.Distance(intersectPos);
					float endToIntersect = edgeEnd.Distance(intersectPos);

					if (Math.Abs(edgeLen - startToIntersect) < s_PlaneIntersectionEpsilon && Math.Abs(endToIntersect) < s_PlaneIntersectionEpsilon)
					{
						EdgeIntersectionInfo intersection = new EdgeIntersectionInfo(edgeIt.Current.Vertex2, edgeIt.Current.Vertex2, intersectPos);
						intersectionContainer.Add(intersection);
					}
					else if (startToIntersect < s_PlaneIntersectionEpsilon && Math.Abs(edgeLen - endToIntersect) < s_PlaneIntersectionEpsilon)
					{

						EdgeIntersectionInfo intersection = new EdgeIntersectionInfo(edgeIt.Current.Vertex1, edgeIt.Current.Vertex1, intersectPos);
						intersectionContainer.Add(intersection);
					}
					else if (startToIntersect < edgeLen && endToIntersect < edgeLen)
					{
						EdgeIntersectionInfo intersection = new EdgeIntersectionInfo(edgeIt.Current.Vertex1, edgeIt.Current.Vertex2, intersectPos);
						intersectionContainer.Add(intersection);
					}
				}
			}

			return intersectionContainer.Count > 0;
		}
	}
}
