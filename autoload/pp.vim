" File: pp.vim
" Author: romgrk
" Description: pp wrappers
" Date: 16 Oct 2015

" Global:
fu! pp# (...)
    if !(a:0)
        return g:pp
    else
        call pp.dump(a:1, (a:0==2 ? a:2 : 2))
    end
endfu
fu! pp#print (...)
    try

    call pp#()._('Comment', ' => ')
    for i in range(a:0)
        call pp#dump(a:000[i])
        if (a:0 > 1 && i < a:0 - 1)
            call pp#().sep()
            "call pp#()._('Comment', ",\t")
        end
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

