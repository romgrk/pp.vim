" File: pp.vim
" Author: romgrk
" Description: pretty print
" Date: 16 Oct 2015
" !::exe [so %]

if exists('g:loaded_pp') && !exists('g:debug')
    finish
end
let loaded_pp = 1

fu! s:init_types ()
    let types = [0, 1, 2, 3, 4]
    let types[0] = 'Number'
    let types[1] = 'String'
    let types[2] = 'Function'
    let types[3] = 'List'
    let types[4] = 'Dict'
    return types
endfu

fu! s:init_theme ()
    let theme = {}
    let theme['Name']            = 'Normal'
    let theme['String']          = 'ModType'
    let theme['Number']          = 'HighType'
    let theme['Function']        = 'Keyword'
    let theme['List']            = 'Variable'
    let theme['Dict']            = 'Type'
    let theme['SpecialChar']     = 'SpecialChar'
    let theme['Separator']       = 'Comment'
    let theme['Delimiter']       = 'Delimiter'
    let theme['StringDelimiter'] = 'StringDelimiter'
    return theme
endfu

"if !exists('g:pp') | let g:pp = | end
let pp = {'loaded': 1, 'string as :: key': function('search')}
let pp.theme = s:init_theme()
"let pp.FS = ",\t"
"let pp.RS = "\n"
let pp.FS = ", \t"
let pp.RS = "\t\t"

let s:types  = s:init_types()

com! -nargs=* -complete=expression R call pp.regex(func_pattern)
com! -nargs=* -complete=expression P call pp#print(<args>)

" Script:
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

" Global:
fu! pp# ()
    return g:pp
endfu
fu! pp#print (...)
    try

    call pp#()._('Comment', ' => ')
    for i in range(a:0)
        call pp#dump(a:000[i])
        "if (a:0 > 1 && i < a:0 - 1)
            "call self.sep()
            "call pp#()._('Comment', ",\t")
        "end
    endfor
    catch /.*/ | call s:hl('TextError', v:exception) | endtry
endfu
fu! pp#dump (Obj)
    call pp#().dump(a:Obj, 2)
endfu
fu! pp#hl (group, text)
    let group = get(pp#().theme, a:group, a:group)
    call s:hl(group, a:text)
endfu
fu! pp#theme (...)
    if (a:0)
       let pp#()['theme'] = a:1
    else
        return pp#().theme
    end
endfu


" PP_object:
fu! pp._ (group, text) dict
    let group = get(self.theme, a:group, a:group)
    call s:hl(group, a:text)
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
fu! pp.delimiter(start, Obj, end) dict
    call self._('Delimiter', a:start)
    let Obj = a:Obj
    if s:type(Obj) == 'List'
        call self._(Obj[0], Obj[1])
    elseif s:type(Obj) == 'Function'
        call Obj()
    elseif s:type(Obj) == 'String'
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

fu! pp.string(str) dict
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
            call self._('BKeyword', token)
        elseif t =~? '\v[(){}[\]]'
            call self._('Delimiter', token)
        elseif (empty(end) && t =~ '"\|''') || t == end
            call self._('Keyword', token)
            let end = t
        elseif !empty(end) && t =~ '\v[^' . end . ']+'
            call self._('Blue', token)
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
    if t == 'String'
        call self.string(Object)  | end
    if t == 'Function'
        call self.func(Object)    | end
    if t == 'List'
        call self.list(Object, r) | end
    if t == 'Dict'
        call self.dict(Object, r) | end

endfu

