--A minimal RTF prolog looks like this:
{\rtf1\ansi\deff0{\fonttbl{\f0 Times New Roman;}} 

--A font table with three fonts might look like:

  {\rtf1\ansi\deff0{\fonttbl
  {\f0 Georgia;}
  {\f1 Braille Kiama;}
  {\f2 Courier New;}
  }

--A generally optional but sometimes necessary part of the prolog is a color table. This is a color table:

  {\colortbl;\red255\green0\blue0;\red0\green0\blue255;}
  
  
 --RTF Document Formatting Commands 
 \deflang1033\widowctrl --i.e., codes that apply to the document as a whole
 {\header\pard\qr\plain\f0\chpgn\par} --emitting right after the document-formatting commands
  
 {\pard
  ...stuff...
  \par}

For example:
--***************************************************************--
  {\pard
  \li1440\ri1440\fi480\qj
  A resource can be anything that has identity.  Familiar
   examples include an electronic document, an image, a service
   (e.g., "today's weather report for Los Angeles"), and a
   collection of other resources.  Not all resources are network
   "retrievable"; e.g., human beings, corporations, and bound
   books in a library can also be considered resources.
  \par}
--***************************************************************--


Character Formatting

  \plain -- turn off all formatting
  \ul -- underline
  \b  -- bold
  \i  -- italic
  \sub   -- subscript
  \super -- superscript

  \fN -- change to font #N (where that's the number of a font declared
           in the fonttable in the prolog)
  \fsN -- set current font size to N half-points
         e.g., \fs30 = 15 point
  \scaps -- smallcaps
  \strike -- strikethru
  \v -- hidden text (For comments?)
  \langN -- language N
              US English: 1033    MX Spanish: 2058     French: 1036
              Turkish: 1055       No language: 1024
  \noproof -- disable spellchecking here  (not known to older RTF readers)
  
  {\super\chftn}{\footnote\pard\plain\chftn. Foo!}
    -- set an autonumbered footnote of "Foo!" hanging off of the current
       point in the text
  
  {\field{\*\fldinst{HYPERLINK "http://www.suck.com/"}}{\fldrslt{\ul
  stuff
  }}}
    -- make "stuff" a link to http://www.suck.com/
  
  \cfN -- select foreground color #N (from color table)
  \cbN -- select background color #N (from color table)
  
 Paragraph and Block-Level Formatting

  \page -- pagebreak
  \line -- newline (not a real paragraph break)
  \tab  -- tab (better than using a literal tab character)
  \par  -- End this paragraph, and start a new one, inheriting paragraph
           properties from the previous one.
           (Note that \par means END-paragraph, but if you treat it as it
            if means start-paragraph, you won't break too many things.)
  \par\pard -- End previous paragraph, and start a new one that doesn't
               inherit paragraph properties from the previous one.
           (The \par ends the previous paragraph, the \pard resets
            the new paragraph's formatting attributes.)
  
  \ql -- left (i.e., no) justification
  \qr -- right-justify (i.e., align right)
  \qj -- full-justify (i.e., smooth margins on both sides)
  \qc -- center
  
  \liN -- left-indent this whole paragraph by N twips (default: 0)
  \riN -- right-indent this whole paragraph by N twips (default: 0)
  \fiN -- first-line left-indent this paragraph by N twips (default: 0)
    (Note that this indenting is relative to the margin set by \liN!)
    (Note also that the above can have negative values.
     E.g., \fi-120 backdents (to the left!) the first line by
     120 twips from the paragraph's left margin.)
  
  \sbN -- N twips of extra (vertical) space before this paragraph (default: 0)
  \saN -- N twips of extra (vertical) space after this paragraph (default: 0)
  
  \pagebb -- pagebreak before this paragraph
  \keep -- don't split up this paragraph (i.e., across pages)
  \keepn -- don't split up this paragraph from the next one
  \widctlpar -- widow-and-orphans control for this paragraph
               (antonym: \nowidctlpar)
  
  {\header\pard\qr\plain\f0\chpgn\par}
    -- turn on page numbering.  Lasts until next \sect\sectd.
  
  \colsN -- N newspaper-columns per page.  Lasts until next \sect\sectd.
  \linebetcol -- show lines between columns.
  
  \sect\sectd -- new section.  (Resets header and columnation.)
  
 Document Formatting

If you emit these, do it right after the prolog:

  \ftnbj\ftnrestart -- initialize footnote numbering
  \deflangN -- set the document's default language to N.
                   (See \languageN, above)
  \widowctrl -- turn on widows-and-orphans control for the document
  \hyphcaps  -- allow hyphenation of capitalized words (\hyphcaps0 turns off)
  \hyphauto  -- automatic hyphenation (\hyphauto0 turns off)
  \pgnstartN -- for page numbering, set first page to N
  \marglN -- set left page-margin to N twips (default: 1800)
  \margrN -- set right page-margin to N twips (default: 1800)
  \margtN -- set top page-margin to N twips (default: 1440)
  \margbN -- set top page-margin to N twips (default: 1440)
  \landscape -- document is in landscape format
     (i.e., it's sideways on the page)
	 
 Characters, Escapes, and Character Commands

  [return] -- ignored (unless preceded by an escaping backslash)
  [linefeed] -- ignored (unless preceded by an escaping backslash)
  [space] -- a space (yes, space and tabs ARE significant whitespace)
  [tab] -- a tab to the next tab stop.  Use the command \tab instead, or
            consider expanding tabs to spaces.
            (Setting tab stops is not covered in this document.)
  \'XX  -- character with hex code XX (e.g., \'BB is character 187)
  \\ -- a backslash   (same as \'5c)
  \{ -- an open-brace (same as \'7b)
  \} -- a close-brace (same as \'7d)
  \~ -- non-breaking space
  \- -- optional hyphen (!)
  \_ -- non-breaking hyphen
  
   \bullet -- bullet character (same as Latin-1 character 149)
  \endash -- n-width dash
  \emdash -- m-width dash
  \enspace -- n-width non-breaking space
  \emspace -- m-width non-breaking space
  \lquote -- single openquote (6)
  \rquote -- single closequote (9)
  \ldblquote -- double openquote (66)
  \rdblquote -- double closequote (66)
  
  SAMPLE COMPLETE RTF DOCUMENT ^

  {\rtf1\ansi\deff0

  {\fonttbl
  {\f0 Times New Roman;}
  }

  \deflang1033\widowctrl
  {\header\pard\qr\plain\f0{\noproof\i La dame} p.\chpgn\par}

  \lang1036\fs36

  {\pard\qc\f1\fs60\b\i La dame\par}

  {\pard\sb300\li900
  Toc toc Il a ferm\'e9 la porte\line
  Les lys du jardin sont fl\'e9tris\line
  Quel est donc ce mort qu'on emporte
  \par}

  {\pard\sb300\li900
  Tu viens de toquer \'e0 sa porte\line
     Et trotte trotte\line
     Trotte la petite souris
  \par}

  {\pard\sb900\li900\scaps\fs44
  \endash  Guillaume Apollinaire, {\i Alcools}\par}

  \page\lang1033\fs32
  {\pard\b\ul\fs40 Vocabulary\par}
  {\pard\li300\fi-150{\noproof\b toc }{\i(n.m.)} \endash  tap; knock\par}
  {\pard\li300\fi-150{\noproof\b lys }{\i(n.m.)} \endash  lily\par}
  {\pard\li300\fi-150{\noproof\b fl\'e9trir }
  {\i(v.itr.)} \endash  to wilt; for a flower or beauty to fade;
   for a plant to wither\par}
  {\pard\li300\fi-150{\noproof\b mort }
  {\i(adj., here used as a masc. noun)} \endash  dead\par}
  {\pard\li300\fi-150{\noproof\b emporter }
  {\i(v.tr.)} \endash  to take a person or thing [somewhere];
   to take\~[out/away/etc.] or carry\~[away] a thing\par}
  {\pard\li300\fi-150{\noproof\b toquer }
  {\i(v.itr.)} \endash  to tap; to knock\par}
  {\pard\li300\fi-150{\noproof\b trotter }
  {\i(v.itr.)} \endash  to trot; to scurry\par}
  {\pard\li300\fi-150{\noproof\b souris }{\i(n.f.)} \endash  mouse\par}

  {\pard\sb200\b\ul\fs40 Free Translation\par}
  {\pard
  Click click He closed the door / Garden lilies faded / Which body is today
   // You just tapped on the door / And tip toe / Taps the little mouse
  \line  \_Translation Sean M. Burke, 2001
  \par}
  }