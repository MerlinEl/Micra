//
// Copyright 2012 Autodesk, Inc.  All rights reserved.
//
// Use of this software is subject to the terms of the Autodesk license
// agreement provided at the time of installation or download, or which
// otherwise accompanies this software in either electronic or hard copy form.  
//
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using Autodesk.Max;

namespace Micra.Core {
    /// <summary>
    /// Represents a scene element that can create references to other scene elements. 
    /// </summary>
    public class ReferenceMaker : Animatable
    {
        internal ReferenceMaker(  IReferenceMaker x) : base(x) 
        {
            if (parameterBlock == null)
                parameterBlock = Targets.FilterType<ParameterBlock2>().FirstOrDefault();

            if (parameterBlock == null)
                parameterBlock = Targets.FilterType<ParameterBlock1>().FirstOrDefault();
        }

        public IReferenceMaker _Maker { get { return _Anim as IReferenceMaker; } }

        public IEnumerable<ReferenceTarget> Targets
        {
            get
            {
                for (int i = 0; i < _Maker.NumRefs; ++i)
                {
                    if (_Maker.GetReference(i) != null)
                    {
                        ReferenceTarget rt = null;
                        try
                        {
                            rt = CreateWrapper<ReferenceTarget>(_Maker.GetReference(i));
                        }
                        catch (Exception)
                        {
                            // Happens because the EPhere wrapper can't handle all reference types.
                        }
                        if (rt != null)
                            yield return rt;
                    }
                }
            }
        }

        public IEnumerable<ReferenceTarget> TargetTree
        {
            get 
            {
                foreach (ReferenceTarget rt in Targets)
                {
                    foreach (ReferenceTarget rt2 in rt.TargetTree)
                        yield return rt2;
                    yield return rt;
                }
            }
        }

        /// <summary>
        /// This is the number of references 
        /// </summary>
        public int NumTargets
        {
            get { return _Maker.NumRefs; }
        }

        public ReferenceTarget GetTarget(int n)
        {
            return CreateWrapper<ReferenceTarget>(_Maker.GetReference(n));
        }

        public void SetTarget(int n, ReferenceTarget rt)
        {
            if (rt == null)
                _Maker.ReplaceReference(n, null, true);
            else
                _Maker.ReplaceReference(n, rt._Target, true);
        }

        public IndexedProperty<int, ReferenceTarget> TargetArray 
        {
            get
            {
                return new IndexedProperty<int, ReferenceTarget>(
                    (int n) => GetTarget(n),
                    (int n, ReferenceTarget rt) => SetTarget(n, rt));
            }
        }
    }

    /// <summary>
    /// An iterator that allows the observers of a reference target to be enumerated.
    /// </summary>
    class ObserverIterator : Autodesk.Max.Plugins.DependentEnumProc
    {
        public List<ReferenceMaker> makers = new List<ReferenceMaker>();

        public override int Proc(  IReferenceMaker rmaker)
        {
            if (rmaker != null)
                makers.Add(Animatable.CreateWrapper<ReferenceMaker>(rmaker));
            return 0;
        }
    }

    /// <summary>
    /// Represents a scene element that can be notified of changes. 
    /// </summary>
    public class ReferenceTarget : ReferenceMaker
    {
        internal ReferenceTarget(IReferenceTarget x) : base(x) 
        {
        }

        public IReferenceTarget _Target { get { return _Anim as IReferenceTarget; } }

        public IEnumerable<ReferenceMaker> Observers
        {
            get
            {
                ObserverIterator o = new ObserverIterator();
                _Target.DoEnumDependents(o);
                return o.makers;
            }
        }

        public void AddListener(Action a)
        {
            new ReferenceListener(this, RefMessage.Change, a);
        }        
    }
}
