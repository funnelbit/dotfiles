"=============================================================================
" FILE: matcher_glob.vim
" AUTHOR:  Shougo Matsushita <Shougo.Matsu@gmail.com>
" Last Modified: 20 Dec 2011.
" License: MIT license  {{{
"     Permission is hereby granted, free of charge, to any person obtaining
"     a copy of this software and associated documentation files (the
"     "Software"), to deal in the Software without restriction, including
"     without limitation the rights to use, copy, modify, merge, publish,
"     distribute, sublicense, and/or sell copies of the Software, and to
"     permit persons to whom the Software is furnished to do so, subject to
"     the following conditions:
"
"     The above copyright notice and this permission notice shall be included
"     in all copies or substantial portions of the Software.
"
"     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
"     OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"     MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
"     IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
"     CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
"     TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
"     SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
" }}}
"=============================================================================

let s:save_cpo = &cpo
set cpo&vim

function! unite#filters#matcher_glob#define()"{{{
  return s:matcher
endfunction"}}}

let s:matcher = {
      \ 'name' : 'matcher_glob',
      \ 'description' : 'glob matcher',
      \}

function! s:matcher.filter(candidates, context)"{{{
  if a:context.input == ''
    return a:candidates
  endif

  let candidates = a:candidates
  for input in split(a:context.input, '\\\@<! ')
    let input = substitute(input, '\\ ', ' ', 'g')

    if input =~ '^!'
      if input == '!'
        continue
      endif

      " Exclusion.
      let input = substitute(unite#escape_match(input),
            \ '\\\@<!|', '\\|', 'g')
      let expr = 'v:val.word !~ ' . string(input[1:])
    elseif input =~ '\\\@<![*|]'
      " Wildcard(*) or OR(|).
      let input = substitute(unite#escape_match(input),
            \ '\\\@<!|', '\\|', 'g')
      let expr = 'v:val.word =~ ' . string(input)
    else
      let input = substitute(input, '\\\(.\)', '\1', 'g')
      let expr = &ignorecase ?
            \ printf('stridx(tolower(v:val.word), %s) != -1', string(tolower(input))) :
            \ printf('stridx(v:val.word, %s) != -1', string(input))
    endif

    let candidates = filter(copy(candidates), expr)
  endfor

  return candidates
endfunction"}}}

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: foldmethod=marker
