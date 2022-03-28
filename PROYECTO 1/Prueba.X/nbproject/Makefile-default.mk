#
# Generated Makefile - do not edit!
#
# Edit the Makefile in the project folder instead (../Makefile). Each target
# has a -pre and a -post target defined where you can add customized code.
#
# This makefile implements configuration specific macros and targets.


# Include project Makefile
ifeq "${IGNORE_LOCAL}" "TRUE"
# do not include local makefile. User is passing all local related variables already
else
include Makefile
# Include makefile containing local settings
ifeq "$(wildcard nbproject/Makefile-local-default.mk)" "nbproject/Makefile-local-default.mk"
include nbproject/Makefile-local-default.mk
endif
endif

# Environment
MKDIR=gnumkdir -p
RM=rm -f 
MV=mv 
CP=cp 

# Macros
CND_CONF=default
ifeq ($(TYPE_IMAGE), DEBUG_RUN)
IMAGE_TYPE=debug
OUTPUT_SUFFIX=hex
DEBUGGABLE_SUFFIX=elf
FINAL_IMAGE=${DISTDIR}/P_01.X.${IMAGE_TYPE}.${OUTPUT_SUFFIX}
else
IMAGE_TYPE=production
OUTPUT_SUFFIX=hex
DEBUGGABLE_SUFFIX=elf
FINAL_IMAGE=${DISTDIR}/P_01.X.${IMAGE_TYPE}.${OUTPUT_SUFFIX}
endif

ifeq ($(COMPARE_BUILD), true)
COMPARISON_BUILD=
else
COMPARISON_BUILD=
endif

ifdef SUB_IMAGE_ADDRESS

else
SUB_IMAGE_ADDRESS_COMMAND=
endif

# Object Directory
OBJECTDIR=build/${CND_CONF}/${IMAGE_TYPE}

# Distribution Directory
DISTDIR=dist/${CND_CONF}/${IMAGE_TYPE}

# Source Files Quoted if spaced
SOURCEFILES_QUOTED_IF_SPACED=PRINCIPAL.s Configuraciones.s Interrupciones.s Variables.s Multiplexado.s Reloj_Digital.s Fechas.s Timer.s

# Object Files Quoted if spaced
OBJECTFILES_QUOTED_IF_SPACED=${OBJECTDIR}/PRINCIPAL.o ${OBJECTDIR}/Configuraciones.o ${OBJECTDIR}/Interrupciones.o ${OBJECTDIR}/Variables.o ${OBJECTDIR}/Multiplexado.o ${OBJECTDIR}/Reloj_Digital.o ${OBJECTDIR}/Fechas.o ${OBJECTDIR}/Timer.o
POSSIBLE_DEPFILES=${OBJECTDIR}/PRINCIPAL.o.d ${OBJECTDIR}/Configuraciones.o.d ${OBJECTDIR}/Interrupciones.o.d ${OBJECTDIR}/Variables.o.d ${OBJECTDIR}/Multiplexado.o.d ${OBJECTDIR}/Reloj_Digital.o.d ${OBJECTDIR}/Fechas.o.d ${OBJECTDIR}/Timer.o.d

# Object Files
OBJECTFILES=${OBJECTDIR}/PRINCIPAL.o ${OBJECTDIR}/Configuraciones.o ${OBJECTDIR}/Interrupciones.o ${OBJECTDIR}/Variables.o ${OBJECTDIR}/Multiplexado.o ${OBJECTDIR}/Reloj_Digital.o ${OBJECTDIR}/Fechas.o ${OBJECTDIR}/Timer.o

# Source Files
SOURCEFILES=PRINCIPAL.s Configuraciones.s Interrupciones.s Variables.s Multiplexado.s Reloj_Digital.s Fechas.s Timer.s



CFLAGS=
ASFLAGS=
LDLIBSOPTIONS=

############# Tool locations ##########################################
# If you copy a project from one host to another, the path where the  #
# compiler is installed may be different.                             #
# If you open this project with MPLAB X in the new host, this         #
# makefile will be regenerated and the paths will be corrected.       #
#######################################################################
# fixDeps replaces a bunch of sed/cat/printf statements that slow down the build
FIXDEPS=fixDeps

.build-conf:  ${BUILD_SUBPROJECTS}
ifneq ($(INFORMATION_MESSAGE), )
	@echo $(INFORMATION_MESSAGE)
endif
	${MAKE}  -f nbproject/Makefile-default.mk ${DISTDIR}/P_01.X.${IMAGE_TYPE}.${OUTPUT_SUFFIX}

MP_PROCESSOR_OPTION=PIC16F887
FINAL_IMAGE_NAME_MINUS_EXTENSION=${DISTDIR}/P_01.X.${IMAGE_TYPE}
# ------------------------------------------------------------------------------------
# Rules for buildStep: pic-as-assembler
ifeq ($(TYPE_IMAGE), DEBUG_RUN)
${OBJECTDIR}/PRINCIPAL.o: PRINCIPAL.s  nbproject/Makefile-${CND_CONF}.mk 
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/PRINCIPAL.o 
	${MP_AS} -mcpu=PIC16F887 -c \
	-o ${OBJECTDIR}/PRINCIPAL.o \
	PRINCIPAL.s \
	 -D__DEBUG=1  -msummary=+mem,-psect,-class,-hex,-file,-sha1,-sha256,-xml,-xmlfull -fmax-errors=20 -mwarn=0 -xassembler-with-cpp
	
${OBJECTDIR}/Configuraciones.o: Configuraciones.s  nbproject/Makefile-${CND_CONF}.mk 
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/Configuraciones.o 
	${MP_AS} -mcpu=PIC16F887 -c \
	-o ${OBJECTDIR}/Configuraciones.o \
	Configuraciones.s \
	 -D__DEBUG=1  -msummary=+mem,-psect,-class,-hex,-file,-sha1,-sha256,-xml,-xmlfull -fmax-errors=20 -mwarn=0 -xassembler-with-cpp
	
${OBJECTDIR}/Interrupciones.o: Interrupciones.s  nbproject/Makefile-${CND_CONF}.mk 
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/Interrupciones.o 
	${MP_AS} -mcpu=PIC16F887 -c \
	-o ${OBJECTDIR}/Interrupciones.o \
	Interrupciones.s \
	 -D__DEBUG=1  -msummary=+mem,-psect,-class,-hex,-file,-sha1,-sha256,-xml,-xmlfull -fmax-errors=20 -mwarn=0 -xassembler-with-cpp
	
${OBJECTDIR}/Variables.o: Variables.s  nbproject/Makefile-${CND_CONF}.mk 
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/Variables.o 
	${MP_AS} -mcpu=PIC16F887 -c \
	-o ${OBJECTDIR}/Variables.o \
	Variables.s \
	 -D__DEBUG=1  -msummary=+mem,-psect,-class,-hex,-file,-sha1,-sha256,-xml,-xmlfull -fmax-errors=20 -mwarn=0 -xassembler-with-cpp
	
${OBJECTDIR}/Multiplexado.o: Multiplexado.s  nbproject/Makefile-${CND_CONF}.mk 
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/Multiplexado.o 
	${MP_AS} -mcpu=PIC16F887 -c \
	-o ${OBJECTDIR}/Multiplexado.o \
	Multiplexado.s \
	 -D__DEBUG=1  -msummary=+mem,-psect,-class,-hex,-file,-sha1,-sha256,-xml,-xmlfull -fmax-errors=20 -mwarn=0 -xassembler-with-cpp
	
${OBJECTDIR}/Reloj_Digital.o: Reloj_Digital.s  nbproject/Makefile-${CND_CONF}.mk 
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/Reloj_Digital.o 
	${MP_AS} -mcpu=PIC16F887 -c \
	-o ${OBJECTDIR}/Reloj_Digital.o \
	Reloj_Digital.s \
	 -D__DEBUG=1  -msummary=+mem,-psect,-class,-hex,-file,-sha1,-sha256,-xml,-xmlfull -fmax-errors=20 -mwarn=0 -xassembler-with-cpp
	
${OBJECTDIR}/Fechas.o: Fechas.s  nbproject/Makefile-${CND_CONF}.mk 
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/Fechas.o 
	${MP_AS} -mcpu=PIC16F887 -c \
	-o ${OBJECTDIR}/Fechas.o \
	Fechas.s \
	 -D__DEBUG=1  -msummary=+mem,-psect,-class,-hex,-file,-sha1,-sha256,-xml,-xmlfull -fmax-errors=20 -mwarn=0 -xassembler-with-cpp
	
${OBJECTDIR}/Timer.o: Timer.s  nbproject/Makefile-${CND_CONF}.mk 
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/Timer.o 
	${MP_AS} -mcpu=PIC16F887 -c \
	-o ${OBJECTDIR}/Timer.o \
	Timer.s \
	 -D__DEBUG=1  -msummary=+mem,-psect,-class,-hex,-file,-sha1,-sha256,-xml,-xmlfull -fmax-errors=20 -mwarn=0 -xassembler-with-cpp
	
else
${OBJECTDIR}/PRINCIPAL.o: PRINCIPAL.s  nbproject/Makefile-${CND_CONF}.mk 
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/PRINCIPAL.o 
	${MP_AS} -mcpu=PIC16F887 -c \
	-o ${OBJECTDIR}/PRINCIPAL.o \
	PRINCIPAL.s \
	 -msummary=+mem,-psect,-class,-hex,-file,-sha1,-sha256,-xml,-xmlfull -fmax-errors=20 -mwarn=0 -xassembler-with-cpp
	
${OBJECTDIR}/Configuraciones.o: Configuraciones.s  nbproject/Makefile-${CND_CONF}.mk 
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/Configuraciones.o 
	${MP_AS} -mcpu=PIC16F887 -c \
	-o ${OBJECTDIR}/Configuraciones.o \
	Configuraciones.s \
	 -msummary=+mem,-psect,-class,-hex,-file,-sha1,-sha256,-xml,-xmlfull -fmax-errors=20 -mwarn=0 -xassembler-with-cpp
	
${OBJECTDIR}/Interrupciones.o: Interrupciones.s  nbproject/Makefile-${CND_CONF}.mk 
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/Interrupciones.o 
	${MP_AS} -mcpu=PIC16F887 -c \
	-o ${OBJECTDIR}/Interrupciones.o \
	Interrupciones.s \
	 -msummary=+mem,-psect,-class,-hex,-file,-sha1,-sha256,-xml,-xmlfull -fmax-errors=20 -mwarn=0 -xassembler-with-cpp
	
${OBJECTDIR}/Variables.o: Variables.s  nbproject/Makefile-${CND_CONF}.mk 
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/Variables.o 
	${MP_AS} -mcpu=PIC16F887 -c \
	-o ${OBJECTDIR}/Variables.o \
	Variables.s \
	 -msummary=+mem,-psect,-class,-hex,-file,-sha1,-sha256,-xml,-xmlfull -fmax-errors=20 -mwarn=0 -xassembler-with-cpp
	
${OBJECTDIR}/Multiplexado.o: Multiplexado.s  nbproject/Makefile-${CND_CONF}.mk 
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/Multiplexado.o 
	${MP_AS} -mcpu=PIC16F887 -c \
	-o ${OBJECTDIR}/Multiplexado.o \
	Multiplexado.s \
	 -msummary=+mem,-psect,-class,-hex,-file,-sha1,-sha256,-xml,-xmlfull -fmax-errors=20 -mwarn=0 -xassembler-with-cpp
	
${OBJECTDIR}/Reloj_Digital.o: Reloj_Digital.s  nbproject/Makefile-${CND_CONF}.mk 
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/Reloj_Digital.o 
	${MP_AS} -mcpu=PIC16F887 -c \
	-o ${OBJECTDIR}/Reloj_Digital.o \
	Reloj_Digital.s \
	 -msummary=+mem,-psect,-class,-hex,-file,-sha1,-sha256,-xml,-xmlfull -fmax-errors=20 -mwarn=0 -xassembler-with-cpp
	
${OBJECTDIR}/Fechas.o: Fechas.s  nbproject/Makefile-${CND_CONF}.mk 
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/Fechas.o 
	${MP_AS} -mcpu=PIC16F887 -c \
	-o ${OBJECTDIR}/Fechas.o \
	Fechas.s \
	 -msummary=+mem,-psect,-class,-hex,-file,-sha1,-sha256,-xml,-xmlfull -fmax-errors=20 -mwarn=0 -xassembler-with-cpp
	
${OBJECTDIR}/Timer.o: Timer.s  nbproject/Makefile-${CND_CONF}.mk 
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/Timer.o 
	${MP_AS} -mcpu=PIC16F887 -c \
	-o ${OBJECTDIR}/Timer.o \
	Timer.s \
	 -msummary=+mem,-psect,-class,-hex,-file,-sha1,-sha256,-xml,-xmlfull -fmax-errors=20 -mwarn=0 -xassembler-with-cpp
	
endif

# ------------------------------------------------------------------------------------
# Rules for buildStep: pic-as-linker
ifeq ($(TYPE_IMAGE), DEBUG_RUN)
${DISTDIR}/P_01.X.${IMAGE_TYPE}.${OUTPUT_SUFFIX}: ${OBJECTFILES}  nbproject/Makefile-${CND_CONF}.mk    
	@${MKDIR} ${DISTDIR} 
	${MP_LD} -mcpu=PIC16F887 ${OBJECTFILES_QUOTED_IF_SPACED} \
	-o ${DISTDIR}/P_01.X.${IMAGE_TYPE}.${OUTPUT_SUFFIX} \
	 -D__DEBUG=1  -msummary=+mem,-psect,-class,-hex,-file,-sha1,-sha256,-xml,-xmlfull -mcallgraph=std -Wl,-Map=${FINAL_IMAGE_NAME_MINUS_EXTENSION}.map -mno-download-hex
else
${DISTDIR}/P_01.X.${IMAGE_TYPE}.${OUTPUT_SUFFIX}: ${OBJECTFILES}  nbproject/Makefile-${CND_CONF}.mk   
	@${MKDIR} ${DISTDIR} 
	${MP_LD} -mcpu=PIC16F887 ${OBJECTFILES_QUOTED_IF_SPACED} \
	-o ${DISTDIR}/P_01.X.${IMAGE_TYPE}.${OUTPUT_SUFFIX} \
	 -msummary=+mem,-psect,-class,-hex,-file,-sha1,-sha256,-xml,-xmlfull -mcallgraph=std -Wl,-Map=${FINAL_IMAGE_NAME_MINUS_EXTENSION}.map -mno-download-hex
endif


# Subprojects
.build-subprojects:


# Subprojects
.clean-subprojects:

# Clean Targets
.clean-conf: ${CLEAN_SUBPROJECTS}
	${RM} -r ${OBJECTDIR}
	${RM} -r ${DISTDIR}

# Enable dependency checking
.dep.inc: .depcheck-impl

DEPFILES=$(shell mplabwildcard ${POSSIBLE_DEPFILES})
ifneq (${DEPFILES},)
include ${DEPFILES}
endif
