--MacroScript GrabViewport category:"Tools" tooltip:"Grab Viewport"

(

---------------------------------------------------------------------

--GRABVIEWPORT MACROSCRIPT

--Created:3/23/99

--Edited:4/28/99

--by Borislav Petrov

--bobo@email.archlab.tuwien.ac.at

---------------------------------------------------------------------

--Snapshot Active Viewport to Bitmap

--Filename in format:

--VPGRAB_MaxFileName_ViewportName_CurentFrame.ImageFormatExtension

---------------------------------------------------------------------

--

--Init Variables

local grab_bmp --bitmap to put the snapshot into

local bmp_name --name of the bitmap to save

local get_viewport_name --viewport name

local gac,gct,mfn --variables to hold ActiveCamera, CurrentTime, MaxFileName

--

--Start Macro

grab_bmp = gw.getViewportDib() --get the viewport bitmap into variable

get_viewport_name = viewport.GetType() --get viewport name

gvn = get_viewport_name as string --convert viewport name to string

gvn = substring gvn 6 (gvn.count-5) --cut the string

if gvn == "camera" then --if the remaining string is "camera"

( 

gac = getActiveCamera() --get the camera

gvn = gac.name --get the name of the camera

)

mfn = MaxFileName --get max file name

if mfn == "" then --if there is no name

mfn = "Untitled" --use "Untitled"

else

mfn = getFileNameFile mfn --use the file name without .MAX extension

gct = SliderTime as string --get current frame time

--

bmp_name = "VPGRAB_"+ mfn +"_" +gvn + "_" + gct --build the output file name

--

--Display file save dialog

bmp_name = getSaveFileName caption:"Save Viewport to:" filename:bmp_name \

types:"BMP(*.bmp)|*.bmp|TIFF(*.tif)|*.tif|JPG(*.jpg)|*.jpg|TGA(*.tga)|*.tga|"

--

if bmp_name != undefined then --if user has confirmed / entered a valid name

( 

grab_bmp.filename = bmp_name --set output name to the one entered in the save file dialog

save grab_bmp --save the bitmap

display grab_bmp --display the bitmap in a VFB

)

--

)--end of script
