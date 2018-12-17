doubleval = dotnetobject "system.double" 48.4133
mc2system.show (dotnetclass "MidpointRounding")
decimalplaces = 0.01
math = (dotnetclass "system.math")
mc2system.show math
math.round (dotnetobject "decimal" 48.4133)
math.round doubleval
math.Floor (dotnetobject "decimal" 48.4133)
math.Ceiling (dotnetobject "decimal" 48.4133)