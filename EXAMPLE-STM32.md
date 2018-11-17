# Example

This example setup shows configuration settings for a STM32F3 target. It also demonstrates some features regarding component specific build settings and include path handling.

## Project Structure

    components/
        component1/
            inc/
                file1.h
            src/
                file1.cpp
            component.mk
            project.mk
        component2/
            component.mk
            file2.h
            file2.cpp
     main/
        main.c
        component.mk
        stm32f30x.ld
        stm32f30x_startup.s
    tools/
        cpmk/
            ...
    Makefile
    env.mk

## Project configuration

*Makefile*

    PROJECT_NAME := Example_Project
    APPLICATION_TYPE := EMBEDDED
    TOOLCHAIN_PREFIX ?= arm-none-eabi-
    LD_SCRIPT = ./main/stm32f30x.ld

    ifneq ($(DEBUG), 1)
    OPT_FLAGS = -O2 -ffunction-sections -fdata-sections
    else
    OPT_FLAGS = -O0 -g -ffunction-sections -fdata-sections
    endif

    ARCH_FLAGS = -mcpu=cortex-m4 -mthumb -mfpu=fpv4-sp-d16 -mfloat-abi=hard

    ERROR_FLAGS = -Wall

    CFLAGS = -std=gnu11 $(OPT_FLAGS) $(ARCH_FLAGS) $(ERROR_FLAGS)

    CXXFLAGS = -std=gnu++17 $(OPT_FLAGS) $(ARCH_FLAGS) $(ERROR_FLAGS) -fno-exceptions -fno-rtti

    ASFLAGS = -x assembler-with-cpp $(ARCH_FLAGS)

    LDFLAGS = -T$(LD_SCRIPT) -nostartfiles -Xlinker --gc-sections \
    -fno-rtti -fno-exceptions -static $(OPT_FLAGS) $(ARCH_FLAGS) $(ERROR_FLAGS)

    SYMBOLS = USE_HAL_DRIVER STM32F303xC

    LD_FIRST_OBJECTS = $(BUILD_ROOT_PATH)/main/stm32f30x_startup.o

    -include ./env.mk
    include ./tools/cpmk/project.mk

*env.mk*

Put local settings here that belong to your setup and should not be under version control.

    TOOLCHAIN_PATH = /home/user/toolchains/gcc-arm-none-eabi-7-2018-q2-update
    VERBOSE = 1

## Component configuration

### Component 1

*components/component1/component.mk*

    SOURCE_PATHS += $(BASE_PATH)/src
    CFLAGS += -O3

*components/component1/project.mk*

Setting the include path project-wide here allows component2 also to use it without any path prefixes. Additionally *file1.cpp* is made phony, so it will recompile every time without any modification check.

    INCLUDE_PATHS += $(BASE_PATH)/inc
    .PHONY: $(BASE_PATH)/src/file1.cpp

*components/component1/src/file1.cpp*

    #include "file1.h"
    ...

### Component 2

*components/component2/component.mk*

This file can be empty because the default settings will be sufficient.

*components/component2/file2.cpp*

    #include "file1.h"
    #include "file2.h"
    ...

### Main Component

*main/component.mk*

This file can be empty because the default settings will be sufficient.

*main/main.cpp*

*file1.h* can be included without path because of extending the include paths in *components/component1/project.mk*

*file2.h* has to be prefixed with the component name to get included successfully.

    #include "file1.h"
    #include "component2/file2.h"
