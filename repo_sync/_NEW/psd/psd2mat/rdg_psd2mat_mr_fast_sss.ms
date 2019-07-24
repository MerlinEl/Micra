struct theRenderer (
 theName = "Mental Ray (SSS Fast)",
 theMaps = #("bump.map", "'ambient.shader'", "'overall_color.shader'", "'diffuse_color.shader'", "'diffuse_weight.shader'", "'front_sss_color.shader'", "'front_sss_weight.shader'", "'front_sss_radius.shader'", "'back_sss_color.shader'", "'back_sss_weight.shader'", "'back_sss_radius.shader'", "'back_sss_depth.shader'", "'specular.shader'", "'exponent.shader'", "'scale_conversion.shader'", "'falloff.shader'"),
 theMapNames = #("Bump", "Ambient", "Overall Diffuse Color", "Unscattered Diffuse Color", "Unscattered Diffuse Weight", "Front Surface Scatter Color", "Front Surface Scatter Weight", "Front Surface Scatter Radius", "Back Surface Scatter Color", "Back Surface Scatter Weight", "Back Surface Scatter Radius", "Back Surface Scatter Depth", "Specular Color", "Shininess", "Scale Conversion Falloff", "Falloff Strenght"),
 theTests = #("Bump", "Ambient", "Overall Diffuse Color", "Unscattered Diffuse Color", "Unscattered Diffuse Weight", "Front Surface Scatter Color", "Front Surface Scatter Weight", "Front Surface Scatter Radius", "Back Surface Scatter Color", "Back Surface Scatter Weight", "Back Surface Scatter Radius", "Back Surface Scatter Depth", "Specular Color", "Shininess", "Scale Conversion Falloff", "Falloff Strenght"),
 theMatFunc = SSS_Fast_Material__mi
)
rdg_renderOptions = theRenderer()
print "rdg::PSD2Mat: MR SSS Fast loaded."

