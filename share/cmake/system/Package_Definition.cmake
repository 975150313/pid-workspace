
#
# A convenience set of macros to create adequate variables in the context of the parent scope.
# used to define components of a package
#
##################################################################################
#######################  auxiliary package management functions ##################
##################################################################################

###
macro(add_Author author institution)
	set(${PROJECT_NAME}_AUTHORS_AND_INSTITUTIONS ${${PROJECT_NAME}_AUTHORS_AND_INSTITUTIONS} "${author}(${institution})" CACHE INTERNAL "")
endmacro(add_Author author insitution)

###
macro(add_Caterory category_spec)
	set(${PROJECT_NAME}_CATEGORIES ${${PROJECT_NAME}_CATEGORIES} ${category_spec} CACHE INTERNAL "")
endmacro(add_Caterory category_spec)

###
macro(set_Current_Version major minor patch)
	#################################################
	################## setting version ##############
	#################################################
	set (${PROJECT_NAME}_VERSION_MAJOR ${major} CACHE INTERNAL "")
	set (${PROJECT_NAME}_VERSION_MINOR ${minor} CACHE INTERNAL "")
	set (${PROJECT_NAME}_VERSION_PATCH ${patch} CACHE INTERNAL "")
	set (${PROJECT_NAME}_VERSION ${${PROJECT_NAME}_VERSION_MAJOR}.${${PROJECT_NAME}_VERSION_MINOR}.${${PROJECT_NAME}_VERSION_PATCH} CACHE INTERNAL "")
	message(STATUS "version currently built = "${${PROJECT_NAME}_VERSION})

	#################################################
	############ MANAGING install paths #############
	#################################################
	if(USE_LOCAL_DEPLOYMENT)
		set(${PROJECT_NAME}_DEPLOY_PATH own CACHE INTERNAL "")
	else(USE_LOCAL_DEPLOYMENT)
		set(${PROJECT_NAME}_DEPLOY_PATH ${${PROJECT_NAME}_VERSION} CACHE INTERNAL "")
	endif(USE_LOCAL_DEPLOYMENT) 

	set ( ${PROJECT_NAME}_INSTALL_LIB_PATH ${${PROJECT_NAME}_DEPLOY_PATH}/lib CACHE INTERNAL "")
	set ( ${PROJECT_NAME}_INSTALL_AR_PATH ${${PROJECT_NAME}_DEPLOY_PATH}/lib CACHE INTERNAL "")
	set ( ${PROJECT_NAME}_INSTALL_HEADERS_PATH ${${PROJECT_NAME}_DEPLOY_PATH}/include CACHE INTERNAL "")
	set ( ${PROJECT_NAME}_INSTALL_SHARE_PATH ${${PROJECT_NAME}_DEPLOY_PATH}/share CACHE INTERNAL "")
	set ( ${PROJECT_NAME}_INSTALL_BIN_PATH ${${PROJECT_NAME}_DEPLOY_PATH}/bin CACHE INTERNAL "")
endmacro(set_Current_Version major minor patch)

###
macro(generate_License_File)

if(${CMAKE_BUILD_TYPE} MATCHES Release)
	if(	DEFINED ${PROJECT_NAME}_LICENSE 
		AND NOT ${${PROJECT_NAME}_LICENSE} STREQUAL "")
	
		find_file(LICENSE   "License${${PROJECT_NAME}_LICENSE}.cmake"
				PATHS "${WORKSPACE_DIR}/share/cmake/system"
				NO_DEFAULT_PATH
				DOC "Path to the license configuration file")
		if(LICENSE_IN-NOTFOUND)
			message(WARNING "license configuration file for ${${PROJECT_NAME}_LICENSE} not found in workspace, license file will not be generated")
		else(LICENSE_IN-NOTFOUND)
			include(${WORKSPACE_DIR}/share/cmake/licenses/License${${PROJECT_NAME}_LICENSE}.cmake)
			file(WRITE ${CMAKE_SOURCE_DIR}/license.txt ${LICENSE_LEGAL_TERMS})
		endif(LICENSE_IN-NOTFOUND)

	endif()
endif()
endmacro(generate_License_File)

##################################################################################
###########################  declaration of the package ##########################
##################################################################################
macro(declare_Package author institution year license address description)
#################################################
############ MANAGING build mode ################
#################################################
if(${CMAKE_BINARY_DIR} MATCHES release)
	set(CMAKE_BUILD_TYPE "Release" CACHE String "the type of build is dependent from build location" FORCE)
	set ( INSTALL_NAME_SUFFIX "" CACHE INTERNAL "")
	set ( USE_MODE_SUFFIX "_RELEASE" CACHE INTERNAL "")
elseif(${CMAKE_BINARY_DIR} MATCHES debug)
	set(CMAKE_BUILD_TYPE "Debug" CACHE String "the type of build is dependent from build location" FORCE)
	set ( INSTALL_NAME_SUFFIX -dbg CACHE INTERNAL "")
	set ( USE_MODE_SUFFIX "_DEBUG" CACHE INTERNAL "")
elseif(${CMAKE_BINARY_DIR} MATCHES build)
	if(NOT EXISTS ${CMAKE_BINARY_DIR}/debug OR NOT IS_DIRECTORY ${CMAKE_BINARY_DIR}/debug)
		execute_process(COMMAND ${CMAKE_COMMAND} -E  make_directory debug WORKING_DIRECTORY ${CMAKE_BINARY_DIR})
	endif()
	if(NOT EXISTS ${CMAKE_BINARY_DIR}/release OR NOT IS_DIRECTORY ${CMAKE_BINARY_DIR}/release)
		execute_process(COMMAND ${CMAKE_COMMAND} -E  make_directory release WORKING_DIRECTORY ${CMAKE_BINARY_DIR})
	endif()
	execute_process(COMMAND ${CMAKE_COMMAND} ${CMAKE_SOURCE_DIR} WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/debug)
	execute_process(COMMAND ${CMAKE_COMMAND} ${CMAKE_SOURCE_DIR} WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/release)

	#need to create targets
	add_custom_target(build ALL
		COMMAND ${CMAKE_COMMAND} -E  chdir ${CMAKE_BINARY_DIR}/debug ${CMAKE_BUILD_TOOL} build
		COMMAND ${CMAKE_COMMAND} -E  chdir ${CMAKE_BINARY_DIR}/release ${CMAKE_BUILD_TOOL} build
	)
	return()
else()	# the build must be done in the build directory 
	return()
endif(${CMAKE_BINARY_DIR} MATCHES release)

#################################################
############ Initializing variables #############
#################################################
set(${PROJECT_NAME}_MAIN_AUTHOR "${author}" CACHE INTERNAL "")
set(${PROJECT_NAME}_MAIN_INSTITUTION "${institution}" CACHE INTERNAL "")

set(${PROJECT_NAME}_AUTHORS_AND_INSTITUTIONS "${author}(${institution})" CACHE INTERNAL "")

set(${PROJECT_NAME}_DESCRIPTION "${description}" CACHE INTERNAL "")
set(${PROJECT_NAME}_YEARS ${year} CACHE INTERNAL "")
set(${PROJECT_NAME}_LICENSE ${license} CACHE INTERNAL "")
set(${PROJECT_NAME}_ADDRESS ${address} CACHE INTERNAL "")
set(${PROJECT_NAME}_CATEGORIES "" CACHE INTERNAL "")
set(${PROJECT_NAME}_COMPONENTS "" CACHE INTERNAL "")
set(${PROJECT_NAME}_COMPONENTS_LIBS "" CACHE INTERNAL "")
set(${PROJECT_NAME}_COMPONENTS_APPS "" CACHE INTERNAL "")

#################################################
############ MANAGING generic paths #############
#################################################
set(PACKAGE_BINARY_INSTALL_DIR ${WORKSPACE_DIR}/install CACHE INTERNAL "")
set(${PROJECT_NAME}_INSTALL_PATH ${PACKAGE_BINARY_INSTALL_DIR}/${PROJECT_NAME} CACHE INTERNAL "")
set(CMAKE_INSTALL_PREFIX ${${PROJECT_NAME}_INSTALL_PATH})

#################################################
############ DECLARING options ##################
#################################################
option(BUILD_WITH_EXAMPLES "Package builds examples" ON)
option(BUILD_WITH_TESTS "Package uses tests" OFF)
option(BUILD_WITH_PRINT_MESSAGES "Package generates print in console" OFF)
option(BUILD_WITH_DOC "Package generates documentation" ON)
option(USE_LOCAL_DEPLOYMENT "Package uses tests" ON)
if(BUILD_WITH_PRINT_MESSAGES)
	add_definitions(-DPRINT_MESSAGES)
endif(BUILD_WITH_PRINT_MESSAGES)

########################################################################
############ inclusion of required macros and functions ################
########################################################################
#TODO uncomment to test
#include(Package_Finding)
#include(Package_Configuration)

endmacro(declare_Package author institution year license address description)



##################################################################################
################################### building the package #########################
##################################################################################
macro(build_Package)

##########################################################
############ MANAGING non source files ###################
##########################################################

generate_License_File() #license
install(FILES ${CMAKE_SOURCE_DIR}/license.txt DESTINATION ${${PROJECT_NAME}_DEPLOY_PATH})

# generating/installing the generic cmake find file for the package 
configure_file(${WORKSPACE_DIR}/share/cmake/system/FindPackage.cmake.in ${CMAKE_BINARY_DIR}/share/Find${PROJECT_NAME}.cmake @ONLY)
install(FILES ${CMAKE_BINARY_DIR}/share/Find${PROJECT_NAME}.cmake DESTINATION ${WORKSPACE_DIR}/share/cmake/find) #install in the worskpace cmake find modules directory

#install(FILES ${CMAKE_BINARY_DIR}/share/Find${PROJECT_NAME}.cmake DESTINATION ${${PROJECT_NAME}_INSTALL_SHARE_PATH}/cmake) #install it in the corresponding package version
# generating/installing the version specific cmake "use" file 
configure_file(${CMAKE_SOURCE_DIR}/share/UsePackageVersion.cmake.in ${CMAKE_BINARY_DIR}/share/Use${PROJECT_NAME}-${${PROJECT_NAME}_VERSION}.cmake @ONLY)
install(FILES ${CMAKE_BINARY_DIR}/share/Use${PROJECT_NAME}-${${PROJECT_NAME}_VERSION}.cmake DESTINATION ${${PROJECT_NAME}_INSTALL_SHARE_PATH})
#installing the CMakeModules folder (contains find scripts)
install(DIRECTORY ${CMAKE_SOURCE_DIR}/share/cmake DESTINATION ${${PROJECT_NAME}_INSTALL_SHARE_PATH})

#################################################
############ MANAGING the BUILD #################
#################################################

# if all dependencies are satisfied --> TODO : remove this include
include_directories(include)

#recursive call into subdirectories to build/install/test the package
add_subdirectory(src)
add_subdirectory(apps)
add_subdirectory(test)
add_subdirectory(share)

#################################################
##### MANAGING the SYSTEM PACKAGING #############
#################################################
#TODO Il faudrait packager les libs debug ET release d'un coup !! (PAS facile avec CMAKE) 
#option(GENERATE_INSTALLER "Package generate an OS installer for linux with tgz and if possible debian" OFF)
#if(GENERATE_INSTALLER)
#	include(InstallRequiredSystemLibraries)
#	set(CPACK_GENERATOR TGZ)
#	set(CPACK_PACKAGE_NAME "${PROJECT_NAME}")
#	set(CPACK_PACKAGE_CONTACT ${${PROJECT_NAME}_MAIN_AUTHOR})
#	set(CPACK_PACKAGE_DESCRIPTION_SUMMARY ${${PROJECT_NAME}_DESCRIPTION})
#	set(CPACK_PACKAGE_VENDOR ${${PROJECT_NAME}_MAIN_INSTITUTION})
#	set(CPACK_RESOURCE_FILE_LICENSE ${CMAKE_SOURCE_DIR}/license.txt)#TODO change with binary dir and generate the file !!
#	set(CPACK_PACKAGE_VERSION_MAJOR ${${PROJECT_NAME}_VERSION_MAJOR})
#	set(CPACK_PACKAGE_VERSION_MINOR ${${PROJECT_NAME}_VERSION_MINOR})
#	set(CPACK_PACKAGE_VERSION_PATCH ${${PROJECT_NAME}_VERSION_PATCH})
#	set(CPACK_PACKAGE_VERSION "${${PROJECT_NAME}_VERSION}${INSTALL_NAME_SUFFIX}")
#	set(CPACK_PACKAGE_INSTALL_DIRECTORY "${PROJECT_NAME}/${${PROJECT_NAME}_VERSION}")
#
#	if(UNIX AND NOT APPLE)
#		list(APPEND CPACK_GENERATOR DEB)
#	endif(UNIX AND NOT APPLE)
#	include(CPack)


#	if(UNIX AND NOT APPLE) #linux install
#		add_custom_target(package_install
#				COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_BINARY_DIR}/${PROJECT_NAME}-${${PROJECT_NAME}_VERSION}${INSTALL_NAME_SUFFIX}-Linux.tar.gz
#					${${PROJECT_NAME}_INSTALL_PATH}/installers/${PROJECT_NAME}-${${PROJECT_NAME}_VERSION}${INSTALL_NAME_SUFFIX}-Linux.tar.gz
#				DEPENDS ${CMAKE_BINARY_DIR}/${PROJECT_NAME}-${${PROJECT_NAME}_VERSION}${INSTALL_NAME_SUFFIX}-Linux.tar.gz
#				COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_BINARY_DIR}/${PROJECT_NAME}-${${PROJECT_NAME}_VERSION}${INSTALL_NAME_SUFFIX}-Linux.deb
#					${${PROJECT_NAME}_INSTALL_PATH}/installers/${PROJECT_NAME}-${${PROJECT_NAME}_VERSION}${INSTALL_NAME_SUFFIX}-Linux.deb
#				DEPENDS ${CMAKE_BINARY_DIR}/${PROJECT_NAME}-${${PROJECT_NAME}_VERSION}${INSTALL_NAME_SUFFIX}-Linux.tar.gz
#				COMMENT "installing ${CMAKE_BINARY_DIR}/${PROJECT_NAME}-${${PROJECT_NAME}_VERSION}${INSTALL_NAME_SUFFIX}-Linux.deb in ${${PROJECT_NAME}_INSTALL_PATH}/installers"
#			)
#	else(UNIX AND NOT APPLE) #apple install
#		add_custom_target(package_install
#			   	COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_BINARY_DIR}/${PROJECT_NAME}-${${PROJECT_NAME}_VERSION}${INSTALL_NAME_SUFFIX}-Linux.tar.gz
#					${${PROJECT_NAME}_INSTALL_PATH}/installers/${PROJECT_NAME}-${${PROJECT_NAME}_VERSION}${INSTALL_NAME_SUFFIX}-Linux.tar.gz
#				COMMENT "installing ${CMAKE_BINARY_DIR}/${PROJECT_NAME}-${${PROJECT_NAME}_VERSION}${INSTALL_NAME_SUFFIX}-Linux.tag.gz in ${${PROJECT_NAME}_INSTALL_PATH}/installers" 						 
#			)
#	endif(UNIX AND NOT APPLE)
#
#endif(GENERATE_INSTALLER)

#################################################
######### MANAGING global make commands #########
#################################################

#creating a global build command
#if(GENERATE_INSTALLER)
#	if(CMAKE_BUILD_TYPE MATCHES Release)
#		if(${BUILD_WITH_TESTS})
#			add_custom_target(build 
#				COMMAND ${CMAKE_BUILD_TOOL}
#				COMMAND ${CMAKE_BUILD_TOOL} test
#				COMMAND ${CMAKE_BUILD_TOOL} doc 
#				COMMAND ${CMAKE_BUILD_TOOL} install
#				COMMAND ${CMAKE_BUILD_TOOL} package
#				COMMAND ${CMAKE_BUILD_TOOL} package_install
#			) 
#		else(${BUILD_WITH_TESTS})
#			add_custom_target(build 
#				COMMAND ${CMAKE_BUILD_TOOL}
#				COMMAND ${CMAKE_BUILD_TOOL} doc 
#				COMMAND ${CMAKE_BUILD_TOOL} install
#				COMMAND ${CMAKE_BUILD_TOOL} package
#				COMMAND ${CMAKE_BUILD_TOOL} package_install
#			) 
#		endif(${BUILD_WITH_TESTS})
#	else(CMAKE_BUILD_TYPE MATCHES Release)
#		if(${BUILD_WITH_TESTS})
#			add_custom_target(build 
#				COMMAND ${CMAKE_BUILD_TOOL} 
#				COMMAND ${CMAKE_BUILD_TOOL} test
#				COMMAND ${CMAKE_BUILD_TOOL} install
#				COMMAND ${CMAKE_BUILD_TOOL} package
#				COMMAND ${CMAKE_BUILD_TOOL} package_install
#			) 
#		else(${BUILD_WITH_TESTS})
#			add_custom_target(build 
#				COMMAND ${CMAKE_BUILD_TOOL} 
#				COMMAND ${CMAKE_BUILD_TOOL} install
#				COMMAND ${CMAKE_BUILD_TOOL} package
#				COMMAND ${CMAKE_BUILD_TOOL} package_install
#			)  
#		endif(${BUILD_WITH_TESTS})
#
#	endif(CMAKE_BUILD_TYPE MATCHES Release)
#
#else(GENERATE_INSTALLER)
	if(CMAKE_BUILD_TYPE MATCHES Release)
		if(${BUILD_WITH_TESTS})
			add_custom_target(build 
				COMMAND ${CMAKE_BUILD_TOOL}
				COMMAND ${CMAKE_BUILD_TOOL} test
				COMMAND ${CMAKE_BUILD_TOOL} doc 
				COMMAND ${CMAKE_BUILD_TOOL} install
			) 
		else(${BUILD_WITH_TESTS})
	
			add_custom_target(build 
				COMMAND ${CMAKE_BUILD_TOOL}
				COMMAND ${CMAKE_BUILD_TOOL} doc 
				COMMAND ${CMAKE_BUILD_TOOL} install
			) 
		endif()
	else(CMAKE_BUILD_TYPE MATCHES Release)
		if(${BUILD_WITH_TESTS})
			add_custom_target(build 
				COMMAND ${CMAKE_BUILD_TOOL}
				COMMAND ${CMAKE_BUILD_TOOL} test
				COMMAND ${CMAKE_BUILD_TOOL} install
			) 
		else(${BUILD_WITH_TESTS})
			
			add_custom_target(build 
				COMMAND ${CMAKE_BUILD_TOOL} 
				COMMAND ${CMAKE_BUILD_TOOL} install
			) 
		endif(${BUILD_WITH_TESTS})
	endif(CMAKE_BUILD_TYPE MATCHES Release)
#endif(GENERATE_INSTALLER)

endmacro(build_Package)



##################################################################################
########## adding source code of the example components to the API doc ###########
##################################################################################
function(add_Example_To_Doc c_name)
	file(MAKE_DIRECTORY ${PROJECT_BINARY_DIR}/share/examples/)
	file(COPY ${PROJECT_SOURCE_DIR}/apps/${c_name} DESTINATION ${PROJECT_BINARY_DIR}/share/examples/)
endfunction(add_Example_To_Doc c_name)

##################################################################################
################### generating API documentation for the package #################
##################################################################################
function(generate_API)
option(GENERATE_LATEX_API "Generating the latex api documentation" ON)
if(CMAKE_BUILD_TYPE MATCHES Release) # if in release mode we generate the doc

#finding doxygen tool and doxygen configuration file 
find_package(Doxygen)
find_file(DOXYFILE_IN   "Doxyfile.in"
			PATHS "${CMAKE_SOURCE_DIR}/share/doxygen"
			NO_DEFAULT_PATH
			DOC "Path to the doxygen configuration template file")

if(NOT DOXYGEN_FOUND)
	message(WARNING "Doxygen not found please install it to generate the API documentation")
endif(NOT DOXYGEN_FOUND)
if(DOXYFILE_IN-NOTFOUND)
	message(WARNING "Doxyfile not found in the share folder of your package !! Getting the standard doxygen template file from workspace ... ")
	find_file(GENERIC_DOXYFILE_IN   "Doxyfile.in"
					PATHS "${WORKSPACE_DIR}/share/cmake/system"
					NO_DEFAULT_PATH
					DOC "Path to the generic doxygen configuration template file")
	if(GENERIC_DOXYFILE_IN-NOTFOUND)
		message(WARNING "No Template file found, skipping documentation generation !!")		
	else(GENERIC_DOXYFILE_IN-NOTFOUND)
		file(COPY ${WORKSPACE_DIR}/share/doxygen/Doxyfile.in ${CMAKE_SOURCE_DIR}/share/doxygen)
		message(STATUS "Template file found and copied to your package, you can now modify it")		
	endif(GENERIC_DOXYFILE_IN-NOTFOUND)
endif(DOXYFILE_IN-NOTFOUND)

if(DOXYGEN_FOUND AND NOT DOXYFILE_IN-NOTFOUND AND NOT GENERIC_DOXYFILE_IN-NOTFOUND) #we are able to generate the doc
	# general variables
	set(DOXYFILE_SOURCE_DIRS "${CMAKE_SOURCE_DIR}/include/")
	set(DOXYFILE_PROJECT_NAME ${PROJECT_NAME})
	set(DOXYFILE_PROJECT_VERSION ${${PROJECT_NAME}_VERSION})
	set(DOXYFILE_OUTPUT_DIR ${CMAKE_BINARY_DIR}/share/doc)
	set(DOXYFILE_HTML_DIR html)
	set(DOXYFILE_LATEX_DIR latex)

	### new targets ###
	# creating the specific target to run doxygen
	add_custom_target(doxygen
		${DOXYGEN_EXECUTABLE} ${CMAKE_BINARY_DIR}/share/Doxyfile
		DEPENDS ${CMAKE_BINARY_DIR}/share/Doxyfile
		WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}"
		COMMENT "Generating API documentation with Doxygen" VERBATIM
	)

	# target to clean installed doc
	set_property(DIRECTORY
		APPEND PROPERTY
		ADDITIONAL_MAKE_CLEAN_FILES
		"${DOXYFILE_OUTPUT_DIR}/${DOXYFILE_HTML_DIR}")

	# creating the doc target
	get_target_property(DOC_TARGET doc TYPE)
	if(NOT DOC_TARGET)
		add_custom_target(doc)
	endif(NOT DOC_TARGET)

	add_dependencies(doc doxygen)

	### end new targets ###

	### doxyfile configuration ###

	# configuring doxyfile for html generation 
	set(DOXYFILE_GENERATE_HTML "YES")

	# configuring doxyfile to use dot executable if available
	set(DOXYFILE_DOT "NO")
	if(DOXYGEN_DOT_EXECUTABLE)
		set(DOXYFILE_DOT "YES")
	endif()

	# configuring doxyfile for latex generation 
	set(DOXYFILE_PDFLATEX "NO")

	if(GENERATE_LATEX_API)
		# target to clean installed doc
		set_property(DIRECTORY
			APPEND PROPERTY
			ADDITIONAL_MAKE_CLEAN_FILES
			"${DOXYFILE_OUTPUT_DIR}/${DOXYFILE_LATEX_DIR}")
		set(DOXYFILE_GENERATE_LATEX "YES")
		find_package(LATEX)
		find_program(DOXYFILE_MAKE make)
		mark_as_advanced(DOXYFILE_MAKE)
		if(LATEX_COMPILER AND MAKEINDEX_COMPILER AND DOXYFILE_MAKE)
			if(PDFLATEX_COMPILER)
				set(DOXYFILE_PDFLATEX "YES")
			endif(PDFLATEX_COMPILER)

			add_custom_command(TARGET doxygen
				POST_BUILD
				COMMAND "${DOXYFILE_MAKE}"
				COMMENT	"Running LaTeX for Doxygen documentation in ${DOXYFILE_OUTPUT_DIR}/${DOXYFILE_LATEX_DIR}..."
				WORKING_DIRECTORY "${DOXYFILE_OUTPUT_DIR}/${DOXYFILE_LATEX_DIR}")
		else(LATEX_COMPILER AND MAKEINDEX_COMPILER AND DOXYFILE_MAKE)
			set(DOXYGEN_LATEX "NO")
		endif(LATEX_COMPILER AND MAKEINDEX_COMPILER AND DOXYFILE_MAKE)

	else(GENERATE_LATEX_API)
		set(DOXYFILE_GENERATE_LATEX "NO")
	endif(GENERATE_LATEX_API)

	#configuring the Doxyfile.in file to generate a doxygen configuration file
	configure_file(${CMAKE_SOURCE_DIR}/share/doxygen/Doxyfile.in ${CMAKE_BINARY_DIR}/share/Doxyfile @ONLY)
	### end doxyfile configuration ###

	### installing documentation ###
	install(DIRECTORY ${CMAKE_BINARY_DIR}/share/doc DESTINATION ${${PROJECT_NAME}_INSTALL_SHARE_PATH})

	### end installing documentation ###

endif(DOXYGEN_FOUND AND NOT DOXYFILE_IN-NOTFOUND AND NOT GENERIC_DOXYFILE_IN-NOTFOUND)
	set(BUILD_WITH_DOC OFF)
endif(CMAKE_BUILD_TYPE MATCHES Release)
endfunction(generate_API)

###################### !!!!!!!!!!!!!!!!!!!!! ####################
### DEBUT code a virer une fois le système de gestion de dépendences fini
##################################################################

##################################################################################
###################### building a header component #########################
##################################################################################
macro(buildPureHeaderComponent c_name)
	#managing headers	
	set(${PROJECT_NAME}_COMP_HEADER_${c_name}_INCLUDE_DIR ${CMAKE_SOURCE_DIR}/include/${c_name})
	install(DIRECTORY ${${PROJECT_NAME}_COMP_HEADER_${c_name}_INCLUDE_DIR} DESTINATION ${${PROJECT_NAME}_INSTALL_HEADERS_PATH} FILES_MATCHING PATTERN "*.h")
	install(DIRECTORY ${${PROJECT_NAME}_COMP_HEADER_${c_name}_INCLUDE_DIR} DESTINATION ${${PROJECT_NAME}_INSTALL_HEADERS_PATH} FILES_MATCHING PATTERN "*.hpp")
	install(DIRECTORY ${${PROJECT_NAME}_COMP_HEADER_${c_name}_INCLUDE_DIR} DESTINATION ${${PROJECT_NAME}_INSTALL_HEADERS_PATH} FILES_MATCHING PATTERN "*.hh")
	#updating global variables of the CMake process	
	set(${PROJECT_NAME}_COMPONENTS "${${PROJECT_NAME}_COMPONENTS};${c_name}" CACHE INTERNAL "")
	set(${PROJECT_NAME}_COMPONENTS_LIBS "${${PROJECT_NAME}_COMPONENTS_LIBS};${c_name}" CACHE INTERNAL "")
endmacro(buildPureHeaderComponent)


##################################################################################
###################### declaration of a library component ########################
##################################################################################
macro(buildLibComponent c_name used_libraries_list)
	#managing headers	
	set(${PROJECT_NAME}_COMP_LIB_${c_name}_INCLUDE_DIR ${CMAKE_SOURCE_DIR}/include/${c_name})
	install(DIRECTORY ${PROJECT_NAME}_COMP_LIB_${c_name}_INCLUDE_DIR DESTINATION ${${PROJECT_NAME}_INSTALL_HEADERS_PATH} FILES_MATCHING PATTERN "*.h")
	install(DIRECTORY ${PROJECT_NAME}_COMP_LIB_${c_name}_INCLUDE_DIR DESTINATION ${${PROJECT_NAME}_INSTALL_HEADERS_PATH} FILES_MATCHING PATTERN "*.hpp")
	#managing sources
	set(${PROJECT_NAME}_COMP_LIB_${c_name}_SOURCE_DIR ${CMAKE_SOURCE_DIR}/src/${c_name})
	
	file(GLOB_RECURSE ${PROJECT_NAME}_COMP_LIB_${c_name}_ALL_SOURCES "${c_name}/*.c" "${c_name}/*.cpp" "${c_name}/*.h" "${c_name}/*.hpp")
	
	add_library(${c_name}-st${INSTALL_NAME_SUFFIX} STATIC ${${PROJECT_NAME}_COMP_LIB_${c_name}_ALL_SOURCES})
	target_link_libraries(${c_name}-st${INSTALL_NAME_SUFFIX} ${used_libraries_list})
	add_library(${c_name}${INSTALL_NAME_SUFFIX} SHARED ${${PROJECT_NAME}_COMP_LIB_${c_name}_ALL_SOURCES})
	target_link_libraries(${c_name}${INSTALL_NAME_SUFFIX} ${used_libraries_list})

	# installing library
	INSTALL(TARGETS ${c_name}${INSTALL_NAME_SUFFIX} ${c_name}-st${INSTALL_NAME_SUFFIX}
		RUNTIME DESTINATION ${${PROJECT_NAME}_INSTALL_BIN_PATH}
		LIBRARY DESTINATION ${${PROJECT_NAME}_INSTALL_LIB_PATH}
		ARCHIVE DESTINATION ${${PROJECT_NAME}_INSTALL_AR_PATH}
	)

	#updating global variables of the CMake process	
	set(${PROJECT_NAME}_COMPONENTS "${${PROJECT_NAME}_COMPONENTS};${c_name}" CACHE INTERNAL "")
	set(${PROJECT_NAME}_COMPONENTS_LIBS "${${PROJECT_NAME}_COMPONENTS_LIBS};${c_name}" CACHE INTERNAL "")

endmacro(buildLibComponent)


##################################################################################
################## declaration of an application component #######################
##################################################################################
macro(buildAppComponent c_name used_libraries_list)
	#managing sources
	set(${PROJECT_NAME}_COMP_APP_${c_name}_SOURCE_DIR ${CMAKE_SOURCE_DIR}/apps/${c_name})

	file(GLOB_RECURSE ${PROJECT_NAME}_COMP_APP_${c_name}_ALL_SOURCES "${c_name}/*.c" "${c_name}/*.cpp" "${c_name}/*.h" "${c_name}/*.hpp")
	
	add_executable(${c_name}${INSTALL_NAME_SUFFIX} ${${PROJECT_NAME}_COMP_APP_${c_name}_ALL_SOURCES})
	target_link_libraries(${c_name}${INSTALL_NAME_SUFFIX} ${used_libraries_list})

	# installing library
	INSTALL(TARGETS ${c_name}${INSTALL_NAME_SUFFIX} 
	RUNTIME DESTINATION ${${PROJECT_NAME}_INSTALL_BIN_PATH}
	)

	#updating global variables of the CMake process	
	set(${PROJECT_NAME}_COMPONENTS "${${PROJECT_NAME}_COMPONENTS};${c_name}" CACHE INTERNAL "")
	set(${PROJECT_NAME}_COMPONENTS_APPS "${${PROJECT_NAME}_COMPONENTS_APPS};${c_name}" CACHE INTERNAL "")
	
endmacro(buildAppComponent)


##################################################################################
################ printing variables for components in the package ################
##################################################################################
macro(printComponentVariables)
	message("components of package ${PROJECT_NAME} are :" ${${PROJECT_NAME}_COMPONENTS})
	message("libraries : "${${PROJECT_NAME}_COMPONENTS_LIBS})
	message("applications : "${${PROJECT_NAME}_COMPONENTS_APPS})
endmacro(printComponentVariables)



###################### !!!!!!!!!!!!!!!!!!!!! ####################
### FIN code a virer une fois le système de gestion de dépendences fini
####################!!!!!!!!!!!!!!!!!!!!!!!!!!!##################

###REMARQUE
###
### pour defs et links il faut permettre de dire qu'on les exporte OU PAS
### i.e. ils servent uniquement en interne OU ils doivent être exportés en même
### temps que le composant !!!

##################################################################################
######### auxiliary functions for component declaration management ###############
##################################################################################

function(manage_Additional_Component_Flags target_name defs links)

# managing compile time flags
if(NOT ${defs} STREQUAL "")
	target_compile_definitions(${target_name} ${defs})
endif(NOT ${defs} STREQUAL "")

# managing link time flags
if(NOT ${links} STREQUAL "")
	target_link_libraries(${target_name} ${links})
endif(NOT ${links} STREQUAL "")

endfunction(manage_Additional_Component_Flags target_name defs links)

###
function (fill_Component_Target_Compilation c_name dep_name)

if(	${${PROJECT_NAME}_${c_name}_TYPE} STREQUAL "APP"
	OR ${${PROJECT_NAME}_${c_name}_TYPE} STREQUAL "SHARED")
	if(NOT ${${dep_name}_INC_DIRS} STREQUAL "")
		target_include_directories(${c_name} PUBLIC ${${dep_name}_INC_DIRS})
	endif(NOT ${${dep_name}_INC_DIRS} STREQUAL "")

	if(NOT ${${dep_name}_DEFS} STREQUAL "")
		target_compile_definitions(${c_name} PUBLIC ${${dep_name}_DEFS})
	endif(NOT ${${dep_name}_DEFS} STREQUAL "")

elseif(	${${PROJECT_NAME}_${c_name}_TYPE} STREQUAL "STATIC")
	if(NOT ${${dep_name}_INC_DIRS} STREQUAL "")
		target_include_directories(${c_name}-st PUBLIC ${${dep_name}_INC_DIRS})
	endif(NOT ${${dep_name}_INC_DIRS} STREQUAL "")

	if(NOT ${${dep_name}_DEFS} STREQUAL "")
		target_compile_definitions(${c_name}-st PUBLIC ${${dep_name}_DEFS})
	endif(NOT ${${dep_name}_DEFS} STREQUAL "")
endif()#do nothing in case of a pure header component

endfunction (fill_Component_Target_Compilation c_name dep_name)

###
function (fill_Component_Target_Linking c_name dep_name)

if(	${${PROJECT_NAME}_${c_name}_TYPE} STREQUAL "APP"
	OR ${${PROJECT_NAME}_${c_name}_TYPE} STREQUAL "SHARED")
	if(NOT ${${dep_name}_LINKS} STREQUAL "")
		target_link_libraries(${c_name} ${${dep_name}_LINKS})
	endif(NOT ${${dep_name}_LINKS} STREQUAL "")
elseif(	${${PROJECT_NAME}_${c_name}_TYPE} STREQUAL "SHARED")
	if(NOT ${${dep_name}_LINKS} STREQUAL "")
		target_link_libraries(${c_name} ${${dep_name}_LINKS})
	endif(NOT ${${dep_name}_LINKS} STREQUAL "")
elseif(	${${PROJECT_NAME}_${c_name}_TYPE} STREQUAL "STATIC")
	if(NOT ${${dep_name}_LINKS} STREQUAL "")
		target_link_libraries(${c_name}-st ${${dep_name}_LINKS})
	endif(NOT ${${dep_name}_LINKS} STREQUAL "")
endif()#do nothing in case of a pure header component

endfunction (fill_Component_Target_Linking c_name dep_name)

###

##################################################################################
###################### declaration of a library component ########################
##################################################################################
function(declare_Library_Component c_name dirname type)
	#indicating that the component has been declared and need to be completed
	if(${type} STREQUAL "HEADER"
	OR ${type} STREQUAL "STATIC")
	OR ${type} STREQUAL "SHARED")
		set(${PROJECT_NAME}_${c_name}_TYPE ${type} CACHE INTERNAL "")
	else()
		message(FATAL_ERROR "you must specify a type (HEADER, STATIC or SHARED) for your library")
		return()
	endif()

	### managing headers ###
	#a library defines a folder containing one or more headers and/or subdirectories 
	set(${PROJECT_NAME}_${c_name}_TEMP_INCLUDE_DIR ${CMAKE_SOURCE_DIR}/include/${dirname} CACHE INTERNAL "")
	set(${PROJECT_NAME}_${c_name}_HEADER_DIR_NAME ${dirname})
	file(	GLOB_RECURSE
		${PROJECT_NAME}_${c_name}_HEADERS
		RELATIVE ${${PROJECT_NAME}_${c_name}_TEMP_INCLUDE_DIR}
	       	"${${PROJECT_NAME}_${c_name}_TEMP_INCLUDE_DIR}/*.h" 
		"${${PROJECT_NAME}_${c_name}_TEMP_INCLUDE_DIR}/*.hh" 
		"${${PROJECT_NAME}_${c_name}_TEMP_INCLUDE_DIR}/*.hpp"
	)

	install(DIRECTORY ${${PROJECT_NAME}_${c_name}_TEMP_INCLUDE_DIR} DESTINATION ${${PROJECT_NAME}_INSTALL_HEADERS_PATH} FILES_MATCHING PATTERN "*.h")
	install(DIRECTORY ${${PROJECT_NAME}_${c_name}_TEMP_INCLUDE_DIR} DESTINATION ${${PROJECT_NAME}_INSTALL_HEADERS_PATH} FILES_MATCHING PATTERN "*.hpp")
	install(DIRECTORY ${${PROJECT_NAME}_${c_name}_TEMP_INCLUDE_DIR} DESTINATION ${${PROJECT_NAME}_INSTALL_HEADERS_PATH} FILES_MATCHING PATTERN "*.hh")
	
	
	if(NOT ${${PROJECT_NAME}_${c_name}_TYPE} STREQUAL "HEADER")
		#collect sources for the library
		set(${PROJECT_NAME}_${c_name}_TEMP_SOURCE_DIR ${CMAKE_SOURCE_DIR}/src/${c_name})
	
		file(	GLOB_RECURSE 
			${PROJECT_NAME}_${c_name}_ALL_SOURCES 
			"${${PROJECT_NAME}_${c_name}_TEMP_SOURCE_DIR}/*.c" 
			"${${PROJECT_NAME}_${c_name}_TEMP_SOURCE_DIR}/*.cc" 
			"${${PROJECT_NAME}_${c_name}_TEMP_SOURCE_DIR}/*.cpp" 
			"${${PROJECT_NAME}_${c_name}_TEMP_SOURCE_DIR}/*.h" 
			"${${PROJECT_NAME}_${c_name}_TEMP_SOURCE_DIR}/*.hpp" 
			"${${PROJECT_NAME}_${c_name}_TEMP_SOURCE_DIR}/*.hh"
		)
		
		#defining shared and/or static targets for the library and
		#adding the targets to the list of installed components when make install is called
		if(${${PROJECT_NAME}_${c_name}_TYPE} STREQUAL "STATIC")
			add_library(${c_name}${INSTALL_NAME_SUFFIX} STATIC ${${PROJECT_NAME}_${c_name}_ALL_SOURCES})
			install(TARGETS ${c_name}${INSTALL_NAME_SUFFIX}
				ARCHIVE DESTINATION ${${PROJECT_NAME}_INSTALL_AR_PATH}
			)

		elseif(${${PROJECT_NAME}_${c_name}_TYPE} STREQUAL "SHARED")
			add_library(${c_name}${INSTALL_NAME_SUFFIX} SHARED ${${PROJECT_NAME}_${c_name}_ALL_SOURCES})
			install(TARGETS ${c_name}${INSTALL_NAME_SUFFIX}
				LIBRARY DESTINATION ${${PROJECT_NAME}_INSTALL_LIB_PATH}
				RUNTIME DESTINATION ${${PROJECT_NAME}_INSTALL_BIN_PATH}
			)
		endif()
		target_include_directories(${c_name}${INSTALL_NAME_SUFFIX} ${${PROJECT_NAME}_${c_name}_TEMP_INCLUDE_DIR})
		manage_Additional_Component_Flags(${c_name}${INSTALL_NAME_SUFFIX} ${internal_defs} "")
	endif(NOT ${${PROJECT_NAME}_${c_name}_TYPE} STREQUAL "HEADER")

	# registering exported flags for all kinds of libs
	set(${PROJECT_NAME}_${c_name}_DEFS "" CACHE INTERNAL "")
	set(${PROJECT_NAME}_${c_name}_LINKS "" CACHE INTERNAL "")	
	
	#updating global variables of the CMake process	
	set(${PROJECT_NAME}_COMPONENTS "${${PROJECT_NAME}_COMPONENTS};${c_name}" CACHE INTERNAL "")
	set(${PROJECT_NAME}_COMPONENTS_LIBS "${${PROJECT_NAME}_COMPONENTS_LIBS};${c_name}" CACHE INTERNAL "")
	# global variable to know that the component has been declared
	set(${PROJECT_NAME}_${c_name}_DECLARED TRUE CACHE INTERNAL "")
	
endfunction(declare_Library_Component c_name type)



##################################################################################
################# declaration of an application component ########################
##################################################################################
function(declare_Application_Component c_name type internal_defs internal_link_flags)
	if(${${PROJECT_NAME}_${c_name}_DECLARED})
		message("ERROR declare_Application_Component : a component with the same name ${c_name} is already defined")
	endif()

	if(${type} STREQUAL "TEST" 
	OR ${type} STREQUAL "APP"
	OR ${type} STREQUAL "EXAMPLE")
		set(${PROJECT_NAME}_${c_name}_TYPE ${type} CACHE INTERNAL "")
	else() #a simple application by default
		message(FATAL_ERROR "tou have to set a type name (TEST, APP, EXAMPLE) for the application component ${c_name}")
	endif()	
	
	# specifically managing examples 	
	if(${${PROJECT_NAME}_${c_name}_TYPE} STREQUAL "EXAMPLE") 
		if(NOT BUILD_WITH_EXAMPLES) #examples are not built so no need to continue
			unset(${PROJECT_NAME}_${c_name}_TYPE CACHE)
			return()
		endif(NOT BUILD_WITH_EXAMPLES)
		add_Example_To_Doc(${c_name}) #examples are added to the doc to be referenced
	endif(${${PROJECT_NAME}_${c_name}_TYPE} STREQUAL "EXAMPLE")

	#managing sources for the application
	if(${${PROJECT_NAME}_${c_name}_TYPE} STREQUAL "APP"
	OR ${${PROJECT_NAME}_${c_name}_TYPE} STREQUAL "EXAMPLE")		
		set(${PROJECT_NAME}_${c_name}_TEMP_SOURCE_DIR ${CMAKE_SOURCE_DIR}/apps/${c_name})
	elseif(${${PROJECT_NAME}_${c_name}_TYPE} STREQUAL "TEST")
		set(${PROJECT_NAME}_${c_name}_TEMP_SOURCE_DIR ${CMAKE_SOURCE_DIR}/test/${c_name})
	endif()

	file(	GLOB_RECURSE 
		${PROJECT_NAME}_${c_name}_ALL_SOURCES 
		"${${PROJECT_NAME}_${c_name}_TEMP_SOURCE_DIR}/*.c" 
		"${${PROJECT_NAME}_${c_name}_TEMP_SOURCE_DIR}/*.cc" 
		"${${PROJECT_NAME}_${c_name}_TEMP_SOURCE_DIR}/*.cpp" 
		"${${PROJECT_NAME}_${c_name}_TEMP_SOURCE_DIR}/*.h" 
		"${${PROJECT_NAME}_${c_name}_TEMP_SOURCE_DIR}/*.hpp" 
		"${${PROJECT_NAME}_${c_name}_TEMP_SOURCE_DIR}/*.hh"
	)
	
	#defining the target to build the application
	add_executable(${c_name}${INSTALL_NAME_SUFFIX} ${${PROJECT_NAME}_${c_name}_ALL_SOURCES})
	manage_Additional_Component_Flags(${c_name}${INSTALL_NAME_SUFFIX} ${internal_defs} ${internal_link_flags} "" "")
	
	if(NOT ${${PROJECT_NAME}_${c_name}_TYPE} STREQUAL "TEST")
		# adding the application to the list of installed components when make install is called (not for test applications)
		INSTALL(TARGETS ${c_name}${INSTALL_NAME_SUFFIX} 
			RUNTIME DESTINATION ${${PROJECT_NAME}_INSTALL_BIN_PATH}
		)
	endif(NOT ${${PROJECT_NAME}_${c_name}_TYPE} STREQUAL "TEST")

	# registering exported flags for all kinds of apps => empty variables since applications export no flags
	set(${PROJECT_NAME}_${c_name}_DEFS "" CACHE INTERNAL "")
	set(${PROJECT_NAME}_${c_name}_LINKS "" CACHE INTERNAL "")

	#updating global variables of the CMake process	
	set(${PROJECT_NAME}_COMPONENTS "${${PROJECT_NAME}_COMPONENTS};${c_name}" CACHE INTERNAL "")
	set(${PROJECT_NAME}_COMPONENTS_APPS "${${PROJECT_NAME}_COMPONENTS_APPS};${c_name}" CACHE INTERNAL "")
	# global variable to know that the component has been declared
	set(${PROJECT_NAME}_${c_name}_DECLARED TRUE CACHE INTERNAL "")
endfunction(declare_Application_Component c_name type)


##################################################################################
####### specifying a dependency between the current package and another one ######
### global dependencies between packages (the system package is considered #######
###### as external but requires no additionnal info (default system folders) ##### 
### these functions are to be used after a find_package command. #################
##################################################################################
 
macro(declare_Package_Dependancy dep_package version exact list_of_components)
# ${PROJECT}_DEPENDENCIES				# packages required by current package
# ${PROJECT}__DEPENDANCY_${dep_package}_VERSION		# version constraint for package ${dep_package}   required by ${PROJECT}  
# ${PROJECT}_DEPENDENCY_${dep_package}_VERSION_EXACT	# TRUE if exact version is required
# ${PROJECT}_DEPENDANCY_${dep_package}_COMPONENTS	# list of composants of ${dep_package} used by current package
	# the package is necessarily required at that time
	set(${PROJECT}_DEPENDENCIES${USE_MODE_SUFFIX} ${${PROJECT}_DEPENDENCIES_RELEASE${USE_MODE_SUFFIX}} ${dep_package} CACHE INTERNAL "")
	set(${PROJECT}_DEPENDENCY_${dep_package}_VERSION${USE_MODE_SUFFIX} ${version} CACHE INTERNAL "")
macro(declare_Package_Dependancy)
 	set(${PROJECT}_DEPENDENCY_${dep_package}_${version}_EXACT${USE_MODE_SUFFIX} ${exact} CACHE INTERNAL "")
	set(${PROJECT}_DEPENDENCY_${dep_package}_COMPONENTS${USE_MODE_SUFFIX} ${${PROJECT}_DEPENDENCY_${dep_package}_COMPONENTS${USE_MODE_SUFFIX}} ${list_of_components} CACHE INTERNAL "")
	
macro(declare_Package_Dependancy)

### declare external dependncies
macro(declare_External_Package_Dependancy dep_package path_to_dependency)
	#${PROJECT}_EXTERNAL_DEPENDENCY_${dep_package}_REFERENCE_PATH is the helper path to locate external libs
	set(${PROJECT}_EXTERNAL_DEPENDENCY_${dep_package}_REFERENCE_PATH${USE_MODE_SUFFIX} ${path_to_dependency} CACHE PATH "Reference path to the root dir of external library"}
endmacro(declare_External_Package_Dependancy dep_name path_to_dependency)

##################################################################################
################# local dependencies between components ########################## 
### these functions are to be used after a find_package command and after ######## 
### the declaration of internal components (otherwise will not work) #############
##################################################################################

### declare internal dependancies between components of the same package ${PROJECT}
macro(declare_Internal_Component_Dependancy component dep_component)
	set(${PROJECT}_${component}_INTERNAL_DEPENDENCIES ${${PROJECT}_${component}_INTERNAL_DEPENDENCIES${USE_MODE_SUFFIX}} ${dep_component} CACHE INTERNAL "")
endmacro(declare_Internal_Component_Dependancy component dep_component)

### declare package dependancies between components of two packages ${PROJECT} and ${dep_package}
macro(declare_Package_Component_Dependancy component dep_package dep_component)
	# ${PROJECT}_${component}_DEPENDENCIES			# packages used by the component ${component} of the current package
	# ${PROJECT}_${component}_DEPENDANCY_${dep_package}_COMPONENTS	# components of package ${dep_package} used by component ${component} of current package
	set(${PROJECT}_${component}_DEPENDENCIES${USE_MODE_SUFFIX} ${${PROJECT}_${component}_DEPENDENCIES${USE_MODE_SUFFIX}}  ${dep_package} CACHE INTERNAL "")
	set(${PROJECT}_${component}_DEPENDENCY_${dep_package}_COMPONENTS${USE_MODE_SUFFIX}  ${${PROJECT}_${component}_DEPENDENCY_${dep_package}_COMPONENTS${USE_MODE_SUFFIX}} ${dep_component} CACHE INTERNAL "")
	
endmacro(declare_Package_Component_Dependancy component dep_component)


### declare external (add-hoc) dependancy between components of current and an external packages 
macro(declare_External_Component_Dependancy component dep_package inc_dirs defs links)
	set(${PROJECT}_${component}_EXTERNAL_DEPENDENCIES${USE_MODE_SUFFIX} ${${PROJECT}_${component}_EXTERNAL_DEPENDENCIES${USE_MODE_SUFFIX}} ${dep_package} CACHE INTERNAL "")
	set(
	${PROJECT}_${component}_EXTERNAL_DEPENDENCY_${dep_package}_INCLUDE_DIRS${USE_MODE_SUFFIX}
  	${${PROJECT}_${component}_EXTERNAL_DEPENDENCY_${dep_package}_INCLUDE_DIRS${USE_MODE_SUFFIX}} 
	${inc_dirs} CACHE INTERNAL ""
	) 
	set(
	${PROJECT}_${component}_EXTERNAL_DEPENDENCY_${dep_package}_DEFS${USE_MODE_SUFFIX}
  	${${PROJECT}_${component}_EXTERNAL_DEPENDENCY_${dep_package}_DEFS${USE_MODE_SUFFIX}} 
	${defs} CACHE INTERNAL ""
	) 
	set(
	${PROJECT}_${component}_EXTERNAL_DEPENDENCY_${dep_package}_LINKS${USE_MODE_SUFFIX}
  	${${PROJECT}_${component}_EXTERNAL_DEPENDENCY_${dep_package}_LINKS${USE_MODE_SUFFIX}} 
	${links} CACHE INTERNAL ""
	)
endmacro(declare_External_Component_Dependancy component dep_component)

### declare system (add-hoc) dependancy between components of current and a system packages 
macro(declare_System_Component_Dependancy component inc_dirs defs links)
	set(
	${PROJECT}_${component}_SYSTEM_DEPENDENCY_INCLUDE_DIRS${USE_MODE_SUFFIX}
  	${${PROJECT}_${component}_SYSTEM_DEPENDENCY_INCLUDE_DIRS${USE_MODE_SUFFIX}} 
	${inc_dirs} CACHE INTERNAL ""
	) 
	set(
	${PROJECT}_${component}_SYSTEM_DEPENDENCY_DEFS${USE_MODE_SUFFIX}
  	${${PROJECT}_${component}_SYSTEM_DEPENDENCY_DEFS${USE_MODE_SUFFIX}} 
	${defs} CACHE INTERNAL ""
	) 
	set(
	${PROJECT}_${component}_SYSTEM_DEPENDENCY_LINKS${USE_MODE_SUFFIX}
  	${${PROJECT}_${component}_SYSTEM_DEPENDENCY_LINKS${USE_MODE_SUFFIX}} 
	${links} CACHE INTERNAL ""
	)
endmacro(declare_External_Component_Dependancy component dep_component)

##################################################################################
###################### adding dependency to a component ##########################
### to be used after a call to a declare_Component and the corresponding declare_Dependency functions
########################################################################################################

# il faut définir une sorte de "configuration" pour lier le composant à ses dépendances
# idée déclarer le composant de manière conditionelle en fonction des résultats des find_packages

function(add_Component_Dependency c_name dep_name)

#checking that arguments are correct
if(NOT DEFINED ${dep_name}_TYPE)
	message("ERROR add_Component_Dependency : the dependency ${dep_name} has not been defined")
endif(NOT DEFINED ${dep_name}_TYPE)

if (NOT DEFINED ${PROJECT_NAME}_${c_name}_TYPE)
	message("ERROR add_Component_Dependency : the component ${c_name} has not been defined")
endif(NOT DEFINED ${PROJECT_NAME}_${c_name}_TYPE)

if(${${PROJECT_NAME}_${c_name}_TYPE} STREQUAL "HEADER")
	# specific case when the type of component is pure header 
	# => there is no target to populate with target_xxx functions
	#adding the dependency to the list of dependencies of the component
	set(${PROJECT_NAME}_${c_name}_DEPENDENCIES ${${PROJECT_NAME}_${c_name}_DEPENDENCIES};${dep_name} CACHE INTERNAL "")
	return() #no need to do more
else(${${PROJECT_NAME}_${c_name}_TYPE} STREQUAL "HEADER")
	#adding the dependency to the list of dependencies of the component
	set(${PROJECT_NAME}_${c_name}_DEPENDENCIES ${${PROJECT_NAME}_${c_name}_DEPENDENCIES};${dep_name} CACHE INTERNAL "")
endif()

# compile and link time operations have to be done
fill_Component_Target_Compilation(${c_name} ${dep_name})
fill_Component_Target_Linking(${c_name} ${dep_name})

endfunction(add_Component_Dependency c_name dep_name)


