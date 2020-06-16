using Autodesk.Max;
using System;

namespace Micra.Core {
    public class PrimitiveParams {


    }
    public class PBox : SceneObject {

        public PBox(SceneObject x) : base(x._Object) { _Node = x._Node; }
        //internal PBox(IPrimitive x) : base(x) {}

        public float Length {
            get => (float)parameterBlock["Length"].Value;
            set { parameterBlock["Length"].Value = value;}
        }
        public float Width {
            get => (float)parameterBlock["Width"].Value;
            set { parameterBlock["Width"].Value = value; }
        }
        public float Height {
            get => (float)parameterBlock["Height"].Value;
            set { parameterBlock["Height"].Value = value;}
        }
    }
}
