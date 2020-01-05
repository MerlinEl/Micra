bl_info = {
    "name" : "Script Live-Link [BD3D]",
    "author" : "BD3D, kaio",
    "description" : "Easely work with other text editor within blender.",
    "blender" : (2, 80, 0),
    "location" : "Text Editor",
    "warning" : "",
    "category" : "Generic"
}
#Please don't use the addon on itself. it will crash. 
#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-

import bpy, os, functools, rna_keymap_ui, re
context = C = bpy.context

#getting attributes inside thoses def below was more tricky that you might think
################################################################################
#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-
#                             LIVE-LINK DEF
#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-
################################################################################
#                                path_01
#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-

def poll_text1():  #main timer, check if text changed, will trigger ui redraw
    G      = bpy.context.scene.SCR_OT_group
    G_path = G.path_01
    G_name = os.path.basename(G_path)
    if G.debug_mode: print("debug: poll_text1: check")

    if os.path.exists(G_path):
        mtime = os.path.getmtime(G_path)
        if mtime != bpy.context.scene["scr_index_01"]:
            if G.debug_mode: print("debug: poll_text1: not same file ! is EXECUTE in first line?")
            bpy.context.scene["scr_index_01"] = mtime
            file = open(G_path) ; line_o = file.readline() ; file.close()
            if "EXECUTE" in line_o: #if key word not in first line
                if G.debug_mode: print("debug: poll_text1: EXECUTE in first line, call for redraw")
                call_redraw1()
            elif "STOP" in line_o: bpy.ops.scr.stop_link(index=1)
    return 0.5

def call_redraw1(): #once txt changed, UI redrawed, and exexute_text.ok attribute is ok,  triggering execute_text1 
    G = bpy.context.scene.SCR_OT_group
    if G.debug_mode: print("debug: call_redraw1")
    wm = bpy.data.window_managers[0]
    text_editor = [a for w in wm.windows for a in w.screen.areas if a.spaces.active]
    i=0
    for b in text_editor:
        if b.type == "TEXT_EDITOR": #will redraw will only work on an open text editor
            i+=1
            if i ==1: #only do it once
                if G.debug_mode: print("debug: call_redraw1: redrawing")
                execute_text1.ok = True
                b.tag_redraw()
                return

def execute_text1(context):  #execute_text1 always listen for execute_text1.ok, if True, -> make false and executing code or err
    G = bpy.context.scene.SCR_OT_group
    if G.debug_mode: print("debug: execute_text1: trying execution")
    st = getattr(context, 'space_data', None)
    if not execute_text1.ok or not st: #will not trigger execution if no context nor 
        return
    execute_text1.ok = False
    if G.debug_mode: print("debug: execute_text1: starting exec def")
    exec_script(bpy.context.scene.SCR_OT_group.path_01)

#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-
#                                path_02
#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-

def poll_text2():  #main timer, check if text changed, will trigger ui redraw
    G      = bpy.context.scene.SCR_OT_group
    G_path = G.path_02
    G_name = os.path.basename(G_path)
    if G.debug_mode: print("debug: poll_text2: check")

    if os.path.exists(G_path):
        mtime = os.path.getmtime(G_path)
        if mtime != bpy.context.scene["scr_index_02"]:
            if G.debug_mode: print("debug: poll_text2: not same file ! is EXECUTE in first line?")
            bpy.context.scene["scr_index_02"] = mtime
            file = open(G_path) ; line_o = file.readline() ; file.close()
            if "EXECUTE" in line_o: #if key word not in first line
                if G.debug_mode: print("debug: poll_text2: EXECUTE in first line, call for redraw")
                call_redraw2()
            elif "STOP" in line_o: bpy.ops.scr.stop_link(index=2)
    return 0.5

def call_redraw2(): #once txt changed, UI redrawed, and exexute_text.ok attribute is ok,  triggering execute_text2 
    G = bpy.context.scene.SCR_OT_group
    if G.debug_mode: print("debug: call_redraw2")
    wm = bpy.data.window_managers[0]
    text_editor = [a for w in wm.windows for a in w.screen.areas if a.spaces.active]
    i=0
    for b in text_editor:
        if b.type == "TEXT_EDITOR": #will redraw will only work on an open text editor
            i+=1
            if i ==1: #only do it once
                if G.debug_mode: print("debug: call_redraw2: redrawing")
                execute_text2.ok = True
                b.tag_redraw()
                return

def execute_text2(context):  #execute_text2 always listen for execute_text2.ok, if True, -> make false and executing code or err
    G = bpy.context.scene.SCR_OT_group
    if G.debug_mode: print("debug: execute_text2: trying execution")
    st = getattr(context, 'space_data', None)
    if not execute_text2.ok or not st: #will not trigger execution if no context nor 
        return
    execute_text2.ok = False
    if G.debug_mode: print("debug: execute_text2: starting exec def")
    exec_script(bpy.context.scene.SCR_OT_group.path_02)

#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-
#                                path_03
#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-

def poll_text3():  #main timer, check if text changed, will trigger ui redraw
    G      = bpy.context.scene.SCR_OT_group
    G_path = G.path_03
    G_name = os.path.basename(G_path)
    if G.debug_mode: print("debug: poll_text3: check")

    if os.path.exists(G_path):
        mtime = os.path.getmtime(G_path)
        if mtime != bpy.context.scene["scr_index_03"]:
            bpy.context.scene["scr_index_03"] = mtime
            if G.debug_mode: print("debug: poll_text3: not same file ! is EXECUTE in first line?")
            file = open(G_path) ; line_o = file.readline() ; file.close()
            if "EXECUTE" in line_o: #if key word not in first line
                if G.debug_mode: print("debug: poll_text3: EXECUTE in first line, call for redraw")
                call_redraw3()
            elif "STOP" in line_o: bpy.ops.scr.stop_link(index=3)
    return 0.5

def call_redraw3(): #once txt changed, UI redrawed, and exexute_text.ok attribute is ok,  triggering execute_text3 
    G = bpy.context.scene.SCR_OT_group
    if G.debug_mode: print("debug: call_redraw3")
    wm = bpy.data.window_managers[0]
    text_editor = [a for w in wm.windows for a in w.screen.areas if a.spaces.active]
    i=0
    for b in text_editor:
        if b.type == "TEXT_EDITOR": #will redraw will only work on an open text editor
            i+=1
            if i ==1: #only do it once
                if G.debug_mode: print("debug: call_redraw3: redrawing")
                execute_text3.ok = True
                b.tag_redraw()
                return

def execute_text3(context):  #execute_text3 always listen for execute_text3.ok, if True, -> make false and executing code or err
    G = bpy.context.scene.SCR_OT_group
    if G.debug_mode: print("debug: execute_text3: trying execution")
    st = getattr(context, 'space_data', None)
    if not execute_text3.ok or not st: #will not trigger execution if no context nor 
        return
    execute_text3.ok = False
    if G.debug_mode: print("debug: execute_text3: starting exec def")
    exec_script(bpy.context.scene.SCR_OT_group.path_03)

################################################################################
#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-
#                                  DEF
#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-
################################################################################

def exec_script(G_path):
    G        = bpy.context.scene.SCR_OT_group
    G_name   = os.path.basename(G_path)
    line_one = open(G_path).readline() #make def out of this
    file     = open(G_path)
    if G.debug_mode: print("debug: exec_script: is custom?")

    try:
        if "EXECUTE_CUSTOM" in line_one:
            script_cut = ""
            i=0
            start_cut=False
            start_cut_index=0
            for line in file:
                i+=1
                if "EXECUTE_STOP" in line:
                    start_cut = False
                if start_cut == True:
                    script_cut+=line[start_cut_index:]
                if "EXECUTE_START" in line:
                    start_cut = True
                    start_cut_index = line.index("#")
            if script_cut == "":
                print(script_cut)
                print("[LIVE-LINK MESSAGE: wrong usage of #EXECUTE_CUSTOM, you need #EXECUTE_START and #EXECUTE_STOP as boundaries at least once]")
                return None

            if G.debug_mode: print("debug: exec_script: starting custom exec")
            new_file_name = G_name[:-3] + "_script_cut.py"
            new_file      = os.path.dirname(G_path)+'\\' + new_file_name
            new = open(new_file, "w") ; new.write(script_cut) ; new.close() 
            file.close()
            if G.debug_mode: print("debug: exec_script: file created, is it empty")

            if G.print_message_on_exec == True: print(" ") ; print("[LIVE-LINK MESSAGE: executing " + new_file_name+"] #EXECUTE_CUSTOM")
            bpy.ops.script.python_file_run(filepath=new_file) #BUG_HERE: this print 2x the error for some reasons? annoying but not game-breaking

        else: #Then run whole script
            if G.print_message_on_exec == True: print(" ") ; print("[LIVE-LINK MESSAGE: executing " + G_name+"] #EXECUTE")
            bpy.ops.script.python_file_run(filepath=G_path) #BUG_HERE: 

    except Exception as err: 
        print("[LIVE-LINK MESSAGE: your script '" + G_name+"' Failed]") ; print(err)


def show_message_box(message="",message2="",title="",icon='INFO'):
    def draw(self,context):
        self.layout.label(text=message)
        self.layout.label(text=message2)
    bpy.context.window_manager.popup_menu(draw,title=title,icon=icon)

################################################################################
#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-
#                                OPERATORS
#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-
################################################################################

class SCR_OT_link(bpy.types.Operator):
    bl_idname      = "scr.link"
    bl_label       = ""
    bl_description = ""

    index : bpy.props.IntProperty()
    def execute(self, context):
        index  = self.index
        G      = bpy.context.scene.SCR_OT_group
        if index ==1:
            G_path=G.path_01
            bpy.context.scene["scr_index_01"] = os.path.getmtime(G_path)
            bpy.context.scene["scr_index_01_check"] = True
            if G.debug_mode: print("debug: start operator: ","index:"+str(index), " path:"+G_path, " time:"+str(bpy.context.scene["scr_index_01"]))
        if index ==2:
            G_path=G.path_02
            bpy.context.scene["scr_index_02"] = os.path.getmtime(G_path)
            bpy.context.scene["scr_index_02_check"] = True
            if G.debug_mode: print("debug: start operator: ","index:"+str(index), " path:"+G_path, " time:"+str(bpy.context.scene["scr_index_02"]))
        if index ==3:
            G_path=G.path_03
            bpy.context.scene["scr_index_03"] = os.path.getmtime(G_path)
            bpy.context.scene["scr_index_03_check"] = True
            if G.debug_mode: print("debug: start operator: ","index:"+str(index), " path:"+G_path, " time:"+str(bpy.context.scene["scr_index_03"]))
        G_name = os.path.basename(G_path)

        print("[LIVE-LINK MESSAGE: starting livelink for: "+G_name+"]")
        if index ==1:
            add = bpy.types.SpaceTextEditor.draw_handler_add
            bpy.app.timers.register(lambda: setattr(register,"execute_text1", add(execute_text1, (getattr(bpy, 'context'),), 'WINDOW', 'POST_PIXEL')), first_interval=0.1)
            bpy.app.timers.register(poll_text1)
        if index ==2:
            add = bpy.types.SpaceTextEditor.draw_handler_add
            bpy.app.timers.register(lambda: setattr(register,"execute_text2", add(execute_text2, (getattr(bpy, 'context'),), 'WINDOW', 'POST_PIXEL')), first_interval=0.1)
            bpy.app.timers.register(poll_text2)
        if index ==3:
            add = bpy.types.SpaceTextEditor.draw_handler_add
            bpy.app.timers.register(lambda: setattr(register,"execute_text3", add(execute_text3, (getattr(bpy, 'context'),), 'WINDOW', 'POST_PIXEL')), first_interval=0.1)
            bpy.app.timers.register(poll_text3)
        return {'FINISHED'}
    
class SCR_OT_stop_link(bpy.types.Operator):
    bl_idname      = "scr.stop_link"
    bl_label       = ""
    bl_description = ""

    index : bpy.props.IntProperty() 
    def execute(self, context):
        index  = self.index
        G      = bpy.context.scene.SCR_OT_group
        if index ==1:
            G_path=G.path_01
            bpy.context.scene["scr_index_01_check"] = False
        if index ==2:
            G_path=G.path_02
            bpy.context.scene["scr_index_02_check"] = False
        if index ==3:
            G_path=G.path_03
            bpy.context.scene["scr_index_03_check"] = False
        G_name = os.path.basename(G_path)

        if G.debug_mode: print("debug: stop operator: ","index:"+str(index), " path:"+G_path)

        print("[LIVE-LINK MESSAGE: stopping livelink for: "+G_name+"]")
        if index ==1:
            bpy.app.timers.unregister(poll_text1)
            bpy.types.SpaceTextEditor.draw_handler_remove(register.execute_text1, 'WINDOW')
        if index ==2:
            bpy.app.timers.unregister(poll_text2)
            bpy.types.SpaceTextEditor.draw_handler_remove(register.execute_text2, 'WINDOW')
        if index ==3:
            bpy.app.timers.unregister(poll_text3)
            bpy.types.SpaceTextEditor.draw_handler_remove(register.execute_text3, 'WINDOW')
        return {'FINISHED'}

#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-

class SCR_OT_run(bpy.types.Operator):
    bl_idname      = "scr.run"
    bl_label       = ""
    bl_description = "execute"
    index : bpy.props.IntProperty() 
    def execute(self, context):
        index  = self.index
        G      = bpy.context.scene.SCR_OT_group
        if index ==1: G_path = G.path_01
        if index ==2: G_path = G.path_02
        if index ==3: G_path = G.path_03
        G_name = os.path.basename(G_path)
        exec_script(G_path)
        return {'FINISHED'}

#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#- #ADDON RELOADER


class SCR_OT_addon_reloader(bpy.types.Operator):
    bl_idname      = "scr.addon_reloader"
    bl_label       = ""
    bl_description = ""
    
    def execute(self, context):
        G            = bpy.context.scene.SCR_OT_group
        Addon_Path   = G.addon_path
        Addon_module = os.path.basename(Addon_Path)[:-3]
        for add in bpy.context.preferences.addons:
            if add.module == Addon_module:
                bpy.ops.preferences.addon_remove(module=Addon_module)
        bpy.ops.preferences.addon_install(overwrite=True, target='DEFAULT', filepath=Addon_Path, filter_folder=True, filter_python=True, filter_glob="*.py;*.zip")
        try:
            bpy.ops.preferences.addon_enable(module=Addon_module)
        except:
            bpy.ops.preferences.addon_enable(module=Addon_module) #some error work only first
        return {'FINISHED'}


################################################################################
#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-
#                                     DRAW
#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-
################################################################################

class SCR_PT_panel(bpy.types.Panel):
    bl_space_type  = 'TEXT_EDITOR'
    bl_region_type = 'UI'
    bl_category    = "Live-Link"
    bl_label       = "Scripts Live-Link"

    def draw(self, context):
        layout     = self.layout
        G          = bpy.context.scene.SCR_OT_group

        main_box   = layout.column(align=True)
        first_row  = main_box.column(align=True)
        second_row = main_box.row(align=True)
        G_path     = G.path_01
        G_name     = os.path.basename(G_path)
        if G_name != "":
            title           = first_row.row()
            title.label(text=' ')
            title.label(text=G_name[:-3])
            title.label(text=' ')
        first_row.prop(G, "path_01",text="")
        if G_path[-3:] ==".py":
            second_row.operator(SCR_OT_run.bl_idname, text='Execute',icon="CONSOLE").index = 1
            if "scr_index_01_check" not in bpy.context.scene:
                second_row.operator(SCR_OT_link.bl_idname, text="Start Live-Link",icon="PASTEDOWN").index = 1
            elif bpy.context.scene["scr_index_01_check"] == False:
                second_row.operator(SCR_OT_link.bl_idname, text="Start Live-Link",icon="PASTEDOWN").index = 1
            elif bpy.context.scene["scr_index_01_check"] == True:
                second_row.operator(SCR_OT_stop_link.bl_idname, text="Stop Live-Link",icon="PANEL_CLOSE").index = 1
        layout.separator(factor=0.6)

        main_box   = layout.column(align=True)
        first_row  = main_box.column(align=True)
        second_row = main_box.row(align=True)
        G_path     = G.path_02
        G_name     = os.path.basename(G_path)
        if G_name != "":
            title           = first_row.row()
            title.label(text=' ')
            title.label(text=G_name[:-3])
            title.label(text=' ')
        first_row.prop(G, "path_02",text="")
        if G_path[-3:] ==".py":
            second_row.operator(SCR_OT_run.bl_idname, text='Execute',icon="CONSOLE").index = 2
            if "scr_index_02_check" not in bpy.context.scene:
                second_row.operator(SCR_OT_link.bl_idname, text="Start Live-Link",icon="PASTEDOWN").index = 2
            elif bpy.context.scene["scr_index_02_check"] == False:
                second_row.operator(SCR_OT_link.bl_idname, text="Start Live-Link",icon="PASTEDOWN").index = 2
            elif bpy.context.scene["scr_index_02_check"] == True:
                second_row.operator(SCR_OT_stop_link.bl_idname, text="Stop Live-Link",icon="PANEL_CLOSE").index = 2
        layout.separator(factor=0.6)

        main_box   = layout.column(align=True)
        first_row  = main_box.column(align=True)
        second_row = main_box.row(align=True)
        G_path     = G.path_03
        G_name     = os.path.basename(G_path)
        if G_name != "":
            title           = first_row.row()
            title.label(text=' ')
            title.label(text=G_name[:-3])
            title.label(text=' ')
        first_row.prop(G, "path_03",text="")
        if G_path[-3:] ==".py":
            second_row.operator(SCR_OT_run.bl_idname, text='Execute',icon="CONSOLE").index = 3
            if "scr_index_03_check" not in bpy.context.scene:
                second_row.operator(SCR_OT_link.bl_idname, text="Start Live-Link",icon="PASTEDOWN").index = 3
            elif bpy.context.scene["scr_index_03_check"] == False:
                second_row.operator(SCR_OT_link.bl_idname, text="Start Live-Link",icon="PASTEDOWN").index = 3
            elif bpy.context.scene["scr_index_03_check"] == True:
                second_row.operator(SCR_OT_stop_link.bl_idname, text="Stop Live-Link",icon="PANEL_CLOSE").index = 3
        layout.separator(factor=1.1)

        col = layout.column(align=False)
        col.prop(G, "print_message_on_exec")#icon='CHECKBOX_HLT')
        col.prop(G, "debug_mode")#icon='CHECKBOX_HLT')
        col.operator('wm.url_open', text="FAQ, Official Thread", icon='INFO').url = "https://blenderartists.org/t/scripting-live-link/1182392"
        

#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-

class SCR_PT_panel_add(bpy.types.Panel):
    bl_space_type  = 'TEXT_EDITOR'
    bl_region_type = 'UI'
    bl_category    = "Live-Link"
    bl_label       = "Addon Reloader"

    def draw(self, context):
        layout = self.layout
        col    = layout.column(align=True)
        coll   = col.column(align=True)
        coll.prop(bpy.context.scene.SCR_OT_group,"addon_path",text="")
        if bpy.context.scene.SCR_OT_group.addon_path != "":
            if bpy.context.scene.SCR_OT_group.addon_path[-3:] == ".py":
                col.operator(SCR_OT_addon_reloader.bl_idname, text="Reload Addon",icon="FILE_REFRESH")

################################################################################
#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-
#                                     REG
#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-
################################################################################

class SCR_OT_group(bpy.types.PropertyGroup):
    print_message_on_exec : bpy.props.BoolProperty(name="print info msg before exec",subtype='NONE',default=True)
    debug_mode : bpy.props.BoolProperty(name="'script-livelink' debug info",subtype='NONE',default=False)

    path_01    : bpy.props.StringProperty(name=" ",subtype='FILE_PATH',default=r"‪")
    path_02    : bpy.props.StringProperty(name=" ",subtype='FILE_PATH',default=r"‪")
    path_03    : bpy.props.StringProperty(name=" ",subtype='FILE_PATH',default=r"‪")
    addon_path : bpy.props.StringProperty(name=" ",subtype='FILE_PATH',default=r"‪")

#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-

sc_classes = {
    SCR_OT_group,
    SCR_PT_panel,
    SCR_PT_panel_add,
    SCR_OT_link,
    SCR_OT_stop_link,
    SCR_OT_addon_reloader,
    SCR_OT_run,
}

def register():
    for cls in sc_classes : bpy.utils.register_class(cls)
    bpy.types.Scene.SCR_OT_group = bpy.props.PointerProperty(type=SCR_OT_group)
    execute_text1.ok = False
    execute_text2.ok = False
    execute_text3.ok = False

def unregister():
    for cls in sc_classes : bpy.utils.unregister_class(cls)
    if "scr_index_01_check" in bpy.context.scene:
        if bpy.context.scene["scr_index_01_check"] == True:
            bpy.app.timers.unregister(poll_text1)
            bpy.types.SpaceTextEditor.draw_handler_remove(register.execute_text1, 'WINDOW')
    if "scr_index_02_check" in bpy.context.scene:
        if bpy.context.scene["scr_index_02_check"] == True:
            bpy.app.timers.unregister(poll_text2)
            bpy.types.SpaceTextEditor.draw_handler_remove(register.execute_text2, 'WINDOW')
    if "scr_index_03_check" in bpy.context.scene:
        if bpy.context.scene["scr_index_03_check"] == True:
            bpy.app.timers.unregister(poll_text3)
            bpy.types.SpaceTextEditor.draw_handler_remove(register.execute_text3, 'WINDOW')

if __name__ == "__main__":
    register()