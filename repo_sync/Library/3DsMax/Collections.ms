AllObjectsNames = objects as array
/*
result:
#($Sphere:Sphere06 @ [-116.897728,13.638180,0.000000], $Sphere:Sphere02 @ [-148.708481,47.601475,0.000000], $Sphere:Sphere11 @ [-154.612549,82.287827,0.000000], $Sphere:Sphere08 @ [-155.350555,91.143913,0.000000], $Sphere:Sphere13 @ [-77.859779,65.313652,0.000000], $Sphere:Sphere01 @ [-119.904808,-67.298782,0.000000], $Sphere:Sphere03 @ [-119.904808,-69.773643,0.000000], $Sphere:Sphere04 @ [-122.267181,-71.461052,0.000000], $Sphere:Sphere05 @ [-130.282364,-63.558380,0.000000], $Sphere:Sphere07 @ [-129.044922,-67.833145,0.000000], $Sphere:Sphere09 @ [-126.345078,-70.757988,0.000000], $Sphere:Sphere10 @ [-122.632774,-62.995911,0.000000], $Sphere:Sphere14 @ [-107.998901,-107.521545,0.000000])
*/
AllObjectsNames = for i in objects collect i
/*
result:
#($Sphere:Sphere06 @ [-116.897728,13.638180,0.000000], $Sphere:Sphere02 @ [-148.708481,47.601475,0.000000], $Sphere:Sphere11 @ [-154.612549,82.287827,0.000000], $Sphere:Sphere08 @ [-155.350555,91.143913,0.000000], $Sphere:Sphere13 @ [-77.859779,65.313652,0.000000], $Sphere:Sphere01 @ [-119.904808,-67.298782,0.000000], $Sphere:Sphere03 @ [-119.904808,-69.773643,0.000000], $Sphere:Sphere04 @ [-122.267181,-71.461052,0.000000], $Sphere:Sphere05 @ [-130.282364,-63.558380,0.000000], $Sphere:Sphere07 @ [-129.044922,-67.833145,0.000000], $Sphere:Sphere09 @ [-126.345078,-70.757988,0.000000], $Sphere:Sphere10 @ [-122.632774,-62.995911,0.000000], $Sphere:Sphere14 @ [-107.998901,-107.521545,0.000000])
*/
AllObjectsNames = (for i in objects collect i.name)
/*
result:
#("Sphere06", "Sphere02", "Sphere11", "Sphere08", "Sphere13", "Sphere01", "Sphere03", "Sphere04", "Sphere05", "Sphere07", "Sphere09", "Sphere10", "Sphere14")
*/
AllObjectsNames = sort (for i in objects collect i.name)
/*
result:
#("Sphere01", "Sphere02", "Sphere03", "Sphere04", "Sphere05", "Sphere06", "Sphere07", "Sphere08", "Sphere09", "Sphere10", "Sphere11", "Sphere13", "Sphere14")
*/
AllObjectsCount = (objects.count)
/*
result:
13
*/
AllObjectsNumbers = (for i in 1 to (objects.count) collect i)
/*
result:
#(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13)
*/
oVisUnsortNum=#{}
for i = 1 to (objects.count) do (oVisUnsortNum[i] = not(objects[i].IsHidden))
oVisUnsortNames = for i in (oVisUnsortNum) collect (objects[i].name)
oVisSortedNum = for i in (oVisUnsortNames) collect (findItem (sort(oName())) i )
