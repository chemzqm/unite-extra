let s:save_cpo = &cpo
set cpo&vim

let s:source = {
            \ 'name': 'project',
            \ 'description' : 'vim project source',
            \  "default_action" : "open",
            \ 'hooks' : {},
            \ 'action_table': {},
            \ 'syntax' : 'uniteSource__project'
            \ }

let s:source.action_table.open = {
            \ 'description' : 'open project',
            \ 'is_quit' : 1
            \ }

let s:source.action_table.tabopen = {
            \ 'description' : 'open project in new tab',
            \ 'is_quit' : 1
            \ }


function! s:source.action_table.open.func(candidate)
  execute 'lcd ' . a:candidate.source__project
  execute 'Unite -buffer-name=files file_rec'
endfunction

function! s:source.action_table.tabopen.func(candidate)
  tabnew
  execute 'Explore ' . a:candidate.source__project . '/'
endfunction

function! s:source.hooks.on_init(args, context) abort
   "name description args
  let a:context.source__bufnr = bufnr('%')
  let list = map(copy(g:project_folders), 'split(glob(v:val . ''/*''), ''\n'')')
  exe "let a:context.source__directories=" . join(list, '+')
endfunction

function! s:source.hooks.on_close(args, context)
  let a:context.source__directories = []
endfunction

function! s:source.hooks.on_syntax(args, context)
  syntax case ignore
  syntax match uniteSource__ProjectHeader /^.*$/
        \ containedin=uniteSource__command
  syntax match uniteSource__ProjectRoot /^.*\%17c/ contained
        \ containedin=uniteSource__ProjectHeader
  syntax match uniteSource__ProjectName /\%18c.*$/ contained
        \ containedin=uniteSource__ProjectHeader
  highlight link uniteSource__ProjectRoot Comment
  highlight link uniteSource__ProjectName Identifier
endfunction

function! s:source.gather_candidates(args, context)
    let res = []
    for str in a:context.source__directories
      let word = fnamemodify(str, ':t')
      let abbr = printf(' %-14s %-20s', fnamemodify(str, ':h:t'), word)
      call add(res, {
            \ "word": word,
            \ "abbr": abbr,
            \ "kind": "word",
            \ "source": "project",
            \ "source__project": str,
            \})
    endfor
    return res
endfunction

function! unite#sources#project#define()
  return s:source
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
