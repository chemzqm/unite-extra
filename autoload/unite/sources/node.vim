let s:save_cpo = &cpo
set cpo&vim

let s:source = {
            \ 'name': 'node',
            \ 'description' : 'vim node modules source',
            \  "default_action" : "open",
            \ 'hooks' : {},
            \ 'action_table': {},
            \ }

let s:source.action_table.open = {
            \ 'description' : 'open module files',
            \ 'is_quit' : 1
            \ }

let s:source.action_table.main = {
            \ 'description' : 'open main file',
            \ 'is_quit' : 1
            \ }

let s:source.action_table.help = {
            \ 'description' : 'open readme.md file',
            \ 'is_quit' : 1
            \ }

let s:source.action_table.preview = {
            \ 'description' : 'preview package.json',
            \ 'is_quit': 0,
            \ 'is_selectable': 0,
            \ }

let s:source.action_table.browser = {
            \ 'description' : 'open module project in browser',
            \ 'is_quit': 1,
            \ 'is_selectable': 0,
            \ }

function! s:source.action_table.open.func(candidate) abort
  execute 'lcd ' . a:candidate.source__path
  execute 'Unite -buffer-name=files file_rec/async:.'
endfunction

" Open main file
function! s:source.action_table.main.func(candidate) abort
  let path = a:candidate.source__path
  let content = webapi#json#decode(join(readfile(path . '/package.json'), ''))
  let main = exists('content.main') ? content.main : 'index.js'
  let main = main =~# '\v\.js$' ? main : main . '.js'
  let file = simplify(path . '/' . main)
  execute 'silent edit ' . file
  setl nobuflisted
endfunction

" Open Readme.md
function! s:source.action_table.help.func(candidate) abort
  let path = a:candidate.source__path
  let list = filter(split(glob(path . '/*.md'), '\n'), 'v:val =~? "readme\.md"')
  if len(list)
    execute 'silent edit ' . list[0]
    setl nobuflisted
  endif
endfunction

" Open package.json in preview window
function! s:source.action_table.preview.func(candidate)
  let path = a:candidate.source__path
  let file = substitute(path . '/package.json', '\v^\.\/', '', '')
  call unite#view#_preview_file(file)
  call unite#add_previewed_buffer_list(file)
endfunction

" Open module in browser
function! s:source.action_table.browser.func(candidate)
  let path = a:candidate.source__path
  let content = webapi#json#decode(join(readfile(path . '/package.json'), ''))
  let page = get(content, 'homepage', 0)
  if empty(page) | return | endif
  echo page
  call system('open ' . page)
endfunction

function! s:source.hooks.on_init(args, context) abort
endfunction

function! s:source.hooks.on_close(args, context)
endfunction

function! s:source.hooks.on_syntax(args, context)
endfunction

function! s:source.gather_candidates(args, context)
    let list = s:Dependencies()
    if empty(list)| return [] | endif
    let res = []
    " TODO add version info
    for item in list
      call add(res, {
            \ "word": item.name,
            \ "abbr": item.name,
            \ "kind": "word",
            \ "source": "node",
            \ "source__path": item.path,
            \})
    endfor
    return res
endfunction

function! s:GetPackageDir()
  let file = findfile('package.json', '.;')
  if empty(file)
    echohl Error | echon 'project root not found' | echohl None
    return
  endif
  return fnamemodify(file, ':h')
endfunction

function! s:Dependencies() abort
  let dir = s:GetPackageDir()
  if empty(dir) | return | endif
  let obj = webapi#json#decode(join(readfile(dir . '/package.json'), ''))
  let browser = exists('obj.browser')
  let list = []
  let deps = browser ? keys(obj.browser) : []
  let vals = browser ? values(obj.browser) : []
  for key in keys(obj.dependencies)
    let i = index(vals, key)
    if i == -1
      call add(list, {
            \ "name": key,
            \ "path": dir . '/node_modules/' . key,
            \})
    else
      call add(list, {
            \ "name": deps[i],
            \ "path": dir . '/node_modules/' . key,
            \})
    endif
  endfor
  return list
endfunction

function! unite#sources#node#define()
return s:source
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
