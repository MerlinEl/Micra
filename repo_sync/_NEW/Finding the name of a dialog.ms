Finding the name of a dialog from Maxscript

To get the name of a dialog you'd just look at the window title, so how do you do this from MaxScript?

 

An approach would be to get the list of windows for the 3ds Max application:

maxHWND = windows.getMaxHWND()
maxChildren1 = windows.getChildrenHWND 0
 

Open the dialog (programatically or manually), in this example i'll open the Batchrender dialog like in post closing_the_batch_render_dialog_from_maxscript):

actionMan.executeAction -43434444 "4096" -- Render: Batch Render Dialog Toggle

 

Get the list again:

maxChildren2 = windows.getChildrenHWND 0

 

And then compare the two list and print the different:

for i in maxChildren2 do
(
 f=0
 for j in maxChildren1 do
 (
  if i[5]==j[5] then 
  (
   f=1
  )
 )
 if f==0 then 
 (
  print i
 )
)

And finally you can do what you want with the dialog (here i'll close it like in post closing_the_batch_render_dialog_from_maxscript):


windows.sendMessage t[1] 0x0112 0xF060 0