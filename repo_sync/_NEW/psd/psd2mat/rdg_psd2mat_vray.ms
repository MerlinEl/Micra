struct theRenderer (
 theName = "VRay",
 theMaps = #("texmap_diffuse", "texmap_reflection", "texmap_hilightGlossiness", "texmap_reflectionGlossiness", "texmap_reflectionIOR", "texmap_refraction", "texmap_refractionGlossiness", "texmap_refractionIOR", "texmap_translucent", "texmap_bump", "texmap_displacement" ,"texmap_opacity", "texmap_environment"),
 theMapNames = #("Diffuse", "Reflect", "HGlossiness", "RGlossiness", "Fresnel IOR", "Refract", "Glossiness", "IOR", "Translucent", "Bump", "Displace", "Opacity", "Environment"),
 theTests = #("diff", "refl", "hgloss", "rgloss", "fresnel", "refr", "glossi", "ior", "trans", "bump", "displ", "opac", "env"),
 theMatFunc = VRayMtl
)
rdg_renderOptions = theRenderer()
print "rdg::PSD2Mat: vray settings loaded."
