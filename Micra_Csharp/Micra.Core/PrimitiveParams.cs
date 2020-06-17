using Autodesk.Max;
using System;

namespace Micra.Core {
    public class PrimitiveParams {


    }
    internal static class EParams {

        public const string Length  = "Length";
        public const string Width   = "Width";
        public const string Height  = "Height";
        //public const string realWorldMapSize = "realWorldMapSize";
    }

    public class PBox : SceneObject {
        /*public bool realWorldMapSize { //not works

            get => (bool)parameterBlock[EParams.realWorldMapSize].Value;
            set { parameterBlock[EParams.realWorldMapSize].Value = value; }
        }*/
        public PBox(SceneObject x) : base(x._Object) { _Node = x._Node; }
        //internal PBox(IPrimitive x) : base(x) {}
        //171.3615cm
        public float Length {
            get => (float)parameterBlock[EParams.Length].Value;
            set { parameterBlock[EParams.Length].Value = value;}
        }
        public float Width {
            get => (float)parameterBlock[EParams.Width].Value;
            set { parameterBlock[EParams.Width].Value = value; }
        }
        public float Height {
            get => (float)parameterBlock[EParams.Height].Value;
            set { parameterBlock[EParams.Height].Value = value;}
        }
        /*
        param:length
		param:width
		param:height
		param:widthsegs
		param:lengthsegs
		param:heightsegs
		param:mapcoords
        */
    }
}
