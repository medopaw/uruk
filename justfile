# Default recipe
default:
    @just --list

# Show help message
help:
    @echo "Uruk - Install dev tools in 'make install' way"
    @echo ""
    @echo "This repository helps you install development tools on macOS."
    @echo "You can customize which tools to install by editing default.conf or creating custom.conf"
    @echo ""
    @echo "Available commands:"
    @echo ""
    @echo "  just install           Install all tools specified in config files"
    @echo "  just add-target        Add a new installation target interactively"
    @echo "  just add-target <name> Add a new target with the specified name"
    @echo "  just edit-config       Edit configuration file (creates custom.conf if needed)"
    @echo "  just edit-config <editor> Edit config with specified editor (e.g. code, zed, nano)"
    @echo "  just format-config     Format custom.conf with default.conf structure"
    @echo ""
    @echo "  just list-targets      Show all available installation targets"
    @echo "  just list-installed    Show currently installed targets"
    @echo "  just list-uninstalled  Show targets that are not installed"
    @echo ""
    @echo "  just help              Show this help message"
    @echo ""
    @echo "For detailed usage, see README.md"

# Install all tools specified in config files
install:
    chmod +x install.sh
    ./install.sh

# Add a new installation target interactively or with specified name
add-target *args:
    chmod +x add-target.sh
    ./add-target.sh {{args}}

# Edit configuration file
edit-config *args:
    chmod +x edit-config.sh
    ./edit-config.sh {{args}}

# Format custom.conf with default.conf structure
format-config:
    chmod +x format-config.sh
    ./format-config.sh

# Show all available installation targets
list-targets *args:
    chmod +x list-targets.sh
    ./list-targets.sh {{args}}

# Show currently installed targets
list-installed *args:
    chmod +x list-installed.sh
    ./list-installed.sh {{args}}

# Show targets that are not installed
list-uninstalled *args:
    chmod +x list-uninstalled.sh
    ./list-uninstalled.sh {{args}}
