Skriptovatelnost

LS3D LOD Utlity je skriptovatelna pres inteface LS3DGUP.LODU od revize 57011)
Interface

showinterface LS3DGUP.LODU
  Interface: LODU
   Properties:
   Methods:
    CreateSet()
    CreateSetEnabled()
    AddToSet()
    AddNodesToSet Nodes
    AddToSetEnabled()
    RemoveFromSet()
    RemoveFromSetEnabled()
    GetNumLODs()
    SetSelectedLOD Index
    GetSelectedLOD()
    SelectFirstLOD()
    SelectLastLOD()
    SelectPreviousLOD()
    SelectNextLOD()
    MakeVisible()
    IsVisible()
    SetInfinite Infinite
    IsInfinite()
    GetDistance()
    SetDistance Distance
    GetStrategy()
       GetStrategy enums: {#bbox|#pivot
    SetStrategy Strategy
       Strategy enums: {#bbox|#pivot}
   Actions:
OK

Priklad

-- Illusion Softworks
-- http://www.illusionsoftworks.com
-- Copyright (c) 2004-2006 Illusion Softworks. All Rights Reserved
--
-- toto je ukazkovy skript jak je mozne vyuzit maxscriptove rozhrani k LS3D LOD Utility
-- detaily o rozhrani je mozne ziskat zavolanim 
-- 
-- showinterface LS3DGUP.LODU 
--

-- vycisteni pro nekolikanasobne spousteni
delete $Test*

-- vytvorim si nekolik pracovnich objektu
s = sphere()
s.name = "TestSphere"
s.pos = [-50,0,0]

b = box()
b.name = "TestBox"

t = teapot()
t.name = "TestTeapot"
t.pos = [50,0,0]

messagebox "Vytvoril jsem jednoduchou scenu\n\nTed dam objekty do groupy ..."

-- vytvorim skupinu z objektu
g = group $Test* name:"TestGroup" select:true

messagebox "Groupa vytvorena\n\nTed groupu prohlasim za LODovaci skupinu  ..."

-- skupina je selectnuta, 
-- pokusim se vytvorit lodovaci skupinu z groupy
LS3DGUP.LODU.CreateSet()

messagebox "Vyborne!\n\nTed vykopnu prvni LOD (teapot) ven z LODovaci skupiny ..."

-- oddelam teapot z lodovaci skupiny (ale zustane v groupe)
LS3DGUP.LODU.SelectFirstLOD()
LS3DGUP.LODU.RemoveFromSet()

messagebox "Fajn!\n\nTed se tam ten teapot zase vratim ..."
LS3DGUP.LODU.AddNodesToSet $TestTeapot -- poznamka: umi vzit pole nodu a kazdy prvek zkusi pridat k lodovaci skupine

messagebox "ok!\n\nTed prepnu zobrazeni na 3. LOD ..."
LS3DGUP.LODU.SetSelectedLOD(2)
LS3DGUP.LODU.MakeVisible()

messagebox "ok!\n\nTed prepnu zobrazeni na 2. LOD ..."
LS3DGUP.LODU.SetSelectedLOD(1)
LS3DGUP.LODU.MakeVisible()

messagebox "ok!\n\nNastavim distance u 2. LODu na 50m ..."
LS3DGUP.LODU.SetDistance(50)

messagebox ("ok!\n\nDistance nastavena na "+(LS3DGUP.LODU.GetDistance() as string))

-- protoze se mi nutne prenastavila i distance na prvnim lodu
-- zeptam se prvniho lodu jestli je v nekonecnu
LS3DGUP.LODU.SetSelectedLOD(0)
messagebox ("ok!\n\nInfinite 1.LODu je "+(LS3DGUP.LODU.IsInfinite() as string))
LS3DGUP.LODU.SetSelectedLOD(2)
messagebox ("ok!\n\nInfinite 3.LODu je "+(LS3DGUP.LODU.IsInfinite() as string))

-- a to je vse pratele

