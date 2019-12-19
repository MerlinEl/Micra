SET BLENDER_ROOT="D:\ReneBaca\Blender\blender-2.81a-windows64\"
SET BLENDER_BRIDGE="D:\ReneBaca\Blender\blender-2.81a-windows64\bridge"

"%BLENDER_ROOT%\blender.exe" "%BLENDER_BRIDGE%\Test.blend" --background --python "%BLENDER_BRIDGE%\convert_blend_to_obj.py" -- "%BLENDER_BRIDGE%\Test.obj"