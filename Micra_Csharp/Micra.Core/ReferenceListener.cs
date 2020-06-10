//
// Copyright 2012 Autodesk, Inc.  All rights reserved.
//
// Use of this software is subject to the terms of the Autodesk license
// agreement provided at the time of installation or download, or which
// otherwise accompanies this software in either electronic or hard copy form.  
//
using Autodesk.Max;
using System;

namespace Micra.Core {
    /// <summary>
    /// A utility class for associating call-back functions with change notifications. 
    /// </summary>
    internal class ReferenceListener : Autodesk.Max.Plugins.ReferenceMaker {
        ReferenceTarget target;
        readonly RefMessage message;
        readonly Action action;

        public ReferenceListener(ReferenceTarget target, RefMessage message, Action action) {
            this.target = target;
            this.message = message;
            this.action = action;
            Kernel.listeners.Add(this);
            ReplaceReference(0, target._Target, true);
        }

        public override RefResult NotifyRefChanged(IInterval changeInt, IReferenceTarget hTarget, ref UIntPtr partID, RefMessage message, bool propagate) {
            //todo fix it
            //if ( hTarget.Handle != target._Target.Handle )
            //return RefResult.Dontcare;
            if ( message == this.message )
                action();
            if ( message == RefMessage.RefDeleted ) {
                Kernel.listeners.Remove(this);
                Dispose();
            }
            return RefResult.Succeed;
        }

        public override int NumRefs {
            get {
                return 1;
            }
        }

        public override IReferenceTarget GetReference(int i) {
            if ( i != 0 ) return null;
            return target._Target;
        }

        public override void SetReference(int i, IReferenceTarget rtarg) {
            if ( i != 0 )
                return;
            if ( rtarg == null )
                target = null;
            else
                target = Animatable.CreateWrapper<ReferenceTarget>(rtarg);
        }
    }
}
