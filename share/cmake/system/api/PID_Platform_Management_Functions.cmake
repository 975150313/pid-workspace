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
		if(CURRENT_PLATFORM AND NOT CURRENT_PLATFORM STREQUAL "")# a current platform is already defined
			#if any of the following variable changed, the cache of the CMake project needs to be regenerated from scratch
			set(TEMP_PLATFORM ${CURRENT_PLATFORM})
			set(TEMP_C_COMPILER ${CMAKE_C_COMPILER})
			set(TEMP_CXX_COMPILER ${CMAKE_CXX_COMPILER})
			set(TEMP_CMAKE_LINKER ${CMAKE_LINKER})
			set(TEMP_CMAKE_RANLIB ${CMAKE_RANLIB})
			set(TEMP_CMAKE_CXX_COMPILER_ID ${CMAKE_CXX_COMPILER_ID})
			set(TEMP_CMAKE_CXX_COMPILER_VERSION ${CMAKE_CXX_COMPILER_VERSION})
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
