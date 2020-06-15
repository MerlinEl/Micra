using _2KGames.Fusion.Bridge;
using _2KGames.Fusion.Core.Modules;
using _2KGames.Fusion.Core.Visualisers;

namespace _2KGames.Fusion.Core.Controls.Volume
{

    /// <summary>
    /// Visualise Vertex primitive
    /// </summary>
    public class EdgeVisualiser : IVisualiser
    {
        public Vector4 Color
        {
            get;
            set;
        }

        public bool ZTest
        {
            get;
            set;
        }

        public EdgeVisualiser(RenderContext renderContext, Vector4 color, bool zTest)
            : base(renderContext)
        {
            Color = color;
            ZTest = zTest;
        }


		public override bool ProcessEveryFrame
		{
			get
			{
				return true;
			}
		}

		public override void ProcessCommand(SceneNode sceneObject, INodeCacheData nodeData)
        {
            Edge edge = sceneObject as Edge;
            if (edge != null)
            {
                Vector toCameraOffset = m_RenderContext.GetActiveCamera().GetPos() - edge.GetPos();
                toCameraOffset.Normalize();
                toCameraOffset = toCameraOffset * 0.05f;
                m_RenderContext.DrawThickLine(edge.Vertex1.GetPos() + toCameraOffset, edge.Vertex2.GetPos() + toCameraOffset, Color, Matrix.Identity, ZTest, 0.0f, 0.01f);

				m_RenderContext.DrawLine(edge.Vertex1.GetPos() + toCameraOffset, edge.Vertex2.GetPos() + toCameraOffset, Color, Matrix.Identity, ZTest, 100000.0f);
            }
        }
    }
}
