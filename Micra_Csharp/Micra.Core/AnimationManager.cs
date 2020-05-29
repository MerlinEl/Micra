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
    /// Provides access to global functionality for managing animations. 
    /// </summary>
    public static class AnimationManager {
        public static void StartPlayback(bool selectedOnly) { Kernel._Interface.StartAnimPlayback(selectedOnly ? 1 : 0); }
        public static void StartPlayback() { StartPlayback(false); }
        public static int Speed { get { return Kernel._Interface.PlaybackSpeed; } set { Kernel._Interface.PlaybackSpeed = value; } }
        public static bool Loop { get { return Kernel._Interface.PlaybackLoop; } set { Kernel._Interface.PlaybackLoop = value; } }
        public static void EndPlayback() { Kernel._Interface.EndAnimPlayback(); }
        public static bool IsPlaying { get { return Kernel._Interface.IsAnimPlaying; } set { if ( value ) StartPlayback(); else EndPlayback(); } }
        public static bool AnimateButtonEnabled { get { return Kernel._Interface.IsAnimateEnabled; } set { Kernel._Interface.EnableAnimateButton(value); } }
        public static bool RealTimePlayback { get { return Kernel._Interface.RealTimePlayback; } set { Kernel._Interface.RealTimePlayback = value; } }
        public static TimeValue StartTime { get { return TimeRange.start; } set { Interval i = new Interval(value, EndTime); TimeRange = i; } }
        public static TimeValue EndTime { get { return TimeRange.end; } set { Interval i = new Interval(StartTime, value); TimeRange = i; } }
        public static Interval TimeRange { get { return new Interval(Kernel._Interface.AnimRange); } set { Kernel._Interface.AnimRange = value._IInterval; } }
        public static int StartFrame { get { return TimeToFrame(StartTime); } }
        public static int EndFrame { get { return TimeToFrame(EndTime); } }
        public static bool IsRealTime { get { return Kernel._Interface.RealTimePlayback; } set { Kernel._Interface.RealTimePlayback = value; } }
        public static int FrameRate { get { return Kernel._Global.FrameRate; } set { Kernel._Global.FrameRate = value; } }
        public static int TicksPerFrame { get { return Kernel._Global.TicksPerFrame; } set { Kernel._Global.TicksPerFrame = value; } }
        public static bool IsLegalFrameRate(int r) { return Kernel._Global.LegalFrameRate(r) != 0; }
        public static TimeDisp TimeDisplay { get { return Kernel._Global.TimeDisplayMode; } set { Kernel._Global.TimeDisplayMode = value; } }
        public static int TimeToFrame(TimeValue t) { return Math.Min(EndTime, ( (int)t - (int)StartTime ) / TicksPerFrame); }
        public static TimeValue FrameToTime(int f) { return Math.Min(EndTime, ( f * TicksPerFrame ) + (int)StartTime); }
        public static int TicksPerSec { get { return TicksPerFrame * FrameRate; } }
        public static TimeValue SecToTimeSpan(double sec) { return (int)( sec * TicksPerSec ); }
        public static double TimeSpanToSec(TimeValue t) { return (double)t / (double)TicksPerSec; }
    }
}
