set(CUDA_Language_AVAILABLE FALSE CACHE INTERNAL "")

if(CMAKE_MAJOR_VERSION GREATER 3
OR (CMAKE_MAJOR_VERSION EQUAL 3 AND CMAKE_MINOR_VERSION GREATER 7))
  set(CUDA_CMAKE_SUPPORT "NEW" CACHE INTERNAL "")#WIth CMake 3.8+ CUDAis managed as any language
else()
  set(CUDA_CMAKE_SUPPORT "OLD" CACHE INTERNAL "")
endif()

set(CUDA_USE_STATIC_CUDA_RUNTIME OFF CACHE INTERNAL "")
set(CUDA_LIBRARIES CACHE INTERNAL "")
set(CUDA_INCLUDE_DIRS CACHE INTERNAL "")
find_package(CUDA)
if(NOT CUDA_FOUND)#simply stop the configuration
  message("[PID] WARNING : CUDA language is not supported because no CUDA compiler has been found.")
  return()
endif()

#setting general variables
set(CUDA_Language_AVAILABLE TRUE CACHE INTERNAL "")
#memorizing build variables
set(CUDA_LIBRARIES ${CUDA_LIBRARIES} CACHE INTERNAL "" FORCE)
set(CUDA_INCLUDE_DIRS ${CUDA_INCLUDE_DIRS} CACHE INTERNAL "" FORCE)
set(CMAKE_CUDA_COMPILER ${CUDA_NVCC_EXECUTABLE} CACHE FILEPATH "" FORCE)
set(CMAKE_CUDA_HOST_COMPILER ${CUDA_HOST_COMPILER} CACHE FILEPATH "" FORCE)
mark_as_advanced(CMAKE_CUDA_COMPILER CMAKE_CUDA_HOST_COMPILER)

check_language(CUDA)
if(CMAKE_CUDA_COMPILER)
  enable_language(CUDA)
else()
  message(STATUS "No CUDA support")
endif()

set(__cuda_arch_bin)
set(__cuda_arch_ptx)


# Check which arch can be computed depending on the version of NVCC
if(CUDA_VERSION VERSION_LESS "6.0")#CUDA not really managed under version 6
  set(AVAILABLE_CUDA_ARCHS "2.0" "2.1" "3.0" "3.2" "3.5" CACHE INTERNAL "")
elseif(CUDA_VERSION VERSION_LESS "8.0")
  set(AVAILABLE_CUDA_ARCHS  "2.0" "2.1" "3.0" "3.2" "3.5" "5.0" "5.2" CACHE INTERNAL "")
elseif(CUDA_VERSION VERSION_LESS "9.0")
  set(AVAILABLE_CUDA_ARCHS  "2.0" "2.1" "3.0" "3.2" "3.5" "5.0" "5.2" "6.0" "6.1" CACHE INTERNAL "")
else()#version is greater than 9, deprecated arch are 201 21, etc.
  set(AVAILABLE_CUDA_ARCHS  "3.0" "3.2" "3.5" "5.0" "5.2" "6.0" "6.1" "6.2" "7.0" "7.2" "7.5" CACHE INTERNAL "")
endif()

# detecting current CUDA architecture on host, if any
# goal is to set default values for used architectures
execute_process( COMMAND "${CUDA_NVCC_EXECUTABLE}" "${WORKSPACE_DIR}/share/cmake/platforms/DetectCudaArch.cu" "--run"
                   WORKING_DIRECTORY "${CMAKE_BINARY_DIR}"
                   RESULT_VARIABLE _nvcc_res OUTPUT_VARIABLE _nvcc_out
                   ERROR_QUIET OUTPUT_STRIP_TRAILING_WHITESPACE)

if(_nvcc_res EQUAL 0)#OK default arch has been found
  list(GET _nvcc_out 0 nb_devices)
  set(nb_device_managed 0)
  while(nb_device_managed LESS nb_devices)
    math(EXPR nb_device_managed "${nb_device_managed}+1")#increment first to use it in list(GET)
    list(GET _nvcc_out ${nb_device_managed} device_managed)
    list(APPEND using_arch ${device_managed})
  endwhile()
  math(EXPR nb_device_managed "${nb_device_managed}+1")
  list(GET _nvcc_out ${nb_device_managed} driver_version)
  math(EXPR nb_device_managed "${nb_device_managed}+1")
  list(GET _nvcc_out ${nb_device_managed} runtime_version)
  set(DEFAULT_CUDA_ARCH ${using_arch} CACHE INTERNAL "")#there may have more than one arch specified if more than one CPU is used
  set(DEFAULT_CUDA_DRIVER ${driver_version} CACHE INTERNAL "")
  set(DEFAULT_CUDA_RUNTIME ${runtime_version} CACHE INTERNAL "")
else()# choose the default arch among those available (take the greatest version)
  set(DEFAULT_CUDA_ARCH CACHE INTERNAL "")#no default arch means no nvidia card installed
  set(DEFAULT_CUDA_DRIVER CACHE INTERNAL "")#no default driver means no nvidia card installed
  set(DEFAULT_CUDA_RUNTIME CACHE INTERNAL "")#no default runtime means no nvidia card installed
endif()

#set the compiler flags according to the default cuda arch
set(check_flags ${CMAKE_CUDA_FLAGS})
set(list_of_arch)
foreach(flag IN LISTS check_flags)
  if( flag MATCHES "arch=compute_([^,]+),code=sm_([^ \t]+)"
      AND (CMAKE_MATCH_1 STREQUAL CMAKE_MATCH_2))
      list(APPEND list_of_arch ${CMAKE_MATCH_1})
  endif()
endforeach()
# generate flags to tell NVCC to add binaries for the specified GPUs (mostly for a given GPU)

set(RESET_CUDA FALSE)
if(NOT list_of_arch)#flags for arch have not been configured yet
  if(NOT DEFAULT_CUDA_ARCH)
    set(RESET_CUDA TRUE)
  else()
    #first checking tha default CUDA arch are well supported
    foreach(arch IN LISTS DEFAULT_CUDA_ARCH)#we will use default cuda arch
      list(FIND AVAILABLE_CUDA_ARCHS ${arch} INDEX)
      if(INDEX EQUAL -1)#current compiler in use cannot generate code for that architecture
        message("[PID] WARNING: CUDA language is not supported because CUDA compiler in use (nvcc version ${CUDA_VERSION}) cannot generate code for current platform GPU architecture ${arch}")
        set(RESET_CUDA TRUE)
        break()
      endif()
    endforeach()
    if(NOT RESET_CUDA)#if we can use the default arch
      set(NVCC_FLAGS_EXTRA "")# NVCC flags to be set when using target architectures
      string(REGEX REPLACE "\\." "" ARCH_LIST "${DEFAULT_CUDA_ARCH}")
      foreach(arch IN LISTS ARCH_LIST)#generate flags for those archs
        set(NVCC_FLAGS_EXTRA "${NVCC_FLAGS_EXTRA} -gencode arch=compute_${arch},code=sm_${arch}")
      endforeach()
      set(NVCC_FLAGS_EXTRA "${NVCC_FLAGS_EXTRA} -D_FORCE_INLINES")
      set(CUDA_NVCC_FLAGS ${NVCC_FLAGS_EXTRA} CACHE INTERNAL "" FORCE)
      set(CMAKE_CUDA_FLAGS ${NVCC_FLAGS_EXTRA} CACHE INTERNAL "" FORCE)
    endif()
  endif()
endif()
if(RESET_CUDA)
  #setting general variables
  set(CUDA_Language_AVAILABLE FALSE CACHE INTERNAL "")
  unset(CUDA_LIBRARIES CACHE)
  unset(CUDA_INCLUDE_DIRS CACHE)
  unset(DEFAULT_CUDA_ARCH CACHE)
  unset(DEFAULT_CUDA_DRIVER CACHE)
  unset(DEFAULT_CUDA_RUNTIME CACHE)
  unset(AVAILABLE_CUDA_ARCHS CACHE)
  unset(CUDA_VERSION CACHE)
  unset(CUDA_NVCC_EXECUTABLE CACHE)
  unset(CUDA_NVCC_FLAGS CACHE)
  unset(CUDA_FOUND)
endif()
