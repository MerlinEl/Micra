undo on
(
delete $box*
delete $sphere*
clearUndoBuffer()
)

max undo

clearUndoBuffer()

setSaveRequired <boolean> -- if is undo list empty or not
getSaveRequired()   -- if is undo list empty or not

undo ["undo_item_label" | label:<string_operand> | variable_name ] <bool_expr> <expr>

undo "add background" on
(
...
)

my_context_name = "An Undo Context"
undo my_context_name on

(
...
)



--creates a single undo for spinner drag and type-in
utility foo "foo"
(
	spinner sp "Radius"
	local isspinner = false
	local firstundo = false

	on sp changed val do 
	(
		local useundo = (isspinner and firstundo) or (not isspinner)
		undo "changed" useundo 
		(
			$.radius = val
		)
		firstundo = false
	)
	on sp buttonDown do 
	(
		isspinner = true
		firstundo = true
	)
	
	on sp buttonUp do 
	(
		isspinner = false
	)
)