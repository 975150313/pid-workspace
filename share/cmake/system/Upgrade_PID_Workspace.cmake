#########################################################################################
#	This file is part of the program PID						#
#  	Program description : build system supportting the PID methodology  		#
#  	Copyright (C) Robin Passama, LIRMM (Laboratoire d'Informatique de Robotique 	#
#	et de Microelectronique de Montpellier). All Right reserved.			#
#											#
#	This software is free software: you can redistribute it and/or modify		#
#	it under the terms of the CeCILL-C license as published by			#
#	the CEA CNRS INRIA, either version 1						#
#	of the License, or (at your option) any later version.				#
#	This software is distributed in the hope that it will be useful,		#
#	but WITHOUT ANY WARRANTY; without even the implied warranty of			#
#	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the			#
#	CeCILL-C License for more details.						#
#											#
#	You can find the complete license description on the official website 		#
#	of the CeCILL licenses family (http://www.cecill.info/index.en.html)		#
#########################################################################################


list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/system)
include(PID_Workspace_Internal_Functions NO_POLICY_SCOPE)

# needed to parse adequately CMAKe variables passed to the script
SEPARATE_ARGUMENTS(CMAKE_SYSTEM_PROGRAM_PATH)
SEPARATE_ARGUMENTS(CMAKE_SYSTEM_INCLUDE_PATH)
SEPARATE_ARGUMENTS(CMAKE_SYSTEM_LIBRARY_PATH)
SEPARATE_ARGUMENTS(CMAKE_FIND_LIBRARY_PREFIXES)
SEPARATE_ARGUMENTS(CMAKE_FIND_LIBRARY_SUFFIXES)
SEPARATE_ARGUMENTS(CMAKE_SYSTEM_PREFIX_PATH)

## global management of the process
remove_Progress_File() #reset the build progress information (sanity action)
begin_Progress(workspace NEED_REMOVE)

if(UPDATE_ALL_PACKAGES STREQUAL ON)
	set(UPDATE_PACKS TRUE)
else()
	set(UPDATE_PACKS FALSE)
endif()
if(TARGET_OFFICIAL STREQUAL OFF)
	set(TARGET_REMOTE origin)
else()	#by default using official remote (where all official references are from)
	set(TARGET_REMOTE official)
endif()
upgrade_Workspace(${TARGET_REMOTE} ${UPDATE_PACKS})

## global management of the process
if(UPDATE_PACKS)
	message("--------------------------------------------")
	message("All packages deployed during this process : ")
	print_Deployed_Packages()
endif()
finish_Progress(TRUE) #reset the build progress information
