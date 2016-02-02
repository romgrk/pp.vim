" File: pp.vim
" Author: romgrk
" Description: pp wrappers
" Date: 16 Oct 2015

" Global:
fu! pp# (...)
    if !(a:0)
        return g:pp
    else
        call g:pp.dump(a:1, (a:0==2 ? a:2 : 2))
    end
endfu

" create the hlGroup @group
fu! pp#hi (group, ...)
    let bang = get(a:, 'bang', (a:0 > 0 ? a:1 : 0))
    exe 'hi' . (bang ? '! ' : ' ') . a:group[4] .
        \' guifg=' . a:group[0] .
        \ (empty(a:group[1]) ? '' : ' guibg=' . a:group[1]) .
        \ (empty(a:group[2]) ? '' : ' gui=' . a:group[2]) .
        \ (empty(a:group[2]) ? '' : ' cterm=' . a:group[2]) .
        \' ctermfg=' . a:group[3]
endfu


" prints whatever it receives as argument
fu! pp#print (...)
    try

    call pp#()._('Comment', ' => ')
    for i in range(a:0)
        call pp#dump(a:000[i])
        if (a:0 > 1 && i < a:0 - 1)
            call pp#().sep()
        end
    endfor
    catch /.*/ | call pp#hl('ErrorMsg', v:exception) | endtry
endfu

" prints a single object
fu! pp#dump (Obj)
    call pp#().dump(a:Obj, 2)
endfu

" prints without newline 
" 1. the group&text : (group, text)     OR
" 2. the list of group&text : ([group, text], [group2, text2], ...)
fu! pp#echo (...)
    " (group, text)
    if (a:0 == 2 && type(a:1)==type("string"))
        let group = pp#group(a:1)
        let text = escape(a:2, '"\')
        call g:pp._(a:1, text)
    " ([group, text], [group2, text2], ...)
    elseif (a:0 > 1 && type(a:1)==type([]))
        for pair in a:000
            let group = pp#group(pair[0])
            let text = escape(pair[1], '"\')
            call g:pp._(group, text)
        endfor
    end
endfu
" Alias for pp#echo
fu! pp#hl (...)
    call call('pp#echo', a:000)
endfu

" echoes without newline the group&text
" (delimiter, object [,endDelimiter])
fu! pp#delimited (...)
    let startChar = a:1
    let endChar   = startChar
    if (a:0 > 2) | let endChar = a:3 | end
    call g:pp.delimited(startChar, a:2, endChar)
endfu

" returns the group's HL name or the group itself if
" it doesnt exist in the theme
fu! pp#group (hl)
    return get(g:pp['theme'], a:hl, a:hl)
endfu

" get/set the theme
fu! pp#theme (...)
    if (a:0)
        let g:pp['theme'] = a:1
    else
        return g:pp.theme
    end
endfu

fu! pp#prettyTheme ()
    let theme = {}
    let theme['Name']            = 'ppNormal'
    let theme['String']          = 'ppString'
    let theme['Number']          = 'ppNumber'
    let theme['Float']           = 'ppNumber'
    let theme['Function']        = 'ppFunction'
    let theme['FuncIdentifier']  = 'ppFuncIdentifier'
    let theme['List']            = 'ppList'
    let theme['Dict']            = 'ppDict'
    let theme['SpecialChar']     = 'ppSpecialChar'
    let theme['Separator']       = 'ppSeparator'
    let theme['Delimiter']       = 'ppDelimiter'
    let theme['StringDelimiter'] = 'ppStringDelimiter'
    call pp#hi(['#e8e8d3',  '',  '',      99,   'ppNormal'])
    call pp#hi(['#40cf00',  '',  '',      119,  'ppString'])
    call pp#hi(['#ff8700',  '',  '',      130,  'ppNumber'])
    call pp#hi(['#3a50dd',  '',  'bold',  125,  'ppFunction'])
    call pp#hi(['#9999f8',  '',  '',      86,   'ppFuncIdentifier'])
    call pp#hi(['#ffaf70',  '',  '',      134,  'ppList'])
    call pp#hi(['#ffb964',  '',  '',      51,   'ppDict'])
    call pp#hi(['#799d6a',  '',  'bold',  76,   'ppSpecialChar'])
    call pp#hi(['#888888',  '',  '',      45,   'ppSeparator'])
    call pp#hi(['#668799',  '',  '',      77,   'ppDelimiter'])
    call pp#hi(['#799033',  '',  '',      118,  'ppStringDelimiter'])
    "call pp#theme(theme)
    let g:pp['theme'] = l:theme
endfu

