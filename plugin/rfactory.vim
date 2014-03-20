function! s:FactoryOnCurrentLine()
  let fg_methods = ['create', 'build', 'build_stubbed', 'attributes_for']
  let pattern = '\<\%('. join(fg_methods, '\|') . '\).\(:\w\+\)\%(, \(:\w\+\)\)\?'
  let factory_details = matchlist(getline('.'), pattern)
  if len(factory_details)
    let factory_name = factory_details[1]
    let factory_trait = factory_details[2]
    split spec/support/factories.rb
    call search('.*factory.' . factory_name)
    if factory_trait !=? ''
      call search('.*trait.' . factory_trait)
    endif
    normal! zz
  else
    " s:ShowErrorMessage('No factory call found on current line.')
  endif
endfunction

command! Rfactory :call <sid>FactoryOnCurrentLine()

nnoremap go :Rfactory<CR>
