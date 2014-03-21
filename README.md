RFactory
========

Rfactory is a vim plugin for rapid navigation to [Factory Girl] factory
definitions within Vim.

[Factory Girl]: https://github.com/thoughtbot/factory\_girl

Usage
-----

While on a factory reference in a spec file, run `:Rfactory` to navigate to
the factory definition. If the current line contains a FactoryGirl trait
reference, you will be taken to that trait.

Configuration
-------------

`:Rfactory` will look for factories in `spec/factories.rb`. Overwrite
`g:rfactory_factory_location` to change this location.

```vim
let g:rfactory_factory_location = "spec/support/factories.rb"
```
