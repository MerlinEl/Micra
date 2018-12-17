
format "heap size:% MB\n" (heapSize/1000000 as float)

format "heap size:% MB\n" (12680000/1000000) --12 MB
format "heap size:% MB\n" (20000000/1000000) --20 MB

heapSize += 2000000 -- another 2 MB


if heapSize < (30*1000000) do heapSize =  (30*1000000) -- set heap size to 30 MB