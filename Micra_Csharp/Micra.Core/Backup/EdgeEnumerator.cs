using System;
using System.Collections;
using System.Collections.Generic;

namespace _2KGames.Fusion.Core.Controls.Volume
{
    public class EdgeEnumerator : IEnumerator<Edge>
    {
        private readonly IEnumerator<Vertex> m_FaceVerticesEnumerator;
        private Edge m_CurrentEdge;
        private Vertex m_FirstVertex;

        public EdgeEnumerator(Face face)
        {
            m_FaceVerticesEnumerator = face.Vertices.GetEnumerator();
        }

        public Edge /*IEnumerator<Edge>.*/Current
        {
            get { return m_CurrentEdge; }
        }

        object IEnumerator.Current
        {
            get { return m_CurrentEdge; }
        }

        public void Reset()
        {
            //m_FaceVerticesEnumerator.Reset();
        }

        public bool MoveNext()
        {
            //to get first edge we have to get 2 vertices
            if (m_FirstVertex == null)
            {
                if (!m_FaceVerticesEnumerator.MoveNext())
                {
                    return false;
                }
                else
                {
                    m_FirstVertex = m_FaceVerticesEnumerator.Current;
                }
            }

            Vertex prevVertex = m_FaceVerticesEnumerator.Current;
            if (m_FaceVerticesEnumerator.MoveNext())
            {
                m_CurrentEdge = new Edge(prevVertex, m_FaceVerticesEnumerator.Current);
                return true;
            }
            else
            {
                if (m_FirstVertex != null)
                {
                    //to get last edge, we have to return first and last vertices
                    m_CurrentEdge = new Edge(prevVertex, m_FirstVertex);
                    m_FirstVertex = null;
                    return true;
                }
                else
                {
                    //even the edge from Last and First vertices was used, no other edge to iterate 
                    return false;
                }
            }
        }

        void IDisposable.Dispose() { }
    }
}
