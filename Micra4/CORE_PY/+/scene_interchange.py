# ##### BEGIN GPL LICENSE BLOCK #####
#
#  This program is free software; you can redistribute it and/or
#  modify it under the terms of the GNU General Public License
#  as published by the Free Software Foundation; either version 2
#  of the License, or (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#
# Script copyright (C) Silvio Falcinelli  10-AUGUST-2010  Blender 2.5.3
# Thailand KhonKaen , Italy Rome   
#
# beta 3
#
# based on obj import Script copyright (C) Campbell J Barton 2007
# Boujour camera tracker import  
#
#
# ***** END GPL LICENCE BLOCK *****
#
#
# --------------------------------------------------------------------------

import os
import time
import bpy
import mathutils
import geometry
import platform
SYS = platform.system()



CurrentMat=''

def stripFile(path):
	lastSlash= max(path.rfind('\\'), path.rfind('/'))
	if lastSlash != -1:
		path= path[:lastSlash]
	return '%s%s' % (path, os.sep)


def stripPath(path):
	return path.split('/')[-1].split('\\')[-1]

def stripExt(name): 
	index= name.rfind('.')
	if index != -1:
		return name[ : index ]
	else:
		return name

def unpack_list(list_of_tuples):
	l = []
	for t in list_of_tuples:
		l.extend(t)
	return l

def unpack_face_list(list_of_tuples):
	l = []
	for t in list_of_tuples:
		face = [i for i in t]
		if len(face) != 3 and len(face) != 4:
			raise RuntimeError("{0} vertices in face.".format(len(face)))
		if len(face) == 4 and face[3] == 0:
			face = [face[3], face[0], face[1], face[2]]
		if len(face) == 3:
			face.append(0)
		l.extend(face)
	return l


def line_value(line_split):
	length= len(line_split)
	if length == 1:
		return None
	elif length == 2:
		return line_split[1]
	elif length > 2:
		return ' '.join( line_split[1:] )


def split_mesh(verts_loc, faces, unique_materials, filepath):
	global CurrentMat
	filename = stripExt(stripPath(filepath))
	def key_to_name(key):
		if type(key) == tuple:
			return '%s~%s' % key
		elif not key:
			return filename 
		else:
			return key
	def face_key(face):
		return face[4], face[2] # object,material
	face_split_dict= {}
	oldkey= -1
	for face in faces:
		key= face_key(face)
		if oldkey != key:
			try:
				verts_split, faces_split, unique_materials_split, vert_remap= face_split_dict[key]
			except KeyError:
				faces_split= []
				verts_split= []
				unique_materials_split= {}
				vert_remap= [-1]*len(verts_loc)
				face_split_dict[key]= (verts_split, faces_split, unique_materials_split, vert_remap)
			oldkey= key
		fcvrtlc_ind= face[0]
		for enum, i in enumerate(fcvrtlc_ind):
			try:	
				if vert_remap[i] == -1:
					new_index= len(verts_split)
					vert_remap[i]= new_index 
					fcvrtlc_ind[enum] = new_index 
					verts_split.append( verts_loc[i] ) 
				else:
					fcvrtlc_ind[enum] = vert_remap[i] 
			except: ()  
		faces_split.append(face)
	return [(value[0], value[1], value[2], key_to_name(key)) for key, value in list(face_split_dict.items())]
	CurrentMat = key

def create_mesh(scn, new_objects, has_ngons,  verts_loc, verts_tex, faces,  dataname):
	global CurrentMat
	context_object= None
	# reverse loop through face indicies
	for f_idx in range(len(faces)-1, -1, -1):
		fcvrtlc_ind,\
		fvt_ind,\
		context_material,\
		context_smooth_group,\
		context_object= faces[f_idx]
		len_fcvrtlc_ind = len(fcvrtlc_ind)
		if len_fcvrtlc_ind==1:
			faces.pop(f_idx)# cant add single vert faces
		elif not fvt_ind or len_fcvrtlc_ind == 2: # faces that have no texture coords are lines
			if CREATE_EDGES:
				edges.extend( [(fcvrtlc_ind[i], fcvrtlc_ind[i+1]) for i in range(len_fcvrtlc_ind-1)] )
			faces.pop(f_idx)


	context_material = -1
	me= bpy.data.meshes.new(dataname)
	me.add_geometry(len(verts_loc), 0, len(faces))
	me.verts.foreach_set("co", unpack_list(verts_loc))
	me.faces.foreach_set("verts_raw", unpack_face_list([f[0] for f in faces]))
	if verts_tex and me.faces:
		me.add_uv_texture()
	context_material_old= -1 
	mat= 0 
	me_faces= me.faces

	for i, face in enumerate(faces):
		if len(face[0]) < 2:
			pass #raise "bad face"
		elif len(face[0])==2:
			if CREATE_EDGES:
				edges.append(face[0])
		else:
			if 1:
				blender_face = me.faces[i]
#   blender_face= me_faces[face_index_map]
				fcvrtlc_ind,\
				fvt_ind,\
				context_material,\
				context_smooth_group,\
				context_object= face

				if verts_tex:
					blender_tface= me.uv_textures[0].data[i]
					if len(fcvrtlc_ind)==4:
						if fcvrtlc_ind[2]==0 or fcvrtlc_ind[3]==0:
							fvt_ind= fvt_ind[2], fvt_ind[3], fvt_ind[0], fvt_ind[1]
					else: # length of 3
						if fcvrtlc_ind[0]==0:
							fvt_ind= fvt_ind[0], fvt_ind[1], fvt_ind[2]

					blender_tface.uv1= verts_tex[fvt_ind[0]]
					blender_tface.uv2= verts_tex[fvt_ind[1]]
					blender_tface.uv3= verts_tex[fvt_ind[2]]
					if len(fcvrtlc_ind)==4:
						blender_tface.uv4= verts_tex[fvt_ind[3]]

	del me_faces

	def edges_match(e1, e2):
		return (e1[0] == e2[0] and e1[1] == e2[1]) or (e1[0] == e2[1] and e1[1] == e2[0])

	me.autosmooth=True
	me.autosmooth_angle=35

	me.update()
	ob= bpy.data.objects.new("Mesh", me)
	scn.objects.link(ob)
	new_objects.append(ob)

	ob.name=dataname   ##silvio
	ob.data.autosmooth=True
	ob.data.autosmooth_angle=35

	CurMatName = ''
	CurMatName = (dataname.split('~'))[1]

	aM=''
	for cM in bpy.data.materials:
		if cM.name == CurMatName : aM=cM
	
	if aM=='':
		bpy.ops.material.new()
		aM = bpy.data.materials[len(bpy.data.materials)-1]

	ob.active_material = aM  
	
def strip_slash(line_split):
	if line_split[-1][-1]== '\\':
		if len(line_split[-1])==1:
			line_split.pop()
		else:
			line_split[-1]= line_split[-1][:-1]
		return True
	return False

def get_float_func(filepath):
	print(filepath)
	file= open(filepath, 'rU')
	for line in file: #.xreadlines():
		line = line.lstrip()
		if line.startswith('v'): # vn vt v
			if ',' in line:
				return lambda f: float(f.replace(',', '.'))
			elif '.' in line:
				return float
	return float 




def load_obj(filepath,
			 context):
				
	print(' INFO: Start Geometry') 

	time_main= time.time()
	scene= bpy.context.scene
	SCL = scene.SCL 
	verts_loc= []
	verts_tex= []
	faces= [] 
	vertex_groups = {} 
	#print(filepath)
	float_func= get_float_func(filepath)
	context_material= None
	context_smooth_group= None
	context_object= None
	context_vgroup = None
	context_parm = '' 
	has_ngons= False
	unique_materials= {}
	unique_material_images= {}
	context_multi_line= ''
	time_sub= time.time()
	
	if scene.IMPORT_MATERIAL: create_materials(filepath) 
	file= open(filepath, 'rU')
	
	

	for line in file: 
		try:
			line = line.lstrip() 
	
			if line.startswith('v '):
				line_split= line.split()
	
				verts_loc.append( (float_func(line_split[1]) * SCL , -float_func(line_split[3]) * SCL, float_func(line_split[2])* SCL)  )
	
			elif line.startswith('vn '):
				pass
	
			elif line.startswith('vt '):
				line_split= line.split()
				verts_tex.append( (float_func(line_split[1]), float_func(line_split[2])) )
	
			elif line.startswith('usemtl'):
				context_material= line_value(line.split())
				context_material_old = -1
	
			elif line.startswith('f') or context_multi_line == 'f':
		
				if context_multi_line:
	
					line_split= line.split()
	
				else:
					line_split= line[2:].split()
					fcvrtlc_ind= []
					fvt_ind= []
	
					# Instance a face
					faces.append((\
					fcvrtlc_ind,\
					fvt_ind,\
					context_material,\
					context_smooth_group,\
					context_object\
					))
				if strip_slash(line_split):
					context_multi_line = 'f'
				else:
					context_multi_line = ''
				for v in line_split:
					obj_vert= v.split('/')
					vert_loc_index= int(obj_vert[0])-1
					if vert_loc_index < 0:
						vert_loc_index= len(verts_loc) + vert_loc_index + 1
	
					fcvrtlc_ind.append(vert_loc_index)
	
					if len(obj_vert)>1 and obj_vert[1]:
	
	
						vert_tex_index= int(obj_vert[1])-1
	
						if vert_tex_index < 0:
							vert_tex_index= len(verts_tex) + vert_tex_index + 1
	
						fvt_ind.append(vert_tex_index)
					else:
						# dummy
						fvt_ind.append(0)
	
				if len(fcvrtlc_ind) > 4:
					has_ngons= True
			elif line.startswith('o'):
				context_object= line_value(line.split())
			elif line.startswith('g'):
				context_object= line_value(line.split())
	
				# Nurbs support
			elif line.startswith('cstype '):
				context_nurbs['cstype']= line_value(line.split()) # 'rat bspline' / 'bspline'
			elif line.startswith('curv ') or context_multi_line == 'curv':
				line_split= line.split()
				curv_idx = context_nurbs['curv_idx'] = context_nurbs.get('curv_idx', []) # incase were multiline
				if not context_multi_line:
					context_nurbs['curv_range'] = float_func(line_split[1]), float_func(line_split[2])
					line_split[0:3] = [] # remove first 3 items
	
				if strip_slash(line_split):
					context_multi_line = 'curv'
				else:
					context_multi_line = ''
	
	
				for i in line_split:
					vert_loc_index = int(i)-1
	
					if vert_loc_index < 0:
						vert_loc_index= len(verts_loc) + vert_loc_index + 1
	
					curv_idx.append(vert_loc_index)
	
			elif line.startswith('parm') or context_multi_line == 'parm':
				line_split= line.split()
	
				if context_multi_line:
					context_multi_line = ''
				else:
					context_parm = line_split[1]
					line_split[0:2] = [] # remove first 2
	
				if strip_slash(line_split):
					context_multi_line = 'parm'
				else:
					context_multi_line = ''
	
				if context_parm.lower() == 'u':
					context_nurbs.setdefault('parm_u', []).extend( [float_func(f) for f in line_split] )
				elif context_parm.lower() == 'v': # surfaces not suported yet
					context_nurbs.setdefault('parm_v', []).extend( [float_func(f) for f in line_split] )
				# else: # may want to support other parm's ?
	
			elif line.startswith('deg '):
				context_nurbs['deg']= [int(i) for i in line.split()[1:]]
			elif line.startswith('end'):
				# Add the nurbs curve
				if context_object:
					context_nurbs['name'] = context_object
				nurbs.append(context_nurbs)
				context_nurbs = {}
				context_parm = ''   
		except: ()

	file.close()
	time_new= time.time()
	print('%.4f sec' % (time_new-time_sub))

	print(' INFO :  split geometry ') 

	time_sub= time_new
	time_new= time.time()

	time_sub= time_new

	scene = context.scene
	new_objects= []

	for verts_loc_split, faces_split, unique_materials_split, dataname in split_mesh(verts_loc, faces, unique_materials, filepath):
		create_mesh(scene, new_objects, has_ngons,  verts_loc_split, verts_tex, faces_split,   dataname)
	   ##motionOBJ(filepath,dataname)

	time_new= time.time()
	print('%.4f sec' % (time_new-time_sub))
	print('finished importing: "%s" in %.4f sec.' % (filepath, (time_new-time_main)))
	print('start ')



def load_image(imagepath, dirname):

	if os.path.exists(imagepath):
		return bpy.data.images.load(imagepath)

	variants = [os.path.join(dirname, imagepath), os.path.join(dirname, os.path.basename(imagepath))]

	for path in variants:
		if os.path.exists(path):
			return bpy.data.images.load(path)
		else:
			print(path, "doesn't exist")
	return None





def create_materials(filepath):
	print(' INFO: Start Textures Find ')
	DIR= stripFile(filepath)
	material_libs= []
	unique_materials= {}
	unique_material_images= {}
	def load_material_image(blender_material, context_material_name, imagepath, type, mapping,DIR):
		import platform
		SYS = platform.system()
		Nt=True
		sname=type+"_"+stripExt(stripPath(img_filepath))
		sname=sname.split('|')[0]
		for t in bpy.data.textures:
			
			if t:
				try:
					if t.name.split('.')[0] == sname : Nt=False
					texture=t
				except:
					Nt=False

		if Nt:
			if str(imagepath) != '1': 
				imagepath=imagepath.replace('//','\\')
			path=DIR+imagepath
			path=path.replace('\\\\','\\')
		
			
			if SYS=='Windows':
				path=path.replace('/','\\')
				path=path.replace('\\\\','\\')
			else:
				path=path.replace('\\','/')
				path=path.replace('//','/')

			path=path.split('|')[0]
			
			texture = bpy.data.textures.new(sname)
			
			texture.type = 'IMAGE' 
			texture = texture.recast_type()
			
			img = load_image(path, DIR)

			texture.image = img
			has_data = img.has_data if img else False

	
			if type == 'Kd':
				if has_data and img.depth == 32:
					blender_material.add_texture(texture, "UV", ("COLOR", "ALPHA"))
					texture.mipmap = True
					texture.interpolation = True
					texture.use_alpha = True
					blender_material.transparency = True
					blender_material.alpha = 0.0
	
				else:
					blender_material.add_texture(texture, "UV", "COLOR")
				unique_material_images[context_material_name]= img, has_data 
	
			elif type == 'Ka':
				blender_material.add_texture(texture, "UV", "AMBIENT")
	
			elif type == 'Ks':
				blender_material.add_texture(texture, "UV", "SPECULARITY")
	
			elif type == 'Bump':
				blender_material.add_texture(texture, "UV", "NORMAL")

				
			elif type == 'D':
				blender_material.add_texture(texture, "UV", "ALPHA")
				blender_material.transparency = True
				blender_material.alpha = 0.0
	
			elif type == 'refl ':
				blender_material.add_texture(texture, "UV", "REFLECTION")


			try:
				map = mapping.split('|')[1]
				map=map.split(' ')
				if len(map)>0:
					if map[0] == '1':
					   texture.extension = 'clip'
					print(texture.extension)
					texture.mirror_x = map[1]
					texture.mirror_y = map[2]
					texture.repeat_x = map[3]
					texture.repeat_y = map[4]
					mapping_sX = map[5]
					mapping_sY = map[6]
					mapping_flipXY = map[7]
					img_h = map[8]
					img_alpha = map[9]
					img_alpha_neg = map[10]
					texture
					
			except:()

	mtlpath=  filepath.replace('.obj' , '.mtl')
	context_material= None
	mtl= open(mtlpath, 'r')
	for line in mtl:
		if line.startswith('newmtl'):
			context_material_name= line_value(line.split())
			makeNew=True
			for cM in bpy.data.materials:
				if cM.name == context_material_name : 
					makeNew=False
					context_material = cM
			if makeNew:
				context_material = bpy.data.materials.new(context_material_name)
				print(context_material.name)
				
		line_split= line.split()
		line_lower= (line.lower().lstrip()).replace('\t','')
		if line_lower.startswith('ka'):
			try:
				context_material.mirror_color=(float(line_split[1]),float(line_split[2]),float(line_split[3]))
			except:()
		elif line_lower.startswith('kd'):
			try:
				context_material.diffuse_color=(float(line_split[1]),float(line_split[2]),float(line_split[3]))
			except:()
		elif line_lower.startswith('ks'):
			try:
				context_material.specular_color=(float(line_split[1]),float(line_split[2]),float(line_split[3]))
			except:()
		elif line_lower.startswith('ns'):
			context_material.specular_hardness = int((float(line_split[1])*0.51))
		elif line_lower.startswith('ray_reflect'):
			context_material.raytrace_mirror.reflect_factor  = float(line_split[1])
		elif line_lower.startswith('reflect_blur'):
			context_material.raytrace_mirror.gloss_factor = float(line_split[1])
		elif line_lower.startswith('reflect_samples'):
			context_material.raytrace_mirror.gloss_samples = integer(float(line_split[1]))
		elif line_lower.startswith('reflect_depth'):
			context_material.raytrace_mirror.depth  = integer(float(line_split[1]))
		elif line_lower.startswith('reflect_maxdist'):
			context_material.raytrace_mirror.distance  = integer(float(line_split[1]))
		elif line_lower.startswith('reflect_anisotropic'):
			context_material.raytrace_mirror.anisotropic  = float(line_split[1])
		elif line_lower.startswith('ray_refract'):
			context_material.raytrace_transparency.fresnel_factor  = float(line_split[1])
		elif line_lower.startswith('ni'):
			context_material.raytrace_transparency.ior = max(1, min(float(line_split[1]), 3))
		elif line_lower.startswith('refract_blur'):
			context_material.raytrace_transparency.gloss_factor  = float(line_split[1])
		elif line_lower.startswith('refract_samples'):
			context_material.raytrace_transparency.gloss_samples  = integer(float(line_split[1]))
		elif line_lower.startswith('refract_depth'):
			context_material.raytrace_transparency.depth  = integer(float(line_split[1]))
		elif line_lower.startswith('refract_limit'):
			context_material.raytrace_transparency.limit  = integer(float(line_split[1]))
		elif line_lower.startswith('translucency'):
			context_material.translucency  =  float(line_split[1])
		elif line_lower.startswith('emit'):
			context_material.emit  =  float(line_split[1])
		elif line_lower.startswith('sss_scale'):
			context_material.subsurface_scattering.scale.scale  =  float(line_split[1])
		elif line_lower.startswith('sss_color'):
			context_material.subsurface_scattering.color=(float(line_split[1]),float(line_split[2]),float(line_split[3]))
		elif line_lower.startswith('shader'):
			context_material.diffuse_shader  =  line_split[1]
		elif line_lower.startswith('roughness'):
			context_material.roughness  =  line_split[1]
		### texture
		elif line_lower.startswith('d') or line_lower.startswith('tr'):
			context_material.alpha = float(line_split[1])
		elif line_lower.startswith('map_ka'):
			img_filepath= line_value(line.split())
			print('_____________________________\n' + img_filepath)
			if img_filepath:
				load_material_image(context_material,context_material_name,img_filepath,'Ka',line_lower,DIR)
		elif line_lower.startswith('map_ks'):
			img_filepath= line_value(line.split())
			if img_filepath:
				load_material_image(context_material,context_material_name,img_filepath,'Ks',line_lower,DIR)
		elif line_lower.startswith('map_kd'):
			img_filepath=  line_value(line.split())
			if img_filepath:
				load_material_image(context_material,context_material_name,img_filepath,'Kd',line_lower,DIR)
		elif line_lower.startswith('map_bump'):
			img_filepath= line_value(line.split())
			
			if img_filepath:
				load_material_image(context_material,context_material_name,img_filepath,'Bump',line_lower,DIR)
		elif line_lower.startswith('map_displ'):
			img_filepath= line_value(line.split())
			if img_filepath:
				load_material_image(context_material,context_material_name,img_filepath,'Disp',line_lower,DIR)
		elif line_lower.startswith('map_d') or line_lower.startswith('map_tr'): 
			img_filepath= line_value(line.split())
			if img_filepath:
				load_material_image(context_material,context_material_name,img_filepath,'D',line_lower,DIR)
		elif line_lower.startswith('refl'):
			img_filepath= line_value(line.split())
			if img_filepath:
				load_material_image(context_material,context_material_name,img_filepath,'refl',line_lower,DIR)
	mtl.close()

#########################################################################################################

def load_Scn(filepath):
	print(' INFO: Start Lights ')
	from math import pi
	scene = bpy.context.scene
	SCL = scene.SCL 
	makeNew=False
	makeCamNew=False
	l_from=None
	l_type=None
	l_rot=None
	l_color=None
	l_power=None
	l_name=None
	context_lamp=None
	mtl= open(filepath, 'r')

	path=stripExt(filepath)

	def load_light_image(lamp,imagepath,sname):
		DIR= stripFile(filepath)
		Nt=True
		for t in bpy.data.textures:
			if t:
				try:
					if t.name.split('.')[0] == sname : Nt=False
					texture=t
				except:
					Nt=False

		if Nt:
	

			if str(imagepath) != '1': 
				imagepath=imagepath.replace('//','\\')
			path=DIR+imagepath
			path=path.replace('\\\\','\\')
			
			if SYS=='Windows':
				path=path.replace('/','\\')
			else:
				path=path.replace('\\','/')
				path=path.replace('//','/').replace('//','/')


			
			#image = bpy.data.add_image(path)


			image = load_image(path, DIR)

			texture = bpy.data.textures.new(sname)
			texture.type = 'IMAGE' 
			texture = texture.recast_type()
			texture.image = image



	for line in mtl:
		

		line_split= line.split()
		line_lower= (line.lower().lstrip()).replace('\t','')
		

		if line_lower.startswith('from'):
			l_from = (float(line_split[1])*SCL,float(line_split[2])*SCL,float(line_split[3])*SCL)
	
		elif line_lower.startswith('rot'):
			l_rot = (float(line_split[1]),float(line_split[2]),float(line_split[3]))



		if scene.IMPORT_LIGHT:

			if line.startswith('newlight'):
				l_from=None
				l_type=None
				l_rot=None
				l_name= line_value(line.split())
				makeNew=True
	
			if makeNew and l_from and l_rot and l_type  and l_name:
				l=bpy.ops.object.lamp_add(type=l_type, view_align=False, location=l_from, rotation=(0,0,0)) 
				ob = bpy.context.scene.objects.active
				lamp = ob.data
				ob.name=l_name
				lamp.name=l_name
				makeNew=False
				ob.rotation_euler[0]=l_rot[0] * pi / 180
				ob.rotation_euler[1]=l_rot[1] * pi / 180
				ob.rotation_euler[2]=l_rot[2] * pi / 180
				

				if scene.IMPORT_ANIMATION_LAMP:
					LampMotion=stripFile(filepath)+"Motion/"+l_name+'.lmp'
					if os.path.isfile(LampMotion):
						Fc = open(LampMotion, 'r');
						l = 1;
						readVerts = False;
						readCam = False;
						numFrames = 0;
						bpy.ops.anim.keyingset_button_add(all=True)
						bpy.ops.anim.driver_button_add(all=True)
						for curLine in Fc.readlines():
							lp = curLine.split()
							location = (float(eval(lp[1]) * SCL),float(eval(lp[2]) * SCL),float(eval(lp[3]) * SCL))
							scene.frame_current=(int(float(lp[0])))
							ob.location=location
							ob.rotation_euler[0] = pi * (float(lp[4]))/180
							ob.rotation_euler[1] = pi * (float(lp[5]))/180
							ob.rotation_euler[2] = pi * (float(lp[6]))/180
							ob.keyframe_insert("location")
							ob.keyframe_insert("rotation_euler")
							l += 1;
						Fc.close

						
				

			if line_lower.startswith('type'):
				l_type = line_split[1]
	
			elif line_lower.startswith('power'):
				lamp.energy = float(line_split[1])
	
			elif line_lower.startswith('areax'):
				lamp.size = float(line_split[1])*SCL
				lamp.shadow_method='RAY_SHADOW'
				lamp.shadow_ray_samples_x=8
				lamp.distance=3
	
			elif line_lower.startswith('areay'):
				lamp.shape='RECTANGLE'
				lamp.size_y = float(line_split[1])*SCL
				lamp.shadow_ray_samples_y=8

	
			elif line_lower.startswith('color'):
				lamp.color = (float(line_split[1]),float(line_split[2]),float(line_split[3]))
	
			elif line_lower.startswith('samples'):
				try: lamp.shadow_ray_samples = int(float(line_split[1]))
				except:()   
				try: lamp.shadow_ray_samples_x=int(float(line_split[1]))
				except:()
				try: lamp.shadow_ray_samples_y=int(float(line_split[1]))
				except:()

				   
			elif line_lower.startswith('texture'):
				img_filepath= line_value(line.split())
				if img_filepath:
	
					load_light_image(lamp, img_filepath,"Lamp_"+stripExt(stripPath(img_filepath)))
					

				








		if scene.IMPORT_CAMERA:

			
			if line.startswith('newcam'):
				print(' INFO: New Cam')

				l_from=None
				l_type=None
				l_rot=None
				l_lens=None
				l_name= line_value(line.split())
				makeCamNew=True
				
				  
			if makeCamNew and l_from and l_rot and l_name:
				print(' INFO: Make Cam %s ' % l_name)
				bpy.ops.object.camera_add(view_align=False, enter_editmode=False, location=(0.0, 0.0, 0.0), rotation=(0.0, 0.0, 0.0))
				camMotion=stripFile(filepath)+'Motion/'+l_name+'.cam'
				ob = bpy.context.scene.objects.active
				cam = ob.data
				ob.name=l_name
				cam.name=l_name
				ob.location=l_from
				ob.rotation_euler[0] = pi * l_rot[0]/180
				ob.rotation_euler[1] = pi * l_rot[1]/180
				ob.rotation_euler[2] = pi * l_rot[2]/180
				ob.data.clip_end = 5000
				ob.data.clip_start=0.0001
				makeCamNew=False  
	
			  
			elif line_lower.startswith('lensm') and makeCamNew==False:
				cam.lens = float(line_split[1])

				if scene.IMPORT_ANIMATION_CAM:
					if os.path.isfile(camMotion):
						

					#   camipo = driver_add(cam.lens, index=-1)
					#   camipo = Blender.Ipo.New('Camera','render_cam_camipo')
					#   lenscurve = camipo.addCurve('Lens')
					#   lenscurve.setInterpolation('Linear')
					#   cam.lens = float(line_split[1])




						Fc = open(camMotion, 'r');
						l = 1;
						readVerts = False;
						readCam = False;
						numFrames = 0;

						bpy.ops.anim.keyingset_button_add(all=True)
						bpy.ops.anim.driver_button_add(all=True)
						for curLine in Fc.readlines():
							if (l==1) and ('cRio ' not in curLine):
								file.close();
								break;
							if l > 1:
								lp = curLine.split()
								location = (float(eval(lp[1]) * SCL),float(eval(lp[2]) * SCL),float(eval(lp[3]) * SCL))
								scene.frame_current=(int(float(lp[0])))
								ob.location=location
								ob.rotation_euler[0] = pi * (float(lp[4]))/180
								ob.rotation_euler[1] = pi * (float(lp[5]))/180
								ob.rotation_euler[2] = pi * (float(lp[6]))/180
								ob.data.lens = float(lp[7])
								ob.keyframe_insert("location")
								ob.keyframe_insert("rotation_euler")
			
							l += 1;
						Fc.close
				# api blender 2.5.3   error
				try:
					bpy.ops.view3d.object_as_camera(cam)
				except:()

				try:
					bpy.ops.view3d.object_as_camera(ob)
				except:()

				try:
					bpy.ops.view3d.object_as_camera()
				except:()
	

	  
		if scene.IMPORT_GEOMETRY:
			if line.startswith('newpivot'):
				objects= bpy.context.scene.objects
				lineV = line.split() 
				for ob in objects:
	
					if  ob.name.split('~')[0] == lineV[1] and not ob.get('name'): 
						bpy.context.scene.objects.active = ob
						print(ob.name.split('~')[0])
						objPivot=ob
						pivotX=float(lineV[2]) * SCL
						pivotY=float(lineV[3]) * SCL
						pivotZ=float(lineV[4]) * SCL
						pivotX -= pivotX * 2 
						pivotY -= pivotY * 2
						pivotZ -= pivotZ * 2 
						
						try:
						  bpy.ops.object.mode_set(mode='EDIT')
						  bpy.ops.transform.translate(value=(pivotX,pivotY,pivotZ))
						except:()
						
						bpy.ops.object.mode_set(mode='OBJECT')
						pivotX=float(lineV[2]) * SCL
						pivotY=float(lineV[3]) * SCL
						pivotZ=float(lineV[4]) * SCL
						pivotZ=0
						ob.location=(pivotX,pivotY,pivotZ)
		
						ob['name']=(ob.name.split('~')[0])

			

			

			if line.startswith('newdummy'):
				objects= bpy.context.scene.objects
				lineV = line.split() 

				pX=(float(lineV[2]) * SCL)
				pY=(float(lineV[3]) * SCL)
				pZ=(float(lineV[4]) * SCL)
				
				sX=(float(lineV[5]) * SCL)
				sY=(float(lineV[6]) * SCL)
				sZ=(float(lineV[7]) * SCL)

				rX=float(lineV[8]) 
				rY=float(lineV[9])
				rZ=float(lineV[10])

			   
				bpy.ops.object.add(view_align=False, 
									enter_editmode=False, 
									location=(pX, pY, pZ), 
									rotation=(rX, rY, rZ)
									)
				Nobj=bpy.context.active_object
				Nobj.name=lineV[1]
				Nobj.scale=(sX,sY,sZ)




	### unify geometry multimaterial
	#for ob in objects:
		#if  ob.name.split('~')[0] ==  ob.get('name'): 
	

	mtl.close()


def load_obj_mot(path):
	print(' INFO: Start Objects  animation ') 
	from math import pi 
	SC = bpy.context.scene
	SCR = SC.render
	SCL = SC.SCL 
	FrameRate = float(SCR.fps)
	objects=bpy.context.scene.objects
	for ObjMot in objects:
		filename=path+'Motion/'+(ObjMot.name.split('~'))[0]+'.mot'
		if os.path.isfile(filename):

			File = open (filename, 'rU')
			CurChannel = -1
			ScaleFlag = 0
			LocX=None
			LocY=None   
			LocZ=None
			RotX=None
			RotY=None
			RotZ=None
			ScaleX=None
			ScaleY=None
			ScaleZ=None
			LocX=ObjMot.location[0]
			LocY=ObjMot.location[1]
			LocZ=ObjMot.location[2]
			SC.frame_current=1

			cf=0
			for Line in File:
				line=Line.split (' ')

				if len(line) > 1:
					ObjMot.keyframe_insert("location")
					ObjMot.keyframe_insert("rotation_euler")
					ObjMot.keyframe_insert("scale")  
					SC.frame_current=int(float(line[0]))
					
					ObjMot.location[0]=(float(line[1]) * SCL)
					ObjMot.location[1]=(float(line[2]) * SCL)
					ObjMot.location[2]=(float(line[3]) * SCL)
					
					try: ObjMot.rotation_euler[0] = pi * float(line[4]) /180				
					except: ObjMot.rotation_euler[0] = 0
					try: ObjMot.rotation_euler[1] = pi * float(line[5]) /180 
					except: ObjMot.rotation_euler[1] = 0
					try: ObjMot.rotation_euler[2] = pi * float(line[6]) /180 
					except: ObjMot.rotation_euler[2] = 0
	
					ObjMot.scale[0]=float(line[7])
					ObjMot.scale[1]=float(line[8])
					ObjMot.scale[2]=float(line[9])
					ObjMot.keyframe_insert("location")
					ObjMot.keyframe_insert("rotation_euler")
					ObjMot.keyframe_insert("scale")
			File.close()



def joinMultiMat():
	
	objects=bpy.context.scene.objects
	for Obj in objects:
		namePattern=Obj.name.split('~')[0]
		namePattern=namePattern+"~*"
		try:
		  bpy.ops.object.select_pattern(pattern="namePattern", case_sensitive=False, extend=True)
		  bpy.ops.object.join()
		except:()

	for Obj in objects:
		Obj.name=Obj.name.split('~')[0]




def parent(filepath):
	print(' INFO: Parent ')
	from math import pi
	scene = bpy.context.scene
	SCL = scene.SCL 
	mtl= open(filepath, 'r')

	for line in mtl:
		
		if scene.IMPORT_GEOMETRY:
			if line.startswith('newchildof'):
				objects= bpy.context.scene.objects
				lineV = line.split() 
				for ob in objects:
	
					if (ob.name.split('~'))[0] == lineV[1] and not ob.get('parent'): 
						for obf in objects:
	
							if (obf.name.split('~'))[0] == lineV[2]: 
								ob.location[0] = ob.location[0]-obf.location[0]
								ob.location[1] = ob.location[1]-obf.location[1] 
								ob.location[2] = ob.location[2]-obf.location[2] 

								ob.parent = obf


								ob['parent']=(obf.name.split('~')[0])
								print("\n______________" +ob.name + " child of  " +  obf.name)




DEBUG= True

DEBUG= False
from bpy.props import *


IntProperty = bpy.types.Scene.IntProperty
BoolProperty = bpy.types.Scene.BoolProperty
FloatProperty = bpy.types.Scene.FloatProperty



FloatProperty(attr="SCL",name="Clamp Scale", description="Clamp the size to this maximum (Zero to Disable)", min=0.000, max=1000.0, soft_min=0.00, soft_max=1000.0, default=0.001)
BoolProperty(attr="IMPORT_GEOMETRY",default= True)
BoolProperty(attr="IMPORT_CAMERA",default= True)
BoolProperty(attr="IMPORT_LIGHT",default= True)
BoolProperty(attr="IMPORT_MATERIAL",default= True)
BoolProperty(attr="IMPORT_ANIMATION_CAM",default= True)
BoolProperty(attr="IMPORT_ANIMATION_OBJ",default= False)
BoolProperty(attr="IMPORT_ANIMATION_LAMP",default= False)

class SCENE_PT_importScene(bpy.types.Panel):
	bl_label = "Import Scene"
	bl_space_type = "PROPERTIES"
	bl_region_type = "WINDOW"
	bl_context = "scene"
	
	def draw(self, context):
		layout = self.layout
		scene = context.scene
		row = layout.row()
		row = layout.row()
		row = row.split(percentage=0.6)
		row.prop(scene,"IMPORT_GEOMETRY", text='Geometry', icon='OBJECT_DATA')
		row = row.split(percentage=0.1)
		row.label(text=' ')
		row.prop(scene,"IMPORT_ANIMATION_OBJ", text='', icon='ANIM_DATA')

		row = layout.row()
		row = row.split(percentage=0.6)
		row.prop(scene,"IMPORT_CAMERA", text='Camera', icon='CAMERA_DATA')
		row = row.split(percentage=0.1)
		row.label(text=' ')
		row.prop(scene,"IMPORT_ANIMATION_CAM", text='', icon='ANIM_DATA')
		row = layout.row()
		row = row.split(percentage=0.6)
		row.prop(scene,"IMPORT_LIGHT", text='Light', icon='LAMP_DATA')
		row = row.split(percentage=0.1)
		row.label(text=' ')
		row.prop(scene,"IMPORT_ANIMATION_LAMP", text='', icon='ANIM_DATA')
		row = layout.row()
		row = row.split(percentage=0.6)
		row.prop(scene,"IMPORT_MATERIAL", text='Material', icon='MATERIAL_DATA')
		row = row.split(percentage=0.1)
		row.label(text=' ')
		row.label(text=' ') 
		row = layout.row()

		row = layout.row()
		row = layout.row()
		row = layout.row()
		row = layout.row()
		row.prop(scene,"SCL" , text="Scale")
		row = layout.row()
		row = layout.row()
		row.operator("object.custom_path" , text="Import Scene")
		row = layout.row()
		row = layout.row()
		row = layout.row()
		row = layout.row()
		layout.label(text='Scene interchange: rev 6-AUGUST-2010') 
		layout.label(text='3DS Max, Lightwave, Maya') 
		layout.label(text='Camera Animation, Full Shader Parameter') 
		row = layout.row()
		row = layout.row()
		row = layout.row()
		row = layout.row()
		row = layout.row()
		row = layout.row()
		row = layout.row()
		layout.label(text='Copyright (C)   Silvio Falcinelli')
		row = layout.row()
		layout.label(text='GNU license')
		row = layout.row()
		row = layout.row()

import bpy
from bpy.props import *

bpy.types.Scene.StringProperty(name="file path",
	attr="path", 
	description="simple file path",
	maxlen= 1024,
	default= "")



class OBJECT_OT_CustomPath(bpy.types.Operator):
	bl_idname = "object.custom_path"
	bl_label = "Scene Path"
	__doc__ = ""

	filepath = StringProperty(name="File Path", description="getting file path", maxlen= 1024, default= "")



	def execute(self, context):
		scene = context.scene
		scene.path = self.properties.filepath
		
		if scene.SCL< 0.01 : scene.SCL=0.01

		namefile=stripExt(self.properties.filepath)
		
		print(namefile)

		if scene.IMPORT_GEOMETRY: load_obj(namefile+'.obj', context)


		load_Scn(namefile+'.scn')
		###parent(namefile+'.scn')
		joinMultiMat()


		if bpy.context.scene.IMPORT_ANIMATION_OBJ: load_obj_mot(stripFile(namefile))
			
		print(' INFO: Scene  Done ')  
		return {'FINISHED'}
	def invoke(self, context, event):

		wm = context.manager
		wm.add_fileselect(self)
		context.scene.path = context.scene.path
		return {'RUNNING_MODAL'}

def register():
	bpy.types.register(SCENE_PT_importScene)
	bpy.types.register(OBJECT_OT_CustomPath)

def unregister():
	bpy.types.register(SCENE_PT_importScene)	
	bpy.types.unregister(OBJECT_OT_CustomPath)

if __name__ == "__main__":
	register()



'''

	last upgrade 8-August-2010
	texture ok
	light rotation ok   
	light samples ok
	import separed part camera light ok
	UV texture ok
	light animation ok

'''