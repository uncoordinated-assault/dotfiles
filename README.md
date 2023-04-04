 [![Continous Integration](https://github.com/wfrsk/dotfiles/actions/workflows/ci.yml/badge.svg)](https://github.com/wfrsk/dotfiles/actions/workflows/ci.yml) <img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-nc-nd/4.0/80x15.png"/>

# What is this?

This is the repository where _most of_ my initialization and configuration files live in, these files are a core section of my daily development workflow.

# The installation process

The installation process is fairly straightforward:

- There are two modes of setup available.
- They go by the names `bare` and `visual`
- The `bare` mode is what you would call `the _minimalistic_ setup`, it contains just enough for the initialization of both my system and my development environment .
- The `visual` mode is what you would call `the _full_ setup`, it inherits from the `bare` mode and it contains the following:
    - Provides both `.xinitrc` and `.xserverrc` files required for the `X Server`.
    - Configuration files for the following programs:
        - `i3 window manager`.
        - `rofi` .
        - `picom` .
        - `alacritty` .
    - A spice of love.

Things said, lets move onto the _actual_ setup process.

The `setup.sh` script can be invoked in this way:

```sh
path/to/setup.sh [setup_mode="bare"]?
```
The ``[setup_mode(...)]?`` section indicates that it takes an optional argument, called `setup_mode`, the value of this argument must be one of the previously mentioned setup modes.

And finally, the ``[(...)="bare"](...)`` section indicates that this argument has a value of ``"bare"`` as the default one.

**Tip**: You must give the `setup.sh` script executable permissions, otherwise it will not be invoked.

You may do so with the following:
```sh
chmod a+x "setup.sh"
```
# Contributions

I encourage everyone who considers my work helpful to contribute.

- [Create a new issue](https://github.com/wfrsk/dotfiles/issues/new/choose)
- [Create a new pull request](https://github.com/wfrsk/dotfiles/compare)

# License

**All** files under this repository, excluding those belonging to a submodule, are licensed under the [CC BY-NC-ND 4.0](https://creativecommons.org/licenses/by-nc-nd/4.0/) license.

A copy of the license can be found in the repository root.

