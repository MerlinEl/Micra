--Format



clearListener()
setListenerSel #(0,-1) -- select all the text
x=getListenerSelText() -- get selected textt
edt_1.text = x



debug = newScript()
format "% \n" x to:debug



b2=memStreamMgr.openstring "{aaaaa}"
b2.readblock "{" "}"



ms = memStreamMgr.openString "token! //comment!\n { { nested bracket pair } } "
ms.readToken()
ms.readBlock "{" "}"
memStreamMgr.close ms



ms = memStreamMgr.openString "token! //comment!\n { nested bracket pair } "
ms.readToken()
ms.readBlock "{" "}"
memStreamMgr.close ms