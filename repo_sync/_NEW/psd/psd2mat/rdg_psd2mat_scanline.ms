struct theRenderer (
 theName = "Scanline",
 theMaps = #("ambientMap", "diffuseMap", "specularMap", "specularLevelMap", "glossinessMap", "selfIllumMap", "opacityMap", "filterMap", "bumpMap", "reflectionMap", "refractionMap", "displacementMap"),
 theMapNames = #("Ambient Color", "Diffuse Color", "Specular Color", "Specular Level", "Glossiness", "Self-Illumination", "Opacity", "Filter Color", "Bump", "Reflection", "Refraction", "Displacement"),
 theTests = #("amb", "diff", "specmap", "speclevel", "gloss", "self", "opac", "filter", "bump", "refl", "refr", "displ"),
 theMatFunc = Standard
)
 
rdg_renderOptions = theRenderer()
print "rdg::PSD2Mat: scanline settings loaded."
