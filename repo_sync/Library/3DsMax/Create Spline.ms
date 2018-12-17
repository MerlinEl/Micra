-- Create a single cycle sinewave spline
-- Jim Hawkins www.j-hawkins.com
sinline = splineshape()
addnewspline sinline
knot_interval = 20
sine_amplitude = 100 
for x = 0 to 360 by knot_interval do
(
    y = sine_amplitude * sin(x)
    addknot sinline 1 #smooth #curve [x, y, 0]
)
updateshape sinline 
