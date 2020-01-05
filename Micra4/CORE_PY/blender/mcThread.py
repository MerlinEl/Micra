import threading
from time import sleep

# Register class after given delay
class RegisterScript(threading.Thread):
	def __init__(self, dir, fname, delay):
		threading.Thread.__init__(self)
		self.fname = fname	#script filename
		self.fpath = dir +"\\"+ fname	#full script path
		self.delay = delay	#sec

	def run(self):
		print('\nwaiting to register script: {} sec'.format(self.delay))	
		sleep(self.delay)
		try:
			# exec(compile(open(self.fpath).read(), self.fname, 'exec'))
			exec(compile(open(self.fpath).read(), self.fname, 'exec'), {})
			print ('Register Bridge Command :\n\t', self.fpath)
		except: 
			print ('Unable to register Script:\n\t', self.fpath)
			import sys
			print ("Error:\n\t", sys.exc_info()[0])
		# finally:
			# assert 'string' in locals(), "won't fail because 'import' worked properly"
		print ("THREAD: end")
	
# Example    
# script_path = Micra_Blender_Dir + "\\mcCommand.py"
# from mcThread import RegisterScript
# thread = RegisterScript(script_path, 0.05)
# thread.start()

# Works from listener
# fname = 'mcCommand.py'
# fpath = 'E:\\Aprog\\Orien\\Micra\\Micra4\\CORE_PY\\blender' + '\\' + fname
# exec(compile(open(fpath).read(), fname, 'exec'))