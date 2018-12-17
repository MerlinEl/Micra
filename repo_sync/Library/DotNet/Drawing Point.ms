p1= [1, 5]
p2 = [28, 49]

points = dotnetObject "Drawing.Point[]" 2
points.Set 0 (dotnetObject "Drawing.Point" 1 5)
points.Set 1 (dotnetObject "Drawing.Point" 28 49)
(points.get 1).y