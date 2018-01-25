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

######################################################################
############# function related to git tool configuration #############
######################################################################

###
function(configure_Git)
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR} git --version OUTPUT_VARIABLE version_string)
string(REGEX REPLACE "^[^0-9]*([0-9]+\\.[0-9]+\\.[0-9]+).*$" "\\1" VERSION ${version_string})
if(VERSION STREQUAL ${version_string})
	message("[PID] WARNING : cannot determine version of git")
	set(GIT_VERSION CACHE INTERNAL "" FORCE)
else()
	set(GIT_VERSION ${VERSION} CACHE INTERNAL "" FORCE)
endif()
endfunction(configure_Git)

###
function(git_Provides_GETURL RESULT)

if(GIT_VERSION AND NOT (GIT_VERSION VERSION_LESS 2.7.0))
	set(${RESULT} TRUE PARENT_SCOPE)
else()
	set(${RESULT} FALSE PARENT_SCOPE)
endif()

endfunction(git_Provides_GETURL)

######################################################################
############# function used to navigate between branches #############
######################################################################

###
function(go_To_Integration package)
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git checkout integration
		OUTPUT_QUIET ERROR_QUIET)
endfunction(go_To_Integration)

###
function(go_To_Master package)
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git checkout master
		OUTPUT_QUIET ERROR_QUIET)
endfunction(go_To_Master)

###
function(go_To_Workspace_Master)
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR} git checkout master
		OUTPUT_QUIET ERROR_QUIET)
endfunction(go_To_Workspace_Master)

###
function(go_To_Workspace_Development)
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR} git checkout development
		OUTPUT_QUIET ERROR_QUIET)
endfunction(go_To_Workspace_Development)

###
function(go_To_Commit repo branch)
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${repo} git checkout ${branch}
		OUTPUT_QUIET ERROR_QUIET)
endfunction(go_To_Commit)

###
function(go_To_Version package version)
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git checkout tags/v${version}
		OUTPUT_QUIET ERROR_QUIET)
endfunction(go_To_Version)


###
function(get_Repository_Version_Tags AVAILABLE_VERSIONS package)
set(${AVAILABLE_VERSIONS} PARENT_SCOPE)
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git tag -l v*
		OUTPUT_VARIABLE res)

if(NOT res) #no version available => BUG
	return()
endif()
string(REPLACE "\n" ";" GIT_VERSIONS ${res})
set(${AVAILABLE_VERSIONS} ${GIT_VERSIONS} PARENT_SCOPE)
endfunction(get_Repository_Version_Tags)

###
function(normalize_Version_Tags VERSION_NUMBERS VERSIONS_TAGS)
foreach(tag IN ITEMS ${VERSIONS_TAGS})
	string(REGEX REPLACE "^v(.*)$" "\\1" VNUMBERS ${tag})
	list(APPEND result ${VNUMBERS})
endforeach()
set(${VERSION_NUMBERS} ${result} PARENT_SCOPE)
endfunction(normalize_Version_Tags)


###
function(get_Repository_Current_Branch BRANCH_NAME repo)
set(${BRANCH_NAME} PARENT_SCOPE)
execute_process(COMMAND git rev-parse --abbrev-ref HEAD
		WORKING_DIRECTORY ${repo}
		OUTPUT_VARIABLE current_branch ERROR_QUIET)
if(current_branch
	AND NOT current_branch STREQUAL ""
AND NOT current_branch MATCHES HEAD)
	string(REGEX REPLACE "^[ \t\n]*([^ \t\n]+)[ \t\n]*$" "\\1" RES_BRANCH ${current_branch})
	set(${BRANCH_NAME} ${RES_BRANCH} PARENT_SCOPE)
endif()
endfunction(get_Repository_Current_Branch)


###
function(get_Repository_Current_Commit COMMIT_NAME repo)
set(${COMMIT_NAME} PARENT_SCOPE)
execute_process(COMMAND git log -n 1
		WORKING_DIRECTORY ${repo}
		OUTPUT_VARIABLE last_log ERROR_QUIET)
string(REPLACE "\n" ";" LINES "${last_log}")
string(REGEX REPLACE "^commit ([^;]+).*$" "\\1" SHA1_ID ${LINES})
set(${COMMIT_NAME} ${SHA1_ID} PARENT_SCOPE)
endfunction(get_Repository_Current_Commit)


###
function(save_Repository_Context INITIAL_COMMIT SAVED_CONTENT package)
get_Repository_Current_Branch(BRANCH_NAME ${WORKSPACE_DIR}/packages/${package})
if(NOT BRANCH_NAME)
	get_Repository_Current_Commit(COMMIT_NAME ${WORKSPACE_DIR}/packages/${package})
	set(CONTEXT ${COMMIT_NAME})
else()
	set(CONTEXT ${BRANCH_NAME})
endif()
set(${INITIAL_COMMIT} ${CONTEXT} PARENT_SCOPE)
has_Modifications(RESULT ${package})
if(RESULT)
	execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git stash save --include-untracked OUTPUT_QUIET ERROR_QUIET)
	set(${SAVED_CONTENT} TRUE PARENT_SCOPE)
else()
	set(${SAVED_CONTENT} FALSE PARENT_SCOPE)
endif()
endfunction(save_Repository_Context)

###
function(restore_Repository_Context package initial_commit saved_content)
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git reset --hard
		COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git clean -ff -d
		OUTPUT_QUIET ERROR_QUIET)#this is a mandatory step due to the generation of versionned files in source dir when build takes place (this should let the repository in same state as initially)

go_To_Commit(${WORKSPACE_DIR}/packages/${package} ${initial_commit})
if(saved_content)
	execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git stash pop OUTPUT_QUIET ERROR_QUIET)
endif()
endfunction(restore_Repository_Context)


###
function(save_Workspace_Repository_Context INITIAL_COMMIT SAVED_CONTENT)
get_Repository_Current_Branch(BRANCH_NAME ${WORKSPACE_DIR})
if(NOT BRANCH_NAME)
	get_Repository_Current_Commit(COMMIT_NAME ${WORKSPACE_DIR})
	set(CONTEXT ${COMMIT_NAME})
else()
	set(CONTEXT ${BRANCH_NAME})
endif()
set(${INITIAL_COMMIT} ${CONTEXT} PARENT_SCOPE)
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR} git status --porcelain OUTPUT_VARIABLE res_out ERROR_QUIET)
if(NOT res_out)# no modification to stage or commit
	set(${SAVED_CONTENT} FALSE PARENT_SCOPE)
else()
	execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR} git stash save --include-untracked OUTPUT_QUIET ERROR_QUIET)
	set(${SAVED_CONTENT} TRUE PARENT_SCOPE)
endif()
endfunction(save_Workspace_Repository_Context)

###
function(restore_Workspace_Repository_Context initial_commit saved_content)
go_To_Commit(${WORKSPACE_DIR} ${initial_commit})
if(saved_content)
	execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR} git stash pop OUTPUT_QUIET ERROR_QUIET)
endif()
endfunction(restore_Workspace_Repository_Context)

######################################################################
############# function used to merge standard branches ###############
######################################################################

###
function(merge_Into_Master RESULT package version_string)
go_To_Master(${package})
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git merge --ff-only integration RESULT_VARIABLE res OUTPUT_QUIET ERROR_QUIET)
if(NOT res EQUAL 0)
	set(${RESULT} FALSE PARENT_SCOPE)
	return()
endif()
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git tag -a v${version_string} -m "releasing version ${version_string}")
set(${RESULT} TRUE PARENT_SCOPE)
endfunction(merge_Into_Master)

###
function(merge_Into_Integration package)
go_To_Integration(${package})
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git merge --ff-only master)
endfunction(merge_Into_Integration)

###
function(integrate_Branch package branch)
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git merge ${branch} OUTPUT_QUIET ERROR_QUIET)
endfunction(integrate_Branch)

###
function(commit_Current_Repository_Branch package commit_message)
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git add --all)
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git commit -m "${commit_message}")
endfunction(commit_Current_Repository_Branch)


### registering the address means registering the CMakelists.txt
function(register_Repository_Address package)
go_To_Integration(${package})
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git add CMakeLists.txt)
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git commit -m "adding repository address to the root CMakeLists.txt file")
endfunction(register_Repository_Address)

###
function(register_Repository_Version package version_string)
go_To_Integration(${package})
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git add CMakeLists.txt)
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git commit -m "[skip ci] start new version ${version_string}")
endfunction(register_Repository_Version)

#############################################################################
############# function used to publish/update modifications   ###############
#############################################################################

###
function(publish_Package_References_In_Workspace_Repository package)
if(EXISTS ${WORKSPACE_DIR}/share/cmake/find/Find${package}.cmake AND EXISTS ${WORKSPACE_DIR}/share/cmake/references/Refer${package}.cmake)
	execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR} git add share/cmake/find/Find${package}.cmake OUTPUT_QUIET ERROR_QUIET)
	execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR} git add share/cmake/references/Refer${package}.cmake OUTPUT_QUIET ERROR_QUIET)
	execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR} git commit -m "${package} registered" OUTPUT_QUIET ERROR_QUIET)
	execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR} git push origin master OUTPUT_QUIET ERROR_QUIET)
else()
	message("[PID] ERROR : problem registering package ${package}, cannot find adequate cmake files in workspace.")
endif()
endfunction(publish_Package_References_In_Workspace_Repository)


###
function(publish_Framework_References_In_Workspace_Repository framework)
if(EXISTS ${WORKSPACE_DIR}/share/cmake/references/ReferFramework${framework}.cmake)
	execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR} git add share/cmake/references/ReferFramework${framework}.cmake OUTPUT_QUIET ERROR_QUIET)
	execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR} git commit -m "framework ${framework} registered" OUTPUT_QUIET ERROR_QUIET)
	execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR} git push origin master OUTPUT_QUIET ERROR_QUIET)
else()
	message("[PID] ERROR : problem registering framework ${framework}, cannot find adequate cmake files in workspace.")
endif()
endfunction(publish_Framework_References_In_Workspace_Repository)

###
function(update_Workspace_Repository remote)
go_To_Workspace_Master()
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR} git pull ${remote} master)#pulling master branch of origin or official
endfunction(update_Workspace_Repository)


###
function(publish_Repository_Integration package)
go_To_Integration(${package})
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git push origin integration OUTPUT_QUIET ERROR_QUIET)#try pushing on integration branch

#now testing if everything is OK using the git log command
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git log --oneline --decorate --max-count=1 OUTPUT_VARIABLE res ERROR_QUIET)
if (NOT "${res}" STREQUAL "")
	string(FIND "${res}" "integration" INDEX_LOCAL)
	string(FIND "${res}" "origin/integration" INDEX_REMOTE)
	if(INDEX_LOCAL GREATER 0 AND INDEX_REMOTE GREATER 0)# both found => the last commit on integration branch is tracked by local and remote integration branches
		return()
	else()
		message("[PID] WARNING : problem updating package ${package} integration branch on its origin remote. Maybe due to a conflict between local and origin integration branches.")
	endif()
endif()
endfunction(publish_Repository_Integration)


###
function(publish_Repository_Version package version_string RESULT)
go_To_Master(${package})
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git push --porcelain official master OUTPUT_VARIABLE out ERROR_QUIET)#releasing on master branch of official
if(out MATCHES "^.*rejected.*$")
	set(${RESULT} FALSE PARENT_SCOPE)
	return()
endif()

#now testing if everything is OK using the git log command
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git log --oneline --decorate --max-count=1 OUTPUT_VARIABLE res ERROR_QUIET)
if (NOT "${res}" STREQUAL "")
	string(FIND "${res}" "master" INDEX_LOCAL)
	string(FIND "${res}" "official/master" INDEX_REMOTE)
	if(INDEX_LOCAL GREATER 0 AND INDEX_REMOTE GREATER 0)# both found => the last commit on master branch is tracked by local and remote master branch
		set(OFFICIAL_SYNCHRO TRUE)
	else()
		set(OFFICIAL_SYNCHRO FALSE)
	endif()
endif()
if(OFFICIAL_SYNCHRO)
	execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git push official v${version_string} OUTPUT_QUIET ERROR_QUIET)#releasing version tag
	set(${RESULT} TRUE PARENT_SCOPE)
else()
	set(${RESULT} FALSE PARENT_SCOPE)
endif()
endfunction(publish_Repository_Version)

###
function(test_Remote_Connection CONNECTED package remote)
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git remote show ${remote} OUTPUT_QUIET ERROR_QUIET RESULT_VARIABLE res)
if(res EQUAL 0)
	set(${CONNECTED} TRUE PARENT_SCOPE)
else()
	set(${CONNECTED} FALSE PARENT_SCOPE)
endif()
endfunction(test_Remote_Connection)

### DONE here manage PUBLIC ACCESS repositories
function(update_Repository_Versions RESULT package)
go_To_Master(${package})
is_Package_Connected(CONNECTED ${package} official) #check if the package has a repository URL defined (fetch)
get_Package_Repository_Address(${package} URL PUBLIC_URL)
if(NOT CONNECTED)#no official remote (due to old package style or due to a misuse of git command within a package)
	if(URL AND NOT URL STREQUAL "")
		if(PUBLIC_URL AND NOT PUBLIC_URL STREQUAL "")#the package has a public address where anyone can get it
			execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git remote add official ${PUBLIC_URL} ERROR_QUIET OUTPUT_QUIET)
			execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git remote set-url --push official ${URL} ERROR_QUIET OUTPUT_QUIET)
			message("[PID] WARNING : package ${package} has no official remote defined (malformed package), set it to ${URL} (for push) and ${PUBLIC_URL} (for fetch).")
		else() #default situation
			execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git remote add official ${URL} ERROR_QUIET OUTPUT_QUIET)
			message("[PID] WARNING : package ${package} has no official remote defined (malformed package), set it to ${URL}.")
		endif()
	else() #no official repository and no URL defined for the package => the package has never been connected (normal situation)
		set(${RESULT} FALSE PARENT_SCOPE)
		return()
	endif()
elseif(URL AND NOT URL STREQUAL "") # official package is connected
	get_Remotes_Address(${package} RES_OFFICIAL RES_ORIGIN)#get the adress of the official git remote
	if(NOT RES_OFFICIAL STREQUAL URL AND NOT RES_OFFICIAL STREQUAL PUBLIC_URL) #the address of official is not the same as the one specified in the package description
		if(PUBLIC_URL AND NOT PUBLIC_URL STREQUAL "")#the package has a public address where anyone can get it
			execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git remote set-url official ${PUBLIC_URL} ERROR_QUIET OUTPUT_QUIET)
			execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git remote set-url --push official ${URL} ERROR_QUIET OUTPUT_QUIET)
			message("[PID] WARNING : local package ${package} official remote defined in package description (push=${URL} fetch=${PUBLIC_URL}) differs from the one defined by git (${RES_OFFICIAL}) ! Use the one defined in pakage description !")
		else() #default situation
			execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git remote set-url official ${URL} ERROR_QUIET OUTPUT_QUIET)
			execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git remote set-url --push official ${URL} ERROR_QUIET OUTPUT_QUIET)
			message("[PID] WARNING : local package ${package} official remote defined in package description (${URL}) differs from the one defined by git (${RES_OFFICIAL}) ! Use the one defined in pakage description !")
		endif()
	else()#package remotes are consistent, but this can be an old version of the package before a migration occurred
		test_Remote_Connection(CONNECTED ${package} official)
		if(NOT CONNECTED) #problem if not connected a migration occurred, we have to update everything
			include(${WORKSPACE_DIR}/share/cmake/references/Refer${package}.cmake OPTIONAL RESULT_VARIABLE res)
			if(res STREQUAL NOTFOUND) #reference not found, may mean the package has been removed
				message("[PID] WARNING : local package ${package} cannot update from its official remote and is not know into workspace, aborting its update ! Please check that the package still exists or try upgrading your workspace.")
				set(${RESULT} FALSE PARENT_SCOPE) #simply exitting
				return()
			endif()
			#from here the package is known and its reference related variables have been updated
			if (${package}_PUBLIC_ADDRESS STREQUAL RES_OFFICIAL
				OR ${package}_ADDRESS STREQUAL RES_OFFICIAL)#OK so no problem detected but cannot interact with the remote repository
				message("[PID] WARNING : local package ${package} cannot be update from its official remote, aborting its update ! Please check your connection.")
				set(${RESULT} FALSE PARENT_SCOPE) #simply exitting
				return()
			else() #for now only updating the official remote address so that update can occur
				if(PUBLIC_URL AND NOT PUBLIC_URL STREQUAL "")#the package has a public address where anyone can get it
					execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git remote set-url official ${${package}_PUBLIC_ADDRESS} ERROR_QUIET OUTPUT_QUIET)
					execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git remote set-url --push official ${${package}_ADDRESS} ERROR_QUIET OUTPUT_QUIET)
					message("[PID] WARNING : local package ${package} official remote defined in package description (push=${${package}_ADDRESS}, fetch=${${package}_PUBLIC_ADDRESS}) differs from the one defined by git (${RES_OFFICIAL}) ! Use the one defined in pakage description !")
				else() #default situation
					execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git remote set-url official ${${package}_ADDRESS} ERROR_QUIET OUTPUT_QUIET)
					execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git remote set-url --push official ${${package}_ADDRESS} ERROR_QUIET OUTPUT_QUIET)
					message("[PID] WARNING : local package ${package} official remote defined in package description (${${package}_ADDRESS}) differs from the one defined by git (${RES_OFFICIAL}) ! Use the one defined in pakage description !")
				endif()
				# once the update will be done the official address in description should have changed accordingly
			endif()
		endif()
	endif()
else() # PROBLEM: no URL defined in description !!
	message("[PID] WARNING : local package ${package} has no official remote defined while an official remote is defined by git ! This is an uncoherent package state !")
	set(${RESULT} FALSE PARENT_SCOPE)
endif()
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git fetch official --tags  OUTPUT_QUIET ERROR_QUIET)#getting new tags
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git pull --ff-only official master RESULT_VARIABLE res OUTPUT_QUIET ERROR_QUIET)#pulling master branch of official
if(NOT res EQUAL 0)#not a fast forward !! => there is a problem
	message("[PID] WARNING : local package ${package} master branch and corresponding branch in official repository have diverge ! If you committed no modification to the local master branch (use gitk or git log to see that), ask to the administrator of this repository to solve the problem !")
	set(${RESULT} FALSE PARENT_SCOPE)
	return()
endif()
set(${RESULT} TRUE PARENT_SCOPE)
endfunction(update_Repository_Versions)

###
function(update_Remotes package)
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git fetch official OUTPUT_QUIET ERROR_QUIET)#fetching official
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git fetch origin OUTPUT_QUIET ERROR_QUIET)#fetching origin
endfunction(update_Remotes package)

######################################################################
############################ other functions #########################
######################################################################

### to know wether a package has modifications on its current branch
function(has_Modifications RESULT package)
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git status --porcelain OUTPUT_VARIABLE res_out ERROR_QUIET)
if(NOT res_out)# no modification to stage or commit
	set(${RESULT} FALSE PARENT_SCOPE)
else()#there are modification
	set(${RESULT} TRUE PARENT_SCOPE)
endif()
endfunction(has_Modifications)

### to know wether a package has interesting commits that may be part of a release
function(check_For_New_Commits_To_Release RESULT package)
go_To_Integration(${package})
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git log --oneline --decorate --max-count=2 OUTPUT_VARIABLE res ERROR_QUIET)
if (NOT "${res}" STREQUAL "")
	string(REPLACE " " "%" GIT_LOGS ${res})
	string(REPLACE "\t" "%" GIT_LOGS ${GIT_LOGS})
	string(REGEX REPLACE "^(.+)\n$" "\\1" GIT_LOGS ${GIT_LOGS})
	string(REPLACE "\n" ";" GIT_LOGS ${GIT_LOGS})
	list(LENGTH GIT_LOGS SIZE)
	if(SIZE GREATER 1)
		list(GET GIT_LOGS 1 LINE2)
		string(FIND "${LINE2}" "%master" INDEX_MAS)
		if(INDEX_MAS EQUAL -1)# master not found in two last lines starting from integration
			set(${RESULT} TRUE PARENT_SCOPE) #master is more than 1 commit away from integration
			return()
		endif()
	endif()
endif()
set(${RESULT} FALSE PARENT_SCOPE)
endfunction(check_For_New_Commits_To_Release)

### to know whether a package as a remote or not
## the connection is tested only on fetch address
function(is_Package_Connected CONNECTED package remote)
	git_Provides_GETURL(RESULT)
	if(RESULT)
		execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git remote get-url ${remote} OUTPUT_VARIABLE out RESULT_VARIABLE res)
		if(NOT res AND NOT out STREQUAL "")
			set(${CONNECTED} TRUE PARENT_SCOPE)
		else()
			set(${CONNECTED} FALSE PARENT_SCOPE)
		endif()
		return()
	else()
		execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git remote -v OUTPUT_VARIABLE out RESULT_VARIABLE res)
		if(NOT res AND NOT out STREQUAL "")
			string(REPLACE "${remote}" "found" IS_FOUND ${out})
			if(NOT IS_FOUND STREQUAL ${out})
				set(${CONNECTED} TRUE PARENT_SCOPE)
				return()
			endif()
		endif()
		set(${CONNECTED} FALSE PARENT_SCOPE)
		return()
	endif()
endfunction(is_Package_Connected)

### function called when deploying a package from reference files
function(clone_Repository IS_DEPLOYED package url)
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages git clone ${url})
if(EXISTS ${WORKSPACE_DIR}/packages/${package} AND IS_DIRECTORY ${WORKSPACE_DIR}/packages/${package})
	set(${IS_DEPLOYED} TRUE PARENT_SCOPE)
	execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git fetch origin OUTPUT_QUIET ERROR_QUIET)
	execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git checkout integration OUTPUT_QUIET ERROR_QUIET)#go to integration to create the local branch
	execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git checkout master OUTPUT_QUIET ERROR_QUIET)#go back to master by default

	# now adding reference to official remote with official == origin (default case)
	execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git remote add official ${url})
	execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git fetch official OUTPUT_QUIET ERROR_QUIET) #updating remote branches for official remote
else()
	set(${IS_DEPLOYED} FALSE PARENT_SCOPE)
	message("[PID] ERROR : impossible to clone the repository of package ${package} (bad repository address or you have no clone rights for this repository). Please contact the administrator of this package.")
endif()
endfunction(clone_Repository)

function(initialize_Git_Repository_Push_Address package url)
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git remote set-url --push origin ${url})
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git remote set-url --push official ${url})
endfunction(initialize_Git_Repository_Push_Address)

### testing if the repository is inialized (from git point of view) according to PID standard (basically it has an integration branch)
function(test_Package_Remote_Initialized package url INITIALIZED)
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/pid git clone ${url} OUTPUT_QUIET ERROR_QUIET) #cloning in a temporary area

execute_process(COMMAND git branch -a
		WORKING_DIRECTORY ${WORKSPACE_DIR}/pid/${package}
		OUTPUT_VARIABLE all_branches ERROR_QUIET)#getting all branches

if(all_branches AND NOT all_branches STREQUAL "")
	string(REPLACE "\n" ";" GIT_BRANCHES ${all_branches})
	set(INTEGRATION_FOUND FALSE)
	foreach(branch IN ITEMS ${GIT_BRANCHES})#checking that the origin/integration branch exists
		string(REGEX REPLACE "^[ \t]*remotes/(origin/integration)[ \t]*$" "\\1" A_BRANCH ${branch})
		if(NOT branch STREQUAL "${A_BRANCH}")#i.e. match found (this is the origin integration branch)
			set(INTEGRATION_FOUND TRUE)
			break()
		endif()
	endforeach()

	set(${INITIALIZED} ${INTEGRATION_FOUND} PARENT_SCOPE)
else()
	set(${INITIALIZED} FALSE PARENT_SCOPE)
endif()
	execute_process(COMMAND ${CMAKE_COMMAND} -E remove_directory ${WORKSPACE_DIR}/pid/${package} OUTPUT_QUIET ERROR_QUIET)
endfunction(test_Package_Remote_Initialized)


### testing if the repository is inialized (from git point of view) according to PID standard (basically it has an integration branch)
function(test_Remote_Initialized repository url INITIALIZED)
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/pid git clone ${url} OUTPUT_QUIET ERROR_QUIET) #cloning in a temporary area

execute_process(COMMAND git branch -a
		WORKING_DIRECTORY ${WORKSPACE_DIR}/pid/${repository}
		OUTPUT_VARIABLE all_branches ERROR_QUIET)#getting all branches

if(all_branches AND NOT all_branches STREQUAL "")#the repository must have branches to be initialized
	set(${INITIALIZED} TRUE PARENT_SCOPE)
else()
	set(${INITIALIZED} FALSE PARENT_SCOPE)
endif()
	execute_process(COMMAND ${CMAKE_COMMAND} -E remove_directory ${WORKSPACE_DIR}/pid/${repository} OUTPUT_QUIET ERROR_QUIET)
endfunction(test_Remote_Initialized)

### create a repository with no official remote specified (for now)
function(init_Repository package)
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git init OUTPUT_QUIET ERROR_QUIET)
#otherwise we need to initialize the system
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git add -A  OUTPUT_QUIET ERROR_QUIET)
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git commit -m "initialization of package done" OUTPUT_QUIET ERROR_QUIET)
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git tag -a v0.0.0 -m "creation of package" OUTPUT_QUIET ERROR_QUIET)
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git checkout -b integration master  OUTPUT_QUIET ERROR_QUIET)
endfunction(init_Repository)

### first time the package is connected after its creation
function(connect_Repository package url)
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git remote add origin ${url})
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git remote add official ${url})

execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git push origin integration  OUTPUT_QUIET ERROR_QUIET)

go_To_Master(${package})
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git push origin master  OUTPUT_QUIET ERROR_QUIET)

execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git push origin --tags OUTPUT_QUIET ERROR_QUIET)

execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git fetch official)
endfunction(connect_Repository)

### rare use function: when official repository has moved
function(reconnect_Repository package url)
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git remote set-url official ${url})
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git remote set-url --push official ${url})
go_To_Master(${package})
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git pull official master)#updating master
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git fetch official --tags  OUTPUT_QUIET ERROR_QUIET)
go_To_Integration(${package})
endfunction(reconnect_Repository)


###
function(reconnect_Repository_Remote package url public_url remote_name)
	if(public_url AND NOT public_url STREQUAL "") #if there is a public URL the package is clonable from a public address
		execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git remote set-url ${remote_name} ${public_url})
		execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git remote set-url --push ${remote_name} ${url})
	else()#default case => same push and fetch address for remote
		execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git remote set-url ${remote_name} ${url})
		execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git remote set-url --push ${remote_name} ${url})
	endif()
endfunction(reconnect_Repository_Remote)

### set the origin remote to a completely new address
function(change_Origin_Repository package url)
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git remote set-url origin ${url} OUTPUT_QUIET ERROR_QUIET)
go_To_Integration(${package})
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git pull origin integration OUTPUT_QUIET ERROR_QUIET)
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git push origin integration OUTPUT_QUIET ERROR_QUIET)
message("[PID] INFO: Origin remote has been changed to ${url}.")
endfunction(change_Origin_Repository)



### getting the project name given a repository address
function(get_Repository_Name RES_NAME git_url)
#testing ssh address
string(REGEX REPLACE "^[^@]+@[^:]+:(.+)$" "\\1" REPO_PATH ${git_url})
if(REPO_PATH STREQUAL "${git_url}")
	#testing https address
	string(REGEX REPLACE "^https?://(.*)$" "\\1" REPO_PATH ${git_url})
	if(REPO_PATH STREQUAL "${git_url}")
		return()
	endif()
endif()
get_filename_component(REPO_NAME ${REPO_PATH} NAME_WE)
set(${RES_NAME} ${REPO_NAME} PARENT_SCOPE)
endfunction(get_Repository_Name)

### checking if package has official and origin remote repositories
function(check_For_Remote_Respositories git_url)
if(git_url STREQUAL "") #no official repository => do nothing
	return()
endif()
is_Package_Connected(CONNECTED ${PROJECT_NAME} official)
if(CONNECTED) #the package has an official remote
	#here check that official address conforms
	get_Remotes_Address(${PROJECT_NAME} RES_OFFICIAL RES_ORIGIN)
	if(NOT ${RES_OFFICIAL} STREQUAL ${git_url})#problem address do not match
		execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${CMAKE_SOURCE_DIR} git remote set-url official ${git_url} OUTPUT_QUIET ERROR_QUIET)
		execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${CMAKE_SOURCE_DIR} git fetch official OUTPUT_QUIET ERROR_QUIET)
		execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${CMAKE_SOURCE_DIR} git fetch official --tags OUTPUT_QUIET ERROR_QUIET)
	#else() nothing to do
	endif()
else()
	# not connected to an official remote while it should => problem => corrective action
	execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${CMAKE_SOURCE_DIR} git remote add official ${git_url} OUTPUT_QUIET ERROR_QUIET)
	execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${CMAKE_SOURCE_DIR} git fetch official OUTPUT_QUIET ERROR_QUIET)
	execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${CMAKE_SOURCE_DIR} git fetch official --tags OUTPUT_QUIET ERROR_QUIET)
endif()
#now checking that there is an origin remote
is_Package_Connected(CONNECTED ${PROJECT_NAME} origin)
if(NOT CONNECTED) #the package has no origin remote => create it and set it to the same address as official
	execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${CMAKE_SOURCE_DIR} git remote add origin ${git_url} OUTPUT_QUIET ERROR_QUIET)
	execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${CMAKE_SOURCE_DIR} git fetch origin OUTPUT_QUIET ERROR_QUIET)
#else we cannot conclude if origin is OK or not as the user may have forked the official project (and so may want to keep another address than official)
endif()
endfunction(check_For_Remote_Respositories)

### checking which remote integration branch can be updated
function(get_Remotes_To_Update REMOTES_TO_UPDATE package)
set(return_list)
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git log --oneline --decorate --max-count=1 OUTPUT_VARIABLE res ERROR_QUIET)
if (NOT "${res}" STREQUAL "")
	string(FIND "${res}" "origin/integration" INDEX_ORIGIN)
	string(FIND "${res}" "official/integration" INDEX_OFFICIAL)
	if(INDEX_ORIGIN LESS 1)
		list(APPEND return_list origin)
	endif()
	if(INDEX_OFFICIAL LESS 1)
		list(APPEND return_list official)
	endif()
endif()

set(${REMOTES_TO_UPDATE} ${return_list} PARENT_SCOPE)
endfunction(get_Remotes_To_Update)

### getting git address of remotes
function(get_Remotes_Address package RES_OFFICIAL RES_ORIGIN)
set(${RES_OFFICIAL} PARENT_SCOPE)
set(${RES_ORIGIN} PARENT_SCOPE)
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git remote -v OUTPUT_VARIABLE RESULTING_REMOTES)
if(RESULTING_REMOTES)
	string(REPLACE "\n" ";" LINES ${RESULTING_REMOTES})
	foreach(remote IN ITEMS ${LINES})
		string(REGEX REPLACE "^([^ \t]+)[ \t]+([^ \t]+)[ \t]+.*$" "\\1;\\2" REMOTES_INFO ${remote})
		list(GET REMOTES_INFO 1 ADDR_REMOTE)
		list(GET REMOTES_INFO 0 NAME_REMOTE)
		if(NAME_REMOTE STREQUAL "official")
			set(${RES_OFFICIAL} ${ADDR_REMOTE} PARENT_SCOPE)
		elseif(NAME_REMOTE STREQUAL "origin")
			set(${RES_ORIGIN} ${ADDR_REMOTE} PARENT_SCOPE)
		endif()
	endforeach()
endif()
endfunction(get_Remotes_Address)

##############################################################################
############## wrappers repository related functions #########################
##############################################################################

###
function(clone_Wrapper_Repository IS_DEPLOYED wrapper url)
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/wrappers git clone ${url} OUTPUT_QUIET ERROR_QUIET)
if(EXISTS ${WORKSPACE_DIR}/wrappers/${wrapper} AND IS_DIRECTORY ${WORKSPACE_DIR}/wrappers/${wrapper})
	set(${IS_DEPLOYED} TRUE PARENT_SCOPE)
	execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/wrappers/${wrapper} git fetch origin OUTPUT_QUIET ERROR_QUIET) #just in case of
else()
	set(${IS_DEPLOYED} FALSE PARENT_SCOPE)
	message("[PID] ERROR : impossible to clone the repository of external package wrapper ${wrapper} (bad repository address or you have no clone rights for this repository). Please contact the administrator of this wrapper.")
endif()
endfunction(clone_Wrapper_Repository)


###
function(init_Wrapper_Repository wrapper)
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/wrappers/${wrapper} git init)
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/wrappers/${wrapper} git add -A)
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/wrappers/${wrapper} git commit -m "initialization of wrapper")
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/wrappers/${wrapper} git lfs track "*.tar.gz" OUTPUT_QUIET ERROR_QUIET)
endfunction(init_Wrapper_Repository)


### registering the address means registering the CMakelists.txt
function(register_Wrapper_Repository_Address wrapper)
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/wrappers/${wrapper} git add CMakeLists.txt)
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/wrappers/${wrapper} git commit -m "adding repository address to the root CMakeLists.txt file")
endfunction(register_Wrapper_Repository_Address)


### first time the wrapper is connected after its creation
function(connect_Wrapper_Repository wrapper url)
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/wrappers/${wrapper} git remote add origin ${url})
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/wrappers/${wrapper} git push origin master OUTPUT_QUIET ERROR_QUIET)
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/wrappers/${wrapper} git fetch origin)
endfunction(connect_Wrapper_Repository)

### rare use function: when official repository has moved
function(reconnect_Wrapper_Repository wrapper url)
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/wrappers/${wrapper} git remote set-url origin ${url})
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/wrappers/${wrapper} git pull origin master)#updating master
endfunction(reconnect_Wrapper_Repository)


### to know whether a wrapper as a remote or not
function(is_Wrapper_Connected CONNECTED wrapper remote)
	execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/wrappers/${wrapper} git remote show ${remote} OUTPUT_QUIET ERROR_VARIABLE res)
	if(NOT res OR res STREQUAL "")
		set(${CONNECTED} TRUE PARENT_SCOPE)
	else()
		set(${CONNECTED} FALSE PARENT_SCOPE)
	endif()
endfunction(is_Wrapper_Connected)

###
function(initialize_Wrapper_Git_Repository_Push_Address package url)
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/wrappers/${package} git remote set-url --push origin ${url})
endfunction(initialize_Wrapper_Git_Repository_Push_Address)

### update the repository of the wrapper
function(update_Wrapper_Repository package)
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/wrappers/${package} git pull origin master OUTPUT_QUIET ERROR_QUIET)#pulling master branch of origin (in case of) => merge can take place
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/wrappers/${package} git lfs pull origin master)#fetching master branch to get most up to date archives
endfunction(update_Wrapper_Repository package)

##############################################################################
############## frameworks repository related functions #######################
##############################################################################

###
function(clone_Framework_Repository IS_DEPLOYED framework url)
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/sites/frameworks git clone ${url} OUTPUT_QUIET ERROR_QUIET)

#framework may be named by only by their name or with a -framework suffix
if(EXISTS ${WORKSPACE_DIR}/sites/frameworks/${framework} AND IS_DIRECTORY ${WORKSPACE_DIR}/sites/frameworks/${framework})
	set(${IS_DEPLOYED} TRUE PARENT_SCOPE)
	execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/sites/frameworks/${framework} git fetch origin OUTPUT_QUIET ERROR_QUIET) #just in case of
else()
	if(EXISTS ${WORKSPACE_DIR}/sites/frameworks/${framework}-framework AND IS_DIRECTORY ${WORKSPACE_DIR}/sites/frameworks/${framework}-framework)
		execute_process(COMMAND ${CMAKE_COMMAND} -E rename ${WORKSPACE_DIR}/sites/frameworks/${framework}-framework ${WORKSPACE_DIR}/sites/frameworks/${framework} OUTPUT_QUIET ERROR_QUIET)
		execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/sites/frameworks/${framework} git lfs pull origin master)#fetching master branch to get most up to date archives
		set(${IS_DEPLOYED} TRUE PARENT_SCOPE)

	else()
		set(${IS_DEPLOYED} FALSE PARENT_SCOPE)
		message("[PID] ERROR : impossible to clone the repository of framework ${framework} (bad repository address or you have no clone rights for this repository). Please contact the administrator of this framework.")
	endif()
endif()
endfunction(clone_Framework_Repository)

###
function(init_Framework_Repository framework)
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/sites/frameworks/${framework} git init)
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/sites/frameworks/${framework} git add -A)
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/sites/frameworks/${framework} git commit -m "initialization of framework")
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/sites/frameworks/${framework} git lfs track "*.tar.gz" OUTPUT_QUIET ERROR_QUIET)
endfunction(init_Framework_Repository)

###
function(update_Framework_Repository framework)
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/sites/frameworks/${framework} git pull origin master OUTPUT_QUIET ERROR_QUIET)#pulling master branch of origin (in case of) => merge can take place
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/sites/frameworks/${framework} git lfs pull origin master)#fetching master branch to get most up to date archives
endfunction(update_Framework_Repository)

###
function(publish_Framework_Repository framework PUBLISHED)
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/sites/frameworks/${framework} git status --porcelain OUTPUT_VARIABLE res)
if(res AND NOT res STREQUAL "")
	execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/sites/frameworks/${framework} git add -A OUTPUT_QUIET ERROR_QUIET)
	execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/sites/frameworks/${framework} git commit -m "publishing new version of framework")
	execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/sites/frameworks/${framework} git pull origin master OUTPUT_QUIET ERROR_QUIET)#pulling master branch of origin to get modifications (new binaries) that would have been published at the same time (most of time a different binary for another plateform of the package)
	execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/sites/frameworks/${framework} git lfs pull origin master OUTPUT_QUIET ERROR_QUIET) #fetching LFS content
	execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/sites/frameworks/${framework} git push origin master OUTPUT_VARIABLE out_push)#pushing to master branch of origin
	set(${PUBLISHED} TRUE PARENT_SCOPE)
else()
	set(${PUBLISHED} FALSE PARENT_SCOPE)
endif()
endfunction(publish_Framework_Repository)

### registering the address means registering the CMakelists.txt
function(register_Framework_Repository_Address framework)
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/sites/frameworks/${framework} git add CMakeLists.txt)
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/sites/frameworks/${framework} git commit -m "adding repository address to the root CMakeLists.txt file")
endfunction(register_Framework_Repository_Address)


### first time the framework is connected after its creation
function(connect_Framework_Repository framework url)
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/sites/frameworks/${framework} git remote add origin ${url})
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/sites/frameworks/${framework} git push origin master OUTPUT_QUIET ERROR_QUIET)
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/sites/frameworks/${framework} git fetch origin)
endfunction(connect_Framework_Repository)

### rare use function: when official repository has moved
function(reconnect_Framework_Repository framework url)
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/sites/frameworks/${framework} git remote set-url origin ${url})
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/sites/frameworks/${framework} git pull origin master)#updating master
endfunction(reconnect_Framework_Repository)


### to know whether a package as a remote or not
function(is_Framework_Connected CONNECTED framework remote)
	execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/sites/frameworks/${framework} git remote show ${remote} OUTPUT_QUIET ERROR_VARIABLE res)
	if(NOT res OR res STREQUAL "")
		set(${CONNECTED} TRUE PARENT_SCOPE)
	else()
		set(${CONNECTED} FALSE PARENT_SCOPE)
	endif()
endfunction(is_Framework_Connected)


### set the origin remote to a completely new address
function(change_Origin_Framework_Repository framework url)
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/sites/frameworks/${framework} git remote set-url origin ${url} OUTPUT_QUIET ERROR_QUIET)
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/sites/frameworks/${framework} git pull origin master OUTPUT_QUIET ERROR_QUIET)
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/sites/frameworks/${framework} git push origin master OUTPUT_QUIET ERROR_QUIET)
message("[PID] INFO: Origin remote has been changed to ${url}.")
endfunction(change_Origin_Framework_Repository)

########################################################################################
############## static site repository repository related functions #####################
########################################################################################

###
function(clone_Static_Site_Repository IS_INITIALIZED BAD_URL package url)
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/sites/packages git clone ${url})

# the static sites may have a different name than its package
extract_Package_Namespace_From_SSH_URL(${url} ${package} NAMESPACE SERVER_ADDRESS EXTENSION)
if(EXTENSION AND NOT EXTENSION STREQUAL "") # there is an extension to the name of the package
	if(EXISTS ${WORKSPACE_DIR}/sites/packages/${package}${EXTENSION} AND IS_DIRECTORY ${WORKSPACE_DIR}/sites/packages/${package}${EXTENSION})
		execute_process(COMMAND ${CMAKE_COMMAND} -E rename ${WORKSPACE_DIR}/sites/packages/${package}${EXTENSION} ${WORKSPACE_DIR}/sites/packages/${package} OUTPUT_QUIET ERROR_QUIET)
	endif()
endif()

if(EXISTS ${WORKSPACE_DIR}/sites/packages/${package} AND IS_DIRECTORY ${WORKSPACE_DIR}/sites/packages/${package})
	set(${BAD_URL} FALSE PARENT_SCOPE) # if the folder exists it means that the official repository exists but it may be still unintialized
	if(EXISTS ${WORKSPACE_DIR}/sites/packages/${package}/build AND IS_DIRECTORY ${WORKSPACE_DIR}/sites/packages/${package}/build
		AND EXISTS ${WORKSPACE_DIR}/sites/packages/${package}/CMakeLists.txt)
		set(${IS_INITIALIZED} TRUE PARENT_SCOPE)
		execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/sites/packages/${package} git fetch origin OUTPUT_QUIET ERROR_QUIET) #just in case of
		execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/sites/packages/${package} git lfs pull origin master)#fetching master branch to get most up to date archives

	else() # the site's repository appear to be non existing
		execute_process(COMMAND ${CMAKE_COMMAND} -E remove_directory ${WORKSPACE_DIR}/sites/packages/${package} OUTPUT_QUIET ERROR_QUIET) #just in case of
		set(${IS_INITIALIZED} FALSE PARENT_SCOPE)
	endif()
else()
	set(${IS_INITIALIZED} FALSE PARENT_SCOPE)
	set(${BAD_URL} TRUE PARENT_SCOPE)
endif()
endfunction(clone_Static_Site_Repository)

###
function(init_Static_Site_Repository CONNECTED package wiki_git_url push_site)
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/sites/packages/${package} git init OUTPUT_QUIET ERROR_QUIET)
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/sites/packages/${package} git remote add origin ${wiki_git_url} OUTPUT_QUIET ERROR_QUIET)
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/sites/packages/${package} git add -f build/.gitignore OUTPUT_QUIET ERROR_QUIET)
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/sites/packages/${package} git lfs track "*.tar.gz" OUTPUT_QUIET ERROR_QUIET) #tracking tar.gz archives with git LFS
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/sites/packages/${package} git add -A OUTPUT_QUIET ERROR_QUIET)
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/sites/packages/${package} git commit -m "initialization of static site project" OUTPUT_QUIET ERROR_QUIET)
if(push_site) #if push is required, then synchronized static site local repository with its official repository
	execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/sites/packages/${package} git push origin master OUTPUT_QUIET ERROR_QUIET)
	#now testing if everything is OK using the git log command
	execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/sites/packages/${package} git log --oneline --decorate --max-count=1 OUTPUT_VARIABLE res ERROR_QUIET)
	if (NOT "${res}" STREQUAL "")
		string(FIND "${res}" "master" INDEX_LOCAL)
		string(FIND "${res}" "origin/master" INDEX_REMOTE)
		if(INDEX_LOCAL GREATER 0 AND INDEX_REMOTE GREATER 0)# both found => the last commit on master branch is tracked by local and remote master branch
			set(${CONNECTED} TRUE PARENT_SCOPE)
			return()
		endif()
	endif()
endif()
set(${CONNECTED} FALSE PARENT_SCOPE)
endfunction(init_Static_Site_Repository)

###
function(update_Static_Site_Repository package)
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/sites/packages/${package} git pull origin master OUTPUT_QUIET ERROR_QUIET)# pulling master branch of origin (in case of) => merge can take place
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/sites/packages/${package} git lfs pull origin master)# pulling master branch of origin (in case of) => merge can take place
endfunction(update_Static_Site_Repository)

###
function(publish_Static_Site_Repository package PUBLISHED)
	execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/sites/packages/${package} git status --porcelain OUTPUT_VARIABLE res)
	if(res AND NOT res STREQUAL "")
		execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/sites/packages/${package} git add -A OUTPUT_QUIET ERROR_QUIET)
		execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/sites/packages/${package} git commit -m "publising ${package} static site" OUTPUT_QUIET ERROR_QUIET)
		execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/sites/packages/${package} git pull origin master OUTPUT_QUIET ERROR_QUIET)#pulling master branch of origin to get modifications (new binaries) that would have been published at the same time (most of time a different binary for another plateform of the package)
		execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/sites/packages/${package} git lfs pull origin master OUTPUT_QUIET ERROR_QUIET) #fetching LFS content
		execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/sites/packages/${package} git push origin master OUTPUT_QUIET ERROR_QUIET)#pushing the package site by pushing to master branch of origin => will induce an automatic management of artefact generation/publication to finally publish the resulting web site
		set(${PUBLISHED} TRUE PARENT_SCOPE)
	else()
		set(${PUBLISHED} FALSE PARENT_SCOPE)
	endif()

endfunction(publish_Static_Site_Repository)
