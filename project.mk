###############################################################################
# Project makefile included by main makefile
###############################################################################

ifeq ($(VERBOSE), 1)
V = 1
endif

ifneq ($(V), 1)
MAKEFLAGS += --silent
endif

ifndef PROJECT_NAME
$(error PROJECT_NAME is not defined)
endif

SELF_PATH = $(dir $(lastword $(MAKEFILE_LIST)))
HERE := $(SELF_PATH)

###############################################################################
# Configuration
###############################################################################

.DEFAULT_GOAL = all

BUILD_ROOT_PATH ?= ./build

ifdef TOOLCHAIN_PATH
PATH := $(TOOLCHAIN_PATH)/bin:$(PATH)
endif


CC := $(TOOLCHAIN_PREFIX)gcc
CXX := $(TOOLCHAIN_PREFIX)g++
AS := $(TOOLCHAIN_PREFIX)gcc
AR := $(TOOLCHAIN_PREFIX)ar
LD := $(TOOLCHAIN_PREFIX)g++
OBJCOPY := $(TOOLCHAIN_PREFIX)objcopy
OBJDUMP := $(TOOLCHAIN_PREFIX)objdump
SIZE := $(TOOLCHAIN_PREFIX)size
NM := $(TOOLCHAIN_PREFIX)nm
GDB := $(TOOLCHAIN_PREFIX)gdb


export CC CXX AS AR LD OBJCOPY OBJDUMP SIZE NM GDB
export CFLAGS CXXFLAGS ASFLAGS ARFLAGS LDFLAGS


###############################################################################
# Components
###############################################################################

MAIN_COMPONENT_PATH ?= ./main
COMPONENT_ROOT_PATHS ?= ./components

ifndef COMPONENTS
COMPONENTS := $(dir $(foreach cd,$(COMPONENT_ROOT_PATHS),\
	$(wildcard $(cd)/*/component.mk) $(wildcard $(cd)/component.mk) \
))
COMPONENTS := $(sort $(foreach comp,$(COMPONENTS),$(lastword $(subst /, , $(comp)))))
COMPONENTS += main
endif

COMPONENTS := $(filter-out $(EXCLUDE_COMPONENTS), $(COMPONENTS))

COMPONENTS_CLEAN := $(filter-out $(EXCLUDE_COMPONENTS_CLEAN), $(COMPONENTS))

COMPONENT_PATHS := $(foreach comp,$(filter-out main, $(COMPONENTS)),\
	$(firstword $(foreach cd,\
	$(COMPONENT_ROOT_PATHS), $(wildcard $(dir $(cd))$(comp) $(cd)/$(comp)))))

ifneq ($(filter main,$(COMPONENTS)),)
COMPONENT_PATHS += $(MAIN_COMPONENT_PATH)
endif

OBJECTS = $(foreach component,$(COMPONENTS),$(wildcard $(BUILD_ROOT_PATH)/$(component)/*.o))

ifndef INCLUDE_PATHS
INCLUDE_PATHS := 
else
INCLUDE_PATHS := $(INCLUDE_PATHS)
endif

# Include project.mk from component folders

COMPONENT_PROJECT_MAKEFILES := $(foreach path,$(COMPONENT_PATHS),$(path)/project.mk)
BASE_PATH = ./$(SELF_PATH)
-include $(COMPONENT_PROJECT_MAKEFILES)

INCLUDE_PATHS += $(COMPONENT_ROOT_PATHS) $(MAIN_COMPONENT_PATH)

export INCLUDE_PATHS SYMBOLS BUILD_LIBRARIES

# Targets

define ComponentRules
.PHONY: component-$(1)

component-$(1):
	mkdir -p $(BUILD_ROOT_PATH)/$(1)
	@echo "(MAKE)" $(2)
	+$(MAKE) -f $(HERE)/include/component.mk \
	BASE_PATH=$(2) \
	BUILD_PATH=$(BUILD_ROOT_PATH)/$(1)

component-$(1)-clean:
	@echo "(RM)" $(BUILD_ROOT_PATH)/$(1)
	$(RM) -r $(BUILD_ROOT_PATH)/$(1)
endef

$(foreach component,$(COMPONENT_PATHS), \
	$(eval $(call ComponentRules,$(notdir $(component)),$(component))))

components: $(foreach cp, $(COMPONENTS), component-$(cp))


###############################################################################
# Application targets
###############################################################################

ifeq ($(APPLICATION_TYPE), EMBEDDED)
include $(HERE)/include/app_embedded.mk
else
include $(HERE)/include/app_desktop.mk
endif

all: $(APP_ALL)

clean: $(addprefix component-,$(addsuffix -clean,$(COMPONENTS_CLEAN)))
	@echo "(RM)" $(CLEAN_FILES)
	$(RM) $(CLEAN_FILES)

builddir:
	@mkdir -p $(BUILD_ROOT_PATH)


###############################################################################
# Additional helper targets
###############################################################################

include $(HERE)/include/help.mk
include $(HERE)/include/info.mk

