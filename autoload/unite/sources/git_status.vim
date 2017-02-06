let s:save_cpo = &cpo
set cpo&vim

function! unite#sources#git_status#define()
  return s:source
endfunction

let s:source = {
      \ 'name': 'git_status',
      \ 'description': 'candidates from git status',
      \ 'syntax' : 'uniteSource__uniteGitStatus',
      \ 'default_kind': 'file',
      \ 'hooks': {},
      \ 'action_table' : {
      \    'add': {
      \      'description': 'git add',
      \      'is_quit': 0,
      \      'is_selectable': 1,
      \    },
      \    'delete': {
      \      'description': 'remove file',
      \      'is_quit': 0,
      \      'is_selectable': 1,
      \    },
      \    'reset': {
      \      'description': 'git reset HEAD',
      \      'is_quit': 0,
      \      'is_selectable': 1,
      \    },
      \    'commit': {
      \      'description': 'git commit',
      \      'is_quit': 0,
      \      'is_selectable': 0,
      \    },
      \  },
      \ }

let s:status_symbol_map = {
      \ ' ': ' ',
      \ 'M': '~',
      \ 'A': '+',
      \ 'D': '-',
      \ 'R': '→',
      \ 'C': 'C',
      \ 'U': 'U',
      \ '?': '?'
      \ }

function! s:system(command)
  let output = system(a:command)
  if v:shell_error && output !=# ""
    echoerr output
  endif
endfunction

function! s:source.action_table.add.func(candidates) abort
  let paths = map(copy(a:candidates), "v:val['action__path']")

  if len(paths)
    let root = a:candidates[0].source__root
    execute 'lcd ' . root
    call s:system('git add ' . join(paths, ' '))
    call unite#force_redraw()
  endif
endfunction

function! s:source.action_table.delete.func(candidates) abort
  if !len(a:candidates) | return | endif
  let root = a:candidates[0].source__root
  execute 'lcd ' . root
  for item in a:candidates
    let p = item.action__path
    if filereadable(p)
      execute 'Rm ' . p
    endif
  endfor
  call unite#force_redraw()
endfunction

function! s:source.action_table.reset.func(candidates) abort
  if !len(a:candidates) | return | endif
  let root = a:candidates[0].source__root
  execute 'lcd ' . root
  let modified = []
  for item in a:candidates
    let path = item.action__path
    if item.source__modify
      call s:system('git checkout -- '. path)
      call add(modified, path)
    else
      call s:system('git reset HEAD -- '. path)
    endif
  endfor
  checktime
  call unite#force_redraw()
endfunction

function! s:source.action_table.commit.func(candidate) abort
  let root = a:candidate.source__root
  wincmd p
  let path = fnamemodify(simplify(root . '/' . a:candidate.action__path), ':~:.')
  execute 'Gcommit -v -- ' . path
endfunction

function! s:git_status_to_unite(val, source__root)
  let index_status = a:val[0]
  let work_tree_status = a:val[1]
  let rest = strpart(a:val, 3)
  let move_dest = matchstr(rest, '-> \zs.\+\ze')
  let path = empty(move_dest) ? rest : move_dest
  let index_status_symbol = s:status_symbol_map[index_status]
  let work_tree_status_symbol = s:status_symbol_map[work_tree_status]
  let word = index_status_symbol . work_tree_status_symbol . ' ' . rest
  return {
        \	'source': 'git_status',
        \	'kind': 'file',
        \ 'word': word,
        \ 'source__modify': work_tree_status_symbol == '~',
        \ 'source__root': a:source__root,
        \	'action__path' : path
        \	}
endfunction

function! s:source.hooks.on_init(args, context) abort
  let git_dir = easygit#gitdir(getcwd())
  if empty(git_dir) | return | endif
  let a:context.source__root = fnamemodify(git_dir, ':h')
endfunction

function! s:source.gather_candidates(args, context)
  let root = a:context.source__root
  if empty(root) | return | endif
  let old_cwd = getcwd()
  execute 'lcd '.root
  let raw = system('git status --porcelain -uall')
  let lines = split(raw, '\n')
  let candidates = map(lines, "s:git_status_to_unite(v:val,'".a:context.source__root."')")
  execute 'lcd '.old_cwd
  return candidates
endfunction

function! s:source.hooks.on_syntax(args, context)
  syntax case ignore
  syntax match uniteGitStatusHeader /^.*$/
        \ containedin=uniteSource__uniteGitStatus

  syntax match uniteGitStatusSymbol /^\s\zs\S\+/
        \ contained containedin=uniteGitStatusHeader
  syntax match uniteGitStatusAdd /+/
        \ contained containedin=uniteGitStatusSymbol
  syntax match uniteGitStatusDelete /-/
        \ contained containedin=uniteGitStatusSymbol
  syntax match uniteGitStatusChange /\~/
        \ contained containedin=uniteGitStatusSymbol
  syntax match uniteGitStatusUnknown /?/
        \ contained containedin=uniteGitStatusSymbol

  highlight uniteGitStatusAdd    guifg=#009900 ctermfg=2
  highlight uniteGitStatusChange guifg=#bbbb00 ctermfg=3
  highlight uniteGitStatusDelete guifg=#ff2222 ctermfg=1
  highlight uniteGitStatusUnknown guifg=#5f5f5f ctermfg=59

endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
