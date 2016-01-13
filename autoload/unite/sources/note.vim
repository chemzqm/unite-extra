let s:save_cpo = &cpo
set cpo&vim

let s:source = {
      \  'name': 'note',
      \  'hooks': {},
      \  "default_action" : "open",
      \  'action_table' : {
      \    'open' : {
      \     'description' : 'open by vim',
      \     'is_selectable' : 0,
      \    },
      \    'delete': {
      \     'description': 'delete note',
      \     'is_selectable' : 0,
      \    },
      \  }
      \}

function! s:source.hooks.on_init(args, context)
  let a:context.source__input = len(a:context.input) == 0 ? '' : a:context.input
endfunction

function! s:source.hooks.on_close(args, context)
  unlet a:context.source__input
endfunction

function! s:source.gather_candidates(args, context)

  let dict = xolox#notes#get_fnames_and_titles(0)
  let res = []
  for fname in s:sort_ftime(keys(dict))
    let val = dict[fname]
    call add(res, {
          \ "word": val,
          \ "source": "note",
          \ "action__path": fname,
          \ "action__note": val,
          \})
    unlet fname
  endfor
  return res
endfunction

function! s:compare_by_ftime(f1, f2)
  let t1 = getftime(a:f1)
  let t2 = getftime(a:f2)
  return t1 > t2 ? -1 : 1
endfunction

function! s:sort_ftime(names)
  return sort(a:names, 's:compare_by_ftime')
endfunction

function! s:source.action_table.open.func(candidate)
  exe "Note " a:candidate.action__note
endfunction

function! s:source.action_table.delete.func(candidate)
  exe "DeleteNote " a:candidate.action__note
endfunction

function! unite#sources#note#define()
  return s:source
endfunction


"unlet s:source

let &cpo = s:save_cpo
unlet s:save_cpo
