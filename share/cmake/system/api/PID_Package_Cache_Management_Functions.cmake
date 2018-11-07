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
############### API functions for managing user options cache variables #####################
#############################################################################################
include(CMakeDependentOption)

#.rst:
#
# .. ifmode:: internal
#
#  .. |declare_Native_Global_Cache_Options| replace:: ``declare_Native_Global_Cache_Options``
#  .. _declare_Native_Global_Cache_Options:
#
#  declare_Native_Global_Cache_Options
#  -----------------------------------
#
#   .. command:: declare_Native_Global_Cache_Options()
#
#   Define the generic PID Cmake options that can be set by the user.
#
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

#.rst:
#
# .. ifmode:: internal
#
#  .. |manage_Parrallel_Build_Option| replace:: ``manage_Parrallel_Build_Option``
#  .. _manage_Parrallel_Build_Option:
#
#  manage_Parrallel_Build_Option
#  -----------------------------
#
#   .. command:: manage_Parrallel_Build_Option()
#
#   Set the cache variable that defines the generator flags to use when doing parallel build.
#
macro(manage_Parrallel_Build_Option)
### parallel builds management
if(ENABLE_PARALLEL_BUILD)
	include(ProcessorCount)
	ProcessorCount(NUMBER_OF_JOBS)
	math(EXPR NUMBER_OF_JOBS "${NUMBER_OF_JOBS}+1")
	if(${NUMBER_OF_JOBS} GREATER 1)
		set(PARALLEL_JOBS_FLAG "-j${NUMBER_OF_JOBS}" CACHE INTERNAL "")
	endif()
else()
	set(PARALLEL_JOBS_FLAG CACHE INTERNAL "")
endif()
endmacro(manage_Parrallel_Build_Option)

#.rst:
#
# .. ifmode:: internal
#
#  .. |set_Mode_Specific_Options_From_Global| replace:: ``set_Mode_Specific_Options_From_Global``
#  .. _set_Mode_Specific_Options_From_Global:
#
#  set_Mode_Specific_Options_From_Global
#  -------------------------------------
#
#   .. command:: set_Mode_Specific_Options_From_Global()
#
#   Generate the cache file containing build options from cache of the current project global cache.
#
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
				string(REGEX REPLACE "^([^:]+):([^=]+)=(.*)$" "set( \\1 \"\\3\"\ CACHE \\2 \"\" FORCE)\n" AN_OPTION "${line}")
				file(APPEND ${OPTIONS_FILE} ${AN_OPTION})
			endif()
		endforeach()
	else() # only populating the load cache script with default PID cache variables to transmit them to release/debug mode caches
		file(APPEND ${OPTIONS_FILE} "set(WORKSPACE_DIR \"${WORKSPACE_DIR}\" CACHE PATH \"\" FORCE)\n")
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


#.rst:
#
# .. ifmode:: internal
#
#  .. |get_Option_Line_Info| replace:: ``get_Option_Line_Info``
#  .. _get_Option_Line_Info:
#
#  get_Option_Line_Info
#  --------------------
#
#   .. command:: get_Option_Line_Info(NAME TYPE VALUE COMMENT line)
#
#   Extracting information from a line contained in a CMake cache file.
#
#     :line: string taht contains a given line from a cache file.
#
#     :NAME: output variable that contains the name of the option if any in the line, empty otherwise.
#
#     :TYPE: output variable that contains the type of the option if any in the line, empty otherwise.
#
#     :VALUE: output variable that contains the value of the option if any in the line, empty otherwise.
#
#     :COMMENT: output variable that contains the comment if any in the line, empty otherwise.
#
function(get_Option_Line_Info NAME TYPE VALUE COMMENT line)
  set(${NAME} PARENT_SCOPE)
  set(${TYPE} PARENT_SCOPE)
  set(${VALUE} PARENT_SCOPE)
  set(${COMMENT} PARENT_SCOPE)
  if(line AND (NOT line STREQUAL "-- Cache values"))#this line may contain option info
    string(REGEX REPLACE "^//(.*)$" "\\1" COMMENT_LINE ${line})
    if(line STREQUAL "${COMMENT_LINE}") #no match => this NOT a comment =>  is an option line
      string(REGEX REPLACE "^([^:]+):([^=]+)=(.*)$" "\\1;\\2;\\3" AN_OPTION "${line}") #indexes 0: name, 1:type, 2: value
      list(GET AN_OPTION 0 var_name)
      list(GET AN_OPTION 1 var_type)
      list(GET AN_OPTION 2 var_value)
      set(${NAME} ${var_name} PARENT_SCOPE)
      set(${TYPE} ${var_type} PARENT_SCOPE)
      set(${VALUE} ${var_value} PARENT_SCOPE)
    else()#match is OK => this is a comment line
      set(${COMMENT} "${COMMENT_LINE}" PARENT_SCOPE)
    endif()
  endif()#if first line simply do nothing (because no information)
endfunction(get_Option_Line_Info)

#.rst:
#
# .. ifmode:: internal
#
#  .. |find_Option_Into_List| replace:: ``find_Option_Into_List``
#  .. _find_Option_Into_List:
#
#  find_Option_Into_List
#  ---------------------
#
#   .. command:: find_Option_Into_List(INDEX option_name option_type list_name)
#
#   Finding the given CMake cache option from a list of cache file lines.
#
#     :option_name: the name of the cmake cache option to find.
#
#     :option_type: the type of the cmake cache option to find (STRING, PATH, INTERNAL, BOOL).
#
#     :list_name: the name of the list where finding lines from a cache file.
#
#     :INDEX: output variable that contains the index of the line that matches in number of characters, -1 if not found.
#
function(find_Option_Into_List INDEX option_name option_type list_name)
  string(FIND "${${list_name}}" "${option_name}:${option_type}=" POS)
  set(${INDEX} ${POS} PARENT_SCOPE)
endfunction(find_Option_Into_List)

#.rst:
#
# .. ifmode:: internal
#
#  .. |get_Option_Value_From_List| replace:: ``get_Option_Value_From_List``
#  .. _get_Option_Value_From_List:
#
#  get_Option_Value_From_List
#  --------------------------
#
#   .. command:: get_Option_Value_From_List(VALUE option_name option_type list_name)
#
#   Getting the value of an option from a list of cache file lines.
#
#     :option_name: the name of the cmake cache option to get value from.
#
#     :option_type: the type of the cmake cache option to get value from (STRING, PATH, INTERNAL, BOOL).
#
#     :list_name: the name of the list where finding lines from a cache file.
#
#     :VALUE: output variable that contains the value of the cache option (may be empty if option has no value or does not exist).
#
function(get_Option_Value_From_List VALUE option_name option_type list_name)
  set(${VALUE} PARENT_SCOPE)
  foreach(line IN LISTS ${list_name})#value of list name is a list in enclosing scope
    if(line AND (NOT line STREQUAL "-- Cache values"))#this line may contain option info
      string(REGEX REPLACE "^${option_name}:${option_type}=(.*)$" "\\1" AN_OPTION_VAL "${line}")
      if(NOT (line STREQUAL "${AN_OPTION_VAL}"))#MATCH => the option has been found
        set(${VALUE} ${AN_OPTION_VAL} PARENT_SCOPE)
      endif()
    endif()
  endforeach()
endfunction(get_Option_Value_From_List)

#.rst:
#
# .. ifmode:: internal
#
#  .. |set_Global_Options_From_Mode_Specific| replace:: ``set_Global_Options_From_Mode_Specific``
#  .. _set_Global_Options_From_Mode_Specific:
#
#  set_Global_Options_From_Mode_Specific
#  -------------------------------------
#
#   .. command:: set_Global_Options_From_Mode_Specific()
#
#   Force the build options of the global build mode from cache of the current specific build mode (Release or Debug). Use to update global cache options related to the specific build mode in order to keep consistency of cache at global level.
#
function(set_Global_Options_From_Mode_Specific)
	# GOAL: copying new cache entries in the global build cache
  #first get cache entries from debug and release mode
  execute_process(COMMAND ${CMAKE_COMMAND} -LH -N WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/debug OUTPUT_FILE ${CMAKE_BINARY_DIR}/optionsDEBUG.txt)
  execute_process(COMMAND ${CMAKE_COMMAND} -LH -N WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/release OUTPUT_FILE ${CMAKE_BINARY_DIR}/optionsRELEASE.txt)
	file(STRINGS ${CMAKE_BINARY_DIR}/options.txt LINES_GLOBAL)
	file(STRINGS ${CMAKE_BINARY_DIR}/optionsDEBUG.txt LINES_DEBUG)
	file(STRINGS ${CMAKE_BINARY_DIR}/optionsRELEASE.txt LINES_RELEASE)
  # searching new cache entries in release mode cache
	foreach(line IN LISTS LINES_RELEASE)
    get_Option_Line_Info(OPT_NAME OPT_TYPE OPT_VALUE OPT_COMMENT "${line}")
    if(OPT_COMMENT)#the line contains a comment, simply memorize it (will be used for immediate next option)
      set(last_comment "${OPT_COMMENT}")
    elseif(OPT_NAME AND OPT_TYPE)#the line contains an option
      find_Option_Into_List(INDEX ${OPT_NAME} ${OPT_TYPE} LINES_GLOBAL)#search for same option in global cache
      if(INDEX EQUAL -1)#not found in global cache => this a new cache entry coming from mode specific build
        set(${OPT_NAME} ${OPT_VALUE} CACHE ${OPT_TYPE} "${last_comment}")#value may be empty
      elseif(BUILD_RELEASE_ONLY)
        set(${OPT_NAME} ${OPT_VALUE} CACHE ${OPT_TYPE} "${last_comment}" FORCE)#value may be empty
      endif()
    endif()
	endforeach()
  set(last_comment "")

  # searching new cache entries in debug mode cache
  foreach(line IN LISTS LINES_DEBUG)
    get_Option_Line_Info(OPT_NAME OPT_TYPE OPT_VALUE OPT_COMMENT "${line}")
    if(OPT_COMMENT)#the line contains a comment, simply memorize it (will be used for immediate next option)
      set(last_comment "${OPT_COMMENT}")
    elseif(OPT_NAME AND OPT_TYPE)#the line contains an option
      find_Option_Into_List(INDEX_GLOB ${OPT_NAME} ${OPT_TYPE} LINES_GLOBAL)#search for same option in global cache
      find_Option_Into_List(INDEX_REL ${OPT_NAME} ${OPT_TYPE} LINES_RELEASE)#search for same option in global cache
      if(INDEX_GLOB EQUAL -1 AND INDEX_REL EQUAL -1)#not found in global and release caches
        set(${OPT_NAME} ${OPT_VALUE} CACHE ${OPT_TYPE} "${last_comment}")#add it to global cache
      elseif((NOT POS_REL EQUAL -1) AND (NOT POS EQUAL -1))#found in both global and release caches
        #1) check if release and debug have same value
        set(debug_value ${OPT_VALUE})
        get_Option_Value_From_List(release_value ${OPT_NAME} ${OPT_TYPE} LINES_RELEASE)
        if(debug_value STREQUAL release_value) #debug and release have same value
          #1) if their value differ from global one then apply it
          get_Option_Value_From_List(global_value ${OPT_NAME} ${OPT_TYPE} LINES_GLOBAL)
          if(NOT (release_value STREQUAL global_value))#their value is different from value of same global option => need to update
            set(${OPT_NAME} ${release_value} CACHE ${OPT_TYPE} "${last_comment}" FORCE)#add it to global cache
          endif()
        #else debug and release mode variables differ (rare case, except for CMAKE_BUILD_TYPE)
        #simply do nothing : DO NOT remove otherwise at next configuration time it will be added with the value of a mode
        endif()
      endif()
    endif()
	endforeach()
  set(last_comment "")

  # searching removed cache entries in release and debug mode caches => then remove them from global cache
	foreach(line IN LISTS LINES_GLOBAL)
    get_Option_Line_Info(OPT_NAME OPT_TYPE OPT_VALUE OPT_COMMENT "${line}")
    if(OPT_NAME AND OPT_TYPE)#the line contains an option
      if(NOT BUILD_RELEASE_ONLY)
        set(INDEX_DEBUG -1)
        find_Option_Into_List(INDEX_DEBUG ${OPT_NAME} ${OPT_TYPE} LINES_DEBUG)#search for same option in global cache
      endif()
      find_Option_Into_List(INDEX_REL ${OPT_NAME} ${OPT_TYPE} LINES_RELEASE)#search for same option in global cache
      if(INDEX_DEBUG EQUAL -1 AND INDEX_REL EQUAL -1)#not found in debug and release caches
        unset(${OPT_NAME} CACHE) #the option ${OPT_NAME} does not belong to release or debug, simply remove it from global cache
      endif()
    endif()
	endforeach()

	#removing temporary files containing cache entries
	execute_process(COMMAND ${CMAKE_COMMAND} -E remove -f ${CMAKE_BINARY_DIR}/optionsDEBUG.txt)
	execute_process(COMMAND ${CMAKE_COMMAND} -E remove -f ${CMAKE_BINARY_DIR}/optionsRELEASE.txt)
	execute_process(COMMAND ${CMAKE_COMMAND} -E remove -f ${CMAKE_BINARY_DIR}/options.txt)
endfunction(set_Global_Options_From_Mode_Specific)

#.rst:
#
# .. ifmode:: internal
#
#  .. |reset_Mode_Cache_Options| replace:: ``reset_Mode_Cache_Options``
#  .. _reset_Mode_Cache_Options:
#
#  reset_Mode_Cache_Options
#  ------------------------
#
#   .. command:: reset_Mode_Cache_Options(CACHE_POPULATED)
#
#   Force the reset of the current specific build mode (Release or Debug) cache with content coming from the global cache.
#
#     :CACHE_POPULATED: output variable that is TRUE if cache of the current specific build mode has been reset with values coming from the global cache.
#
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

#.rst:
#
# .. ifmode:: internal
#
#  .. |first_Called_Build_Mode| replace:: ``first_Called_Build_Mode``
#  .. _first_Called_Build_Mode:
#
#  first_Called_Build_Mode
#  -----------------------
#
#   .. command:: first_Called_Build_Mode(RESULT)
#
#   Tells whether the current specific build mode is the first one called during global build process (depends on CMake options chosen by the user).
#
#     :RESULT: output variable that is TRUE if current specific build mode is the first to execute.
#
function(first_Called_Build_Mode RESULT)
set(${RESULT} FALSE PARENT_SCOPE)
if(CMAKE_BUILD_TYPE MATCHES Debug OR (CMAKE_BUILD_TYPE MATCHES Release AND BUILD_RELEASE_ONLY))
	set(${RESULT} TRUE PARENT_SCOPE)
endif()
endfunction(first_Called_Build_Mode)

############################################################################
############### API functions for setting global package info ##############
############################################################################

#.rst:
#
# .. ifmode:: internal
#
#  .. |print_Component| replace:: ``print_Component``
#  .. _print_Component:
#
#  print_Component
#  ----------------
#
#   .. command:: print_Component(component)
#
#   Print the  variables for the target of a given component in the currenlty defined package.
#
#     :component: the name of the component to print.
#
macro(print_Component component)
	if(NOT ${PROJECT_NAME}_${component}_TYPE STREQUAL "PYTHON")
		message("COMPONENT : ${component}${INSTALL_NAME_SUFFIX}")
		message("INTERFACE : ")
		get_target_property(RES_VAR ${component}${INSTALL_NAME_SUFFIX} INTERFACE_INCLUDE_DIRECTORIES)
		message("includes of ${component}${INSTALL_NAME_SUFFIX} = ${RES_VAR}")
		get_target_property(RES_VAR ${component}${INSTALL_NAME_SUFFIX} INTERFACE_COMPILE_DEFINITIONS)
		message("defs of ${component}${INSTALL_NAME_SUFFIX} = ${RES_VAR}")
		get_target_property(RES_VAR ${component}${INSTALL_NAME_SUFFIX} INTERFACE_LINK_LIBRARIES)
		message("libraries of ${component}${INSTALL_NAME_SUFFIX} = ${RES_VAR}")

		if(NOT ${PROJECT_NAME}_${component}_TYPE STREQUAL "HEADER")
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

#.rst:
#
# .. ifmode:: internal
#
#  .. |print_Component_Variables| replace:: ``print_Component_Variables``
#  .. _print_Component_Variables:
#
#  print_Component_Variables
#  -------------------------
#
#   .. command:: print_Component_Variables()
#
#   Print target related variables for all components of the currenlty defined package.
#
macro(print_Component_Variables)
	message("components of package ${PROJECT_NAME} are :" ${${PROJECT_NAME}_COMPONENTS})
	message("libraries : " ${${PROJECT_NAME}_COMPONENTS_LIBS})
	message("applications : " ${${PROJECT_NAME}_COMPONENTS_APPS})
	message("applications : " ${${PROJECT_NAME}_COMPONENTS_SCRIPTS})

	foreach(component IN LISTS ${PROJECT_NAME}_COMPONENTS)
		print_Component(${component})
	endforeach()
endmacro(print_Component_Variables)

#.rst:
#
# .. ifmode:: internal
#
#  .. |init_Standard_Path_Cache_Variables| replace:: ``init_Standard_Path_Cache_Variables``
#  .. _init_Standard_Path_Cache_Variables:
#
#  init_Standard_Path_Cache_Variables
#  ----------------------------------
#
#   .. command:: init_Standard_Path_Cache_Variables()
#
#   Initialize generic cache variables values in currently defined package (for instance used to set CMAKE_INSTALL_PREFIX).
#
function(init_Standard_Path_Cache_Variables)
set(${PROJECT_NAME}_INSTALL_PATH ${PACKAGE_BINARY_INSTALL_DIR}/${PROJECT_NAME} CACHE INTERNAL "")
set(CMAKE_INSTALL_PREFIX "${${PROJECT_NAME}_INSTALL_PATH}"  CACHE INTERNAL "")
set(${PROJECT_NAME}_PID_RUNTIME_RESOURCE_PATH ${CMAKE_SOURCE_DIR}/share/resources CACHE INTERNAL "")
endfunction(init_Standard_Path_Cache_Variables)

#.rst:
#
# .. ifmode:: internal
#
#  .. |set_Install_Cache_Variables| replace:: ``set_Install_Cache_Variables``
#  .. _set_Install_Cache_Variables:
#
#  set_Install_Cache_Variables
#  ---------------------------
#
#   .. command:: set_Install_Cache_Variables()
#
#   Set cache variables values for all PID standard variable used for install in currently defined package.
#
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

#.rst:
#
# .. ifmode:: internal
#
#  .. |set_Version_Cache_Variables| replace:: ``set_Version_Cache_Variables``
#  .. _set_Version_Cache_Variables:
#
#  set_Version_Cache_Variables
#  ---------------------------
#
#   .. command:: set_Version_Cache_Variables(major minor patch)
#
#   Set cache variables values for PID standard variable used for version description in currently defined package.
#
#     :major: the major version number
#
#     :minor: the minor version number
#
#     :patch: the patch version number
#
function(set_Version_Cache_Variables major minor patch)
	set (${PROJECT_NAME}_VERSION_MAJOR ${major} CACHE INTERNAL "")
	set (${PROJECT_NAME}_VERSION_MINOR ${minor} CACHE INTERNAL "")
	set (${PROJECT_NAME}_VERSION_PATCH ${patch} CACHE INTERNAL "")
	set (${PROJECT_NAME}_VERSION ${${PROJECT_NAME}_VERSION_MAJOR}.${${PROJECT_NAME}_VERSION_MINOR}.${${PROJECT_NAME}_VERSION_PATCH} CACHE INTERNAL "")
endfunction(set_Version_Cache_Variables)


#.rst:
#
# .. ifmode:: internal
#
#  .. |reset_Version_Cache_Variables| replace:: ``reset_Version_Cache_Variables``
#  .. _reset_Version_Cache_Variables:
#
#  reset_Version_Cache_Variables
#  -----------------------------
#
#   .. command:: reset_Version_Cache_Variables()
#
#   Reset cache variables values for PID standard variable used for version description in currently defined package. Used for cleaning the project before starting configuration.
#
function(reset_Version_Cache_Variables)
#resetting general info about the package : only list are reset
set (${PROJECT_NAME}_VERSION_MAJOR CACHE INTERNAL "" )
set (${PROJECT_NAME}_VERSION_MINOR CACHE INTERNAL "" )
set (${PROJECT_NAME}_VERSION_PATCH CACHE INTERNAL "" )
set (${PROJECT_NAME}_VERSION CACHE INTERNAL "" )
endfunction(reset_Version_Cache_Variables)

#.rst:
#
# .. ifmode:: internal
#
#  .. |add_Platform_Constraint_Set| replace:: ``add_Platform_Constraint_Set``
#  .. _add_Platform_Constraint_Set:
#
#  add_Platform_Constraint_Set
#  ---------------------------
#
#   .. command:: add_Platform_Constraint_Set(type arch os abi constraints)
#
#   Define a new set of configuration constraints that applies to all platforms matching all conditions imposed by filters used.
#
#     :type: the type of processor architecture (e.g. x86) used as a filter.
#
#     :arch: the bits of the processor architecture (e.g. 64) used as a filter.
#
#     :os: the operating system kernel (e.g. linux) used as a filter.
#
#     :abi: the compiler abi (abi98 or abi11) used as a filter.
#
#     :constraints: the list of configuration to check if current platform matches all the filters.
#
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


#############################################################################################
############### API functions for setting components related cache variables ################
#############################################################################################

#.rst:
#
# .. ifmode:: internal
#
#  .. |package_Has_Nothing_To_Build| replace:: ``package_Has_Nothing_To_Build``
#  .. _package_Has_Nothing_To_Build:
#
#  package_Has_Nothing_To_Build
#  ----------------------------
#
#   .. command:: package_Has_Nothing_To_Build(NOTHING_BUILT)
#
#   Tell whether a package has something to build or not.
#
#     :NOTHING_BUILT: the output variable that is TRUE if the package content define nothing to build (depending on options chosen by the user and content of the package).
#
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

#.rst:
#
# .. ifmode:: internal
#
#  .. |package_Has_Nothing_To_Install| replace:: ``package_Has_Nothing_To_Install``
#  .. _package_Has_Nothing_To_Install:
#
#  package_Has_Nothing_To_Install
#  ------------------------------
#
#   .. command:: package_Has_Nothing_To_Install(NOTHING_INSTALLED)
#
#   Tell whether a package has something to install or not.
#
#     :NOTHING_INSTALLED: the output variable that is TRUE if the package content define nothing to install (depending on options chosen by the user and content of the package).
#
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

#.rst:
#
# .. ifmode:: internal
#
#  .. |is_Python_Module| replace:: ``is_Python_Module``
#  .. _is_Python_Module:
#
#  is_Python_Module
#  ----------------
#
#   .. command:: is_Python_Module(IS_PYTHON package component)
#
#   Check whether a component is a python wrapped module.
#
#     :package: the name of the package containing the component.
#
#     :component: the name of the component to check.
#
#     :IS_PYTHON: the output variable that is TRUE if the package content define nothing to install (depending on options chosen by the user and content of the package).
#
function(is_Python_Module IS_PYTHON package component)
	if(${package}_${component}_TYPE STREQUAL "MODULE")
		set(${IS_PYTHON} ${${package}_${component}_HAS_PYTHON_WRAPPER} PARENT_SCOPE)
	else()
		set(${IS_PYTHON} FALSE PARENT_SCOPE)
	endif()
endfunction(is_Python_Module)

#.rst:
#
# .. ifmode:: internal
#
#  .. |configure_Install_Variables| replace:: ``configure_Install_Variables``
#  .. _configure_Install_Variables:
#
#  configure_Install_Variables
#  ---------------------------
#
#   .. command:: configure_Install_Variables(component export include_dirs dep_defs exported_defs exported_options static_links shared_links c_standard cxx_standard runtime_resources)
#
#   Configure cache variables defining a component of the currenlty defined package. These variables will be used to generate the part of the package cmake use file related to the component.
#
#     :component: the name of the component.
#
#     :export: if TRUE means that the component description is exported by the package (i.e. may be used by other packages).
#
#     :include_dirs: the list of external include path known by the component.
#
#     :dep_defs:  the list of preprocessor definitions defined by the component but used in the interface of its external dependencies.
#
#     :exported_defs:  the list of preprocessor definitions defined by the component and used in its own interface.
#
#     :exported_options:  the list of compiler options exported by the component.
#
#     :static_links:  the list of path to external static libraries used by the component.
#
#     :shared_links:  the list of path to external shared libraries used by the component.
#
#     :c_standard:  the C language standard used by component.
#
#     :cxx_standard:  the C++ language standard used by component.
#
#     :runtime_resources: the list of path to runtime resources used by the component.
#
function (configure_Install_Variables component export include_dirs dep_defs exported_defs exported_options static_links shared_links c_standard cxx_standard runtime_resources)
# configuring the export
if(export) # if dependancy library is exported then we need to register its dep_defs and include dirs in addition to component interface defs
	if(dep_defs OR exported_defs)
    append_Unique_In_Cache(${PROJECT_NAME}_${component}_DEFS${USE_MODE_SUFFIX} "${exported_defs}")
    append_Unique_In_Cache(${PROJECT_NAME}_${component}_DEFS${USE_MODE_SUFFIX} "${dep_defs}")
	endif()
	if(include_dirs)
    append_Unique_In_Cache(${PROJECT_NAME}_${component}_INC_DIRS${USE_MODE_SUFFIX} "${include_dirs}")
	endif()
	if(exported_options)
    append_Unique_In_Cache(${PROJECT_NAME}_${component}_OPTS${USE_MODE_SUFFIX} "${exported_options}")
	endif()

	# links are exported since we will need to resolve symbols in the third party components that will the use the component
	if(shared_links)
    append_Unique_In_Cache(${PROJECT_NAME}_${component}_LINKS${USE_MODE_SUFFIX} "${shared_links}")
	endif()
	if(static_links)
    append_Unique_In_Cache(${PROJECT_NAME}_${component}_LINKS${USE_MODE_SUFFIX} "${static_links}")
	endif()

else() # otherwise no need to register them since no more useful
	if(exported_defs)
		#just add the exported defs of the component not those of the dependency
    append_Unique_In_Cache(${PROJECT_NAME}_${component}_DEFS${USE_MODE_SUFFIX} "${exported_defs}")
	endif()
	if(static_links) #static links are exported if component is not a shared or module lib (otherwise they simply disappear)
		if (	${PROJECT_NAME}_${component}_TYPE STREQUAL "HEADER"
			OR ${PROJECT_NAME}_${component}_TYPE STREQUAL "STATIC"
		)
      append_Unique_In_Cache(${PROJECT_NAME}_${component}_LINKS${USE_MODE_SUFFIX} "${static_links}")
		endif()
	endif()
	if(shared_links)#private links are shared "non exported" libraries -> these links are used to process executables linking
    append_Unique_In_Cache(${PROJECT_NAME}_${component}_PRIVATE_LINKS${USE_MODE_SUFFIX} "${shared_links}")
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

if(runtime_resources)#runtime resources are exported in any case
  append_Unique_In_Cache(${PROJECT_NAME}_${component}_RUNTIME_RESOURCES "${runtime_resources}")
endif()
endfunction(configure_Install_Variables)

#.rst:
#
# .. ifmode:: internal
#
#  .. |is_Package_Dependency| replace:: ``is_Package_Dependency``
#  .. _is_Package_Dependency:
#
#  is_Package_Dependency
#  ---------------------
#
#   .. command:: is_Package_Dependency(IS_DEPENDENCY dep_package)
#
#   Check whether a native or external package is a dependency of the currently defined package.
#
#     :dep_package: the name of the package to check.
#
#     :IS_DEPENDENCY: the output variable that is TRUE if dep_package is a dependency of the current package, FALSE otherwise.
#
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

#.rst:
#
# .. ifmode:: internal
#
#  .. |add_Package_Dependency_To_Cache| replace:: ``add_Package_Dependency_To_Cache``
#  .. _add_Package_Dependency_To_Cache:
#
#  add_Package_Dependency_To_Cache
#  -------------------------------
#
#   .. command:: add_Package_Dependency_To_Cache(dep_package version exact list_of_components)
#
#   Set adequate cache variables of currently defined package when defining a native package dependency.
#
#     :dep_package: the name of the native package that IS the dependency.
#
#     :version: the version constraint on dep_package (may be empty string if no version constraint applies).
#
#     :exact: if TRUE the version constraint is exact.
#
#     :list_of_components: the list of components that must belong to dep_package.
#
function(add_Package_Dependency_To_Cache dep_package version exact list_of_components)
  append_Unique_In_Cache(${PROJECT_NAME}_DEPENDENCIES${USE_MODE_SUFFIX} ${dep_package})
  append_Unique_In_Cache(${PROJECT_NAME}_DEPENDENCY_${dep_package}_COMPONENTS${USE_MODE_SUFFIX} "${list_of_components}")
	set(${PROJECT_NAME}_DEPENDENCY_${dep_package}_VERSION${USE_MODE_SUFFIX} ${version} CACHE INTERNAL "")
	set(${PROJECT_NAME}_DEPENDENCY_${dep_package}_VERSION_EXACT${USE_MODE_SUFFIX} ${exact} CACHE INTERNAL "")#false by definition since no version constraint
endfunction(add_Package_Dependency_To_Cache)

#.rst:
#
# .. ifmode:: internal
#
#  .. |add_External_Package_Dependency_To_Cache| replace:: ``add_External_Package_Dependency_To_Cache``
#  .. _add_External_Package_Dependency_To_Cache:
#
#  add_External_Package_Dependency_To_Cache
#  ----------------------------------------
#
#   .. command:: add_External_Package_Dependency_To_Cache(dep_package version exact list_of_components)
#
#   Set adequate cache variables of currently defined package when defining an external package dependency.
#
#     :dep_package: the name of the external package that IS the dependency.
#
#     :version: the version constraint on dep_package (may be empty string if no version constraint applies).
#
#     :exact: if TRUE the version constraint is exact.
#
#     :list_of_components: the list of components that must belong to dep_package.
#
function(add_External_Package_Dependency_To_Cache dep_package version exact list_of_components)
  append_Unique_In_Cache(${PROJECT_NAME}_EXTERNAL_DEPENDENCIES${USE_MODE_SUFFIX} ${dep_package})
  append_Unique_In_Cache(${PROJECT_NAME}_EXTERNAL_DEPENDENCY_${dep_package}_COMPONENTS${USE_MODE_SUFFIX} "${list_of_components}")
  set(${PROJECT_NAME}_EXTERNAL_DEPENDENCY_${dep_package}_VERSION${USE_MODE_SUFFIX} ${version} CACHE INTERNAL "")
	set(${PROJECT_NAME}_EXTERNAL_DEPENDENCY_${dep_package}_VERSION_EXACT${USE_MODE_SUFFIX} ${exact} CACHE INTERNAL "")#false by definition since no version constraint
endfunction(add_External_Package_Dependency_To_Cache)

#.rst:
#
# .. ifmode:: internal
#
#  .. |reset_Component_Cached_Variables| replace:: ``reset_Component_Cached_Variables``
#  .. _reset_Component_Cached_Variables:
#
#  reset_Component_Cached_Variables
#  --------------------------------
#
#   .. command:: reset_Component_Cached_Variables(component)
#
#   Reset all cache internal variables related to a given component. Used to ensure the cache is clean before configuring.
#
#     :component: the name of the target component.
#
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
set(${PROJECT_NAME}_${component}_AUX_SOURCE_CODE CACHE INTERNAL "")
set(${PROJECT_NAME}_${component}_AUX_MONITORED_PATH CACHE INTERNAL "")
set(${PROJECT_NAME}_${component}_RUNTIME_RESOURCES${USE_MODE_SUFFIX} CACHE INTERNAL "")
set(${PROJECT_NAME}_${component}_DESCRIPTION CACHE INTERNAL "")
set(${PROJECT_NAME}_${component}_USAGE_INCLUDES CACHE INTERNAL "")
endfunction(reset_Component_Cached_Variables)

#.rst:
#
# .. ifmode:: internal
#
#  .. |init_Component_Cached_Variables_For_Export| replace:: ``init_Component_Cached_Variables_For_Export``
#  .. _init_Component_Cached_Variables_For_Export:
#
#  init_Component_Cached_Variables_For_Export
#  ------------------------------------------
#
#   .. command:: init_Component_Cached_Variables_For_Export(component c_standard cxx_standard exported_defs exported_options exported_links runtime_resources)
#
#   Initialize cache internal variables related to a given component.
#
#     :component: the name of the target component.
#
#     :c_standard:  the C language standard used by component.
#
#     :cxx_standard:  the C++ language standard used by component.
#
#     :exported_defs:  the list of preprocessor definitions defined by the component and used in its own interface.
#
#     :exported_options:  the list of compiler options exported by the component.
#
#     :exported_links:  the list of links used by the component and exported in its description.
#
#     :runtime_resources: the list of path to runtime resources used by the component.
#
function(init_Component_Cached_Variables_For_Export component c_standard cxx_standard exported_defs exported_options exported_links runtime_resources)
set(${PROJECT_NAME}_${component}_DEFS${USE_MODE_SUFFIX} "${exported_defs}" CACHE INTERNAL "") #exported defs
set(${PROJECT_NAME}_${component}_LINKS${USE_MODE_SUFFIX} "${exported_links}" CACHE INTERNAL "") #exported links
set(${PROJECT_NAME}_${component}_INC_DIRS${USE_MODE_SUFFIX} "" CACHE INTERNAL "") #exported include directories (not useful to set it there since they will be exported "manually")
set(${PROJECT_NAME}_${component}_OPTS${USE_MODE_SUFFIX} "${exported_options}" CACHE INTERNAL "") #exported compiler options
set(${PROJECT_NAME}_${component}_RUNTIME_RESOURCES${USE_MODE_SUFFIX} "${runtime_resources}" CACHE INTERNAL "")#runtime resources are exported by default
set(${PROJECT_NAME}_${component}_C_STANDARD${USE_MODE_SUFFIX} "${c_standard}" CACHE INTERNAL "")#minimum C standard of the component interface
set(${PROJECT_NAME}_${component}_CXX_STANDARD${USE_MODE_SUFFIX} "${cxx_standard}" CACHE INTERNAL "")#minimum C++ standard of the component interface
endfunction(init_Component_Cached_Variables_For_Export)

#.rst:
#
# .. ifmode:: internal
#
#  .. |reset_Package_Description_Cached_Variables| replace:: ``reset_Package_Description_Cached_Variables``
#  .. _reset_Package_Description_Cached_Variables:
#
#  reset_Package_Description_Cached_Variables
#  ------------------------------------------
#
#   .. command:: reset_Package_Description_Cached_Variables()
#
#   Resetting all internal cached variables defined by a package. Used to start reconfiguration from a clean situation.
#
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

#.rst:
#
# .. ifmode:: internal
#
#  .. |init_Component_Description| replace:: ``init_Component_Description``
#  .. _init_Component_Description:
#
#  init_Component_Description
#  --------------------------
#
#   .. command:: init_Component_Description(component description usage)
#
#   Initialize cache internal variables related to the documentation of a given component.
#
#     :component: the name of the target component.
#
#     :description:  the long description of component utility.
#
#     :usage: the list of path to header files to include in order to use the component.
#
function(init_Component_Description component description usage)
generate_Formatted_String("${description}" RES_STRING)
set(${PROJECT_NAME}_${component}_DESCRIPTION "${RES_STRING}" CACHE INTERNAL "")
set(${PROJECT_NAME}_${component}_USAGE_INCLUDES "${usage}" CACHE INTERNAL "")
endfunction(init_Component_Description)

#.rst:
#
# .. ifmode:: internal
#
#  .. |mark_As_Declared| replace:: ``mark_As_Declared``
#  .. _mark_As_Declared:
#
#  mark_As_Declared
#  ----------------
#
#   .. command:: mark_As_Declared(component)
#
#   Memorize that the component has been declare in current configuration process.
#
#     :component: the name of the target component.
#
function(mark_As_Declared component)
set(${PROJECT_NAME}_DECLARED_COMPS ${${PROJECT_NAME}_DECLARED_COMPS} ${component} CACHE INTERNAL "")
endfunction(mark_As_Declared)

#.rst:
#
# .. ifmode:: internal
#
#  .. |is_Declared| replace:: ``is_Declared``
#  .. _is_Declared:
#
#  is_Declared
#  -----------
#
#   .. command:: is_Declared(component RESULT)
#
#   Check whether a component has been declared in current configuration process, or not.
#
#     :component: the name of the component to check.
#
#     :RESULT: the output variable that is TRUE if component has been declared, FALSE otherwise.
#
function(is_Declared component RESULT)
list(FIND ${PROJECT_NAME}_DECLARED_COMPS ${component} INDEX)
if(INDEX EQUAL -1)
	set(${RESULT} FALSE PARENT_SCOPE)
else()
	set(${RESULT} TRUE PARENT_SCOPE)
endif()
endfunction(is_Declared)

#.rst:
#
# .. ifmode:: internal
#
#  .. |reset_Declared| replace:: ``reset_Declared``
#  .. _reset_Declared:
#
#  reset_Declared
#  --------------
#
#   .. command:: reset_Declared()
#
#   Reset all declared component in currenlty defined package.
#
function(reset_Declared)
set(${PROJECT_NAME}_DECLARED_COMPS CACHE INTERNAL "")
endfunction(reset_Declared)

#.rst:
#
# .. ifmode:: internal
#
#  .. |export_Component| replace:: ``export_Component``
#  .. _export_Component:
#
#  export_Component
#  ----------------
#
#   .. command:: export_Component(IS_EXPORTING package component dep_package dep_component mode)
#
#   Check whether a component exports another component.
#
#     :package: the name of the package containing the exporting component.
#
#     :component: the name of the exporting component.
#
#     :dep_package: the name of the package containing the exported component.
#
#     :dep_component: the name of the exported component.
#
#     :mode: the build mode to consider (Debug or Release)
#
#     :IS_EXPORTING: the output variable that is TRUE if component export dep_component, FALSE otherwise.
#
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

#.rst:
#
# .. ifmode:: internal
#
#  .. |is_HeaderFree_Component| replace:: ``is_HeaderFree_Component``
#  .. _is_HeaderFree_Component:
#
#  is_HeaderFree_Component
#  -----------------------
#
#   .. command:: is_HeaderFree_Component(RESULT package component)
#
#   Check whether a component has a public interface (i.e. a set of public headers).
#
#     :package: the name of the package containing the component.
#
#     :component: the name of the component.
#
#     :RESULT: the output variable that is TRUE if component has NO public interface, FALSE otherwise.
#
function(is_HeaderFree_Component RESULT package component)
if (	${package}_${component}_TYPE STREQUAL "APP"
	OR ${package}_${component}_TYPE STREQUAL "EXAMPLE"
	OR ${package}_${component}_TYPE STREQUAL "TEST"
	OR ${package}_${component}_TYPE STREQUAL "MODULE"
	OR ${package}_${component}_TYPE STREQUAL "PYTHON"
	)
	set(${RESULT} TRUE PARENT_SCOPE)
else()
	set(${RESULT} FALSE PARENT_SCOPE)
endif()
endfunction(is_HeaderFree_Component)

#.rst:
#
# .. ifmode:: internal
#
#  .. |is_Runtime_Component| replace:: ``is_Runtime_Component``
#  .. _is_Runtime_Component:
#
#  is_Runtime_Component
#  --------------------
#
#   .. command:: is_Runtime_Component(RESULT package component)
#
#   Check whether a component exists at runtime or not.
#
#     :package: the name of the package containing the component.
#
#     :component: the name of the component.
#
#     :RESULT: the output variable that is TRUE if component exists at runtime, FALSE otherwise.
#
function(is_Runtime_Component RESULT package component)
if (	${package}_${component}_TYPE STREQUAL "APP"
	OR ${package}_${component}_TYPE STREQUAL "EXAMPLE"
	OR ${package}_${component}_TYPE STREQUAL "TEST"
	OR ${package}_${component}_TYPE STREQUAL "SHARED"
	OR ${package}_${component}_TYPE STREQUAL "MODULE"
	)
	set(${RESULT} TRUE PARENT_SCOPE)
else()
	set(${RESULT} FALSE PARENT_SCOPE)
endif()
endfunction(is_Runtime_Component)

#.rst:
#
# .. ifmode:: internal
#
#  .. |is_Executable_Component| replace:: ``is_Executable_Component``
#  .. _is_Executable_Component:
#
#  is_Executable_Component
#  -----------------------
#
#   .. command:: is_Executable_Component(RESULT package component)
#
#   Check whether a component is an executable.
#
#     :package: the name of the package containing the component.
#
#     :component: the name of the component.
#
#     :RESULT: the output variable that is TRUE if component is an executable, FALSE otherwise.
#
function(is_Executable_Component RESULT package component)
if (	${package}_${component}_TYPE STREQUAL "APP"
	OR ${package}_${component}_TYPE STREQUAL "EXAMPLE"
	OR ${package}_${component}_TYPE STREQUAL "TEST"
	)
	set(${RESULT} TRUE PARENT_SCOPE)
else()
	set(${RESULT} FALSE PARENT_SCOPE)
endif()
endfunction(is_Executable_Component)

#.rst:
#
# .. ifmode:: internal
#
#  .. |is_Built_Component| replace:: ``is_Built_Component``
#  .. _is_Built_Component:
#
#  is_Built_Component
#  ------------------
#
#   .. command:: is_Built_Component(RESULT package component)
#
#   Check whether a component is built by the build process or simply installed (e.g. header only libraries and python scripts are not built).
#
#     :package: the name of the package containing the component.
#
#     :component: the name of the component.
#
#     :RESULT: the output variable that is TRUE if component is built, FALSE otherwise.
#
function (is_Built_Component RESULT  package component)
if (	${package}_${component}_TYPE STREQUAL "APP"
	OR ${package}_${component}_TYPE STREQUAL "EXAMPLE"
	OR ${package}_${component}_TYPE STREQUAL "TEST"
	OR ${package}_${component}_TYPE STREQUAL "STATIC"
	OR ${package}_${component}_TYPE STREQUAL "SHARED"
	OR ${package}_${component}_TYPE STREQUAL "MODULE"
)
	set(${RESULT} TRUE PARENT_SCOPE)
else()
	set(${RESULT} FALSE PARENT_SCOPE)#scripts and headers libraries are not built
endif()
endfunction(is_Built_Component)

#.rst:
#
# .. ifmode:: internal
#
#  .. |will_be_Built| replace:: ``will_be_Built``
#  .. _will_be_Built:
#
#  will_be_Built
#  -------------
#
#   .. command:: will_be_Built(RESULT component)
#
#   Check whether a component of the currently defined package  will built depending on cache variables chosen by the user.
#
#     :component: the name of the component.
#
#     :RESULT: the output variable that is TRUE if component will be built by current build process, FALSE otherwise.
#
function(will_be_Built RESULT component)
if((${PROJECT_NAME}_${component}_TYPE STREQUAL "PYTHON") #python scripts are never built
	OR (${PROJECT_NAME}_${component}_TYPE STREQUAL "TEST" AND NOT BUILD_AND_RUN_TESTS)
	OR (${PROJECT_NAME}_${component}_TYPE STREQUAL "EXAMPLE" AND (NOT BUILD_EXAMPLES OR NOT BUILD_EXAMPLE_${component})))
	set(${RESULT} FALSE PARENT_SCOPE)
	return()
else()
	if(${PROJECT_NAME}_${component}_TYPE STREQUAL "MODULE")### to know wehether a module is a python wrapped module and is really compilable
		contains_Python_Code(HAS_WRAPPER ${CMAKE_SOURCE_DIR}/src/${${PROJECT_NAME}_${component}_SOURCE_DIR})
		if(HAS_WRAPPER AND NOT CURRENT_PYTHON)#wthe module will not be built as there is no python configuration
			set(${RESULT} FALSE PARENT_SCOPE)
			return()
		endif()
	endif()
	set(${RESULT} TRUE PARENT_SCOPE)
endif()
endfunction(will_be_Built)

#.rst:
#
# .. ifmode:: internal
#
#  .. |will_be_Installed| replace:: ``will_be_Installed``
#  .. _will_be_Installed:
#
#  will_be_Installed
#  -----------------
#
#   .. command:: will_be_Installed(RESULT component)
#
#   Check whether a component of the currently defined package will installed depending on cache variables chosen by the user and component nature.
#
#     :component: the name of the component.
#
#     :RESULT: the output variable that is TRUE if component will be installed by current build process, FALSE otherwise.
#
function(will_be_Installed RESULT component)
if( (${PROJECT_NAME}_${component}_TYPE STREQUAL "TEST")
	OR (${PROJECT_NAME}_${component}_TYPE STREQUAL "EXAMPLE" AND (NOT BUILD_EXAMPLES OR NOT BUILD_EXAMPLE_${component})))
	set(${RESULT} FALSE PARENT_SCOPE)
else()
	if(${PROJECT_NAME}_${component}_TYPE STREQUAL "MODULE")### to know wehether a module is a python wrapped module and is really compilable
		contains_Python_Code(HAS_WRAPPER ${CMAKE_SOURCE_DIR}/src/${${PROJECT_NAME}_${component}_SOURCE_DIR})
		if(HAS_WRAPPER AND NOT CURRENT_PYTHON)#the module will not be installed as there is no python configuration
			set(${RESULT} FALSE PARENT_SCOPE)
			return()
		endif()
	endif()
	set(${RESULT} TRUE PARENT_SCOPE)
endif()
endfunction(will_be_Installed)

#.rst:
#
# .. ifmode:: internal
#
#  .. |is_Externally_Usable| replace:: ``is_Externally_Usable``
#  .. _is_Externally_Usable:
#
#  is_Externally_Usable
#  --------------------
#
#   .. command:: is_Externally_Usable(RESULT component)
#
#   Check whether a component of the currently defined package is, by nature, usable by another package.
#
#     :component: the name of the component.
#
#     :RESULT: the output variable that is TRUE if component can be used by another package, FALSE otherwise.
#
function(is_Externally_Usable RESULT component)
if( (${PROJECT_NAME}_${component}_TYPE STREQUAL "TEST")
	OR (${PROJECT_NAME}_${component}_TYPE STREQUAL "EXAMPLE"))
	set(${RESULT} FALSE PARENT_SCOPE)
else()
	set(${RESULT} TRUE PARENT_SCOPE)
endif()
endfunction(is_Externally_Usable)

#.rst:
#
# .. ifmode:: internal
#
#  .. |build_Option_For_Example| replace:: ``build_Option_For_Example``
#  .. _build_Option_For_Example:
#
#  build_Option_For_Example
#  ------------------------
#
#   .. command:: build_Option_For_Example(example_comp)
#
#   Create a cache option to active/deactivate the build of an example.
#
#     :example_comp: the name of the example component.
#
function(build_Option_For_Example example_comp)
CMAKE_DEPENDENT_OPTION(BUILD_EXAMPLE_${example_comp} "Package build the example application ${example_comp}" ON "BUILD_EXAMPLES" ON)
endfunction(build_Option_For_Example)

#.rst:
#
# .. ifmode:: internal
#
#  .. |reset_Removed_Examples_Build_Option| replace:: ``reset_Removed_Examples_Build_Option``
#  .. _reset_Removed_Examples_Build_Option:
#
#  reset_Removed_Examples_Build_Option
#  -----------------------------------
#
#   .. command:: reset_Removed_Examples_Build_Option()
#
#   Remove all cache variables related to examples in currently defined package.
#
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

#.rst:
#
# .. ifmode:: internal
#
#  .. |register_Component_Binary| replace:: ``register_Component_Binary``
#  .. _register_Component_Binary:
#
#  register_Component_Binary
#  -------------------------
#
#   .. command:: register_Component_Binary(component)
#
#   Memorize in cache the generated binary name of a component. Warining: the binary name uses Cmake generator expressions.
#
#     :component: the name of the component.
#
function(register_Component_Binary component)
	set(${PROJECT_NAME}_${component}_BINARY_NAME${USE_MODE_SUFFIX} "$<TARGET_FILE_NAME:${component}${INSTALL_NAME_SUFFIX}>" CACHE INTERNAL "")
endfunction(register_Component_Binary)

#.rst:
#
# .. ifmode:: internal
#
#  .. |is_Component_Exporting_Other_Components| replace:: ``is_Component_Exporting_Other_Components``
#  .. _is_Bin_Component_Exporting_Other_Components:
#
#  is_Component_Exporting_Other_Components
#  ---------------------------------------
#
#   .. command:: is_Component_Exporting_Other_Components(RESULT package component mode)
#
#   Check whether a component exports other components.
#
#     :package: the name of the package containing the component.
#
#     :component: the name of the component.
#
#     :mode: the build mode considered (Release or Debug).
#
#     :RESULT: the output variable that is TRUE if the component export other components, FALSE otherwise.
#
function(is_Component_Exporting_Other_Components RESULT package component mode)
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
endfunction(is_Component_Exporting_Other_Components)

#.rst:
#
# .. ifmode:: internal
#
#  .. |find_Packages_Containing_Component| replace:: ``find_Packages_Containing_Component``
#  .. _find_Packages_Containing_Component:
#
#  find_Packages_Containing_Component
#  ----------------------------------
#
#   .. command:: find_Packages_Containing_Component(CONTAINER_PACKAGES package component)
#
#   Find the list of packages that define a given component.
#
#     :package: the name of the package from where starting the search.
#
#     :is_external: if package is an external package then it is TRUE, FALSE if it is native.
#
#     :component: the name of the component.
#
#     :CONTAINER_PACKAGES: the output variable that contains the list of packages that define a component with same name.
#
function(find_Packages_Containing_Component CONTAINER_PACKAGES package is_external component)
set(result)
#searching into component of the current package
if(is_external)#external components may have variations among their DEBUG VS RELEASE VERSION
  list(FIND ${package}_COMPONENTS${USE_MODE_SUFFIX} ${component} INDEX)
else()
  list(FIND ${package}_COMPONENTS ${component} INDEX)
endif()
if(NOT INDEX EQUAL -1)#the same component name has been found
  list(APPEND result ${package})
endif()
#searching into direct external dependencies
foreach(ext_dep IN LISTS ${package}_EXTERNAL_DEPENDENCIES${USE_MODE_SUFFIX})
  find_Packages_Containing_Component(CONTAINER ${ext_dep} TRUE ${component})
  if(CONTAINER)
    list(APPEND result ${CONTAINER})
  endif()
endforeach()
if(NOT is_external)
  #searching into direct native dependencies
  set(CONTAINER)
  foreach(nat_dep IN LISTS ${package}_DEPENDENCIES${USE_MODE_SUFFIX})
    find_Packages_Containing_Component(CONTAINER ${nat_dep} FALSE ${component})
    if(CONTAINER)
      list(APPEND result ${CONTAINER})
    endif()
  endforeach()
endif()
if(result)
  list(REMOVE_DUPLICATES result)
endif()
set(${CONTAINER_PACKAGES} ${result} PARENT_SCOPE)
endfunction(find_Packages_Containing_Component)

##################################################################################
############################## install the dependancies ##########################
########### functions used to create the use<package><version>.cmake  ############
##################################################################################

#.rst:
#
# .. ifmode:: internal
#
#  .. |write_Use_File| replace:: ``write_Use_File``
#  .. _write_Use_File:
#
#  write_Use_File
#  --------------
#
#   .. command:: write_Use_File(file package build_mode)
#
#   Write the use file of a package for the given build mode.
#
#     :file: the path to file to write in.
#
#     :package: the name of the package.
#
#     :build_mode: the build mode considered (Release or Debug).
#
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

  #writing info about compiler used to build the binary
  file(APPEND ${file} "set(${package}_BUILT_WITH_CXX_COMPILER ${CMAKE_CXX_COMPILER} CACHE INTERNAL \"\")\n")
  file(APPEND ${file} "set(${package}_BUILT_WITH_C_COMPILER ${CMAKE_C_COMPILER} CACHE INTERNAL \"\")\n")
  file(APPEND ${file} "set(${package}_BUILT_WITH_COMPILER_IS_GNUCXX \"${CMAKE_COMPILER_IS_GNUCXX}\" CACHE INTERNAL \"\" FORCE)\n")
  file(APPEND ${file} "set(${package}_BUILT_WITH_CXX_COMPILER_ID \"${CMAKE_CXX_COMPILER_ID}\" CACHE INTERNAL \"\" FORCE)\n")
  file(APPEND ${file} "set(${package}_BUILT_WITH_CXX_COMPILER_VERSION \"${CMAKE_CXX_COMPILER_VERSION}\" CACHE INTERNAL \"\" FORCE)\n")
  file(APPEND ${file} "set(${package}_BUILT_WITH_C_COMPILER_ID \"${CMAKE_C_COMPILER_ID}\" CACHE INTERNAL \"\" FORCE)\n")
  file(APPEND ${file} "set(${package}_BUILT_WITH_C_COMPILER_VERSION \"${CMAKE_C_COMPILER_VERSION}\" CACHE INTERNAL \"\" FORCE)\n")

	file(APPEND ${file} "set(${package}_BUILT_WITH_CXX_ABI ${CURRENT_CXX_ABI} CACHE INTERNAL \"\")\n")
  file(APPEND ${file} "set(${package}_BUILT_WITH_CMAKE_INTERNAL_PLATFORM_ABI ${CMAKE_INTERNAL_PLATFORM_ABI} CACHE INTERNAL \"\")\n")
  list(REMOVE_DUPLICATES CXX_STANDARD_LIBRARIES)
  file(APPEND ${file} "set(${package}_BUILT_WITH_CXX_STD_LIBRARIES ${CXX_STANDARD_LIBRARIES} CACHE INTERNAL \"\")\n")
  foreach(lib IN LISTS CXX_STANDARD_LIBRARIES)
    file(APPEND ${file} "set(${package}_BUILT_WITH_CXX_STD_LIB_${lib}_ABI_SOVERSION ${CXX_STD_LIB_${lib}_ABI_SOVERSION} CACHE INTERNAL \"\")\n")
  endforeach()
  file(APPEND ${file} "set(${package}_BUILT_WITH_CXX_STD_SYMBOLS ${CXX_STD_SYMBOLS} CACHE INTERNAL \"\")\n")
  foreach(symbol IN LISTS CXX_STD_SYMBOLS)
    file(APPEND ${file} "set(${package}_BUILT_WITH_CXX_STD_SYMBOL_${symbol}_VERSION ${CXX_STD_SYMBOL_${symbol}_VERSION} CACHE INTERNAL \"\")\n")
  endforeach()


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
foreach(config IN LISTS ${package}_PLATFORM_CONFIGURATIONS${MODE_SUFFIX})
  if(${package}_PLATFORM_CONFIGURATION_${config}_ARGS${MODE_SUFFIX})
    file(APPEND ${file} "set(${package}_PLATFORM_CONFIGURATION_${config}_ARGS${MODE_SUFFIX} ${${package}_PLATFORM_CONFIGURATION_${config}_ARGS${MODE_SUFFIX}} CACHE INTERNAL \"\")\n")
  endif()
endforeach()
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

#.rst:
#
# .. ifmode:: internal
#
#  .. |create_Use_File| replace:: ``create_Use_File``
#  .. _create_Use_File:
#
#  create_Use_File
#  ---------------
#
#   .. command:: create_Use_File()
#
#   Create the use file for the currenlt defined package.
#
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

#.rst:
#
# .. ifmode:: internal
#
#  .. |generate_Info_File| replace:: ``generate_Info_File``
#  .. _generate_Info_File:
#
#  generate_Info_File
#  ------------------
#
#   .. command:: generate_Info_File()
#
#   Create the info file (Info<package>.cmake) for the currenlty defined package. This info file is used at build time to know whether the content of the package has changed.
#
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
      file(APPEND ${file} "set(${PROJECT_NAME}_${a_component}_AUX_SOURCE_CODE ${${PROJECT_NAME}_${a_component}_AUX_SOURCE_CODE} CACHE INTERNAL \"\")\n")
      file(APPEND ${file} "set(${PROJECT_NAME}_${a_component}_AUX_MONITORED_PATH ${${PROJECT_NAME}_${a_component}_AUX_MONITORED_PATH} CACHE INTERNAL \"\")\n")
    endif()
		if(${PROJECT_NAME}_${a_component}_HEADER_DIR_NAME)
			file(APPEND ${file} "set(${PROJECT_NAME}_${a_component}_HEADER_DIR_NAME ${${PROJECT_NAME}_${a_component}_HEADER_DIR_NAME} CACHE INTERNAL \"\")\n")
			file(APPEND ${file} "set(${PROJECT_NAME}_${a_component}_HEADERS ${${PROJECT_NAME}_${a_component}_HEADERS} CACHE INTERNAL \"\")\n")
      file(APPEND ${file} "set(${PROJECT_NAME}_${a_component}_HEADERS_ADDITIONAL_FILTERS ${${PROJECT_NAME}_${a_component}_HEADERS_ADDITIONAL_FILTERS} CACHE INTERNAL \"\")\n")
    endif()
	endforeach()
endif()
endfunction(generate_Info_File)

#.rst:
#
# .. ifmode:: internal
#
#  .. |generate_Find_File| replace:: ``generate_Find_File``
#  .. _generate_Find_File:
#
#  generate_Find_File
#  ------------------
#
#   .. command:: generate_Find_File()
#
#   Create and install the find file (Find<package>.cmake) for the currenlty defined package.
#
function(generate_Find_File)
if(${CMAKE_BUILD_TYPE} MATCHES Release)
	# generating/installing the generic cmake find file for the package
	configure_file(${WORKSPACE_DIR}/share/patterns/packages/FindPackage.cmake.in ${CMAKE_BINARY_DIR}/share/Find${PROJECT_NAME}.cmake @ONLY)
	install(FILES ${CMAKE_BINARY_DIR}/share/Find${PROJECT_NAME}.cmake DESTINATION ${WORKSPACE_DIR}/share/cmake/find) #install in the worskpace cmake directory which contains cmake find modules
endif()
endfunction(generate_Find_File)

#.rst:
#
# .. ifmode:: internal
#
#  .. |generate_Use_File| replace:: ``generate_Use_File``
#  .. _generate_Use_File:
#
#  generate_Use_File
#  -----------------
#
#   .. command:: generate_Use_File()
#
#   Create and install the use file (Use<package>-<version>.cmake) for the currenlty defined package.
#
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

#.rst:
#
# .. ifmode:: internal
#
#  .. |current_Native_Dependencies_For_Package| replace:: ``current_Native_Dependencies_For_Package``
#  .. _current_Native_Dependencies_For_Package:
#
#  current_Native_Dependencies_For_Package
#  ---------------------------------------
#
#   .. command:: current_Native_Dependencies_For_Package(package depfile packages_already_managed PACKAGES_NEWLY_MANAGED)
#
#   Write the description of native dependencies of a given package in the dependencies description file.
#
#     :package: the name of the package.
#
#     :file: the path to file to write in.
#
#     :packages_already_managed: the list of packages already managed in the process of writing dependency file.
#
#     :PACKAGES_NEWLY_MANAGED: the output variable containing the list of package newly managed after this call.
#
function(current_Native_Dependencies_For_Package package depfile packages_already_managed PACKAGES_NEWLY_MANAGED)
get_Mode_Variables(TARGET_SUFFIX MODE_SUFFIX ${CMAKE_BUILD_TYPE})
#information on package to register
file(APPEND ${depfile} "set(CURRENT_NATIVE_DEPENDENCY_${package}_VERSION${MODE_SUFFIX} ${${package}_VERSION_STRING} CACHE INTERNAL \"\")\n")
file(APPEND ${depfile} "set(CURRENT_NATIVE_DEPENDENCY_${package}_ALL_VERSION${MODE_SUFFIX} ${${package}_ALL_REQUIRED_VERSIONS} CACHE INTERNAL \"\")\n")
file(APPEND ${depfile} "set(CURRENT_NATIVE_DEPENDENCY_${package}_EXTERNAL_DEPENDENCIES${MODE_SUFFIX} ${${package}_EXTERNAL_DEPENDENCIES${MODE_SUFFIX}} CACHE INTERNAL \"\")\n")
file(APPEND ${depfile} "set(CURRENT_NATIVE_DEPENDENCY_${package}_DEPENDENCIES${MODE_SUFFIX} ${${package}_DEPENDENCIES${MODE_SUFFIX}} CACHE INTERNAL \"\")\n")

#registering platform configuration info coming from the dependency
file(APPEND ${depfile} "set(CURRENT_NATIVE_DEPENDENCY_${package}_PLATFORM_CONFIGURATIONS${MODE_SUFFIX} ${${package}_PLATFORM_CONFIGURATIONS${MODE_SUFFIX}} CACHE INTERNAL \"\")\n")
foreach(config IN LISTS ${package}_PLATFORM_CONFIGURATIONS${MODE_SUFFIX})
  if(${package}_PLATFORM_CONFIGURATION_${config}_ARGS${MODE_SUFFIX})#there are arguments to pass to that constraint
    file(APPEND ${depfile} "set(CURRENT_NATIVE_DEPENDENCY_${package}_PLATFORM_CONFIGURATION_${config}_ARGS${MODE_SUFFIX} ${${package}_PLATFORM_CONFIGURATION_${config}_ARGS${MODE_SUFFIX}} CACHE INTERNAL \"\")\n")
  endif()
endforeach()
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

#.rst:
#
# .. ifmode:: internal
#
#  .. |current_External_Dependencies_For_Package| replace:: ``current_External_Dependencies_For_Package``
#  .. _current_External_Dependencies_For_Package:
#
#  current_External_Dependencies_For_Package
#  -----------------------------------------
#
#   .. command:: current_External_Dependencies_For_Package(package depfile PACKAGES_NEWLY_MANAGED)
#
#   Write the description of external dependencies of a given package in the dependencies description file.
#
#     :package: the name of the package.
#
#     :file: the path to file to write in.
#
#     :PACKAGES_NEWLY_MANAGED: the output variable containing the list of external package newly managed after this call.
#
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

#.rst:
#
# .. ifmode:: internal
#
#  .. |generate_Dependencies_File| replace:: ``generate_Dependencies_File``
#  .. _generate_Dependencies_File:
#
#  generate_Dependencies_File
#  --------------------------
#
#   .. command:: generate_Dependencies_File()
#
#   Create the dependencies description file (Dep<package>.cmake) for the currenlty defined package. This file is used to track modifications of packages used.
#
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
foreach(config IN LISTS ${PROJECT_NAME}_PLATFORM_CONFIGURATIONS${MODE_SUFFIX})
  if(${PROJECT_NAME}_PLATFORM_CONFIGURATION_${config}_ARGS${MODE_SUFFIX})
    file(APPEND ${file} "set(TARGET_PLATFORM_CONFIGURATION_${config}_ARGS${MODE_SUFFIX} ${${PROJECT_NAME}_PLATFORM_CONFIGURATION_${config}_ARGS${MODE_SUFFIX}} CACHE INTERNAL \"\")\n")
  endif()
endforeach()
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
