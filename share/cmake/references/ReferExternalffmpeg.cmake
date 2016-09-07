#### referencing external package ffmpeg ####
set(ffmpeg_PID_Package_AUTHOR _Robin_Passama CACHE INTERNAL "")
set(ffmpeg_PID_Package_INSTITUTION _LIRMM: Laboratoire d'Informatique de Robotique et de Microélectronique de Montpellier, www.lirmm.fr CACHE INTERNAL "")
set(ffmpeg_PID_Package_CONTACT_MAIL passama@lirmm.fr CACHE INTERNAL "")
set(ffmpeg_AUTHORS "FFMPEG.org authors, see http://www.ffmpeg.org/" CACHE INTERNAL "")
set(ffmpeg_LICENSES "LGPL v2.1 license" CACHE INTERNAL "")
set(ffmpeg_DESCRIPTION external package providing C++ libraries to manage video streams, repackaged for PID CACHE INTERNAL "")
set(ffmpeg_CATEGORIES programming/video CACHE INTERNAL "")

#declaration of possible platforms
set(ffmpeg_AVAILABLE_PLATFORMS linux64cxx11;linux64;linux32;macosx64 CACHE INTERNAL "")
set(ffmpeg_AVAILABLE_PLATFORM_linux64cxx11_OS linux CACHE INTERNAL "")
set(ffmpeg_AVAILABLE_PLATFORM_linux64cxx11_ARCH 64 CACHE INTERNAL "")
set(ffmpeg_AVAILABLE_PLATFORM_linux64cxx11_ABI CXX11 CACHE INTERNAL "")
set(ffmpeg_AVAILABLE_PLATFORM_linux64cxx11_CONFIGURATION  CACHE INTERNAL "")

set(ffmpeg_AVAILABLE_PLATFORM_linux64_OS linux CACHE INTERNAL "")
set(ffmpeg_AVAILABLE_PLATFORM_linux64_ARCH 64 CACHE INTERNAL "")
set(ffmpeg_AVAILABLE_PLATFORM_linux64_ABI CXX CACHE INTERNAL "")
set(ffmpeg_AVAILABLE_PLATFORM_linux64_CONFIGURATION  CACHE INTERNAL "")
set(ffmpeg_AVAILABLE_PLATFORM_linux32_OS linux CACHE INTERNAL "")
set(ffmpeg_AVAILABLE_PLATFORM_linux32_ARCH 32 CACHE INTERNAL "")
set(ffmpeg_AVAILABLE_PLATFORM_linux32_ABI CXX CACHE INTERNAL "")
set(ffmpeg_AVAILABLE_PLATFORM_linux32_CONFIGURATION  CACHE INTERNAL "")
set(ffmpeg_AVAILABLE_PLATFORM_macosx64_OS macosx CACHE INTERNAL "")
set(ffmpeg_AVAILABLE_PLATFORM_macosx64_ARCH 64 CACHE INTERNAL "")
set(ffmpeg_AVAILABLE_PLATFORM_macosx64_ABI CXX CACHE INTERNAL "")
set(ffmpeg_AVAILABLE_PLATFORM_macosx64_CONFIGURATION  CACHE INTERNAL "")


# declaration of known references
set(ffmpeg_REFERENCES 2.7.1 2.8.2 CACHE INTERNAL "")

######## #version 2.7.1 ###########
set(ffmpeg_REFERENCE_2.7.1 linux64 linux32 CACHE INTERNAL "")

#linux 32
set(ffmpeg_REFERENCE_2.7.1_linux32_URL https://gite.lirmm.fr/pid/ext-ffmpeg/repository/archive.tar.gz?ref=linux-32-2.7.1 CACHE INTERNAL "")
set(ffmpeg_REFERENCE_2.7.1_linux32_FOLDER ext-ffmpeg-linux-32-2.7.1-b005d0ae1584a59850830ffb683e3bdcb274625e CACHE INTERNAL "")
#linux 64
set(ffmpeg_REFERENCE_2.7.1_linux64_URL https://gite.lirmm.fr/pid/ext-ffmpeg/repository/archive.tar.gz?ref=linux-64-2.7.1 CACHE INTERNAL "")
set(ffmpeg_REFERENCE_2.7.1_linux64_FOLDER ext-ffmpeg-linux-64-2.7.1-73e535c5c664ba25ee51f6c48b36df20cd06fd50 CACHE INTERNAL "")

######## #version 2.8.2 ###########
set(ffmpeg_REFERENCE_2.8.2 linux64cxx11 linux64 CACHE INTERNAL "")

#linux 64
set(ffmpeg_REFERENCE_2.8.2_linux64_URL https://gite.lirmm.fr/pid/ext-ffmpeg/repository/archive.tar.gz?ref=linux-64-2.8.2 CACHE INTERNAL "")
set(ffmpeg_REFERENCE_2.8.2_linux64_FOLDER ext-ffmpeg-linux-64-2.8.2-189082e52216ea8f2d92609aa91e7aa664486571 CACHE INTERNAL "")

#linux 64 cxx11
set(ffmpeg_REFERENCE_2.8.2_linux64cxx11_URL https://gite.lirmm.fr/pid/ext-ffmpeg/repository/archive.tar.gz?ref=linux64cxx11-2.8.2 CACHE INTERNAL "")
set(ffmpeg_REFERENCE_2.8.2_linux64cxx11_FOLDER ext-ffmpeg-linux64cxx11-2.8.2-39e2ea773a957f069bf24556bd0c1eabc34c7b0a CACHE INTERNAL "")
