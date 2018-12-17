OLE Automation
==============

releaseAllOLEObjects() --After calling this function, all existing OLE objects become disabled and any attempt to use them further will generate a runtime error
releaseOLEObject <ole_object>

pshop=CreateOLEObject"Photoshop.Application" -- open app

pshop.visible = true -- will make app visible on the desktop

pshop.open "C:\\Windows\\winnt.bmp" -- load image in app

pshop.quit -- close app

pshop.application.name -- get app name













ACTIVEX
=======

rollout rPhotoshop "Photoshop Application"

(

activeXControl ax "Photoshop.Application" height:200 width:300

)

createDialog rPhotoshop 400 400

showProperties rPhotoshop.ax

rPhotoshop.ax.open "d:\\temp\\appledis.jpg"

rPhotoshop.ax.actions[1].name

rPhotoshop.ax.playAction "My Action"