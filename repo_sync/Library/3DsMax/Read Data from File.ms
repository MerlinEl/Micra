-- This Script will reset your scene, so save before running it
resetMaxFile #noPrompt --reset your scene
s = sphere () --create a scene object (a Sphere)
spaz = s.pos.controller --assign a variable to the object’s position controller

-- Function Definition:
fn AddKeysFromFile ctrl file = -- The ctrl argument is the object's controller track; the file argument is the data file from which position data will be read.
(
    local f = openFile file --A local variable is assigned to the data file
    t=0 --Set the time to 0 before adding keys.
    while (not eof f) do --This starts the loop statement. "While the end of the file has not been reached, do the following..
        (
            local x = addNewKey ctrl t --A local variable holds the built-in addNewKey function, which adds a key to the controller argument at the specified time
            local a = [readValue f,readValue f,readValue f] --A local variable reads the first three values from the data file.
            x.value = a --The XYZ value of the new key is read from the a variable.
            t += 10 --These lines set the time forward at whatever increment the positional data requires. In this case, the increment is 10 frames
        )
    close f --After the end of the file has been reached, close the data file. 
)        

-- EVALUATE FUNCTION        
AddKeysFromFile spaz "infiniti.dat" --Calls the function on the position controller of the sphere, from the infiniti.dat file created earlier.



