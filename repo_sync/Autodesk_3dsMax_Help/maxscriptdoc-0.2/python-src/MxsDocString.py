class MxsDocString:
    """An MxsDocString is composed by :
        - a keyword (the type of the documented object : function, struct, 
          rollout)
        - a name (the name of the documented object : fooBar)
        - a text (the documentation of the object)
        - a list of keywords (@param, @author, @return, @url), that have 
          values associated. In fact, a keyword is... a MxsDocString :]

    """

    def __init__(self, keyword):

        self.keyword = keyword
        # This one is used by "plugin" keyword only !
        self.className = None
        self.name = None
        self.text = ""

        # When a function is declared under a struct
        # Not implemented yet, needs a better grammar.
        self.parent = None

        # Contains the parameters of a function
        # function myMxsFunction foo bar = (...)
        self.parameters = []

        # Contains the parameters that has been documented (@bool myBool, 
        # @string myValue, etc)
        self.docparameters = []

        self.level = 0

    def SetClass(self, s):
        self.className = s

    def GetClass(self):
        return self.className

    def SetLevel(self, level):
        self.level = level

    def GetLevel(self):
        return self.level

    def SetKeyword(self, s):
        self.keyword = s

    def GetKeyword(self):
        return self.keyword

    def GetName(self):
        return self.name

    def GetText(self):
        return self.text

    def AppendText(self, text):
        self.text = self.text + text

    def GetParameters(self):
        return self.parameters

    def SetLastParameterDefaultValue(self, value):
        self.parameters[-1] += (":%s" % value)

    def GetDocParameters(self):
        return self.docparameters

    def SetName(self, name):
        self.name = name

    def SetText(self, text):
        self.text = text

    # parameter is just a string here (true parameter,
    # not the documented one)
    def AddParameter(self, parameter):
        self.parameters.append(parameter)

    # this parameter is a DocString object !
    def AddDocParameter(self, parameter):
        self.docparameters.append(parameter)

    def TrimText(self):
        self.text = self.text.strip()

    # Not used yet.
    def SetParent(self, value):
        self.parent = value

    def GetParent(self):
        return self.parent


