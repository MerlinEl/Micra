--------------------------------------------------------------------------------
/* mcSnap by Orien 2019 */
--------------------------------------------------------------------------------
/*
*@Used Structures
	Micra
*
*@Used Objects

*
*/
struct MICRA_SNAP
(
	fn getActiveItems =
	(
		local active = #()
		for i = 1 to snapmode.numOSnaps do
		(
			for j = 1 to (snapmode.getOSnapNumItems i) do
			(
				(if snapmode.getOSnapItemActive i j do active += #(snapmode.getOSnapItemName i j))
			)
		)
		return active
	),
	fn isActive str =
	(
		for i = 1 to snapmode.numOSnaps do
		(
			for j = 1 to (snapmode.getOSnapNumItems i) do
			(
				if str == (snapmode.getOSnapItemName i j) and snapmode.getOSnapItemActive i j == true do return true
			)
		)
		return false
	),
	fn setItems boolean = 
	(
		for i = 1 to snapmode.numOSnaps do
		(
			for j = 1 to (snapmode.getOSnapNumItems i) do
			(
				(snapmode.setOSnapItemActive i j boolean)
			)
		)
	),
	fn enabled arr boolean =
	(
		for a in arr do
		(
			for i = 1 to snapmode.numOSnaps do
			(
				for j = 1 to (snapmode.getOSnapNumItems i) do
				(
					if a == (snapmode.getOSnapItemName i j) do (snapmode.setOSnapItemActive i j boolean)
				)
			)
		)
	)
)
 --create instance
Global mcSnap = Micra.instanceStructure MICRA_SNAP "mcSnap"