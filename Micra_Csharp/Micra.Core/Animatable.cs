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
using System.Reflection;
using System.Runtime.Remoting;
using System.Runtime.Remoting.Channels;

using Autodesk.Max;

namespace Micra.Core
{
    /// <summary>
    /// Used internally to create a list of all animatables in a scene.
    /// </summary>
    internal class EnumAnimList : Autodesk.Max.Animatable.IEnumAnimList
    {
        public List<Animatable> animatables = new List<Animatable>();

        #region IEnumAnimList Members
        public bool Proc(IAnimatable theAnim)
        {
            animatables.Add(new Animatable(theAnim));
            return true;
        }
        #endregion

        #region IEquatable<IEnumAnimList> Members
        public bool Equals(Autodesk.Max.Animatable.IEnumAnimList other)
        {
            return this == other;
        }
        #endregion

        #region IDisposable Members
        public void Dispose()
        { }
        #endregion

        public IntPtr Handle { get { return IntPtr.Zero; } }

        public IntPtr NativePointer => throw new NotImplementedException();
    }

    /// <summary>
    /// Represents an AppData chunk. It wraps an Autodesk.Max.IAnimatable
    /// and provides access to the chunk functions.
    /// </summary>
    public class AppData
    {
        IAnimatable anim;
        ClassID cid;
        SuperClassID scid;

        public AppData(IAnimatable anim, ClassID cid, SuperClassID scid)
        {
            this.anim = anim;
            this.cid = cid;
            this.scid = scid;
        }

        public byte[] GetChunk(uint id)
        {
            IAppDataChunk chunk = anim.GetAppDataChunk(cid._IClass_ID, scid, id);
            if (chunk == null) return null;
            return chunk.Data;
        }

        public void AddChunk(uint id, byte[] data)
        {
            anim.AddAppDataChunk(cid._IClass_ID, scid, id, data);
        }

        public void RemoveChunk(uint id)
        {
            anim.RemoveAppDataChunk(cid._IClass_ID, scid, id);
        }

        public IEnumerable<byte[]> Chunks
        {
            get
            {
                for (uint i = 0; true; ++i)
                {
                    byte[] chunk = GetChunk(i);
                    if (chunk == null)
                        yield break;
                    yield return chunk;
                }
            }
        }
    }    

    /// <summary>
    /// Represents common functionality for all scene elements. 
    /// Wraps the Autodesk.Max.IAnimatable class which wraps the 
    /// 3ds Max SDK Animatable class. Provides services for managing
    /// and exposing the wrapper to all derived classes. 
    /// </summary>
    public class Animatable 
    {
        private IAnimatable wrapped;

        protected IParameterBlock parameterBlock;

        internal Animatable(IAnimatable x) 
        { 
            wrapped = x;

            foreach (Animatable anim in Anims)
            {
                if (anim.SuperClassID == SuperClassID.ParameterBlock2)
                    parameterBlock = new ParameterBlock2((IIParamBlock2)anim._Anim);
            }
        }

        /// <summary>
        /// Returns the corresponding wrapped object from the Autodesk.Max layer. 
        /// This is only used if the APIs of Autodesk.Max layer are required.
        /// </summary>
        public IAnimatable _Anim { get { return wrapped; } }
        
        /// <summary>
        /// This function is used internally for creating a MaxDotNet object from the Autodesk.Max layer.
        /// Specifical 
        /// You might need to use it if you are needing to write code that uses both MaxDotNet assembly
        /// and the Autodesk.Max layer. That workflow is not officially supported.
        /// </summary>
        /// <param name="x"></param>
        /// <returns></returns>
        public static T CreateWrapper<T>(IAnimatable x) where T : Animatable
        {
            if (x == null)
                return null;

            // TODO: this should use SuperClass IDs instead.
            if (x is IIParamBlock2)
                return new ParameterBlock2(x as IIParamBlock2) as T;
            else if (x is IIParamBlock)
                return new ParameterBlock1(x as IIParamBlock) as T;
            else if (x is IINode)
                return new Node(x as IINode) as T;
            else if (x is IModifier)
                return new Modifier(x as IModifier) as T;
            else if (x is IStdMat2)
                return new StdMaterial(x as IStdMat2) as T;
            else if (x is IMtl)
                return new Material(x as IMtl) as T;
            else if (x is ITexmap)
                return new Texture(x as ITexmap) as T;
            else if (x is ICameraObject)
                return new Camera(x as ICameraObject) as T;
            else if (x is ILightObject)
                return new Light(x as ILightObject) as T;
            else if (x is IGeomObject)
                return new Geometry(x as IGeomObject) as T;
            else if (x is IObject)
                return new SceneObject(x as IObject) as T;
            else if (x is IBaseObject)
                return new SceneElement(x as IBaseObject) as T;
            else if (x is IReferenceTarget)
                return new ReferenceTarget(x as IReferenceTarget) as T;
            else if (x is IReferenceMaker)
                return new ReferenceMaker(x as IReferenceMaker) as T;
            else if (x is ICustAttrib)
                return new CustomAttribute(x as ICustAttrib) as T;
            else if (x is IICustAttribContainer)
                return new CustomAttributes(x as IICustAttribContainer) as T;
            else if (x is IAnimatable)
                return new Animatable(x as IAnimatable) as T;
            else
                throw new Exception(x + " is not an object that can be wrapped");                         
        }

        /// <summary>
        /// Returns an animatable from a super class ID and a class ID 
        /// </summary>
        /// <typeparam name="T"></typeparam>
        /// <param name="scid"></param>
        /// <param name="cid"></param>
        /// <returns></returns>
        public static T CreatePluginInstance<T>(SuperClassID scid, ClassID cid) where T : Animatable
        {
            // Note: the global Kernel.g.CreateInstance() function is broken! This caused me a lot of grief.
            object o = Kernel._Interface.CreateInstance(scid, cid._IClass_ID);
            IAnimatable ia = o as IAnimatable;
            T r = CreateWrapper<T>(ia);
            if (r == null)
                throw new Exception("Failed to create plug-in instance");
            return r;
        }

        public IEnumerable<Animatable> Anims
        {
            get
            {
                for (int i = 0; i < _Anim.NumSubs; ++i)
                {
                    if (_Anim.SubAnim(i) != null)
                    {
                        Animatable a = new Animatable(_Anim.SubAnim(i));
                        if (a.Valid)
                            yield return a;
                    }
                }
            }
        }



        public static bool operator ==(Animatable a, Animatable b)
        {
            return (object)a == null ? (object)b == null : a.Equals(b);
        }

        public static bool operator !=(Animatable a, Animatable b)
        {
            return (object)a == null ? (object)b != null : !a.Equals(b);
        }

        public override bool Equals(object obj)
        {
            Animatable that = obj as Animatable;
            if ((object)that == null) return false;
            return AnimHandle == that.AnimHandle;
        }

        public override int GetHashCode()
        {
            return wrapped.GetHashCode();
        }

        public string ClassName { get { return _Anim.ClassName; } }
        public ClassID ClassID { get { return new ClassID(_Anim.ClassID); } }
        public SuperClassID SuperClassID { get { return new SuperClassID(_Anim.SuperClassID); } }
        public UIntPtr AnimHandle { get { return Kernel._Global.Animatable.GetHandleByAnim(_Anim); } }
        public bool Valid { get { return AnimHandle != null; } }
        
        public AppData GetAppData(ClassID cid, SuperClassID scid) { return new AppData(_Anim, cid, scid); }
        public AppData GetAppData(Animatable plugin) { return new AppData(_Anim, plugin.ClassID, plugin.SuperClassID); }
        public void ClearAppData() { _Anim.ClearAllAppData(); }

        public CustomAttributes AttributeContainer { get { return new CustomAttributes(_Anim.CustAttribContainer); } }

        #region parameter block functions
        public IEnumerable<IParameter> Params
        {
            get
            {
                if (parameterBlock == null)
                    yield break;

                foreach (IParameter p in parameterBlock.Params)
                    yield return p;
            }
        }

        public IParameterBlock ParameterBlock
        {
            get
            {
                return parameterBlock;
            }
        }

        public Object this[string sParamName]
        {
            get
            {
                return parameterBlock[sParamName].Value;
            }
            set
            {
                parameterBlock[sParamName].Value = value;
            }
        }

        public Object this[int paramID]
        {
            get
            {
                return parameterBlock[paramID].Value;
            }
            set
            {
                parameterBlock[paramID].Value = value;
            }
        }
        #endregion
    }
}
