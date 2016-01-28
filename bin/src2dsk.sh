#!/bin/bash
# Version 5
#
# Purpose: Assemble, Link, & Copy a binary to a DOS 3.3 .DSK image without all the cc65 library crap.
# Usage: src2dsk.sh {sourcefile}
#
# Example:
# 1. src2dsk.sh barebones.s
#
#    foo.s   <- input assembly source file
#    foo.o   <- output of assembler
#    foo.bin <- output of linker
#    foo.dsk <- DOS 3.3 disk contaning binary 'FOO'
#
# 2. Mount 'barebones.dsk' in your emulator
#
# If you try BRUN'ing the file the RTS won't exit to DOS 3.3 / BASIC properly.
# A simple work-around is to BLOAD, then run it.
#   3. BLOAD BAREBONES
#   4. CALL -151
#   5. AA72.AA73
#   6  Use whatever addres is displayed (bytes are swapped):
#      1000G
#
# The 'barebones.s' exits via 'JMP $3D0' to warmstart DOS.
#
# You can get a blank DSK here
# * ftp://ftp.apple.asimov.net/pub/apple_II/images/masters/

## wget ftp://ftp.apple.asimov.net/pub/apple_II/images/masters/emptyDSK_Dos33.zip
# curl -# -o EmptyDSK_DOS33.zip ftp://ftp.apple.asimov.net/pub/apple_II/images/masters/emptyDSK_Dos33.zip
#
# I've included an 'empty.dsk' in the repo. for convenience
COPY=cp
DEL=rm

# Verify we have a .s file !
    if [[ -z ${1} ]]; then
        echo "ERROR: need an assembly source file (e.g. foo.s) to build from!"
        exit 1
    fi

# Verify we can find toolchain
# http://www.cc65.org/doc/ca65-2.html#ss2.2
    if [[ -z ${CC65_HOME} ]]; then
        echo "INFO: 'CC65_HOME' not set, should point to directory containing 'ca65', 'ld65'"
        CC65_HOME=../bin
        echo "INFO: Trying '${CC65_HOME}' for assembler and linker"
    fi

# Assembler
    if [ ! -f ${CC65_HOME}/bin/ca65 ]; then
        echo "ERROR: Couldn't find assembler 'ca65' !"
        exit 1
    fi

# Linker
    if [ ! -f ${CC65_HOME}/bin/ld65 ]; then
        echo "ERROR: Couldn't find linker 'ld65' !"
        exit 1
    fi

# Verify we can find a2tools
    if [ ! -f a2in ]; then
        echo "WARNING: Missing a2tools 'a2in', attempting to build"
        echo "INFO: Compiling 'a2tools' ..."
        echo "  gcc -DUNIX a2tools.c -o a2in"
        gcc -DUNIX a2tools.c -o a2in
        ${COPY} a2in a2rm
        ${COPY} a2in a2ls
        if [[ -f a2in ]]; then
            echo "... success!"
        else
            echo "ERROR: a2tools missing: 'a2in'"
            echo " "
            echo "The original tools can be found here:"
            echo " * ftp://ftp.apple.asimov.net/pub/apple_II/utility/"
            echo " * http://slackbuilds.org/repository/14.1/system/a2tools/"
            echo "To download:"
            echo "   curl -o a2tools.zip ftp://ftp.apple.asimov.net/pub/apple_II/utility/a2tools.zip"
            echo "This repo. contains a copy but was unable to compile it."
            exit 1
        fi
    fi

# Filenames and extensions
    #http://stackoverflow.com/questions/965053/extract-filename-and-extension-in-bash
    # Get filename without path
    # Get filename without extension
    DIR=$(dirname "${1}")
    FILENAME=$(basename "${1}")
    FILE="${FILENAME%%.*}"

    DEBUG=
    #DEBUG=echo
    #${DEBUG} "... dir : ${DIR}"
    #${DEBUG} "... name: ${FILENAME}"
    #${DEBUG} "... file: ${FILE}"

    SRC=${FILE}.s
    OBJ=${FILE}.o
    BIN=${FILE}.bin
    DSK=${FILE}.dsk

    ASM_FLAGS="--cpu 65c02"
    LNK_FLAGS="-C apple2bin.cfg"

    #If your code doesn't load below $803 you could alternatively
    #use this to assemble & link
    #CnL_FLAGS="-t apple2enh -C apple2enh-asm.cfg -u __EXEHDR__"

# Assemble & Link
    ${DEBUG} ${DEL}                                ${BIN}   ${OBJ}
    ${DEBUG} ${CC65_HOME}/bin/ca65 ${ASM_FLAGS}          -o ${OBJ} ${DIR}/${SRC}
    ${DEBUG} ${CC65_HOME}/bin/ld65 ${LNK_FLAGS} -o ${BIN}   ${OBJ}

    # Default Linker Config script can't target address < $803
    #${DEBUG} ${CC65_HOME}/bin/cl65 ${CnL_FLAGS} -o ${BIN}          ${SRC} 

if [ -f ${OBJ} ]; then
# Copy to bootable empty DOS 3.3 .DSK
    # We need to uppercase the file name for a DOS 3.3 DSK
    # The ${1,,} is a Bash 4.0 uppercase extension so we can't use that
    # Likewise, GNU sed 's/.*/\L&/g' doesn't work on OSX (BSD)
    A2FILE=`echo "${FILE}" | awk '{print toupper($0)}'`

    if [ ! -f ${DSK} ]; then
        echo "INFO: Using blank disk: ${DSK}"
        ${COPY} emptydos33.dsk ${DSK}
    else
        echo "INFO: Updatig existing disk: ${DSK}"
        # If you want to keep an existing disk then you'll
        # will want to first remove the old file on the .DSK image
        ${DEBUG} a2rm      ${FILE}.dsk ${A2FILE}
    fi

    if [ -f ${BIN} ]; then
        ${DEBUG} a2in -r b ${DSK} ${A2FILE} ${BIN}

    # Debug
        #${CC65_HOME}/bin/od65 --dump-all ${OBJ}

    # Done!
        if [ -f ${DSK} ]; then
            echo "INFO: Created: ${DSK}"
        else
            echo "ERROR: Couldn't create: ${DSK}"
        fi
    else
        echo "ERROR: Failed to link"
    fi
else
    echo "ERROR: Failed to assemble"
fi

