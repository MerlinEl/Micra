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
    /// Represents a light in the scene.
    /// Wraps a LightObject in the 3ds Max SDK.
    /// </summary>
    public class Light : SceneObject
    {
        internal Light(ILightObject x) : base(x) { }

        /// <summary>
        /// Returns the corresponding wrapped object from the Autodesk.Max layer. 
        /// This is only used if the APIs of Autodesk.Max layer are required.
        /// </summary>
        public ILightObject _Light { get { return _Anim as ILightObject; } }

        public int AbsoluteMapBias
        {
            get
            {
                return _Light.AbsMapBias;
            }
            set
            {
                _Light.AbsMapBias = value;
            }
        }

        public bool DisplayAttenuation
        {
            get { return _Light.AttenDisplay; }
            set { _Light.SetAttenDisplay(value ? 0 : 1); } 
        }

        public bool DisplayCone
        {
            get { return _Light.ConeDisplay; }
        }

        public void Enable(bool b)
        {
            _Light.Enable(b ? 1 : 0);
        }

        public float GetAspect(TimeValue t, Interval valid)
        {
            return _Light.GetAspect(t, valid._IInterval);
        }

        public float GetAttenuation(TimeValue t, int which, Interval valid)
        {
            return _Light.GetAtten(t, which, valid._IInterval);
        }

        public float GetFallOffSize(TimeValue t, Interval valid)
        {
            return _Light.GetFallsize(t, valid._IInterval);
        }

        public float GetHotspot(TimeValue t, Interval valid)
        {
            return _Light.GetHotspot(t, valid._IInterval);
        }

        public float GetIntensity(TimeValue t, Interval valid)
        {
            return _Light.GetIntensity(t, valid._IInterval);
        }

        public float GetMapBias(TimeValue t, Interval valid)
        {
            return _Light.GetMapBias(t, valid._IInterval);
        }

        public float GetMapRange(TimeValue t, Interval valid)
        {
            return _Light.GetMapRange(t, valid._IInterval);
        }

        public int GetMapSize(TimeValue t, Interval valid)
        {
            return _Light.GetMapSize(t, valid._IInterval);
        }

        public Color GetRGBColor(TimeValue t, Interval valid)
        {
            var p = _Light.GetRGBColor(t, valid._IInterval);
            return new Color(p.X, p.Y, p.Z);
        }

        public float GetRayBias(TimeValue t, Interval valid)
        {
            return _Light.GetRayBias(t, valid._IInterval);
        }

        public float GetTargetDist(TimeValue t, Interval valid)
        {
            return _Light.GetTDist(t, valid._IInterval);
        }

        public bool Include
        {
            get { return _Light.Include; }
        }

        public int Overshoot
        {
            get
            {
                return _Light.Overshoot;
            }
            set
            {
                _Light.Overshoot = value;
            }
        }

        public Texture ProjectionMap
        {
            get
            {
                return new Texture(_Light.ProjMap);
            }
            set
            {
                _Light.ProjMap = value._Texmap;
            }
        }

        public int Projector
        {
            get
            {
                return _Light.Projector;
            }
            set
            {
                _Light.Projector = value;
            }
        }

        public void SetAspect(TimeValue t, float f)
        {
            _Light.SetAspect(t, f);
        }

        public void SetAttenuation(TimeValue time, int which, float f)
        {
            _Light.SetAtten(time, which, f);
        }

        public void SetConeDisplay(bool b, int notify)
        {
            _Light.SetConeDisplay(b ? 1 : 0, notify);
        }

        public void SetFallOffSize(TimeValue time, float f)
        {
            _Light.SetFallsize(time, f);
        }

        public void SetHotspot(TimeValue time, float f)
        {
            _Light.SetHotspot(time, f);
        }

        public void SetIntensity(TimeValue time, float f)
        {
            _Light.SetIntensity(time, f);
        }

        public void SetMapBias(TimeValue t, float f)
        {
            _Light.SetMapBias(t, f);
        }

        public void SetMapRange(TimeValue t, float f)
        {
            _Light.SetMapRange(t, f);
        }

        public void SetMapSize(TimeValue t, int param1)
        {
            _Light.SetMapSize(t, param1);
        }

        public void SetRGBColor(TimeValue t, Color rgb)
        {
            Point3 p3 = new Point3(rgb.r, rgb.g, rgb.b);
            _Light.SetRGBColor(t, p3._IPoint3); 
        }

        public void SetRayBias(TimeValue t, float f)
        {
            _Light.SetRayBias(t, f);
        }

        public void SetTargetDist(TimeValue time, float f)
        {
            _Light.SetTDist(time, f);
        }

        public int Shadow
        {
            get
            {
                return _Light.Shadow;
            }
            set
            {
                _Light.Shadow = value;
            }
        }

        public int ShadowMethod
        {
            get { return _Light.ShadowMethod; }
        }

        public int ShadowType
        {
            get
            {
                return _Light.ShadowType;
            }
            set
            {
                _Light.ShadowType = value;
            }
        }

        public void UpdateTargetDistance(TimeValue t, Node inode)
        {
            _Light.UpdateTargDistance(t, inode._Node);
        }

        public bool UseAttenuation
        {
            get { return _Light.UseAtten; }
        }

        public bool UseGlobal
        {
            get
            {
                return _Light.UseGlobal != 0;
            }
            set
            {
                _Light.UseGlobal = value ? 1 : 0;
            }
        }

        public bool UseLight
        {
            get { return _Light.UseLight; }
            set { _Light.SetUseLight(value ? 1 : 0); }
        }
    }
}
