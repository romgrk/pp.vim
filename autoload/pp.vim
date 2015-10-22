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
fu! pp#print (...)
    try

    call pp#()._('Comment', ' => ')
    for i in range(a:0)
        call pp#dump(a:000[i])
        if (a:0 > 1 && i < a:0 - 1)
            call pp#().sep()
        end
    endfor
    catch /.*/ | call pp#hl('TextError', v:exception) | endtry
endfu
fu! pp#dump (Obj)
    call pp#().dump(a:Obj, 2)
endfu
fu! pp#hl (group, text)
    let group = get(pp#theme(), a:group, a:group)
    let text = escape(a:text, '"\')
    exe 'echohl ' . a:group
    exe 'echon "' . text . '"'
    echohl None
endfu
fu! pp#theme (...)
    if (a:0)
       let g:pp['theme'] = a:1
    else
        return g:pp.theme
    end
endfu

fu! s:hi (gr)
    exe 'hi ' . a:gr[4] .
        \' guifg=' . a:gr[0] .
        \ (empty(a:gr[1]) ? '' : ' guibg=' . a:gr[1]) .
        \ (empty(a:gr[2]) ? '' : ' gui=' . a:gr[2]) .
        \ (empty(a:gr[2]) ? '' : ' cterm=' . a:gr[2]) .
        \' ctermfg=' . a:gr[3]
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
    call s:hi(['#e8e8d3',  '',  '',      99,   'ppNormal'])
    call s:hi(['#40cf00',  '',  '',      119,  'ppString'])
    call s:hi(['#ff8700',  '',  '',      130,  'ppNumber'])
    call s:hi(['#3a50dd',  '',  'bold',  125,  'ppFunction'])
    call s:hi(['#9999f8',  '',  '',      86,   'ppFuncIdentifier'])
    call s:hi(['#ffaf70',  '',  '',      134,  'ppList'])
    call s:hi(['#ffb964',  '',  '',      51,   'ppDict'])
    call s:hi(['#799d6a',  '',  'bold',  76,   'ppSpecialChar'])
    call s:hi(['#888888',  '',  '',      45,   'ppSeparator'])
    call s:hi(['#668799',  '',  '',      77,   'ppDelimiter'])
    call s:hi(['#799033',  '',  '',      118,  'ppStringDelimiter'])
    call pp#theme(theme)
endfu

