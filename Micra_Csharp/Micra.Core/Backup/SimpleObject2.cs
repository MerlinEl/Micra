using Autodesk.Max.MaxSDK.Util;
using System;

namespace Autodesk.Max.Plugins {
    public abstract class SimpleObject2 : SimpleObjectBase, ISimpleObject2, ISimpleObjectBase, IGeomObject, IObject, IBaseObject, IReferenceTarget, IReferenceMaker, IAnimatable, IInterfaceServer, IEquatable<IInterfaceServer>, IDisposable, INativeObject, INoncopyable, IEquatable<INoncopyable> {
        private ISimpleObject2 _Impl => (ISimpleObject2)base.Implementation;

        public override int NumSubs => _Impl.NumSubs;

        public override int NumParamBlocks => _Impl.NumParamBlocks;

        public override int NumRefs => _Impl.NumRefs;

        public override IAnimatable SubAnim(int i) {
            return _Impl.SubAnim(i);
        }

        public override string SubAnimName(int i) {
            return _Impl.SubAnimName(i);
        }

        public override IIParamBlock2 GetParamBlock(int i) {
            return _Impl.GetParamBlock(i);
        }

        public sealed override IIParamBlock2 GetParamBlockByID(short id) {
            return _Impl.GetParamBlockByID(id);
        }

        public override IReferenceTarget GetReference(int i) {
            return _Impl.GetReference(i);
        }
    }
}