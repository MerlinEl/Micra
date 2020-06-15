using System;
using _2KGames.Fusion.Bridge;
using _2KGames.Fusion.Core.Helpers;

namespace _2KGames.Fusion.Core.Controls.Volume
{
	///Represents Volume Edge, do not hold it, its temporary object similar to iterator, some operation will invalidate it.
	///Dependes on the order of Vertex1 and Vertex2!
	public class Edge : VolumeBaseNode
	{
		public Vertex Vertex1 { get; private set; }
		public Vertex Vertex2 { get; private set; }

		public Edge(Vertex vertex1, Vertex vertex2)
		{
			Vertex1 = vertex1;
			Vertex2 = vertex2;
			IsVisible = true;
		}

		public Vector GetEdgeVector()
		{
			return Vertex2.GetPos() - Vertex1.GetPos();
		}

		public override void SetPos(Vector pos)
		{
			Vector currentPos = GetPos();
			Vector diff = pos - currentPos;

			if (Vertex1.TransformStamp != TransformStamp)
			{
				Vertex1.TransformStamp = TransformStamp;
				Vertex1.SetPos(Vertex1.GetPos() + diff);
			}

			if (Vertex2.TransformStamp != TransformStamp)
			{
				Vertex2.TransformStamp = TransformStamp;
				Vertex2.SetPos(Vertex2.GetPos() + diff);
			}

			UpdateRequest();
		}

		public override Vector GetPos()
		{
			return (Vertex1.GetPos() + Vertex2.GetPos()) * 0.5f;
		}

		public override AABB GetBBox()
		{
			AABB bbox = new AABB(new Vector(1, 1, 1) * s_MaxToleranceMultipliers * s_DefaultTolerance);
			bbox.SetCenter(Vertex1.GetPos());

			AABB bbox2 = new AABB(new Vector(1, 1, 1) * s_MaxToleranceMultipliers * s_DefaultTolerance);
			bbox2.SetCenter(Vertex2.GetPos());

			bbox.Absorb(bbox2);
			return bbox;
		}


		private const float s_DefaultTolerance = 0.05f;
		private const float s_MaxToleranceMultipliers = 100.0f;

		public override void Accept(ILineCDVisitor visitor)
		{
			float maxDistance = s_DefaultTolerance * ValueHelper.Clamp(GetPos().Distance(visitor.GetRayOrigin()) * 0.2f, s_MaxToleranceMultipliers, 1.0f);
			float d1 = 0, d2 = 0;

			float dis = Vector.SegmentToSegmentDistance(visitor.GetRayOrigin(), visitor.GetRayEnd(), Vertex1.GetPos(), Vertex2.GetPos(), ref d1, ref d2);

			if (dis < maxDistance)
			{
				Vector intersectPos = visitor.GetRayOrigin() + (visitor.GetRayEnd() - visitor.GetRayOrigin()) * d1;

				TraceResult myRes = new TraceResult(TraceHitType.Volume, null);
				myRes.SetSceneNode(this);

				myRes.LineData = new LineData();
				myRes.LineData.SetIsecPos(intersectPos);
				myRes.LineData.SetDistance((intersectPos - visitor.GetRayOrigin()).Length);
				
				visitor.AddTraceRes(myRes);
			}
		}

		public bool CalculateNormal(Edge edge2, out Vector normal)
		{
			Vector vec1 = GetEdgeVector();
			vec1.Normalize();

			Vector vec2 = edge2.GetEdgeVector();
			vec2.Normalize();

			if (vec1.Distance2(vec2) < ValueHelper.Epsilon)
			{
				normal = new Vector(0, 0, 0);
				//collinear vectors, cannot calculate normal
				return false;
			}

			normal = vec1.Cross(vec2);
			normal.Normalize();
			return true;
		}


		public override Vector GetDir()
		{
			Vector vec = GetEdgeVector();
			vec.Normalize();
			return vec;
		}

		public override Vector GetRight()
		{
			Vector axis = new Vector(0, 0, 1);

			if (Math.Abs(GetDir().Dot(axis)) > 0.9999)
			{
				axis = new Vector(1, 0, 0);
			}

			Vector res = axis.Cross(GetDir());
			res.Normalize();
			return res;
		}

		public override Vector GetUp()
		{
			Vector vec = GetDir().Cross(GetRight());
			vec.Normalize();

			return vec;
		}

		public override Matrix GetMatrixCopy()
		{
			return new Matrix(GetRight(), GetDir(), GetUp(), GetPos());
		}

		public override Matrix GetWorldMatrixCopy()
		{
			return GetMatrixCopy();
		}

		public override Quat GetRot()
		{
			return GetMatrixCopy().GetRotQuat();
		}

		public override void SetRot(Quat rot)
		{
		}
	}
}
