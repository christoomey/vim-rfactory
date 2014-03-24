let rfactory_fg_methods = ['create', 'build', 'build_stubbed', 'attributes_for']
let method_pattern = '\<\%('. join(rfactory_fg_methods, '\|') . '\)' " Non capturing 'or'
let symbol_pattern = '\(:\w\+\)'
let optional_trait_pattern = '\%(, '.symbol_pattern.'\)\?'
let s:pattern = method_pattern . '.' . symbol_pattern . optional_trait_pattern
let g:rfactory_debug = []
let s:FALSE = 0
let s:TRUE = 1
let s:factory_path_patterns = [
      \ "spec/factories.rb",
      \ "test/factories.rb",
      \ "spec/factories/*.rb",
      \ "test/factories/*.rb"
      \ ]

function! s:FactoryOnCurrentLine()
  return matchlist(getline("."), s:pattern)
endfunction

function! s:Debug(msg)
  call add(g:rfactory_debug, a:msg)
endfunction

function! s:FactoryFilePaths()
  let results = []
  for pattern in s:factory_path_patterns
    let files_for_pattern = s:FilesForGlobAsList(pattern)
    call extend(results, files_for_pattern)
  endfor
  return results
endfunction

function! s:FilesForGlobAsList(glob_pattern)
  let use_wilgignore = s:FALSE
  return split(glob(a:glob_pattern, use_wilgignore), "\n")
endfunction

function! s:BuildFactoryContext()
  let factory_definition = s:FactoryOnCurrentLine()
  let factory = { "is_present": len(factory_definition) }
  if factory.is_present
    let factory["name"] = factory_definition[1]
    let factory["trait"] = factory_definition[2]
  endif
  return factory
endfunction

function! s:TryToFindTrait(trait)
  if a:trait != ""
    call search(".*trait." . a:trait)
  endif
endfunction

function! s:CenterFactoryInWindow()
  normal! zz
endfunction

function! s:FactoryDefinitionFound(factory_name)
  return search(".*factory." . a:factory_name) != 0
endfunction

function! s:SearchAndFocusOnFactory(factory, factory_file)
  execute "edit " . a:factory_file
  if s:FactoryDefinitionFound(a:factory.name)
    call s:TryToFindTrait(a:factory.trait)
    call s:CenterFactoryInWindow()
    let factory_found = s:TRUE
  else
    let factory_found = s:FALSE
  endif
  return factory_found
endfunction

function! s:SearchForFactoryInFiles(factory, factory_file_paths)
  for factory_file in a:factory_file_paths
    if s:SearchAndFocusOnFactory(a:factory, factory_file)
      break
    endif
  endfor
endfunction

function! s:OpenFirstFactoryFile(factory_files)
  execute "edit " . a:factory_files[0]
endfunction

function! s:Rfactory(edit_method)
  let factory = s:BuildFactoryContext()
  let factory_files = s:FactoryFilePaths()
  execute a:edit_method
  if factory.is_present
    call s:SearchForFactoryInFiles(factory, factory_files)
  else
    call s:OpenFirstFactoryFile(factory_files)
  endif
endfunction

command! Rfactory :call <sid>Rfactory('edit')
command! REfactory :call <sid>Rfactory('edit')
command! RSfactory :call <sid>Rfactory('split')
command! RVfactory :call <sid>Rfactory('vsplit')
command! RTfactory :call <sid>Rfactory('tabedit')
