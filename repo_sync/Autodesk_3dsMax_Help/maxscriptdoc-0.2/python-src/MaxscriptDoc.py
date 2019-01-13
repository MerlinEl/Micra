""" MaxscriptDoc parse maxscript files and provides an HTML-doc output.

    It works with a 2pass lexical analysis, using a simplified Pygments 
    RegexLexer class.

    The first one for a quick research of the mxs value, the second one
    to analyse the stringDocs (called from MxsOutputHTML.Process)

    USAGE :

        Using the executable :

            MaxscriptDoc.exe -i inputfile.ms -o output.html

        Using python :

            Add python to system variable PATH
            Add .py to system variable PATHEXT

            MaxscriptDoc.py -i inputfile.ms -o output.html

    TWEAKS :

        The default color palette is ugly as hell.
        You should consider editing mxsdoc.css for your eyes safety

"""

from MaxscriptLexer import MaxscriptLexer, StringDocLexer
from MxsDocString import MxsDocString
from MxsOutputHTML import MxsOutputHTML
from pygments.token import *
import sys, getopt

__author__ = "Laurent 'MrPingouin' Chea"
__license__ = "BSD"
__version__ = "0.2"
__email__ = "contact [at] laurentchea.com"

class MaxscriptDoc:

    def __init__(self, filename, verbose):

        try:
            self.filename = filename
            f = open(filename)
            data = f.read()
            f.close()

            self.mxsLexer = MaxscriptLexer()
            self.docLexer = StringDocLexer()

            tokens = self.mxsLexer.get_tokens(data)

            # List of StringDoc ! 
            self.elements = []

            # We add a mandatory first element, which will contain
            # the module documentation
            self.elements.append(MxsDocString(""))

            self.inDefinition = False
            self.isDefaultValue = False

            self.level = 0

            self.verbose = False

            for ttype, value in tokens:

                if verbose == True:
                    if ttype != Token.Text:
                        print ttype, value

                # OBJECT TYPE

                if ttype == Token.Keyword:

                    value = value.lower()
                    if value == "fn":
                        value = "function"

                    self.elements.append(MxsDocString(value))
                    self.inDefinition = True
                    self.elements[-1].SetLevel(self.level)

                # If value was "plugin", the next keyword is the plugin class
                # We add it to the MxsDocString keyword

                if ttype == Token.Name.Class:
                    self.elements[-1].SetClass(value)

                # OBJECT NAME

                if ttype == Token.Name.Function:
                    self.elements[-1].SetName(value)


                # OPTIONAL OBJECT DOCUMENTATION

                if ttype == Token.Literal.String.Doc:
                    # We take the last item of the list.
                    el = self.elements[-1]

                    docTokens = self.docLexer.get_tokens(value)

                    # The different MxsDocString objects are set 
                    # step-by-step
                    # if the token type is a keyword, 
                    #       we create a new MxsDocString
                    # if it's a Name or Token.StringDoc, 
                    #       we fill the last parameter details

                    for docttype, docvalue in docTokens:

                        if docttype == Token.Keyword:
                            el.AddDocParameter(MxsDocString("@" + docvalue))
                        if docttype == Token.Name:
                            el.GetDocParameters()[-1].SetName(docvalue)
                        if docttype == Token.Literal.String.Doc:
                            el.GetDocParameters()[-1].SetText(docvalue)
                        if docttype == Token.Text:
                            el.AppendText(docvalue)

                    # We know that this text is always surrounded 
                    # by /*** ***/
                    # We first trim the text, then strip the characters

                    el.TrimText()
                    el.SetText(el.GetText()[4:-4])
                    # Now that the final ***/ has been stripped, 
                    # we can still 
                    # trim the text !
                    el.TrimText()

                # HANDLING STATE : FUNCTION

                if ttype == Token.Operator:
                    if value == "=":
                        self.inDefinition = False 

                if ttype == Token.Punctuation:
                    if value == "(":
                        self.level = self.level + 1
                        self.inDefinition = False 

                    elif value == ")":
                        self.level = self.level - 1

                    elif value == ":":
                        if self.inDefinition:
                            self.isDefaultValue = True


                if ttype == Token.Name : 
                    # We're in a function definition, and we still don't 
                    # have encountered any '=' or '('
                    # The token is logically a function parameter

                    # We completely ignore plugin definition (name, classID, extends)
                    # It has nothing to do in a documentation
                
                    if self.elements[-1].GetKeyword()  != "plugin":
                        if self.inDefinition:
                            if self.isDefaultValue:
                                self.isDefaultValue = False
                                self.elements[-1].SetLastParameterDefaultValue(value)
                            else:
                                self.elements[-1].AddParameter(value)
                        
        except:
            print "Unhandled exception : ", sys.exc_info()[0]
            sys.exit(2)
    
    def GetElements(self):
        return self.elements

    def SetVerbose(self, verbose):
        self.verbose = verbose
            
    @staticmethod
    def printHelp():
        print ("MaxscriptDoc v%s\n" % __version__)
        print "USAGE :"
        print "MaxscriptDoc.py -i <inputfile> -o <outputfile> [-v]"
        print "or"
        print "MaxscriptDoc.exe -i <inputfile> -o <outputfile> [-v]"
        print ""
        print "-v : verbose mode, print the lexical analysis"

    
if __name__ == "__main__":

    if len(sys.argv) == 1:
        MaxscriptDoc.printHelp()
        sys.exit()
    else:
        inputfile = ''
        outputfile = ''
        
        try:
            # argv[1:] because we don't need the name of the executable
            opts, args = getopt.getopt(sys.argv[1:], "hvi:o:",
                                       ["inputfile=", "outputfile="])
        except getopt.GetoptError:
            MaxscriptDoc.printHelp()
            sys.exit(2)

        verbose = False

        for opt, arg in opts:
            if opt == "-h":
                MaxscriptDoc.printHelp()
                sys.exit()
            elif opt =="-v":
                verbose = True
            elif opt in ("-i", "--inputfile"):
                inputfile = arg
            elif opt in ("-o", "--outputfile"):
                outputfile = arg

        if inputfile  and outputfile:
            mxsDoc = MaxscriptDoc(inputfile, verbose)
            htmlOutput = MxsOutputHTML(outputfile, inputfile, 
                                       mxsDoc.GetElements())
            htmlOutput.Process()
        else:
            MaxscriptDoc.printHelp()

        sys.exit()

