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
    /// <summary>
    /// Represents a color with each color component represented as a float, including the 
    /// transparency. 
    /// </summary>
    [Serializable]
    public struct Color {
        public float r;
        public float g;
        public float b;
        public float a;

        public Color(System.Drawing.Color c) : this(c.R, c.G, c.B, 255) { }
        public Color(IColor c) : this(c.R, c.G, c.B) { }
        public Color(IAColor c) : this(c.R, c.G, c.B, c.A) { }
        public Color(float r, float g, float b, float a) { this.r = r; this.g = g; this.b = b; this.a = a; }
        public Color(float r, float g, float b) : this(r, g, b, 1.0f) { }
        public Color(byte r, byte g, byte b, byte a) : this((float)r / 255.0f, (float)g / 255.0f, (float)b / 255.0f, (float)a / 255.0f) { }
        public Color(byte r, byte g, byte b) : this(r, g, b, 255) { }

        int IntR { get { return (int)( r * 255.0f ); } }
        int IntG { get { return (int)( g * 255.0f ); } }
        int IntB { get { return (int)( b * 255.0f ); } }
        int IntA { get { return (int)( a * 255.0f ); } }

        public IAColor _IAColor { get { return Kernel._Global.AColor.Create(r, g, b, a); } }
        public IColor _IColor { get { return Kernel._Global.Color.Create(r, g, b); } }
        public System.Drawing.Color SystemColor { get { return System.Drawing.Color.FromArgb(IntA, IntR, IntG, IntB); } }

        public static readonly Color MinColor = new Color(0, 0, 0, 0);
        public static readonly Color MaxColor = new Color((byte)255, (byte)255, (byte)255, (byte)255);
    }
}
