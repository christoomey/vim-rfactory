function! s:FactoryOnCurrentLine()
  let pattern = '\<create(\(:\w\+\)'
  let factory_details = matchlist(getline('.'), pattern)
  if len(factory_details)
    let factory_name = factory_details[1]
    split spec/support/factories.rb
    call search('.*factory.' . factory_name)
  endif
endfunction

command! Rfactory :call <sid>FactoryOnCurrentLine()

nnoremap go :Rfactory<CR>
