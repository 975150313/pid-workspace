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

##########################################################################################
############################ Guard for optimization of configuration process #############
##########################################################################################
if(PID_CONTINUOUS_INTEGRATION_FUNCTIONS_INCLUDED)
  return()
endif()
set(PID_CONTINUOUS_INTEGRATION_FUNCTIONS_INCLUDED TRUE)
##########################################################################################


###
function(reset_CI_Variables)
		set(${PROJECT_NAME}_ALLOWED_CI_PLATFORMS CACHE INTERNAL "")
endfunction(reset_CI_Variables)

### allow to specify the set of platforms for which the CI will take place
function(allow_CI_For_Platform platform)
	set(${PROJECT_NAME}_ALLOWED_CI_PLATFORMS ${${PROJECT_NAME}_ALLOWED_CI_PLATFORMS} ${platform} CACHE INTERNAL "")
endfunction(allow_CI_For_Platform)

#########################################################################################
############################# CI for native packges #####################################
#########################################################################################


### sets the adequate ci scripts in the package repository
function(verify_Package_CI_Content)

if(NOT EXISTS ${CMAKE_SOURCE_DIR}/share/ci)#the ci folder is missing
	file(COPY ${WORKSPACE_DIR}/share/patterns/packages/package/share/ci DESTINATION ${CMAKE_SOURCE_DIR}/share)
	message("[PID] INFO : creating the ci folder in package ${PROJECT_NAME} repository")
elseif(NOT IS_DIRECTORY ${CMAKE_SOURCE_DIR}/share/ci)#the ci folder is missing
	file(REMOVE ${CMAKE_SOURCE_DIR}/share/ci)
	message("[PID] WARNING : removed file ${CMAKE_SOURCE_DIR}/share/ci in package ${PROJECT_NAME}")
	file(COPY ${WORKSPACE_DIR}/share/patterns/packages/package/share/ci DESTINATION ${CMAKE_SOURCE_DIR}/share)
	message("[PID] INFO : creating the ci folder in package ${PROJECT_NAME} repository")
else() #updating these files by silently replacing the ci folder
	file(REMOVE ${CMAKE_SOURCE_DIR}/share/ci)
	file(COPY ${WORKSPACE_DIR}/share/patterns/packages/package/share/ci DESTINATION ${CMAKE_SOURCE_DIR}/share)
endif()
endfunction(verify_Package_CI_Content)

### configure the ci by generating the adequate gitlab-ci.yml file for the project
function(generate_Package_CI_Config_File)

if(NOT ${PROJECT_NAME}_ALLOWED_CI_PLATFORMS)
	if(EXISTS ${CMAKE_SOURCE_DIR}/.gitlab-ci.yml)
		file(REMOVE ${CMAKE_SOURCE_DIR}/.gitlab-ci.yml)#remove the file as CI is allowed for no platform
	endif()
	return() #no CI to run so no need to generate the file
endif()

verify_Package_CI_Content()

# determine general informations about package content
if(NOT ${PROJECT_NAME}_COMPONENTS_LIBS)
	set(PACKAGE_CI_HAS_LIBRARIES "false")
else()
	set(PACKAGE_CI_HAS_LIBRARIES "true")
endif()

# are there tests and examples ?
set(PACKAGE_CI_HAS_TESTS "false")
set(PACKAGE_CI_HAS_EXAMPLES "false")
foreach(component IN LISTS ${PROJECT_NAME}_DECLARED_COMPS)#looking into all declared components
	if(${PROJECT_NAME}_${component}_TYPE STREQUAL "EXAMPLE")
		set(PACKAGE_CI_HAS_EXAMPLES "true")
	elseif(${PROJECT_NAME}_${component}_TYPE STREQUAL "TEST")
		set(PACKAGE_CI_HAS_TESTS "true")
	endif()
endforeach()

#is there a static site defined for the project ?
if(NOT ${PROJECT_NAME}_FRAMEWORK AND NOT ${PROJECT_NAME}_SITE_GIT_ADDRESS)
	set(PACKAGE_CI_HAS_SITE "false")
	set(PACKAGE_CI_PUBLISH_BINARIES "false")
	set(PACKAGE_CI_PUBLISH_DEV_INFO "false")
else()
	set(PACKAGE_CI_HAS_SITE "true")
	if(${PROJECT_NAME}_BINARIES_AUTOMATIC_PUBLISHING)
		set(PACKAGE_CI_PUBLISH_BINARIES "true")
	else()
		set(PACKAGE_CI_PUBLISH_BINARIES "false")
	endif()
	if(${PROJECT_NAME}_DEV_INFO_AUTOMATIC_PUBLISHING)
		set(PACKAGE_CI_PUBLISH_DEV_INFO "true")
	else()
		set(PACKAGE_CI_PUBLISH_DEV_INFO "false")
	endif()
endif()

#configuring pattern file
set(TARGET_TEMPORARY_FILE ${CMAKE_BINARY_DIR}/.gitlab-ci.yml)
configure_file(${WORKSPACE_DIR}/share/patterns/packages/.gitlab-ci.yml.in ${TARGET_TEMPORARY_FILE} @ONLY)#adding the gitlab-ci configuration file to the repository

#now need to complete the configuration file with platform and environment related information
# managing restriction on platforms used for CI and generating CI config file
foreach(platform IN LISTS ${PROJECT_NAME}_ALLOWED_CI_PLATFORMS)
	add_CI_Config_File_Runner_Selection_By_Platform(${TARGET_TEMPORARY_FILE} ${platform})
endforeach()
file(APPEND ${TARGET_TEMPORARY_FILE} "\n\n############ jobs definition, by platform #############\n\n")
foreach(platform IN LISTS ${PROJECT_NAME}_ALLOWED_CI_PLATFORMS)
	add_CI_Config_File_Jobs_Definitions_By_Platform(${TARGET_TEMPORARY_FILE} ${platform})
endforeach()

file(COPY ${TARGET_TEMPORARY_FILE} DESTINATION ${CMAKE_SOURCE_DIR})
endfunction(generate_Package_CI_Config_File)

##subsidiary function used to write how a runner is selected according to a given platform
function(add_CI_Config_File_Runner_Selection_By_Platform configfile platform)
file(APPEND ${configfile} "#platform ${platform}\n\n")
file(APPEND ${configfile} ".selection_platform_${platform}_: &selection_platform_${platform}\n    tags:\n        - pid\n        - ${platform}\n\n")
endfunction(add_CI_Config_File_Runner_Selection_By_Platform)

##subsidiary function used to write how a runner is selected according to a given platform, for all jabs of the pid CI pipeline
function(add_CI_Config_File_Jobs_Definitions_By_Platform configfile platform)
file(APPEND ${configfile} "#pipeline generated for platform: ${platform}\n\n")

file(APPEND ${configfile} "#integration jobs for platform ${platform}\n\n")
file(APPEND ${configfile} "configure_integration_${platform}:\n  <<: *configure_integration\n  <<: *selection_platform_${platform}\n\n")
file(APPEND ${configfile} "build_integration_${platform}:\n  <<: *build_integration\n  <<: *selection_platform_${platform}\n\n")
file(APPEND ${configfile} "deploy_integration_${platform}:\n  <<: *deploy_integration\n  <<: *selection_platform_${platform}\n\n")
file(APPEND ${configfile} "cleanup_integration_${platform}:\n  <<: *cleanup_integration\n  <<: *selection_platform_${platform}\n\n")

file(APPEND ${configfile} "#release jobs for platform ${platform}\n\n")
file(APPEND ${configfile} "configure_release_${platform}:\n  <<: *configure_release\n  <<: *selection_platform_${platform}\n\n")
file(APPEND ${configfile} "build_release_${platform}:\n  <<: *build_release\n  <<: *selection_platform_${platform}\n\n")
file(APPEND ${configfile} "deploy_release_${platform}:\n  <<: *deploy_release\n  <<: *selection_platform_${platform}\n\n")
file(APPEND ${configfile} "cleanup_release_${platform}:\n  <<: *cleanup_release\n  <<: *selection_platform_${platform}\n\n")
endfunction(add_CI_Config_File_Jobs_Definitions_By_Platform)

#########################################################################################
############################ CI for external packges wrappers ###########################
#########################################################################################

### sets the adequate ci scripts in the wrapper repository
function(verify_Wrapper_CI_Content)

if(NOT EXISTS ${CMAKE_SOURCE_DIR}/share/ci)#the ci folder is missing
	file(COPY ${WORKSPACE_DIR}/share/patterns/wrappers/package/share/ci DESTINATION ${CMAKE_SOURCE_DIR}/share)
	message("[PID] INFO : creating the ci folder in wrapper ${PROJECT_NAME} repository")
elseif(NOT IS_DIRECTORY ${CMAKE_SOURCE_DIR}/share/ci)#the ci folder is missing
	file(REMOVE ${CMAKE_SOURCE_DIR}/share/ci)
	message("[PID] WARNING : removed file ${CMAKE_SOURCE_DIR}/share/ci in wrapper ${PROJECT_NAME}")
	file(COPY ${WORKSPACE_DIR}/share/patterns/wrappers/package/share/ci DESTINATION ${CMAKE_SOURCE_DIR}/share)
	message("[PID] INFO : creating the ci folder in wrapper ${PROJECT_NAME} repository")
else() #updating these files by silently replacing the ci folder
	file(REMOVE ${CMAKE_SOURCE_DIR}/share/ci)
	file(COPY ${WORKSPACE_DIR}/share/patterns/wrappers/package/share/ci DESTINATION ${CMAKE_SOURCE_DIR}/share)
endif()
endfunction(verify_Wrapper_CI_Content)

##subsidiary function used to write how a runner is selected according to a given platform, for all jabs of the pid CI pipeline
function(add_CI_Config_File_Jobs_Definitions_By_Platform_For_Wrapper configfile platform)
file(APPEND ${configfile} "#pipeline generated for platform: ${platform}\n\n")
file(APPEND ${configfile} "#jobs for platform ${platform}\n\n")
file(APPEND ${configfile} "configure_wrapper_${platform}:\n  <<: *configure_wrapper\n  <<: *selection_platform_${platform}\n\n")
file(APPEND ${configfile} "build_wrapper_${platform}:\n  <<: *build_wrapper\n  <<: *selection_platform_${platform}\n\n")
file(APPEND ${configfile} "deploy_wrapper_${platform}:\n  <<: *deploy_wrapper\n  <<: *selection_platform_${platform}\n\n")
file(APPEND ${configfile} "cleanup_wrapper_${platform}:\n  <<: *cleanup_wrapper\n  <<: *selection_platform_${platform}\n\n")
endfunction(add_CI_Config_File_Jobs_Definitions_By_Platform_For_Wrapper)

### configure the ci by generating the adequate gitlab-ci.yml file for the project
function(generate_Wrapper_CI_Config_File)

if(NOT ${PROJECT_NAME}_ALLOWED_CI_PLATFORMS)
	if(EXISTS ${CMAKE_SOURCE_DIR}/.gitlab-ci.yml)
		file(REMOVE ${CMAKE_SOURCE_DIR}/.gitlab-ci.yml)#remove the file as CI is allowed for no platform
	endif()
	return() #no CI to run so no need to generate the file
endif()

verify_Wrapper_CI_Content()

#is there a static site defined for the project ?
if(NOT ${PROJECT_NAME}_FRAMEWORK AND NOT ${PROJECT_NAME}_SITE_GIT_ADDRESS)
	set(PACKAGE_CI_HAS_SITE "false")
	set(PACKAGE_CI_PUBLISH_BINARIES "false")
else()
	set(PACKAGE_CI_HAS_SITE "true")
	if(${PROJECT_NAME}_BINARIES_AUTOMATIC_PUBLISHING)
		set(PACKAGE_CI_PUBLISH_BINARIES "true")
	else()
		set(PACKAGE_CI_PUBLISH_BINARIES "false")
	endif()
endif()

#configuring pattern file
set(TARGET_TEMPORARY_FILE ${CMAKE_BINARY_DIR}/.gitlab-ci.yml)
configure_file(${WORKSPACE_DIR}/share/patterns/wrappers/.gitlab-ci.yml.in ${TARGET_TEMPORARY_FILE} @ONLY)#adding the gitlab-ci configuration file to the repository

#now need to complete the configuration file with platform and environment related information
# managing restriction on platforms used for CI and generating CI config file
foreach(platform IN LISTS ${PROJECT_NAME}_ALLOWED_CI_PLATFORMS)
	add_CI_Config_File_Runner_Selection_By_Platform(${TARGET_TEMPORARY_FILE} ${platform})
endforeach()
file(APPEND ${TARGET_TEMPORARY_FILE} "\n\n############ jobs definition, by platform #############\n\n")
foreach(platform IN LISTS ${PROJECT_NAME}_ALLOWED_CI_PLATFORMS)
	add_CI_Config_File_Jobs_Definitions_By_Platform_For_Wrapper(${TARGET_TEMPORARY_FILE} ${platform})
endforeach()

file(COPY ${TARGET_TEMPORARY_FILE} DESTINATION ${CMAKE_SOURCE_DIR})
endfunction(generate_Wrapper_CI_Config_File)
