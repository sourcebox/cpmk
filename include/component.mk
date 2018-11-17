###############################################################################
# Component build makefile, included by project.mk
###############################################################################


ifndef BASE_PATH
$(error BASE_PATH is not defined)
endif

ifndef BUILD_PATH
$(error BUILD_PATH is not defined)
endif

.DEFAULT_GOAL = build


SOURCE_PATHS := $(BASE_PATH)
INCLUDE_PATHS += $(BASE_PATH)


include $(BASE_PATH)/component.mk


SOURCE_FILES := $(foreach dir,$(SOURCE_PATHS),$(wildcard $(dir)/*.c))
SOURCE_FILES += $(foreach dir,$(SOURCE_PATHS),$(wildcard $(dir)/*.cpp))
SOURCE_FILES += $(foreach dir,$(SOURCE_PATHS),$(wildcard $(dir)/*.cc))
SOURCE_FILES += $(foreach dir,$(SOURCE_PATHS),$(wildcard $(dir)/*.s))
SOURCE_FILES := $(filter-out $(EXCLUDE_SOURCE_FILES), $(SOURCE_FILES))

INCLUDE_FLAGS := $(addprefix -I, $(INCLUDE_PATHS))

SYMBOL_FLAGS := $(addprefix -D, $(SYMBOLS))

OBJECTS := $(foreach file,$(SOURCE_FILES),$(BUILD_PATH)/$(basename $(notdir $(file))).o)


build: $(OBJECTS)


define SourceDirRules
$(BUILD_PATH)/%.o: $(1)/%.c
	@echo "(CC)" $$<
	$(CC) $(CFLAGS) $(CPPFLAGS) $(INCLUDE_FLAGS) $(SYMBOL_FLAGS) -c \
	-o $$@ $$< \
	-Wp,-MMD,$(BUILD_PATH)/$$*.d,-MT"$$@"

$(BUILD_PATH)/%.o: $(1)/%.cpp
	@echo "(CXX)" $$<
	$(CXX) $(CXXFLAGS) $(CPPFLAGS) $(INCLUDE_FLAGS) $(SYMBOL_FLAGS) -c \
	-o $$@ $$< \
	-Wp,-MMD,$(BUILD_PATH)/$$*.d,-MT"$$@"

$(BUILD_PATH)/%.o: $(1)/%.cc
	@echo "(CXX)" $$<
	$(CXX) $(CXXFLAGS) $(CPPFLAGS) $(INCLUDE_FLAGS) $(SYMBOL_FLAGS) -c \
	-o $$@ $$< \
	-Wp,-MMD,$(BUILD_PATH)/$$*.d,-MT"$$@"

$(BUILD_PATH)/%.o: $(1)/%.s
	@echo "(AS)" $$<
	$(AS) $(ASFLAGS) -c \
	-o $$@ $$< \
	-Wp,-MMD,$(BUILD_PATH)/$$*.d,-MT"$$@"
endef

$(foreach srcdir, $(SOURCE_PATHS),$(eval $(call SourceDirRules,$(srcdir))))

-include $(OBJECTS:.o=.d)
