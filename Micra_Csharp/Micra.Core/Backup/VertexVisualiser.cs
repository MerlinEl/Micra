using _2KGames.Fusion.Bridge;
using _2KGames.Fusion.Core.Modules;
using _2KGames.Fusion.Core.Visualisers;

namespace _2KGames.Fusion.Core.Controls.Volume
{
    /// <summary>
    /// Visualise Vertex primitive
    /// </summary>
    public class VertexVisualiser : IVisualiser
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

        public VertexVisualiser(RenderContext renderContext, Vector4 color, bool zTest)
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
            Vertex vertex = sceneObject as Vertex;
            if (vertex != null)
            {
				m_RenderContext.DrawSphere(vertex.GetPos(), vertex.GetBBox(m_RenderContext.GetActiveCamera().GetPos()).GetRadius(), Matrix.Identity, Color, false, ZTest, true, true);
            }
        }
    }
    
}
