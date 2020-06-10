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
    //comments guide > https://docs.microsoft.com/cs-cz/dotnet/csharp/language-reference/language-specification/documentation-comments
    //maxapi.h > https://github.com/mathieumg/inf4715/blob/master/Exporter/maxsdk/include/maxapi.h
    public enum TaskModes : uint {

        TASK_MODE_CREATE = 1,
        TASK_MODE_MODIFY = 2,
        TASK_MODE_HIERARCHY = 3,
        TASK_MODE_MOTION = 4,
        TASK_MODE_DISPLAY = 5,
        TASK_MODE_UTILITY = 6,
    }

    public enum GeometryType {

        VERTEX = 1,
        EDGE = 2,
        FACE = 3,
        ANY = 4
    }

    /// <summary>
    /// Represents a time value during an animation. 
    /// Wraps the TimeValue typedef in 3ds Max SDK.
    /// <seealso cref="Interval"/>
    /// </summary>
    [Serializable]
    public struct TimeValue {
        public int time;
        public TimeValue(int time) { this.time = time; }
        public static implicit operator TimeValue(int time) { return new TimeValue(time); }
        public static implicit operator int(TimeValue time) { return time.time; }

        public static readonly TimeValue PositiveInfinity = int.MaxValue;
        public static readonly TimeValue NegativeInfinity = int.MinValue;
    }

    /// <summary>
    /// Represents a range of time values during an animation.
    /// Wraps the Interval struct in the 3ds Max SDK.
    /// <seealso cref="TimeValue"/>
    /// </summary>
    [Serializable]
    public struct Interval {
        public TimeValue start;
        public TimeValue end;
        public Interval(IInterval i) { this.start = i.Start; this.end = i.End; }
        public Interval(int start, int end) { this.start = start; this.end = end; }

        public IInterval _IInterval { get { return Kernel._Global.Interval.Create(start, end); } }

        public static readonly Interval Forever = new Interval(TimeValue.NegativeInfinity, TimeValue.PositiveInfinity);
        public static readonly Interval Never = new Interval(TimeValue.NegativeInfinity, TimeValue.NegativeInfinity);
    }
}
