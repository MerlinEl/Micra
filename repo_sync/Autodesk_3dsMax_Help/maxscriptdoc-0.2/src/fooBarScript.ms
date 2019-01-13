/*** Foobar Script 

    This is a test for the @module keyword.
    This page should have been reached by a link in the "See Also" section.

    This is also the place to test another case, scripted plugin definition.

    Lorem ipsum, blah blah.

    @module output
    @version 0.1

***/

plUgIn helper Foobar_Helper
name:"FooBar"
classID:#(0x4613b85f, 0x67f1f49)
category:"Standard"
extends:point
replaceUI:true
(
    /***    This is a plugin documentation.
            For now, I completly ignore the plugin definition (name, classID, replaceUI).
            I don't think they really matter in a documentation. 
            However, it uses the extends docParamter.

            @extends Point


    ***/

	local test = 99+5

    fn FoobarFunction =
    (
        /*** You should avoid putting operations in the rollouts "on whatever" clauses, but call functions instead. MaxscriptDoc doesn't process those clauses, you may encounter issues at the documentation generation.

        For example, if you transform "on create do" comment to a docString, the docString will appear as a documentation for FoobarFunction !
        
        ***/
    )

	tool create
	(
		on mousepoint click do
		(
			nodeTM.translation = gridPoint;#stop
		)
	)

	on create do
	(
        /* You should not put operations here. */
		print "on create"
	)

	on clone orig cancelled do
	(

		print "on clone"
		print cancelled
	)

	on attachedtonode nodeName do
	(
		print "on attachedtonode"
	)
)

