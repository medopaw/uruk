# Uruk
 Install dev tools in `make install` way.

## Description

Uruk is named after the first city in recorded history, and is designed to simplify installing dev tools on new mac.

Notice that it only works on macOS for now.

## Install Uruk

Just clone the git repository.

```bash
git clone git@github.com:medopaw/uruk.git
```

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

### Run install.sh directly

Though not recommended, you can also run `install.sh` and specify things to install in command-line.

```bash
chmod +x install.sh
./install.sh python ruby
```

## Config

Uruk is shipped with `default.conf` to make it work out-of-box. It is recommend to create `custom.conf` to override default settings.

If `custom.conf` is found, `default.conf` in the same directory will be ignored.

And `custom.conf` is in `.gitignore`, so that you can keep your own configuration and don't have to merge with new git commits after updating Uruk.

Of course you can edit `default.conf` directly and include changes and submit to git commit and share with other developers.

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

For every install target (i.e. python, ruby, etc.), Uruk decides which install script(s) should be run first by retrieving name(s) from:

1. Command-line parameter
2. Read from `custom.conf`. Content in this file will be treated as an array separated by any blank characters.
3. Read from `default.conf`. The format is the same with `custom.conf`.

For each name retrieved in step 1 or 2, Uruk will try to resolve it and run specific script. Let's say the name is "python" --

1. If `python.sh` exists under current directory, then it will be run.
2. Otherwise, Uruk will look into a folder named `python`. If such folder doesn't exist, Uruk will ask you to specify installation target(s).
3. Uruk will try to run `python/install.sh`. If failed, a message will be printed to ask you to specify target(s).
