using _2KGames.Fusion.Bridge;
using _2KGames.Fusion.Core.Modules;
using _2KGames.Fusion.Core.Visualisers;

namespace _2KGames.Fusion.Core.Controls.Volume
{
	/// <summary>
	/// Visualise faces of area
	/// </summary>
	public class FaceVisualiser : IVisualiser
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

		public bool Shade
		{
			get;
			set;
		}

		public bool DoubleSided
		{
			get;
			set;
		}

		public bool OutlineHighlight
		{
			get;
			set;
		}

		public FaceVisualiser(RenderContext renderContext, Vector4 color, bool zTest, bool shade, bool outlineHighlight = false)
			: base(renderContext)
		{
			Color = color;
			ZTest = zTest;
			Shade = shade;
			DoubleSided = true;
			OutlineHighlight = outlineHighlight;
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
			if (sceneObject == null || !sceneObject.IsVisible)
			{
				return;
			}

			Face face = sceneObject as Face;
			if (face != null)
			{
				Vector[] vertices;
				ushort[] indices;

				face.GetMeshData(out vertices, out indices);

				Vector normal = face.GetFirstNormal();
				Vector offset = normal * 0.005f;

				Vector4 shadeColor = Color;
				if (Shade)
				{
					float intensity = normal.Dot(m_RenderContext.GetActiveCamera().GetDir() * -1.0f);
					intensity = Helpers.ValueHelper.Clamp(intensity, 1.0f, 0.1f);

					shadeColor.Set(Color.x * (0.5f + intensity * 0.5f), Color.y * (0.5f + intensity * 0.5f), Color.z * (0.5f + intensity * 0.5f), Color.w);
				}

				m_RenderContext.DrawTris(vertices, indices, shadeColor, Matrix.Identity, ZTest, 0.0f, !DoubleSided, false);

				if (OutlineHighlight)
				{
					EdgeEnumerator edgeIt = face.GetEdgeEnumerator();

					Vector4 white = new Vector4(1, 1, 1, 1);

					while (edgeIt.MoveNext())
					{
						m_RenderContext.DrawThickLine(edgeIt.Current.Vertex1.GetPos(), edgeIt.Current.Vertex2.GetPos(), white, Matrix.Identity, true, 0.0f, 0.035f);
					}
				}
			}
		}
	}
}
