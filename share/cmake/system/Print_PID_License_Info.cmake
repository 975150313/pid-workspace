list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/system)
list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/references)
list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/licenses)

include(Workspace_Internal_Functions)

if(REQUIRED_LICENSE)
	include(${WORKSPACE_DIR}/share/cmake/licenses/License${REQUIRED_LICENSE}.cmake OPTIONAL RESULT_VARIABLE REQUIRED_STATUS)
	if(REQUIRED_STATUS STREQUAL NOTFOUND)
		message("ERROR : License name ${REQUIRED_LICENSE} does not refer to any known license in the workspace")
		return()
	endif()
	print_License_Info(${REQUIRED_LICENSE})

else()
	print_Available_Licenses()
endif()


