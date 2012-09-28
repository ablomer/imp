imp is a bash script that integrates NASM, LOAD, GDB, and SCRIPT.


Welcome to the imp wiki!

Recommendation: Copy _imp.sh_ into your assembly project directory.

````
Usage: imp FILE [OPTIONS]

        -v (or --version)       Displays the NASM and IMP versions.

        -b (or --backup)        Creates a directory called 'backup' and
                                saves a copy of the given source-code
                                with a time tag.

        -l (or --log)           Executes SCRIPT and saves the log to a
                                '.log' file with the current date and time.

        -d (or --debug)         Compiles the source-code with debug symbols
                                and executes the result in GDB.

        -r (or --run)           Executes the program after compiling.

        -c (or --clean)         Permanently deletes all files created by
                                NASM or LOAD.

        -w (or --copyright)     Displays copyright details.

        -h (or --help)          Displays this help screen.

````

* Most combination of flags will work.
* Order does not matter.

**Examples**

`imp.sh elfcode.asm` will build and load _elfcode.asm_ with NASM and LOAD, respectively.

`imp.sh elfcode.asm -r` will build, load, and run _elfcode.asm_.

`imp.sh elfcode.asm -r -l` will build, load, and run _elfcode.asm_ in SCRIPT.

`imp.sh elfcode.asm -d` will build (with symbols and list), load, and run _elfcode.asm_ in GDB.

`imp.sh elfcode.asm -d -l` will build (with symbols and list), load, and run _elfcode.asm_ in GDB in SCRIPT.

`imp.sh elfcode.asm -b` will create a folder named 'backup' in the current directory and save a copy of _elfcode.asm_ with a date/time tag.

`imp.sh elfcode.asm -b -r` will save a copy, build, load, and run _elfcode.asm_.

`imp.sh elfcode.asm -b -d` will save a copy, build (with symbols and list), load, and run _elfcode.asm_ in GDB.