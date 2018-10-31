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

set(cuda_FOUND FALSE CACHE INTERNAL "")
# - Find cuda installation
# Try to find libraries for cuda on UNIX systems. The following values are defined
#  cuda_FOUND        - True if cuda is available
#  cuda_LIBRARIES    - link against these to use cuda library

set(CUDA_USE_STATIC_CUDA_RUNTIME FALSE CACHE INTERNAL "" FORCE)
if(CUDA_VERSION)#if the CUDA version is known (means that a nvcc compiler has been defined)
	if(NOT cuda_architecture) #no architecture defined => take the default one
		set(cuda_FOUND TRUE CACHE INTERNAL "")
		set(USED_cuda_architecture ${DEFAULT_CUDA_ARCH} CACHE INTERNAL "")
		#TODO detect current architecture
	else() #there is a target architecture defined
		#need check to check if architecture is compatible with nvcc compiler
		set(USED_cuda_architecture ${cuda_architecture} CACHE INTERNAL "")
		#TODO detect possible architecture for nvcc then compare
	endif()
endif()
