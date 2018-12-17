$.verts["vSel_1"] = (polyOp.getVertSelection $.baseobject)


deleteItem $.verts["vSel_1"] 98


--print numbers in set
for i in $.verts["vSel_1"] do print i


--collect numbers feom set to a new array
for i in $.verts["vSel_1"] collect (filterString (i as string) "(:")[2] -- strings


y=for i in $.verts["vSel_1"] collect execute(filterString (i as string) "(:")[2] --integers

---insertItem 2 ($.verts["vSel_1"]) 1 -- not working



				--insertItem
				vSel = for i in $.verts["vSel_1"] collect execute(filterString (i as string) "(:")[2] 
				vSel += (polyOp.getVertSelection $.baseobject)
				$.verts["vSel_1"] = vSel
				select ($.verts["vSel_1"])