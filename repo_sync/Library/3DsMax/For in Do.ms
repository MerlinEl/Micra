for i in #(0.02,0.277,0.030,0.488) do if i > 0.1 do exit with i
for i in #(0.02,0.277,0.030,0.488) collect i as string
for i in #(0.02,0.277,0.030,0.488) where i > 0.1 collect i

for p = polyop.getNumFaces $ to 1 by -1 do print (p as string) --reverse continuity
for i in 1 to (polyop.getNumFaces $) do (print i as string) -- normal continuity