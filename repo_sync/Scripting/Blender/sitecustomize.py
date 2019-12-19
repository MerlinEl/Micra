#!/usr/bin/env python
# -*- coding: utf-8 -*-
# ==============================================================================
# ==== Documentation
# ==============================================================================
"""
	Description
	===========
		Full site customization module

	@authors: Alexander G. Morano
	@contact: alex.morano@nick.com
	@date: Dec 23, 2010
	@organization: Nickelodeon Animation Studios
"""
# ==============================================================================
# ==== Imports
# ==============================================================================
import os
import sys
import site
import getpass
import platform
import subprocess
# ==============================================================================
# ==== Globals
# ==============================================================================
__version__	= '1.0.0'
# ==============================================================================

# Directory Roots for AUX
__root		= os.path.dirname( os.path.abspath(__file__) ).lower()
__drive	= __root

while __drive and not os.path.exists( os.path.join( __drive, 'auxiliary' ) ):
	__drive, dir = os.path.split( __drive )
	if dir == '': break

# support extension libraries root -- must reside next to nas root
__rootAux	= os.path.join( __drive, 'auxiliary')

#
# LOGGING
# try the database logger first, then fall back on the file logger...		
if not os.path.exists( __rootAux ):
	print 'Auxillary root :: %s' % __rootAux
	raise Exception('Missing major extension libraries')

# Python Specific info for interpreter Session
__pyVer	= '%d.%d' % (sys.version_info[0], sys.version_info[1])
__pyBits 	= ['32', '64']['64 bit' in platform.python_compiler()]
__pyString = '__%s_%s' % (__pyVer, __pyBits)

__all = os.path.join(__rootAux, '__all')
__pypath = os.path.join(__rootAux, __pyString)

sys.path.insert(0, __all)
sys.path.insert(0, __pypath)

# Module locations
site.addsitedir( __all )
site.addsitedir( __pypath )

# ==============================================================================

def sysPathEnvAdd(envVar, path, insert=-1):
	"""
	Adds a path to the environment variable, performing smart checks
	as to insertion order (LIFO), existance and duplicate removal
	@param envVar:
	@type envVar:
	@param path:
	@type path:
	@param insert:
	@type insert:
	@return:
	@rtype: C{bool}
	"""
	oldPath = os.environ.get(envVar, '')
	if oldPath:
		parts = oldPath.split(os.pathsep)
		if path in parts: return
		
		parts.insert(insert, path)
		path = (os.pathsep).join(parts)
	os.putenv('envVar', path)
	os.environ[envVar] = path
	return 1

# ==============================================================================

## The Mudbox Machine
##
sysPathEnvAdd('MUDBOX_PLUG_IN_PATH', ('%s/plugins/mudbox' % __drive).replace('\\', '/' ) )

## The Nuke Machine
##
sysPathEnvAdd('NUKE_PATH', ('%s/nas/nuke' % __root).replace('\\', '/' ) )

## The Mari Machine
##
path = ('%s/nas/mari' % __root).replace('\\', '/' )
sysPathEnvAdd('MARI_SCRIPT_PATH', path )
os.environ['MARI_SCRIPT_PATH'] = path
os.putenv('MARI_SCRIPT_PATH', path)

#args = ['SETX', 'MARI_SCRIPT_PATH', path]
#subprocess.call(args, shell=1, stdout=subprocess.PIPE)
'''
if subprocess.call(args, shell=1, stdout=subprocess.PIPE)==0:				
	os.environ['MARI_SCRIPT_PATH'] = path
	os.putenv('MARI_SCRIPT_PATH', path)
else:
	print 'Failure to set environment %s == %s' % (k, vars[k])
'''
## The Everything-else Machine
##
path = os.environ.get('TEMP', None)
if path is None:
	path = os.environ.get('TMP', None)
	if path is None:
		path = 'c:\\Users\\%s\\AppData\\Local\\Temp' % getpass.getuser()
path = '%s/nuke' % path.replace('\\', '/')
sysPathEnvAdd('NUKE_TEMP_DIR', path)

delight = os.environ.get('DELIGHT', '')
newDelight = os.path.join(__root, 'apps\\3delight')

if os.path.exists(newDelight):
	sysPathEnvAdd('DELIGHT', newDelight)	
	
	newDisplays = os.path.join(newDelight, 'displays')
	sysPathEnvAdd('DL_DISPLAYS_PATH', newDisplays)
	
	newShaders = os.path.join(newDelight, 'shaders')
	shaders = os.environ.get('DL_SHADERS_PATH', '')
	if shaders:
		newShaders = '%s%s%s' % (shaders, os.pathsep, newShaders)
	sysPathEnvAdd('DL_SHADERS_PATH', newShaders)
	
	newDelight = os.path.join(newDelight, 'bin')
	sys.path.append(newDelight)

newEnv = []
for path in sys.path:
	path = os.path.normpath(path)
	if os.altsep:
		path = path.replace(os.sep, os.altsep)
	newEnv.append(path)

oldEnv = os.environ['Path'].split(os.pathsep)
for path in oldEnv:
	path = os.path.normpath(path)
	if os.altsep:
		path = path.replace(os.sep, os.altsep)
	if not path in newEnv:
		newEnv.append(path)

sysPathEnvAdd('Path', (os.pathsep).join(newEnv) )

import pprint
pprint.pprint(sys.path)

for x in sorted(os.environ.keys()):
	print x, os.environ[x]
