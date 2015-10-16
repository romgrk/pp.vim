

# *pp.vim* - pretty printer
==========================-

command: `P`
Use it as you would use `echo`.

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

## Settings

### theme:

```viml
" pp.theme =>

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
```

### more:

```viml
let obj   = {'some': 'object'}
let depth = 4
call pp.dump(obj, depth)
" (P default's is depth=2)
```

### autoload:

`pp#()` : returns `pp` dict

`pp#print()`: `P` command callback

`pp#dump(obj)`: prints `obj` (depth=2)

`pp#theme()`: returns current theme

`pp#theme(t)`: sets `pp['theme']` to `t`

