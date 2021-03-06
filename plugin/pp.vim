" File: g:pp.vim
" Author: romgrk
" Description: pretty print
" Date: 16 Oct 2015
" !::exe [so %]

if exists('g:did_loaded_pp') && !get(g:, 'debug')
    finish | end
let g:did_loaded_pp = 1

if get(g:, 'debug', 0)
    unlet! g:pp | end

" PP commands
com! -nargs=* -complete=expression P     call pp#print(<args>)
com! -nargs=* -complete=expression Pp    call pp#print(<args>)
com! -nargs=* -complete=expression Print call pp#print(<args>)

" Object setup
let g:pp = {}

fu! s:init_types ()
    let types                    = range(8)
    let types[0]                 = 'Number'
    let types[1]                 = 'String'
    let types[2]                 = 'Function'
    let types[3]                 = 'List'
    let types[4]                 = 'Dict'
    let types[5]                 = 'Float'
    let types[6]                 = 'Boolean'
    let types[7]                 = 'Null'
    return types
endfu

fu! s:init_theme()
    let theme                    = {}
    let theme['Name']            = 'Normal'
    let theme['String']          = 'String'
    let theme['Number']          = 'Number'
    let theme['Float']           = 'Number'
    let theme['Function']        = 'Function'
    let theme['FuncIdentifier']  = 'Identifier'
    "let theme['List']            = 'Enum'      <= not really standard
    let theme['List']            = 'Constant'
    let theme['Dict']            = 'Structure'
    let theme['Boolean']         = 'Boolean'
    let theme['Null']            = 'Comment'
    let theme['SpecialChar']     = 'SpecialChar'
    let theme['Separator']       = 'Comment'
    let theme['Delimiter']       = 'Delimiter'
    let theme['StringDelimiter'] = 'StringDelimiter'
    hi def link Null Comment
    return theme
endfu

" 1. set theme via a global func
if exists('*PPtheme') | try
    let g:pp.theme = PPtheme()
catch /.*/ | endtry | end

" 2. check if theme isnt already set
if !exists("pp.theme")
    let g:pp.theme = s:init_theme() | end

" Properties
let g:pp.FS = ", " " ,\t   FieldSeparator
let g:pp.RS = "\n"  " \n    RecordSeparator


" Script:

let s:types  = s:init_types()

fu! g:pp.type(obj)
    return s:types[type(a:obj)]
endfu

" PP_object:
fu! g:pp._ (group, text) dict
    let group = get(self.theme, a:group, a:group)
    if type(a:text) != 1
        let text = string(a:text)
    else
        let text = a:text
    end
    exe 'echohl ' . group
    exe 'echon "' . escape(text, '"\') . '"'
endfu
fu! g:pp.tokens(str) dict
    let tokens = split(a:str, '\<\|\>\|\(''\|"\|\W\)\@=')
    return tokens
endfu
fu! g:pp.escape (char) dict
    let esc = {}
    "let esc["\<Tab>"] = '\t'
    "let esc["\<CR>"]  = '\n'
    "let esc["\<Esc>"] = '\e'

    if exists('l:esc[a:char]')
        return esc[a:char]
    else
        return strtrans(a:char) | end
endfu

fu! g:pp.rsep (...) dict
    let sep = get(a:, 1, self.RS)
    call self._('Separator', sep)
endfu
fu! g:pp.sep (...) dict
    let sep = get(a:, 1, self.FS)
    call self._('Separator', sep)
endfu
fu! g:pp.eq() dict
    call self._('Delimiter', ': ')
endfu
fu! g:pp.brace(char) dict
    call self._('Delimiter', a:char)
endfu
fu! g:pp.delimited(start, Obj, end) dict
    call self._('Delimiter', a:start)
    let Obj = a:Obj
    if g:pp.type(Obj) == 'List'
        call self._(Obj[0], Obj[1])
    elseif g:pp.type(Obj) == 'Function'
        let res = Obj()
        if !empty(res)
            echon res
        end
    elseif g:pp.type(Obj) == 'String'
        call Echon(Obj)
    else
        call Echon(Obj)
    end
    call self._('Delimiter', a:end)
endfu

" Printers:
fu! g:pp.regex(expr) dict
    let expr = a:expr
    call self._('Normal', "pattern\t")
    call self._('RegexpDelimiter', '/')
    call self._('Regexp', expr)
    call self._('RegexpDelimiter', '/')
endfu
fu! g:pp.color(str) dict
    let hex = tolower(a:str[1:])
    let hlname = 'Color' . hex
    if !hlexists(hlname)
        let nr = str2nr(hex, 16)
        let fg = nr < 0x888888 ? '#ffffff' : '#000000'
        exe 'hi '. hlname . ' guifg=' . fg . ' guibg=#' . hex
    end
    call self._(hlname, '''' . a:str . '''')
endfu
fu! g:pp.string(str) dict
    if (a:str =~ '\v^#[A-Fa-f0-9]{6}$')
        call self.color(a:str)
        return
    end

    call self._('StringDelimiter', '''')
    let n = 0
    let out = ''
    let str = a:str
    while n < strlen(str)
        let c = str[n]
        let n += 1
        if (c =~ '\p')
            let out .= c
            continue
        else
            call self._('String', out)
            let out = '' | end

        call self._('SpecialChar', self.escape(c))
    endwhile
    if !empty(out) | call self._('String', out) | end
    call self._('StringDelimiter', '''')
endfu
fu! g:pp.property(key) dict
    let key = a:key
    if key =~ '\v^(\w|_|\k|\i)+$'
        call self._('Name', key) | else
        call self.string(key)    | end
endfu
fu! g:pp.func(Fn) dict
    let str = string(a:Fn)
    let tokens = self.tokens(str)
    let token = ''

    let end = ''
    for t in tokens
        let token .= t
        if t ==? 'function'
            call self._('Function', token)
        elseif t =~? '\v[(){}[\]]'
            call self._('Delimiter', token)
        elseif (empty(end) && t =~ '"\|''') || t == end
            call self._('Keyword', token)
            let end = t
        elseif !empty(end) && t =~ '\v[^' . end . ']+'
            call self._('FuncIdentifier', token)
        else
            continue
        end
        let token = ''
    endfor
endfu
fu! g:pp.list(list, ...) dict
    let list = a:list
    let len  = len(list)
    let r    = a:0 ? a:1 : 0
    if (r > 0)
        call self.brace('[ ')
        for i in range(len)
            call self.dump(list[i], r - 1)
            if i+1<len | call self.sep() | end
        endfor
        call self.brace(' ]')
    else
        "call self._('Comment', '... #')
        call self.brace('[ … ')
        call self._('Number', len)
        call self.brace(' ]')
    end
endfu
fu! g:pp.dict(obj, ...) dict
    let obj = a:obj
    let r   = a:0 ? a:1 : 0
    if (r > 0)
        call self.brace('{ ')
        let init = 0
        for key in keys(obj)
            if  !init  | let init = 1
            else       | call self.sep() | end
            call self.property(key)       " key
            call self.eq()                " =
            call self.dump(obj[key], r-1) " value
        endfor
        call self.brace(' }')
    else
        call self.brace('{')
        call self._('Number', len(obj))
        call self.brace('}')
    end
endfu

fu! g:pp.dump (Object, ...) dict
    " target
    let Object = a:Object
    " recursive
    let r = a:0 ? a:1 : 0

    let t = g:pp.type(Object)
    if t == 'Number'
        call self._(t, Object)
    elseif t == 'Float'
        call self._(t, Object)
    elseif t == 'Boolean'
        call self._(t, Object ? 'true' : 'false')
    elseif t == 'Null'
        call self._(t, 'null')
    elseif t == 'String'
        call self.string(Object)
    elseif t == 'Function'
        call self.func(Object)
    elseif t == 'List'
        call self.list(Object, r)
    elseif t == 'Dict'
        call self.dict(Object, r)
    end
endfu

