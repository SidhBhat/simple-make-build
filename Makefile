#!/usr/bin/make -f
# Set environment variables

# this makefile follows the below conventions for variables denoting files and directories
# all directory names must end with a terminal '/' character
# file names never end in terminal '/' character


#===================================================

SHELL = /bin/bash

# set this variable if using shared library, to any value (cleaning existing build files may be necessary).
SHARED =

#===================================================
# Compile commands
#===================================================
CC       = gcc
CLIBS    =
INCLUDES =
CFLAGS   = -g -O -Wall
CXX      = g++
CXXLIBS  =
CXXINCLUDES =
CXXFLAGS = -g -O -Wall
ifdef SHARED
CFLAGS   += -fpie
CXXFLAGS += -fpie
endif
ifdef SHARED
CRPATH   =
CXXRPATH =
endif
#===================================================
# Build Directories
#===================================================
override srcdir     = src/
override buildir    = build/
#===================================================
# Install directories
#===================================================
DESTDIR     =
prefix      = /usr/local/
override exec_prefix = $(prefix)
override bindir      = $(exec_prefix)/bin/
override datarootdir = $(prefix)/share/
override datadir     = $(datarootdir)
override libdir      = $(prefix)/lib/
#===================================================
prog_name    = mainc
cxxprog_name = maincxx
#===================================================
override INSTALL          = install -D -p
override INSTALL_PROGRAM  = $(INSTALL) -m 755
override INSTALL_DATA     = $(INSTALL) -m 644
#===================================================
# Source and target objects
#===================================================
CXX1SRCS  = $(wildcard $(srcdir)*.cpp)
CXX2SRCS  = $(wildcard $(srcdir)*.cxx)
CXXSRCS   = $(CXX1SRCS) $(CXX2SRCS)
CXXOBJS   = $(patsubst $(srcdir)%.cpp,$(buildir)cpp%.o,$(CXX1SRCS)) $(patsubst $(srcdir)%.cxx,$(buildir)cxx%.o,$(CXX2SRCS))
CXXMKS    = $(patsubst $(srcdir)%.cpp,$(buildir)pp%.mk,$(CXX1SRCS)) $(patsubst $(srcdir)%.cxx,$(buildir)xx%.mk,$(CXX2SRCS))
CSRCS     = $(wildcard $(srcdir)*.c)
COBJS     = $(patsubst $(srcdir)%.c,$(buildir)c%.o,$(CSRCS))
CMKS      = $(patsubst $(srcdir)%.c,$(buildir)%.mk,$(CSRCS))
#=====================================================

build: build-c build-c++
.PHONY:build

build-c++: $(buildir)$(cxxprog_name)
.PHONY: build-c++

build-c: $(buildir)$(prog_name)
.PHONY: build-c

install:install-c install-c++
.PHONY:install

install-c: FILE = $(DESTDIR)$(bindir)$(prog_name)
install-c:
	@[ -f "$(FILE)" ] && { echo -e "\e[31mError\e[32m $$file exists Defualt behavior is not to overwrite...\e[0m Terminating..."; exit 24; } || true
	$(INSTALL_PROGRAM) $(buildir)$(prog_name) -t $(DESTDIR)$(bindir)
.PHONY:install-c

install-c++: FILE = $(DESTDIR)$(bindir)$(cxxprog_name)
install-c++:
	@[ -f "$(FILE)" ] && { echo -e "\e[31mError\e[32m $$file exists Defualt behavior is not to overwrite...\e[0m Terminating..."; exit 24; } || true
	$(INSTALL_PROGRAM) $(buildir)$(cxxprog_name) -t $(DESTDIR)$(bindir)
.PHONY:install-c++

debug:
	@echo -e "\e[35mC++ Source Files \e[0m: $(CXXSRCS)"
	@echo -e "\e[35mC++ Make Files   \e[0m: $(CXXMKS)"
	@echo -e "\e[35mC++ Object Files \e[0m: $(CXXOBJS)"
	@echo    "#-------------------------------------------#"
	@echo -e "\e[35mC Source Files   \e[0m: $(CSRCS)"
	@echo -e "\e[35mC Make Files     \e[0m: $(CMKS)"
	@echo -e "\e[35mC Object Files   \e[0m: $(COBJS)"
	@echo -e "\e[35mmakeflages;makegoals\e[0m:$(MAKEFLAGS) ; $(MAKECMDGOALS)"
.PHONY:debug

help:
	@echo "The follwing targets may be given..."
	@echo -e "\t...install"
	@echo -e "\t...install-c"
	@echo -e "\t...install-c++"
	@echo -e "\t...build*"
	@echo -e "\t...build-c"
	@echo -e "\t...build-c++"
	@echo -e "\t...uninstall"
	@echo -e "\t...uninstall-c"
	@echo -e "\t...uninstall-c++"
	@echo -e "\t...clean"
	@echo "Other options"
	@echo -e "\t...debug"
	@echo -e "\t...help"
.PHONY:help

#=====================================================

$(buildir)$(prog_name): $(COBJS)
ifndef SHARED
	$(CC) $(CFLAGS) -o $@ $(INCLUDES) $(COBJS) $(CLIBS)
else
	$(CC) $(filter-out -pic -fpic -Fpic,$(CFLAGS)) -o $@ $(INCLUDES) -Wl,-rpath="$(RPATH)" $(COBJS) $(CLIBS)
endif

$(buildir)$(cxxprog_name): $(CXXOBJS)
ifndef SHARED
	$(CXX) $(CXXFLAGS) -o $@ $(CXXINCLUDES) $(CXXOBJS) $(CXXLIBS)
else
	$(CXX) $(filter-out -pic -fpic -Fpic,$(CXXFLAGS)) -o $@ $(CXXINCLUDES) -Wl,-rpath="$(RPATH)" $(CXXOBJS) $(CXXLIBS)
endif

$(buildir)%.mk : $(srcdir)%.c
	@mkdir -p $(@D)
ifndef SHARED
	@$(CC) -M $< | awk '{ if(/^$(subst .mk,,$(@F))/) { printf("%s%s\n","$(@D)/c",$$0) } else { print $$0 } } END { printf("\t$(CC) $(CFLAGS) -c -o $(buildir)c$*.o $<")}' > $@
else
	@$(CC) -M $< | awk '{ if(/^$(subst .mk,,$(@F))/) { printf("%s%s\n","$(@D)/c",$$0) } else { print $$0 } } END { printf("\t$(CC) $(filter-out -pie -fpie -Fpie -pic -fpic -Fpic,$(CFLAGS)) -c -o $(buildir)c$*.o $<")}' > $@
endif
	@echo -e "\e[32mCreating Makefile \"$@\"\e[0m..."

$(buildir)pp%.mk : $(srcdir)%.cpp
	@mkdir -p $(@D)
ifndef SHARED
	@$(CXX) -M $< | awk '{ if(/^$(patsubst pp%.mk,%,$(@F))/) { printf("%s%s\n","$(@D)/cpp",$$0) } else { print $$0 } } END { printf("\t$(CXX) $(CXXFLAGS) -c -o $(buildir)cpp$*.o $<")}' > $@
else
	@$(CXX) -M $< | awk '{ if(/^$(patsubst pp%.mk,%,$(@F))/) { printf("%s%s\n","$(@D)/cpp",$$0) } else { print $$0 } } END { printf("\t$(CXX) $(filter-out -pie -fpie -Fpie -pic -fpic -Fpic,$(CXXFLAGS)) -c -o $(buildir)cpp$*.o $<")}' > $@
endif
	@echo -e "\e[32mCreating Makefile \"$@\"\e[0m..."

$(buildir)xx%.mk : $(srcdir)%.cxx
	@mkdir -p $(@D)
ifndef SHARED
	@$(CXX) -M $< | awk '{ if(/^$(patsubst xx%.mk,%,$(@F))/) { printf("%s%s\n","$(@D)/cxx",$$0) } else { print $$0 } } END { printf("\t$(CXX) $(CXXFLAGS) -c -o $(buildir)cxx$*.o $<")}' > $@
else
	@$(CXX) -M $< | awk '{ if(/^$(patsubst xx%.mk,%,$(@F))/) { printf("%s%s\n","$(@D)/cxx",$$0) } else { print $$0 } } END { printf("\t$(CXX) $(filter-out -pie -fpie -Fpie -pic -fpic -Fpic,$(CXXFLAGS)) -c -o $(buildir)cxx$*.o $<")}' > $@
endif
	@echo -e "\e[32mCreating Makefile \"$@\"\e[0m..."

ifneq ($(strip $(filter build $(buildir)$(prog_name) $(OBJS),$(MAKECMDGOALS))),)
include $(CMKS) $(CXXMKS)
else ifeq ($(MAKECMDGOALS),)
include $(CMKS) $(CXXMKS)
endif

#=====================================================

clean:
	rm -rf $(buildir)
.PHONY:clean

uninstall:uninstall-c uninstall-c++
.PHONY:uninstall

uninstall-c: FILE = $(DESTDIR)$(bindir)$(prog_name)
uninstall-c:
	rm -f $(FILE)
.PHONY:uninstall

uninstall-c++: FILE = $(DESTDIR)$(bindir)$(cxxprog_name)
uninstall-c++:
	rm -f $(FILE)
.PHONY:uninstall
