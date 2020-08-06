APP_BASENAME := $(BUILD_ROOT_PATH)/$(PROJECT_NAME)

APP_EXE := $(APP_BASENAME)

ifneq (,$(findstring Windows, $(OS)))
APP_EXE := $(APP_EXE).exe
endif

APP_MAP := $(APP_BASENAME).map
APP_LST := $(APP_BASENAME).lst

APP_ALL := $(APP_EXE) $(APP_LST)

CLEAN_FILES := $(APP_ALL) $(APP_MAP)

GDB_ARGS ?= $(APP_EXE)

.PHONY: $(APP_EXE)

all: size

$(APP_EXE): link

link: builddir components
	@echo "(LD)"
	$(eval OBJECTS := $(filter-out $(LD_FIRST_OBJECTS), $(OBJECTS)))
	$(eval OBJECTS := $(filter-out $(LD_LAST_OBJECTS), $(OBJECTS)))
	$(LD) $(LDFLAGS) \
	-Wl,-Map,$(APP_MAP) \
	$(LD_FIRST_OBJECTS) $(OBJECTS) $(LD_LAST_OBJECTS) $(LDLIBS) \
	-o $(APP_EXE)

$(APP_LST): $(APP_EXE)
	@echo "(OBJDUMP)" $@
	@$(OBJDUMP) -h -S $(APP_EXE) > $(APP_LST)

size: $(APP_EXE)
	@echo
	@$(SIZE) --format=berkeley $(APP_EXE)
	@echo

size-details: $(APP_EXE)
	$(NM) --size-sort --print-size --reverse-sort --radix=d --demangle \
		$(APP_EXE)

run: $(APP_EXE)
	@$(APP_EXE)

debug: $(APP_EXE)
	@$(GDB) $(GDB_ARGS)
