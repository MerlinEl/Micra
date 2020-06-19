namespace Micra.Core.Prim {
    /// <summary> Enum Primitive Parmeters</summary>
    internal static class EParams {
        public const string Radius = "Radius";
        public const string Segs = "Segs";
        public const string Smooth = "Smooth";
        public const string Body = "Body";
        public const string Handle = "Handle";
        public const string Spout = "Spout";
        public const string Lid = "Lid";
        public const string Mapcoords = "Mapcoords";
        public const string Length = "Length";
        public const string Width = "Width";
        public const string Height = "Height";
        public const string Widthsegs = "Widthsegs";
        public const string Lengthsegs = "Lengthsegs";
        public const string Heightsegs = "Heightsegs";
        public const string Hemisphere = "Hemisphere";
        public const string Chop = "Chop";
        public const string Recenter = "Recenter";
        public const string Slice = "Slice";
        public const string Slicefrom = "Slicefrom";
        public const string Sliceto = "Sliceto";
        public const string Capsegs = "Capsegs";
        public const string Sides = "Sides";
        public const string Radius1 = "Radius1";
        public const string Radius2 = "Radius2";
        public const string Tuberotation = "Tuberotation";
        public const string Tubetwist = "Tubetwist";
        public const string Family = "Family";
        public const string Pvalue = "P value";
        public const string Qvalue = "Q value";
        public const string Pscale = "P scale";
        public const string Qscale = "Q scale";
        public const string Rscale = "R scale";
        public const string Parameter = "Parameter";
        public const string Size = "Size";
        public const string Centermarker = "Centermarker";
        public const string Axistripod = "Axistripod";
        public const string Cross = "Cross";
        public const string Box = "Box";
        public const string Constantscreensize = "Constantscreensize";
        public const string Drawontop = "Drawontop";
        public const string Render_thickness = "Render_thickness";
        public const string Render_sides = "Render_sides";
        public const string Render_angle = "Render_angle";
        public const string Render_width = "Render_width";
        public const string Render_length = "Render_length";
        public const string Render_angle2 = "Render_angle2";
        public const string Render_threshold = "Render_threshold";
        public const string Ellipse_thickness = "Ellipse_thickness";
        public const string Ellipse_outline = "Ellipse_outline";
        public const string Fov = "Fov";
        public const string Targetdistance = "Target distance";
        public const string Nearclip = "Near clip";
        public const string Farclip = "Far clip ";
        public const string Nearenvrange = "Near env range";
        public const string Farenvrange = "Far env range";
        public const string Multipasseffectenabled = "Multipass effect enabled";
        public const string Mpeffect_rendereffectsperpass = "Mpeffect - render effects per pass";
        public const string Fovtype = "Fov type";
        public const string Color = "Color";
        public const string Multiplier = "Multiplier";
        public const string Contrast = "Contrast";
        public const string Diffusesoften = "Diffuse soften";
        public const string Attenuationnearstart = "Attenuation near start";
        public const string Attenuationnearend = "Attenuation near end";
        public const string Attenuationfarstart = "Attenuation far start";
        public const string Attenuationfarend = "Attenuation far end";
        public const string Decayfalloff = "Decay falloff";
        public const string Shadowcolor = "Shadow color";
        public const string Atmosphereopacity = "Atmosphere opacity";
        public const string Atmospherecoloramount = "Atmosphere color amount";
        public const string Shadowdensity = "Shadow density";
        public const string Hotspot = "Hotspot";
        public const string Falloff = "Falloff";
        public const string Aspectratio = "Aspect ratio";
        public const string Density = "Density";
        public const string Renderscale = "Renderscale";
    }
    /// <summary> Primitive Objects with predefined Params</summary>
    public class PTeapot : SceneObject {
        public PTeapot(SceneObject x) : base(x._Object) { _Node = x._Node; }
        public float Radius {
            get => (float)parameterBlock[EParams.Radius].Value;
            set { parameterBlock[EParams.Radius].Value = value; }
        }
        public float Segs {
            get => (float)parameterBlock[EParams.Segs].Value;
            set { parameterBlock[EParams.Segs].Value = value; }
        }
        public float Smooth {
            get => (float)parameterBlock[EParams.Smooth].Value;
            set { parameterBlock[EParams.Smooth].Value = value; }
        }
        public float Body {
            get => (float)parameterBlock[EParams.Body].Value;
            set { parameterBlock[EParams.Body].Value = value; }
        }
        public float Handle {
            get => (float)parameterBlock[EParams.Handle].Value;
            set { parameterBlock[EParams.Handle].Value = value; }
        }
        public float Spout {
            get => (float)parameterBlock[EParams.Spout].Value;
            set { parameterBlock[EParams.Spout].Value = value; }
        }
        public float Lid {
            get => (float)parameterBlock[EParams.Lid].Value;
            set { parameterBlock[EParams.Lid].Value = value; }
        }
        public float Mapcoords {
            get => (float)parameterBlock[EParams.Mapcoords].Value;
            set { parameterBlock[EParams.Mapcoords].Value = value; }
        }
    }
    public class PBox : SceneObject {
        public PBox(SceneObject x) : base(x._Object) { _Node = x._Node; }
        public float Length {
            get => (float)parameterBlock[EParams.Length].Value;
            set { parameterBlock[EParams.Length].Value = value; }
        }
        public float Width {
            get => (float)parameterBlock[EParams.Width].Value;
            set { parameterBlock[EParams.Width].Value = value; }
        }
        public float Height {
            get => (float)parameterBlock[EParams.Height].Value;
            set { parameterBlock[EParams.Height].Value = value; }
        }
        public float Widthsegs {
            get => (float)parameterBlock[EParams.Widthsegs].Value;
            set { parameterBlock[EParams.Widthsegs].Value = value; }
        }
        public float Lengthsegs {
            get => (float)parameterBlock[EParams.Lengthsegs].Value;
            set { parameterBlock[EParams.Lengthsegs].Value = value; }
        }
        public float Heightsegs {
            get => (float)parameterBlock[EParams.Heightsegs].Value;
            set { parameterBlock[EParams.Heightsegs].Value = value; }
        }
        public float Mapcoords {
            get => (float)parameterBlock[EParams.Mapcoords].Value;
            set { parameterBlock[EParams.Mapcoords].Value = value; }
        }
    }
    public class PPlane : SceneObject {
        public PPlane(SceneObject x) : base(x._Object) { _Node = x._Node; }
        public float Length {
            get => (float)parameterBlock[EParams.Length].Value;
            set { parameterBlock[EParams.Length].Value = value; }
        }
        public float Width {
            get => (float)parameterBlock[EParams.Width].Value;
            set { parameterBlock[EParams.Width].Value = value; }
        }
        public float Lengthsegs {
            get => (float)parameterBlock[EParams.Lengthsegs].Value;
            set { parameterBlock[EParams.Lengthsegs].Value = value; }
        }
        public float Widthsegs {
            get => (float)parameterBlock[EParams.Widthsegs].Value;
            set { parameterBlock[EParams.Widthsegs].Value = value; }
        }
        public float Density {
            get => (float)parameterBlock[EParams.Density].Value;
            set { parameterBlock[EParams.Density].Value = value; }
        }
        public float Renderscale {
            get => (float)parameterBlock[EParams.Renderscale].Value;
            set { parameterBlock[EParams.Renderscale].Value = value; }
        }
        public float Mapcoords {
            get => (float)parameterBlock[EParams.Mapcoords].Value;
            set { parameterBlock[EParams.Mapcoords].Value = value; }
        }
    }

    public class PSphere : SceneObject {
        public PSphere(SceneObject x) : base(x._Object) { _Node = x._Node; }
        public float Radius {
            get => (float)parameterBlock[EParams.Radius].Value;
            set { parameterBlock[EParams.Radius].Value = value; }
        }
        public float Segs {
            get => (float)parameterBlock[EParams.Segs].Value;
            set { parameterBlock[EParams.Segs].Value = value; }
        }
        public float Smooth {
            get => (float)parameterBlock[EParams.Smooth].Value;
            set { parameterBlock[EParams.Smooth].Value = value; }
        }
        public float Hemisphere {
            get => (float)parameterBlock[EParams.Hemisphere].Value;
            set { parameterBlock[EParams.Hemisphere].Value = value; }
        }
        public float Chop {
            get => (float)parameterBlock[EParams.Chop].Value;
            set { parameterBlock[EParams.Chop].Value = value; }
        }
        public float Recenter {
            get => (float)parameterBlock[EParams.Recenter].Value;
            set { parameterBlock[EParams.Recenter].Value = value; }
        }
        public float Mapcoords {
            get => (float)parameterBlock[EParams.Mapcoords].Value;
            set { parameterBlock[EParams.Mapcoords].Value = value; }
        }
        public float Slice {
            get => (float)parameterBlock[EParams.Slice].Value;
            set { parameterBlock[EParams.Slice].Value = value; }
        }
        public float Slicefrom {
            get => (float)parameterBlock[EParams.Slicefrom].Value;
            set { parameterBlock[EParams.Slicefrom].Value = value; }
        }
        public float Sliceto {
            get => (float)parameterBlock[EParams.Sliceto].Value;
            set { parameterBlock[EParams.Sliceto].Value = value; }
        }
    }
    public class PCylinder : SceneObject {
        public PCylinder(SceneObject x) : base(x._Object) { _Node = x._Node; }
        public float Radius {
            get => (float)parameterBlock[EParams.Radius].Value;
            set { parameterBlock[EParams.Radius].Value = value; }
        }
        public float Height {
            get => (float)parameterBlock[EParams.Height].Value;
            set { parameterBlock[EParams.Height].Value = value; }
        }
        public float Heightsegs {
            get => (float)parameterBlock[EParams.Heightsegs].Value;
            set { parameterBlock[EParams.Heightsegs].Value = value; }
        }
        public float Capsegs {
            get => (float)parameterBlock[EParams.Capsegs].Value;
            set { parameterBlock[EParams.Capsegs].Value = value; }
        }
        public float Sides {
            get => (float)parameterBlock[EParams.Sides].Value;
            set { parameterBlock[EParams.Sides].Value = value; }
        }
        public float Smooth {
            get => (float)parameterBlock[EParams.Smooth].Value;
            set { parameterBlock[EParams.Smooth].Value = value; }
        }
        public float Slice {
            get => (float)parameterBlock[EParams.Slice].Value;
            set { parameterBlock[EParams.Slice].Value = value; }
        }
        public float Slicefrom {
            get => (float)parameterBlock[EParams.Slicefrom].Value;
            set { parameterBlock[EParams.Slicefrom].Value = value; }
        }
        public float Sliceto {
            get => (float)parameterBlock[EParams.Sliceto].Value;
            set { parameterBlock[EParams.Sliceto].Value = value; }
        }
        public float Mapcoords {
            get => (float)parameterBlock[EParams.Mapcoords].Value;
            set { parameterBlock[EParams.Mapcoords].Value = value; }
        }
    }

    public class PHedra : SceneObject {
        public PHedra(SceneObject x) : base(x._Object) { _Node = x._Node; }
        public float Radius {
            get => (float)parameterBlock[EParams.Radius].Value;
            set { parameterBlock[EParams.Radius].Value = value; }
        }
        public float Family {
            get => (float)parameterBlock[EParams.Family].Value;
            set { parameterBlock[EParams.Family].Value = value; }
        }
        public float Pvalue {
            get => (float)parameterBlock[EParams.Pvalue].Value;
            set { parameterBlock[EParams.Pvalue].Value = value; }
        }
        public float Qvalue {
            get => (float)parameterBlock[EParams.Qvalue].Value;
            set { parameterBlock[EParams.Qvalue].Value = value; }
        }
        public float Pscale {
            get => (float)parameterBlock[EParams.Pscale].Value;
            set { parameterBlock[EParams.Pscale].Value = value; }
        }
        public float Qscale {
            get => (float)parameterBlock[EParams.Qscale].Value;
            set { parameterBlock[EParams.Qscale].Value = value; }
        }
        public float Rscale {
            get => (float)parameterBlock[EParams.Rscale].Value;
            set { parameterBlock[EParams.Rscale].Value = value; }
        }
        public float Parameter {
            get => (float)parameterBlock[EParams.Parameter].Value;
            set { parameterBlock[EParams.Parameter].Value = value; }
        }
    }
    public class PTube : SceneObject {
        public PTube(SceneObject x) : base(x._Object) { _Node = x._Node; }
        public float Radius1 {
            get => (float)parameterBlock[EParams.Radius1].Value;
            set { parameterBlock[EParams.Radius1].Value = value; }
        }
        public float Radius2 {
            get => (float)parameterBlock[EParams.Radius2].Value;
            set { parameterBlock[EParams.Radius2].Value = value; }
        }
        public float Height {
            get => (float)parameterBlock[EParams.Height].Value;
            set { parameterBlock[EParams.Height].Value = value; }
        }
        public float Sides {
            get => (float)parameterBlock[EParams.Sides].Value;
            set { parameterBlock[EParams.Sides].Value = value; }
        }
        public float Capsegs {
            get => (float)parameterBlock[EParams.Capsegs].Value;
            set { parameterBlock[EParams.Capsegs].Value = value; }
        }
        public float Heightsegs {
            get => (float)parameterBlock[EParams.Heightsegs].Value;
            set { parameterBlock[EParams.Heightsegs].Value = value; }
        }
        public float Smooth {
            get => (float)parameterBlock[EParams.Smooth].Value;
            set { parameterBlock[EParams.Smooth].Value = value; }
        }
        public float Slice {
            get => (float)parameterBlock[EParams.Slice].Value;
            set { parameterBlock[EParams.Slice].Value = value; }
        }
        public float Slicefrom {
            get => (float)parameterBlock[EParams.Slicefrom].Value;
            set { parameterBlock[EParams.Slicefrom].Value = value; }
        }
        public float Sliceto {
            get => (float)parameterBlock[EParams.Sliceto].Value;
            set { parameterBlock[EParams.Sliceto].Value = value; }
        }
        public float Mapcoords {
            get => (float)parameterBlock[EParams.Mapcoords].Value;
            set { parameterBlock[EParams.Mapcoords].Value = value; }
        }
    }
    public class PPointHelper : SceneObject {
        public PPointHelper(SceneObject x) : base(x._Object) { _Node = x._Node; }
        public float Size {
            get => (float)parameterBlock[EParams.Size].Value;
            set { parameterBlock[EParams.Size].Value = value; }
        }
        public float Centermarker {
            get => (float)parameterBlock[EParams.Centermarker].Value;
            set { parameterBlock[EParams.Centermarker].Value = value; }
        }
        public float Axistripod {
            get => (float)parameterBlock[EParams.Axistripod].Value;
            set { parameterBlock[EParams.Axistripod].Value = value; }
        }
        public float Cross {
            get => (float)parameterBlock[EParams.Cross].Value;
            set { parameterBlock[EParams.Cross].Value = value; }
        }
        public float Box {
            get => (float)parameterBlock[EParams.Box].Value;
            set { parameterBlock[EParams.Box].Value = value; }
        }
        public float Constantscreensize {
            get => (float)parameterBlock[EParams.Constantscreensize].Value;
            set { parameterBlock[EParams.Constantscreensize].Value = value; }
        }
        public float Drawontop {
            get => (float)parameterBlock[EParams.Drawontop].Value;
            set { parameterBlock[EParams.Drawontop].Value = value; }
        }
    }
    public class PCircle : SceneObject {
        public PCircle(SceneObject x) : base(x._Object) { _Node = x._Node; }
        public float Render_thickness {
            get => (float)parameterBlock[EParams.Render_thickness].Value;
            set { parameterBlock[EParams.Render_thickness].Value = value; }
        }
        public float Render_sides {
            get => (float)parameterBlock[EParams.Render_sides].Value;
            set { parameterBlock[EParams.Render_sides].Value = value; }
        }
        public float Render_angle {
            get => (float)parameterBlock[EParams.Render_angle].Value;
            set { parameterBlock[EParams.Render_angle].Value = value; }
        }
        public float Render_width {
            get => (float)parameterBlock[EParams.Render_width].Value;
            set { parameterBlock[EParams.Render_width].Value = value; }
        }
        public float Render_length {
            get => (float)parameterBlock[EParams.Render_length].Value;
            set { parameterBlock[EParams.Render_length].Value = value; }
        }
        public float Render_angle2 {
            get => (float)parameterBlock[EParams.Render_angle2].Value;
            set { parameterBlock[EParams.Render_angle2].Value = value; }
        }
        public float Render_threshold {
            get => (float)parameterBlock[EParams.Render_threshold].Value;
            set { parameterBlock[EParams.Render_threshold].Value = value; }
        }
    }
    public class PEllipse : SceneObject {
        public PEllipse(SceneObject x) : base(x._Object) { _Node = x._Node; }
        public float Length {
            get => (float)parameterBlock[EParams.Length].Value;
            set { parameterBlock[EParams.Length].Value = value; }
        }
        public float Width {
            get => (float)parameterBlock[EParams.Width].Value;
            set { parameterBlock[EParams.Width].Value = value; }
        }
        public float Ellipse_thickness {
            get => (float)parameterBlock[EParams.Ellipse_thickness].Value;
            set { parameterBlock[EParams.Ellipse_thickness].Value = value; }
        }
        public float Ellipse_outline {
            get => (float)parameterBlock[EParams.Ellipse_outline].Value;
            set { parameterBlock[EParams.Ellipse_outline].Value = value; }
        }
    }
    public class PHelix : SceneObject {
        public PHelix(SceneObject x) : base(x._Object) { _Node = x._Node; }
        public float Render_thickness {
            get => (float)parameterBlock[EParams.Render_thickness].Value;
            set { parameterBlock[EParams.Render_thickness].Value = value; }
        }
        public float Render_sides {
            get => (float)parameterBlock[EParams.Render_sides].Value;
            set { parameterBlock[EParams.Render_sides].Value = value; }
        }
        public float Render_angle {
            get => (float)parameterBlock[EParams.Render_angle].Value;
            set { parameterBlock[EParams.Render_angle].Value = value; }
        }
        public float Render_width {
            get => (float)parameterBlock[EParams.Render_width].Value;
            set { parameterBlock[EParams.Render_width].Value = value; }
        }
        public float Render_length {
            get => (float)parameterBlock[EParams.Render_length].Value;
            set { parameterBlock[EParams.Render_length].Value = value; }
        }
        public float Render_angle2 {
            get => (float)parameterBlock[EParams.Render_angle2].Value;
            set { parameterBlock[EParams.Render_angle2].Value = value; }
        }
        public float Render_threshold {
            get => (float)parameterBlock[EParams.Render_threshold].Value;
            set { parameterBlock[EParams.Render_threshold].Value = value; }
        }
    }
    public class PLinearShape : SceneObject {
        public PLinearShape(SceneObject x) : base(x._Object) { _Node = x._Node; }
        public float Render_thickness {
            get => (float)parameterBlock[EParams.Render_thickness].Value;
            set { parameterBlock[EParams.Render_thickness].Value = value; }
        }
        public float Render_sides {
            get => (float)parameterBlock[EParams.Render_sides].Value;
            set { parameterBlock[EParams.Render_sides].Value = value; }
        }
        public float Render_angle {
            get => (float)parameterBlock[EParams.Render_angle].Value;
            set { parameterBlock[EParams.Render_angle].Value = value; }
        }
        public float Render_width {
            get => (float)parameterBlock[EParams.Render_width].Value;
            set { parameterBlock[EParams.Render_width].Value = value; }
        }
        public float Render_length {
            get => (float)parameterBlock[EParams.Render_length].Value;
            set { parameterBlock[EParams.Render_length].Value = value; }
        }
        public float Render_angle2 {
            get => (float)parameterBlock[EParams.Render_angle2].Value;
            set { parameterBlock[EParams.Render_angle2].Value = value; }
        }
        public float Render_threshold {
            get => (float)parameterBlock[EParams.Render_threshold].Value;
            set { parameterBlock[EParams.Render_threshold].Value = value; }
        }
    }
    public class PNGon : SceneObject {
        public PNGon(SceneObject x) : base(x._Object) { _Node = x._Node; }
        public float Render_thickness {
            get => (float)parameterBlock[EParams.Render_thickness].Value;
            set { parameterBlock[EParams.Render_thickness].Value = value; }
        }
        public float Render_sides {
            get => (float)parameterBlock[EParams.Render_sides].Value;
            set { parameterBlock[EParams.Render_sides].Value = value; }
        }
        public float Render_angle {
            get => (float)parameterBlock[EParams.Render_angle].Value;
            set { parameterBlock[EParams.Render_angle].Value = value; }
        }
        public float Render_width {
            get => (float)parameterBlock[EParams.Render_width].Value;
            set { parameterBlock[EParams.Render_width].Value = value; }
        }
        public float Render_length {
            get => (float)parameterBlock[EParams.Render_length].Value;
            set { parameterBlock[EParams.Render_length].Value = value; }
        }
        public float Render_angle2 {
            get => (float)parameterBlock[EParams.Render_angle2].Value;
            set { parameterBlock[EParams.Render_angle2].Value = value; }
        }
        public float Render_threshold {
            get => (float)parameterBlock[EParams.Render_threshold].Value;
            set { parameterBlock[EParams.Render_threshold].Value = value; }
        }
    }
    public class PRectangle : SceneObject {
        public PRectangle(SceneObject x) : base(x._Object) { _Node = x._Node; }
        public float Render_thickness {
            get => (float)parameterBlock[EParams.Render_thickness].Value;
            set { parameterBlock[EParams.Render_thickness].Value = value; }
        }
        public float Render_sides {
            get => (float)parameterBlock[EParams.Render_sides].Value;
            set { parameterBlock[EParams.Render_sides].Value = value; }
        }
        public float Render_angle {
            get => (float)parameterBlock[EParams.Render_angle].Value;
            set { parameterBlock[EParams.Render_angle].Value = value; }
        }
        public float Render_width {
            get => (float)parameterBlock[EParams.Render_width].Value;
            set { parameterBlock[EParams.Render_width].Value = value; }
        }
        public float Render_length {
            get => (float)parameterBlock[EParams.Render_length].Value;
            set { parameterBlock[EParams.Render_length].Value = value; }
        }
        public float Render_angle2 {
            get => (float)parameterBlock[EParams.Render_angle2].Value;
            set { parameterBlock[EParams.Render_angle2].Value = value; }
        }
        public float Render_threshold {
            get => (float)parameterBlock[EParams.Render_threshold].Value;
            set { parameterBlock[EParams.Render_threshold].Value = value; }
        }
    }
    public class PFreeCamera : SceneObject {
        public PFreeCamera(SceneObject x) : base(x._Object) { _Node = x._Node; }
        public float Fov {
            get => (float)parameterBlock[EParams.Fov].Value;
            set { parameterBlock[EParams.Fov].Value = value; }
        }
        public float Targetdistance {
            get => (float)parameterBlock[EParams.Targetdistance].Value;
            set { parameterBlock[EParams.Targetdistance].Value = value; }
        }
        public float Nearclip {
            get => (float)parameterBlock[EParams.Nearclip].Value;
            set { parameterBlock[EParams.Nearclip].Value = value; }
        }
        public float Farclip {
            get => (float)parameterBlock[EParams.Farclip].Value;
            set { parameterBlock[EParams.Farclip].Value = value; }
        }
        public float Nearenvrange {
            get => (float)parameterBlock[EParams.Nearenvrange].Value;
            set { parameterBlock[EParams.Nearenvrange].Value = value; }
        }
        public float Farenvrange {
            get => (float)parameterBlock[EParams.Farenvrange].Value;
            set { parameterBlock[EParams.Farenvrange].Value = value; }
        }
        public float Multipasseffectenabled {
            get => (float)parameterBlock[EParams.Multipasseffectenabled].Value;
            set { parameterBlock[EParams.Multipasseffectenabled].Value = value; }
        }
        public float Mpeffect_rendereffectsperpass {
            get => (float)parameterBlock[EParams.Mpeffect_rendereffectsperpass].Value;
            set { parameterBlock[EParams.Mpeffect_rendereffectsperpass].Value = value; }
        }
        public float Fovtype {
            get => (float)parameterBlock[EParams.Fovtype].Value;
            set { parameterBlock[EParams.Fovtype].Value = value; }
        }
    }
    public class PTargetCamera : SceneObject {
        public PTargetCamera(SceneObject x) : base(x._Object) { _Node = x._Node; }
        public float Fov {
            get => (float)parameterBlock[EParams.Fov].Value;
            set { parameterBlock[EParams.Fov].Value = value; }
        }
        public float Targetdistance {
            get => (float)parameterBlock[EParams.Targetdistance].Value;
            set { parameterBlock[EParams.Targetdistance].Value = value; }
        }
        public float Nearclip {
            get => (float)parameterBlock[EParams.Nearclip].Value;
            set { parameterBlock[EParams.Nearclip].Value = value; }
        }
        public float Farclip {
            get => (float)parameterBlock[EParams.Farclip].Value;
            set { parameterBlock[EParams.Farclip].Value = value; }
        }
        public float Nearenvrange {
            get => (float)parameterBlock[EParams.Nearenvrange].Value;
            set { parameterBlock[EParams.Nearenvrange].Value = value; }
        }
        public float Farenvrange {
            get => (float)parameterBlock[EParams.Farenvrange].Value;
            set { parameterBlock[EParams.Farenvrange].Value = value; }
        }
        public float Multipasseffectenabled {
            get => (float)parameterBlock[EParams.Multipasseffectenabled].Value;
            set { parameterBlock[EParams.Multipasseffectenabled].Value = value; }
        }
        public float Mpeffect_rendereffectsperpass {
            get => (float)parameterBlock[EParams.Mpeffect_rendereffectsperpass].Value;
            set { parameterBlock[EParams.Mpeffect_rendereffectsperpass].Value = value; }
        }
        public float Fovtype {
            get => (float)parameterBlock[EParams.Fovtype].Value;
            set { parameterBlock[EParams.Fovtype].Value = value; }
        }
    }
    public class POmniLight : SceneObject {
        public POmniLight(SceneObject x) : base(x._Object) { _Node = x._Node; }
        public float Color {
            get => (float)parameterBlock[EParams.Color].Value;
            set { parameterBlock[EParams.Color].Value = value; }
        }
        public float Multiplier {
            get => (float)parameterBlock[EParams.Multiplier].Value;
            set { parameterBlock[EParams.Multiplier].Value = value; }
        }
        public float Contrast {
            get => (float)parameterBlock[EParams.Contrast].Value;
            set { parameterBlock[EParams.Contrast].Value = value; }
        }
        public float Diffusesoften {
            get => (float)parameterBlock[EParams.Diffusesoften].Value;
            set { parameterBlock[EParams.Diffusesoften].Value = value; }
        }
        public float Attenuationnearstart {
            get => (float)parameterBlock[EParams.Attenuationnearstart].Value;
            set { parameterBlock[EParams.Attenuationnearstart].Value = value; }
        }
        public float Attenuationnearend {
            get => (float)parameterBlock[EParams.Attenuationnearend].Value;
            set { parameterBlock[EParams.Attenuationnearend].Value = value; }
        }
        public float Attenuationfarstart {
            get => (float)parameterBlock[EParams.Attenuationfarstart].Value;
            set { parameterBlock[EParams.Attenuationfarstart].Value = value; }
        }
        public float Attenuationfarend {
            get => (float)parameterBlock[EParams.Attenuationfarend].Value;
            set { parameterBlock[EParams.Attenuationfarend].Value = value; }
        }
        public float Decayfalloff {
            get => (float)parameterBlock[EParams.Decayfalloff].Value;
            set { parameterBlock[EParams.Decayfalloff].Value = value; }
        }
        public float Shadowcolor {
            get => (float)parameterBlock[EParams.Shadowcolor].Value;
            set { parameterBlock[EParams.Shadowcolor].Value = value; }
        }
        public float Atmosphereopacity {
            get => (float)parameterBlock[EParams.Atmosphereopacity].Value;
            set { parameterBlock[EParams.Atmosphereopacity].Value = value; }
        }
        public float Atmospherecoloramount {
            get => (float)parameterBlock[EParams.Atmospherecoloramount].Value;
            set { parameterBlock[EParams.Atmospherecoloramount].Value = value; }
        }
        public float Shadowdensity {
            get => (float)parameterBlock[EParams.Shadowdensity].Value;
            set { parameterBlock[EParams.Shadowdensity].Value = value; }
        }
    }
    public class PTargetSpot : SceneObject {
        public PTargetSpot(SceneObject x) : base(x._Object) { _Node = x._Node; }
        public float Color {
            get => (float)parameterBlock[EParams.Color].Value;
            set { parameterBlock[EParams.Color].Value = value; }
        }
        public float Multiplier {
            get => (float)parameterBlock[EParams.Multiplier].Value;
            set { parameterBlock[EParams.Multiplier].Value = value; }
        }
        public float Contrast {
            get => (float)parameterBlock[EParams.Contrast].Value;
            set { parameterBlock[EParams.Contrast].Value = value; }
        }
        public float Diffusesoften {
            get => (float)parameterBlock[EParams.Diffusesoften].Value;
            set { parameterBlock[EParams.Diffusesoften].Value = value; }
        }
        public float Hotspot {
            get => (float)parameterBlock[EParams.Hotspot].Value;
            set { parameterBlock[EParams.Hotspot].Value = value; }
        }
        public float Falloff {
            get => (float)parameterBlock[EParams.Falloff].Value;
            set { parameterBlock[EParams.Falloff].Value = value; }
        }
        public float Aspectratio {
            get => (float)parameterBlock[EParams.Aspectratio].Value;
            set { parameterBlock[EParams.Aspectratio].Value = value; }
        }
        public float Attenuationnearstart {
            get => (float)parameterBlock[EParams.Attenuationnearstart].Value;
            set { parameterBlock[EParams.Attenuationnearstart].Value = value; }
        }
        public float Attenuationnearend {
            get => (float)parameterBlock[EParams.Attenuationnearend].Value;
            set { parameterBlock[EParams.Attenuationnearend].Value = value; }
        }
        public float Attenuationfarstart {
            get => (float)parameterBlock[EParams.Attenuationfarstart].Value;
            set { parameterBlock[EParams.Attenuationfarstart].Value = value; }
        }
        public float Attenuationfarend {
            get => (float)parameterBlock[EParams.Attenuationfarend].Value;
            set { parameterBlock[EParams.Attenuationfarend].Value = value; }
        }
        public float Decayfalloff {
            get => (float)parameterBlock[EParams.Decayfalloff].Value;
            set { parameterBlock[EParams.Decayfalloff].Value = value; }
        }
        public float Shadowcolor {
            get => (float)parameterBlock[EParams.Shadowcolor].Value;
            set { parameterBlock[EParams.Shadowcolor].Value = value; }
        }
        public float Atmosphereopacity {
            get => (float)parameterBlock[EParams.Atmosphereopacity].Value;
            set { parameterBlock[EParams.Atmosphereopacity].Value = value; }
        }
        public float Atmospherecoloramount {
            get => (float)parameterBlock[EParams.Atmospherecoloramount].Value;
            set { parameterBlock[EParams.Atmospherecoloramount].Value = value; }
        }
        public float Shadowdensity {
            get => (float)parameterBlock[EParams.Shadowdensity].Value;
            set { parameterBlock[EParams.Shadowdensity].Value = value; }
        }
    }
    public class PTorus : SceneObject {
        public PTorus(SceneObject x) : base(x._Object) { _Node = x._Node; }
        public float Radius1 {
            get => (float)parameterBlock[EParams.Radius1].Value;
            set { parameterBlock[EParams.Radius1].Value = value; }
        }
        public float Radius2 {
            get => (float)parameterBlock[EParams.Radius2].Value;
            set { parameterBlock[EParams.Radius2].Value = value; }
        }
        public float Tuberotation {
            get => (float)parameterBlock[EParams.Tuberotation].Value;
            set { parameterBlock[EParams.Tuberotation].Value = value; }
        }
        public float Tubetwist {
            get => (float)parameterBlock[EParams.Tubetwist].Value;
            set { parameterBlock[EParams.Tubetwist].Value = value; }
        }
        public float Segs {
            get => (float)parameterBlock[EParams.Segs].Value;
            set { parameterBlock[EParams.Segs].Value = value; }
        }
        public float Sides {
            get => (float)parameterBlock[EParams.Sides].Value;
            set { parameterBlock[EParams.Sides].Value = value; }
        }
        public float Smooth {
            get => (float)parameterBlock[EParams.Smooth].Value;
            set { parameterBlock[EParams.Smooth].Value = value; }
        }
        public float Slice {
            get => (float)parameterBlock[EParams.Slice].Value;
            set { parameterBlock[EParams.Slice].Value = value; }
        }
        public float Sliceto {
            get => (float)parameterBlock[EParams.Sliceto].Value;
            set { parameterBlock[EParams.Sliceto].Value = value; }
        }
        public float Slicefrom {
            get => (float)parameterBlock[EParams.Slicefrom].Value;
            set { parameterBlock[EParams.Slicefrom].Value = value; }
        }
        public float Mapcoords {
            get => (float)parameterBlock[EParams.Mapcoords].Value;
            set { parameterBlock[EParams.Mapcoords].Value = value; }
        }
    }
}
