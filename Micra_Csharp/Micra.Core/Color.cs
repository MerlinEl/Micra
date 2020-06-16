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
        public float r; //These values are in the range 0.0 to 1.0.
        public float g; //These values are in the range 0.0 to 1.0.
        public float b; //These values are in the range 0.0 to 1.0.
        public float a; //These values are in the range 0.0 to 1.0.

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
        /// <summary>Generate Random Color RGB in range( 0.0 to 1.0 )</summary>
        public static Color Random() {
            Random random = new Random();
            return new Color(Utility.RandomFloat(random), Utility.RandomFloat(random), Utility.RandomFloat(random));
        }
        /// <summary> Generate Rainbow Color RGB in range( 0.0 to 1.0 )
        ///     <example> 
        ///         <code>
		///             example: 
        ///             for (int i = 0; i < SpnBoxCnt.Value; i++) {
        ///                 box.Wirecolor = Color.RainbowColor((int)SpnBoxCnt.Value, i);
        ///             }
		///         </code>
		///     </example>
        ///     <para>param: <paramref name="numOfSteps"/>Total Colors Number</para>
        ///     <para>param: <paramref name="step"/>Current Color Number</para>
        /// </summary>
        public static Color RainbowColor(int numOfSteps, int step) {
            var r = 0.0;
            var g = 0.0;
            var b = 0.0;
            var h = (Double)step / numOfSteps;
            var i = (Int32)( h * 6 );
            var f = h * 6.0 - i;
            var q = 1 - f;

            switch ( i % 6 ) {
                case 0: r = 1; g = f; b = 0; break;
                case 1: r = q; g = 1; b = 0; break;
                case 2: r = 0; g = 1; b = f; break;
                case 3: r = 0; g = q; b = 1; break;
                case 4: r = f; g = 0; b = 1; break;
                case 5: r = 1; g = 0; b = q; break;
            }
            return new Color((float)r, (float)g, (float)b);
        }

        public override string ToString() {
            return String.Format("R:{0} G:{1} B:{2} A:{3}", r, g, b, a);
        }
    }
}


/// <summary>
/// Compares two color values.
/// </summary>
/*public static int Compare(Color colorA, Color colorB) {
    return colorA.ToArgb().CompareTo(colorB.ToArgb());
}

/// <summary>
/// Extends the ColorTranslator.ToHtml method with an alpha value.
/// </summary>
public static String ToHtml(Color c) {
    if ( c.IsKnownColor || c.IsNamedColor || c.IsSystemColor )
        return ColorTranslator.ToHtml(c);
    else
        return "#" + c.A.ToString("X2", null)
                   + c.R.ToString("X2", null)
                   + c.G.ToString("X2", null)
                   + c.B.ToString("X2", null);
}

/// <summary>
/// Extends the ColorTranslator.FromHtml method to accept alpha values.
/// </summary>
public static Color FromHtml(String htmlColor) {
    Throw.IfNull(htmlColor, "htmlColor");

    if ( htmlColor.Length == 9 && htmlColor[0] == '#' )
        return Color.FromArgb(Convert.ToInt32(htmlColor.Substring(1, 2), 16)
                             , Convert.ToInt32(htmlColor.Substring(3, 2), 16)
                             , Convert.ToInt32(htmlColor.Substring(5, 2), 16)
                             , Convert.ToInt32(htmlColor.Substring(7, 2), 16));
    else
        return ColorTranslator.FromHtml(htmlColor);
}

/// <summary>
/// Workaround 3dsMax Color issues. (Alpha + flipped components)
/// </summary>
/// <param name="color">The color value from 3dsMax.</param>
/// <returns>A correct color value.</returns>
public static Color FromMaxColor(Color color) {
    return Color.FromArgb(255, color.B, color.G, color.R);
}

/// <summary>
/// Converts an Autodesk.Max.IColor struct to a System.Drawing.Color struct.
/// </summary>
public static Color FromMaxColor(IColor color) {
    Throw.IfNull(color, "color");
    return FromMaxColor(Color.FromArgb((int)color.ToRGB));
}

/// <summary>
/// Converts an Autodesk.Max.IAColor struct to a System.Drawing.Color struct.
/// </summary>
public static Color FromMaxColor(IAColor color) {
    Throw.IfNull(color, "color");
    return new Color (System.Drawing.Color.FromArgb((int)color.ToRGB));
}

public static Color FromMaxColor(IPoint3 color) {
    return new Color( 
        System.Drawing.Color.FromArgb(ToColorChannel(color.X), ToColorChannel(color.Y), ToColorChannel(color.Z))
    );
}

private static int ToColorChannel(float channel) {
    return (int)( channel * 255 );
}

/// <summary>
/// Resolves a GuiColors enum value to a Color value.
/// </summary>
public static Color FromMaxGuiColor(GuiColors color) {
    return Colors.FromMaxColor(MaxInterfaces.ColorManager.GetColor(color));
}

/// <summary>
/// Combines two colors by overlaying them.
/// </summary>
public static Color OverlayColor(Color colorA, Color colorB) {
    float overlayAmount = colorB.A / 255f;
    float baseAmount = 1.0f - overlayAmount;

    return Color.FromArgb(
       255,
       (byte)Math.Round(colorA.R * baseAmount + colorB.R * overlayAmount),
       (byte)Math.Round(colorA.G * baseAmount + colorB.G * overlayAmount),
       (byte)Math.Round(colorA.B * baseAmount + colorB.B * overlayAmount));
}

/// <summary>
/// Gets the most contrasting color from two alternatives.
/// </summary>
/// <param name="refColor">The color to contrast with.</param>
/// <param name="colorA">Color alternative A</param>
/// <param name="colorB">Color alternative B</param>
public static Color SelectContrastingColor(Color refColor, Color colorA, Color colorB) {
    Throw.IfNull(refColor, "refColor");
    Throw.IfNull(colorA, "colorA");
    Throw.IfNull(colorB, "colorB");

    float brightnessRef = refColor.GetBrightness();
    float brightnessA = colorA.GetBrightness();
    float brightnessB = colorB.GetBrightness();

    if ( Math.Abs(brightnessRef - brightnessB) > Math.Abs(brightnessRef - brightnessA) )
        return colorB;
    else
        return colorA;
}*/
