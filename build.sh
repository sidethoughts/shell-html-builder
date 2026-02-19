#!/bin/bash

#config
currentFolder=$(pwd)
htmlFolder="$currentFolder/html/home/"
moduleFolder="$currentFolder/modules/"
newFolder=~/Dokumente/coding/sidethoughts-website/home/
newModulesFolder=~/Dokumente/coding/sidethoughts-website/home/modules/
homeFolder=~/Dokumente/coding/sidethoughts-website/home/..


if [[ -e $newFolder ]]; then 
    rm -rf $newFolder #remove build DIR if exists
    echo "removed old"
fi

#checks all modules files for modules as well and copy them to the build directory
check_modules() {
    # remove old modules and copy new ones
    mkdir -p "$newModulesFolder"
    cp -r $moduleFolder $newFolder
    echo "copied modules"

    # create array from all html module files and sending each file to find_in_file
    readarray -t filesArray < <(find $moduleFolder | grep "\.html*$" )
    echo "Found: "${#filesArray[@]}" html files:"
    for i in "${filesArray[@]}"; do
        echo "$i"
        find_in_file "$i" $moduleFolder $newModulesFolder $moduleFolder
    done
    echo "done"
}

find_html_files() {
    #finding all files with .html and save them to array
    readarray -t filesArray < <(find $htmlFolder | grep "\.html*$" )
    echo "Found: "${#filesArray[@]}" html files:"
    for i in "${filesArray[@]}"; do
        echo "$i"
        find_in_file "$i" $htmlFolder $newFolder $newModulesFolder
        
    done
    mv "$newFolder"root_index.html $homeFolder/index.html
    echo "done"

}

#$1 path of the file 
#$2 base dir path htmlFolder or moduleFolder
#$3 dir where to put file newModulesFolder or newFolder
#$4 dir where to look for modules moduleFolder oe newModulesFolder
#looks if file contains @includes and give them to replace_html_module_file
find_in_file() {
    # create array from all @includes in file 
    readarray -t includesArray < <(grep '@include' $1 )
    for i in "${includesArray[@]}"; do
        echo "$i"
    done

    fileScr="${1//$2/}" # eg. /sidethoughts/index.html
    fileName=${fileScr##*/} # eg. index.html
    fileDir=${fileScr%$fileName} #eg. sidethoughts/
    # sends every @includes to replace_html_module_file with some file checks to asure everything is right
    for include in "${includesArray[@]}"; do
        echo "$include"
        if [[ -n $include ]]; then
            echo "found @include in $1"
            moduleName="${include##*-}"
            if [[ -e $moduleFolder/$moduleName ]]; then
                echo "module exist"
                replace_html_module_file $include "$4$moduleName" $1 $3$fileScr "$3$fileDir"
            else
                echo file does not exist
            fi
        else
            echo "empty"
        fi
    done
}


#$1= what module e.g. @include-nav.html
#$2= what module to copy e.g. ../modules/nav.html
#$3 = file to inspect e.g. ../index.html
#$4 = file to create with module e.g. ../build/index.html
#$5 = build dir e.g. . ../build/.../
# replaces @includes-module.html with the module html code from its file
replace_html_module_file() {
    #check if build dir exists if not create
    if [ ! -d "$5" ]; then
        mkdir -p "$5"
        echo "Directory '$5' created."
    else
        echo "Directory '$5' already exists."
    fi    
      
    #check if file ($4) exits already then read and write in this exact file
    if [[ -e $4 ]]; then # if exist then
        echo "overwriting because file exists"
        sed -i "\,$1,r $2" "$4"
    else # if not then copy html with module in new file
    echo $3
        sed "\,$1,r $2" "$3" > "$4"
        echo "file created"
        echo "$1"

    fi

    #remove @include in this file
    sed -i "\,$1,d" "$4"
}

format() {
    readarray -t filesArray < <(find $newFolder | grep "\.html*$" )
    for i in "${filesArray[@]}"; do
        js-beautify $i --type html --replace --indent-size 2 --max-preserve-newlines 0
    done
    js-beautify $homeFolder/index.html --type html --replace --indent-size 2 --max-preserve-newlines 0
}

check_modules
find_html_files
format
