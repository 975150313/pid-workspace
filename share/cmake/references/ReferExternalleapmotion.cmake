#### referencing external package leapmotion ####
set(leapmotion_PID_Package_AUTHOR _Robin_Passama CACHE INTERNAL "")
set(leapmotion_PID_Package_INSTITUTION _LIRMM: Laboratoire d'Informatique de Robotique et de Microélectronique de Montpellier, www.lirmm.fr CACHE INTERNAL "")
set(leapmotion_PID_Package_CONTACT_MAIL passama@lirmm.fr CACHE INTERNAL "")
set(leapmotion_AUTHORS "Leapmotion company, see https://www.leapmotion.com" CACHE INTERNAL "")
set(leapmotion_LICENSES "leapmotion SDK license agreement, see https://central.leapmotion.com/agreements/SdkAgreement" CACHE INTERNAL "")
set(leapmotion_DESCRIPTION "external package providing wrapper for leapmotion SDK in PID system" CACHE INTERNAL "")
set(leapmotion_CATEGORIES image vision CACHE INTERNAL "")


#declaration of possible platforms
set(leapmotion_AVAILABLE_PLATFORMS linux64cxx11;linux64;linux32 CACHE INTERNAL "")
set(leapmotion_AVAILABLE_PLATFORM_linux64cxx11_OS linux CACHE INTERNAL "")
set(leapmotion_AVAILABLE_PLATFORM_linux64cxx11_ARCH 64 CACHE INTERNAL "")
set(leapmotion_AVAILABLE_PLATFORM_linux64cxx11_ABI CXX11 CACHE INTERNAL "")
set(leapmotion_AVAILABLE_PLATFORM_linux64cxx11_CONFIGURATION posix gtk2  CACHE INTERNAL "")
set(leapmotion_AVAILABLE_PLATFORM_linux64_OS linux CACHE INTERNAL "")
set(leapmotion_AVAILABLE_PLATFORM_linux64_ARCH 64 CACHE INTERNAL "")
set(leapmotion_AVAILABLE_PLATFORM_linux64_ABI CXX CACHE INTERNAL "")
set(leapmotion_AVAILABLE_PLATFORM_linux64_CONFIGURATION posix gtk2  CACHE INTERNAL "")
set(leapmotion_AVAILABLE_PLATFORM_linux32_OS linux CACHE INTERNAL "")
set(leapmotion_AVAILABLE_PLATFORM_linux32_ARCH 32 CACHE INTERNAL "")
set(leapmotion_AVAILABLE_PLATFORM_linux32_ABI CXX CACHE INTERNAL "")
set(leapmotion_AVAILABLE_PLATFORM_linux32_CONFIGURATION posix gtk2  CACHE INTERNAL "")

# declaration of known references
set(leapmotion_REFERENCES 2.3.1 CACHE INTERNAL "")
set(leapmotion_REFERENCE_2.3.1 linux64cxx11 linux32 linux64 CACHE INTERNAL "")

#linux 32
set(leapmotion_REFERENCE_2.3.1_linux32_URL https://gite.lirmm.fr/rob-vision-devices/ext-leapmotion/repository/archive.tar.gz?ref=linux32-2.3.1 CACHE INTERNAL "")
set(leapmotion_REFERENCE_2.3.1_linux32_FOLDER ext-leapmotion-linux32-2.3.1-5264ba73ff3ea5316366c5a2f6418dde0948deb7 CACHE INTERNAL "")

#linux 64 
set(leapmotion_REFERENCE_2.3.1_linux64_URL https://gite.lirmm.fr/rob-vision-devices/ext-leapmotion/repository/archive.tar.gz?ref=linux64-2.3.1 CACHE INTERNAL "")
set(leapmotion_REFERENCE_2.3.1_linux64_FOLDER ext-leapmotion-linux64-2.3.1-d0812b511a34aa5740f096048e0f992343bc715b CACHE INTERNAL "")

#linux64cxx11

set(leapmotion_REFERENCE_2.3.1_linux64cxx11_URL https://gite.lirmm.fr/rob-vision-devices/ext-leapmotion/repository/archive.tar.gz?ref=linux64cxx11-2.3.1 CACHE INTERNAL "")
set(leapmotion_REFERENCE_2.3.1_linux64cxx11_FOLDER ext-leapmotion-linux64cxx11-2.3.1-0413faf23bee2ec15b731fb166b1b048fce87435 CACHE INTERNAL "")
