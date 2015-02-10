" Vim syntax file
" Language: RDF N3/N3Logic/Turtle/NTriples/NQuads
" URL: <https://github.com/neapel/vim-n3-syntax/>
" Maintainer: Pascal Germroth <pascal@ensieve.org>

if exists("b:current_syntax")
  finish
endif


let s:notNameChar = ".,;\\[\\]<>(){}:\"' \t\n\r@?!^#"
let s:notNameStart = s:notNameChar . "0-9-"
let s:bareName = "[^" . s:notNameStart . "][^" . s:notNameChar . "]*"
let s:prefix = "[@?:]\\@<!\\(" . s:bareName . "\\)\\?:"
let s:onlyPrefix = s:prefix . "[^" . s:notNameChar . "]\\@!"
let s:qname = s:prefix . s:bareName
let s:ncname = s:bareName . "[:]\\@!"
let s:onlyNCname = "\\([@?:]\\|[^" . s:notNameChar . "]\\)\\@<!" . s:ncname
let s:variable = "?" . s:ncname

let s:uri = "<[^> \\t\\n\\r]*>"
let s:ws = "\\_s*"
let s:dot = "\\."
let s:symbol = "\\(" . s:uri . "\\|" . s:qname . "\\)"
let s:symbolList = s:ws . s:symbol . "\\(" . s:ws . "," . s:ws . s:symbol . "\\)*" . s:ws
let s:forAllStatement = "@forAll" . s:symbolList . s:dot
let s:forSomeStatement = "@forSome" . s:symbolList . s:dot
let s:baseStatement = "@base" . s:ws . s:uri . s:ws . s:dot
let s:prefixStatement = "@prefix" . s:ws . s:onlyPrefix . s:ws . s:uri . s:ws . s:dot


" everything we don't recognize is an error.
syn match n3Unknown /\S/
hi def link n3Unknown Error


" comment
syn keyword n3Todo FIXME NOTE NOTES TODO XXX contained
hi def link n3Todo Todo

syn match n3Comment /#.*$/ contains=@Spell,n3Todo
hi def link n3Comment Comment




" TODO: allow @-less keywords with @keywords.


" @forAll symbollist
execute "syn match n3Universal /" . s:forAllStatement . "/ contains=@n3Symbol,n3Comma"
hi def link n3Universal n3Statement

" @forSome symbollist
execute "syn match n3Existential /" . s:forSomeStatement . "/ contains=@n3Symbol,n3Comma"
hi def link n3Existential n3Statement

" @base uri
execute "syn match n3BaseDecl /" . s:baseStatement . "/ contains=n3Uri"
hi def link n3BaseDecl n3Statement

" @prefix prefix: uri
execute "syn match n3PrefixDecl /" . s:prefixStatement . "/ contains=n3Prefix,n3Uri"
hi def link n3PrefixDecl n3Statement

hi def link n3Statement PreProc



"  @has expression
syn match n3Has /@has/
hi def link n3Has Ignore

" @is expression @of
syn region n3IsOf matchgroup=n3IsOfKeyword start=/@is/ end=/@of/ contains=TOP
hi def link n3IsOfKeyword Operator


" blocks
syn region n3Formula matchgroup=n3CurlBrack start=/{/ end=/}/ contains=TOP
hi def link n3CurlBrack n3Bracket

syn region n3Anonymous matchgroup=n3SquareBrack start=/\[/ end=/\]/ contains=TOP
hi def link N3SquareBrack n3Bracket

syn region n3List matchgroup=n3RoundBrack start=/(/ end=/)/ contains=TOP
hi def link n3RoundBrack n3Bracket

hi def link n3Bracket Normal


syn cluster n3Symbol contains=n3Uri,n3QName

" QNames/Prefixes
execute "syn match n3Prefix /" . s:onlyPrefix . "/"
hi def link n3Prefix Keyword

execute "syn match n3Variable /" . s:variable . "/ contained containedin=n3Formula"
hi def link n3Variable Identifier

execute "syn match n3QNamePrefix /" . s:prefix . "/ contained"
hi def link n3QNamePrefix n3Prefix

execute "syn match n3QName /" . s:qname . "/ contains=n3QNamePrefix"
hi def link n3QName n3Uri

" boolean literals
syn match n3Boolean /@\(true\|false\)/
hi def link n3Boolean Boolean

" number literals
syn match n3Integer /[-+]\?\d\+/
hi def link n3Integer Number
syn match n3Rational $[-+]\?\d\+/\d\+$
hi def link n3Rational Number
syn match n3Decimal /[-+]\?\d\+\.\d*/
hi def link n3Decimal Number
syn match n3Double /[-+]\?\d\+\(\.\d\+\)\?[eE][-+]\?\d\+/
hi def link n3Double Number
syn cluster n3Number contains=n3Integer,n3Rational,n3Double,n3Decimal

" separators
syn match n3Comma /,/
hi def link n3Comma n3Separator
syn match n3Semicolon /;/
hi def link n3Semicolon n3Separator
syn match n3Dot /\./
hi def link n3Dot n3Separator

hi def link n3Separator Normal


" stringy literals with escape characters
syn match n3UnicodeEscape /\\u\x\{4}\|\\U\x\{8}/ contained
hi def link n3UnicodeEscape Special

syn match n3StringEscape /\\[abtnvfr"'\\]/ contained
hi def link n3StringEscape Special

syn match n3UriEscape /%\x\{2}/ contained
hi def link n3UriEscape Special

syn match n3InvalidUri /<[^>]*>/
hi def link n3InvalidUri Error

execute "syn match n3Uri /" . s:uri . "/ contains=n3UriEscape,n3UnicodeEscape"
hi def link n3Uri String


" stringy literal
syn region n3Literal start=/\z("""\|"\)/ skip=/\\\\\|\\\z1/ end=/\z1/ keepend
			\ contains=n3StringEscape,n3UnicodeEscape,@Spell
			\ skipwhite skipempty nextgroup=n3LiteralLanguage,n3LiteralType
hi def link n3Literal String

" highlight only when following a literal
syn match n3LiteralLanguage /@[a-zA-Z]\+\(-[a-zA-Z]\+\)\+/ contained
hi def link n3LiteralLanguage Type

syn match n3LiteralType /\^\^/ contained
hi def link n3LiteralType Type

" operators
syn match n3Path /!\|\^\@<!\^\^\@!/
hi def link n3Path Operator

syn match n3KeywordA /@a/
hi def link n3KeywordA Operator

" shortcuts allowed as predicates
syn match n3Shortcut /=>\|<=\|:=\|=/
hi def link n3Shortcut Operator


" highlight XML literals, inspired by
" https://github.com/seebi/semweb.vim/blob/master/syntax/n3.vim
" use zero-width lookahead to check for foo:XMLLiteral, <...XMLLiteral>,
"
syn include @n3XMLLiteralContent syntax/xml.vim
syn match n3Literal /\("""\|"\)\%(\\.\|\_[^"]\)\+\1\%(\_s*\^\^\_s*\S\+XMLLiteral\>\)\@=/
			\ contains=n3StringEscape,n3UnicodeEscape,@n3XMLLiteralContent

let b:current_syntax = "n3"
