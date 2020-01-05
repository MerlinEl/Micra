import mcGetWindow as gw

# initializing dictionary 
test_dict_1 = gw.getWindowsWithTitle('Blender')
for w in test_dict_1:
	print ("title:",w.title)
	
# printing original list 
print("The original dictionary 1: " + str(test_dict_1)) 	

	 
res_1 = [d.title for d in test_dict_1 ]

# print result 
print("The filtered dictionary 1 is :\n\t{}".format( ",\n\t".join(res_1))) 

#~ -----------------------------------------------------------------------------
