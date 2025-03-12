# Uruk

Install dev tools in `make install` way.

## Description

Named after the first city in recorded history, Uruk is designed to simplify installing dev tools on a new mac.

Notice that it only works on macOS for now.

## Install Uruk

```bash
git clone https://github.com/medopaw/uruk.git
```

Or download https://github.com/medopaw/uruk/archive/master.zip and extract to local directory.

## Install Dev Tools Using Uruk

First enter Uruk directory.

```bash
cd uruk # Or `cd uruk-master` if it's extracted from github zip file
```

And then you can install all things your need in just one line.

```bash
make install
```

If a popup update window appears and ask you to install xcode-select command line developer tools, click "Install" and wait till it finishes.

By default, this will install git (brew version), python (pyenv version) and ruby (rbenv version) if nothing modified.

## Customization

### .conf files

Uruk is shipped with `default.conf` to make it work out-of-box. It is recommend to create `custom.conf` to override default settings.

If `custom.conf` is found, `default.conf` in the same directory will be ignored.

And `custom.conf` is in `.gitignore`, so that you can keep your own configuration and don't have to merge with new git commits after updating Uruk.

Of course you can edit `default.conf` directly and include changes and submit to git commit and share with other developers.

You can configure multiple tools in `custom.conf` like this:

```bash
python
ruby
```

or

```bash
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

The status code explicitly or implicitly returned from `is_installed` will be used to check if it is installed: `0` means installed, otherwise not installed.

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
4. docker
5. pyenv
6. python
7. rbenv
8. ruby
9. tig
10. tldr
11. autojump
12. ranger
13. iterm2
14. firefox
15. google-chrome
16. sublime-text
17. visual-studio-code
18. pycharm-ce-with-anaconda-plugin
19. github
20. switchhosts
21. sogouinput
22. baiduinput
23. wechat
24. qq
25. neteasemusic
26. qqmusic
27. baidunetdisk
28. mas
29. caffeinate
30. rust
31. makers
32. loopback
33. rsync

All depended targets will be installed first. The dependency is specified in installation scripts by calling `install_if_needed`. You can modify installation script to customize your own installation.

For what is shipped, e.g. pyenv, fzf and brew will be installed before installing python.

## Under the Hood

### Retrieve targets

For every install target (i.e. python, ruby, etc.), Uruk decides which install script(s) should be run first by retrieving name(s) from:

1. Command-line parameter
2. Read from `custom.conf`. Content in this file will be treated as an array separated by any blank characters.
3. Read from `default.conf`. The format is the same with `custom.conf`.

### Check if already installed

For each name retrieved in step 1 or 2, Uruk will try to resolve it and run specific script. Let's say the name is "python" --

1. If `targets/python/is_installed.sh` exists, use its returned value (`true` or `0` means installed, otherwise not installed)
2. If `targets/python.brewtarget` exists, treat it as a brew target and check if `brew list python` has `0` exit code.
3. If `targets/python.casktarget` exists, treat it as a cask target and check if `brew list --cask python` has `0` exit code.
4. If `targets/python.mastarget` exists, treat it as a Mac App Store target and read MAS ID from it and check if `mas list | grep "^$mas_id"` has `0` exit code.
5. Run `command -v python` to check if `python` is installed

### Install one target

1. Uruk will try to run `python/install.sh`.
2. If `python/install.sh` does not exist, Uruk will try to run `python.sh` under current directory instead.
3. If `python.sh` does not exist either, a message will appear, telling you Uruk can't locate any install script.
4. If `targets/python.brewtarget` exists, treat it as a brew target and run `brew install python`.
5. If `targets/python.casktarget` exists, treat it as a cask target and run `brew install python`.
6. If `targets/python.mastarget` exists, treat it as a Mac App Store target and read MAS ID form it and run `mas install $mas_id`.
