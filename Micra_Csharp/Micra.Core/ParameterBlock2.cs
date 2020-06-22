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
    /// Wraps a 3ds Max SDK IParamBlock2. You should use 
    /// the IParameterBlock interface, instead which provides a common interface to 
    /// both parameter block 1 and parameter block 2.
    /// <see cref="IParameterBlock"/>
    /// </summary>
    public class ParameterBlock2 : ReferenceTarget, IParameterBlock
    {
        internal ParameterBlock2(IIParamBlock2 pb) : base(pb) { }

        public IIParamBlock2 _Block { get { return _Target as IIParamBlock2; } }
        public static ParameterBlock2 Create(IIParamBlock2 x) { return Animatable.CreateWrapper<ParameterBlock2>(x); }

        public new IEnumerable<IParameter> Params { get { for (int i = 0; i < _Block.NumParams; ++i) yield return new Parameter2(_Block, _Block.IndextoID(i)); } }
        public IEnumerable<Object> GetValues() { return from p in Params select p.Value; }
        public IEnumerable<Object> GetValues(TimeValue t) { return from p in Params select p.GetValue(t); }

        public new IParameter this[string paramName]
        {
            get
            {
                return Params.FirstOrDefault((IParameter x) => x.Name == paramName.ToLower());
            }
        }

        public new IParameter this[int paramID]
        {
            get
            {
                return Params.FirstOrDefault((IParameter x) => x.Id == paramID);
            }
        }
    }

    /// <summary>
    /// Wraps a ParamDef struct. 
    /// </summary>
    internal struct ParamDef
    {
        internal IParamDef def;
        internal ParamDef(IParamDef def) { this.def = def; }
    }

    /// <summary>
    /// Represents a single parameter in a parameter block. There is no such thing in the 3ds Max SDK,
    /// so this wraps a parameter block and a parameter id together. 
    /// </summary>
    public struct Parameter2 : IParameter
    {
        internal short id;
        internal IIParamBlock2 pb;
        internal Parameter2(IIParamBlock2 pb, short id) { this.pb = pb; this.id = id; }

        internal ParamDef Def
        {
            get { return new ParamDef(pb.GetParamDef(id)); }
        }

        public string Name
        {
            get { return Def.def.IntName.ToLower(); }
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

        public void SetValue(Object value, TimeValue t)
        {
            SetValue(value, t, -1);
        }

        public Object GetValue(TimeValue t)
        {
            return GetValue(t, -1);
        }

        public int TableSize
        {
            get
            {
                return pb.Count(id);
            }
            set
            {
                pb.SetCount(id, value);
            }
        }

        public IEnumerable<Object> GetTableValues()
        {
            return GetTableValues(Kernel.Now);
        }

        public IEnumerable<Object> GetTableValues(TimeValue t)
        {
            for (int i = 0; i < TableSize; ++i)
                yield return GetValue(t, i);
        }

        public int Id
        {
            get { return id; }
        }


        public string Type
        {
            get { return Enum.GetName(typeof(ParamType2), Def.def.Type); }
        }

        public Object GetValue(TimeValue t, int tabIndex)
        {
            switch (Def.def.Type)
            {
                case ParamType2.Index:
                case ParamType2.IndexTab:
                case ParamType2.Int:
                case ParamType2.IntTab:
                case ParamType2.RadiobtnIndex:
                case ParamType2.RadiobtnIndexTab:
                    return pb.GetInt(id, t, tabIndex);

                case ParamType2.Float:
                case ParamType2.FloatTab:
                case ParamType2.Angle:
                case ParamType2.AngleTab:
                case ParamType2.Double:
                case ParamType2.DoubleTab:
                case ParamType2.World:
                case ParamType2.WorldTab:
                case ParamType2.PcntFrac:
                case ParamType2.PcntFracTab:
                    {
                        IParamDimension dimension = Def.def.Dim;
                        float result = pb.GetFloat(id, t, tabIndex);

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
                            //Plugin.Log( Plugin.LogType.Warning, "Error while using IParamDimension to convert value (NullReferenceException)" );
                        }
                        catch (Exception)
                        {
                            throw;
                            // Plugin.Log( Plugin.LogType.Warning, "Unknown error while using IParamDimension to convert value" );
                        }
                    }
                case ParamType2.Bool:
                case ParamType2.BoolTab:
                case ParamType2.Bool2:
                    return pb.GetInt(id, t, tabIndex) != 0;

                case ParamType2.Rgba:
                case ParamType2.RgbaTab:
                case ParamType2.Color:
                case ParamType2.ColorTab:
                    return pb.GetColor(id, t, tabIndex);

                case ParamType2.Point3:
                case ParamType2.Point3Tab:
                    return pb.GetPoint3(id, t, tabIndex);

                case ParamType2.Frgba:
                case ParamType2.FrgbaTab:
                    return pb.GetAColor(id, t, tabIndex);

                case ParamType2.Tstr:
                case ParamType2.TstrTab:
                case ParamType2.String:
                case ParamType2.StringTab:
                case ParamType2.Filename:
                case ParamType2.FilenameTab:
                case ParamType2.Name:
                case ParamType2.NameTab:
                    return pb.GetStr(id, t, tabIndex);

                default:
                    return "parameter type " + Type + " is not supported";
            }
        }

        public void SetValue(Object value, TimeValue time, int tabIndex)
        {
            switch (Def.def.Type)
            {
                case ParamType2.Index:
                case ParamType2.IndexTab:
                case ParamType2.Int:
                case ParamType2.IntTab:
                case ParamType2.RadiobtnIndex:
                case ParamType2.RadiobtnIndexTab:
                    pb.SetValue(id, time, (int)value, tabIndex);
                    break;

                case ParamType2.Float:
                case ParamType2.FloatTab:
                case ParamType2.Angle:
                case ParamType2.AngleTab:
                case ParamType2.Double:
                case ParamType2.DoubleTab:
                case ParamType2.World:
                case ParamType2.WorldTab:
                case ParamType2.PcntFrac:
                case ParamType2.PcntFracTab:
                    {
                        //IParamDimension dimension = parameters.GetParamDimension( parameters.IDtoIndex( this.paramID ) );
                        IParamDimension dimension = Def.def.Dim;
                        float result = pb.GetFloat(id, time, tabIndex);

                        try
                        {
                            pb.SetValue(id, time, dimension != null ? dimension.UnConvert(Calc.OToF(value)) : Calc.OToF(value), tabIndex);
                        }
                        // Happens sometimes?
                        catch (AccessViolationException)
                        {
                            // Plugin.Log(Plugin.LogType.Warning, "Error while using IParamDimension to unconvert value");
                            pb.SetValue(id, time, (float)value, tabIndex);
                        }
                    }
                    break;

                case ParamType2.Bool:
                case ParamType2.BoolTab:
                case ParamType2.Bool2:
                    pb.SetValue(id, time, (bool)value ? 1 : 0, tabIndex);
                    break;

                case ParamType2.Rgba:
                case ParamType2.RgbaTab:
                case ParamType2.Color:
                case ParamType2.ColorTab:
                    pb.SetValue(id, time, (IColor)value, tabIndex);
                    break;

                case ParamType2.Frgba:
                case ParamType2.FrgbaTab:
                    pb.SetValue(id, time, (IAColor)value, tabIndex);
                    break;

                case ParamType2.Point3:
                case ParamType2.Point3Tab:
                    pb.SetValue(id, time, value as IPoint3, tabIndex);
                    break;

                case ParamType2.Tstr:
                case ParamType2.TstrTab:
                case ParamType2.String:
                case ParamType2.StringTab:
                case ParamType2.Filename:
                case ParamType2.FilenameTab:
                case ParamType2.Name:
                case ParamType2.NameTab:
                    // I'm worried about this. What about AssetUser?
                    pb.SetValue(id, time, (string)value, tabIndex);
                    break;

                default:
                    throw new Exception("parameter type " + Type + " is not supported");
            }
        }
    }
}
