macroScript setpivotnow
category:"Tool"
buttontext:"set pivot"
tooltip:"pivot to vertex"

(
try($.pivot=(getTransformAxis $ 1).row4)
catch()
)