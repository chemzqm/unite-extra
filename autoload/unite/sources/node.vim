let s:save_cpo = &cpo
set cpo&vim

let s:source = {
            \ 'name': 'node',
            \ 'description' : 'vim node modules source',
            \  "default_action" : "main",
            \ 'hooks' : {},
            \ 'action_table': {},
            \ }

let s:source.action_table.open = {
            \ 'description' : 'open module files',
            \ 'is_quit' : 1
            \ }

let s:source.action_table.main = {
            \ 'description' : 'open module main file',
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

let s:source.action_table.update = {
            \ 'description' : 'udpate and save a module to latest version',
            \ 'is_quit': 1,
            \ 'is_selectable': 0,
            \ }

function! s:source.action_table.update.func(candidate) abort
  let path = a:candidate.source__directory
  let name = a:candidate.source__name
  let old_cwd = getcwd()
  execute 'lcd ' . path
  if exists('*termopen')
    execute 'belowright 5new'
    set winfixheight
    call termopen('npm install '.name.'@latest --save', {
          \ 'on_exit': function('s:OnUpdate'),
          \ 'source_path': a:candidate.source__path,
          \ 'buffer_nr': bufnr('%'),
          \})
    call setbufvar('%', 'is_autorun', 1)
    execute 'wincmd p'

    execute 
  else
    execute '!npm update '.name.' --save'
  endif
  execute 'lcd ' . old_cwd
endfunction

function! s:OnUpdate(job_id, status, event) dict
  if a:status == 0
    execute 'silent! bd! '.self.buffer_nr
    let content = webapi#json#decode(join(readfile(self.source_path . '/package.json'), ''))
    echohl WarningMsg | echon 'Updated '.content.name.' to '.content.version | echohl None
  endif
endfunction

function! s:source.action_table.open.func(candidate) abort
  let old_cwd = getcwd()
  execute 'lcd ' . a:candidate.source__path
  execute 'Unite -buffer-name=files file_rec/async:.'
  execute 'lcd ' . old_cwd
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
  if exists(':Open')
    execute 'Open ' . page
  else
    call system('open ' . page)
  endif
endfunction

function! s:source.hooks.on_init(args, context) abort
endfunction

function! s:source.hooks.on_close(args, context)
endfunction

function! s:source.hooks.on_syntax(args, context)
endfunction

function! s:source.gather_candidates(args, context)
    let directory = s:GetPackageDir()
    let dependencies = s:Dependencies()
    if empty(dependencies)| return [] | endif
    let res = []
    for item in dependencies
      call add(res, {
            \ "word": item.name,
            \ "abbr": item.name,
            \ "kind": "common",
            \ "source": "node",
            \ "source__name": item.key,
            \ "source__path": item.path,
            \ "source__directory": directory,
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
            \ "key": key,
            \ "name": key,
            \ "path": dir . '/node_modules/' . key,
            \})
    else
      call add(list, {
            \ "key": key,
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
