				modPanel.getCurrentObject() == $.modifiers[#Edit_Poly]
				((modPanel.getCurrentObject()).getSelection #Vertex as array)
				
				(modPanel.getCurrentObject()).Remove selLevel:#Vertex
				(modPanel.getCurrentObject()).buttonOp #Remove
				
				local curmood = Filters.GetModOrObj()
				if classOf curmood == Edit_Poly do (curmood.buttonOp #Remove)
				curmood.ButtonOp #Collapse