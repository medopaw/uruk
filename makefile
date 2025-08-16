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
