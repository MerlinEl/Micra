import re
import datetime
import sys
import StringIO

class MxsOutputHTML:
    """ MxsOutputHTML needs two arguments :
            - an output file path
            - a list of stringDocs returned by MaxscriptDoc class

    """

    filename = None

    italicRe = re.compile('[+](.*?)[+]')
    underlineRe = re.compile('__.*__')
    strongRe = re.compile('[*]{2}(.*)[*]{2}')
    imgRe = re.compile('(image::[ ]+(?P<url>.*))')

    def __init__(self, filename, srcFilename, elements):
        self.filename = filename
        self.srcFilename = srcFilename
        self.elements = elements

    
    def TranslateReSTLike(self, s):
        """ This is where we interpret the style of the docString.
            Using a syntax like reST one.
            We also perform the nl2br part here.

        """

        try:
            if s != None:

                if self.imgRe.search(s):
                    s =  re.sub(r'image::[ ]+(.*)', """<img src="\\1" />""", s, flags=re.MULTILINE)
                if self.strongRe.search(s):
                    s = re.sub(r'[*]{2}(.*?)[*]{2}', "<strong>\\1</strong>", s)

                if self.underlineRe.search(s):
                    s = re.sub(r'__(.*?)__', "<u>\\1</u>", s)

                if self.italicRe.search(s):
                    s = re.sub(r'[+](.*?)[+]', "<i>\\1</i>", s)

                s = s.replace('\n','<br/>\n')
                s = s.replace('\t','<span class="tabulation\">&nbsp;</span>\n')

                return s

            return ""

        except:
            print "unhandled exception : ", sys.exc_info()[0]

    def Process(self):
        """ This is where we write the documentation formatted as an HTML
            doc to the specified outputfile.

            The 2nd lexical analysis pass occurs here.

        """

        output = open(self.filename, "w+")

        headBlock = StringIO.StringIO()
        tocBlock = StringIO.StringIO()
        pageBlock = StringIO.StringIO()
        footerBlock = StringIO.StringIO()
        externalModuleBlock = StringIO.StringIO()
        infoBlock = StringIO.StringIO()

        # HTML HEADERS

        headBlock.write("<html>\n")
        headBlock.write("\t<head>\n")
        headBlock.write("""\t\t<link rel="stylesheet" type="text/css" href="mxsdoc.css"/>\n""")
        headBlock.write("\t</head>\n")
        headBlock.write("\t<body>\n")

        # We use div "main" to center the doc.
        
        headBlock.write("""\t\t<div id="main">\n""")

        # TABLE OF CONTENTS

        tocBlock.write("""\t\t\t<div id="toc">\n""")

        tocBlock.write("\t\t\t\t<h1>Table Of Contents</h1>\n")
        tocBlock.write("\t\t\t\t<ul>\n")

        # We skip the first element (what I call the "module documentation")

        for el in self.elements[1:]:
            s = el.GetName()
            level = el.GetLevel()
            cssLevel = ("class=\"tocSub%s\"" % level)

            tocBlock.write("""\t\t\t\t\t<li %s><a href="#%s">%s</a></li>\n""" % (cssLevel, s,s))

        tocBlock.write("\t\t\t\t</ul>\n")
        tocBlock.write("\t\t\t\t<h1>See also</h1>\n")
        tocBlock.write("\t\t\t\t<ul>\n")
        tocBlock.write("__EXTERNAL_MODULE_PLACEHOLDER__")
        tocBlock.write("\t\t\t\t</ul>\n")

        # LINK TO THE SOURCE CODE

        tocBlock.write("\t\t\t\t<h1>Infos</h1>\n")
        tocBlock.write("__INFO_BLOCK_PLACEHOLDER__")
        tocBlock.write("""\t\t\t\t<p class="moduleInfo"><span class="keyword">Source</span><span class="value"><a href="%s" target="_blank">%s</a></span></p>\n""" % (self.srcFilename, self.srcFilename))

        now = datetime.datetime.now()
        datestr = ("%d-%d-%d @ %d:%d" % (now.year, now.month, now.day, now.hour, now.minute))

        tocBlock.write("""\t\t\t\t<p class="moduleInfo"><span class="keyword">Doc generation</span><span class="value">%s</span></p>\n""" % datestr)
        tocBlock.write("""\t\t\t</div>\n""")

        # MODULE MAIN DOCUMENTATION

        pageBlock.write("""\t\t\t<div id="page">\n""")

        # FIXME : Make a better check ?

        el = self.elements[0]

        doc = el.GetText()
        doc = self.TranslateReSTLike(doc)
        pageBlock.write("""\t\t\t<div id="moduleDoc">\n""")
        pageBlock.write("""\t\t\t\t<h1>%s</h1>\n""" % self.srcFilename)
        pageBlock.write("""\t\t\t\t<p>%s</p>\n""" % doc)
        
        # Some parameters have a name (a variable for example)
        # And some don't (@url, @return)

        for p in el.GetDocParameters():

            # Parameter with a name
            if p.GetName() != None:
                pageBlock.write("""<p class="tokenParam"><span class="keyword">%s</span> <span class="name">%s</span> <span class="text">%s</span></p>\n""" % (p.GetKeyword(), p.GetName(), p.GetText()))

            # Parameter with no name
            else:
                k = p.GetKeyword()
                v = p.GetText()

                if k == "@url":
                    infoBlock.write("""\t\t\t\t<p class="moduleInfo"><span class="keyword">%s</span><span class="value"><a href="%s" target="_blank">%s</a></span></p>\n""" % (k[1:], v, v))
                # External references, not printed in documentation, but in TOC
                elif k == "@module":
                    externalModuleBlock.write("""\t\t\t\t\t<li><a href="%s.html">%s</a></li>\n""" % (v,v))
                else:
                    infoBlock.write("""\t\t\t\t<p class="moduleInfo"><span class="keyword">%s</span><span class="value">%s</span></p>\n""" % (k[1:], v))
                
        pageBlock.write("""</div>""")

        
        # MODULE MEMBERS (the functions, the structs, the rollouts...)

        pageBlock.write("""<div id="members">""")

        # We skip the first element, it already has been processed
        for el in self.elements[1:]:

            level = el.GetLevel()
            cssLevel = ""
            keyword = el.GetKeyword()
            className = el.GetClass()
            name = el.GetName()

            if className != None:
                className = (" %s " % className)
            else:
                className = ""

            cssLevel = (" subLevel%s" % level )

            pageBlock.write("""<div class="element%s">\n""" % cssLevel)
            pageBlock.write("""<p class="tokenFunction"><a name="%s"><span class="tokenType">%s%s</span> """ % (name, keyword, className))

            pageBlock.write("""<span class="tokenFunctionName">%s</span></a>""" % name)

            for p in el.GetParameters():
                pageBlock.write(""" <span class="tokenFunctionParam">%s</span>""" % p)

            pageBlock.write("""</p>\n""")

            if el.GetText() != None:
                doc = el.GetText()
                doc = self.TranslateReSTLike(doc)
                pageBlock.write("""<p class="tokenDoc">%s</p>\n""" % doc)
   
            for p in el.GetDocParameters():
                doc = p.GetText()
                doc = self.TranslateReSTLike(doc)
                if p.GetName() != None:
                    pageBlock.write("""<p class="tokenParam"><span class="keyword">%s</span> <span class="name">%s</span> <span class="text">%s</span></p>\n""" % (p.GetKeyword(), p.GetName(), doc))
                else:
                    pageBlock.write("""<p class="tokenParam"><span class="keyword">%s</span> <span class="text">%s</span></p>\n""" % (p.GetKeyword(), doc))

            pageBlock.write("</div>")

        pageBlock.write("</div>\n") #end of members
        pageBlock.write("</div>\n") #end of page

        footerBlock.write("""<div class="clear">&nbsp;</div>\n""")
        footerBlock.write("""<div id="footer">Generated by <a href="http://www.laurentchea.com/" target="_blank">MrPingouin's</a> maxscriptDoc</footer>""")
        footerBlock.write("</div>\n") #end of main

        footerBlock.write("</body>\n")
        footerBlock.write("</html>\n")

        output.write(headBlock.getvalue())

        # LEFT PART

        toc = tocBlock.getvalue()
        toc = re.sub(r'__EXTERNAL_MODULE_PLACEHOLDER__', externalModuleBlock.getvalue(), toc)
        toc = re.sub(r'__INFO_BLOCK_PLACEHOLDER__', infoBlock.getvalue(), toc)
        output.write(toc)
        output.write(pageBlock.getvalue())
        output.write(footerBlock.getvalue())

        output.close()



