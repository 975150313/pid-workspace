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

##################################################################
######## CMake License file description : Free BSD ###############
##################################################################

set(LICENSE_NAME "FreeBSD")
set(LICENSE_FULLNAME "BSD 2 Clause License")
set(LICENSE_VERSION "1")
set(LICENSE_AUTHORS "the University of California Berkeley")
set(LICENSE_IS_OPEN_SOURCE 		TRUE)

set(	LICENSE_HEADER_FILE_DESCRIPTION
"/*      File: @PROJECT_FILENAME@
*       This file is part of the program ${${PROJECT_NAME}_FOR_LICENSE}
*       Program description : ${${PROJECT_NAME}_DESCRIPTION_FOR_LICENSE}
*       Copyright (C) ${${PROJECT_NAME}_YEARS_FOR_LICENSE} - ${${PROJECT_NAME}_AUTHORS_LIST_FOR_LICENSE}. All Right reserved.
*
*       This software is free software: you can redistribute it and/or modify
*       it under the terms of the ${LICENSE_NAME} license as published by
*       ${LICENSE_AUTHORS}, either version ${LICENSE_VERSION}
*       of the License, or (at your option) any later version.
*       This software is distributed in the hope that it will be useful,
*       but WITHOUT ANY WARRANTY; without even the implied warranty of
*       MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
*       ${LICENSE_NAME} License for more details.
*
*       You should have received a copy of the BSD 2 Clause License
*       along with this software. If not see <http://opensource.org/licenses>.
*/
")

set(	LICENSE_LEGAL_TERMS
"
Software license for the software named : ${${PROJECT_NAME}_FOR_LICENSE}

Software description : ${${PROJECT_NAME}_DESCRIPTION_FOR_LICENSE}

Copyright (C) ${${PROJECT_NAME}_YEARS_FOR_LICENSE} ${${PROJECT_NAME}_AUTHORS_LIST_FOR_LICENSE}

This software is free software: you can redistribute it and/or modify it under the terms of the ${LICENSE_NAME} license as published by
${LICENSE_AUTHORS}, either version ${LICENSE_VERSION} of the License, or (at your option) any later version. This software
is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

Information about license applying to this software:

License : ${LICENSE_NAME}

Official name of the license : ${LICENSE_FULLNAME}

Version of the license : ${LICENSE_VERSION}

License authors : ${LICENSE_AUTHORS}

Additionnal information can be found on the official website of the Open Source Initiative licenses (http://opensource.org/licenses)

Legal terms of the license are reproduced below:

BSD 2 Clause License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

	(1) Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
	(2) Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS \"AS IS\" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
")
