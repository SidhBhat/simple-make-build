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
ifdef SHARED
CFLAGS   += -fpie
endif
ifdef SHARED
CRPATH   =
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
prog_name    = main
#===================================================
override INSTALL          = install -D -p
override INSTALL_PROGRAM  = $(INSTALL) -m 755
override INSTALL_DATA     = $(INSTALL) -m 644
#===================================================
# Source and target objects
#===================================================
SRCS     = $(wildcard $(srcdir)*.c)
OBJS     = $(patsubst $(srcdir)%.c,$(buildir)c%.o,$(SRCS))
MKS      = $(patsubst $(srcdir)%.c,$(buildir)%.mk,$(SRCS))
#=====================================================

build: $(buildir)$(prog_name)
.PHONY: build

install: FILE = $(DESTDIR)$(bindir)$(prog_name)
install:
	@[ -f "$(FILE)" ] && { echo -e "\e[31mError\e[32m $$file exists Defualt behavior is not to overwrite...\e[0m Terminating..."; exit 24; } || true
	$(INSTALL_PROGRAM) $(buildir)$(prog_name) -t $(DESTDIR)$(bindir)
.PHONY:install

debug:
	@echo -e "\e[35mC Source Files   \e[0m: $(SRCS)"
	@echo -e "\e[35mC Make Files     \e[0m: $(MKS)"
	@echo -e "\e[35mC Object Files   \e[0m: $(OBJS)"
	@echo -e "\e[35mmakeflages;makegoals\e[0m:$(MAKEFLAGS) ; $(MAKECMDGOALS)"
.PHONY:debug

help:
	@echo "The follwing targets may be given..."
	@echo -e "\t...install"
	@echo -e "\t...install-c"
	@echo -e "\t...build*"
	@echo -e "\t...build-c"
	@echo -e "\t...uninstall"
	@echo -e "\t...clean"
	@echo "Other options"
	@echo -e "\t...debug"
	@echo -e "\t...help"
.PHONY:help

#=====================================================

$(buildir)$(prog_name): $(OBJS)
ifndef SHARED
	$(CC) $(CFLAGS) -o $@ $(INCLUDES) $(OBJS) $(CLIBS)
else
	$(CC) $(filter-out -pic -fpic -Fpic,$(CFLAGS)) -o $@ $(INCLUDES) -Wl,-rpath="$(RPATH)" $(OBJS) $(CLIBS)
endif


$(buildir)%.mk : $(srcdir)%.c
	@mkdir -p $(@D)
ifndef SHARED
	@$(CC) -M $< -MQ $(buildir)c$*.o | awk '{ print $$0 } END { printf("\t$$(CC) $$(CFLAGS) -c -o $(buildir)c$*.o $<\n") }' > $@
else
	@$(CC) -M $< -MQ $(buildir)c$*.o | awk '{ print $$0 } END { printf("\t$$(CC) $$(filter-out -pie -fpie -Fpie -pic -fpic -Fpic,$$(CFLAGS)) -c -o $(buildir)c$*.o $<\n") }' > $@
endif
	@echo -e "\e[32mCreating Makefile \"$@\"\e[0m..."

override build_targets = install build $(buildir)$(prog_name) $(OBJS)
ifneq ($(strip $(filter $(build_targets),$(MAKECMDGOALS))),)
include $(MKS)
else ifeq ($(MAKECMDGOALS),)
include $(MKS)
endif

#=====================================================

clean:
	rm -rf $(buildir)
.PHONY:clean

uninstall: FILE = $(DESTDIR)$(bindir)$(prog_name)
uninstall:
	rm -f $(FILE)
.PHONY:uninstall
