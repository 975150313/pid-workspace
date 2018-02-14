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
list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/system/api)
list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/system/commands)

include(PID_Wrapper_API_Internal_Functions NO_POLICY_SCOPE)
include(External_Definition NO_POLICY_SCOPE) #to be able to interpret content of external package description files

include(CMakeParseArguments)

#########################################################################################
######################## API to be used in wrapper description ##########################
#########################################################################################

### API : declare_PID_Wrapper(AUTHOR main_author_name ... [INSTITUION ...] [MAIL ...] YEAR ... LICENSE license [ADDRESS address] DESCRIPTION ...)
macro(declare_PID_Wrapper)
set(oneValueArgs LICENSE ADDRESS MAIL PUBLIC_ADDRESS README)
set(multiValueArgs AUTHOR INSTITUTION YEAR DESCRIPTION)
cmake_parse_arguments(DECLARE_PID_WRAPPER "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )
if(NOT DECLARE_PID_WRAPPER_AUTHOR)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, an author name must be given using AUTHOR keyword.")
endif()
if(NOT DECLARE_PID_WRAPPER_YEAR)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, a year or year interval must be given using YEAR keyword.")
endif()
if(NOT DECLARE_PID_WRAPPER_LICENSE)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, a license type must be given using LICENSE keyword.")
endif()
if(NOT DECLARE_PID_WRAPPER_DESCRIPTION)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, a (short) description of the wrapper must be given using DESCRIPTION keyword.")
endif()

if(DECLARE_PID_WRAPPER_UNPARSED_ARGUMENTS)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, unknown arguments ${DECLARE_PID_WRAPPER_UNPARSED_ARGUMENTS}.")
endif()

if(NOT DECLARE_PID_WRAPPER_ADDRESS AND DECLARE_PID_WRAPPER_PUBLIC_ADDRESS)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, the wrapper must have an adress if a public access adress is declared.")
endif()

declare_Wrapper(	"${DECLARE_PID_WRAPPER_AUTHOR}" "${DECLARE_PID_WRAPPER_INSTITUTION}" "${DECLARE_PID_WRAPPER_MAIL}"
			"${DECLARE_PID_WRAPPER_YEAR}" "${DECLARE_PID_WRAPPER_LICENSE}"
			"${DECLARE_PID_WRAPPER_ADDRESS}" "${DECLARE_PID_WRAPPER_PUBLIC_ADDRESS}"
		"${DECLARE_PID_WRAPPER_DESCRIPTION}" "${DECLARE_PID_WRAPPER_README}")
endmacro(declare_PID_Wrapper)

### feed information about the original projet
macro(define_PID_Wrapper_Original_Project_Info)
	set(oneValueArgs URL)
	set(multiValueArgs AUTHORS LICENSES)
	cmake_parse_arguments(DEFINE_WRAPPED_PROJECT "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )
	if(NOT DEFINE_WRAPPED_PROJECT_AUTHORS)
		message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, authors references must be given using AUTHOR keyword.")
	endif()
	if(NOT DEFINE_WRAPPED_PROJECT_LICENSES)
		message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, a license description must be given using LICENSE keyword.")
	endif()
	if(NOT DEFINE_WRAPPED_PROJECT_URL)
		message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, The URL of the original project must be given using URL keyword.")
	endif()
	define_Wrapped_Project("${DEFINE_WRAPPED_PROJECT_AUTHORS}" "${DEFINE_WRAPPED_PROJECT_LICENSES}"  "${DEFINE_WRAPPED_PROJECT_URL}")
endmacro(define_PID_Wrapper_Original_Project_Info)

### API : add_PID_Wrapper_Author(AUTHOR ... [INSTITUTION ...])
macro(add_PID_Wrapper_Author)
set(multiValueArgs AUTHOR INSTITUTION)
cmake_parse_arguments(ADD_PID_WRAPPER_AUTHOR "" "" "${multiValueArgs}" ${ARGN} )
if(NOT ADD_PID_WRAPPER_AUTHOR_AUTHOR)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, an author name must be given using AUTHOR keyword.")
endif()
add_Author("${ADD_PID_WRAPPER_AUTHOR_AUTHOR}" "${ADD_PID_WRAPPER_AUTHOR_INSTITUTION}")
endmacro(add_PID_Wrapper_Author)

### API : add_PID_Package_Category(category_path)
macro(add_PID_Wrapper_Category)
if(NOT ${ARGC} EQUAL 1)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, the add_PID_Wrapper_Category command requires one string argument of the form <category>[/subcategory]*.")
endif()
add_Category("${ARGV0}")
endmacro(add_PID_Wrapper_Category)

### API : declare_PID_Wrapper_Publishing()
macro(declare_PID_Wrapper_Publishing)
set(optionArgs PUBLISH_BINARIES)
set(oneValueArgs PROJECT FRAMEWORK GIT PAGE)
set(multiValueArgs DESCRIPTION ALLOWED_PLATFORMS)
cmake_parse_arguments(DECLARE_PID_WRAPPER_PUBLISHING "${optionArgs}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )
if(NOT DECLARE_PID_WRAPPER_PUBLISHING_PROJECT)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, you must tell where to find the project page of the official external package wrapper repository using PROJECT keyword.")
endif()

if(NOT DECLARE_PID_WRAPPER_PUBLISHING_FRAMEWORK AND NOT DECLARE_PID_WRAPPER_PUBLISHING_GIT)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, you must tell either where to find the repository of the package's static site (using GIT keyword) or to which framework the package contributes to (using FRAMEWORK keyword).")
endif()
if(DECLARE_PID_WRAPPER_PUBLISHING_FRAMEWORK)
	define_Framework_Contribution("${DECLARE_PID_WRAPPER_PUBLISHING_FRAMEWORK}" "${DECLARE_PID_WRAPPER_PUBLISHING_PROJECT}" "${DECLARE_PID_WRAPPER_PUBLISHING_DESCRIPTION}")
else()#DECLARE_PID_WRAPPER_PUBLISHING_HOME
	if(NOT DECLARE_PID_WRAPPER_PUBLISHING_PAGE)
		message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, you must tell where to find the index page for the static site of the package (using PAGE keyword).")
	endif()
	define_Static_Site_Contribution("${DECLARE_PID_WRAPPER_PUBLISHING_PROJECT}" "${DECLARE_PID_WRAPPER_PUBLISHING_GIT}" "${DECLARE_PID_WRAPPER_PUBLISHING_PAGE}" "${DECLARE_PID_WRAPPER_PUBLISHING_DESCRIPTION}")
endif()

#manage publication of binaries
if(DECLARE_PID_WRAPPER_PUBLISHING_ALLOWED_PLATFORMS)
	foreach(platform IN ITEMS ${DECLARE_PID_WRAPPER_PUBLISHING_ALLOWED_PLATFORMS})
		restrict_CI(${platform})
	endforeach()
endif()

#manage publication of binaries
if(DECLARE_PID_WRAPPER_PUBLISHING_PUBLISH_BINARIES)
	publish_Binaries(TRUE)
else()
	publish_Binaries(FALSE)
endif()
endmacro(declare_PID_Wrapper_Publishing)

### build the wrapper ==> providing commands used to deploy a specific version of the external package
### make build version=1.55.0 (download, configure, compile and install the adequate version)
macro(build_PID_Wrapper)
if(${ARGC} GREATER 0)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, the build_PID_Wrapper command requires no arguments.")
	return()
endif()
build_Wrapped_Project()
endmacro(build_PID_Wrapper)

########################################################################################
###############To be used in subfolders of the src folder ##############################
########################################################################################

#	memorizing a new known version (the target folder that can be found in src folder contains the script used to install the project)
macro(add_PID_Wrapper_Known_Version)
set(optionArgs)
set(oneValueArgs VERSION DEPLOY COMPATIBILITY SONAME POSTINSTALL)
set(multiValueArgs)
cmake_parse_arguments(ADD_PID_WRAPPER_KNOWN_VERSION "${optionArgs}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )
if(NOT ADD_PID_WRAPPER_KNOWN_VERSION_VERSION)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, you must define the version number using the VERSION keyword.")
endif()
if(NOT ADD_PID_WRAPPER_KNOWN_VERSION_DEPLOY)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, you must define the build script to use using the DEPLOY keyword.")
endif()

#verify the version information
set(version ${ADD_PID_WRAPPER_KNOWN_VERSION_VERSION})
if(NOT EXISTS ${CMAKE_SOURCE_DIR}/src/${version} OR NOT IS_DIRECTORY ${CMAKE_SOURCE_DIR}/src/${version})
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad version argument when calling add_PID_Wrapper_Known_Version, no folder \"${version}\" can be found in src folder !")
	return()
endif()
list(FIND ${PROJECT_NAME}_KNOWN_VERSIONS ${version} INDEX)
if(NOT INDEX EQUAL -1)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad version argument when calling add_PID_Wrapper_Known_Version, version \"${version}\" is already registered !")
	return()
endif()
#verify the script information
set(script_file ${ADD_PID_WRAPPER_KNOWN_VERSION_DEPLOY})
get_filename_component(RES_EXTENSION ${script_file} EXT)
if(NOT RES_EXTENSION MATCHES ".*\\.cmake$")
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad version argument when calling add_PID_Wrapper_Known_Version, type of script file ${script_file} cannot be deduced from its extension only .cmake extensions supported")
	return()
endif()

if(NOT EXISTS ${CMAKE_SOURCE_DIR}/src/${version}/${script_file})
	message(FATAL_ERROR "[PID] CRITICAL ERROR : cannot find script file ${script_file} in folder src/${version}/.")
	return()
endif()

#manage post install script
set(post_install_script)
if(ADD_PID_WRAPPER_KNOWN_VERSION_POSTINSTALL)
	set(post_install_script ${ADD_PID_WRAPPER_KNOWN_VERSION_POSTINSTALL})
	get_filename_component(RES_EXTENSION ${post_install_script} EXT)
	if(NOT RES_EXTENSION MATCHES ".*\\.cmake$")
		message(FATAL_ERROR "[PID] CRITICAL ERROR : bad version argument when calling add_PID_Wrapper_Known_Version, type of script file ${script_file} cannot be deduced from its extension only .cmake extensions supported")
		return()
	endif()
	if(NOT EXISTS ${CMAKE_SOURCE_DIR}/src/${version}/${post_install_script})
		message(FATAL_ERROR "[PID] CRITICAL ERROR : cannot find post install script file ${post_install_script} in folder src/${version}/.")
		return()
	endif()
endif()

if(ADD_PID_WRAPPER_KNOWN_VERSION_COMPATIBILITY)
	belongs_To_Known_Versions(PREVIOUS_VERSION_EXISTS ${ADD_PID_WRAPPER_KNOWN_VERSION_COMPATIBILITY})
	if(NOT PREVIOUS_VERSION_EXISTS)
		message(FATAL_ERROR "[PID] CRITICAL ERROR : compatibility with previous version ${ADD_PID_WRAPPER_KNOWN_VERSION_COMPATIBILITY} is impossible since this version is not wrapped.")
		return()
	endif()
	set(compatible_with_version ${ADD_PID_WRAPPER_KNOWN_VERSION_COMPATIBILITY})
endif()
add_Known_Version("${version}" "${script_file}" "${compatible_with_version}" "${ADD_PID_WRAPPER_KNOWN_VERSION_SONAME}" "${post_install_script}")
endmacro(add_PID_Wrapper_Known_Version)

### dependency to OS configuration
macro(declare_PID_Wrapper_Platform_Configuration)
set(oneValueArgs PLATFORM)
set(multiValueArgs CONFIGURATION)
cmake_parse_arguments(DECLARE_PID_WRAPPER_PLATFORM "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )
if(NOT DECLARE_PID_WRAPPER_PLATFORM_CONFIGURATION)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, declare_PID_Wrapper_Platform requires at least to define a required configuration using CONFIGURATION keyword.")
	return()
endif()
declare_Wrapped_Configuration("${DECLARE_PID_WRAPPER_PLATFORM_PLATFORM}" "${DECLARE_PID_WRAPPER_PLATFORM_CONFIGURATION}")
endmacro(declare_PID_Wrapper_Platform_Configuration)

### dependency to another external package
macro(declare_PID_Wrapper_External_Dependency)
set(options )
set(oneValueArgs PACKAGE)
set(multiValueArgs) #known versions of the external package that can be used to build/run it
cmake_parse_arguments(DECLARE_PID_WRAPPER_DEPENDENCY "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )
if(NOT DECLARE_PID_WRAPPER_DEPENDENCY_PACKAGE)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, declare_PID_Wrapper_External_Dependency requires to define the name of the dependency by using PACKAGE keyword.")
	return()
endif()
if(DECLARE_PID_WRAPPER_DEPENDENCY_PACKAGE STREQUAL PROJECT_NAME)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, package ${DECLARE_PID_WRAPPER_DEPENDENCY_PACKAGE} cannot require itself !")
	return()
endif()
set(list_of_versions)
set(exact_versions)
if(DECLARE_PID_WRAPPER_DEPENDENCY_UNPARSED_ARGUMENTS)#there are still arguments to parse
	set(TO_PARSE "${DECLARE_PID_WRAPPER_DEPENDENCY_UNPARSED_ARGUMENTS}")
	set(RES_VERSION TRUE)
	while(TO_PARSE AND RES_VERSION)
		parse_Package_Dependency_Version_Arguments("${TO_PARSE}" RES_VERSION RES_EXACT TO_PARSE)#TODO
		if(RES_VERSION)
			list(APPEND list_of_versions ${RES_VERSION})
			if(RES_EXACT)
				list(APPEND exact_versions ${RES_VERSION})
			endif()
		elseif(RES_EXACT)
			message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments when declaring dependency to external package ${DECLARE_PID_WRAPPER_DEPENDENCY_PACKAGE}, you must use the EXACT keyword together with the VERSION keyword.")
			return()
		endif()
	endwhile()
endif()
set(list_of_components)
if(TO_PARSE) #there are still expression to parse
	set(oneValueArgs)
	set(options)
	set(multiValueArgs COMPONENTS)
	cmake_parse_arguments(DECLARE_PID_WRAPPER_DEPENDENCY_MORE "${options}" "${oneValueArgs}" "${multiValueArgs}" ${TO_PARSE})
	if(DECLARE_PID_WRAPPER_DEPENDENCY_MORE_COMPONENTS)
		list(LENGTH DECLARE_PID_WRAPPER_DEPENDENCY_COMPONENTS SIZE)
		if(SIZE LESS 1)
			message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments when declaring dependency to external package ${DECLARE_PID_WRAPPER_DEPENDENCY_PACKAGE}, at least one component dependency must be defined when using the COMPONENTS keyword.")
			return()
		endif()
		set(list_of_components ${DECLARE_PID_WRAPPER_DEPENDENCY_MORE_COMPONENTS})
	else()
		message(FATAL_ERROR "[PID] WARNING : when declaring dependency to external package ${DECLARE_PID_WRAPPER_DEPENDENCY_PACKAGE}, unknown arguments used ${DECLARE_PID_WRAPPER_DEPENDENCY_MORE_UNPARSED_ARGUMENTS}.")
	endif()
endif()

declare_Wrapped_External_Dependency("${DECLARE_PID_WRAPPER_DEPENDENCY_PACKAGE}" "${list_of_versions}" "${exact_versions}" "${list_of_components}")
endmacro(declare_PID_Wrapper_External_Dependency)

### define a component
macro(declare_PID_Wrapper_Component)
set(oneValueArgs COMPONENT C_STANDARD CXX_STANDARD)
set(multiValueArgs INCLUDES SHARED_LINKS STATIC_LINKS DEFINITIONS OPTIONS RUNTIME_RESOURCES) #known versions of the external package that can be used to build/run it
cmake_parse_arguments(DECLARE_PID_WRAPPER_COMPONENT "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )
if(NOT DECLARE_PID_WRAPPER_COMPONENT_COMPONENT)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, declare_PID_Wrapper_Component requires to define the name of the component by using COMPONENT keyword.")
	return()
endif()
if(NOT DECLARE_PID_WRAPPER_COMPONENT_SHARED_LINKS
	AND NOT DECLARE_PID_WRAPPER_COMPONENT_STATIC_LINKS
	AND NOT DECLARE_PID_WRAPPER_COMPONENT_INCLUDES)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : when calling declare_PID_Wrapper_Component, component descirption is empty ! Use one or more of the keywords INCLUDES SHARED_LINKS STATIC_LINKS to define such resources.")
	return()
endif()
declare_Wrapped_Component(${DECLARE_PID_WRAPPER_COMPONENT_COMPONENT}
	"${DECLARE_PID_WRAPPER_COMPONENT_SHARED_LINKS}"
	"${DECLARE_PID_WRAPPER_COMPONENT_STATIC_LINKS}"
	"${DECLARE_PID_WRAPPER_COMPONENT_INCLUDES}"
	"${DECLARE_PID_WRAPPER_COMPONENT_DEFINITIONS}"
	"${DECLARE_PID_WRAPPER_COMPONENT_OPTIONS}"
	"${DECLARE_PID_WRAPPER_COMPONENT_C_STANDARD}"
	"${DECLARE_PID_WRAPPER_COMPONENT_CXX_STANDARD}"
	"${DECLARE_PID_WRAPPER_COMPONENT_RUNTIME_RESOURCES}")
endmacro(declare_PID_Wrapper_Component)

### define a component
macro(declare_PID_Wrapper_Component_Dependency)
set(options EXPORT)
set(oneValueArgs COMPONENT EXTERNAL PACKAGE)
set(multiValueArgs INCLUDES SHARED_LINKS STATIC_LINKS DEFINITIONS OPTIONS)
cmake_parse_arguments(DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )
if(NOT DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_COMPONENT)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, declare_PID_Wrapper_Component_Dependency requires to define the name of the component to chich a dependency applies by using the COMPONENT keyword.")
	return()
endif()

if(DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_EXPORT)
	set(exported TRUE)
else()
	set(exported FALSE)
endif()

if(DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_PACKAGE) #this is a dependency to another external package
	list(FIND ${PROJECT_NAME}_KNOWN_VERSION_${CURRENT_MANAGED_VERSION}_DEPENDENCIES ${DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_PACKAGE} INDEX)
	if(INDEX EQUAL -1)
		message(FATAL_ERROR "[PID] CRITICAL ERROR : when calling declare_PID_Wrapper_Component_Dependency, the external package ${DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_PACKAGE} the component ${DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_COMPONENT} depends on external package ${DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_PACKAGE} that is not defined as a dependency of the current project.")
		return()
	endif()
	if(DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_EXTERNAL)
		declare_Wrapped_Component_Dependency_To_Explicit_Component(${DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_COMPONENT}
			${DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_PACKAGE}
			${DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_EXTERNAL}
			${exported}
			"${DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_DEFINITIONS}"
		)
	else()
		declare_Wrapped_Component_Dependency_To_Implicit_Components(${DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_COMPONENT}
			${DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_PACKAGE} #everything exported by default
			"${DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_INCLUDES}"
			"${DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_SHARED_LINKS}"
			"${DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_STATIC_LINKS}"
			"${DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_DEFINITIONS}"
			"${DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_OPTIONS}"
		)
	endif()
else()#this is a dependency to another component defined in the same external package
	if(NOT DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_EXTERNAL)
		message(FATAL_ERROR "[PID] CRITICAL ERROR : when calling declare_PID_Wrapper_Component_Dependency, need to define the component used by ${DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_COMPONENT}, by using the keyword EXTERNAL.")
		return()
	endif()
	declare_Wrapped_Component_Internal_Dependency(${DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_COMPONENT}
		${DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_EXTERNAL}
		${exported}
		"${DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_DEFINITIONS}"
	)
endif()
endmacro(declare_PID_Wrapper_Component_Dependency)


#########################################################################################
######################## API to be used in deploy scripts ###############################
#########################################################################################

###
function(translate_Into_Options)
set(options)
set(oneValueArgs C_STANDARD CXX_STANDARD FLAGS)
set(multiValueArgs INCLUDES DEFINITIONS)
cmake_parse_arguments(TRANSLATE_INTO_OPTION "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )
if(NOT TRANSLATE_INTO_OPTION_FLAGS)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : when calling translate_Into_Options, need to define the variable where to return flags by using the FLAGS keyword.")
	return()
endif()
set(result "")
if(TRANSLATE_INTO_OPTION_INCLUDES)
	foreach(an_include IN ITEMS ${TRANSLATE_INTO_OPTION_INCLUDES})
		set(result "${result} -I${an_include}")
	endforeach()
endif()
if(TRANSLATE_INTO_OPTION_DEFINITIONS)
	foreach(a_def IN ITEMS ${TRANSLATE_INTO_OPTION_DEFINITIONS})
		set(result "${result} -D${a_def}")
	endforeach()
endif()

if(TRANSLATE_INTO_OPTION_C_STANDARD OR TRANSLATE_INTO_OPTION_CXX_STANDARD)
	translate_Standard_Into_Option(RES_C_STD_OPT RES_CXX_STD_OPT "${TRANSLATE_INTO_OPTION_C_STANDARD}" "${TRANSLATE_INTO_OPTION_CXX_STANDARD}")
	if(RES_C_STD_OPT)
		set(result "${result} ${RES_C_STD_OPT}")
	endif()
	if(RES_CXX_STD_OPT)
		set(result "${result} ${RES_CXX_STD_OPT}")
	endif()
endif()
set(${TRANSLATE_INTO_OPTION_FLAGS} ${result} PARENT_SCOPE)
endfunction(translate_Into_Options)

###
function(get_External_Dependency_Info)
set(options FLAGS)
set(oneValueArgs PACKAGE ROOT C_STANDARD CXX_STANDARD)
set(multiValueArgs OPTIONS INCLUDES DEFINITIONS LINKS)
cmake_parse_arguments(GET_EXTERNAL_DEPENDENCY_INFO "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )
if(NOT GET_EXTERNAL_DEPENDENCY_INFO_PACKAGE)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : when calling get_External_Dependency_Info, need to define the external package by using the keyword PACKAGE.")
	return()
endif()

#build the version prefix using variables automatically configured in Build_PID_Wrapper script
#for cleaner description at next lines only
set(prefix ${TARGET_EXTERNAL_PACKAGE}_KNOWN_VERSION_${TARGET_EXTERNAL_VERSION})

if(GET_EXTERNAL_DEPENDENCY_INFO_ROOT)
	set(dep_version ${${prefix}_DEPENDENCY_${GET_EXTERNAL_DEPENDENCY_INFO_PACKAGE}_VERSION_USED_FOR_BUILD})
	set(ext_package_root ${WORKSPACE_DIR}/external/${CURRENT_PLATFORM}/${GET_EXTERNAL_DEPENDENCY_INFO_PACKAGE}/${dep_version})
	set(${GET_EXTERNAL_DEPENDENCY_INFO_ROOT} ${ext_package_root} PARENT_SCOPE)
endif()

if(GET_EXTERNAL_DEPENDENCY_INFO_INCLUDES)
	if(GET_EXTERNAL_DEPENDENCY_INFO_FLAGS)
		translate_Into_Options(INCLUDES ${${prefix}_BUILD_INCLUDES} FLAGS RES_INCLUDES)
		set(${GET_EXTERNAL_DEPENDENCY_INFO_INCLUDES} ${RES_INCLUDES} PARENT_SCOPE)
	else()
  	set(${GET_EXTERNAL_DEPENDENCY_INFO_INCLUDES} ${${prefix}_BUILD_INCLUDES} PARENT_SCOPE)
	endif()
endif()

if(GET_EXTERNAL_DEPENDENCY_INFO_DEFINITIONS)
	if(GET_EXTERNAL_DEPENDENCY_INFO_FLAGS)
		translate_Into_Options(DEFINITIONS ${${prefix}_BUILD_DEFINITIONS} FLAGS RES_DEFS)
		set(${GET_EXTERNAL_DEPENDENCY_INFO_INCLUDES} ${RES_DEFS} PARENT_SCOPE)
	else()
	  set(${GET_EXTERNAL_DEPENDENCY_INFO_INCLUDES} ${${prefix}_BUILD_DEFINITIONS} PARENT_SCOPE)
	endif()
endif()

if(GET_EXTERNAL_DEPENDENCY_INFO_OPTIONS)
  set(${GET_EXTERNAL_DEPENDENCY_INFO_INCLUDES} ${${prefix}_BUILD_COMPILER_OPTIONS} PARENT_SCOPE)
endif()

if(GET_EXTERNAL_DEPENDENCY_INFO_C_STANDARD)
	if(GET_EXTERNAL_DEPENDENCY_INFO_FLAGS)
		translate_Into_Options(C_STANDARD ${${prefix}_BUILD_C_STANDARD} FLAGS RES_C_STD)
		set(${GET_EXTERNAL_DEPENDENCY_INFO_C_STANDARD} ${RES_C_STD} PARENT_SCOPE)
	else()
	  set(${GET_EXTERNAL_DEPENDENCY_INFO_C_STANDARD} ${${prefix}_BUILD_C_STANDARD} PARENT_SCOPE)
	endif()
endif()

if(GET_EXTERNAL_DEPENDENCY_INFO_CXX_STANDARD)
	if(GET_EXTERNAL_DEPENDENCY_INFO_FLAGS)
		translate_Into_Options(CXX_STANDARD ${${prefix}_BUILD_CXX_STANDARD} FLAGS RES_CXX_STD)
		set(${GET_EXTERNAL_DEPENDENCY_INFO_CXX_STANDARD} ${RES_CXX_STD} PARENT_SCOPE)
	else()
	  set(${GET_EXTERNAL_DEPENDENCY_INFO_CXX_STANDARD} ${${prefix}_BUILD_CXX_STANDARD} PARENT_SCOPE)
	endif()
endif()

if(GET_EXTERNAL_DEPENDENCY_INFO_LINKS)
  set(${GET_EXTERNAL_DEPENDENCY_INFO_LINKS} ${${prefix}_BUILD_LINKS} PARENT_SCOPE)
endif()

endfunction(get_External_Dependency_Info)
