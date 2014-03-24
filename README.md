Rfactory [![Build Status](https://travis-ci.org/christoomey/vim-rfactory.svg?branch=master)](https://travis-ci.org/christoomey/vim-rfactory)
============================================================================================================================================

`Rfactory` is a vim plugin for rapid navigation to [Factory Girl][] factory
definitions within Vim, inspired by the navigation commands in [Rails.vim][].

![rfactory navigation demo][]

[Factory Girl]: https://github.com/thoughtbot/factory_girl
[Rails.vim]: https://github.com/tpope/vim-rails
[rfactory navigation demo]: ./images/rfactory-navigation-demo.gif

Usage
-----

With your cursor anywhere on a line containing a FactoryGirl reference, e.g.
`create(:user)`, run `:Rfactory` to navigate to the `:user` factory
definition. If the current line contains a [FactoryGirl trait][] reference,
you will be taken to the line that defines the trait within the parent
factory.

There are variants to the `:Rfactory` command to open the factories file in
your preferred split or tab configuration.

[FactoryGirl trait]: https://github.com/thoughtbot/factory_girl/blob/master/GETTING_STARTED.md#traits

Command      | Action
-------------|-----------------
`:Rfactory`  | `:edit` the file
`:RSfactory` | `:split` the file
`:RVfactory` | `:vsplit` the file
`:RTfactory` | `:tabedit` the file
`:REfactory` | (alias for `:Rfactory`)

Requirements
------------

`Rfactory` expects the factory file or files to be in one of the standard
factory file locations as specified in the [Defining Factories section][] of the
FactoryGirl docs, specifically:

``` txt
test/factories.rb
spec/factories.rb
test/factories/*.rb
spec/factories/*.rb
```

[Defining Factories section]: https://github.com/thoughtbot/factory_girl/blob/master/GETTING_STARTED.md#defining-factories
