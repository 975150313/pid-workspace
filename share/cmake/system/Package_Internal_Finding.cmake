
##################################################################################
##################auxiliary functions to check package version####################
##################################################################################

### check if an exact major.minor version exists (patch version is always let undefined)
function (check_Exact_Version 	VERSION_HAS_BEEN_FOUND 
				package_name package_install_dir major_version minor_version) #minor version cannot be increased
set(${VERSION_HAS_BEEN_FOUND} FALSE PARENT_SCOPE)
list_Version_Subdirectories(version_dirs ${package_install_dir})
if(version_dirs)#scanning non local versions
	set(curr_patch_version -1)
	foreach(patch IN ITEMS ${version_dirs})
		string(REGEX REPLACE "^${major_version}\\.${minor_version}\\.([0-9]+)$" "\\1" A_VERSION "${patch}")
		if(	NOT (A_VERSION STREQUAL "${patch}") #there is a match
			AND ${A_VERSION} GREATER ${curr_patch_version})#newer patch version
			set(curr_patch_version ${A_VERSION})
			set(result true)	
		endif()
	endforeach()
	
	if(result)#at least a good version has been found
		set(${VERSION_HAS_BEEN_FOUND} TRUE PARENT_SCOPE)
		document_Version_Strings(${package_name} ${major_version} ${minor_version} ${curr_patch_version})
		return()
	endif()
endif()
endfunction(check_Exact_Version)


###  check if a version with constraints =major >=minor (with greater minor number available) exists (patch version is always let undefined)
function(check_Best_Version 	VERSION_HAS_BEEN_FOUND
				package_name package_install_dir major_version minor_version)#major version cannot be increased
set(${VERSION_HAS_BEEN_FOUND} FALSE PARENT_SCOPE)
set(curr_max_minor_version ${minor_version})
set(curr_patch_version 0)
list_Version_Subdirectories(version_dirs ${package_install_dir})
if(version_dirs)#scanning local versions  
	foreach(version IN ITEMS ${version_dirs})
		string(REGEX REPLACE "^${major_version}\\.([0-9]+)\\.([0-9]+)$" "\\1;\\2" A_VERSION "${version}")
		if(NOT (A_VERSION STREQUAL "${version}"))#there is a match
			list(GET A_VERSION 0 minor)
			list(GET A_VERSION 1 patch)
			if("${minor}" EQUAL "${curr_max_minor_version}"
			AND ("${patch}" EQUAL "${curr_patch_version}" OR "${patch}" GREATER "${curr_patch_version}"))
				set(result true)			
				#a more recent patch version found with same max minor version
				set(curr_patch_version ${patch})
			elseif("${minor}" GREATER "${curr_max_minor_version}")
				set(result true)
				#a greater minor version found
				set(curr_max_minor_version ${minor})
				set(curr_patch_version ${patch})	
			endif()
		endif()
	endforeach()
endif()
if(result)#at least a good version has been found
	set(${VERSION_HAS_BEEN_FOUND} TRUE PARENT_SCOPE)
	document_Version_Strings(${package_name} ${major_version} ${curr_max_minor_version} ${curr_patch_version})
endif()
endfunction(check_Best_Version)


### check if a version with constraints >=major >=minor (with greater major and minor number available) exists (patch version is always let undefined) 
function(check_Last_Version 	VERSION_HAS_BEEN_FOUND
				package_name package_install_dir)#taking local version or the most recent if not available
set(${VERSION_HAS_BEEN_FOUND} FALSE PARENT_SCOPE)
list_Version_Subdirectories(non_local_versions ${package_install_dir})
if(non_local_versions)  
	set(${VERSION_HAS_BEEN_FOUND} TRUE PARENT_SCOPE)
	set(version_string_curr "0.0.0")
	foreach(non_local_version_dir IN ITEMS ${non_local_versions})
		if("${version_string_curr}" VERSION_LESS "${non_local_version_dir}")
			set(version_string_curr ${non_local_version_dir})
		endif()
	endforeach()
	get_Version_String_Numbers(${version_string_curr} major minor patch)
	document_Version_Strings(${package_name} ${major} ${minor} ${patch})
endif()
endfunction(check_Last_Version)

##################################################################################
##################auxiliary functions to check components info  ##################
##################################################################################

#checking elements of a component
function(check_Component_Elements_Exist COMPONENT_ELEMENT_NOTFOUND package_path package_name component_name)
set(${COMPONENT_ELEMENT_NOTFOUND} TRUE PARENT_SCOPE)
if(NOT DEFINED ${package_name}_${component_name}_TYPE)#type of the component must be defined
	return()
endif() 	

list(FIND ${package_name}_COMPONENTS_APPS ${component_name} idx)
if(idx EQUAL -1)#the component is NOT an application
	list(FIND ${package_name}_COMPONENTS_LIBS ${component_name} idx)
	if(idx EQUAL -1)#the component is NOT a library either
		return() #ERROR
	else()#the component is a library 
		#for a lib checking headers and then binaries
		if(DEFINED ${package_name}_${component_name}_HEADERS)#a library must have HEADERS defined otherwise ERROR
			#checking existence of all its exported headers			
			foreach(header IN ITEMS ${${package_name}_${component_name}_HEADERS})
				find_file(PATH_TO_HEADER NAMES ${header} PATHS ${package_path}/include/${${package_name}_${component_name}_HEADER_DIR_NAME} NO_DEFAULT_PATH)
				if(PATH_TO_HEADER-NOTFOUND)
					set(PATH_TO_HEADER CACHE INTERNAL "")
					return()
				else()
					set(PATH_TO_HEADER CACHE INTERNAL "")
				endif()
			endforeach()
		else()
			return()
		endif()
		#now checking for binaries if necessary
		if(	${package_name}_${component_name}_TYPE STREQUAL "STATIC"
			OR ${package_name}_${component_name}_TYPE STREQUAL "SHARED")
			#checking release and debug binaries (at least one is required)
			find_library(	PATH_TO_LIB 
					NAMES ${${package_name}_${component_name}_BINARY_NAME} ${${package_name}_${component_name}_BINARY_NAME_DEBUG}
					PATHS ${package_path}/lib NO_DEFAULT_PATH)
			if(PATH_TO_LIB-NOTFOUND)
				set(PATH_TO_LIB CACHE INTERNAL "")				
				return()
			else()
				set(PATH_TO_LIB CACHE INTERNAL "")
			endif()			
		endif()
		set(${COMPONENT_ELEMENT_NOTFOUND} FALSE PARENT_SCOPE)
	endif()

else()#the component is an application
	if(${${package_name}_${component_name}_TYPE} STREQUAL "APP")
		#now checking for binary
		find_program(	PATH_TO_EXE 
				NAMES ${${package_name}_${component_name}_BINARY_NAME} ${${package_name}_${component_name}_BINARY_NAME_DEBUG}
				PATHS ${package_path}/bin NO_DEFAULT_PATH)
		if(PATH_TO_EXE-NOTFOUND)
			set(PATH_TO_EXE CACHE INTERNAL "")
			return()
		else()
			set(PATH_TO_EXE CACHE INTERNAL "")
		endif()
		set(${COMPONENT_ELEMENT_NOTFOUND} FALSE  PARENT_SCOPE)
	else()
		return()
	endif()
endif()

endfunction(check_Component_Elements_Exist)

###
function (all_Components package_name package_version path_to_package_version)
set(USE_FILE_NOTFOUND FALSE PARENT_SCOPE)
include(${path_to_package_version}/share/Use${package_name}-${package_version}.cmake  OPTIONAL RESULT_VARIABLE res)#using the generated Use<package>-<version>.cmake file to get adequate version information about components
if(	${res} STREQUAL NOTFOUND
	OR NOT DEFINED ${package_name}_COMPONENTS) #if there is no component defined for the package there is an error
	set(USE_FILE_NOTFOUND TRUE PARENT_SCOPE)
	return()
endif()

foreach(a_component IN ITEMS ${${package_name}_COMPONENTS})
	check_Component_Elements_Exist(COMPONENT_ELEMENT_NOTFOUND ${path_to_package_version} ${package_name} ${a_component})
	if(COMPONENT_ELEMENT_NOTFOUND)
		set(${package_name}_${requested_component}_FOUND FALSE CACHE INTERNAL "")
	else()
		set(${package_name}_${requested_component}_FOUND TRUE CACHE INTERNAL "")
	endif()
endforeach()
endfunction (all_Components)


###
function (select_Components package_name package_version path_to_package_version list_of_components)
set(USE_FILE_NOTFOUND FALSE PARENT_SCOPE)
include(${path_to_package_version}/share/Use${package_name}-${package_version}.cmake OPTIONAL RESULT_VARIABLE res)#using the generated Use<package>-<version>.cmake file to get adequate version information about components
if(${res} STREQUAL NOTFOUND)
	set(USE_FILE_NOTFOUND TRUE PARENT_SCOPE)
	return()
endif()

if(NOT DEFINED ${package_name}_COMPONENTS)#if there is no component defined for the package there is an error
	set(USE_FILE_NOTFOUND TRUE PARENT_SCOPE)
	return()
endif()

#checking that all requested components trully exist for this version
set(ALL_REQUIRED_COMPONENTS_HAVE_BEEN_FOUND TRUE PARENT_SCOPE)
foreach(requested_component IN ITEMS ${list_of_components})
	list(FIND ${package_name}_COMPONENTS ${requested_component} idx)	
	if(idx EQUAL -1)#component has not been found
		set(${package_name}_${requested_component}_FOUND FALSE  CACHE INTERNAL "")
		if(${${package_name}_FIND_REQUIRED_${requested_component}})
			set(ALL_REQUIRED_COMPONENTS_HAVE_BEEN_FOUND FALSE PARENT_SCOPE)
		endif()
	else()#component found
		check_Component_Elements_Exist(COMPONENT_ELEMENT_NOTFOUND ${path_to_package_version} ${package_name} ${requested_component})
		if(COMPONENT_ELEMENT_NOTFOUND)
			set(${package_name}_${requested_component}_FOUND FALSE  CACHE INTERNAL "")
		else()		
			set(${package_name}_${requested_component}_FOUND TRUE  CACHE INTERNAL "")
		endif()
	endif()
endforeach()
endfunction (select_Components)


###
function(is_Exact_Version_Compatible_With_Previous_Constraints 
		is_compatible
		need_finding
		package
		version_string)

set(${is_compatible} FALSE PARENT_SCOPE)
set(${need_finding} FALSE PARENT_SCOPE)
if(${package}_REQUIRED_VERSION_EXACT)
	if(NOT ${${package}_REQUIRED_VERSION_EXACT} VERSION_EQUAL ${version_string})#not compatible if versions are not the same				
		return() 
	endif()
	set(${is_compatible} TRUE PARENT_SCOPE)
	return()
endif()
#no exact version required	
get_Version_String_Numbers("${version_string}.0" exact_major exact_minor exact_patch)
foreach(version_required IN ITEMS ${${package}_ALL_REQUIRED_VERSIONS})
#	message("version required=${version_required}, exact_major=${exact_major}, exact_minor=${exact_minor}")
	unset(COMPATIBLE_VERSION)
	is_Compatible_Version(COMPATIBLE_VERSION ${exact_major} ${exact_minor} ${version_required})
	if(NOT COMPATIBLE_VERSION)
		return()#not compatible
	endif()
endforeach()

set(${is_compatible} TRUE PARENT_SCOPE)	
if(NOT ${${package}_VERSION_STRING} VERSION_EQUAL ${version_string})
	set(${need_finding} TRUE PARENT_SCOPE) #need to find the new exact version
endif()
endfunction(is_Exact_Version_Compatible_With_Previous_Constraints)


###
function(is_Version_Compatible_With_Previous_Constraints 
		is_compatible		
		version_to_find
		package
		version_string)

set(${is_compatible} FALSE PARENT_SCOPE)
# 1) testing compatibility and recording the higher constraint for minor version number
if(${package}_REQUIRED_VERSION_EXACT)
	get_Version_String_Numbers("${${package}_REQUIRED_VERSION_EXACT}.0" exact_major exact_minor exact_patch)
	is_Compatible_Version(COMPATIBLE_VERSION ${exact_major} ${exact_minor} ${version_string})
	if(COMPATIBLE_VERSION)	
		set(${is_compatible} TRUE PARENT_SCOPE)
	endif()
	return()#no need to set the version to find
endif()
get_Version_String_Numbers("${version_string}.0" new_major new_minor new_patch)
set(curr_major ${new_major})
set(curr_max_minor 0)
foreach(version_required IN ITEMS ${${package}_ALL_REQUIRED_VERSIONS})
	get_Version_String_Numbers("${version_required}.0" required_major required_minor required_patch)
	if(NOT ${required_major} EQUAL ${new_major})
		return()#not compatible
	elseif(${required_minor} GREATER ${new_major})
		set(curr_max_minor ${required_minor})
	else()
		set(curr_max_minor ${new_minor})
	endif()
endforeach()
set(${is_compatible} TRUE PARENT_SCOPE)	

# 2) now we have the greater constraint 
set(max_version_constraint "${curr_major}.${curr_max_minor}")
if(NOT ${${package}_VERSION_STRING} VERSION_GREATER ${max_version_constraint})
	set(${version_to_find} ${max_version_constraint} PARENT_SCOPE) #need to find the new version
endif()

endfunction(is_Version_Compatible_With_Previous_Constraints)


###
# each dependent package version is defined as ${package}_DEPENDENCY_${dependency}_VERSION
# other variables set by the package version use file 
# ${package}_DEPENDENCY_${dependency}_REQUIRED		# TRUE if package is required FALSE otherwise (QUIET MODE)
# ${package}_DEPENDENCY_${dependency}_VERSION		# version if a version if specified
# ${package}_DEPENDENCY_${dependency}_VERSION_EXACT	# TRUE if exact version is required
# ${package}_DEPENDENCY_${dependency}_COMPONENTS	# list of components
function(resolve_Package_Dependency package dependency mode)
if(mode MATCHES Debug)
	set(build_mode_suffix "_DEBUG")
else()
	set(build_mode_suffix "")
endif()

if(${dependency}_FOUND) #the dependency has already been found (previously found in iteration or recursion, not possible to import it again)
	if(${package}_DEPENDENCY_${dependency}_VERSION${build_mode_suffix}) # a specific version is required
	 	if( ${package}_DEPENDENCY_${dependency}_VERSION_EXACT${build_mode_suffix}) #an exact version is required
			
			is_Exact_Version_Compatible_With_Previous_Constraints(IS_COMPATIBLE NEED_REFIND ${dependency} ${${package}_DEPENDENCY_${dependency}_VERSION${build_mode_suffix}}) # will be incompatible if a different exact version already required OR if another major version required OR if another minor version greater than the one of exact version
 
			if(IS_COMPATIBLE)
				if(NEED_REFIND)
					# OK installing the exact version instead
					#WARNING call to find package
					find_package(
						${dependency} 
						${${package}_DEPENDENCY_${dependency}_VERSION${build_mode_suffix}} 
						EXACT
						MODULE
						REQUIRED
						${${package}_DEPENDENCY_${dependency}_COMPONENTS${build_mode_suffix}}
					)
				endif()
				return()				
			else() #not compatible
				message(FATAL_ERROR "impossible to find compatible versions of dependent package ${dependency} regarding versions constraints. Search ended when trying to satisfy version coming from package ${package}. All required versions are : ${${dependency}_ALL_REQUIRED_VERSIONS}, Exact version already required is ${${dependency}_REQUIRED_VERSION_EXACT}, Last exact version required is ${${package}_DEPENDENCY_${dependency}_VERSION${build_mode_suffix}}.")
				return()
			endif()
		else()#not an exact version required
			is_Version_Compatible_With_Previous_Constraints (
					COMPATIBLE_VERSION VERSION_TO_FIND 
					${dependency} ${${package}_DEPENDENCY_${dependency}_VERSION${build_mode_suffix}})
			if(COMPATIBLE_VERSION)
				if(VERSION_TO_FIND)
					find_package(
						${dependency} 
						${VERSION_TO_FIND}
						MODULE
						REQUIRED
						${${package}_DEPENDENCY_${dependency}_COMPONENTS${build_mode_suffix}}
					)
				else()
					return() # nothing to do more, the current used version is compatible with everything 	
				endif()
			else()
				message(FATAL_ERROR "impossible to find compatible versions of dependent package ${dependency} regarding versions constraints. Search ended when trying to satisfy version coming from package ${package}. All required versions are : ${${dependency}_ALL_REQUIRED_VERSIONS}, Exact version already required is ${${dependency}_REQUIRED_VERSION_EXACT}, Last version required is ${${package}_DEPENDENCY_${dependency}_VERSION${build_mode_suffix}}.")
				return()
			endif()
		endif()
	else()
		return()#by default the version is compatible (no constraints) so return 
	endif()
else()#the dependency has not been already found
#	message("DEBUG resolve_Package_Dependency ${dependency} NOT FOUND !!")	
	if(${package}_DEPENDENCY_${dependency}_VERSION${build_mode_suffix})
		
		if(${package}_DEPENDENCY_${dependency}_VERSION_EXACT${build_mode_suffix}) #an exact version has been specified
			#WARNING recursive call to find package
			find_package(
				${dependency} 
				${${package}_DEPENDENCY_${dependency}_VERSION${build_mode_suffix}} 
				EXACT
				MODULE
				REQUIRED
				${${package}_DEPENDENCY_${dependency}_COMPONENTS${build_mode_suffix}}
			)

		else()
			#WARNING recursive call to find package
#			message("DEBUG before find : dep= ${dependency}, version = ${${package}_DEPENDENCY_${dependency}_VERSION${build_mode_suffix}}")
			find_package(
				${dependency} 
				${${package}_DEPENDENCY_${dependency}_VERSION${build_mode_suffix}} 
				MODULE
				REQUIRED
				${${package}_DEPENDENCY_${dependency}_COMPONENTS${build_mode_suffix}}
			)
		endif()
	else()
		find_package(
			${dependency} 
			MODULE
			REQUIRED
			${${package}_DEPENDENCY_${dependency}_COMPONENTS${build_mode_suffix}}
		)
	endif()
endif()

endfunction(resolve_Package_Dependency)


############################################################################
################ macros used to write cmake find scripts ###################
############################################################################
macro(exitFindScript package message_to_send)
	if(${package}_FIND_REQUIRED)
		message(SEND_ERROR ${message_to_send})#fatal error
		return()
	elseif(${package}_FIND_QUIETLY)
		return()#simply exitting
	else()
		message(STATUS ${message_to_send})#simple notification message
		return() 
	endif()
endmacro(exitFindScript)

macro(finding_Package package)
set(${package}_FOUND FALSE CACHE INTERNAL "")

#workspace dir must be defined for each package build
set(PACKAGE_${package}_SEARCH_PATH
    ${PACKAGE_BINARY_INSTALL_DIR}/${package}
    CACHE
    INTERNAL
    "path to the package install dir containing versions of the package : ${package}"
  )

check_Directory_Exists(EXIST ${PACKAGE_${package}_SEARCH_PATH})
if(EXIST)
	# at this stage the only thing to do is to check for versions

	#variables that will be filled by generic functions
	if(${package}_FIND_VERSION)
		if(${package}_FIND_VERSION_EXACT) #using a specific version (only patch number can be adapted, first searching if there is any local version matching constraints, otherwise search for a non local version)
			check_Exact_Version(VERSION_HAS_BEEN_FOUND "${package}" ${PACKAGE_${package}_SEARCH_PATH} ${${package}_FIND_VERSION_MAJOR} ${${package}_FIND_VERSION_MINOR})
		else() #using the best version as regard of version constraints (only non local version are used)
			check_Best_Version(VERSION_HAS_BEEN_FOUND "${package}" ${PACKAGE_${package}_SEARCH_PATH} ${${package}_FIND_VERSION_MAJOR} ${${package}_FIND_VERSION_MINOR})
		endif()
	else() #no specific version targetted using last available version (takes the last version available either local or non local - local first)
		check_Last_Version(VERSION_HAS_BEEN_FOUND "${package}" ${PACKAGE_${package}_SEARCH_PATH})
	endif()

	if(VERSION_HAS_BEEN_FOUND)#a good version of the package has been found
		set(PATH_TO_PACKAGE_VERSION ${PACKAGE_${package}_SEARCH_PATH}/${${package}_VERSION_RELATIVE_PATH})	
		if(${package}_FIND_COMPONENTS) #specific components must be checked, taking only selected components	
				
			select_Components(${package} ${${package}_VERSION_STRING} ${PATH_TO_PACKAGE_VERSION} "${${package}_FIND_COMPONENTS}")
			if(USE_FILE_NOTFOUND)
				exitFindScript("The selected version of ${package} (${${package}_VERSION_STRING}) has no configuration file or file is corrupted")
			endif()

			if(NOT ALL_REQUIRED_COMPONENTS_HAVE_BEEN_FOUND)
				exitFindScript("Some of the requested components of the package ${package} are missing (version chosen is ${${package}_VERSION_STRING}, requested is ${${package}_FIND_VERSION}),either bad names specified or broken package versionning")
			endif()	
		
		else()#no component check, register all of them
			all_Components("${package}" ${${package}_VERSION_STRING} ${PATH_TO_PACKAGE_VERSION})
			if(USE_FILE_NOTFOUND)
				exitFindScript("The  selected version of the-testpack-a (${${package}_VERSION_STRING}) has no configuration file or file is corrupted")
			endif(D)
				
		endif()

		#here everything has been found => setting global standard CMake find process variables to adequate values
		set(${package}_FOUND TRUE CACHE INTERNAL "")
		set(${package}_ROOT_DIR ${PATH_TO_PACKAGE_VERSION} CACHE INTERNAL "")
		set(${PROJECT_NAME}_ALL_USED_PACKAGES ${${PROJECT_NAME}_ALL_USED_PACKAGES} ${package} CACHE INTERNAL "")
		if(${package}_FIND_VERSION)
			if(${package}_FIND_VERSION_EXACT)
				set(${package}_ALL_REQUIRED_VERSIONS CACHE INTERNAL "") #unset all the other required version
				set(${package}_REQUIRED_VERSION_EXACT "${${package}_FIND_VERSION_MAJOR}.${${package}_FIND_VERSION_MINOR}" CACHE INTERNAL "")
			else()
				set(${package}_ALL_REQUIRED_VERSIONS ${${package}_ALL_REQUIRED_VERSIONS} "${${package}_FIND_VERSION_MAJOR}.${${package}_FIND_VERSION_MINOR}" CACHE INTERNAL "")	
			endif()
		else()
			set(${package}_ALL_REQUIRED_VERSIONS CACHE INTERNAL "") #unset all the other required version
			set(${package}_REQUIRED_VERSION_EXACT CACHE INTERNAL "") #unset the exact required version	
		endif()
		
	else()#no adequate version found
		if(REQUIRED_PACKAGES_AUTOMATIC_DOWNLOAD)
			if(${package}_FIND_REQUIRED)
				if(${package}_FIND_VERSION)
					add_To_Install_Package_Specification(${package} "${${package}_FIND_VERSION_MAJOR}.${${package}_FIND_VERSION_MINOR}" ${${package}_FIND_VERSION_EXACT})
				else()
					add_To_Install_Package_Specification(${package} "" FALSE)
				endif()
			endif()
		else()
			exitFindScript("The package ${package} with version ${${package}_FIND_VERSION} cannot be found in the workspace")
		endif()
	endif()
else() #if the directory does not exist it means the package cannot be found
	if(REQUIRED_PACKAGES_AUTOMATIC_DOWNLOAD)
		if(${package}_FIND_REQUIRED)
			if(${package}_FIND_VERSION)
				add_To_Install_Package_Specification(${package} "${${package}_FIND_VERSION_MAJOR}.${${package}_FIND_VERSION_MINOR}" ${${package}_FIND_VERSION_EXACT})
			else()
				add_To_Install_Package_Specification(${package} "" FALSE)
			endif()
		endif()
	else()
		exitFindScript("The required package ${package} cannot be found in the workspace")
	endif()

endif()

endmacro(finding_Package)
