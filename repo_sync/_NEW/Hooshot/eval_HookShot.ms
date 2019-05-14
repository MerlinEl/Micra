root = "E:\P3D_scripts_playGround\HookShot_Now\\"  -- << ROOT
scriptsToEval = #("lib_HookShot.ms", "HookShotMain.ms", "HookShotMiddle.ms", "HookShotTarget.ms")


for script in scriptsToEval do filein (root +script)