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
from bpy.types import Menu, Panel, Operator, PropertyGroup, Operator, AddonPreferences, PropertyGroup
from bpy.props import StringProperty, IntProperty, BoolProperty, FloatProperty, EnumProperty, PointerProperty
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
    #print("poll_text1") #FOR_TESTING_PURPOSE
    G      = bpy.context.scene.SCR_OT_group
    G_path = G.path_01
    G_name = os.path.basename(G_path)

    if os.path.exists(G_path):
        mtime = os.path.getmtime(G_path)
        if mtime != bpy.context.scene[G_name]:
            bpy.context.scene[os.path.basename(G_path)] = mtime
            if "EXECUTE" in open(G_path).readline(): #if key word not in first line
                call_redraw1()
    return 0.5

def call_redraw1(): #once txt changed, UI redrawed, and exexute_text.ok attribute is ok,  triggering execute_text1 
    #print("call_redraw1") #FOR_TESTING_PURPOSE
    wm = bpy.data.window_managers[0]
    text_editor = [a for w in wm.windows for a in w.screen.areas if a.spaces.active]
    i=0
    for b in text_editor:
        if b.type == "TEXT_EDITOR": #will redraw will only work on an open text editor
            i+=1
            if i ==1: #only do it once
                #print("redrawing") #FOR_TESTING_PURPOSE
                execute_text1.ok = True
                b.tag_redraw()
                return

def execute_text1(context):  #execute_text1 always listen for execute_text1.ok, if True, -> make false and executing code or err
    #print("execute_text1") #FOR_TESTING_PURPOSE
    st = getattr(context, 'space_data', None)
    if not execute_text1.ok or not st: #will not trigger execution if no context nor 
        return
    execute_text1.ok = False
    exec_script(bpy.context.scene.SCR_OT_group.path_01)

#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-
#                                path_02
#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-

def poll_text2():  #main timer, check if text changed, will trigger ui redraw
    #print("poll_text2") #FOR_TESTING_PURPOSE
    G      = bpy.context.scene.SCR_OT_group
    G_path = G.path_02
    G_name = os.path.basename(G_path)

    if os.path.exists(G_path):
        mtime = os.path.getmtime(G_path)
        if mtime != bpy.context.scene[G_name]:
            bpy.context.scene[os.path.basename(G_path)] = mtime
            if "EXECUTE" in open(G_path).readline(): #if key word not in first line
                call_redraw2()
    return 0.5

def call_redraw2(): #once txt changed, UI redrawed, and exexute_text.ok attribute is ok,  triggering execute_text2 
    #print("call_redraw2") #FOR_TESTING_PURPOSE
    wm = bpy.data.window_managers[0]
    text_editor = [a for w in wm.windows for a in w.screen.areas if a.spaces.active]
    i=0
    for b in text_editor:
        if b.type == "TEXT_EDITOR": #will redraw will only work on an open text editor
            i+=1
            if i ==1: #only do it once
                #print("redrawing") #FOR_TESTING_PURPOSE
                execute_text2.ok = True
                b.tag_redraw()
                return

def execute_text2(context):  #execute_text2 always listen for execute_text2.ok, if True, -> make false and executing code or err
    #print("execute_text2") #FOR_TESTING_PURPOSE
    st = getattr(context, 'space_data', None)
    if not execute_text2.ok or not st: #will not trigger execution if no context nor 
        return
    execute_text2.ok = False
    exec_script(bpy.context.scene.SCR_OT_group.path_02)

#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-
#                                path_03
#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-

def poll_text3():  #main timer, check if text changed, will trigger ui redraw
    #print("poll_text3") #FOR_TESTING_PURPOSE
    G      = bpy.context.scene.SCR_OT_group
    G_path = G.path_03
    G_name = os.path.basename(G_path)

    if os.path.exists(G_path):
        mtime = os.path.getmtime(G_path)
        if mtime != bpy.context.scene[G_name]:
            bpy.context.scene[os.path.basename(G_path)] = mtime
            if "EXECUTE" in open(G_path).readline(): #if key word not in first line
                call_redraw3()
    return 0.5

def call_redraw3(): #once txt changed, UI redrawed, and exexute_text.ok attribute is ok,  triggering execute_text3 
    #print("call_redraw3") #FOR_TESTING_PURPOSE
    wm = bpy.data.window_managers[0]
    text_editor = [a for w in wm.windows for a in w.screen.areas if a.spaces.active]
    i=0
    for b in text_editor:
        if b.type == "TEXT_EDITOR": #will redraw will only work on an open text editor
            i+=1
            if i ==1: #only do it once
                #print("redrawing") #FOR_TESTING_PURPOSE
                execute_text3.ok = True
                b.tag_redraw()
                return

def execute_text3(context):  #execute_text3 always listen for execute_text3.ok, if True, -> make false and executing code or err
    #print("execute_text3") #FOR_TESTING_PURPOSE
    st = getattr(context, 'space_data', None)
    if not execute_text3.ok or not st: #will not trigger execution if no context nor 
        return
    execute_text3.ok = False
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
    in_brack = re.findall(r'\[(.*?)\]', line_one)

    try:
        if len(in_brack) >0:
            custom_msg = script_cut = ""
            if len(in_brack) >= 1 :
                if ":" in in_brack[0] : fp1 , fp2 = int(in_brack[0][:in_brack[0].index(":")]) , int(in_brack[0][in_brack[0].index(":")+1:]) #of course it is
                if ":" not in in_brack[0] : fp1 = fp2 = int(in_brack[0])
                custom_msg+="["+in_brack[0]+"] "
            if len(in_brack) >  1 :
                if ":" in in_brack[1] : sp1 , sp2 = int(in_brack[1][:in_brack[1].index(":")]) , int(in_brack[1][in_brack[1].index(":")+1:])
                if ":" not in in_brack[1] : sp1 = sp2 = int(in_brack[1])
                custom_msg+="["+in_brack[1]+"] "
            if len(in_brack) >  2 :
                if ":" in in_brack[2] : tp1 , tp2 = int(in_brack[2][:in_brack[2].index(":")]) , int(in_brack[2][in_brack[2].index(":")+1:])
                if ":" not in in_brack[2] : tp1 = tp2 = int(in_brack[2])
                custom_msg+="["+in_brack[2]+"] "
            if len(in_brack) >  3 :
                if ":" in in_brack[3] : qp1 , qp2 = int(in_brack[3][:in_brack[3].index(":")]) , int(in_brack[3][in_brack[3].index(":")+1:])
                if ":" not in in_brack[3] : qp1 = qp2 = int(in_brack[3])
                custom_msg+="["+in_brack[3]+"] "
            if len(in_brack) >  4 : print("[LIVE-LINK MESSAGE: more than 4 brackets are not supported]")

            i=0
            for line in file:
                i+=1
                if len(in_brack) >= 1 :
                    if fp1>fp2:fp1,fp2=fp2,fp1 #if user_idiot == True: reverse_for_him()
                    if (i >=fp1 and i <=fp2): script_cut+=line
                if len(in_brack) >  1 :
                    if sp1>sp2:sp1,sp2=sp2,sp1
                    if (i >=sp1 and i <=sp2): script_cut+=line
                if len(in_brack) >  2 :
                    if tp1>tp2:tp1,tp2=tp2,tp1
                    if (i >=tp1 and i <=tp2): script_cut+=line
                if len(in_brack) >  3 :
                    if qp1>qp2:qp1,qp2=qp2,qp1
                    if (i >=qp1 and i <=qp2): script_cut+=line

            new_file_name = G_name[:-3] + "_script_cut.py"
            new_file      = os.path.dirname(G_path)+'\\' + new_file_name
            new = open(new_file, "w") ; new.write(script_cut) ; new.close() #was forced to do this, exec() don't work for addon reg
            file.close()

            if G.print_message_on_exec == True: print(" ") ; print("[LIVE-LINK MESSAGE: executing " + new_file_name+"] "+custom_msg)
            bpy.ops.script.python_file_run(filepath=new_file) #BUG_HERE: this print 2x the error for some reasons? annoying but not game-breaking

        if len(in_brack) ==0: #Then run whole script

            if G.print_message_on_exec == True: print(" ") ; print("[LIVE-LINK MESSAGE: executing " + G_name+"]")
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
        if index ==1: G_path=G.path_01
        if index ==2: G_path=G.path_02
        if index ==3: G_path=G.path_03
        G_name = os.path.basename(G_path)
        bpy.context.scene[G_name]          = os.path.getmtime(G_path)
        bpy.context.scene[G_name+" check"] = True

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
        if index ==1: G_path=G.path_01
        if index ==2: G_path=G.path_02
        if index ==3: G_path=G.path_03
        G_name = os.path.basename(G_path)

        print("[LIVE-LINK MESSAGE: stopping livelink for: "+G_name+"]")
        bpy.context.scene[G_name+" check"] = False
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

class SCR_PT_panel(Panel):
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
            if G_name+" check" not in bpy.context.scene:
                second_row.operator(SCR_OT_link.bl_idname, text="Start Live-Link",icon="PASTEDOWN").index = 1
            elif bpy.context.scene[G_name+" check"] == False:
                second_row.operator(SCR_OT_link.bl_idname, text="Start Live-Link",icon="PASTEDOWN").index = 1
            elif bpy.context.scene[G_name+" check"] == True:
                second_row.operator(SCR_OT_stop_link.bl_idname, text="Stop Live-Link",icon="PANEL_CLOSE").index = 1
        layout.separator()

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
            if G_name+" check" not in bpy.context.scene:
                second_row.operator(SCR_OT_link.bl_idname, text="Start Live-Link",icon="PASTEDOWN").index = 2
            elif bpy.context.scene[G_name+" check"] == False:
                second_row.operator(SCR_OT_link.bl_idname, text="Start Live-Link",icon="PASTEDOWN").index = 2
            elif bpy.context.scene[G_name+" check"] == True:
                second_row.operator(SCR_OT_stop_link.bl_idname, text="Stop Live-Link",icon="PANEL_CLOSE").index = 2
        layout.separator()

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
            if G_name+" check" not in bpy.context.scene:
                second_row.operator(SCR_OT_link.bl_idname, text="Start Live-Link",icon="PASTEDOWN").index = 3
            elif bpy.context.scene[G_name+" check"] == False:
                second_row.operator(SCR_OT_link.bl_idname, text="Start Live-Link",icon="PASTEDOWN").index = 3
            elif bpy.context.scene[G_name+" check"] == True:
                second_row.operator(SCR_OT_stop_link.bl_idname, text="Stop Live-Link",icon="PANEL_CLOSE").index = 3
        layout.separator()

        row = layout.column(align=True)
        row.prop(G, "print_message_on_exec")

#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-

class SCR_PT_panel_add(Panel):
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
    print_message_on_exec : BoolProperty(name="print info msg before exec",subtype='NONE',default=False)
    path_01    : StringProperty(name=" ",subtype='FILE_PATH',default=r"‪")
    path_02    : StringProperty(name=" ",subtype='FILE_PATH',default=r"‪")
    path_03    : StringProperty(name=" ",subtype='FILE_PATH',default=r"‪")
    addon_path : StringProperty(name=" ",subtype='FILE_PATH',default=r"‪")

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
    bpy.app.timers.unregister(poll_text1)
    bpy.app.timers.unregister(poll_text2)
    bpy.app.timers.unregister(poll_text3)
    bpy.types.SpaceTextEditor.draw_handler_remove(register.execute_text1, 'WINDOW')
    bpy.types.SpaceTextEditor.draw_handler_remove(register.execute_text2, 'WINDOW')
    bpy.types.SpaceTextEditor.draw_handler_remove(register.execute_text3, 'WINDOW')

if __name__ == "__main__":
    register()