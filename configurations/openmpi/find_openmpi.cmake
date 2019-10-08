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

macro(set_openmpi_version)
  #need to extract OpenMPI version
  find_path(OMPI_INCLUDE_DIR NAMES mpi.h PATHS ${MPI_C_INCLUDE_DIRS})
  file(READ ${OMPI_INCLUDE_DIR}/mpi.h OMPI_VERSION_FILE_CONTENTS)
  string(REGEX MATCH "define OMPI_MAJOR_VERSION * +([0-9]+)"
        OMPI_MAJOR_VERSION "${OMPI_VERSION_FILE_CONTENTS}")
  string(REGEX REPLACE "define OMPI_MAJOR_VERSION * +([0-9]+)" "\\1"
        OMPI_MAJOR_VERSION "${OMPI_MAJOR_VERSION}")
  string(REGEX MATCH "define OMPI_MINOR_VERSION * +([0-9]+)"
        OMPI_MINOR_VERSION "${OMPI_VERSION_FILE_CONTENTS}")
  string(REGEX REPLACE "define OMPI_MINOR_VERSION * +([0-9]+)" "\\1"
        OMPI_MINOR_VERSION "${OMPI_MINOR_VERSION}")
  string(REGEX MATCH "define OMPI_RELEASE_VERSION * +([0-9]+)"
        OMPI_PATCH_VERSION "${OMPI_VERSION_FILE_CONTENTS}")
  string(REGEX REPLACE "define OMPI_RELEASE_VERSION * +([0-9]+)" "\\1"
        OMPI_PATCH_VERSION "${OMPI_PATCH_VERSION}")
  set(OMPI_VERSION ${OMPI_MAJOR_VERSION}.${OMPI_MINOR_VERSION}.${OMPI_PATCH_VERSION})

  #Check MPI less version
  if (MPI_C_VERSION AND MPI_CXX_VERSION) # check if version is set (cmake version <3.10 is not set)
    if(MPI_C_VERSION LESS_EQUAL MPI_CXX_VERSION)
      set(MPI_VERSION ${MPI_C_VERSION})
    else()
      set(MPI_VERSION ${MPI_CXX_VERSION})
    endif()
  endif()
endmacro(set_openmpi_version)

macro(set_openmpi_variables)
  # Extract and make list with all links Flags
  convert_PID_Libraries_Into_System_Links(MPI_C_LIBRARIES MPI_C_LINKS)#getting good system links (with -l)
  list(APPEND MPI_C_LINKS "-lpthread") #don't add MPI_C_LINK_FLAGS (not used by PID)
  if(MPI_C_LINKS)
    list(REMOVE_DUPLICATES MPI_C_LINKS)
  endif()
  convert_PID_Libraries_Into_System_Links(MPI_CXX_LIBRARIES MPI_CXX_LINKS)#getting good system links (with -l)
  list(APPEND MPI_CXX_LINKS "-lpthread") #don't add MPI_CXX_LINK_FLAGS (not used by PID)
  if(MPI_CXX_LINKS)
    list(REMOVE_DUPLICATES MPI_CXX_LINKS)
  endif()

  convert_PID_Libraries_Into_Library_Directories(MPI_C_LIBRARIES MPI_C_LIBRARY_DIRS)
  convert_PID_Libraries_Into_Library_Directories(MPI_CXX_LIBRARIES MPI_CXX_LIBRARY_DIRS)

  # Create vars whith all <lang> datas
  list(APPEND MPI_COMPILER ${MPI_C_COMPILER} ${MPI_CXX_COMPILER})
  if(MPI_COMPILER)
    list(REMOVE_DUPLICATES MPI_COMPILER)
  endif()
  list(APPEND MPI_COMPILE_FLAGS ${MPI_C_COMPILE_FLAGS} ${MPI_CXX_COMPILE_FLAGS})
  if(MPI_COMPILE_FLAGS)
    list(REMOVE_DUPLICATES MPI_COMPILE_FLAGS)
  endif()
  list(APPEND MPI_INCLUDE_DIRS ${MPI_C_INCLUDE_DIRS} ${MPI_CXX_INCLUDE_DIRS})
  if(MPI_INCLUDE_DIRS)
    list(REMOVE_DUPLICATES MPI_INCLUDE_DIRS)
  endif()
  list(APPEND MPI_LINK_FLAGS ${MPI_C_LINKS} ${MPI_CXX_LINKS})
  if(MPI_LINK_FLAGS)
    list(REMOVE_DUPLICATES MPI_LINK_FLAGS)
  endif()
  list(APPEND MPI_LIBRARIES ${MPI_C_LIBRARIES} ${MPI_CXX_LIBRARIES})
  if(MPI_LIBRARIES)
    list(REMOVE_DUPLICATES MPI_LIBRARIES)
  endif()
  list(APPEND MPI_LIBRARY_DIRS ${MPI_C_LIBRARY_DIRS} ${MPI_CXX_LIBRARY_DIRS})
  if(MPI_LIBRARY_DIRS)
    list(REMOVE_DUPLICATES MPI_LIBRARY_DIRS)
  endif()
endmacro(set_openmpi_variables)

found_PID_Configuration(openmpi FALSE)

# findMPI need to be use in a "non script" environment (try_compile function)
# so we create a separate project (test_mpi) to generate usefull vars and extract them in a file (openmpi_config_vars.cmake)
# and read this file in our context.

set(path_test_mpi ${WORKSPACE_DIR}/configurations/openmpi/test_mpi/build/${CURRENT_PLATFORM})
set(path_mpi_config_vars ${path_test_mpi}/openmpi_config_vars.cmake )

if(EXISTS ${path_mpi_config_vars})#file already computed
	include(${path_mpi_config_vars}) #just to check that same version is required
	if(MPI_C_FOUND AND MPI_CXX_FOUND)#optimization only possible if openMPI has been found
    set_openmpi_version()
    if(NOT openmpi_version #no specific version to search for
			OR openmpi_version VERSION_EQUAL OMPI_VERSION)# or same version required and already found no need to regenerate
        set_openmpi_variables()
      	found_PID_Configuration(openmpi TRUE)
      return()#exit without regenerating (avoid regenerating between debug and release builds due to generated file timestamp change)
			#also an optimization avoid launching again and again boost config for each package build in debug and release modes (which is widely used)
		endif()
	endif()
endif()

# execute separate project to extract datas
if(NOT EXISTS ${path_test_mpi})
	file(MAKE_DIRECTORY ${path_test_mpi})
endif()

execute_process(COMMAND ${CMAKE_COMMAND} ${WORKSPACE_DIR}/configurations/openmpi/test_mpi
                WORKING_DIRECTORY ${path_test_mpi} OUTPUT_QUIET)

# Extract datas from openmpi_config_vars.cmake
if(EXISTS ${path_mpi_config_vars} )
  include(${path_mpi_config_vars})
else()
  if(ADDITIONNAL_DEBUG_INFO)
    message("[PID] WARNING : cannot execute tests for OpenMPI !")
  endif()
  return()
endif()

if(MPI_C_FOUND AND MPI_CXX_FOUND)
  set_openmpi_version()
  if(NOT openmpi_version #no specific version to search for
    OR openmpi_version VERSION_EQUAL OMPI_VERSION)# or same version required and already found no need to regenerate
    set_openmpi_variables()
  	found_PID_Configuration(openmpi TRUE)
    return()
  endif()
endif()
if(ADDITIONNAL_DEBUG_INFO)
  message("[PID] WARNING : cannot find OpenMPI library !")
endif()
