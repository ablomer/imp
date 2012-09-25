#!/bin/sh
#
# Given an ASM source-code file, IMP will build it with NASM and load
# it with LOAD.
#
# Copyright (C) 2012 Augusto A. Blomer
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# Created: 09/18/2012
# Updated: 09/24/2012 (v1.1)

# TODO: Add customizable directory options for backup, builds (regular and debug), executables, logs, ...
# TODO: Display GDB and SCRIPT versions, if possible.
# TODO: Use counter instead of date for backups and logs.

# Defaults:
BACKUP=false	# Create a backup folder and source file.
LOG=false	# Create log file with SCRIPT.
DEBUG=false	# Build with symbols and execute in GDB.
RUN=false	# Execute after build.
CLEAN=false	# Delete files created by NASM and GDB.

TITLE="IMP Copyright (C) 2012 Augusto A. Blomer"

VERSION=false
HELP=false
COPYRIGHT=false

# If no parameters were given.
if [ -z "$1" ]; then
	VERSION=true
fi

args=()
# Check for flags and arguments.
until [ -z "$1" ]; do
	case "$1" in
		-v|--version) VERSION=true; shift ;;
		-b|--backup)  BACKUP=true; shift ;;
		-l|--log)  LOG=true; shift ;;
		-d|--debug)  DEBUG=true; shift ;;
		-r|--run)  RUN=true; shift ;;
		-c|--clean)  CLEAN=true; shift ;;
		-h|--help)  HELP=true; shift ;;
		-w|--copyright)  COPYRIGHT=true; shift;;
		-|--) shift ; break ;;
		-*) echo "Invalid option \'$1\'" exit 2 ;;
		*) args+=("$1") ; shift ;;
	esac
done

FILEARG=$args

# If the VERSION flag is set.
if $VERSION ; then
	echo $TITLE
	nasm -v
	exit 0
fi

# If the HELP flag is set.
if $HELP ; then
	echo $TITLE
	nasm -v
	echo
	echo "Usage: imp FILE [OPTIONS]"
	echo
	echo "	-v (or --version)	Displays the NASM and IMP versions."
	echo
	echo "	-b (or --backup)	Creates a directory called 'backup' and"
	echo "				saves a copy of the given source-code"
	echo "				with a time tag."
	echo
	echo "	-l (or --log)		Executes SCRIPT and saves the log to a"
	echo "				'.log' file with the current date and time."
	echo
	echo "	-d (or --debug)		Compiles the source-code with debug symbols"
	echo "				and executes the result in GDB."
	echo
	echo "	-r (or --run)		Executes the program after compiling."
	echo
	echo "	-c (or --clean)		Permanently deletes all files created by"
	echo "				NASM or LOAD."
	echo
	echo "	-w (or --copyright)	Displays copyright details."
	echo
	echo "	-h (or --help)		Displays this help screen."
	echo

	exit 0
fi

# If the COPYRIGHT flag is set.
if $COPYRIGHT ; then

	echo $TITLE
	echo
	echo    "This program is free software: you can redistribute it and/or modify"
	echo    "it under the terms of the GNU General Public License as published by"
	echo    "the Free Software Foundation, either version 3 of the License, or"
	echo    "(at your option) any later version."
	echo
	echo    "This program is distributed in the hope that it will be useful,"
	echo    "but WITHOUT ANY WARRANTY; without even the implied warranty of"
	echo    "MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the"
	echo    "GNU General Public License for more details."
	echo
	echo    "You should have received a copy of the GNU General Public License"
	echo    "along with this program.  If not, see <http://www.gnu.org/licenses/>."
	echo

	exit 0

fi

# If the file does not exist or is empty.
if [ ! -s "$FILEARG" ]; then
	echo The file \'$FILEARG\' does not exist or may be empty.
	exit 2
fi

# Get the file name.
FILENAME=`echo $FILEARG | cut -d'.' -f 1`

# Get the file extension.
FILEEXT=`echo $FILEARG | cut -d'.' -f 2`

# If the file extenstion is NOT 'asm'.
if [ `echo "asm" | tr [:upper:] [:lower:]` != `echo $FILEEXT | tr [:upper:] [:lower:]` ]; then
	echo The file type \'$FILEEXT\' is not supported.
	exit 2
fi

NOW=$(date +"%F_%T")

# If the backup flag is set.
if $BACKUP ; then
	mkdir -p ./backup
	cp ./$FILEARG ./backup/$FILENAME.$NOW.$FILEEXT
fi

# Get the name of the 'o' file created by NASM to pass to LOAD.
LOADEXT=".o"
LOADFILE=$FILENAME$LOADEXT

# Get the name of the 'lst' file created by NASM to pass to GDB.
LSTEXT=".lst"
LSTFILE=$FILENAME$LSTEXT

# Clean the directory.
rm -f ./$LSTFILE ./$LOADFILE ./a.out

# If the CLEAN flag is set.
if $CLEAN ; then
	echo Directory cleaned.
	exit 0
fi

# If the DEBUG flag is set.
if $DEBUG ; then
	# Compile with NASM with debugging symbols.
	nasm -f elf -g -l ./$LSTFILE ./$FILEARG

	# LOAD (link) the file.
	ld ./$LOADFILE

	if $LOG ; then
		# Run GDB in SCRIPT.
		script -c gdb ./a.out $NOW.log

	else
		# Run the executable created by LOAD in GDB.
		gdb ./a.out

	fi

# Else-if the RUN flag is set.
elif $RUN ; then
	# Compile with NASM.
	nasm -f elf ./$FILEARG

	# LOAD (link) the file.
	ld ./$LOADFILE

	if $LOG ; then
		# Run the executable created by LOAD in SCRIPT.
		script -c ./a.out $NOW.log

	else
		# Run the executable created by LOAD.
		./a.out

	fi

else
	# Compile with NASM.
	nasm -f elf ./$FILEARG

	# LOAD (link) the file.
	ld ./$LOADFILE

	if $LOG ; then
		# Run SCRIPT.
		script $NOW.log

	fi

	echo Build complete.

fi
