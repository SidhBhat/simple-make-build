# Introduction

This is the make solution I use to build simple c or c++ projects. This makefile automatically detects the source files in the project tree
(using the `wildcard` function), to generate the depandancy list, and compile into a single executable. This is one of a set of similar sister
projects used to build c and c++ projects.

## How To Use

Using this build solution is simple. All you need to do is copy the [Makefile](Makefile) into your project directory.

```bash
cd /path/to/your/project/
```

then

```bash
curl -sL https://raw.githubusercontent.com/SidhBhat/simple-make-build/main/Makefile > Makefile
```

Now you're going to want to set _these_ variables inside the makefile, to specify where to look for sources and where to build them.

```make
#build configuration
override srcdir     = src/
override buildir    = build/
#program Name
prog_name           = main
```

You are pretty much set now. However here are the compile time variables you can set in the makefile, or through the commandline:

```make
# Compiler options
CXX         = g++
CXXLIBS     =
CXXINCLUDES =
CXXFLAGS    = -g -O -Wall
# Install location
DESTDIR     =
prefix      = /usr/local/
```

## The Directory Structure

The Directory Structure is pretty straightforward. The makefile expects all source files to be directly in `srcdir/`. And all build files are confined
to `buildir/`.

<!-- Mermaid rendering of flowcharts  -->
```mermaid
graph
	ProjectDir-->Makefile
	ProjectDir-->srcdir/
	ProjectDir-->buildir/
	srcdir/-->source_files
	buildir/-->build_files
	buildir/-->executable
```

## Branches

This repository is organised in two branches one `main` and the other `cpp`. You are currently on `cpp`. The `main` branch has the c version. To compile
c++ projects checkout branch `cpp`.

You can also download the latest release:

  - [cpp version](https://github.com/SidhBhat/simple-make-build/releases/tag/v1.6-cpp)
  - [c version](https://github.com/SidhBhat/simple-make-build/releases/tag/v1.6-c)

Prior development included support for c and cpp files in the same makefile. But it was decided to drop that version as nobody actually developed independant
projects on the same project tree.

## Sibling Projects

This Makefile is one among a set of make solutions to build c and c++ projects

  - [make-build_C_app](https://github.com/SidhBhat/make-build_C_app)
  - [make-build_Cpp_app](https://github.com/SidhBhat/make-build_Cpp_app)
  - [make-build_C_lib](https://github.com/SidhBhat/make-build_C_lib)
  - [make-build_Cpp_lib](https://github.com/SidhBhat/make-build_C_lib)
  - [simple-make-build\*](https://github.com/SidhBhat/simple-make-build)

## Contributing
If you would like to contribute, you can start by simply creating a pull request `:)`.
