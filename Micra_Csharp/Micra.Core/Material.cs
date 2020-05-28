//
// Copyright 2012 Autodesk, Inc.  All rights reserved.
//
// Use of this software is subject to the terms of the Autodesk license
// agreement provided at the time of installation or download, or which
// otherwise accompanies this software in either electronic or hard copy form.  
//
using Autodesk.Max;

namespace Micra.Core {
    /// <summary>
    /// Represents a shading related plug-in such as a texture or material. 
    /// Wraps the MtlBase class in the 3ds Max SDK.
    /// </summary>
    public class ShadingObject : ReferenceTarget {
        internal ShadingObject(IMtlBase x) : base(x) { }
        public IMtlBase _MtlBase { get { return _Anim as IMtlBase; } }
        public uint GBufferID { get { return _MtlBase.GBufID; } set { _MtlBase.GBufID = value; } }
        public bool IsMultiMtl { get { return _MtlBase.IsMultiMtl; } }
    }

    /// <summary>
    /// Represents a material. Wraps the Mtl class in the 3ds Max SDK.
    /// </summary>
    public class Material : ShadingObject {
        internal Material(IMtl x) : base(x) { }
        public IMtl _Mtl { get { return _Anim as IMtl; } }

        public void SetAmbient(Color c, TimeValue t) { _Mtl.SetAmbient(c._IColor, t); }
        public void SetDiffuse(Color c, TimeValue t) { _Mtl.SetDiffuse(c._IColor, t); }
        public void SetSpecular(Color c, TimeValue t) { _Mtl.SetSpecular(c._IColor, t); }
        public void SetShininess(float v, TimeValue t) { _Mtl.SetShininess(v, t); }

        public ShadingObject ActiveTexmap { get { return CreateWrapper<ShadingObject>(_Mtl.ActiveTexmap); } set { _Mtl.ActiveTexmap = value._MtlBase; } }
        public bool DontKeepOldMaterial { get { return _Mtl.DontKeepOldMtl; } }

        public int NumSubMaterials { get { return _Mtl.NumSubMtls; } }
        public ShadingObject GetSubMaterial(int n) { return CreateWrapper<ShadingObject>(_Mtl.GetSubMtl(n)); }
        public void SetSubMaterial(int n, Material m) { _Mtl.SetSubMtl(n, m._Mtl); }
        public bool SupportsRenderElements { get { return _Mtl.SupportsRenderElements; } }
        public bool SupportsShaders { get { return _Mtl.SupportsShaders; } }

        public string GetSubMaterialSlotName(int i) { return _Mtl.GetSubMtlSlotName(i); }
        public string GetSubMaterialTrackViewName(int i) { return _Mtl.GetSubMtlSlotName(i); }

        public Color GetAmbient(int mtlNum, bool backFace) { return new Color(_Mtl.GetAmbient(mtlNum, backFace)); }
        public Color GetDiffuse(int mtlNum, bool backFace) { return new Color(_Mtl.GetDiffuse(mtlNum, backFace)); }
        public Color GetSelfIllumColor(int mtlNum, bool backFace) { return new Color(_Mtl.GetSelfIllumColor(mtlNum, backFace)); }
        public Color GetSpecular(int mtlNum, bool backFace) { return new Color(_Mtl.GetSpecular(mtlNum, backFace)); }
        public bool IsSelfIlluminationColorOn(int mtlNum, bool backFace) { return _Mtl.GetSelfIllumColorOn(mtlNum, backFace); }
        public float GetSelfIllumination(int mtlNum, bool backFace) { return _Mtl.GetSelfIllum(mtlNum, backFace); }
        public float GetShininess(int mtlNum, bool backFace) { return _Mtl.GetShininess(mtlNum, backFace); }
        public float GetShinyStrength(int mtlNum, bool backFace) { return _Mtl.GetShinStr(mtlNum, backFace); }
        public float GetTransparency(int mtlNum, bool backFace) { return _Mtl.GetXParency(mtlNum, backFace); }
        public float GetWireSize(int mtlNum, bool backFace) { return _Mtl.WireSize(mtlNum, backFace); }

        public Color GetAmbient(int mtlNum) { return new Color(_Mtl.GetAmbient(mtlNum, false)); }
        public Color GetDiffuse(int mtlNum) { return new Color(_Mtl.GetDiffuse(mtlNum, false)); }
        public Color GetSelfIllumColor(int mtlNum) { return new Color(_Mtl.GetSelfIllumColor(mtlNum, false)); }
        public Color GetSpecular(int mtlNum) { return new Color(_Mtl.GetSpecular(mtlNum, false)); }
        public bool IsSelfIlluminationColorOn(int mtlNum) { return _Mtl.GetSelfIllumColorOn(mtlNum, false); }
        public float GetSelfIllumination(int mtlNum) { return _Mtl.GetSelfIllum(mtlNum, false); }
        public float GetShininess(int mtlNum) { return _Mtl.GetShininess(mtlNum, false); }
        public float GetShinyStrength(int mtlNum) { return _Mtl.GetShinStr(mtlNum, false); }
        public float GetTransparency(int mtlNum) { return _Mtl.GetXParency(mtlNum, false); }
        public float GetWireSize(int mtlNum) { return _Mtl.WireSize(mtlNum, false); }

        public Color Ambient { get { return new Color(_Mtl.GetAmbient(0, false)); } }
        public Color Diffuse { get { return new Color(_Mtl.GetDiffuse(0, false)); } }
        public Color SelfIllumColor { get { return new Color(_Mtl.GetSelfIllumColor(0, false)); } }
        public Color Specular { get { return new Color(_Mtl.GetSpecular(0, false)); } }
        public bool SelfIlluminationColorOn { get { return _Mtl.GetSelfIllumColorOn(0, false); } }
        public float SelfIllumination { get { return _Mtl.GetSelfIllum(0, false); } }
        public float Shininess { get { return _Mtl.GetShininess(0, false); } }
        public float ShinyStrength { get { return _Mtl.GetShinStr(0, false); } }
        public float Transparency { get { return _Mtl.GetXParency(0, false); } }
        public float WireSize { get { return _Mtl.WireSize(0, false); } }
    }

    /// <summary>
    /// Represents some of the properties contained in the standard material. 
    /// Wraps a StdMat class in the 3ds Max SDK. You should use StdMaterial instead. 
    /// </summary>
    public class BaseStdMaterial : Material {
        internal BaseStdMaterial(IStdMat x) : base(x) { }
        public IStdMat _StdMat { get { return _Anim as IStdMat; } }

        public bool AmbientDiffuseLock { get { return _StdMat.AmbDiffTexLock; } set { _StdMat.LockAmbDiffTex(value); } }
        //TODO fix it
        /*public bool FaceMap { get { return _StdMat.FaceMap; } set { _StdMat.FaceMap = value; } }
        public bool FallOffOut { get { return _StdMat.FalloffOut; } set { _StdMat.FalloffOut = value; } }
        public bool SamplingOn { get { return _StdMat.SamplingOn; } set { _StdMat.SamplingOn = value; } }
        public int Shading { get { return _StdMat.Shading; } set { _StdMat.Shading = value; } }
        public bool Soften { get { return _StdMat.Soften; } set { _StdMat.Soften = value; } }
        public int TransparencyType { get { return _StdMat.TransparencyType; } set { _StdMat.TransparencyType = value; } }
        public bool TwoSided { get { return _StdMat.TwoSided; } set { _StdMat.TwoSided = value; } }
        public bool Wire { get { return _StdMat.Wire; } set { _StdMat.Wire = value; } }
        public bool WireUnits { get { return _StdMat.WireUnits; } set { _StdMat.WireUnits = value; } }*/

        public Color GetAmbient(TimeValue t) { return new Color(_StdMat.GetAmbient(t)); }
        public Color GetDiffuse(TimeValue t) { return new Color(_StdMat.GetDiffuse(t)); }
        public Color GetSpecular(TimeValue t) { return new Color(_StdMat.GetSpecular(t)); }
        public float GetShininess(TimeValue t) { return _StdMat.GetShininess(t); }
        public float GetShinyStrength(TimeValue t) { return _StdMat.GetShinStr(t); }
        public float GetSelfIllumination(TimeValue t) { return _StdMat.GetSelfIllum(t); }
        public float GetOpacity(TimeValue t) { return _StdMat.GetOpacity(t); }
        public float GetOpacityFallOff(TimeValue t) { return _StdMat.GetOpacFalloff(t); }
        public float GetWireSize(TimeValue t) { return _StdMat.GetWireSize(t); }
        public float GetRefractionIndex(TimeValue t) { return _StdMat.GetIOR(t); }

        new public void SetAmbient(Color c, TimeValue t) { _StdMat.SetAmbient(c._IColor, t); }
        new public void SetDiffuse(Color c, TimeValue t) { _StdMat.SetDiffuse(c._IColor, t); }
        new public void SetSpecular(Color c, TimeValue t) { _StdMat.SetSpecular(c._IColor, t); }
        new public void SetShininess(float f, TimeValue t) { _StdMat.SetShininess(f, t); }

        public void SetShinyStrength(float f, TimeValue t) { _StdMat.SetShinStr(f, t); }
        public void SetSelfIllumination(float f, TimeValue t) { _StdMat.SetSelfIllum(f, t); }
        public void SetOpacity(float f, TimeValue t) { _StdMat.SetOpacity(f, t); }
        public void SetOpacityFallOff(float f, TimeValue t) { _StdMat.SetOpacFalloff(f, t); }
        public void SetWireSize(float f, TimeValue t) { _StdMat.SetWireSize(f, t); }
        public void SetRefractionIndex(float f, TimeValue t) { _StdMat.SetIOR(f, t); }

        new public Color Ambient { get { return GetAmbient(Kernel.Now); } set { SetAmbient(value, Kernel.Now); } }
        new public Color Diffuse { get { return GetDiffuse(Kernel.Now); } set { SetDiffuse(value, Kernel.Now); } }
        new public Color Specular { get { return GetSpecular(Kernel.Now); } set { SetSpecular(value, Kernel.Now); } }
        new public float Shininess { get { return GetShininess(Kernel.Now); } set { SetShininess(value, Kernel.Now); } }
        new public float ShinyStrength { get { return GetShinyStrength(Kernel.Now); } set { SetShinyStrength(value, Kernel.Now); } }
        new public float SelfIllumination { get { return GetSelfIllumination(Kernel.Now); } set { SetSelfIllumination(value, Kernel.Now); } }
        new public float WireSize { get { return GetWireSize(Kernel.Now); } set { SetWireSize(value, Kernel.Now); } }
        public float Opacity { get { return GetOpacity(Kernel.Now); } set { SetOpacity(value, Kernel.Now); } }
        public float OpacityFallOff { get { return GetOpacityFallOff(Kernel.Now); } set { SetOpacityFallOff(value, Kernel.Now); } }
        public float RefractionIndex { get { return GetRefractionIndex(Kernel.Now); } set { SetRefractionIndex(value, Kernel.Now); } }
    }

    /// <summary>
    /// Represents a standard material. Wraps the StdMat2 class in the 3ds Max SDK.
    /// </summary>
    public class StdMaterial : BaseStdMaterial {
        internal StdMaterial(IStdMat2 x) : base(x) { }
        public IStdMat2 _StdMat2 { get { return _Anim as IStdMat2; } }

        public static StdMaterial Create() {
            // Note some weirdness in the default standard material (property, not a constructor)
            return CreateWrapper<StdMaterial>(Kernel._Global.NewDefaultStdMat);
        }

        public static StdMaterial CreateDiffuse(Color c) { StdMaterial m = Create(); m.Diffuse = c; return m; }
        public static StdMaterial CreateAmbient(Color c) { StdMaterial m = Create(); m.Ambient = c; return m; }
        public static StdMaterial CreateSpecular(Color c) { StdMaterial m = Create(); m.Specular = c; return m; }

        public static StdMaterial Create(Color diffuse, Color ambient, Color specular, float shininess) {
            StdMaterial m = Create();
            m.Diffuse = diffuse;
            m.Ambient = ambient;
            m.Specular = specular;
            m.Shininess = shininess;
            return m;
        }
    }

    /// <summary>
    /// Represents a texture map. Wraps the Mtl class in the 3ds Max SDK.
    /// </summary>
    public class Texture : ShadingObject {
        internal Texture(ITexmap x) : base(x) { }
        public ITexmap _Texmap { get { return _Anim as ITexmap; } }
    }
}
