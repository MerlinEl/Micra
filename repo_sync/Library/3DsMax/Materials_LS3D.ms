
----if classof material == ls3dmaterial !!!!!!!



"10_zidka02.xml"
newGuid = "0x6d0b4a54, 0x4ba026b3"

oldGuid = sceneMaterials["chram"].ls3d.GetGUID()
sceneMaterials["chram"].ls3d.GetName()

sceneMaterials["chram"].ls3d.ClearBindings()
sceneMaterials["chram"].ls3d.SetGUID oldGuid
sceneMaterials["chram"].ls3d.GuessBindings()
sceneMaterials["chram"].ls3d.Synchronize()


"missions/m09_exhibition_place/09_chram_all_ac.xml"

meditMaterials[1]=sceneMaterials["chram"]
meditMaterials[1]=standard()

09_zlutej_korunka_ac_da.dds


  Interface: ls3d
   Properties:
   Methods:
    <bool>Synchronize()
    <bool>GuessBindings()
    <bool>ClearBindings()
    <bool>Switch()
    <string>GetGUID()
    <bool>SetGUID <string>GUID
    <string>GetName()
    <string>GetDescription()
    <bool>SetDescription <string>Description
    <string>GetTexturePath <integer>index
    <integer>GetTextureCount()
   Actions:
   
   
   
newGuid = "0x6d0b4a54, 0x4ba026b3"
oldGuid = sceneMaterials["Material #43057"][1].ls3d.GetGUID()
sceneMaterials["Material #43057"][1].SetGUID newGuid
sceneMaterials["Material #43057"][1].ls3d.Synchronize()
"Material #43057"
meditMaterials[1]= sceneMaterials["inter"] 
sceneMaterials["inter"][3].SetGUID newGuid