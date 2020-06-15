using _2KGames.Fusion.Bridge;
using _2KGames.Fusion.Core.Helpers;

namespace _2KGames.Fusion.Core.Controls.Volume
{
    ///Represents Volume Vertex
    public class Vertex : VolumeBaseNode
    {
		//Matrix to support local space
        private Matrix m_Matrix;

        public Vertex(Vector pos)
        {
			m_Matrix = Matrix.Identity;
			m_Matrix.SetPos(pos);
            IsVisible = true;
        }

		public override void SetPos(Vector pos)
        {
			m_Matrix.SetPos(pos);
			UpdateRequest();
        }

        public override Vector GetPos()
        {
			return m_Matrix.GetPos();
        }

		public override Vector GetDir()
		{
			return m_Matrix.GetDir();
		}

		public override Vector GetRight()
		{
			return m_Matrix.GetRight();
		}

		public override Vector GetUp()
		{
			return m_Matrix.GetUp();
		}

		public override Matrix GetMatrixCopy()
		{
			return m_Matrix;
		}

		public override Matrix GetWorldMatrixCopy()
		{
			return GetMatrixCopy();
		}

		public override void SetMatrix(Matrix mtx)
		{
			m_Matrix = mtx;
		}

		public override Quat GetRot()
		{
			return GetMatrixCopy().GetRotQuat();
		}

		public override void SetRot(Quat rot)
		{
			m_Matrix.SetRotQuat(rot);
		}

	    private const float s_DefaultTolerance = 0.06f;
	    private const float s_MaxToleranceMultipliers = 100.0f;

	    public override AABB GetBBox()
        {
            AABB bbox = new AABB(0.0f);
			bbox.SetCenter(m_Matrix.GetPos());
			bbox.SetSize(new Vector(1.0f, 1.0f, 1.0f) * s_DefaultTolerance * s_MaxToleranceMultipliers);
            return bbox;
        }

		public AABB GetBBox(Vector cameraPos)
		{
			float size = s_DefaultTolerance * ValueHelper.Clamp(GetPos().Distance(cameraPos) * 0.2f, s_MaxToleranceMultipliers, 1.0f);
			AABB bbox = new AABB(size);
			bbox.SetCenter(m_Matrix.GetPos());
			return bbox;
		}

		public override void Accept(ILineCDVisitor visitor)
		{
			Sphere sphere = new Sphere(m_Matrix.GetPos(), GetBBox(visitor.GetRayOrigin()).GetRadius());
			Vector rayDir = (visitor.GetRayEnd() - visitor.GetRayOrigin());
			rayDir.Normalize();

			Vector intersectPos = new Vector(0, 0, 0);
			if (sphere.GetLineIntersection(visitor.GetRayOrigin(), rayDir, ref intersectPos))
			{
				TraceResult traceResult = new TraceResult(TraceHitType.Volume, null);
				traceResult.SetSceneNode(this);

				traceResult.LineData = new LineData();
				traceResult.LineData.SetIsecPos(intersectPos);
				traceResult.LineData.SetISecNorm(rayDir);
				traceResult.LineData.SetDistance((intersectPos - visitor.GetRayOrigin()).Length);
				
				visitor.AddTraceRes(traceResult);
			}
		}

    }
}
