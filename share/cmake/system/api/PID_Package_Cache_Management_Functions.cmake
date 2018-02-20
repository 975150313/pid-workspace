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
if(PID_PACKAGE_CACHE_MANAGEMENT_FUNCTIONS_INCLUDED)
  return()
endif()
set(PID_PACKAGE_CACHE_MANAGEMENT_FUNCTIONS_INCLUDED TRUE)
##########################################################################################

#############################################################################################
#################### API functions for managing dependency constraints when building ########
#############################################################################################

###
function(erase_Previous_Build_Constraint_From_Package)
#prepare the package constraints to be registered
if(RECEIVED_CONSTRAINTS) #there were constraints previously registered
	#reset all previous info from this package
	if(RECEIVED_CONSTRAINTS_${RECEIVED_CONSTRAINTS})
		foreach(dep IN LISTS RECEIVED_CONSTRAINTS_${RECEIVED_CONSTRAINTS})
			set(RECEIVED_CONSTRAINTS_${RECEIVED_CONSTRAINTS}_${dep} CACHE INTERNAL "")
			set(RECEIVED_CONSTRAINTS_${RECEIVED_CONSTRAINTS}_${dep}_EXACT CACHE INTERNAL "")
		endforeach()
		set(RECEIVED_CONSTRAINTS_${RECEIVED_CONSTRAINTS} CACHE INTERNAL "")
	endif()
endif()
endfunction(erase_Previous_Build_Constraint_From_Package)

###
function(set_Build_Constraints_From_Package package)
	#set the global memory adequately
set(RECEIVED_CONSTRAINTS ${package} CACHE INTERNAL "")
set(RECEIVED_CONSTRAINTS_${package} ${SET_BUILD_CONSTRAINTS_${package}} CACHE INTERNAL "")
foreach(dep IN LISTS RECEIVED_CONSTRAINTS_${package})
	set(RECEIVED_CONSTRAINTS_${package}_${dep} ${SET_BUILD_CONSTRAINTS_${package}_${dep}} CACHE INTERNAL "")
	set(RECEIVED_CONSTRAINTS_${package}_${dep}_EXACT ${SET_BUILD_CONSTRAINTS_${package}_${dep}_EXACT} CACHE INTERNAL "")
endforeach()
endfunction(set_Build_Constraints_From_Package)

###
function(reset_Build_Constraint_Variables_For_Interaction)
foreach(dep IN LISTS SET_BUILD_CONSTRAINTS_${SET_BUILD_CONSTRAINTS})#reset the build constraints passed by a given package
	set(SET_BUILD_CONSTRAINTS_${SET_BUILD_CONSTRAINTS}_${dep} CACHE INTERNAL "")
	set(SET_BUILD_CONSTRAINTS_${SET_BUILD_CONSTRAINTS}_${dep}_EXACT CACHE INTERNAL "")
endforeach()
set(SET_BUILD_CONSTRAINTS_${SET_BUILD_CONSTRAINTS} CACHE INTERNAL "")#reset the build constraints
set(SET_BUILD_CONSTRAINTS CACHE INTERNAL "")#reset the build constraints
endfunction(reset_Build_Constraint_Variables_For_Interaction)

###
function(received_Build_Contraints)
if(SET_BUILD_CONSTRAINTS)#if another set of constraints is provided then reconfigure, otherwise keep configuration "as is"
	erase_Previous_Build_Constraint_From_Package()
	set_Build_Constraints_From_Package(${SET_BUILD_CONSTRAINTS})
	reset_Build_Constraint_Variables_For_Interaction() #need to reset before another package ask for specific constraints
endif()
endfunction(received_Build_Contraints)

### HERE TODO : use all the received constraints from one package to configure dependency alternatives/option chosen
function(configured_With_Build_Constraints VERSION IS_EXACT dep_package)
if(RECEIVED_CONSTRAINTS)
	set(package ${RECEIVED_CONSTRAINTS})
	if(RECEIVED_CONSTRAINTS_${package})
		list(FIND RECEIVED_CONSTRAINTS_${package} ${dep_package} INDEX)
		if(NOT INDEX EQUAL -1)#the dependency is also used locally
			set(${VERSION} ${RECEIVED_CONSTRAINTS_${package}_${dep_package}} PARENT_SCOPE)
			set(${IS_EXACT} ${RECEIVED_CONSTRAINTS_${package}_${dep_package}_EXACT} PARENT_SCOPE)
			return()
		endif()
	endif()
endif()
#otherwise no constraint on version
set(${VERSION} PARENT_SCOPE)
set(${IS_EXACT} PARENT_SCOPE)
endfunction(configured_With_Build_Constraints)

#############################################################################################
############### API functions for managing user options cache variables #####################
#############################################################################################
include(CMakeDependentOption)

###
macro(declare_Native_Global_Cache_Options)

# base options
option(BUILD_EXAMPLES "Package builds examples" OFF)
option(BUILD_API_DOC "Package generates the HTML API documentation" OFF)
option(BUILD_AND_RUN_TESTS "Package uses tests" OFF)
option(BUILD_RELEASE_ONLY "Package only build release version" OFF)
option(GENERATE_INSTALLER "Package generates an OS installer for UNIX system" OFF)
option(REQUIRED_PACKAGES_AUTOMATIC_DOWNLOAD "Enabling the automatic download of not found packages marked as required" ON)
option(ENABLE_PARALLEL_BUILD "Package is built with optimum number of jobs with respect to system properties" ON)
option(BUILD_DEPENDENT_PACKAGES "the build will leads to the rebuild of its dependent package that lies in the workspace as source packages" ON)
option(ADDITIONNAL_DEBUG_INFO "Getting more info on debug mode or more PID messages (hidden by default)" OFF)
option(BUILD_STATIC_CODE_CHECKING_REPORT "running static checks on libraries and applications, if tests are run then additionnal static code checking tests are automatically added." OFF)

# dependent options
include(CMakeDependentOption)
CMAKE_DEPENDENT_OPTION(BUILD_LATEX_API_DOC "Package generates the LATEX api documentation" OFF "BUILD_API_DOC" OFF)
CMAKE_DEPENDENT_OPTION(BUILD_TESTS_IN_DEBUG "Package build and run test in debug mode also" OFF "BUILD_AND_RUN_TESTS" OFF)
CMAKE_DEPENDENT_OPTION(BUILD_COVERAGE_REPORT "Package build a coverage report in debug mode" ON "BUILD_AND_RUN_TESTS;BUILD_TESTS_IN_DEBUG" OFF)
CMAKE_DEPENDENT_OPTION(REQUIRED_PACKAGES_AUTOMATIC_UPDATE "Package will try to install new version when configuring" OFF "REQUIRED_PACKAGES_AUTOMATIC_DOWNLOAD" OFF)

endmacro(declare_Native_Global_Cache_Options)

###
macro(manage_Parrallel_Build_Option)

### parallel builds management
if(ENABLE_PARALLEL_BUILD)
	include(ProcessorCount)
	ProcessorCount(NUMBER_OF_JOBS)
	math(EXPR NUMBER_OF_JOBS ${NUMBER_OF_JOBS}+1)
	if(${NUMBER_OF_JOBS} GREATER 1)
		set(PARALLEL_JOBS_FLAG "-j${NUMBER_OF_JOBS}" CACHE INTERNAL "")
	endif()
else()
	set(PARALLEL_JOBS_FLAG CACHE INTERNAL "")
endif()

endmacro(manage_Parrallel_Build_Option)

function(set_Mode_Specific_Options_From_Global)
	execute_process(COMMAND ${CMAKE_COMMAND} -L -N WORKING_DIRECTORY ${CMAKE_BINARY_DIR} OUTPUT_FILE ${CMAKE_BINARY_DIR}/options.txt)
	#parsing option file and generating a load cache cmake script
	file(STRINGS ${CMAKE_BINARY_DIR}/options.txt LINES)
	set(CACHE_OK FALSE)
	foreach(line IN LISTS LINES)
		if(NOT line STREQUAL "-- Cache values")
			set(CACHE_OK TRUE)
			break()
		endif()
	endforeach()
	set(OPTIONS_FILE ${CMAKE_BINARY_DIR}/share/cacheConfig.cmake)
	file(WRITE ${OPTIONS_FILE} "")
	if(CACHE_OK)
		foreach(line IN LISTS LINES)
			if(NOT line STREQUAL "-- Cache values")
				string(REGEX REPLACE "^([^:]+):([^=]+)=(.*)$" "set( \\1 \\3\ CACHE \\2 \"\" FORCE)\n" AN_OPTION "${line}")
				file(APPEND ${OPTIONS_FILE} ${AN_OPTION})
			endif()
		endforeach()
	else() # only populating the load cache script with default PID cache variables to transmit them to release/debug mode caches
		file(APPEND ${OPTIONS_FILE} "set(WORKSPACE_DIR ${WORKSPACE_DIR} CACHE PATH \"\" FORCE)\n")
		file(APPEND ${OPTIONS_FILE} "set(BUILD_EXAMPLES ${BUILD_EXAMPLES} CACHE BOOL \"\" FORCE)\n")
		file(APPEND ${OPTIONS_FILE} "set(BUILD_API_DOC ${BUILD_API_DOC} CACHE BOOL \"\" FORCE)\n")
		file(APPEND ${OPTIONS_FILE} "set(BUILD_COVERAGE_REPORT ${BUILD_COVERAGE_REPORT} CACHE BOOL \"\" FORCE)\n")
		file(APPEND ${OPTIONS_FILE} "set(BUILD_STATIC_CODE_CHECKING_REPORT ${BUILD_STATIC_CODE_CHECKING_REPORT} CACHE BOOL \"\" FORCE)\n")
		file(APPEND ${OPTIONS_FILE} "set(BUILD_LATEX_API_DOC ${BUILD_LATEX_API_DOC} CACHE BOOL \"\" FORCE)\n")
		file(APPEND ${OPTIONS_FILE} "set(BUILD_AND_RUN_TESTS ${BUILD_AND_RUN_TESTS} CACHE BOOL \"\" FORCE)\n")
		file(APPEND ${OPTIONS_FILE} "set(RUN_TESTS_WITH_PRIVILEGES ${RUN_TESTS_WITH_PRIVILEGES} CACHE BOOL \"\" FORCE)\n")
		file(APPEND ${OPTIONS_FILE} "set(BUILD_TESTS_IN_DEBUG ${BUILD_TESTS_IN_DEBUG} CACHE BOOL \"\" FORCE)\n")
		file(APPEND ${OPTIONS_FILE} "set(BUILD_RELEASE_ONLY ${BUILD_RELEASE_ONLY} CACHE BOOL \"\" FORCE)\n")
		file(APPEND ${OPTIONS_FILE} "set(GENERATE_INSTALLER ${GENERATE_INSTALLER} CACHE BOOL \"\" FORCE)\n")
		file(APPEND ${OPTIONS_FILE} "set(REQUIRED_PACKAGES_AUTOMATIC_DOWNLOAD ${REQUIRED_PACKAGES_AUTOMATIC_DOWNLOAD} CACHE BOOL \"\" FORCE)\n")
		file(APPEND ${OPTIONS_FILE} "set(REQUIRED_PACKAGES_AUTOMATIC_UPDATE ${REQUIRED_PACKAGES_AUTOMATIC_UPDATE} CACHE BOOL \"\" FORCE)\n")
		file(APPEND ${OPTIONS_FILE} "set(ENABLE_PARALLEL_BUILD ${ENABLE_PARALLEL_BUILD} CACHE BOOL \"\" FORCE)\n")
		file(APPEND ${OPTIONS_FILE} "set(BUILD_DEPENDENT_PACKAGES ${BUILD_DEPENDENT_PACKAGES} CACHE BOOL \"\" FORCE)\n")
		file(APPEND ${OPTIONS_FILE} "set(ADDITIONNAL_DEBUG_INFO ${ADDITIONNAL_DEBUG_INFO} CACHE BOOL \"\" FORCE)\n")
	endif()
endfunction(set_Mode_Specific_Options_From_Global)

function(set_Global_Options_From_Mode_Specific)

	# copying new cache entries in the global build cache
	execute_process(COMMAND ${CMAKE_COMMAND} -LH -N WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/debug OUTPUT_FILE ${CMAKE_BINARY_DIR}/optionsDEBUG.txt)
execute_process(COMMAND ${CMAKE_COMMAND} -LH -N WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/release OUTPUT_FILE ${CMAKE_BINARY_DIR}/optionsRELEASE.txt)
	file(STRINGS ${CMAKE_BINARY_DIR}/options.txt LINES_GLOBAL)
	file(STRINGS ${CMAKE_BINARY_DIR}/optionsDEBUG.txt LINES_DEBUG)
	file(STRINGS ${CMAKE_BINARY_DIR}/optionsRELEASE.txt LINES_RELEASE)
	# searching new cache entries in release mode cache
	foreach(line IN LISTS LINES_RELEASE)
		if(NOT "${line}" STREQUAL "-- Cache values" AND NOT "${line}" STREQUAL "")#this line may contain option info
			string(REGEX REPLACE "^//(.*)$" "\\1" COMMENT ${line})
			if("${line}" STREQUAL "${COMMENT}") #no match this is an option line
				string(REGEX REPLACE "^([^:]+):([^=]+)=(.+)$" "\\1;\\2;\\3" AN_OPTION "${line}") #indexes 0: name, 1:value, 2: type
				if("${AN_OPTION}" STREQUAL "${line}")#no match this is certainly
					string(REGEX REPLACE "^([^:]+):([^=]+)=(.*)$" "\\1;\\2;\\3" AN_OPTION "${line}") #there is certainly no value set for the option
					list(GET AN_OPTION 0 var_name)
					string(FIND "${LINES}" "${var_name}" POS)
					if(POS EQUAL -1)#not found, this a new cache entry
						list(GET AN_OPTION 1 var_type)
						set(${var_name} CACHE ${var_type} "${last_comment}")
					endif()
				else() #OK the option has a value
					list(GET AN_OPTION 0 var_name)
					string(FIND "${LINES}" "${var_name}" POS)
					if(POS EQUAL -1)#not found, this a new cache entry
						list(GET AN_OPTION 1 var_type)
						list(GET AN_OPTION 2 var_value)
						set(${var_name} ${var_value} CACHE ${var_type} "${last_comment}")
					endif()
				endif()
			else()#match is OK this is a comment line
				set(last_comment "${COMMENT}")
			endif()
		endif()
	endforeach()


	# searching new cache entries in debug mode cache
	foreach(line IN LISTS LINES_DEBUG)
		if(NOT "${line}" STREQUAL "-- Cache values" AND NOT "${line}" STREQUAL "")
			string(REGEX REPLACE "^//(.*)$" "\\1" COMMENT ${line})
			if("${line}" STREQUAL "${COMMENT}") #no match this is an option line
				string(REGEX REPLACE "^([^:]+):([^=]+)=(.*)$" "\\1;\\3;\\2" AN_OPTION "${line}")
				list(GET AN_OPTION 0 var_name)
				string(FIND "${LINES}" "${var_name}" POS)
				string(FIND "${LINES_RELEASE}" "${var_name}" POS_REL)
				if(POS EQUAL -1 AND POS_REL EQUAL -1)#not found
					list(GET AN_OPTION 1 var_value)
					list(GET AN_OPTION 2 var_type)
					set(${var_name} ${var_value} CACHE ${var_type} "${last_comment}")
				endif()
			else()#match is OK this is a comment line
				set(last_comment "${COMMENT}")
			endif()
		endif()
	endforeach()
	# searching removed cache entries in release and debug mode caches => then remove them from global cache
	foreach(line IN LISTS LINES_GLOBAL)
		if(NOT "${line}" STREQUAL "-- Cache values" AND NOT "${line}" STREQUAL "")#this line may contain option info
			string(REGEX REPLACE "^//(.*)$" "\\1" COMMENT ${line})
			if("${line}" STREQUAL "${COMMENT}") #no match this is an option line
				string(REGEX REPLACE "^([^:]+):([^=]+)=(.*)$" "\\1;\\3;\\2" AN_OPTION "${line}")
				list(GET AN_OPTION 0 var_name)
				string(FIND "${LINES_DEBUG}" "${var_name}" POS_DEB)
				string(FIND "${LINES_RELEASE}" "${var_name}" POS_REL)
				if(POS_DEB EQUAL -1 AND POS_REL EQUAL -1)#not found in any mode specific cache
					unset(${var_name} CACHE)
				endif()
			endif()
		endif()
	endforeach()

	#removing temporary files containing cache entries
	execute_process(COMMAND ${CMAKE_COMMAND} -E remove -f ${CMAKE_BINARY_DIR}/optionsDEBUG.txt)
	execute_process(COMMAND ${CMAKE_COMMAND} -E remove -f ${CMAKE_BINARY_DIR}/optionsRELEASE.txt)
	execute_process(COMMAND ${CMAKE_COMMAND} -E remove -f ${CMAKE_BINARY_DIR}/options.txt)
endfunction(set_Global_Options_From_Mode_Specific)


###
function(reset_Mode_Cache_Options CACHE_POPULATED)

#unset all global options
set(WORKSPACE_DIR "" CACHE PATH "" FORCE)
set(BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)
set(BUILD_API_DOC OFF CACHE BOOL "" FORCE)
set(BUILD_COVERAGE_REPORT OFF CACHE BOOL "" FORCE)
set(BUILD_STATIC_CODE_CHECKING_REPORT OFF CACHE BOOL "" FORCE)
set(BUILD_LATEX_API_DOC OFF CACHE BOOL "" FORCE)
set(BUILD_AND_RUN_TESTS OFF CACHE BOOL "" FORCE)
set(BUILD_TESTS_IN_DEBUG OFF CACHE BOOL "" FORCE)
set(BUILD_RELEASE_ONLY OFF CACHE BOOL "" FORCE)
set(GENERATE_INSTALLER OFF CACHE BOOL "" FORCE)
set(ADDITIONNAL_DEBUG_INFO OFF CACHE BOOL "" FORCE)
set(REQUIRED_PACKAGES_AUTOMATIC_UPDATE OFF CACHE BOOL "" FORCE)
#default ON options
set(ENABLE_PARALLEL_BUILD ON CACHE BOOL "" FORCE)
set(REQUIRED_PACKAGES_AUTOMATIC_DOWNLOAD ON CACHE BOOL "" FORCE)
set(BUILD_DEPENDENT_PACKAGES ON CACHE BOOL "" FORCE)
#include the cmake script that sets the options coming from the global build configuration
if(EXISTS ${CMAKE_BINARY_DIR}/../share/cacheConfig.cmake)
	include(${CMAKE_BINARY_DIR}/../share/cacheConfig.cmake NO_POLICY_SCOPE)
	set(${CACHE_POPULATED} TRUE PARENT_SCOPE)
else()
	set(${CACHE_POPULATED} FALSE PARENT_SCOPE)
endif()

#some purely internal variable that are global for the project
set(PROJECT_RUN_TESTS FALSE CACHE INTERNAL "")
set(RUN_TESTS_WITH_PRIVILEGES FALSE CACHE INTERNAL "")
endfunction(reset_Mode_Cache_Options)



###
function(first_Called_Build_Mode RESULT)
set(${RESULT} FALSE PARENT_SCOPE)
if(CMAKE_BUILD_TYPE MATCHES Debug OR (CMAKE_BUILD_TYPE MATCHES Release AND BUILD_RELEASE_ONLY))
	set(${RESULT} TRUE PARENT_SCOPE)
endif()
endfunction(first_Called_Build_Mode)

############################################################################
############### API functions for setting global package info ##############
############################################################################

### printing variables for components in the package ################
macro(print_Component component imported)
	if(NOT ${PROJECT_NAME}_${component}_TYPE STREQUAL "PYTHON")
		message("COMPONENT : ${component}${INSTALL_NAME_SUFFIX}")
		message("INTERFACE : ")
		get_target_property(RES_VAR ${component}${INSTALL_NAME_SUFFIX} INTERFACE_INCLUDE_DIRECTORIES)
		message("includes of ${component}${INSTALL_NAME_SUFFIX} = ${RES_VAR}")
		get_target_property(RES_VAR ${component}${INSTALL_NAME_SUFFIX} INTERFACE_COMPILE_DEFINITIONS)
		message("defs of ${component}${INSTALL_NAME_SUFFIX} = ${RES_VAR}")
		get_target_property(RES_VAR ${component}${INSTALL_NAME_SUFFIX} INTERFACE_LINK_LIBRARIES)
		message("libraries of ${component}${INSTALL_NAME_SUFFIX} = ${RES_VAR}")

		if(NOT ${imported} AND NOT ${PROJECT_NAME}_${component}_TYPE STREQUAL "HEADER")
			message("IMPLEMENTATION :")
			get_target_property(RES_VAR ${component}${INSTALL_NAME_SUFFIX} INCLUDE_DIRECTORIES)
			message("includes of ${component}${INSTALL_NAME_SUFFIX} = ${RES_VAR}")
			get_target_property(RES_VAR ${component}${INSTALL_NAME_SUFFIX} COMPILE_DEFINITIONS)
			message("defs of ${component}${INSTALL_NAME_SUFFIX} = ${RES_VAR}")
			get_target_property(RES_VAR ${component}${INSTALL_NAME_SUFFIX} LINK_LIBRARIES)
			message("libraries of ${component}${INSTALL_NAME_SUFFIX} = ${RES_VAR}")
		endif()
	else()
		message("COMPONENT : ${component}${INSTALL_NAME_SUFFIX} IS PYTHON SCRIPT")
	endif()
endmacro(print_Component)

macro(print_Component_Variables)
	message("components of package ${PROJECT_NAME} are :" ${${PROJECT_NAME}_COMPONENTS})
	message("libraries : " ${${PROJECT_NAME}_COMPONENTS_LIBS})
	message("applications : " ${${PROJECT_NAME}_COMPONENTS_APPS})
	message("applications : " ${${PROJECT_NAME}_COMPONENTS_SCRIPTS})

	foreach(component IN LISTS ${PROJECT_NAME}_COMPONENTS)
		print_Component(${component} FALSE)
	endforeach()
endmacro(print_Component_Variables)

function(init_Standard_Path_Cache_Variables)
set(${PROJECT_NAME}_INSTALL_PATH ${PACKAGE_BINARY_INSTALL_DIR}/${PROJECT_NAME} CACHE INTERNAL "")
set(CMAKE_INSTALL_PREFIX ${${PROJECT_NAME}_INSTALL_PATH}  CACHE INTERNAL "")
set(${PROJECT_NAME}_PID_RUNTIME_RESOURCE_PATH ${CMAKE_SOURCE_DIR}/share/resources CACHE INTERNAL "")
endfunction(init_Standard_Path_Cache_Variables)


### set cache variable for install
function(set_Install_Cache_Variables)
	set(${PROJECT_NAME}_DEPLOY_PATH ${${PROJECT_NAME}_VERSION} CACHE INTERNAL "")
	set ( ${PROJECT_NAME}_INSTALL_LIB_PATH ${${PROJECT_NAME}_DEPLOY_PATH}/lib CACHE INTERNAL "")
	set ( ${PROJECT_NAME}_INSTALL_AR_PATH ${${PROJECT_NAME}_DEPLOY_PATH}/lib CACHE INTERNAL "")
	set ( ${PROJECT_NAME}_INSTALL_HEADERS_PATH ${${PROJECT_NAME}_DEPLOY_PATH}/include CACHE INTERNAL "")
	set ( ${PROJECT_NAME}_INSTALL_SHARE_PATH ${${PROJECT_NAME}_DEPLOY_PATH}/share CACHE INTERNAL "")
	set ( ${PROJECT_NAME}_INSTALL_SCRIPT_PATH ${${PROJECT_NAME}_INSTALL_SHARE_PATH}/script CACHE INTERNAL "")
	set ( ${PROJECT_NAME}_INSTALL_BIN_PATH ${${PROJECT_NAME}_DEPLOY_PATH}/bin CACHE INTERNAL "")
	set ( ${PROJECT_NAME}_INSTALL_RPATH_DIR ${${PROJECT_NAME}_DEPLOY_PATH}/.rpath CACHE INTERNAL "")
	set ( ${PROJECT_NAME}_ROOT_DIR ${PACKAGE_BINARY_INSTALL_DIR}/${PROJECT_NAME}/${${PROJECT_NAME}_DEPLOY_PATH} CACHE INTERNAL "")
endfunction(set_Install_Cache_Variables)

### setting cache variable for versionning
function(set_Version_Cache_Variables major minor patch)
	set (${PROJECT_NAME}_VERSION_MAJOR ${major} CACHE INTERNAL "")
	set (${PROJECT_NAME}_VERSION_MINOR ${minor} CACHE INTERNAL "")
	set (${PROJECT_NAME}_VERSION_PATCH ${patch} CACHE INTERNAL "")
	set (${PROJECT_NAME}_VERSION ${${PROJECT_NAME}_VERSION_MAJOR}.${${PROJECT_NAME}_VERSION_MINOR}.${${PROJECT_NAME}_VERSION_PATCH} CACHE INTERNAL "")
endfunction(set_Version_Cache_Variables)


function(reset_Version_Cache_Variables)
#resetting general info about the package : only list are reset
set (${PROJECT_NAME}_VERSION_MAJOR CACHE INTERNAL "" )
set (${PROJECT_NAME}_VERSION_MINOR CACHE INTERNAL "" )
set (${PROJECT_NAME}_VERSION_PATCH CACHE INTERNAL "" )
set (${PROJECT_NAME}_VERSION CACHE INTERNAL "" )
endfunction(reset_Version_Cache_Variables)

### define a set of configuration constraints that applies to all platforms with specific condition specified by type arch os and abi
function(add_Platform_Constraint_Set type arch os abi constraints)
	if(${PROJECT_NAME}_ALL_PLATFORMS_CONSTRAINTS${USE_MODE_SUFFIX})
		set(CURRENT_INDEX ${${PROJECT_NAME}_ALL_PLATFORMS_CONSTRAINTS${USE_MODE_SUFFIX}}) #current index is the current number of all constraint sets
	else()
		set(CURRENT_INDEX 0) #current index is the current number of all constraint sets
	endif()
	set(${PROJECT_NAME}_PLATFORM_CONSTRAINT_${CURRENT_INDEX}_CONDITION_TYPE${USE_MODE_SUFFIX} ${type} CACHE INTERNAL "")
	set(${PROJECT_NAME}_PLATFORM_CONSTRAINT_${CURRENT_INDEX}_CONDITION_ARCH${USE_MODE_SUFFIX} ${arch} CACHE INTERNAL "")
	set(${PROJECT_NAME}_PLATFORM_CONSTRAINT_${CURRENT_INDEX}_CONDITION_OS${USE_MODE_SUFFIX} ${os} CACHE INTERNAL "")
	set(${PROJECT_NAME}_PLATFORM_CONSTRAINT_${CURRENT_INDEX}_CONDITION_ABI${USE_MODE_SUFFIX} ${abi} CACHE INTERNAL "")
	# the configuration constraint is written here and applies as soon as all conditions are satisfied
	set(${PROJECT_NAME}_PLATFORM_CONSTRAINT_${CURRENT_INDEX}_CONFIGURATION${USE_MODE_SUFFIX} ${constraints} CACHE INTERNAL "")

	math(EXPR NEW_SET_SIZE "${CURRENT_INDEX}+1")
	set(${PROJECT_NAME}_ALL_PLATFORMS_CONSTRAINTS${USE_MODE_SUFFIX} ${NEW_SET_SIZE} CACHE INTERNAL "")
endfunction(add_Platform_Constraint_Set)

### add a set of configuration constraints that are satisfied by the current platform
function(add_Configuration_To_Platform constraints)
	list(APPEND ${PROJECT_NAME}_PLATFORM_CONFIGURATIONS${USE_MODE_SUFFIX} ${constraints})
	list(REMOVE_DUPLICATES ${PROJECT_NAME}_PLATFORM_CONFIGURATIONS${USE_MODE_SUFFIX})
	set(${PROJECT_NAME}_PLATFORM_CONFIGURATIONS${USE_MODE_SUFFIX} ${${PROJECT_NAME}_PLATFORM_CONFIGURATIONS${USE_MODE_SUFFIX}} CACHE INTERNAL "") #to put the new value in cache
endfunction(add_Configuration_To_Platform)

#############################################################################################
############### API functions for setting components related cache variables ################
#############################################################################################

### to know wehether a package has something to build
function(package_Has_Nothing_To_Build NOTHING_BUILT)
	foreach(comp IN LISTS ${PROJECT_NAME}_COMPONENTS)
		will_be_Built(RES ${comp})
		if(RES)
			set(${NOTHING_BUILT} FALSE PARENT_SCOPE)
			return()
		endif()
	endforeach()
	set(${NOTHING_BUILT} TRUE PARENT_SCOPE)
endfunction(package_Has_Nothing_To_Build)

### to know whether a package has something to install
function(package_Has_Nothing_To_Install NOTHING_INSTALLED)
	if(${PROJECT_NAME}_COMPONENTS)
		foreach(comp IN LISTS ${PROJECT_NAME}_COMPONENTS)
			will_be_Installed(RES ${comp})
			if(RES)
				set(${NOTHING_INSTALLED} FALSE PARENT_SCOPE)
				return()
			endif()
		endforeach()
	endif()
	set(${NOTHING_INSTALLED} TRUE PARENT_SCOPE)
endfunction(package_Has_Nothing_To_Install)


### to know wehether a module is a python wrapped module
function(is_Python_Module IS_PYTHON package component)
	if(${package}_${component}_TYPE STREQUAL "MODULE")
		set(${IS_PYTHON} ${${package}_${component}_HAS_PYTHON_WRAPPER} PARENT_SCOPE)
	else()
		set(${IS_PYTHON} FALSE PARENT_SCOPE)
	endif()
endfunction(is_Python_Module)



### configure variables exported by component that will be used to generate the package cmake use file
function (configure_Install_Variables component export include_dirs dep_defs exported_defs exported_options static_links shared_links c_standard cxx_standard runtime_resources)

# configuring the export
if(export) # if dependancy library is exported then we need to register its dep_defs and include dirs in addition to component interface defs
	if(	NOT dep_defs STREQUAL ""
		OR NOT exported_defs  STREQUAL "")
		set(${PROJECT_NAME}_${component}_DEFS${USE_MODE_SUFFIX}
			${${PROJECT_NAME}_${component}_DEFS${USE_MODE_SUFFIX}}
			${exported_defs} ${dep_defs}
			CACHE INTERNAL "")
	endif()
	if(NOT include_dirs STREQUAL "")
		set(	${PROJECT_NAME}_${component}_INC_DIRS${USE_MODE_SUFFIX}
			${${PROJECT_NAME}_${component}_INC_DIRS${USE_MODE_SUFFIX}}
			${include_dirs}
			CACHE INTERNAL "")
	endif()
	if(NOT exported_options STREQUAL "")
		set(	${PROJECT_NAME}_${component}_OPTS${USE_MODE_SUFFIX}
			${${PROJECT_NAME}_${component}_OPTS${USE_MODE_SUFFIX}}
			${exported_options}
			CACHE INTERNAL "")
	endif()

	# links are exported since we will need to resolve symbols in the third party components that will the use the component
	if(NOT shared_links STREQUAL "")
		set(	${PROJECT_NAME}_${component}_LINKS${USE_MODE_SUFFIX}
			${${PROJECT_NAME}_${component}_LINKS${USE_MODE_SUFFIX}}
			${shared_links}
			CACHE INTERNAL "")
	endif()
	if(NOT static_links STREQUAL "")
		set(	${PROJECT_NAME}_${component}_LINKS${USE_MODE_SUFFIX}
			${${PROJECT_NAME}_${component}_LINKS${USE_MODE_SUFFIX}}
			${static_links}
			CACHE INTERNAL "")
	endif()

else() # otherwise no need to register them since no more useful
	if(NOT exported_defs STREQUAL "")
		#just add the exported defs of the component not those of the dependency
		set(	${PROJECT_NAME}_${component}_DEFS${USE_MODE_SUFFIX}
			${${PROJECT_NAME}_${component}_DEFS${USE_MODE_SUFFIX}}
			${exported_defs}
			CACHE INTERNAL "")
	endif()
	if(NOT static_links STREQUAL "") #static links are exported if component is not a shared or module lib (otherwise they simply disappear)
		if (	${PROJECT_NAME}_${component}_TYPE STREQUAL "HEADER"
			OR ${PROJECT_NAME}_${component}_TYPE STREQUAL "STATIC"
		)
		set(	${PROJECT_NAME}_${component}_LINKS${USE_MODE_SUFFIX}
			${${PROJECT_NAME}_${component}_LINKS${USE_MODE_SUFFIX}}
			${static_links}
			CACHE INTERNAL "")
		endif()
	endif()
	if(NOT shared_links STREQUAL "")#private links are shared "non exported" libraries -> these links are used to process executables linking
		set(	${PROJECT_NAME}_${component}_PRIVATE_LINKS${USE_MODE_SUFFIX}
			${${PROJECT_NAME}_${component}_PRIVATE_LINKS${USE_MODE_SUFFIX}}
			${shared_links}
			CACHE INTERNAL "")
	endif()
endif()

is_C_Version_Less(IS_LESS "${${PROJECT_NAME}_${component}_C_STANDARD${USE_MODE_SUFFIX}}" "${c_standard}")
if(IS_LESS)
	set(${PROJECT_NAME}_${component}_C_STANDARD${USE_MODE_SUFFIX} ${c_standard} CACHE INTERNAL "")
endif()

is_CXX_Version_Less(IS_LESS "${${PROJECT_NAME}_${component}_CXX_STANDARD${USE_MODE_SUFFIX}}" "${cxx_standard}")
if(IS_LESS)
	set(${PROJECT_NAME}_${component}_CXX_STANDARD${USE_MODE_SUFFIX} ${cxx_standard} CACHE INTERNAL "")
endif()

if(NOT runtime_resources STREQUAL "")#runtime resources are exported in any case
	set(	${PROJECT_NAME}_${component}_RUNTIME_RESOURCES
		${${PROJECT_NAME}_${component}_RUNTIME_RESOURCES}
		${runtime_resources}
		CACHE INTERNAL "")
endif()
endfunction(configure_Install_Variables)


### test if a native or external package is a dependency of the current package
function(is_Package_Dependency IS_DEPENDENCY dep_package)
set(${IS_DEPENDENCY} FALSE PARENT_SCOPE)
if(${PROJECT_NAME}_DEPENDENCIES${USE_MODE_SUFFIX})#there are dependencies to sreach in
	list(FIND ${PROJECT_NAME}_DEPENDENCIES${USE_MODE_SUFFIX} ${dep_package} INDEX)
	if(NOT INDEX EQUAL -1) #package found in dependencies
		set(${IS_DEPENDENCY} TRUE PARENT_SCOPE)
		return()
	endif()
endif()
if(${PROJECT_NAME}_EXTERNAL_DEPENDENCIES${USE_MODE_SUFFIX})#there are external dependencies to sreach in
	list(FIND ${PROJECT_NAME}_EXTERNAL_DEPENDENCIES${USE_MODE_SUFFIX} ${dep_package} INDEX)
	if(NOT INDEX EQUAL -1)#package found in dependencies
		set(${IS_DEPENDENCY} TRUE PARENT_SCOPE)
		return()
	endif()
endif()
endfunction(is_Package_Dependency)

### set cached variable for packages dependency
function(add_Package_Dependency_To_Cache dep_package version exact list_of_components)
	set(${PROJECT_NAME}_DEPENDENCIES${USE_MODE_SUFFIX} ${${PROJECT_NAME}_DEPENDENCIES${USE_MODE_SUFFIX}} ${dep_package} CACHE INTERNAL "")
	set(${PROJECT_NAME}_DEPENDENCY_${dep_package}_COMPONENTS${USE_MODE_SUFFIX} ${${PROJECT_NAME}_DEPENDENCY_${dep_package}_COMPONENTS${USE_MODE_SUFFIX}} ${list_of_components} CACHE INTERNAL "")
	list(REMOVE_DUPLICATES ${PROJECT_NAME}_DEPENDENCIES${USE_MODE_SUFFIX})
	list(REMOVE_DUPLICATES ${PROJECT_NAME}_DEPENDENCY_${dep_package}_COMPONENTS${USE_MODE_SUFFIX})
	set(${PROJECT_NAME}_DEPENDENCY_${dep_package}_VERSION${USE_MODE_SUFFIX} ${version} CACHE INTERNAL "")
	set(${PROJECT_NAME}_DEPENDENCY_${dep_package}_VERSION_EXACT${USE_MODE_SUFFIX} ${exact} CACHE INTERNAL "")#false by definition since no version constraint
endfunction(add_Package_Dependency_To_Cache)

### set cached variable for external packages dependency
function(add_External_Package_Dependency_To_Cache dep_package version exact list_of_components)
	set(${PROJECT_NAME}_EXTERNAL_DEPENDENCIES${USE_MODE_SUFFIX} ${${PROJECT_NAME}_EXTERNAL_DEPENDENCIES${USE_MODE_SUFFIX}} ${dep_package} CACHE INTERNAL "")
	set(${PROJECT_NAME}_EXTERNAL_DEPENDENCY_${dep_package}_COMPONENTS${USE_MODE_SUFFIX} ${${PROJECT_NAME}_EXTERNAL_DEPENDENCY_${dep_package}_COMPONENTS${USE_MODE_SUFFIX}} ${list_of_components} CACHE INTERNAL "")
	list(REMOVE_DUPLICATES ${PROJECT_NAME}_EXTERNAL_DEPENDENCIES${USE_MODE_SUFFIX})
	list(REMOVE_DUPLICATES ${PROJECT_NAME}_EXTERNAL_DEPENDENCY_${dep_package}_COMPONENTS${USE_MODE_SUFFIX})
	set(${PROJECT_NAME}_EXTERNAL_DEPENDENCY_${dep_package}_VERSION${USE_MODE_SUFFIX} ${version} CACHE INTERNAL "")
	set(${PROJECT_NAME}_EXTERNAL_DEPENDENCY_${dep_package}_VERSION_EXACT${USE_MODE_SUFFIX} ${exact} CACHE INTERNAL "")#false by definition since no version constraint
endfunction(add_External_Package_Dependency_To_Cache)

### reset components related cached variables
function(reset_Component_Cached_Variables component)

# resetting package dependencies
foreach(a_dep_pack IN LISTS ${PROJECT_NAME}_${component}_DEPENDENCIES${USE_MODE_SUFFIX})
	foreach(a_dep_comp IN LISTS ${PROJECT_NAME}_${component}_DEPENDENCY_${a_dep_pack}_COMPONENTS${USE_MODE_SUFFIX})
		set(${PROJECT_NAME}_${component}_EXPORT_${a_dep_pack}_${a_dep_comp}${USE_MODE_SUFFIX} CACHE INTERNAL "")
	endforeach()
	set(${PROJECT_NAME}_${component}_DEPENDENCY_${a_dep_pack}_COMPONENTS${USE_MODE_SUFFIX}  CACHE INTERNAL "")
endforeach()
set(${PROJECT_NAME}_${component}_DEPENDENCIES${USE_MODE_SUFFIX}  CACHE INTERNAL "")

# resetting internal dependencies
foreach(a_internal_dep_comp IN LISTS ${PROJECT_NAME}_${component}_INTERNAL_DEPENDENCIES${USE_MODE_SUFFIX})
	set(${PROJECT_NAME}_${component}_INTERNAL_EXPORT_${a_internal_dep_comp}${USE_MODE_SUFFIX} CACHE INTERNAL "")
endforeach()
set(${PROJECT_NAME}_${component}_INTERNAL_DEPENDENCIES${USE_MODE_SUFFIX} CACHE INTERNAL "")

#resetting all other variables
set(${PROJECT_NAME}_${component}_HEADER_DIR_NAME CACHE INTERNAL "")
set(${PROJECT_NAME}_${component}_HEADERS CACHE INTERNAL "")
set(${PROJECT_NAME}_${component}_C_STANDARD CACHE INTERNAL "")
set(${PROJECT_NAME}_${component}_CXX_STANDARD CACHE INTERNAL "")
set(${PROJECT_NAME}_${component}_BINARY_NAME${USE_MODE_SUFFIX} CACHE INTERNAL "")
set(${PROJECT_NAME}_${component}_DEFS${USE_MODE_SUFFIX} CACHE INTERNAL "")
set(${PROJECT_NAME}_${component}_OPTS${USE_MODE_SUFFIX} CACHE INTERNAL "")
set(${PROJECT_NAME}_${component}_LINKS${USE_MODE_SUFFIX} CACHE INTERNAL "")
set(${PROJECT_NAME}_${component}_PRIVATE_LINKS${USE_MODE_SUFFIX} CACHE INTERNAL "")
set(${PROJECT_NAME}_${component}_INC_DIRS${USE_MODE_SUFFIX} CACHE INTERNAL "")
set(${PROJECT_NAME}_${component}_SOURCE_CODE CACHE INTERNAL "")
set(${PROJECT_NAME}_${component}_SOURCE_DIR CACHE INTERNAL "")
set(${PROJECT_NAME}_${component}_RUNTIME_RESOURCES${USE_MODE_SUFFIX} CACHE INTERNAL "")
set(${PROJECT_NAME}_${component}_DESCRIPTION CACHE INTERNAL "")
set(${PROJECT_NAME}_${component}_USAGE_INCLUDES CACHE INTERNAL "")
endfunction(reset_Component_Cached_Variables)

function(init_Component_Cached_Variables_For_Export component c_standard cxx_standard exported_defs exported_options exported_links runtime_resources)
set(${PROJECT_NAME}_${component}_DEFS${USE_MODE_SUFFIX} "${exported_defs}" CACHE INTERNAL "") #exported defs
set(${PROJECT_NAME}_${component}_LINKS${USE_MODE_SUFFIX} "${exported_links}" CACHE INTERNAL "") #exported links
set(${PROJECT_NAME}_${component}_INC_DIRS${USE_MODE_SUFFIX} "" CACHE INTERNAL "") #exported include directories (not useful to set it there since they will be exported "manually")
set(${PROJECT_NAME}_${component}_OPTS${USE_MODE_SUFFIX} "${exported_options}" CACHE INTERNAL "") #exported compiler options
set(${PROJECT_NAME}_${component}_RUNTIME_RESOURCES${USE_MODE_SUFFIX} "${runtime_resources}" CACHE INTERNAL "")#runtime resources are exported by default
set(${PROJECT_NAME}_${component}_C_STANDARD${USE_MODE_SUFFIX} "${c_standard}" CACHE INTERNAL "")#minimum C standard of the component interface
set(${PROJECT_NAME}_${component}_CXX_STANDARD${USE_MODE_SUFFIX} "${cxx_standard}" CACHE INTERNAL "")#minimum C++ standard of the component interface
endfunction(init_Component_Cached_Variables_For_Export)

### resetting all internal cached variables that would cause some troubles
function(reset_Package_Description_Cached_Variables)
	# package dependencies declaration must be reinitialized otherwise some problem (uncoherent dependancy versions) would appear
	foreach(dep_package IN LISTS ${PROJECT_NAME}_DEPENDENCIES${USE_MODE_SUFFIX})
		set(${PROJECT_NAME}_DEPENDENCY_${dep_package}_COMPONENTS${USE_MODE_SUFFIX} CACHE INTERNAL "")
		set(${PROJECT_NAME}_DEPENDENCY_${dep_package}_VERSION${USE_MODE_SUFFIX} CACHE INTERNAL "")
		set(${PROJECT_NAME}_DEPENDENCY_${dep_package}_${${PROJECT_NAME}_DEPENDENCY_${dep_package}_VERSION${USE_MODE_SUFFIX}}_EXACT${USE_MODE_SUFFIX} CACHE INTERNAL "")
	endforeach()
	set(${PROJECT_NAME}_DEPENDENCIES${USE_MODE_SUFFIX} CACHE INTERNAL "")

	# external package dependencies declaration must be reinitialized
	foreach(dep_package IN LISTS ${PROJECT_NAME}_EXTERNAL_DEPENDENCIES${USE_MODE_SUFFIX})
		set(${PROJECT_NAME}_EXTERNAL_DEPENDENCY_${dep_package}_COMPONENTS${USE_MODE_SUFFIX} CACHE INTERNAL "")
		set(${PROJECT_NAME}_EXTERNAL_DEPENDENCY_${dep_package}_VERSION${USE_MODE_SUFFIX} CACHE INTERNAL "")
		set(${PROJECT_NAME}_EXTERNAL_DEPENDENCY_${dep_package}_VERSION_EXACT${USE_MODE_SUFFIX} CACHE INTERNAL "")
	endforeach()
	set(${PROJECT_NAME}_EXTERNAL_DEPENDENCIES${USE_MODE_SUFFIX} CACHE INTERNAL "")

	# component declaration must be reinitialized otherwise some problem (redundancy of declarations) would appear
	foreach(a_component IN LISTS ${PROJECT_NAME}_COMPONENTS)
		reset_Component_Cached_Variables(${a_component})
	endforeach()
	reset_Declared()
	set(${PROJECT_NAME}_COMPONENTS CACHE INTERNAL "")
	set(${PROJECT_NAME}_COMPONENTS_LIBS CACHE INTERNAL "")
	set(${PROJECT_NAME}_COMPONENTS_APPS CACHE INTERNAL "")
	set(${PROJECT_NAME}_COMPONENTS_SCRIPTS CACHE INTERNAL "")
endfunction(reset_Package_Description_Cached_Variables)

###
function(init_Component_Description component description usage)
generate_Formatted_String("${description}" RES_STRING)
set(${PROJECT_NAME}_${component}_DESCRIPTION "${RES_STRING}" CACHE INTERNAL "")
set(${PROJECT_NAME}_${component}_USAGE_INCLUDES "${usage}" CACHE INTERNAL "")
endfunction(init_Component_Description)

###
function(mark_As_Declared component)
set(${PROJECT_NAME}_DECLARED_COMPS ${${PROJECT_NAME}_DECLARED_COMPS} ${component} CACHE INTERNAL "")
endfunction(mark_As_Declared)

###
function(is_Declared component RES)
list(FIND ${PROJECT_NAME}_DECLARED_COMPS ${component} INDEX)
if(INDEX EQUAL -1)
	set(${RES} FALSE PARENT_SCOPE)
else()
	set(${RES} TRUE PARENT_SCOPE)
endif()

endfunction(is_Declared)


###
function(is_Library_Type RES keyword)
	if(keyword STREQUAL "HEADER"
		OR keyword STREQUAL "STATIC"
		OR keyword STREQUAL "SHARED"
		OR keyword STREQUAL "MODULE")
		set(${RES} TRUE PARENT_SCOPE)
	else()
		set(${RES} FALSE PARENT_SCOPE)
	endif()
endfunction(is_Library_Type)

###
function(is_Application_Type RES keyword)
	if(	keyword STREQUAL "TEST"
		OR keyword STREQUAL "APP"
		OR keyword STREQUAL "EXAMPLE")
		set(${RES} TRUE PARENT_SCOPE)
	else()
		set(${RES} FALSE PARENT_SCOPE)
	endif()
endfunction(is_Application_Type)

###
function(reset_Declared)
set(${PROJECT_NAME}_DECLARED_COMPS CACHE INTERNAL "")
endfunction(reset_Declared)

function(export_Component IS_EXPORTING package component dep_package dep_component mode)
is_HeaderFree_Component(IS_HF ${package} ${component})
if(IS_HF)
	set(${IS_EXPORTING} FALSE PARENT_SCOPE)
	return()
endif()
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})

if(package STREQUAL "${dep_package}")
	if(${package}_${component}_INTERNAL_EXPORT_${dep_component}${VAR_SUFFIX})
		set(${IS_EXPORTING} TRUE PARENT_SCOPE)
	else()
		set(${IS_EXPORTING} FALSE PARENT_SCOPE)
	endif()
else()
	if(${package}_${component}_EXPORT_${dep_package}_${dep_component}${VAR_SUFFIX})
		set(${IS_EXPORTING} TRUE PARENT_SCOPE)
	else()
		set(${IS_EXPORTING} FALSE PARENT_SCOPE)
	endif()

endif()

endfunction(export_Component)

### to know if the component is an application
function(is_HeaderFree_Component ret_var package component)
if (	${package}_${component}_TYPE STREQUAL "APP"
	OR ${package}_${component}_TYPE STREQUAL "EXAMPLE"
	OR ${package}_${component}_TYPE STREQUAL "TEST"
	OR ${package}_${component}_TYPE STREQUAL "MODULE"
	OR ${package}_${component}_TYPE STREQUAL "PYTHON"
	)
	set(${ret_var} TRUE PARENT_SCOPE)
else()
	set(${ret_var} FALSE PARENT_SCOPE)
endif()
endfunction(is_HeaderFree_Component)


### to know if the component is an application
function(is_Runtime_Component ret_var package component)
if (	${package}_${component}_TYPE STREQUAL "APP"
	OR ${package}_${component}_TYPE STREQUAL "EXAMPLE"
	OR ${package}_${component}_TYPE STREQUAL "TEST"
	OR ${package}_${component}_TYPE STREQUAL "SHARED"
	OR ${package}_${component}_TYPE STREQUAL "MODULE"
	)
	set(${ret_var} TRUE PARENT_SCOPE)
else()
	set(${ret_var} FALSE PARENT_SCOPE)
endif()
endfunction(is_Runtime_Component)

### to know if the component is an application
function(is_Executable_Component ret_var package component)
if (	${package}_${component}_TYPE STREQUAL "APP"
	OR ${package}_${component}_TYPE STREQUAL "EXAMPLE"
	OR ${package}_${component}_TYPE STREQUAL "TEST"
	)
	set(${ret_var} TRUE PARENT_SCOPE)
else()
	set(${ret_var} FALSE PARENT_SCOPE)
endif()
endfunction(is_Executable_Component)

### to know if component will be built
function (is_Built_Component ret_var  package component)
if (	${package}_${component}_TYPE STREQUAL "APP"
	OR ${package}_${component}_TYPE STREQUAL "EXAMPLE"
	OR ${package}_${component}_TYPE STREQUAL "TEST"
	OR ${package}_${component}_TYPE STREQUAL "STATIC"
	OR ${package}_${component}_TYPE STREQUAL "SHARED"
	OR ${package}_${component}_TYPE STREQUAL "MODULE"
)
	set(${ret_var} TRUE PARENT_SCOPE)
else()
	set(${ret_var} FALSE PARENT_SCOPE)#scripts and headers libraries are not built
endif()
endfunction(is_Built_Component)

function(build_Option_For_Example example_comp)
CMAKE_DEPENDENT_OPTION(BUILD_EXAMPLE_${example_comp} "Package build the example application ${example_comp}" ON "BUILD_EXAMPLES" ON)
endfunction(build_Option_For_Example)

function(reset_Removed_Examples_Build_Option)
get_cmake_property(ALL_CACHED_VARIABLES CACHE_VARIABLES) #getting all cache variables
foreach(a_cache_var ${ALL_CACHED_VARIABLES})
	string(REGEX REPLACE "^BUILD_EXAMPLE_(.*)$" "\\1" EXAMPLE_NAME ${a_cache_var})

	if(NOT EXAMPLE_NAME STREQUAL "${a_cache_var}")#match => this is an option related to an example !!
		set(DECLARED FALSE)
		is_Declared(${EXAMPLE_NAME} DECLARED)
		if(NOT DECLARED)# corresponding example component has not been declared
			unset(${a_cache_var} CACHE)#remove option from cache
		endif()
	endif()
endforeach()
endfunction(reset_Removed_Examples_Build_Option)

###
function(will_be_Built result component)
if((${PROJECT_NAME}_${component}_TYPE STREQUAL "SCRIPT") #python scripts are never built
	OR (${PROJECT_NAME}_${component}_TYPE STREQUAL "TEST" AND NOT BUILD_AND_RUN_TESTS)
	OR (${PROJECT_NAME}_${component}_TYPE STREQUAL "EXAMPLE" AND (NOT BUILD_EXAMPLES OR NOT BUILD_EXAMPLE_${component})))
	set(${result} FALSE PARENT_SCOPE)
	return()
else()
	if(${PROJECT_NAME}_${component}_TYPE STREQUAL "MODULE")### to know wehether a module is a python wrapped module and is really compilable
		contains_Python_Code(HAS_WRAPPER ${CMAKE_SOURCE_DIR}/src/${${PROJECT_NAME}_${component}_SOURCE_DIR})
		if(HAS_WRAPPER AND NOT CURRENT_PYTHON)#wthe module will not be built as there is no python configuration
			set(${result} FALSE PARENT_SCOPE)
			return()
		endif()
	endif()
	set(${result} TRUE PARENT_SCOPE)
endif()
endfunction(will_be_Built)

###
function(will_be_Installed result component)
if( (${PROJECT_NAME}_${component}_TYPE STREQUAL "TEST")
	OR (${PROJECT_NAME}_${component}_TYPE STREQUAL "EXAMPLE" AND (NOT BUILD_EXAMPLES OR NOT BUILD_EXAMPLE_${component})))
	set(${result} FALSE PARENT_SCOPE)
else()
	if(${PROJECT_NAME}_${component}_TYPE STREQUAL "MODULE")### to know wehether a module is a python wrapped module and is really compilable
		contains_Python_Code(HAS_WRAPPER ${CMAKE_SOURCE_DIR}/src/${${PROJECT_NAME}_${component}_SOURCE_DIR})
		if(HAS_WRAPPER AND NOT CURRENT_PYTHON)#wthe module will not be installed as there is no python configuration
			set(${result} FALSE PARENT_SCOPE)
			return()
		endif()
	endif()
	set(${result} TRUE PARENT_SCOPE)
endif()
endfunction(will_be_Installed)

###
function(is_Externally_Usable result component)
if( (${PROJECT_NAME}_${component}_TYPE STREQUAL "TEST")
	OR (${PROJECT_NAME}_${component}_TYPE STREQUAL "EXAMPLE"))
	set(${result} FALSE PARENT_SCOPE)
else()
	set(${result} TRUE PARENT_SCOPE)
endif()
endfunction(is_Externally_Usable)


### registering the binary name of a component
function(register_Component_Binary c_name)
	set(${PROJECT_NAME}_${c_name}_BINARY_NAME${USE_MODE_SUFFIX} "$<TARGET_FILE_NAME:${c_name}${INSTALL_NAME_SUFFIX}>" CACHE INTERNAL "")
endfunction(register_Component_Binary)

#resolving dependencies
function(is_Bin_Component_Exporting_Other_Components RESULT package component mode)
set(${RESULT} FALSE PARENT_SCOPE)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})

#scanning external dependencies
if(${package}_${component}_LINKS${VAR_SUFFIX}) #only exported links here
	set(${RESULT} TRUE PARENT_SCOPE)
	return()
endif()

# scanning internal dependencies
foreach(int_dep IN LISTS ${package}_${component}_INTERNAL_DEPENDENCIES${VAR_SUFFIX})
	if(${package}_${component}_INTERNAL_EXPORT_${int_dep}${VAR_SUFFIX})
		set(${RESULT} TRUE PARENT_SCOPE)
		return()
	endif()
endforeach()

# scanning package dependencies
foreach(dep_pack IN LISTS ${package}_${component}_DEPENDENCIES${VAR_SUFFIX})
	foreach(ext_dep IN LISTS ${package}_${component}_DEPENDENCY_${dep_pack}_COMPONENTS${VAR_SUFFIX})
		if(${package}_${component}_EXPORT_${dep_pack}_${ext_dep}${VAR_SUFFIX})
			set(${RESULT} TRUE PARENT_SCOPE)
			return()
		endif()
	endforeach()
endforeach()
endfunction(is_Bin_Component_Exporting_Other_Components)


##################################################################################
############################## install the dependancies ##########################
########### functions used to create the use<package><version>.cmake  ############
##################################################################################
function(write_Use_File file package build_mode)
set(MODE_SUFFIX "")
if(${build_mode} MATCHES Release) #mode independent info written only once in the release mode
	file(APPEND ${file} "######### declaration of package meta info that can be usefull for other packages ########\n")
	file(APPEND ${file} "set(${package}_LICENSE ${${package}_LICENSE} CACHE INTERNAL \"\")\n")
	file(APPEND ${file} "set(${package}_ADDRESS ${${package}_ADDRESS} CACHE INTERNAL \"\")\n")
	file(APPEND ${file} "set(${package}_PUBLIC_ADDRESS ${${package}_PUBLIC_ADDRESS} CACHE INTERNAL \"\")\n")
	file(APPEND ${file} "set(${package}_CATEGORIES ${${package}_CATEGORIES} CACHE INTERNAL \"\")\n")

	file(APPEND ${file} "######### declaration of package web site info ########\n")
	file(APPEND ${file} "set(${package}_FRAMEWORK ${${package}_FRAMEWORK} CACHE INTERNAL \"\")\n")
	file(APPEND ${file} "set(${package}_PROJECT_PAGE ${${package}_PROJECT_PAGE} CACHE INTERNAL \"\")\n")
	file(APPEND ${file} "set(${package}_SITE_ROOT_PAGE ${${package}_SITE_ROOT_PAGE} CACHE INTERNAL \"\")\n")
	file(APPEND ${file} "set(${package}_SITE_GIT_ADDRESS ${${package}_SITE_GIT_ADDRESS} CACHE INTERNAL \"\")\n")
	file(APPEND ${file} "set(${package}_SITE_INTRODUCTION ${${package}_SITE_INTRODUCTION} CACHE INTERNAL \"\")\n")

	file(APPEND ${file} "######### declaration of package development info ########\n")
	get_Repository_Current_Branch(RES_BRANCH ${WORKSPACE_DIR}/packages/${package})
	if(NOT RES_BRANCH OR RES_BRANCH STREQUAL "master")#not on a development branch
		file(APPEND ${file} "set(${package}_DEVELOPMENT_STATE release CACHE INTERNAL \"\")\n")
	else()
		file(APPEND ${file} "set(${package}_DEVELOPMENT_STATE development CACHE INTERNAL \"\")\n")
	endif()


	file(APPEND ${file} "######### declaration of package components ########\n")
	file(APPEND ${file} "set(${package}_COMPONENTS ${${package}_COMPONENTS} CACHE INTERNAL \"\")\n")
	file(APPEND ${file} "set(${package}_COMPONENTS_APPS ${${package}_COMPONENTS_APPS} CACHE INTERNAL \"\")\n")
	file(APPEND ${file} "set(${package}_COMPONENTS_LIBS ${${package}_COMPONENTS_LIBS} CACHE INTERNAL \"\")\n")
	file(APPEND ${file} "set(${package}_COMPONENTS_SCRIPTS ${${package}_COMPONENTS_SCRIPTS} CACHE INTERNAL \"\")\n")

	file(APPEND ${file} "####### internal specs of package components #######\n")
	foreach(a_component IN LISTS ${package}_COMPONENTS_LIBS)
		file(APPEND ${file} "set(${package}_${a_component}_TYPE ${${package}_${a_component}_TYPE} CACHE INTERNAL \"\")\n")
		if(NOT ${package}_${a_component}_TYPE STREQUAL "MODULE")#modules do not have public interfaces
			file(APPEND ${file} "set(${package}_${a_component}_HEADER_DIR_NAME ${${package}_${a_component}_HEADER_DIR_NAME} CACHE INTERNAL \"\")\n")
			file(APPEND ${file} "set(${package}_${a_component}_HEADERS ${${package}_${a_component}_HEADERS} CACHE INTERNAL \"\")\n")
		endif()
	endforeach()
	foreach(a_component IN LISTS ${package}_COMPONENTS_APPS)
		file(APPEND ${file} "set(${package}_${a_component}_TYPE ${${package}_${a_component}_TYPE} CACHE INTERNAL \"\")\n")
	endforeach()
	foreach(a_component IN LISTS ${package}_COMPONENTS_SCRIPTS)
		file(APPEND ${file} "set(${package}_${a_component}_TYPE ${${package}_${a_component}_TYPE} CACHE INTERNAL \"\")\n")
	endforeach()
else()
	set(MODE_SUFFIX _DEBUG)
endif()

get_System_Variables(CURRENT_PLATFORM_NAME CURRENT_PACKAGE_STRING)
#mode dependent info written adequately depending on the mode
# 0) platforms configuration constraints
file(APPEND ${file} "#### declaration of platform dependencies in ${CMAKE_BUILD_TYPE} mode ####\n")
file(APPEND ${file} "set(${package}_PLATFORM${MODE_SUFFIX} ${CURRENT_PLATFORM_NAME} CACHE INTERNAL \"\")\n") # not really usefull since a use file is bound to a given platform, but may be usefull for debug
file(APPEND ${file} "set(${package}_PLATFORM_CONFIGURATIONS${MODE_SUFFIX} ${${package}_PLATFORM_CONFIGURATIONS${MODE_SUFFIX}} CACHE INTERNAL \"\")\n")

# 1) external package dependencies
file(APPEND ${file} "#### declaration of external package dependencies in ${CMAKE_BUILD_TYPE} mode ####\n")
file(APPEND ${file} "set(${package}_EXTERNAL_DEPENDENCIES${MODE_SUFFIX} ${${package}_EXTERNAL_DEPENDENCIES${MODE_SUFFIX}} CACHE INTERNAL \"\")\n")

foreach(a_ext_dep IN LISTS ${package}_EXTERNAL_DEPENDENCIES${MODE_SUFFIX})
	file(APPEND ${file} "set(${package}_EXTERNAL_DEPENDENCY_${a_ext_dep}_VERSION${MODE_SUFFIX} ${${package}_EXTERNAL_DEPENDENCY_${a_ext_dep}_VERSION${MODE_SUFFIX}} CACHE INTERNAL \"\")\n")
	if(${package}_EXTERNAL_DEPENDENCY_${a_ext_dep}_VERSION_EXACT${MODE_SUFFIX})
		file(APPEND ${file} "set(${package}_EXTERNAL_DEPENDENCY_${a_ext_dep}_VERSION_EXACT${MODE_SUFFIX} TRUE CACHE INTERNAL \"\")\n")
	else()
		file(APPEND ${file} "set(${package}_EXTERNAL_DEPENDENCY_${a_ext_dep}_VERSION_EXACT${MODE_SUFFIX} FALSE CACHE INTERNAL \"\")\n")
	endif()
	file(APPEND ${file} "set(${package}_EXTERNAL_DEPENDENCY_${a_ext_dep}_COMPONENTS${MODE_SUFFIX} ${${package}_EXTERNAL_DEPENDENCY_${a_ext_dep}_COMPONENTS${MODE_SUFFIX}} CACHE INTERNAL \"\")\n")
endforeach()

# 2) native package dependencies
file(APPEND ${file} "#### declaration of package dependencies in ${CMAKE_BUILD_TYPE} mode ####\n")
file(APPEND ${file} "set(${package}_DEPENDENCIES${MODE_SUFFIX} ${${package}_DEPENDENCIES${MODE_SUFFIX}} CACHE INTERNAL \"\")\n")
foreach(a_dep IN LISTS ${package}_DEPENDENCIES${MODE_SUFFIX})
	file(APPEND ${file} "set(${package}_DEPENDENCY_${a_dep}_VERSION${MODE_SUFFIX} ${${package}_DEPENDENCY_${a_dep}_VERSION${MODE_SUFFIX}} CACHE INTERNAL \"\")\n")
	if(${package}_DEPENDENCY_${a_dep}_VERSION_EXACT${MODE_SUFFIX})
		file(APPEND ${file} "set(${package}_DEPENDENCY_${a_dep}_VERSION_EXACT${MODE_SUFFIX} TRUE CACHE INTERNAL \"\")\n")
	else()
		file(APPEND ${file} "set(${package}_DEPENDENCY_${a_dep}_VERSION_EXACT${MODE_SUFFIX} FALSE CACHE INTERNAL \"\")\n")
	endif()
	file(APPEND ${file} "set(${package}_DEPENDENCY_${a_dep}_COMPONENTS${MODE_SUFFIX} ${${package}_DEPENDENCY_${a_dep}_COMPONENTS${MODE_SUFFIX}} CACHE INTERNAL \"\")\n")
endforeach()

# 3) internal+external components specifications
file(APPEND ${file} "#### declaration of components exported flags and binary in ${CMAKE_BUILD_TYPE} mode ####\n")
foreach(a_component IN LISTS ${package}_COMPONENTS)
	is_Built_Component(IS_BUILT_COMP ${package} ${a_component})
	is_HeaderFree_Component(IS_HF_COMP ${package} ${a_component})
	if(IS_BUILT_COMP)#if not a pure header library
		file(APPEND ${file} "set(${package}_${a_component}_BINARY_NAME${MODE_SUFFIX} ${${package}_${a_component}_BINARY_NAME${MODE_SUFFIX}} CACHE INTERNAL \"\")\n")
	endif()
	if(NOT IS_HF_COMP)#it is a library but not a module library
		file(APPEND ${file} "set(${package}_${a_component}_INC_DIRS${MODE_SUFFIX} ${${package}_${a_component}_INC_DIRS${MODE_SUFFIX}} CACHE INTERNAL \"\")\n")
		file(APPEND ${file} "set(${package}_${a_component}_OPTS${MODE_SUFFIX} ${${package}_${a_component}_OPTS${MODE_SUFFIX}} CACHE INTERNAL \"\")\n")
		file(APPEND ${file} "set(${package}_${a_component}_DEFS${MODE_SUFFIX} ${${package}_${a_component}_DEFS${MODE_SUFFIX}} CACHE INTERNAL \"\")\n")
		file(APPEND ${file} "set(${package}_${a_component}_LINKS${MODE_SUFFIX} ${${package}_${a_component}_LINKS${MODE_SUFFIX}} CACHE INTERNAL \"\")\n")
		file(APPEND ${file} "set(${package}_${a_component}_PRIVATE_LINKS${MODE_SUFFIX} ${${package}_${a_component}_PRIVATE_LINKS${MODE_SUFFIX}} CACHE INTERNAL \"\")\n")
		file(APPEND ${file} "set(${package}_${a_component}_C_STANDARD${MODE_SUFFIX} ${${package}_${a_component}_C_STANDARD${MODE_SUFFIX}} CACHE INTERNAL \"\")\n")
		file(APPEND ${file} "set(${package}_${a_component}_CXX_STANDARD${MODE_SUFFIX} ${${package}_${a_component}_CXX_STANDARD${MODE_SUFFIX}} CACHE INTERNAL \"\")\n")
	endif()
	file(APPEND ${file} "set(${package}_${a_component}_RUNTIME_RESOURCES${MODE_SUFFIX} ${${package}_${a_component}_RUNTIME_RESOURCES${MODE_SUFFIX}} CACHE INTERNAL \"\")\n")
endforeach()

# 4) package internal component dependencies
file(APPEND ${file} "#### declaration package internal component dependencies in ${CMAKE_BUILD_TYPE} mode ####\n")
foreach(a_component IN LISTS ${package}_COMPONENTS)
	if(${package}_${a_component}_INTERNAL_DEPENDENCIES${MODE_SUFFIX}) # the component has internal dependencies
		file(APPEND ${file} "set(${package}_${a_component}_INTERNAL_DEPENDENCIES${MODE_SUFFIX} ${${package}_${a_component}_INTERNAL_DEPENDENCIES${MODE_SUFFIX}} CACHE INTERNAL \"\")\n")
		foreach(a_int_dep IN LISTS ${package}_${a_component}_INTERNAL_DEPENDENCIES${MODE_SUFFIX})
			if(${package}_${a_component}_INTERNAL_EXPORT_${a_int_dep}${MODE_SUFFIX})
				file(APPEND ${file} "set(${package}_${a_component}_INTERNAL_EXPORT_${a_int_dep}${MODE_SUFFIX} TRUE CACHE INTERNAL \"\")\n")
			else()
				file(APPEND ${file} "set(${package}_${a_component}_INTERNAL_EXPORT_${a_int_dep}${MODE_SUFFIX} FALSE CACHE INTERNAL \"\")\n")
			endif()
		endforeach()
	endif()
endforeach()

# 5) component dependencies
file(APPEND ${file} "#### declaration of component dependencies in ${CMAKE_BUILD_TYPE} mode ####\n")
foreach(a_component IN LISTS ${package}_COMPONENTS)
	if(${package}_${a_component}_DEPENDENCIES${MODE_SUFFIX}) # the component has package dependencies
		file(APPEND ${file} "set(${package}_${a_component}_DEPENDENCIES${MODE_SUFFIX} ${${package}_${a_component}_DEPENDENCIES${MODE_SUFFIX}} CACHE INTERNAL \"\")\n")
		foreach(dep_package IN LISTS ${package}_${a_component}_DEPENDENCIES${MODE_SUFFIX})
			file(APPEND ${file} "set(${package}_${a_component}_DEPENDENCY_${dep_package}_COMPONENTS${MODE_SUFFIX} ${${package}_${a_component}_DEPENDENCY_${dep_package}_COMPONENTS${MODE_SUFFIX}} CACHE INTERNAL \"\")\n")
			foreach(dep_component IN LISTS ${package}_${a_component}_DEPENDENCY_${dep_package}_COMPONENTS${MODE_SUFFIX})
				if(${package}_${a_component}_EXPORT_${dep_package}_${dep_component})
					file(APPEND ${file} "set(${package}_${a_component}_EXPORT_${dep_package}_${dep_component}${MODE_SUFFIX} TRUE CACHE INTERNAL \"\")\n")
				else()
					file(APPEND ${file} "set(${package}_${a_component}_EXPORT_${dep_package}_${dep_component}${MODE_SUFFIX} FALSE CACHE INTERNAL \"\")\n")
				endif()
			endforeach()
		endforeach()
	endif()
endforeach()
endfunction(write_Use_File)

function(create_Use_File)
if(${CMAKE_BUILD_TYPE} MATCHES Release) #mode independent info written only once in the release mode
	set(file ${CMAKE_BINARY_DIR}/share/UseReleaseTemp)
else()
	set(file ${CMAKE_BINARY_DIR}/share/UseDebugTemp)
endif()

#resetting the file content
file(WRITE ${file} "")
write_Use_File(${file} ${PROJECT_NAME} ${CMAKE_BUILD_TYPE})

#finalizing release mode by agregating info from the debug mode
if(${CMAKE_BUILD_TYPE} MATCHES Release) #mode independent info written only once in the release mode
	if(EXISTS ${CMAKE_BINARY_DIR}/../debug/share/UseDebugGen) #checking that the debug generated file exists
		file(READ ${CMAKE_BINARY_DIR}/../debug/share/UseDebugGen DEBUG_CONTENT)
		file(APPEND ${file} "${DEBUG_CONTENT}")
	endif()
	#removing debug files
	file(REMOVE ${CMAKE_BINARY_DIR}/../debug/share/UseDebugGen)
	file(REMOVE ${CMAKE_BINARY_DIR}/../debug/share/UseDebugTemp)
	file (GENERATE OUTPUT ${CMAKE_BINARY_DIR}/share/Use${PROJECT_NAME}-${${PROJECT_NAME}_VERSION}.cmake INPUT ${file})
else() #this step is required to generate info containing generator expression
	file (GENERATE OUTPUT ${CMAKE_BINARY_DIR}/share/UseDebugGen INPUT ${file})
endif()
endfunction(create_Use_File)

###############################################################################################
############################## providing info on the package content ##########################
###############################################################################################

#################### function used to create the Info<package>.cmake  #########################
function(generate_Info_File)
if(${CMAKE_BUILD_TYPE} MATCHES Release) #mode independent info written only once in the release mode
	set(file ${CMAKE_BINARY_DIR}/share/Info${PROJECT_NAME}.cmake)
	file(WRITE ${file} "")#resetting the file content
	file(APPEND ${file} "######### declaration of package components ########\n")
	file(APPEND ${file} "set(${PROJECT_NAME}_COMPONENTS ${${PROJECT_NAME}_COMPONENTS} CACHE INTERNAL \"\")\n")
	foreach(a_component IN LISTS ${PROJECT_NAME}_COMPONENTS)
		file(APPEND ${file} "######### content of package component ${a_component} ########\n")
		file(APPEND ${file} "set(${PROJECT_NAME}_${a_component}_TYPE ${${PROJECT_NAME}_${a_component}_TYPE} CACHE INTERNAL \"\")\n")
		if(${PROJECT_NAME}_${a_component}_SOURCE_DIR)
			file(APPEND ${file} "set(${PROJECT_NAME}_${a_component}_SOURCE_DIR ${${PROJECT_NAME}_${a_component}_SOURCE_DIR} CACHE INTERNAL \"\")\n")
			file(APPEND ${file} "set(${PROJECT_NAME}_${a_component}_SOURCE_CODE ${${PROJECT_NAME}_${a_component}_SOURCE_CODE} CACHE INTERNAL \"\")\n")
		endif()
		if(${PROJECT_NAME}_${a_component}_HEADER_DIR_NAME)
			file(APPEND ${file} "set(${PROJECT_NAME}_${a_component}_HEADER_DIR_NAME ${${PROJECT_NAME}_${a_component}_HEADER_DIR_NAME} CACHE INTERNAL \"\")\n")
			file(APPEND ${file} "set(${PROJECT_NAME}_${a_component}_HEADERS ${${PROJECT_NAME}_${a_component}_HEADERS} CACHE INTERNAL \"\")\n")

		endif()
	endforeach()
endif()

endfunction(generate_Info_File)


############ function used to create the  Find<package>.cmake file of the package  ###########
function(generate_Find_File)
if(${CMAKE_BUILD_TYPE} MATCHES Release)
	# generating/installing the generic cmake find file for the package
	configure_file(${WORKSPACE_DIR}/share/patterns/packages/FindPackage.cmake.in ${CMAKE_BINARY_DIR}/share/Find${PROJECT_NAME}.cmake @ONLY)
	install(FILES ${CMAKE_BINARY_DIR}/share/Find${PROJECT_NAME}.cmake DESTINATION ${WORKSPACE_DIR}/share/cmake/find) #install in the worskpace cmake directory which contains cmake find modules
endif()
endfunction(generate_Find_File)

############ function used to create the Use<package>-<version>.cmake file of the package  ###########
macro(generate_Use_File)
create_Use_File()
if(${CMAKE_BUILD_TYPE} MATCHES Release)
	install(	FILES ${CMAKE_BINARY_DIR}/share/Use${PROJECT_NAME}-${${PROJECT_NAME}_VERSION}.cmake
			DESTINATION ${${PROJECT_NAME}_INSTALL_SHARE_PATH}
	)
endif()
endmacro(generate_Use_File)

############################################################################################
############ function used to create the Dep<package>.cmake file of the package  ###########
############################################################################################

## subsidiary function to write the description of native dependencies of a given package in the dependencies description file
function(current_Native_Dependencies_For_Package package depfile PACKAGES_ALREADY_MANAGED PACKAGES_NEWLY_MANAGED)
get_Mode_Variables(TARGET_SUFFIX MODE_SUFFIX ${CMAKE_BUILD_TYPE})
#information on package to register
file(APPEND ${depfile} "set(CURRENT_NATIVE_DEPENDENCY_${package}_VERSION${MODE_SUFFIX} ${${package}_VERSION_STRING} CACHE INTERNAL \"\")\n")
file(APPEND ${depfile} "set(CURRENT_NATIVE_DEPENDENCY_${package}_ALL_VERSION${MODE_SUFFIX} ${${package}_ALL_REQUIRED_VERSIONS} CACHE INTERNAL \"\")\n")
file(APPEND ${depfile} "set(CURRENT_NATIVE_DEPENDENCY_${package}_EXTERNAL_DEPENDENCIES${MODE_SUFFIX} ${${package}_EXTERNAL_DEPENDENCIES${MODE_SUFFIX}} CACHE INTERNAL \"\")\n")
file(APPEND ${depfile} "set(CURRENT_NATIVE_DEPENDENCY_${package}_DEPENDENCIES${MODE_SUFFIX} ${${package}_DEPENDENCIES${MODE_SUFFIX}} CACHE INTERNAL \"\")\n")

#registering platform configuration info coming from the dependency
file(APPEND ${depfile} "set(CURRENT_NATIVE_DEPENDENCY_${package}_PLATFORM_CONFIGURATIONS${MODE_SUFFIX} ${${package}_PLATFORM_CONFIGURATIONS${MODE_SUFFIX}} CACHE INTERNAL \"\")\n")

#call on external dependencies
set(ALREADY_MANAGED ${PACKAGES_ALREADY_MANAGED} ${package})
set(NEWLY_MANAGED ${package})

foreach(a_used_package IN LISTS ${package}_EXTERNAL_DEPENDENCIES${MODE_SUFFIX})
	list(FIND ALREADY_MANAGED ${a_used_package} INDEX)
	if(INDEX EQUAL -1) #not managed yet
		current_External_Dependencies_For_Package(${a_used_package} ${depfile} NEW_LIST)
		list(APPEND ALREADY_MANAGED ${NEW_LIST})
		list(APPEND NEWLY_MANAGED ${NEW_LIST})
	endif()
endforeach()

#recursion on native dependencies
foreach(a_used_package IN LISTS ${package}_DEPENDENCIES${MODE_SUFFIX})
	list(FIND ALREADY_MANAGED ${a_used_package} INDEX)
	if(INDEX EQUAL -1) #not managed yet
		current_Native_Dependencies_For_Package(${a_used_package} ${depfile} "${ALREADY_MANAGED}" NEW_LIST)
		list(APPEND ALREADY_MANAGED ${NEW_LIST})
		list(APPEND NEWLY_MANAGED ${NEW_LIST})
	endif()
endforeach()

set(${PACKAGES_NEWLY_MANAGED} ${NEWLY_MANAGED} PARENT_SCOPE)
endfunction(current_Native_Dependencies_For_Package)

## subsidiary function to write the description of external dependencies of a given package in the dependencies description file
function(current_External_Dependencies_For_Package package depfile PACKAGES_NEWLY_MANAGED)
get_Mode_Variables(TARGET_SUFFIX MODE_SUFFIX ${CMAKE_BUILD_TYPE})
#information on package to register
file(APPEND ${depfile} "set(CURRENT_EXTERNAL_DEPENDENCY_${package}_VERSION${MODE_SUFFIX} ${${package}_VERSION_STRING} CACHE INTERNAL \"\")\n")
file(APPEND ${depfile} "set(CURRENT_EXTERNAL_DEPENDENCY_${package}_ALL_VERSION${MODE_SUFFIX} ${${package}_ALL_REQUIRED_VERSIONS} CACHE INTERNAL \"\")\n")

# platform configuration info for external libraries
file(APPEND ${depfile} "set(CURRENT_EXTERNAL_DEPENDENCY_${package}_PLATFORM_CONFIGURATIONS${MODE_SUFFIX} ${${package}_PLATFORM_CONFIGURATIONS${MODE_SUFFIX}} CACHE INTERNAL \"\")\n")

set(NEWLY_MANAGED ${package})
set(${PACKAGES_NEWLY_MANAGED} ${NEWLY_MANAGED} PARENT_SCOPE)
endfunction(current_External_Dependencies_For_Package)


### generate the dependencies description file
macro(generate_Dependencies_File)
get_System_Variables(CURRENT_PLATFORM_NAME CURRENT_PACKAGE_STRING)
get_Mode_Variables(TARGET_SUFFIX MODE_SUFFIX ${CMAKE_BUILD_TYPE})
set(file ${CMAKE_BINARY_DIR}/share/Dep${PROJECT_NAME}.cmake)
file(WRITE ${file} "")
############# FIRST PART : statically declared dependencies ################

# 1) platforms
file(APPEND ${file} "set(TARGET_PLATFORM ${CURRENT_PLATFORM_NAME} CACHE INTERNAL \"\")\n")
file(APPEND ${file} "set(TARGET_PLATFORM_TYPE ${CURRENT_PLATFORM_TYPE} CACHE INTERNAL \"\")\n")
file(APPEND ${file} "set(TARGET_PLATFORM_ARCH ${CURRENT_PLATFORM_ARCH} CACHE INTERNAL \"\")\n")
file(APPEND ${file} "set(TARGET_PLATFORM_OS ${CURRENT_PLATFORM_OS} CACHE INTERNAL \"\")\n")
file(APPEND ${file} "set(TARGET_PLATFORM_ABI ${CURRENT_PLATFORM_ABI} CACHE INTERNAL \"\")\n")
file(APPEND ${file} "set(TARGET_PLATFORM_CONFIGURATIONS${MODE_SUFFIX} ${${PROJECT_NAME}_PLATFORM_CONFIGURATIONS${MODE_SUFFIX}} CACHE INTERNAL \"\")\n")

# 2) external packages
file(APPEND ${file} "#### declaration of external package dependencies in ${CMAKE_BUILD_TYPE} mode ####\n")
file(APPEND ${file} "set(TARGET_EXTERNAL_DEPENDENCIES${MODE_SUFFIX} ${${PROJECT_NAME}_EXTERNAL_DEPENDENCIES${MODE_SUFFIX}} CACHE INTERNAL \"\")\n")

if(${PROJECT_NAME}_EXTERNAL_DEPENDENCIES${MODE_SUFFIX})
	foreach(a_ext_dep IN LISTS ${PROJECT_NAME}_EXTERNAL_DEPENDENCIES${MODE_SUFFIX})
		file(APPEND ${file} "set(TARGET_EXTERNAL_DEPENDENCY_${a_ext_dep}_VERSION${MODE_SUFFIX} ${${PROJECT_NAME}_EXTERNAL_DEPENDENCY_${a_ext_dep}_VERSION${MODE_SUFFIX}} CACHE INTERNAL \"\")\n")
		if(${PROJECT_NAME}_EXTERNAL_DEPENDENCY_${a_ext_dep}_VERSION_EXACT${MODE_SUFFIX})
			file(APPEND ${file} "set(TARGET_EXTERNAL_DEPENDENCY_${a_ext_dep}_VERSION_EXACT${MODE_SUFFIX} TRUE CACHE INTERNAL \"\")\n")
		else()
			file(APPEND ${file} "set(TARGET_EXTERNAL_DEPENDENCY_${a_ext_dep}_VERSION_EXACT${MODE_SUFFIX} FALSE CACHE INTERNAL \"\")\n")
		endif()
	endforeach()
endif()

# 3) native package dependencies
file(APPEND ${file} "#### declaration of package dependencies in ${CMAKE_BUILD_TYPE} mode ####\n")
file(APPEND ${file} "set(TARGET_NATIVE_DEPENDENCIES${MODE_SUFFIX} ${${PROJECT_NAME}_DEPENDENCIES${MODE_SUFFIX}} CACHE INTERNAL \"\")\n")
if(${PROJECT_NAME}_DEPENDENCIES${MODE_SUFFIX})
	foreach(a_dep IN LISTS ${PROJECT_NAME}_DEPENDENCIES${MODE_SUFFIX})
		file(APPEND ${file} "set(TARGET_NATIVE_DEPENDENCY_${a_dep}_VERSION${MODE_SUFFIX} ${${PROJECT_NAME}_DEPENDENCY_${a_dep}_VERSION${MODE_SUFFIX}} CACHE INTERNAL \"\")\n")
		if(${PROJECT_NAME}_DEPENDENCY_${a_dep}_VERSION_EXACT${MODE_SUFFIX})
			file(APPEND ${file} "set(TARGET_NATIVE_DEPENDENCY_${a_dep}_VERSION_EXACT${MODE_SUFFIX} TRUE CACHE INTERNAL \"\")\n")
		else()
			file(APPEND ${file} "set(TARGET_NATIVE_DEPENDENCY_${a_dep}_VERSION_EXACT${MODE_SUFFIX} FALSE CACHE INTERNAL \"\")\n")
		endif()
	endforeach()
endif()


set(NEWLY_MANAGED)
set(ALREADY_MANAGED)
############# SECOND PART : dynamically found dependencies according to current workspace content ################

#external dependencies
file(APPEND ${file} "set(CURRENT_EXTERNAL_DEPENDENCIES${MODE_SUFFIX} ${${PROJECT_NAME}_ALL_USED_EXTERNAL_PACKAGES} CACHE INTERNAL \"\")\n")
if(${PROJECT_NAME}_ALL_USED_EXTERNAL_PACKAGES)
	foreach(a_used_package IN LISTS ${PROJECT_NAME}_ALL_USED_EXTERNAL_PACKAGES)
		current_External_Dependencies_For_Package(${a_used_package} ${file} NEWLY_MANAGED)
		list(APPEND ALREADY_MANAGED ${NEWLY_MANAGED})
	endforeach()
endif()

#native dependencies

file(APPEND ${file} "set(CURRENT_NATIVE_DEPENDENCIES${MODE_SUFFIX} ${${PROJECT_NAME}_ALL_USED_PACKAGES} CACHE INTERNAL \"\")\n")
if(${PROJECT_NAME}_ALL_USED_PACKAGES)
	foreach(a_used_package IN LISTS ${PROJECT_NAME}_ALL_USED_PACKAGES)
		list(FIND ALREADY_MANAGED ${a_used_package} INDEX)
		if(INDEX EQUAL -1) #not managed yet
			current_Native_Dependencies_For_Package(${a_used_package} ${file} "${ALREADY_MANAGED}" NEWLY_MANAGED)
			list(APPEND ALREADY_MANAGED ${NEWLY_MANAGED})
		endif()
	endforeach()
endif()

endmacro(generate_Dependencies_File)
