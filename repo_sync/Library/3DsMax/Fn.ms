fn hiddenobj = 
	(
	a = #()
	for i in $* do
		(
		if i.ishidden == true then append a i
		)
	qsort a name_compare_case_insensitive
	return a
	)

fn unhiddenobj = 
	(
	a = #()
	for i in $* do
		(
		if i.ishidden == false then append a i
		)
	qsort a name_compare_case_insensitive
	return a
	)