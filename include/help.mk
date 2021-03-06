help:
	@echo "General targets:"
	@echo "    all                      Build all"
	@echo "    clean                    Remove build output"
	@echo "    clean-all                Clean build directory completely"
	@echo "    components               Build all components (no linking)"
	@echo "    component-<name>         Build component <name> only"
	@echo "    component-<name>-clean   Clean component <name> only"
	@echo "    link                     Link application"
	@echo "    info                     Show build settings"
	@echo "    size                     Show memory usage summary"
	@echo "    size-details             Show memory usage details"
	@echo
	@echo "Desktop targets:"
	@echo "    run                      Run application"
	@echo "    debug                    Run application in debugger"
	@echo
	@echo "Embedded targets:"
	@echo "    debug                    Start debugger with application"

