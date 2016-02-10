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

macro(find_Posix)

set(posix_FOUND FALSE)
# - Find posix installation
# Try to find libraries for posix on UNIX systems. The following values are defined
#  posix_FOUND        - True if posix is available
#  posix_LIBRARIES    - link against these to use posix system
if (UNIX)

	# posix is never a framework and some header files may be
	# found in tcl on the mac
	set(CMAKE_FIND_FRAMEWORK_SAVE ${CMAKE_FIND_FRAMEWORK})
	set(CMAKE_FIND_FRAMEWORK NEVER)

	# MODIFICATION for our needs: must be in default system folders so do not provide additionnal folders !!!!!
	find_path(posix_pthread_INCLUDE_PATH pthread.h)
	find_path(posix_rt_INCLUDE_PATH time.h)
	find_path(posix_dl_INCLUDE_PATH dlfcn.h)
	find_path(posix_math_INCLUDE_PATH math.h)

	find_library(posix_pthread_LIB pthread) 
	find_library(posix_rt_LIB rt)
	find_library(posix_dl_LIB dl)
	find_library(posix_math_LIB m)
	

	set(posix_LIBRARIES) # start with empty list
	set(IS_FOUND TRUE)
	if(posix_pthread_INCLUDE_PATH AND posix_pthread_LIB)
		set(posix_LIBRARIES ${posix_LIBRARIES} -lpthread)
	else()
		message("[PID] ERROR : when finding posix framework, cannot find pthread library.")
		set(IS_FOUND FALSE)
	endif()

	if(posix_rt_INCLUDE_PATH AND posix_rt_LIB)
		set(posix_LIBRARIES ${posix_LIBRARIES} -lrt)
	else()
		message("[PID] ERROR : when finding posix framework, cannot find rt library.")
		set(IS_FOUND FALSE)
	endif()

	if(posix_dl_INCLUDE_PATH AND posix_dl_LIB)
		set(posix_LIBRARIES ${posix_LIBRARIES} -ldl)
	else()
		message("[PID] ERROR : when finding posix framework, cannot find dl library.")
		set(IS_FOUND FALSE)
	endif()

	if(posix_math_INCLUDE_PATH AND posix_math_LIB)
		set(posix_LIBRARIES ${posix_LIBRARIES} -lm)
	else()
		message("[PID] ERROR : when finding posix framework, cannot find math library.")
		set(IS_FOUND FALSE)
	endif()

	if(NOT IS_FOUND)
		set(posix_FOUND FALSE)
	else()
		set(posix_FOUND TRUE)
	endif ()

	unset(IS_FOUND)
	unset(posix_pthread_INCLUDE_PATH CACHE)
	unset(posix_pthread_LIB CACHE)
	unset(posix_rt_INCLUDE_PATH CACHE)
	unset(posix_rt_LIB CACHE)
	set(CMAKE_FIND_FRAMEWORK ${CMAKE_FIND_FRAMEWORK_SAVE})
endif ()
endmacro(find_Posix)

if(NOT posix_FOUND) #any linux or macosx is posix ... 
	set(posix_COMPILE_OPTIONS CACHE INTERNAL "")
	set(posix_LINK_OPTIONS CACHE INTERNAL "")
	set(posix_RPATH CACHE INTERNAL "")
	find_Posix()
	if(posix_FOUND)
		set(posix_LINK_OPTIONS ${posix_LIBRARIES} CACHE INTERNAL "") #simply adding all posix standard libraries		
		set(posix_FOUND TRUE CACHE INTERNAL "")
		set(CHECK_posix_RESULT TRUE)
	else()
		set(posix_FOUND FALSE CACHE INTERNAL "")
		set(CHECK_posix_RESULT FALSE)
	endif()
endif()

