#! /bin/bash

############### Houskeeping and pre-processing ###################################      

######  testing codeblock, clean up last run #####
    rm -rf ./metadata 
    echo -ne "\\n Metadata directory cleaned! \\n\\n" 
######  testing codeblock, clean up last run #####


#make current working directory cwd a variable
    CWD=$(pwd)
#count number of files
    FILE_COUNT=$(find "$CWD" -type f | wc -l)

#make directory and variable metadata, $LOGFILE $ERRFILE $MD5HASH
#these are legacy commands and some may not be used in the current script version
    mkdir metadata
    cd metadata
    META=$(pwd)
    LOGFILE="$META/_script.log"
    exec &> >(tee -ia "$META/_script.log")                                   #Output script log, ignore interr, append file
    MD5HASH="$MD5HASH"
    cd "$CWD"
    echo -ne "\\n Current working directory is: "$CWD "\\n"
#exclude script file from processing
    EXCL=$(basename "$0")
    echo -ne "\\n Exclude Script file from processing: "$EXCL "\\n\\n"         
    printf "\\n Metadata directory is $META \\n\\n"                                                  
    shopt -s extglob

####################################################################################
#Declare fnFindDup()
#08/01/18 Adapted from Find Duplicate File Names - By Dev (dk_mahadeva@yahoo.com)
#reference https://www.linuxquestions.org/questions/linux-newbie-8/how-to-list-duplicate-filenames-917457/
fnFindDup() {
    path=$1
    : ${path:=.}
    fullList=$(find `pwd` $path  ! -iname "$EXCLLOG" | grep -v '^\.' | awk -F '/' '{print $NF,$0}' | sort +0 -1)
    fileNames=$(find `pwd` $path ! -iname "$EXCLLOG" | grep -v '^\.' | awk -F '/' '{print $NF}' | sort | uniq -d)
    }
####################################################################################
#Declare fnListDup()
fnListDup() {
    echo -ne "\\n ***List and count of duplicate files & path*** \\n\\n"
    for EACH in $fileNames; do
        echo "$fullList" | grep -wE "^$EACH " 
      	echo "$fullList" | grep -wE "^$EACH " | wc -l    #wc -l count for duplicate range processing 
    done
    echo -ne "\\n"
   
 #create duplicates.log for array processing and count log for metadata processing range variable
    for EACH in $fileNames; do
       echo "$fullList" | grep -wE "^$EACH " >> "$META/_dupArray.txt"
       echo "$fullList" | grep -wE "^$EACH " | wc -l  >> "$META/_dupCount.txt" 
    done
    }
####################################################################################
#Declare fnCreateDupArray()
fnCreateDupArray() {
    array=()
    IFS=''                                                  #preserve whitespace in filename #IFS is input field separator
    while read line ; do    
         array+=("$line")
    done < "$META/_dupArray.txt"                            #dupArray.log as input
            
    #Verify Array - loops through array for each item
    echo -ne "\\n***View Array data***\\n"
    echo -ne "\\nArray size: ${#array[*]}"
    echo -ne "\\nArray items and indexes:"
    for index in ${!array[@]}
    do
        printf  "\\n%4d: %s\\n" "$index" "${array[$index]}"   
    done
    
    }
####################################################################################
#Declare fnDupMetadata()
fnDupMetadata() {
    #create variables needed for duplicate file metadata processing
    fnFindDup
    fnListDup
    fnCreateDupArray
      
    #set iteration variables   
    end="${#array[*]}"
    next=0                                      
    start=0                 #array index position
    stop=0
    echo -ne "\\n***Array End Value: $end ***\\n"
    
    #Set range and process all items in array of duplicates ($array); start at postion zero
    while read line ; do
        range=$line 
            #Get each individual item in a range of duplicates
            for (( x=$next; x<$range; x++ )); do                                       
                    stop=$(( start + 1 ))
                        shopt -s dotglob
                        
                        #Create terminal output for script log file  
                        echo -ne "\\nProcess duplicates in a range\\n"
                        current=$(echo "${array[$start]}" | awk -F '^[^ ]*\\s' '{print $2}')  #Split line in Array on first whitespace
                        printf "Range:$range X:$x Y:$y   Item:  "${array[$start]}"\\n"
                        printf "Start:$start Stop:$stop \\n"    
                        
                        #METADATA PROCESSING HERE FOR DUPLICATE FILES IN EACH RANGE
                        #APPEND THE TXT OUTPUTS WITH -($INCREMENT)              
                        #INCREMENT ALL DUPLICATES IN A RANGE 
                        ls "$current" -laR --full-time --author > "$META"/"$(basename\
                        "$current")"_"metadata_ls-"$x".txt" 2>> "$META"/"_error.txt" 
                        ls "$current" -lARu --full-time  > "$META"/"$(basename\
                        "$current")"_"metadata_ls_access-"$x".txt" 2>> "$META"/"_error.txt"                   
                start=$stop
            done 
      done < "$META/_dupCount.txt" 
      echo -ne "\\n\\t***** Duplicate File Processing completed! ***** \\n"
    }
####################################################################################
#Declare fnFindNonDup() and fnListNonDup()
fnFindNonDup() {
    echo -ne "\\n ***Create Array of NON-duplicate files & path*** \\n\\n"
    }

fnListNonDup() {
    echo -ne "\\n ***List and count of NON-duplicate files & path*** \\n\\n"
    }

####################################################################################
#Declare fnMetadata()
fnMetadata() {
    echo -ne "\\n ***Starting Metadata Processing of NON-duplicate files*** \\n\\n"
    fnFindNonDup
    fnListNonDup                  
}

####################################################################################
#Start file processing, call functions, create outputs
fnDupMetadata
fnFindNonDup
fnListNonDup
#fnMetadata

#echo file counts, processing time and end
    echo -ne "\\n\\n Start Total number of files in " "$CWD" "File Count: " $FILE_COUNT
    echo -ne "\\n\\n Finish Total number of new files created in metadata dir: " $(find "$META" -type f | wc -l)
    echo -ne "\\n\\n Processing is finished! \\n\\n\\n"
    echo -ne " \\n Processing Time \\n"
    trap times EXIT 

