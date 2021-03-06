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
if(PID_VERSION_MANAGEMENT_FUNCTIONS_INCLUDED)
  return()
endif()
set(PID_VERSION_MANAGEMENT_FUNCTIONS_INCLUDED TRUE)
##########################################################################################

#.rst:
#
# .. ifmode:: internal
#
#  .. |init_PID_Version_Variable| replace:: ``init_PID_Version_Variable``
#  .. _init_PID_Version_Variable:
#
#  init_PID_Version_Variable
#  -------------------------
#
#   .. command:: init_PID_Version_Variable()
#
#     Initialize global variable describing the version of PID in use
#
function(init_PID_Version_Variable)
if(NOT EXISTS ${WORKSPACE_DIR}/pid/PID_version.cmake)#if workspace has not been built (or build files deleted), then build it to get the version
	execute_process(COMMAND ${CMAKE_COMMAND} ${WORKSPACE_DIR} WORKING_DIRECTORY ${WORKSPACE_DIR}/pid)
endif()
include(${WORKSPACE_DIR}/pid/PID_version.cmake) # get the current workspace version

if(	EXISTS ${CMAKE_SOURCE_DIR}/share/cmake/${PROJECT_NAME}_PID_Version.cmake)# get the workspace version with wich the package has been built
	#The file already resides in package shared files
	include(${CMAKE_SOURCE_DIR}/share/cmake/${PROJECT_NAME}_PID_Version.cmake)
	if(${PID_WORKSPACE_VERSION} LESS ${${PROJECT_NAME}_PID_VERSION})#workspace need to be updated
		update_Workspace_Repository("official")
		execute_process(COMMAND ${CMAKE_COMMAND} ${WORKSPACE_DIR} WORKING_DIRECTORY ${WORKSPACE_DIR}/pid)#reconfigure workspace
		include(${WORKSPACE_DIR}/pid/PID_version.cmake) # get the current workspace version AGAIN (most up to date version)
		if(${PID_WORKSPACE_VERSION} LESS ${${PROJECT_NAME}_PID_VERSION})#still less => impossible
			message("[PID] INFO : PID version ${${PROJECT_NAME}_PID_VERSION} of ${PROJECT_NAME} is corrupted ... regenerating version according to most up to date workspace.")
			set(${PROJECT_NAME}_PID_VERSION ${PID_WORKSPACE_VERSION} CACHE INTERNAL "")
			file(WRITE ${CMAKE_SOURCE_DIR}/share/cmake/${PROJECT_NAME}_PID_Version.cmake "set(${PROJECT_NAME}_PID_VERSION ${${PROJECT_NAME}_PID_VERSION} CACHE INTERNAL \"\")")#save the PID version with which the package has been built
		endif()
	#else if > the workspace version of scripts should be able to manage difference between versions by using the ${PROJECT_NAME}_PID_VERSION variable (inside package) or ${package_name}_PID_VERSION (outside package)
	endif()
else()
	set(${PROJECT_NAME}_PID_VERSION ${PID_WORKSPACE_VERSION})#if no version defined yet then set it to the current workspace one
	file(WRITE ${CMAKE_SOURCE_DIR}/share/cmake/${PROJECT_NAME}_PID_Version.cmake "set(${PROJECT_NAME}_PID_VERSION ${${PROJECT_NAME}_PID_VERSION} CACHE INTERNAL \"\")")#save the PID version with which the package has been built
endif()
endfunction(init_PID_Version_Variable)

#.rst:
#
# .. ifmode:: internal
#
#  .. |PID_Package_Is_With_Development_Info_In_Use_Files| replace:: ``PID_Package_Is_With_Development_Info_In_Use_Files``
#  .. _PID_Package_Is_With_Development_Info_In_Use_Files:
#
#  PID_Package_Is_With_Development_Info_In_Use_Files
#  -------------------------------------------------
#
#   .. command:: PID_Package_Is_With_Development_Info_In_Use_Files(RESULT package)
#
#     Tell wether target package in use has been developped with a version of PID that supports developer info in use files.
#
#      :package: the name of target package.
#
#      :RESULT: the output variable that is TRUE if package use file contains developer info.
#
function(PID_Package_Is_With_Development_Info_In_Use_Files RESULT package)
	if(NOT ${package}_PID_VERSION)
		set(${RESULT} FALSE PARENT_SCOPE)
		return()
	endif()
	if(${${package}_PID_VERSION} GREATER 1) #with packages generated with version > 1 we can find development info about packages
		set(${RESULT} TRUE PARENT_SCOPE)
	else()
		set(${RESULT} FALSE PARENT_SCOPE)
	endif()
endfunction(PID_Package_Is_With_Development_Info_In_Use_Files)

#.rst:
#
# .. ifmode:: internal
#
#  .. |PID_Package_Is_With_Site_Info_In_Use_Files| replace:: ``PID_Package_Is_With_Site_Info_In_Use_Files``
#  .. _PID_Package_Is_With_Site_Info_In_Use_Files:
#
#  PID_Package_Is_With_Site_Info_In_Use_Files
#  ------------------------------------------
#
#   .. command:: PID_Package_Is_With_Site_Info_In_Use_Files(RESULT package)
#
#     Tell wether target package in use has been developped with a version of PID that supports static site info in use files.
#
#      :package: the name of target package.
#
#      :RESULT: the output variable that is TRUE if package use file contains static site info.
#
function(PID_Package_Is_With_Site_Info_In_Use_Files RESULT package)
	if(NOT ${package}_PID_VERSION)
		set(${RESULT} FALSE PARENT_SCOPE)
		return()
	endif()
	if(${${package}_PID_VERSION} GREATER 1) #with packages generated with version > 1 we can find web site info about packages
		set(${RESULT} TRUE PARENT_SCOPE)
	else()
		set(${RESULT} FALSE PARENT_SCOPE)
	endif()
endfunction(PID_Package_Is_With_Site_Info_In_Use_Files)

#.rst:
#
# .. ifmode:: internal
#
#  .. |PID_Package_Is_With_V2_Platform_Info_In_Use_Files| replace:: ``PID_Package_Is_With_V2_Platform_Info_In_Use_Files``
#  .. _PID_Package_Is_With_V2_Platform_Info_In_Use_Files:
#
#  PID_Package_Is_With_V2_Platform_Info_In_Use_Files
#  -------------------------------------------------
#
#   .. command:: PID_Package_Is_With_V2_Platform_Info_In_Use_Files(RESULT package)
#
#     Tell wether target package in use has been developped with a version of PID that supports platform info Version 2 in use files.
#
#      :package: the name of target package.
#
#      :RESULT: the output variable that is TRUE if package use file contains new way to describe platform info.
#
function(PID_Package_Is_With_V2_Platform_Info_In_Use_Files RES package)
	if(NOT ${package}_PID_VERSION)
		set(${RES} FALSE PARENT_SCOPE)
		return()
	endif()
	if(${${package}_PID_VERSION} GREATER 1) #with packages generated with version > 1 we can find development info about packages
		set(${RES} TRUE PARENT_SCOPE)
	else()
		set(${RES} FALSE PARENT_SCOPE)
	endif()
endfunction(PID_Package_Is_With_V2_Platform_Info_In_Use_Files)
