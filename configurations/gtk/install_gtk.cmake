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

function(install_GTK_Version version)
if(	CURRENT_DISTRIBUTION STREQUAL ubuntu
	OR CURRENT_DISTRIBUTION STREQUAL debian)
	if(version EQUAL 2)
		execute_OS_Configuration_Command(apt-get install -y libgtk2.0-dev libgtkmm-2.4-dev)
	elseif(version EQUAL 3)
		execute_OS_Configuration_Command(apt-get install -y libgtkmm-3.0-dev)
	endif()
elseif(	CURRENT_DISTRIBUTION STREQUAL arch)
	if(version EQUAL 2)
		execute_OS_Configuration_Command(pacman -S gtk2 gtkmm --noconfirm)
	elseif(version EQUAL 3)
		execute_OS_Configuration_Command(pacman -S gtkmm3 --noconfirm)
	endif()
endif()
endfunction(install_GTK_Version)

if(gtk_version)
		install_GTK_Version(${gtk_version})
elseif(gtk_preferred)
		list(GET gtk_preferred 0 best_version)
		install_GTK_Version(${best_version})
endif()
