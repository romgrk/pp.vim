

# *pp.vim* - pretty printer
==========================-

`command! P`
Use it as you would use `echo`. (! but with a comma separated list)

e.g.:
```viml
P [1, 2, '3', {'a': 4}], function('search')
```

![alt text](./pp_demo.png "")

*pp.vim* defines the global dict `pp`, which contains the functions for printing/parsing.

```viml
P pp
```

![alt text](./pp_self2.png "")

You can also use it as a replacement for `call`.
```viml
P setline('.', 'A line.')
```

## Settings

### theme:

You can define your theme by:
 * defining a global func `PPtheme`
 * calling `pp#theme(dict)`
 * setting `g:pp['theme']`

```viml
" pp.theme =>

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
```

You can also get the pretty theme by calling `pp#prettyTheme()`.

### more:

Calling `pp` function:
```viml
let obj   = {'some': {'object': {'very': {'deeply': 'recursive'}}}}
let depth = 4
call pp.dump(obj, depth)
" (P default's is depth=2)
```

### autoload:

`pp#()` : returns `pp` dict

`pp#print(...)`: `P` command

`pp#dump(obj[, depth=2])`: prints `obj` 

`pp#theme()`: returns current theme

`pp#theme(t)`: sets `pp['theme']` to `t`

