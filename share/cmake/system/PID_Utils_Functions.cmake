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

#############################################################
########### general utilities for build management ##########
#############################################################

### getting suffixes related to target mode (common accessor usefull in many places)
function(get_Mode_Variables TARGET_SUFFIX VAR_SUFFIX mode)
if(mode MATCHES Release)
	set(${TARGET_SUFFIX} PARENT_SCOPE)
	set(${VAR_SUFFIX} PARENT_SCOPE)
else()
	set(${TARGET_SUFFIX} -dbg PARENT_SCOPE)
	set(${VAR_SUFFIX} _DEBUG PARENT_SCOPE)
endif()
endfunction(get_Mode_Variables)

### getting basic system variables related to current platform (common accessor usefull in many places)
function(get_System_Variables PLATFORM_NAME PACKAGE_STRING)
set(${PLATFORM_NAME} ${CURRENT_PLATFORM} PARENT_SCOPE)
set(${PACKAGE_STRING} ${CURRENT_PACKAGE_STRING} PARENT_SCOPE)
endfunction(get_System_Variables)

###
function(is_A_System_Reference_Path path IS_SYSTEM)

if(UNIX)
	if(path STREQUAL / OR path STREQUAL /usr OR path STREQUAL /usr/local)
		set(${IS_SYSTEM} TRUE PARENT_SCOPE)
	else()
		set(${IS_SYSTEM} FALSE PARENT_SCOPE)
	endif()
endif()

if(APPLE AND NOT ${IS_SYSTEM})
	if(path STREQUAL /Library/Frameworks OR path STREQUAL /Network/Library/Frameworks OR path STREQUAL /System/Library/Framework)
		set(${IS_SYSTEM} TRUE PARENT_SCOPE)
	endif()
endif()

endfunction(is_A_System_Reference_Path)


###
function(extract_Info_From_Platform RES_ARCH RES_BITS RES_OS RES_ABI name)
	string(REGEX REPLACE "^([^_]+)_([^_]+)_([^_]+)_([^_]+)$" "\\1;\\2;\\3;\\4" list_of_properties ${name})
	list(GET list_of_properties 0 arch)
	list(GET list_of_properties 1 bits)
	list(GET list_of_properties 2 os)
	list(GET list_of_properties 3 abi)
	set(${RES_ARCH} ${arch} PARENT_SCOPE)
	set(${RES_BITS} ${bits} PARENT_SCOPE)
	set(${RES_OS} ${os} PARENT_SCOPE)
	set(${RES_ABI} ${abi} PARENT_SCOPE)
endfunction(extract_Info_From_Platform)

#############################################################
################ string handling utilities ##################
#############################################################

###
function(extract_All_Words the_string separator all_words_in_list)
set(res "")
string(REPLACE "${separator}" ";" res "${the_string}")
set(${all_words_in_list} ${res} PARENT_SCOPE)
endfunction(extract_All_Words)


###
function(extract_All_Words_From_Path name_with_slash all_words_in_list)
set(res "")
string(REPLACE "/" ";" res "${name_with_slash}")
set(${all_words_in_list} ${res} PARENT_SCOPE)
endfunction(extract_All_Words_From_Path)


###
function(fill_List_Into_String input_list res_string)
set(res "")
foreach(element IN ITEMS ${input_list})
	set(res "${res} ${element}")
endforeach()
string(STRIP "${res}" res_finished)
set(${res_string} ${res_finished} PARENT_SCOPE)
endfunction(fill_List_Into_String)

###
function(extract_Package_Namespace_From_SSH_URL url package NAMESPACE SERVER_ADDRESS EXTENSION)
string (REGEX REPLACE "^([^@]+@[^:]+):([^/]+)/${package}(\\.site|-site|\\.pages|-pages)?\\.git$" "\\2;\\1" RESULT ${url})
if(NOT RESULT STREQUAL "${url}") #match found
	list(GET RESULT 0 NAMESPACE_NAME)
	set(${NAMESPACE} ${NAMESPACE_NAME} PARENT_SCOPE)
	list(GET RESULT 1 ACCOUNT_ADDRESS)
	set(${SERVER_ADDRESS} ${ACCOUNT_ADDRESS} PARENT_SCOPE)

	string (REGEX REPLACE "^[^@]+@[^:]+:[^/]+/${package}(\\.site|-site|\\.pages|-pages)\\.git$" "\\1" RESULT ${url})
	if(NOT RESULT STREQUAL "${url}") #match found
		set(${EXTENSION} ${RESULT} PARENT_SCOPE)
	else()
		set(${EXTENSION} PARENT_SCOPE)
	endif()

else()
	set(${NAMESPACE} PARENT_SCOPE)
	set(${SERVER_ADDRESS} PARENT_SCOPE)
	set(${EXTENSION} PARENT_SCOPE)
endif()
endfunction(extract_Package_Namespace_From_SSH_URL)


###
function(format_PID_Identifier_Into_Markdown_Link RES_LINK function_name)
string(REPLACE "_" "" RES_STR ${function_name})#simply remove underscores
string(REPLACE " " "-" FINAL_STR ${RES_STR})#simply remove underscores
set(${RES_LINK} ${FINAL_STR} PARENT_SCOPE)
endfunction(format_PID_Identifier_Into_Markdown_Link)


###
function(normalize_Version_String INPUT_VERSION_STRING NORMALIZED_OUTPUT_VERSION_STRING)
	get_Version_String_Numbers(${INPUT_VERSION_STRING} major minor patch)
	set(VERSION_STR "${major}.")
	if(minor)
		set(VERSION_STR "${VERSION_STR}${minor}.")
	else()
		set(VERSION_STR "${VERSION_STR}0.")
	endif()
	if(patch)
		set(VERSION_STR "${VERSION_STR}${patch}")
	else()
		set(VERSION_STR "${VERSION_STR}0")
	endif()
	set(${NORMALIZED_OUTPUT_VERSION_STRING} ${VERSION_STR} PARENT_SCOPE)
endfunction(normalize_Version_String)


#############################################################
################ filesystem management utilities ############
#############################################################

###
function(create_Symlink path_to_old path_to_new)
if(	EXISTS ${path_to_new} AND IS_SYMLINK ${path_to_new})
	execute_process(#removing the existing symlink
		COMMAND ${CMAKE_COMMAND} -E remove -f ${path_to_new}
	)
endif()
execute_process(
	COMMAND ${CMAKE_COMMAND} -E create_symlink ${path_to_old} ${path_to_new}
)
endfunction(create_Symlink)

###
function(create_Runtime_Symlink path_to_target path_to_container_folder rpath_sub_folder)
#first creating the path where to put symlinks if it does not exist
set(RUNTIME_DIR ${path_to_container_folder}/${rpath_sub_folder})
file(MAKE_DIRECTORY ${RUNTIME_DIR})
get_filename_component(A_FILE ${path_to_target} NAME)
#second creating the symlink
create_Symlink(${path_to_target} ${RUNTIME_DIR}/${A_FILE})
endfunction(create_Runtime_Symlink)

###
function(install_Runtime_Symlink path_to_target path_to_rpath_folder rpath_sub_folder)
	get_filename_component(A_FILE "${path_to_target}" NAME)
	set(FULL_RPATH_DIR ${path_to_rpath_folder}/${rpath_sub_folder})
	install(DIRECTORY DESTINATION ${FULL_RPATH_DIR}) #create the folder that will contain symbolic links to runtime resources used by the component (will allow full relocation of components runtime dependencies at install time)
	install(CODE "
	              if(EXISTS ${FULL_RPATH_DIR}/${A_FILE} AND IS_SYMLINK ${FULL_RPATH_DIR}/${A_FILE})
									execute_process(COMMAND ${CMAKE_COMMAND} -E remove -f ${FULL_RPATH_DIR}/${A_FILE}
									                 WORKING_DIRECTORY ${CMAKE_INSTALL_PREFIX})
		            endif()
		            execute_process(COMMAND ${CMAKE_COMMAND} -E create_symlink ${path_to_target} ${FULL_RPATH_DIR}/${A_FILE}
	                              WORKING_DIRECTORY ${CMAKE_INSTALL_PREFIX})
		            message(\"-- Installing: ${FULL_RPATH_DIR}/${A_FILE}\")
	")# creating links "on the fly" when installing

endfunction(install_Runtime_Symlink)


###
function (check_Directory_Exists is_existing path)
if(	EXISTS "${path}"
	AND IS_DIRECTORY "${path}"
  )
	set(${is_existing} TRUE PARENT_SCOPE)
	return()
endif()
set(${is_existing} FALSE PARENT_SCOPE)
endfunction(check_Directory_Exists)


###
function (check_Required_Directories_Exist PROBLEM type folder)
	#checking directory containing headers
	set(${PROBLEM} PARENT_SCOPE)
	if(type STREQUAL "STATIC" OR type STREQUAL "SHARED" OR type STREQUAL "HEADER")
		check_Directory_Exists(EXIST  ${CMAKE_SOURCE_DIR}/include/${folder})
		if(NOT EXIST)
			set(${PROBLEM} "No folder named ${folder} in the include folder of the project" PARENT_SCOPE)
			return()
		endif()
	endif()
	if(type STREQUAL "STATIC" OR type STREQUAL "SHARED" OR type STREQUAL "MODULE"
		OR type STREQUAL "APP" OR type STREQUAL "EXAMPLE" OR type STREQUAL "TEST")
		check_Directory_Exists(EXIST  ${CMAKE_CURRENT_SOURCE_DIR}/${folder})
		if(NOT EXIST)
			set(${PROBLEM} "No folder named ${folder} in folder ${CMAKE_CURRENT_SOURCE_DIR}" PARENT_SCOPE)
			return()
		endif()
	elseif(type STREQUAL "PYTHON")
		check_Directory_Exists(EXIST ${CMAKE_CURRENT_SOURCE_DIR}/script/${folder})
		if(NOT EXIST)
			set(${PROBLEM} "No folder named ${folder} in folder ${CMAKE_CURRENT_SOURCE_DIR}/script" PARENT_SCOPE)
			return()
		endif()
	endif()
endfunction(check_Required_Directories_Exist)


#############################################################
################ Management of version information ##########
#############################################################

###
function (document_Version_Strings package_name major minor patch)
	set(${package_name}_VERSION_MAJOR ${major} CACHE INTERNAL "")
	set(${package_name}_VERSION_MINOR ${minor} CACHE INTERNAL "")
	set(${package_name}_VERSION_PATCH ${patch} CACHE INTERNAL "")
	set(${package_name}_VERSION_STRING "${major}.${minor}.${patch}" CACHE INTERNAL "")
	set(${package_name}_VERSION_RELATIVE_PATH "${major}.${minor}.${patch}" CACHE INTERNAL "")
endfunction(document_Version_Strings)


###
function (document_External_Version_Strings package version)
	set(${package}_VERSION_STRING "${version}" CACHE INTERNAL "")
	set(${package}_VERSION_RELATIVE_PATH "${version}" CACHE INTERNAL "")
endfunction(document_External_Version_Strings)


###
function(get_Version_String_Numbers version_string major minor patch)
string(REGEX REPLACE "^([0-9]+)\\.([0-9]+)\\.([0-9]+)$" "\\1;\\2;\\3" A_VERSION "${version_string}")
if(A_VERSION STREQUAL "${version_string}") #no match try with more than 3 elements
string(REGEX REPLACE "^([0-9]+)\\.([0-9]+)\\.([0-9]+)\\.?(.*)$" "\\1;\\2;\\3;\\4" A_VERSION "${version_string}")
endif()
if(NOT A_VERSION STREQUAL "${version_string}") # version string is well formed with major.minor.patch (at least) format
	list(GET A_VERSION 0 major_vers)
	list(GET A_VERSION 1 minor_vers)
	list(GET A_VERSION 2 patch_vers)
	set(${major} ${major_vers} PARENT_SCOPE)
	set(${minor} ${minor_vers} PARENT_SCOPE)
	set(${patch} ${patch_vers} PARENT_SCOPE)
else()#testing with only two elements
	string(REGEX REPLACE "^([0-9]+)\\.([0-9]+)$" "\\1;\\2" A_VERSION "${version_string}")
	if(NOT A_VERSION STREQUAL "${version_string}") # version string is well formed with major.minor format
		list(GET A_VERSION 0 major_vers)
		list(GET A_VERSION 1 minor_vers)
		set(${major} ${major_vers} PARENT_SCOPE)
		set(${minor} ${minor_vers} PARENT_SCOPE)
		set(${patch} PARENT_SCOPE)
	else() #only a major number ??
		string(REGEX REPLACE "^([0-9]+)$" "\\1" A_VERSION "${version_string}")
		if(NOT A_VERSION STREQUAL "${version_string}") # version string is well formed with major.minor format
			list(GET A_VERSION 0 major_vers)
			set(${major} ${major_vers} PARENT_SCOPE)
			set(${minor} PARENT_SCOPE)
			set(${patch} PARENT_SCOPE)
		else() #not even a number
			message(FATAL_ERROR "[PID] CRITICAL ERROR : corrupted version string ${version_string}.")
		endif()
	endif()
endif()
endfunction(get_Version_String_Numbers)

###
function(list_Version_Subdirectories result curdir)
	file(GLOB children RELATIVE ${curdir} ${curdir}/*)
	set(dirlist "")
	foreach(child ${children})
		if(IS_DIRECTORY ${curdir}/${child} AND "${child}" MATCHES "^[0-9]+\\.[0-9]+\\.[0-9]+$")
			list(APPEND dirlist ${child})
		endif()
	endforeach()
	set(${result} ${dirlist} PARENT_SCOPE)
endfunction(list_Version_Subdirectories)

###
function(list_Platform_Symlinks result curdir)
	file(GLOB children RELATIVE ${curdir} ${curdir}/*)
	set(dirlist "")
	foreach(child ${children})
		if(IS_SYMLINK ${curdir}/${child} AND "${child}" MATCHES "^[^_]+_[^_]+_[^_]+_[^_]+$")
			list(APPEND dirlist ${child})
		endif()
	endforeach()
	set(${result} ${dirlist} PARENT_SCOPE)
endfunction(list_Platform_Symlinks)


###
function(list_Platform_Subdirectories result curdir)
	file(GLOB children RELATIVE ${curdir} ${curdir}/*)
	set(dirlist "")
	foreach(child ${children})
		if(IS_DIRECTORY ${curdir}/${child}
			AND NOT IS_SYMLINK ${curdir}/${child}
			AND "${child}" MATCHES "^[^_]+_[^_]+_[^_]+_[^_]+$")
			list(APPEND dirlist ${child})
		endif()
	endforeach()
	set(${result} ${dirlist} PARENT_SCOPE)
endfunction(list_Platform_Subdirectories)

###
function(list_Subdirectories result curdir)
	file(GLOB children RELATIVE ${curdir} ${curdir}/*)
	set(dirlist "")
	foreach(child ${children})
		if(IS_DIRECTORY ${curdir}/${child})
			list(APPEND dirlist ${child})
		endif()
	endforeach()
	set(${result} ${dirlist} PARENT_SCOPE)
endfunction(list_Subdirectories)


###
function(list_Regular_Files result curdir)
	file(GLOB children RELATIVE ${curdir} ${curdir}/*)
	set(filelist "")
	foreach(child ${children})
		if(NOT IS_DIRECTORY ${curdir}/${child} AND NOT IS_SYMLINK ${curdir}/${child})
			list(APPEND filelist ${child})
		endif()
	endforeach()
	set(${result} ${filelist} PARENT_SCOPE)
endfunction(list_Regular_Files)


###
function(is_Compatible_Version is_compatible reference_major reference_minor version_to_compare)
set(${is_compatible} FALSE PARENT_SCOPE)
get_Version_String_Numbers("${version_to_compare}.0" compare_major compare_minor compared_patch)
if(	NOT ${compare_major} EQUAL ${reference_major}
	OR ${compare_minor} GREATER ${reference_minor})
	return()#not compatible
endif()
set(${is_compatible} TRUE PARENT_SCOPE)
endfunction(is_Compatible_Version)

###
function(is_Exact_Compatible_Version is_compatible reference_major reference_minor version_to_compare)
set(${is_compatible} FALSE PARENT_SCOPE)
get_Version_String_Numbers("${version_to_compare}.0" compare_major compare_minor compared_patch)
if(	NOT ${compare_major} EQUAL ${reference_major}
		OR NOT ${compare_minor} EQUAL ${reference_minor})
	return()#not compatible
endif()
set(${is_compatible} TRUE PARENT_SCOPE)
endfunction(is_Exact_Compatible_Version)

#############################################################
################ Information about authors ##################
#############################################################

###
function(generate_Full_Author_String author RES_STRING)
string(REGEX REPLACE "^([^\\(]+)\\(([^\\)]+)\\)$" "\\1;\\2" author_institution "${author}")
if(author_institution STREQUAL "${author}")
	string(REGEX REPLACE "^([^\\(]+)\\(([^\\)]*)\\)$" "\\1;\\2" author_institution "${author}")
	list(GET author_institution 0 AUTHOR_NAME)
	set(INSTITUTION_NAME)
else()
	list(GET author_institution 0 AUTHOR_NAME)
	list(GET author_institution 1 INSTITUTION_NAME)
endif()
extract_All_Words("${AUTHOR_NAME}" "_" AUTHOR_ALL_WORDS)
extract_All_Words("${INSTITUTION_NAME}" "_" INSTITUTION_ALL_WORDS)
fill_List_Into_String("${AUTHOR_ALL_WORDS}" AUTHOR_STRING)
fill_List_Into_String("${INSTITUTION_ALL_WORDS}" INSTITUTION_STRING)
if(NOT INSTITUTION_STRING STREQUAL "")
	set(${RES_STRING} "${AUTHOR_STRING} (${INSTITUTION_STRING})" PARENT_SCOPE)
else()
	set(${RES_STRING} "${AUTHOR_STRING}" PARENT_SCOPE)
endif()
endfunction()

###
function(generate_Contact_String author mail RES_STRING)
extract_All_Words("${author}" "_" AUTHOR_ALL_WORDS)
fill_List_Into_String("${AUTHOR_ALL_WORDS}" AUTHOR_STRING)
if(mail AND NOT mail STREQUAL "")
	set(${RES_STRING} "${AUTHOR_STRING} (${mail})" PARENT_SCOPE)
else()
	set(${RES_STRING} "${AUTHOR_STRING}" PARENT_SCOPE)
endif()
endfunction()

###
function(generate_Formatted_String input RES_STRING)
extract_All_Words("${input}" "_" INPUT_ALL_WORDS)
fill_List_Into_String("${INPUT_ALL_WORDS}" INPUT_STRING)
set(${RES_STRING} "${INPUT_STRING}" PARENT_SCOPE)
endfunction(generate_Formatted_String)

###
function(get_Formatted_Author_String author RES_STRING)
string(REGEX REPLACE "^([^\\(]+)\\(([^\\)]*)\\)$" "\\1;\\2" author_institution "${author}")
list(LENGTH author_institution SIZE)
if(${SIZE} EQUAL 2)
list(GET author_institution 0 AUTHOR_NAME)
list(GET author_institution 1 INSTITUTION_NAME)
extract_All_Words("${AUTHOR_NAME}" "_" AUTHOR_ALL_WORDS)
extract_All_Words("${INSTITUTION_NAME}" "_" INSTITUTION_ALL_WORDS)
fill_List_Into_String("${AUTHOR_ALL_WORDS}" AUTHOR_STRING)
fill_List_Into_String("${INSTITUTION_ALL_WORDS}" INSTITUTION_STRING)
elseif(${SIZE} EQUAL 1)
list(GET author_institution 0 AUTHOR_NAME)
extract_All_Words("${AUTHOR_NAME}" "_" AUTHOR_ALL_WORDS)
fill_List_Into_String("${AUTHOR_ALL_WORDS}" AUTHOR_STRING)
set(INSTITUTION_STRING "")
endif()
if(NOT INSTITUTION_STRING STREQUAL "")
	set(${RES_STRING} "${AUTHOR_STRING} - ${INSTITUTION_STRING}" PARENT_SCOPE)
else()
	set(${RES_STRING} "${AUTHOR_STRING}" PARENT_SCOPE)
endif()
endfunction(get_Formatted_Author_String)

###
function(get_Formatted_Package_Contact_String package RES_STRING)
extract_All_Words("${${package}_MAIN_AUTHOR}" "_" AUTHOR_ALL_WORDS)
extract_All_Words("${${package}_MAIN_INSTITUTION}" "_" INSTITUTION_ALL_WORDS)
fill_List_Into_String("${AUTHOR_ALL_WORDS}" AUTHOR_STRING)
fill_List_Into_String("${INSTITUTION_ALL_WORDS}" INSTITUTION_STRING)
if(NOT INSTITUTION_STRING STREQUAL "")
	if(${package}_CONTACT_MAIL)
		set(${RES_STRING} "${AUTHOR_STRING} (${${package}_CONTACT_MAIL}) - ${INSTITUTION_STRING}" PARENT_SCOPE)
	else()
		set(${RES_STRING} "${AUTHOR_STRING} - ${INSTITUTION_STRING}" PARENT_SCOPE)
	endif()
else()
	if(${package}_CONTACT_MAIL)
		set(${RES_STRING} "${AUTHOR_STRING} (${${package}_CONTACT_MAIL})" PARENT_SCOPE)
	else()
		set(${RES_STRING} "${AUTHOR_STRING}" PARENT_SCOPE)
	endif()
endif()
endfunction(get_Formatted_Package_Contact_String)

###
function(get_Formatted_Framework_Contact_String framework RES_STRING)
extract_All_Words("${${framework}_FRAMEWORK_MAIN_AUTHOR}" "_" AUTHOR_ALL_WORDS)
extract_All_Words("${${framework}_FRAMEWORK_MAIN_INSTITUTION}" "_" INSTITUTION_ALL_WORDS)
fill_List_Into_String("${AUTHOR_ALL_WORDS}" AUTHOR_STRING)
fill_List_Into_String("${INSTITUTION_ALL_WORDS}" INSTITUTION_STRING)
if(NOT INSTITUTION_STRING STREQUAL "")
	if(${framework}_FRAMEWORK_CONTACT_MAIL)
		set(${RES_STRING} "${AUTHOR_STRING} (${${framework}_FRAMEWORK_CONTACT_MAIL}) - ${INSTITUTION_STRING}" PARENT_SCOPE)
	else()
		set(${RES_STRING} "${AUTHOR_STRING} - ${INSTITUTION_STRING}" PARENT_SCOPE)
	endif()
else()
	if(${package}_FRAMEWORK_CONTACT_MAIL)
		set(${RES_STRING} "${AUTHOR_STRING} (${${framework}_FRAMEWORK_CONTACT_MAIL})" PARENT_SCOPE)
	else()
		set(${RES_STRING} "${AUTHOR_STRING}" PARENT_SCOPE)
	endif()
endif()
endfunction(get_Formatted_Framework_Contact_String)


### checking that the license applying to the package is closed source or not (set the variable CLOSED to TRUE or FALSE adequately)
function(package_License_Is_Closed_Source CLOSED package)
	#first step determining if the dependent package provides its license in its use file (compatiblity with previous version of PID)
	if(NOT ${package}_LICENSE)
		if(EXISTS ${WORKSPACE_DIR}/share/cmake/references/Refer${package}.cmake)
			include(${WORKSPACE_DIR}/share/cmake/references/Refer${package}.cmake) #the reference file contains the license
		else()#we consider the package as having an opensource license
			set(${CLOSED} FALSE PARENT_SCOPE)
			return()
		endif()
	endif()
	set(found_license_description FALSE)
	if(KNOWN_LICENSES)
		list(FIND KNOWN_LICENSES ${${package}_LICENSE} INDEX)
		if(NOT INDEX EQUAL -1)
			set(found_license_description TRUE)
		endif()#otherwise license has never been loaded so do not know if open or closed source
	endif()#otherwise license is unknown for now
	if(NOT found_license_description)
		#trying to find that license
		include(${WORKSPACE_DIR}/share/cmake/licenses/License${${package}_LICENSE}.cmake RESULT_VARIABLE res)
		if(res MATCHES NOTFOUND)
			set(${CLOSED} TRUE PARENT_SCOPE)
			message("[PID] ERROR : cannot find description file for license ${${package}_LICENSE}, specified for package ${package}. Package is supposed to be closed source.")
			return()
		endif()
		set(temp_list ${KNOWN_LICENSES} ${${package}_LICENSE} CACHE INTERNAL "")
		list(REMOVE_DUPLICATES temp_list)
		set(KNOWN_LICENSES ${temp_list} CACHE INTERNAL "")#adding the license to known licenses

		if(LICENSE_IS_OPEN_SOURCE)
			set(KNOWN_LICENSE_${${package}_LICENSE}_CLOSED FALSE CACHE INTERNAL "")
		else()
			set(KNOWN_LICENSE_${${package}_LICENSE}_CLOSED TRUE CACHE INTERNAL "")
		endif()
	endif()
	# here the license is already known, simply checking for the registered values
	# this memorization is to optimize configuration time as License file may be long to load
	set(${CLOSED} ${KNOWN_LICENSE_${${package}_LICENSE}_CLOSED} PARENT_SCOPE)
endfunction(package_License_Is_Closed_Source)

#############################################################
################ Source file management #####################
#############################################################

### used to activate adequate languages depending on source file used in the project
macro(activate_Adequate_Languages)
get_All_Sources_Absolute(list_of_files ${CMAKE_SOURCE_DIR})#list all source files
get_property(USED_LANGUAGES GLOBAL PROPERTY ENABLED_LANGUAGES) #getting all languages already in use

foreach(source_file IN ITEMS ${list_of_files})
		get_filename_component(EXTENSION ${source_file} EXT)
		if(EXTENSION STREQUAL ".f")#we have a fortran file
				list(FIND USED_LANGUAGES Fortran INDEX)
				if(INDEX EQUAL -1)#fortran is not in use already
					enable_language(Fortran)#use fortran
					list(APPEND USED_LANGUAGES Fortran)
				endif()
		elseif(EXTENSION STREQUAL ".asm" OR EXTENSION STREQUAL ".s" OR EXTENSION STREQUAL ".S" )#we have an assembler file
				list(FIND USED_LANGUAGES ASM INDEX)
				if(INDEX EQUAL -1)#assembler is not in use already
					enable_language(ASM)#use assembler
					list(APPEND USED_LANGUAGES ASM)
				endif()
		endif()
endforeach()
endmacro(activate_Adequate_Languages)

###
function(get_All_Sources_Relative RESULT dir)
file(	GLOB_RECURSE
	RES
	RELATIVE ${dir}
	"${dir}/*.c"
	"${dir}/*.cc"
	"${dir}/*.cpp"
	"${dir}/*.cxx"
	"${dir}/*.h"
	"${dir}/*.hpp"
	"${dir}/*.hh"
	"${dir}/*.hxx"
	"${dir}/*.s"
	"${dir}/*.S"
	"${dir}/*.asm"
	"${dir}/*.f"
	"${dir}/*.py"
)
set (${RESULT} ${RES} PARENT_SCOPE)
endfunction(get_All_Sources_Relative)

### absolute sources do not take into account python files as they will not be part of a build process
function(get_All_Sources_Absolute RESULT dir)
file(	GLOB_RECURSE
	RES
	${dir}
	"${dir}/*.c"
	"${dir}/*.cc"
	"${dir}/*.cpp"
	"${dir}/*.cxx"
	"${dir}/*.h"
	"${dir}/*.hpp"
	"${dir}/*.hh"
	"${dir}/*.hxx"
	"${dir}/*.s"
	"${dir}/*.S"
	"${dir}/*.asm"
	"${dir}/*.f"
)
set (${RESULT} ${RES} PARENT_SCOPE)
endfunction(get_All_Sources_Absolute)

### to know wether the folder contains some python script
function(contains_Python_Code HAS_PYTHON dir)
file(GLOB_RECURSE HAS_PYTHON_CODE ${dir} "${dir}/*.py")
set(${HAS_PYTHON} ${HAS_PYTHON_CODE} PARENT_SCOPE)
endfunction(contains_Python_Code)

### to know wether the folder is a python package
function(contains_Python_Package_Description IS_PYTHON_PACK dir)
	file(GLOB PY_PACK_FILE RELATIVE ${dir} "${dir}/__init__.py")
	set(${IS_PYTHON_PACK} ${PY_PACK_FILE} PARENT_SCOPE)
endfunction(contains_Python_Package_Description)


###
function(get_All_Headers_Relative RESULT dir)
file(	GLOB_RECURSE
	RES
	RELATIVE ${dir}
	"${dir}/*.h"
	"${dir}/*.hpp"
	"${dir}/*.hh"
	"${dir}/*.hxx"
)
set (${RESULT} ${RES} PARENT_SCOPE)
endfunction(get_All_Headers_Relative)

###
function(get_All_Headers_Absolute RESULT dir)
file(	GLOB_RECURSE
	RES
	${dir}
	"${dir}/*.h"
	"${dir}/*.hpp"
	"${dir}/*.hh"
	"${dir}/*.hxx"
)
set (${RESULT} ${RES} PARENT_SCOPE)
endfunction(get_All_Headers_Absolute)

###
function(is_Shared_Lib_With_Path SHARED input_link)
set(${SHARED} FALSE PARENT_SCOPE)
get_filename_component(LIB_TYPE ${input_link} EXT)
if(LIB_TYPE)
        if(APPLE)
                if(LIB_TYPE MATCHES "^(\\.[0-9]+)*\\.dylib$")#found shared lib
			set(${SHARED} TRUE PARENT_SCOPE)
		endif()
	elseif(UNIX)
                if(LIB_TYPE MATCHES "^\\.so(\\.[0-9]+)*$")#found shared lib
			set(${SHARED} TRUE PARENT_SCOPE)
		endif()
	endif()
else()
	# no extenion may be possible with MACOSX frameworks
        if(APPLE)
		set(${SHARED} TRUE PARENT_SCOPE)
	endif()
endif()
endfunction(is_Shared_Lib_With_Path)

###
function(get_Link_Type RES_TYPE input_link)
get_filename_component(LIB_TYPE ${input_link} EXT)
if(LIB_TYPE)
        if(LIB_TYPE MATCHES "^(\\.[0-9]+)*\\.dylib$")#found shared lib
		set(${RES_TYPE} SHARED PARENT_SCOPE)
	elseif(LIB_TYPE MATCHES "^\\.so(\\.[0-9]+)*$")#found shared lib (MACOSX)
		set(${RES_TYPE} SHARED PARENT_SCOPE)
	elseif(LIB_TYPE MATCHES "^\\.a$")#found static lib (C)
		set(${RES_TYPE} STATIC PARENT_SCOPE)
	elseif(LIB_TYPE MATCHES "^\\.la$")#found static lib (pkg-config)
		set(${RES_TYPE} STATIC PARENT_SCOPE)
	else()#unknown extension => linker option
		set(${RES_TYPE} OPTION PARENT_SCOPE)
	endif()
else()
	# no extension => a possibly strange linker option
	set(${RES_TYPE} OPTION PARENT_SCOPE)
endif()
endfunction(get_Link_Type)

### function used to retrieve the adequate version to an external package
function(is_External_Package_Defined ref_package ext_package mode RES_PATH_TO_PACKAGE)
get_System_Variables(CURRENT_PLATFORM_NAME CURRENT_PACKAGE_STRING)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
set(${RES_PATH_TO_PACKAGE} NOTFOUND PARENT_SCOPE)
if(${ext_package}_FOUND)
	set(${RES_PATH_TO_PACKAGE} ${WORKSPACE_DIR}/external/${CURRENT_PLATFORM_NAME}/${ext_package}/${${ext_package}_VERSION_STRING} PARENT_SCOPE)
else()
	set(${RES_PATH_TO_PACKAGE} PARENT_SCOPE)
endif()
endfunction(is_External_Package_Defined)


###
function(resolve_External_Libs_Path COMPLETE_LINKS_PATH package ext_links mode)
set(res_links)
foreach(link IN ITEMS ${ext_links})
	string(REGEX REPLACE "^<([^>]+)>(.*)" "\\1;\\2" RES ${link})
	if(NOT RES STREQUAL ${link})# a replacement has taken place => this is a full path to a library
		set(fullpath)
		list(GET RES 0 ext_package_name)
		list(GET RES 1 relative_path)
		is_External_Package_Defined(${package} ${ext_package_name} ${mode} PATHTO)
		if(PATHTO STREQUAL NOTFOUND)
			message(FATAL_ERROR "[PID] CRITICAL ERROR : undefined external package ${ext_package_name} used for link ${link}!! Please set the path to this external package.")
		else()
			set(fullpath ${PATHTO}${relative_path})
			list(APPEND res_links ${fullpath})
		endif()
	else() # this may be a link with a prefix (like -L<path>) that need replacement
		string(REGEX REPLACE "^([^<]+)<([^>]+)>(.*)" "\\1;\\2;\\3" RES_WITH_PREFIX ${link})
		if(NOT RES_WITH_PREFIX STREQUAL ${link})# a replacement has taken place
			list(GET RES_WITH_PREFIX 0 link_prefix)
			list(GET RES_WITH_PREFIX 1 ext_package_name)
			is_External_Package_Defined(${package} ${ext_package_name} ${mode} PATHTO)
			if(PATHTO STREQUAL NOTFOUND)
				message(FATAL_ERROR "[PID] CRITICAL ERROR : undefined external package ${ext_package_name} used for link ${link}!!")
			endif()
			liST(LENGTH RES_WITH_PREFIX SIZE)
			if(SIZE EQUAL 3)
				list(GET RES_WITH_PREFIX 2 relative_path)
				set(fullpath ${link_prefix}${PATHTO}/${relative_path})
			else()
				set(fullpath ${link_prefix}${PATHTO})
			endif()
			list(APPEND res_links ${fullpath})
		else()#this is a link that does not require any replacement (e.g. -l<library name> or -L<system path>)
			list(APPEND res_links ${link})
		endif()
	endif()
endforeach()
set(${COMPLETE_LINKS_PATH} ${res_links} PARENT_SCOPE)
endfunction(resolve_External_Libs_Path)

###
function(resolve_External_Includes_Path COMPLETE_INCLUDES_PATH package_context ext_inc_dirs mode)
set(res_includes)
foreach(include_dir IN ITEMS ${ext_inc_dirs})
	string(REGEX REPLACE "^<([^>]+)>(.*)" "\\1;\\2" RES ${include_dir})
	if(NOT RES STREQUAL ${include_dir})# a replacement has taken place => this is a full path to an incude dir of an external package
		list(GET RES 0 ext_package_name)
		is_External_Package_Defined(${package_context} ${ext_package_name} ${mode} PATHTO)
		if(PATHTO STREQUAL NOTFOUND)
			message(FATAL_ERROR "[PID] CRITICAL ERROR : undefined external package ${ext_package_name} used for include dir ${include_dir}!! Please set the path to this external package.")
		endif()
		liST(LENGTH RES SIZE)
		if(SIZE EQUAL 2)#the package name has a suffix (relative path)
			list(GET RES 1 relative_path)
			set(fullpath ${PATHTO}${relative_path})
		else()	#no suffix append to the external package name
			set(fullpath ${PATHTO})
		endif()
		list(APPEND res_includes ${fullpath})
	else() # this may be an include dir with a prefix (-I<path>) that need replacement
		string(REGEX REPLACE "^-I<([^>]+)>(.*)" "\\1;\\2" RES_WITH_PREFIX ${include_dir})
		if(NOT RES_WITH_PREFIX STREQUAL ${include_dir})
			list(GET RES_WITH_PREFIX 1 relative_path)
			list(GET RES_WITH_PREFIX 0 ext_package_name)
			is_External_Package_Defined(${package_context} ${ext_package_name} ${mode} PATHTO)
			if(PATHTO STREQUAL NOTFOUND)
				message(FATAL_ERROR "[PID] CRITICAL ERROR : undefined external package ${ext_package_name} used for include dir ${include_dir}!! Please set the path to this external package.")
			endif()
			set(fullpath ${PATHTO}${relative_path})
			list(APPEND res_includes ${fullpath})
		else()#this is an include dir that does not require any replacement ! (should be avoided)
			string(REGEX REPLACE "^-I(.+)" "\\1" RES_WITHOUT_PREFIX ${include_dir})
			if(NOT RES_WITHOUT_PREFIX STREQUAL ${include_dir})
				list(APPEND res_includes ${RES_WITHOUT_PREFIX})
			else()
				list(APPEND res_includes ${include_dir}) #for absolute path or system dependencies simply copying the path
			endif()
		endif()
	endif()
endforeach()
set(${COMPLETE_INCLUDES_PATH} ${res_includes} PARENT_SCOPE)
endfunction(resolve_External_Includes_Path)


###
function(resolve_External_Resources_Path COMPLETE_RESOURCES_PATH package ext_resources mode)
set(res_resources)
foreach(resource IN ITEMS ${ext_resources})
	string(REGEX REPLACE "^<([^>]+)>(.*)" "\\1;\\2" RES ${resource})
	if(NOT RES STREQUAL ${resource})# a replacement has taken place => this is a relative path to an external package resource
		set(fullpath)
		list(GET RES 0 ext_package_name)
		list(GET RES 1 relative_path)
		is_External_Package_Defined(${package} ${ext_package_name} ${mode} PATHTO)
		if(PATHTO STREQUAL NOTFOUND)
			message(FATAL_ERROR "[PID] CRITICAL ERROR : undefined external package ${ext_package_name} used for resource ${resource}!! Please set the path to this external package.")
		else()
			set(fullpath ${PATHTO}${relative_path})
			list(APPEND res_resources ${fullpath})
		endif()
	else()
		list(APPEND res_resources ${resource})	#for  relative path or system dependencies (absolute path) simply copying the path
	endif()
endforeach()
set(${COMPLETE_RESOURCES_PATH} ${res_resources} PARENT_SCOPE)
endfunction(resolve_External_Resources_Path)


#############################################################
################ Package Life cycle management ##############
#############################################################

###
function(set_Package_Repository_Address package git_url)
	file(READ ${WORKSPACE_DIR}/packages/${package}/CMakeLists.txt CONTENT)
	string(REGEX REPLACE  "([ \t\n]+)YEAR" "\\1ADDRESS ${git_url}\n\\1 YEAR" NEW_CONTENT ${CONTENT})
	file(WRITE ${WORKSPACE_DIR}/packages/${package}/CMakeLists.txt ${NEW_CONTENT})
endfunction(set_Package_Repository_Address)

###
function(reset_Package_Repository_Address package new_git_url)
	file(READ ${WORKSPACE_DIR}/packages/${package}/CMakeLists.txt CONTENT)
	string(REGEX REPLACE "([ \t\n]+)ADDRESS([ \t\n]+)([^ \t\n]+)([ \t\n]+)" "\\1ADDRESS\\2${new_git_url}\\4" NEW_CONTENT ${CONTENT})
	string(REGEX REPLACE "([ \t\n]+)PUBLIC_ADDRESS([ \t\n]+)([^ \t\n]+)([ \t\n]+)" "\\1PUBLIC_ADDRESS\\2${new_git_url}\\4" FINAL_CONTENT ${NEW_CONTENT})
	file(WRITE ${WORKSPACE_DIR}/packages/${package}/CMakeLists.txt ${FINAL_CONTENT})
endfunction(reset_Package_Repository_Address)

###
function(get_Package_Repository_Address package RES_URL RES_PUBLIC_URL)
	file(READ ${WORKSPACE_DIR}/packages/${package}/CMakeLists.txt CONTENT)
	#checking for restricted address
	string(REGEX REPLACE "^.+[ \t\n]ADDRESS[ \t\n]+([^ \t\n]+)[ \t\n]+.*$" "\\1" url ${CONTENT})
	if(url STREQUAL "${CONTENT}")#no match
		set(${RES_URL} PARENT_SCOPE)
	else()
		set(${RES_URL} ${url} PARENT_SCOPE)
	endif()
	#checking for public (fetch only) address
	string(REGEX REPLACE "^.+[ \t\n]PUBLIC_ADDRESS[ \t\n]+([^ \t\n]+)[ \t\n]+.*$" "\\1" url ${CONTENT})
	if(url STREQUAL "${CONTENT}")#no match
		set(${RES_PUBLIC_URL} PARENT_SCOPE)
	else()
		set(${RES_PUBLIC_URL} ${url} PARENT_SCOPE)
	endif()
endfunction(get_Package_Repository_Address)

###
function(list_All_Source_Packages_In_Workspace PACKAGES)
file(GLOB source_packages RELATIVE ${WORKSPACE_DIR}/packages ${WORKSPACE_DIR}/packages/*)
foreach(a_file IN ITEMS ${source_packages})
	if(EXISTS ${WORKSPACE_DIR}/packages/${a_file} AND IS_DIRECTORY ${WORKSPACE_DIR}/packages/${a_file})
		list(APPEND result ${a_file})
	endif()
endforeach()
set(${PACKAGES} ${result} PARENT_SCOPE)
endfunction(list_All_Source_Packages_In_Workspace)

###
function(list_All_Binary_Packages_In_Workspace NATIVE_PACKAGES EXTERNAL_PACKAGES)
get_System_Variables(CURRENT_PLATFORM_NAME CURRENT_PACKAGE_STRING)
file(GLOB bin_pakages RELATIVE ${WORKSPACE_DIR}/install/${CURRENT_PLATFORM_NAME} ${WORKSPACE_DIR}/install/${CURRENT_PLATFORM_NAME}/*)
foreach(a_file IN ITEMS ${bin_pakages})
	if(EXISTS ${WORKSPACE_DIR}/install/${CURRENT_PLATFORM_NAME}/${a_file} AND IS_DIRECTORY ${WORKSPACE_DIR}/install/${CURRENT_PLATFORM_NAME}/${a_file})
		list(APPEND result ${a_file})
	endif()
endforeach()
set(${NATIVE_PACKAGES} ${result} PARENT_SCOPE)
set(result)
file(GLOB ext_pakages RELATIVE ${WORKSPACE_DIR}/external/${CURRENT_PLATFORM_NAME} ${WORKSPACE_DIR}/external/${CURRENT_PLATFORM_NAME}/*)
foreach(a_file IN ITEMS ${ext_pakages})
	if(EXISTS ${WORKSPACE_DIR}/external/${CURRENT_PLATFORM_NAME}/${a_file} AND IS_DIRECTORY ${WORKSPACE_DIR}/external/${CURRENT_PLATFORM_NAME}/${a_file})
		list(APPEND result ${a_file})
	endif()
endforeach()

set(${EXTERNAL_PACKAGES} ${result} PARENT_SCOPE)
endfunction(list_All_Binary_Packages_In_Workspace)


###
function(package_Already_Built ANSWER package reference_package)
set(${ANSWER} TRUE PARENT_SCOPE)
if(EXISTS ${WORKSPACE_DIR}/packages/${package}/build/build_process)
	if(${WORKSPACE_DIR}/packages/${package}/build/build_process IS_NEWER_THAN ${WORKSPACE_DIR}/packages/${reference_package}/build/build_process)
		message("package ${package} is newer than package ${reference_package}")
		set(${ANSWER} FALSE PARENT_SCOPE)
	endif()
endif()
endfunction(package_Already_Built)


###
function(test_Modified_Components package build_tool result)
set(${result} FALSE PARENT_SCOPE)
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package}/build/release ${build_tool} cmake_check_build_system OUTPUT_VARIABLE NEED_UPDATE)
if(NOT NEED_UPDATE STREQUAL "")
	set(${result} TRUE PARENT_SCOPE)
endif()
endfunction(test_Modified_Components)


###
function(get_Version_Number_And_Repo_From_Package package NUMBER STRING_NUMBER ADDRESS)
set(${ADDRESS} PARENT_SCOPE)
file(STRINGS ${WORKSPACE_DIR}/packages/${package}/CMakeLists.txt PACKAGE_METADATA) #getting global info on the package
foreach(line IN ITEMS ${PACKAGE_METADATA})
	string(REGEX REPLACE "^.*set_PID_Package_Version\\(([0-9]+)(\\ +)([0-9]+)(\\ *)([0-9]*)(\\ *)\\).*$" "\\1;\\3;\\5" A_VERSION ${line})
	if(NOT "${line}" STREQUAL "${A_VERSION}")
		set(VERSION_COMMAND ${A_VERSION})#only taking the last instruction since it shadows previous ones
	endif()
	string(REGEX REPLACE "^.*ADDRESS[\\ \\\t]+([^\\ \\\t]+\\.git).*$" "\\1" AN_ADDRESS ${line})
	if(NOT "${line}" STREQUAL "${AN_ADDRESS}")
		set(${ADDRESS} ${AN_ADDRESS} PARENT_SCOPE)#an address had been found
	endif()
endforeach()
if(VERSION_COMMAND)
	#from here we are sure there is at least 2 digits
	list(GET VERSION_COMMAND 0 MAJOR)
	list(GET VERSION_COMMAND 1 MINOR)
	list(LENGTH VERSION_COMMAND size_of_version)
	if(NOT size_of_version GREATER 2)
		set(PATCH 0)
		list(APPEND VERSION_COMMAND 0)
	else()
		list(GET VERSION_COMMAND 2 PATCH)
	endif()
	set(${STRING_NUMBER} "${MAJOR}.${MINOR}.${PATCH}" PARENT_SCOPE)
else()
	set(${STRING_NUMBER} "" PARENT_SCOPE)
endif()

set(${NUMBER} ${VERSION_COMMAND} PARENT_SCOPE)
endfunction(get_Version_Number_And_Repo_From_Package)

###
function(set_Version_Number_To_Package package major minor patch)

file(READ ${WORKSPACE_DIR}/packages/${package}/CMakeLists.txt PACKAGE_METADATA) #getting global info on the package
string(REGEX REPLACE "^(.*)set_PID_Package_Version\\(([0-9]+)(\\ +)([0-9]+)(\\ *)([0-9]*)(\\ *)\\)(.*)$" "\\1;\\8" PACKAGE_METADATA_WITHOUT_VERSION ${PACKAGE_METADATA})

list(GET PACKAGE_METADATA_WITHOUT_VERSION 0 BEGIN)
list(GET PACKAGE_METADATA_WITHOUT_VERSION 1 END)

set(TO_WRITE "${BEGIN}set_PID_Package_Version(${major} ${minor} ${patch})${END}")
file(WRITE ${WORKSPACE_DIR}/packages/${package}/CMakeLists.txt ${TO_WRITE}) #getting global info on the package

endfunction(set_Version_Number_To_Package)

###
function(is_Binary_Package_Version_In_Development RESULT package version)
set(${RESULT} FALSE PARENT_SCOPE)
get_System_Variables(CURRENT_PLATFORM_NAME CURRENT_PACKAGE_STRING)
set(USE_FILE ${WORKSPACE_DIR}/install/${CURRENT_PLATFORM_NAME}/${package}/${version}/share/Use${package}-${version}.cmake)
if(EXISTS ${USE_FILE}) #file does not exists means the target version is not in development
	set(PID_VERSION_FILE ${WORKSPACE_DIR}/install/${CURRENT_PLATFORM_NAME}/${package}/${version}/share/cmake/${package}_PID_Version.cmake)
	if(EXISTS ${PID_VERSION_FILE})
		include(${PID_VERSION_FILE})
		PID_Package_Is_With_Development_Info_In_Use_Files(RES ${package})
		if(RES)
			include(${USE_FILE})#include the definitions
			if(${package}_DEVELOPMENT_STATE STREQUAL "development") #this binary package has been built from a development branch
				set(${RESULT} TRUE PARENT_SCOPE)
			endif()
		endif()
	endif()
endif()
endfunction(is_Binary_Package_Version_In_Development)


### hard clean consist in cleaning the build folder in an aggressive way
function(hard_Clean_Wrapper wrapper)
set(TARGET_BUILD_FOLDER ${WORKSPACE_DIR}/wrappers/${wrapper}/build)
file(GLOB thefiles RELATIVE ${TARGET_BUILD_FOLDER} ${TARGET_BUILD_FOLDER}/*)
if(thefiles)
foreach(a_file IN ITEMS ${thefiles})
	if(NOT a_file STREQUAL ".gitignore")
		if(IS_DIRECTORY ${TARGET_BUILD_FOLDER}/${a_file})
			execute_process(COMMAND ${CMAKE_COMMAND} -E remove_directory ${TARGET_BUILD_FOLDER}/${a_file})
		else()#it is a regular file or symlink
			execute_process(COMMAND ${CMAKE_COMMAND} -E remove -f ${TARGET_BUILD_FOLDER}/${a_file})
		endif()
	endif()
endforeach()
endif()
endfunction(hard_Clean_Wrapper)

### hard clean consist in cleaning the build folder in an aggressive way
function(hard_Clean_Package package)
set(TARGET_BUILD_FOLDER ${WORKSPACE_DIR}/packages/${package}/build)
file(GLOB thefiles RELATIVE ${TARGET_BUILD_FOLDER} ${TARGET_BUILD_FOLDER}/*)
if(thefiles)
foreach(a_file IN ITEMS ${thefiles})
	if(NOT a_file STREQUAL ".gitignore")
		if(IS_DIRECTORY ${TARGET_BUILD_FOLDER}/${a_file})
			execute_process(COMMAND ${CMAKE_COMMAND} -E remove_directory ${TARGET_BUILD_FOLDER}/${a_file})
		else()#it is a regular file or symlink
			execute_process(COMMAND ${CMAKE_COMMAND} -E remove -f ${TARGET_BUILD_FOLDER}/${a_file})
		endif()
	endif()
endforeach()
endif()
endfunction(hard_Clean_Package)

function(hard_Clean_Package_Debug package)
set(TARGET_BUILD_FOLDER ${WORKSPACE_DIR}/packages/${package}/build/debug)
file(GLOB thefiles RELATIVE ${TARGET_BUILD_FOLDER} ${TARGET_BUILD_FOLDER}/*)
if(thefiles)
foreach(a_file IN ITEMS ${thefiles})
	if(NOT a_file STREQUAL ".gitignore")
		if(IS_DIRECTORY ${TARGET_BUILD_FOLDER}/${a_file})
			execute_process(COMMAND ${CMAKE_COMMAND} -E remove_directory ${TARGET_BUILD_FOLDER}/${a_file})
		else()#it is a regular file or symlink
			execute_process(COMMAND ${CMAKE_COMMAND} -E remove -f ${TARGET_BUILD_FOLDER}/${a_file})
		endif()
	endif()
endforeach()
endif()
endfunction(hard_Clean_Package_Debug)

function(hard_Clean_Package_Release package)
set(TARGET_BUILD_FOLDER ${WORKSPACE_DIR}/packages/${package}/build/release)
file(GLOB thefiles RELATIVE ${TARGET_BUILD_FOLDER} ${TARGET_BUILD_FOLDER}/*)
if(thefiles)
foreach(a_file IN ITEMS ${thefiles})
	if(NOT a_file STREQUAL ".gitignore")
		if(IS_DIRECTORY ${TARGET_BUILD_FOLDER}/${a_file})
			execute_process(COMMAND ${CMAKE_COMMAND} -E remove_directory ${TARGET_BUILD_FOLDER}/${a_file})
		else()#it is a regular file or symlink
			execute_process(COMMAND ${CMAKE_COMMAND} -E remove -f ${TARGET_BUILD_FOLDER}/${a_file})
		endif()
	endif()
endforeach()
endif()
endfunction(hard_Clean_Package_Release)

### reconfiguring a package
function(reconfigure_Package_Build package)
set(TARGET_BUILD_FOLDER ${WORKSPACE_DIR}/packages/${package}/build)
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${TARGET_BUILD_FOLDER} ${CMAKE_COMMAND} ..)
endfunction(reconfigure_Package_Build)

function(reconfigure_Package_Build_Debug package)
set(TARGET_BUILD_FOLDER ${WORKSPACE_DIR}/packages/${package}/build/debug)
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${TARGET_BUILD_FOLDER} ${CMAKE_COMMAND} ..)
endfunction(reconfigure_Package_Build_Debug)

function(reconfigure_Package_Build_Release package)
set(TARGET_BUILD_FOLDER ${WORKSPACE_DIR}/packages/${package}/build/release)
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${TARGET_BUILD_FOLDER} ${CMAKE_COMMAND} ..)
endfunction(reconfigure_Package_Build_Release)

### checking package dependencies (i.e. if their version specified in the CMakeLists.txt of the package is released)
function(check_For_Dependencies_Version BAD_DEPS package)
set(${BAD_DEPS} PARENT_SCOPE)
set(list_of_bad_deps)
#check that the files describing the dependencies are existing
if(NOT EXISTS ${WORKSPACE_DIR}/packages/${package}/build/release/share/Dep${package}.cmake
OR NOT EXISTS ${WORKSPACE_DIR}/packages/${package}/build/debug/share/Dep${package}.cmake)
	message("[PID] ERROR : no dependency description found in package ${package} ! cannot check version of its dependencies.")
	return()
endif()
# loading variables describing dependencies
include(${WORKSPACE_DIR}/packages/${package}/build/release/share/Dep${package}.cmake)
include(${WORKSPACE_DIR}/packages/${package}/build/debug/share/Dep${package}.cmake)
# now check that target dependencies
#debug
if(TARGET_NATIVE_DEPENDENCIES_DEBUG)
	foreach(dep IN ITEMS ${TARGET_NATIVE_DEPENDENCIES_DEBUG})
		if(EXISTS ${WORKSPACE_DIR}/packages/${dep})#checking that the user may use a version generated by a source package
				# step 1: get all versions for that package
				get_Repository_Version_Tags(AVAILABLE_VERSIONS ${dep})
				set(VERSION_NUMBERS)
				if(AVAILABLE_VERSIONS)
					normalize_Version_Tags(VERSION_NUMBERS "${AVAILABLE_VERSIONS}")
				endif()

				# step 2: checking that the version specified in the CMakeLists really exist
				if(TARGET_NATIVE_DEPENDENCY_${dep}_VERSION_DEBUG)
					normalize_Version_String(${TARGET_NATIVE_DEPENDENCY_${dep}_VERSION_DEBUG} NORMALIZED_STR)# normalize to a 3 digits version number to allow comparion in the search

					list(FIND VERSION_NUMBERS ${NORMALIZED_STR} INDEX)
					if(INDEX EQUAL -1)
							list(APPEND list_of_bad_deps "${dep}#${TARGET_NATIVE_DEPENDENCY_${dep}_VERSION_DEBUG}")#using # instead of _ since names of package can contain _
					endif()
				endif()#else no version bound to dependency == no constraint
		endif()
	endforeach()
endif()
#release
if(TARGET_NATIVE_DEPENDENCIES)
	foreach(dep IN ITEMS ${TARGET_NATIVE_DEPENDENCIES})
		if(EXISTS ${WORKSPACE_DIR}/packages/${dep})#checking that the user may use a version generated by a source package
				# step 1: get all versions for that package
				get_Repository_Version_Tags(AVAILABLE_VERSIONS ${dep})
				set(VERSION_NUMBERS)
				if(AVAILABLE_VERSIONS)
					normalize_Version_Tags(VERSION_NUMBERS "${AVAILABLE_VERSIONS}")
				endif()

				# step 2: checking that the version specified in the CMakeLists really exist
				if(TARGET_NATIVE_DEPENDENCY_${dep}_VERSION)
					normalize_Version_String(${TARGET_NATIVE_DEPENDENCY_${dep}_VERSION} NORMALIZED_STR)# normalize to a 3 digits version number to allow comparion in the search
					list(FIND VERSION_NUMBERS ${NORMALIZED_STR} INDEX)
					if(INDEX EQUAL -1)
							list(APPEND list_of_bad_deps "${dep}#${TARGET_NATIVE_DEPENDENCY_${dep}_VERSION}")#using # instead of _ since names of package can contain _
					endif()
				endif()#no version bound to dependency == no constraint
		endif()
	endforeach()
endif()
if(list_of_bad_deps)#guard to avoid troubles with CMake complaining that the list does not exist
	list(REMOVE_DUPLICATES list_of_bad_deps)
	set(${BAD_DEPS} ${list_of_bad_deps} PARENT_SCOPE)#need of guillemet to preserve the list structure
endif()
endfunction(check_For_Dependencies_Version)

################################################################
################ Wrappers Life cycle management ################
################################################################

###
function(set_Wrapper_Repository_Address wrapper git_url)
	file(READ ${WORKSPACE_DIR}/wrappers/${wrapper}/CMakeLists.txt CONTENT)
	string(REGEX REPLACE  "([ \t\n]+)YEAR" "\\1ADDRESS ${git_url}\n\\1YEAR" NEW_CONTENT ${CONTENT})
	file(WRITE ${WORKSPACE_DIR}/wrappers/${wrapper}/CMakeLists.txt ${NEW_CONTENT})
endfunction(set_Wrapper_Repository_Address)

###
function(reset_Wrapper_Repository_Address wrapper new_git_url)
	file(READ ${WORKSPACE_DIR}/wrappers/${wrapper}/CMakeLists.txt CONTENT)
	string(REGEX REPLACE "([ \t\n]+)ADDRESS[ \t\n]+([^ \t\n]+)([ \t\n]+)" "\\1ADDRESS ${new_git_url}\\3" NEW_CONTENT ${CONTENT})
	file(WRITE ${WORKSPACE_DIR}/wrappers/${wrapper}/CMakeLists.txt ${NEW_CONTENT})
endfunction(reset_Wrapper_Repository_Address)

################################################################
################ Frameworks Life cycle management ##############
################################################################

###
function(set_Framework_Repository_Address framework git_url)
	file(READ ${WORKSPACE_DIR}/sites/frameworks/${framework}/CMakeLists.txt CONTENT)
	string(REGEX REPLACE  "([ \t\n]+)YEAR" "\\1ADDRESS ${git_url}\n\\1YEAR" NEW_CONTENT ${CONTENT})
	file(WRITE ${WORKSPACE_DIR}/sites/frameworks/${framework}/CMakeLists.txt ${NEW_CONTENT})
endfunction(set_Framework_Repository_Address)

###
function(reset_Framework_Repository_Address framework new_git_url)
	file(READ ${WORKSPACE_DIR}/sites/frameworks/${framework}/CMakeLists.txt CONTENT)
	string(REGEX REPLACE "([ \t\n]+)ADDRESS[ \t\n]+([^ \t\n]+)([ \t\n]+)" "\\1ADDRESS ${new_git_url}\\3" NEW_CONTENT ${CONTENT})
	file(WRITE ${WORKSPACE_DIR}/sites/frameworks/${framework}/CMakeLists.txt ${NEW_CONTENT})
endfunction(reset_Framework_Repository_Address)

###
function(get_Framework_Repository_Address framework RES_URL)
	file(READ ${WORKSPACE_DIR}/sites/frameworks/${framework}/CMakeLists.txt CONTENT)
	string(REGEX REPLACE "^.+[ \t\n]ADDRESS[ \t\n]+([^ \t\n]+)[ \t\n]+.*$" "\\1" url ${CONTENT})
	if(url STREQUAL "${CONTENT}")#no match
		set(${RES_URL} "" PARENT_SCOPE)
		return()
	endif()
	set(${RES_URL} ${url} PARENT_SCOPE)
endfunction(get_Framework_Repository_Address)

### function used to extract information used by jekyll to adequately configure the site
function(get_Jekyll_URLs full_url PUBLIC_URL BASE_URL)
	string(REGEX REPLACE "^(http[s]?://[^/]+)/(.+)$" "\\1;\\2" all_urls ${full_url})
	if(NOT (all_urls STREQUAL ${full_url}))#it matches
		list(GET all_urls 0 pub)
		list(GET all_urls 1 base)
		set(PUBLIC_URL ${pub} PARENT_SCOPE)
		set(BASE_URL ${base} PARENT_SCOPE)
	else()
		string(REGEX REPLACE "^(http[s]?://[^/]+)/?$" "\\1" pub_url ${full_url})
		set(PUBLIC_URL ${pub_url} PARENT_SCOPE)
		set(BASE_URL PARENT_SCOPE)
	endif()
endfunction(get_Jekyll_URLs)

################################################################
################ Markdown file management ######################
################################################################

function(test_Site_Content_File FILE_NAME EXTENSION file_name)
set(FILE_NAME PARENT_SCOPE)
set(EXTENSION PARENT_SCOPE)

#get the name and extension of the file
string(REGEX REPLACE "^([^\\.]+)\\.(.+)$" "\\1;\\2" RESULTING_FILE ${file_name})
if(NOT RESULTING_FILE STREQUAL ${file_name}) #it matches
	list(GET RESULTING_FILE 1 RES_EXT)
	list(APPEND POSSIBLE_EXTS markdown mkdown mkdn mkd md htm html jpg png gif bmp)
	list(FIND POSSIBLE_EXTS ${RES_EXT} INDEX)
	if(INDEX GREATER -1)
		list(GET RESULTING_FILE 0 RES_NAME)
		set(FILE_NAME ${RES_NAME} PARENT_SCOPE)
		set(EXTENSION ${RES_EXT} PARENT_SCOPE)
	endif()
endif()
endfunction(test_Site_Content_File)

#########################################################################
################ text files manipulation utilities ######################
#########################################################################

### testing is two regular files have same content
function(test_Same_File_Content file1_path file2_path ARE_SAME)
file(READ ${file1_path} FILE_1_CONTENT)
file(READ ${file2_path} FILE_2_CONTENT)
if("${FILE_1_CONTENT}" STREQUAL "${FILE_2_CONTENT}")
	set(${ARE_SAME} TRUE PARENT_SCOPE)
else()
	set(${ARE_SAME} FALSE PARENT_SCOPE)
endif()
endfunction(test_Same_File_Content)

### testing is two directory have exact same content (even their contained files have same content)
function(test_Same_Directory_Content dir1_path dir2_path ARE_SAME)
file(GLOB_RECURSE ALL_FILES_DIR1 RELATIVE ${dir1_path} ${dir1_path}/*)
file(GLOB_RECURSE ALL_FILES_DIR2 RELATIVE ${dir2_path} ${dir2_path}/*)
foreach(a_file IN ITEMS ${ALL_FILES_DIR1})
	list(FIND ALL_FILES_DIR2 ${a_file} INDEX)
	if(INDEX EQUAL -1)#if file not found -> not same content
		set(${ARE_SAME} FALSE PARENT_SCOPE)
		return()
	else()
		if(NOT IS_DIRECTORY ${dir1_path}/${a_file} AND NOT IS_SYMLINK ${dir1_path}/${a_file})
			set(SAME FALSE)
			test_Same_File_Content(${dir1_path}/${a_file} ${dir2_path}/${a_file} SAME)
			if(NOT SAME)#file content is different

				set(${ARE_SAME} FALSE PARENT_SCOPE)
				return()
			endif()
		endif()
	endif()
endforeach()
set(${ARE_SAME} TRUE PARENT_SCOPE)
endfunction(test_Same_Directory_Content)

######################################################################################
################ compiler arguments test/manipulation functions ######################
######################################################################################

function(translate_Standard_Into_Option RES_C_STD_OPT RES_CXX_STD_OPT c_std_number cxx_std_number)

	#managing c++
	if(cxx_std_number EQUAL 98)
		set(${RES_CXX_STD_OPT} "-std=c++98" PARENT_SCOPE)
	elseif(cxx_std_number EQUAL 11)
		set(${RES_CXX_STD_OPT} "-std=c++11" PARENT_SCOPE)
	elseif(cxx_std_number EQUAL 14)
		set(${RES_CXX_STD_OPT} "-std=c++14" PARENT_SCOPE)
	elseif(cxx_std_number EQUAL 17)
		set(${RES_CXX_STD_OPT} "-std=c++17" PARENT_SCOPE)
	endif()

	#managing c
	if(c_std_number EQUAL 90)
		set(${RES_C_STD_OPT} "-std=c90" PARENT_SCOPE)
	elseif(c_std_number EQUAL 99)
		set(${RES_C_STD_OPT} "-std=c99" PARENT_SCOPE)
	elseif(c_std_number EQUAL 11)
		set(${RES_C_STD_OPT} "-std=c11" PARENT_SCOPE)
	endif()

endfunction(translate_Standard_Into_Option)

### compare 2 different C++ language standard version
function(is_CXX_Version_Less IS_LESS first second)
if(first EQUAL 98)
	if(second EQUAL 98)
		set(${IS_LESS} FALSE PARENT_SCOPE)
	else()
		set(${IS_LESS} TRUE PARENT_SCOPE)
	endif()
else()
	if(second EQUAL 98)
		set(${IS_LESS} FALSE PARENT_SCOPE)
	else()# both number are comparable
		if(first LESS second)
			set(${IS_LESS} TRUE PARENT_SCOPE)
		else()
			set(${IS_LESS} FALSE PARENT_SCOPE)
		endif()
	endif()
endif()
endfunction(is_CXX_Version_Less)

### compare 2 different C language standard version
function(is_C_Version_Less IS_LESS first second)
if(first EQUAL 11)#last version is 11 so never less
	set(${IS_LESS} FALSE PARENT_SCOPE)
else()
	if(second EQUAL 11)
		set(${IS_LESS} TRUE PARENT_SCOPE)
	else()# both number are comparable (90 or 99)
		if(first LESS second)
			set(${IS_LESS} TRUE PARENT_SCOPE)
		else()
			set(${IS_LESS} FALSE PARENT_SCOPE)
		endif()
	endif()
endif()
endfunction(is_C_Version_Less)

### check if the option passed to the compiler is used to set the language standard is use
function(is_C_Standard_Option STANDARD_NUMBER opt)
string(REGEX REPLACE "^[ \t]*-std=(c|gnu)(90|99|11)[ \t]*$" "\\2" OUTPUT_VAR_C ${opt})
if(NOT OUTPUT_VAR_C STREQUAL opt)#it matches
	set(${STANDARD_NUMBER} ${OUTPUT_VAR_C} PARENT_SCOPE)
endif()
endfunction(is_C_Standard_Option)

### check if the option passed to the compiler is used to set the language standard is use
function(is_CXX_Standard_Option STANDARD_NUMBER opt)
string(REGEX REPLACE "^[ \t]*-std=(c|gnu)\\+\\+(98|11|14|17)[ \t]*$" "\\2" OUTPUT_VAR_CXX ${opt})
if(NOT OUTPUT_VAR_CXX STREQUAL opt)#it matches
	set(${STANDARD_NUMBER} ${OUTPUT_VAR_CXX} PARENT_SCOPE)
endif()
endfunction(is_CXX_Standard_Option)

#################################################################################################
################################### pure CMake utilities ########################################
#################################################################################################

function(append_Unique_In_Cache list_name element_value)
	if(${list_name})
		set(temp_list ${${list_name}})
		list(APPEND temp_list ${element_value})
		list(REMOVE_DUPLICATES temp_list)
		set(${list_name} ${temp_list} CACHE INTERNAL "")
	else()
		set(${list_name} ${element_value} CACHE INTERNAL "")
	endif()
endfunction(append_Unique_In_Cache)
