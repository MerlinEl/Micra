The function gc() invokes the garbage collector. 
Normally, the collector runs automatically when available memory runs low, 
so you don't normally need to call it explicitly. 
However, in some situations, it is useful to be able to force a collect to 
ensure a pause due to garbage collection will be delayed as long as possible.

You can also invoke the collector to cause any unreferenced open files to be closed. 
In some situations, a file can be left open if a runtime error occurs while it is still open. 
If the file object was being held in a local variable at this point, it may not be possible to 
get at it from the Listener to force a close. 
Any subsequent attempts to open it may result in an "already open" error from the operating system. 
Running the collector will cause the file object to be reclaimed and this forces any open file 
associated with it to be closed.

gc [light:false] [delayed:false]
