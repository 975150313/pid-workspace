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

found_PID_Configuration(pcre3 FALSE)

# - Find pcre3 installation
# Try to find libraries for pcre3 on UNIX systems. The following values are defined
#  pcre3_FOUND        - True if pcre3 is available
#  pcre3_LIBRARIES    - link against these to use pcre3 library
if (UNIX)
	find_path(pcre3_INCLUDE_DIR pcre.h)
	find_library(pcre3_LIBRARY pcre)

	set(pcre3_INCLUDE_PATH ${pcre3_INCLUDE_DIR})
	set(pcre3_LIB ${pcre3_LIBRARY})
	unset(pcre3_INCLUDE_DIR CACHE)
	unset(pcre3_LIBRARY CACHE)

	if(pcre3_INCLUDE_PATH AND pcre3_LIB)
		convert_PID_Libraries_Into_System_Links(pcre3_LIB PCRE3_LINKS)#getting good system links (with -l)
		convert_PID_Libraries_Into_Library_Directories(pcre3_LIB PCRE3_LIBDIRS)

		found_PID_Configuration(pcre3 TRUE)
	else()
		message("[PID] ERROR : cannot find pcre3 library.")
	endif()
endif ()
