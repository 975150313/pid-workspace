########################################################################
############ inclusion of required macros and functions ################
########################################################################
include(Package_Internal_Finding)
include(Package_Internal_Configuration)

##################################################################################
#################### package management public functions and macros ##############
##################################################################################

##################################################################################
###########################  declaration of the package ##########################
##################################################################################
macro(declare_Package author institution year license address description)
#################################################
############ DECLARING options ##################
#################################################
list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/share/cmake) # adding the cmake scripts files from the package
list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/find) # using common find modules of the workspace

include(CMakeDependentOption)
option(BUILD_EXAMPLES "Package builds examples" ON)

option(BUILD_API_DOC "Package generates the HTML API documentation" ON)
CMAKE_DEPENDENT_OPTION(BUILD_LATEX_API_DOC "Package generates the LATEX api documentation" OFF
		         "BUILD_API_DOC" OFF)

option(BUILD_AND_RUN_TESTS "Package uses tests" OFF)
option(BUILD_WITH_PRINT_MESSAGES "Package generates print in console" OFF)

option(USE_LOCAL_DEPLOYMENT "Package uses tests" ON)
CMAKE_DEPENDENT_OPTION(GENERATE_INSTALLER "Package generates an OS installer for linux with debian" ON
		         "NOT USE_LOCAL_DEPLOYMENT" OFF)

option(REQUIRED_PACKAGES_AUTOMATIC_DOWNLOAD "Enabling the automatic download of not found packages marked as required" OFF)

#################################################
############ MANAGING build mode ################
#################################################
if(${CMAKE_BINARY_DIR} MATCHES release)
	reset_Mode_Cache_Options()

	set(CMAKE_BUILD_TYPE "Release" CACHE String "the type of build is dependent from build location" FORCE)
	set ( INSTALL_NAME_SUFFIX "" CACHE INTERNAL "")
	set ( USE_MODE_SUFFIX "" CACHE INTERNAL "")
	
elseif(${CMAKE_BINARY_DIR} MATCHES debug)
	reset_Mode_Cache_Options()
	
	set(CMAKE_BUILD_TYPE "Debug" CACHE String "the type of build is dependent from build location" FORCE)
	set ( INSTALL_NAME_SUFFIX -dbg CACHE INTERNAL "")
	set ( USE_MODE_SUFFIX "_DEBUG" CACHE INTERNAL "")
	
elseif(${CMAKE_BINARY_DIR} MATCHES build)

	add_custom_target(build ALL
		COMMAND ${CMAKE_COMMAND} -E  chdir ${CMAKE_BINARY_DIR}/debug ${CMAKE_BUILD_TOOL} build
		COMMAND ${CMAKE_COMMAND} -E  chdir ${CMAKE_BINARY_DIR}/release ${CMAKE_BUILD_TOOL} build
	)
	add_custom_target(clean
		COMMAND ${CMAKE_COMMAND} -E  chdir ${CMAKE_BINARY_DIR}/debug ${CMAKE_BUILD_TOOL} clean
		COMMAND ${CMAKE_COMMAND} -E  chdir ${CMAKE_BINARY_DIR}/release ${CMAKE_BUILD_TOOL} clean
	)

	if(NOT EXISTS ${CMAKE_BINARY_DIR}/debug OR NOT IS_DIRECTORY ${CMAKE_BINARY_DIR}/debug)
		execute_process(COMMAND ${CMAKE_COMMAND} -E  make_directory debug WORKING_DIRECTORY ${CMAKE_BINARY_DIR})
	endif()
	if(NOT EXISTS ${CMAKE_BINARY_DIR}/release OR NOT IS_DIRECTORY ${CMAKE_BINARY_DIR}/release)
		execute_process(COMMAND ${CMAKE_COMMAND} -E  make_directory release WORKING_DIRECTORY ${CMAKE_BINARY_DIR})
	endif()
	
	#getting options
	execute_process(COMMAND ${CMAKE_COMMAND} -L -N WORKING_DIRECTORY ${CMAKE_BINARY_DIR} OUTPUT_FILE ${CMAKE_BINARY_DIR}/options.txt)
	#parsing option file and generating a load cache cmake script	
	file(STRINGS ${CMAKE_BINARY_DIR}/options.txt LINES)
	set(OPTIONS_FILE ${CMAKE_BINARY_DIR}/share/cacheConfig.cmake) 
	file(WRITE ${OPTIONS_FILE} "")
	foreach(line IN ITEMS ${LINES})
		if(NOT ${line} STREQUAL "-- Cache values")
			string(REGEX REPLACE "^([^:]+):([^=]+)=(.*)$" "set( \\1 \\3\ CACHE \\2 \"\" FORCE)\n" AN_OPTION "${line}")
			file(APPEND ${OPTIONS_FILE} ${AN_OPTION})
		endif()
	endforeach()
	
	execute_process(COMMAND ${CMAKE_COMMAND} ${CMAKE_SOURCE_DIR} WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/debug)
	execute_process(COMMAND ${CMAKE_COMMAND} ${CMAKE_SOURCE_DIR} WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/release)
	return()
else()	# the build must be done in the build directory
	message(WARNING "Please run cmake in the build folder of the package ${PROJECT_NAME}")
	return()
endif(${CMAKE_BINARY_DIR} MATCHES release)

#################################################
############ Initializing variables #############
#################################################
reset_cached_variables()

set(${PROJECT_NAME}_MAIN_AUTHOR "${author}" CACHE INTERNAL "")
set(${PROJECT_NAME}_MAIN_INSTITUTION "${institution}" CACHE INTERNAL "")

set(${PROJECT_NAME}_AUTHORS_AND_INSTITUTIONS "${author}(${institution})" CACHE INTERNAL "")

set(${PROJECT_NAME}_DESCRIPTION "${description}" CACHE INTERNAL "")
set(${PROJECT_NAME}_YEARS ${year} CACHE INTERNAL "")
set(${PROJECT_NAME}_LICENSE ${license} CACHE INTERNAL "")
set(${PROJECT_NAME}_ADDRESS ${address} CACHE INTERNAL "")

#################################################
############ MANAGING generic paths #############
#################################################
set(PACKAGE_BINARY_INSTALL_DIR ${WORKSPACE_DIR}/install CACHE INTERNAL "")
set(${PROJECT_NAME}_INSTALL_PATH ${PACKAGE_BINARY_INSTALL_DIR}/${PROJECT_NAME} CACHE INTERNAL "")
set(CMAKE_INSTALL_PREFIX ${${PROJECT_NAME}_INSTALL_PATH})

if(BUILD_WITH_PRINT_MESSAGES)
	add_definitions(-DPRINT_MESSAGES)
endif(BUILD_WITH_PRINT_MESSAGES)
endmacro(declare_Package)


############################################################################
################## setting currently developed version number ##############
############################################################################
function(set_Current_Version major minor patch)

	set (${PROJECT_NAME}_VERSION_MAJOR ${major} CACHE INTERNAL "")
	set (${PROJECT_NAME}_VERSION_MINOR ${minor} CACHE INTERNAL "")
	set (${PROJECT_NAME}_VERSION_PATCH ${patch} CACHE INTERNAL "")
	set (${PROJECT_NAME}_VERSION ${${PROJECT_NAME}_VERSION_MAJOR}.${${PROJECT_NAME}_VERSION_MINOR}.${${PROJECT_NAME}_VERSION_PATCH} CACHE INTERNAL "")
	message(STATUS "version currently built = "${${PROJECT_NAME}_VERSION})

	#################################################
	############ MANAGING install paths #############
	#################################################
	if(USE_LOCAL_DEPLOYMENT)
		set(${PROJECT_NAME}_DEPLOY_PATH own-${${PROJECT_NAME}_VERSION} CACHE INTERNAL "")
	else(USE_LOCAL_DEPLOYMENT)
		set(${PROJECT_NAME}_DEPLOY_PATH ${${PROJECT_NAME}_VERSION} CACHE INTERNAL "")
	endif(USE_LOCAL_DEPLOYMENT) 
	set ( ${PROJECT_NAME}_INSTALL_LIB_PATH ${${PROJECT_NAME}_DEPLOY_PATH}/lib CACHE INTERNAL "")
	set ( ${PROJECT_NAME}_INSTALL_AR_PATH ${${PROJECT_NAME}_DEPLOY_PATH}/lib CACHE INTERNAL "")
	set ( ${PROJECT_NAME}_INSTALL_HEADERS_PATH ${${PROJECT_NAME}_DEPLOY_PATH}/include CACHE INTERNAL "")
	set ( ${PROJECT_NAME}_INSTALL_SHARE_PATH ${${PROJECT_NAME}_DEPLOY_PATH}/share CACHE INTERNAL "")
	set ( ${PROJECT_NAME}_INSTALL_BIN_PATH ${${PROJECT_NAME}_DEPLOY_PATH}/bin CACHE INTERNAL "")
	set ( ${PROJECT_NAME}_INSTALL_RPATH_DIR ${${PROJECT_NAME}_DEPLOY_PATH}/.rpath CACHE INTERNAL "")
endfunction(set_Current_Version)

############################################################################
############### API functions for setting additionnal package info #########
############################################################################
###
function(add_Author author institution)
	set(${PROJECT_NAME}_AUTHORS_AND_INSTITUTIONS ${${PROJECT_NAME}_AUTHORS_AND_INSTITUTIONS} "${author}(${institution})" CACHE INTERNAL "")
endfunction(add_Author)


###
function(add_Reference version system url url-dbg)
	set(${PROJECT_NAME}_REFERENCES ${${PROJECT_NAME}_REFERENCES} ${version} CACHE INTERNAL "")
	set(${PROJECT_NAME}_REFERENCE_${version} ${${PROJECT_NAME}_REFERENCE_${version}} ${system} CACHE INTERNAL "")
	set(${${PROJECT_NAME}_REFERENCE_${version}_${system} ${url} CACHE INTERNAL "")
	set(${${PROJECT_NAME}_REFERENCE_${version}_${system}_DEBUG ${url-dbg} CACHE INTERNAL "")
endfunction(add_Reference)

###
function(add_Caterory category_spec)
	set(${PROJECT_NAME}_CATEGORIES ${${PROJECT_NAME}_CATEGORIES} ${category_spec} CACHE INTERNAL "")
endfunction(add_Caterory)



##################################################################################
################################### building the package #########################
##################################################################################
macro(build_Package)

set(CMAKE_SKIP_BUILD_RPATH  FALSE) # don't skip the full RPATH for the build tree
set(CMAKE_BUILD_WITH_INSTALL_RPATH FALSE) # when building, don't use the install RPATH already
#set(CMAKE_INSTALL_RPATH "${${PROJECT_NAME}_INSTALL_PATH}/${${PROJECT_NAME}_INSTALL_LIB_PATH}") 
if(UNIX AND NOT APPLE)
	set(CMAKE_INSTALL_RPATH "\$ORIGIN/../lib") #the default install rpath is the library folder of the installed package (internal libraries managed by default), name is relative to $ORIGIN to enable easy package relocation
else() #TODO with APPLE
	message("install system is compatible with UNIX systems but not APPLE")
endif()

#################################################################################
############ MANAGING the configuration of package dependencies #################
#################################################################################

# from here only direct dependencies have been satisfied
# 0) if there are packages to install it means that there are some unresolved required dependencies
if(${PROJECT_NAME}_TOINSTALL_PACKAGES)
	if(REQUIRED_PACKAGES_AUTOMATIC_DOWNLOAD)
		message(FATAL_ERROR "there are some unresolved required package dependencies : ${${PROJECT_NAME}_TOINSTALL_PACKAGES}. Automatic download of package not supported yet")#TODO
		return()
	else()	
		message(FATAL_ERROR "there are some unresolved required package dependencies : ${${PROJECT_NAME}_TOINSTALL_PACKAGES}. You may download them \"by hand\" or use the required packages automatic download option")
		return()
	endif()

endif()

# 1) resolving required packages versions (there can be multiple versions required at the same time)
# we get the set of all packages undirectly required
foreach(dep_pack IN ITEMS ${PROJECT_NAME}_DEPENDENCIES${USE_MODE_SUFFIX})
	resolve_Package_Build_Dependencies(${dep_pack})
endforeach()
#here every package dependency should have been resolved OR ERROR

# 2) if all version are OK resolving all necessary variables (CFLAGS, LDFLAGS and include directories)
foreach(dep_pack IN ITEMS ${PROJECT_NAME}_DEPENDENCIES${USE_MODE_SUFFIX})
	configure_Package_Build_Variables(${dep_pack})
endforeach()

# 3) when done resolving runtime dependencies for all used package (direct or undirect)
foreach(dep_pack IN ITEMS ${PROJECT_NAME}_DEPENDENCIES${USE_MODE_SUFFIX})
	resolve_Package_Runtime_Dependencies(${dep_pack} ${CMAKE_BUILD_TYPE})
endforeach()

#################################################
############ MANAGING the BUILD #################
#################################################

# recursive call into subdirectories to build/install/test the package
add_subdirectory(src)
add_subdirectory(apps)
add_subdirectory(test)
add_subdirectory(share)

##########################################################
############ MANAGING non source files ###################
##########################################################
generate_License_File() # generating/installing the file containing license info about the package
generate_Find_File() # generating/installing the generic cmake find file for the package
if(${CMAKE_BUILD_TYPE} MATCHES Release)
	#installing the share/cmake folder (may contain specific find scripts for external libs used by the package)
	install(DIRECTORY ${CMAKE_SOURCE_DIR}/share/cmake DESTINATION ${${PROJECT_NAME}_INSTALL_SHARE_PATH})
endif()
generate_Use_File() #generating/installing the version specific cmake "use" file
generate_API() #generating/installing the API documentation

#resolving dependencies
foreach(component IN ITEMS ${${PROJECT_NAME}_COMPONENTS})
	resolve_Source_Component_Runtime_Dependencies(${component})
endforeach()

#################################################
##### MANAGING the SYSTEM PACKAGING #############
#################################################
# both release and debug packages are built and both must be generated+upoaded / downloaded+installed in the same time
if(GENERATE_INSTALLER)
	include(InstallRequiredSystemLibraries)
	#common infos	
	set(CPACK_PACKAGE_NAME "${PROJECT_NAME}")
	set(CPACK_PACKAGE_CONTACT ${${PROJECT_NAME}_MAIN_AUTHOR})
	set(CPACK_PACKAGE_DESCRIPTION_SUMMARY ${${PROJECT_NAME}_DESCRIPTION})
	set(CPACK_PACKAGE_VENDOR ${${PROJECT_NAME}_MAIN_INSTITUTION})
	set(CPACK_RESOURCE_FILE_LICENSE ${CMAKE_SOURCE_DIR}/license.txt)
	set(CPACK_PACKAGE_VERSION_MAJOR ${${PROJECT_NAME}_VERSION_MAJOR})
	set(CPACK_PACKAGE_VERSION_MINOR ${${PROJECT_NAME}_VERSION_MINOR})
	set(CPACK_PACKAGE_VERSION_PATCH ${${PROJECT_NAME}_VERSION_PATCH})
	set(CPACK_PACKAGE_VERSION "${${PROJECT_NAME}_VERSION}${INSTALL_NAME_SUFFIX}")
	set(CPACK_PACKAGE_INSTALL_DIRECTORY "${PROJECT_NAME}/${${PROJECT_NAME}_VERSION}")

	if(UNIX AND NOT APPLE AND NOT CYGWIN)#on any unix platform

		list(APPEND CPACK_GENERATOR DEB)	
		execute_process(COMMAND dpkg --print-architecture OUTPUT_VARIABLE OUT_DPKG)
		set(CPACK_DEBIAN_PACKAGE_ARCHITECTURE ${OUT_DPKG})
		 		

		add_custom_target(package_install
				COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_BINARY_DIR}/${PROJECT_NAME}-${${PROJECT_NAME}_VERSION}${INSTALL_NAME_SUFFIX}-Linux.deb
				${${PROJECT_NAME}_INSTALL_PATH}/installers/${PROJECT_NAME}-${${PROJECT_NAME}_VERSION}${INSTALL_NAME_SUFFIX}-Linux.deb
				COMMENT "installing ${CMAKE_BINARY_DIR}/${PROJECT_NAME}-${${PROJECT_NAME}_VERSION}${INSTALL_NAME_SUFFIX}-Linux.deb in ${${PROJECT_NAME}_INSTALL_PATH}/installers"
				)
	endif() 
	
	if(CPACK_GENERATOR DEB) #there are defined generators
		include(CPack)
	endif()
endif(GENERATE_INSTALLER)

###############################################################################
######### creating build target for easy sequencing all make commands #########
###############################################################################

#creating a global build command
if(GENERATE_INSTALLER)
	if(CMAKE_BUILD_TYPE MATCHES Release)
		if(BUILD_AND_RUN_TESTS)
			if(BUILD_API_DOC)
				add_custom_target(build 
					COMMAND ${CMAKE_BUILD_TOOL}
					COMMAND ${CMAKE_BUILD_TOOL} test
					COMMAND ${CMAKE_BUILD_TOOL} doc 
					COMMAND ${CMAKE_BUILD_TOOL} install
					COMMAND ${CMAKE_BUILD_TOOL} package
					COMMAND ${CMAKE_BUILD_TOOL} package_install
				)
			else(BUILD_API_DOC)
				add_custom_target(build 
					COMMAND ${CMAKE_BUILD_TOOL}
					COMMAND ${CMAKE_BUILD_TOOL} test
					COMMAND ${CMAKE_BUILD_TOOL} install
					COMMAND ${CMAKE_BUILD_TOOL} package
					COMMAND ${CMAKE_BUILD_TOOL} package_install
				)
			endif(BUILD_API_DOC) 
		else(BUILD_AND_RUN_TESTS)
			if(BUILD_API_DOC)
				add_custom_target(build 
					COMMAND ${CMAKE_BUILD_TOOL}
					COMMAND ${CMAKE_BUILD_TOOL} doc 
					COMMAND ${CMAKE_BUILD_TOOL} install
					COMMAND ${CMAKE_BUILD_TOOL} package
					COMMAND ${CMAKE_BUILD_TOOL} package_install
				)
			else(BUILD_API_DOC)
				add_custom_target(build 
					COMMAND ${CMAKE_BUILD_TOOL}
					COMMAND ${CMAKE_BUILD_TOOL} install
					COMMAND ${CMAKE_BUILD_TOOL} package
					COMMAND ${CMAKE_BUILD_TOOL} package_install
				)
			endif(BUILD_API_DOC)
		endif(BUILD_AND_RUN_TESTS)
	else(CMAKE_BUILD_TYPE MATCHES Release)
		if(BUILD_AND_RUN_TESTS)
			add_custom_target(build 
				COMMAND ${CMAKE_BUILD_TOOL} 
				COMMAND ${CMAKE_BUILD_TOOL} test
				COMMAND ${CMAKE_BUILD_TOOL} install
				COMMAND ${CMAKE_BUILD_TOOL} package
				COMMAND ${CMAKE_BUILD_TOOL} package_install
			) 
		else(BUILD_AND_RUN_TESTS)
			add_custom_target(build 
				COMMAND ${CMAKE_BUILD_TOOL} 
				COMMAND ${CMAKE_BUILD_TOOL} install
				COMMAND ${CMAKE_BUILD_TOOL} package
				COMMAND ${CMAKE_BUILD_TOOL} package_install
			)  
		endif(BUILD_AND_RUN_TESTS)

	endif(CMAKE_BUILD_TYPE MATCHES Release)

else(GENERATE_INSTALLER)
	if(CMAKE_BUILD_TYPE MATCHES Release)
		if(BUILD_AND_RUN_TESTS)
			if(BUILD_API_DOC)
				add_custom_target(build 
					COMMAND ${CMAKE_BUILD_TOOL}
					COMMAND ${CMAKE_BUILD_TOOL} test
					COMMAND ${CMAKE_BUILD_TOOL} doc 
					COMMAND ${CMAKE_BUILD_TOOL} install
				)
			else(BUILD_API_DOC)
				add_custom_target(build 
					COMMAND ${CMAKE_BUILD_TOOL}
					COMMAND ${CMAKE_BUILD_TOOL} test
					COMMAND ${CMAKE_BUILD_TOOL} install
				)
			endif(BUILD_API_DOC) 
		else(BUILD_AND_RUN_TESTS)
			if(BUILD_API_DOC)
				add_custom_target(build 
					COMMAND ${CMAKE_BUILD_TOOL}
					COMMAND ${CMAKE_BUILD_TOOL} doc 
					COMMAND ${CMAKE_BUILD_TOOL} install
				)
			else(BUILD_API_DOC) 
				add_custom_target(build 
					COMMAND ${CMAKE_BUILD_TOOL}
					COMMAND ${CMAKE_BUILD_TOOL} install
				)
			endif(BUILD_API_DOC)
		endif()
	else(CMAKE_BUILD_TYPE MATCHES Release)
		if(BUILD_AND_RUN_TESTS)
			add_custom_target(build 
				COMMAND ${CMAKE_BUILD_TOOL}
				COMMAND ${CMAKE_BUILD_TOOL} test
				COMMAND ${CMAKE_BUILD_TOOL} install
			) 
		else(BUILD_AND_RUN_TESTS)
			
			add_custom_target(build 
				COMMAND ${CMAKE_BUILD_TOOL} 
				COMMAND ${CMAKE_BUILD_TOOL} install
			) 
		endif(BUILD_AND_RUN_TESTS)
	endif(CMAKE_BUILD_TYPE MATCHES Release)
endif(GENERATE_INSTALLER)

endmacro(build_Package)


##################################################################################
############# auxiliary package management internal functions and macros #########
##################################################################################

### printing variables for components in the package ################
macro(printComponentVariables)
	message("components of package ${PROJECT_NAME} are :" ${${PROJECT_NAME}_COMPONENTS})
	message("libraries : "${${PROJECT_NAME}_COMPONENTS_LIBS})
	message("applications : "${${PROJECT_NAME}_COMPONENTS_APPS})
endmacro(printComponentVariables)


### generating the license of the package
function(generate_License_File)
if(${CMAKE_BUILD_TYPE} MATCHES Release)
	if(	DEFINED ${PROJECT_NAME}_LICENSE 
		AND NOT ${${PROJECT_NAME}_LICENSE} STREQUAL "")
	
		find_file(	LICENSE   
				"License${${PROJECT_NAME}_LICENSE}.cmake"
				PATH "${WORKSPACE_DIR}/share/cmake/system"
				NO_DEFAULT_PATH
			)
		set(LICENSE ${LICENSE} CACHE INTERNAL "")
		
		if(LICENSE_IN-NOTFOUND)
			message(WARNING "license configuration file for ${${PROJECT_NAME}_LICENSE} not found in workspace, license file will not be generated")
		else(LICENSE_IN-NOTFOUND)
			include(${WORKSPACE_DIR}/share/cmake/licenses/License${${PROJECT_NAME}_LICENSE}.cmake)
			file(WRITE ${CMAKE_SOURCE_DIR}/license.txt ${LICENSE_LEGAL_TERMS})
			install(FILES ${CMAKE_SOURCE_DIR}/license.txt DESTINATION ${${PROJECT_NAME}_DEPLOY_PATH})
		endif(LICENSE_IN-NOTFOUND)
	endif()
endif()
endfunction(generate_License_File)

### generating the Find<package>.cmake file of the package
function(generate_Find_File)
if(${CMAKE_BUILD_TYPE} MATCHES Release)
	# generating/installing the generic cmake find file for the package 
	configure_file(${WORKSPACE_DIR}/share/cmake/patterns/FindPackage.cmake.in ${CMAKE_BINARY_DIR}/share/Find${PROJECT_NAME}.cmake @ONLY)
	install(FILES ${CMAKE_BINARY_DIR}/share/Find${PROJECT_NAME}.cmake DESTINATION ${WORKSPACE_DIR}/share/cmake/find) #install in the worskpace cmake directory which contains cmake find modules
endif()
endfunction(generate_Find_File)

### generating the Use<package>-<version>.cmake file for the current package version
macro(generate_Use_File)
create_Use_File()
if(${CMAKE_BUILD_TYPE} MATCHES Release)
	install(	FILES ${CMAKE_BINARY_DIR}/share/Use${PROJECT_NAME}-${${PROJECT_NAME}_VERSION}.cmake 
			DESTINATION ${${PROJECT_NAME}_INSTALL_SHARE_PATH}
	)
endif()
endmacro(generate_Use_File)


### configure variables exported by component that will be used to generate the package cmake use file
function (configure_Install_Variables component export include_dirs dep_defs exported_defs static_links shared_links)

# configuring the export
if(export) # if dependancy library is exported then we need to register its dep_defs and include dirs in addition to component interface defs
	if(	NOT dep_defs STREQUAL "" 
		OR NOT exported_defs  STREQUAL "")	
		set(	${PROJECT_NAME}_${component}_DEFS${USE_MODE_SUFFIX}
			${${PROJECT_NAME}_${component}_DEFS${USE_MODE_SUFFIX}} 
			${exported_defs} ${dep_defs}
			CACHE INTERNAL "")
	endif()
	if(NOT include_dirs STREQUAL "")
		set(	${PROJECT_NAME}_${component}_INC_DIRS${USE_MODE_SUFFIX} 
			${${PROJECT_NAME}_${component}_INC_DIRS${USE_MODE_SUFFIX}} 
			${include_dirs}
			CACHE INTERNAL "")
	endif()
	# links are exported since we will need to resolve symbols in the third party components that will the use the component 	
	if(NOT shared_links STREQUAL "")
		set(	${PROJECT_NAME}_${component}_LINKS${USE_MODE_SUFFIX}
			${${PROJECT_NAME}_${component}_LINKS${USE_MODE_SUFFIX}}
			${shared_links}
			CACHE INTERNAL "")
	endif()
	if(NOT static_links STREQUAL "")
		set(	${PROJECT_NAME}_${component}_LINKS${USE_MODE_SUFFIX}
			${${PROJECT_NAME}_${component}_LINKS${USE_MODE_SUFFIX}}
			${static_links}
			CACHE INTERNAL "")
	endif()

else() # otherwise no need to register them since no more useful
	if(NOT exported_defs STREQUAL "") 
		#just add the exported defs of the component not those of the dependency
		set(	${PROJECT_NAME}_${component}_DEFS${USE_MODE_SUFFIX}
			${${PROJECT_NAME}_${component}_DEFS${USE_MODE_SUFFIX}} 
			${exported_defs}
			CACHE INTERNAL "")
	endif()
	if(	NOT static_links STREQUAL "" #static links are exported if component is not a shared lib
		AND (	${PROJECT_NAME}_${component}_TYPE STREQUAL "HEADER" 
			OR ${PROJECT_NAME}_${component}_TYPE STREQUAL "STATIC"
		)
	)
		
		set(	${PROJECT_NAME}_${component}_LINKS${USE_MODE_SUFFIX}
			${${PROJECT_NAME}_${component}_LINKS${USE_MODE_SUFFIX}}
			${static_links}
			CACHE INTERNAL "")
	endif()
endif()

endfunction(configure_Install_Variables)

### to know if the component is an application
function(is_Executable_Component ret_var package component)
if (	${package}_${component}_TYPE STREQUAL "APP"
	OR ${package}_${component}_TYPE STREQUAL "EXAMPLE"
	OR ${package}_${component}_TYPE STREQUAL "TEST"
	)
	set(${ret_var} TRUE PARENT_SCOPE)
else()
	set(${ret_var} FALSE PARENT_SCOPE)
endif()
endfunction(is_Executable_Component)

### to know if component will be built
function (is_Built_Component ret_var  package component)
if (	${package}_${component}_TYPE STREQUAL "APP"
	OR ${package}_${component}_TYPE STREQUAL "EXAMPLE"
	OR ${package}_${component}_TYPE STREQUAL "TEST"
	OR ${package}_${component}_TYPE STREQUAL "STATIC"
	OR ${package}_${component}_TYPE STREQUAL "SHARED"
)
	set(${ret_var} TRUE PARENT_SCOPE)
else()
	set(${ret_var} FALSE PARENT_SCOPE)
endif()
endfunction(is_Built_Component)

### 
function(will_be_Built result component)
if(NOT ${PROJECT_NAME}_${component}_DECLARED)
	set(${result} FALSE PARENT_SCOPE)
	message(FATAL_ERROR "component ${component} does not exist")
elseif( (${PROJECT_NAME}_${component}_TYPE STREQUAL "TEST" AND NOT BUILD_AND_RUN_TESTS)
	OR (${PROJECT_NAME}_${component}_TYPE STREQUAL "EXAMPLE" AND NOT BUILD_EXAMPLES))
	set(${result} FALSE PARENT_SCOPE)
else()
	set(${result} TRUE PARENT_SCOPE)
endif()
endfunction(will_be_Built)


### adding source code of the example components to the API doc
function(add_Example_To_Doc c_name)
	file(MAKE_DIRECTORY ${PROJECT_BINARY_DIR}/share/examples/)
	file(COPY ${${PROJECT_NAME}_${c_name}_TEMP_SOURCE_DIR} DESTINATION ${PROJECT_BINARY_DIR}/share/examples/)
endfunction(add_Example_To_Doc c_name)

### generating API documentation for the package
function(generate_API)

if(${CMAKE_BUILD_TYPE} MATCHES Release) # if in release mode we generate the doc

if(NOT BUILD_API_DOC)
	return()
endif()

#finding doxygen tool and doxygen configuration file 
find_package(Doxygen)
if(NOT DOXYGEN_FOUND)
	message(WARNING "Doxygen not found please install it to generate the API documentation")
	return()
endif(NOT DOXYGEN_FOUND)
find_file(DOXYFILE_IN   "Doxyfile.in"
			PATHS "${CMAKE_SOURCE_DIR}/share/doxygen"
			NO_DEFAULT_PATH
	)
set(DOXYFILE_IN ${DOXYFILE_IN} CACHE INTERNAL "")
if(DOXYFILE_IN-NOTFOUND)
	message(WARNING "Doxyfile not found in the share folder of your package !! Getting the standard doxygen template file from workspace ... ")
	find_file(GENERIC_DOXYFILE_IN   "Doxyfile.in"
					PATHS "${WORKSPACE_DIR}/share/cmake/patterns"
					NO_DEFAULT_PATH
		)
	set(GENERIC_DOXYFILE_IN ${GENERIC_DOXYFILE_IN} CACHE INTERNAL "")
	if(GENERIC_DOXYFILE_IN-NOTFOUND)
		message(WARNING "No Template file found in ${WORKSPACE_DIR}/share/cmake/patterns/, skipping documentation generation !!")		
	else(GENERIC_DOXYFILE_IN-NOTFOUND)
		file(COPY ${WORKSPACE_DIR}/share/cmake/patterns/Doxyfile.in ${CMAKE_SOURCE_DIR}/share/doxygen)
		message(STATUS "Template file found in ${WORKSPACE_DIR}/share/cmake/patterns/ and copied to your package, you can now modify it")		
	endif(GENERIC_DOXYFILE_IN-NOTFOUND)
endif(DOXYFILE_IN-NOTFOUND)

if(DOXYGEN_FOUND AND (NOT DOXYFILE_IN-NOTFOUND OR NOT GENERIC_DOXYFILE_IN-NOTFOUND)) #we are able to generate the doc
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

	if(BUILD_LATEX_API_DOC)
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

	else(BUILD_LATEX_API_DOC)
		set(DOXYFILE_GENERATE_LATEX "NO")
	endif(BUILD_LATEX_API_DOC)

	#configuring the Doxyfile.in file to generate a doxygen configuration file
	configure_file(${CMAKE_SOURCE_DIR}/share/doxygen/Doxyfile.in ${CMAKE_BINARY_DIR}/share/Doxyfile @ONLY)
	### end doxyfile configuration ###

	### installing documentation ###
	install(DIRECTORY ${CMAKE_BINARY_DIR}/share/doc DESTINATION ${${PROJECT_NAME}_INSTALL_SHARE_PATH})

	### end installing documentation ###

endif()
	set(BUILD_API_DOC OFF FORCE)
endif()
endfunction(generate_API)


### configure the target with exported flags (cflags and ldflags)
function(manage_Additional_Component_Exported_Flags component_name inc_dirs defs links)
#message("manage_Additional_Component_Exported_Flags ${component_name} includes = ${inc_dirs}, defs = ${defs}, links=${links} \n")

# managing compile time flags (-I<path>)
if(NOT inc_dirs STREQUAL "")
	target_include_directories(${component_name}${INSTALL_NAME_SUFFIX} PUBLIC "${inc_dirs}") #not before 2.8.11	
endif()
# managing compile time flags (-D<preprocessor_defs>)
if(NOT defs STREQUAL "")
	target_compile_definitions(${component_name}${INSTALL_NAME_SUFFIX} PUBLIC "${defs}") #not before 2.8.11
endif()
# managing link time flags
if(NOT links STREQUAL "")
	target_link_libraries(${component_name}${INSTALL_NAME_SUFFIX} ${links})
endif()

endfunction(manage_Additional_Component_Exported_Flags)


### configure the target with internal flags (cflags only)
function(manage_Additional_Component_Internal_Flags component_name inc_dirs defs)
# managing compile time flags
#message("manage_Additional_Component_Internal_Flags ${component_name} includes = ${inc_dirs}, defs = ${defs} ")
if(NOT inc_dirs STREQUAL "")
	target_include_directories(${component_name}${INSTALL_NAME_SUFFIX} PRIVATE "${inc_dirs}")
endif()

# managing compile time flags
if(NOT defs STREQUAL "")
	target_compile_definitions(${component_name}${INSTALL_NAME_SUFFIX} PRIVATE "${defs}")
endif()
endfunction(manage_Additional_Component_Internal_Flags)


### configure the target to link with another target issued from a component of the same package
function (fill_Component_Target_With_Internal_Dependency component dep_component export comp_defs comp_exp_defs dep_defs)
is_Built_Component(COMP_IS_BUILT ${PROJECT_NAME} ${component})
is_Executable_Component(DEP_IS_EXEC ${PROJECT_NAME} ${dep_component})
if(COMP_IS_BUILT) #the component has a corresponding target

	if(NOT COMP_IS_EXEC)#the required internal component is a library 
		if(export)
			#set(${PROJECT_NAME}_${component}_TEMP_DEFS ${comp_exp_defs} ${dep_defs} ${${dep_package}_${dep_component}_DEFINITIONS${USE_MODE_SUFFIX}})#OLD
			set(${PROJECT_NAME}_${component}_TEMP_DEFS ${comp_exp_defs} ${dep_defs})
			manage_Additional_Component_Internal_Flags(${component} "" "${comp_defs}")				
			manage_Additional_Component_Exported_Flags(${component} "" "${${PROJECT_NAME}_${component}_TEMP_DEFS}" "${dep_component}${INSTALL_NAME_SUFFIX}")
			
		else()
			set(${PROJECT_NAME}_${component}_TEMP_DEFS ${comp_defs} ${dep_defs})
			manage_Additional_Component_Internal_Flags(${component} "" "${${PROJECT_NAME}_${component}_TEMP_DEFS}")
			manage_Additional_Component_Exported_Flags(${component} "" "${comp_exp_defs}" "${dep_component}${INSTALL_NAME_SUFFIX}")
		endif()
	else()
		message(FATAL_ERROR "Executable component ${dep_c_name} cannot be a dependency for component ${component}")	
	endif()
endif()#do nothing in case of a pure header component
endfunction(fill_Component_Target_With_Internal_Dependency)


### configure the target to link with another component issued from another package
function (fill_Component_Target_With_Package_Dependency component dep_package dep_component export comp_defs comp_exp_defs dep_defs)

is_Built_Component(COMP_IS_BUILT ${PROJECT_NAME} ${component})
is_Executable_Component(DEP_IS_EXEC ${dep_package} ${dep_component})
if(COMP_IS_BUILT) #the component has a corresponding target

	if(NOT DEP_IS_EXEC)#the required package component is a library
		
		if(export)
			set(${PROJECT_NAME}_${component}_TEMP_DEFS ${comp_exp_defs} ${dep_defs} ${${dep_package}_${dep_component}_DEFINITIONS${USE_MODE_SUFFIX}})
			manage_Additional_Component_Internal_Flags(${component} "" "${comp_defs}")
			manage_Additional_Component_Exported_Flags(${component} "${${dep_package}_${dep_component}_INCLUDE_DIRS${USE_MODE_SUFFIX}}" "${${PROJECT_NAME}_${component}_TEMP_DEFS}" "${${dep_package}_${dep_component}_LIBRARIES${USE_MODE_SUFFIX}}")
		else()
			set(${PROJECT_NAME}_${component}_TEMP_DEFS ${comp_defs} ${dep_defs} ${${dep_package}_${dep_component}_DEFINITIONS${USE_MODE_SUFFIX}})	
			manage_Additional_Component_Internal_Flags(${component} "${${dep_package}_${dep_component}_INCLUDE_DIRS${USE_MODE_SUFFIX}}" "${${PROJECT_NAME}_${component}_TEMP_DEFS}")
			manage_Additional_Component_Exported_Flags(${component} "" "${comp_exp_defs}" "${${dep_package}_${dep_component}_LIBRARIES${USE_MODE_SUFFIX}}")
			
		endif()
#HERE TODO revoir l'export des libraries !!
 	else()
		message(FATAL_ERROR "Executable component ${dep_component} from package ${dep_package} cannot be a dependency for component ${component}")	
	endif()
endif()#do nothing in case of a pure header component
endfunction(fill_Component_Target_With_Package_Dependency)


### configure the target to link with an external dependancy
function(fill_Component_Target_With_External_Dependency component export comp_defs comp_exp_defs ext_defs ext_inc_dirs ext_links)

is_Built_Component(COMP_IS_BUILT ${PROJECT_NAME} ${component})
if(COMP_IS_BUILT) #the component has a corresponding target

	# setting compile/linkage definitions for the component target
	if(export)
		set(${PROJECT_NAME}_${component}_TEMP_DEFS ${comp_exp_defs} ${ext_defs})
		manage_Additional_Component_Internal_Flags(${component} "" "${comp_defs}")
		manage_Additional_Component_Exported_Flags(${component} "${ext_inc_dirs}" "${${PROJECT_NAME}_${component}_TEMP_DEFS}" "${ext_links}")

	else()
		set(${PROJECT_NAME}_${component}_TEMP_DEFS ${comp_defs} ${ext_defs})		
		manage_Additional_Component_Internal_Flags(${component} "${ext_inc_dirs}" "${${PROJECT_NAME}_${component}_TEMP_DEFS}")
		manage_Additional_Component_Exported_Flags(${component} "" "${comp_exp_defs}" "${ext_links}")
	endif()

endif()#do nothing in case of a pure header component
endfunction(fill_Component_Target_With_External_Dependency)


### reset components related cached variables 
function(reset_component_cached_variables component)
if(${${PROJECT_NAME}_${component}_DECLARED}) #if component declared unset all its specific variables
	# unsetting package dependencies
	foreach(a_dep_pack IN ITEMS ${${PROJECT_NAME}_${component}_DEPENDENCIES${USE_MODE_SUFFIX}})
		foreach(a_dep_comp IN ITEMS ${${PROJECT_NAME}_${component}_DEPENDENCY_${a_dep_pack}_COMPONENTS${USE_MODE_SUFFIX}})
			set(${PROJECT_NAME}_${component}_EXPORT_${a_dep_pack}_${a_dep_comp}${USE_MODE_SUFFIX} CACHE INTERNAL "")
		endforeach()
		set(${PROJECT_NAME}_${component}_DEPENDENCY_${a_dep_pack}_COMPONENTS${USE_MODE_SUFFIX}  CACHE INTERNAL "")
	endforeach()
	set(${PROJECT_NAME}_${component}_DEPENDENCIES${USE_MODE_SUFFIX}  CACHE INTERNAL "")

	# unsetting internal dependencies
	foreach(a_internal_dep_comp IN ITEMS ${${PROJECT_NAME}_${component}_INTERNAL_DEPENDENCIES${USE_MODE_SUFFIX}})
		set(${PROJECT_NAME}_${component}_INTERNAL_EXPORT_${a_internal_dep_comp}${USE_MODE_SUFFIX} CACHE INTERNAL "")
	endforeach()
	set(${PROJECT_NAME}_${component}_INTERNAL_DEPENDENCIES${USE_MODE_SUFFIX}  CACHE INTERNAL "")

	#unsetting all other variables
	set(${PROJECT_NAME}_${component}_HEADER_DIR_NAME CACHE INTERNAL "")
	set(${PROJECT_NAME}_${component}_HEADERS CACHE INTERNAL "")
	set(${PROJECT_NAME}_${component}_BINARY_NAME${USE_MODE_SUFFIX} CACHE INTERNAL "")
	set(${PROJECT_NAME}_${component}_DEFS${USE_MODE_SUFFIX} CACHE INTERNAL "")
	set(${PROJECT_NAME}_${component}_LINKS${USE_MODE_SUFFIX} CACHE INTERNAL "")
	set(${PROJECT_NAME}_${component}_INC_DIRS${USE_MODE_SUFFIX} CACHE INTERNAL "")
	set(${PROJECT_NAME}_${component}_DECLARED CACHE INTERNAL "")
endif()
endfunction(reset_component_cached_variables)

### resetting all internal cached variables that would cause some troubles
function(reset_cached_variables)

#resetting general info about the package : only list are reset
set(${PROJECT_NAME}_MAIN_AUTHOR CACHE INTERNAL "")
set(${PROJECT_NAME}_MAIN_INSTITUTION CACHE INTERNAL "")
set(${PROJECT_NAME}_AUTHORS_AND_INSTITUTIONS CACHE INTERNAL "")
set(${PROJECT_NAME}_DESCRIPTION CACHE INTERNAL "")
set(${PROJECT_NAME}_YEARS CACHE INTERNAL "")
set(${PROJECT_NAME}_LICENSE CACHE INTERNAL "")
set(${PROJECT_NAME}_ADDRESS CACHE INTERNAL "")
set(${PROJECT_NAME}_CATEGORIES CACHE INTERNAL "")
set (${PROJECT_NAME}_VERSION_MAJOR CACHE INTERNAL "")
set (${PROJECT_NAME}_VERSION_MINOR CACHE INTERNAL "")
set (${PROJECT_NAME}_VERSION_PATCH CACHE INTERNAL "")
set (${PROJECT_NAME}_VERSION CACHE INTERNAL "")


# references to package binaries version available must be reset
foreach(ref_version IN ITEMS ${${PROJECT_NAME}_REFERENCES})
	foreach(ref_system IN ITEMS ${${PROJECT_NAME}_REFERENCES_${ref_version}})
		set(${PROJECT_NAME}_REFERENCE_${ref_version}_${ref_system} CACHE INTERNAL "")
	endforeach()
	set(${PROJECT_NAME}_REFERENCE_${ref_version} CACHE INTERNAL "")
endforeach()
set(${PROJECT_NAME}_REFERENCES CACHE INTERNAL "")

# package dependencies declaration must be reinitialized otherwise some problem (uncoherent dependancy versions) would appear
foreach(dep_package IN ITEMS ${${PROJECT_NAME}_DEPENDENCIES${USE_MODE_SUFFIX}})
	set(${PROJECT_NAME}_DEPENDENCY_${dep_package}_COMPONENTS${USE_MODE_SUFFIX} CACHE INTERNAL "")	
	set(${PROJECT_NAME}_DEPENDENCY_${dep_package}_${${PROJECT_NAME}_DEPENDENCY_${dep_package}_VERSION${USE_MODE_SUFFIX}}_EXACT${USE_MODE_SUFFIX} CACHE INTERNAL "")
	set(${PROJECT_NAME}_DEPENDENCY_${dep_package}_VERSION${USE_MODE_SUFFIX} CACHE INTERNAL "")
endforeach()
set(${PROJECT_NAME}_DEPENDENCIES${USE_MODE_SUFFIX} CACHE INTERNAL "")

# external package dependencies declaration must be reinitialized 
foreach(dep_package IN ITEMS ${${PROJECT_NAME}_EXTERNAL_DEPENDENCIES${USE_MODE_SUFFIX}})
	set(${PROJECT_NAME}_EXTERNAL_DEPENDENCY_${dep_package}_REFERENCE_PATH${USE_MODE_SUFFIX} CACHE INTERNAL "")
endforeach()
set(${PROJECT_NAME}_EXTERNAL_DEPENDENCIES${USE_MODE_SUFFIX} CACHE INTERNAL "")


# component declaration must be reinitialized otherwise some problem (redundancy of declarations) would appear
foreach(a_component IN ITEMS ${${PROJECT_NAME}_COMPONENTS})
	reset_component_cached_variables(${a_component})
endforeach()
set(${PROJECT_NAME}_COMPONENTS CACHE INTERNAL "")
set(${PROJECT_NAME}_COMPONENTS_LIBS CACHE INTERNAL "")
set(${PROJECT_NAME}_COMPONENTS_APPS CACHE INTERNAL "")

#unsetting all root variables usefull to the find/configuration mechanism
foreach(a_used_package IN ITEMS ${${PROJECT_NAME}_ALL_USED_PACKAGES})
	set(${a_used_package}_FOUND CACHE INTERNAL "")
	set(${a_used_package}_ROOT_DIR CACHE INTERNAL "")
	set(${a_used_package}_ALL_REQUIRED_VERSIONS CACHE INTERNAL "")
	set(${a_used_package}_REQUIRED_VERSION_EXACT CACHE INTERNAL "")
endforeach()
set(${PROJECT_NAME}_ALL_USED_PACKAGES CACHE INTERNAL "")
set(${PROJECT_NAME}_TOINSTALL_PACKAGES CACHE INTERNAL "")
endfunction(reset_cached_variables)

function(reset_Mode_Cache_Options)
#unset all global options
set(BUILD_EXAMPLES CACHE BOOL FALSE FORCE)
set(BUILD_API_DOC CACHE BOOL FALSE FORCE)
set(BUILD_API_DOC CACHE BOOL FALSE FORCE)
set(BUILD_AND_RUN_TESTS CACHE BOOL FALSE FORCE)
set(BUILD_WITH_PRINT_MESSAGES CACHE BOOL FALSE FORCE)
set(USE_LOCAL_DEPLOYMENT CACHE BOOL FALSE FORCE)
set(GENERATE_INSTALLER CACHE BOOL FALSE FORCE)
set(WORKSPACE_DIR CACHE PATH "" FORCE)
set(REQUIRED_PACKAGES_AUTOMATIC_DOWNLOAD CACHE BOOL FALSE FORCE)
#include the cmake script that sets the options coming from the global build configuration
include(${CMAKE_BINARY_DIR}/../share/cacheConfig.cmake)
endfunction(reset_Mode_Cache_Options)


##################################################################################
############################## install the dependancies ########################## 
########### functions used to create the use<package><version>.cmake  ############ 
##################################################################################

function(create_Use_File)
if(${CMAKE_BUILD_TYPE} MATCHES Release) #mode independent info written only once in the release mode 
	set(file ${CMAKE_BINARY_DIR}/share/Use${PROJECT_NAME}-${${PROJECT_NAME}_VERSION}.cmake)
else()
	set(file ${CMAKE_BINARY_DIR}/share/UseDebugTemp)
endif()
#resetting the file content
file(WRITE ${file} "")
if(${CMAKE_BUILD_TYPE} MATCHES Release) #mode independent info written only once in the release mode 
	file(APPEND ${file} "######### declaration of package components ########\n")
	file(APPEND ${file} "set(${PROJECT_NAME}_COMPONENTS ${${PROJECT_NAME}_COMPONENTS} CACHE INTERNAL \"\")\n")
	file(APPEND ${file} "set(${PROJECT_NAME}_COMPONENTS_APPS ${${PROJECT_NAME}_COMPONENTS_APPS} CACHE INTERNAL \"\")\n")
	file(APPEND ${file} "set(${PROJECT_NAME}_COMPONENTS_LIBS ${${PROJECT_NAME}_COMPONENTS_LIBS} CACHE INTERNAL \"\")\n")
	
	file(APPEND ${file} "####### internal specs of package components #######\n")
	foreach(a_component IN ITEMS ${${PROJECT_NAME}_COMPONENTS_LIBS})
		file(APPEND ${file} "set(${PROJECT_NAME}_${a_component}_TYPE ${${PROJECT_NAME}_${a_component}_TYPE} CACHE INTERNAL \"\")\n")
		file(APPEND ${file} "set(${PROJECT_NAME}_${a_component}_HEADER_DIR_NAME ${${PROJECT_NAME}_${a_component}_HEADER_DIR_NAME} CACHE INTERNAL \"\")\n")
		file(APPEND ${file} "set(${PROJECT_NAME}_${a_component}_HEADERS ${${PROJECT_NAME}_${a_component}_HEADERS} CACHE INTERNAL \"\")\n")
	endforeach()
	foreach(a_component IN ITEMS ${${PROJECT_NAME}_COMPONENTS_APPS})
		file(APPEND ${file} "set(${PROJECT_NAME}_${a_component}_TYPE ${${PROJECT_NAME}_${a_component}_TYPE} CACHE INTERNAL \"\")\n")
	endforeach()
	
endif()

#mode dependent info written adequately depending the mode 

# 1) external package dependencies
file(APPEND ${file} "#### declaration of external package dependencies in ${CMAKE_BUILD_TYPE} mode ####\n")
file(APPEND ${file} "set(${PROJECT_NAME}_EXTERNAL_DEPENDENCIES${USE_MODE_SUFFIX} ${${PROJECT_NAME}_EXTERNAL_DEPENDENCIES${USE_MODE_SUFFIX}} CACHE INTERNAL \"\")\n")

foreach(a_ext_dep IN ITEMS ${${PROJECT_NAME}_EXTERNAL_DEPENDENCIES${USE_MODE_SUFFIX}})
		file(APPEND ${file} "set(${PROJECT_NAME}_EXTERNAL_DEPENDENCY_${a_ext_dep}_REFERENCE_PATH${USE_MODE_SUFFIX} ${${PROJECT_NAME}_EXTERNAL_DEPENDENCY_${a_ext_dep}_REFERENCE_PATH${USE_MODE_SUFFIX}} CACHE INTERNAL \"\")\n")
endforeach()

# 2) package dependencies
file(APPEND ${file} "#### declaration of package dependencies in ${CMAKE_BUILD_TYPE} mode ####\n")
file(APPEND ${file} "set(${PROJECT_NAME}_DEPENDENCIES${USE_MODE_SUFFIX} ${${PROJECT_NAME}_DEPENDENCIES${USE_MODE_SUFFIX}} CACHE INTERNAL \"\")\n")
foreach(a_dep IN ITEMS ${${PROJECT_NAME}_DEPENDENCIES${USE_MODE_SUFFIX}})
		file(APPEND ${file} "set(${PROJECT_NAME}_DEPENDENCY_${a_dep}_VERSION${USE_MODE_SUFFIX} ${${PROJECT_NAME}_DEPENDENCY_${a_dep}_VERSION${USE_MODE_SUFFIX}} CACHE INTERNAL \"\")\n")
		file(APPEND ${file} "set(${PROJECT_NAME}_DEPENDENCY_${a_dep}_VERSION_EXACT${USE_MODE_SUFFIX} ${${PROJECT_NAME}_DEPENDENCY_${a_dep}_VERSION_EXACT${USE_MODE_SUFFIX}} CACHE INTERNAL \"\")\n")
		file(APPEND ${file} "set(${PROJECT_NAME}_DEPENDENCY_${a_dep}_COMPONENTS${USE_MODE_SUFFIX} ${${PROJECT_NAME}_DEPENDENCY_${a_dep}_COMPONENTS${USE_MODE_SUFFIX}} CACHE INTERNAL \"\")\n")
endforeach()

# 3) internal components specifications
file(APPEND ${file} "#### declaration of components exported flags and binary in ${CMAKE_BUILD_TYPE} mode ####\n")
foreach(a_component IN ITEMS ${${PROJECT_NAME}_COMPONENTS})
	is_Built_Component(IS_BUILT_COMP ${PROJECT_NAME} ${a_component})
	is_Executable_Component(IS_EXEC_COMP ${PROJECT_NAME} ${a_component})
	if(IS_BUILT_COMP)#if not a pure header library
		file(APPEND ${file} "set(${PROJECT_NAME}_${a_component}_BINARY_NAME${USE_MODE_SUFFIX} ${${PROJECT_NAME}_${a_component}_BINARY_NAME${USE_MODE_SUFFIX}} CACHE INTERNAL \"\")\n")
	endif()
	if(NOT IS_EXEC_COMP)#it is a library
		file(APPEND ${file} "set(${PROJECT_NAME}_${a_component}_INC_DIRS${USE_MODE_SUFFIX} ${${PROJECT_NAME}_${a_component}_INC_DIRS${USE_MODE_SUFFIX}} CACHE INTERNAL \"\")\n")
		file(APPEND ${file} "set(${PROJECT_NAME}_${a_component}_DEFS${USE_MODE_SUFFIX} ${${PROJECT_NAME}_${a_component}_DEFS${USE_MODE_SUFFIX}} CACHE INTERNAL \"\")\n")
		file(APPEND ${file} "set(${PROJECT_NAME}_${a_component}_LINKS${USE_MODE_SUFFIX} ${${PROJECT_NAME}_${a_component}_LINKS${USE_MODE_SUFFIX}} CACHE INTERNAL \"\")\n")
	endif()
	file(APPEND ${file} "set(${PROJECT_NAME}_${a_component}_RUNTIME_DEPS${USE_MODE_SUFFIX} ${${PROJECT_NAME}_${a_component}_RUNTIME_DEPS${USE_MODE_SUFFIX}} CACHE INTERNAL \"\")\n")
endforeach()

# 4) package internal component dependencies
file(APPEND ${file} "#### declaration package internal component dependencies in ${CMAKE_BUILD_TYPE} mode ####\n")
foreach(a_component IN ITEMS ${${PROJECT_NAME}_COMPONENTS})
	if(${PROJECT_NAME}_${a_component}_INTERNAL_DEPENDENCIES${USE_MODE_SUFFIX}) # the component has internal dependencies
		file(APPEND ${file} "set(${PROJECT_NAME}_${a_component}_INTERNAL_DEPENDENCIES${USE_MODE_SUFFIX} ${${PROJECT_NAME}_${a_component}_INTERNAL_DEPENDENCIES${USE_MODE_SUFFIX}} CACHE INTERNAL \"\")\n")
		foreach(a_int_dep IN ITEMS ${${PROJECT_NAME}_${a_component}_INTERNAL_DEPENDENCIES${USE_MODE_SUFFIX}})
			file(APPEND ${file} "set(${PROJECT_NAME}_${a_component}_INTERNAL_EXPORT_${a_int_dep}${USE_MODE_SUFFIX} ${${PROJECT_NAME}_${a_component}_INTERNAL_EXPORT_${a_int_dep}${USE_MODE_SUFFIX}} CACHE INTERNAL \"\")\n")
		endforeach()
	endif()
endforeach()

# 5) component dependencies 
file(APPEND ${file} "#### declaration of component dependencies in ${CMAKE_BUILD_TYPE} mode ####\n")
foreach(a_component IN ITEMS ${${PROJECT_NAME}_COMPONENTS})
	if(${PROJECT_NAME}_${a_component}_DEPENDENCIES${USE_MODE_SUFFIX}) # the component has package dependencies
		file(APPEND ${file} "set(${PROJECT_NAME}_${a_component}_DEPENDENCIES${USE_MODE_SUFFIX} ${${PROJECT_NAME}_${a_component}_DEPENDENCIES${USE_MODE_SUFFIX}} CACHE INTERNAL \"\")\n")
		foreach(dep_package IN ITEMS ${${PROJECT_NAME}_${a_component}_DEPENDENCIES${USE_MODE_SUFFIX}})
			file(APPEND ${file} "set(${PROJECT_NAME}_${a_component}_DEPENDENCY_${dep_package}_COMPONENTS${USE_MODE_SUFFIX} ${${PROJECT_NAME}_${a_component}_DEPENDENCY_${dep_package}_COMPONENTS${USE_MODE_SUFFIX}} CACHE INTERNAL \"\")\n")
			foreach(dep_component IN ITEMS ${${PROJECT_NAME}_${a_component}_DEPENDENCY_${dep_package}_COMPONENTS${USE_MODE_SUFFIX}})
				file(APPEND ${file} "set(${PROJECT_NAME}_${a_component}_EXPORT_${dep_package}_${dep_component}${USE_MODE_SUFFIX} ${${PROJECT_NAME}_${a_component}_EXPORT_${dep_package}_${dep_component}${USE_MODE_SUFFIX}} CACHE INTERNAL \"\")\n")			
			endforeach()
		endforeach()
	endif()
endforeach()

#finalizing release mode by agregating info from the debug mode
if(${CMAKE_BUILD_TYPE} MATCHES Release) #mode independent info written only once in the release mode 
	file(READ "${CMAKE_BINARY_DIR}/../debug/share/UseDebugTemp" DEBUG_CONTENT)
	file(APPEND ${file} ${DEBUG_CONTENT})
endif()
endfunction(create_Use_File)

