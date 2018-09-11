#! /bin/bash


############### Houskeeping and pre-processing #####################################      

######  testing codeblock, clean up last run #####
    rm -rf ./metadata 
    echo -ne "\\n Metadata directory cleaned! \\n\\n" 
######  testing codeblock, clean up last run #####

#make current working directory cwd a variable
    CWD=$(pwd)
#count number of files
    FILE_COUNT=$(find "$CWD"  ! -iname "*.sh" ! -iname "*.log" -type f | wc -l)

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
    EXCL=$((basename "$0") | tee "$META/_EXCLUDE.log")
    echo -ne "\\n Exclude Script file from processing: "$EXCL "\\n\\n"         
    printf "\\n Metadata directory is $META \\n\\n"                                                  
    shopt -s extglob
#exclude directory and other files file from processing
    ls -R ./metadata_v1.5 >> "$META/_EXCLUDE.log"
    ls -R ./metadata >> "$META/_EXCLUDE.log"
    ls *.sh >> "$META/_EXCLUDE.log" | ls *.log >> "$META/_EXCLUDE.log"
    EXCLDIR1=$(ls -R "metadata_v1.5")                                       #Create exclude variables 
    EXCLDIR2=$(ls -R "metadata")
    EXCLFILES=$(ls *.sh ; ls *.log )

####################################################################################
#Declare fnFindDup()
#08/01/18 Adapted from original source code Find Duplicate File Names - By Dev (dk_mahadeva@yahoo.com)
#reference https://www.linuxquestions.org/questions/linux-newbie-8/how-to-list-duplicate-filenames-917457/
fnFindDup() {
    path=$1
    : ${path:=.}
    fullList=$(find `pwd` $path | grep -v '^\.' | grep -vFf "$META/_EXCLUDE.log" | awk -F '/' '{print $NF,$0}' | sort +0 -1)
    fileNames=$(find `pwd` $path | grep -v '^\.' | grep -vFf "$META/_EXCLUDE.log" | awk -F '/' '{print $NF}' | sort | uniq -d)
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
   
 #create .log for array processing and count log for metadata processing range variable
    for EACH in $fileNames; do
       echo "$fullList" | grep -wE "^$EACH " >> "$META/_dupArray.log"
       echo "$fullList" | grep -wE "^$EACH " | wc -l  >> "$META/_dupCount.log" 
    done
    }
####################################################################################
#Declare fnCreateDupArray()
fnCreateDupArray() {
    array=()
    IFS=''                                                  #Preserve whitespace in filename #IFS is input field separator
    while read line ; do    
         array+=("$line")
         #echo "reading duplicates.log"
    done < "$META/_dupArray.log"                            #_dupArray.txt as input
            
    #Verify Array - loops through array for each item
    echo -ne "\\n***View Array data***\\n"
    echo -ne "\\nArray size: ${#array[*]}"
    echo -ne "\\nArray items and indexes:"
    for index in ${!array[@]}
    do
        printf  "\\n%4d: %s\\n" "$index" "${array[$index]}"   
    done
    #exit 0
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
    DUPCOUNT="$end"
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
                        current=$(echo "${array[$start]}" | awk -F '^[^ ]*\\s' '{print $2}')  #Regex to split each line in array
                        printf "Range:$range X:$x Y:$y   Item:  "${array[$start]}"\\n"
                        printf "Start:$start Stop:$stop \\n" 
                        #printf "Current: $current \\n"    
                        
                        #METADATA PROCESSING HERE FOR DUPLICATE FILES IN EACH RANGE
                        #APPEND THE TXT OUTPUTS WITH -($INCREMENT)              
                        #INCREMENT ALL DUPLICATES IN A RANGE 
                        ls "$current" -laR --full-time --author > "$META"/"$(basename "$current")"_"metadata_ls-"$x".txt" 2>>        "$META"/"_error.log" 
                        ls "$current" -lARu --full-time > "$META"/"$(basename "$current")"_"metadata_ls_access-"$x".txt" 2>> "$META"/"_error.log"                   
                start=$stop
            done 
      done < "$META/_dupCount.log" 
      echo -ne "\\n\\t**** Duplicate File Processing completed! ****\\n"
    }
####################################################################################
#Declare fnFindNonDup() fnListNonDup() and fnCreateDupArray()
#Find all non duplicate files for processing; exclude certain files and directories; 
#Create array for processing by fnMetadata()
#08/01/18 Adapted from original source code Find Duplicate File Names - By Dev (dk_mahadeva@yahoo.com)
#reference https://www.linuxquestions.org/questions/linux-newbie-8/how-to-list-duplicate-filenames-917457/

fnFindNonDup() {
    echo "$fileNames" >> "$META/_EXCLUDE.log"                              #exclude duplicate processing files
    ls -R metadata >> "$META/_EXCLUDE.log"                                 #exclude metadata processing files
    #EXCLDIR2=$(ls -r metadata)                                            #variable for possible use later
    echo -ne "\\n\\t*** See Exclude log for list of excluded files*** \\n" 
        
    #Create list with path and filename list, excluding .sh, .log and $META dirs 
    fullList2=$( find . "$CWD" | grep -v '^\.' | grep -vFf "$META/_EXCLUDE.log" | awk -F '/' '{print $NF,$0}' )   
    fileNames2=$( find . "$CWD" -type f | grep -vFf "$META/_EXCLUDE.log" | awk -F '/' '{print $NF}' )  #get only files with -type f
     }

#Declare fnListNonDup()
fnListNonDup() {
    echo -ne "\\n\\t*** List and count of NON-DUPLICATE files & path*** \\n"
   
    #testing code
    #for EACH in $fileNames2; do
        #echo "$fullList2" | grep -wE "^$EACH " > /dev/null
      	#echo "$fullList2" | grep -wE "^$EACH " | wc -l   > /dev/null      #wc -l count for processing 
    #done
   
    #create .log for array processing and count log
    for EACH in $fileNames2; do
       echo "$fullList2" | grep -wE "^$EACH " >> "$META/_NonDupArray2.log"
       #echo $EACH 
    done
    echo "$fullList2" | grep -wE "^$EACH " | wc -l  >> "$META/_NonDupCount2.log" 
    NONDUP=$(cat "$META/_NonDupCount2.log")
    }

#Declare fnCreateNonDupArray()
#Create array of non-duplicate files from _NonDupArray2.log
fnCreateNonDupArray() {
    array2=()
    IFS=''                                                  #Preserve whitespace in filename #IFS is input field separator
    while read line ; do    
         array2+=("$line")
    done < "$META/_NonDupArray2.log"                        
#Verify Array - loops through array for each item
    echo -ne "\\n\\t*** View Non-Dup Array data ***\\n"
    echo -ne "\\nArray size: ${#array2[*]}"
    echo -ne "\\nArray items and indexes:"
    for index in ${!array2[@]}
    do
        printf  "\\n%4d: %s\\n" "$index" "${array2[$index]}" 
    done
    }

####################################################################################
#Process outputs
#Declare fnMetadata()
fnMetadata() {
    echo -ne "\\n\\t***Starting Processing of NON-DUPLICATE files***\\n"
    #create variables needed for NON-DUPLICATE file processing
    fnFindNonDup
    fnListNonDup
    fnCreateNonDupArray
    #testing code
        
    #set iteration variables   
    end="${#array2[*]}"
    next=0                                      
    start=0                 #array index position
    stop=0
    NONDUPCOUNT="$end"
    echo -ne "\\n***Array End Value: $end ***\\n"
    
    #Set range and process all items in array of non-duplicates ($array2); start at postion zero
    while read line ; do
        range=$line
         
            #Get each individual item in a range of non-duplicates
            for (( x=$next; x<$range; x++ )); do                                       
                    stop=$(( start + 1 ))
                        shopt -s dotglob
                        #Create terminal output for script log file  
                        echo -ne "\\nProcess non-duplicates in a range\\n"
                        current=$(echo "${array2[$start]}" | awk -F '[^ ]*\\s/' '{print "/" $2}' ) #Regex split line                        
                        printf "Range:$range X:$x Y:$y   Item:  "${array2[$start]}"\\n"
                        printf "Start:$start Stop:$stop \\n"    
                        printf "Current: $current \\n" 
                        
                        #METADATA PROCESSING HERE FOR NON-DUPLICATE FILES IN EACH RANGE
                        #APPEND THE TXT OUTPUTS WITH -($INCREMENT)              
                        ls "$current" -laR --full-time --author > "$META"/"$(basename "$current")"_"metadata_ls-"$x".txt"\
                        2>> "$META"/"_error.log"           
                        #08/30/18 increment non-dup output?
                        ls "$current" -lARu --full-time > "$META"/"$(basename "$current")"_"metadata_ls_access-"$x".txt"\
                        2>> "$META"/"_error.log"                   
                start=$stop
            done 
      done  < "$META/_NonDupCount2.log"
      echo -ne "\\n\\t**** NON-DUPLICATE File Processing completed! ****\\n"            
}

####################################################################################
#CALL MAIN FUNCTIONS to start file processing, call other functions, create outputs
fnDupMetadata
fnMetadata

#echo file counts, processing time and end
    echo -ne "\\n\\n Total number of Duplicate files in " "$CWD" "File Count: " $DUPCOUNT
    echo -ne "\\n\\n Total number of Non-Duplicate files in " "$CWD" "File Count: " $NONDUP
    echo -ne "\\n\\n Total number of files in " "$CWD" "File Count: " $FILE_COUNT
    echo -ne "\\n\\n Finish Total number of new files created in metadata dir: " $(find "$META" -type f | wc -l) "\\n"
    echo -ne "\\n\\t**** $EXCL Script Processing is finished! ****\\n\\n\\n"
    echo -ne " \\n Processing Time \\n"
    trap times EXIT 

