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
using Micra.Core.Utils;

namespace Micra.Core {
    /// <summary>
    /// Wraps a IParamBlock (parameter block 1) in the 3ds Max SDK. You should use 
    /// the IParameterBlock interface, instead which provides a common interface to 
    /// both parameter block 1 and parameter block 2.
    /// <see cref="IParameterBlock"/>
    /// </summary>
    public class ParameterBlock1 : ReferenceTarget, IParameterBlock
    {
        readonly List<Param1> ps = new List<Param1>();

        //unsafe internal ParameterBlock1(IIParamBlock pb) : base(pb) 
        internal ParameterBlock1(IIParamBlock pb) : base(pb) 
        { 
            for (int i=0; i < pb.NumParams; ++i)
            {
                IGetParamName gpn = Kernel._Global.GetParamName.Create("", i);

                //Rplaced>
                //pb.NotifyDependents(Interval.Forever._IInterval, (UIntPtr)gpn.Handle.ToPointer(), RefMessage.GetParamName, SuperClassID.NotifyAll, false, null);
                //<

                //With>
                //new UIntPtr(gpn.NativePointer.ToPointer())
                byte[] b = BitConverter.GetBytes(gpn.NativePointer.ToInt64());
                UIntPtr uIntPtr = new UIntPtr(BitConverter.ToUInt64(b, 0));
                NotifyDependentsOption notifyDependentsOption = new NotifyDependentsOption();
                //<

                pb.NotifyDependents(Interval.Forever._IInterval, uIntPtr, RefMessage.GetParamName, SuperClassID.NotifyAll, false, null, notifyDependentsOption);

                if (!String.IsNullOrEmpty(gpn.Name))
                {
                    ps.Add(new Param1(_Block, gpn.Name, i));
                }               
            }
        }

        public IIParamBlock _Block { get { return _Anim as IIParamBlock; } }

        public new IEnumerable<IParameter> Params
        {
            get { foreach (Param1 p in ps) yield return p; }
        }

        public new IParameter this[string internalName]
        {
            get { return Params.FirstOrDefault((IParameter p) => p.Name == internalName.ToLower()); }
        }

        public new IParameter this[int id]
        {
            get { return Params.FirstOrDefault((IParameter p) => p.Id == id); }
        }
    }

    /// <summary>
    /// Used internal to represent a ParamBlock (parameter block 1) parameter/
    /// </summary>
    internal struct Param1 : IParameter
    {
        internal int id;
        internal string name;
        internal IIParamBlock pb;
        internal Param1(IIParamBlock pb, string name, int id) { this.pb = pb; this.name = name.ToLower(); this.id = id; }

        IParamDimension GetDimension()
        {
            return null;
        }

        public Object Value
        {
            get
            {
                return GetValue(Kernel.Now);
            }
            set
            {
                SetValue(value, Kernel.Now);
            }
        }

        public Object GetValue(TimeValue t)
        {
            ParamType pt = pb.GetParameterType(id);
    
            switch (pt)
            {
                case ParamType.Int:
                    return pb.GetInt(id, t);

                case ParamType.Float:
                    {
                        IParamDimension dimension = GetDimension();
                        float result = pb.GetFloat(id, t);

                        try
                        {
                            return dimension != null ? dimension.Convert(result) : result;
                        }
                        // This happens sometimes?
                        catch (AccessViolationException)
                        {
                            throw;
                            //Plugin.Log( Plugin.LogType.Warning, "Error while using IParamDimension to convert value (AccessViolationException)" );
                        }
                        // Also happens when dimension is corrupt (i.e. during VRayMtl creation on 32 bit)
                        catch (NullReferenceException)
                        {
                            throw;
                        }
                        catch (Exception)
                        {
                            throw;
                            // Plugin.Log( Plugin.LogType.Warning, "Unknown error while using IParamDimension to convert value" );
                        }
                    }

                case ParamType.Bool:
                    return pb.GetInt(id, t) != 0;

                case ParamType.Rgba:
                    return pb.GetColor(id, t);

                case ParamType.Point3:
                    return pb.GetPoint3(id, t);

                default:
                    return "parameter type " + Enum.GetName(typeof(ParamType), pt) + " is not supported";
            }
        }

        public void SetValue(Object value, TimeValue time)
        {
            ParamType pt = pb.GetParameterType(id);

            switch (pt)
            {
                case ParamType.Int:
                    pb.SetValue(id, time, (int)value);
                    break;

                case ParamType.Float:
                    {
                        // TODO: get the dimension.
                        IParamDimension dimension = GetDimension();

                        float result = pb.GetFloat(id, time);

                        try
                        {
                            pb.SetValue(id, time, dimension != null ? dimension.UnConvert(Calc.OToF(value)) : Calc.OToF(value));
                        }
                        // Happens sometimes?
                        catch (AccessViolationException)
                        {
                            // Plugin.Log(Plugin.LogType.Warning, "Error while using IParamDimension to unconvert value");
                            pb.SetValue(id, time, (float)value);
                        }
                    }
                    break;

                case ParamType.Bool:
                    pb.SetValue(id, time, (bool)value ? 1 : 0);
                    break;

                case ParamType.Rgba:
                    pb.SetValue(id, time, (IColor)value);
                    break;

                case ParamType.Point3:
                    pb.SetValue(id, time, value as IPoint3);
                    break;

                default:
                    throw new Exception("parameter type is not supported");
            }
        }

        public int Id
        {
            get { return id;  }
        }

        public string Name
        {
            get { return name; }
        }

        public string Type
        {
            get 
            {
                return Enum.GetName(typeof(ParamType), pb.GetParameterType(id));
            }
        }
    }
}
