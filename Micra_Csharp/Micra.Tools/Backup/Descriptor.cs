using Autodesk.Max;

namespace Micra.Tools {
    public class Descriptor : Autodesk.Max.Plugins.ClassDesc2 {
        public IGlobal Global { get; }

        public Descriptor(IGlobal global) {
            Global = global;
            Create(true);
        }

        public override IClass_ID ClassID {
            get { return this.Global.Class_ID.Create((uint)0x28ca31e0, (uint)0x622d62c8); }
        }
        public override bool IsPublic {
            get { return true; }
        }
        public override string Category {
            get { return InternalName; }
        }
        public override string ClassName {
            get { return "Utilities"; }
        }
        public override SClass_ID SuperClassID {
            get { return SClass_ID.Utility; }
        }

        public override object Create(bool loading) {
            return this; //return new Utilities(this);
        }
    }
}
