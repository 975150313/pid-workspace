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


if(	CURRENT_DISTRIBUTION STREQUAL ubuntu
	OR CURRENT_DISTRIBUTION STREQUAL debian)
	if(gtk_version EQUAL 2)
		execute_process(COMMAND sudo apt-get install -y libgtk2.0-dev libgtkmm-2.4-dev)
	elseif(gtk_version EQUAL 3)
		execute_process(COMMAND sudo apt-get install -y libgtkmm-3.0-dev)
	endif()
elseif(	CURRENT_DISTRIBUTION STREQUAL arch)
	if(gtk_version EQUAL 2)
		execute_process(COMMAND sudo pacman -S gtk2 gtkmm)
	elseif(gtk_version EQUAL 3)
		execute_process(COMMAND sudo pacman -S gtkmm3)
	endif()
endif()
