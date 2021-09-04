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
startdir = $(CURDIR)
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
OBJS_C    = $(patsubst %.c,%.o,$(subst $(srcdir),$(buildir),$(SRC_C)))
OBJS_CXX1 = $(patsubst %.cc,%.o,$(subst $(srcdir),$(buildir),$(SRC_CXX1)))
OBJS_CXX2 = $(patsubst %.cpp,%.o,$(subst $(srcdir),$(buildir),$(SRC_CXX2)))
OBJS_CXX  = $(filter-out $(OBJS_CXX2),$(OBJS_CXX1)) $(OBJS_CXX2)
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
	@echo -e "source files c   : $(SRC_C)"
	@echo -e "object files c   : $(OBJS_C)"
	@echo -e "source files cc  : $(SRC_CXX1)"
	@echo -e "source files cpp : $(SRC_CXX2)"
	@echo -e "source files c++ : $(SRC_CXX)"
	@echo -e "object files cc  : $(OBJS_CXX1)"
	@echo -e "object files cpp : $(OBJS_CXX2)"
	@echo -e "object files c++ : $(OBJS_CXX)"
.PHONY: debug

build-c++: $(buildir)/$(cxxprog_name)
.PHONY: build-c++

build-c: $(buildir)/$(prog_name)
.PHONY: build-c


#=====================================================
$(buildir)/$(cxxprog_name): $(OBJS_CXX)
	$(CXX) $(CXXFLAGS) $(CXXLIBS) $(OBJS_CXX) -o $(buildir)/$(cxxprog_name)

$(buildir)/$(prog_name): $(OBJS_C)
	$(CC) $(CFLAGS) $(CLIBS) $(OBJS_C) -o $(buildir)/$(prog_name)

$(OBJS_C): $(buildir)/%.o : $(srcdir)/%.c $(buildir)/include-lists/include-listc_%.txt ./headersearch.sh
	@./headersearch.sh $(filter %.txt,$^) $<
	$(CC) $(CFLAGS) -c $< -o $@

$(filter-out $(OBJS_CXX2),$(OBJS_CXX1)): $(buildir)/%.o : $(srcdir)/%.cc $(buildir)/include-lists/include-listcc_%.txt ./headersearch.sh
	@./headersearch.sh $(filter %.txt,$^) $<
	$(CXX) $(CXXFLAGS) -c $< -o $@


$(OBJS_CXX2): $(buildir)/%.o : $(srcdir)/%.cpp $(buildir)/include-lists/include-listcpp_%.txt ./headersearch.sh
	@./headersearch.sh $(filter %.txt,$^) $<
	$(CXX) $(CXXFLAGS) -c $< -o $@

$(buildir)/include-lists/include-listc_%.txt: $(srcdir)/%.c dependlist.sh
	mkdir -p $(dir $@)
	./dependlist.sh $< > $@

$(buildir)/include-lists/include-listcc_%.txt: $(srcdir)/%.cc dependlist.sh
	mkdir -p $(dir $@)
	./dependlist.sh $< > $@

$(buildir)/include-lists/include-listcpp_%.txt: $(srcdir)/%.cpp dependlist.sh
	mkdir -p $(dir $@)
	./dependlist.sh $< > $@

#=====================================================

clean:
	rm -rf $(buildir)
.PHONY: clean

clean-c:
	rm -f $(OBJS_C)
	rm -f $(buildir)/$(prog_name)
	rm -f $(buildir)/include-lists/include-listc_*.txt
.PHONY: clean-c

clean-c++:
	rm -f $(OBJS_CXX)
	rm -f $(buildir)/$(cxxprog_name)
	rm -f $(buildir)/include-lists/include-listcc_*.txt
	rm -f $(buildir)/include-lists/include-listcpp_*.txt
.PHONY: clean-c++

clean-all: clean
	rm -f ./dependlist.sh
	rm -f ./headersearch.sh
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
	@echo "...install"
	@echo "...install-c"
	@echo "...install-c++"
	@echo "...build"
	@echo "...build-c"
	@echo "...build-c++"
	@echo "...uninstall"
	@echo "...uninstall-c"
	@echo "...uninstall-c++"
	@echo "...clean"
	@echo "...clean-c"
	@echo "...clean-c++"
	@echo "...clean-all"
	@echo "Other options"
	@echo "...depend"
	@echo "...debug"
	@echo "...help"
.PHONY: help

hash := \#
depend: dependlist.sh
	mkdir -p $(buildir)/include-lists
	for file in $(srcdir)/*.c ; do \
		name=$${file$(hash)$(hash)*/}; \
		./dependlist.sh "$$file" > $(buildir)/include-lists/include-listc_$${name%.c}.txt; \
	done
	for file in $(srcdir)/*.cc ; do \
		name=$${file$(hash)$(hash)*/}; \
		./dependlist.sh "$$file" > $(buildir)/include-lists/include-listcc_$${name%.cc}.txt; \
	done
	for file in $(srcdir)/*.cpp ; do \
		name=$${file$(hash)$(hash)*/}; \
		./dependlist.sh "$$file" > $(buildir)/include-lists/include-listcc_$${name%.cpp}.txt; \
		mv $(buildir)/include-lists/include-listcc_$${name%.cpp}.txt -T $(buildir)/include-lists/include-listpp_$${name%.cpp}.txt; \
	done
.PHONY: depend

dependlist.sh:
	@echo -e "$(hash)!/bin/bash"\
	"\n$(hash) Generated by makefile, DO NOT EDIT!"\
	"\n[ -f \"\$$1\" ] && {"\
	"\n\tlist=\$$(gcc -M \"\$$1\")"\
	"\n\t[ \$$? -eq 0 ] && {"\
	"\n\t\tlist=\$${list//*.o/}"\
	"\n\t\tlist=\$${list//:/}"\
	"\n\t\tif [ \"\$${1$(hash)$(hash)*.}\" == \"c\" ]; then"\
	"\n\t\t\tlist=\$${list//*.c/}"\
	"\n\t\telif [ \"\$${1$(hash)$(hash)*.}\" == \"cc\" ]; then"\
	"\n\t\t\tlist=\$${list//*.cc/}"\
	"\n\t\telif [ \"\$${1$(hash)$(hash)*.}\" == \"cpp\" ]; then"\
	"\n\t\t\tlist=\$${list//*.cpp/}"\
	"\n\t\tfi"\
	"\n\t\tlist=\$$(echo \"\$$list\" | tr -d '\\\\\\')"\
	"\n\t\tfor file in \$$list; do"\
	"\n\t\t\tfilelist=\"\$$filelist \$$file\""\
	"\n\t\tdone"\
	"\n\t\techo \"\$$filelist\""\
	"\n\t\texit 0"\
	"\n\t}"\
	"\n\texit 1"\
	"\n} || {"\
	"\n\texit 2"\
	"\n}"\
	"\nexit 0"> dependlist.sh
	chmod a+x dependlist.sh

headersearch.sh:
	@echo -e "$(hash)!/bin/bash"\
	"\n$(hash) Generated by makefile, DO NOT EDIT!"\
	"\n[ -f \"\$$1\" ] && {"\
	"\n\tfilelist=\$$(cat \"\$$1\")"\
	"\n} || {"\
	"\n\texit 2"\
	"\n}"\
	"\nfor file in \$$filelist; do"\
	"\n\techo \"Searching for header \\\"\$$file\\\" included from \\\"\$$2\\\"...\""\
	"\n\t[ -f \"\$$file\" ] && {"\
	"\n\t\techo \"Found header \\\"\$$file\\\"...\""\
	"\n\t} || {"\
	"\n\t\techo \"Header \\\"\$$file\\\" not found\""\
	"\n\t\techo \"Compilation terminated\""\
	"\n\t\texit 1"\
	"\n\t}"\
	"\ndone"\
	"\nexit 0" > headersearch.sh
	chmod a+x headersearch.sh

