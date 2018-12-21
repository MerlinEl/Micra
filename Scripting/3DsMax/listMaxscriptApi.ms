(
fn GatherMaxscriptKeyword =
    (
    out_script=newscript()
    n_stream=stringstream ""
    --//--
    afilter_black=#()
    afilter_blue1=#()
    afilter_blue2=#()
    afilter_Brown=#()
    afilter_Green=#()
    afilter_Gold=#()
    afilter_Red=#()
    afilter_Italic=#()
    --//--
    apropos "" to:n_stream
    seek n_stream 0
    --//--
    while not eof n_stream do
        (
        mtrim=(dotnetobject "system.string" (readLine n_stream)).Split "(" 
        --//--
        if mtrim.count > 1 then
            (
            xtype=(dotnetobject "system.string" mtrim[2]).split ")"
            --//--
            if xtype.count > 1 then
                (--redirect to the wanted array there ...
                appendvalstr=((dotnetobject "system.string" mtrim[1]).Split " ")[1]
                --//--
                case xtype[1] of
                    (
                    "<internal>":(appendifunique afilter_black appendvalstr)
                    "Array":(appendifunique afilter_black appendvalstr)
                    "BooleanClass":(appendifunique afilter_black appendvalstr)
                    "Float":(appendifunique afilter_black appendvalstr)
                    "Integer":(appendifunique afilter_black appendvalstr)
                    "MAXScriptFunction":(appendifunique afilter_black appendvalstr)
                    "MSCustAttribDef":(appendifunique afilter_black appendvalstr)
                    "MSPluginClass":(appendifunique afilter_black appendvalstr)
                    "Point2":(appendifunique afilter_black appendvalstr)
                    "Primitive":(appendifunique afilter_blue1 appendvalstr)
                    "RCMenu":(appendifunique afilter_black appendvalstr)
                    "RolloutClass":(appendifunique afilter_black appendvalstr)
                    "StandardMaterialClass":(appendifunique afilter_black appendvalstr)
                    "String":(appendifunique afilter_black appendvalstr)
                    "StructDef":(appendifunique afilter_Brown appendvalstr)
                    "TextureClass":(appendifunique afilter_black appendvalstr)
                    "UndefinedClass":(appendifunique afilter_black appendvalstr)
                    "const BipedGeneric":(appendifunique afilter_blue1 appendvalstr)
                    "const BooleanClass":(appendifunique afilter_Italic appendvalstr)
                    "const Class":(appendifunique afilter_blue2 appendvalstr)
                    "const Color":(appendifunique afilter_Italic appendvalstr)
                    "const CurveCtlGeneric":(appendifunique afilter_blue1 appendvalstr)
                    "const EmptyClass":(appendifunique afilter_Italic appendvalstr)
                    "const Float":(appendifunique afilter_Italic appendvalstr)
                    "const Generic":(appendifunique afilter_blue1 appendvalstr)
                    "const HKey":(appendifunique afilter_Italic appendvalstr)
                    "const Interface":(appendifunique afilter_Green appendvalstr)
                    "const MAXClass":(appendifunique afilter_blue2 appendvalstr)
                    "const MAXMeshClass":(appendifunique afilter_blue1 appendvalstr)
                    "const MAXScriptFunction":()--empty
                    "const MAXSuperClass":(appendifunique afilter_blue2 appendvalstr)
                    "const MappedGeneric":(appendifunique afilter_blue1 appendvalstr)
                    "const MappedPrimitive":(appendifunique afilter_blue1 appendvalstr)
                    "const MeditMaterialsClass":(appendifunique afilter_Italic appendvalstr)
                    "const NodeGeneric":(appendifunique afilter_blue1 appendvalstr)
                    "const ObjectSet":(appendifunique afilter_Gold appendvalstr)
                    "const OkClass":(appendifunique afilter_Italic appendvalstr)
                    "const Point3":(appendifunique afilter_Italic appendvalstr)
                    "const Primitive":(appendifunique afilter_blue1 appendvalstr)
                    "const Primitive":()--empty
                    "const SelectionSetArray":(appendifunique afilter_Italic appendvalstr)
                    "const StructDef":(appendifunique afilter_Brown appendvalstr)
                    "const UndefinedClass":(appendifunique afilter_Italic appendvalstr)
                    "const UnsuppliedClass":(appendifunique afilter_Italic appendvalstr)
                    "dotNetObject":(appendifunique afilter_black appendvalstr)
                    "persistent UndefinedClass":(appendifunique afilter_black appendvalstr)
                    "system Array":(appendifunique afilter_Red appendvalstr)
                    "system BooleanClass":(appendifunique afilter_Red appendvalstr)
                    "system Color":(appendifunique afilter_Red appendvalstr)
                    "system Control":(appendifunique afilter_Red appendvalstr)
                    "system Float":(appendifunique afilter_Red appendvalstr)
                    "system Integer":(appendifunique afilter_Red appendvalstr)
                    "system Integer64":(appendifunique afilter_Red appendvalstr)
                    "system Interval":(appendifunique afilter_Red appendvalstr)
                    "system MAXRootNode":(appendifunique afilter_Red appendvalstr)
                    "system MAXTVNode":(appendifunique afilter_Red appendvalstr)
                    "system MaterialLibrary":(appendifunique afilter_Red appendvalstr)
                    "system Name":(appendifunique afilter_Red appendvalstr)
                    "system String":(appendifunique afilter_Red appendvalstr)
                    "system Time":(appendifunique afilter_Red appendvalstr)
                    "system UndefinedClass":(appendifunique afilter_Red appendvalstr)
                    "system WindowStream":(appendifunique afilter_Red appendvalstr)
                    default:(messagebox "New Class found, Please update the main function." title:"Warning" beep:false)
                    --default:(format(xtype[1]+"\n")to:out_script)
                    )

                )

            )

        )
    --//--Black keyword
    sort afilter_black
    format ("-------------------------------------------------------------"+"\n") to:out_script
    format ("Black"+"\n") to:out_script
    format ("-------------------------------------------------------------"+"\n") to:out_script
    --//--
    for f in afilter_black do
        (
        evalstr=(dotnetobject "system.string" f).Split ("\""+"&"+"%")
        --//--
        if evalstr.count == 1 then
            (
            format (evalstr[1]+"\n") to:out_script
            )
        --//--
        )
    --//--blue1 keyword
    sort afilter_blue1
    format ("-------------------------------------------------------------"+"\n") to:out_script
    format ("Blue1"+"\n") to:out_script
    format ("-------------------------------------------------------------"+"\n") to:out_script
    --//--
    for f in afilter_blue1 do
        (
        evalstr=(dotnetobject "system.string" f).Split ("\""+"&"+"%")
        --//--
        if evalstr.count == 1 then
            (
            format (evalstr[1]+"\n") to:out_script
            )
        --//--
        )
    --//--blue2 keyword
    sort afilter_blue2
    format ("-------------------------------------------------------------"+"\n") to:out_script
    format ("Blue2"+"\n") to:out_script
    format ("-------------------------------------------------------------"+"\n") to:out_script
    --//--
    for f in afilter_blue2 do
        (
        evalstr=(dotnetobject "system.string" f).Split ("\""+"&"+"%")
        --//--
        if evalstr.count == 1 then
            (
            format (evalstr[1]+"\n") to:out_script
            )
        --//--
        )
    --//--Brown keyword
    sort afilter_Brown
    format ("-------------------------------------------------------------"+"\n") to:out_script
    format ("Brown"+"\n") to:out_script
    format ("-------------------------------------------------------------"+"\n") to:out_script
    --//--
    for f in afilter_Brown do
        (
        evalstr=(dotnetobject "system.string" f).Split ("\""+"&"+"%")
        --//--
        if evalstr.count == 1 then
            (
            format (evalstr[1]+"\n") to:out_script
            )
        --//--
        )
    --//--Green keyword
    sort afilter_Green
    format ("-------------------------------------------------------------"+"\n") to:out_script
    format ("Green"+"\n") to:out_script
    format ("-------------------------------------------------------------"+"\n") to:out_script
    --//--
    for f in afilter_Green do
        (
        evalstr=(dotnetobject "system.string" f).Split ("\""+"&"+"%")
        --//--
        if evalstr.count == 1 then
            (
            format (evalstr[1]+"\n") to:out_script
            )
        --//--
        )
    --//--Gold keyword
    sort afilter_Gold
    format ("-------------------------------------------------------------"+"\n") to:out_script
    format ("Gold"+"\n") to:out_script
    format ("-------------------------------------------------------------"+"\n") to:out_script
    --//--
    for f in afilter_Gold do
        (
        evalstr=(dotnetobject "system.string" f).Split ("\""+"&"+"%")
        --//--
        if evalstr.count == 1 then
            (
            format (evalstr[1]+"\n") to:out_script
            )
        --//--
        )
    --//--Red keyword
    sort afilter_Red
    format ("-------------------------------------------------------------"+"\n") to:out_script
    format ("Red"+"\n") to:out_script
    format ("-------------------------------------------------------------"+"\n") to:out_script
    --//--
    for f in afilter_Red do
        (
        evalstr=(dotnetobject "system.string" f).Split ("\""+"&"+"%")
        --//--
        if evalstr.count == 1 then
            (
            format (evalstr[1]+"\n") to:out_script
            )
        --//--
        )
    --//--Italic keyword
    sort afilter_Italic
    format ("-------------------------------------------------------------"+"\n") to:out_script
    format ("Italic"+"\n") to:out_script
    format ("-------------------------------------------------------------"+"\n") to:out_script
    --//--
    for f in afilter_Italic do
        (
        evalstr=(dotnetobject "system.string" f).Split ("\""+"&"+"%")
        --//--
        if evalstr.count == 1 then
            (
            format (evalstr[1]+"\n") to:out_script
            )
        --//--
        )

    )
--//--
GatherMaxscriptKeyword()
ok
)