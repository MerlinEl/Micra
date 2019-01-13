/***    This is a sample maxscript file that absolutely does nothing.
        It is here to show how an html document file can be automatically generated.

        This __mxsDoc__ is a mix between +javadoc+ syntax (the @ keywords), and +python+ documentation style (triple-quoted """block""" just after a function declaration).
    
        To get everything working correctly, here are some rules :

            - All single lines commentaries are ignored
            - All multiline commentaries are ignored except if they start and end by three ***
            - Those docStrings are always associated to a previous function or struct name
            - The file should directly start with a docString
        
        Formatted this way, the application will be able to generate an HTML documentation.

        **USAGE**

        MaxscriptDoc.py(.exe) -i inputFile.ms -o outputFile.html

        **INFOS**

            - We admit that your script is perfectly running under 3dsmax (i.e. syntax is correct)
            - There's absolutely no check on @url elements, paths can be relative or absolute
            - The different regexps are kinda weak, don't be too harsh with them
            - The links will work only if all the docs are in the same folder (I'm using ./doc, ./src, ./img)
        
        **__TODO__**
        
            - Eventually detect in a stringDoc references to a known element, and make a link

        __**RELEASE NOTES**__
            
            **0.2**
            Add some reST-like syntax (strong, underline, image)
            Sub-functions are now identified
            Plugin definitions should work too

            **0.1**
            First release

        @author Laurent "MrPingouin" Chea
        @url http://www.laurentchea.com
        @version 0.2
        @module fooBarScript.ms

***/


struct myStruct 
(
    /*** This is where we comment __myStruct__.
         Let's try to be more specific.
         Maybe.
         
         @bool valueA  I've decided to comment valueA, and valueC, the remainder is not important. What if the line is kinda long ?
         @string valueC  This value documentation will appear in doc.
    ***/

    /*  Here's a multiline comment, but should not be included in final doc.

    */

    valueA,
    valueB,
    valueC = #(), -- This is a comment about a parameter
    valueD = #{},

    fn helloWorld paramWithLongName paramB par:false=
    (
        /***  This is the comment of functionB. 

              @integer    paramWithLongName  This is paramWithLongName comment.
              @float    paramB  This is paramB comment.
              @bool    par  **Optional** par comment.
              @return   Return true if something, false if not.
        ***/

        return false
        
    ),

    function fooBar =
    (
        /*** No parameters for this function. ***/
    ),

    function SubFuctionTest =
    (
        function SubFuction = 
        (
            /*** Why do you do this to me ? ***/
        )
    )

)

struct SecondStruct (
    /*** Fortunately, each one can uses its favorite writing style.
         The '(' is now placed on the same line, but everything is ok.

    ***/
)

function GlobalEvilDisplayCallback =
(
    /*** Here, a function that is not in a structure.
         It should work too.
    ***/
)

s = "This is correct"
"Unfortunately this is correct too"

rollout R_RolloutName "Test" 
(
    /*** So, hungarian notation or not hungarian notation ?
        Anyway, here's a little test of how an image can be included.
        Using reST standard image directive could be enough.

        image:: ./img/PlaybackViewport02.jpg

        Testing several occurence of image directive.
        I should also translate the url.

        image:: img/scripted_visibility.jpg

    ***/

    button btn_test "buttonName" width:80
)
