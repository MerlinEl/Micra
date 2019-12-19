#!/usr/bin/env python
# -*- coding: utf-8 -*-
# ==============================================================================
# ==== Documentation
# ==============================================================================
"""
	Description
	===========
		NAS Mari Core

	@authors: Alexander G. Morano
	@contact: alex.morano@nick.com
	@date: June 06, 2011
	@organization: Nickelodeon Animation Studios
"""
# ==============================================================================
# ==== Imports
# ==============================================================================
import mari

import nas.system as ns
# ==============================================================================
# ==== Globals
# ==============================================================================
log = ns.session.logger()
__version__	= '1.0.0'
# ==============================================================================

class Session( object ):
	"""
	"""
	
	def __init__(self):
		"""
		"""
		log.info( mari.app.version().string() )
		
		ns.env.sessionAppSet( 'Mari', mari.app.version().string() )

		# ======================================================================
		# ==== Python Directories
		# ======================================================================
		"""
		log.info('PLUGIN DIRECTORIES')

		core =  os.path.join(ns.env.Root, 'nas\\nuke')
		nn.pathNukeAdd( core, addToSysPath=True )

		rootPath = os.path.join( core, 'gizmos')
		nn.pathNukeAdd( rootPath )

		for path in io.dirRecurse(rootPath, level=1):
			newPath = os.path.join(rootPath, path)
			try:
				nn.pathNukeAdd( newPath )
			except:
				log.info('Skip %s Path', newPath)

		nn.pathNukeAdd( os.path.join(ns.env.Root, 'plugins\\nuke', ns.env.PyBits) )
		"""
		# ======================================================================
		# ==== CALLBACKS
		# ======================================================================
		log.info('CALLBACKS')
		
		mari.utils.connect( mari.projects.projectSaved, self.__callback_save )
		"""When Mari Loads a project"""
		
		mari.utils.connect( mari.projects.openedProject, self.__callback_load )		
		"""When Mari Loads a project"""
		
		#mari.utils.connect( mari.projects.projectClosed, self.__callback_closed )
		#"""When Nuke Loads a Script"""
				
		mari.utils.connect( mari.app.exit, self.__callback_exit )		
		"""When Mari exits"""

	# ==========================================================================
	# ==== EVENTS
	# ==========================================================================
	
	def __callback_save(self, project):
		"""
		Update Mach with current scene file
		"""		
		ns.env.SessionOp('save', project)
		log.info( 'Mari save :: %s', project )

	def __callback_load(self, project):
		"""
		Update Mach with current scene file
		"""		
		ns.env.SessionOp('open', project)
		log.info( 'Mari open :: %s', project )

	def __callback_exit(self):
		"""
		Update Mach with a saved Maya state
		"""
		ns.env.SessionOp('disassemble')
		log.info( 'Mari shutdown' )

# ==============================================================================
# ==== SINGLETON SESSION ENVIRONMENT
# ==============================================================================
env = session = Session = Session()
# ==============================================================================