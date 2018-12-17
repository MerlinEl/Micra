plugin modifier notesMod
name:"Notes"
classID:#(0x737151d9, 0x6550ff01)
(
    parameters main rollout:rltNotes
    (
        txt type:#string ui:txtNotes
    )
    rollout rltNotes "Notes"
    (
        editText txtNotes "" pos:[0,0] height:200 width:160
        button btnDel "Erase"
 
        on btnDel pressed do txtNotes.text = ""
    )
)
--created by Garp http://www.scriptspot.com/users/garp