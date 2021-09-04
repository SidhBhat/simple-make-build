#!/usr/bin/make -f
# Set environment variables
#===================================================

SHELL = /bin/bash

#===================================================
# Compile commands
#===================================================
CC       = gcc
CXX      = g++
CLIBS    =
CXXLIBS  =
CFLAGS   = -g -O -Wall
CXXFLAGS = -g -O -Wall
#===================================================
# Build Directories
#===================================================
srcdir   = ./src
buildir  = ./build
#===================================================
# Install directories
#===================================================
prefix      = /usr/local
exec_prefix = $(prefix)
bindir      = $(exec_prefix)/bin
datarootdir = $(prefix)/share
datadir     = $(datarootdir)
DESTDIR     =
#===================================================
INSTALL         = install -D
INSTALL_PROGRAM = $(INSTALL) -m 755
INTALL_DATA     = $(INSTALL) -m 644
#===================================================
# Names of programs
#===================================================
prog_name = mainc
cxxprog_name = maincxx
# Error if names are same, to avoid conflict
ifeq ($(strip $(prog_name)), $(strip $(cxxprog_name)))
    $(error "'cxxprog_name' and 'prog_name' cannot be the same")
endif
#====================================================
# Source and target objects
#===================================================
SRC_C     = $(wildcard $(srcdir)/*.c)
SRC_CXX1  = $(wildcard $(srcdir)/*.cc)
SRC_CXX2  = $(wildcard $(srcdir)/*.cpp)
SRC_CXX   = $(SRC_CXX1) $(SRC_CXX2)
OBJS_C    = $(patsubst %.c,%.o,$(subst $(srcdir)/,$(buildir)/c,$(SRC_C)))
OBJS_CXX1 = $(patsubst %.cc,%.o,$(subst $(srcdir)/,$(buildir)/cc,$(SRC_CXX1)))
OBJS_CXX2 = $(patsubst %.cpp,%.o,$(subst $(srcdir)/,$(buildir)/cc,$(SRC_CXX2)))
OBJS_CXX  = $(filter-out $(OBJS_CXX2),$(OBJS_CXX1)) $(OBJS_CXX2)
MK_C      = $(patsubst %.c,%.mk,$(subst $(srcdir)/,$(buildir)/Make-list/makec-,$(SRC_C)))
MK_CXX1   = $(patsubst %.cc,%.mk,$(subst $(srcdir)/,$(buildir)/Make-list/makecc-,$(SRC_CXX1)))
MK_CXX2   = $(patsubst %.cpp,%.mk,$(subst $(srcdir)/,$(buildir)/Make-list/makecc-,$(SRC_CXX2)))
MK_CXX    = $(filter-out $(MK_CXX2),$(MK_CXX1)) $(MK_CXX2)
#=====================================================

build: build-c build-c++
.PHONY: build

install: install-c install-c++
.PHONY: install

install-c: build-c
	@[ -f "$(DESTDIR)$(bindir)/$(prog_name)" ] && { \
		echo -e "\e[35mWarning\e[0m: file named \"$(prog_name)\" exits at \"$(DESTDIR)$(bindir)/$(prog_name)\""; \
		echo "Defualt behavoir is not to overwrite."; \
	} || { \
		echo "Installing file \"$(prog_name)\" at \"$(DESTDIR)$(bindir)/$(prog_name)\""; \
		$(INSTALL_PROGRAM) $(buildir)/$(prog_name) -T $(DESTDIR)$(bindir)/$(prog_name); \
	}
.PHONY: install-c

install-c++: build-c++
	@[ -f "$(DESTDIR)$(bindir)/$(cxxprog_name)" ] && { \
		echo -e "\e[35mWarning\e[0m: file named \"$(cxxprog_name)\" exits at \"$(DESTDIR)$(bindir)/$(cxxprog_name)\""; \
		echo "Defualt behavoir is not to overwrite."; \
	} || { \
		echo "Installing file \"$(cxxprog_name)\" at \"$(DESTDIR)$(bindir)/$(cxxprog_name)\""; \
		$(INSTALL_PROGRAM) $(buildir)/$(cxxprog_name) -T $(DESTDIR)$(bindir)/$(cxxprog_name); \
	}
.PHONY: install-c++

debug:
	@echo "current directory: $(startdir) : $(CURDIR)"
	@echo "MAKE : $(MAKE) $(MAKEFLAGS)"
	@echo "------------------------------------->"
	@echo "source files c   : $(SRC_C)"
	@echo "source files c++ : $(SRC_CXX)"
	@echo "------------------------------------->"
	@echo "object files c   : $(OBJS_C)"
	@echo "object files c++ : $(OBJS_CXX)"
	@echo "------------------------------------->"
	@echo "make files c     : $(MK_C)"
	@echo "make files c++   : $(MK_CXX)"
	@echo "------------------------------------->"
	@echo "source files cc  : $(SRC_CXX1)"
	@echo "source files cpp : $(SRC_CXX2)"
	@echo "object files cc  : $(OBJS_CXX1)"
	@echo "object files cpp : $(OBJS_CXX2)"
	@echo "make files cc    : $(MK_CXX1)"
	@echo "make files cpp   : $(MK_CXX2)"
	@echo "------------------------------------->"
.PHONY: debug

build-c++: $(buildir)/$(cxxprog_name)
.PHONY: build-c++

build-c: $(buildir)/$(prog_name)
.PHONY: build-c

#==============================Build Instructions==================================
$(buildir)/$(cxxprog_name):$(OBJS_CXX)
	$(CXX) $(CXXFLAGS) $(OBJS_CXX) $(CXXLIBS) -o $(buildir)/$(cxxprog_name)

$(buildir)/$(prog_name):$(OBJS_C)
	$(CC) $(CFLAGS) $(OBJS_C) $(CLIBS) -o $(buildir)/$(prog_name)

$(MK_C): $(buildir)/Make-list/makec-%.mk : $(srcdir)/%.c dependlist.sh
	@mkdir -p $(dir $@)
	@./dependlist.sh "$<" "$(CC) $(CFLAGS) -c $< -o $(buildir)/c$*.o" > $@
	@sed -i '1s/^/$(subst /,\/,$(buildir)/c)/' $@
	@echo "Creating make file... $@"

$(filter-out $(MK_CXX2),$(MK_CXX1)): $(buildir)/Make-list/makecc-%.mk : $(srcdir)/%.cc dependlist.sh
	@mkdir -p $(dir $@)
	@./dependlist.sh "$<" "$(CXX) $(CXXFLAGS) -c $< -o $(buildir)/cc$*.o" > $@
	@sed -i '1s/^/$(subst /,\/,$(buildir)/cc)/' $@
	@echo "Creating make file... $@"

$(MK_CXX2): $(buildir)/Make-list/makecc-%.mk : $(srcdir)/%.cpp dependlist.sh
	@mkdir -p $(dir $@)
	@./dependlist.sh "$<" "$(CXX) $(CXXFLAGS) -c $< -o $(buildir)/cc$*.o" > $@
	@sed -i '1s/^/$(subst /,\/,$(buildir)/cc)/' $@
	@echo "Creating make file... $@"

# $(OBJS_C): $(buildir)/c%.o : $(buildir)/Make-list/makec-%.mk
# 	@$(MAKE) -C $(CURDIR) -f $< $(MAKEFLAGS)
#
# $(OBJS_CXX): $(buildir)/cc%.o : $(buildir)/Make-list/makecc-%.mk
# 	@$(MAKE) -C $(CURDIR) -f $< $(MAKEFLAGS)

include $(MK_C) $(MK_CXX)

#==================================================================================

clean:
	rm -rf $(buildir)
.PHONY: clean

clean-c:
	rm -f $(OBJS_C)
	rm -f $(buildir)/$(prog_name)
	rm -f $(buildir)/include-lists/makec-*.mk
.PHONY: clean-c

clean-c++:
	rm -f $(OBJS_CXX)
	rm -f $(buildir)/$(cxxprog_name)
	rm -f $(buildir)/Make-list/makecc_*.mk
.PHONY: clean-c++

clean-all: clean
	rm -f ./dependlist.sh
.PHONY: clean-all

uninstall-c:
	rm -f $(DESTDIR)$(bindir)/$(prog_name)
.PHONY: uninstall-c

uninstall-c++:
	rm -f $(DESTDIR)$(bindir)/$(cxxprog_name)
.PHONY: uninstall-c++

uninstall: uninstall-c uninstall-c++
.PHONY: uninstall

help:
	@echo "The follwing targets may be given..."
	@echo -e "\t...install"
	@echo -e "\t...install-c"
	@echo -e "\t...install-c++"
	@echo -e "\t...build"
	@echo -e "\t...build-c"
	@echo -e "\t...build-c++"
	@echo -e "\t...uninstall"
	@echo -e "\t...uninstall-c"
	@echo -e "\t...uninstall-c++"
	@echo -e "\t...clean"
	@echo -e "\t...clean-c"
	@echo -e "\t...clean-c++"
	@echo -e "\t...clean-all"
	@echo "Other options"
	@echo -e "\t...depend"
	@echo -e "\t...depend-c"
	@echo -e "\t...depend-c++"
	@echo -e "\t...debug"
	@echo -e "\t...help"
.PHONY: help

hash := \#
depend: depend-c depend-c++
.PHONY: depend

depend-c: dependlist.sh
	@mkdir -p $(buildir)/Make-list
	@for file in $(srcdir)/*.c; do \
		name=$${file$(hash)$(hash)*/}; \
		./dependlist.sh "$$file" "$(CC) $(CFLAGS) -c $$file -o $(buildir)/c$${name%.c}.o" > $(buildir)/Make-list/makec-$${name%.c}.mk; \
		sed -i '1s/^/$(subst /,\/,$(buildir))\//' $(buildir)/Make-list/makec-$${name%.c}.mk; \
		echo "Creating Make file... \"$(buildir)/Make-list/makec-$${name%.c}.mk\""; \
	done
.PHONY: depend

depend-c++: dependlist.sh
	@mkdir -p $(buildir)/Make-list
	@for file in $(srcdir)/*.cc; do \
		name=$${file$(hash)$(hash)*/}; \
		./dependlist.sh "$$file" "$(CC) $(CFLAGS) -c $$file -o $(buildir)/cc$${name%.cc}.o" > $(buildir)/Make-list/makecc-$${name%.cc}.mk; \
		sed -i '1s/^/$(subst /,\/,$(buildir))\//' $(buildir)/Make-list/makecc-$${name%.cc}.mk; \
		echo "Creating Make file... \"$(buildir)/Make-list/makecc-$${name%.cc}.mk\""; \
	done
	@for file in $(srcdir)/*.cpp; do \
		name=$${file$(hash)$(hash)*/}; \
		./dependlist.sh "$$file" "$(CC) $(CFLAGS) -c $$file -o $(buildir)/cc$${name%.cpp}.o" > $(buildir)/Make-list/makecc-$${name%.cpp}.mk; \
		sed -i '1s/^/$(subst /,\/,$(buildir))\//' $(buildir)/Make-list/makecc-$${name%.cpp}.mk; \
		echo "Creating Make file... \"$(buildir)/Make-list/makecc-$${name%.cpp}.mk\""; \
	done
.PHONY: depend-c++

dependlist.sh:
	@echo -e "$(hash)!/bin/bash"\
	"\n$(hash) Generated by makefile, DO NOT EDIT!"\
	"\n[ -f \"\$$1\" ] && {"\
	"\n\tgcc -M \"\$$1\""\
	"\n\techo -e \"\\\\t\$$2\""\
	"\n\texit 0"\
	"\n} || {"\
	"\n\texit 1"\
	"\n}" >> dependlist.sh
	@chmod u+x,g+x dependlist.sh
	@echo "srcipt: dependlist.sh generated."
