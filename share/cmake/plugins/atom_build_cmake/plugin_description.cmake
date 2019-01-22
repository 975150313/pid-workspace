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

set(atom_build_cmake_PLUGIN_DESCRIPTION "use this plugin to generate configuration files to be used with the build-cmake atom plugin" CACHE INTERNAL "")

set(atom_build_cmake_PLUGIN_ACTIVATION_MESSAGE "generating build configuration files..." CACHE INTERNAL "")

set(atom_build_cmake_PLUGIN_ACTIVATED_MESSAGE "automatically generating CMakeSettings.json configuration files in order to configure atom build-cmake plugin (CMake build provider)." CACHE INTERNAL "")

set(atom_build_cmake_PLUGIN_RESIDUAL_FILES "CMakeSettings.json" CACHE INTERNAL "")
