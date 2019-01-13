from pygments.lexer import RegexLexer, bygroups, include
from pygments.token import *
import re


class MaxscriptLexer(RegexLexer):
    """We consider that the analyzed script can be run correctly by 3dsmax, 
       and thus respects Maxscript's grammar 

    """

    name = 'Maxscript Lexer'
    aliases = "maxscript"
    filenames = ['*.ms']

    flags = re.MULTILINE | re.DOTALL | re.IGNORECASE

    tokens = {
        'root': [
            (r'\n', Text),
            (r'[^\S\n]+', Text),
            (r'(/[*]{3}(.*?)[*]{3}/)', String.Doc),
            (r'(/[*](.*?)[*]/)', Comment.Multiline),
            (r'--.*?$', Comment.Singleline),
            (r'[]{}:(),;[#]', Punctuation),
            (r'(in|and|or|not)\b', Operator.Word),
            (r'!=|==|[-+/*%=<>]', Operator),

            (r'(function|fn|struct|rollout)((?:\s|\\\s)+)', bygroups(Keyword, Text), 
                                             'funcname'),
            (r'(plugin)((?:\s|\\\s)+)', bygroups(Keyword, Text), 
                                        'plugin'),
            include('name'),
            include('keywords'),
            (r"([0-9]+(\.[0-9]*)?([eE][+-][0-9]+)?)\b"
             r"[flFLdD]?|0[xX][0-9a-fA-F]+[Ll]?", Number),
            (r'"(.*?)"', String)
            
        ],
        'name': [
            ('[a-zA-Z_][a-zA-Z0-9_]*', Name)
        ],
        'plugin': [
            # As listed in maxscript reference
            ('(geometry|SimpleObject|Shape|Light|Camera|helper|Modifier|SimpleMod|TrackviewUtility|Material|TextureMap|RenderEffect|Atmospheric)', Name.Class),
            ('[a-zA-Z_][a-zA-Z0-9_]*', Name.Function, '#pop')
        ],
        'funcname': [
            ('[a-zA-Z_][a-zA-Z0-9_]*', Name.Function, '#pop')
        ],
        'keywords': [
            (r'(assert|if|then|else|do|while|try|catch|for|global|print|as|to|return|true|false)\b', Keyword),
        ]
    }

class StringDocLexer(RegexLexer):
    name = 'Maxscript StringDoc Lexer'
    
    tokens = {
        'root': [
            (r'^[ ]+@(integer|float|string|double|bool)[ ]+([a-zA-Z][a-zA-Z0-9_]*)(.*)\n', bygroups(Keyword, Name, String.Doc)),
            (r'^[ ]+@(image|return|author|url|version|module|extends)[ ]+(.*)\n', bygroups(Keyword, String.Doc)),
            (r'^(.*)\n', Text),
        ]
    }



