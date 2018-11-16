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

include(Configuration_Definition NO_POLICY_SCOPE)

found_PID_Configuration(opengl FALSE)

if(UNIX)
	set(OPENGL_LIBS)
	set(OPENGL_INCS)
	#searching only in standard paths
	if(APPLE)
		find_path(opengl_INCLUDE_DIR OpenGL/gl.h)
		find_path(opengl_glfw3_INCLUDE_DIR NAMES GLFW/glfw3.h)

		find_library(opengl_gl_LIBRARY OpenGL)
		find_library(opengl_agl_LIBRARY AGL)
		find_library(opengl_glfw3_LIBRARY glfw)
		if(NOT opengl_INCLUDE_DIR MATCHES opengl_INCLUDE_DIR-NOTFOUND
				AND NOT opengl_glfw3_INCLUDE_DIR MATCHES opengl_glfw3_INCLUDE_DIR-NOTFOUND
				AND NOT opengl_agl_LIBRARY MATCHES opengl_agl_LIBRARY-NOTFOUND
				AND NOT opengl_gl_LIBRARY MATCHES opengl_gl_LIBRARY-NOTFOUND
				AND NOT opengl_glfw3_LIBRARY MATCHES opengl_glfw3_LIBRARY-NOTFOUND)

			set(OPENGL_LIBS ${opengl_gl_LIBRARY} ${opengl_agl_LIBRARY} ${opengl_glfw3_LIBRARY})
			set(OPENGL_INCS ${opengl_INCLUDE_DIR} ${opengl_glfw3_INCLUDE_DIR})
			convert_PID_Libraries_Into_System_Links(OPENGL_LIBS OPENGL_LINKS)#getting good system links (with -l)
			convert_PID_Libraries_Into_Library_Directories(OPENGL_LIBS OPENGL_LIBDIRS)
			found_PID_Configuration(opengl TRUE)
		endif()
		unset(opengl_INCLUDE_DIR CACHE)
		unset(opengl_glfw3_INCLUDE_DIR CACHE)
		unset(opengl_gl_LIBRARY CACHE)
		unset(opengl_agl_LIBRARY CACHE)
		unset(opengl_glfw3_LIBRARY CACHE)
	else()
		#search headers only in standard path
		find_path(opengl_INCLUDE_DIR GL/gl.h)
		find_path(opengl_glut_INCLUDE_DIR NAMES GL/glut.h GL/freeglut.h)
		find_path(opengl_glfw3_INCLUDE_DIR NAMES GLFW/glfw3.h)

		#search libraries only in standard path
		find_library(opengl_gl_LIBRARY NAMES GL)
		find_library(opengl_glu_LIBRARY NAMES GLU)
		find_library(opengl_glut_LIBRARY NAMES glut)
		find_library(opengl_glfw3_LIBRARY NAMES glfw)
		if(NOT opengl_INCLUDE_DIR MATCHES opengl_INCLUDE_DIR-NOTFOUND
				AND NOT opengl_glut_INCLUDE_DIR MATCHES opengl_glut_INCLUDE_DIR-NOTFOUND
				AND NOT opengl_glfw3_INCLUDE_DIR MATCHES opengl_glfw3_INCLUDE_DIR-NOTFOUND
				AND NOT opengl_gl_LIBRARY MATCHES opengl_gl_LIBRARY-NOTFOUND
				AND NOT opengl_glu_LIBRARY MATCHES opengl_glu_LIBRARY-NOTFOUND
				AND NOT opengl_glut_LIBRARY MATCHES opengl_glut_LIBRARY-NOTFOUND
				AND NOT opengl_glfw3_LIBRARY MATCHES opengl_glfw3_LIBRARY-NOTFOUND)
			set(OPENGL_LIBS ${opengl_gl_LIBRARY} ${opengl_glu_LIBRARY} ${opengl_glut_LIBRARY} ${opengl_glfw3_LIBRARY})
			set(OPENGL_INCS ${opengl_INCLUDE_DIR} ${opengl_glut_INCLUDE_DIR} ${opengl_glfw3_INCLUDE_DIR})
			convert_PID_Libraries_Into_System_Links(OPENGL_LIBS OPENGL_LINKS)#getting good system links (with -l)
			convert_PID_Libraries_Into_Library_Directories(OPENGL_LIBS OPENGL_LIBDIRS)
			found_PID_Configuration(opengl TRUE)
		endif()
		unset(opengl_INCLUDE_DIR CACHE)
		unset(opengl_glut_INCLUDE_DIR CACHE)
		unset(opengl_glfw3_INCLUDE_DIR CACHE)
		unset(opengl_gl_LIBRARY CACHE)
		unset(opengl_glu_LIBRARY CACHE)
		unset(opengl_glut_LIBRARY CACHE)
		unset(opengl_glfw3_LIBRARY CACHE)
	endif()

endif()
