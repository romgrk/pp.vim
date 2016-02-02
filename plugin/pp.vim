" File: pp.vim
" Author: romgrk
" Description: pretty print
" Date: 16 Oct 2015
" !::exe [so %]

let s:debug = exists('g:debug')

if exists('g:loaded_pp') && !s:debug
    finish | end
let g:loaded_pp = 1

if !exists('g:pp') || exists('debug') | let g:pp = {} | end

" PP command
com! -nargs=* -complete=expression P     call pp#print(<args>)
com! -nargs=* -complete=expression Print call pp#print(<args>)

fu! s:init_types ()
    let types = [0, 1, 2, 3, 4, 5]
    let types[0] = 'Number'
    let types[1] = 'String'
    let types[2] = 'Function'
    let types[3] = 'List'
    let types[4] = 'Dict'
    let types[5] = 'Float'
    return types
endfu

fu! s:init_theme ()
    let theme = {}
    let theme['Name']            = 'Normal'
    let theme['String']          = 'String'
    let theme['Number']          = 'Number'
    let theme['Float']           = 'Number'
    let theme['Function']        = 'Function'
    let theme['FuncIdentifier']  = 'Identifier'
    let theme['List']            = 'Enum'
    let theme['Dict']            = 'Structure'
    let theme['SpecialChar']     = 'SpecialChar'
    let theme['Separator']       = 'Comment'
    let theme['Delimiter']       = 'Delimiter'
    let theme['StringDelimiter'] = 'StringDelimiter'
    return theme
endfu

if exists('*PPtheme') | try
    let pp.theme = PPtheme()
    catch /.*/ | endtry
end

if !exists("pp['theme']")
    let pp.theme = s:init_theme() | end

let pp['loaded'] = 1

" FieldSeparator, RecordSeparator
let pp.FS = ", "
let pp.RS = "\t"

" Funny highlighting targets
let pp['str :: key'] = function('search')
let pp['funky list'] = [0.1, 0.46666, 99, 'halua bouaboua']


" Script:

let s:types  = s:init_types()

fu! s:type(obj)
    return s:types[type(a:obj)]
endfu
fu! s:print (value)
    exe 'echo "' . string(a:value) . '"'
endfu
fu! s:write (value)
    exe 'echon "' . string(a:value) . '"'
endfu
fu! s:hl (group, text)
    let text = escape(a:text, '"\')
    exe ':echohl ' . a:group
    exe ':echon "' . text . '"'
    return 1
endfu
fu! s:hl_tokens (tokens)
    for t in tokens
        call self._(t[0], t[1])
    endfor
endfu
fu! s:hi (gr)
    exe 'hi ' . a:gr[4] .
        \' guifg=' . a:gr[0] .
        \ (empty(a:gr[1]) ? '' : ' guibg=' . a:gr[1]) .
        \ (empty(a:gr[2]) ? '' : ' gui=' . a:gr[2]) .
        \ (empty(a:gr[2]) ? '' : ' cterm=' . a:gr[2]) .
        \' ctermfg=' . a:gr[3]
endfu

let pp.scope = s:

" PP_object:
fu! pp._ (group, text) dict
    let group = get(self.theme, a:group, a:group)
    if type(a:text) != 1
        let text = string(a:text)
    else
        let text = a:text
    end
    call s:hl(group, text)
endfu
fu! pp.tokens(str) dict
    let tokens = split(a:str, '\<\|\>\|\(''\|"\|\W\)\@=')
    return tokens
endfu
fu! pp.escape (char) dict
    let esc = {}
    "let esc["\<Tab>"] = '\t'
    "let esc["\<CR>"]  = '\n'
    "let esc["\<Esc>"] = '\e'

    if exists('l:esc[a:char]')
        return esc[a:char]
    else
        return strtrans(a:char) | end
endfu

fu! pp.rsep (...) dict
    let sep = get(a:, 1, self.RS)
    call self._('Separator', sep)
endfu
fu! pp.sep (...) dict
    let sep = get(a:, 1, self.FS)
    call self._('Separator', sep)
endfu
fu! pp.eq() dict
    call self._('Delimiter', ': ')
endfu
fu! pp.brace(char) dict
    call self._('Delimiter', a:char)
endfu

fu! pp.delimited(start, Obj, end) dict
    call self._('Delimiter', a:start)
    let Obj = a:Obj
    if s:type(Obj) == 'List'
        call self._(Obj[0], Obj[1])
    elseif s:type(Obj) == 'Function'
        "call Obj()
        echon Obj()
    elseif s:type(Obj) == 'String'
        call Echon(Obj)
    else
        call Echon(Obj)
    end
    call self._('Delimiter', a:end)
endfu

fu! pp.regex(expr) dict
    let expr = a:expr
    call self._('Normal', "pattern\t")
    call self._('RegexpDelimiter', '/')
    call self._('Regexp', expr)
    call self._('RegexpDelimiter', '/')
endfu

fu! pp.color(str) dict
    let hex = tolower(a:str[1:])
    let hlname = 'Color' . hex
    if !hlexists(hlname)
        let nr = str2nr(hex, 16)
        let fg = nr < 0x888888 ? '#ffffff' : '#000000'
        exe 'hi '. hlname . ' guifg=' . fg . ' guibg=#' . hex
    end
    call self._(hlname, '''' . a:str . '''')
endfu
fu! pp.string(str) dict
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
fu! pp.property(key) dict
    let key = a:key
    if key =~ '\v^(\w|_|\k|\i)+$'
        call self._('Name', key) | else
        call self.string(key)    | end
endfu
fu! pp.func(Fn) dict
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
fu! pp.list(list, ...) dict
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
        call self.brace('[ ')
        call self._('Number', len)
        call self.brace(' ]')
    end
endfu
fu! pp.dict(obj, ...) dict
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

fu! pp.dump (Object, ...) dict
    " target
    let Object = a:Object
    " recursive
    let r = a:0 ? a:1 : 0

    let t = s:type(Object)
    if t == 'Number'
        call self._(t, Object)    | end
    if t == 'Float'
        call self._(t, Object) | end
    if t == 'String'
        call self.string(Object)  | end
    if t == 'Function'
        call self.func(Object)    | end
    if t == 'List'
        call self.list(Object, r) | end
    if t == 'Dict'
        call self.dict(Object, r) | end

endfu

