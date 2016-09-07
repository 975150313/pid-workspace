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

include(${WORKSPACE_DIR}/share/cmake/constraints/configurations/imagemagic/installable_imagemagic.cmake)
if(imagemagic_INSTALLABLE)
	message("[PID] INFO : trying to install imagemagic and some of its related packages...")
	execute_process(COMMAND sudo apt-get install imagemagick libmagick++-dev libx264-dev)
	include(${WORKSPACE_DIR}/share/cmake/constraints/configurations/imagemagic/find_imagemagic.cmake)
	if(imagemagic_FOUND)
		message("[PID] INFO : imagemagic installed !")
		set(imagemagic_INSTALLED TRUE)
	else()
		set(imagemagic_INSTALLED FALSE)
		message("[PID] INFO : install of imagemagic has failed !")
	endif()
else()
	set(imagemagic_INSTALLED FALSE)
endif()

