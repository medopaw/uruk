# Uruk
 Install dev tools in `make install` way.

## Description

Uruk is named after the first city in recorded history, and is designed to simplify installing dev tools on new mac.

Notice that it only works on macOS for now.

## Install Uruk

```bash
git clone git@github.com:medopaw/uruk.git
cd uruk
```

## Install Dev Tools Using Uruk

You can install all things your need in just one line.

```bash
make install
```

Before doing that, you need to configure multiple tools in `custom.conf` like this:

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

## Known Issues

### Source rc/profile During Installation

Sometimes we need to source rc/profile during installation. Right now Uruk can't handle this correctly.

e.g. After `rbenv init`, reloading is needed. For now we need to install rbenv and then install ruby separately, otherwise `rbenv` won't be found when installing ruby.

In `custom.conf` you should write `rbenv ruby` instead of `ruby` to avoid this.

## Under the Hood

For every install target (i.e. python, ruby), Uruk decides which install script(s) should be run first by retrieving name(s) from:

1. Command-line parameter
2. Read from `custom.conf`. Content in this file will be treated as an array separated by any blank characters.
3. Read from `default.conf`. The format is the same with `custom.conf`.

For each name retrieved in step 1 or 2, Uruk will try to resolve it and run specific script. Let's say the name is "python" --

1. If `python.sh` exists under current directory, then it will be run.
2. Otherwise, Uruk will look into a folder named `python`. If such folder doesn't exist, Uruk will list all folders and `.sh` files and ask you to choose.
3. Uruk will try to run `python/install.sh`. If failed, a message will be printed to ask you to specify target(s).
