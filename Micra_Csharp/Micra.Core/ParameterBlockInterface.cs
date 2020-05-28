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

namespace Micra.Core {
    /// <summary>
    /// Extends any class that implements IParameterBlock with new functions 
    /// for enumerating values. 
    /// </summary>
    public static class IParameterBlockExtensions
    {
        public static IEnumerable<Object> GetValues(this IParameterBlock self) 
        { 
            return GetValues(self, Kernel.Now);
        }

        public static IEnumerable<Object> GetValues(this IParameterBlock self, TimeValue t) 
        { 
            return from x in self.Params select x.GetValue(t); 
        }
    }

    /// <summary>
    /// Represents a list of parameters, either from an IParamBlock or IParamBlock2
    /// </summary>
    public interface IParameterBlock 
    {
        IEnumerable<IParameter> Params { get; }
        IParameter this[string internalName] { get; }
        IParameter this[int id] { get; }
    }

    /// <summary>
    /// Represents a single parameter in either an IParamBlock or IParamBlock2.
    /// </summary>
    public interface IParameter 
    {
        Object Value { get; set; }
        int Id { get; }
        string Name { get; }
        string Type { get; }
        Object GetValue(TimeValue t);
        void SetValue(Object value, TimeValue t);
    }
}
