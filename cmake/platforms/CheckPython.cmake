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

set(CURRENT_PYTHON CACHE INTERNAL "")
set(CURRENT_PYTHON_EXECUTABLE CACHE INTERNAL "")
set(CURRENT_PYTHON_LIBRARIES CACHE INTERNAL "")
set(CURRENT_PYTHON_INCLUDE_DIRS CACHE INTERNAL "")
set(PYTHONINTERP_FOUND FALSE)
set(PYTHONLIBS_FOUND FALSE)
set(Python_Language_AVAILABLE FALSE CACHE INTERNAL "")

find_package(PythonInterp) # find the default python interpreter (but will be configured with python variable from toolchain file)

if(PYTHONINTERP_FOUND)
  set(PY_VERSION "${PYTHON_VERSION_MAJOR}.${PYTHON_VERSION_MINOR}")
  find_package(PythonLibs ${PY_VERSION}) #searching for libs with the adequate version
  if(PYTHONLIBS_FOUND)
    set(CURRENT_PYTHON ${PY_VERSION} CACHE INTERNAL "")
    set(CURRENT_PYTHON_EXECUTABLE "${PYTHON_EXECUTABLE}" CACHE INTERNAL "")
    set(CURRENT_PYTHON_LIBRARIES "${PYTHON_LIBRARIES}" CACHE INTERNAL "")
    set(CURRENT_PYTHON_INCLUDE_DIRS ${PYTHON_INCLUDE_DIRS} CACHE INTERNAL "")
    set(Python_Language_AVAILABLE TRUE CACHE INTERNAL "")
  endif()
endif()

#now identifying the python package manager
if(NOT CURRENT_PYTHON VERSION_LESS 3.0)
  set(pip_name "pip3")
else()#use python 2
  set(pip_name "pip")
endif()
find_program(PATH_TO_PIP ${pip_name})
if(PATH_TO_PIP)
  set(CURRENT_PYTHON_PACKAGER PIP CACHE INTERNAL "")
  set(CURRENT_PYTHON_PACKAGER_EXE ${pip_name} CACHE INTERNAL "")
  set(CURRENT_PYTHON_PACKAGER_EXE_OPTIONS install CACHE INTERNAL "")
else()
  set(CURRENT_PYTHON_PACKAGER CACHE INTERNAL "")
  set(CURRENT_PYTHON_PACKAGER_EXE CACHE INTERNAL "")
  set(CURRENT_PYTHON_PACKAGER_EXE_OPTIONS CACHE INTERNAL "")
endif()
