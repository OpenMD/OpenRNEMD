#!/bin/bash
# 
# This script was originally taken from the format-codebase.sh file from the
# Drychem libraries. The code has been modified to match the OpenRNEMD coding
# style.
# 
# Copyright (c) 2020-2021 Cody R. Drisko
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

printHelpMessage()    #@ DESCRIPTION: Print the format-code program's help message
{                     #@ USAGE: printHelpMessage
  printf "\nUSAGE: format-codebase [-h] [-f path] [-i fileName]\n\n"
  printf "  -h  Prints help information about the format-codebase program.\n\n"
  printf "  -f  REQUIRED: Absolute path to clang-format.\n"
  printf "  -i  OPTIONAL: Filename and path (relative to project root) to ignore\n"
  printf "        when formatting.\n\n"
  printf "EXAMPLE: format-codebase -f /opt/local/libexec/llvm-10/bin/clang-format -i \"src/antlr/*\"\n\n"
}

formatFiles()         #@ DESCRIPTION: Use clang-format to format each file in the repository
{                     #@ USAGE: formatFiles LIST
  for elem in "$@"; do
    if [[ -f "$elem" && ("${elem##*.}" == cpp || "${elem##*.}" == hpp) ]]
    then
      for file in "${ignoreFiles[@]}"
      do
        if [[ "$PWD/$elem" == "$file" ]] 
        then
          continue 2;
        fi
      done

      printf "Formatting: %s\n" "$elem"
      "${formatterPath:?Path to clang-format is required.}" -i -style=file "$elem"

    elif [[ -d $elem ]]
    then
      cd "$elem" || ( printf "Could not change into required directory.\n" && exit 1 )

      formatFiles -- *

      cd ../
    fi
  done
}

main()                #@ DESCRIPTION: Execute the main portion of the script's code
{                     #@ USAGE: main LIST
  declare -a ignoreFiles
  declare formatterPath

  local OPTIND opt

  while getopts f:i:h opt
  do
    case $opt in
      f) formatterPath="${OPTARG}" ;;
      i) if [ "${OPTARG:$(( ${#OPTARG} - 1 )):1}" == '*' ]
         then
           for file in $PWD/$OPTARG
           do
             ignoreFiles+=( "$file" )
           done
         else
           ignoreFiles+=( "$PWD/$OPTARG" )
         fi ;;
      h) printHelpMessage && exit 0 ;;
      *) printf "Invalid option flag passed to program.\n" && exit 1 ;;
    esac
  done

  shift $((OPTIND-1))

  formatFiles -- *
}

main "$@"
