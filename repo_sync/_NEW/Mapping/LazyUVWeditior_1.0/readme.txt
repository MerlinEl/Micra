LAZY UVW EDITOR © COPYRIGHT 2014 - Aaron dabelow - aarondabelow@gmail.com - www.aarondabelow.com

Description:
The Lazy UVW editor is a way to procedurally create seamless textures without having to unwrap uvs. It accomplishes this by using multiple uvw channels to cover pinching, stretching, or seams of the basic uvw mapping options, and the resulting map may be baked down to one channel if desired.

Standard Installation:
Drag and drop, or maxscript>run to launch the installer to launch the script.

API:
I have structured this script to have an API so that the tool can be used independent from the UI and its functionalities added into other tools or pipelines.

there are 2 structures that are usefull to the user that can be accessed via maxscript, to see them and their properties execute this code:

	showproperties lazyUVW_Def
	showproperties uvwFun

the first, the "lazyUVW_Def" is a data structure that hold the information for the current uvw operation. It stays in memory, and can be edited by the UI or by maxscript. This is essentially the instructions for the script to use.

  mode:<data>; Public			{int}	 - the UVW operation to perform. the index corresponds with the dropdown list in the UI
  textureMap1:<data>; Public		{string} - the filename of an image file, to use as the texture, in channel 1
  textureMap2:<data>; Public		{string} - the filename of an image file, to use as the texture, in channel 2
  textureMap1_tile_U:<data>; Public	{float}  - the U tiling amount for the texture map in channel 1
  textureMap1_tile_V:<data>; Public	{float}  - the V tiling amount for the texture map in channel 1
  textureMap2_tile_U:<data>; Public	{float}  - the U tiling amount for the texture map in channel 2
  textureMap2_tile_V:<data>; Public     {float}  - the V tiling amount for the texture map in channel 2
  blendNoise:<data>; Public		{float}	 - the amount of noise to add to the procedural blend map
  blendMap1:<data>; Public		{string} - the filename of an image file, to use as the texture, in the blending channel
  blendMode:<data>; Public		{int}	 - the UVW operation to perform. 1 is procedural 2 is texture based
  bakeEnabled:<data>; Public		{bool}	 - sets weather the texure will be baked or not
  bakeDestination:<data>; Public	{string} - where to save the baked image, this is a path, not a filename
  bakeToMap:<data>; Public		{bool}	 - sets weather to create a new material applied to the object, with its baked map
  bakeChannel:<data>; Public		{int}	 - the destination map channel of the automatic unwrap
  bakeResolution:<data>; Public		{int}	 - the x and y resolution to the baked map

To edit any of the properties, enabling baking and its destination for example, set it like this.

	lazyUVW_Def.bakeEnabled = true
	lazyUVW_Def.bakeDestination = "C:\test\"

Once you have set any properties you want, you execute the operation by calling the "applyUVW" function from uvwFun, and it will operate on your selection.

	uvwFun.applyUVW()

These operations can be done with the UI open or closed, please note that if the UI is open, any changes made via maxscript will not appear in the UI, and only will be if you call the "updateUI" function.
	
	uvwFun.updateUI()


License:
This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.