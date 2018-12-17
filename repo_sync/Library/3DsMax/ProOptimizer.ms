$.modifiers[#ProOptimizer].Calculate = on



if selection.count == 0 then (MessageBox "Please select at least one object" title:"Error")
     else
     if (selection.count >= 1) do
     (
         FixArray = #()
         for o in selection do
         (--begin for
          if (superclassof o == geometryclass) do 
             (--begin do
                 append FixArray o
             )-- End do
         )-- End For
         c = 1
         while c <= FixArray.count do --do stuff below.
         (--begin do
             addModifier FixArray[c] (ProOptimizer ()) --adds modifier to each object in array
             FixArray[c].modifiers[#ProOptimizer].Calculate = on
             FixArray[c].modifiers[#ProOptimizer].vertexPercent = 40.0 --to visually see that it's worked.
             c += 1
         )--end do
     )