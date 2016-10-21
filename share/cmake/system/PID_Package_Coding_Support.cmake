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



### generating test coverage reports for the package
function(generate_Coverage)

if(${CMAKE_BUILD_TYPE} MATCHES Debug) # coverage is well generated in debug mode

	if(NOT BUILD_COVERAGE_REPORT)
		return()
	endif()

	find_program( GCOV_PATH gcov ) # for generating coverage traces
	find_program( LCOV_PATH lcov ) # for generating HTML coverage reports
	find_program( GENHTML_PATH genhtml ) #for generating HTML
	mark_as_advanced(GCOV_PATH LCOV_PATH GENHTML_PATH)

	if(NOT GCOV_PATH)
		message("[PID] WARNING : gcov not found please install it to generate coverage reports.")
	endif()

	if(NOT LCOV_PATH)
		message("[PID] WARNING : lcov not found please install it to generate coverage reports.")
	endif()

	if(NOT GENHTML_PATH)
		message("[PID] WARNING : genhtml not found please install it to generate coverage reports.")
	endif()

	if(NOT GCOV_PATH OR NOT LCOV_PATH OR NOT GENHTML_PATH)
		set(BUILD_COVERAGE_REPORT OFF FORCE)
	endif()

	# CHECK VALID COMPILER
	if("${CMAKE_CXX_COMPILER_ID}" MATCHES "(Apple)?[Cc]lang")
		if("${CMAKE_CXX_COMPILER_VERSION}" VERSION_LESS 3)
			message("[PID] WARNING : Clang version must be 3.0.0 or greater to generate coverage reports")
			set(BUILD_COVERAGE_REPORT OFF FORCE)
		endif()
	elseif(NOT CMAKE_COMPILER_IS_GNUCXX)
		message("[PID] WARNING : not a gnu C/C++ compiler, impossible to generate coverage reports.")
		set(BUILD_COVERAGE_REPORT OFF FORCE)
	endif() 
endif()

if(BUILD_COVERAGE_REPORT AND PROJECT_RUN_TESTS)
	
	set(CMAKE_CXX_FLAGS_DEBUG  "-g -O0 --coverage -fprofile-arcs -ftest-coverage" CACHE STRING "Flags used by the C++ compiler during coverage builds." FORCE)
	set(CMAKE_C_FLAGS_DEBUG  "-g -O0 --coverage -fprofile-arcs -ftest-coverage" CACHE STRING "Flags used by the C compiler during coverage builds." FORCE)
	set(CMAKE_EXE_LINKER_FLAGS_DEBUG "--coverage" CACHE STRING "Flags used for linking binaries during coverage builds." FORCE)
	set(CMAKE_SHARED_LINKER_FLAGS_DEBUG "--coverage" CACHE STRING "Flags used by the shared libraries linker during coverage builds."  FORCE)
	mark_as_advanced(CMAKE_CXX_FLAGS_DEBUG CMAKE_C_FLAGS_DEBUG CMAKE_EXE_LINKER_FLAGS_DEBUG CMAKE_SHARED_LINKER_FLAGS_DEBUG)

	if(${CMAKE_BUILD_TYPE} MATCHES Debug)
	
		set(coverage_info "${CMAKE_BINARY_DIR}/lcovoutput.info")
		set(coverage_cleaned "${CMAKE_BINARY_DIR}/lcovoutput.cleaned")
		set(coverage_dir "${CMAKE_BINARY_DIR}/lcovoutput")
	
		# Setup coverage target
		add_custom_target(coverage
                  
			COMMAND ${LCOV_PATH} --directory ${CMAKE_BINARY_DIR} --zerocounters #prepare coverage generation
			
			COMMAND ${CMAKE_MAKE_PROGRAM} test ${PARALLEL_JOBS_FLAG} # Run tests 

			COMMAND ${LCOV_PATH} --directory ${CMAKE_BINARY_DIR} --capture --output-file ${coverage_info}
			COMMAND ${LCOV_PATH} --remove ${coverage_info} 'test/*' '/usr/*' 'external/*' 'install/*' --output-file ${coverage_cleaned} #configure the filter of output (remove everything that is not related to
			COMMAND ${GENHTML_PATH} -o ${coverage_dir} ${coverage_cleaned} #generating output
			COMMAND ${CMAKE_COMMAND} -E remove ${coverage_info} ${coverage_cleaned} #cleanup lcov files

			WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
			COMMENT "Generating code coverage report."
		)

	endif()
else() #no coverage wanted or possible (no test defined), create a do nothing rule for coverage
	if(BUILD_COVERAGE_REPORT AND ${CMAKE_BUILD_TYPE} MATCHES Debug) #create a do nothing target when no run is possible on coverage
		add_custom_target(coverage  
			COMMAND ${CMAKE_COMMAND} -E echo "[PID] WARNING : no coverage to perform !!"
			WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
		)
	endif()
	set(CMAKE_CXX_FLAGS_DEBUG  "-g" CACHE STRING "Flags used by the C++ compiler during coverage builds." FORCE)
	set(CMAKE_C_FLAGS_DEBUG  "-g" CACHE STRING "Flags used by the C compiler during coverage builds." FORCE)
	set(CMAKE_EXE_LINKER_FLAGS_DEBUG "" CACHE STRING "Flags used for linking binaries during coverage builds." FORCE)
	set(CMAKE_SHARED_LINKER_FLAGS_DEBUG "" CACHE STRING "Flags used by the shared libraries linker during coverage builds."  FORCE)
	mark_as_advanced(CMAKE_CXX_FLAGS_DEBUG CMAKE_C_FLAGS_DEBUG CMAKE_EXE_LINKER_FLAGS_DEBUG CMAKE_SHARED_LINKER_FLAGS_DEBUG)

endif()
endfunction(generate_Coverage)


### generating static code checking reports for the package

### target configuration for cppcheck
function(add_StaticCheck component)

if(BUILD_STATIC_CODE_CHECKING_REPORT AND ${CMAKE_BUILD_TYPE} MATCHES Release)
	if(NOT TARGET ${component})
		message(FATAL_ERROR "[PID] CRITICAL ERROR: unknown target name ${component} when trying to cppcheck !")
	endif()
	
	get_target_property(SOURCES_TO_CHECK "${component}" SOURCES)
	set(files_to_check)
	foreach(source_file ${SOURCES_TO_CHECK}) #listing all cpp source files of the target
		get_source_file_property(CHECK_LANG "${source_file}" LANGUAGE)
		if("${CHECK_LANG}" MATCHES "CXX")
			get_source_file_property(CHECK_LOC "${source_file}" LOCATION)
			list(APPEND files_to_check "${CHECK_LOC}")
		endif()
	endforeach()

	if(BUILD_AND_RUN_TESTS) #adding a test target to check for errors
		add_test(NAME ${component}_cppcheck_test
			 COMMAND "${CPPCHECK_EXECUTABLE}" ${CPPCHECK_ARGS} ${files_to_check})
		set_tests_properties(${component}_cppcheck_test PROPERTIES FAIL_REGULAR_EXPRESSION " error: ")
	endif()

	#adding the output 
	add_custom_command(TARGET all_cppcheck
		PRE_BUILD
		COMMAND ${CPPCHECK_EXECUTABLE} --quiet ${CPPCHECK_ARGS} ${files_to_check}
		WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
		COMMENT
		"${component}_cppcheck: Running cppcheck on target ${component}..."
		VERBATIM)
endif()

endfunction(add_StaticCheck)

##global configuration function
function(generate_Static_Checks)

if(BUILD_STATIC_CODE_CHECKING_REPORT AND ${CMAKE_BUILD_TYPE} MATCHES Release)

	# cppcheck app bundles on Mac OS X are GUI, we want command line only
	set(_oldappbundlesetting ${CMAKE_FIND_APPBUNDLE})
	set(CMAKE_FIND_APPBUNDLE NEVER)
	find_program(CPPCHECK_EXECUTABLE NAMES cppcheck)

	# Restore original setting for appbundle finding
	set(CMAKE_FIND_APPBUNDLE ${_oldappbundlesetting})

	#trying to find the cpp check executable
	find_program(CPPCHECK_EXECUTABLE NAMES cppcheck)
	mark_as_advanced(CPPCHECK_EXECUTABLE)

	# Restore original setting for appbundle finding
	set(CMAKE_FIND_APPBUNDLE ${_oldappbundlesetting})

	if(CPPCHECK_EXECUTABLE) #TODO maybe setting args according to the component type (e.g. unsued function for library is normal)
		set(CPPCHECK_ARGS "--template=\"file {file} line {line};;[{severity};;{id}]:{message}\" --enable=all" CACHE INTERNAL "")
	else()	
		message(STATUS "[PID] WARNING: cppcheck not found, forcing option BUILD_STATIC_CODE_CHECKING_REPORT to OFF.")
		set(BUILD_STATIC_CODE_CHECKING_REPORT OFF FORCE)	
	endif()

endif()
endfunction(generate_Static_Checks)

