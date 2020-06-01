using Autodesk.Max;

namespace Micra.Tools { //not used
    internal class MxDescriptor : Autodesk.Max.Plugins.ClassDesc2 {
        public override object Create(bool loading) {

            return null;
            //return new GlobalUtility();
        }

        public override bool IsPublic {
            get {
                return true;
            }
        }

        public override string ClassName {
            get {
                return "Micra Tools";
            }
        }

        public override SClass_ID SuperClassID {
            get {
                return SClass_ID.Gup;
            }
        }

        public override IClass_ID ClassID {
            get {
                return MxGet.Class_ID;
            }
        }

        public override string Category {
            get {
                return "Micra";
            }
        }
    }
}