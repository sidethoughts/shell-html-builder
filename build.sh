#!/bin/bash

#config
currentFolder=$(pwd)
htmlFolder="$currentFolder/html/home/"
moduleFolder="$currentFolder/modules/"
newFolder=~/Dokumente/coding/sidethoughts-website/home/
homeFolder=~/Dokumente/coding/sidethoughts-website/home/..


if [[ -e $newFolder ]]; then 
    rm -rf $newFolder #remove build DIR if exists
fi

find_html_files() {
    #finding all files with .html and save them to array
    readarray -t filesArray < <(find $htmlFolder | grep "\.html*$" )
    echo "Found: "${#filesArray[@]}" html files:"
    for i in "${filesArray[@]}"; do
        echo "$i"
        find_in_file "$i"
        
    done
    echo "done"
}

find_in_file() {
    # create array from all @includes in file
    readarray -t includesArray < <(grep '@include' $1 )
    for i in "${includesArray[@]}"; do
        echo "$i"
    done

    fileScr="${1//$htmlFolder/}" #sidethoughts/index.html
    fileName=${fileScr##*/} # index.html
    fileDir=${fileScr%$fileName} #sidethoughts/
    #cp "$1" "$newFolder$fileScr"
    for include in "${includesArray[@]}"; do
        echo "$include"
        if [[ -n $include ]]; then
            echo "found @include in $1"
            moduleName="${include##*-}"
            
            if [[ -e $moduleFolder/$moduleName ]]; then
                echo "module exist"
                replace_html_module_file $include "$moduleFolder$moduleName" $1 $newFolder$fileScr $newFolder$fileDir
            else
                echo file does not exist
            fi
        else
            echo "empty"
        fi
    done
}


#$1=what module e.g. @include-nav.html
#$2= what module to change e.g. ../modules/nav.html
#$3 = file to inspect e.g. ../index.html
#$4 = file to create with module e.g. ../build/index.html
#$5 = build dir e.g. . ../build/.../
replace_html_module_file() {
    #check if build dir exists if not create
    if [ ! -d "$5" ]; then
        mkdir -p "$5"
        echo "Directory '$5' created."
    else
        echo "Directory '$5' already exists."
    fi    
      
    #check if file ($4) exits then read and write in this file
    if [[ -e $4 ]]; then # if exist then
        echo "overwriting because file exists"
        sed -i "/$1/r $2" "$4"
    else # if not copy html with module in new file
        sed "/$1/r $2" "$3" > "$4"
    fi

    #remove @include in new file
    sed -i "/$1/d" "$4"
}

find_html_files

cp "$newFolder"root_index.html $homeFolder/index.html