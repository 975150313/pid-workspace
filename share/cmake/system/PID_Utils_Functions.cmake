###
function(get_Mode_Target_Suffix TARGET_SUFFIX mode)
if(mode MATCHES Debug)
	set(${TARGET_SUFFIX} "-dbg" PARENT_SCOPE)
elseif(mode MATCHES Release)
	set(${TARGET_SUFFIX} "" PARENT_SCOPE)
else()
	message(FATAL_ERROR "Only Release or Debug modes are possible within PID")
endif()
endfunction(get_Mode_Target_Suffix)

###
function(get_Mode_Variable_Suffix VARIABLE_SUFFIX mode)
if(mode MATCHES Debug)
	set(${VARIABLE_SUFFIX} "_DEBUG" PARENT_SCOPE)
elseif(mode MATCHES Release)
	set(${VARIABLE_SUFFIX} "" PARENT_SCOPE)
else()
	message(FATAL_ERROR "Only Release or Debug modes are possible within PID")
endif()
endfunction(get_Mode_Variable_Suffix)

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
function(extract_All_Words name_with_underscores all_words_in_list)
set(res "")
string(REPLACE "_" ";" res "${name_with_underscores}")
set(${all_words_in_list} ${res} PARENT_SCOPE)
endfunction()

###
function(fill_List_Into_String input_list res_string)
set(res "")
foreach(element IN ITEMS ${input_list})
	set(res "${res} ${element}")
endforeach()
string(STRIP "${res}" res_finished)
set(${res_string} ${res_finished} PARENT_SCOPE)
endfunction()

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
function(create_Rpath_Symlink path_to_target path_to_rpath_folder rpath_sub_folder)
#first creating the path where to put symlinks if it does not exist
set(FULL_RPATH_DIR ${path_to_rpath_folder}/.rpath/${rpath_sub_folder})
file(MAKE_DIRECTORY ${FULL_RPATH_DIR})
get_filename_component(A_FILE ${path_to_target} NAME)
#second creating the symlink
create_Symlink(${path_to_target} ${FULL_RPATH_DIR}/${A_FILE})
endfunction(create_Rpath_Symlink)

###
function(install_Rpath_Symlink path_to_target path_to_rpath_folder rpath_sub_folder)
get_filename_component(A_FILE "${path_to_target}" NAME)
set(FULL_RPATH_DIR ${path_to_rpath_folder}/.rpath/${rpath_sub_folder})
install(DIRECTORY DESTINATION ${FULL_RPATH_DIR}) #create the folder that will contain symbolic links to runtime resources used by the component (will allow full relocation of components runtime dependencies at install time)
install(CODE "
	##create_Rpath_Symlink(${lib} ${${PROJECT_NAME}_DEPLOY_PATH} ${bin_component})
	if(EXISTS ${FULL_RPATH_DIR}/${A_FILE} AND IS_SYMLINK ${FULL_RPATH_DIR}/${A_FILE})
		execute_process(COMMAND ${CMAKE_COMMAND} -E remove -f ${FULL_RPATH_DIR}/${A_FILE}
				WORKING_DIRECTORY ${CMAKE_INSTALL_PREFIX})
	endif()
	execute_process(COMMAND ${CMAKE_COMMAND} -E create_symlink ${path_to_target} ${FULL_RPATH_DIR}/${A_FILE}
				WORKING_DIRECTORY ${CMAKE_INSTALL_PREFIX})
	message(\"-- Installing: ${FULL_RPATH_DIR}/${A_FILE}\")

")# creating links "on the fly" when installing

endfunction(install_Rpath_Symlink)

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
function (document_Version_Strings package_name major minor patch)
	set(${package_name}_VERSION_MAJOR ${major} CACHE INTERNAL "")
	set(${package_name}_VERSION_MINOR ${minor} CACHE INTERNAL "")
	set(${package_name}_VERSION_PATCH ${patch} CACHE INTERNAL "")
	set(${package_name}_VERSION_STRING "${major}.${minor}.${patch}" CACHE INTERNAL "")
	set(${package_name}_VERSION_RELATIVE_PATH "${major}.${minor}.${patch}" CACHE INTERNAL "")
endfunction(document_Version_Strings)

###
function(get_Version_String_Numbers version_string major minor patch)
string(REGEX REPLACE "^([0-9]+)\\.([0-9]+)\\.([0-9]+)$" "\\1;\\2;\\3" A_VERSION "${version_string}")
if(NOT A_VERSION STREQUAL "${version_string}")
	list(GET A_VERSION 0 major_vers)
	list(GET A_VERSION 1 minor_vers)
	list(GET A_VERSION 2 patch_vers)
	set(${major} ${major_vers} PARENT_SCOPE)
	set(${minor} ${minor_vers} PARENT_SCOPE)
	set(${patch} ${patch_vers} PARENT_SCOPE)
else()
	message(FATAL_ERROR "BUG : corrupted version string : ${version_string}")
endif()	
endfunction(get_Version_String_Numbers)

###
function(list_Version_Subdirectories result curdir)
	file(GLOB children RELATIVE ${curdir} ${curdir}/*)
	set(dirlist "")
	foreach(child ${children})
		if(IS_DIRECTORY ${curdir}/${child})
			list(APPEND dirlist ${child})
		endif()
	endforeach()
	list(REMOVE_ITEM dirlist "installers")
	set(${result} ${dirlist} PARENT_SCOPE)
endfunction(list_Version_Subdirectories)


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
function(generate_Full_Author_String author RES_STRING)
string(REGEX REPLACE "^([^\\(]+)\\(([^\\)]*)\\)$" "\\1;\\2" author_institution "${author}")
list(GET author_institution 0 AUTHOR_NAME)
list(GET author_institution 1 INSTITUTION_NAME)
extract_All_Words("${AUTHOR_NAME}" AUTHOR_ALL_WORDS)
extract_All_Words("${INSTITUTION_NAME}" INSTITUTION_ALL_WORDS)
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
extract_All_Words("${author}" AUTHOR_ALL_WORDS)
fill_List_Into_String("${AUTHOR_ALL_WORDS}" AUTHOR_STRING)
if(mail AND NOT mail STREQUAL "")
	set(${RES_STRING} "${AUTHOR_STRING} (${mail})" PARENT_SCOPE)
else()
	set(${RES_STRING} "${AUTHOR_STRING}" PARENT_SCOPE)
endif()
endfunction()

###
function(generate_Institution_String institution RES_STRING)
extract_All_Words("${institution}" INSTITUTION_ALL_WORDS)
fill_List_Into_String("${INSTITUTION_ALL_WORDS}" INSTITUTION_STRING)
set(${RES_STRING} "${INSTITUTION_STRING}" PARENT_SCOPE)
endfunction()

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
)
set (${RESULT} ${RES} PARENT_SCOPE)
endfunction(get_All_Sources_Relative)

###
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
)
set (${RESULT} ${RES} PARENT_SCOPE)
endfunction(get_All_Sources_Absolute)

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
		if(LIB_TYPE MATCHES "^\\.dylib(\\.[^\\.]+)*$")#found shared lib
			set(${SHARED} TRUE PARENT_SCOPE)
		endif()
	elseif(UNIX)
		if(LIB_TYPE MATCHES "^\\.so(\\.[^\\.]+)*$")#found shared lib
			set(${SHARED} TRUE PARENT_SCOPE)
		endif()
	endif()
endif()
endfunction(is_Shared_Lib_With_Path)


###
function(is_External_Package_Defined ref_package ext_package mode RES_PATH_TO_PACKAGE)
get_Mode_Variable_Suffix(mode_suffix ${mode})
set(EXT_PACKAGE-NOTFOUND PARENT_SCOPE)

if(DEFINED ${ref_package}_EXTERNAL_DEPENDENCY_${ext_package}_VERSION${mode_suffix})
	set(${RES_PATH_TO_PACKAGE} ${WORKSPACE_DIR}/external/${ext_package}/${${ref_package}_EXTERNAL_DEPENDENCY_${ext_package}_VERSION${mode_suffix}} PARENT_SCOPE)
	return()
elseif(${ref_package}_DEPENDENCIES${mode_suffix}) #the external dependency may be issued from a third party native package
	foreach(dep_pack IN ITEMS ${${ref_package}_DEPENDENCIES${mode_suffix}})
		is_External_Package_Defined(${dep_pack} ${ext_package} ${mode} PATHTO)
		if(NOT EXT_PACKAGE-NOTFOUND)
			set(${RES_PATH_TO_PACKAGE} ${PATHTO} PARENT_SCOPE)
			return()
		endif()
	endforeach()
endif()
set(EXT_PACKAGE-NOTFOUND TRUE PARENT_SCOPE)
endfunction(is_External_Package_Defined)


###
function(resolve_External_Libs_Path COMPLETE_LINKS_PATH package ext_links mode)
set(res_links)
foreach(link IN ITEMS ${ext_links})
	string(REGEX REPLACE "^<([^>]+)>([^\\.]+\\.[a|la|so|dylib].*)" "\\1;\\2" RES ${link})
	if(NOT RES MATCHES ${link})# a replacement has taken place => this is a full path to a library
		set(fullpath)
		list(GET RES 0 ext_package_name)
		list(GET RES 1 relative_path)
		unset(EXT_PACKAGE-NOTFOUND)		
		is_External_Package_Defined(${package} ${ext_package_name} ${mode} PATHTO)
		if(DEFINED EXT_PACKAGE-NOTFOUND)
			message(FATAL_ERROR "undefined external package ${ext_package_name} used for link ${link}!! Please set the path to this external package.")		
		else()
			set(fullpath ${PATHTO}${relative_path})
			list(APPEND res_links ${fullpath})				
		endif()
	else() # this may be a link with a prefix (like -L<path>) that need replacement
		string(REGEX REPLACE "^([^<]+)<([^>]+)>(.*)" "\\1;\\2;\\3" RES_WITH_PREFIX ${link})
		if(NOT RES_WITH_PREFIX MATCHES ${link})
			list(GET RES_WITH_PREFIX 0 link_prefix)
			list(GET RES_WITH_PREFIX 1 ext_package_name)
			is_External_Package_Defined(${package} ${ext_package_name} ${mode} PATHTO)
			if(EXT_PACKAGE-NOTFOUND)
				message(FATAL_ERROR "undefined external package ${ext_package_name} used for link ${link}!!")
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
	if(NOT RES MATCHES ${include_dir})# a replacement has taken place => this is a full path to an incude dir of an external package
		list(GET RES 0 ext_package_name)
		is_External_Package_Defined(${package_context} ${ext_package_name} ${mode} PATHTO)
		if(EXT_PACKAGE-NOTFOUND)
			message(FATAL_ERROR "undefined external package ${ext_package_name} used for include dir ${include_dir}!! Please set the path to this external package.")
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
		if(NOT RES_WITH_PREFIX MATCHES ${include_dir})
			list(GET RES_WITH_PREFIX 1 relative_path)
			list(GET RES_WITH_PREFIX 0 ext_package_name)
			is_External_Package_Defined(${package_context} ${ext_package_name} ${mode} PATHTO)
			if(EXT_PACKAGE-NOTFOUND)
				message(FATAL_ERROR "undefined external package ${ext_package_name} used for include dir ${include_dir}!! Please set the path to this external package.")
			endif()
			set(fullpath ${PATHTO}${relative_path})
			list(APPEND res_includes ${fullpath})
		else()#this is an include dir that does not require any replacement ! (should be avoided)
			string(REGEX REPLACE "^-I(.+)" "\\1" RES_WITHOUT_PREFIX ${include_dir})			
			if(NOT RES_WITHOUT_PREFIX MATCHES ${include_dir})
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
	if(NOT RES MATCHES ${resource})# a replacement has taken place => this is a relative path to a resource
		set(fullpath)
		list(GET RES 0 ext_package_name)
		list(GET RES 1 relative_path)
		unset(EXT_PACKAGE-NOTFOUND)		
		is_External_Package_Defined(${package} ${ext_package_name} ${mode} PATHTO)
		if(DEFINED EXT_PACKAGE-NOTFOUND)
			message(FATAL_ERROR "undefined external package ${ext_package_name} used for resource ${resource}!! Please set the path to this external package.")		
		else()
			set(fullpath ${PATHTO}${relative_path})
			list(APPEND res_resources ${fullpath})				
		endif()
	else()
		list(APPEND res_resources ${resource})	#for absolute path or system dependencies simply copying the path	
	endif()
endforeach()
set(${COMPLETE_RESOURCES_PATH} ${res_resources} PARENT_SCOPE)
endfunction(resolve_External_Resources_Path)


###
function(get_Mode_Variables TARGET_SUFFIX VAR_SUFFIX mode)
if(mode MATCHES Release)
	set(${TARGET_SUFFIX} PARENT_SCOPE)
	set(${VAR_SUFFIX} PARENT_SCOPE)
else()
	set(${TARGET_SUFFIX} -dbg PARENT_SCOPE)
	set(${VAR_SUFFIX} _DEBUG PARENT_SCOPE)
endif()
endfunction(get_Mode_Variables)

