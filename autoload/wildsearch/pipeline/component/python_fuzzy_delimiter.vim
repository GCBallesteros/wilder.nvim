function! wildsearch#pipeline#component#python_fuzzy_delimiter#make(args)
  return {ctx, x -> s:make(a:args, ctx, x)}
endfunction

function! s:make(args, ctx, x)
  if has_key(a:args, 'delimiter')
    if type(a:args.delimiter) == v:t_string
      let l:delimiter = a:args.delimiter
    else
      let l:delimiter = a:args.delimiter(a:ctx, a:x)
    endif
  else
    let l:delimiter = '[_-]'
  endif

  if has_key(a:args, 'word')
    if type(a:args.word) == v:t_string
      let l:word = a:args.word
    else
      let l:word = a:args.word(a:ctx, a:x)
    endif
  else
    let l:word = '\w'
  endif

  let l:res = ''
  let l:chars = split(a:x, '\zs')
  let l:len = len(l:chars)

  if l:len == 0
  endif

  let l:first = 1
  let l:i = 0
  while l:i < l:len
    let l:char = l:chars[l:i]

    if l:char ==# '\'
      if l:i+1 < len(l:chars)
        let l:char .= l:chars[l:i+1]
        let l:i += 2
      else
        let l:i += 1
      endif
      let l:escaped = 1
    else
      let l:i += 1
      let l:escaped = 0
    endif

    if l:first
      let l:first = 0
      if match(l:char, '[[:upper:]]') >= 0
        let l:res .= l:char
      else
        let l:res .= '[' . l:char . '|' . toupper(l:char) . ']'
      endif
      continue
    endif

    if !l:escaped && match(l:char, '[[:upper:]]') >= 0
      let l:res .= '(?:(?:' . l:word . '*?(?:' . l:delimiter . '|' . l:char . '))|' . l:char . ')'
    else
      let l:res .= '(?:(?:' . l:word . '*?(?:' . l:delimiter . l:char . '|' . toupper(l:char) . '))|' . l:char . ')'
    endif
  endwhile

  let l:res .= l:word . '*'

  return l:res
endfunction
