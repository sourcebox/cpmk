APP_BASENAME := $(BUILD_ROOT_PATH)/$(PROJECT_NAME)

APP_ELF := $(APP_BASENAME).elf
APP_BIN := $(APP_BASENAME).bin
APP_HEX := $(APP_BASENAME).hex
APP_MAP := $(APP_BASENAME).map
APP_LST := $(APP_BASENAME).lst

APP_ALL := $(APP_ELF) $(APP_BIN) $(APP_HEX) $(APP_LST)

CLEAN_FILES := $(APP_ALL) $(APP_MAP)

.PHONY: $(APP_ELF)

all: size

$(APP_ELF): link

link: builddir components
	@echo "(LD)"
	$(eval OBJECTS := $(filter-out $(LD_FIRST_OBJECTS), $(OBJECTS)))
	$(eval OBJECTS := $(filter-out $(LD_LAST_OBJECTS), $(OBJECTS)))
	$(LD) $(LDFLAGS) \
	-Wl,-Map,$(APP_MAP) \
	$(LD_FIRST_OBJECTS) $(OBJECTS) $(LD_LAST_OBJECTS) $(LDLIBS) \
	-o $(APP_ELF)

$(APP_BIN): $(APP_ELF)
	@echo "(OBJCOPY)" $@
	$(OBJCOPY) -O binary $(APP_ELF) $(APP_BIN)

$(APP_HEX): $(APP_ELF)
	@echo "(OBJCOPY)" $@
	$(OBJCOPY) -O ihex $(APP_ELF) $(APP_HEX)

$(APP_LST): $(APP_ELF)
	@echo "(OBJDUMP)" $@
	@$(OBJDUMP) -h -S $(APP_ELF) > $(APP_LST)

size: $(APP_ELF)
	@echo
	@$(SIZE) --format=berkeley $(APP_ELF)
	@echo

size-details: $(APP_ELF)
	$(NM) --size-sort --print-size --reverse-sort --radix=d --demangle \
		$(APP_ELF)

debug: $(APP_ELF)
	@$(GDB) $(APP_ELF)
