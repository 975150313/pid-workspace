
# Introduction

PID is a development methodology used to standardize and automate the development process of C/C++ projects on UNIX platforms. The present repository contains the base implementation of PID, based on CMake scripts.

This project defines a **workspace** where users put their C/C++ projects and the workspace repository is used to share references on existing projects, in order to deploy them on users workstations.

PID is also a framwork, made of various C/C++ packages, that are helpful for developping C/C++ code. For deeper understanding and learning of PID readers can refer to [this website](http://pid.lirmm.net/pid-framework)

# What is it useful for ?

The term "methodoloy" is supposed to cover all phases of the development process. My intent when I first write this framework is to provide a packaging system where people can easily share and reuse the projects they work(ed) on, either under source of binary format. Indeed, in the context of my laboratory (LIRMM, Montpellier, France), and more precisely for robotic teams, we had no real frame to develop and share our projects which lead to tremendously complex reuse of code.

The basic idea is to formalize as far as possible (using a CMake API) all aspects of the project (being it software they generate, projects then depends on, way to deal with git branches, available version released, prebuild binaries already available online, documentation or licensing aspects, and so on). This way PID automates everything related to project development in a kind of standard "way of doing".

People that can be interested in using PID are project managers that want to enforce a way to ease sharing and integration of code in their team or institution, but it may be also useful for lone programmers that simply want a clean method for developping their code.

# Key Features

+ Fully based on CMake and git.
+ Management of C/C++ projects in a common an standardized way (same basic commands and options to manage the build process for all projects).
+ Management of source and binary packages in a common way.
+ Management of external binary packages and OS dependencies.
+ Formalization of packages dependencies and versions, automating deployment of dependencies (either binary or source). 
+ Installation of packages is local (no modification of OS configuration, as far as possible).
+ Standardizing and Automating of the release, publishing and deployment process of packages.
+ Standardizing the continuous integration process (based on gitlab ci)
+ Standardizing and Automating online documentation generation (based on gitlab pages, jekyll, doxygen, cppchecks and lcov).
+ Management of repositories for binaries (based on gitlab pages).
+ Standardizing and Automating license management (applying liecnse information everywhere needed), as well as other meta information about the package (authors, contact, etc.).
+ Plugin mechanism to provide addintionnal functionalities to manage external tools (typically IDE). For instance a plugin used to configure `atom-clang-complete` plugin in Atom IDE. 
+ Standardization and management of build environments and target platforms, to allow the management of many execution targets for the same code and easily change the build environment to use (for instance changing the compiler in use for all packages). These features can be used to manage crosscompilation. 


# About the license

pid-workspace and PID base packages are licensed with the CeCILL-C open source license. A copy of the license is available in the file license.txt. 

CeCILL-C is an open source software license equivalent to and compatible with LGPL. The difference is that it is governed by French law and disagreements or disputes shall be referred to the Paris Courts having jurisdiction.


# Install

Please refer to [PID framework website](http://pid.lirmm.net/pid-framework) to get the complete install procedure.

Installing the PID framework is a simple task, as soon as you have adequate dependencies:

- cmake, version 3.0.2 or greater
- git, version 1.7.6 or greater

## if you are a project manager and want to put in place a common isolated environment for your team(s)

+ fork this repository and/or clone it into your own repository server. For instance we use a private instance of gitlab in my laboratory and our official pid-workspace is a specific project in this server. The fork is usefull if you want to provide your modifications (contributions to PID or referencing of your packages) to other teams and people around the world. Indeed the current repository may be used as the global "marketplace" for everyone (this is mainly interesting for open source projects) .

+ clone the forked repository in your workstation


```bash
> git clone <adress of the pid-workspace official repository given by your team leader>
```

+ configure your local repository:

```bash
> cd pid-workspace/pid
> cmake ..
```

+ edit the CMakeLists.txt file by setting the variable `PID_OFFICIAL_REMOTE_ADDRESS` to the address of your official workspace. Then commit/push, that's it your team can start working in an isolated environment. This action ensures that you will not be affected by modifications of this repository unless you specifically decide it (using a dedicated git remote pointing to the current repository).


## if you are member of a team with a specific official repository

+ fork the official repository your team leader has put in place:

+ clone this forked repository:

```bash
> git clone <adress of the pid-workspace official repository given by your team leader>
```

+ configure your local repository:

```bash
> cd pid-workspace/pid
> cmake ..
```

## if you are a lone developper and want to contribute (for instance you want to publish open source packages)

+ fork this repository so that you can use merge requests to provide your contributions. The forked repository becomes your official repository. 

+ clone the forked repository in your workstation:

```bash
> git clone <adress of the pid-workspace official repository given by your team leader>
```

+ configure your local repository:

```bash
> cd pid-workspace/pid
> cmake ..
```

+ edit the CMakeLists.txt file by setting the variable `PID_OFFICIAL_REMOTE_ADDRESS` to the address of your official workspace. Then commit/push to master branch. That's it your team can start working in an isolated environment. This action ensures that you will not be affected by modifications of this repository unless you specifically decide it (using a dedicated git remote pointing to the current repository).


## if you just want to use PID to install some packages provided by third-parties

+ simply clone the current repository into your workstation.

```bash
> git clone <adress of the pid-workspace official repository given by your team leader>
```
+ Then configure your workspace:

```bash
> cd pid-workspace/pid
> cmake ..
```

## Final steps

I recommend to read the documentation in this [website](http://pid.lirmm.net/pid-framework). You will find many resources explaining how to start using PID. 

# Remarks about OS portability

PID has been designed to be usable on most of UNIX platforms, relying mainly on a cross platform CMake API. Nevertheless, it has been tested for linux and notably with Ubuntu and Linux Mint. Most of linux distros should work, but some specific codes should be improved to support other distributions (when for instance you want to automatically deploy system packages with other package managers than apt). Except for this aspect, PID should work well in any case.

-----

Android is not specifically supported and I never test PID on such a system. Nevertheless Android having a linux kernel it should not be too difficult to provide a patch so that it would be fully managed as any linux distro. Of course it may only concern C/C++ development, PID is for now not supporting Java. I let those experts who would like to use PID to manage their packages make some proposals. 

----- 

Mac OSX is a particular case of UNIX system and even if theorically supported, its support has many limits:

- there are not so many prebuild binaries of packages for this OS, which can become painful for installing some packages with dependencies to external binaries.
- the scripts have been tested on linux only, so you may encounter some problem using Mac OSX even if core mechanisms of MAC OSX (notably the management of dynamic libraries model) are implemented.

Any contribution for this popular OS is welcome, being it patch for the PID system or any kind of configuration specific contribution (for instance for managing a packaging system like macport or prebuild binaries for Mac OSX).

----- 

iOS also suffers from the same disadvantage as OSX and the same answer apply here.

----- 

Windows is not supported at all. This is due to the fact that Windows is not a UNIX system and lacks very basic mechanisms that are used by PID (for instance symbolic links). I just have no time to work on this and furthermore I never use Windows so do not expect any contribution from me.

Anyway any contribution that would make PID work on Windows would be very appreciated. The only requirement I have regarding these contributions is that they do not break the functionning for UNIX system. 

# Considering contribution

As told previously, any contribution is welcome:

- new functionalities
- patches for BUGS
- rewriting of comments
- better documentation (like new tutorials)
- etc. 

To provide a contribution simply use the pull/merge request mechanism.

# Contact

If you have any question, remark, proposal about PID, please contact me using the **issues** of the project. 



