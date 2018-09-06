#########################################################################################
#       This file is part of the program PID                                            #
#       Program description : build system supportting the PID methodology              #
#       Copyright (C) Robin Passama, LIRMM (Laboratoire d'Informatique de Robotique     #
#       et de Microelectronique de Montpellier). All Right reserved.                    #
#                                                                                       #
#       This software is free software: you can redistribute it and/or modify           #
#       it under the terms of the CeCILL-C license as published by                      #
#       the CEA CNRS INRIA, either version 1                                            #
#       of the License, or (at your option) any later version.                          #
#       This software is distributed in the hope that it will be useful,                #
#       but WITHOUT ANY WARRANTY; without even the implied warranty of                  #
#       MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the                    #
#       CeCILL-C License for more details.                                              #
#                                                                                       #
#       You can find the complete license description on the official website           #
#       of the CeCILL licenses family (http://www.cecill.info/index.en.html)            #
#########################################################################################

##########################################################################################
############################ Guard for optimization of configuration process #############
##########################################################################################
if(PACKAGE_DEFINITION_INCLUDED)
  return()
endif()
set(PACKAGE_DEFINITION_INCLUDED TRUE)
##########################################################################################

list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/system/api)
list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/system/commands)

include(PID_Package_API_Internal_Functions NO_POLICY_SCOPE)
include(External_Definition NO_POLICY_SCOPE) #to be able to interpret content of external package description files
include(CMakeParseArguments)

#.rst:
#
# .. ifmode:: user
#
#  .. |declare_PID_Package| replace:: ``declare_PID_Package``
#  .. _declare_PID_Package:
#
#  declare_PID_Package
#  -------------------
#
#   .. command:: declare_PID_Package(AUTHOR ... YEAR ... LICENSE ... DESCRIPTION ... [OPTIONS])
#
#     Declare the current CMake project as a PID package with specific meta-information passed as parameters.
#
#     .. rubric:: Required parameters
#
#     :AUTHOR <name>: The name of the author in charge of maintaining the package.
#     :YEAR <dates>: Reflects the lifetime of the package, e.g. ``YYYY-ZZZZ`` where ``YYYY`` is the creation year and ``ZZZZ`` the latest modification date.
#     :LICENSE <license name>: The name of the license applying to the package. This must match one of the existing license file in the ``licenses`` directory of the workspace.
#     :DESCRIPTION <description>: A short description of the package usage and utility.
#
#     .. rubric:: Optional parameters
#
#     :INSTITUTION <institutions>: Define the institution(s) to which the reference author belongs.
#     :MAIL <e-mail>: E-mail of the reference author.
#     :ADDRESS <url>: The url of the package's official repository. Must be set once the package is published.
#     :PUBLIC_ADDRESS <url>: Can be used to provide a public counterpart to the repository `ADDRESS`
#     :README <path relative to share folder>: Used to define a user-defined README file for the package.
#
#     .. admonition:: Constraints
#        :class: warning
#
#        - This function must be called in the root ``CMakeLists.txt`` file of the package before any other call to the PID API.
#        - It must be called **exactly once**.
#
#     .. admonition:: Effects
#        :class: important
#
#        Initialization of the package internal state. After this call the package's content can be defined.
#
#     .. rubric:: Example
#
#     .. code-block:: cmake
#
#        declare_PID_Package(
#                          AUTHOR Robin Passama
#                          INSTITUTION LIRMM
#                          YEAR 2013-2018
#                          LICENSE CeCILL
#                          ADDRESS git@gite.lirmm.fr:passama/a-given-package.git
#                          DESCRIPTION "an example PID package"
#        )
#
macro(declare_PID_Package)
set(oneValueArgs LICENSE ADDRESS MAIL PUBLIC_ADDRESS README)
set(multiValueArgs AUTHOR INSTITUTION YEAR DESCRIPTION)
cmake_parse_arguments(DECLARE_PID_PACKAGE "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )
if(NOT DECLARE_PID_PACKAGE_AUTHOR)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, an author name must be given using AUTHOR keyword.")
endif()
if(NOT DECLARE_PID_PACKAGE_YEAR)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, a year or year interval must be given using YEAR keyword.")
endif()
if(NOT DECLARE_PID_PACKAGE_LICENSE)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, a license type must be given using LICENSE keyword.")
endif()
if(NOT DECLARE_PID_PACKAGE_DESCRIPTION)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, a (short) description of the package must be given using DESCRIPTION keyword.")
endif()

if(DECLARE_PID_PACKAGE_UNPARSED_ARGUMENTS)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, unknown arguments ${DECLARE_PID_PACKAGE_UNPARSED_ARGUMENTS}.")
endif()

if(NOT DECLARE_PID_PACKAGE_ADDRESS AND DECLARE_PID_PACKAGE_PUBLIC_ADDRESS)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, the package must have an adress if a public access adress is declared.")
endif()

declare_Package(	"${DECLARE_PID_PACKAGE_AUTHOR}" "${DECLARE_PID_PACKAGE_INSTITUTION}" "${DECLARE_PID_PACKAGE_MAIL}"
			"${DECLARE_PID_PACKAGE_YEAR}" "${DECLARE_PID_PACKAGE_LICENSE}"
			"${DECLARE_PID_PACKAGE_ADDRESS}" "${DECLARE_PID_PACKAGE_PUBLIC_ADDRESS}"
		"${DECLARE_PID_PACKAGE_DESCRIPTION}" "${DECLARE_PID_PACKAGE_README}")
endmacro(declare_PID_Package)

#.rst:
# .. ifmode:: user
#
#  .. |set_PID_Package_Version| replace:: ``set_PID_Package_Version``
#  .. _set_PID_Package_Version:
#
#  set_PID_Package_Version
#  -----------------------
#
#  .. command:: set_PID_Package_Version(MAJOR MINOR [PATCH])
#
#   Set the current version number of the package.
#
#   .. rubric:: Required parameters
#
#   :MAJOR: A positive number indicating the major version number.
#   :MINOR: A positive number indicating the minor version number.
#
#   .. rubric:: Optional parameters
#
#   :PATCH: A positive number indicating the patch version number. If not defined, it will default to ``0``.
#
#   .. admonition:: Constraints
#      :class: warning
#
#      - This function must be called in the root ``CMakeLists.txt`` file of the package, after |declare_PID_Package|_ but before |build_PID_Package|_.
#      - It must be called **exactly once**.
#
#   .. admonition:: Effects
#      :class: important
#
#      Setting the current version number will affect the binar installation folder and configuration files.
#
#   .. rubric:: Example
#
#   .. code-block:: cmake
#
#      set_PID_Package_Version(1 2)
#
macro(set_PID_Package_Version)
if(${ARGC} EQUAL 3)
	set_Current_Version(${ARGV0} ${ARGV1} ${ARGV2})
elseif(${ARGC} EQUAL 2)
	set_Current_Version(${ARGV0} ${ARGV1} 0)
else()
  finish_Progress(GLOBAL_PROGRESS_VAR)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, you need to input a major and a minor number, optionnaly you can set a patch version (considered as 0 if not set).")
endif()
endmacro(set_PID_Package_Version)

#.rst:
# .. ifmode:: user
#
#  .. |add_PID_Package_Author| replace:: ``add_PID_Package_Author``
#  .. _add_PID_Package_Author:
#
#  add_PID_Package_Author
#  -----------------------
#
#  .. command:: add_PID_Package_Author(AUTHOR ... [INSTITUTION ...])
#
#   Add an author to the list of authors.
#
#   .. rubric:: Required parameters
#
#   :AUTHOR <name>: Name of the additional author.
#
#   .. rubric:: Optional parameters
#
#   :INSTITUTION <institutions>: Institution(s) to which the author belongs.
#
#   .. admonition:: Constraints
#      :class: warning
#
#      - This function must be called in the root ``CMakeLists.txt`` file of the package, after |declare_PID_Package|_ but before |build_PID_Package|_.
#
#   .. admonition:: Effects
#     :class: important
#
#     Add an author to the list of authors.
#
#   .. rubric:: Example
#
#   .. code-block:: cmake
#
#      add_PID_Package_Author(AUTHOR Benjamin Navarro INSTITUTION LIRMM)
#
macro(add_PID_Package_Author)
set(multiValueArgs AUTHOR INSTITUTION)
cmake_parse_arguments(ADD_PID_PACKAGE_AUTHOR "" "" "${multiValueArgs}" ${ARGN} )
if(NOT ADD_PID_PACKAGE_AUTHOR_AUTHOR)
  finish_Progress(GLOBAL_PROGRESS_VAR)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, an author name must be given using AUTHOR keyword.")
endif()
add_Author("${ADD_PID_PACKAGE_AUTHOR_AUTHOR}" "${ADD_PID_PACKAGE_AUTHOR_INSTITUTION}")
endmacro(add_PID_Package_Author)

#.rst:
# .. ifmode:: user
#
#  add_PID_Package_Reference
#  -------------------------
#
#  .. command:: add_PID_Package_Reference(VERSION ... PLATFORM ... URL ...)
#
#   Declare a reference to a known binary version of the package. This is useful to register various released version of the package.
#
#   .. rubric:: Required parameters
#
#   :VERSION <major>.<minor>[.<patch>]: The full version number of the referenced binary package. See |set_PID_Package_Version|_.
#
#   :PLATFORM <name>: The name of the target plaftorm for which the binary package has been built.
#
#   :URL <url-rel> <url-dbg>:
#     - ``<url-rel>`` is the url of the package binary release build
#     - ``<url-dbg>`` is the url of the package binary debug build.
#
#   .. admonition:: Constraints
#      :class: warning
#
#      - This function must be called in the root ``CMakeLists.txt`` file of the package, after |declare_PID_Package|_ but before |build_PID_Package|_.
#
#   .. admonition:: Effects
#     :class: important
#
#     Declare a reference that defines where to find an installable binary for a given platform.
#
#     PID uses this information to generate a CMake configuration file that will be used to retrieve this package version. This is the only way to define direct references to binary packages.
#
#   .. rubric:: Example
#
#   .. code-block:: cmake
#
#    add_PID_Package_Reference(VERSION 1.0.0 PLATFORM x86_linux_64_abi11
#      URL https://gite.lirmm.fr/pid/pid-binaries/wikis/pid-rpath/1.0.0/linux64/pid-rpath-1.0.0-linux64.tar.gz
#          https://gite.lirmm.fr/pid/pid-binaries/wikis/pid-rpath/1.0.0/linux64/pid-rpath-1.0.0-dbg-linux64.tar.gz
#    )
#
macro(add_PID_Package_Reference)
set(oneValueArgs VERSION PLATFORM)
set(multiValueArgs  URL)
cmake_parse_arguments(ADD_PID_PACKAGE_REFERENCE "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )

if(NOT ADD_PID_PACKAGE_REFERENCE_URL)
  finish_Progress(GLOBAL_PROGRESS_VAR)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, you need to set the urls where to find binary packages for release and debug modes, using URL <release addr> <debug addr>.")
else()
	list(LENGTH ADD_PID_PACKAGE_REFERENCE_URL SIZE)
	if(NOT SIZE EQUAL 2)
    finish_Progress(GLOBAL_PROGRESS_VAR)
		message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, you need to set the urls where to find binary packages for release and debug modes using URL <release addr> <debug addr>.")
	endif()
endif()
list(GET ADD_PID_PACKAGE_REFERENCE_URL 0 URL_REL)
list(GET ADD_PID_PACKAGE_REFERENCE_URL 1 URL_DBG)

if(NOT ADD_PID_PACKAGE_REFERENCE_PLATFORM)
  finish_Progress(GLOBAL_PROGRESS_VAR)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, you need to set the target platform name using PLATFORM keyword.")
endif()

if(NOT ADD_PID_PACKAGE_REFERENCE_VERSION)
  finish_Progress(GLOBAL_PROGRESS_VAR)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, you need to input a target version number (with major and minor values, optionnaly you can also set a patch value which is considered as 0 if not set) using VERSION keyword.")
else()
	get_Version_String_Numbers(${ADD_PID_PACKAGE_REFERENCE_VERSION} MAJOR MINOR PATCH)
  if(NOT DEFINED MAJOR)
    finish_Progress(GLOBAL_PROGRESS_VAR)
  	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, the version number is corrupted (should follow the pattern major.minor[.patch]).")
  endif()
  #manage PID v1 API way of doing
	set(TARGET_PLATFORM_FOR_REFERENCE ${ADD_PID_PACKAGE_REFERENCE_PLATFORM})

	if(TARGET_PLATFORM_FOR_REFERENCE)#target platform cannot be determined
		if(NOT PATCH)
			add_Reference("${MAJOR}.${MINOR}.0" "${TARGET_PLATFORM_FOR_REFERENCE}" "${URL_REL}" "${URL_DBG}")
		else()
			add_Reference("${MAJOR}.${MINOR}.${PATCH}" "${TARGET_PLATFORM_FOR_REFERENCE}" "${URL_REL}" "${URL_DBG}")
		endif()
	endif()#otherwise simply do not add the reference, cannot resolve with new platform naming standard
endif()
endmacro(add_PID_Package_Reference)

#.rst:
# .. ifmode:: user
#
#  .. |add_PID_Package_Category| replace:: ``add_PID_Package_Category``
#  .. _add_PID_Package_Category:
#
#  add_PID_Package_Category
#  ------------------------
#
#  .. command:: add_PID_Package_Category(CATEGORY)
#
#   Declare that the current package belongs to a given category.
#
#   .. rubric:: Required parameters
#
#   :CATEGORY: A string describing the category to which the package belongs. Sub-categories are divided by ``/``.
#
#   .. admonition:: Constraints
#      :class: warning
#
#      - This function must be called in the root ``CMakeLists.txt`` file of the package, after |declare_PID_Package|_ but before |build_PID_Package|_.
#
#   .. admonition:: Effects
#     :class: important
#
#     Register the package has being member of the given (sub)category. This information will be added to the :ref:`package reference file` when it is generated.
#
#   .. rubric:: Example
#
#   .. code-block:: cmake
#
#    add_PID_Package_Category(example/packaging)
#
macro(add_PID_Package_Category)
if(NOT ${ARGC} EQUAL 1)
  finish_Progress(GLOBAL_PROGRESS_VAR)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, the add_PID_Package_Category command requires one string argument of the form <category>[/subcategory]*.")
endif()
add_Category("${ARGV0}")
endmacro(add_PID_Package_Category)

macro(declare_PID_Documentation)
	message("[PID] WARNING : the declare_PID_Documentation is deprecated and is no more used in PID version 2. To define a documentation site please use declare_PID_Publishing function. Skipping documentation generation phase.")
endmacro(declare_PID_Documentation)

#.rst:
# .. ifmode:: user
#
#  .. |declare_PID_Publishing| replace:: ``declare_PID_Publishing``
#  .. _declare_PID_Publishing:
#
#  declare_PID_Publishing
#  -----------------------
#
#  .. command:: declare_PID_Publishing(AUTHOR ... [INSTITUTION ...])
#
#   Declare a site where the package is published, i.e. an online website where documentation and binaries of the package ar stored and accessible. There are two alternative for this function: defining a lone static site or defining the publication of the package in a framework.
#
#   .. rubric:: Required parameters
#
#   :PROJECT <url>: Where to find the project page.
#
#   One of the two following options must be selected.
#
#   :FRAMEWORK <name>: The package belongs to the ``name`` framework. It will contribute to that site.
#   :GIT <url>: A stand-alone package. ``<url>`` is the git repository for the static site of this package.
#
#   When the ``GIT`` option is used, the following argument is also required:
#
#   :PAGE <url>: ``<url>`` is the online url of the static site.
#
#   .. rubric:: Optional parameters
#
#   :DESCRIPTION <description>: A long description of the package utility.
#   :TUTORIAL <file>: ``<file>`` should be a markdown file relative to the ``share/site`` folder of the package. This will be used to generate a tutorial webpage.
#   :ADVANCED <file>: ``<file>`` should be a markdown file relative to the ``share/site`` folder of the package. This will be used to generate an advanced description page.
#   :PUBLISH_BINARIES: If this is present, the package will automatically publish new binaries to the publication site.
#   :PUBLISH_DEVELOPMENT_INFO: If this is present, the package website will contain information for developpers such as coverage reports and static checks.
#   :ALLOWED_PLATFORMS <list of platforms>: This argument lists the set of platforms used for CI, only the specified platforms will be managed in the CI process. **WARNING: Due to gitlab limitation (only one pipeline can be defined) only ONE platform is allowed at the moment.**
#
#   When the ``GIT`` option is used, the following argument is also accepted:
#
#   :LOGO <path>: ``<path>`` is an image file that will be used as a logo. The file path is relative to the ``share/site`` folder of the package.
#
#   .. admonition:: Constraints
#      :class: warning
#
#      - This function must be called in the root ``CMakeLists.txt`` file of the package, after |declare_PID_Package|_ but before |build_PID_Package|_. It should also be called after every call to |set_PID_Package_Version|_, |add_PID_Package_Author|_ and |add_PID_Package_Category|_.
#
#   .. admonition:: Effects
#     :class: important
#
#     The main effect is to generate or update a static site for the project. This static site locally resides in a dedicated git repository. If the project belongs to no framework then it has its lone static site that can be found in sites/packages/<package name>. If it belongs to a framework, the framework repository can be found in sites/frameworks/<framework name>. In this later case, the package only contributes to its own related content not the overall content of the framework.
#
#     In both case, depending on how the package is built, the package will generate different kind of documentation (API documentatio, static check reports, coverage reports, etc.). Depending on options it can also deploy binaries or developper info for the current version and target platform into the static site repository (framework or lone static site).
#
#   .. rubric:: Example
#
#   Declaring the publication of the ``pid-rpath`` package as a stand-alone package:
#
#   .. code-block:: cmake
#
#    declare_PID_Publishing(PROJECT https://gite.lirmm.fr/pid/pid-rpath
#    			GIT git@gite.lirmm.fr:pid/pid-rpath-pages.git
#    			PAGE http://pid.lirmm.net/pid-rpath
#    			DESCRIPTION pid-rpath is a package providing a little API to ease the management of runtime resources within a PID workspace. Runtime resources may be either configuration files, executables or module libraries. Its usage is completely bound to the use of PID system.
#    			ADVANCED specific_usage.md
#    			LOGO	img/rouage_PID.jpg
#    			PUBLISH_BINARIES)
#
#  Declaring the publication of the ``pid-rpath`` package into the ``PID`` framework:
#
#  .. code-block:: cmake
#
#   declare_PID_Publishing(	PROJECT https://gite.lirmm.fr/pid/pid-rpath
#   			FRAMEWORK pid
#   			DESCRIPTION pid-rpath is a package providing a little API to ease the management of runtime resources within a PID workspace. Runtime resources may be either configuration files, executables or module libraries. Its usage is completely bound to the use of PID system.
#   			ADVANCED specific_usage.md
#   			PUBLISH_BINARIES)
#
macro(declare_PID_Publishing)
set(optionArgs PUBLISH_BINARIES PUBLISH_DEVELOPMENT_INFO)
set(oneValueArgs PROJECT FRAMEWORK GIT PAGE ADVANCED TUTORIAL LOGO)
set(multiValueArgs DESCRIPTION ALLOWED_PLATFORMS)
cmake_parse_arguments(DECLARE_PID_PUBLISHING "${optionArgs}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )

	#manage configuration of CI
if(DECLARE_PID_PUBLISHING_ALLOWED_PLATFORMS)
	foreach(platform IN LISTS DECLARE_PID_PUBLISHING_ALLOWED_PLATFORMS)
		allow_CI_For_Platform(${platform})
	endforeach()
	set(DO_CI TRUE)
else()
	set(DO_CI FALSE)
endif()

if(DECLARE_PID_PUBLISHING_FRAMEWORK)
	if(NOT DECLARE_PID_PUBLISHING_PROJECT)
    finish_Progress(GLOBAL_PROGRESS_VAR)
		message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, you must tell where to find the project page of the official package repository using PROJECT keyword.")
	endif()
	if(${PROJECT_NAME}_FRAMEWORK AND (NOT ${PROJECT_NAME}_FRAMEWORK STREQUAL ""))
    finish_Progress(GLOBAL_PROGRESS_VAR)
		message(FATAL_ERROR "[PID] CRITICAL ERROR: a framework (${${PROJECT_NAME}_FRAMEWORK}) has already been defined, cannot define a new one !")
		return()
	elseif(${PROJECT_NAME}_SITE_GIT_ADDRESS AND (NOT ${PROJECT_NAME}_SITE_GIT_ADDRESS STREQUAL ""))
    finish_Progress(GLOBAL_PROGRESS_VAR)
		message(FATAL_ERROR "[PID] CRITICAL ERROR: a static site (${${PROJECT_NAME}_SITE_GIT_ADDRESS}) has already been defined, cannot define a framework !")
		return()
	endif()
	init_Documentation_Info_Cache_Variables("${DECLARE_PID_PUBLISHING_FRAMEWORK}" "${DECLARE_PID_PUBLISHING_PROJECT}" "" "" "${DECLARE_PID_PUBLISHING_DESCRIPTION}")
	set(PUBLISH_DOC TRUE)
elseif(DECLARE_PID_PUBLISHING_GIT)
	if(NOT DECLARE_PID_PUBLISHING_PROJECT)
    finish_Progress(GLOBAL_PROGRESS_VAR)
		message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, you must tell where to find the project page of the official package repository using PROJECT keyword.")
	endif()
	if(NOT DECLARE_PID_PUBLISHING_PAGE)
    finish_Progress(GLOBAL_PROGRESS_VAR)
		message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, you must tell where to find the index page for the static site of the package (using PAGE keyword).")
	endif()
	if(${PROJECT_NAME}_FRAMEWORK AND (NOT ${PROJECT_NAME}_FRAMEWORK STREQUAL ""))
    finish_Progress(GLOBAL_PROGRESS_VAR)
		message(FATAL_ERROR "[PID] CRITICAL ERROR: a framework (${${PROJECT_NAME}_FRAMEWORK}) has already been defined, cannot define a static site !")
		return()
	elseif(${PROJECT_NAME}_SITE_GIT_ADDRESS AND (NOT ${PROJECT_NAME}_SITE_GIT_ADDRESS STREQUAL ""))
    finish_Progress(GLOBAL_PROGRESS_VAR)
		message(FATAL_ERROR "[PID] CRITICAL ERROR: a static site (${${PROJECT_NAME}_SITE_GIT_ADDRESS}) has already been defined, cannot define a new one !")
		return()
	endif()
	init_Documentation_Info_Cache_Variables("" "${DECLARE_PID_PUBLISHING_PROJECT}" "${DECLARE_PID_PUBLISHING_GIT}" "${DECLARE_PID_PUBLISHING_PAGE}" "${DECLARE_PID_PUBLISHING_DESCRIPTION}")
	set(PUBLISH_DOC TRUE)
else()
	set(PUBLISH_DOC FALSE)
endif()#otherwise there is no site contribution

#manage publication of binaries
if(DECLARE_PID_PUBLISHING_PUBLISH_BINARIES)
	if(NOT PUBLISH_DOC)
    finish_Progress(GLOBAL_PROGRESS_VAR)
		message(FATAL_ERROR "[PID] CRITICAL ERROR : you cannot publish binaries of the project (using PUBLISH_BINARIES) if you do not publish package ${PROJECT_NAME} using a static site (either use FRAMEWORK or SITE keywords).")
	endif()
	if(NOT DO_CI)
    finish_Progress(GLOBAL_PROGRESS_VAR)
		message(FATAL_ERROR "[PID] CRITICAL ERROR : you cannot publish binaries of the project (using PUBLISH_BINARIES) if you do not allow any CI process for package ${PROJECT_NAME} (use ALLOWED_PLATFORMS to defines which platforms will be used in CI process).")
	endif()
	publish_Binaries(TRUE)
else()
	publish_Binaries(FALSE)
endif()

#manage publication of information for developpers
if(DECLARE_PID_PUBLISHING_PUBLISH_DEVELOPMENT_INFO)
	if(NOT PUBLISH_DOC)
    finish_Progress(GLOBAL_PROGRESS_VAR)
		message(FATAL_ERROR "[PID] CRITICAL ERROR : you cannot publish development info of the project (using PUBLISH_DEVELOPMENT_INFO) if you do not publish package ${PROJECT_NAME} using a static site (either use FRAMEWORK or SITE keywords).")
	endif()
	if(NOT DO_CI)
    finish_Progress(GLOBAL_PROGRESS_VAR)
		message(FATAL_ERROR "[PID] CRITICAL ERROR : you cannot publish development info of the project (using PUBLISH_DEVELOPMENT_INFO) if you do not allow any CI process for package ${PROJECT_NAME} (use ALLOWED_PLATFORMS to defines which platforms will be used in CI process).")
	endif()
	publish_Development_Info(TRUE)
else()
	publish_Development_Info(FALSE)
endif()

#user defined doc
if(DECLARE_PID_PUBLISHING_ADVANCED)
	define_Documentation_Content(advanced "${DECLARE_PID_PUBLISHING_ADVANCED}")
else()
	define_Documentation_Content(advanced FALSE)
endif()
if(DECLARE_PID_PUBLISHING_TUTORIAL)
	define_Documentation_Content(tutorial "${DECLARE_PID_PUBLISHING_TUTORIAL}")
else()
	define_Documentation_Content(tutorial FALSE)
endif()
if(DECLARE_PID_PUBLISHING_LOGO)
	define_Documentation_Content(logo "${DECLARE_PID_PUBLISHING_LOGO}")
else()
	define_Documentation_Content(logo FALSE)
endif()
endmacro(declare_PID_Publishing)

#.rst:
# .. ifmode:: user
#
#  .. |declare_PID_Component_Documentation| replace:: ``declare_PID_Component_Documentation``
#  .. _declare_PID_Component_Documentation:
#
#  declare_PID_Component_Documentation
#  -----------------------------------
#
#  .. command:: declare_PID_Component_Documentation(COMPONENT ... FILE ...)
#
#   Add specific documentation for a component
#
#   .. rubric:: Required parameters
#
#   :COMPONENT <name>: Name of the component for which a markdown page is provided.
#   :FILE <path>: Path to the markdown page for the specified component. ``<path>`` is relative to the ``share/site`` folder of the package.
#
#   .. admonition:: Constraints
#      :class: warning
#
#      - The component must have been declared with |declare_PID_Component|_.
#
#   .. admonition:: Effects
#     :class: important
#
#     This function registers a markdown page with documentation about the component. This page can be used to generate a specific web page for the component than will be put in the static site defined by the package deployment, see |declare_PID_Publishing|_.
#
#   .. rubric:: Example
#
#   .. code-block:: cmake
#
#    declare_PID_Component_Documentation(COMPONENT my-lib FILE mylib_usage.md)
#
macro(declare_PID_Component_Documentation)
set(oneValueArgs COMPONENT FILE)
cmake_parse_arguments(DECLARE_PID_COMPONENT_DOCUMENTATION "" "${oneValueArgs}" "" ${ARGN} )
if(NOT DECLARE_PID_COMPONENT_DOCUMENTATION_FILE)
  finish_Progress(GLOBAL_PROGRESS_VAR)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, you must define the file or folder that contains specific documentation content for the project using FILE keyword.")
endif()
if(NOT DECLARE_PID_COMPONENT_DOCUMENTATION_COMPONENT)
  finish_Progress(GLOBAL_PROGRESS_VAR)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, you must define a component name for this content using COMPONENT keyword.")
endif()
#user defined doc for a given component
define_Component_Documentation_Content(${DECLARE_PID_COMPONENT_DOCUMENTATION_COMPONENT} "${DECLARE_PID_COMPONENT_DOCUMENTATION_FILE}")
endmacro(declare_PID_Component_Documentation)

#.rst:
# .. ifmode:: user
#
#  check_PID_Platform
#  ------------------
#
#  .. command:: check_PID_Platform(CONFIGURATION ... [OPTIONS])
#
#   Check if the current target platform conforms to the given platform configuration. If constraints are violated then the configuration of the package fail. Otherwise the project will be configured and built accordingly. The configuration will be checked only if the current platform matches some constraints. If there is no constraint then the configuration is checked whatever the current target platform is.
#
#   .. rubric:: Required parameters
#
#   :CONFIGURATION <configurations>: Check the given configurations against the current target platform.
#
#   .. rubric:: Optional parameters
#
#   These parameters can be used to refine the configuration check.
#
#   :TYPE <arch>: Constraint on the processor type.
#   :OS <name>: Constraint on the operating system.
#   :ARCH <32|64>: Constraint on the processor architecture.
#   :ABI <CXX|CXX11>: Constraint on the ABI of the compiler.
#
#   .. admonition:: Constraints
#      :class: warning
#
#      - This function must be called in the root ``CMakeLists.txt`` file of the package, after |declare_PID_Package|_ but before |build_PID_Package|_.
#
#   .. admonition:: Effects
#     :class: important
#
#     Add an author to the list of authors.
#     First it checks if the current target platform of the workspace satisfies the specified constraints (TYPE, OS, ARCH and ABI). If all constraints are not respected then nothing is checked and the configuration of the package continues. Otherwise, the package configuration must be checked before continuing the configuration. Each configuration required is then checked individually. This can lead to the automatic install of some configuration, if this is possible (i.e. if there is a known way to install this configuration), which is typically the case for system software dependencies like libraries when:
#
#     1. No cross compilation takes place
#     2. The host system distribution is managed by the configuration (most of time debian like distributions are managed for installable configurations).
#
#     If the target plaform conforms to all required configurations, then the configuration continue. Otherwise the configuratin fails.
#
#   .. rubric:: Example
#
#   Checking that if the target platform is a linux with 32 bits architecture, then it must provide ``posix`` and ``x11`` configruation.
#
#   .. code-block:: cmake
#
#      check_PID_Platform(OS linux ARCH 32 CONFIGURATION posix x11)
#
#   Checking that any target platform provides an openssl configuration.
#
#   .. code-block:: cmake
#
#      check_PID_Platform(openssl)
#
macro(check_PID_Platform)
set(oneValueArgs NAME OS ARCH ABI TYPE)
set(multiValueArgs CONFIGURATION)
cmake_parse_arguments(CHECK_PID_PLATFORM "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )
if(CHECK_PID_PLATFORM_NAME)
	message("[PID] WARNING : NAME is a deprecated argument. Platforms are now defined at workspace level and this macro now check if the current platform satisfies configuration constraints according to the optionnal conditions specified by TYPE, ARCH, OS and ABI. The only constraints that will be checked are those for which the current platform satisfies the conditions.")
	if(NOT CHECK_PID_PLATFORM_OS)
    finish_Progress(GLOBAL_PROGRESS_VAR)
		message(FATAL_ERROR "[PID] CRITICAL ERROR : you must define at least an OS when using the deprecated NAME keyword")
	endif()
	if(NOT CHECK_PID_PLATFORM_ARCH)
    finish_Progress(GLOBAL_PROGRESS_VAR)
		message(FATAL_ERROR "[PID] CRITICAL ERROR : you must define at least an ARCH when using the deprecated NAME keyword")
	endif()
	check_Platform_Constraints(RESULT IS_CURRENT "" "${CHECK_PID_PLATFORM_ARCH}" "${CHECK_PID_PLATFORM_OS}" "${CHECK_PID_PLATFORM_ABI}" "${CHECK_PID_PLATFORM_CONFIGURATION}") #no type as it was not managed with PID v1
	set(${CHECK_PID_PLATFORM_NAME} ${IS_CURRENT})
	if(IS_CURRENT AND NOT RESULT)
    finish_Progress(GLOBAL_PROGRESS_VAR)
		message(FATAL_ERROR "[PID] CRITICAL ERROR: when calling check_PID_Platform, constraint cannot be satisfied !")
	endif()

else()
	if(NOT CHECK_PID_PLATFORM_CONFIGURATION)
    finish_Progress(GLOBAL_PROGRESS_VAR)
		message(FATAL_ERROR "[PID] CRITICAL ERROR : you must use the CONFIGURATION keyword to describe the set of configuration constraints that apply to the current platform.")
	endif()

	#checking the constraints
	check_Platform_Constraints(RESULT IS_CURRENT "${CHECK_PID_PLATFORM_TYPE}" "${CHECK_PID_PLATFORM_ARCH}" "${CHECK_PID_PLATFORM_OS}" "${CHECK_PID_PLATFORM_ABI}" "${CHECK_PID_PLATFORM_CONFIGURATION}")
	if(NOT RESULT)
    finish_Progress(GLOBAL_PROGRESS_VAR)
		message(FATAL_ERROR "[PID] CRITICAL ERROR: when calling check_PID_Platform, constraint cannot be satisfied !")
	endif()
endif()
endmacro(check_PID_Platform)

#.rst:
# .. ifmode:: user
#
#  .. |get_PID_Platform_Info| replace:: ``get_PID_Platform_Info``
#  .. _get_PID_Platform_Info:
#
#  get_PID_Platform_Info
#  -----------------------
#
#  .. command:: get_PID_Platform_Info([OPTIONS])
#
#   Get information about the target platform. This can be used to configure the build accordingly.
#
#   .. rubric:: Optional parameters
#
#   All arguments are optional but at least one must be provided. All properties are retrieved for the target platform.
#
#   :NAME <VAR>: Output the name of the target platform in ``VAR``
#   :TYPE <VAR>: Ouptut the processor type in ``VAR``
#   :OS <VAR>: Output the OS name in ``VAR``
#   :ARCH <VAR>: Output the architecture in ``VAR``
#   :ABI <VAR>: Output the ABI in ``VAR``
#   :DISTRIBUTION <VAR>: Output the distribution in ``VAR``
#   :PYTHON <VAR>: Output the Python version in ``VAR``
#
#   .. admonition:: Effects
#     :class: important
#
#     After the call, the variables defined by the user will be set to the corresponding value. Then it can be used to control the configuration of the package.
#
#   .. rubric:: Example
#
#   .. code-block:: cmake
#
#      add_PID_Package_Author(AUTHOR Benjamin Navarro INSTITUTION LIRMM)
#
function(get_PID_Platform_Info)
set(oneValueArgs NAME OS ARCH ABI TYPE PYTHON DISTRIBUTION VERSION)
cmake_parse_arguments(GET_PID_PLATFORM_INFO "" "${oneValueArgs}" "" ${ARGN} )
set(OK FALSE)
if(GET_PID_PLATFORM_INFO_NAME)
	set(OK TRUE)
	set(${GET_PID_PLATFORM_INFO_NAME} ${CURRENT_PLATFORM} PARENT_SCOPE)
endif()
if(GET_PID_PLATFORM_INFO_TYPE)
	set(OK TRUE)
	set(${GET_PID_PLATFORM_INFO_TYPE} ${CURRENT_PLATFORM_TYPE} PARENT_SCOPE)
endif()
if(GET_PID_PLATFORM_INFO_OS)
	set(OK TRUE)
	set(${GET_PID_PLATFORM_INFO_OS} ${CURRENT_PLATFORM_OS} PARENT_SCOPE)
endif()
if(GET_PID_PLATFORM_INFO_ARCH)
	set(OK TRUE)
	set(${GET_PID_PLATFORM_INFO_ARCH} ${CURRENT_PLATFORM_ARCH} PARENT_SCOPE)
endif()
if(GET_PID_PLATFORM_INFO_ABI)
	set(OK TRUE)
  if(CURRENT_PLATFORM_ABI STREQUAL "abi11")
    set(${GET_PID_PLATFORM_INFO_ABI} CXX11 PARENT_SCOPE)
  elseif(CURRENT_PLATFORM_ABI STREQUAL "abi98")
    set(${GET_PID_PLATFORM_INFO_ABI} CXX PARENT_SCOPE)
  endif()
endif()
if(GET_PID_PLATFORM_INFO_PYTHON)
		set(OK TRUE)
		set(${GET_PID_PLATFORM_INFO_PYTHON} ${CURRENT_PYTHON} PARENT_SCOPE)
endif()
if(GET_PID_PLATFORM_INFO_DISTRIBUTION)
		set(OK TRUE)
		set(${GET_PID_PLATFORM_INFO_DISTRIBUTION} ${CURRENT_DISTRIBUTION} PARENT_SCOPE)
endif()
if(GET_PID_PLATFORM_INFO_DISTRIBUTION_VERSION)
		set(OK TRUE)
		set(${GET_PID_PLATFORM_INFO_DISTRIBUTION_VERSION} ${CURRENT_DISTRIBUTION_VERSION} PARENT_SCOPE)
endif()
if(NOT OK)
	message("[PID] ERROR : you must use one or more of the NAME, TYPE, ARCH, OS or ABI keywords together with corresponding variables that will contain the resulting property of the current platform in use.")
endif()
endfunction(get_PID_Platform_Info)

macro(check_All_PID_Default_Platforms)
set(multiValueArgs CONFIGURATION)
message("[PID] WARNING : the check_All_PID_Default_Platforms function is deprecated as check_PID_Platform will now do the job equaly well.")

check_PID_Platform(NAME linux64 OS linux ARCH 64 ABI CXX)
check_PID_Platform(NAME linux32 OS linux ARCH 32 ABI CXX)
check_PID_Platform(NAME linux64cxx11 OS linux ARCH 64 ABI CXX11)
check_PID_Platform(NAME macosx64 OS macosx ARCH 64 ABI CXX)

cmake_parse_arguments(CHECK_PID_PLATFORM "" "" "${multiValueArgs}" ${ARGN} )

if(CHECK_PID_PLATFORM_CONFIGURATION)
	check_Platform_Constraints(RESULT IS_CURRENT "" "" "" "" "${CHECK_PID_PLATFORM_CONFIGURATION}")
	if(NOT RESULT)
    finish_Progress(GLOBAL_PROGRESS_VAR)
		message(FATAL_ERROR "[PID] CRITICAL ERROR : when calling check_All_PID_Default_Platforms, the current platform dos not satisfy configuration constraints.")
	endif()
endif()
endmacro(check_All_PID_Default_Platforms)

#.rst:
# .. ifmode:: user
#
#  .. |build_PID_Package| replace:: ``build_PID_Package``
#  .. _build_PID_Package:
#
#  build_PID_Package
#  -----------------
#
#  .. command:: build_PID_Package()
#
#   Automatically configure a PID package according to previous information.
#
#   .. admonition:: Constraints
#      :class: warning
#
#      - This function must be called **last** in the root ``CMakeLists.txt`` file of the package.
#
#   .. admonition:: Effects
#     :class: important
#
#     This function generates configuration files, manage the generation of the global native build process and include the `CMakeLists.txt` files from the following folders (in that order): ``src``, ``apps``, ``test``, ``share``.
#
#   .. rubric:: Example
#
#   .. code-block:: cmake
#
#      build_PID_Package()
#
macro(build_PID_Package)
if(${ARGC} GREATER 0)
  finish_Progress(GLOBAL_PROGRESS_VAR)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, the build_PID_Package command requires no arguments.")
endif()
build_Package()
endmacro(build_PID_Package)

#.rst:
# .. ifmode:: user
#
#  .. |declare_PID_Component| replace:: ``declare_PID_Component``
#  .. _declare_PID_Component:
#
#  declare_PID_Component
#  -----------------------
#
#  .. command:: declare_PID_Component(<type> NAME ... DIRECTORY .. [OPTIONS])
#
#   Declare a new component in the current package.
#
#   .. rubric:: Required parameters
#
#   :<type>: - ``STATIC_LIB``: static library
#            - ``SHARED_LIB``: shared library
#            - ``MODULE_LIB``: shared library without header
#            - ``HEADER_LIB``: header-only library
#            - ``APPLICATION``: standard application
#            - ``EXAMPLE_APPLICATION``: example code
#            - ``TEST_APPLICATION``: unit test
#   :NAME <name>: Unique identifier of the component. ``name`` cannot contain whitespaces.
#   :DIRECTORY <dir>: Sub-folder where to find the component sources. This is relative to the current `CMakeLists.txt` folder.
#
#   .. rubric:: Optional parameters
#
#   :DESCRIPTION <text>: Provides a description of the component. This will be used in generated documentation.
#   :USAGE <list of headers to include>: This should be used to list useful includes to put in client code. This is used for documentation purpose.
#   :C_STANDARD <90|99|11>: C language standard used to build the component. Defaults to ``90`` (i.e. ANSI-C)
#   :CXX_STANDARD <98|11|14|17>: C++ language standard used to build the component. Defaults to ``98``.
#   :RUNTIME_RESOURCES <files>: ``<files>`` is a list of files and folders relative to the ``share/resources`` folder. These files will be installed automatically and should be accessed in a PID component using the `pid-rpath <http://pid.lirmm.net/pid-framework/packages/pid-rpath>`_ package.
#   :INTERNAL: This flag is used to introduce compilation options that are only used by this component.
#   :EXPORTED: This flag is used to export compilation options. Meaning, components that later refer to this component will be using these options.
#
#   The following options are supported by the ``INTERNAL`` and ``EXPORTED`` commands:
#   :DEFINITIONS <defs>: Preprocessor definitions.
#   :LINKS <links>: Linker flags.
#   :COMPILER_OPTIONS <options>: Compiler-specific options.
#
#   Furthermore, the ``INTERNAL`` option also support the following commands:
#   :INCLUDE_DIRS <dirs>: Additional include directories.
#
#   .. admonition:: Constraints
#      :class: warning
#
#      - <type> acceptability depends on the current folder.
#
#   .. admonition:: Effects
#     :class: important
#
#     Defines a new component in the package. Will create related targets to build the component and install it (if applicable).
#
#   .. rubric:: Example
#
#   .. code-block:: cmake
#
#      add_PID_Package_Author(AUTHOR Benjamin Navarro INSTITUTION LIRMM)
#      declare_PID_Component(STATIC_LIB NAME my-static-lib DIRECTORY binary_lib
#                            INTERNAL DEFINITIONS EXPORT_SYMBOLS
#                            EXPORT DEFINITIONS IMPORT_SYMBOLS
#     )
#
macro(declare_PID_Component)
set(options STATIC_LIB SHARED_LIB MODULE_LIB HEADER_LIB APPLICATION EXAMPLE_APPLICATION TEST_APPLICATION PYTHON_PACK)
set(oneValueArgs NAME DIRECTORY C_STANDARD CXX_STANDARD)
set(multiValueArgs INTERNAL EXPORTED RUNTIME_RESOURCES DESCRIPTION USAGE)
cmake_parse_arguments(DECLARE_PID_COMPONENT "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )
if(DECLARE_PID_COMPONENT_UNPARSED_ARGUMENTS)
  finish_Progress(GLOBAL_PROGRESS_VAR)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, unknown arguments ${DECLARE_PID_COMPONENT_UNPARSED_ARGUMENTS}.")
endif()

#check for the name argument
if(NOT DECLARE_PID_COMPONENT_NAME)
  finish_Progress(GLOBAL_PROGRESS_VAR)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, a name must be given to the component using NAME keyword.")
endif()

#check unique names
set(DECLARED FALSE)
is_Declared(${DECLARE_PID_COMPONENT_NAME} DECLARED)
if(DECLARED)
  finish_Progress(GLOBAL_PROGRESS_VAR)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : a component with the same name than ${DECLARE_PID_COMPONENT_NAME} is already defined.")
	return()
endif()
unset(DECLARED)

#check for directory argument
if(NOT DECLARE_PID_COMPONENT_DIRECTORY)
  finish_Progress(GLOBAL_PROGRESS_VAR)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, a source directory must be given using DIRECTORY keyword.")
endif()

if(DECLARE_PID_COMPONENT_C_STANDARD)
	set(c_language_standard ${DECLARE_PID_COMPONENT_C_STANDARD})
	if(	NOT c_language_standard EQUAL 90
	AND NOT c_language_standard EQUAL 99
	AND NOT c_language_standard EQUAL 11)
  finish_Progress(GLOBAL_PROGRESS_VAR)
		message(FATAL_ERROR "[PID] CRITICAL ERROR : bad C_STANDARD argument, the value used must be 90, 99 or 11.")
	endif()
endif()

if(DECLARE_PID_COMPONENT_CXX_STANDARD)
	set(cxx_language_standard ${DECLARE_PID_COMPONENT_CXX_STANDARD})
	if(	NOT cxx_language_standard EQUAL 98
	AND NOT cxx_language_standard EQUAL 11
	AND NOT cxx_language_standard EQUAL 14
	AND NOT cxx_language_standard EQUAL 17 )
  finish_Progress(GLOBAL_PROGRESS_VAR)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad CXX_STANDARD argument, the value used must be 98, 11, 14 or 17.")
	endif()
else() #default language standard is first standard
	set(cxx_language_standard 98)
endif()

set(nb_options 0)
if(DECLARE_PID_COMPONENT_STATIC_LIB)
	math(EXPR nb_options "${nb_options}+1")
	set(type "STATIC")
endif()
if(DECLARE_PID_COMPONENT_SHARED_LIB)
	math(EXPR nb_options "${nb_options}+1")
	set(type "SHARED")
endif()
if(DECLARE_PID_COMPONENT_MODULE_LIB)
	math(EXPR nb_options "${nb_options}+1")
	set(type "MODULE")
endif()
if(DECLARE_PID_COMPONENT_HEADER_LIB)
	math(EXPR nb_options "${nb_options}+1")
	set(type "HEADER")
endif()
if(DECLARE_PID_COMPONENT_APPLICATION)
	math(EXPR nb_options "${nb_options}+1")
	set(type "APP")
endif()
if(DECLARE_PID_COMPONENT_EXAMPLE_APPLICATION)
	math(EXPR nb_options "${nb_options}+1")
	set(type "EXAMPLE")
endif()
if(DECLARE_PID_COMPONENT_TEST_APPLICATION)
	math(EXPR nb_options "${nb_options}+1")
	set(type "TEST")
endif()
if(DECLARE_PID_COMPONENT_PYTHON_PACK)
	math(EXPR nb_options "${nb_options}+1")
	set(type "PYTHON")
endif()
if(NOT nb_options EQUAL 1)
  finish_Progress(GLOBAL_PROGRESS_VAR)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, only one type among (STATIC_LIB, SHARED_LIB, MODULE_LIB, HEADER_LIB, APPLICATION, EXAMPLE_APPLICATION or TEST_APPLICATION) must be given for the component.")
endif()
#checking that the required directories exist
check_Required_Directories_Exist(PROBLEM ${type} ${DECLARE_PID_COMPONENT_DIRECTORY})
if(PROBLEM)
  finish_Progress(GLOBAL_PROGRESS_VAR)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments when declaring ${DECLARE_PID_COMPONENT_NAME}, the source directory ${DECLARE_PID_COMPONENT_DIRECTORY} cannot be found in ${CMAKE_CURRENT_SOURCE_DIR} (${PROBLEM}).")
endif()

set(internal_defs "")
set(internal_inc_dirs "")
set(internal_link_flags "")
if(DECLARE_PID_COMPONENT_INTERNAL)
	if(DECLARE_PID_COMPONENT_INTERNAL STREQUAL "")
    finish_Progress(GLOBAL_PROGRESS_VAR)
		message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, INTERNAL keyword must be followed by by at least one DEFINITION OR INCLUDE_DIR OR LINK keyword and related arguments.")
	endif()
	set(internal_multiValueArgs DEFINITIONS INCLUDE_DIRS LINKS COMPILER_OPTIONS)
	cmake_parse_arguments(DECLARE_PID_COMPONENT_INTERNAL "" "" "${internal_multiValueArgs}" ${DECLARE_PID_COMPONENT_INTERNAL} )
	if(DECLARE_PID_COMPONENT_INTERNAL_DEFINITIONS)
		set(internal_defs ${DECLARE_PID_COMPONENT_INTERNAL_DEFINITIONS})
	endif()
	if(DECLARE_PID_COMPONENT_INTERNAL_INCLUDE_DIRS)
		set(internal_inc_dirs ${DECLARE_PID_COMPONENT_INTERNAL_INCLUDE_DIRS})
	endif()
	if(DECLARE_PID_COMPONENT_INTERNAL_COMPILER_OPTIONS)
		set(internal_compiler_options ${DECLARE_PID_COMPONENT_INTERNAL_COMPILER_OPTIONS})
	endif()
	if(DECLARE_PID_COMPONENT_INTERNAL_LINKS)
		if(type MATCHES HEADER OR type MATCHES STATIC)
      finish_Progress(GLOBAL_PROGRESS_VAR)
			message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, ${type} libraries cannot define internal linker flags.")
		endif()
		set(internal_link_flags ${DECLARE_PID_COMPONENT_INTERNAL_LINKS})
	endif()
endif()

set(exported_defs "")
if(DECLARE_PID_COMPONENT_EXPORTED)
	if(type MATCHES APP OR type MATCHES EXAMPLE OR type MATCHES TEST)
    finish_Progress(GLOBAL_PROGRESS_VAR)
		message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, applications cannot export anything (invalid use of the EXPORT keyword).")
	elseif(type MATCHES MODULE)
    finish_Progress(GLOBAL_PROGRESS_VAR)
		message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, module librairies cannot export anything (invalid use of the EXPORT keyword).")
	endif()
	if(DECLARE_PID_COMPONENT_EXPORTED STREQUAL "")
    finish_Progress(GLOBAL_PROGRESS_VAR)
		message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, EXPORTED keyword must be followed by at least one DEFINITIONS OR LINKS keyword and related arguments.")
	endif()
	set(exported_multiValueArgs DEFINITIONS LINKS COMPILER_OPTIONS)
	cmake_parse_arguments(DECLARE_PID_COMPONENT_EXPORTED "" "" "${exported_multiValueArgs}" ${DECLARE_PID_COMPONENT_EXPORTED} )
	if(DECLARE_PID_COMPONENT_EXPORTED_DEFINITIONS)
		set(exported_defs ${DECLARE_PID_COMPONENT_EXPORTED_DEFINITIONS})
	endif()
	if(DECLARE_PID_COMPONENT_EXPORTED_LINKS)
		set(exported_link_flags ${DECLARE_PID_COMPONENT_EXPORTED_LINKS})
	endif()
	if(DECLARE_PID_COMPONENT_EXPORTED_COMPILER_OPTIONS)
		set(exported_compiler_options ${DECLARE_PID_COMPONENT_EXPORTED_COMPILER_OPTIONS})
	endif()
endif()

set(runtime_resources "")
if(DECLARE_PID_COMPONENT_RUNTIME_RESOURCES)
	set(runtime_resources ${DECLARE_PID_COMPONENT_RUNTIME_RESOURCES})
endif()

if(type MATCHES "APP" OR type MATCHES "EXAMPLE" OR type MATCHES "TEST")
	declare_Application_Component(	${DECLARE_PID_COMPONENT_NAME}
					${DECLARE_PID_COMPONENT_DIRECTORY}
					${type}
					"${c_language_standard}"
					"${cxx_language_standard}"
					"${internal_inc_dirs}"
					"${internal_defs}"
					"${internal_compiler_options}"
					"${internal_link_flags}"
					"${runtime_resources}")
elseif(type MATCHES "PYTHON")#declare a python package
	declare_Python_Component(${DECLARE_PID_COMPONENT_NAME} ${DECLARE_PID_COMPONENT_DIRECTORY})
else() #it is a library
	declare_Library_Component(	${DECLARE_PID_COMPONENT_NAME}
					${DECLARE_PID_COMPONENT_DIRECTORY}
					${type}
					"${c_language_standard}"
					"${cxx_language_standard}"
					"${internal_inc_dirs}"
					"${internal_defs}"
					"${internal_compiler_options}"
					"${exported_defs}"
					"${exported_compiler_options}"
					"${internal_link_flags}"
					"${exported_link_flags}"
					"${runtime_resources}")
endif()
if(NOT "${DECLARE_PID_COMPONENT_DESCRIPTION}" STREQUAL "")
	init_Component_Description(${DECLARE_PID_COMPONENT_NAME} "${DECLARE_PID_COMPONENT_DESCRIPTION}" "${DECLARE_PID_COMPONENT_USAGE}")
endif()
endmacro(declare_PID_Component)

#.rst:
# .. ifmode:: user
#
#  .. |declare_PID_Package_Dependency| replace:: ``declare_PID_Package_Dependency``
#  .. _declare_PID_Package_Dependency:
#
#  declare_PID_Package_Dependency
#  ------------------------------
#
#  .. command:: declare_PID_Package_Dependency(PACKAGE ... EXTERNAL|NATIVE [OPTIONS])
#
#   Declare a dependency between the current package and another package.
#
#   .. rubric:: Required parameters
#
#   :PACKAGE <name>: Name of the package the current package depends upon.
#   :EXTERNAL: Use this keyword when ``name`` is an external package.
#   :NATIVE: Use this keyword when ``name`` is a native PID package.
#
#   .. rubric:: Optional parameters
#
#   :OPTIONAL: Make the dependency optional.
#   :(EXACT) VERSION <version>: Specifies the requested package version. ``EXACT`` means this exact version is required (patch revision may be ignored for native packages), otherwise this is treated as a minimum version requirement. Multiple exact versions may be specified. In that case, the first one is the default version.
#   :COMPONENTS <components>: Specify which components of the given package are required.
#
#   .. admonition:: Constraints
#      :class: warning
#
#      - This function must be called in the root ``CMakeLists.txt`` file of the package, after |declare_PID_Package|_ but before |build_PID_Package|_.
#
#   .. admonition:: Effects
#     :class: important
#
#     This function will register the target package as a dependency of the current package. The information will be added to the :ref:`package use file`.
#
#   .. rubric:: Example
#
#   Simple example:
#
#   .. code-block:: cmake
#
#      declare_PID_Package_Dependency (
#                PACKAGE another-package
#                NATIVE VERSION 1.0
#                COMPONENTS lib-other-sh
#      )
#
#   Specifying multiple acceptable versions:
#
#   .. code-block:: cmake
#
#      declare_PID_Package_Dependency (PACKAGE boost EXTERNAL
#                                      EXACT VERSION 1.55.0
#                                      EXACT VERSION 1.63.0
#                                      EXACT VERSION 1.64.0
#      )
#
macro(declare_PID_Package_Dependency)
set(options EXTERNAL NATIVE OPTIONAL)
set(oneValueArgs PACKAGE)
cmake_parse_arguments(DECLARE_PID_DEPENDENCY "${options}" "${oneValueArgs}" "" ${ARGN} )
if(NOT DECLARE_PID_DEPENDENCY_PACKAGE)
  finish_Progress(GLOBAL_PROGRESS_VAR)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, a name must be given to the required package using PACKAGE keywork.")
endif()
if(DECLARE_PID_DEPENDENCY_PACKAGE STREQUAL PROJECT_NAME)
  finish_Progress(GLOBAL_PROGRESS_VAR)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, package ${DECLARE_PID_DEPENDENCY_PACKAGE} cannot require itself !")
endif()
if(DECLARE_PID_DEPENDENCY_EXTERNAL AND DECLARE_PID_DEPENDENCY_NATIVE)
  finish_Progress(GLOBAL_PROGRESS_VAR)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments when declaring dependency to package ${DECLARE_PID_DEPENDENCY_PACKAGE}, the type of the required package must be EXTERNAL or NATIVE, not both.")
elseif(NOT DECLARE_PID_DEPENDENCY_EXTERNAL AND NOT DECLARE_PID_DEPENDENCY_NATIVE)
  finish_Progress(GLOBAL_PROGRESS_VAR)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments when declaring dependency to package ${DECLARE_PID_DEPENDENCY_PACKAGE}, the type of the required package must be EXTERNAL or NATIVE (use one of these KEYWORDS).")
else() #first checks OK now parsing version related arguments
	set(list_of_versions)
	set(exact_versions)
	if(DECLARE_PID_DEPENDENCY_UNPARSED_ARGUMENTS)
		set(TO_PARSE "${DECLARE_PID_DEPENDENCY_UNPARSED_ARGUMENTS}")
		set(RES_VERSION TRUE)
		while(TO_PARSE AND RES_VERSION)
			parse_Package_Dependency_Version_Arguments("${TO_PARSE}" RES_VERSION RES_EXACT TO_PARSE)
			if(RES_VERSION)
				list(APPEND list_of_versions ${RES_VERSION})
				if(RES_EXACT)
					list(APPEND exact_versions ${RES_VERSION})
				endif()
			elseif(RES_EXACT)
        finish_Progress(GLOBAL_PROGRESS_VAR)
				message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments when declaring dependency to package ${DECLARE_PID_DEPENDENCY_PACKAGE}, you must use the EXACT keyword together with the VERSION keyword.")
			endif()
		endwhile()
	endif()
	set(list_of_components)
	if(TO_PARSE) #there are still components to parse
		set(oneValueArgs)
		set(options)
		set(multiValueArgs COMPONENTS)
		cmake_parse_arguments(DECLARE_PID_DEPENDENCY_MORE "${options}" "${oneValueArgs}" "${multiValueArgs}" ${TO_PARSE})
		if(DECLARE_PID_DEPENDENCY_MORE_COMPONENTS)
			list(LENGTH DECLARE_PID_DEPENDENCY_MORE_COMPONENTS SIZE)
			if(SIZE LESS 1)
        finish_Progress(GLOBAL_PROGRESS_VAR)
				message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments when declaring dependency to package ${DECLARE_PID_DEPENDENCY_PACKAGE}, at least one component dependency must be defined when using the COMPONENTS keyword.")
			endif()
			set(list_of_components ${DECLARE_PID_DEPENDENCY_MORE_COMPONENTS})
		else()
      finish_Progress(GLOBAL_PROGRESS_VAR)
			message(FATAL_ERROR "[PID] WARNING : when declaring dependency to package ${DECLARE_PID_DEPENDENCY_PACKAGE}, unknown arguments used ${DECLARE_PID_DEPENDENCY_MORE_UNPARSED_ARGUMENTS}.")
		endif()
	endif()

	if(DECLARE_PID_DEPENDENCY_EXTERNAL)#external package
		declare_External_Package_Dependency(${DECLARE_PID_DEPENDENCY_PACKAGE} "${DECLARE_PID_DEPENDENCY_OPTIONAL}" "${list_of_versions}" "${exact_versions}" "${list_of_components}")
	else()#native package
		declare_Package_Dependency(${DECLARE_PID_DEPENDENCY_PACKAGE} "${DECLARE_PID_DEPENDENCY_OPTIONAL}" "${list_of_versions}" "${exact_versions}" "${list_of_components}")
	endif()
endif()
endmacro(declare_PID_Package_Dependency)

### Get information about a dependency so that it can help the user configure the build
function(used_Package_Dependency)
set(oneValueArgs USED VERSION PACKAGE)
cmake_parse_arguments(USED_PACKAGE_DEPENDENCY "" "${oneValueArgs}" "" ${ARGN} )

if(NOT USED_PACKAGE_DEPENDENCY_PACKAGE)
  finish_Progress(GLOBAL_PROGRESS_VAR)
	message(FATAL_ERROR "[PID] CRITICAL ERROR: when calling used_Package_Dependency you specified no dependency name using PACKAGE keyword")
	return()
endif()
set(dep_package ${USED_PACKAGE_DEPENDENCY_PACKAGE})
set(package_found TRUE)
list(FIND ${PROJECT_NAME}_DEPENDENCIES${USE_MODE_SUFFIX} ${dep_package} INDEX)
if(INDEX EQUAL -1)
	list(FIND ${PROJECT_NAME}_EXTERNAL_DEPENDENCIES${USE_MODE_SUFFIX} ${dep_package} INDEX)
	if(INDEX EQUAL -1)
		set(package_found FALSE)
	else()
		set(IS_EXTERNAL TRUE)
	endif()
endif()

if(USED_PACKAGE_DEPENDENCY_USED)
	if(package_found)
		set(${USED_PACKAGE_DEPENDENCY_USED} TRUE PARENT_SCOPE)
	else()
		set(${USED_PACKAGE_DEPENDENCY_USED} FALSE PARENT_SCOPE)
	endif()
endif()

if(USED_PACKAGE_DEPENDENCY_VERSION)
	if(package_found)
		#from here it has been found so it may have a version
		if(IS_EXTERNAL)#it is an external package
			set(${USED_PACKAGE_DEPENDENCY_VERSION} ${${PROJECT_NAME}_EXTERNAL_DEPENDENCY_${dep_package}_VERSION${USE_MODE_SUFFIX}} PARENT_SCOPE)#by definition no version used
		else()#it is a native package
			set(${USED_PACKAGE_DEPENDENCY_VERSION} ${${PROJECT_NAME}_DEPENDENCY_${dep_package}_VERSION${USE_MODE_SUFFIX}} PARENT_SCOPE)#by definition no version used
		endif()
	else()
		set(${USED_PACKAGE_DEPENDENCY_VERSION} FALSE PARENT_SCOPE)
	endif()
endif()

endfunction(used_Package_Dependency dep_package)


#.rst:
# .. ifmode:: user
#
#  .. |declare_PID_Component_Dependency| replace:: ``declare_PID_Component_Dependency``
#  .. _declare_PID_Component_Dependency:
#
#  declare_PID_Component_Dependency
#  --------------------------------
#
#  .. command:: declare_PID_Component_Dependency(COMPONENT ... [OPTIONS])
#
#   Declare a dependency for a component of the current package. The arguments differ whether the component is from a native PID package or an external/system dependency. Only the ``COMPONENT`` argument is always required.
#
#   .. rubric:: Common parameters
#
#   :COMPONENT <name>: Name of the component.
#   :EXPORT: If this flag is present, the dependency is exported.
#   :INTERNAL_DEFINITIONS <defs>: Definitions used internally in ``name`` when the dependency is used.
#   :IMPORTED_DEFINITIONS <defs>: Definitions contained in the interface of the dependency that are set when the component uses this dependency.
#   :EXPORTED_DEFINITIONS <defs>: Definitions that are exported by ``name`` when that dependency is used.
#
#   .. rubric:: Native component
#
#   Only the ``NATIVE`` argument is required in this case. ``PACKAGE`` is required if the depended-upon component is not internal.
#
#   :NATIVE <component>: ``component`` is the component that ``name`` depends upon.
#   :PACKAGE <package>: ``component`` is part of the ``package`` native package. If ``PACKAGE`` is not used, it means ``component`` is part of the current package.
#
#   .. rubric:: External or system dependency
#
#   :EXTERNAL <package>: Name of the external package that is depended upon.
#   :INCLUDE_DIRS <dirs>: Specify include directories for this dependency. For external packages, these paths must be relative to the package root dir (using ``<package>``). This should not be used for system packages as include directories should be in the default system folders.
#   :RUNTIME_RESOURCES <paths>: Specify where to find runtime resources. For external package, these paths must be relative to the package root dir (using ``<package>``). This should not be used for system packages as shared resources should be in standard locations.
#   :COMPILER_OPTIONS: Compiler options that are not definitions.
#   :LINKS STATIC|SHARED <links>:
#     - ``STATIC <links>``: static libraries. For system libraries, system referencing must be used (e.g. -lm for libm.a). For external packages, complete path (relative to the package root dir) must be used.
#     - ``SHARED <links>``: shared libraries. For system libraries, system referencing must be used (e.g. -lm for libm.a). For external packages, complete path (relative to the package root dir) must be used.
#
#   .. admonition:: Constraints
#      :class: warning
#
#      - Must be called after the component has been declared using |declare_PID_Component|_.
#
#   .. admonition:: Effects
#     :class: important
#
#     This function is used to defined a dependency between a component in the current package and another component. This will configure the build process accordingly.
#
#   .. rubric:: Example
#
#   .. code-block:: cmake
#
#      declare_PID_Component_Dependency(COMPONENT my-static-lib
#                                       EXTERNAL boost INCLUDE_DIRS <boost>/include
#      )
#
#      declare_PID_Component_Dependency(COMPONENT my-static-lib
#                                       EXPORT DEPEND my-given-lib-bis
#      )

#
macro(declare_PID_Component_Dependency)
set(options EXPORT)
set(oneValueArgs COMPONENT DEPEND NATIVE PACKAGE EXTERNAL C_STANDARD CXX_STANDARD)
set(multiValueArgs INCLUDE_DIRS LINKS COMPILER_OPTIONS INTERNAL_DEFINITIONS IMPORTED_DEFINITIONS EXPORTED_DEFINITIONS RUNTIME_RESOURCES)
cmake_parse_arguments(DECLARE_PID_COMPONENT_DEPENDENCY "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )

if(NOT DECLARE_PID_COMPONENT_DEPENDENCY_COMPONENT)
  finish_Progress(GLOBAL_PROGRESS_VAR)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments when declaring dependency for component ${DECLARE_PID_COMPONENT_DEPENDENCY_COMPONENT}, a name must be given to the component that declare the dependency using COMPONENT keyword.")
endif()
if(DECLARE_PID_COMPONENT_DEPENDENCY_UNPARSED_ARGUMENTS)
  finish_Progress(GLOBAL_PROGRESS_VAR)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments when declaring dependency for component ${DECLARE_PID_COMPONENT_DEPENDENCY_COMPONENT}, unknown arguments ${DECLARE_PID_COMPONENT_DEPENDENCY_UNPARSED_ARGUMENTS}.")
endif()
set(export FALSE)
if(DECLARE_PID_COMPONENT_DEPENDENCY_EXPORT)
	set(export TRUE)
endif()

set(comp_defs "")
if(DECLARE_PID_COMPONENT_DEPENDENCY_INTERNAL_DEFINITIONS)
	set(comp_defs ${DECLARE_PID_COMPONENT_DEPENDENCY_INTERNAL_DEFINITIONS})
endif()

set(dep_defs "")
if(DECLARE_PID_COMPONENT_DEPENDENCY_IMPORTED_DEFINITIONS)
	set(dep_defs ${DECLARE_PID_COMPONENT_DEPENDENCY_IMPORTED_DEFINITIONS})
endif()

set(comp_exp_defs "")
if(DECLARE_PID_COMPONENT_DEPENDENCY_EXPORTED_DEFINITIONS)
	set(comp_exp_defs ${DECLARE_PID_COMPONENT_DEPENDENCY_EXPORTED_DEFINITIONS})
endif()

set(static_links "")
set(shared_links "")
if(DECLARE_PID_COMPONENT_DEPENDENCY_LINKS)
	set(multiValueArgs STATIC SHARED)
	cmake_parse_arguments(DECLARE_PID_COMPONENT_DEPENDENCY_LINKS "" "" "${multiValueArgs}" ${DECLARE_PID_COMPONENT_DEPENDENCY_LINKS} )
	if(DECLARE_PID_COMPONENT_DEPENDENCY_LINKS_UNPARSED_ARGUMENTS)
    finish_Progress(GLOBAL_PROGRESS_VAR)
		message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments when declaring dependency for component ${DECLARE_PID_COMPONENT_DEPENDENCY_COMPONENT}, the LINKS option argument must be followed only by static and/or shared links.")
	endif()

	if(DECLARE_PID_COMPONENT_DEPENDENCY_LINKS_STATIC)
		set(static_links ${DECLARE_PID_COMPONENT_DEPENDENCY_LINKS_STATIC})
	endif()

	if(DECLARE_PID_COMPONENT_DEPENDENCY_LINKS_SHARED)
		set(shared_links ${DECLARE_PID_COMPONENT_DEPENDENCY_LINKS_SHARED})
	endif()
endif()

if(DECLARE_PID_COMPONENT_DEPENDENCY_COMPILER_OPTIONS)
	set(compiler_options ${DECLARE_PID_COMPONENT_DEPENDENCY_COMPILER_OPTIONS})
endif()

if(DECLARE_PID_COMPONENT_DEPENDENCY_DEPEND OR DECLARE_PID_COMPONENT_DEPENDENCY_NATIVE)
	if(DECLARE_PID_COMPONENT_DEPENDENCY_EXTERNAL)
    finish_Progress(GLOBAL_PROGRESS_VAR)
		message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments when declaring dependency for component ${DECLARE_PID_COMPONENT_DEPENDENCY_COMPONENT}, keywords EXTERNAL (requiring an external package) and NATIVE (or DEPEND) (requiring a PID component) cannot be used simultaneously.")
	endif()
	if(DECLARE_PID_COMPONENT_DEPENDENCY_DEPEND)
		set(target_component ${DECLARE_PID_COMPONENT_DEPENDENCY_DEPEND})
	else()
		set(target_component ${DECLARE_PID_COMPONENT_DEPENDENCY_NATIVE})
	endif()

  if(DECLARE_PID_COMPONENT_DEPENDENCY_PACKAGE
		AND NOT DECLARE_PID_COMPONENT_DEPENDENCY_PACKAGE STREQUAL "${PROJECT_NAME}")
		#package dependency target package is not current project
		is_Package_Dependency(IS_DEPENDENCY "${DECLARE_PID_COMPONENT_DEPENDENCY_PACKAGE}")
		if(NOT IS_DEPENDENCY)#the target package has NOT been defined as a dependency
			set(IS_CONFIGURED TRUE)
			if(${PROJECT_NAME}_${DECLARE_PID_COMPONENT_DEPENDENCY_COMPONENT}_TYPE STREQUAL "TEST" AND NOT BUILD_AND_RUN_TESTS)
				set(IS_CONFIGURED FALSE)
			elseif(${PROJECT_NAME}_${DECLARE_PID_COMPONENT_DEPENDENCY_COMPONENT}_TYPE STREQUAL "EXAMPLE" AND (NOT BUILD_EXAMPLES OR NOT BUILD_EXAMPLE_${DECLARE_PID_COMPONENT_DEPENDENCY_COMPONENT}))
				set(IS_CONFIGURED FALSE)
			endif()
			if(IS_CONFIGURED) #only notify the error if the package DOES configure the component
				message(WARNING "[PID] WARNING : bad arguments when declaring dependency for component ${DECLARE_PID_COMPONENT_DEPENDENCY_COMPONENT}, the component depends on an unknown package ${DECLARE_PID_COMPONENT_DEPENDENCY_PACKAGE} !")
			endif()
		endif()
		declare_Package_Component_Dependency(
					${DECLARE_PID_COMPONENT_DEPENDENCY_COMPONENT}
					${DECLARE_PID_COMPONENT_DEPENDENCY_PACKAGE}
					${target_component}
					${export}
					"${comp_defs}"
					"${comp_exp_defs}"
					"${dep_defs}"
					)
	else()#internal dependency
		if(target_component STREQUAL "${DECLARE_PID_COMPONENT_DEPENDENCY_COMPONENT}")
      finish_Progress(GLOBAL_PROGRESS_VAR)
			message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments when declaring dependency for component ${DECLARE_PID_COMPONENT_DEPENDENCY_COMPONENT}, the component cannot depend on itself !")
		endif()

		declare_Internal_Component_Dependency(
					${DECLARE_PID_COMPONENT_DEPENDENCY_COMPONENT}
					${target_component}
					${export}
					"${comp_defs}"
					"${comp_exp_defs}"
					"${dep_defs}"
					)
	endif()

elseif(DECLARE_PID_COMPONENT_DEPENDENCY_EXTERNAL)#external dependency

	if(DECLARE_PID_COMPONENT_DEPENDENCY_PACKAGE) #an external package name is given => external package is supposed to be provided with a description file
		if(DECLARE_PID_COMPONENT_DEPENDENCY_PACKAGE STREQUAL "${PROJECT_NAME}")
      finish_Progress(GLOBAL_PROGRESS_VAR)
			message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments when declaring dependency for component ${DECLARE_PID_COMPONENT_DEPENDENCY_COMPONENT}, the target external package canoot be current project !")
		endif()
		#check for package dependency using the PACKAGE name
		is_Package_Dependency(IS_DEPENDENCY "${DECLARE_PID_COMPONENT_DEPENDENCY_PACKAGE}")
		if(NOT IS_DEPENDENCY)
      set(IS_CONFIGURED TRUE)
			if(${PROJECT_NAME}_${DECLARE_PID_COMPONENT_DEPENDENCY_COMPONENT}_TYPE STREQUAL "TEST" AND NOT BUILD_AND_RUN_TESTS)
				set(IS_CONFIGURED FALSE)
			elseif(${PROJECT_NAME}_${DECLARE_PID_COMPONENT_DEPENDENCY_COMPONENT}_TYPE STREQUAL "EXAMPLE" AND (NOT BUILD_EXAMPLES OR NOT BUILD_EXAMPLE_${DECLARE_PID_COMPONENT_DEPENDENCY_COMPONENT}))
				set(IS_CONFIGURED FALSE)
			endif()
			if(IS_CONFIGURED) #only notify the error if the package DOES configure the component
        message(WARNING "[PID] WARNING : bad arguments when declaring dependency for component ${DECLARE_PID_COMPONENT_DEPENDENCY_COMPONENT}, the component depends on an unknown external package ${DECLARE_PID_COMPONENT_DEPENDENCY_PACKAGE} !")
			endif()
		endif()

		declare_External_Component_Dependency(
					${DECLARE_PID_COMPONENT_DEPENDENCY_COMPONENT}
					${DECLARE_PID_COMPONENT_DEPENDENCY_PACKAGE}
					${DECLARE_PID_COMPONENT_DEPENDENCY_EXTERNAL}
					${export}
					"${comp_defs}"
					"${comp_exp_defs}"
					"${dep_defs}")

	else() #an external package name is given but without using an external package description
		is_Package_Dependency(IS_DEPENDENCY "${DECLARE_PID_COMPONENT_DEPENDENCY_EXTERNAL}")
		if(NOT IS_DEPENDENCY)
      set(IS_CONFIGURED TRUE)
			if(${PROJECT_NAME}_${DECLARE_PID_COMPONENT_DEPENDENCY_COMPONENT}_TYPE STREQUAL "TEST" AND NOT BUILD_AND_RUN_TESTS)
				set(IS_CONFIGURED FALSE)
			elseif(${PROJECT_NAME}_${DECLARE_PID_COMPONENT_DEPENDENCY_COMPONENT}_TYPE STREQUAL "EXAMPLE" AND (NOT BUILD_EXAMPLES OR NOT BUILD_EXAMPLE_${DECLARE_PID_COMPONENT_DEPENDENCY_COMPONENT}))
				set(IS_CONFIGURED FALSE)
			endif()
			if(IS_CONFIGURED) #only notify the error if the package DOES configure the component
        message(WARNING "[PID] WARNING : bad arguments when declaring dependency for component ${DECLARE_PID_COMPONENT_DEPENDENCY_COMPONENT}, the component depends on an unknown external package ${DECLARE_PID_COMPONENT_DEPENDENCY_EXTERNAL} !")
			endif()
		endif()
		declare_External_Package_Component_Dependency(
					${DECLARE_PID_COMPONENT_DEPENDENCY_COMPONENT}
					${DECLARE_PID_COMPONENT_DEPENDENCY_EXTERNAL}
					${export}
					"${DECLARE_PID_COMPONENT_DEPENDENCY_INCLUDE_DIRS}"
					"${comp_defs}"
					"${comp_exp_defs}"
					"${dep_defs}"
					"${compiler_options}"
					"${static_links}"
					"${shared_links}"
					"${DECLARE_PID_COMPONENT_DEPENDENCY_C_STANDARD}"
					"${DECLARE_PID_COMPONENT_DEPENDENCY_CXX_STANDARD}"
					"${DECLARE_PID_COMPONENT_DEPENDENCY_RUNTIME_RESOURCES}")
	endif()
else()#system dependency

	declare_System_Component_Dependency(
			${DECLARE_PID_COMPONENT_DEPENDENCY_COMPONENT}
			${export}
			"${DECLARE_PID_COMPONENT_DEPENDENCY_INCLUDE_DIRS}"
			"${comp_defs}"
			"${comp_exp_defs}"
			"${dep_defs}"
			"${compiler_options}"
			"${static_links}"
			"${shared_links}"
			"${DECLARE_PID_COMPONENT_DEPENDENCY_C_STANDARD}"
			"${DECLARE_PID_COMPONENT_DEPENDENCY_CXX_STANDARD}"
			"${DECLARE_PID_COMPONENT_DEPENDENCY_RUNTIME_RESOURCES}")
endif()
endmacro(declare_PID_Component_Dependency)


function(wrap_CTest_Call name command args)
	if(NOT CMAKE_VERSION VERSION_LESS 3.4)#cannot do if on tests before this version
		add_test(NAME ${name} COMMAND ${command} ${args})
	else()
		add_test(${name} ${command} ${args})
	endif()
endfunction(wrap_CTest_Call)

#.rst:
# .. ifmode:: user
#
#  .. |run_PID_Test| replace:: ``run_PID_Test``
#  .. _run_PID_Test:
#
#  run_PID_Test
#  -----------------------
#
#  .. command:: run_PID_Test(NAME ... [OPTIONS])
#
#   Run a test using an application.
#
#   The application can be:
#   - an executable (e.g. valgrind)
#   - a PID component (standard, example or test application)
#   - a Python script
#
#   .. rubric:: Common parameters
#
#   :NAME <name>: Unique identifier for the test
#   :ARGUMENTS <args>: (optional) Arguments passed to the executable, component or script
#
#   .. rubric:: Executable parameters
#
#   :EXE <name>: Name of the executable to run.
#
#   .. rubric:: Component parameters
#
#   :COMPONENT <name>: Name of the component to run.
#   :PACKAGE <name>: Package to which the component belongs (defaults to the current package).
#
#   .. rubric:: Python script
#
#   :PYTHON: Flag the test as a Python test.
#
#   In that case, the first argument of ``ARGUMENTS`` is interpreted as a Python script, located in the ``test`` or ``share/script`` folder of the package.
#
#   .. admonition:: Constraints
#      :class: warning
#
#      - The component variant of this function must be called after the component has been declared.
#
#   .. admonition:: Effects
#     :class: important
#
#     Adds a test to the ``make test`` target. When the test is run it will generate a ``PASSED`` or ``ERROR`` message according to the result.
#
#   .. rubric:: Example
#
#   .. code-block:: cmake
#
#      run_PID_Test (NAME correctness_of_my-shared-lib_step1 COMPONENT my-test ARGUMENTS "first" "124" "12")
#      run_PID_Test (NAME correctness_of_my-shared-lib_step2 COMPONENT my-test ARGUMENTS "second" "12" "46")
#      run_PID_Test (NAME correctness_of_my-shared-lib_step3 COMPONENT my-test ARGUMENTS "first" "0" "87")
#
function(run_PID_Test)
set(options PRIVILEGED PYTHON)
set(oneValueArgs NAME EXE COMPONENT PACKAGE)
set(multiValueArgs ARGUMENTS)
cmake_parse_arguments(RUN_PID_TEST "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )
if(RUN_PID_TEST_UNPARSED_ARGUMENTS)
  finish_Progress(GLOBAL_PROGRESS_VAR)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments for the test ${RUN_PID_TEST_NAME}, unknown arguments ${DECLARE_PID_COMPONENT_DEPENDENCY_UNPARSED_ARGUMENTS}.")
endif()
if(NOT RUN_PID_TEST_NAME)
  finish_Progress(GLOBAL_PROGRESS_VAR)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments for the test ${RUN_PID_TEST_NAME}, a name must be given to the test (using NAME <name> syntax) !")
else()
	if(NOT CMAKE_VERSION VERSION_LESS 3.4)#cannot do call if(TEST) before this version, the default behavior (without using NAME and COMMAND will overwrite the rprevious test with same name)
		if(TEST ${RUN_PID_TEST_NAME})
			message("[PID] WARNING : bad arguments for the test ${RUN_PID_TEST_NAME}, this test unit is already defined. Skipping new definition !")
			return()
		endif()
	endif()
endif()

if(NOT RUN_PID_TEST_EXE AND NOT RUN_PID_TEST_COMPONENT AND NOT RUN_PID_TEST_PYTHON)
  finish_Progress(GLOBAL_PROGRESS_VAR)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments for the test ${RUN_PID_TEST_NAME}, an executable must be defined. Using EXE you can use an executable present on your system. By using COMPONENT you can specify a component built by the project. In this later case you must specify a PID executable component. If the PACKAGE keyword is used then this component will be found in another package than the current one. Finaly you can otherwise use the PYTHON keyword and pass the target python script file lying in your test folder as argument (path is relative to the test folder).")
endif()

if((RUN_PID_TEST_EXE AND RUN_PID_TEST_COMPONENT)
		OR (RUN_PID_TEST_EXE AND RUN_PID_TEST_PYTHON)
		OR (RUN_PID_TEST_COMPONENT AND RUN_PID_TEST_PYTHON))
    finish_Progress(GLOBAL_PROGRESS_VAR)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments for the test ${RUN_PID_TEST_NAME}, you must use either a system executable (using EXE keyword) OR a PID application component (using COMPONENT keyword) OR the python executable (using PYTHON keyword).")
endif()

if(RUN_PID_TEST_PYTHON)
	if(NOT CURRENT_PYTHON)
		return()
	endif()
	if(NOT RUN_PID_TEST_ARGUMENTS)
    finish_Progress(GLOBAL_PROGRESS_VAR)
		message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments for the test ${RUN_PID_TEST_NAME}, you must define a path to a target python file using ARGUMENTS keyword.")
	endif()
	list(LENGTH  RUN_PID_TEST_ARGUMENTS SIZE)
	if(NOT SIZE EQUAL 1)
		message("[PID] WARNING : bad arguments for the test ${RUN_PID_TEST_NAME}, you must define a path to a UNIQUE target python file using ARGUMENTS keyword. First file is selected, others will be ignored.")
	endif()
	list(GET RUN_PID_TEST_ARGUMENTS 0 target_py_file)
	if (NOT target_py_file MATCHES "^.*\\.py$")
    finish_Progress(GLOBAL_PROGRESS_VAR)
		message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments for the test ${RUN_PID_TEST_NAME}, ${target_py_file} is not a python file.")
	endif()
	if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${target_py_file})#first check that the file exists in test folder
		set(PATH_TO_PYTHON_FILE ${CMAKE_CURRENT_SOURCE_DIR}/${target_py_file})
	elseif(EXISTS ${CMAKE_SOURCE_DIR}/share/script/${target_py_file})
		set(PATH_TO_PYTHON_FILE ${CMAKE_SOURCE_DIR}/share/script/${target_py_file})
	else()
    finish_Progress(GLOBAL_PROGRESS_VAR)
		message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments for the test ${RUN_PID_TEST_NAME}, ${target_py_file} cannot be found in either test or script folders.")
	endif()
endif()

if(NOT PID_CROSSCOMPILATION)
	set(PROJECT_RUN_TESTS TRUE CACHE INTERNAL "")
endif()

if(RUN_PID_TEST_PRIVILEGED)
	if(NOT RUN_TESTS_WITH_PRIVILEGES)
		set(RUN_TESTS_WITH_PRIVILEGES TRUE CACHE INTERNAL "")
	endif()
endif()

if(RUN_PID_TEST_EXE)
	wrap_CTest_Call(${RUN_PID_TEST_NAME} "${RUN_PID_TEST_EXE}" "${RUN_PID_TEST_ARGUMENTS}")
elseif(RUN_PID_TEST_COMPONENT)# run test by executing a PID component
	if(RUN_PID_TEST_PACKAGE)#component coming from another PID package
		set(target_of_test ${RUN_PID_TEST_PACKAGE}-${RUN_PID_TEST_COMPONENT}${INSTALL_NAME_SUFFIX})
		wrap_CTest_Call(${RUN_PID_TEST_NAME} "${target_of_test}" "${RUN_PID_TEST_ARGUMENTS}")
	else()#internal component
		wrap_CTest_Call(${RUN_PID_TEST_NAME} "${RUN_PID_TEST_COMPONENT}${INSTALL_NAME_SUFFIX}" "${RUN_PID_TEST_ARGUMENTS}")
	endif()
elseif(RUN_PID_TEST_PYTHON)#run PID test with python
	wrap_CTest_Call(${RUN_PID_TEST_NAME} "${CURRENT_PYTHON_EXECUTABLE}" "${PATH_TO_PYTHON_FILE}")
	#setting the python path automatically for this test
	set_tests_properties(${RUN_PID_TEST_NAME} PROPERTIES ENVIRONMENT "PYTHONPATH=${WORKSPACE_DIR}/install/python${CURRENT_PYTHON}")
endif()
endfunction(run_PID_Test)


#############################################################################################
###########################Other functions of the API #######################################
#############################################################################################

#.rst:
# .. ifmode:: user-advanced
#
#  .. |external_PID_Package_Path| replace:: ``external_PID_Package_Path``
#  .. _external_PID_Package_Path:
#
#  external_PID_Package_Path
#  ^^^^^^^^^^^^^^^^^^^^^^^^^
#
#  .. command:: external_PID_Package_Path(NAME ... PATH ...)
#
#   Get the path to a target external package that is supposed to exist in the local workspace.
#
#   .. rubric:: Required parameters
#
#   :NAME <name>: Name of the target external package.
#   :PATH <var>: ``<var>`` will contain the package root folder.
#
#   .. admonition:: Constraints
#      :class: warning
#
#      - This function must be called after a dependency to ``name`` has been declared using |declare_PID_Package_Dependency|_.
#
#   .. admonition:: Effects
#     :class: important
#
#     No effect on the project.
#
#   .. rubric:: Example
#
#   .. code-block:: cmake
#
#      external_PID_Package_Path(NAME boost PATH BOOST_ROOT_PATH)
#      message(INFO "Boost root path is: ${BOOST_ROOT_PATH}")
#
function(external_PID_Package_Path)
set(oneValueArgs NAME PATH)
cmake_parse_arguments(EXT_PACKAGE_PATH "" "${oneValueArgs}" "" ${ARGN} )
if(NOT EXT_PACKAGE_PATH_NAME OR NOT EXT_PACKAGE_PATH_PATH)
  finish_Progress(GLOBAL_PROGRESS_VAR)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, a name of an external package must be provided with name and a variable containing the resulting path must be set with PATH keyword.")
endif()
is_External_Package_Defined("${EXT_PACKAGE_PATH_NAME}" PATHTO)
if(PATHTO STREQUAL NOTFOUND)
	set(${EXT_PACKAGE_PATH_PATH} NOTFOUND PARENT_SCOPE)
else()
	set(${EXT_PACKAGE_PATH_PATH} ${PATHTO} PARENT_SCOPE)
endif()
endfunction(external_PID_Package_Path)


#.rst:
# .. ifmode:: user-advanced
#
#  .. |create_PID_Install_Symlink| replace:: ``create_PID_Install_Symlink``
#  .. _create_PID_Install_Symlink:
#
#  create_PID_Install_Symlink
#  ^^^^^^^^^^^^^^^^^^^^^^^^^^
#
#  .. command:: create_PID_Install_Symlink(NAME ... PATH ... TARGET ...)
#
#   Creates a symlink somewhere in the install folder of the package.
#
#   .. rubric:: Required parameters
#
#   :NAME <name>: Name of the created symlink.
#   :PATH <var>: Path (relative to the package install folder) where the symlink will be put.
#   :TARGET <path>: The absolute path targetted by the symlink.
#
#   .. admonition:: Constraints
#      :class: warning
#
#      - The target path must exist.
#
#   .. admonition:: Effects
#     :class: important
#
#     This creates a package specific symlink. It is mostly used to manage runtime dependencies for specific external or system resources.
#
#   .. rubric:: Example
#
#   .. code-block:: cmake
#
#      external_PID_Package_Path (NAME boost PATH BOOST_ROOT_PATH)
#      create_PID_Install_Symlink(NAME libboost_system.so PATH bin TARGET ${BOOST_ROOT_PATH}/lib/libboost_system.so)
#
macro(create_PID_Install_Symlink)
set(oneValueArgs NAME PATH TARGET)
cmake_parse_arguments(CREATE_INSTALL_SYMLINK "" "${oneValueArgs}" "" ${ARGN} )
if(NOT CREATE_INSTALL_SYMLINK_NAME OR NOT CREATE_INSTALL_SYMLINK_PATH OR NOT CREATE_INSTALL_SYMLINK_TARGET)
  finish_Progress(GLOBAL_PROGRESS_VAR)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, a name for the new symlink created must be provided with NAME keyword, the path relative to its install location must be provided with PATH keyword and the target of the symlink must be provided with TARGET keyword.")
endif()
set(FULL_INSTALL_PATH ${CMAKE_INSTALL_PREFIX}/${${PROJECT_NAME}_DEPLOY_PATH}/${CREATE_INSTALL_SYMLINK_PATH})
set( link   ${CREATE_INSTALL_SYMLINK_NAME})
set( target ${CREATE_INSTALL_SYMLINK_TARGET})

add_custom_target(install_symlink_${link} ALL
        COMMAND ${CMAKE_COMMAND} -E remove -f ${FULL_INSTALL_PATH}/${link}
	COMMAND ${CMAKE_COMMAND} -E chdir ${FULL_INSTALL_PATH} ${CMAKE_COMMAND} -E  create_symlink ${target} ${link})

endmacro(create_PID_Install_Symlink)
