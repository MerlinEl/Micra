//
// Copyright 2012 Autodesk, Inc.  All rights reserved.
//
// Use of this software is subject to the terms of the Autodesk license
// agreement provided at the time of installation or download, or which
// otherwise accompanies this software in either electronic or hard copy form.  
//
using Autodesk.Max;
using System.Collections.Generic;

namespace Micra.Core {
    /// <summary>
    /// Represents a collection of custom attributes. Wraps the 3ds Max class ICustAttribContainer.
    /// </summary>
    public class CustomAttributes : ReferenceTarget {
        internal CustomAttributes(IICustAttribContainer x) : base(x) { }
        public IICustAttribContainer _Container { get { return _Anim as IICustAttribContainer; } }

        public IEnumerable<CustomAttribute> Attributes {
            get {
                for ( int i = 0; i < Count; ++i )
                    yield return new CustomAttribute(_Container.GetCustAttrib(i));
            }
        }

        public void Append(CustomAttribute attr) {
            _Container.AppendCustAttrib(attr._Attrib);
        }
        public int Count {
            get {
                return _Container.NumCustAttribs;
            }
        }
        public void Set(int i, CustomAttribute attr) {
            _Container.SetCustAttrib(i, attr._Attrib);
        }
        public void Remove(int i) {
            _Container.RemoveCustAttrib(i);
        }
        public void Insert(int i, CustomAttribute attr) {
            _Container.InsertCustAttrib(i, attr._Attrib);
        }
        public Animatable Owner {
            get {
                return CreateWrapper<Animatable>(_Container.Owner);
            }
        }
    }

    /// <summary>
    /// Represents an individual custom attribute. Wraps 
    /// the ICustAttrib class in the 3ds Max SDK.
    /// </summary>
    public class CustomAttribute : ReferenceTarget {
        internal CustomAttribute(ICustAttrib x) : base(x) { }
        public ICustAttrib _Attrib { get { return _Anim as ICustAttrib; } }
        public string Name { get { return _Attrib.Name; } }
    }
}
