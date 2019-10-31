/*HeaderStart******************************************************************************
:Created By: Manu Pratap
:Company: Dhruva Infotech.
:Site: http://dhruva.com
:E-mail: mpspanwar@yahoo.co.in
©manupratap
:Script Name: [UV_Normalizer]

:Purpose:
This script is written to find out the Texel Density, Area of Geometry and Area used by the Pixels in UV layout
and normalize them according to a chunk-texel density or cluster-texel density.
NOTE:- How to use it?
-->If Mesh Dimension groupbox has some value on it then it will find the texel density according to mesh area
and if mesh dimension is on '0' then it will get the texel density according to selected chunk of uv.
-->Default dimension is set on metres.
--->It will work in every unit set-up of 3ds Max and as user will change the unit set-up, the unit for script will change automatically.

:History:

:Todo:

:Bugs:

:Tests:

*****************************************************************************HeaderEnd*/

--Let's create a function to acknowledge Texel Density
fn GetTexelDensity mTexW mTexH =
(
--Check the Modifier Class whether it is unwrap_uvw or not
if classof (unwrapmod = modpanel.getcurrentobject()) == unwrap_uvw do
(
--Make an array of selected Faces
if (faces = unwrapmod.getselectedfaces()).count > 0 do
(
-- Get some information about the selection
unwrapmod.getarea faces &mX &mY &mWidth &mHeight &mAreaUVW &mAreaGeom

-- Calculate the total texture area
textureArea = mTexW * mTexH

-- Calculate the used area
usedAreaPixels = mAreaUVW * textureArea

-- Calculate the texel density
texelDensity = sqrt (usedAreaPixels/mAreaGeom)
-- break()
)
)
texelDensity
)

try(destroyDialog rol_UVNormalizer)catch()

--Creating the Rollout
rollout rol_UVNormalizer "UV Normalizer" width:222 height:155
(
--defining local variables
local theTexDen
local theTexDenCluster
local theWidth,theHeight = 0.0
local theAxisX,theAxisY
local theTextureMapArea,theGeomArea,theUsedAreaPixels,theDefinedRatio
local texelDensity = undefined

-- Buttons and Group for Mesh Dimension
groupBox theMeshSize "Mesh Dimension" pos:[6,7] width:114 height:70 --main groupbox
spinner spnGrowSelectionWidth "Width:" range:[0,10000,0] pos:[27,24] width:88 height:16 type:#worldunits scale:0.1
spinner spnGrowSelectionHeight "Height:" range:[0,10000,0] pos:[25,52] width:90 height:16 type:#worldunits scale:0.1
--------------------------------------------------------------------------------------------------------------------------------------------------------

--Buttons and Group for Map Dimension
groupBox theMapSize "Map Dimension" pos:[125,7] width:90 height:70 --main groupbox
spinner spnGrowSelectionAxisX " U:" range:[0,8192,512] pos:[136,24] width:74 height:16 type:#integer scale:128
spinner spnGrowSelectionAxisY " V:" range:[0,8192,512] pos:[136,52] width:74 height:16 type:#integer scale: 128
----------------------------------------------------------------------------------------------------------------------------------------------------------

--Buttons and Group for Texel Densitizer
groupbox theTexelDensitizer "Texel Densitizer" pos:[6,80] width:209 height:70
button btn_getTexelDensity "Get Texel Density" pos:[12,95] width:95 height:25
button btn_setTexelDensity "Set Texel Density" pos:[115,95] width:95 height:25
edittext the_TexDen "" pos:[9,125] fieldWidth:94 height:17 readOnly:true text:"" bold:true
edittext the_TexDenCluster "" pos:[111,125] fieldWidth:94 height:17 readOnly:true text:"" bold:true
----------------------------------------------------------------------------------------------------------------------------------------------------------

on spnGrowSelectionWidth changed val do theWidth = val

on spnGrowSelectionHeight changed val do theHeight = val

on spnGrowSelectionAxisX changed val do theAxisX = val

on spnGrowSelectionAxisY changed val do theAxisY = val

on rol_UVNormalizer open do
(
theWidth = spnGrowSelectionWidth.value
theHeight = spnGrowSelectionHeight.value
theAxisX = spnGrowSelectionAxisX.value
theAxisY = spnGrowSelectionAxisY.value
)

--button get texel density
on btn_getTexelDensity pressed do
(
if theWidth > 0.0 or theHeight > 0.0 then
(
-- Finding the Ratio between geometry pixels and uvw pixels
if theWidth >= theHeight then
theRatioWH = (theWidth/theHeight) as float
else theRatioWH = (theHeight/theWidth) as float

--Creating the Formulae to know Texel Density
theTextureMapArea = (theAxisX * theAxisY)
theGeomArea = (theWidth * theHeight)
theUsedAreaPixels = (theTextureMapArea / theRatioWH)
texelDensity = sqrt (theUsedAreaPixels / theGeomArea)

--Result of Formulae
format "Texel Density: %\nArea of Geometry: %\n" texelDensity theGeomArea
format "Pixels used by Area in UV Space: %\n" theUsedAreaPixels

-- print texelDensity
the_TexDen.text = "" + texelDensity as string
)

else
(
-- Calculate the Texel Density for the given texture size
texelDensity = GetTexelDensity theAxisX theAxisY

--Show the Texel Density in Listener Window
format "Texel Density: %\n" texelDensity

--giving new Variable for texel density
-- print texelDensity_fab
the_TexDen.text = "" + texelDensity as string
)
)
--end of get texel density script

--button Normalize
on btn_setTexelDensity pressed do
(
if texelDensity != undefined then
(
if modpanel.getcurrentobject() != undefined and classof (modpanel.getcurrentobject()) == Unwrap_UVW then
(
----it will rescale the cluster to equalize the texel density
actionMan.executeAction 2077580866 "40207"

-- In this short script 'c' is defining the cluster
texelDensityCluster = GetTexelDensity theAxisX theAxisY
format "Texel Density Cluster: %\n" texelDensityCluster

-- print texelDensityCluster
the_TexDenCluster.text = "" + texelDensity as string

--it will acknowledge the texel density of cluster so we can define the ratio
--getting the ratio between single face and cluster
theDefinedRatio=(texelDensity/texelDensityCluster)
theUnwrapmod = modpanel.getcurrentobject()
theUnwrapmod.scaleSelectedCenter theDefinedRatio 0
)else messagebox "Please select a object with Unwrap UVW modifier applied to it."
)
else messagebox "Please get texel density first."

--end of Normalization
)
----end of Normalize Script

)
--end of full script

createDialog rol_UVNormalizer
--end of rollout