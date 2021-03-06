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

found_PID_Configuration(boost FALSE)
set(components_to_search system filesystem ${boost_libraries})#boost_libraries used to check that components that user wants trully exist
list(REMOVE_DUPLICATES components_to_search)#using system and filesystem as these two libraries exist since early versions of boost

set(path_test_boost ${WORKSPACE_DIR}/configurations/boost/test_boost/build/${CURRENT_PLATFORM})# each result is conditionate by the current platform in use

if(EXISTS ${path_test_boost}/boost_config_vars.cmake)#file already computed
	include(${path_test_boost}/boost_config_vars.cmake) #just to check that same version is required
	if(Boost_Found)#optimization only possible if boost has been found
		if(NOT boost_version #no specific version to search for
			OR boost_version VERSION_EQUAL BOOST_VERSION)# or same version required and already found no need to regenerate
			#now simply have to check that components to search exist
			set(all_found TRUE)
			foreach(a_component IN LISTS components_to_search)
				list(FIND BOOST_COMPONENTS ${a_component} COMP_INDEX)
				if(COMP_INDEX EQUAL -1)#not found
					set(all_found FALSE)
					break()
				endif()
			endforeach()
			if(all_found)
				convert_PID_Libraries_Into_System_Links(Boost_LIBRARIES BOOST_LINKS)#getting good system links (with -l)
				convert_PID_Libraries_Into_Library_Directories(Boost_LIBRARIES BOOST_LIBRARY_DIRS)
				found_PID_Configuration(boost TRUE)
				unset(Boost_FOUND)
				return()#exit without regenerating (avoid regenerating between debug and release builds due to generated file timestamp change)
				#also an optimization avoid launching again and again boost config for each package build in debug and release modes (which is widely used)
			endif()
		endif()
	endif()
endif()
#any other situation implies a new configuration of the test project

set(calling_defs "-DBOOST_COMPONENTS_TO_SEARCH=${components_to_search}")
if(boost_version)
	set(calling_defs "-DBOOST_VERSION_TO_SEARCH=${boost_version} ${calling_defs}")
endif()

if(CMAKE_HOST_WIN32)#on a window host path must be resolved
	separate_arguments(COMMAND_ARGS_AS_LIST WINDOWS_COMMAND "${calling_defs}")
else()#if not on wondows use a UNIX like command syntac
	separate_arguments(COMMAND_ARGS_AS_LIST UNIX_COMMAND "${calling_defs}")#always from host perpective
endif()

if(NOT EXISTS ${path_test_boost})
	file(MAKE_DIRECTORY ${path_test_boost})
endif()
# execute separate project to extract datas
execute_process(COMMAND ${CMAKE_COMMAND} ${COMMAND_ARGS_AS_LIST} ${WORKSPACE_DIR}/configurations/boost/test_boost/
								WORKING_DIRECTORY ${path_test_boost} OUTPUT_QUIET)

# Extract datas from hdf5i_config_vars.cmake
set(path_boost_config_vars ${path_test_boost}/boost_config_vars.cmake )
if(EXISTS ${path_boost_config_vars} )
  include(${path_boost_config_vars})
else()
	if(ADDITIONNAL_DEBUG_INFO)
		message("[PID] WARNING : tests for Boost failed !")
	endif()
	return()
endif()

if(NOT Boost_FOUND)#check failed : due to missing searched component !!
	if(ADDITIONNAL_DEBUG_INFO)
		message("[PID] WARNING : tests for Boost not successfull !")
	endif()
	unset(Boost_FOUND)
	return()
endif()
convert_PID_Libraries_Into_System_Links(Boost_LIBRARIES BOOST_LINKS)#getting good system links (with -l)
convert_PID_Libraries_Into_Library_Directories(Boost_LIBRARIES BOOST_LIBRARY_DIRS)
found_PID_Configuration(boost TRUE)
unset(Boost_FOUND)
