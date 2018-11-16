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

include(Configuration_Definition NO_POLICY_SCOPE)

found_PID_Configuration(freetype2 FALSE)

# - Find freetype2 installation
# Try to find libraries for freetype2 on UNIX systems. The following values are defined
#  freetype2_FOUND        - True if freetype2 is available
#  freetype2_LIBRARIES    - link against these to use freetype2 library
if (UNIX)

	find_path(freetype2_INCLUDE_PATH freetype2/ft2build.h)
	find_library(freetype2_LIB freetype)

	set(freetype2_LIBRARIES) # start with empty list
	set(IS_FOUND TRUE)
	if(freetype2_INCLUDE_PATH AND freetype2_LIB)
		convert_PID_Libraries_Into_System_Links(freetype2_LIB freetype2_LINKS)#getting good system links (with -l)
		convert_PID_Libraries_Into_Library_Directories(freetype2_LIB freetype2_LIBDIR)#getting good system libraries folders (to be used with -L)
	else()
		message("[PID] ERROR : cannot find freetype2 library.")
		set(IS_FOUND FALSE)
	endif()

	if(IS_FOUND)
		found_PID_Configuration(freetype2 TRUE)
	endif ()

	unset(IS_FOUND)
	unset(freetype2_INCLUDE_PATH CACHE)
	unset(freetype2_LIB CACHE)
endif ()
