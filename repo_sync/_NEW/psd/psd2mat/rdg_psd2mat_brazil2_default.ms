struct theRenderer (
 theName = "Brazil r/s v2",
 theMaps = #("bmtl_Cs_map", "bmtl_Os_map", "bmtl_xtra_light_map", "bmtl_Ld_map", "bmtl_bump_map", "bmtl_disp_map", "bmtl_env_map", "texmapmgr.ambient.tms_map","texmapmgr.Luminosity.tms_map","texmapmgr.Ka.tms_map","texmapmgr.Kd.tms_map","texmapmgr.Kl.tms_map","texmapmgr.Reflectivity.tms_map","texmapmgr.Reflection_Tint.tms_map","texmapmgr.Kr.tms_map","texmapmgr.IOR.tms_map","texmapmgr.Specular_Color.tms_map","texmapmgr.Spec__Level.tms_map","texmapmgr.Spec__Gloss.tms_map","texmapmgr.Soften.tms_map","texmapmgr.Gain.tms_map"),
 theMapNames = #("Color (Cs)", "Opacity (Os)", "Extra Light", "Diffusion", "Bump", "Displacement", "Environment", "Ambient","Luminosity","Ka","Kd","Kl","Reflectivity","Reflection Tint","Kr","IOR","Specular Color","Spec Level","Spec Gloss","Soften","Gain"),
 theTests = #("(Cs)", "(Os)", "extra light", "Diff", "Bump", "displ", "environ", "amb", "Lumin","Ka","Kd","Kl","Reflectivity","Reflection Tint","Kr","IOR","Specular","Spec Level","Spec Gloss","Soften","Gain"),
 theMatFunc = Brazil2_Advanced_Material
)
rdg_renderOptions = theRenderer()
print "rdg::PSD2Mat: Brazil r/s v2 settings loaded."
