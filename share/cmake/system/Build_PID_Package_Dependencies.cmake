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
#	You can be find the complete license description on the official website 	#
#	of the CeCILL licenses family (http://www.cecill.info/index.en.html)		#
#########################################################################################

list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/system)


			
if(DEPENDENT_PACKAGES)
	SEPARATE_ARGUMENTS(DEPENDENT_PACKAGES)
	foreach(dep_pack IN ITEMS ${DEPENDENT_PACKAGES})
		execute_process (COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${dep_pack}/build ${BUILD_TOOL} build)
	endforeach()
else()
	message("[ERROR] : no package to build !")
endif()


