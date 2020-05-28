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
    /// Represents a 3ds Max modifier. Wraps the Modifier class in the 3ds Max SDK. 
    /// </summary>
    public class Modifier : SceneElement
    {
        internal Modifier(IModifier x) : base(x) { }
        public IModifier _Modifier { get { return _Anim as IModifier; } }        

        public void Apply(Node n)
        {
            n.AddModifier(this);
        }

        public void Remove(Node n)
        {
            n.DeleteModifier(this);
        }

        public bool Enabled
        {
            get
            {
                return _Modifier.IsEnabled;
            }
            set
            {
                if (value)
                {
                    _Modifier.EnableMod();
                }
                else
                {
                    _Modifier.DisableMod();
                }
            }
        }

        public bool EnabledInViews
        {
            get
            {
                return _Modifier.IsEnabledInViews;
            }
            set
            {
                if (value)
                {
                    _Modifier.EnableModInViews();
                }
                else
                {
                    _Modifier.DisableModInViews();
                }
            }
        }

        public bool EnabledInRender
        {
            get
            {
                return _Modifier.IsEnabledInRender;
            }
            set
            {
                if (value)
                {
                    _Modifier.EnableModInRender();
                }
                else
                {
                    _Modifier.DisableModInRender();
                }
            }
        }
    }
}
