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
    /// <summary>
    /// Provides a number of predefined colors for convenience.
    /// </summary>
    public static class Colors {
        public static Color AliceBlue { get { return new Color(System.Drawing.Color.AliceBlue); } }
        public static Color AntiqueWhite { get { return new Color(System.Drawing.Color.AntiqueWhite); } }
        public static Color Aqua { get { return new Color(System.Drawing.Color.Aqua); } }
        public static Color Aquamarine { get { return new Color(System.Drawing.Color.Aquamarine); } }
        public static Color Azure { get { return new Color(System.Drawing.Color.Azure); } }
        public static Color Beige { get { return new Color(System.Drawing.Color.Beige); } }
        public static Color Bisque { get { return new Color(System.Drawing.Color.Bisque); } }
        public static Color Black { get { return new Color(System.Drawing.Color.Black); } }
        public static Color BlanchedAlmond { get { return new Color(System.Drawing.Color.BlanchedAlmond); } }
        public static Color Blue { get { return new Color(System.Drawing.Color.Blue); } }
        public static Color BlueViolet { get { return new Color(System.Drawing.Color.BlueViolet); } }
        public static Color Brown { get { return new Color(System.Drawing.Color.Brown); } }
        public static Color BurlyWood { get { return new Color(System.Drawing.Color.BurlyWood); } }
        public static Color CadetBlue { get { return new Color(System.Drawing.Color.CadetBlue); } }
        public static Color Chartreuse { get { return new Color(System.Drawing.Color.Chartreuse); } }
        public static Color Chocolate { get { return new Color(System.Drawing.Color.Chocolate); } }
        public static Color Coral { get { return new Color(System.Drawing.Color.Coral); } }
        public static Color CornflowerBlue { get { return new Color(System.Drawing.Color.CornflowerBlue); } }
        public static Color Cornsilk { get { return new Color(System.Drawing.Color.Cornsilk); } }
        public static Color Crimson { get { return new Color(System.Drawing.Color.Crimson); } }
        public static Color Cyan { get { return new Color(System.Drawing.Color.Cyan); } }
        public static Color DarkBlue { get { return new Color(System.Drawing.Color.DarkBlue); } }
        public static Color DarkCyan { get { return new Color(System.Drawing.Color.DarkCyan); } }
        public static Color DarkGoldenrod { get { return new Color(System.Drawing.Color.DarkGoldenrod); } }
        public static Color DarkGray { get { return new Color(System.Drawing.Color.DarkGray); } }
        public static Color DarkGreen { get { return new Color(System.Drawing.Color.DarkGreen); } }
        public static Color DarkKhaki { get { return new Color(System.Drawing.Color.DarkKhaki); } }
        public static Color DarkMagenta { get { return new Color(System.Drawing.Color.DarkMagenta); } }
        public static Color DarkOliveGreen { get { return new Color(System.Drawing.Color.DarkOliveGreen); } }
        public static Color DarkOrange { get { return new Color(System.Drawing.Color.DarkOrange); } }
        public static Color DarkOrchid { get { return new Color(System.Drawing.Color.DarkOrchid); } }
        public static Color DarkRed { get { return new Color(System.Drawing.Color.DarkRed); } }
        public static Color DarkSalmon { get { return new Color(System.Drawing.Color.DarkSalmon); } }
        public static Color DarkSeaGreen { get { return new Color(System.Drawing.Color.DarkSeaGreen); } }
        public static Color DarkSlateBlue { get { return new Color(System.Drawing.Color.DarkSlateBlue); } }
        public static Color DarkSlateGray { get { return new Color(System.Drawing.Color.DarkSlateGray); } }
        public static Color DarkTurquoise { get { return new Color(System.Drawing.Color.DarkTurquoise); } }
        public static Color DarkViolet { get { return new Color(System.Drawing.Color.DarkViolet); } }
        public static Color DeepPink { get { return new Color(System.Drawing.Color.DeepPink); } }
        public static Color DeepSkyBlue { get { return new Color(System.Drawing.Color.DeepSkyBlue); } }
        public static Color DimGray { get { return new Color(System.Drawing.Color.DimGray); } }
        public static Color DodgerBlue { get { return new Color(System.Drawing.Color.DodgerBlue); } }
        public static Color Firebrick { get { return new Color(System.Drawing.Color.Firebrick); } }
        public static Color FloralWhite { get { return new Color(System.Drawing.Color.FloralWhite); } }
        public static Color ForestGreen { get { return new Color(System.Drawing.Color.ForestGreen); } }
        public static Color Fuchsia { get { return new Color(System.Drawing.Color.Fuchsia); } }
        public static Color Gainsboro { get { return new Color(System.Drawing.Color.Gainsboro); } }
        public static Color GhostWhite { get { return new Color(System.Drawing.Color.GhostWhite); } }
        public static Color Gold { get { return new Color(System.Drawing.Color.Gold); } }
        public static Color Goldenrod { get { return new Color(System.Drawing.Color.Goldenrod); } }
        public static Color Gray { get { return new Color(System.Drawing.Color.Gray); } }
        public static Color Green { get { return new Color(System.Drawing.Color.Green); } }
        public static Color GreenYellow { get { return new Color(System.Drawing.Color.GreenYellow); } }
        public static Color Honeydew { get { return new Color(System.Drawing.Color.Honeydew); } }
        public static Color HotPink { get { return new Color(System.Drawing.Color.HotPink); } }
        public static Color IndianRed { get { return new Color(System.Drawing.Color.IndianRed); } }
        public static Color Indigo { get { return new Color(System.Drawing.Color.Indigo); } }
        public static Color Khaki { get { return new Color(System.Drawing.Color.Khaki); } }
        public static Color Lavender { get { return new Color(System.Drawing.Color.Lavender); } }
        public static Color LavenderBlush { get { return new Color(System.Drawing.Color.LavenderBlush); } }
        public static Color LawnGreen { get { return new Color(System.Drawing.Color.LawnGreen); } }
        public static Color LemonChiffon { get { return new Color(System.Drawing.Color.LemonChiffon); } }
        public static Color LightBlue { get { return new Color(System.Drawing.Color.LightBlue); } }
        public static Color LightCoral { get { return new Color(System.Drawing.Color.LightCoral); } }
        public static Color LightCyan { get { return new Color(System.Drawing.Color.LightCyan); } }
        public static Color LightGoldenrodYellow { get { return new Color(System.Drawing.Color.LightGoldenrodYellow); } }
        public static Color LightGray { get { return new Color(System.Drawing.Color.LightGray); } }
        public static Color LightGreen { get { return new Color(System.Drawing.Color.LightGreen); } }
        public static Color LightPink { get { return new Color(System.Drawing.Color.LightPink); } }
        public static Color LightSalmon { get { return new Color(System.Drawing.Color.LightSalmon); } }
        public static Color LightSeaGreen { get { return new Color(System.Drawing.Color.LightSeaGreen); } }
        public static Color LightSkyBlue { get { return new Color(System.Drawing.Color.LightSkyBlue); } }
        public static Color LightSlateGray { get { return new Color(System.Drawing.Color.LightSlateGray); } }
        public static Color LightSteelBlue { get { return new Color(System.Drawing.Color.LightSteelBlue); } }
        public static Color LightYellow { get { return new Color(System.Drawing.Color.LightYellow); } }
        public static Color Lime { get { return new Color(System.Drawing.Color.Lime); } }
        public static Color LimeGreen { get { return new Color(System.Drawing.Color.LimeGreen); } }
        public static Color Linen { get { return new Color(System.Drawing.Color.Linen); } }
        public static Color Magenta { get { return new Color(System.Drawing.Color.Magenta); } }
        public static Color Maroon { get { return new Color(System.Drawing.Color.Maroon); } }
        public static Color MediumAquamarine { get { return new Color(System.Drawing.Color.MediumAquamarine); } }
        public static Color MediumBlue { get { return new Color(System.Drawing.Color.MediumBlue); } }
        public static Color MediumOrchid { get { return new Color(System.Drawing.Color.MediumOrchid); } }
        public static Color MediumPurple { get { return new Color(System.Drawing.Color.MediumPurple); } }
        public static Color MediumSeaGreen { get { return new Color(System.Drawing.Color.MediumSeaGreen); } }
        public static Color MediumSlateBlue { get { return new Color(System.Drawing.Color.MediumSlateBlue); } }
        public static Color MediumSpringGreen { get { return new Color(System.Drawing.Color.MediumSpringGreen); } }
        public static Color MediumTurquoise { get { return new Color(System.Drawing.Color.MediumTurquoise); } }
        public static Color MediumVioletRed { get { return new Color(System.Drawing.Color.MediumVioletRed); } }
        public static Color MidnightBlue { get { return new Color(System.Drawing.Color.MidnightBlue); } }
        public static Color MintCream { get { return new Color(System.Drawing.Color.MintCream); } }
        public static Color MistyRose { get { return new Color(System.Drawing.Color.MistyRose); } }
        public static Color Moccasin { get { return new Color(System.Drawing.Color.Moccasin); } }
        public static Color NavajoWhite { get { return new Color(System.Drawing.Color.NavajoWhite); } }
        public static Color Navy { get { return new Color(System.Drawing.Color.Navy); } }
        public static Color OldLace { get { return new Color(System.Drawing.Color.OldLace); } }
        public static Color Olive { get { return new Color(System.Drawing.Color.Olive); } }
        public static Color OliveDrab { get { return new Color(System.Drawing.Color.OliveDrab); } }
        public static Color Orange { get { return new Color(System.Drawing.Color.Orange); } }
        public static Color OrangeRed { get { return new Color(System.Drawing.Color.OrangeRed); } }
        public static Color Orchid { get { return new Color(System.Drawing.Color.Orchid); } }
        public static Color PaleGoldenrod { get { return new Color(System.Drawing.Color.PaleGoldenrod); } }
        public static Color PaleGreen { get { return new Color(System.Drawing.Color.PaleGreen); } }
        public static Color PaleTurquoise { get { return new Color(System.Drawing.Color.PaleTurquoise); } }
        public static Color PaleVioletRed { get { return new Color(System.Drawing.Color.PaleVioletRed); } }
        public static Color PapayaWhip { get { return new Color(System.Drawing.Color.PapayaWhip); } }
        public static Color PeachPuff { get { return new Color(System.Drawing.Color.PeachPuff); } }
        public static Color Peru { get { return new Color(System.Drawing.Color.Peru); } }
        public static Color Pink { get { return new Color(System.Drawing.Color.Pink); } }
        public static Color Plum { get { return new Color(System.Drawing.Color.Plum); } }
        public static Color PowderBlue { get { return new Color(System.Drawing.Color.PowderBlue); } }
        public static Color Purple { get { return new Color(System.Drawing.Color.Purple); } }
        public static Color Red { get { return new Color(System.Drawing.Color.Red); } }
        public static Color RosyBrown { get { return new Color(System.Drawing.Color.RosyBrown); } }
        public static Color RoyalBlue { get { return new Color(System.Drawing.Color.RoyalBlue); } }
        public static Color SaddleBrown { get { return new Color(System.Drawing.Color.SaddleBrown); } }
        public static Color Salmon { get { return new Color(System.Drawing.Color.Salmon); } }
        public static Color SandyBrown { get { return new Color(System.Drawing.Color.SandyBrown); } }
        public static Color SeaGreen { get { return new Color(System.Drawing.Color.SeaGreen); } }
        public static Color SeaShell { get { return new Color(System.Drawing.Color.SeaShell); } }
        public static Color Sienna { get { return new Color(System.Drawing.Color.Sienna); } }
        public static Color Silver { get { return new Color(System.Drawing.Color.Silver); } }
        public static Color SkyBlue { get { return new Color(System.Drawing.Color.SkyBlue); } }
        public static Color SlateBlue { get { return new Color(System.Drawing.Color.SlateBlue); } }
        public static Color SlateGray { get { return new Color(System.Drawing.Color.SlateGray); } }
        public static Color Snow { get { return new Color(System.Drawing.Color.Snow); } }
        public static Color SpringGreen { get { return new Color(System.Drawing.Color.SpringGreen); } }
        public static Color SteelBlue { get { return new Color(System.Drawing.Color.SteelBlue); } }
        public static Color Tan { get { return new Color(System.Drawing.Color.Tan); } }
        public static Color Teal { get { return new Color(System.Drawing.Color.Teal); } }
        public static Color Thistle { get { return new Color(System.Drawing.Color.Thistle); } }
        public static Color Tomato { get { return new Color(System.Drawing.Color.Tomato); } }
        public static Color Transparent { get { return new Color(System.Drawing.Color.Transparent); } }
        public static Color Turquoise { get { return new Color(System.Drawing.Color.Turquoise); } }
        public static Color Violet { get { return new Color(System.Drawing.Color.Violet); } }
        public static Color Wheat { get { return new Color(System.Drawing.Color.Wheat); } }
        public static Color White { get { return new Color(System.Drawing.Color.White); } }
        public static Color WhiteSmoke { get { return new Color(System.Drawing.Color.WhiteSmoke); } }
        public static Color Yellow { get { return new Color(System.Drawing.Color.Yellow); } }
        public static Color YellowGreen { get { return new Color(System.Drawing.Color.YellowGreen); } }
    };
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
