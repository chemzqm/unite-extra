let s:save_cpo = &cpo
set cpo&vim

let s:file = expand('~') . '/.vim/command.json'

let s:source = {
            \ 'name': 'command',
            \ 'description' : 'vim command source',
            \  "default_action" : "execute",
            \ 'hooks' : {},
            \ 'action_table': {},
            \ 'syntax' : 'uniteSource__command'
            \ }

let s:source.action_table.execute = {
            \ 'description' : 'execute command',
            \ 'is_quit' : 1
            \ }

let s:source.action_table.add = {
            \ 'description' : 'add command',
            \ 'is_quit' : 1
            \ }

let s:source.action_table.edit = {
            \ 'description' : 'edit command',
            \ 'is_quit' : 1
            \ }

function! s:source.action_table.execute.func(candidate)
  let command = a:candidate.source__command
  let has_args = a:candidate.source__args
  if has_args
    call feedkeys(':' . command . ' ', 'n')
  else
    exe command
  endif
endfunction

function! s:source.action_table.add.func(candidate)
  exe 'slient edit' . s:file
  exe 'normal! G'
endfunction

function! s:source.action_table.edit.func(candidate)
  let command = a:candidate.source__command
  exe 'silent edit +/"' . command . '" ' . s:file
  exe 'normal! zz'
  let cursor = getcurpos()
  let cursor[2] = 15
  call setpos('.', cursor)
endfunction

function! s:source.hooks.on_init(args, context) abort
   "name description args
  let a:context.source__bufnr = bufnr('%')
  let a:context.source__data = json_decode(join(readfile(s:file), ''))
endfunction

function! s:source.hooks.on_close(args, context)
  let a:context.source__data = ''
endfunction

function! s:source.hooks.on_syntax(args, context)
  syntax case ignore
  syntax match uniteSource__CommandHeader /^.*$/
        \ containedin=uniteSource__command
  syntax match uniteSource__CommandSign /\v^.{3}/ contained
        \ containedin=uniteSource__CommandHeader
  syntax match uniteSource__CommandTrigger /\%7c.*\%19c/ contained
        \ containedin=uniteSource__CommandHeader
  syntax match uniteSource__CommandDescription /\%20c.*$/ contained
        \ containedin=uniteSource__CommandHeader
  highlight link uniteSource__CommandSign Type
  highlight link uniteSource__CommandTrigger Identifier
  highlight link uniteSource__CommandDescription Statement
endfunction

function! s:source.gather_candidates(args, context)
    let res = []
    for obj in a:context.source__data
      let abbr = printf(' ▷ %-12s %s', obj.command, obj.description)
      call add(res, {
            \ "word": abbr,
            \ "abbr": abbr,
            \ "kind": "word",
            \ "source": "command",
            \ "source__args": obj.args,
            \ "source__command": obj.command,
            \ "source__bufnr": a:context.source__bufnr,
            \})
    endfor
    return res
endfunction

function! unite#sources#command#define()
  return s:source
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
