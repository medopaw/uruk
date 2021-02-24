# Uruk

Install dev tools in `make install` way.

## Description

Named after the first city in recorded history, Uruk is designed to simplify installing dev tools on a new mac.

Notice that it only works on macOS for now.

## Install Uruk

0. Open your terminal.
1. `git clone git@github.com:medopaw/uruk.git` or download https://github.com/medopaw/uruk/archive/master.zip and extract to lcoal directory.
2. Enter `uruk` directory.
3. Run `make install`.
4. If a popup update window appears and ask you to install xcode-select command line developer tools, click "Install" and wait till it finishes.

## Install Dev Tools Using Uruk

First enter Uruk directory.

```bash
cd uruk
```

And then you can install all things your need in just one line.

```bash
make install
```

By default, this will install python and ruby if nothing modified.

## Customization

### .conf files

Uruk is shipped with `default.conf` to make it work out-of-box. It is recommend to create `custom.conf` to override default settings.

If `custom.conf` is found, `default.conf` in the same directory will be ignored.

And `custom.conf` is in `.gitignore`, so that you can keep your own configuration and don't have to merge with new git commits after updating Uruk.

Of course you can edit `default.conf` directly and include changes and submit to git commit and share with other developers.

You can configure multiple tools in `custom.conf` like this:

```
python
ruby
```

or

```
python ruby
```

And then run
```bash
make install
```

and both python and ruby will be installed.

If no `custom.conf` was found, Uruk will read from `default.conf`.

### Check if already installed differently

Uruk use `command -v` to check if a target is installed. You can specify different checking method in `is_installed.sh` in the folder with target name.

You should always call `return` in `is_installed.sh` at the end of execution. Otherwise there may be wrong results.

Often a customized `is_installed` is needed if you want to use `brew` or other installed version instead of system default version.

### Run install.sh directly

Though not recommended, you can also run `install.sh` and specify things to install in command-line.

```bash
chmod +x install.sh
./install.sh python ruby
```

## Supported Installation Targets

1. brew
2. fzf
3. git
4. pyenv
5. python
6. rbenv
7. ruby

All depended targets will be installed first. The dependency is specified in installation scripts by calling `install_if_need`. You can modify installation script to customize your own installation.

For what is shipped, e.g. pyenv, fzf and brew will be installed before installing python.

## Under the Hood

### Retrive targets

For every install target (i.e. python, ruby, etc.), Uruk decides which install script(s) should be run first by retrieving name(s) from:

1. Command-line parameter
2. Read from `custom.conf`. Content in this file will be treated as an array separated by any blank characters.
3. Read from `default.conf`. The format is the same with `custom.conf`.

### Check if already installed

For each name retrieved in step 1 or 2, Uruk will try to resolve it and run specific script. Let's say the name is "python" --

1. If `python/is_installed.sh` exists, use its returned value (`true` or `0` means installed, otherwise not installed)
2. Run `command -v python` to check if `python` is installed

### Install the targeted

1. Uruk will try to run `python/install.sh`.
2. If `python/install.sh` does not exist, Uruk will try to run `python.sh` under current directory instead.
3. If `python.sh` does not exist either, a message will be printed to ask you to specify target(s).