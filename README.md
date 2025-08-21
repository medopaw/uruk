# Uruk

Install dev tools in `make install` way.

## Description

Named after the first city in recorded history, Uruk is designed to simplify installing dev tools on a new mac.

Notice that it only works on macOS for now.

## Quick Start (Remote Installation)

**One-line installation** - No need to clone the repository:

```bash
curl -fsSL https://raw.githubusercontent.com/medopaw/uruk/master/remote-install.sh | bash
```

This will:
1. 🚀 Automatically download and set up Uruk in a temporary directory
2. 🔍 Scan all available installation targets and generate a configuration file
3. ✏️ Open your preferred editor to customize which tools to install
4. ⚡ Run the installation with your selected tools
5. 🧹 Clean up temporary files automatically

Essential tools like `git` are enabled by default. You can add more by uncommenting lines in the configuration file.

### Debug Mode

To enable debug output for troubleshooting:

```bash
URUK_DEBUG=1 curl -fsSL https://raw.githubusercontent.com/medopaw/uruk/master/remote-install.sh | bash
```

This will show detailed information about:
- Directory operations and file checks
- Configuration file processing  
- Target discovery and parsing
- Installation command execution

## Manual Installation

If you prefer to customize before running, or want to keep the repository locally:

### Clone the Repository

```bash
git clone https://github.com/medopaw/uruk.git
```

Or download https://github.com/medopaw/uruk/archive/master.zip and extract to local directory.

### Install Dev Tools

First enter Uruk directory.

```bash
cd uruk # Or `cd uruk-master` if it's extracted from github zip file
```

And then you can install all things your need in just one line.

```bash
make install
```

If a popup update window appears and ask you to install xcode-select command line developer tools, click "Install" and wait till it finishes.

By default, this will install git (brew version) and rust if nothing modified.

## Available Commands

Uruk provides several commands to help you manage installation targets. You can use either `make` commands or run the shell scripts directly.

### Get Help

Show all available commands and usage information:

```bash
make help
# or run make without arguments
make
```

### Install Tools

Install all tools specified in configuration files:

```bash
make install
# Alternative: run install.sh directly
chmod +x install.sh
./install.sh
```

### Manage Installation Targets

Add a new installation target interactively:

```bash
make add-target
# Alternative: run add-target.sh directly
chmod +x add-target.sh
./add-target.sh
```

Add a new target with a specific name (will prompt for type and other details):

```bash
make add-target vim
# Alternative: run add-target.sh directly
chmod +x add-target.sh
./add-target.sh vim
```

### List Targets

Show all available installation targets:

```bash
make list-targets
# Alternative: run list-targets.sh directly
chmod +x list-targets.sh
./list-targets.sh
```

Show currently installed targets:

```bash
make list-installed
# Alternative: run list-installed.sh directly
chmod +x list-installed.sh
./list-installed.sh
```

Show targets that are not installed:

```bash
make list-uninstalled
# Alternative: run list-uninstalled.sh directly
chmod +x list-uninstalled.sh
./list-uninstalled.sh
```

All listing commands support a `--simple` flag for script-friendly output:

```bash
make list-targets ARGS="--simple"
make list-installed ARGS="--simple"
make list-uninstalled ARGS="--simple"
# Alternative: run scripts directly
./list-targets.sh --simple
./list-installed.sh --simple
./list-uninstalled.sh --simple
```

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

### Adding New Targets

You can add new installation targets using the `make add-target` command. This will interactively guide you through creating the necessary files for a new target:

```bash
make add-target
# or with a specific name
make add-target newtool
```

This automatically updates the README with the new target in the supported targets list.

### Check if already installed differently

Uruk use `command -v` to check if a target is installed. You can specify different checking method in `is_installed.sh` in the folder with target name.

The status code explicitly or implicitly returned from `is_installed` will be used to check if it is installed: `0` means installed, otherwise not installed.

Often a customized `is_installed` is needed if you want to use `brew` or other installed version instead of system default version.

### Command-line Installation

You can also specify targets to install directly in the command-line:

```bash
make install python ruby
# Alternative: run install.sh directly
chmod +x install.sh
./install.sh python ruby
```

## Supported Installation Targets

1. alfred
2. autojump
3. baiduinput
4. baidunetdisk
5. bat
6. brew
7. caffeinate
8. cargo-update
9. chromium
10. coreutils
11. docker
12. doomemacs
13. dropbox
14. emacs
15. fd
16. ffmpeg
17. firefox
18. fselect
19. fzf
20. gh
21. git
22. git-delta
23. git-lfs
24. github
25. google-chrome
26. hammerspoon
27. iterm2
28. jenv
29. json-helper
30. karabiner-elements
31. location-helper
32. loopback
33. makers
34. mas
35. neteasemusic
36. node
37. oh-my-zsh
38. onedrive
39. p4merge
40. pycharm-ce-with-anaconda-plugin
41. pyenv
42. python
43. qq
44. qqmusic
45. quickmail
46. ranger
47. rbenv
48. rg
49. rsync
50. ruby
51. rust
52. sogouinput
53. sublime-text
54. switchhosts
55. tig
56. tldr
57. vim
58. visual-studio-code
59. wechat
60. xcode-command-line-tools
61. zed

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
