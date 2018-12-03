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
if(PID_PLATFORM_MANAGEMENT_FUNCTIONS_INCLUDED)
  return()
endif()
set(PID_PLATFORM_MANAGEMENT_FUNCTIONS_INCLUDED TRUE)
##########################################################################################


#############################################################################################
############### API functions for managing platform description variables ###################
#############################################################################################

#.rst:
#
# .. ifmode:: internal
#
#  .. |manage_Current_Platform| replace:: ``manage_Current_Platform``
#  .. _manage_Current_Platform:
#
#  manage_Current_Platform
#  ------------------------
#
#   .. command:: manage_Current_Platform(build_folder)
#
#    If the platform description has changed then clean and launch the reconfiguration of the package.
#
#     :build_folder: the path to the package build_folder.
#
macro(manage_Current_Platform build_folder)
	if(build_folder STREQUAL build)
		if(CURRENT_PLATFORM)# a current platform is already defined
			#if any of the following variable changed, the cache of the CMake project needs to be regenerated from scratch
			set(TEMP_PLATFORM ${CURRENT_PLATFORM})
			set(TEMP_C_COMPILER ${CMAKE_C_COMPILER})
			set(TEMP_CXX_COMPILER ${CMAKE_CXX_COMPILER})
			set(TEMP_CMAKE_LINKER ${CMAKE_LINKER})
			set(TEMP_CMAKE_RANLIB ${CMAKE_RANLIB})
			set(TEMP_CMAKE_CXX_COMPILER_ID ${CMAKE_CXX_COMPILER_ID})
			set(TEMP_CMAKE_CXX_COMPILER_VERSION ${CMAKE_CXX_COMPILER_VERSION})
      set(TEMP_CXX_STANDARD_LIBRARIES ${CXX_STANDARD_LIBRARIES})
      foreach(lib IN LISTS TEMP_CXX_STANDARD_LIBRARIES)
        set(TEMP_CXX_STD_LIB_${lib}_ABI_SOVERSION ${CXX_STD_LIB_${lib}_ABI_SOVERSION})
      endforeach()
      set(TEMP_CXX_STD_SYMBOLS ${CXX_STD_SYMBOLS})
      foreach(symbol IN LISTS TEMP_CXX_STD_SYMBOLS)
        set(TEMP_CXX_STD_SYMBOL_${symbol}_VERSION ${CXX_STD_SYMBOL_${symbol}_VERSION})
      endforeach()
		endif()
	endif()
  load_Current_Platform()
	if(build_folder STREQUAL build)
		if(TEMP_PLATFORM)
			if( (NOT TEMP_PLATFORM STREQUAL CURRENT_PLATFORM) #the current platform has changed to we need to regenerate
					OR (NOT TEMP_C_COMPILER STREQUAL CMAKE_C_COMPILER)
					OR (NOT TEMP_CXX_COMPILER STREQUAL CMAKE_CXX_COMPILER)
					OR (NOT TEMP_CMAKE_LINKER STREQUAL CMAKE_LINKER)
					OR (NOT TEMP_CMAKE_RANLIB STREQUAL CMAKE_RANLIB)
					OR (NOT TEMP_CMAKE_CXX_COMPILER_ID STREQUAL CMAKE_CXX_COMPILER_ID)
					OR (NOT TEMP_CMAKE_CXX_COMPILER_VERSION STREQUAL CMAKE_CXX_COMPILER_VERSION)
				)
        set(DO_CLEAN TRUE)
      else()
        set(DO_CLEAN FALSE)
        #detecting if soname of standard lirbaries have changed
        foreach(lib IN LISTS TEMP_CXX_STANDARD_LIBRARIES)
          if(NOT TEMP_CXX_STD_LIB_${lib}_ABI_SOVERSION VERSION_EQUAL CXX_STD_LIB_${lib}_ABI_SOVERSION)
            set(DO_CLEAN TRUE)
            break()
          endif()
        endforeach()
        if(NOT DO_CLEAN)#must check that previous and current lists of standard libraries perfectly match
          foreach(lib IN LISTS CXX_STANDARD_LIBRARIES)
            if(NOT TEMP_CXX_STD_LIB_${lib}_ABI_SOVERSION VERSION_EQUAL CXX_STD_LIB_${lib}_ABI_SOVERSION)
              set(DO_CLEAN TRUE)
              break()
            endif()
          endforeach()
        endif()

        #detecting symbol version changes and symbol addition-removal in C++ standard libraries
        if(NOT DO_CLEAN)
          foreach(symbol IN LISTS TEMP_CXX_STD_SYMBOLS)
            if(NOT TEMP_CXX_STD_SYMBOL_${symbol}_VERSION VERSION_EQUAL CXX_STD_SYMBOL_${symbol}_VERSION)
              set(DO_CLEAN TRUE)
              break()
            endif()
          endforeach()
        endif()
        if(NOT DO_CLEAN)#must check that previous and current lists of ABI symbols perfectly match
          foreach(symbol IN LISTS CXX_STD_SYMBOLS)
            if(NOT CXX_STD_SYMBOL_${symbol}_VERSION VERSION_EQUAL TEMP_CXX_STD_SYMBOL_${symbol}_VERSION)
              set(DO_CLEAN TRUE)
              break()
            endif()
          endforeach()
        endif()

      endif()
      if(DO_CLEAN)
				message("[PID] INFO : cleaning the build folder after major environment change")
				hard_Clean_Package_Debug(${PROJECT_NAME})
				hard_Clean_Package_Release(${PROJECT_NAME})
				reconfigure_Package_Build_Debug(${PROJECT_NAME})#force reconfigure before running the build
				reconfigure_Package_Build_Release(${PROJECT_NAME})#force reconfigure before running the build
			endif()
		endif()
	endif()
endmacro(manage_Current_Platform)

#.rst:
#
# .. ifmode:: internal
#
#  .. |load_Current_Platform| replace:: ``load_Current_Platform``
#  .. _load_Current_Platform:
#
#  load_Current_Platform
#  ---------------------
#
#   .. command:: load_Current_Platform()
#
#    Load the platform description information into current process.
#
function(load_Current_Platform)
#loading the current platform configuration simply consist in including the config file generated by the workspace
include(${WORKSPACE_DIR}/pid/Workspace_Platforms_Info.cmake)
endfunction(load_Current_Platform)

#.rst:
#
# .. ifmode:: internal
#
#  .. |reset_Package_Platforms_Variables| replace:: ``reset_Package_Platforms_Variables``
#  .. _reset_Package_Platforms_Variables:
#
#  reset_Package_Platforms_Variables
#  ---------------------------------
#
#   .. command:: reset_Package_Platforms_Variables()
#
#    Reset all platform constraints aplying to current project.
#
function(reset_Package_Platforms_Variables)

	if(${PROJECT_NAME}_PLATFORM_CONFIGURATIONS${USE_MODE_SUFFIX}) # reset all configurations satisfied by current platform
    foreach(config IN LISTS ${PROJECT_NAME}_PLATFORM_CONFIGURATIONS${USE_MODE_SUFFIX})
      set(${PROJECT_NAME}_PLATFORM_CONFIGURATION_${config}_ARGS${USE_MODE_SUFFIX} CACHE INTERNAL "")#reset arguments if any
    endforeach()
		set(${PROJECT_NAME}_PLATFORM_CONFIGURATIONS${USE_MODE_SUFFIX} CACHE INTERNAL "")
	endif()
	#reset all constraints defined by the package
	if(${PROJECT_NAME}_ALL_PLATFORMS_CONSTRAINTS${USE_MODE_SUFFIX} GREATER 0)
		set(CURRENT_INDEX 0)

		while(${${PROJECT_NAME}_ALL_PLATFORMS_CONSTRAINTS${USE_MODE_SUFFIX}} GREATER CURRENT_INDEX)
			set(${PROJECT_NAME}_PLATFORM_CONSTRAINT_${CURRENT_INDEX}_CONDITION_TYPE${USE_MODE_SUFFIX} CACHE INTERNAL "")
			set(${PROJECT_NAME}_PLATFORM_CONSTRAINT_${CURRENT_INDEX}_CONDITION_ARCH${USE_MODE_SUFFIX} CACHE INTERNAL "")
		  	set(${PROJECT_NAME}_PLATFORM_CONSTRAINT_${CURRENT_INDEX}_CONDITION_OS${USE_MODE_SUFFIX} CACHE INTERNAL "")
			set(${PROJECT_NAME}_PLATFORM_CONSTRAINT_${CURRENT_INDEX}_CONDITION_ABI${USE_MODE_SUFFIX} CACHE INTERNAL "")
			set(${PROJECT_NAME}_PLATFORM_CONSTRAINT_${CURRENT_INDEX}_CONFIGURATION${USE_MODE_SUFFIX} CACHE INTERNAL "")
			math(EXPR CURRENT_INDEX "${CURRENT_INDEX}+1")
		endwhile()
	endif()
	set(${PROJECT_NAME}_ALL_PLATFORMS_CONSTRAINTS${USE_MODE_SUFFIX} 0 CACHE INTERNAL "")
endfunction(reset_Package_Platforms_Variables)


#.rst:
#
# .. ifmode:: internal
#
#  .. |is_Compatible_With_Current_ABI| replace:: ``is_Compatible_With_Current_ABI``
#  .. _is_Compatible_With_Current_ABI:
#
#  is_Compatible_With_Current_ABI
#  ------------------------------
#
#   .. command:: is_Compatible_With_Current_ABI(COMPATIBLE package)
#
#    Chech whether the given package binary in use use a compatible ABI for standard library.
#
#     :package: the name of binary package to check.
#
#     :COMPATIBLE: the output variable that is TRUE if package's stdlib usage is compatible with current platform ABI, FALSE otherwise.
#
function(is_Compatible_With_Current_ABI COMPATIBLE package)

  if((${package}_BUILT_WITH_CXX_ABI AND NOT ${package}_BUILT_WITH_CXX_ABI STREQUAL CURRENT_CXX_ABI)
    OR (${package}_BUILT_WITH_CMAKE_INTERNAL_PLATFORM_ABI AND NOT ${package}_BUILT_WITH_CMAKE_INTERNAL_PLATFORM_ABI STREQUAL CMAKE_INTERNAL_PLATFORM_ABI))
    set(${COMPATIBLE} FALSE PARENT_SCOPE)
    #remark: by default we are not restructive if teh binary file does not contain sur information
    return()
  else()
    #test for standard libraries versions
    foreach(lib IN LISTS ${package}_BUILT_WITH_CXX_STD_LIBRARIES)
      if(${package}_BUILT_WITH_CXX_STD_LIB_${lib}_ABI_SOVERSION
          AND CXX_STD_LIB_${lib}_ABI_SOVERSION
          AND (NOT ${package}_BUILT_WITH_CXX_STD_LIB_${lib}_ABI_SOVERSION STREQUAL CXX_STD_LIB_${lib}_ABI_SOVERSION))
          #soversion number must be defined for the given lib in order to be compared (if no sonumber => no restriction)
          set(${COMPATIBLE} FALSE PARENT_SCOPE)
          return()
      endif()
    endforeach()
    foreach(lib IN LISTS CXX_STANDARD_LIBRARIES)
      if(${package}_BUILT_WITH_CXX_STD_LIB_${lib}_ABI_SOVERSION
          AND CXX_STD_LIB_${lib}_ABI_SOVERSION
          AND (NOT ${package}_BUILT_WITH_CXX_STD_LIB_${lib}_ABI_SOVERSION STREQUAL CXX_STD_LIB_${lib}_ABI_SOVERSION))
          #soversion number must be defined for the given lib in order to be compared (if no sonumber => no restriction)
          set(${COMPATIBLE} FALSE PARENT_SCOPE)
          return()
      endif()
    endforeach()

    #test symbols versions
    foreach(symbol IN LISTS ${package}_BUILT_WITH_CXX_STD_SYMBOLS)#for each symbol used by the binary
      if(NOT CXX_STD_SYMBOL_${symbol}_VERSION)#corresponding symbol do not exist in current environment => it is an uncompatible binary
        set(${COMPATIBLE} FALSE PARENT_SCOPE)
        return()
      endif()

      #the binary has been built and linked against a newer version of standard libraries => NOT compatible
      if(${package}_BUILT_WITH_CXX_STD_SYMBOL_${symbol}_VERSION VERSION_GREATER CXX_STD_SYMBOL_${symbol}_VERSION)
        set(${COMPATIBLE} FALSE PARENT_SCOPE)
        return()
      endif()
    endforeach()
  endif()
  set(${COMPATIBLE} TRUE PARENT_SCOPE)
endfunction(is_Compatible_With_Current_ABI)


#.rst:
#
# .. ifmode:: internal
#
#  .. |parse_Configuration_Constraints| replace:: ``parse_Configuration_Constraints``
#  .. _parse_Configuration_Constraints:
#
#  parse_Configuration_Constraints
#  -------------------------------
#
#   .. command:: parse_Configuration_Constraints(CONFIG_NAME CONFIG_ARGS configuration_constraint)
#
#     Extract the arguments passed to a configuration check.
#
#     :configuration_constraint: the string representing the configuration constraint check.
#
#     :CONFIG_NAME: the output variable containing the name of the configuration
#
#     :CONFIG_ARGS: the output variable containing the list of  arguments of the constraint check.
#
function(parse_Configuration_Constraints CONFIG_NAME CONFIG_ARGS configuration_constraint)
  string(REPLACE " " "" configuration_constraint ${configuration_constraint})#remove the spaces if any
  string(REPLACE "\t" "" configuration_constraint ${configuration_constraint})#remove the tabulations if any

  string(REGEX REPLACE "^([^[]+)\\[([^]]+)\\]$" "\\1;\\2" NAME_ARGS "${configuration_constraint}")#argument list format : configuration[list_of_args]
  if(NOT NAME_ARGS STREQUAL configuration_constraint)#it matches !! => there are arguments passed to the configuration
    list(GET NAME_ARGS 0 THE_NAME)
    list(GET NAME_ARGS 1 THE_ARGS)
    set(${CONFIG_ARGS} PARENT_SCOPE)
    set(${CONFIG_NAME} PARENT_SCOPE)
    if(NOT THE_ARGS)
      return()
    endif()
    string(REPLACE ":" ";" ARGS_LIST "${THE_ARGS}")
    foreach(arg IN LISTS ARGS_LIST)
      string(REGEX REPLACE "^([^=]+)=(.+)$" "\\1;\\2" ARG_VAL "${arg}")#argument format :  arg_name=first,second,third OR arg_name=val
      if(ARG_VAL STREQUAL arg)#no match => ill formed argument
        return()
      endif()
      list(APPEND result ${ARG_VAL})
    endforeach()
      set(${CONFIG_ARGS} ${result} PARENT_SCOPE)
      set(${CONFIG_NAME} ${THE_NAME} PARENT_SCOPE)
  else()#this is a configuration constraint without arguments
    set(${CONFIG_ARGS} PARENT_SCOPE)
    set(${CONFIG_NAME} ${configuration_constraint} PARENT_SCOPE)
  endif()
endfunction(parse_Configuration_Constraints)

#.rst:
#
# .. ifmode:: internal
#
#  .. |generate_Configuration_Parameters| replace:: ``generate_Configuration_Parameters``
#  .. _generate_Configuration_Parameters:
#
#  generate_Configuration_Parameters
#  ---------------------------------
#
#   .. command:: generate_Configuration_Parameters(RESULTING_EXPRESSION config_name config_args)
#
#     Generate a list whose each element is an expression of the form name=value.
#
#     :config_name: the name of the system configuration.
#
#     :config_args: list of arguments to use as constraints checn checking the system configuration.
#
#     :LIST_OF_PAREMETERS: the output variable containing the list of expressions used to value the configuration.
#
function(generate_Configuration_Parameters LIST_OF_PAREMETERS config_name config_args)
  set(returned)
  if(config_args)
    set(first_time TRUE)
    #now generating expression for each argument
    while(config_args)
      list(GET config_args 0 name)
      list(GET config_args 1 value)
      list(APPEND returned "${name}=${value}")
      list(REMOVE_AT config_args 0 1)
    endwhile()
  endif()
  set(${LIST_OF_PAREMETERS} ${returned} PARENT_SCOPE)
endfunction(generate_Configuration_Parameters)

#.rst:
#
# .. ifmode:: internal
#
#  .. |generate_Configuration_Constraints| replace:: ``generate_Configuration_Constraints``
#  .. _generate_Configuration_Constraints:
#
#  generate_Configuration_Constraints
#  ----------------------------------
#
#   .. command:: generate_Configuration_Constraints(RESULTING_EXPRESSION config_name config_args)
#
#     Generate an expression (string) that describes the configuration check given by configuration name and arguments. Inverse operation of parse_Configuration_Constraints.
#
#     :config_name: the name of the system configuration.
#
#     :config_args: list of arguments to use as constraints checn checking the system configuration.
#
#     :RESULTING_EXPRESSION: the output variable containing the configuration check equivalent expression.
#
function(generate_Configuration_Constraints RESULTING_EXPRESSION config_name config_args)
  if(config_args)
    set(final_expression "${config_name}[")
    set(first_time TRUE)
    #now generating expression for each argument
    foreach(arg IN LISTS config_args)
      if(NOT first_time)
        set(final_expression "${final_expression}:${arg}")
      else()
        set(final_expression "${final_expression}${arg}")
        set(first_time FALSE)
      endif()
    endforeach()
    set(final_expression "${final_expression}]")

  else()#there is no argument
    set(final_expression "${config_name}")
  endif()
  set(${RESULTING_EXPRESSION} "${final_expression}" PARENT_SCOPE)
endfunction(generate_Configuration_Constraints)

#.rst:
#
# .. ifmode:: internal
#
#  .. |check_System_Configuration| replace:: ``check_System_Configuration``
#  .. _check_System_Configuration:
#
#  check_System_Configuration
#  --------------------------
#
#   .. command:: check_System_Configuration(RESULT NAME CONSTRAINTS config)
#
#    Check whether the given configuration constraint (= configruation name + arguments) conforms to target platform.
#
#     :config: the configuration expression (may contain arguments).
#
#     :RESULT: the output variable that is TRUE configuration constraints is satisfied by current platform.
#
#     :NAME: the output variable that contains the name of the configuration without arguments.
#
#     :CONSTRAINTS: the output variable that contains the constraints that applmy to the configuration once used. It includes arguments (constraints imposed by user) and generated contraints (constraints automatically defined by the configuration itself once used).
#
function(check_System_Configuration RESULT NAME CONSTRAINTS config)
  parse_Configuration_Constraints(CONFIG_NAME CONFIG_ARGS "${config}")
  if(NOT CONFIG_NAME)
    set(${NAME} PARENT_SCOPE)
    set(${CONSTRAINTS} PARENT_SCOPE)
    set(${RESULT} FALSE PARENT_SCOPE)
    message("[PID] CRITICAL ERROR : configuration check ${config} is ill formed.")
    return()
  endif()
  check_System_Configuration_With_Arguments(RESULT_WITH_ARGS BINARY_CONSTRAINTS ${CONFIG_NAME} CONFIG_ARGS)
  set(${NAME} ${CONFIG_NAME} PARENT_SCOPE)
  set(${RESULT} ${RESULT_WITH_ARGS} PARENT_SCOPE)
  # last step consist in generating adequate expressions for constraints
  generate_Configuration_Parameters(LIST_OF_CONSTRAINTS ${CONFIG_NAME} "${BINARY_CONSTRAINTS}")
  set(${CONSTRAINTS} ${LIST_OF_CONSTRAINTS} PARENT_SCOPE)
endfunction(check_System_Configuration)

#.rst:
#
# .. ifmode:: internal
#
#  .. |check_System_Configuration_With_Arguments| replace:: ``check_System_Configuration_With_Arguments``
#  .. _check_System_Configuration_With_Arguments:
#
#  check_System_Configuration_With_Arguments
#  -----------------------------------------
#
#   .. command:: check_System_Configuration_With_Arguments(RESULT BINARY_CONTRAINTS config_name config_args)
#
#    Check whether the given configuration constraint (= configruation name + arguments) conforms to target platform.
#
#     :config_name: the name of the configuration (without argument).
#
#     :config_args: the constraints passed as arguments by the user of the configuration.
#
#     :RESULT: the output variable that is TRUE configuration constraints is satisfied by current platform.
#
#     :BINARY_CONTRAINTS: the output variable that contains the list of all parameter (constraints coming from argument or generated by the configuration itself) to use whenever the configuration is used.
#
function(check_System_Configuration_With_Arguments CHECK_OK BINARY_CONTRAINTS config_name config_args)
  set(${BINARY_CONTRAINTS} PARENT_SCOPE)
  if(EXISTS ${WORKSPACE_DIR}/configurations/${config_name}/check_${config_name}.cmake)

    reset_Configuration_Cache_Variables(${config_name}) #reset the output variables to ensure a good result

    include(${WORKSPACE_DIR}/configurations/${config_name}/check_${config_name}.cmake)#get the description of the configuration check

    #now preparing args passed to the configruation (generate cmake variables)
    if(${config_args})#testing if the variable containing arguments is not empty
      prepare_Configuration_Arguments(${config_name} ${config_args})#setting variables that correspond to the arguments passed to the check script
    endif()
    check_Configuration_Arguments(ARGS_TO_SET ${config_name})
    if(ARGS_TO_SET)#there are unset required arguments
      fill_String_From_List(ARGS_TO_SET RES_STRING)
      message("[PID] WARNING : when checking arguments of configuration ${config_name}, there are required arguments that are not set : ${RES_STRING}")
      set(${CHECK_OK} FALSE PARENT_SCOPE)
      return()
    endif()

    # finding artifacts to fulfill system configuration
    find_Configuration(FOUND ${config_name})
    set(${config_name}_CONFIG_AVAILABLE TRUE)
    if(NOT FOUND)
    	install_Configuration(INSTALLED ${config_name})
    	if(NOT INSTALLED)
        set(${config_name}_CONFIG_AVAILABLE FALSE)
      endif()
    endif()

    if(NOT ${config_name}_CONFIG_AVAILABLE)#configuration is available so we can generate output variables
      set(${CHECK_OK} FALSE PARENT_SCOPE)
      return()
    endif()

    # checking dependencies
    foreach(check IN LISTS ${config_name}_CONFIGURATION_DEPENDENCIES)
      check_System_Configuration(RESULT_OK CONFIG_NAME CONFIG_CONSTRAINTS ${check})#check that dependencies are OK
      if(NOT RESULT_OK)
        message("[PID] WARNING : when checking configuration of current platform, configuration ${check}, used by ${config_name} cannot be satisfied.")
        set(${CHECK_OK} FALSE PARENT_SCOPE)
        return()
      endif()
    endforeach()

    #extracting variables to make them usable in calling context
    extract_Configuration_Resulting_Variables(${config_name})

    #return the complete set of binary contraints
    get_Configuration_Resulting_Constraints(ALL_CONSTRAINTS ${config_name})

    set(${BINARY_CONTRAINTS} ${ALL_CONSTRAINTS} PARENT_SCOPE)#automatic appending constraints generated by the configuration itself for the given binary package generated
    set(${CHECK_OK} TRUE PARENT_SCOPE)
  else()
    message("[PID] WARNING : when checking constraints on current platform, configuration information for ${config_name} does not exists. You use an unknown constraint. Please remove this constraint or create a new cmake script file called check_${config_name}.cmake in ${WORKSPACE_DIR}/configurations/${config_name} to manage this configuration.")
    set(${CHECK_OK} FALSE PARENT_SCOPE)
  endif()
endfunction(check_System_Configuration_With_Arguments)


#.rst:
#
# .. ifmode:: internal
#
#  .. |into_Configuration_Argument_List| replace:: ``into_Configuration_Argument_List``
#  .. _into_Configuration_Argument_List:
#
#  into_Configuration_Argument_List
#  --------------------------------
#
#   .. command:: into_Configuration_Argument_List(ALLOWED config_name config_args)
#
#    Test if a configuration can be used with current platform.
#
#     :input: the parent_scope variable containing string delimited arguments.
#
#     :OUTPUT: the output variable containing column delimited arguments.
#
function(into_Configuration_Argument_List input OUTPUT)
  string(REPLACE ";" "," TEMP "${${input}}")
  string(REPLACE " " "" TEMP "${TEMP}")
  string(REPLACE "\t" "" TEMP "${TEMP}")
  set(${OUTPUT} ${TEMP} PARENT_SCOPE)
endfunction(into_Configuration_Argument_List)

#.rst:
#
# .. ifmode:: internal
#
#  .. |is_Allowed_System_Configuration| replace:: ``is_Allowed_System_Configuration``
#  .. _is_Allowed_System_Configuration:
#
#  is_Allowed_System_Configuration
#  -------------------------------
#
#   .. command:: is_Allowed_System_Configuration(ALLOWED config_name config_args)
#
#    Test if a configuration can be used with current platform.
#
#     :config_name: the name of the configuration (without argument).
#
#     :config_args: the constraints passed as arguments by the user of the configuration.
#
#     :ALLOWED: the output variable that is TRUE if configuration can be used.
#
function(is_Allowed_System_Configuration ALLOWED config_name config_args)
  set(${ALLOWED} TRUE PARENT_SCOPE)
  if( EXISTS ${WORKSPACE_DIR}/configurations/${config_name}/check_${config_name}.cmake
      AND EXISTS ${WORKSPACE_DIR}/configurations/${config_name}/find_${config_name}.cmake)

    reset_Configuration_Cache_Variables(${config_name}) #reset the output variables to ensure a good result

    include(${WORKSPACE_DIR}/configurations/${config_name}/check_${config_name}.cmake)#get the description of the configuration check

    #now preparing args passed to the configruation (generate cmake variables)
    if(${config_args})#testing if the variable containing arguments is not empty
      prepare_Configuration_Arguments(${config_name} ${config_args})#setting variables that correspond to the arguments passed to the check script
    endif()
    check_Configuration_Arguments(ARGS_TO_SET ${config_name})
    if(ARGS_TO_SET)#there are unset required arguments
      fill_String_From_List(ARGS_TO_SET RES_STRING)
      message("[PID] WARNING : when testing arguments of configuration ${config_name}, there are required arguments that are not set : ${RES_STRING}")
      set(${ALLOWED} FALSE PARENT_SCOPE)
      return()
    endif()

    # checking dependencies first
    foreach(check IN LISTS ${config_name}_CONFIGURATION_DEPENDENCIES)
      parse_Configuration_Constraints(CONFIG_NAME CONFIG_ARGS "${check}")
      if(NOT CONFIG_NAME)
        set(${ALLOWED} FALSE PARENT_SCOPE)
        return()
      endif()
      is_Allowed_System_Configuration(DEP_ALLOWED CONFIG_NAME CONFIG_ARGS)
      if(NOT DEP_ALLOWED)
        set(${ALLOWED} FALSE PARENT_SCOPE)
        return()
      endif()
    endforeach()

    include(${WORKSPACE_DIR}/configurations/${config_name}/find_${config_name}.cmake)	# find the artifact from the configuration
    if(NOT ${config_name}_FOUND)# not found, trying to see if it can be installed
      if(EXISTS ${WORKSPACE_DIR}/configurations/${config_name}/installable_${config_name}.cmake)
        include(${WORKSPACE_DIR}/configurations/${config_name}/installable_${config_name}.cmake)
        if(NOT ${config_name}_INSTALLABLE)
          set(${ALLOWED} FALSE PARENT_SCOPE)
          return()
        endif()
      else()
        set(${ALLOWED} FALSE PARENT_SCOPE)
        return()
      endif()
    endif()
  else()
    message("[PID] WARNING : configuration ${config_name} is unknown in workspace.")
    set(${ALLOWED} FALSE PARENT_SCOPE)
    return()
  endif()
endfunction(is_Allowed_System_Configuration)

#FROM here

#.rst:
#
# .. ifmode:: internal
#
#  .. |find_Configuration| replace:: ``find_Configuration``
#  .. _find_Configuration:
#
#  find_Configuration
#  ------------------
#
#   .. command:: find_Configuration(FOUND config)
#
#   Call the procedure for finding artefacts related to a configuration.
#
#     :config: the name of the configuration to find.
#
#     :FOUND: the output variable that is TRUE is configuration has been found, FALSE otherwise.
#
macro(find_Configuration FOUND config)
  set(${FOUND} FALSE)
  if(EXISTS ${WORKSPACE_DIR}/configurations/${config}/find_${config}.cmake)
    include(${WORKSPACE_DIR}/configurations/${config}/find_${config}.cmake)
    if(${config}_CONFIG_FOUND)
      set(${FOUND} TRUE)
    endif()
  endif()
endmacro(find_Configuration)

#.rst:
#
# .. ifmode:: internal
#
#  .. |is_Configuration_Installable| replace:: ``is_Configuration_Installable``
#  .. _is_Configuration_Installable:
#
#  is_Configuration_Installable
#  ----------------------------
#
#   .. command:: is_Configuration_Installable(INSTALLABLE config)
#
#   Call the procedure telling if a configuratio can be installed.
#
#     :config: the name of the configuration to install.
#
#     :INSTALLABLE: the output variable that is TRUE is configuartion can be installed, FALSE otherwise.
#
macro(is_Configuration_Installable INSTALLABLE config)
  set(${INSTALLABLE} FALSE)
  if(EXISTS ${WORKSPACE_DIR}/configurations/${config}/installable_${config}.cmake)
    include(${WORKSPACE_DIR}/configurations/${config}/installable_${config}.cmake)
    if(${config}_INSTALLABLE)
      set(${INSTALLABLE} TRUE)
    endif()
  endif()
endmacro(is_Configuration_Installable)

#.rst:
#
# .. ifmode:: internal
#
#  .. |install_Configuration| replace:: ``install_Configuration``
#  .. _install_Configuration:
#
#  install_Configuration
#  ---------------------
#
#   .. command:: install_Configuration(INSTALLED config)
#
#   Call the install procedure of a given configuration.
#
#     :config: the name of the configuration to install.
#
#     :INSTALLED: the output variable that is TRUE is configuartion has been installed, FALSE otherwise.
#
macro(install_Configuration INSTALLED config)
  set(${INSTALLED} FALSE)
  is_Configuration_Installable(INSTALLABLE ${config})
  if(INSTALLABLE)
    message("[PID] INFO : installing configuration ${config}...")
  	if(EXISTS ${WORKSPACE_DIR}/configurations/${config}/install_${config}.cmake)
      include(${WORKSPACE_DIR}/configurations/${config}/install_${config}.cmake)
      find_Configuration(FOUND ${config})
      if(FOUND)
        message("[PID] INFO : configuration ${config} installed !")
        set(${INSTALLED} TRUE)
      else()
        message("[PID] WARNING : install of configuration ${config} has failed !")
      endif()
    endif()
  endif()
endmacro(install_Configuration)

#.rst:
#
# .. ifmode:: internal
#
#  .. |reset_Configuration_Cache_Variables| replace:: ``reset_Configuration_Cache_Variables``
#  .. _reset_Configuration_Cache_Variables:
#
#  reset_Configuration_Cache_Variables
#  -----------------------------------
#
#   .. command:: reset_Configuration_Cache_Variables(config)
#
#   Reset all cache variables relatied to the given configuration
#
#     :config: the name of the configuration to be reset.
#
function(reset_Configuration_Cache_Variables config)
  if(${config}_RETURNED_VARIABLES)
    foreach(var IN LISTS ${config}_RETURNED_VARIABLES)
      set(${config}_${var} CACHE INTERNAL "")
    endforeach()
    set(${config}_RETURNED_VARIABLES CACHE INTERNAL "")
  endif()
  set(${config}_FOUND FALSE CACHE INTERNAL "")
  set(${config}_REQUIRED_CONSTRAINTS CACHE INTERNAL "")
  set(${config}_OPTIONAL_CONSTRAINTS CACHE INTERNAL "")
  foreach(constraint IN LISTS ${config}_IN_BINARY_CONSTRAINTS)
    set(${config}_${constraint}_BINARY_VALUE CACHE INTERNAL "")
  endforeach()
  set(${config}_IN_BINARY_CONSTRAINTS CACHE INTERNAL "")
  set(${config}_CONFIGURATION_DEPENDENCIES CACHE INTERNAL "")
endfunction(reset_Configuration_Cache_Variables)


#.rst:
#
# .. ifmode:: internal
#
#  .. |extract_Configuration_Resulting_Variables| replace:: ``extract_Configuration_Resulting_Variables``
#  .. _extract_Configuration_Resulting_Variables:
#
#  extract_Configuration_Resulting_Variables
#  -----------------------------------------
#
#   .. command:: extract_Configuration_Resulting_Variables(config)
#
#     Get the list of constraints that should apply to a given configuration when used in a binary.
#
#     :config: the name of the configuration to be checked.
#
function(extract_Configuration_Resulting_Variables config)
  #updating output variables from teh value of variables specified by PID_Configuration_Variables
  foreach(var IN LISTS ${config}_RETURNED_VARIABLES)
    #the content of ${config}_${var}_RETURNED_VARIABLE is the name of a variable so need to get its value using ${}
    set(${config}_${var} ${${${config}_${var}_RETURNED_VARIABLE}} CACHE INTERNAL "")
  endforeach()
endfunction(extract_Configuration_Resulting_Variables)


#.rst:
#
# .. ifmode:: internal
#
#  .. |check_Configuration_Arguments| replace:: ``check_Configuration_Arguments``
#  .. _check_Configuration_Arguments:
#
#  check_Configuration_Arguments
#  -----------------------------
#
#   .. command:: check_Configuration_Arguments(ARGS_TO_SET config)
#
#     Check if all required arguments for the configuration are set before checking the configuration.
#
#     :config: the name of the configuration to be checked.
#
#     :ARGS_TO_SET: the parent scope variable containing the list of required arguments that have not been set by user.
#
function(check_Configuration_Arguments ARGS_TO_SET config)
  set(list_of_args)
  foreach(arg IN LISTS ${config}_REQUIRED_CONSTRAINTS)
    if(NOT ${config}_${arg} AND NOT ${config}_${arg} EQUAL 0 AND NOT ${config}_${arg} STREQUAL "FALSE")
      list(APPEND list_of_args ${arg})
    endif()
  endforeach()
  set(${ARGS_TO_SET} ${list_of_args} PARENT_SCOPE)
endfunction(check_Configuration_Arguments)

#.rst:
#
# .. ifmode:: internal
#
#  .. |prepare_Configuration_Arguments| replace:: ``prepare_Configuration_Arguments``
#  .. _prepare_Config_Arguments:
#
#  prepare_Configuration_Arguments
#  -------------------------------
#
#   .. command:: prepare_Configuration_Arguments(config arguments)
#
#     Set the variables corresponding to configuration arguments in the parent scope.
#
#     :config: the name of the configuration to be checked.
#
#     :arguments: the parent scope variable containing the list of arguments generated from parse_Configuration_Constraints.
#
function(prepare_Configuration_Arguments config arguments)
  if(NOT arguments OR NOT ${arguments})
    return()
  endif()
  set(argument_couples ${${arguments}})
  while(argument_couples)
    list(GET argument_couples 0 name)
    list(GET argument_couples 1 value)
    list(REMOVE_AT argument_couples 0 1)#update the list of arguments in parent scope
    string(REPLACE " " "" VAL_LIST "${value}")#remove the spaces in the string if any
    string(REPLACE "," ";" VAL_LIST "${VAL_LIST}")#generate a cmake list (with ";" as delimiter) from an argument list (with "," delimiter)
    list(FIND ${config}_REQUIRED_CONSTRAINTS ${name} INDEX)
    set(GENERATE_VAR FALSE)
    if(NOT INDEX EQUAL -1)
      set(GENERATE_VAR TRUE)
    else()
      list(FIND ${config}_OPTIONAL_CONSTRAINTS ${name} INDEX)
      if(NOT INDEX EQUAL -1)
        set(GENERATE_VAR TRUE)
      else()
        list(FIND ${config}_IN_BINARY_CONSTRAINTS ${name} INDEX)
        if(NOT INDEX EQUAL -1)
          set(GENERATE_VAR TRUE)
        endif()
      endif()
    endif()
    if(GENERATE_VAR)
      #now interpret variables contained in the list
      set(final_list_of_values)
      foreach(element IN LISTS VAL_LIST)#for each value in the list
        if(element AND DEFINED ${element})#element is a variable
          list(APPEND final_list_of_values ${${element}})
        else()
          list(APPEND final_list_of_values ${element})
        endif()
      endforeach()
      set(${config}_${name} ${final_list_of_values} PARENT_SCOPE)
    endif()
  endwhile()
endfunction(prepare_Configuration_Arguments)

#.rst:
#
# .. ifmode:: internal
#
#  .. |get_Configuration_Resulting_Constraints| replace:: ``get_Configuration_Resulting_Constraints``
#  .. _get_Configuration_Resulting_Constraints:
#
#  get_Configuration_Resulting_Constraints
#  ---------------------------------------
#
#   .. command:: get_Configuration_Resulting_Constraints(BINARY_CONSTRAINTS config)
#
#     Get the list of constraints that should apply to a given configuration when used in a binary.
#
#     :config: the name of the configuration to be checked.
#
#     :BINARY_CONSTRAINTS: the output variable the contains the list of constraints to be used in binaries (pair name-value).
#
function(get_Configuration_Resulting_Constraints BINARY_CONSTRAINTS config)

#updating all constraints to apply in binary package, they correspond to variable that will be outputed
foreach(constraint IN LISTS ${config}_REQUIRED_CONSTRAINTS)
  set(VAL_LIST ${${config}_${constraint}})
  string(REPLACE " " "" VAL_LIST "${VAL_LIST}")#remove the spaces in the string if any
  string(REPLACE ";" "," VAL_LIST "${VAL_LIST}")#generate a configuration argument list (with "," as delimiter) from an argument list (with "," delimiter)
  list(APPEND all_constraints ${constraint} "${VAL_LIST}")#use guillemet to set exactly one element
endforeach()

foreach(constraint IN LISTS ${config}_IN_BINARY_CONSTRAINTS)
  set(VAL_LIST "${${${config}_${constraint}_BINARY_VALUE}}")#interpret the value of the adequate configuration generated internal variable
  if(NOT VAL_LIST)#list is empty
    list(APPEND all_constraints ${constraint} "\"\"")#specific case: dealing with an empty value
  else()
    string(REPLACE " " "" VAL_LIST "${VAL_LIST}")#remove the spaces in the string if any
    string(REPLACE ";" "," VAL_LIST "${VAL_LIST}")#generate a configuration argument list (with "," as delimiter) from an argument list (with "," delimiter)
    list(APPEND all_constraints ${constraint} "${VAL_LIST}")#use guillemet to set exactly one element
  endif()
endforeach()

#optional constraints are never propagated to binaries description
set(${BINARY_CONSTRAINTS} ${all_constraints} PARENT_SCOPE)#the value of the variable is not the real value but the name of the variable

endfunction(get_Configuration_Resulting_Constraints)
