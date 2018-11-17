# Synopsis

cpmk is a small component based build framework for C/C++ projects based on makefiles.

Main features:

- Handling of all common build tasks
- Reasonable default behaviour but customisable when needed
- Greatly simplifies build configuration setup, minimum makefile consists of 2 lines
- Support for modular project setups via self-contained components
- Cross-compiling support for embedded hardware


# Requirements

- GNU Make
- GCC compatible C/C++ Toolchain


# Usage

## Summary

- Install the framework in an arbitrary location of your project
- Create or edit your main project makefile to setup variables and include
*project.mk* from the framework folder
- Setup your main component under *./main*
- Setup additional components under *./components*
- Run the *make* command for a full build
- Run *make clean* to cleanup the build directory
- Use *V=1* or *VERBOSE=1* optionally to get verbose build messages
- Run *make help* for additional info on targets
- Run *make info* to show the build configuration

**Warning**: Don't use any spaces in path or file names *within* your project! Make will process them as delimiters causing errors. However, having spaces in the path *to* your project is working.


## Toolchain setup

The toolchain binaries must be either in the PATH or be setup via the TOOLCHAIN_PATH environment variable. When using the environment variable, the setting must be the root path of the toolchain, not the *bin* directory.


## Components

A component is a directory with a *component.mk* file that is included when the component is build. This file can contain specific settings for the component but also be empty.

Optionally, a component can have a *project.mk* file that is included at the beginning of the project build. This file can be used for global settings belonging to all components or the whole build process itself.

By default, components must be either the main component under *./main* or reside in a directory named *./components* under the project root. 

**Warning**: Component directories are not scanned recursively. Also, all components must have unique names.

Components can be build and cleaned separately via individual make targets. This can save time in some situations by not having to issue a full *make clean*. You can also check if a components will compile on its own while your project will not build as whole.

Example:

    make component-main           Build component main
    make component-main-clean     Clean component main

*Hint:* The make command will also support tab completion to show the available targets


# Configuration Variables

## Supported Standard Variables

    CC          Compiler for C files (*.c)
    CXX         Compiler for C++ files (*.cpp/*.cc)
    AS          Compiler for Assembler files (*.s)
    AR          Archive maintaining program
    LD          Linker
    OBJDUMP     objdump utility
    OBJCOPY     objcopy utility
    SIZE        size utility
    NM          nm utility
    GDB         Debugger
    CFLAGS      Flags for the C compiler
    CXXFLAGS    Flags for the C++ compiler
    CPPFLAGS    Flags for the C preprocessor
    ASFLAGS     Flags for the assembler
    LDFLAGS     Flags for the linker
    LDLIBS      Library flags for the linker


## Toolchain Settings

    TOOLCHAIN_PATH      Path to the toolchain base directory
    TOOLCHAIN_PREFIX    Prefix for the program names


## Build Output

    PROJECT_NAME        Used for output filenames, must be defined
    APPLICATION_TYPE    Set to EMBEDDED for building .elf, .bin and .hex files
    BUILD_ROOT_PATH     Output directory, defaults to ./build
    V or VERBOSE        Enable verbosity, defaults to 0


## Components Setup

    COMPONENTS              List of components to build, default is empty for all components
    EXCLUDE_COMPONENTS      List of components to exclude
    MAIN_COMPONENT_PATH     Path to main component, defaults to ./main
    COMPONENT_ROOT_PATHS    List of component search paths, defaults to ./components


## Paths and Symbols

    SOURCE_PATHS            Paths to the source files, defaults to component's base directory
    EXCLUDE_SOURCE_FILES    Source files to be excluded from compilation
    INCLUDE_PATHS           Paths to be added via -I compiler flags, defaults to component's base directory and $(COMPONENT_ROOT_PATHS)
    SYMBOLS                 Symbols to be added via -D compiler flags

Paths for sources and includes are relative to the project directory. To construct paths relative to a component, use the variable *$(BASE_PATH)* which is set to the components directory before including the *.component.mk* or *project.mk* makefiles respectively.


## Link Order

These settings allow to change the processing order of objects at the link stage. Files are processed in the order defined by LD_FIRST_OBJECTS, then undeclared objects, then LD_LAST_OBJECTS.

The full relative path to the .o file in the build output directory has to be provided for each object.

    LD_FIRST_OBJECTS    List of objects to appear first in link command
    LD_LAST_OBJECTS     List of objects to appear last in link command

### Background

Some versions of the GNU Arm Embedded Toolchain have a flaw in the linker that leads to have weak symbols removed by mistake, especially when using link time optimization (LTO). This bug mainly affects startup code containing the ISR vector table.

A known workaround is to put any of these files at the start of the object file list when linking. The LD_FIRST_OBJECTS setting allows to achieve this.


# Example

## Minimum Setup for a Hello World Application

*Makefile*

    PROJECT_NAME := Hello_World
    include ./cpmk/project.mk

This assumes that you installed the framework under ./cpmk in your project. Otherwise the path has to be adapted accordingly.

*main/component.mk*

This file must be present but can be empty because the default settings will be sufficient.

*main/main.c*

    #include <stdio.h>

    int main() {
        printf("Hello World\n");
    }

## Detailed Setup for an Embedded Project with STM32 MCU

See [EXAMPLE-STM32.md](EXAMPLE-STM32.md)


# Tested Environments

## Linux Mint 18.3:

- GNU Make 4.1
- GCC 5.4.0
- GNU Arm Embedded Toolchain Version 5-2016-q3-update
- GNU Arm Embedded Toolchain Version 7-2018-q2-update
- AVR GCC 4.9.2

## macOS 10.12:

- GNU Make 3.8.1
- GNU Arm Embedded Toolchain Version 5-2016-q3-update

## Windows 7 (MinGW):
- GNU Make 4.1
- GNU Arm Embedded Toolchain Version 5-2016-q3-update
