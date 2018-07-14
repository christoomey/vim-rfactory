Rfactory [![Build Status](https://travis-ci.org/christoomey/vim-rfactory.svg?branch=master)](https://travis-ci.org/christoomey/vim-rfactory)
============================================================================================================================================

`Rfactory` is a Vim plugin for rapid navigation to [FactoryBot][] factory
definitions within Vim, inspired by the navigation commands in [Rails.vim][].

![rfactory navigation demo][]

[FactoryBot]: https://github.com/thoughtbot/factory_bot
[Rails.vim]: https://github.com/tpope/vim-rails
[rfactory navigation demo]: ./images/rfactory-navigation-demo.gif

Installation
------------
There are several plugin managers available to simplify installation of Rfactory and other vim plugins

### [Vundle](https://github.com/VundleVim/Vundle.vim)
Place this in your .vimrc:

```
Plugin 'christoomey/vim-rfactory'
```

then run the following in Vim:

```
:source %
:PluginInstall
```
For Vundle version < 0.10.2, replace Plugin with Bundle above.

### [NeoBundle](https://github.com/Shougo/neobundle.vim)
place this in your .vimrc:

```
NeoBundle 'christoomey/vim-rfactory'
```
then run the following in Vim:

```
:source %
:NeoBundleInstall
```

### [VimPlug](https://github.com/junegunn/vim-plug)
Place this in your .vimrc:

```
Plug 'christoomey/vim-rfactory'
```
then run the following in Vim:

```
:source %
:PlugInstall
```

### [Pathogen](https://github.com/tpope/vim-pathogen)
Run the following in a terminal:

```
cd ~/.vim/bundle
git clone https://github.com/christoomey/vim-rfactory
```


Usage
-----

With your cursor anywhere on a line containing a FactoryBot reference, e.g.
`create(:user)`, run `:Rfactory` to navigate to the `:user` factory
definition.

If the current line contains a [FactoryBot trait][] reference,
you will be taken to the line that defines the trait within the parent
factory.

There are variants to the `:Rfactory` command to open the factories file in
your preferred split or tab configuration.

[FactoryBot trait]: https://github.com/thoughtbot/factory_bot/blob/master/GETTING_STARTED.md#traits

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
FactoryBot docs, specifically:

``` txt
test/factories.rb
spec/factories.rb
test/factories/*.rb
spec/factories/*.rb
```

[Defining Factories section]: https://github.com/thoughtbot/factory_bot/blob/master/GETTING_STARTED.md#defining-factories

Support
-------

The plugin does its best to support each of the FactoryBot methods,
specifically:

- `create`
- `build`
- `build_stubbed`
- `attributes_for`

In addition, for each of the above methods, `Rfactory` also supports the
`<method>_pair` and `<method>_list` variants (e.g. `create_pair` and
`create_list`).
