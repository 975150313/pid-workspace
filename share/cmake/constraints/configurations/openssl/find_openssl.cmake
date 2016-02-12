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

set(openssl_FOUND FALSE CACHE INTERNAL "")
if(UNIX)
	find_path(openssl_INCLUDE_DIR openssl/ssl.h) #searching only in standard paths
	find_library(openssl_SSL_LIBRARY NAMES ssl ssleay32 ssleay32MD)
	find_library(openssl_CRYPTO_LIBRARY NAMES crypto)
	if(NOT openssl_INCLUDE_DIR MATCHES openssl_INCLUDE_DIR-NOTFOUND
	AND NOT openssl_SSL_LIBRARY MATCHES openssl_SSL_LIBRARY-NOTFOUND
	AND NOT openssl_CRYPTO_LIBRARY MATCHES openssl_CRYPTO_LIBRARY-NOTFOUND)
		set(openssl_LIBRARIES ${openssl_SSL_LIBRARY} ${openssl_CRYPTO_LIBRARY})
		unset(openssl_INCLUDE_DIR CACHE)
		unset(openssl_SSL_LIBRARY CACHE)
		unset(openssl_CRYPTO_LIBRARY CACHE)
		set(openssl_FOUND TRUE CACHE INTERNAL "")
	endif()
endif()

