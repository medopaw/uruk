# Default target
help:
	@echo "Uruk - Install dev tools in 'make install' way"
	@echo ""
	@echo "This repository helps you install development tools on macOS."
	@echo "You can customize which tools to install by editing default.conf or creating custom.conf"
	@echo ""
	@echo "Available commands:"
	@echo ""
	@echo "  make install           Install all tools specified in config files"
	@echo "  make add-target        Add a new installation target interactively"
	@echo "  make add-target <name> Add a new target with the specified name"
	@echo "  make edit-config       Edit configuration file (creates custom.conf if needed)"
	@echo "  make edit-config <editor> Edit config with specified editor (e.g. code, zed, nano)"
	@echo "  make format-config     Format custom.conf with default.conf structure"
	@echo ""
	@echo "  make list-targets      Show all available installation targets"
	@echo "  make list-installed    Show currently installed targets"
	@echo "  make list-uninstalled  Show targets that are not installed"
	@echo ""
	@echo "  make help              Show this help message"
	@echo ""
	@echo "For detailed usage, see README.md"

install:
	chmod +x install.sh
	./install.sh

add-target:
	chmod +x add-target.sh
	@if [ "$(filter-out $@,$(MAKECMDGOALS))" ]; then \
		./add-target.sh $(filter-out $@,$(MAKECMDGOALS)); \
	else \
		./add-target.sh; \
	fi

edit-config:
	chmod +x edit-config.sh
	@if [ "$(filter-out $@,$(MAKECMDGOALS))" ]; then \
		./edit-config.sh $(filter-out $@,$(MAKECMDGOALS)); \
	else \
		./edit-config.sh; \
	fi

format-config:
	chmod +x format-config.sh
	./format-config.sh

list-targets:
	chmod +x list-targets.sh
	./list-targets.sh $(ARGS)

list-installed:
	chmod +x list-installed.sh
	./list-installed.sh $(ARGS)

list-uninstalled:
	chmod +x list-uninstalled.sh
	./list-uninstalled.sh $(ARGS)

# This handles the case where additional arguments are passed to make
%:
	@:
